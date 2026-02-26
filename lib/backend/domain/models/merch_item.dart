import 'package:flutter/material.dart';

enum MerchItemType {
  shirt,
  magnet,
  sticker,
  keychain,
}

class MerchItem {
  final String id;
  final String name;
  final String description;
  final int coinPrice;
  final String? imageUrl; // Supabase Storage URL or null for placeholder
  final MerchItemType type;
  final List<String>? sizes; // Only for shirts
  final String printifyProductId; // Printify API product ID
  final String accentColorHex; // Hex color for UI theming
  final String placeholderIconName; // Material Icon name fallback
  final int sortOrder;
  final bool isActive;

  const MerchItem({
    required this.id,
    required this.name,
    required this.description,
    required this.coinPrice,
    this.imageUrl,
    required this.type,
    this.sizes,
    required this.printifyProductId,
    this.accentColorHex = '#00E5FF',
    this.placeholderIconName = 'shopping_bag',
    this.sortOrder = 0,
    this.isActive = true,
  });

  bool get requiresSize => type == MerchItemType.shirt && sizes != null;

  /// Parse hex color string to Flutter Color
  Color get accentColor {
    try {
      final hex = accentColorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF00E5FF); // cyan fallback
    }
  }

  /// Map placeholder icon name to IconData
  IconData get placeholderIcon {
    return _iconMap[placeholderIconName] ?? Icons.shopping_bag;
  }

  static const Map<String, IconData> _iconMap = {
    'checkroom': Icons.checkroom,
    'rectangle': Icons.rectangle,
    'star': Icons.star,
    'vpn_key': Icons.vpn_key,
    'shopping_bag': Icons.shopping_bag,
    'local_offer': Icons.local_offer,
    'redeem': Icons.redeem,
    'card_giftcard': Icons.card_giftcard,
  };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'coin_price': coinPrice,
        'image_url': imageUrl,
        'type': type.name,
        'sizes': sizes,
        'printify_product_id': printifyProductId,
        'accent_color': accentColorHex,
        'placeholder_icon': placeholderIconName,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  factory MerchItem.fromJson(Map<String, dynamic> json) => MerchItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        coinPrice: json['coin_price'] as int,
        imageUrl: json['image_url'] as String?,
        type: MerchItemType.values.firstWhere(
          (e) => e.name == json['type'],
        ),
        sizes: (json['sizes'] as List<dynamic>?)?.cast<String>(),
        printifyProductId: json['printify_product_id'] as String,
        accentColorHex: json['accent_color'] as String? ?? '#00E5FF',
        placeholderIconName:
            json['placeholder_icon'] as String? ?? 'shopping_bag',
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}
