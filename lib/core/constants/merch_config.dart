import 'package:flutter/material.dart';
import '../../backend/data/merch_items_service.dart';
import '../../backend/domain/models/merch_item.dart';

/// Thin wrapper around MerchItemsService for backwards compatibility.
///
/// All catalog data (items, prices, sizes) and shop config (XP gate, Printify
/// min balance) are now fetched from Supabase via MerchItemsService.
/// This class provides the same static API that the rest of the app expects.
class MerchConfig {
  /// XP gate threshold — dynamically loaded from merch_config table.
  /// Falls back to 250000 if not yet fetched.
  static int get xpGateThreshold => MerchItemsService().xpGateThreshold;

  /// Printify account balance threshold — dynamically loaded.
  /// Falls back to 100.0 if not yet fetched.
  static double get printifyMinBalance => MerchItemsService().printifyMinBalance;

  /// Active merch items from Supabase (cached in MerchItemsService)
  static List<MerchItem> get items => MerchItemsService().items;

  /// Get accent color for an item
  static Color getAccentColor(MerchItem item) => item.accentColor;

  /// Get accent color by item ID (looks up from cached items)
  static Color getAccentColorById(String itemId) {
    final item = MerchItemsService().getItemById(itemId);
    return item?.accentColor ?? const Color(0xFF00E5FF);
  }

  /// Get placeholder icon for an item
  static IconData getPlaceholderIcon(MerchItem item) => item.placeholderIcon;

  /// Get placeholder icon by item ID (looks up from cached items)
  static IconData getPlaceholderIconById(String itemId) {
    final item = MerchItemsService().getItemById(itemId);
    return item?.placeholderIcon ?? Icons.shopping_bag;
  }

  /// Get item by ID
  static MerchItem? getItem(String id) => MerchItemsService().getItemById(id);
}
