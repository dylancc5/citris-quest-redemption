import 'package:flutter/material.dart';
import '../../backend/domain/models/merch_item.dart';
import '../../core/theme.dart';

class MerchConfig {
  // XP gate threshold - users must have at least this much XP to unlock merch redemption
  static const int xpGateThreshold = 250000;

  // Printify account balance threshold - minimum balance to allow checkout
  static const double printifyMinBalance = 100.0;

  // Pricing configuration (coins per item)
  static const Map<String, int> pricing = {
    'shirt': 2500,
    'magnet': 500,
    'sticker': 300,
    'keychain': 800,
  };

  // Shirt sizes available
  static const List<String> shirtSizes = ['S', 'M', 'L', 'XL', '2XL'];

  // Per-item accent colors for card borders, glows, and icons
  static const Map<String, Color> accentColors = {
    'shirt': AppTheme.cyanAccent,
    'magnet': AppTheme.magentaPrimary,
    'sticker': AppTheme.greenPrimary,
    'keychain': AppTheme.yellowPrimary,
  };

  // Helper to get accent color for item
  static Color getAccentColor(String itemId) {
    return accentColors[itemId] ?? AppTheme.cyanAccent;
  }

  // Placeholder icon mappings (Material Icons as strings)
  // Used as fallback when no remote images are available
  static const Map<String, IconData> placeholderIcons = {
    'shirt': Icons.checkroom,
    'magnet': Icons.rectangle,
    'sticker': Icons.star,
    'keychain': Icons.vpn_key,
  };

  // Asset keys for remote product photos stored in game_assets / asset_metadata.
  // Naming convention: 'merch_images/{item_id}_{index}'
  // Add keys here when you add photos via the upload script.
  static const Map<String, List<String>> imageAssetKeys = {
    'shirt': [],
    'magnet': [],
    'sticker': [],
    'keychain': [],
  };

  // Merch items catalog
  static final List<MerchItem> items = [
    MerchItem(
      id: 'shirt',
      name: 'CITRIS Quest T-Shirt',
      description:
          'Premium retro pixel-art design celebrating 25 years of CITRIS innovation. '
          'Comfortable cotton blend, perfect for scanning artworks in style.',
      coinPrice: pricing['shirt']!,
      imageUrl: 'shirt',
      type: MerchItemType.shirt,
      sizes: shirtSizes,
      printifyProductId: 'PRINTIFY_SHIRT_ID',
      imageAssetKeys: imageAssetKeys['shirt'],
    ),
    MerchItem(
      id: 'magnet',
      name: 'CITRIS Quest Magnet',
      description:
          'Space Invader pixel art magnet for your fridge or locker. '
          'Show off your CITRIS Quest achievements IRL.',
      coinPrice: pricing['magnet']!,
      imageUrl: 'magnet',
      type: MerchItemType.magnet,
      printifyProductId: 'PRINTIFY_MAGNET_ID',
      imageAssetKeys: imageAssetKeys['magnet'],
    ),
    MerchItem(
      id: 'sticker',
      name: 'CITRIS Quest Sticker Pack',
      description:
          'Weatherproof vinyl stickers featuring retro game characters. '
          'Includes 5 unique designs from the CITRIS Quest universe.',
      coinPrice: pricing['sticker']!,
      imageUrl: 'sticker',
      type: MerchItemType.sticker,
      printifyProductId: 'PRINTIFY_STICKER_ID',
      imageAssetKeys: imageAssetKeys['sticker'],
    ),
    MerchItem(
      id: 'keychain',
      name: 'CITRIS Quest Keychain',
      description:
          'Premium acrylic keychain with CITRIS branding. '
          'Durable and stylish - keep CITRIS Quest with you everywhere.',
      coinPrice: pricing['keychain']!,
      imageUrl: 'keychain',
      type: MerchItemType.keychain,
      printifyProductId: 'PRINTIFY_KEYCHAIN_ID',
      imageAssetKeys: imageAssetKeys['keychain'],
    ),
  ];

  // Helper to get item by ID
  static MerchItem getItem(String id) {
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Item with ID $id not found'),
    );
  }

  // Helper to get placeholder icon for item
  static IconData getPlaceholderIcon(String itemId) {
    return placeholderIcons[itemId] ?? Icons.shopping_bag;
  }
}
