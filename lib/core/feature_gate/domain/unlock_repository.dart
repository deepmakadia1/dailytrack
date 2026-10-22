import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';

/// The `unlocks` store (contracts/core_services.md). Expired rows are kept;
/// the gate decides what counts as unlocked.
abstract interface class UnlockRepository {
  /// Every non-revoked unlock, expired or not. Emits now and after writes.
  Stream<List<Unlock>> watchLive();

  /// Used by rewarded ads and purchases (T4.4, T4.5) and tests. [expiresAt]
  /// null = permanent.
  Future<Unlock> grant(
    FeatureKey key, {
    required UnlockSource source,
    DateTime? expiresAt,
  });

  /// Soft-deletes the unlock (for example a refunded purchase).
  Future<void> revoke(String unlockId);

  /// Uses up one one-time unlock for [key]: the oldest live, unexpired
  /// rewarded-ad unlock is revoked (a rewarded ad grants one export; SET-03,
  /// feature 008 clarification Q2). Purchases are never used up. Returns
  /// whether one was used.
  Future<bool> consumeOne(FeatureKey key);
}
