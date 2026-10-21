import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-011 and data-model.md §5.
void main() {
  final at = DateTime.utc(2026, 10, 14);
  TransactionDraft draft({
    TxnType type = TxnType.expense,
    int? amount = 100,
    String? account = 'a',
    String? to,
    String? category = 'c',
    String note = '',
  }) => TransactionDraft(
    type: type,
    amountMinor: amount,
    accountId: account,
    toAccountId: to,
    categoryId: category,
    paymentMode: PaymentMode.cash,
    occurredAt: at,
    note: note,
  );

  test('a complete expense, income and transfer are valid', () {
    expect(validateTransaction(draft()), isEmpty);
    expect(validateTransaction(draft(type: TxnType.income)), isEmpty);
    expect(
      validateTransaction(
        draft(type: TxnType.transfer, to: 'b', category: null),
      ),
      isEmpty,
    );
  });

  test('amount: missing or 0 is required; over the limit is too large', () {
    expect(validateTransaction(draft(amount: null)), {
      TxnField.amount: TxnError.amountRequired,
    });
    expect(validateTransaction(draft(amount: 0)), {
      TxnField.amount: TxnError.amountRequired,
    });
    expect(validateTransaction(draft(amount: AmountEntry.maxMinor)), isEmpty);
    expect(validateTransaction(draft(amount: AmountEntry.maxMinor + 1)), {
      TxnField.amount: TxnError.amountTooLarge,
    });
  });

  test('a keypad error wins over the stored amount', () {
    expect(validateTransaction(draft(), amountError: AmountError.invalid), {
      TxnField.amount: TxnError.amountInvalid,
    });
    expect(validateTransaction(draft(), amountError: AmountError.tooLarge), {
      TxnField.amount: TxnError.amountTooLarge,
    });
  });

  test('expense and income need a category', () {
    expect(validateTransaction(draft(category: null)), {
      TxnField.category: TxnError.categoryRequired,
    });
    expect(validateTransaction(draft(type: TxnType.income, category: null)), {
      TxnField.category: TxnError.categoryRequired,
    });
  });

  test('a transfer needs a different destination account', () {
    expect(validateTransaction(draft(type: TxnType.transfer, category: null)), {
      TxnField.toAccount: TxnError.toAccountRequired,
    });
    expect(
      validateTransaction(
        draft(type: TxnType.transfer, to: 'a', category: null),
      ),
      {TxnField.toAccount: TxnError.sameAccount},
    );
  });

  test('a transfer ignores a leftover category', () {
    expect(
      validateTransaction(draft(type: TxnType.transfer, to: 'b')),
      isEmpty,
    );
  });

  test('notes over 200 characters are rejected; 200 is fine', () {
    expect(validateTransaction(draft(note: 'x' * 200)), isEmpty);
    expect(validateTransaction(draft(note: 'x' * 201)), {
      TxnField.note: TxnError.noteTooLong,
    });
  });

  test('several errors are reported together', () {
    expect(validateTransaction(draft(amount: null, category: null)), {
      TxnField.amount: TxnError.amountRequired,
      TxnField.category: TxnError.categoryRequired,
    });
  });

  group('Repeat end date (US3 s3, feature 003 T061)', () {
    final entry = draft().copyWith(
      occurredAt: DateTime(2026, 10, 14, 21).toUtc(),
    );

    test('before the entry date → repeatEndBeforeStart', () {
      expect(
        validateTransaction(
          entry,
          repeat: RepeatSettings(endDate: DateTime(2026, 10, 13)),
        ),
        {TxnField.repeat: TxnError.repeatEndBeforeStart},
      );
    });

    test('the same day, a later day, or no end date is valid', () {
      for (final end in [DateTime(2026, 10, 14), DateTime(2027), null]) {
        expect(
          validateTransaction(entry, repeat: RepeatSettings(endDate: end)),
          isEmpty,
          reason: '$end',
        );
      }
      expect(validateTransaction(entry), isEmpty, reason: 'Repeat off');
    });

    test('endAt is the last moment of the end date', () {
      expect(
        RepeatSettings(endDate: DateTime(2026, 10, 22)).endAt,
        DateTime(2026, 10, 23).subtract(const Duration(milliseconds: 1)),
      );
      expect(const RepeatSettings().endAt, isNull);
    });
  });
}
