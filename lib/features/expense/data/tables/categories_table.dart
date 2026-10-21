// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';

/// Expense and income categories (spec §4, data-model.md §2).
@DataClassName('CategoryRow')
@TableIndex(name: 'categories_type_sort', columns: {#type, #sortOrder})
class Categories extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// l10n key when [isDefault] (e.g. `expense_cat_food`), else user text.
  TextColumn get name => text()
      .withLength(min: 1, max: 40)
      .check(name.length.isBetweenValues(1, 40))();

  IntColumn get type => intEnum<CategoryType>()();
  TextColumn get iconKey => text()();

  /// `#RRGGBB` from the fixed 16-color palette.
  TextColumn get colorHex =>
      text().withLength(min: 7, max: 7).check(colorHex.like('#%'))();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
