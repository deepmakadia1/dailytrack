import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';

/// The oldest `schemaVersion` a backup can have. Every Drift schema since
/// the first is restorable: later versions only added tables, so each
/// module upgrades its section with JSON steps (feature 008 research R7).
const int minRestorableSchema = 1;

/// The part of a module's backup section the migrator needs. Pure Dart, so
/// the migrator stays testable without a database.
abstract interface class SectionUpgrader {
  /// Key under `modules`.
  String get moduleId;

  /// First `schemaVersion` whose backups have this section. Older backups
  /// get an empty section.
  int get sinceSchemaVersion;

  /// Upgrades [section] written at schema [from] to the current schema.
  /// Called only when `from < current`.
  Map<String, Object?> upgrade(
    Map<String, Object?> section, {
    required int from,
  });
}

/// What the migrator did to a document.
final class MigratedDocument {
  const new(this.document, {required this.skippedModuleIds});

  /// At the current schema, with one section per known module.
  final BackupDocument document;

  /// Sections for modules this app does not know; they are not restored.
  final List<String> skippedModuleIds;
}

/// Brings a backup from any supported schema to the current one (FR-006).
final class BackupMigrator {
  const new(this.sections, {required this.current});

  final List<SectionUpgrader> sections;
  final int current;

  MigratedDocument upgrade(BackupDocument doc) {
    final from = doc.schemaVersion;
    if (from > current) throw BackupTooNew(from);
    if (from < minRestorableSchema) {
      throw BackupInvalid('schemaVersion $from is not supported');
    }
    final known = {for (final s in sections) s.moduleId};
    final skipped = [
      for (final id in doc.modules.keys)
        if (!known.contains(id)) id,
    ];
    final upgraded = <String, Map<String, Object?>>{};
    for (final s in sections) {
      final section = doc.modules[s.moduleId];
      if (section == null) {
        upgraded[s.moduleId] = const {'tables': <String, Object?>{}};
      } else if (from < current) {
        upgraded[s.moduleId] = s.upgrade(section, from: from);
      } else {
        upgraded[s.moduleId] = section;
      }
    }
    return MigratedDocument(
      doc.copyWith(schemaVersion: current, modules: upgraded),
      skippedModuleIds: skipped,
    );
  }
}
