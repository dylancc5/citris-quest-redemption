import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service for the merch redemption shop
///
/// Handles user login, logout, and profile data caching using the same
/// Supabase instance as the main CITRIS Quest game.
///
/// Uses singleton pattern to maintain shared state across the app.
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // Cached user profile data
  String? _userId;
  String? _username;
  String? _email;
  int _xp = 0;
  int _coins = 0;

  // Reactive notifiers for UI updates
  final ValueNotifier<int> xpNotifier = ValueNotifier(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

  // Getters
  bool get isLoggedIn {
    try {
      return _supabase.auth.currentUser != null;
    } catch (e) {
      debugPrint('AuthService: isLoggedIn check failed: $e');
      return isLoggedInNotifier.value;
    }
  }
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  int get xp => xpNotifier.value;
  int get coins => coinsNotifier.value;

  /// Initialize the service by checking for existing session
  Future<void> initialize() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        await _loadUserProfile(session.user.id);
        isLoggedInNotifier.value = true;
      } catch (e) {
        debugPrint('AuthService: Failed to load profile on init: $e');
        await logout();
      }
    }
  }

  /// Login with game username and password
  ///
  /// Flow:
  /// 1. Fetch email from username via RPC
  /// 2. Sign in with email and password
  /// 3. Load and cache user profile
  Future<bool> login(String username, String password) async {
    try {
      // Step 1: Get email from username
      final emailResponse = await _supabase.rpc(
        'get_email_by_username',
        params: {'lookup_username': username},
      );

      if (emailResponse == null) {
        throw Exception('Username not found');
      }

      final email = emailResponse as String;

      // Step 2: Sign in with email and password
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Authentication failed');
      }

      // Step 3: Load user profile
      await _loadUserProfile(authResponse.user!.id);

      isLoggedInNotifier.value = true;
      return true;
    } catch (e) {
      debugPrint('AuthService: Login failed: $e');
      return false;
    }
  }

  /// Logout and clear cached data
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('AuthService: Logout error: $e');
    } finally {
      _clearCache();
      isLoggedInNotifier.value = false;
    }
  }

  /// Refresh user profile from database
  ///
  /// Call this after transactions that modify coins or XP
  Future<void> refreshProfile() async {
    if (_userId == null) return;

    try {
      await _loadUserProfile(_userId!);
    } catch (e) {
      debugPrint('AuthService: Failed to refresh profile: $e');
    }
  }

  /// Load user profile from user_profiles table
  Future<void> _loadUserProfile(String userId) async {
    final response = await _supabase
        .from('user_profiles')
        .select('player_id, username, xp, coins')
        .eq('player_id', userId)
        .single();

    _userId = response['player_id'] as String;
    _username = response['username'] as String;
    _xp = (response['xp'] as int?) ?? 0;
    _coins = (response['coins'] as int?) ?? 0;

    // Get email from auth.users
    _email = _supabase.auth.currentUser?.email;

    // Update notifiers
    xpNotifier.value = _xp;
    coinsNotifier.value = _coins;
  }

  /// Clear cached profile data
  void _clearCache() {
    _userId = null;
    _username = null;
    _email = null;
    _xp = 0;
    _coins = 0;
    xpNotifier.value = 0;
    coinsNotifier.value = 0;
  }

  /// Update local coin balance (call before DB update for optimistic UI)
  void updateLocalCoins(int newBalance) {
    _coins = newBalance;
    coinsNotifier.value = newBalance;
  }
}
