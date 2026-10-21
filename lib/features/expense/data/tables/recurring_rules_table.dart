// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/expense/data/budgets_recurring_tables_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/type_shape_check.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

/// Templates that create transactions on a schedule (spec §4,
/// data-model.md §3.1). Added in schema v3.
@DataClassName('RecurringRuleRow')
@TableIndex(name: 'recurring_rules_due', columns: {#isActive, #nextRunAt})
class RecurringRules extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  IntColumn get templateType => intEnum<TxnType>()();

  /// Minor units (paise), always positive like `transactions.amount_minor`.
  IntColumn get amountMinor =>
      integer().check(amountMinor.isBetweenValues(1, 99999999900))();

  TextColumn get accountId => text().references(Accounts, #id)();

  /// Transfer only.
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();

  /// Null for transfers.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  IntColumn get paymentMode => intEnum<PaymentMode>()();

  TextColumn get note => text().nullable().check(
    note.isNull() | note.length.isSmallerOrEqualValue(200),
  )();

  IntColumn get frequency => intEnum<Frequency>()();

  /// Every N periods. Always 1 from the UI (spec Assumptions).
  IntColumn get interval => integer()
      .withDefault(const Constant(1))
      .check(interval.isBiggerOrEqualValue(1))();

  /// UTC ms of the first occurrence. Keeps the original day of month after
  /// a clamped month (research R8).
  IntColumn get anchorAt => integer()();

  /// UTC ms of the next occurrence. Only moves forward (research R9).
  IntColumn get nextRunAt => integer()();

  /// UTC ms, inclusive. Null = no end.
  IntColumn get endAt => integer().nullable().check(
    endAt.isNull() | endAt.isBiggerOrEqual(anchorAt),
  )();

  /// False when paused or ended.
  BoolColumn get isActive => boolean()();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [recurringRulesTypeShapeCheck];
}
