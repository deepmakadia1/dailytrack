import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fakes.dart';
import '../helpers/real_container.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late MockAdService ads;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    ads = MockAdService();
    when(() => ads.initialize()).thenAnswer((_) async {});
  });
  tearDown(() => db.close());

  Future<BootstrapResult> boot(ProviderContainer c) {
    c.listen(bootstrapProvider, (_, _) {});
    return c.read(bootstrapProvider.future);
  }

  Future<ProviderContainer> containerWith({
    bool onboardingDone = false,
    bool lockEnabled = false,
    bool removeAdsPurchased = false,
    List<String>? enabled,
  }) async {
    final c = makeRealContainer(db, ads: ads);
    final repo = c.read(settingsRepositoryProvider);
    if (onboardingDone) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
      );
    }
    if (lockEnabled) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('lockEnabled', 'true', 0)",
      );
    }
    if (removeAdsPurchased) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('removeAdsPurchased', 'true', 0)",
      );
    }
    if (enabled != null) {
      await repo.setModules(order: ['expense', 'habit'], enabled: enabled);
    }
    return c;
  }

  group('SYS-01 returning user with lock on lands on SYS-03; without lock '
      'lands on DSH-01', () {
    test('lock on → /lock', () async {
      final c = await containerWith(onboardingDone: true, lockEnabled: true);
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        Routes.lockPath(from: Routes.home),
      );
    });

    test('lock off → /home', () async {
      final c = await containerWith(onboardingDone: true);
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
    });

    test('onboarding not done → /onboarding', () async {
      final c = await containerWith(lockEnabled: true);
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.onboarding);
    });
  });

  group('SYS-01 ads SDK is not initialized when Remove Ads is purchased', () {
    test('purchased → initialize is never called', () async {
      final c = await containerWith(removeAdsPurchased: true);
      await boot(c);
      verifyNever(() => ads.initialize());
    });

    test('not purchased → initialize is called once', () async {
      final c = await containerWith();
      await boot(c);
      verify(() => ads.initialize()).called(1);
    });
  });

  test('an ads failure never blocks startup', () async {
    when(() => ads.initialize()).thenThrow(StateError('ads down'));
    final c = await containerWith(onboardingDone: true);
    expect(await boot(c), isA<BootstrapReady>());
  });

  test('a database that cannot open gives BootstrapFailed', () async {
    final broken = AppDatabase(
      LazyDatabase(() async => throw StateError('disk full')),
    );
    // Never opened, so there is nothing to close (closing would rethrow).
    final c = makeRealContainer(broken, ads: ads);
    expect(await boot(c), isA<BootstrapFailed>());
    verifyNever(() => ads.initialize());
  });

  test('seeds every registered module, even disabled ones', () async {
    final c = await containerWith(enabled: ['habit']);
    await boot(c);
    final expense = await (db.select(
      db.categories,
    )..where((r) => r.type.equalsValue(CategoryType.expense))).get();
    expect(expense, hasLength(12));
    expect(await db.select(db.accounts).get(), hasLength(1));
  });

  test('retry runs startup again', () async {
    final c = await containerWith(onboardingDone: true);
    await boot(c);
    await c.read(bootstrapProvider.notifier).retry();
    expect(c.read(bootstrapProvider).value, isA<BootstrapReady>());
    expect(await db.select(db.accounts).get(), hasLength(1));
  });

  test('FakeBootstrap mirrors the real startup rule', () async {
    final repo = FakeSettingsRepository();
    final c = ProviderContainer(
      overrides: [
        bootstrapProvider.overrideWith(() => FakeBootstrap.fromSettings(repo)),
      ],
    );
    addTearDown(c.dispose);
    final r = await boot(c);
    expect((r as BootstrapReady).initialLocation, Routes.onboarding);
  });

  // --- 003-budgets-recurring-reports (T021): app-open hooks and the
  // notification launch payload (research R10, R15). ---
  group('app open', () {
    late FakeTrackerModule expense;
    late FakeTrackerModule habit;
    late FakeNotificationService notifications;

    Future<ProviderContainer> start({
      bool lockEnabled = false,
      String? payload,
      List<String> enabled = const ['expense', 'habit'],
    }) async {
      expense = FakeTrackerModule(id: 'expense');
      habit = FakeTrackerModule(id: 'habit');
      notifications = FakeNotificationService(payloadAtLaunch: payload);
      final c = makeRealContainer(
        db,
        ads: ads,
        registry: ModuleRegistry([expense, habit]),
        notifications: notifications,
      );
      await db.customStatement(
        "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
      );
      if (lockEnabled) {
        await db.customStatement(
          "INSERT INTO settings VALUES ('lockEnabled', 'true', 0)",
        );
      }
      await c
          .read(settingsRepositoryProvider)
          .setModules(order: ['expense', 'habit'], enabled: enabled);
      return c;
    }

    test(
      'a never-completing onAppOpen does not delay the first route',
      () async {
        final c = await start();
        final never = Completer<void>();
        expense.onAppOpenBody = () => never.future;
        final r = await boot(c).timeout(const Duration(seconds: 2));
        expect((r as BootstrapReady).initialLocation, Routes.home);
        await pumpEventQueue();
        expect(expense.appOpenCalls, 1);
        expect(c.read(appOpenRunnerProvider).isRunning, isTrue);
      },
    );

    test(
      'a throwing onAppOpen is ignored and later modules still run',
      () async {
        final c = await start();
        expense.onAppOpenBody = () async => throw StateError('rollover failed');
        expect(await boot(c), isA<BootstrapReady>());
        await c.read(appOpenRunnerProvider).run();
        expect(expense.appOpenCalls, greaterThanOrEqualTo(1));
        expect(habit.appOpenCalls, greaterThanOrEqualTo(1));
      },
    );

    test('disabled modules are skipped', () async {
      final c = await start(enabled: ['habit']);
      await boot(c);
      await c.read(appOpenRunnerProvider).run();
      expect(expense.appOpenCalls, 0);
      expect(habit.appOpenCalls, greaterThanOrEqualTo(1));
    });

    test('the in-flight guard skips a second run while one is going', () async {
      final c = await start();
      final gate = Completer<void>();
      expense.onAppOpenBody = () => gate.future;
      final runner = c.read(appOpenRunnerProvider);
      final first = runner.run();
      final second = runner.run(); // e.g. a resume during cold start
      await pumpEventQueue();
      expect(expense.appOpenCalls, 1);
      gate.complete();
      await Future.wait([first, second]);
      await runner.run();
      expect(expense.appOpenCalls, 2);
    });

    test('app open raises latestSeenAt for the feature gate', () async {
      final c = await start();
      await c.read(appOpenRunnerProvider).run();
      await pumpEventQueue();
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.latestSeenAt, isNotNull);
    });

    test('notifications are initialized at startup', () async {
      final c = await start();
      await boot(c);
      expect(notifications.initializeCalls, 1);
    });

    test(
      'EXP-02 US2-6 a launch payload opens its location when lock is off',
      () async {
        final c = await start(payload: '/expenses/budgets?month=2026-09');
        final r = await boot(c);
        expect(
          (r as BootstrapReady).initialLocation,
          '/expenses/budgets?month=2026-09',
        );
      },
    );

    test('EXP-02 US2-6 tap with lock on goes through SYS-03, then to the '
        'alert (feature 007)', () async {
      final c = await start(
        lockEnabled: true,
        payload: '/expenses/budgets?month=2026-09',
      );
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        Routes.lockPath(from: '/expenses/budgets?month=2026-09'),
      );
    });

    test('a payload that is not a location is ignored', () async {
      final c = await start(payload: 'budget');
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
    });
  });
}
