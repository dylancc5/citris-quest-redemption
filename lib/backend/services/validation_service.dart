import 'package:flutter/foundation.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/shipping_address.dart';
import '../domain/models/order_result.dart';
import '../data/auth_service.dart';
import '../../core/constants/merch_config.dart';

/// Validation service for merch redemption
///
/// Enforces business rules:
/// - XP gate: Users must have ≥250,000 XP to unlock merch redemption
/// - Coin balance: Users must have sufficient coins for purchase
/// - Address validation: US addresses only with required fields
class ValidationService {
  // Singleton instance
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  final AuthService _authService = AuthService();

  /// Validate purchase eligibility
  ///
  /// Checks:
  /// 1. XP gate (≥250,000 XP) - UNLOCK requirement, NOT spent
  /// 2. Coin balance (sufficient for total cost)
  ///
  /// Returns ValidationResult with success status and error message if failed.
  ValidationResult validatePurchase(List<CartItem> items) {
    // Check if user is logged in
    if (!_authService.isLoggedIn) {
      return ValidationResult.failure('Please log in to continue');
    }

    // Calculate total cost
    final totalCost = items.fold(0, (sum, item) => sum + item.subtotal);

    // Check XP gate (NOT spent, just checked)
    if (_authService.xp < MerchConfig.xpGateThreshold) {
      final remaining = MerchConfig.xpGateThreshold - _authService.xp;
      return ValidationResult.failure(
        'You need $remaining more XP to unlock merch redemption.\n\n'
        'Current XP: ${_authService.xp} / ${MerchConfig.xpGateThreshold}\n\n'
        'Keep playing CITRIS Quest to earn more XP!',
      );
    }

    // Check coin balance
    if (_authService.coins < totalCost) {
      final shortage = totalCost - _authService.coins;
      return ValidationResult.failure(
        'Insufficient coins. You need $shortage more coins.\n\n'
        'Current balance: ${_authService.coins} coins\n'
        'Total cost: $totalCost coins\n\n'
        'Earn coins by scanning artworks in the CITRIS Quest app!',
      );
    }

    debugPrint('ValidationService: Purchase validation passed');
    return ValidationResult.success();
  }

  /// Validate shipping address
  ///
  /// Delegates to ShippingAddress.validate() but adds service-level logging.
  ValidationResult validateAddress(ShippingAddress address) {
    final errors = address.validate();

    if (errors.isNotEmpty) {
      final errorMessages = errors.values
          .where((msg) => msg != null)
          .join('\n');

      debugPrint('ValidationService: Address validation failed: $errorMessages');
      return ValidationResult.failure(
        'Please fix the following address errors:\n\n$errorMessages',
      );
    }

    debugPrint('ValidationService: Address validation passed');
    return ValidationResult.success();
  }

  /// Validate cart is not empty
  ValidationResult validateCartNotEmpty(List<CartItem> items) {
    if (items.isEmpty) {
      return ValidationResult.failure('Your cart is empty');
    }
    return ValidationResult.success();
  }

  /// Validate cart items have required customizations (e.g., shirt sizes)
  ValidationResult validateCartItemCustomizations(List<CartItem> items) {
    for (final cartItem in items) {
      if (cartItem.item.requiresSize && cartItem.selectedSize == null) {
        return ValidationResult.failure(
          '${cartItem.item.name} requires a size selection',
        );
      }
    }
    return ValidationResult.success();
  }

  /// Comprehensive validation for checkout flow
  ///
  /// Runs all validations in sequence and returns first failure.
  ValidationResult validateCheckout(
    List<CartItem> items,
    ShippingAddress address,
  ) {
    // 1. Cart not empty
    var result = validateCartNotEmpty(items);
    if (!result.isValid) return result;

    // 2. Cart items have required customizations
    result = validateCartItemCustomizations(items);
    if (!result.isValid) return result;

    // 3. XP gate + coin balance
    result = validatePurchase(items);
    if (!result.isValid) return result;

    // 4. Shipping address
    result = validateAddress(address);
    if (!result.isValid) return result;

    debugPrint('ValidationService: Checkout validation passed');
    return ValidationResult.success();
  }
}
