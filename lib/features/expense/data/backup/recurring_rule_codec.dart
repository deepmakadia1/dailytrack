import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/backup/transaction_codec.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// `recurring_rules` rows in a backup (feature 008 data-model §3).
abstract final class RecurringRuleCodec {
  static const String table = 'recurringRules';

  static Map<String, Object?> encode(RecurringRuleRow r) => {
    'id': r.id,
    'templateType': r.templateType.name,
    'amountMinor': r.amountMinor,
    'accountId': r.accountId,
    'toAccountId': r.toAccountId,
    'categoryId': r.categoryId,
    'paymentMode': r.paymentMode.name,
    'note': r.note,
    'frequency': r.frequency.name,
    'interval': r.interval,
    'anchorAt': r.anchorAt,
    'nextRunAt': r.nextRunAt,
    'endAt': r.endAt,
    'isActive': r.isActive,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: amount range, note ≤ 200, interval ≥ 1,
  /// endAt ≥ anchorAt, and the type shape.
  static RecurringRuleRow decode(BackupFields f) {
    final type = f.enumByName('templateType', TxnType.values);
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
    final anchorAt = f.integer('anchorAt');
    final endAt = f.nullableInt('endAt');
    if (endAt != null && endAt < anchorAt) {
      f.invalid('endAt', 'is before anchorAt');
    }
    return RecurringRuleRow(
      id: f.string('id', min: 1),
      templateType: type,
      amountMinor: f.integer('amountMinor', min: 1, max: maxAmountMinor),
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      paymentMode: f.enumByName('paymentMode', PaymentMode.values),
      note: f.nullableString('note', max: maxNoteLength),
      frequency: f.enumByName('frequency', Frequency.values),
      interval: f.integer('interval', min: 1),
      anchorAt: anchorAt,
      nextRunAt: f.integer('nextRunAt'),
      endAt: endAt,
      isActive: f.boolean('isActive'),
      createdAt: f.integer('createdAt'),
      updatedAt: f.integer('updatedAt'),
      deletedAt: f.nullableInt('deletedAt'),
    );
  }
}
