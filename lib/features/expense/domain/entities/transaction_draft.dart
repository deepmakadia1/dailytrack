import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_draft.freezed.dart';

/// EXP-02 form input. Becomes a `Transaction` on save.
@freezed
abstract class TransactionDraft with _$TransactionDraft {
  const factory({
    required TxnType type,
    required PaymentMode paymentMode,

    /// UTC.
    required DateTime occurredAt,
    int? amountMinor,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    @Default('') String note,
    String? receiptPath,
  }) = _TransactionDraft;
}
