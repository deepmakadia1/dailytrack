// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart.
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:drift/drift.dart';

/// Gated features the user has unlocked (spec §4, data-model.md §3.3).
/// Added in schema v3. Read only through the core `FeatureGate`.
@DataClassName('UnlockRow')
@TableIndex(name: 'unlocks_feature', columns: {#featureKey})
class Unlocks extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// `FeatureKey.storageKey`, e.g. `advancedReports` or
  /// `premiumTheme_saffron` (research R13).
  TextColumn get featureKey => text()();

  /// UTC epoch milliseconds. NULL = permanent.
  IntColumn get expiresAt => integer().nullable()();

  IntColumn get source => intEnum<UnlockSource>()();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete; `revoke` sets it (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
