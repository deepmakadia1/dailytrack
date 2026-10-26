import 'package:dailytrack/core/ads/domain/ad_config.dart';
import 'package:dailytrack/core/ads/domain/ad_screen_probe.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/interstitial_cap.dart';
import 'package:dailytrack/core/ads/interstitial_coordinator.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

class _Player implements InterstitialPlayer {
  bool ready = true;
  int shows = 0;
  int preloads = 0;

  @override
  bool get isReady => ready;

  @override
  Future<void> preload() async {
    preloads++;
    ready = true;
  }

  @override
  Future<bool> show({required void Function() onShown}) async {
    shows++;
    ready = false;
    onShown();
    return true;
  }
}

class _Probe implements AdScreenProbe {
  bool allow = true;

  @override
  bool get canShowFullScreenAd => allow;
}

/// The interstitial path around the pure cap (feature 009 T098, T106,
/// T115): sessions, the EXP-02 counter, the screen check, persistence,
/// and the dev reset. Times are local 2026-10-22 noon.
void main() {
  late FakeSettingsRepository settings;
  late MutableClock clock;
  late _Player player;
  late _Probe probe;
  late InterstitialCoordinator coordinator;
  final now = DateTime(2026, 10, 22, 12);
  final installedLongAgo = now.subtract(const Duration(days: 10));

  setUp(() {
    settings = FakeSettingsRepository(
      initial: AppSettings(
        adsInstallAt: installedLongAgo.toUtc().millisecondsSinceEpoch,
        // A session already started today, so this one is not the first.
        adsLastSessionDay: '2026-10-22',
      ),
    );
    clock = MutableClock(now);
    player = _Player();
    probe = _Probe();
    coordinator = InterstitialCoordinator(
      settings: settings,
      clock: clock,
      config: AdConfig.defaults,
      probe: probe,
      delay: (_) async {},
    );
  });

  Future<CapDecision> save({bool closing = true}) =>
      coordinator.handle(ExpenseSaved(screenClosing: closing), player);

  test('the 4th new entry closing the screen shows one; the counter resets '
      'and the shown ad is recorded for today', () async {
    await coordinator.startSession();
    for (var i = 0; i < 3; i++) {
      expect(await save(), const CapBlock(CapBlockReason.notEnoughSaves));
    }
    expect(await save(), isA<CapAllow>());
    expect(player.shows, 1);
    expect(coordinator.expenseSaves, 0);
    final s = settings.current;
    expect(s.adsInterstitialsToday, 1);
    expect(s.adsInterstitialDay, '2026-10-22');
    expect(s.adsLastInterstitialAt, now.toUtc().millisecondsSinceEpoch);
    expect(player.preloads, 1, reason: 'the next one is preloaded');
  });

  test('"Save and add another" counts but never shows', () async {
    await coordinator.startSession();
    for (var i = 0; i < 5; i++) {
      await save(closing: false);
    }
    expect(player.shows, 0);
    expect(coordinator.expenseSaves, 5);
    expect(await save(), isA<CapAllow>());
  });

  test('§11 first session of the day blocks; a later session that day is '
      'allowed', () async {
    settings = FakeSettingsRepository(
      initial: AppSettings(
        adsInstallAt: installedLongAgo.toUtc().millisecondsSinceEpoch,
        adsLastSessionDay: '2026-10-21',
      ),
    );
    coordinator = InterstitialCoordinator(
      settings: settings,
      clock: clock,
      config: AdConfig.defaults,
      probe: probe,
      delay: (_) async {},
    );
    await coordinator.startSession();
    expect(coordinator.isFirstSessionOfDay, isTrue);
    expect(
      await coordinator.handle(const HabitCreated(), player),
      const CapBlock(CapBlockReason.firstSession),
    );
    // 30 minutes in the background starts a new session.
    coordinator.onBackgrounded(clock.now());
    clock.advance(const Duration(minutes: 30));
    await coordinator.onForeground(clock.now());
    expect(coordinator.isFirstSessionOfDay, isFalse);
    expect(
      await coordinator.handle(const HabitCreated(), player),
      isA<CapAllow>(),
    );
  });

  test('clarification Q3: a short trip out (e.g. a full-screen ad) keeps '
      'the session and its save counter', () async {
    await coordinator.startSession();
    await save();
    await save();
    coordinator.onBackgrounded(clock.now());
    clock.advance(const Duration(minutes: 29, seconds: 59));
    await coordinator.onForeground(clock.now());
    expect(coordinator.expenseSaves, 2);
  });

  test('a new session resets the save counter', () async {
    await coordinator.startSession();
    await save();
    coordinator.onBackgrounded(clock.now());
    clock.advance(const Duration(hours: 1));
    await coordinator.onForeground(clock.now());
    expect(coordinator.expenseSaves, 0);
  });

  test('FR-023 not on a reading screen → nothing shows and the saves are '
      'kept for the next try', () async {
    await coordinator.startSession();
    probe.allow = false;
    for (var i = 0; i < 4; i++) {
      await save();
    }
    expect(player.shows, 0);
    expect(coordinator.expenseSaves, 4);
    probe.allow = true;
    expect(await save(), isA<CapAllow>());
  });

  test(
    'FR-024 nothing preloaded → no wait, no show, and a preload starts',
    () async {
      await coordinator.startSession();
      player.ready = false;
      expect(
        await coordinator.handle(const HabitCreated(), player),
        const CapBlock(CapBlockReason.notPreloaded),
      );
      expect(player.preloads, 1);
    },
  );

  test(
    'the 3-minute gap and 4-per-day maximum use the stored counts',
    () async {
      await coordinator.startSession();
      expect(
        await coordinator.handle(const HabitCreated(), player),
        isA<CapAllow>(),
      );
      clock.advance(const Duration(minutes: 1));
      expect(
        await coordinator.handle(const HabitCreated(), player),
        const CapBlock(CapBlockReason.gap),
      );
      for (var i = 0; i < 3; i++) {
        clock.advance(const Duration(minutes: 3));
        expect(
          await coordinator.handle(const ManualBackupSucceeded(), player),
          isA<CapAllow>(),
        );
      }
      clock.advance(const Duration(minutes: 3));
      expect(
        await coordinator.handle(const HabitCreated(), player),
        const CapBlock(CapBlockReason.dailyMax),
      );
    },
  );

  test('§11 install-age rule: the first start records the install time, '
      'and nothing shows for 2 days', () async {
    settings = FakeSettingsRepository();
    coordinator = InterstitialCoordinator(
      settings: settings,
      clock: clock,
      config: AdConfig.defaults,
      probe: probe,
      delay: (_) async {},
    );
    await coordinator.startSession();
    expect(settings.current.adsInstallAt, now.toUtc().millisecondsSinceEpoch);
    coordinator.onBackgrounded(clock.now());
    clock.advance(const Duration(hours: 1));
    await coordinator.onForeground(clock.now());
    expect(
      await coordinator.handle(const HabitCreated(), player),
      const CapBlock(CapBlockReason.installAge),
    );
    // A later start never moves the install time.
    await coordinator.startSession();
    expect(settings.current.adsInstallAt, now.toUtc().millisecondsSinceEpoch);
  });

  test(
    'FR-048 dev "Reset ad counters" lets an interstitial show at once',
    () async {
      settings = FakeSettingsRepository();
      coordinator = InterstitialCoordinator(
        settings: settings,
        clock: clock,
        config: AdConfig.defaults,
        probe: probe,
        delay: (_) async {},
      );
      await coordinator.startSession();
      await settings.recordInterstitialShown(
        at: now.toUtc().millisecondsSinceEpoch,
        dayKey: '2026-10-22',
        countToday: 4,
      );
      await coordinator.resetForDebug();
      final s = settings.current;
      expect(s.adsLastInterstitialAt, isNull);
      expect(s.adsInterstitialDay, isNull);
      expect(s.adsInterstitialsToday, 0);
      expect(coordinator.isFirstSessionOfDay, isFalse);
      expect(
        await coordinator.handle(const HabitCreated(), player),
        isA<CapAllow>(),
      );
    },
  );
}
