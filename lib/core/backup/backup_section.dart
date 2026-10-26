import 'package:dailytrack/core/backup/domain/backup_migrator.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';

/// A module's own part of a backup (`TrackerModule.backupSection()`,
/// feature 008 research R5, contracts/services.md). The engine never touches
/// a module's tables; each module reads, checks, and writes its own rows, so
/// a new module joins backup by adding a section.
abstract class BackupSection implements SectionUpgrader {
  const new();

  /// Every row of the module's tables, soft-deleted ones included (FR-002),
  /// as `{'tables': {name: [row, ...]}}`. Called inside the engine's read
  /// transaction, so all modules see one snapshot.
  Future<Map<String, Object?>> export(AppDatabase db);

  /// Checks shapes, ranges, enum names, uniqueness, and in-section
  /// references, mirroring the table CHECKs. Throws `BackupInvalid`. Called
  /// before anything is written.
  void validate(Map<String, Object?> section);

  /// Replaces the module's rows with [section]'s. Runs only inside the
  /// engine's write transaction, with foreign keys deferred.
  Future<void> restore(AppDatabase db, Map<String, Object?> section);

  /// SQL names of the module's tables. Each one needs the change-counter
  /// triggers (feature 010 research R5); a test checks they exist.
  Set<String> get tables;

  /// True when the module holds data the user made, not only its seeded
  /// defaults (feature 010 research R11). Soft-deleted rows don't count.
  Future<bool> hasUserData(AppDatabase db);

  /// Row counts for the restore summary, by kind.
  Map<String, int> counts(Map<String, Object?> section);

  /// Localized summary, e.g. "1,240 transactions".
  String summary(AppLocalizations l10n, Map<String, int> counts);

  /// Files the section refers to, relative to the app documents folder
  /// (e.g. `receipts/<uuid>.jpg`).
  Iterable<String> attachments(Map<String, Object?> section) => const [];

  /// [section] without file references, for a backup without receipts
  /// (FR-003).
  Map<String, Object?> withoutAttachments(Map<String, Object?> section) =>
      section;

  @override
  Map<String, Object?> upgrade(
    Map<String, Object?> section, {
    required int from,
  }) => section;
}
