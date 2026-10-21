import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/feature_gate/data/drift_feature_gate.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';

/// FeatureGate rules (FR-037, FR-038, FR-041, research R13), on a real
/// in-memory database and the real settings repository.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late MutableClock clock;
  late SettingsRepositoryImpl settings;
  late DriftUnlockRepository unlocks;

  const key = FeatureKey.advancedReports;
  final t0 = DateTime(2026, 10, 15, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MutableClock(t0);
    settings = SettingsRepositoryImpl(db, knownModuleIds: const ['expense']);
    unlocks = DriftUnlockRepository(db, clock);
  });
  tearDown(() => db.close());

  DriftFeatureGate gate({bool debugToolsAvailable = false, Clock? at}) =>
      DriftFeatureGate(
        unlocks,
        settings,
        at ?? clock,
        debugToolsAvailable: debugToolsAvailable,
      );

  test('no unlock → locked', () async {
    expect(await gate().isUnlocked(key), isFalse);
    expect(await gate().watch(key).first, isFalse);
  });

  test('a permanent unlock stays unlocked across a new gate', () async {
    await unlocks.grant(key, source: UnlockSource.purchase);
    expect(await gate().isUnlocked(key), isTrue);
    clock.advance(const Duration(days: 4000));
    expect(await gate().isUnlocked(key), isTrue);
    // Other keys are unaffected.
    expect(await gate().isUnlocked(FeatureKey.exportCsv), isFalse);
  });

  test('an expiring unlock is unlocked only before expiresAt', () async {
    await unlocks.grant(
      key,
      source: UnlockSource.rewardedAd,
      expiresAt: t0.add(const Duration(hours: 24)),
    );
    expect(await gate().isUnlocked(key), isTrue);
    clock.advance(const Duration(hours: 23, minutes: 59));
    expect(await gate().isUnlocked(key), isTrue);
    clock.advance(const Duration(minutes: 1));
    expect(await gate().isUnlocked(key), isFalse, reason: 'at expiry');
  });

  test('watch re-locks at expiry without another write (timer)', () async {
    // A clock that really moves, so the gate's timer fires.
    final start = DateTime(2026, 10, 15, 10);
    final stopwatch = Stopwatch()..start();
    final real = Clock(() => start.add(stopwatch.elapsed));
    await unlocks.grant(
      key,
      source: UnlockSource.rewardedAd,
      expiresAt: real.now().add(const Duration(milliseconds: 300)),
    );
    final values = <bool>[];
    final done = Completer<void>();
    final sub = gate(at: real).watch(key).listen((v) {
      values.add(v);
      if (!v && !done.isCompleted) done.complete();
    });
    addTearDown(sub.cancel);
    await done.future.timeout(const Duration(seconds: 3));
    expect(values, [true, false]);
  });

  test('moving the clock back after expiry keeps it locked', () async {
    await unlocks.grant(
      key,
      source: UnlockSource.rewardedAd,
      expiresAt: t0.add(const Duration(hours: 24)),
    );
    clock.advance(const Duration(hours: 25));
    expect(await gate().isUnlocked(key), isFalse);
    // The user sets the device clock back two days.
    clock.value = t0.subtract(const Duration(days: 1));
    expect(await gate().isUnlocked(key), isFalse, reason: 'latestSeenAt');
    expect(
      (await settings.load()).latestSeenAt,
      t0.add(const Duration(hours: 25)).toUtc().millisecondsSinceEpoch,
    );
  });

  test('revoke locks again, and watch follows it', () async {
    final u = await unlocks.grant(key, source: UnlockSource.purchase);
    final values = <bool>[];
    final sub = gate().watch(key).listen(values.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await unlocks.revoke(u.id);
    await pumpEventQueue();
    expect(values, [true, false]);
    expect(await gate().isUnlocked(key), isFalse);
  });

  test('watch emits true after a grant', () async {
    final values = <bool>[];
    final sub = gate().watch(key).listen(values.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await unlocks.grant(key, source: UnlockSource.purchase);
    await pumpEventQueue();
    expect(values, [false, true]);
  });

  group('debug unlock-all (FR-041)', () {
    test('unlocks everything when developer tools exist', () async {
      await settings.setDebugUnlockAll(enabled: true);
      final g = gate(debugToolsAvailable: true);
      expect(await g.isUnlocked(key), isTrue);
      expect(await g.isUnlocked(FeatureKey.premiumTheme('saffron')), isTrue);
    });

    test('is ignored in prod even when stored as on', () async {
      await settings.setDebugUnlockAll(enabled: true);
      expect(await gate().isUnlocked(key), isFalse);
    });

    test('watch follows the switch', () async {
      final values = <bool>[];
      final sub = gate(debugToolsAvailable: true).watch(key).listen(values.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await settings.setDebugUnlockAll(enabled: true);
      await pumpEventQueue();
      await settings.setDebugUnlockAll(enabled: false);
      await pumpEventQueue();
      expect(values, [false, true, false]);
    });
  });

  test('premium themes are stored as premiumTheme_<name>', () async {
    final u = await unlocks.grant(
      FeatureKey.premiumTheme('saffron'),
      source: UnlockSource.purchase,
    );
    final row = await (db.select(
      db.unlocks,
    )..where((t) => t.id.equals(u.id))).getSingle();
    expect(row.featureKey, 'premiumTheme_saffron');
    expect(u.featureKey, FeatureKey.fromStorage('premiumTheme_saffron'));
    expect(await gate().isUnlocked(FeatureKey.premiumTheme('saffron')), isTrue);
    expect(await gate().isUnlocked(FeatureKey.premiumTheme('ocean')), isFalse);
  });

  test('watchLive lists granted, not revoked, unlocks', () async {
    final a = await unlocks.grant(key, source: UnlockSource.purchase);
    final b = await unlocks.grant(
      FeatureKey.exportCsv,
      source: UnlockSource.rewardedAd,
      expiresAt: t0.add(const Duration(hours: 1)),
    );
    await unlocks.revoke(a.id);
    final live = await unlocks.watchLive().first;
    expect(live.map((u) => u.id), [b.id]);
    expect(live.single.expiresAt, t0.add(const Duration(hours: 1)).toUtc());
    expect(live.single.source, UnlockSource.rewardedAd);
  });
}
