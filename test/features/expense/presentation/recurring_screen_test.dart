import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/screens/recurring_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/recurring_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-10 Recurring transactions (T066; US3 scenarios 8, 9, 12, FR-026).
/// "Now" is Wednesday 14 Oct 2026 10:00.
void main() {
  Future<ExpenseFakes> open(WidgetTester tester, ExpenseFakes f) =>
      pumpExpenseApp(tester, fakes: f, location: Routes.expenseRecurring);

  /// Rent ₹15,000 on the 5th, salary ₹80,000 on the 1st (income), and a
  /// paused weekly one.
  ExpenseFakes withRules() {
    final f = ExpenseFakes.withDefaults()
      ..addRule(
        amount: 1500000,
        anchor: DateTime(2026, 9, 5, 9),
        note: 'Rent',
        id: 'rent-rule',
      )
      ..addRule(
        amount: 8000000,
        anchor: DateTime(2026, 9, 1, 9),
        category: 'income_salary',
        type: TxnType.income,
        id: 'salary-rule',
      )
      ..addRule(
        amount: 30000,
        anchor: DateTime(2026, 10, 5, 8),
        category: 'transport',
        frequency: Frequency.weekly,
        active: false,
        id: 'bus-rule',
      );
    return f;
  }

  testWidgets('EXP-10 US3-8 active rules, then a Paused section; rows show '
      'note or category, signed amount, schedule and next date', (
    tester,
  ) async {
    await open(tester, withRules());
    expect(find.text('Recurring transactions'), findsOneWidget);
    double y(String id) =>
        tester.getTopLeft(find.byKey(ValueKey('rule_row_$id'))).dy;
    final pausedY = tester
        .getTopLeft(find.byKey(const Key('paused_heading')))
        .dy;
    // Active by next run: salary (1 Nov) before rent (5 Nov), then paused.
    expect(y('salary-rule') < y('rent-rule'), isTrue);
    expect(y('rent-rule') < pausedY && pausedY < y('bus-rule'), isTrue);

    final rent = find.byKey(const ValueKey('rule_row_rent-rule'));
    Finder inRent(String text) =>
        find.descendant(of: rent, matching: find.text(text));
    expect(inRent('Rent'), findsOneWidget);
    expect(inRent('Every month on 5th'), findsOneWidget);
    expect(inRent('Next: 5 Nov 2026'), findsOneWidget);
    expect(inRent('−₹15,000.00'), findsOneWidget);
    // No note: the category name; income is shown with a plus.
    final salary = find.byKey(const ValueKey('rule_row_salary-rule'));
    expect(
      find.descendant(of: salary, matching: find.text('Salary')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: salary, matching: find.text('+₹80,000.00')),
      findsOneWidget,
    );
    expect(find.text('Every week on Monday'), findsOneWidget);
  });

  testWidgets('EXP-10 an ended rule shows "Ended …" and cannot be resumed', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults()
      ..addRule(
        amount: 1000,
        anchor: DateTime(2026, 8, 5, 9),
        nextRun: DateTime(2026, 11, 5, 9),
        endAt: DateTime(2026, 10, 31, 23, 59),
        active: false,
        id: 'ended',
      );
    await open(tester, f);
    expect(find.text('Ended 31 Oct 2026'), findsOneWidget);
    await tester.longPress(find.byKey(const ValueKey('rule_row_ended')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ListTile>(find.byKey(const Key('rule_menu_pause'))).enabled,
      isFalse,
    );
  });

  testWidgets('EXP-10 a stale reference shows a warning line', (tester) async {
    final f = withRules();
    f.world.categories['rent'] = f.world.categories['rent']!.copyWith(
      isHidden: true,
    );
    await open(tester, f);
    expect(find.byKey(const ValueKey('rule_stale_rent-rule')), findsOneWidget);
    expect(find.text('Category hidden'), findsOneWidget);
    expect(find.byKey(const ValueKey('rule_stale_salary-rule')), findsNothing);
  });

  testWidgets('EXP-10 US3-9 swipe right pauses and resumes; swipe left '
      'deletes with a 5-second Undo', (tester) async {
    final f = await open(tester, withRules());
    await tester.drag(
      find.byKey(const ValueKey('rule_row_rent-rule')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    expect(f.world.rules['rent-rule']!.isActive, isFalse);
    expect(f.rules.calls['pause'], 1);

    await tester.drag(
      find.byKey(const ValueKey('rule_row_bus-rule')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    expect(f.world.rules['bus-rule']!.isActive, isTrue);
    expect(f.rules.calls['resume'], 1);

    await tester.drag(
      find.byKey(const ValueKey('rule_row_salary-rule')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rule_row_salary-rule')), findsNothing);
    expect(find.text('Recurring transaction deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rule_row_salary-rule')), findsOneWidget);
    expect(f.world.rules['salary-rule']!.deletedAt, isNull);
    await flushTimers(tester);
  });

  testWidgets('EXP-10 US3-9 the long-press menu offers Pause and Delete', (
    tester,
  ) async {
    final f = await open(tester, withRules());
    await tester.longPress(find.byKey(const ValueKey('rule_row_rent-rule')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rule_menu_pause')), findsOneWidget);
    await tester.tap(find.byKey(const Key('rule_menu_delete')));
    await tester.pumpAndSettle();
    expect(f.world.rules['rent-rule']!.deletedAt, isNotNull);
    expect(find.text('Recurring transaction deleted'), findsOneWidget);
    await flushTimers(tester);

    await tester.longPress(find.byKey(const ValueKey('rule_row_salary-rule')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rule_menu_pause')));
    await tester.pumpAndSettle();
    expect(f.world.rules['salary-rule']!.isActive, isFalse);
  });

  testWidgets('EXP-10 tapping a rule opens EXP-02 in rule-edit mode', (
    tester,
  ) async {
    await open(tester, withRules());
    await tester.tap(find.byKey(const ValueKey('rule_row_rent-rule')));
    await tester.pumpAndSettle();
    final form = tester.widget<TransactionFormScreen>(
      find.byType(TransactionFormScreen),
    );
    expect(form.args.mode, FormMode.ruleEdit);
    expect(form.args.ruleId, 'rent-rule');
    expect(find.text('Edit recurring transaction'), findsOneWidget);
  });

  testWidgets('EXP-10 US3-12 the empty state offers "Add recurring '
      'transaction" (no FAB); with rules the FAB shows', (tester) async {
    await open(tester, ExpenseFakes.withDefaults());
    expect(find.text('Nothing repeats yet'), findsOneWidget);
    expect(find.byKey(const Key('add_recurring')), findsNothing);
    await tester.tap(find.text('Add recurring transaction'));
    await tester.pumpAndSettle();
    final form = tester.widget<TransactionFormScreen>(
      find.byType(TransactionFormScreen),
    );
    expect(form.args.repeat, isTrue);
    final repeat = tester.widget<SwitchListTile>(
      find.byKey(const Key('repeat_switch'), skipOffstage: false),
    );
    expect(repeat.value, isTrue);
  });

  testWidgets('EXP-10 shows the FAB when rules exist, and no ads', (
    tester,
  ) async {
    await open(tester, withRules());
    expect(find.byKey(const Key('add_recurring')), findsOneWidget);
    final scaffold = tester.widget<AppScaffold>(find.byType(AppScaffold).last);
    expect(scaffold.bannerSlot, isNull);
    expect(find.byType(RecurringRow), findsNWidgets(3));
  });

  testWidgets('EXP-10 loading shows a skeleton only after 300 ms; a load '
      'error shows "Try again"', (tester) async {
    final f = withRules()..world.watchDelay = const Duration(seconds: 1);
    await pumpExpenseApp(tester, fakes: f);
    routerOf(tester).go(Routes.expenseRecurring);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonCard), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SkeletonCard), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(RecurringRow), findsNWidgets(3));

    f.world
      ..watchDelay = Duration.zero
      ..failWatch = StateError('db');
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    routerOf(tester).go(Routes.expenseRecurring);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    f.world.failWatch = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringRow), findsNWidgets(3));
  });

  testWidgets('EXP-10 opens from the EXP-01 overflow menu', (tester) async {
    await pumpExpenseApp(tester, fakes: withRules());
    await tester.tap(find.byKey(const Key('expenses_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_recurring')));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringScreen), findsOneWidget);
  });
}
