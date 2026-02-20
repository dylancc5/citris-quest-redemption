import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for user profile operations
///
/// Handles fetching user data and atomic coin deduction for merch purchases.
class UserProfilesService {
  // Singleton instance
  static final UserProfilesService _instance = UserProfilesService._internal();
  factory UserProfilesService() => _instance;
  UserProfilesService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get user profile data (XP and coins)
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('player_id, username, xp, bits')
          .eq('player_id', userId)
          .single();

      return {
        'user_id': response['player_id'] as String,
        'username': response['username'] as String,
        'xp': response['xp'] as int,
        'coins': response['bits'] as int,
      };
    } catch (e) {
      debugPrint('UserProfilesService: Failed to fetch profile: $e');
      rethrow;
    }
  }

  /// Atomically deduct coins from user profile
  ///
  /// Uses optimistic locking to prevent race conditions.
  /// Returns true if successful, false if insufficient coins or other error.
  ///
  /// This is a critical operation - must be atomic to prevent:
  /// - Concurrent purchases depleting balance
  /// - Negative coin balances
  Future<bool> deductCoins(String userId, int amount) async {
    try {
      // Fetch current balance first
      final profile = await getUserProfile(userId);
      final currentCoins = profile['coins'] as int;

      // Check if user has enough coins
      if (currentCoins < amount) {
        debugPrint('UserProfilesService: Insufficient coins. Have: $currentCoins, Need: $amount');
        return false;
      }

      // Perform atomic update with optimistic locking
      // Update bits (coins) column, checking current value hasn't changed
      final response = await _supabase
          .from('user_profiles')
          .update({'bits': currentCoins - amount})
          .eq('player_id', userId)
          .eq('bits', currentCoins) // Optimistic lock: only update if bits unchanged
          .select();

      // If no rows updated, another transaction modified the balance
      if (response.isEmpty) {
        debugPrint('UserProfilesService: Coin deduction failed - concurrent modification detected');
        return false;
      }

      debugPrint('UserProfilesService: Successfully deducted $amount coins from user $userId');
      return true;
    } catch (e) {
      debugPrint('UserProfilesService: Coin deduction error: $e');
      return false;
    }
  }

  /// Refund coins to user (used for rollback on transaction failures)
  Future<bool> refundCoins(String userId, int amount) async {
    try {
      final profile = await getUserProfile(userId);
      final currentCoins = profile['coins'] as int;

      await _supabase
          .from('user_profiles')
          .update({'bits': currentCoins + amount})
          .eq('player_id', userId);

      debugPrint('UserProfilesService: Refunded $amount coins to user $userId');
      return true;
    } catch (e) {
      debugPrint('UserProfilesService: Coin refund error: $e');
      return false;
    }
  }
}
