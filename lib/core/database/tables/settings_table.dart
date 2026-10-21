// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart.
import 'package:drift/drift.dart';

/// Key-value settings store (data-model.md §1). Rows are overwritten, never
/// soft-deleted.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();

  /// JSON-encoded value.
  TextColumn get value => text()();

  /// UTC epoch milliseconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
