import 'dart:convert';
import 'dart:io';

import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _known = ['expense', 'habit'];

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(db, knownModuleIds: _known);
  });
  tearDown(() => db.close());

  Future<void> putRaw(String key, String value) => db
      .into(db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: value, updatedAt: 0),
      );

  test('defaults are returned for an empty table', () async {
    expect(await repo.load(), const AppSettings());
  });

  test(
    'corrupt JSON falls back to that key default without throwing',
    () async {
      await putRaw('currencyCode', '{not json');
      await putRaw('onboardingDone', '"yes"'); // wrong type
      await putRaw('locale', jsonEncode('gu'));
      final s = await repo.load();
      expect(s.currencyCode, 'INR');
      expect(s.onboardingDone, isFalse);
      expect(s.locale, 'gu');
    },
  );

  test('setLocale ignores unsupported codes and accepts null', () async {
    await repo.setLocale('hi');
    await repo.setLocale('xx');
    expect((await repo.load()).locale, 'hi');
    await repo.setLocale(null);
    expect((await repo.load()).locale, isNull);
  });

  test('setModules with nothing enabled throws and changes nothing', () async {
    await repo.setModules(order: ['habit', 'expense'], enabled: ['habit']);
    await expectLater(
      repo.setModules(order: ['habit', 'expense'], enabled: []),
      throwsA(isA<LastModuleError>()),
    );
    final s = await repo.load();
    expect(s.enabledModules, ['habit']);
    expect(s.moduleOrder, ['habit', 'expense']);
  });

  test(
    'unknown module ids are dropped on read and missing ones appended',
    () async {
      await putRaw('moduleOrder', jsonEncode(['water', 'habit']));
      await putRaw('enabledModules', jsonEncode(['water', 'habit']));
      final s = await repo.load();
      expect(s.moduleOrder, ['habit', 'expense']);
      expect(s.enabledModules, ['habit']);
    },
  );

  test(
    'an enabled list that ends up empty falls back to the first module',
    () async {
      await putRaw('enabledModules', jsonEncode(['water']));
      expect((await repo.load()).enabledModules, ['expense']);
    },
  );

  test(
    'completeOnboarding writes everything and marks onboarding done',
    () async {
      await repo.completeOnboarding(
        const OnboardingChoices(
          locale: 'gu',
          currencyCode: 'USD',
          moduleOrder: ['habit', 'expense'],
          enabledModules: ['habit'],
        ),
      );
      final s = await repo.load();
      expect(s.locale, 'gu');
      expect(s.currencyCode, 'USD');
      expect(s.moduleOrder, ['habit', 'expense']);
      expect(s.enabledModules, ['habit']);
      expect(s.onboardingDone, isTrue);
    },
  );

  test(
    'completeOnboarding is atomic: a failure mid-write leaves nothing behind',
    () async {
      // Make the final write (onboardingDone) fail inside the transaction.
      await db.customStatement('''
      CREATE TRIGGER fail_onboarding BEFORE INSERT ON settings
      WHEN NEW.key = 'onboardingDone'
      BEGIN SELECT RAISE(ABORT, 'simulated failure'); END;
    ''');
      await expectLater(
        repo.completeOnboarding(
          const OnboardingChoices(
            locale: 'gu',
            currencyCode: 'USD',
            moduleOrder: ['expense', 'habit'],
            enabledModules: ['expense'],
          ),
        ),
        throwsA(anything),
      );
      final s = await repo.load();
      expect(s.onboardingDone, isFalse);
      expect(s.locale, isNull);
      expect(s.currencyCode, 'INR');
    },
  );

  test('completeOnboarding rejects an empty module list', () async {
    await expectLater(
      repo.completeOnboarding(
        const OnboardingChoices(
          locale: null,
          currencyCode: 'INR',
          moduleOrder: ['expense', 'habit'],
          enabledModules: [],
        ),
      ),
      throwsA(isA<LastModuleError>()),
    );
  });

  test('watch emits the current value and again after each write', () async {
    final seen = <String>[];
    final sub = repo.watch().listen((s) => seen.add(s.currencyCode));
    await pumpEventQueue();
    await repo.setCurrency('USD');
    await pumpEventQueue();
    await repo.setCurrency('EUR');
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, ['INR', 'USD', 'EUR']);
  });

  test('seed markers', () async {
    expect(await repo.isSeeded('expense.defaults.v1'), isFalse);
    await repo.markSeeded('expense.defaults.v1');
    expect(await repo.isSeeded('expense.defaults.v1'), isTrue);
  });

  test('a write takes under 100 ms', () async {
    await repo.load(); // warm up
    final sw = Stopwatch()..start();
    await repo.setCurrency('USD');
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(100));
  });

  test('SC-006 settings survive a restart', () async {
    final dir = Directory.systemTemp.createTempSync('dailytrack_settings');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/t.db');

    final first = AppDatabase(NativeDatabase(file));
    final r1 = SettingsRepositoryImpl(first, knownModuleIds: _known);
    await r1.setLocale('gu');
    await r1.setCurrency('USD');
    await r1.setModules(order: ['habit', 'expense'], enabled: ['habit']);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final s = await SettingsRepositoryImpl(
      second,
      knownModuleIds: _known,
    ).load();
    expect(s.locale, 'gu');
    expect(s.currencyCode, 'USD');
    expect(s.moduleOrder, ['habit', 'expense']);
    expect(s.enabledModules, ['habit']);
  });

  // --- 003-budgets-recurring-reports (T014) ---

  group('feature 003 settings', () {
    test('defaults: notifications and budget alerts on, debug off', () async {
      final s = await repo.load();
      expect(s.notificationsEnabled, isTrue);
      expect(s.budgetAlertsEnabled, isTrue);
      expect(s.debugUnlockAll, isFalse);
      expect(s.latestSeenAt, isNull);
    });

    test('round trip of the new switches', () async {
      await repo.setNotificationsEnabled(enabled: false);
      await repo.setBudgetAlertsEnabled(enabled: false);
      await repo.setDebugUnlockAll(enabled: true);
      final s = await repo.load();
      expect(s.notificationsEnabled, isFalse);
      expect(s.budgetAlertsEnabled, isFalse);
      expect(s.debugUnlockAll, isTrue);
    });

    test('raiseLatestSeenAt never lowers the value', () async {
      await repo.raiseLatestSeenAt(2000);
      await repo.raiseLatestSeenAt(1000);
      expect((await repo.load()).latestSeenAt, 2000);
      await repo.raiseLatestSeenAt(3000);
      expect((await repo.load()).latestSeenAt, 3000);
    });

    test('bad JSON in a new key falls back to its default', () async {
      await putRaw('budgetAlertsEnabled', '{not json');
      await putRaw('latestSeenAt', '"later"');
      final s = await repo.load();
      expect(s.budgetAlertsEnabled, isTrue);
      expect(s.latestSeenAt, isNull);
    });

    test('module state is namespaced under module.<key>', () async {
      expect(await repo.readModuleState('expense.budgetRolloverMonth'), isNull);
      await repo.writeModuleState('expense.budgetRolloverMonth', '2026-10');
      expect(
        await repo.readModuleState('expense.budgetRolloverMonth'),
        '2026-10',
      );
      final raw =
          await (db.select(db.settings)..where(
                (t) => t.key.equals('module.expense.budgetRolloverMonth'),
              ))
              .getSingle();
      expect(jsonDecode(raw.value), '2026-10');
      // Not confused with a same-named settings key.
      expect(await repo.readModuleState('locale'), isNull);
    });

    test('corrupt module state reads as null', () async {
      await putRaw('module.expense.x', '{not json');
      expect(await repo.readModuleState('expense.x'), isNull);
    });
  });

  // --- 005-habit-module (T018, research R17) ---

  group('feature 005 settings', () {
    test('habit reminders default to on', () async {
      expect((await repo.load()).habitRemindersEnabled, isTrue);
    });

    test('habit reminders round trip', () async {
      await repo.setHabitRemindersEnabled(enabled: false);
      expect((await repo.load()).habitRemindersEnabled, isFalse);
      await repo.setHabitRemindersEnabled(enabled: true);
      expect((await repo.load()).habitRemindersEnabled, isTrue);
    });

    test('bad JSON falls back to on', () async {
      await putRaw('habitRemindersEnabled', '"no"');
      expect((await repo.load()).habitRemindersEnabled, isTrue);
    });
  });

  // --- 009-ads-rewarded-pro (T010): the interstitial cap keys. ---
  group('interstitial cap keys (feature 009 data-model §1)', () {
    test('the install time is written once and never moved', () async {
      await repo.setAdsInstallAtIfMissing(1000);
      await repo.setAdsInstallAtIfMissing(2000);
      expect((await repo.load()).adsInstallAt, 1000);
    });

    test('a shown interstitial, the session day, and the dev reset '
        'round-trip', () async {
      await repo.recordInterstitialShown(
        at: 5000,
        dayKey: '2026-10-22',
        countToday: 3,
      );
      await repo.setAdsLastSessionDay('2026-10-22');
      var s = await repo.load();
      expect(s.adsLastInterstitialAt, 5000);
      expect(s.adsInterstitialDay, '2026-10-22');
      expect(s.adsInterstitialsToday, 3);
      expect(s.adsLastSessionDay, '2026-10-22');
      await repo.resetAdCounters(installAt: 42);
      s = await repo.load();
      expect(s.adsInstallAt, 42);
      expect(s.adsLastInterstitialAt, isNull);
      expect(s.adsInterstitialDay, isNull);
      expect(s.adsInterstitialsToday, 0);
      expect(s.adsLastSessionDay, '2026-10-22');
    });

    test('corrupt values fall back to defaults', () async {
      await putRaw('adsInterstitialsToday', '-3');
      await putRaw('adsInterstitialDay', '"not a day"');
      final s = await repo.load();
      expect(s.adsInterstitialsToday, 0);
      expect(s.adsInterstitialDay, isNull);
    });

    test(
      'FR-053 rewarded counts round-trip; bad entries are dropped',
      () async {
        await repo.setRewardedCounts(
          dayKey: '2026-10-22',
          counts: const {'advancedReports': 3, 'premiumTheme_rose': 1},
        );
        var s = await repo.load();
        expect(s.rewardedDay, '2026-10-22');
        expect(s.rewardedCounts, {
          'advancedReports': 3,
          'premiumTheme_rose': 1,
        });
        await putRaw(
          'rewardedCounts',
          '{"exportPdf": 2, "bad": "x", "neg": -1}',
        );
        s = await repo.load();
        expect(s.rewardedCounts, {'exportPdf': 2});
      },
    );

    test('Pro state is written together and clamps the streak', () async {
      await repo.setProState(
        owned: true,
        notOwnedStreak: 1,
        pending: true,
        removalPending: true,
      );
      var s = await repo.load();
      expect(s.removeAdsPurchased, isTrue);
      expect(s.proNotOwnedStreak, 1);
      expect(s.proPurchasePending, isTrue);
      expect(s.proRemovalPending, isTrue);
      await putRaw('proNotOwnedStreak', '9');
      s = await repo.load();
      expect(s.proNotOwnedStreak, 2);
    });

    test('FR-025 none of the keys travels in a backup', () {
      for (final key in [
        'removeAdsPurchased',
        'proNotOwnedStreak',
        'proPurchasePending',
        'proRemovalPending',
        'rewardedDay',
        'rewardedCounts',
        'adsInstallAt',
        'adsLastInterstitialAt',
        'adsInterstitialDay',
        'adsInterstitialsToday',
        'adsLastSessionDay',
      ]) {
        expect(BackupSettingsPolicy.isRestorable(key), isFalse, reason: key);
      }
    });
  });
}
