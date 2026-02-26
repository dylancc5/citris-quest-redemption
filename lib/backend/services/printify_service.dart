import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/cart_item.dart';
import '../domain/models/merch_item.dart';
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
        final orderId = responseData['id']?.toString();
        if (orderId == null) {
          throw PrintifyApiException(
            'Order may have been created but no order ID was returned. '
            'Please contact support before retrying.',
          );
        }

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

  /// Get Printify variant ID based on item type and size.
  ///
  /// Variant IDs sourced from the live Printify shop (shop ID: 26314802).
  /// Last verified: 2026-02-24.
  int _getVariantId(CartItem cartItem) {
    switch (cartItem.item.type) {
      case MerchItemType.shirt:
        // product_id: 697e6475e5c7a4d672063ad5
        // Black unisex tee — size → variant_id
        switch (cartItem.selectedSize) {
          case 'XS':  return 67831;
          case 'S':   return 38164;
          case 'M':   return 38178;
          case 'L':   return 38192;
          case 'XL':  return 38206;
          case '2XL': return 38220;
          case '3XL': return 42122;
          case '4XL': return 66213;
          case '5XL': return 95180;
          default:
            throw PrintifyApiException(
              'Unknown shirt size: ${cartItem.selectedSize}',
            );
        }

      case MerchItemType.magnet:
        // product_id: 699a3f65e570108ad6072c53
        // 2" x 2" Die-Cut
        return 76774;

      case MerchItemType.keychain:
        // product_id: 698fac47ea7b7f223102b3b5
        // Silver / 3" x 3"
        return 149431;

      case MerchItemType.sticker:
        // product_id: 697e623754febb0e950e47fc
        // 2" × 2" White vinyl decal
        return 45748;
    }
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
