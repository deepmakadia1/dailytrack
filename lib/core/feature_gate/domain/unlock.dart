import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unlock.freezed.dart';

// Stored as its int index (Drift intEnum). Append-only: never reorder or
// remove values (data-model.md §2).

/// Where an unlock came from (spec §4 `unlocks.source`).
enum UnlockSource { rewardedAd, purchase }

/// A record that a gated feature is available (data-model.md §4). Read
/// through the `FeatureGate`, never directly by screens.
@freezed
abstract class Unlock with _$Unlock {
  const factory({
    required String id,
    required FeatureKey featureKey,
    required UnlockSource source,

    /// UTC.
    required DateTime createdAt,

    /// UTC. Null = permanent.
    DateTime? expiresAt,
  }) = _Unlock;
}
