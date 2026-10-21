import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/expense/presentation/widgets/budget_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-09 Set budget sheet (T034): US1 scenarios 4–6 and FR-011.
void main() {
  Future<ExpenseFakes> openOn(WidgetTester tester, ExpenseFakes f) =>
      pumpExpenseApp(tester, fakes: f, location: Routes.expenseBudgets);

  Finder chip(String label) => find.descendant(
    of: find.byKey(const Key('budget_slot')),
    matching: find.widgetWithText(ChoiceChip, label),
  );

  /// One budget so the list (not the empty state) shows, plus Food free.
  ExpenseFakes withOverall() =>
      ExpenseFakes.withDefaults()..addBudget(limit: 3000000, id: 'overall');

  Future<void> openFoodSheet(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('set_budget_food')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('set_budget_food')));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('save_budget')));
    await tester.pumpAndSettle();
  }

  testWidgets('EXP-09 US1-4/US1-6 new: the slot is preselected; options are '
      'the categories without a budget (Overall already has one)', (
    tester,
  ) async {
    await openOn(tester, withOverall());
    await openFoodSheet(tester);
    expect(tester.widget<ChoiceChip>(chip('Food')).selected, isTrue);
    expect(chip('Overall'), findsNothing, reason: 'one Overall per month');
    expect(chip('Groceries'), findsOneWidget);
    expect(find.text('Repeat every month'), findsOneWidget);
    expect(find.byKey(const Key('delete_budget')), findsNothing);
  });

  testWidgets('EXP-09 US1-5 saves the keypad amount for the selected month '
      'and the screen updates', (tester) async {
    final f = await openOn(tester, withOverall());
    await openFoodSheet(tester);
    await typeAmount(tester, '6000');
    expect(find.text('₹6,000.00'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('budget_rollover')));
    await tester.tap(find.byKey(const Key('budget_rollover')));
    await tester.pump();
    await save(tester);
    expect(find.byKey(const Key('save_budget')), findsNothing);
    final saved = f.world.budgets.values.singleWhere(
      (b) => b.categoryId == 'food',
    );
    expect(saved.monthKey, '2026-10');
    expect(saved.limitMinor, 600000);
    expect(saved.rollover, isFalse);
    expect(find.byType(BudgetRow), findsOneWidget);
  });

  testWidgets('EXP-09 US1-5 an empty or zero amount, or one above the '
      'maximum, is rejected inline', (tester) async {
    final f = await openOn(tester, withOverall());
    await openFoodSheet(tester);
    await save(tester);
    expect(find.text('Enter an amount'), findsOneWidget);
    await typeAmount(tester, '0');
    await save(tester);
    expect(find.text('Enter an amount'), findsOneWidget);
    // "0" then "1000000000" is ₹1,00,00,00,000, above the maximum.
    await typeAmount(tester, '1000000000');
    await save(tester);
    expect(find.text('Amount is too large'), findsOneWidget);
    expect(f.budgets.calls['create'], isNull);
    expect(find.byKey(const Key('save_budget')), findsOneWidget);
  });

  testWidgets('EXP-09 US1-4 edit: the category is fixed, Delete is shown, and '
      'saving keeps the slot', (tester) async {
    final f = withOverall()
      ..addBudget(limit: 600000, category: 'food', id: 'food-budget');
    await openOn(tester, f);
    await tester.tap(find.byType(BudgetRow));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('budget_slot')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('budget_slot_fixed'))).data,
      'Food',
    );
    expect(find.byKey(const Key('delete_budget')), findsOneWidget);
    expect(find.text('₹6,000.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('budget_amount')));
    await tester.pumpAndSettle();
    await typeAmount(tester, '0');
    await save(tester);
    final b = f.world.budgets['food-budget']!;
    expect(b.limitMinor, 6000000);
    expect(b.categoryId, 'food');
  });

  testWidgets('EXP-09 a slot taken meanwhile shows an inline error', (
    tester,
  ) async {
    final f = await openOn(tester, withOverall());
    await openFoodSheet(tester);
    f.addBudget(limit: 100, category: 'food');
    await typeAmount(tester, '100');
    await save(tester);
    expect(
      find.text('This category already has a budget this month.'),
      findsOneWidget,
    );
  });

  testWidgets('EXP-09 a failed save keeps the sheet open with the input', (
    tester,
  ) async {
    final f = await openOn(tester, withOverall());
    await openFoodSheet(tester);
    await typeAmount(tester, '2500');
    f.world.failNextWrite = true;
    await save(tester);
    expect(
      find.text("Couldn't save. Your changes are still here. Try again."),
      findsOneWidget,
    );
    expect(find.text('₹2,500.00'), findsOneWidget);
    await save(tester);
    expect(find.byKey(const Key('save_budget')), findsNothing);
  });
}
