import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-02 keypad visibility (feature 004): scrolling the form hides the
/// keypad; only tapping the amount shows it again.
void main() {
  Finder keypad() => find.byType(NumericKeypad);
  Finder form() => find.byKey(const Key('transaction_form'));
  Finder amount() => find.byKey(const Key('amount_display'));
  Finder save() => find.byKey(const Key('save_transaction'));
  String amountShown(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('amount_value'))).data!;

  Future<ExpenseFakes> open(
    WidgetTester tester, {
    String location = Routes.expenseAdd,
    ExpenseFakes? fakes,
  }) async {
    final f = await pumpExpenseApp(tester, fakes: fakes);
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    return f;
  }

  Future<void> scrollDown(WidgetTester tester) async {
    await tester.drag(form(), const Offset(0, -300));
    await tester.pumpAndSettle();
  }

  Future<void> scrollToTop(WidgetTester tester) async {
    await tester.drag(form(), const Offset(0, 2000));
    await tester.pumpAndSettle();
  }

  group('US1 scrolling the form hides the keypad', () {
    testWidgets('s1 a drag hides the keypad and Save stays visible '
        '(FR-001, FR-007)', (tester) async {
      await open(tester);
      expect(keypad(), findsOneWidget);
      await scrollDown(tester);
      expect(keypad(), findsNothing);
      expect(save(), findsOneWidget);
      expect(tester.getRect(save()).bottom, lessThanOrEqualTo(915));
    });

    testWidgets('a fling hides the keypad too', (tester) async {
      await open(tester);
      await tester.fling(form(), const Offset(0, -400), 2000);
      await tester.pumpAndSettle();
      expect(keypad(), findsNothing);
    });

    testWidgets('a drag that starts on the category grid hides it', (
      tester,
    ) async {
      await open(tester);
      await tester.drag(
        find.byKey(const ValueKey('category_food')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(keypad(), findsNothing);
    });

    testWidgets('s2 the amount and a calculation in progress are kept '
        '(FR-003)', (tester) async {
      await open(tester);
      await typeAmount(tester, '200+50');
      String expression() =>
          tester.widget<Text>(find.byKey(const Key('amount_expression'))).data!;
      final shown = (amountShown(tester), expression());
      await scrollDown(tester);
      await scrollToTop(tester);
      expect((amountShown(tester), expression()), shown);
      expect(shown.$1, '₹250.00');
    });

    testWidgets('s3 scrolling back to the top keeps it hidden (FR-004)', (
      tester,
    ) async {
      await open(tester);
      await scrollDown(tester);
      await scrollToTop(tester);
      expect(keypad(), findsNothing);
    });

    testWidgets('s4 Save after hiding by scroll saves the same transaction', (
      tester,
    ) async {
      final f = await open(tester);
      await typeAmount(tester, '250');
      await tester.tap(find.byKey(const ValueKey('category_food')));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(keypad(), findsNothing);
      await tester.tap(save());
      await tester.pumpAndSettle();
      final saved = f.active.single;
      expect(saved.amountMinor, 25000);
      expect(saved.categoryId, 'food');
      expect(saved.type, TxnType.expense);
      await flushTimers(tester);
    });

    testWidgets('s5 a scroll started by the app does not hide it (FR-002)', (
      tester,
    ) async {
      await open(tester);
      final note = tester.element(find.byKey(const Key('note_field')));
      // Not awaited: the animation only advances while the test pumps.
      Scrollable.ensureVisible(note, duration: Durations.short4);
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
    });

    testWidgets('hiding by scroll is not an unsaved change (FR-005)', (
      tester,
    ) async {
      await open(tester);
      await scrollDown(tester);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.byType(TransactionFormScreen), findsNothing);
    });
  });

  group('US2 only tapping the amount brings the keypad back', () {
    testWidgets('s2 other controls keep it hidden; s1 the amount shows it and '
        'the next digit continues the amount', (tester) async {
      await open(tester);
      await typeAmount(tester, '25');
      await scrollToTop(tester);
      await scrollDown(tester);
      expect(keypad(), findsNothing);

      await tester.ensureVisible(find.byKey(const ValueKey('category_food')));
      await tester.tap(find.byKey(const ValueKey('category_food')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('UPI'));
      await tester.tap(find.text('UPI'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('repeat_switch')));
      await tester.tap(find.byKey(const Key('repeat_switch')));
      await tester.pumpAndSettle();
      expect(keypad(), findsNothing);

      // s3: scrolled out of view, scroll back up and tap the amount.
      await scrollToTop(tester);
      expect(keypad(), findsNothing);
      await tester.tap(amount());
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
      await typeAmount(tester, '0');
      expect(amountShown(tester), '₹250.00');
    });

    testWidgets('edit mode opens hidden; after tapping the amount a scroll '
        'hides it again (FR-006)', (tester) async {
      final f = ExpenseFakes.withDefaults();
      final t = f.addTransaction(amount: 1550, category: 'food');
      await open(tester, location: Routes.expenseEditPath(t.id), fakes: f);
      expect(keypad(), findsNothing);
      await tester.tap(amount());
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
      await scrollDown(tester);
      expect(keypad(), findsNothing);
    });

    testWidgets('rule-edit mode behaves the same', (tester) async {
      final f = ExpenseFakes.withDefaults();
      final rule = f.addRule(amount: 1500000, anchor: DateTime(2026, 9, 5, 9));
      await open(
        tester,
        location: Routes.expenseRuleEditPath(rule.id),
        fakes: f,
      );
      expect(keypad(), findsNothing);
      await tester.tap(amount());
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
      await scrollDown(tester);
      expect(keypad(), findsNothing);
    });

    testWidgets('Done and the note field still hide it (FR-006)', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(keypad(), findsNothing);
      await tester.tap(amount());
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('note_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('note_field')));
      await tester.pumpAndSettle();
      expect(keypad(), findsNothing);
    });

    testWidgets('s4 the amount is a labelled button whose tap action shows '
        'the keypad', (tester) async {
      final semantics = tester.ensureSemantics();
      await open(tester);
      await scrollDown(tester);
      await scrollToTop(tester);
      expect(keypad(), findsNothing);
      final node = tester.getSemantics(amount());
      expect(node.label, contains('₹0.00'));
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      tester.semantics.tap(find.semantics.byLabel(node.label));
      await tester.pumpAndSettle();
      expect(keypad(), findsOneWidget);
      semantics.dispose();
    });
  });
}
