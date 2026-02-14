import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables for the CITRIS Quest Merch Redemption Shop
///
/// Reads from .env file (local dev) with fallback to --dart-define (CI/CD).
class Env {
  // Supabase configuration
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : (dotenv.env['SUPABASE_URL'] ?? '');

  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  static String get supabaseServiceRoleKey =>
      const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY',
                  defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY')
          : (dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '');

  // Printify API configuration
  static String get printifyApiToken =>
      const String.fromEnvironment('PRINTIFY_API_TOKEN', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('PRINTIFY_API_TOKEN')
          : (dotenv.env['PRINTIFY_API_TOKEN'] ?? '');

  static String get printifyShopId =>
      const String.fromEnvironment('PRINTIFY_SHOP_ID', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('PRINTIFY_SHOP_ID')
          : (dotenv.env['PRINTIFY_SHOP_ID'] ?? '');

  /// True if Supabase vars are set (enough to initialize Supabase)
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True if all vars (Supabase + Printify) are set
  static bool get isConfigured =>
      isSupabaseConfigured &&
      printifyApiToken.isNotEmpty &&
      printifyShopId.isNotEmpty;

  static String getMissingVars() {
    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (printifyApiToken.isEmpty) missing.add('PRINTIFY_API_TOKEN');
    if (printifyShopId.isEmpty) missing.add('PRINTIFY_SHOP_ID');
    return missing.join(', ');
  }
}
