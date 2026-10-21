import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_account.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_form_state.freezed.dart';

enum AccountFormStatus { loading, ready, loadError }

/// EXP-07 state (contracts/screens.md). The opening balance is typed on
/// the keypad without a sign; [negative] is the separate +/− toggle.
@freezed
abstract class AccountFormState with _$AccountFormState {
  const factory({
    required AccountFormStatus status,
    @Default('') String name,
    @Default(AccountType.cash) AccountType type,
    @Default('') String openingExpression,
    @Default(false) bool negative,
    @Default('wallet') String iconKey,
    @Default('') String colorHex,
    @Default(<AccountField, AccountError>{})
    Map<AccountField, AccountError> errors,
    @Default(false) bool keypadOpen,
    @Default(false) bool saving,
    @Default(false) bool saveFailed,

    /// The account being edited; null for a new one.
    Account? original,
  }) = _AccountFormState;

  const new _();

  bool get isEdit => original != null;
}
