import 'dart:typed_data';

/// Saving and picking backup files through the system picker (SET-02 Local
/// backup card, FR-013). Implemented in `data/` with `file_picker`.
abstract interface class LocalBackupFiles {
  /// Lets the user choose where to save [bytes]. False when cancelled.
  Future<bool> saveAs(Uint8List bytes, {required String suggestedName});

  /// Lets the user pick a backup file and returns its bytes, or null when
  /// cancelled.
  Future<Uint8List?> pick();
}

/// The backup encryption password, kept only in secure storage
/// (feature 008 research R4, key `backup.password`).
abstract interface class BackupPasswordStore {
  Future<String?> read();
  Future<void> write(String password);
  Future<void> delete();
}

/// One module's part of a restore summary.
final class ModuleSummary {
  const new({required this.moduleId, required this.counts});

  final String moduleId;

  /// Row counts by kind, e.g. `{'transactions': 1240}`.
  final Map<String, int> counts;
}

/// What a backup holds, shown before "Replace current data?" (FR-007).
final class RestorePreview {
  const new({
    required this.createdAt,
    required this.appVersion,
    required this.modules,
    required this.skippedModuleIds,
    required this.receiptCount,
    required this.encrypted,
  });

  /// UTC epoch milliseconds.
  final int createdAt;
  final String appVersion;
  final List<ModuleSummary> modules;
  final List<String> skippedModuleIds;
  final int receiptCount;
  final bool encrypted;
}
