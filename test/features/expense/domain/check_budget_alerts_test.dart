import 'dart:math';

import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// BudgetAlertChecker (FR-015–FR-018, FR-029, research R6) over fakes with
/// real compare-and-set semantics. "Now" is 14 Oct 2026.
void main() {
  late ExpenseFakes f;
  late BudgetAlertChecker checker;

  setUp(() {
    f = ExpenseFakes.withDefaults();
    checker = BudgetAlertChecker(
      f.budgets,
      f.alertNotifier,
      f.notificationGate,
      f.clock,
    );
  });

  Future<List<BudgetAlert>> check(Transaction t) => checker.check(
    occurredAtUtcMs: t.occurredAt.millisecondsSinceEpoch,
    categoryId: t.categoryId,
    type: t.type,
  );

  /// Saves an expense through the fake store, then runs the check the way
  /// EXP-02 does.
  Future<List<BudgetAlert>> save(
    int amount, {
    String category = 'food',
    DateTime? at,
    TxnType type = TxnType.expense,
  }) {
    final t = f.addTransaction(
      amount: amount,
      category: type == TxnType.transfer ? null : category,
      toAccount: type == TxnType.transfer ? 'bank' : null,
      type: type,
      at: at,
    );
    return check(t);
  }

  List<(String?, BudgetThreshold)> sent() => [
    for (final a in f.alertNotifier.sent) (a.categoryId, a.threshold),
  ];

  group('EXP-02 criterion "Budget alert fires once at 80% and once at 100% '
      'per category per month"', () {
    test('₹6,000 Food: 80% once, 100% once, then nothing more', () async {
      f.addBudget(limit: 600000, category: 'food');
      await save(470000);
      expect(sent(), isEmpty, reason: '78%');
      await save(20000);
      expect(sent(), [('food', BudgetThreshold.p80)]);
      expect(f.alertNotifier.sent.single.percent, 81);
      await save(10000);
      expect(sent(), hasLength(1), reason: 'still between 80 and 100');
      await save(100000);
      expect(sent(), [
        ('food', BudgetThreshold.p80),
        ('food', BudgetThreshold.p100),
      ]);
      await save(50000);
      await save(1);
      expect(sent(), hasLength(2));
    });

    test('SC-003: 60 generated save sequences give exactly the alerts of the '
        'reference model (0 duplicates, 0 missed)', () async {
      final rnd = Random(2026);
      var totalAlerts = 0;
      for (var seq = 0; seq < 60; seq++) {
        f = ExpenseFakes.withDefaults();
        checker = BudgetAlertChecker(
          f.budgets,
          f.alertNotifier,
          f.notificationGate,
          f.clock,
        );
        final foodLimit = 1000 + rnd.nextInt(1000000);
        final overallLimit = foodLimit + rnd.nextInt(foodLimit * 2 + 1);
        f
          ..addBudget(limit: foodLimit, category: 'food')
          ..addBudget(limit: overallLimit);

        // Reference model: (spent, 80 sent, 100 sent) per budget.
        final model = {
          'food': (limit: foodLimit, m80: false, m100: false),
          null: (limit: overallLimit, m80: false, m100: false),
        };
        final expected = <(String?, BudgetThreshold)>[];
        final saved = <Transaction>[];
        for (var step = 0; step < 6 + rnd.nextInt(12); step++) {
          if (saved.isNotEmpty && rnd.nextInt(5) == 0) {
            // A delete lowers spending; no check runs, markers stay.
            final t = saved.removeAt(rnd.nextInt(saved.length));
            await f.transactions.softDelete(t.id);
            continue;
          }
          final category = rnd.nextBool() ? 'food' : 'travel';
          final t = f.addTransaction(
            amount: 1 + rnd.nextInt(foodLimit ~/ 2 + 1),
            category: category,
          );
          saved.add(t);
          int spent(String? c) => f.active
              .where((x) => c == null || x.categoryId == c)
              .fold(0, (s, x) => s + x.amountMinor);
          for (final key in [if (category == 'food') 'food', null]) {
            final m = model[key]!;
            final s = spent(key);
            if (s >= m.limit && !m.m100) {
              expected.add((key, BudgetThreshold.p100));
              model[key] = (limit: m.limit, m80: true, m100: true);
            } else if (s * 100 >= m.limit * 80 && !m.m80) {
              expected.add((key, BudgetThreshold.p80));
              model[key] = (limit: m.limit, m80: true, m100: m.m100);
            }
          }
          await check(t);
        }
        expect(sent(), expected, reason: 'sequence $seq');
        // Never more than one alert per threshold per budget.
        expect(sent().toSet(), hasLength(sent().length), reason: 'seq $seq');
        totalAlerts += expected.length;
      }
      expect(totalAlerts, greaterThan(60), reason: 'the set exercises alerts');
    });
  });

  test('US2-2 a single save crossing both thresholds sends only 100% and '
      'marks both', () async {
    final b = f.addBudget(limit: 100000, category: 'food');
    await save(150000);
    expect(sent(), [('food', BudgetThreshold.p100)]);
    expect(f.alertNotifier.sent.single.percent, 150);
    final after = (await f.budgets.findById(b.id))!;
    expect(after.alert80SentAt, isNotNull);
    expect(after.alert100SentAt, isNotNull);
  });

  test('US2-3 overall and category budgets alert independently', () async {
    f
      ..addBudget(limit: 100000, category: 'food')
      ..addBudget(limit: 1000000);
    await save(80000);
    expect(sent(), [('food', BudgetThreshold.p80)]);
    await save(720000, category: 'travel');
    expect(sent(), [
      ('food', BudgetThreshold.p80),
      (null, BudgetThreshold.p80),
    ]);
    // Travel has no budget of its own; only Overall is checked for it.
    await save(200000, category: 'travel');
    expect(sent().last, (null, BudgetThreshold.p100));
  });

  test('US2-4 a drop below and a rise above again sends nothing new', () async {
    f.addBudget(limit: 100000, category: 'food');
    final t = f.addTransaction(amount: 85000, category: 'food');
    await check(t);
    await f.transactions.softDelete(t.id);
    await save(85000);
    expect(sent(), [('food', BudgetThreshold.p80)]);
  });

  test('US2-7 income and transfers run no check', () async {
    f
      ..addBudget(limit: 100, category: 'income_salary')
      ..addBudget(limit: 100)
      ..addAccount('Bank', id: 'bank');
    expect(
      await save(5000, category: 'income_salary', type: TxnType.income),
      isEmpty,
    );
    expect(await save(5000, type: TxnType.transfer), isEmpty);
    expect(f.budgets.calls['forAlert'], isNull);
  });

  test('Q2: past-month and future-month expenses send nothing and record no '
      'marker', () async {
    final b = f.addBudget(limit: 100000, category: 'food', month: '2026-09');
    f.addBudget(limit: 100000, category: 'food', month: '2026-11');
    await save(200000, at: DateTime(2026, 9, 30, 23, 59));
    await save(200000, at: DateTime(2026, 11, 1, 9));
    expect(sent(), isEmpty);
    expect((await f.budgets.findById(b.id))!.alert80SentAt, isNull);
    expect(f.budgets.calls['markAlertSent'], isNull);
  });

  test('US2-5 with the gate closed markers are recorded but nothing is '
      'shown', () async {
    final b = f.addBudget(limit: 100000, category: 'food');
    f.notificationGate.allowed = false;
    final recorded = await save(90000);
    expect(recorded.single.threshold, BudgetThreshold.p80);
    expect(f.alertNotifier.sent, isEmpty);
    expect((await f.budgets.findById(b.id))!.alert80SentAt, isNotNull);
    // Turning notifications back on never sends the old alert.
    f.notificationGate.allowed = true;
    await save(1000);
    expect(f.alertNotifier.sent, isEmpty);
  });

  test('US2-8 a notifier that throws never breaks the check', () async {
    f.addBudget(limit: 100000, category: 'food');
    f.alertNotifier.error = Exception('plugin down');
    final recorded = await save(90000);
    expect(recorded, hasLength(1));
  });

  test('a deleted budget sends nothing', () async {
    final b = f.addBudget(limit: 100000, category: 'food');
    await f.budgets.softDelete(b.id);
    expect(await save(200000), isEmpty);
  });

  test('a new month alerts again', () async {
    f.addBudget(limit: 100000, category: 'food');
    await save(90000);
    f.clock.value = DateTime(2026, 11, 3, 10);
    f.addBudget(limit: 100000, category: 'food', month: '2026-11');
    await save(90000, at: DateTime(2026, 11, 3, 9));
    expect(f.alertNotifier.sent.map((a) => (a.monthKey, a.threshold)), [
      ('2026-10', BudgetThreshold.p80),
      ('2026-11', BudgetThreshold.p80),
    ]);
  });

  test(
    'Q4: a raised limit clears the marker, so it alerts once more',
    () async {
      final b = f.addBudget(limit: 100000, category: 'food');
      await save(90000);
      await f.budgets.update(b.id, limitMinor: 200000, rollover: true);
      await save(80000);
      expect(sent(), [
        ('food', BudgetThreshold.p80),
        ('food', BudgetThreshold.p80),
      ]);
      // Lowering it again never repeats an alert that is still marked.
      await f.budgets.update(b.id, limitMinor: 150000, rollover: true);
      await save(1);
      expect(sent().last, ('food', BudgetThreshold.p100));
    },
  );
}
