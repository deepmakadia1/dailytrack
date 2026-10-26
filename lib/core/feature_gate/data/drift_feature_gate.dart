import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_policy.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';

/// [FeatureGate] over unlock records and settings (research R13).
///
/// The rules live in the pure [UnlockPolicy]: Pro, the dev debug switch
/// (only when developer tools exist, FR-041), or a live unlock that is
/// permanent or expires after the effective now. The effective now is the
/// later of the clock and `latestSeenAt`, so moving the device clock back
/// never revives an expired unlock (FR-038).
final class DriftFeatureGate implements FeatureGate {
  new(
    this._unlocks,
    this._settings,
    this._clock, {
    required this.debugToolsAvailable,
  });

  final UnlockRepository _unlocks;
  final SettingsRepository _settings;
  final Clock _clock;

  /// False in prod, so the stored debug switch is ignored (FR-041).
  final bool debugToolsAvailable;

  /// `latestSeenAt` is written only when the clock is this far ahead of it,
  /// so a watch never loops on its own settings write.
  static const Duration seenAtStep = Duration(minutes: 1);

  int _effectiveNowMs(AppSettings settings) {
    final clockNow = _clock.now();
    final now = clockNow.toUtc().millisecondsSinceEpoch;
    final seen = settings.latestSeenAt;
    if (seen == null || now - seen >= seenAtStep.inMilliseconds) {
      unawaited(_settings.raiseLatestSeenAt(now).catchError((Object _) {}));
    }
    return effectiveNow(clockNow, seen).millisecondsSinceEpoch;
  }

  /// The answer, plus the next expiry that would change it (if any), from
  /// the pure [UnlockPolicy] (feature 009 research R12).
  (bool, int?) _evaluate(
    FeatureKey key,
    List<Unlock> unlocks,
    AppSettings settings,
  ) {
    final d = UnlockPolicy.evaluate(
      key,
      unlocks,
      effectiveNowMs: _effectiveNowMs(settings),
      debugUnlockAll: debugToolsAvailable && settings.debugUnlockAll,
      proOwned: settings.removeAdsPurchased,
    );
    return (d.unlocked, d.nextExpiryMs);
  }

  @override
  Future<bool> isUnlocked(FeatureKey key) async {
    final settings = await _settings.load();
    final unlocks = await _unlocks.watchLive().first;
    return _evaluate(key, unlocks, settings).$1;
  }

  @override
  Stream<bool> watch(FeatureKey key) {
    late StreamController<bool> controller;
    StreamSubscription<List<Unlock>>? unlockSub;
    StreamSubscription<AppSettings>? settingsSub;
    Timer? expiryTimer;
    List<Unlock>? unlocks;
    AppSettings? settings;
    bool? last;

    void emit() {
      final u = unlocks;
      final s = settings;
      if (u == null || s == null || controller.isClosed) return;
      final (value, nextExpiry) = _evaluate(key, u, s);
      expiryTimer?.cancel();
      expiryTimer = null;
      if (nextExpiry != null) {
        final now = _clock.now().toUtc().millisecondsSinceEpoch;
        // Re-check exactly when the latest live unlock runs out.
        expiryTimer = Timer(
          Duration(milliseconds: math.max(0, nextExpiry - now)),
          emit,
        );
      }
      if (value != last) {
        last = value;
        controller.add(value);
      }
    }

    controller = StreamController<bool>(
      onListen: () {
        unlockSub = _unlocks.watchLive().listen((v) {
          unlocks = v;
          emit();
        }, onError: controller.addError);
        settingsSub = _settings.watch().listen((v) {
          settings = v;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        expiryTimer?.cancel();
        await unlockSub?.cancel();
        await settingsSub?.cancel();
      },
    );
    return controller.stream;
  }
}
