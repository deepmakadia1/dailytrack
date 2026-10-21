import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/tables/budgets_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:drift/drift.dart';

part 'budgets_dao.g.dart';

/// A live budget with its category row (null for Overall). The category
/// may be hidden or deleted (spec edge case).
typedef BudgetJoinRow = ({BudgetRow budget, CategoryRow? category});

/// Budgets queries (research R4, R6, R7). Every query excludes
/// soft-deleted budgets unless its name says otherwise.
@DriftAccessor(tables: [Budgets, Categories])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  new(super.attachedDatabase);

  Expression<bool> _live() => budgets.deletedAt.isNull();

  Future<List<BudgetJoinRow>> liveForMonth(String monthKey) async {
    final q = select(budgets).join([
      leftOuterJoin(categories, categories.id.equalsExp(budgets.categoryId)),
    ])..where(_live() & budgets.monthKey.equals(monthKey));
    return [
      for (final r in await q.get())
        (budget: r.readTable(budgets), category: r.readTableOrNull(categories)),
    ];
  }

  /// Live budgets of [monthKey] whose category is Overall or still active
  /// (neither hidden nor deleted): the ones Copy and rollover may copy.
  Future<List<BudgetRow>> copyableForMonth(
    String monthKey, {
    bool rolloverOnly = false,
  }) async {
    final active =
        budgets.categoryId.isNull() |
        (categories.deletedAt.isNull() & categories.isArchived.equals(false));
    var where = _live() & budgets.monthKey.equals(monthKey) & active;
    if (rolloverOnly) where &= budgets.rollover.equals(true);
    final q = select(budgets).join([
      leftOuterJoin(categories, categories.id.equalsExp(budgets.categoryId)),
    ])..where(where);
    return [for (final r in await q.get()) r.readTable(budgets)];
  }

  /// The latest month before [monthKey] that has live budgets.
  Future<String?> latestMonthBefore(String monthKey) async {
    final latest = budgets.monthKey.max();
    final q = selectOnly(budgets)
      ..addColumns([latest])
      ..where(_live() & budgets.monthKey.isSmallerThanValue(monthKey));
    return (await q.getSingle()).read(latest);
  }

  Future<bool> slotTaken(String monthKey, String? categoryId) async {
    final q = select(budgets)
      ..where(
        (b) =>
            _live() &
            b.monthKey.equals(monthKey) &
            (categoryId == null
                ? b.categoryId.isNull()
                : b.categoryId.equals(categoryId)),
      );
    return (await q.get()).isNotEmpty;
  }

  Future<BudgetRow?> liveById(String id) => (select(
    budgets,
  )..where((b) => b.id.equals(id) & _live())).getSingleOrNull();

  Future<BudgetRow?> liveSlot(String monthKey, String? categoryId) =>
      (select(budgets)..where(
            (b) =>
                _live() &
                b.monthKey.equals(monthKey) &
                (categoryId == null
                    ? b.categoryId.isNull()
                    : b.categoryId.equals(categoryId)),
          ))
          .getSingleOrNull();

  Future<void> insertRow(BudgetsCompanion row) => into(budgets).insert(row);

  Future<int> updateLive(String id, BudgetsCompanion row) =>
      (update(budgets)..where((b) => b.id.equals(id) & _live())).write(row);

  Future<int> setDeletedAt(String id, int? deletedAt, int now) =>
      (update(budgets)..where((b) => b.id.equals(id))).write(
        BudgetsCompanion(deletedAt: Value(deletedAt), updatedAt: Value(now)),
      );

  /// Compare-and-set (research R6): sets the 80% marker only if it is unset.
  Future<int> markAlert80(String id, int at) => customUpdate(
    'UPDATE budgets SET alert80_sent_at = ?1, updated_at = ?1 '
    'WHERE id = ?2 AND deleted_at IS NULL AND alert80_sent_at IS NULL',
    variables: [Variable.withInt(at), Variable.withString(id)],
    updates: {budgets},
    updateKind: UpdateKind.update,
  );

  /// Compare-and-set: sets the 100% marker (and a missing 80% one) only if
  /// the 100% marker is unset.
  Future<int> markAlert100(String id, int at) => customUpdate(
    'UPDATE budgets SET alert100_sent_at = ?1, '
    'alert80_sent_at = IFNULL(alert80_sent_at, ?1), updated_at = ?1 '
    'WHERE id = ?2 AND deleted_at IS NULL AND alert100_sent_at IS NULL',
    variables: [Variable.withInt(at), Variable.withString(id)],
    updates: {budgets},
    updateKind: UpdateKind.update,
  );
}
