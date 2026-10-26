import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';

/// The gate's answer for one key, plus the next expiry that would change it.
typedef UnlockDecision = ({bool unlocked, int? nextExpiryMs});

/// Whether a gated feature is available (feature 009 research R12). Pure:
/// callers pass the effective now, the later of the clock and the latest
/// time ever seen, so an unlock that expired stays expired after a restart
/// or when the device clock is moved backwards (PRM-02 AC). In order:
///  1. `adFreeDay` is never unlocked (the reward was dropped, FR-035);
///  2. Pro unlocks everything, for good;
///  3. the dev-only debug switch;
///  4. a live unlock that is permanent or expires after the effective now.
abstract final class UnlockPolicy {
  static UnlockDecision evaluate(
    FeatureKey key,
    List<Unlock> unlocks, {
    required int effectiveNowMs,
    required bool debugUnlockAll,
    required bool proOwned,
  }) {
    if (key == FeatureKey.adFreeDay) {
      return (unlocked: false, nextExpiryMs: null);
    }
    if (proOwned || debugUnlockAll) {
      return (unlocked: true, nextExpiryMs: null);
    }
    int? nextExpiry;
    var unlocked = false;
    for (final u in unlocks) {
      if (u.featureKey != key) continue;
      final expires = u.expiresAt?.millisecondsSinceEpoch;
      if (expires == null) return (unlocked: true, nextExpiryMs: null);
      if (expires > effectiveNowMs) {
        unlocked = true;
        nextExpiry = nextExpiry == null || expires > nextExpiry
            ? expires
            : nextExpiry;
      }
    }
    return (unlocked: unlocked, nextExpiryMs: nextExpiry);
  }
}
