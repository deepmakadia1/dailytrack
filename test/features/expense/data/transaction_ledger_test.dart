import 'dart:math';

import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// EXP-01: "Totals in the summary strip always equal the sum of visible rows
/// (transfers excluded)." Checked over 500 random rows, every period kind and
/// a set of filters (research R4, SC-003).
void main() {
  test(
    'ledger equals the sum of matching rows for every period and filter',
    () async {
      final x = await ExpenseDb.open();
      final rnd = Random(42);
      final accounts = [
        await x.account('Cash'),
        await x.account('SBI', type: AccountType.bank),
        await x.account('Card', type: AccountType.card, opening: -50000),
      ];
      final expenseCats = [await x.category('Food'), await x.category('Fuel')];
      final incomeCat = await x.category('Salary', type: CategoryType.income);

      for (var i = 0; i < 500; i++) {
        final type = TxnType.values[rnd.nextInt(3)];
        final from = accounts[rnd.nextInt(3)];
        final to = accounts.where((a) => a != from).elementAt(rnd.nextInt(2));
        await x.add(
          type: type,
          account: from,
          toAccount: type == TxnType.transfer ? to : null,
          category: switch (type) {
            TxnType.expense => expenseCats[rnd.nextInt(2)],
            TxnType.income => incomeCat,
            TxnType.transfer => null,
          },
          mode: PaymentMode.values[rnd.nextInt(PaymentMode.values.length)],
          amount: 1 + rnd.nextInt(500000),
          note: rnd.nextBool() ? 'chai' : 'other',
          // September and October 2026, any minute of the day.
          at: DateTime(
            2026,
            9,
            1 + rnd.nextInt(61),
            rnd.nextInt(24),
            rnd.nextInt(60),
          ),
        );
      }

      final periods = <Period>[
        SingleDayPeriod(DateTime(2026, 10, 14)),
        SingleDayPeriod(DateTime(2026, 9, 30)),
        WeekPeriod(DateTime(2026, 10), firstDayOfWeek: 1),
        WeekPeriod(DateTime(2026, 10), firstDayOfWeek: 7),
        MonthPeriod(DateTime(2026, 9)),
        MonthPeriod(DateTime(2026, 10)),
        YearPeriod(DateTime(2026)),
        CustomPeriod(DateTime(2026, 9, 20), DateTime(2026, 10, 10)),
      ];
      List<TxnQuery> filtersFor(Period p) => [
        TxnQuery(period: p),
        TxnQuery(period: p, accountIds: {accounts[1]}),
        TxnQuery(period: p, types: {TxnType.expense, TxnType.transfer}),
        TxnQuery(period: p, paymentModes: {PaymentMode.upi}),
        TxnQuery(period: p, categoryIds: {expenseCats.first}),
        TxnQuery(period: p, minAmountMinor: 10000, maxAmountMinor: 300000),
        TxnQuery(period: p, search: 'chai'),
      ];

      var checked = 0;
      for (final period in periods) {
        for (final query in filtersFor(period)) {
          final rows = await x.transactions
              .watchPage(query, limit: 100000)
              .first;
          final ledger = await x.transactions.watchLedger(query).first;
          expect(ledger, _sum(rows), reason: '$query');
          checked += rows.length;
        }
      }
      expect(checked, greaterThan(500), reason: 'the matrix exercised data');
    },
  );
}

/// The ledger computed independently from the visible rows.
PeriodLedger _sum(List<TransactionView> rows) {
  var income = 0;
  var expense = 0;
  final days = <String, DayTotal>{};
  for (final v in rows) {
    final t = v.transaction;
    if (t.isTransfer) continue;
    final key = DateKeys.fromLocal(t.occurredAt.toLocal());
    final day = days[key] ?? const DayTotal();
    if (t.type == TxnType.income) {
      income += t.amountMinor;
      days[key] = day.copyWith(incomeMinor: day.incomeMinor + t.amountMinor);
    } else {
      expense += t.amountMinor;
      days[key] = day.copyWith(expenseMinor: day.expenseMinor + t.amountMinor);
    }
  }
  return PeriodLedger(
    incomeMinor: income,
    expenseMinor: expense,
    dayTotals: days,
  );
}
