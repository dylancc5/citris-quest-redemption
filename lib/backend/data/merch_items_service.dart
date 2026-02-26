import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/merch_item.dart';

/// Service for fetching the merch catalog and shop config from Supabase
///
/// Replaces hardcoded MerchConfig.items with dynamic data from the
/// merch_items and merch_config tables.
class MerchItemsService {
  // Singleton instance
  static final MerchItemsService _instance = MerchItemsService._internal();
  factory MerchItemsService() => _instance;
  MerchItemsService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Reactive list of merch items for UI binding
  final ValueNotifier<List<MerchItem>> itemsNotifier =
      ValueNotifier<List<MerchItem>>([]);

  /// Loading state for initial fetch
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  /// Error state
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);

  // In-memory cache
  List<MerchItem> _items = [];
  bool _hasFetchedItems = false;

  // Config cache (with hardcoded fallbacks)
  int _xpGateThreshold = 250000;
  double _printifyMinBalance = 100.0;
  bool _hasFetchedConfig = false;

  /// Current items list
  List<MerchItem> get items => _items;

  /// XP gate threshold (falls back to 250000 if not yet fetched)
  int get xpGateThreshold => _xpGateThreshold;

  /// Printify minimum balance (falls back to 100.0 if not yet fetched)
  double get printifyMinBalance => _printifyMinBalance;

  /// Whether items have been fetched at least once
  bool get hasFetched => _hasFetchedItems;

  /// Fetch active merch items from Supabase
  ///
  /// Results are cached in memory. Call [refreshItems] to force re-fetch.
  Future<List<MerchItem>> fetchItems() async {
    if (_hasFetchedItems) return _items;

    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    try {
      final response = await _supabase
          .from('merch_items')
          .select()
          .eq('is_active', true)
          .order('coin_price', ascending: true);

      _items = (response as List<dynamic>)
          .map((json) => MerchItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _hasFetchedItems = true;
      itemsNotifier.value = List.unmodifiable(_items);

      debugPrint('MerchItemsService: Fetched ${_items.length} active items');
      return _items;
    } catch (e) {
      debugPrint('MerchItemsService: Failed to fetch items: $e');
      errorNotifier.value =
          'Hmm, the merch shop is having trouble loading right now. '
          'Refresh the page or check back soon!';
      return _items;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Force re-fetch items from Supabase (ignores cache)
  Future<List<MerchItem>> refreshItems() async {
    _hasFetchedItems = false;
    return fetchItems();
  }

  /// Fetch shop config from merch_config table
  ///
  /// Loads xp_gate_threshold and printify_min_balance.
  /// Falls back to hardcoded defaults if fetch fails.
  Future<void> fetchConfig() async {
    if (_hasFetchedConfig) return;

    try {
      final response = await _supabase.from('merch_config').select();

      final configMap = <String, String>{};
      for (final row in (response as List<dynamic>)) {
        final map = row as Map<String, dynamic>;
        configMap[map['key'] as String] = map['value'] as String;
      }

      if (configMap.containsKey('xp_gate_threshold')) {
        _xpGateThreshold =
            int.tryParse(configMap['xp_gate_threshold']!) ?? 250000;
      }
      if (configMap.containsKey('printify_min_balance')) {
        _printifyMinBalance =
            double.tryParse(configMap['printify_min_balance']!) ?? 100.0;
      }

      _hasFetchedConfig = true;
      debugPrint(
        'MerchItemsService: Config loaded — '
        'xpGate=$_xpGateThreshold, printifyMin=$_printifyMinBalance',
      );
    } catch (e) {
      debugPrint(
        'MerchItemsService: Failed to fetch config, using defaults: $e',
      );
      // Keep hardcoded fallbacks
    }
  }

  /// Initialize service — fetches both items and config in parallel
  Future<void> initialize() async {
    await Future.wait([fetchItems(), fetchConfig()]);
  }

  /// Get item by ID from cached list
  MerchItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
