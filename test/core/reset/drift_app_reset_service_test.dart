import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
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

/// Erase all data (T018, FR-048, data-model §6, research R16).
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

  test('every table is empty afterwards; modules, notifications, and the '
      'lock are cleared; then the app restarts', () async {
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

    expect((await counts()).values.every((c) => c == 0), isTrue);
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
}
