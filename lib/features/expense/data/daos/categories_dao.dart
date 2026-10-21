import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/transactions_table.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

part 'categories_dao.g.dart';

/// A category row with its month total and all-time usage count.
typedef CategoryStatsRow = ({CategoryRow row, int monthTotal, int usage});

/// Categories queries (data-model.md §3.2). Soft-deleted rows are excluded.
@DriftAccessor(tables: [Categories, Transactions])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  new(super.attachedDatabase);

  /// Non-deleted categories of [type] with stats over non-deleted
  /// transactions. [pickableOnly] drops hidden ones and orders by usage
  /// (clarification Q2); otherwise the order is sortOrder (EXP-04).
  Stream<List<CategoryStatsRow>> watchWithStats(
    CategoryType type, {
    required int monthStart,
    required int monthEnd,
    bool pickableOnly = false,
  }) {
    final c = categories;
    final t = transactions;
    final monthTotal = t.amountMinor.sum(
      filter:
          t.occurredAt.isBiggerOrEqualValue(monthStart) &
          t.occurredAt.isSmallerThanValue(monthEnd),
    );
    final usage = t.id.count();

    var where = c.type.equalsValue(type) & c.deletedAt.isNull();
    if (pickableOnly) where &= c.isArchived.equals(false);

    final q =
        select(c).join([
            leftOuterJoin(
              t,
              t.categoryId.equalsExp(c.id) & t.deletedAt.isNull(),
              useColumns: false,
            ),
          ])
          ..addColumns([monthTotal, usage])
          ..where(where)
          ..groupBy([c.id])
          ..orderBy([
            if (pickableOnly) OrderingTerm.desc(usage),
            OrderingTerm.asc(c.sortOrder),
            OrderingTerm.asc(c.createdAt),
          ]);

    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            row: r.readTable(c),
            monthTotal: r.read(monthTotal) ?? 0,
            usage: r.read(usage) ?? 0,
          ),
      ],
    );
  }

  Stream<List<CategoryRow>> watchAll() =>
      (select(categories)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([
              (c) => OrderingTerm.asc(c.type),
              (c) => OrderingTerm.asc(c.sortOrder),
            ]))
          .watch();

  /// The row, deleted or not.
  Future<CategoryRow?> byId(String id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> nextSortOrder(CategoryType type) async {
    final max = categories.sortOrder.max();
    final q = selectOnly(categories)
      ..addColumns([max])
      ..where(categories.type.equalsValue(type));
    final current = (await q.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<void> insertRow(CategoriesCompanion row) =>
      into(categories).insert(row);

  Future<int> updateRow(String id, CategoriesCompanion row) =>
      (update(categories)..where((c) => c.id.equals(id))).write(row);

  /// Non-deleted transactions using [id].
  Future<int> transactionCount(String id) async {
    final t = transactions;
    final rowCount = t.id.count();
    final q = selectOnly(t)
      ..addColumns([rowCount])
      ..where(t.categoryId.equals(id) & t.deletedAt.isNull());
    final n = (await q.getSingle()).read(rowCount);
    return n ?? 0;
  }

  /// Moves every transaction (deleted ones too, so an undone delete never
  /// points at a removed category) from [from] to [to].
  Future<int> moveTransactions(String from, String to, int now) =>
      (update(transactions)..where((t) => t.categoryId.equals(from))).write(
        TransactionsCompanion(categoryId: Value(to), updatedAt: Value(now)),
      );
}
