import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Enums are stored by index, so their order is part of the schema.
void main() {
  test('index order is fixed (append-only)', () {
    expect(CategoryType.values.map((e) => e.name), ['expense', 'income']);
    expect(AccountType.values.map((e) => e.name), [
      'cash',
      'bank',
      'upi',
      'card',
      'wallet',
    ]);
    expect(TxnType.values.map((e) => e.name), [
      'expense',
      'income',
      'transfer',
    ]);
    expect(PaymentMode.values.map((e) => e.name), [
      'cash',
      'upi',
      'card',
      'netBanking',
      'other',
    ]);
    // Feature 003 (T006): stored in recurring_rules.frequency.
    expect(Frequency.values.map((e) => e.index), [0, 1, 2, 3]);
    expect(Frequency.values.map((e) => e.name), [
      'daily',
      'weekly',
      'monthly',
      'yearly',
    ]);
  });

  test('every account type maps to a default payment mode (Q4)', () {
    expect(
      {for (final t in AccountType.values) t: t.defaultPaymentMode},
      {
        AccountType.cash: PaymentMode.cash,
        AccountType.bank: PaymentMode.netBanking,
        AccountType.upi: PaymentMode.upi,
        AccountType.card: PaymentMode.card,
        AccountType.wallet: PaymentMode.other,
      },
    );
  });
}
