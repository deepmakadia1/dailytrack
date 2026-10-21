import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// DriftBudgetRepository (contracts/repositories.md, research R4, R7, R6,
/// clarification Q4) on a real in-memory database.
void main() {
  late ExpenseDb x;
  late SettingsRepositoryImpl settings;
  late DriftBudgetRepository repo;
  late String cash;
  late String food;
  late String travel;
  late String salary;

  setUp(() async {
    x = await ExpenseDb.open();
    settings = SettingsRepositoryImpl(x.db, knownModuleIds: const ['expense']);
    repo = DriftBudgetRepository(x.db, x.clock, settings);
    cash = await x.account('Cash');
    food = await x.category('Food');
    travel = await x.category('Travel');
    salary = await x.category('Salary', type: CategoryType.income);
  });

  Future<Budget> make({
    String? category,
    String month = '2026-10',
    int limit = 100000,
    bool rollover = true,
  }) => repo.create(
    BudgetDraft(
      categoryId: category,
      monthKey: month,
      limitMinor: limit,
      rollover: rollover,
    ),
  );

  Future<List<Budget>> live(String month) async {
    final o = await repo.watchOverview(month).first;
    return [?o.overall?.budget, for (final s in o.categories) s.budget];
  }

  group('create, update, delete, undelete', () {
    test('create returns the saved budget; the same slot is taken', () async {
      final b = await make(category: food, limit: 600000);
      expect(b.categoryId, food);
      expect(b.limitMinor, 600000);
      expect(await repo.findById(b.id), b);
      await expectLater(make(category: food), throwsA(isA<BudgetSlotTaken>()));
      await make(); // Overall is its own slot.
      await expectLater(make(), throwsA(isA<BudgetSlotTaken>()));
    });

    test('update changes limit and rollover and keeps the category', () async {
      final b = await make(category: food);
      final u = await repo.update(b.id, limitMinor: 250000, rollover: false);
      expect(u.categoryId, food);
      expect(u.limitMinor, 250000);
      expect(u.rollover, isFalse);
      await expectLater(
        repo.update('missing', limitMinor: 1, rollover: true),
        throwsA(isA<BudgetNotFound>()),
      );
    });

    test(
      'softDelete and undelete; undelete fails when the slot was refilled',
      () async {
        final b = await make(category: food);
        await repo.softDelete(b.id);
        expect(await repo.findById(b.id), isNull);
        await repo.undelete(b.id);
        expect((await repo.findById(b.id))?.id, b.id);

        await repo.softDelete(b.id);
        await make(category: food, limit: 5000);
        await expectLater(repo.undelete(b.id), throwsA(isA<BudgetSlotTaken>()));
      },
    );
  });

  group('EXP-08 criterion "Copy last month does not overwrite budgets already '
      'set for this month"', () {
    test('copies only the empty slots, with markers cleared', () async {
      final sepFood = await make(category: food, month: '2026-09');
      await make(month: '2026-09', limit: 2000000, rollover: false);
      await make(category: travel, month: '2026-09', limit: 50000);
      await repo.markAlertSent(sepFood.id, BudgetThreshold.p100, 1);
      await make(category: food, limit: 200000);

      expect(await repo.copyPreviousMonth('2026-10'), 2);

      final oct = await repo.watchOverview('2026-10').first;
      expect(oct.overall!.budget.limitMinor, 2000000);
      expect(oct.overall!.budget.rollover, isFalse, reason: 'same setting');
      final byCat = {
        for (final s in oct.categories) s.budget.categoryId: s.budget,
      };
      expect(byCat[food]!.limitMinor, 200000, reason: 'existing kept');
      expect(byCat[travel]!.limitMinor, 50000);
      for (final b in await live('2026-10')) {
        expect(b.alert80SentAt, isNull);
        expect(b.alert100SentAt, isNull);
      }
      expect(await repo.copyPreviousMonth('2026-10'), 0, reason: 'all full');
    });

    test('skips hidden or deleted categories', () async {
      final gone = await x.category('Gone');
      await make(category: food, month: '2026-09');
      await make(category: travel, month: '2026-09');
      await make(category: gone, month: '2026-09');
      await x.categories.setHidden(travel, hidden: true);
      await x.categories.delete(gone);
      expect(await repo.copyPreviousMonth('2026-10'), 1);
      expect((await live('2026-10')).map((b) => b.categoryId), [food]);
    });
  });

  group('rolloverIfNeeded (FR-013, research R7)', () {
    const marker = 'expense.budgetRolloverMonth';

    test('copies only repeating budgets into empty slots and writes the '
        'marker', () async {
      await make(category: food, limit: 600000);
      await make(category: travel, rollover: false);
      await make(limit: 3000000);
      await make(month: '2026-11', limit: 2500000); // already set

      await repo.rolloverIfNeeded('2026-11');

      final nov = await repo.watchOverview('2026-11').first;
      expect(nov.overall!.budget.limitMinor, 2500000, reason: 'kept');
      expect(nov.categories.map((s) => s.budget.categoryId), [food]);
      expect(nov.categories.single.budget.limitMinor, 600000);
      expect(nov.categories.single.budget.rollover, isTrue);
      expect(await settings.readModuleState(marker), '2026-11');
    });

    test('a second call in the same month copies nothing, even after the '
        'user deletes a rolled-over budget', () async {
      await make(category: food);
      await repo.rolloverIfNeeded('2026-11');
      final rolled = (await live('2026-11')).single;
      await repo.softDelete(rolled.id);
      await repo.rolloverIfNeeded('2026-11');
      expect(await live('2026-11'), isEmpty);
    });

    test(
      'a skipped month uses the latest earlier month with budgets',
      () async {
        await make(category: food, month: '2026-07', limit: 1000);
        await make(category: food, month: '2026-08', limit: 2000);
        await repo.rolloverIfNeeded('2026-10');
        expect((await live('2026-10')).single.limitMinor, 2000);
        expect(await live('2026-09'), isEmpty, reason: 'current month only');
      },
    );

    test('skips repeating budgets whose category is hidden or deleted, while '
        'still rolling over the others (edge case)', () async {
      final gone = await x.category('Gone');
      await make(category: food);
      await make(category: travel);
      await make(category: gone);
      await make();
      await x.categories.setHidden(travel, hidden: true);
      await x.categories.delete(gone);
      await repo.rolloverIfNeeded('2026-11');
      final nov = await live('2026-11');
      expect(nov.map((b) => b.categoryId), unorderedEquals([null, food]));
    });

    test('a first install with no budgets only writes the marker', () async {
      await repo.rolloverIfNeeded('2026-10');
      expect(await live('2026-10'), isEmpty);
      expect(await settings.readModuleState(marker), '2026-10');
    });
  });

  group('limit change clears markers no longer reached (Q4)', () {
    Future<Budget> spentNineHundred() async {
      final b = await make(category: food);
      await x.add(account: cash, category: food, amount: 90000);
      await repo.markAlertSent(b.id, BudgetThreshold.p100, 1);
      return b;
    }

    test('raised to ₹2,000 clears both', () async {
      final b = await spentNineHundred();
      final u = await repo.update(b.id, limitMinor: 200000, rollover: true);
      expect(u.alert80SentAt, isNull);
      expect(u.alert100SentAt, isNull);
    });

    test('raised to ₹950 clears only the 100% marker', () async {
      final b = await spentNineHundred();
      final u = await repo.update(b.id, limitMinor: 95000, rollover: true);
      expect(u.alert80SentAt, isNotNull);
      expect(u.alert100SentAt, isNull);
    });

    test('lowering keeps markers that are still reached', () async {
      final b = await spentNineHundred();
      final u = await repo.update(b.id, limitMinor: 50000, rollover: true);
      expect(u.alert80SentAt, isNotNull);
      expect(u.alert100SentAt, isNotNull);
    });
  });

  group('markAlertSent compare-and-set (R6)', () {
    test('true only for the call that sets it; 100% also sets 80%', () async {
      final b = await make(category: food);
      expect(await repo.markAlertSent(b.id, BudgetThreshold.p80, 10), isTrue);
      expect(await repo.markAlertSent(b.id, BudgetThreshold.p80, 11), isFalse);
      expect(await repo.markAlertSent(b.id, BudgetThreshold.p100, 12), isTrue);
      expect(await repo.markAlertSent(b.id, BudgetThreshold.p100, 13), isFalse);
      final after = (await repo.findById(b.id))!;
      expect(after.alert80SentAt!.millisecondsSinceEpoch, 10);
      expect(after.alert100SentAt!.millisecondsSinceEpoch, 12);

      final c = await make(category: travel);
      expect(await repo.markAlertSent(c.id, BudgetThreshold.p100, 20), isTrue);
      final both = (await repo.findById(c.id))!;
      expect(both.alert80SentAt!.millisecondsSinceEpoch, 20);
      expect(await repo.markAlertSent(c.id, BudgetThreshold.p80, 21), isFalse);
    });

    test('two parallel calls → exactly one true', () async {
      final b = await make(category: food);
      final results = await Future.wait([
        repo.markAlertSent(b.id, BudgetThreshold.p80, 1),
        repo.markAlertSent(b.id, BudgetThreshold.p80, 2),
      ]);
      expect(results.where((r) => r), hasLength(1));
    });

    test('markers survive a new repository (app restart)', () async {
      final b = await make(category: food);
      await repo.markAlertSent(b.id, BudgetThreshold.p80, 1);
      final again = DriftBudgetRepository(x.db, x.clock, settings);
      expect(await again.markAlertSent(b.id, BudgetThreshold.p80, 2), isFalse);
    });
  });

  group('watchOverview and spentFor', () {
    test('spent counts only expenses in the month; income and transfers are '
        'excluded', () async {
      final sbi = await x.account('SBI');
      await make(limit: 3000000);
      await make(category: food, limit: 580000);
      await x.add(account: cash, category: food, amount: 470000);
      await x.add(account: cash, category: travel, amount: 30000);
      await x.add(
        account: cash,
        category: food,
        amount: 99000,
        at: DateTime(2026, 9, 30, 23, 59),
      );
      await x.add(
        account: cash,
        category: salary,
        amount: 5000000,
        type: TxnType.income,
      );
      await x.add(
        account: cash,
        toAccount: sbi,
        amount: 10000,
        type: TxnType.transfer,
      );

      final o = await repo.watchOverview('2026-10').first;
      expect(o.overall!.spentMinor, 500000);
      expect(o.categories.single.spentMinor, 470000);
      expect(o.categories.single.level, BudgetLevel.warning);
      expect(await repo.spentFor('2026-10', null), 500000);
      expect(await repo.spentFor('2026-10', food), 470000);
      expect(await repo.spentFor('2026-09', food), 99000);
      expect(o.withoutBudget.map((c) => c.id), [
        travel,
      ], reason: 'non-hidden expense categories without a budget');
      expect(o.monthPhase, MonthPhase.current);
    });

    test('re-emits on a transaction insert', () async {
      await make(category: food);
      final values = <int>[];
      final sub = repo
          .watchOverview('2026-10')
          .listen((o) => values.add(o.categories.single.spentMinor));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await x.add(account: cash, category: food, amount: 1234);
      await pumpEventQueue();
      expect(values, [0, 1234]);
    });

    test('a budget for a hidden category is shown and marked', () async {
      await make(category: food);
      await x.categories.setHidden(food, hidden: true);
      final o = await repo.watchOverview('2026-10').first;
      expect(o.categories.single.categoryHidden, isTrue);
      expect(o.categories.single.category?.id, food);
      expect(o.withoutBudget.map((c) => c.id), [travel]);
    });

    test('forAlert returns the category and Overall budgets', () async {
      final overall = await make();
      final f = await make(category: food);
      final r = await repo.forAlert('2026-10', food);
      expect(r.category?.id, f.id);
      expect(r.overall?.id, overall.id);
      final none = await repo.forAlert('2026-10', travel);
      expect(none.category, isNull);
      expect(none.overall?.id, overall.id);
    });
  });
}
