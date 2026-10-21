import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// One money movement (data-model.md §3.1, §4). Pure Dart.
@freezed
abstract class Transaction with _$Transaction {
  const factory({
    required String id,
    required TxnType type,

    /// Always positive, in minor units (paise). The sign comes from [type].
    required int amountMinor,
    required String accountId,
    required PaymentMode paymentMode,

    /// UTC.
    required DateTime occurredAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? toAccountId,
    String? categoryId,
    String? note,

    /// Relative path `receipts/<uuid>.jpg`.
    String? receiptPath,

    /// The rule this entry came from, or is the first occurrence of.
    String? recurringRuleId,
    DateTime? deletedAt,
  }) = _Transaction;

  const new _();

  bool get isTransfer => type == TxnType.transfer;

  /// Contribution to income/expense/net totals: income +, expense −,
  /// transfer 0 (transfers never count in totals).
  int get signedAmountMinor => switch (type) {
    TxnType.income => amountMinor,
    TxnType.expense => -amountMinor,
    TxnType.transfer => 0,
  };
}
