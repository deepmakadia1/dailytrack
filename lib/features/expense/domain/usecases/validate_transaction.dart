import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';

/// The EXP-02 field an error is shown under.
enum TxnField { amount, category, toAccount, note, repeat }

/// data-model.md §5.
enum TxnError {
  amountRequired,
  amountTooLarge,
  amountInvalid,
  categoryRequired,
  toAccountRequired,
  sameAccount,
  noteTooLong,

  /// The Repeat end date is before the entry's date (US3 s3).
  repeatEndBeforeStart,
}

const int maxNoteLength = 200;

/// Validates an EXP-02 draft (FR-011). Returns one error per field; empty
/// means valid. [amountError] is the keypad's own parse error, which wins
/// over the stored amount. [repeat] is the Repeat section when it is on.
Map<TxnField, TxnError> validateTransaction(
  TransactionDraft draft, {
  AmountError? amountError,
  RepeatSettings? repeat,
}) {
  final amount = draft.amountMinor;
  final amountProblem = switch (amountError) {
    AmountError.invalid => TxnError.amountInvalid,
    AmountError.tooLarge => TxnError.amountTooLarge,
    AmountError.required => TxnError.amountRequired,
    null when amount == null || amount <= 0 => TxnError.amountRequired,
    null when amount! > AmountEntry.maxMinor => TxnError.amountTooLarge,
    null => null,
  };

  final isTransfer = draft.type == TxnType.transfer;
  return {
    TxnField.amount: ?amountProblem,
    if (!isTransfer && draft.categoryId == null)
      TxnField.category: TxnError.categoryRequired,
    if (isTransfer && draft.toAccountId == null)
      TxnField.toAccount: TxnError.toAccountRequired
    else if (isTransfer && draft.toAccountId == draft.accountId)
      TxnField.toAccount: TxnError.sameAccount,
    if (draft.note.trim().length > maxNoteLength)
      TxnField.note: TxnError.noteTooLong,
    if (_endsBeforeStart(draft, repeat))
      TxnField.repeat: TxnError.repeatEndBeforeStart,
  };
}

/// Compares local calendar days: an end date on the entry's own day is
/// valid.
bool _endsBeforeStart(TransactionDraft draft, RepeatSettings? repeat) {
  final end = repeat?.endDate;
  if (end == null) return false;
  final start = draft.occurredAt.toLocal();
  return DateTime(
    end.year,
    end.month,
    end.day,
  ).isBefore(DateTime(start.year, start.month, start.day));
}
