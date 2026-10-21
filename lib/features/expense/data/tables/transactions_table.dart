// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/expense/data/transactions_table_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/recurring_rules_table.dart';
import 'package:dailytrack/features/expense/data/tables/type_shape_check.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

/// Money movements (spec §4, data-model.md §3.1). Added in schema v2.
@DataClassName('TransactionRow')
@TableIndex(name: 'transactions_occurred', columns: {#occurredAt})
@TableIndex(
  name: 'transactions_category_occurred',
  columns: {#categoryId, #occurredAt},
)
@TableIndex(
  name: 'transactions_account_occurred',
  columns: {#accountId, #occurredAt},
)
@TableIndex(name: 'transactions_rule', columns: {#recurringRuleId})
class Transactions extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  IntColumn get type => intEnum<TxnType>()();

  /// Minor units (paise), ₹0.01 … ₹99,99,99,999.00. Always positive; the
  /// sign comes from [type].
  IntColumn get amountMinor =>
      integer().check(amountMinor.isBetweenValues(1, 99999999900))();

  /// Source account.
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Transfer only.
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();

  /// Null for transfers.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  IntColumn get paymentMode => intEnum<PaymentMode>()();

  /// Max 200 chars; blank input is stored as NULL.
  TextColumn get note => text().nullable().check(
    note.isNull() | note.length.isSmallerOrEqualValue(200),
  )();

  /// UTC epoch milliseconds, chosen by the user.
  IntColumn get occurredAt => integer()();

  /// Relative path `receipts/<uuid>.jpg`.
  TextColumn get receiptPath => text().nullable()();

  /// The rule this entry came from, or is the first occurrence of. Set by
  /// T1.6; the foreign key was added in schema v3 (feature 003 research R3).
  TextColumn get recurringRuleId =>
      text().nullable().references(RecurringRules, #id)();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// Shape of each type (research R3).
  @override
  List<String> get customConstraints => const [transactionsTypeShapeCheck];
}
