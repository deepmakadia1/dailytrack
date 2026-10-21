import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/recurring_rules_table.dart';
import 'package:dailytrack/features/expense/data/tables/transactions_table.dart';
import 'package:drift/drift.dart';

part 'recurring_rules_dao.g.dart';

/// One rule with its display references (EXP-10).
typedef RuleJoinRow = ({
  RecurringRuleRow rule,
  AccountRow account,
  AccountRow? toAccount,
  CategoryRow? category,
});

/// Recurring rules queries (research R9). Every query excludes soft-deleted
/// rules unless its name says otherwise.
@DriftAccessor(tables: [RecurringRules, Accounts, Categories, Transactions])
class RecurringRulesDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringRulesDaoMixin {
  new(super.attachedDatabase);

  late final $AccountsTable _toAccounts = alias(accounts, 'to_account');

  /// Live rules: active first by next run, then paused or ended.
  Stream<List<RuleJoinRow>> watchAll() {
    final r = recurringRules;
    final q =
        select(r).join([
            innerJoin(accounts, accounts.id.equalsExp(r.accountId)),
            leftOuterJoin(_toAccounts, _toAccounts.id.equalsExp(r.toAccountId)),
            leftOuterJoin(categories, categories.id.equalsExp(r.categoryId)),
          ])
          ..where(r.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.desc(r.isActive),
            OrderingTerm.asc(r.nextRunAt),
            OrderingTerm.asc(r.createdAt),
          ]);
    return q.watch().map(
      (rows) => [
        for (final row in rows)
          (
            rule: row.readTable(r),
            account: row.readTable(accounts),
            toAccount: row.readTableOrNull(_toAccounts),
            category: row.readTableOrNull(categories),
          ),
      ],
    );
  }

  /// The rule, deleted or not.
  Future<RecurringRuleRow?> rawById(String id) =>
      (select(recurringRules)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<RecurringRuleRow?> liveById(String id) => (select(
    recurringRules,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();

  Future<List<String>> dueIds(int nowMs) async {
    final r = recurringRules;
    final q = selectOnly(r)
      ..addColumns([r.id])
      ..where(
        r.deletedAt.isNull() &
            r.isActive.equals(true) &
            r.nextRunAt.isSmallerOrEqualValue(nowMs),
      )
      ..orderBy([OrderingTerm.asc(r.nextRunAt)]);
    return [for (final row in await q.get()) row.read(r.id)!];
  }

  Future<void> insertRule(RecurringRulesCompanion row) =>
      into(recurringRules).insert(row);

  Future<int> updateLive(String id, RecurringRulesCompanion row) => (update(
    recurringRules,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).write(row);

  /// Writes [row] to the rule, deleted or not (restore a snapshot).
  Future<int> updateAny(String id, RecurringRulesCompanion row) =>
      (update(recurringRules)..where((r) => r.id.equals(id))).write(row);

  /// Compare-and-set advance (research R9): changes the rule only if its
  /// next run is still [expectedNextRunAt]. Returns the rows changed.
  Future<int> advance(
    String id, {
    required int expectedNextRunAt,
    required int nextRunAt,
    required bool isActive,
    required int now,
  }) =>
      (update(recurringRules)..where(
            (r) =>
                r.id.equals(id) &
                r.deletedAt.isNull() &
                r.nextRunAt.equals(expectedNextRunAt),
          ))
          .write(
            RecurringRulesCompanion(
              nextRunAt: Value(nextRunAt),
              isActive: Value(isActive),
              updatedAt: Value(now),
            ),
          );

  /// Soft-deletes every live transaction linked to [ruleId], except
  /// [keepId].
  Future<int> deleteLinked(String ruleId, int now, {String? keepId}) {
    final t = transactions;
    var where = t.recurringRuleId.equals(ruleId) & t.deletedAt.isNull();
    if (keepId != null) where &= t.id.equals(keepId).not();
    return (update(t)..where((_) => where)).write(
      TransactionsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}
