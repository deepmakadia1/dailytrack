import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-02 Add / edit transaction (spec §8, US1, T048–T050).
void main() {
  Finder save() => find.byKey(const Key('save_transaction'));
  Finder category(String id) => find.byKey(ValueKey('category_$id'));
  String amountShown(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('amount_value'))).data!;

  Future<ExpenseFakes> openAdd(
    WidgetTester tester, {
    ExpenseFakes? fakes,
    String? type,
  }) async {
    final f = await pumpExpenseApp(tester, fakes: fakes);
    routerOf(tester).go(Routes.expenseAddPath(type: type));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    return f;
  }

  group('EXP-02 acceptance criteria', () {
    testWidgets(
      'A new expense can be saved with amount + category only in 3 taps '
      'after typing the amount.',
      (tester) async {
        final f = await openAdd(tester);
        await typeAmount(tester, '250');

        var taps = 0;
        Future<void> tap(Finder finder) async {
          taps++;
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        await tap(category('food'));
        await tap(save());

        expect(taps, lessThanOrEqualTo(3));
        final saved = f.active.single;
        expect(saved.amountMinor, 25000);
        expect(saved.categoryId, 'food');
        expect(saved.type, TxnType.expense);
        expect(saved.accountId, 'cash');
        expect(find.byType(TransactionFormScreen), findsNothing);
        await flushTimers(tester);
      },
    );

    testWidgets('Amount is stored in paise without rounding errors '
        '(e.g. 10.10 → 1010).', (tester) async {
      final f = await openAdd(tester);
      for (final (typed, paise) in [
        ('10.10', 1010),
        ('0.29', 29),
        ('125000.55', 12500055),
      ]) {
        await typeAmount(tester, typed);
        await tester.tap(category('food'));
        await tester.pump();
        await tester.longPress(save());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('save_and_add_another')));
        await tester.pumpAndSettle();
        expect(f.active.last.amountMinor, paise, reason: typed);
        f.world.transactions.clear();
      }
      await flushTimers(tester);
    });
  });

  group('EXP-02 scenarios', () {
    testWidgets('US1-1 amount keypad is open, no system keyboard, Indian '
        'grouping', (tester) async {
      await openAdd(tester);
      expect(find.byType(NumericKeypad), findsOneWidget);
      expect(tester.testTextInput.isVisible, isFalse);
      // §15.1: Save is the single filled button; the keypad's Done is tonal.
      expect(
        find.byWidgetPredicate(
          (w) => w is FilledButton && w.style == null && w.key != null,
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('save_transaction')), findsOneWidget);
      await typeAmount(tester, '125000');
      expect(amountShown(tester), contains('1,25,000'));
    });

    testWidgets('US1-2 the calculator: 120+35.50 then = stores 15550', (
      tester,
    ) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '120+35.50');
      expect(find.byKey(const Key('amount_expression')), findsOneWidget);
      await typeAmount(tester, '=');
      expect(amountShown(tester), '₹155.50');
      await tester.tap(category('food'));
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.active.single.amountMinor, 15550);
      await flushTimers(tester);
    });

    testWidgets('US1-4 transfer hides categories; same accounts are '
        'rejected inline', (tester) async {
      final f = ExpenseFakes.withDefaults()..addAccount('SBI', id: 'sbi');
      await openAdd(tester, fakes: f, type: 'transfer');
      expect(find.byKey(const Key('from_account_chip')), findsOneWidget);
      expect(category('food'), findsNothing);

      await typeAmount(tester, '100');
      await tester.tap(find.byKey(const Key('to_account_chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick_account_cash')));
      await tester.pumpAndSettle();
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.text('Choose two different accounts'), findsOneWidget);
      expect(f.active, isEmpty);

      await tester.tap(find.byKey(const Key('to_account_chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick_account_sbi')));
      await tester.pumpAndSettle();
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.active.single.toAccountId, 'sbi');
      expect(f.active.single.categoryId, isNull);
      await flushTimers(tester);
    });

    testWidgets('US1-5 empty, zero and too-large amounts show an inline '
        'error', (tester) async {
      final f = await openAdd(tester);
      await tester.tap(category('food'));
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount'), findsOneWidget);

      await typeAmount(tester, '0');
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount'), findsOneWidget);

      await typeAmount(tester, '999999999.01');
      await tester.pump();
      expect(find.textContaining('Amount can be at most'), findsOneWidget);
      expect(f.active, isEmpty);
    });

    testWidgets('US1-6 expense without a category shows an inline error', (
      tester,
    ) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '50');
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.text('Choose a category'), findsOneWidget);
      expect(f.active, isEmpty);
    });

    testWidgets('US1-7 defaults to the last-used account; a Wallet account '
        'sets payment mode Other (Q4)', (tester) async {
      final f = ExpenseFakes.withDefaults()
        ..addAccount('Paytm', id: 'paytm', type: AccountType.wallet)
        ..addTransaction(amount: 1, account: 'paytm', category: 'food');
      await openAdd(tester, fakes: f);
      expect(
        tester
            .widget<ChoiceChip>(
              find.descendant(
                of: find.byType(ChipSelector<PaymentMode>),
                matching: find.widgetWithText(ChoiceChip, 'Other'),
              ),
            )
            .selected,
        isTrue,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('account_chip')),
          matching: find.text('Paytm'),
        ),
        findsOneWidget,
      );

      // Choosing Cash switches the payment mode to Cash.
      await tester.ensureVisible(find.byKey(const Key('account_chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account_chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick_account_cash')));
      await tester.pumpAndSettle();
      await typeAmount(tester, '5');
      await tester.tap(category('food'));
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.active.last.paymentMode, PaymentMode.cash);
      await flushTimers(tester);
    });

    testWidgets('US1-8 Today and Yesterday set the date', (tester) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '5');
      await tester.tap(category('food'));
      await tester.ensureVisible(find.byKey(const Key('date_yesterday')));
      await tester.tap(find.byKey(const Key('date_yesterday')));
      await tester.pump();
      await tester.tap(save());
      await tester.pumpAndSettle();
      final day = f.active.single.occurredAt.toLocal();
      expect((day.year, day.month, day.day), (2026, 10, 13));
      await flushTimers(tester);
    });

    testWidgets('US1-9 note has a 200 limit, a counter and recent '
        'suggestions', (tester) async {
      final f = ExpenseFakes.withDefaults()
        ..addTransaction(amount: 1, category: 'food', note: 'Chai with team');
      await openAdd(tester, fakes: f);
      await tester.pump(const Duration(milliseconds: 300));
      final field = find.byKey(const Key('note_field'));
      await tester.ensureVisible(field);
      expect(find.text('0/200'), findsOneWidget);
      expect(find.text('Chai with team'), findsOneWidget);

      await tester.enterText(field, 'x' * 250);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<TextField>(field).controller!.text, hasLength(200));
      expect(find.text('200/200'), findsOneWidget);
    });

    testWidgets('US1-10 receipt: picked shows a thumbnail; a failure shows '
        'an inline error and keeps the form', (tester) async {
      final f = await openAdd(tester);
      await tester.ensureVisible(find.byKey(const Key('receipt_camera')));
      await tester.tap(find.byKey(const Key('receipt_camera')));
      await tester.pumpAndSettle();
      expect(f.receiptPicker.calls, [ReceiptSource.camera]);
      expect(find.byKey(const Key('receipt_thumbnail')), findsOneWidget);
      // The fake store has no file: the placeholder shows (edge case).
      expect(find.byTooltip('Receipt not available'), findsOneWidget);

      await tester.tap(find.byKey(const Key('receipt_remove')));
      await tester.pumpAndSettle();
      f.receiptPicker.error = const ReceiptFailure('denied');
      await tester.tap(find.byKey(const Key('receipt_gallery')));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't attach the photo. Try again."),
        findsOneWidget,
      );
      expect(find.byType(TransactionFormScreen), findsOneWidget);
    });

    testWidgets('US1-11 save closes, shows "Saved · Undo", and Undo removes '
        'the new entry', (tester) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '99');
      await tester.tap(category('food'));
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);
      expect(find.text('Saved'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(f.active, isEmpty);
      await flushTimers(tester);
    });

    testWidgets('US1-11 Undo after an edit restores the previous values', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      final t = f.addTransaction(amount: 500, category: 'food', note: 'Lunch');
      await pumpExpenseApp(tester, fakes: f);
      routerOf(tester).go(Routes.expenseEditPath(t.id));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('amount_display')));
      await tester.pump();
      await typeAmount(tester, '0');
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.world.transactions[t.id]!.amountMinor, 5000);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(f.world.transactions[t.id], t);
      await flushTimers(tester);
    });

    testWidgets('US1-12 "Save and add another" saves and resets, keeping '
        'type and account', (tester) async {
      final f = await openAdd(tester, type: 'income');
      await typeAmount(tester, '1000');
      await tester.tap(category('income_salary'));
      await tester.longPress(save());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_and_add_another')));
      await tester.pumpAndSettle();
      expect(f.active.single.type, TxnType.income);
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(amountShown(tester), '₹0.00');
      expect(find.text('Save income'), findsOneWidget);
      await flushTimers(tester);
    });

    testWidgets('US1-13 back asks "Discard changes?" only when there are '
        'changes', (tester) async {
      await openAdd(tester);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);

      routerOf(tester).go(Routes.expenseAdd);
      await tester.pumpAndSettle();
      await typeAmount(tester, '5');
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsOneWidget);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);
    });

    testWidgets('US1-14 edit mode is prefilled; delete closes and offers '
        'Undo', (tester) async {
      final f = ExpenseFakes.withDefaults();
      final t = f.addTransaction(amount: 1550, category: 'food', note: 'Tea');
      await pumpExpenseApp(tester, fakes: f);
      routerOf(tester).go(Routes.expenseEditPath(t.id));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      expect(amountShown(tester), '₹15.50');
      expect(find.text('Tea'), findsWidgets);

      await tester.tap(find.byKey(const Key('delete_transaction')));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);
      expect(f.active, isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(f.active.single.id, t.id);
      await flushTimers(tester);
    });

    // Feature 003 (T1.6) added the Repeat toggle; it is off by default.
    testWidgets('US1-15 Repeat is off by default and nothing ad-related', (
      tester,
    ) async {
      await openAdd(tester);
      final repeat = tester.widget<SwitchListTile>(
        find.byKey(const Key('repeat_switch')),
      );
      expect(repeat.value, isFalse);
      expect(find.byKey(const Key('repeat_frequency')), findsNothing);
    });
  });

  group('EXP-02 four states', () {
    testWidgets('loading shows a skeleton only after 300 ms', (tester) async {
      final f = ExpenseFakes.withDefaults()
        ..world.watchDelay = const Duration(seconds: 1);
      await pumpExpenseApp(tester, fakes: f);
      routerOf(tester).go(Routes.expenseAdd);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SkeletonList), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(NumericKeypad), findsOneWidget);
    });

    testWidgets('a load failure shows the error state; Try again recovers', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      await pumpExpenseApp(tester, fakes: f);
      f.world.failWatch = const ExpenseStorageFailure('boom');
      routerOf(tester).go(Routes.expenseAdd);
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      f.world.failWatch = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(NumericKeypad), findsOneWidget);
    });

    testWidgets('empty: with every category hidden only the helper shows', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      for (final c in [...f.world.categories.values]) {
        f.world.categories[c.id] = c.copyWith(isHidden: true);
      }
      await openAdd(tester, fakes: f);
      expect(find.byKey(const Key('no_categories')), findsOneWidget);
      expect(
        find.text('No categories yet. Add one to continue'),
        findsOneWidget,
      );
    });
  });

  group('EXP-02 edge cases', () {
    testWidgets('10÷3 stores 333; 5÷0 and a negative result are rejected', (
      tester,
    ) async {
      final f = await openAdd(tester);
      Future<void> backspace(int times) async {
        for (var i = 0; i < times; i++) {
          await tester.tap(find.bySemanticsLabel('Delete'));
          await tester.pump();
        }
      }

      await tester.tap(category('food'));
      await typeAmount(tester, '5/0');
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.text('Check the calculation'), findsOneWidget);

      await backspace(3);
      await typeAmount(tester, '5-6');
      expect(find.text('Check the calculation'), findsOneWidget);

      await backspace(3);
      await typeAmount(tester, '10/3');
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.active.single.amountMinor, 333);
      await flushTimers(tester);
    });

    testWidgets('an entry dated in the future is accepted', (tester) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '7');
      await tester.tap(category('food'));
      containerOf(tester)
          .read(
            transactionFormControllerProvider(
              const TransactionFormArgs(mode: FormMode.add),
            ).notifier,
          )
          .setOccurredAt(DateTime(2026, 12, 25, 9));
      await tester.pump();
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(f.active.single.occurredAt.toLocal(), DateTime(2026, 12, 25, 9));
      await flushTimers(tester);
    });

    testWidgets('an entry deleted elsewhere closes the form with a message', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      final t = f.addTransaction(amount: 100, category: 'food');
      await pumpExpenseApp(tester, fakes: f);
      routerOf(tester).go(Routes.expenseEditPath(t.id));
      await tester.pumpAndSettle();
      await f.transactions.softDelete(t.id);
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);
      expect(find.text('This transaction no longer exists'), findsOneWidget);
      expect(locationOf(tester), Routes.expenses);
      await flushTimers(tester);
    });

    testWidgets('a save failure keeps the form open with the input intact', (
      tester,
    ) async {
      final f = await openAdd(tester);
      await typeAmount(tester, '42');
      await tester.tap(category('food'));
      f.world.failNextWrite = true;
      await tester.tap(save());
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(
        find.text("Couldn't save. Your changes are still here. Try again."),
        findsOneWidget,
      );
      expect(amountShown(tester), '₹42.00');
      expect(f.active, isEmpty);
    });

    testWidgets('an archived last-used account falls back to the first '
        'active one', (tester) async {
      final f = ExpenseFakes.withDefaults()
        ..addAccount('Old card', id: 'card', archived: true)
        ..addTransaction(amount: 1, account: 'card', category: 'food');
      await openAdd(tester, fakes: f);
      expect(
        find.descendant(
          of: find.byKey(const Key('account_chip')),
          matching: find.text('Cash'),
        ),
        findsOneWidget,
      );
    });
  });
}
