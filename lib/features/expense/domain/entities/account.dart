import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

/// Where money is held (data-model.md §3.3).
@freezed
abstract class Account with _$Account {
  const factory({
    required String id,

    /// `expense_account_cash` for the seeded account, otherwise user text.
    required String name,
    required AccountType type,

    /// Paise; may be negative (e.g. a card).
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
    required bool isArchived,
    required int sortOrder,
  }) = _Account;
}

/// EXP-06 row. The balance is derived, never stored.
@freezed
abstract class AccountWithBalance with _$AccountWithBalance {
  const factory({
    required Account account,
    required int balanceMinor,
    required bool hasTransactions,
  }) = _AccountWithBalance;
}
