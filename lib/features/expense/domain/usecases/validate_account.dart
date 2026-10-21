import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';

enum AccountField { name, openingBalance }

enum AccountError { nameRequired, nameTooLong, balanceOutOfRange }

/// Account names are 1–40 characters (data-model.md §3.3).
const int maxAccountNameLength = 40;

/// ±₹99,99,99,999.00 in paise.
const int maxBalanceMinor = AmountEntry.maxMinor;

/// EXP-07 validation (FR-028, data-model.md §5). Empty means valid.
/// [balanceInvalid] is true when the keypad input itself does not parse.
Map<AccountField, AccountError> validateAccount({
  required String name,
  required int openingBalanceMinor,
  bool balanceInvalid = false,
}) {
  final trimmed = name.trim();
  return {
    if (trimmed.isEmpty)
      AccountField.name: AccountError.nameRequired
    else if (trimmed.length > maxAccountNameLength)
      AccountField.name: AccountError.nameTooLong,
    if (balanceInvalid || openingBalanceMinor.abs() > maxBalanceMinor)
      AccountField.openingBalance: AccountError.balanceOutOfRange,
  };
}
