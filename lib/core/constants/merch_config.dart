import 'package:flutter/material.dart';
import '../../backend/data/merch_items_service.dart';
import '../../backend/domain/models/merch_item.dart';
import '../../core/theme.dart';

/// Thin wrapper around MerchItemsService for backwards compatibility.
///
/// Delegates dynamic values (items, XP gate, Printify balance) to the
/// service. Static helpers remain for UI code that references them directly.
class MerchConfig {
  // XP gate threshold — delegates to service, falls back to 250000
  static int get xpGateThreshold => MerchItemsService().xpGateThreshold;

  // Printify account balance threshold — delegates to service, falls back to 100.0
  static double get printifyMinBalance => MerchItemsService().printifyMinBalance;

  // Items from service (empty until MerchItemsService.initialize() completes)
  static List<MerchItem> get items => MerchItemsService().items;

  // Shirt sizes available (kept static — same for all shirts)
  static const List<String> shirtSizes = ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL', '4XL', '5XL'];

  // Per-item accent colors for UI (kept static as AppTheme constants)
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

  // Placeholder icon mappings (kept static as fallbacks)
  static const Map<String, IconData> placeholderIcons = {
    'shirt': Icons.checkroom,
    'magnet': Icons.rectangle,
    'sticker': Icons.star,
    'keychain': Icons.vpn_key,
  };

  // Helper to get placeholder icon for item
  static IconData getPlaceholderIcon(String itemId) {
    return placeholderIcons[itemId] ?? Icons.shopping_bag;
  }

  // Helper to get item by ID
  static MerchItem? getItem(String id) {
    return MerchItemsService().getItemById(id);
  }
}
