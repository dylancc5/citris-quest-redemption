import 'package:uuid/uuid.dart';
import 'merch_item.dart';

class CartItem {
  final String id; // Unique cart item ID
  final MerchItem item;
  final int quantity;
  final String? selectedSize; // Required for shirts

  CartItem({
    String? id,
    required this.item,
    required this.quantity,
    this.selectedSize,
  }) : id = id ?? const Uuid().v4();

  int get subtotal => item.coinPrice * quantity;

  // Create a copy with updated fields
  CartItem copyWith({
    String? id,
    MerchItem? item,
    int? quantity,
    String? selectedSize,
  }) =>
      CartItem(
        id: id ?? this.id,
        item: item ?? this.item,
        quantity: quantity ?? this.quantity,
        selectedSize: selectedSize ?? this.selectedSize,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item.toJson(),
        'quantity': quantity,
        'selected_size': selectedSize,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        item: MerchItem.fromJson(json['item'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
        selectedSize: json['selected_size'] as String?,
      );

  // Helper for creating order line items
  Map<String, dynamic> toOrderItem() => {
        'item_id': item.id,
        'item_name': item.name,
        'quantity': quantity,
        'size': selectedSize,
        'coin_price': item.coinPrice,
      };
}
