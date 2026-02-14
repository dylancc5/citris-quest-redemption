import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/shipping_address.dart';
import '../domain/models/merch_order.dart';
import '../domain/models/order_result.dart';
import '../data/auth_service.dart';
import '../data/user_profiles_service.dart';
import '../data/merch_orders_service.dart';
import 'printify_service.dart';
import 'validation_service.dart';
import 'cart_service.dart';

/// Order processing service - orchestrates the full transaction flow
///
/// Critical responsibilities:
/// 1. Pre-validate XP gate + coin balance
/// 2. Create Printify order (external API call)
/// 3. Deduct coins from user profile (atomic DB operation)
/// 4. Save order record to merch_orders table
/// 5. Clear cart and refresh user profile
/// 6. Handle rollback on failures
///
/// Transaction integrity:
/// - Coins are ONLY deducted if Printify order succeeds
/// - If order save fails after coin deduction, log CRITICAL error
/// - Printify order is cancelled if coin deduction fails
class OrderProcessingService {
  // Singleton instance
  static final OrderProcessingService _instance = OrderProcessingService._internal();
  factory OrderProcessingService() => _instance;
  OrderProcessingService._internal();

  final AuthService _authService = AuthService();
  final UserProfilesService _userProfilesService = UserProfilesService();
  final MerchOrdersService _merchOrdersService = MerchOrdersService();
  final PrintifyService _printifyService = PrintifyService();
  final ValidationService _validationService = ValidationService();
  final CartService _cartService = CartService();

  /// Process a merch order
  ///
  /// Returns OrderResult with success status and order data or error message.
  Future<OrderResult> processOrder({
    required List<CartItem> items,
    required ShippingAddress address,
  }) async {
    debugPrint('OrderProcessingService: Starting order processing');

    // ========== STEP 1: Pre-validation ==========
    final validationResult = _validationService.validateCheckout(items, address);
    if (!validationResult.isValid) {
      debugPrint('OrderProcessingService: Validation failed: ${validationResult.errorMessage}');
      return OrderResult.failure(validationResult.errorMessage!);
    }

    // Check Printify account balance
    final hasBalance = await _printifyService.checkAccountBalance();
    if (!hasBalance) {
      debugPrint('OrderProcessingService: Printify account balance too low');
      return OrderResult.failure(
        'Merch redemptions are temporarily unavailable. '
        'Please check back later or contact support.',
      );
    }

    final totalCost = items.fold(0, (sum, item) => sum + item.subtotal);
    final userId = _authService.userId!;
    final username = _authService.username!;
    final userEmail = _authService.email!;

    // ========== STEP 2: Create Printify order ==========
    late PrintifyOrderResponse printifyResponse;
    try {
      printifyResponse = await _printifyService.createOrder(
        items: items,
        address: address,
        userEmail: userEmail,
      );

      if (!printifyResponse.success || printifyResponse.orderId == null) {
        throw PrintifyApiException('Printify order creation returned unsuccessful');
      }
    } catch (e) {
      debugPrint('OrderProcessingService: Printify order creation failed: $e');
      return OrderResult.failure(
        'Order service temporarily unavailable. Please try again in a few minutes.\n\n'
        'Your coins have NOT been deducted.',
      );
    }

    final printifyOrderId = printifyResponse.orderId!;
    debugPrint('OrderProcessingService: Printify order created: $printifyOrderId');

    // ========== STEP 3: Deduct coins from user profile ==========
    final deductionSuccess = await _userProfilesService.deductCoins(
      userId,
      totalCost,
    );

    if (!deductionSuccess) {
      // Rollback: Cancel Printify order
      debugPrint('OrderProcessingService: Coin deduction failed, cancelling Printify order');
      await _printifyService.cancelOrder(printifyOrderId);

      return OrderResult.failure(
        'Failed to process payment. Your coins have NOT been deducted.\n\n'
        'This may be due to concurrent purchases or insufficient balance. '
        'Please try again.',
      );
    }

    debugPrint('OrderProcessingService: Coins deducted successfully');

    // ========== STEP 4: Save order record to database ==========
    final order = MerchOrder(
      id: const Uuid().v4(),
      userId: userId,
      username: username,
      items: items.map(OrderItem.fromCartItem).toList(),
      totalCoins: totalCost,
      shippingAddress: address,
      printifyOrderId: printifyOrderId,
      status: OrderStatus.pending,
      createdAt: DateTime.now().toUtc(),
    );

    final saveSuccess = await _merchOrdersService.insertOrder(order);

    if (!saveSuccess) {
      // CRITICAL ERROR: Coins deducted but order not saved
      // This should trigger admin alert in production
      debugPrint('OrderProcessingService: CRITICAL - Order save failed after coin deduction!');
      debugPrint('OrderProcessingService: Order ID: ${order.id}, Printify Order: $printifyOrderId');

      // Attempt to refund coins
      final refundSuccess = await _userProfilesService.refundCoins(userId, totalCost);
      if (refundSuccess) {
        debugPrint('OrderProcessingService: Coins refunded successfully');
      } else {
        debugPrint('OrderProcessingService: CRITICAL - Coin refund also failed!');
      }

      // Attempt to cancel Printify order
      await _printifyService.cancelOrder(printifyOrderId);

      return OrderResult.failure(
        'Order processing error. Please contact support with this reference:\n\n'
        'Order ID: ${order.id}\n'
        'Printify Order: $printifyOrderId\n\n'
        'We have attempted to refund your coins.',
      );
    }

    debugPrint('OrderProcessingService: Order saved successfully');

    // ========== STEP 5: Clear cart and refresh profile ==========
    _cartService.clear();
    await _authService.refreshProfile();

    debugPrint('OrderProcessingService: Order processing complete');
    return OrderResult.success(order);
  }
}
