import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transactions_controller.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/summary_strip.dart';
import 'package:dailytrack/features/expense/presentation/widgets/transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-01 Transactions list (spec §8, US2, T062 and T064).
void main() {
  /// A small October with expenses, income and a transfer over three days,
  /// plus one September expense. "Now" is Wed 14 Oct 2026, 10:00.
  ExpenseFakes october() {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addTransaction(
        id: 'a',
        amount: 15550,
        category: 'food',
        note: 'Lunch',
        at: DateTime(2026, 10, 14, 9),
      )
      ..addTransaction(
        id: 'b',
        amount: 100000,
        type: TxnType.income,
        category: 'income_salary',
        account: 'sbi',
        at: DateTime(2026, 10, 14, 8),
      )
      ..addTransaction(
        id: 'c',
        amount: 5000,
        type: TxnType.transfer,
        toAccount: 'sbi',
        at: DateTime(2026, 10, 14, 7),
      )
      ..addTransaction(
        id: 'd',
        amount: 2000,
        category: 'transport',
        mode: PaymentMode.upi,
        at: DateTime(2026, 10, 13, 18),
      )
      ..addTransaction(
        id: 'e',
        amount: 1010,
        category: 'food',
        note: 'chai',
        at: DateTime(2026, 10, 12, 17),
      )
      ..addTransaction(
        id: 'sep',
        amount: 777,
        category: 'food',
        at: DateTime(2026, 9, 20, 12),
      );
    return f;
  }

  List<String> rowIds(WidgetTester tester) => [
    for (final r in tester.widgetList<TransactionRow>(
      find.byType(TransactionRow),
    ))
      r.view.transaction.id,
  ];

  /// (income, expense, net) read from the summary strip.
  (int, int, int) strip(WidgetTester tester) {
    int read(String key) {
      final t = tester.widget<AmountText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(AmountText),
        ),
      );
      return t.kind == AmountKind.expense && key == 'summary_net'
          ? -t.amountMinor
          : t.amountMinor;
    }

    return (
      read('summary_income'),
      read('summary_expense'),
      read('summary_net'),
    );
  }

  /// The same totals summed from the rows on screen, transfers excluded.
  (int, int, int) sumOfRows(WidgetTester tester) {
    var income = 0;
    var expense = 0;
    for (final r in tester.widgetList<TransactionRow>(
      find.byType(TransactionRow),
    )) {
      final t = r.view.transaction;
      if (t.type == TxnType.income) income += t.amountMinor;
      if (t.type == TxnType.expense) expense += t.amountMinor;
    }
    return (income, expense, income - expense);
  }

  group('EXP-01 acceptance criteria', () {
    testWidgets(
      'Totals in the summary strip always equal the sum of visible rows '
      '(transfers excluded).',
      (tester) async {
        final f = await pumpExpenseApp(tester, fakes: october());
        expect(rowIds(tester), contains('c'), reason: 'the transfer is shown');
        expect(strip(tester), sumOfRows(tester));
        expect(strip(tester), (100000, 18560, 100000 - 18560));

        // With a search, and with an account filter.
        final controller = containerOf(tester).read(
          transactionsControllerProvider.notifier,
        )..setSearch('chai', displayName: (c) => c.name);
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        expect(rowIds(tester), ['e']);
        expect(strip(tester), sumOfRows(tester));

        controller
          ..clearFilters()
          ..applyRouteAccount('sbi');
        await tester.pumpAndSettle();
        expect(rowIds(tester), containsAll(['b', 'c']));
        expect(strip(tester), sumOfRows(tester));
        expect(f.active, hasLength(6));
      },
    );

    testWidgets('Undo restores a deleted row in its original position.', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      for (var i = 0; i < 5; i++) {
        f.addTransaction(
          id: 't$i',
          amount: 100 + i,
          category: 'food',
          at: DateTime(2026, 10, 14, 9),
        );
      }
      await pumpExpenseApp(tester, fakes: f);
      final before = rowIds(tester);
      final third = before[2];

      await tester.drag(
        find.byKey(ValueKey('row_$third')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(rowIds(tester), isNot(contains(third)));
      expect(find.text('Transaction deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(rowIds(tester), before);
      expect(rowIds(tester).indexOf(third), 2);
      await flushTimers(tester);
    });
  });

  group('EXP-01 scenarios', () {
    testWidgets('US2-1 app bar, period selector on this month, summary '
        'strip, then the list', (tester) async {
      await pumpExpenseApp(tester, fakes: october());
      expect(find.text('Expenses'), findsWidgets);
      expect(find.byTooltip('Search transactions'), findsOneWidget);
      expect(find.byTooltip('Filter'), findsOneWidget);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.byType(SummaryStrip), findsOneWidget);
      final selectorY = tester
          .getTopLeft(find.byKey(const Key('period_selector')))
          .dy;
      final stripY = tester.getTopLeft(find.byType(SummaryStrip)).dy;
      final firstRowY = tester.getTopLeft(find.byType(TransactionRow).first).dy;
      expect(selectorY < stripY && stripY < firstRowY, isTrue);

      // Overflow: Categories, Accounts, Budgets, Recurring and Reports
      // (FR-042), in that order.
      await tester.tap(find.byKey(const Key('expenses_overflow')));
      await tester.pumpAndSettle();
      final items = [
        for (final key in [
          'menu_categories',
          'menu_accounts',
          'menu_budgets',
          'menu_recurring',
          'menu_reports',
        ])
          tester.getTopLeft(find.byKey(Key(key))).dy,
      ];
      expect(items, orderedEquals([...items]..sort()));
      expect(find.byType(PopupMenuItem<String>), findsNWidgets(5));
      await tester.tap(find.byKey(const Key('menu_accounts')));
      await tester.pumpAndSettle();
      expect(find.text('Total balance'), findsOneWidget);
    });

    testWidgets('US2-2 changing the period updates list and totals in place', (
      tester,
    ) async {
      await pumpExpenseApp(tester, fakes: october());
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsOneWidget);
      expect(rowIds(tester), ['sep']);
      expect(strip(tester), (0, 777, -777));
      expect(find.byType(TransactionsScreen), findsOneWidget);
    });

    testWidgets('US2-3 sticky headers say Today, Yesterday or EEE, d MMM; '
        'rows show name, note, account · mode and amount', (tester) async {
      await pumpExpenseApp(tester, fakes: october());
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Mon, 12 Oct'), findsOneWidget);
      final row = find.byKey(const ValueKey('txn_d'));
      expect(
        find.descendant(of: row, matching: find.text('Transport')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text('Cash · UPI')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('txn_a')),
          matching: find.text('Lunch'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('US2-4 a transfer is listed but never totalled', (
      tester,
    ) async {
      await pumpExpenseApp(tester, fakes: october());
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('txn_c')),
          matching: find.text('Cash → SBI'),
        ),
        findsOneWidget,
      );
      // 5,000 moved from Cash to SBI counts in neither total.
      expect(strip(tester), (100000, 18560, 100000 - 18560));
    });

    testWidgets('US2-5 search waits 300 ms and matches a Gujarati category '
        'name', (tester) async {
      await pumpExpenseApp(tester, fakes: october(), locale: 'gu');
      await tester.tap(find.byKey(const Key('open_search')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('search_field')), 'ખોરાક');
      await tester.pump(const Duration(milliseconds: 299));
      expect(rowIds(tester), hasLength(5));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(rowIds(tester), unorderedEquals(['a', 'e']));
    });

    testWidgets('US2-6 a chip × removes its filter; filters survive tab '
        'switches and reset on restart', (tester) async {
      final f = october();
      final settings = FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      );
      await pumpExpenseApp(tester, fakes: f, settings: settings);
      containerOf(tester)
          .read(transactionsControllerProvider.notifier)
          .applyFilters(
            types: {TxnType.expense},
            paymentModes: {PaymentMode.upi},
            categoryIds: const {},
            accountIds: const {},
            minAmountMinor: null,
            maxAmountMinor: null,
          );
      await tester.pumpAndSettle();
      expect(rowIds(tester), ['d']);
      expect(find.byType(InputChip), findsNWidgets(2));

      routerOf(tester).go(Routes.home);
      await tester.pumpAndSettle();
      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNWidgets(2));

      await tester.tap(find.byTooltip('Remove filter UPI'));
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsOneWidget);
      expect(rowIds(tester), containsAll(['a', 'd', 'e']));

      await restartTestApp(tester, settings: settings, expense: f);
      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('US2-7 more rows load near the end; new entries appear live', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      for (var i = 0; i < 60; i++) {
        f.addTransaction(
          id: 'p$i',
          amount: 100 + i,
          category: 'food',
          at: DateTime(2026, 10, 1 + i % 13, 9),
        );
      }
      await pumpExpenseApp(tester, fakes: f);
      final container = containerOf(tester);
      expect(
        container.read(transactionsControllerProvider).rows.value,
        hasLength(50),
      );

      await tester.drag(
        find.byKey(const Key('transactions_list')),
        const Offset(0, -6000),
      );
      await tester.pumpAndSettle();
      final state = container.read(transactionsControllerProvider);
      expect(state.pageCount, 2);
      expect(state.rows.value, hasLength(60));

      f.addTransaction(
        id: 'live',
        amount: 4242,
        category: 'food',
        at: DateTime(2026, 10, 14, 9, 30),
      );
      await tester.pumpAndSettle();
      expect(
        container
            .read(transactionsControllerProvider)
            .rows
            .value!
            .map((v) => v.transaction.id),
        contains('live'),
      );
    });

    testWidgets('US2-8 swipe right duplicates; long-press offers Delete and '
        'Duplicate', (tester) async {
      await pumpExpenseApp(tester, fakes: october());
      await tester.longPress(find.byKey(const ValueKey('txn_a')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('row_menu_duplicate')), findsOneWidget);
      expect(find.byKey(const Key('row_menu_delete')), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('row_a')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      final form = tester.widget<TransactionFormScreen>(
        find.byType(TransactionFormScreen),
      );
      expect(form.args.duplicateOf, 'a');
      expect(form.args.mode, FormMode.add);
    });

    testWidgets('edge case "Duplicate of a transfer" opens a transfer with '
        'the same accounts and amount', (tester) async {
      await pumpExpenseApp(tester, fakes: october());
      await tester.drag(
        find.byKey(const ValueKey('row_c')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Save transfer'), findsOneWidget);
      expect(find.text('From Cash'), findsOneWidget);
      expect(find.text('To SBI'), findsOneWidget);
      expect(find.text('₹50.00'), findsOneWidget);
    });

    testWidgets('US2-9 empty period and "No matches" states', (tester) async {
      await pumpExpenseApp(tester, fakes: ExpenseFakes.withDefaults());
      expect(find.text('No transactions in October 2026'), findsOneWidget);
      // §15.1: the empty state's button is the only primary action.
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Add expense'), findsWidgets);

      final f = october();
      await pumpExpenseApp(tester, fakes: f);
      final controller = containerOf(tester).read(
        transactionsControllerProvider.notifier,
      )..setSearch('zzz', displayName: (c) => c.name);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('No matches'), findsOneWidget);
      expect(find.byKey(const Key('no_matches')), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(rowIds(tester), hasLength(5));
      expect(controller.state.query.isFiltered, isFalse);
    });

    testWidgets('US2-10 the FAB opens EXP-02 as an expense', (tester) async {
      await pumpExpenseApp(tester, fakes: october());
      await tester.tap(find.byKey(const Key('add_transaction')));
      await tester.pumpAndSettle();
      final form = tester.widget<TransactionFormScreen>(
        find.byType(TransactionFormScreen),
      );
      expect(form.args.initialType, TxnType.expense);
      expect(form.args.duplicateOf, isNull);
      expect(find.text('Save expense'), findsOneWidget);
    });

    testWidgets('US2-11 /expenses?accountId= applies the account chip once', (
      tester,
    ) async {
      await pumpExpenseApp(
        tester,
        fakes: october(),
        location: Routes.expensesPath(accountId: 'sbi'),
      );
      expect(find.widgetWithText(InputChip, 'SBI'), findsOneWidget);
      expect(rowIds(tester), unorderedEquals(['b', 'c']));
    });

    testWidgets('US2-12 §15.3 the FAB hides on scroll down and returns on '
        'scroll up', (tester) async {
      final f = ExpenseFakes.withDefaults();
      for (var i = 0; i < 30; i++) {
        f.addTransaction(
          amount: 100 + i,
          category: 'food',
          at: DateTime(2026, 10, 1 + i % 13, 9),
        );
      }
      await pumpExpenseApp(tester, fakes: f);
      final list = find.byKey(const Key('transactions_list'));
      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add_transaction')), findsNothing);
      await tester.drag(list, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add_transaction')), findsOneWidget);
    });

    testWidgets('edge case "Undo after leaving": Undo still works from '
        'another tab within 5 s', (tester) async {
      final f = await pumpExpenseApp(tester, fakes: october());
      await tester.drag(
        find.byKey(const ValueKey('row_a')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      routerOf(tester).go(Routes.home);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(f.active.map((t) => t.id), contains('a'));
      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(rowIds(tester).first, 'a');
      await flushTimers(tester);
    });
  });

  group('EXP-01 four states', () {
    testWidgets('loading shows a skeleton only after 300 ms', (tester) async {
      final f = october()..world.watchDelay = const Duration(seconds: 1);
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      routerOf(tester).go(Routes.expenses);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SkeletonList), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(TransactionRow), findsWidgets);
    });

    testWidgets('a load failure shows the error state; Try again recovers', (
      tester,
    ) async {
      final f = october();
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      f.world.failWatch = const ExpenseStorageFailure('boom');
      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      expect(
        find.text("Couldn't load your transactions. Try again."),
        findsOneWidget,
      );
      f.world.failWatch = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionRow), findsWidgets);
    });
  });
}
