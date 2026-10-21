import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/transactions_table.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

part 'accounts_dao.g.dart';

/// An account row with its derived balance and transaction count.
typedef AccountBalanceRow = ({AccountRow row, int balance, int txCount});

/// Accounts queries (data-model.md §3.3). Soft-deleted rows are excluded.
@DriftAccessor(tables: [Accounts, Transactions])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  new(super.attachedDatabase);

  /// balance = opening + income − expense − transfers out + transfers in,
  /// over non-deleted transactions; never stored (FR-009).
  static final String _balanceSql =
      '''
SELECT a.*,
  COALESCE(SUM(CASE
    WHEN t.account_id = a.id AND t.type = ${TxnType.income.index}
      THEN t.amount_minor
    WHEN t.account_id = a.id
      AND t.type IN (${TxnType.expense.index}, ${TxnType.transfer.index})
      THEN -t.amount_minor
    WHEN t.to_account_id = a.id AND t.type = ${TxnType.transfer.index}
      THEN t.amount_minor
    ELSE 0 END), 0) AS delta,
  COUNT(t.id) AS tx_count
FROM accounts a
LEFT JOIN transactions t
  ON (t.account_id = a.id OR t.to_account_id = a.id) AND t.deleted_at IS NULL
WHERE a.deleted_at IS NULL
GROUP BY a.id
ORDER BY a.sort_order, a.created_at''';

  Stream<List<AccountBalanceRow>> watchWithBalances() =>
      customSelect(
        _balanceSql,
        readsFrom: {accounts, transactions},
      ).watch().map(
        (rows) => [
          for (final r in rows)
            () {
              final row = accounts.map(r.data);
              return (
                row: row,
                balance: row.openingBalanceMinor + r.read<int>('delta'),
                txCount: r.read<int>('tx_count'),
              );
            }(),
        ],
      );

  Stream<List<AccountRow>> watchPickable() =>
      (select(accounts)
            ..where((a) => a.deletedAt.isNull() & a.isArchived.equals(false))
            ..orderBy([
              (a) => OrderingTerm.asc(a.sortOrder),
              (a) => OrderingTerm.asc(a.createdAt),
            ]))
          .watch();

  /// The row, deleted or not.
  Future<AccountRow?> byId(String id) =>
      (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Non-deleted, non-archived accounts other than [exceptId].
  Future<int> countActive({String? exceptId}) async {
    final rowCount = accounts.id.count();
    var where = accounts.deletedAt.isNull() & accounts.isArchived.equals(false);
    if (exceptId != null) where &= accounts.id.equals(exceptId).not();
    final q = selectOnly(accounts)
      ..addColumns([rowCount])
      ..where(where);
    final n = (await q.getSingle()).read(rowCount);
    return n ?? 0;
  }

  /// Non-deleted transactions using [id] as source or destination.
  Future<int> transactionCount(String id) async {
    final t = transactions;
    final rowCount = t.id.count();
    final q = selectOnly(t)
      ..addColumns([rowCount])
      ..where(
        (t.accountId.equals(id) | t.toAccountId.equals(id)) &
            t.deletedAt.isNull(),
      );
    final n = (await q.getSingle()).read(rowCount);
    return n ?? 0;
  }

  Future<int> nextSortOrder() async {
    final max = accounts.sortOrder.max();
    final q = selectOnly(accounts)..addColumns([max]);
    final current = (await q.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<void> insertRow(AccountsCompanion row) => into(accounts).insert(row);

  Future<int> updateRow(String id, AccountsCompanion row) =>
      (update(accounts)..where((a) => a.id.equals(id))).write(row);
}
