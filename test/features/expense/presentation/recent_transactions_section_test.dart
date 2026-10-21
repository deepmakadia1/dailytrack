import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/recent_transactions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// DSH-01 Recent transactions (T017, contracts/screens.md, Q4).
void main() {
  // Tall enough that the whole Home fits without scrolling.
  const tall = Size(412, 1800);

  Future<ExpenseFakes> home(WidgetTester tester, ExpenseFakes f) =>
      pumpExpenseApp(tester, fakes: f, location: Routes.home, size: tall);

  List<Key> rowKeys(WidgetTester tester) => [
    for (final e
        in find
            .descendant(
              of: find.byType(RecentTransactionsSection),
              matching: find.byWidgetPredicate(
                (w) =>
                    w.key is ValueKey<String> &&
                    (w.key! as ValueKey<String>).value.startsWith(
                      'recent_row_',
                    ),
              ),
            )
            .evaluate())
      e.widget.key!,
  ];

  testWidgets('DSH-01 shows 5 rows of 8, newest first', (tester) async {
    final f = ExpenseFakes.withDefaults();
    final ids = [
      for (var i = 0; i < 8; i++)
        f
            .addTransaction(
              amount: 100 + i,
              category: 'food',
              at: DateTime(2026, 10, 1 + i, 9),
            )
            .id,
    ];
    await home(tester, f);
    expect(rowKeys(tester), [
      for (final id in ids.reversed.take(5)) Key('recent_row_$id'),
    ]);
  });

  testWidgets('DSH-01 a transfer row shows "From → To" with an unsigned '
      'amount', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addTransaction(amount: 50000, type: TxnType.transfer, toAccount: 'sbi');
    await home(tester, f);
    final row = find.descendant(
      of: find.byType(RecentTransactionsSection),
      matching: find.textContaining('→'),
    );
    expect(row, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RecentTransactionsSection),
        matching: find.text('₹500.00'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DSH-01 "See all" opens EXP-01', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 100, category: 'food');
    await home(tester, f);
    await tester.tap(find.byKey(const Key('recent_see_all')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets('DSH-01 a row tap opens EXP-03', (tester) async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(amount: 100, category: 'food');
    await home(tester, f);
    await tester.tap(find.byKey(Key('recent_row_${t.id}')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  });

  testWidgets('DSH-01 the section is hidden with zero transactions', (
    tester,
  ) async {
    await home(tester, ExpenseFakes.withDefaults());
    expect(find.byType(RecentTransactionsSection), findsOneWidget);
    expect(find.byKey(const Key('recent_transactions')), findsNothing);
    expect(tester.getSize(find.byType(RecentTransactionsSection)).height, 0);
  });

  testWidgets('DSH-01 the section updates live', (tester) async {
    final f = ExpenseFakes.withDefaults();
    await home(tester, f);
    expect(find.byKey(const Key('recent_transactions')), findsNothing);
    final t = f.addTransaction(amount: 100, category: 'food');
    await tester.pumpAndSettle();
    expect(find.byKey(Key('recent_row_${t.id}')), findsOneWidget);
  });
}
