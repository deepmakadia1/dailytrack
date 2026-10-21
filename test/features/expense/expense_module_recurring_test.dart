import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import '../../helpers/real_container.dart';
import 'fakes.dart';

/// ExpenseModule app-open, background and enable/disable hooks for
/// recurring rules (T068, research R10, FR-025, FR-043).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const module = ExpenseModule();

  group('with fakes', () {
    late ExpenseFakes f;
    late FakeBackgroundScheduler scheduler;
    late ProviderContainer c;

    setUp(() {
      f = ExpenseFakes.withDefaults();
      scheduler = FakeBackgroundScheduler();
      c = ProviderContainer(
        overrides: [
          ...f.overrides,
          backgroundSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(c.dispose);
    });

    test(
      'onAppOpen runs rollover, then the generator, then ensureDaily',
      () async {
        f.addRule(
          amount: 1000,
          anchor: DateTime(2026, 9, 5, 9),
          nextRun: DateTime(2026, 10, 5, 9),
        );
        await module.onAppOpen(c.read);
        expect(f.budgets.calls['rolloverIfNeeded'], 1);
        expect(f.rules.calls['generateDue'], 1);
        expect(f.active, hasLength(1));
        expect(scheduler.ensured, ['expense.recurring']);
      },
    );

    test('each onAppOpen step is isolated: a failing generator still '
        'schedules the job', () async {
      final broken = ProviderContainer(
        overrides: [
          ...f.overrides,
          backgroundSchedulerProvider.overrideWithValue(scheduler),
          recurringGeneratorProvider.overrideWith(
            (ref) => throw StateError('no rules'),
          ),
        ],
      );
      addTearDown(broken.dispose);
      await module.onAppOpen(broken.read);
      expect(f.budgets.calls['rolloverIfNeeded'], 1);
      expect(scheduler.ensured, ['expense.recurring']);
    });

    test('backgroundTasks has expense.recurring, which rolls over, generates, '
        'and returns true', () async {
      f.addRule(
        amount: 1000,
        anchor: DateTime(2026, 9, 5, 9),
        nextRun: DateTime(2026, 10, 5, 9),
      );
      final task = module.backgroundTasks[ExpenseModule.recurringTaskName]!;
      expect(await task(c.read), isTrue);
      expect(f.budgets.calls['rolloverIfNeeded'], 1);
      expect(f.active, hasLength(1));
      expect(scheduler.ensured, isEmpty, reason: 'the job is already running');
    });

    test('onEnable schedules the job and catches up', () async {
      await module.onEnable(c.read);
      expect(scheduler.ensured, contains('expense.recurring'));
      expect(f.budgets.calls['rolloverIfNeeded'], 1);
    });

    test('onDisable cancels the job and shown alerts, keeping data', () async {
      f.addRule(amount: 1000, anchor: DateTime(2026, 9, 5, 9));
      await module.onDisable(c.read);
      expect(scheduler.cancelled, ['expense.recurring']);
      expect(f.alertNotifier.cancelAllCalls, 1);
      expect(f.world.rules, hasLength(1));
    });
  });

  test('EXP-10 app open and the background task back to back create each '
      'occurrence once (real Drift)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = MutableClock(DateTime(2026, 10, 14, 10));
    final c = makeRealContainer(
      db,
      overrides: [
        clockProvider.overrideWithValue(clock),
        budgetRepositoryProvider.overrideWith(
          (ref) => DriftBudgetRepository(
            db,
            ref.watch(clockProvider),
            ref.watch(settingsRepositoryProvider),
          ),
        ),
        recurringRuleRepositoryProvider.overrideWith(
          (ref) => DriftRecurringRuleRepository(db, ref.watch(clockProvider)),
        ),
        budgetAlertNotifierProvider.overrideWithValue(
          FakeBudgetAlertNotifier(),
        ),
        notificationGateProvider.overrideWithValue(FakeNotificationGate()),
      ],
    );
    await db.customStatement(
      'INSERT INTO accounts (id, name, type, opening_balance_minor, icon_key, '
      'color_hex, is_archived, sort_order, created_at, updated_at) VALUES '
      "('cash', 'Cash', 0, 0, 'wallet', '#0F766E', 0, 0, 0, 0)",
    );
    await db.customStatement(
      'INSERT INTO categories (id, name, type, icon_key, color_hex, '
      'is_default, is_archived, sort_order, created_at, updated_at) VALUES '
      "('rent', 'Rent', 0, 'home', '#0F766E', 0, 0, 0, 0, 0)",
    );
    await c
        .read(recurringRuleRepositoryProvider)
        .createWithFirstOccurrence(
          TransactionDraft(
            type: TxnType.expense,
            amountMinor: 1500000,
            accountId: 'cash',
            categoryId: 'rent',
            paymentMode: PaymentMode.upi,
            occurredAt: DateTime(2026, 7, 5, 9).toUtc(),
          ),
          const RepeatSettings(),
        );

    await Future.wait([
      module.onAppOpen(c.read),
      module.backgroundTasks[ExpenseModule.recurringTaskName]!(c.read),
    ]);
    await module.onAppOpen(c.read);

    final rows = await db.select(db.transactions).get();
    final dates = rows.map((r) => r.occurredAt).toList()..sort();
    expect(dates.toSet(), hasLength(dates.length), reason: 'no duplicates');
    expect(
      [for (final d in dates) DateTime.fromMillisecondsSinceEpoch(d)],
      [
        DateTime(2026, 7, 5, 9),
        DateTime(2026, 8, 5, 9),
        DateTime(2026, 9, 5, 9),
        DateTime(2026, 10, 5, 9),
      ],
    );
  });
}
