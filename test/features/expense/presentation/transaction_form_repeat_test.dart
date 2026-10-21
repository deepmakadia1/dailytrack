import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/receipt_field.dart';
import 'package:dailytrack/features/expense/presentation/widgets/schedule_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-02 Repeat section and rule-edit mode, as widgets (T065; US3
/// scenarios 1–3, 11, 13, 14). "Now" is Wednesday 14 Oct 2026.
void main() {
  Finder save() => find.byKey(const Key('save_transaction'));
  Finder repeatSwitch() => find.byKey(const Key('repeat_switch'));

  Future<ExpenseFakes> open(
    WidgetTester tester,
    String location, {
    ExpenseFakes? fakes,
    Size size = const Size(412, 915),
  }) async {
    final f = await pumpExpenseApp(tester, fakes: fakes, size: size);
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
    return f;
  }

  Future<void> showRepeat(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      repeatSwitch(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('EXP-02 US3-1 the Repeat switch shows frequency chips, an end '
      'date, and the schedule in words', (tester) async {
    await open(tester, Routes.expenseAdd);
    await showRepeat(tester);
    expect(find.byKey(const Key('repeat_frequency')), findsNothing);
    await tester.tap(repeatSwitch());
    await tester.pumpAndSettle();
    for (final label in ['Daily', 'Weekly', 'Monthly', 'Yearly']) {
      expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
    }
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Monthly'))
          .selected,
      isTrue,
    );
    expect(find.text('Every month on 14th'), findsOneWidget);
    expect(find.text('End date (optional)'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Weekly'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('Every week on Wednesday'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Yearly'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('Every year on 14 Oct'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Daily'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Daily'));
    await tester.pumpAndSettle();
    expect(find.text('Every day'), findsOneWidget);
  });

  testWidgets('EXP-02 US3-2 saving with Repeat on links the entry to a new '
      'rule', (tester) async {
    final f = await open(tester, Routes.expenseAdd);
    await typeAmount(tester, '15000');
    await tester.tap(find.byKey(const ValueKey('category_rent')));
    await showRepeat(tester);
    await tester.tap(repeatSwitch());
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(f.world.rules, hasLength(1));
    expect(f.active.single.recurringRuleId, f.world.rules.keys.single);
    expect(find.text('Saved'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US3-3 an end date before the entry date is an inline '
      'error under Repeat', (tester) async {
    final f = await open(tester, Routes.expenseAdd);
    final c = containerOf(tester);
    await typeAmount(tester, '100');
    await tester.tap(find.byKey(const ValueKey('category_rent')));
    await showRepeat(tester);
    await tester.tap(repeatSwitch());
    await tester.pumpAndSettle();
    // The date picker is the platform's; set the end date directly.
    final args = tester
        .widget<TransactionFormScreen>(find.byType(TransactionFormScreen))
        .args;
    c
        .read(transactionFormControllerProvider(args).notifier)
        .setEndDate(DateTime(2026, 10));
    await tester.pumpAndSettle();
    expect(find.text('Ends 1 Oct 2026'), findsOneWidget);
    await tester.tap(save());
    await tester.pumpAndSettle();
    await showRepeat(tester);
    expect(
      find.text("End date can't be before the first date"),
      findsOneWidget,
    );
    expect(f.world.rules, isEmpty);
    expect(find.byType(TransactionFormScreen), findsOneWidget);
  });

  testWidgets('EXP-02 US3-11 rule-edit: title, "Next date", no receipt field, '
      'no delete icon, Repeat on', (tester) async {
    final f = ExpenseFakes.withDefaults();
    final rule = f.addRule(
      amount: 1500000,
      anchor: DateTime(2026, 9, 5, 9),
      note: 'Rent',
    );
    await open(tester, Routes.expenseRuleEditPath(rule.id), fakes: f);
    expect(find.text('Edit recurring transaction'), findsOneWidget);
    expect(find.text('Next date'), findsOneWidget);
    expect(find.byType(ReceiptField), findsNothing);
    expect(find.byKey(const Key('delete_transaction')), findsNothing);
    await showRepeat(tester);
    expect(tester.widget<SwitchListTile>(repeatSwitch()).value, isTrue);
    expect(find.text('Every month on 5th'), findsOneWidget);

    // Repeat off + save ends the rule, with its own Undo message (Q5).
    await tester.tap(repeatSwitch());
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.text('Recurring transaction deleted'), findsOneWidget);
    expect(f.world.rules[rule.id]!.deletedAt, isNotNull);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(f.world.rules[rule.id]!.deletedAt, isNull);
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US3-13 Repeat is hidden when editing a linked entry', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    final rule = f.addRule(amount: 1000, anchor: DateTime(2026, 9, 5, 9));
    final t = f.addTransaction(amount: 1000, category: 'rent');
    f.world.transactions[t.id] = t.copyWith(recurringRuleId: rule.id);
    await open(tester, Routes.expenseEditPath(t.id), fakes: f);
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(repeatSwitch(), findsNothing);
  });

  testWidgets('EXP-02 US3-14 editing an unlinked entry offers Repeat', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(amount: 1000, category: 'rent');
    await open(tester, Routes.expenseEditPath(t.id), fakes: f);
    await showRepeat(tester);
    expect(repeatSwitch(), findsOneWidget);
  });

  testWidgets('EXP-02 /expenses/recurring/add opens with Repeat on', (
    tester,
  ) async {
    await open(tester, Routes.expenseRecurringAdd);
    await showRepeat(tester);
    expect(tester.widget<SwitchListTile>(repeatSwitch()).value, isTrue);
  });

  testWidgets('EXP-02 the Repeat section fits 360 dp at 200% font scale', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, Routes.expenseRecurringAdd, size: const Size(360, 800));
    await showRepeat(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('repeat_schedule')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  test('ordinal suffixes', () {
    expect(
      [
        for (final d in [1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 31])
          ordinalSuffix(d),
      ],
      ['st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'st', 'nd', 'rd', 'st'],
    );
    expect(Frequency.values, hasLength(4));
  });
}
