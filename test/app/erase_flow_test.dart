import 'dart:async';
import 'dart:convert';

import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_transaction_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_entry_repository.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/habit_bindings.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../helpers/fakes.dart';
import '../helpers/mutable_clock.dart';
import '../helpers/real_app.dart';

/// Erase all data end to end (feature 007 T040, T064; US2-7, US7;
/// FR-047, FR-048, SC-008): a real in-memory database with the production
/// Expense and Habit bindings, the real erase service, and the real startup,
/// which reseeds the defaults and lands on onboarding. Only device services
/// (notifications, secure storage, biometrics, FLAG_SECURE) are fakes.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late MutableClock clock;
  late FakeNotificationService notifications;
  late InMemorySecureStore secure;
  late PinHasher hasher;
  late Map<String, int> defaults;

  // Hashed once outside the widget tests' fake-time zone.
  late String pinRecord;
  setUpAll(() async {
    final record = await PinHasher(
      iterations: 1000,
      runner: (f) async => await f(),
    ).hash('1234');
    pinRecord = jsonEncode(record.toJson());
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MutableClock(DateTime(2026, 10, 21, 10));
    notifications = FakeNotificationService();
    secure = InMemorySecureStore();
    hasher = PinHasher(iterations: 1000, runner: (f) async => await f());
  });
  tearDown(() => db.close());

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
          .read<int>('c');

  /// A user with data in every module table, and optionally app lock on.
  Future<void> seedUser({required bool lockOn}) async {
    await SeedRunner(db).runAll(registeredModules.expand((m) => m.seeders));
    defaults = {
      'categories': await count('categories'),
      'accounts': await count('accounts'),
    };
    final settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    await settings.completeOnboarding(
      const OnboardingChoices(
        locale: 'en',
        currencyCode: 'USD',
        moduleOrder: ['habit', 'expense'],
        enabledModules: ['expense', 'habit'],
      ),
    );
    await settings.setSelectedTheme('saffron');
    await settings.setDateFormat('iso');
    final account = (await db.select(db.accounts).get()).first;
    final food = (await db.select(db.categories).get()).first;
    await DriftTransactionRepository(db, clock).create(
      TransactionDraft(
        type: TxnType.expense,
        paymentMode: PaymentMode.upi,
        occurredAt: clock.now().toUtc(),
        amountMinor: 125000,
        accountId: account.id,
        categoryId: food.id,
        note: 'Rent',
      ),
    );
    await DriftBudgetRepository(db, clock, settings).create(
      const BudgetDraft(
        monthKey: '2026-10',
        limitMinor: 500000,
        rollover: false,
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
    await DriftUnlockRepository(
      db,
      clock,
    ).grant(FeatureKey.premiumTheme('saffron'), source: UnlockSource.purchase);
    if (lockOn) {
      secure
        ..values[SecureLockService.pinKey] = pinRecord
        ..values[SecureLockService.lockoutKey] =
            '{"failedAttempts":2,'
            '"level":0,"lockedAtUtcMs":null,"lockedUntilUtcMs":null}';
      await settings.setLockEnabled(enabled: true);
    }
  }

  Future<void> pumpRealApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final registry = ModuleRegistry(registeredModules);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWith(
            (ref) => SettingsRepositoryImpl(db, knownModuleIds: registry.ids),
          ),
          clockProvider.overrideWithValue(clock),
          adServiceProvider.overrideWithValue(const NoAdsService()),
          notificationPermissionProvider.overrideWithValue(
            FakeNotificationPermission(),
          ),
          moduleRegistryProvider.overrideWithValue(registry),
          textSharerProvider.overrideWithValue(FakeTextSharer()),
          imageSharerProvider.overrideWithValue(FakeImageSharer()),
          featureGateProvider.overrideWithValue(FakeFeatureGate()),
          notificationServiceProvider.overrideWithValue(notifications),
          debugToolsAvailableProvider.overrideWithValue(false),
          backgroundSchedulerProvider.overrideWithValue(
            FakeBackgroundScheduler(),
          ),
          appInfoSourceProvider.overrideWithValue(FakeAppInfoSource()),
          deviceInfoSourceProvider.overrideWithValue(FakeDeviceInfoSource()),
          appReviewServiceProvider.overrideWithValue(FakeAppReviewService()),
          externalLauncherProvider.overrideWithValue(FakeExternalLauncher()),
          lockServiceProvider.overrideWith(
            (ref) => SecureLockService(
              store: secure,
              biometrics: FakeBiometricAuthenticator(),
              settings: ref.watch(settingsRepositoryProvider),
              clock: clock,
              hasher: hasher,
            ),
          ),
          secureScreenServiceProvider.overrideWithValue(
            FakeSecureScreenService(),
          ),
          // The production erase service, as bound in the composition root.
          appResetServiceProvider.overrideWith(
            (ref) => DriftAppResetService(
              db: db,
              modules: registry.all,
              read: ref.read,
              notifications: notifications,
              resetLock: () => ref.read(lockServiceProvider).reset(),
              afterErase: () {
                ref.read(lockSessionProvider.notifier).reset();
                ref.invalidate(bootstrapProvider);
              },
            ),
          ),
          ...expenseOverrides(),
          ...habitOverrides(),
        ],
        child: const DailyTrackApp(),
      ),
    );
    await settleRealDb(tester);
  }

  Future<void> eraseThroughDialogs(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await settleRealDb(tester);
    await tester.enterText(
      find.byKey(const Key('typed_confirm_field')),
      'DELETE',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await settleRealDb(tester);
    await settleRealDb(tester);
  }

  /// Everything the user had is gone; only the first-launch defaults are
  /// back, and the app is at onboarding.
  /// Disposes the app, so no screen or provider timer outlives the test.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settleRealDb(tester);
  }

  /// Runs a database read while pumping, so work the restarted startup
  /// scheduled in fake time can finish and release the database.
  Future<T> read<T>(WidgetTester tester, Future<T> Function() query) async {
    late T value;
    var done = false;
    unawaited(
      query().then((v) {
        value = v;
        done = true;
      }),
    );
    for (var i = 0; i < 20 && !done; i++) {
      await settleRealDb(tester);
    }
    expect(done, isTrue, reason: 'database read did not finish');
    return value;
  }

  Future<void> expectEverythingCleared(WidgetTester tester) async {
    expect(find.byType(OnboardingScreen), findsOneWidget);
    const userTables = [
      'transactions',
      'budgets',
      'recurring_rules',
      'habits',
      'habit_schedules',
      'habit_entries',
      'unlocks',
    ];
    final counts = await read(tester, () async {
      return {
        for (final table in [...userTables, 'categories', 'accounts'])
          table: await count(table),
      };
    });
    for (final table in userTables) {
      expect(counts[table], 0, reason: table);
    }
    // Reseeded once by the restarted startup, not the user's data.
    expect(counts['categories'], defaults['categories']);
    expect(counts['accounts'], defaults['accounts']);
    final settings = await read(
      tester,
      () => SettingsRepositoryImpl(
        db,
        knownModuleIds: const ['expense', 'habit'],
      ).load(),
    );
    expect(settings.onboardingDone, isFalse);
    expect(settings.lockEnabled, isFalse);
    expect(settings.currencyCode, 'INR');
    expect(settings.selectedTheme, 'default');
    expect(settings.dateFormat, 'dMMMy');
    expect(settings.moduleOrder, ['expense', 'habit']);
    expect(secure.values.keys.where((k) => k.startsWith('lock.')), isEmpty);
    expect(notifications.cancelAllCalls, 1);
  }

  testWidgets('US7 Erase all data from SET-01 clears everything and starts '
      'again at onboarding', (tester) async {
    await tester.runAsync(() => seedUser(lockOn: false));
    await pumpRealApp(tester);

    routerOf(tester).go(Routes.more);
    await settleRealDb(tester);
    final row = find.byKey(const Key('settings_erase_all'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Clear of the navigation bar.
    await tester.ensureVisible(row);
    await settleRealDb(tester);
    await tester.tap(row);
    await settleRealDb(tester);
    expect(find.text('Erase all data?'), findsOneWidget);

    await eraseThroughDialogs(tester);
    await expectEverythingCleared(tester);
    await closeApp(tester);
  });

  testWidgets('US2-7 "Forgot PIN?" on SYS-03 erases everything after DELETE, '
      'PIN and lockout included', (tester) async {
    await tester.runAsync(() => seedUser(lockOn: true));
    await pumpRealApp(tester);
    expect(find.byType(UnlockScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await settleRealDb(tester);
    expect(
      find.text(
        "Your PIN can't be recovered. You can erase all data "
        'and start fresh.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('forgot_pin_erase')));
    await settleRealDb(tester);

    await eraseThroughDialogs(tester);
    expect(find.byType(UnlockScreen), findsNothing);
    await expectEverythingCleared(tester);
    await closeApp(tester);
  });

  testWidgets('US2-8 cancelling "Forgot PIN?" keeps everything', (
    tester,
  ) async {
    await tester.runAsync(() => seedUser(lockOn: true));
    await pumpRealApp(tester);
    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await settleRealDb(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_cancel')));
    await settleRealDb(tester);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(await read(tester, () => count('transactions')), 1);
    expect(secure.values.containsKey(SecureLockService.pinKey), isTrue);
    expect(notifications.cancelAllCalls, 0);
    await closeApp(tester);
  });
}
