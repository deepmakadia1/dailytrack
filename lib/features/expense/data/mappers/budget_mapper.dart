import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:drift/drift.dart' show Value;

DateTime _utc(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

extension BudgetRowMapper on BudgetRow {
  Budget toEntity() => Budget(
    id: id,
    categoryId: categoryId,
    monthKey: monthKey,
    limitMinor: limitMinor,
    rollover: rollover,
    alert80SentAt: alert80SentAt == null ? null : _utc(alert80SentAt!),
    alert100SentAt: alert100SentAt == null ? null : _utc(alert100SentAt!),
    createdAt: _utc(createdAt),
    updatedAt: _utc(updatedAt),
  );

  /// A copy of this budget for [targetMonth], with markers cleared.
  BudgetsCompanion copyTo(
    String targetMonth, {
    required String id,
    required int now,
  }) => BudgetsCompanion.insert(
    id: id,
    categoryId: Value(categoryId),
    monthKey: targetMonth,
    limitMinor: limitMinor,
    rollover: rollover,
    createdAt: now,
    updatedAt: now,
  );
}
