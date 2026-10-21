import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/presentation/screens/budgets_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/budget_row.dart';
import 'package:dailytrack/features/expense/presentation/widgets/overall_budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-08 Budgets screen (T033): US1 scenarios 1–3, 7–8, 10–12 and the
/// four states. "Today" is Wednesday 14 Oct 2026 (18 days left, inclusive).
void main() {
  /// Overall ₹30,000 and Food ₹6,000 in October, with ₹12,400 spent, ₹5,100
  /// of it on Food (85%: "Almost used").
  ExpenseFakes october() {
    final f = ExpenseFakes.withDefaults()
      ..addBudget(limit: 3000000, id: 'overall')
      ..addBudget(limit: 600000, category: 'food', id: 'food-budget')
      ..addTransaction(amount: 510000, category: 'food')
      ..addTransaction(amount: 730000, category: 'travel');
    return f;
  }

  Future<ExpenseFakes> open(
    WidgetTester tester, {
    ExpenseFakes? fakes,
    String location = Routes.expenseBudgets,
  }) => pumpExpenseApp(tester, fakes: fakes ?? october(), location: location);

  testWidgets('EXP-08 US1-1 order: month selector, overall card, category '
      'budgets, categories without budget', (tester) async {
    await open(tester);
    expect(find.text('October 2026'), findsOneWidget);
    double y(Finder f) => tester.getTopLeft(f).dy;
    final selector = y(find.byKey(const Key('budgets_month')));
    final card = y(find.byType(OverallBudgetCard));
    final cats = y(find.byKey(const Key('category_budgets_heading')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('without_budget_heading')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(selector < card && card < cats, isTrue);
    expect(find.byKey(const Key('without_budget_heading')), findsOneWidget);
    // Food has a budget, so it is not offered again; Groceries is.
    expect(find.byKey(const ValueKey('unbudgeted_food')), findsNothing);
    expect(find.byKey(const ValueKey('unbudgeted_groceries')), findsOneWidget);
  });

  testWidgets('EXP-08 US1-2 the overall card shows spent, remaining and '
      '"per day left" counting today', (tester) async {
    await open(tester);
    expect(find.text('₹12,400.00 of ₹30,000.00'), findsOneWidget);
    expect(find.text('₹17,600.00 left'), findsOneWidget);
    // 17,600.00 ÷ 18 days (14–31 Oct) = 977.77 rounded down.
    expect(find.text('₹977.77 per day left for 18 days'), findsOneWidget);
  });

  testWidgets('EXP-08 US1-2 over budget shows the over amount and no '
      'per-day amount', (tester) async {
    final f = october()..addTransaction(amount: 2000000, category: 'rent');
    await open(tester, fakes: f);
    expect(find.text('Over budget by ₹2,400.00'), findsOneWidget);
    expect(find.text('No budget left this month'), findsOneWidget);
  });

  testWidgets('EXP-08 US1-11 a past month shows the final result; a future '
      'month counts all its days', (tester) async {
    final f = october()
      ..addBudget(limit: 100000, month: '2026-09')
      ..addTransaction(
        amount: 40000,
        at: DateTime(2026, 9, 20),
        category: 'food',
      )
      ..addBudget(limit: 300000, month: '2026-11');
    await open(tester, fakes: f);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Under budget by ₹600.00'), findsOneWidget);
    expect(find.textContaining('per day'), findsNothing);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('₹100.00 per day for 30 days'), findsOneWidget);
  });

  testWidgets('EXP-08 US1-3 category rows show spent of limit and a level '
      'label, not color alone', (tester) async {
    await open(tester);
    final row = find.byType(BudgetRow);
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.text('₹5,100.00 of ₹6,000.00')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: row, matching: find.text('Almost used · 85% used')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: row, matching: find.byType(ProgressBarStatus)),
      findsOneWidget,
    );
  });

  testWidgets('EXP-08 hidden category budgets are shown and marked', (
    tester,
  ) async {
    final f = october();
    f.world.categories['food'] = f.world.categories['food']!.copyWith(
      isHidden: true,
    );
    await open(tester, fakes: f);
    expect(
      find.descendant(
        of: find.byType(BudgetRow),
        matching: find.text('Hidden'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('EXP-08 US1-10 the empty state offers "Set monthly budget", '
      'which opens EXP-09 with Overall selected', (tester) async {
    await open(tester, fakes: ExpenseFakes.withDefaults());
    expect(find.text('Plan your month'), findsOneWidget);
    expect(
      find.text(
        'Set a monthly budget to see how much you can still spend each day.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    final chip = find.descendant(
      of: find.byKey(const Key('budget_slot')),
      matching: find.widgetWithText(ChoiceChip, 'Overall'),
    );
    expect(tester.widget<ChoiceChip>(chip).selected, isTrue);
  });

  testWidgets('EXP-08 US1-8 "Copy last month\'s budgets" reports the count, '
      'then "Nothing to copy"', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addBudget(limit: 2000000, month: '2026-09')
      ..addBudget(limit: 50000, category: 'travel', month: '2026-09');
    await open(tester, fakes: f);
    Future<void> copy() async {
      await tester.tap(find.byKey(const Key('budgets_overflow')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_copy_last_month')));
      await tester.pumpAndSettle();
    }

    await copy();
    expect(find.text('Copied 2 budgets'), findsOneWidget);
    expect(find.byType(BudgetRow), findsOneWidget);
    await flushTimers(tester);
    await copy();
    expect(find.text('Nothing to copy'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('EXP-08 US1-7 deleting from EXP-09 closes the sheet and offers '
      'a 5-second Undo that restores it', (tester) async {
    final f = await open(tester);
    await tester.tap(find.byType(BudgetRow));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_budget')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('save_budget')), findsNothing);
    expect(find.byType(BudgetRow), findsNothing);
    expect(find.text('Budget deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetRow), findsOneWidget);
    expect(f.budgets.calls['undelete'], 1);
    await flushTimers(tester);
  });

  testWidgets('EXP-08 US1-12 no ad of any kind is shown', (tester) async {
    await open(tester);
    final scaffold = tester.widget<AppScaffold>(find.byType(AppScaffold).last);
    expect(scaffold.bannerSlot, isNull);
    expect(scaffold.title, 'Budgets');
  });

  testWidgets('EXP-08 loading shows a skeleton only after 300 ms', (
    tester,
  ) async {
    final f = october();
    await open(tester, fakes: f);
    f.world.watchDelay = const Duration(seconds: 2);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonCard), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SkeletonCard), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Plan your month'), findsOneWidget);
  });

  testWidgets('EXP-08 a load error shows "Try again", which recovers', (
    tester,
  ) async {
    final f = october();
    await open(tester, fakes: f);
    f.world.failWatch = StateError('db');
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    f.world.failWatch = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Plan your month'), findsOneWidget);
  });

  testWidgets('EXP-08 opens from the EXP-01 overflow menu', (tester) async {
    await open(tester, location: Routes.expenses);
    await tester.tap(find.byKey(const Key('expenses_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_budgets')));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetsScreen), findsOneWidget);
  });

  testWidgets('EXP-08 ?month=2026-09 opens September', (tester) async {
    await open(tester, location: Routes.expenseBudgetsPath(month: '2026-09'));
    expect(find.text('September 2026'), findsOneWidget);
  });
}
