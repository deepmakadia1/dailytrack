import 'package:dailytrack/features/expense/domain/usecases/validate_account.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-07 rules (FR-028, data-model.md §5).
void main() {
  test('a name is required and at most 40 characters after trimming', () {
    expect(validateAccount(name: 'Cash', openingBalanceMinor: 0), isEmpty);
    expect(validateAccount(name: '   ', openingBalanceMinor: 0), {
      AccountField.name: AccountError.nameRequired,
    });
    expect(
      validateAccount(name: '  ${'x' * 40}  ', openingBalanceMinor: 0),
      isEmpty,
    );
    expect(validateAccount(name: 'x' * 41, openingBalanceMinor: 0), {
      AccountField.name: AccountError.nameTooLong,
    });
  });

  test('the opening balance may be negative, within ±₹99,99,99,999', () {
    expect(
      validateAccount(name: 'Card', openingBalanceMinor: -5000000),
      isEmpty,
    );
    expect(
      validateAccount(name: 'Card', openingBalanceMinor: -maxBalanceMinor),
      isEmpty,
    );
    expect(
      validateAccount(name: 'Card', openingBalanceMinor: maxBalanceMinor + 1),
      {AccountField.openingBalance: AccountError.balanceOutOfRange},
    );
    expect(
      validateAccount(name: 'Card', openingBalanceMinor: -maxBalanceMinor - 1),
      {AccountField.openingBalance: AccountError.balanceOutOfRange},
    );
  });

  test('a keypad error is reported on the balance', () {
    expect(
      validateAccount(name: 'A', openingBalanceMinor: 0, balanceInvalid: true),
      {AccountField.openingBalance: AccountError.balanceOutOfRange},
    );
  });
}
