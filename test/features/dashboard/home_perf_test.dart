@Tags(['perf'])
library;

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_account_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_category_repository.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import '../../helpers/real_app.dart';

/// SC-001 host stand-in (T060, research R15): with 10,000 transactions over
/// 24 months, an Overall budget, and 20 habits × 400 days of entries, Home
/// shows the Expense card, the habit ring, five recent rows, and the streak
/// flame within 300 ms of pumping. The on-device timing is checked by hand
/// (quickstart §4). "Now" is 2026-10-21 10:00.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> seed(AppDatabase db, MutableClock clock) async {
    await SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    ).completeOnboarding(
      const OnboardingChoices(
        locale: 'en',
        currencyCode: 'INR',
        moduleOrder: ['expense', 'habit'],
        enabledModules: ['expense', 'habit'],
      ),
    );
    final cash = (await DriftAccountRepository(db, clock).create(
      name: 'Cash',
      type: AccountType.cash,
      openingBalanceMinor: 0,
      iconKey: 'wallet',
      colorHex: '#0F766E',
    )).id;
    final categories = DriftCategoryRepository(db, clock);
    final categoryIds = [
      for (var i = 0; i < 12; i++)
        (await categories.create(
          name: 'Category $i',
          type: CategoryType.expense,
          iconKey: 'category',
          colorHex: '#0F766E',
        )).id,
    ];
    final nowMs = clock.now().toUtc().millisecondsSinceEpoch;
    const span = 730 * Duration.millisecondsPerDay;
    await db.batch((b) {
      b
        ..insertAll(db.transactions, [
          for (var i = 0; i < 10000; i++)
            TransactionsCompanion.insert(
              id: 'txn-$i',
              type: TxnType.expense,
              amountMinor: 100 + i % 5000,
              accountId: cash,
              categoryId: Value(categoryIds[i % categoryIds.length]),
              paymentMode: PaymentMode.cash,
              occurredAt: nowMs - (span * i ~/ 10000),
              createdAt: nowMs,
              updatedAt: nowMs,
            ),
        ])
        ..insert(
          db.budgets,
          BudgetsCompanion.insert(
            id: 'budget-overall',
            monthKey: '2026-10',
            limitMinor: 5000000,
            rollover: true,
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    });
    final habits = DriftHabitRepository(db, clock);
    final habitIds = [
      for (var i = 0; i < 20; i++)
        (await habits.create(
          HabitDraft(
            name: 'Habit $i',
            iconKey: 'menu_book',
            colorHex: '#2B7ACA',
            kind: HabitKind.yesNo,
            schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
            startDate: LocalDate.fromKey('2025-09-01'),
          ),
        )).id,
    ];
    final today = LocalDate.fromDateTime(clock.now());
    await db.batch((b) {
      b.insertAll(db.habitEntries, [
        for (final (h, id) in habitIds.indexed)
          for (var d = 1; d <= 400; d++)
            if ((d + h) % 7 != 0)
              HabitEntriesCompanion.insert(
                id: '$id-$d',
                habitId: id,
                dateKey: today.addDays(-d).key,
                value: 1,
                createdAt: nowMs,
                updatedAt: nowMs,
              ),
      ]);
    });
  }

  testWidgets('DSH-01 SC-001 Home shows its content in under 300 ms with '
      '10,000 transactions and 20 habits', (tester) async {
    final clock = MutableClock(DateTime(2026, 10, 21, 10));

    Future<int> measure() async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.runAsync(() async {
        await seed(db, clock);
        // SYS-01 work before Home, outside the timed window.
        await SettingsRepositoryImpl(
          db,
          knownModuleIds: const ['expense', 'habit'],
        ).migrateAuthMode();
      });
      final watch = Stopwatch()..start();
      await pumpRealDbApp(tester, db: db, clock: clock, migrateAuthMode: false);
      bool ready() =>
          find.byKey(const Key('spent_today')).evaluate().isNotEmpty &&
          find.byKey(const Key('habit_card_ring')).evaluate().isNotEmpty &&
          find
                  .byWidgetPredicate(
                    (w) =>
                        w.key is ValueKey<String> &&
                        (w.key! as ValueKey<String>).value.startsWith(
                          'recent_row_',
                        ),
                  )
                  .evaluate()
                  .length ==
              5 &&
          find.byKey(const Key('streak_flame_count')).evaluate().isNotEmpty;
      while (!ready() && watch.elapsedMilliseconds < 2000) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 1)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      watch.stop();
      expect(ready(), isTrue);
      await tester.pumpWidget(const SizedBox());
      await settleRealDb(tester);
      await tester.runAsync(db.close);
      return watch.elapsedMilliseconds;
    }

    // Warm up the JIT first: the app ships AOT compiled (same practice as
    // test/app/bootstrap_perf_test.dart). Then take the median of three runs,
    // so one slow host scheduling hiccup does not decide the result.
    await measure();
    final runs = [for (var i = 0; i < 3; i++) await measure()]..sort();
    // ignore: avoid_print, the timing goes into the task summary.
    print('DSH-01 Home content in $runs ms');
    expect(runs[1], lessThan(300));
  });
}
