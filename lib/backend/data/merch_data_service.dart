import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches merch product image URLs from the shared asset_metadata table.
///
/// Images are uploaded via scripts/upload_assets.py with asset_type='merch_image'
/// and asset_key pattern 'merch_images/{item_id}_{index}' (e.g. 'merch_images/shirt_1').
/// The public_url from asset_metadata is used directly — no local caching needed
/// since the redemption app is web-based.
class MerchDataService {
  static final MerchDataService _instance = MerchDataService._internal();
  factory MerchDataService() => _instance;
  MerchDataService._internal();

  final _supabase = Supabase.instance.client;

  /// Returns a map of item_id → ordered list of public image URLs.
  /// e.g. { 'shirt': ['https://....jpg', 'https://....jpg'], 'magnet': [...] }
  ///
  /// Returns an empty map on any error so the UI falls back to placeholder icons.
  Future<Map<String, List<String>>> fetchMerchImageUrls() async {
    try {
      final rows = await _supabase
          .from('asset_metadata')
          .select('asset_key, public_url')
          .like('asset_key', 'merch_images/%')
          .order('asset_key');

      final result = <String, List<String>>{};

      for (final row in rows) {
        final assetKey = row['asset_key'] as String?; // e.g. 'merch_images/shirt_1'
        final publicUrl = row['public_url'] as String?;
        if (assetKey == null || publicUrl == null) continue;

        // Extract item_id: 'merch_images/shirt_1' → 'shirt'
        final withoutPrefix = assetKey.replaceFirst('merch_images/', '');
        final underscoreIndex = withoutPrefix.lastIndexOf('_');
        if (underscoreIndex <= 0) continue;
        final itemId = withoutPrefix.substring(0, underscoreIndex);

        result.putIfAbsent(itemId, () => []).add(publicUrl);
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MerchDataService: Failed to fetch image URLs: $e');
      }
      return {};
    }
  }
}
