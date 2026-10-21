import 'package:clock/clock.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/insights/expense_insight_rules.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:flutter_test/flutter_test.dart';

/// Expense insight rules (T038, research R8). "Now" defaults to Wednesday
/// 14 October 2026 at 10:00: day 14 of 31, so 18 days are left including
/// today. Money is whole paise.
void main() {
  final now = DateTime(2026, 10, 14, 10);

  ExpenseInsightRules rulesAt(DateTime t) =>
      ExpenseInsightRules(Clock.fixed(t));

  BudgetStatus overall({
    required int limit,
    required int spent,
    String monthKey = '2026-10',
  }) => buildBudgetStatus(
    budget: Budget(
      id: 'b1',
      monthKey: monthKey,
      limitMinor: limit,
      rollover: false,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    spentMinor: spent,
    nowLocal: now,
  );

  List<ExpenseInsightFact> evaluate({
    Map<String, int> thisMonth = const {},
    Map<String, int> lastMonth = const {},
    BudgetStatus? budget,
    DateTime? at,
  }) => rulesAt(at ?? now).evaluate(
    ExpenseInsightInputs(
      thisMonthByCategory: thisMonth,
      lastMonthSameDaysByCategory: lastMonth,
      overall: budget,
    ),
  );

  test('rule ids are stable and in rotation order', () {
    expect(ExpenseInsightRules.ruleIds, [
      'expense.categoryVsLastMonth',
      'expense.budgetOnTrack',
      'expense.budgetNearLimit',
    ]);
  });

  group('DSH-01 expense.categoryVsLastMonth', () {
    test('+20% applies, +19% does not', () {
      expect(
        evaluate(thisMonth: {'food': 120000}, lastMonth: {'food': 100000}),
        [const CategoryChange(categoryId: 'food', percent: 20, higher: true)],
      );
      expect(
        evaluate(thisMonth: {'food': 119999}, lastMonth: {'food': 100000}),
        isEmpty,
      );
    });

    test('−20% gives a "lower" fact; −19% does not apply', () {
      expect(
        evaluate(thisMonth: {'food': 80000}, lastMonth: {'food': 100000}),
        [const CategoryChange(categoryId: 'food', percent: 20, higher: false)],
      );
      expect(
        evaluate(thisMonth: {'food': 81000}, lastMonth: {'food': 100000}),
        isEmpty,
      );
    });

    test('needs both periods above 0', () {
      expect(evaluate(thisMonth: {'food': 50000}), isEmpty);
      expect(evaluate(lastMonth: {'food': 50000}), isEmpty);
      expect(
        evaluate(thisMonth: {'food': 50000}, lastMonth: {'food': 0}),
        isEmpty,
      );
    });

    test('needs the larger period to be at least ₹200 (20000 paise)', () {
      expect(
        evaluate(thisMonth: {'food': 19999}, lastMonth: {'food': 10000}),
        isEmpty,
      );
      expect(evaluate(thisMonth: {'food': 20000}, lastMonth: {'food': 10000}), [
        const CategoryChange(categoryId: 'food', percent: 100, higher: true),
      ]);
      expect(evaluate(thisMonth: {'food': 10000}, lastMonth: {'food': 20000}), [
        const CategoryChange(categoryId: 'food', percent: 50, higher: false),
      ]);
    });

    test('picks the largest absolute change', () {
      expect(
        evaluate(
          thisMonth: {'food': 150000, 'travel': 40000, 'bills': 100000},
          lastMonth: {'food': 100000, 'travel': 100000, 'bills': 100000},
        ),
        [
          const CategoryChange(
            categoryId: 'travel',
            percent: 60,
            higher: false,
          ),
        ],
      );
    });

    test('an equal percent goes to the larger amount change', () {
      expect(
        evaluate(
          thisMonth: {'food': 30000, 'rent': 3000000},
          lastMonth: {'food': 20000, 'rent': 2000000},
        ),
        [const CategoryChange(categoryId: 'rent', percent: 50, higher: true)],
      );
    });

    test('compares this month to date with the same days last month', () {
      final p = rulesAt(now).periods();
      expect(p.thisMonthFrom, DateTime(2026, 10));
      expect(p.thisMonthTo, DateTime(2026, 10, 14));
      expect(p.lastMonthFrom, DateTime(2026, 9));
      expect(p.lastMonthTo, DateTime(2026, 9, 14));
    });

    test("caps the same days at last month's length (31 Mar vs Feb)", () {
      final p2026 = rulesAt(DateTime(2026, 3, 31, 23, 59)).periods();
      expect(p2026.lastMonthFrom, DateTime(2026, 2));
      expect(p2026.lastMonthTo, DateTime(2026, 2, 28));
      final leap = rulesAt(DateTime(2028, 3, 31, 8)).periods();
      expect(leap.lastMonthTo, DateTime(2028, 2, 29));
      final may = rulesAt(DateTime(2026, 5, 31, 8)).periods();
      expect(may.lastMonthTo, DateTime(2026, 4, 30));
    });

    test('January compares with December of the year before', () {
      final p = rulesAt(DateTime(2026, 1, 15, 9)).periods();
      expect(p.thisMonthFrom, DateTime(2026));
      expect(p.lastMonthFrom, DateTime(2025, 12));
      expect(p.lastMonthTo, DateTime(2025, 12, 15));
    });
  });

  group('DSH-01 expense.budgetOnTrack', () {
    test('applies when spent < 80% and spent ratio ≤ elapsed ratio; reports '
        'days left including today', () {
      expect(evaluate(budget: overall(limit: 1000000, spent: 450000)), [
        const BudgetOnTrack(remainingMinor: 550000, daysLeft: 18),
      ]);
    });

    test('spent ratio exactly equal to the elapsed ratio still applies', () {
      // 14/31 of 310000 is 140000.
      expect(evaluate(budget: overall(limit: 310000, spent: 140000)), [
        const BudgetOnTrack(remainingMinor: 170000, daysLeft: 18),
      ]);
      expect(evaluate(budget: overall(limit: 310000, spent: 140001)), isEmpty);
    });

    test('ahead of pace but under 80% gives no budget fact', () {
      expect(evaluate(budget: overall(limit: 1000000, spent: 790000)), isEmpty);
    });

    test('on the last day of the month one day is left', () {
      final last = DateTime(2026, 10, 31, 20);
      expect(
        evaluate(at: last, budget: overall(limit: 1000000, spent: 500000)),
        [const BudgetOnTrack(remainingMinor: 500000, daysLeft: 1)],
      );
    });
  });

  group('DSH-01 expense.budgetNearLimit', () {
    test('80% and 100% give BudgetNearLimit', () {
      expect(evaluate(budget: overall(limit: 1000000, spent: 800000)), [
        const BudgetNearLimit(percentUsed: 80),
      ]);
      expect(evaluate(budget: overall(limit: 1000000, spent: 850000)), [
        const BudgetNearLimit(percentUsed: 85),
      ]);
      expect(evaluate(budget: overall(limit: 1000000, spent: 1000000)), [
        const BudgetNearLimit(percentUsed: 100),
      ]);
    });

    test('above 100% gives BudgetOver with the amount over', () {
      expect(evaluate(budget: overall(limit: 1000000, spent: 1000001)), [
        const BudgetOver(overMinor: 1),
      ]);
      expect(evaluate(budget: overall(limit: 1000000, spent: 1050000)), [
        const BudgetOver(overMinor: 50000),
      ]);
    });
  });

  group('DSH-01 expense budget rules without a usable budget', () {
    test('no overall budget gives no budget facts', () {
      expect(evaluate(), isEmpty);
    });

    test('a budget for another month is ignored', () {
      expect(
        evaluate(
          budget: overall(limit: 1000000, spent: 900000, monthKey: '2026-09'),
        ),
        isEmpty,
      );
    });
  });

  test('facts come in rule order', () {
    final facts = evaluate(
      thisMonth: {'food': 150000},
      lastMonth: {'food': 100000},
      budget: overall(limit: 1000000, spent: 100000),
    );
    expect(facts.map((f) => f.ruleId), [
      ExpenseInsightRules.categoryVsLastMonth,
      ExpenseInsightRules.budgetOnTrack,
    ]);
  });

  test('money in and out is integer paise', () {
    final budget = overall(limit: 1000000, spent: 1050000);
    expect(budget.spentMinor, isA<int>());
    expect(budget.budget.limitMinor, isA<int>());
    final facts = evaluate(
      thisMonth: {'food': 150000},
      lastMonth: {'food': 100000},
      budget: budget,
    );
    for (final fact in facts) {
      switch (fact) {
        case CategoryChange(:final percent):
          expect(percent, isA<int>());
        case BudgetOnTrack(:final remainingMinor, :final daysLeft):
          expect(remainingMinor, isA<int>());
          expect(daysLeft, isA<int>());
        case BudgetNearLimit(:final percentUsed):
          expect(percentUsed, isA<int>());
        case BudgetOver(:final overMinor):
          expect(overMinor, isA<int>());
      }
    }
    expect(facts.last, const BudgetOver(overMinor: 50000));
  });
}
