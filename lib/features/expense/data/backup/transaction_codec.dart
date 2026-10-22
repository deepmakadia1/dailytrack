import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// Amounts: ₹0.01 … ₹99,99,99,999.00 in minor units (the table CHECK).
const int maxAmountMinor = 99999999900;

/// Notes: at most 200 characters.
const int maxNoteLength = 200;

/// The transfer/expense/income shape both `transactions` and
/// `recurring_rules` CHECK (`type_shape_check.dart`).
void checkTypeShape(
  BackupFields f,
  TxnType type, {
  required String accountId,
  required String? toAccountId,
  required String? categoryId,
}) {
  if (type == TxnType.transfer) {
    if (toAccountId == null || categoryId != null) {
      f.invalid('type', 'transfer needs toAccountId and no category');
    }
    if (toAccountId == accountId) {
      f.invalid('toAccountId', 'must differ from accountId');
    }
  } else if (categoryId == null || toAccountId != null) {
    f.invalid('type', '${type.name} needs a category and no toAccountId');
  }
}

/// `transactions` rows in a backup (feature 008 data-model §3).
abstract final class TransactionCodec {
  static const String table = 'transactions';

  static Map<String, Object?> encode(TransactionRow r) => {
    'id': r.id,
    'type': r.type.name,
    'amountMinor': r.amountMinor,
    'accountId': r.accountId,
    'toAccountId': r.toAccountId,
    'categoryId': r.categoryId,
    'paymentMode': r.paymentMode.name,
    'note': r.note,
    'occurredAt': r.occurredAt,
    'receiptPath': r.receiptPath,
    'recurringRuleId': r.recurringRuleId,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: amount 1..99,999,999,900, note ≤ 200, type shape.
  static TransactionRow decode(BackupFields f) {
    final type = f.enumByName('type', TxnType.values);
    final accountId = f.string('accountId', min: 1);
    final toAccountId = f.nullableString('toAccountId');
    final categoryId = f.nullableString('categoryId');
    checkTypeShape(
      f,
      type,
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
    );
    final receipt = f.nullableString('receiptPath');
    if (receipt != null &&
        !RegExp(r'^receipts/[A-Za-z0-9._-]+$').hasMatch(receipt)) {
      f.invalid('receiptPath', 'is not a receipts/ file');
    }
    return TransactionRow(
      id: f.string('id', min: 1),
      type: type,
      amountMinor: f.integer('amountMinor', min: 1, max: maxAmountMinor),
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      paymentMode: f.enumByName('paymentMode', PaymentMode.values),
      note: f.nullableString('note', max: maxNoteLength),
      occurredAt: f.integer('occurredAt'),
      receiptPath: receipt,
      recurringRuleId: f.nullableString('recurringRuleId'),
      createdAt: f.integer('createdAt'),
      updatedAt: f.integer('updatedAt'),
      deletedAt: f.nullableInt('deletedAt'),
    );
  }
}
