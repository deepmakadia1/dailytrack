import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewarded_unlock.g.dart';

/// What PRM-02 offers: the feature, how long the unlock lasts (null =
/// permanent or one-time), and what earning the reward grants.
final class RewardedUnlockRequest {
  const new({
    required this.key,
    required this.grant,
    this.duration,
    this.subjectName,
  });

  final FeatureKey key;
  final Duration? duration;

  /// Runs only from the ad's reward callback (FR-030).
  final Future<void> Function() grant;

  /// The theme or habit name shown in the sheet title.
  final String? subjectName;
}

/// Shows PRM-02. Bound in the composition root to the premium feature's
/// sheet, so other features never import it (Constitution II).
abstract interface class RewardedUnlockPresenter {
  /// True only when the reward was earned and its grant finished.
  Future<bool> present(BuildContext context, RewardedUnlockRequest request);
}

/// No sheet: the default when nothing is bound. Never grants.
final class NoRewardedUnlockPresenter implements RewardedUnlockPresenter {
  const new();

  @override
  Future<bool> present(
    BuildContext context,
    RewardedUnlockRequest request,
  ) async => false;
}

@Riverpod(keepAlive: true)
RewardedUnlockPresenter rewardedUnlockPresenter(Ref ref) =>
    const NoRewardedUnlockPresenter();

/// Opens PRM-02 for [key] (spec PRM-02, feature 009 contracts/services.md
/// §4). Returns true only when the user watched the ad to the reward and
/// the unlock was written. Without [grant], the reward writes a rewarded
/// unlock that lasts [duration] from the effective now, or for good (or one
/// export) when [duration] is null. The ad-free day is not a reward
/// (FR-035).
Future<bool> showRewardedUnlock(
  BuildContext context,
  FeatureKey key, {
  Duration? duration,
  Future<void> Function()? grant,
  String? subjectName,
}) {
  assert(key != FeatureKey.adFreeDay, 'The ad-free day is not a reward');
  final container = ProviderScope.containerOf(context, listen: false);
  Future<void> writeUnlock() async {
    final settings = await container.read(settingsRepositoryProvider).load();
    final now = effectiveNow(
      container.read(clockProvider).now(),
      settings.latestSeenAt,
    );
    await container
        .read(unlockRepositoryProvider)
        .grant(
          key,
          source: UnlockSource.rewardedAd,
          expiresAt: duration == null ? null : now.add(duration),
        );
  }

  return container
      .read(rewardedUnlockPresenterProvider)
      .present(
        context,
        RewardedUnlockRequest(
          key: key,
          duration: duration,
          grant: grant ?? writeUnlock,
          subjectName: subjectName,
        ),
      );
}
