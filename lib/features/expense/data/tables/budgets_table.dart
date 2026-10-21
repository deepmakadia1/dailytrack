// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/expense/data/budgets_recurring_tables_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:drift/drift.dart';

/// Monthly spending limits (spec §4, data-model.md §3.2). Added in schema
/// v3. One live budget per category, and one Overall budget, per month
/// (research R4).
@DataClassName('BudgetRow')
@TableIndex(name: 'budgets_month', columns: {#monthKey})
@TableIndex.sql(
  'CREATE UNIQUE INDEX budgets_month_category_unique ON budgets '
  "(month_key, IFNULL(category_id, '')) WHERE deleted_at IS NULL",
)
class Budgets extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// NULL = Overall.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// Local month `yyyy-MM` (format CHECK in [customConstraints]).
  TextColumn get monthKey => text()();

  /// Minor units (paise), ₹0.01 … ₹99,99,99,999.00.
  IntColumn get limitMinor =>
      integer().check(limitMinor.isBetweenValues(1, 99999999900))();

  /// "Repeat every month" (research R7).
  BoolColumn get rollover => boolean()();

  /// UTC ms the 80% alert was sent.
  IntColumn get alert80SentAt => integer().nullable()();

  /// UTC ms the 100% alert was sent. Never set without the 80% marker.
  IntColumn get alert100SentAt => integer().nullable().check(
    alert100SentAt.isNull() | alert80SentAt.isNotNull(),
  )();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (month_key GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]')",
  ];
}
