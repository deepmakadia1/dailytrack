import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/expense/data/backup/account_codec.dart';
import 'package:dailytrack/features/expense/data/backup/budget_codec.dart';
import 'package:dailytrack/features/expense/data/backup/category_codec.dart';
import 'package:dailytrack/features/expense/data/backup/recurring_rule_codec.dart';
import 'package:dailytrack/features/expense/data/backup/transaction_codec.dart';

/// The Expense module's backup section (SET-02, feature 008 research R5):
/// accounts, categories, transactions, budgets, and recurring rules,
/// soft-deleted rows included.
final class ExpenseBackupSection extends BackupSection {
  const new();

  @override
  String get moduleId => 'expense';

  /// accounts and categories exist since v1; the section upgrades from there.
  @override
  int get sinceSchemaVersion => 1;

  @override
  Future<Map<String, Object?>> export(AppDatabase db) async => {
    'tables': {
      AccountCodec.table: [
        for (final r in await db.select(db.accounts).get())
          AccountCodec.encode(r),
      ],
      CategoryCodec.table: [
        for (final r in await db.select(db.categories).get())
          CategoryCodec.encode(r),
      ],
      TransactionCodec.table: [
        for (final r in await db.select(db.transactions).get())
          TransactionCodec.encode(r),
      ],
      BudgetCodec.table: [
        for (final r in await db.select(db.budgets).get())
          BudgetCodec.encode(r),
      ],
      RecurringRuleCodec.table: [
        for (final r in await db.select(db.recurringRules).get())
          RecurringRuleCodec.encode(r),
      ],
    },
  };

  /// Older schemas only lacked tables (v1: no transactions; v2: no budgets
  /// or recurring rules), which read as empty. A v2 transaction could carry
  /// a `recurringRuleId` before rules existed; with no rules to point at,
  /// it is cleared, as the v2→v3 database migration's foreign key requires.
  @override
  Map<String, Object?> upgrade(
    Map<String, Object?> section, {
    required int from,
  }) {
    if (from >= 3) return section;
    final transactions = [
      for (final row in tableRows(section, TransactionCodec.table))
        if (row is Map<String, Object?>)
          {...row, 'recurringRuleId': null}
        else
          row,
    ];
    return {
      ...section,
      'tables': {..._tables(section), TransactionCodec.table: transactions},
    };
  }

  static Map<String, Object?> _tables(Map<String, Object?> section) =>
      (section['tables'] as Map<String, Object?>?) ?? const {};

  static List<T> _decode<T>(
    Map<String, Object?> section,
    String table,
    T Function(BackupFields) decode,
  ) {
    final rows = tableRows(section, table);
    return [
      for (var i = 0; i < rows.length; i++)
        decode(BackupFields.of(rows[i], table: table, index: i)),
    ];
  }

  ({
    List<AccountRow> accounts,
    List<CategoryRow> categories,
    List<TransactionRow> transactions,
    List<BudgetRow> budgets,
    List<RecurringRuleRow> rules,
  })
  _read(Map<String, Object?> section) => (
    accounts: _decode(section, AccountCodec.table, AccountCodec.decode),
    categories: _decode(section, CategoryCodec.table, CategoryCodec.decode),
    transactions: _decode(
      section,
      TransactionCodec.table,
      TransactionCodec.decode,
    ),
    budgets: _decode(section, BudgetCodec.table, BudgetCodec.decode),
    rules: _decode(
      section,
      RecurringRuleCodec.table,
      RecurringRuleCodec.decode,
    ),
  );

  @override
  void validate(Map<String, Object?> section) {
    final d = _read(section);
    checkUnique(AccountCodec.table, 'id', d.accounts.map((r) => r.id));
    checkUnique(CategoryCodec.table, 'id', d.categories.map((r) => r.id));
    checkUnique(TransactionCodec.table, 'id', d.transactions.map((r) => r.id));
    checkUnique(BudgetCodec.table, 'id', d.budgets.map((r) => r.id));
    checkUnique(RecurringRuleCodec.table, 'id', d.rules.map((r) => r.id));
    // One budget per category, and one Overall, per month among live rows.
    checkUnique(BudgetCodec.table, 'month and category', [
      for (final b in d.budgets)
        if (b.deletedAt == null) '${b.monthKey}|${b.categoryId ?? ''}',
    ]);

    final accounts = {for (final r in d.accounts) r.id};
    final categories = {for (final r in d.categories) r.id};
    final rules = {for (final r in d.rules) r.id};
    for (final (i, t) in d.transactions.indexed) {
      const table = TransactionCodec.table;
      checkReference(table, i, 'accountId', t.accountId, accounts);
      checkReference(table, i, 'toAccountId', t.toAccountId, accounts);
      checkReference(table, i, 'categoryId', t.categoryId, categories);
      checkReference(table, i, 'recurringRuleId', t.recurringRuleId, rules);
    }
    for (final (i, r) in d.rules.indexed) {
      const table = RecurringRuleCodec.table;
      checkReference(table, i, 'accountId', r.accountId, accounts);
      checkReference(table, i, 'toAccountId', r.toAccountId, accounts);
      checkReference(table, i, 'categoryId', r.categoryId, categories);
    }
    for (final (i, b) in d.budgets.indexed) {
      checkReference(
        BudgetCodec.table,
        i,
        'categoryId',
        b.categoryId,
        categories,
      );
    }
  }

  @override
  Future<void> restore(AppDatabase db, Map<String, Object?> section) async {
    final d = _read(section);
    // Children first, though foreign keys are deferred by the engine.
    await db.delete(db.transactions).go();
    await db.delete(db.budgets).go();
    await db.delete(db.recurringRules).go();
    await db.delete(db.categories).go();
    await db.delete(db.accounts).go();
    await db.batch((b) {
      b
        ..insertAll(db.accounts, d.accounts)
        ..insertAll(db.categories, d.categories)
        ..insertAll(db.recurringRules, d.rules)
        ..insertAll(db.transactions, d.transactions)
        ..insertAll(db.budgets, d.budgets);
    });
  }

  @override
  Map<String, int> counts(Map<String, Object?> section) {
    int live(String table) => tableRows(
      section,
      table,
    ).where((r) => r is Map<String, Object?> && r['deletedAt'] == null).length;
    return {
      'transactions': live(TransactionCodec.table),
      'accounts': live(AccountCodec.table),
      'categories': live(CategoryCodec.table),
      'budgets': live(BudgetCodec.table),
      'recurringRules': live(RecurringRuleCodec.table),
    };
  }

  @override
  String summary(AppLocalizations l10n, Map<String, int> counts) =>
      l10n.backup_countTransactions(counts['transactions'] ?? 0);

  @override
  Iterable<String> attachments(Map<String, Object?> section) => {
    for (final row in tableRows(section, TransactionCodec.table))
      if (row is Map<String, Object?> && row['receiptPath'] is String)
        row['receiptPath']! as String,
  };

  @override
  Map<String, Object?> withoutAttachments(Map<String, Object?> section) => {
    ...section,
    'tables': {
      ..._tables(section),
      TransactionCodec.table: [
        for (final row in tableRows(section, TransactionCodec.table))
          if (row is Map<String, Object?>)
            {...row, 'receiptPath': null}
          else
            row,
      ],
    },
  };
}
