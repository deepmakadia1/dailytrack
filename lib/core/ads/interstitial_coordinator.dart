import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/ads/domain/ad_config.dart';
import 'package:dailytrack/core/ads/domain/ad_screen_probe.dart';
import 'package:dailytrack/core/ads/domain/ad_session.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/interstitial_cap.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:flutter/widgets.dart';

/// A preloaded interstitial that can be shown (the AdMob adapter lives in
/// `data/`).
abstract interface class InterstitialPlayer {
  bool get isReady;

  /// Loads the next interstitial if none is loaded. Never throws.
  Future<void> preload();

  /// Shows the loaded interstitial. [onShown] runs when it appears; the
  /// future completes when it is dismissed. False when it could not show.
  Future<bool> show({required void Function() onShown});
}

/// Decides, for each finished action, whether an interstitial may show
/// (spec §11, feature 009 research R9, R10):
///  - the session rules (a new session on cold start or after 30 minutes
///    in the background; is it the first session of the local day?),
///  - the EXP-02 save counter (per session, reset only by a shown ad),
///  - the global cap from settings, using the effective now,
///  - the screen check, after the closing screen has had time to go.
/// Never waits for an ad to load, and never throws.
final class InterstitialCoordinator {
  new({
    required this._settings,
    required this._clock,
    required AdConfig config,
    required this._probe,
    this._beforeFullScreen,
    Future<void> Function(Duration)? delay,
  }) : _config = config,
       _delay = delay ?? Future<void>.delayed,
       _cap = InterstitialCap(config),
       _session = AdSession(config);

  final SettingsRepository _settings;
  final Clock _clock;
  final AdConfig _config;
  final AdScreenProbe _probe;
  final void Function()? _beforeFullScreen;
  final Future<void> Function(Duration) _delay;
  final InterstitialCap _cap;
  final AdSession _session;

  var _isFirstSessionOfDay = false;
  var _expenseSaves = 0;
  DateTime? _backgroundedAt;
  AppLifecycleListener? _lifecycle;

  /// New EXP-02 entries saved in this session since the last interstitial.
  int get expenseSaves => _expenseSaves;

  bool get isFirstSessionOfDay => _isFirstSessionOfDay;

  DateTime _effectiveNow(AppSettings s) =>
      effectiveNow(_clock.now(), s.latestSeenAt);

  static String _dayKey(DateTime utc) => DateKeys.fromLocal(utc.toLocal());

  /// Starts a session: on cold start (SYS-01) and after a long background
  /// trip. Records the install time the first time ever.
  Future<void> startSession() async {
    try {
      final s = await _settings.load();
      final now = _effectiveNow(s);
      await _settings.setAdsInstallAtIfMissing(now.millisecondsSinceEpoch);
      final today = _dayKey(now);
      final started = _session.start(
        todayKey: today,
        lastSessionDayKey: s.adsLastSessionDay,
      );
      _isFirstSessionOfDay = started.isFirstSessionOfDay;
      _expenseSaves = 0;
      await _settings.setAdsLastSessionDay(started.lastSessionDayKey);
    } on Object {
      // Ads never break the app; the cap simply blocks until it can read.
    }
  }

  /// The app left the foreground.
  void onBackgrounded(DateTime now) => _backgroundedAt ??= now;

  /// The app came back; a long enough absence starts a new session.
  Future<void> onForeground(DateTime now) async {
    final left = _backgroundedAt;
    _backgroundedAt = null;
    if (_session.isNewSession(now: now, backgroundedAt: left)) {
      await startSession();
    }
  }

  /// Follows the app lifecycle (composition root only; tests call
  /// [onBackgrounded] and [onForeground] directly).
  void attachLifecycle() {
    _lifecycle ??= AppLifecycleListener(
      onHide: () => onBackgrounded(_clock.now()),
      onShow: () => unawaited(onForeground(_clock.now())),
    );
  }

  /// Handles one finished action with [player], and says why nothing was
  /// shown (for tests and diagnostics).
  Future<CapDecision> handle(
    AdTrigger trigger,
    InterstitialPlayer player,
  ) async {
    try {
      if (trigger is ExpenseSaved) {
        _expenseSaves++;
        if (!trigger.screenClosing) {
          return const CapBlock(CapBlockReason.notEnoughSaves);
        }
      }
      // Let the closing screen or message finish going away first.
      await _delay(_config.afterCloseDelay);
      if (!player.isReady) {
        unawaited(player.preload());
        return const CapBlock(CapBlockReason.notPreloaded);
      }
      final s = await _settings.load();
      final now = _effectiveNow(s);
      final today = _dayKey(now);
      final state = _stateFrom(s, now);
      final decision = _cap.check(
        state,
        effectiveNow: now,
        todayKey: today,
        trigger: trigger,
      );
      if (decision is CapBlock) return decision;
      if (!_probe.canShowFullScreenAd) {
        return const CapBlock(CapBlockReason.notOnReadingScreen);
      }
      _beforeFullScreen?.call();
      final shown = await player.show(
        onShown: () {
          final next = _cap.afterShown(state, now: now, todayKey: today);
          _expenseSaves = next.expenseSaves;
          unawaited(
            _settings
                .recordInterstitialShown(
                  at: now.millisecondsSinceEpoch,
                  dayKey: today,
                  countToday: next.shownToday,
                )
                .catchError((Object _) {}),
          );
        },
      );
      // The next one is ready for a later action.
      unawaited(player.preload());
      return shown
          ? const CapAllow()
          : const CapBlock(CapBlockReason.notPreloaded);
    } on Object {
      return const CapBlock(CapBlockReason.adsDisabled);
    }
  }

  InterstitialCapState _stateFrom(AppSettings s, DateTime now) {
    DateTime? utc(int? ms) => ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    return InterstitialCapState(
      // Unknown install time counts as just installed.
      installAt: utc(s.adsInstallAt) ?? now,
      lastShownAt: utc(s.adsLastInterstitialAt),
      dayKey: s.adsInterstitialDay,
      shownToday: s.adsInterstitialsToday,
      isFirstSessionOfDay: _isFirstSessionOfDay,
      expenseSaves: _expenseSaves,
    );
  }

  /// Dev-only "Reset ad counters" (FR-048): the install-age rule counts as
  /// met, the last interstitial and today's count are cleared, and this
  /// session is no longer the first of the day.
  Future<void> resetForDebug() async {
    final s = await _settings.load();
    final installAt = _effectiveNow(s)
        .subtract(Duration(days: _config.installAgeDays, minutes: 1));
    await _settings.resetAdCounters(
      installAt: installAt.millisecondsSinceEpoch,
    );
    _expenseSaves = 0;
    _isFirstSessionOfDay = false;
  }

  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}
