import 'dart:async';

import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/rewarded_daily_limit.dart';
import 'package:dailytrack/core/ads/domain/rewarded_outcome.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewarded_unlock_controller.freezed.dart';
part 'rewarded_unlock_controller.g.dart';

/// Where the PRM-02 sheet is (feature 009 data-model §5).
enum RewardedPhase {
  /// An ad is loading (spinner on the button).
  loading,

  /// "Watch a short ad" can be tapped.
  ready,

  /// The full-screen ad is up.
  showing,

  /// No ad within 8 s, or it failed: "Ad not available, try again later".
  unavailable,

  /// 10 rewards for this feature today (FR-053): no ad loads.
  limitReached,

  /// The sheet closes with [RewardedUnlockState.result].
  done,
}

@freezed
abstract class RewardedUnlockState with _$RewardedUnlockState {
  const factory({
    @Default(RewardedPhase.loading) RewardedPhase phase,

    /// The last ad was closed before the reward (clarification Q5).
    @Default(false) bool closedEarly,

    /// Set in [RewardedPhase.done]: whether the reward was earned (or Pro
    /// was bought meanwhile).
    bool? result,
  }) = _RewardedUnlockState;
}

/// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
/// the sheet opens, shows it on request, and grants only from the reward
/// callback. An early close grants nothing and loads a new ad.
@riverpod
class RewardedUnlockController extends _$RewardedUnlockController {
  RewardedUnlockRequest? _request;

  @override
  RewardedUnlockState build(FeatureKey key) {
    // Pro bought (or the debug unlock turned on) while the sheet is open:
    // the feature is unlocked anyway.
    ref.listen(proOwnedProvider, (_, pro) {
      if (pro) _finish(result: true);
    });
    return const RewardedUnlockState();
  }

  RewardedDailyLimit get _limit => RewardedDailyLimit(
    perKeyPerDay: ref.read(adConfigProvider).rewardedPerKeyPerDay,
  );

  String _today(AppSettings s) => DateKeys.fromLocal(
    effectiveNow(ref.read(clockProvider).now(), s.latestSeenAt).toLocal(),
  );

  /// Called once when the sheet opens.
  Future<void> start(RewardedUnlockRequest request) async {
    _request = request;
    final s = await ref.read(settingsRepositoryProvider).load();
    if (!ref.mounted) return;
    if (_limit.reached(
      key,
      today: _today(s),
      storedDay: s.rewardedDay,
      counts: s.rewardedCounts,
    )) {
      state = state.copyWith(phase: RewardedPhase.limitReached);
      return;
    }
    await _prepare();
  }

  Future<void> _prepare() async {
    state = state.copyWith(phase: RewardedPhase.loading);
    bool ready;
    try {
      ready = await ref
          .read(adServiceProvider)
          .prepareRewarded()
          .timeout(ref.read(adConfigProvider).rewardedTimeout);
    } on Object {
      ready = false;
    }
    if (!ref.mounted || state.phase == RewardedPhase.done) return;
    state = state.copyWith(
      phase: ready ? RewardedPhase.ready : RewardedPhase.unavailable,
    );
  }

  /// "Try again" after a failed load.
  Future<void> retry() async {
    if (state.phase != RewardedPhase.unavailable) return;
    await _prepare();
  }

  /// "Watch a short ad". Ignored unless an ad is ready, so double taps show
  /// one ad (FR-046).
  Future<void> watch() async {
    final request = _request;
    if (request == null || state.phase != RewardedPhase.ready) return;
    state = state.copyWith(phase: RewardedPhase.showing);
    // A full-screen ad is the app's own trip out: no SYS-03 on return.
    ref.read(externalActivityGuardProvider).expectExternalActivity();
    final outcome = await ref
        .read(adServiceProvider)
        .showRewarded(
          key,
          // Runs only from the SDK's reward callback (FR-030).
          onEarned: () async {
            await request.grant();
            await _countReward();
          },
        );
    if (!ref.mounted || state.phase == RewardedPhase.done) return;
    switch (outcome) {
      case RewardedOutcome.earned:
        _finish(result: true);
      case RewardedOutcome.closedEarly:
        // Nothing is granted; a new ad loads for another try (Q5).
        state = state.copyWith(closedEarly: true);
        await _prepare();
      case RewardedOutcome.notReady || RewardedOutcome.failed:
        state = state.copyWith(phase: RewardedPhase.unavailable);
    }
  }

  Future<void> _countReward() async {
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final s = await settings.load();
      final today = _today(s);
      await settings.setRewardedCounts(
        dayKey: today,
        counts: _limit.afterReward(
          key,
          today: today,
          storedDay: s.rewardedDay,
          counts: s.rewardedCounts,
        ),
      );
    } on Object {
      // The grant already happened; a lost count only allows one more.
    }
  }

  void _finish({required bool result}) {
    state = state.copyWith(phase: RewardedPhase.done, result: result);
  }
}
