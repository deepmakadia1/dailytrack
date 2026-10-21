import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-06 Accounts (spec §8, US5, T099).
void main() {
  Finder row(String id) => find.byKey(ValueKey('account_row_$id'));

  AmountText balance(WidgetTester tester, String id) =>
      tester.widget<AmountText>(find.byKey(ValueKey('balance_$id')));

  /// Cash 0, SBI 10,000, Card −500 (opening), and an archived wallet.
  ExpenseFakes accounts() {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi', type: AccountType.bank, opening: 1000000)
      ..addAccount('Card', id: 'card', type: AccountType.card, opening: -50000)
      ..addAccount(
        'Old wallet',
        id: 'old',
        type: AccountType.wallet,
        archived: true,
        opening: 700,
      )
      ..addTransaction(amount: 15550, category: 'food')
      ..addTransaction(
        amount: 300000,
        type: TxnType.income,
        category: 'income_salary',
        account: 'sbi',
      )
      ..addTransaction(
        amount: 40000,
        type: TxnType.transfer,
        account: 'sbi',
        toAccount: 'card',
      );
    return f;
  }

  Future<ExpenseFakes> open(WidgetTester tester, [ExpenseFakes? f]) =>
      pumpExpenseApp(
        tester,
        fakes: f ?? accounts(),
        location: Routes.expenseAccounts,
      );

  Future<void> menu(WidgetTester tester, String id) async {
    await tester.longPress(row(id));
    await tester.pumpAndSettle();
  }

  testWidgets('US5-1/2 total card, rows with derived balances (negative in '
      'red with −), collapsed Archived', (tester) async {
    await open(tester);
    // Cash −155.50; SBI 10,000 + 3,000 − 400; Card −500 + 400.
    expect(balance(tester, 'cash').amountMinor, 15550);
    expect(balance(tester, 'cash').kind, AmountKind.expense);
    expect(balance(tester, 'cash').showSign, isTrue);
    expect(balance(tester, 'sbi').amountMinor, 1260000);
    expect(balance(tester, 'sbi').kind, AmountKind.neutral);
    expect(balance(tester, 'card').amountMinor, 10000);
    expect(find.text('−₹155.50'), findsOneWidget);

    final total = tester.widget<AmountText>(
      find.descendant(
        of: find.byKey(const Key('total_balance')),
        matching: find.byType(AmountText),
      ),
    );
    expect(total.amountMinor, 1260000 - 15550 - 10000);
    expect(find.text('Archived'), findsOneWidget);
    expect(row('old'), findsNothing, reason: 'collapsed');
    expect(find.text('Bank'), findsOneWidget);
  });

  testWidgets('US5-3 tap opens EXP-01 filtered to that account', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(row('sbi'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'SBI'), findsOneWidget);
  });

  testWidgets('US5-4 archive shows Undo; an archived account can be '
      'restored', (tester) async {
    final f = await open(tester);
    await menu(tester, 'card');
    await tester.tap(find.byKey(const Key('account_menu_archive')));
    await tester.pumpAndSettle();
    expect(f.world.accounts['card']!.isArchived, isTrue);
    expect(find.text('Account archived'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(f.world.accounts['card']!.isArchived, isFalse);

    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();
    await menu(tester, 'old');
    await tester.tap(find.byKey(const Key('account_menu_archive')));
    await tester.pumpAndSettle();
    expect(f.world.accounts['old']!.isArchived, isFalse);
    await flushTimers(tester);
  });

  testWidgets('US5-5 only an account without transactions can be deleted, '
      'with Undo', (tester) async {
    final f = accounts()..addAccount('Spare', id: 'spare');
    await open(tester, f);
    await menu(tester, 'sbi');
    final deleteTile = tester.widget<ListTile>(
      find.byKey(const Key('account_menu_delete')),
    );
    expect(deleteTile.enabled, isFalse);
    expect(
      find.text('Accounts with transactions can be archived, not deleted'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await menu(tester, 'spare');
    await tester.tap(find.byKey(const Key('account_menu_delete')));
    await tester.pumpAndSettle();
    expect(row('spare'), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(row('spare'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('US5-6 an archived account is not offered in EXP-02', (
    tester,
  ) async {
    await open(tester);
    routerOf(tester).go(Routes.expenseAdd);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('account_chip')));
    await tester.tap(find.byKey(const Key('account_chip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pick_account_sbi')), findsOneWidget);
    expect(find.byKey(const ValueKey('pick_account_old')), findsNothing);
  });

  testWidgets('US5-8 the last active account cannot be archived or deleted '
      '(Q3)', (tester) async {
    final f = ExpenseFakes.withDefaults();
    await open(tester, f);
    await menu(tester, 'cash');
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('account_menu_archive')))
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('account_menu_delete')))
          .enabled,
      isFalse,
    );
    expect(find.text('You need at least one active account'), findsWidgets);
  });

  group('EXP-06 four states', () {
    testWidgets('loading shows a skeleton only after 300 ms', (tester) async {
      final f = accounts()..world.watchDelay = const Duration(seconds: 1);
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      routerOf(tester).go(Routes.expenseAccounts);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SkeletonList), findsOneWidget);
      await tester.pumpAndSettle();
      expect(row('sbi'), findsOneWidget);
    });

    testWidgets('a load failure shows the error state; Try again recovers', (
      tester,
    ) async {
      final f = accounts();
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      f.world.failWatch = const ExpenseStorageFailure('boom');
      routerOf(tester).go(Routes.expenseAccounts);
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      f.world.failWatch = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(row('sbi'), findsOneWidget);
    });

    testWidgets('empty: no accounts at all offers "Add account"', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      f.world.deletedAccounts.add('cash');
      await open(tester, f);
      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Add account'), findsOneWidget);
    });
  });
}
