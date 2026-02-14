import 'package:flutter/foundation.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/merch_item.dart';

/// Shopping cart service with reactive state management
///
/// Manages cart items with ValueNotifiers for automatic UI updates.
/// Uses singleton pattern for shared state across the app.
class CartService {
  // Singleton instance
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Reactive state
  final ValueNotifier<List<CartItem>> cartItemsNotifier = ValueNotifier([]);

  // Getters
  List<CartItem> get items => cartItemsNotifier.value;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get totalCost => items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Add item to cart
  ///
  /// If item with same ID and size already exists, increment quantity.
  /// Otherwise, add new cart entry.
  void addItem(MerchItem item, {String? size}) {
    // For shirts, size is required
    if (item.requiresSize && size == null) {
      throw ArgumentError('Size is required for ${item.name}');
    }

    final currentItems = List<CartItem>.from(items);

    // Check if item with same ID and size already exists
    final existingIndex = currentItems.indexWhere(
      (cartItem) =>
          cartItem.item.id == item.id && cartItem.selectedSize == size,
    );

    if (existingIndex != -1) {
      // Increment quantity of existing item
      final existing = currentItems[existingIndex];
      currentItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      // Add new item to cart
      currentItems.add(CartItem(
        item: item,
        quantity: 1,
        selectedSize: size,
      ));
    }

    cartItemsNotifier.value = currentItems;
    debugPrint('CartService: Added ${item.name} (size: $size) to cart');
  }

  /// Update quantity of a cart item
  ///
  /// If quantity is 0 or negative, removes the item.
  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final currentItems = List<CartItem>.from(items);
    final index = currentItems.indexWhere((item) => item.id == cartItemId);

    if (index != -1) {
      currentItems[index] = currentItems[index].copyWith(quantity: quantity);
      cartItemsNotifier.value = currentItems;
      debugPrint('CartService: Updated item $cartItemId quantity to $quantity');
    }
  }

  /// Remove item from cart
  void removeItem(String cartItemId) {
    final currentItems = List<CartItem>.from(items);
    currentItems.removeWhere((item) => item.id == cartItemId);
    cartItemsNotifier.value = currentItems;
    debugPrint('CartService: Removed item $cartItemId from cart');
  }

  /// Clear all items from cart
  void clear() {
    cartItemsNotifier.value = [];
    debugPrint('CartService: Cart cleared');
  }

  /// Get cart item by ID
  CartItem? getItemById(String cartItemId) {
    try {
      return items.firstWhere((item) => item.id == cartItemId);
    } catch (e) {
      return null;
    }
  }

  /// Check if specific merch item is in cart
  bool containsItem(String merchItemId, {String? size}) {
    return items.any(
      (cartItem) =>
          cartItem.item.id == merchItemId &&
          (size == null || cartItem.selectedSize == size),
    );
  }

  /// Get total quantity of a specific merch item in cart
  int getItemQuantity(String merchItemId, {String? size}) {
    return items
        .where(
          (cartItem) =>
              cartItem.item.id == merchItemId &&
              (size == null || cartItem.selectedSize == size),
        )
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
