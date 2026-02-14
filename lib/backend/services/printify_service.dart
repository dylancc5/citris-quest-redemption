import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/cart_item.dart';
import '../domain/models/shipping_address.dart';
import '../../core/constants/env.dart';
import '../../core/constants/merch_config.dart';

/// Printify API service for order fulfillment
///
/// Handles:
/// - Creating orders in Printify
/// - Checking order status
/// - Validating account balance
class PrintifyService {
  // Singleton instance
  static final PrintifyService _instance = PrintifyService._internal();
  factory PrintifyService() => _instance;
  PrintifyService._internal();

  static const String _baseUrl = 'https://api.printify.com/v1';

  // API headers
  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${Env.printifyApiToken}',
        'Content-Type': 'application/json',
      };

  /// Create an order in Printify
  ///
  /// Maps cart items to Printify line items format and submits order.
  /// Returns Printify order ID on success.
  Future<PrintifyOrderResponse> createOrder({
    required List<CartItem> items,
    required ShippingAddress address,
    required String userEmail,
  }) async {
    try {
      final lineItems = items.map((cartItem) => _mapToLineItem(cartItem)).toList();

      final orderData = {
        'external_id': 'citris-quest-${DateTime.now().millisecondsSinceEpoch}',
        'label': 'CITRIS Quest Merch Redemption',
        'line_items': lineItems,
        'shipping_method': 1, // Standard shipping (adjust based on Printify config)
        'send_shipping_notification': false, // We'll handle notifications separately
        'address_to': {
          'first_name': address.firstName,
          'last_name': address.lastName,
          'email': userEmail,
          'phone': address.phoneNumber ?? '',
          'country': 'US',
          'region': address.state,
          'address1': address.addressLine1,
          'address2': address.addressLine2 ?? '',
          'city': address.city,
          'zip': address.zipCode,
        },
      };

      final url = Uri.parse('$_baseUrl/shops/${Env.printifyShopId}/orders.json');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final orderId = responseData['id'] as String;

        debugPrint('PrintifyService: Order created successfully: $orderId');
        return PrintifyOrderResponse(
          success: true,
          orderId: orderId,
        );
      } else {
        final errorBody = response.body;
        debugPrint('PrintifyService: Order creation failed: ${response.statusCode} - $errorBody');
        throw PrintifyApiException(
          'Failed to create order: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      debugPrint('PrintifyService: Order creation error: $e');
      rethrow;
    }
  }

  /// Get order status from Printify
  Future<PrintifyOrderStatus?> getOrderStatus(String printifyOrderId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/shops/${Env.printifyShopId}/orders/$printifyOrderId.json',
      );
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PrintifyOrderStatus(
          status: data['status'] as String,
          trackingNumber: data['tracking_number'] as String?,
          trackingUrl: data['tracking_url'] as String?,
        );
      } else {
        debugPrint('PrintifyService: Failed to fetch order status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('PrintifyService: Error fetching order status: $e');
      return null;
    }
  }

  /// Check Printify account balance
  ///
  /// Returns true if balance >= minimum threshold, false otherwise.
  Future<bool> checkAccountBalance() async {
    try {
      final url = Uri.parse('$_baseUrl/shops/${Env.printifyShopId}.json');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Printify API returns balance in cents
        final balanceCents = data['balance'] as int?;
        if (balanceCents == null) {
          debugPrint('PrintifyService: Balance not available in response');
          return true; // Assume OK if balance not returned
        }

        final balanceDollars = balanceCents / 100;
        final hasEnoughBalance = balanceDollars >= MerchConfig.printifyMinBalance;

        debugPrint('PrintifyService: Account balance: \$$balanceDollars (min: \$${MerchConfig.printifyMinBalance})');
        return hasEnoughBalance;
      } else {
        debugPrint('PrintifyService: Failed to check balance: ${response.statusCode}');
        return true; // Assume OK on error to not block users
      }
    } catch (e) {
      debugPrint('PrintifyService: Error checking balance: $e');
      return true; // Assume OK on error
    }
  }

  /// Cancel/delete an order (used for rollback)
  Future<bool> cancelOrder(String printifyOrderId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/shops/${Env.printifyShopId}/orders/$printifyOrderId.json',
      );
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200) {
        debugPrint('PrintifyService: Order $printifyOrderId cancelled successfully');
        return true;
      } else {
        debugPrint('PrintifyService: Failed to cancel order: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('PrintifyService: Error cancelling order: $e');
      return false;
    }
  }

  /// Map CartItem to Printify line item format
  Map<String, dynamic> _mapToLineItem(CartItem cartItem) {
    return {
      'product_id': cartItem.item.printifyProductId,
      'variant_id': _getVariantId(cartItem),
      'quantity': cartItem.quantity,
    };
  }

  /// Get Printify variant ID based on item type and size
  ///
  /// For now, returns placeholder. Dylan will need to provide actual variant IDs
  /// from Printify dashboard based on product + size combinations.
  int _getVariantId(CartItem cartItem) {
    // TODO: Replace with actual Printify variant IDs from Dylan
    // Format: product_id -> size -> variant_id mapping

    if (cartItem.item.id == 'shirt' && cartItem.selectedSize != null) {
      // Example mapping (replace with real IDs):
      // S: 12345, M: 12346, L: 12347, XL: 12348, 2XL: 12349
      switch (cartItem.selectedSize) {
        case 'S': return 12345;
        case 'M': return 12346;
        case 'L': return 12347;
        case 'XL': return 12348;
        case '2XL': return 12349;
      }
    }

    // For non-shirt items, return placeholder variant ID
    return 99999; // Replace with actual variant IDs
  }
}

/// Response from Printify order creation
class PrintifyOrderResponse {
  final bool success;
  final String? orderId;
  final String? errorMessage;

  PrintifyOrderResponse({
    required this.success,
    this.orderId,
    this.errorMessage,
  });
}

/// Printify order status response
class PrintifyOrderStatus {
  final String status; // 'pending', 'processing', 'shipped', etc.
  final String? trackingNumber;
  final String? trackingUrl;

  PrintifyOrderStatus({
    required this.status,
    this.trackingNumber,
    this.trackingUrl,
  });
}

/// Exception thrown when Printify API calls fail
class PrintifyApiException implements Exception {
  final String message;
  PrintifyApiException(this.message);

  @override
  String toString() => 'PrintifyApiException: $message';
}
