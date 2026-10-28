import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_transaction_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_entry_repository.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

/// Erase all data (T018, FR-048, data-model §6, research R16), with feature
/// 011's two scopes (T008, data-model §3).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late MutableClock clock;
  late FakeNotificationService notifications;
  late InMemorySecureStore secure;
  late List<FakeTrackerModule> modules;
  late List<String> order;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MutableClock(DateTime(2026, 10, 21, 10));
    notifications = FakeNotificationService();
    secure = InMemorySecureStore()
      ..values['lock.pin'] = '{}'
      ..values['lock.lockout'] = '{}'
      ..values['other'] = 'keep';
    modules = [
      FakeTrackerModule(id: 'expense'),
      FakeTrackerModule(id: 'habit'),
    ];
    order = [];
  });
  tearDown(() => db.close());

  DriftAppResetService service() => DriftAppResetService(
    db: db,
    modules: modules,
    read: <T>(p) => throw UnimplementedError(),
    notifications: notifications,
    resetLock: () async {
      order.add('lock');
      await secure.deleteWhere((k) => k.startsWith('lock.'));
    },
    afterErase: () => order.add('after'),
  );

  /// One row in every table, as a real user would have them.
  Future<void> seedEverything() async {
    final settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    await SeedRunner(db).runAll(registeredModules.expand((m) => m.seeders));
    await settings.completeOnboarding(
      const OnboardingChoices(
        locale: 'gu',
        currencyCode: 'USD',
        moduleOrder: ['expense', 'habit'],
        enabledModules: ['expense', 'habit'],
      ),
    );
    await settings.setLockEnabled(enabled: true);
    final account = (await db.select(db.accounts).get()).first;
    final category = (await db.select(db.categories).get()).first;
    await DriftTransactionRepository(db, clock).create(
      TransactionDraft(
        type: TxnType.expense,
        paymentMode: PaymentMode.cash,
        occurredAt: clock.now().toUtc(),
        amountMinor: 125000,
        accountId: account.id,
        categoryId: category.id,
        note: 'Rent',
      ),
    );
    final habit = await DriftHabitRepository(db, clock).create(
      HabitDraft(
        name: 'Read',
        iconKey: 'menu_book',
        colorHex: '#2B7ACA',
        kind: HabitKind.yesNo,
        schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
        startDate: LocalDate.fromKey('2026-10-01'),
      ),
    );
    await DriftHabitEntryRepository(
      db,
      clock,
      StreakEngine(clock),
    ).apply(habit.id, const LocalDate(2026, 10, 20), const Toggle());
    await DriftUnlockRepository(db, clock).grant(
      FeatureKey.premiumTheme('saffron'),
      source: UnlockSource.rewardedAd,
    );
  }

  Future<Map<String, int>> counts() async => {
    for (final table in db.allTables)
      table.actualTableName:
          (await db
                  .customSelect(
                    'SELECT COUNT(*) AS c FROM ${table.actualTableName}',
                  )
                  .getSingle())
              .read<int>('c'),
  };

  test('every user data table is empty afterwards, and only the kept '
      'settings rows remain; modules, notifications, and the lock are '
      'cleared; then the app restarts', () async {
    await seedEverything();
    final before = await counts();
    for (final name in [
      'settings',
      'accounts',
      'categories',
      'transactions',
      'habits',
      'habit_entries',
      'unlocks',
    ]) {
      expect(before[name], greaterThan(0), reason: name);
    }

    await service().eraseAll();

    final after = await counts();
    expect(
      after.entries.where((e) => e.key != 'settings' && e.value > 0),
      isEmpty,
    );
    final keys = {for (final r in await db.select(db.settings).get()) r.key};
    expect(keys.difference(DriftAppResetService.keptByErase), isEmpty);
    expect([for (final m in modules) m.eraseAllCalls], [1, 1]);
    expect(notifications.cancelAllCalls, 1);
    expect(secure.values.keys, ['other']);
    expect(order, ['lock', 'after']);
  });

  test(
    'a failing delete changes nothing and stops before the other steps',
    () async {
      await seedEverything();
      final before = await counts();
      // A trigger makes the habit_entries delete fail inside the transaction.
      await db.customStatement(
        'CREATE TRIGGER no_erase BEFORE DELETE ON habit_entries '
        "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
      );
      await expectLater(service().eraseAll(), throwsA(anything));
      expect(await counts(), before);
      expect([for (final m in modules) m.eraseAllCalls], [0, 0]);
      expect(notifications.cancelAllCalls, 0);
      expect(secure.values.containsKey('lock.pin'), isTrue);
      expect(order, isEmpty);
    },
  );

  test('a failing module, notification, or lock step does not stop the '
      'rest', () async {
    await seedEverything();
    modules.first.onEraseAllBody = () async => throw StateError('x');
    final failing = DriftAppResetService(
      db: db,
      modules: modules,
      read: <T>(p) => throw UnimplementedError(),
      notifications: notifications,
      resetLock: () async => throw StateError('keystore'),
      afterErase: () => order.add('after'),
    );
    await failing.eraseAll();
    expect([for (final m in modules) m.eraseAllCalls], [1, 1]);
    expect(notifications.cancelAllCalls, 1);
    expect(order, ['after']);
  });

  test(
    'feature 008 T130: after the lock, the widget is redrawn (now hidden), '
    'then startup runs again; a failing refresh never blocks the erase',
    () async {
      final withWidget = DriftAppResetService(
        db: db,
        modules: modules,
        read: <T>(p) => throw UnimplementedError(),
        notifications: notifications,
        resetLock: () async => order.add('lock'),
        afterErase: () => order.add('after'),
        refreshGlance: () async => order.add('widget'),
      );
      await withWidget.eraseAll();
      expect(order, ['lock', 'widget', 'after']);

      order.clear();
      final failing = DriftAppResetService(
        db: db,
        modules: modules,
        read: <T>(p) => throw UnimplementedError(),
        notifications: notifications,
        resetLock: () async => order.add('lock'),
        afterErase: () => order.add('after'),
        refreshGlance: () async => throw StateError('no widget host'),
      );
      await failing.eraseAll();
      expect(order, ['lock', 'after']);
    },
  );

  // --- 009-ads-rewarded-pro (T011): the install time survives. ---
  test(
    'the interstitial install time and Pro are kept; every other ad '
    'counter goes (feature 009 research R9, feature 011 analysis I2)',
    () async {
      final settings = SettingsRepositoryImpl(
        db,
        knownModuleIds: const ['expense', 'habit'],
      );
      await settings.setAdsInstallAtIfMissing(1234);
      await settings.recordInterstitialShown(
        at: 5000,
        dayKey: '2026-10-21',
        countToday: 2,
      );
      await db.customStatement(
        "INSERT INTO settings VALUES ('removeAdsPurchased', 'true', 0)",
      );
      await service().eraseAll();
      final s = await settings.load();
      expect(s.adsInstallAt, 1234);
      expect(s.adsLastInterstitialAt, isNull);
      expect(s.adsInterstitialsToday, 0);
      expect(s.removeAdsPurchased, isTrue);
      expect(await db.select(db.settings).get(), hasLength(2));
    },
  );

  // --- 010-google-account-backup (T041, FR-006a, data-model §1). ---
  group('SET-01 Erase all data keeps the sign-in', () {
    late SettingsRepositoryImpl settings;

    setUp(() {
      settings = SettingsRepositoryImpl(
        db,
        knownModuleIds: const ['expense', 'habit'],
      );
    });

    /// A signed-in phone with data, a known Drive backup, Weekly auto
    /// backups on any network, and counters that have moved.
    Future<void> signedInWithData() async {
      await seedEverything();
      await settings.setAdsInstallAtIfMissing(1234);
      await settings.setDeviceIdCopy('this-phone');
      await settings.setAccount(
        const AccountProfile(
          email: 'me@example.com',
          displayName: 'Asha Patel',
          photoUrl: 'https://example.com/a.png',
        ),
      );
      await settings.setAutoBackup(
        frequency: AutoBackupFrequency.weekly,
        wifiOnly: false,
      );
      await settings.setLastKnownDriveBackup(
        at: 1792540800000,
        deviceId: 'other-phone',
      );
      await settings.setAutoBackupPause(paused: true, notified: true);
      await settings.setBackedUpChangeCounter(3);
    }

    test('SET-01 erase does not sign out: the account keys, sign-in mode, '
        'Auto backup settings, device ID, install time, last known Drive '
        'backup, onboarding, and the device preferences are kept; both change '
        'counters go back to 0; the pause and the lock reset', () async {
      await signedInWithData();
      await settings.setAuthMode(AuthMode.google);
      final before = await settings.load();
      expect(before.dataChangeCounter, greaterThan(0));

      await service().eraseAll();
      final s = await settings.load();
      expect(s.authMode, AuthMode.google);
      expect(s.backupAccountEmail, 'me@example.com');
      expect(s.accountDisplayName, 'Asha Patel');
      expect(s.accountPhotoUrl, 'https://example.com/a.png');
      expect(s.deviceId, 'this-phone');
      expect(s.adsInstallAt, 1234);
      expect(s.autoBackupFrequency, AutoBackupFrequency.weekly);
      expect(s.autoBackupWifiOnly, isFalse);
      expect(s.lastKnownDriveBackupAt, 1792540800000);
      expect(s.lastKnownDriveBackupDeviceId, 'other-phone');
      expect(s.dataChangeCounter, 0);
      expect(s.backedUpChangeCounter, 0);
      // Kept by every erase (clarification Q1): the app opens Home.
      expect(s.onboardingDone, isTrue);
      expect(s.locale, 'gu');
      expect(s.currencyCode, 'USD');
      // Not kept: the pause and the lock.
      expect(s.autoBackupPausedByConflict, isFalse);
      expect(s.lockEnabled, isFalse);
      final keys = {
        for (final row in await db.select(db.settings).get()) row.key,
      };
      expect(keys.difference(DriftAppResetService.keptByErase), isEmpty);
    });
  });

  // --- 011-login-guest-mode (T008, data-model §3): the guest scope. ---
  group('ACC-04 Log out of guest (EraseScope.guestLogOut)', () {
    late SettingsRepositoryImpl settings;

    setUp(() {
      settings = SettingsRepositoryImpl(
        db,
        knownModuleIds: const ['expense', 'habit'],
      );
    });

    /// A guest with data, a theme, ad consent, Pro, Backup settings, and
    /// a known backup an earlier account left behind.
    Future<void> guestWithData() async {
      await seedEverything();
      await settings.setAuthMode(AuthMode.guest);
      await settings.setThemeMode('dark');
      await settings.setSelectedTheme('saffron');
      await settings.setAdsInstallAtIfMissing(1234);
      await settings.setDeviceIdCopy('this-phone');
      await settings.setAutoBackup(
        frequency: AutoBackupFrequency.weekly,
        wifiOnly: false,
      );
      await settings.setLastKnownDriveBackup(at: 1, deviceId: 'x');
      await db.customStatement(
        "INSERT INTO settings VALUES ('removeAdsPurchased', 'true', 0)",
      );
      await db.customStatement('INSERT INTO settings VALUES (?, ?, 0)', [
        SettingsCodec.adConsentStatus,
        '"obtained"',
      ]);
    }

    test('ACC-04 "Log out and delete" removes all module rows and rewarded '
        'unlocks, resets the change counters, and sets authMode none in the '
        'same transaction', () async {
      await guestWithData();
      await service().eraseAll(scope: EraseScope.guestLogOut);
      final after = await counts();
      expect(
        after.entries.where((e) => e.key != 'settings' && e.value > 0),
        isEmpty,
      );
      expect(after['unlocks'], 0);
      final s = await settings.load();
      expect(s.authMode, AuthMode.none);
      expect(s.dataChangeCounter, 0);
      expect(s.backedUpChangeCounter, 0);
    });

    test('ACC-04 After "Log out and delete," language, currency, theme, '
        'enabled modules, onboarding done, and Pro are kept; Backup settings '
        'and the known backup go', () async {
      await guestWithData();
      await service().eraseAll(scope: EraseScope.guestLogOut);
      final s = await settings.load();
      expect(s.locale, 'gu');
      expect(s.currencyCode, 'USD');
      expect(s.themeMode, 'dark');
      expect(s.selectedTheme, 'saffron');
      expect(s.enabledModules, ['expense', 'habit']);
      expect(s.onboardingDone, isTrue);
      expect(s.removeAdsPurchased, isTrue);
      expect(s.adConsentStatus, 'obtained');
      expect(s.deviceId, 'this-phone');
      expect(s.adsInstallAt, 1234);
      expect(s.autoBackupFrequency, AutoBackupFrequency.off);
      expect(s.autoBackupWifiOnly, isTrue);
      expect(s.lastKnownDriveBackupAt, isNull);
      expect(s.lockEnabled, isFalse);
      final keys = {
        for (final row in await db.select(db.settings).get()) row.key,
      };
      expect(
        keys.difference({
          ...DriftAppResetService.keptByGuestLogOut,
          SettingsCodec.authMode,
        }),
        isEmpty,
      );
    });

    test('ACC-04 "Log out and delete" deletes the PIN hash and lockout state '
        'and cancels every scheduled notification; module files go through '
        'onEraseAll; a failing step never stops the next', () async {
      await guestWithData();
      modules.first.onEraseAllBody = () async => throw StateError('x');
      await service().eraseAll(scope: EraseScope.guestLogOut);
      expect(secure.values.keys, ['other']);
      expect(notifications.cancelAllCalls, 1);
      expect([for (final m in modules) m.eraseAllCalls], [1, 1]);
      expect(order, ['lock', 'after']);
    });

    test('ACC-04 A failed erase leaves all data and settings in place, and '
        'the user stays a guest', () async {
      await guestWithData();
      final before = await counts();
      final settingsBefore = await settings.load();
      await db.customStatement(
        'CREATE TRIGGER no_erase BEFORE DELETE ON habit_entries '
        "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
      );
      await expectLater(
        service().eraseAll(scope: EraseScope.guestLogOut),
        throwsA(anything),
      );
      expect(await counts(), before);
      final s = await settings.load();
      expect(s, settingsBefore);
      expect(s.authMode, AuthMode.guest);
      expect(secure.values.containsKey('lock.pin'), isTrue);
      expect(notifications.cancelAllCalls, 0);
    });
  });
}
