import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/merch_order.dart';

/// Service for merch order operations
///
/// Handles CRUD operations for the merch_orders table.
class MerchOrdersService {
  // Singleton instance
  static final MerchOrdersService _instance = MerchOrdersService._internal();
  factory MerchOrdersService() => _instance;
  MerchOrdersService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Insert a new order into the database
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> insertOrder(MerchOrder order) async {
    try {
      // Convert order to JSON for database insertion
      final orderData = {
        'id': order.id,
        'user_id': order.userId,
        'username': order.username,
        'items': order.items.map((item) => item.toJson()).toList(),
        'total_coins': order.totalCoins,
        'shipping_address': order.shippingAddress.toJson(),
        'printify_order_id': order.printifyOrderId,
        'status': order.status.name,
        'created_at': order.createdAt.toIso8601String(),
      };

      await _supabase.from('merch_orders').insert(orderData);

      debugPrint('MerchOrdersService: Successfully inserted order ${order.id}');
      return true;
    } catch (e) {
      debugPrint('MerchOrdersService: Failed to insert order: $e');
      return false;
    }
  }

  /// Get all orders for a specific user
  ///
  /// Returns orders sorted by created_at in descending order (newest first).
  Future<List<MerchOrder>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('merch_orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final orders = (response as List<dynamic>)
          .map((json) => MerchOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        'MerchOrdersService: Fetched ${orders.length} orders for user $userId',
      );
      return orders;
    } catch (e) {
      debugPrint('MerchOrdersService: Failed to fetch orders: $e');
      return [];
    }
  }

  /// Get a specific order by ID
  Future<MerchOrder?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('merch_orders')
          .select()
          .eq('id', orderId)
          .single();

      return MerchOrder.fromJson(response);
    } catch (e) {
      debugPrint('MerchOrdersService: Failed to fetch order $orderId: $e');
      return null;
    }
  }

  /// Update order status (used for Printify webhook updates)
  ///
  /// This would typically be called by a server-side webhook handler,
  /// but included here for completeness.
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? trackingNumber,
    DateTime? shippedAt,
    DateTime? deliveredAt,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status.name};

      if (trackingNumber != null) {
        updateData['tracking_number'] = trackingNumber;
      }
      if (shippedAt != null) {
        updateData['shipped_at'] = shippedAt.toIso8601String();
      }
      if (deliveredAt != null) {
        updateData['delivered_at'] = deliveredAt.toIso8601String();
      }

      await _supabase.from('merch_orders').update(updateData).eq('id', orderId);

      debugPrint(
        'MerchOrdersService: Updated order $orderId status to ${status.name}',
      );
      return true;
    } catch (e) {
      debugPrint('MerchOrdersService: Failed to update order status: $e');
      return false;
    }
  }

  /// Get order count for a user
  Future<int> getUserOrderCount(String userId) async {
    try {
      final response = await _supabase
          .from('merch_orders')
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('MerchOrdersService: Failed to get order count: $e');
      return 0;
    }
  }
}
