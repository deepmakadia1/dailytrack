import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_query_ops.dart';
import 'package:flutter_test/flutter_test.dart';

/// T070: pure query edits behind EXP-01's single notifier.
void main() {
  final october = MonthPeriod(DateTime(2026, 10));
  final base = TxnQuery(period: october);

  test('applyFilters sets every filter; chips list them in a stable order', () {
    final q = base.applyFilters(
      types: {TxnType.income, TxnType.expense},
      paymentModes: {PaymentMode.upi},
      categoryIds: {'food'},
      accountIds: {'sbi'},
      minAmountMinor: 100,
      maxAmountMinor: null,
    );
    expect(q.isFiltered, isTrue);
    expect(q.chips, [
      (kind: FilterKind.type, value: TxnType.expense),
      (kind: FilterKind.type, value: TxnType.income),
      (kind: FilterKind.mode, value: PaymentMode.upi),
      (kind: FilterKind.category, value: 'food'),
      (kind: FilterKind.account, value: 'sbi'),
      (kind: FilterKind.amount, value: null),
    ]);
  });

  test('removeChip removes exactly one filter value', () {
    final q = base.applyFilters(
      types: {TxnType.expense},
      paymentModes: {PaymentMode.upi, PaymentMode.card},
      categoryIds: const {},
      accountIds: const {},
      minAmountMinor: 100,
      maxAmountMinor: 900,
    );
    final noUpi = q.removeChip((kind: FilterKind.mode, value: PaymentMode.upi));
    expect(noUpi.paymentModes, {PaymentMode.card});
    final noAmount = q.removeChip((kind: FilterKind.amount, value: null));
    expect((noAmount.minAmountMinor, noAmount.maxAmountMinor), (null, null));
  });

  test('cleared keeps only the period; withPeriod keeps the filters', () {
    final q = base
        .withSearch('chai', {'food'})
        .withRouteAccount('sbi')
        .withPeriod(MonthPeriod(DateTime(2026, 9)));
    expect(q.accountIds, {'sbi'});
    expect(q.search, 'chai');
    expect(q.period, MonthPeriod(DateTime(2026, 9)));
    expect(q.cleared(), TxnQuery(period: MonthPeriod(DateTime(2026, 9))));
    expect(q.cleared().isFiltered, isFalse);
  });

  test('withRouteAccount replaces the account filter', () {
    final q = base
        .applyFilters(
          types: const {},
          paymentModes: const {},
          categoryIds: const {},
          accountIds: {'a', 'b'},
          minAmountMinor: null,
          maxAmountMinor: null,
        )
        .withRouteAccount('c');
    expect(q.accountIds, {'c'});
  });
}
