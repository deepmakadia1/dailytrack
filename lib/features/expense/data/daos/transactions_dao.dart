import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/transactions_table.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

part 'transactions_dao.g.dart';

/// One joined row: the transaction with its accounts and category.
typedef TransactionJoinRow = ({
  TransactionRow transaction,
  AccountRow account,
  AccountRow? toAccount,
  CategoryRow? category,
});

/// Transactions queries (research R4, R5, R7). Every query excludes
/// soft-deleted rows unless its name says otherwise.
@DriftAccessor(tables: [Transactions, Categories, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  new(super.attachedDatabase);

  static const String _escape = r'\';

  late final $AccountsTable _toAccounts = alias(accounts, 'to_account');

  /// Total and stable order, so an undone delete returns to the same index.
  List<OrderingTerm> get _newestFirst => [
    OrderingTerm.desc(transactions.occurredAt),
    OrderingTerm.desc(transactions.createdAt),
    OrderingTerm.desc(transactions.id),
  ];

  JoinedSelectStatement<HasResultSet, dynamic> _joined() => select(transactions)
      .join([
        innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
        leftOuterJoin(
          _toAccounts,
          _toAccounts.id.equalsExp(transactions.toAccountId),
        ),
        leftOuterJoin(
          categories,
          categories.id.equalsExp(transactions.categoryId),
        ),
      ]);

  TransactionJoinRow _read(TypedResult r) => (
    transaction: r.readTable(transactions),
    account: r.readTable(accounts),
    toAccount: r.readTableOrNull(_toAccounts),
    category: r.readTableOrNull(categories),
  );

  /// Rows matching [query], newest first, at most [limit].
  Stream<List<TransactionJoinRow>> watchPage(TxnQuery query, int limit) {
    final q = _joined()
      ..where(_matching(query))
      ..orderBy(_newestFirst)
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_read).toList());
  }

  /// Every row matching [query], oldest first (SET-03 export).
  Future<List<TransactionJoinRow>> listMatching(TxnQuery query) async {
    final q = _joined()
      ..where(_matching(query))
      ..orderBy([
        OrderingTerm.asc(transactions.occurredAt),
        OrderingTerm.asc(transactions.createdAt),
        OrderingTerm.asc(transactions.id),
      ]);
    return (await q.get()).map(_read).toList();
  }

  /// The newest [limit] rows of all time (DSH-01). Uses the
  /// `transactions_occurred` index.
  Stream<List<TransactionJoinRow>> watchRecent(int limit) {
    final q = _joined()
      ..where(transactions.deletedAt.isNull())
      ..orderBy(_newestFirst)
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_read).toList());
  }

  /// The slim `(occurredAt, type, amountMinor)` projection of every row
  /// matching [query], for the ledger fold.
  Stream<List<(int, TxnType, int)>> watchLedgerRows(TxnQuery query) {
    final t = transactions;
    final q = selectOnly(t)
      ..addColumns([t.occurredAt, t.type, t.amountMinor])
      ..where(_matching(query));
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            r.read(t.occurredAt)!,
            r.readWithConverter<TxnType, int>(t.type)!,
            r.read(t.amountMinor)!,
          ),
      ],
    );
  }

  /// Expense sums grouped by `(categoryId, accountId, paymentMode)` for
  /// every row matching [query]: one query, so the three groupings of a
  /// breakdown always come from the same snapshot (feature 003 R11).
  Stream<List<(String?, String, PaymentMode, int)>> watchExpenseGroups(
    TxnQuery query,
  ) {
    final (q, read) = _expenseGroups(query);
    return q.watch().map((rows) => rows.map(read).toList());
  }

  /// One-shot [watchExpenseGroups] (budget spent, alert checks).
  Future<List<(String?, String, PaymentMode, int)>> expenseGroups(
    TxnQuery query,
  ) async {
    final (q, read) = _expenseGroups(query);
    return (await q.get()).map(read).toList();
  }

  (
    JoinedSelectStatement<HasResultSet, dynamic>,
    (String?, String, PaymentMode, int) Function(TypedResult),
  )
  _expenseGroups(TxnQuery query) {
    final t = transactions;
    final total = t.amountMinor.sum();
    final q = selectOnly(t)
      ..addColumns([t.categoryId, t.accountId, t.paymentMode, total])
      ..where(_matching(query) & t.type.equalsValue(TxnType.expense))
      ..groupBy([t.categoryId, t.accountId, t.paymentMode]);
    return (
      q,
      (r) => (
        r.read(t.categoryId),
        r.read(t.accountId)!,
        r.readWithConverter<PaymentMode, int>(t.paymentMode)!,
        r.read(total) ?? 0,
      ),
    );
  }

  Stream<TransactionJoinRow?> watchById(String id) {
    final q = _joined()
      ..where(transactions.id.equals(id) & transactions.deletedAt.isNull());
    return q.watchSingleOrNull().map((r) => r == null ? null : _read(r));
  }

  Future<TransactionJoinRow?> findById(String id) async {
    final q = _joined()
      ..where(transactions.id.equals(id) & transactions.deletedAt.isNull());
    final r = await q.getSingleOrNull();
    return r == null ? null : _read(r);
  }

  /// The raw row, deleted or not.
  Future<TransactionRow?> rawById(String id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Expense sums for `[dayStart, dayEnd)` and `[monthStart, monthEnd)`, and
  /// the count of all non-deleted transactions of any type.
  Stream<({int today, int month, int count})> watchSpend({
    required int dayStart,
    required int dayEnd,
    required int monthStart,
    required int monthEnd,
  }) {
    final t = transactions;
    final isExpense = t.type.equalsValue(TxnType.expense);
    Expression<bool> within(int from, int to) =>
        isExpense &
        t.occurredAt.isBiggerOrEqualValue(from) &
        t.occurredAt.isSmallerThanValue(to);
    final today = t.amountMinor.sum(filter: within(dayStart, dayEnd));
    final month = t.amountMinor.sum(filter: within(monthStart, monthEnd));
    final count = t.id.count();
    final q = selectOnly(t)
      ..addColumns([today, month, count])
      ..where(t.deletedAt.isNull());
    return q.watchSingle().map(
      (r) => (
        today: r.read(today) ?? 0,
        month: r.read(month) ?? 0,
        count: r.read(count) ?? 0,
      ),
    );
  }

  /// Distinct notes, most recently used first.
  Future<List<String>> recentNotes(String prefix, int limit) async {
    final t = transactions;
    final lastUsed = t.createdAt.max();
    var where = t.deletedAt.isNull() & t.note.isNotNull();
    if (prefix.isNotEmpty) {
      where &= t.note.lower().like(
        '${_escapeLike(prefix.toLowerCase())}%',
        escapeChar: _escape,
      );
    }
    final q = selectOnly(t)
      ..addColumns([t.note, lastUsed])
      ..where(where)
      ..groupBy([t.note])
      ..orderBy([OrderingTerm.desc(lastUsed)])
      ..limit(limit);
    return [for (final r in await q.get()) r.read(t.note)!];
  }

  /// Account of the most recently created non-deleted transaction whose
  /// account is neither archived nor deleted.
  Future<String?> lastUsedAccountId() async {
    final q =
        select(transactions).join([
            innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
          ])
          ..where(
            transactions.deletedAt.isNull() &
                accounts.deletedAt.isNull() &
                accounts.isArchived.equals(false),
          )
          ..orderBy([
            OrderingTerm.desc(transactions.createdAt),
            OrderingTerm.desc(transactions.id),
          ])
          ..limit(1);
    final r = await q.getSingleOrNull();
    return r?.readTable(transactions).accountId;
  }

  /// Every receipt path, including soft-deleted rows.
  Future<Set<String>> allReceiptPaths() async {
    final t = transactions;
    final q = selectOnly(t)
      ..addColumns([t.receiptPath])
      ..where(t.receiptPath.isNotNull());
    return {for (final r in await q.get()) r.read(t.receiptPath)!};
  }

  Future<void> insertRow(TransactionsCompanion row) =>
      into(transactions).insert(row);

  /// Updates the non-deleted row [id]; returns the number of rows changed.
  Future<int> updateActive(String id, TransactionsCompanion row) => (update(
    transactions,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(row);

  Future<int> setDeletedAt(String id, int? deletedAt) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(deletedAt: Value(deletedAt)),
      );

  /// The WHERE clause for [query] (FR-020, research R5).
  Expression<bool> _matching(TxnQuery query) {
    final t = transactions;
    var e =
        t.deletedAt.isNull() &
        t.occurredAt.isBiggerOrEqualValue(query.period.startUtcMs) &
        t.occurredAt.isSmallerThanValue(query.period.endUtcMsExclusive);

    if (query.categoryIds.isNotEmpty) {
      e &= t.categoryId.isIn(query.categoryIds);
    }
    if (query.accountIds.isNotEmpty) {
      e &=
          t.accountId.isIn(query.accountIds) |
          t.toAccountId.isIn(query.accountIds);
    }
    if (query.paymentModes.isNotEmpty) {
      e &= t.paymentMode.isInValues(query.paymentModes);
    }
    if (query.types.isNotEmpty) {
      e &= t.type.isInValues(query.types);
    }
    if (query.minAmountMinor case final min?) {
      e &= t.amountMinor.isBiggerOrEqualValue(min);
    }
    if (query.maxAmountMinor case final max?) {
      e &= t.amountMinor.isSmallerOrEqualValue(max);
    }
    if (query.hasSearch) {
      e &= _searchMatches(query.search.trim(), query.matchingCategoryIds);
    }
    return e;
  }

  /// Note substring, OR a category whose localized name matched (resolved by
  /// the caller), OR an amount match: exact, or a prefix of the whole-rupee
  /// digits when [q] has no decimal point (research R5).
  Expression<bool> _searchMatches(String q, Set<String> categoryIds) {
    final t = transactions;
    var e = t.note.like('%${_escapeLike(q)}%', escapeChar: _escape);
    if (categoryIds.isNotEmpty) {
      e |= t.categoryId.isIn(categoryIds);
    }
    final amount = parseSearchAmount(q);
    if (amount != null) {
      e |= t.amountMinor.equals(amount);
      if (!q.contains('.')) {
        // INTEGER / INTEGER is integer division in SQLite: whole rupees.
        e |= (t.amountMinor / const Constant(100)).cast<String>().like('$q%');
      }
    }
    return e;
  }

  static String _escapeLike(String s) => s
      .replaceAll(_escape, '$_escape$_escape')
      .replaceAll('%', '$_escape%')
      .replaceAll('_', '${_escape}_');

  /// A search query as paise, if it is a plain non-negative amount with at
  /// most 2 decimals ("12", "12.5", "12.50"); otherwise null.
  static int? parseSearchAmount(String q) {
    final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(q);
    if (m == null) return null;
    final rupees = int.parse(m.group(1)!);
    final paise = int.parse((m.group(2) ?? '').padRight(2, '0'));
    return rupees * 100 + paise;
  }
}
