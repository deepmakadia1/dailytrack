import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/fold_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int ms(DateTime local) => local.toUtc().millisecondsSinceEpoch;

  test('sums income and expense separately and excludes transfers', () {
    final ledger = foldLedger([
      (ms(DateTime(2026, 10, 14, 9)), TxnType.expense, 15550),
      (ms(DateTime(2026, 10, 14, 12)), TxnType.income, 100000),
      (ms(DateTime(2026, 10, 14, 13)), TxnType.transfer, 50000),
      (ms(DateTime(2026, 10, 13, 20)), TxnType.expense, 1010),
    ]);

    expect(ledger.incomeMinor, 100000);
    expect(ledger.expenseMinor, 16560);
    expect(ledger.netMinor, 100000 - 16560);
    expect(ledger.dayTotals, {
      '2026-10-14': const DayTotal(incomeMinor: 100000, expenseMinor: 15550),
      '2026-10-13': const DayTotal(expenseMinor: 1010),
    });
    expect(ledger.dayTotals['2026-10-14']!.netMinor, 100000 - 15550);
  });

  test('a transfer-only day has no header total', () {
    final ledger = foldLedger([
      (ms(DateTime(2026, 10, 14, 9)), TxnType.transfer, 500),
    ]);
    expect(ledger, const PeriodLedger());
  });

  test('an entry at 23:59 local time falls on that local day', () {
    final ledger = foldLedger([
      (ms(DateTime(2026, 10, 14, 23, 59)), TxnType.expense, 100),
      (ms(DateTime(2026, 10, 15)), TxnType.expense, 200),
    ]);
    expect(ledger.dayTotals.keys, containsAll(['2026-10-14', '2026-10-15']));
    expect(ledger.dayTotals['2026-10-14']!.expenseMinor, 100);
    expect(ledger.dayTotals['2026-10-15']!.expenseMinor, 200);
  });

  test('edge case "Time zone change": only the day grouping moves', () {
    DateTime Function(int) fixedOffset(Duration offset) => (utcMs) {
      final utc = DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true);
      final shifted = utc.add(offset);
      // A wall-clock DateTime whose fields are the zone's local fields.
      return DateTime(
        shifted.year,
        shifted.month,
        shifted.day,
        shifted.hour,
        shifted.minute,
      );
    };

    final rows = [
      (
        DateTime.utc(2026, 10, 13, 20).millisecondsSinceEpoch,
        TxnType.expense,
        500,
      ),
      (
        DateTime.utc(2026, 10, 13, 10).millisecondsSinceEpoch,
        TxnType.income,
        2000,
      ),
      (
        DateTime.utc(2026, 10, 14, 2).millisecondsSinceEpoch,
        TxnType.expense,
        300,
      ),
    ];

    final india = foldLedger(
      rows,
      toLocal: fixedOffset(const Duration(hours: 5, minutes: 30)),
    );
    final newYork = foldLedger(
      rows,
      toLocal: fixedOffset(const Duration(hours: -4)),
    );

    // 2026-10-13T20:00Z is 14 Oct 01:30 in India and 13 Oct 16:00 in New York.
    expect(india.dayTotals['2026-10-14']!.expenseMinor, 800);
    expect(newYork.dayTotals['2026-10-13']!.expenseMinor, 800);
    expect(newYork.dayTotals['2026-10-13']!.incomeMinor, 2000);

    for (final l in [india, newYork]) {
      expect(l.incomeMinor, 2000);
      expect(l.expenseMinor, 800);
      final summed = l.dayTotals.values.fold<int>(
        0,
        (s, d) => s + d.incomeMinor + d.expenseMinor,
      );
      expect(summed, 2800, reason: 'every row lands in exactly one day');
    }
  });
}
