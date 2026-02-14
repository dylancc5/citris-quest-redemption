import 'shipping_address.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  failed,
  cancelled,
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final String? size;
  final int coinPrice;

  const OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.size,
    required this.coinPrice,
  });

  int get subtotal => quantity * coinPrice;

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'item_name': itemName,
        'quantity': quantity,
        'size': size,
        'coin_price': coinPrice,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        itemId: json['item_id'] as String,
        itemName: json['item_name'] as String,
        quantity: json['quantity'] as int,
        size: json['size'] as String?,
        coinPrice: json['coin_price'] as int,
      );

  factory OrderItem.fromCartItem(CartItem cartItem) => OrderItem(
        itemId: cartItem.item.id,
        itemName: cartItem.item.name,
        quantity: cartItem.quantity,
        size: cartItem.selectedSize,
        coinPrice: cartItem.item.coinPrice,
      );
}

class MerchOrder {
  final String id;
  final String userId;
  final String username;
  final List<OrderItem> items;
  final int totalCoins;
  final ShippingAddress shippingAddress;
  final String printifyOrderId;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;
  final String? errorMessage;

  const MerchOrder({
    required this.id,
    required this.userId,
    required this.username,
    required this.items,
    required this.totalCoins,
    required this.shippingAddress,
    required this.printifyOrderId,
    required this.status,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.trackingNumber,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'items': items.map((item) => item.toJson()).toList(),
        'total_coins': totalCoins,
        'shipping_address': shippingAddress.toJson(),
        'printify_order_id': printifyOrderId,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'shipped_at': shippedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'tracking_number': trackingNumber,
        'error_message': errorMessage,
      };

  factory MerchOrder.fromJson(Map<String, dynamic> json) => MerchOrder(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        username: json['username'] as String,
        items: (json['items'] as List<dynamic>)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCoins: json['total_coins'] as int,
        shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>,
        ),
        printifyOrderId: json['printify_order_id'] as String,
        status: OrderStatus.values.firstWhere(
          (e) => e.name == json['status'],
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        shippedAt: json['shipped_at'] != null
            ? DateTime.parse(json['shipped_at'] as String)
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.parse(json['delivered_at'] as String)
            : null,
        trackingNumber: json['tracking_number'] as String?,
        errorMessage: json['error_message'] as String?,
      );

  MerchOrder copyWith({
    String? id,
    String? userId,
    String? username,
    List<OrderItem>? items,
    int? totalCoins,
    ShippingAddress? shippingAddress,
    String? printifyOrderId,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? trackingNumber,
    String? errorMessage,
  }) =>
      MerchOrder(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        items: items ?? this.items,
        totalCoins: totalCoins ?? this.totalCoins,
        shippingAddress: shippingAddress ?? this.shippingAddress,
        printifyOrderId: printifyOrderId ?? this.printifyOrderId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        shippedAt: shippedAt ?? this.shippedAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
