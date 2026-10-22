import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/backup/transaction_codec.dart';

/// `budgets` rows in a backup (feature 008 data-model §3).
abstract final class BudgetCodec {
  static const String table = 'budgets';

  static Map<String, Object?> encode(BudgetRow r) => {
    'id': r.id,
    'categoryId': r.categoryId,
    'monthKey': r.monthKey,
    'limitMinor': r.limitMinor,
    'rollover': r.rollover,
    'alert80SentAt': r.alert80SentAt,
    'alert100SentAt': r.alert100SentAt,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: `yyyy-MM` month, limit 1..99,999,999,900, and the
  /// 100% marker only with the 80% one.
  static BudgetRow decode(BackupFields f) {
    final alert80 = f.nullableInt('alert80SentAt');
    final alert100 = f.nullableInt('alert100SentAt');
    if (alert100 != null && alert80 == null) {
      f.invalid('alert100SentAt', 'needs alert80SentAt');
    }
    return BudgetRow(
      id: f.string('id', min: 1),
      categoryId: f.nullableString('categoryId'),
      monthKey: f.matching('monthKey', monthKeyPattern, 'yyyy-MM'),
      limitMinor: f.integer('limitMinor', min: 1, max: maxAmountMinor),
      rollover: f.boolean('rollover'),
      alert80SentAt: alert80,
      alert100SentAt: alert100,
      createdAt: f.integer('createdAt'),
      updatedAt: f.integer('updatedAt'),
      deletedAt: f.nullableInt('deletedAt'),
    );
  }
}
