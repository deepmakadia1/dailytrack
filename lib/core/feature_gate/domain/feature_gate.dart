import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';

/// Decides whether a gated feature is available (FR-037, research R13).
/// Every module uses it through this interface only.
abstract interface class FeatureGate {
  /// Emits the current answer, then again whenever it changes: an unlock
  /// expiring, a grant or revoke, or the debug switch.
  Stream<bool> watch(FeatureKey key);

  Future<bool> isUnlocked(FeatureKey key);
}
