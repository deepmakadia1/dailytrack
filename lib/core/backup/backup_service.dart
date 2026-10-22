import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/data/backup_engine.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/share/file_sharer.dart';

/// A saved local backup.
final class SavedBackup {
  const new({required this.fileName, required this.sizeBytes});

  final String fileName;
  final int sizeBytes;
}

/// SET-02 backup actions (FR-012, FR-013). Reads the encrypt and receipts
/// options from settings, so callers cannot make an unencrypted backup while
/// encryption is on (research R4).
class BackupService {
  new({
    required this._engine,
    required this._coordinator,
    required this._settings,
    required this._files,
    required this._passwords,
    required this._sharer,
    required this._cacheDir,
    required this._nowUtcMs,
    required this._drive,
  });

  final BackupEngine _engine;
  final BackupCoordinator _coordinator;
  final SettingsRepository _settings;
  final LocalBackupFiles _files;
  final BackupPasswordStore _passwords;
  final FileSharer _sharer;
  final Future<Directory> Function() _cacheDir;
  final int Function() _nowUtcMs;
  final DriveBackupStore _drive;

  File? _lastFile;

  /// The backup file, encrypted when encryption is on. Throws
  /// [BackupNeedsPassword] if the password can't be read; never falls back
  /// to a plain file (research R4).
  Future<BackupFile> _build() async {
    final s = await _settings.load();
    String? password;
    if (s.backupEncrypt) {
      password = await _passwords.read();
      if (password == null || password.isEmpty) {
        throw const BackupNeedsPassword();
      }
    }
    return await _engine.create(
      includeReceipts: s.backupIncludeReceipts,
      password: password,
    );
  }

  /// Any successful backup ends an auto backup failure streak (FR-020).
  Future<void> _recordSuccess(BackupLocation location, int sizeBytes) async {
    await _settings.setLastBackup(
      at: _nowUtcMs(),
      location: location,
      sizeBytes: sizeBytes,
    );
    await _settings.setAutoBackupFailures(failures: 0, notified: false);
  }

  /// Builds a backup and lets the user save it. Null when the user cancels
  /// the save dialog (nothing is recorded). Throws [BackupNeedsPassword] if
  /// encryption is on but the password cannot be read; never falls back to a
  /// plain file.
  Future<SavedBackup?> backupToDevice() => _coordinator.run(() async {
    final file = await _build();
    _lastFile = await _keepForSharing(file.fileName, file.bytes);
    final saved = await _files.saveAs(file.bytes, suggestedName: file.fileName);
    if (!saved) return null;
    await _recordSuccess(BackupLocation.device, file.bytes.length);
    return SavedBackup(fileName: file.fileName, sizeBytes: file.bytes.length);
  });

  /// Uploads a backup to Google Drive (FR-015). After an auto backup only
  /// the 5 newest auto backups are kept; manual ones are never pruned
  /// (FR-017). On failure nothing is recorded.
  Future<SavedBackup> backupToDrive({required BackupKind kind}) =>
      _coordinator.run(() async {
        final file = await _build();
        await _drive.upload(file.bytes, fileName: file.fileName, kind: kind);
        if (kind == BackupKind.auto) {
          await _settings.setLastAutoBackupAt(_nowUtcMs());
          try {
            await _drive.pruneAuto();
          } on BackupFailure {
            // The backup is safe in Drive; the next run prunes again.
          }
        }
        await _recordSuccess(BackupLocation.drive, file.bytes.length);
        return SavedBackup(
          fileName: file.fileName,
          sizeBytes: file.bytes.length,
        );
      });

  /// Sends the last saved file through the share sheet.
  Future<void> shareLastFile() async {
    final file = _lastFile;
    if (file == null || !file.existsSync()) return;
    await _sharer.shareFile(file.path, mimeType: 'application/octet-stream');
  }

  /// One copy in `<cache>/backups/`, replacing older ones.
  Future<File> _keepForSharing(String name, Uint8List bytes) async {
    final dir = Directory('${(await _cacheDir()).path}/backups');
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
      return await File('${dir.path}/$name').writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      throw const BackupStorageFull();
    }
  }
}

/// SET-02 restore actions (FR-005 – FR-010).
class RestoreService {
  new({
    required this._engine,
    required this._coordinator,
    required this._files,
    required this._aftermath,
  });

  final BackupEngine _engine;
  final BackupCoordinator _coordinator;
  final LocalBackupFiles _files;
  final Future<void> Function() _aftermath;

  /// The picked file's bytes, or null when cancelled.
  Future<Uint8List?> pickFile() => _files.pick();

  /// Reads and checks a backup; changes nothing.
  Future<RestoreCandidate> open(Uint8List bytes, {String? password}) =>
      _engine.open(bytes, password: password);

  /// Writes the backup, then reschedules and refreshes (FR-010). The
  /// aftermath is best effort and never fails the restore.
  Future<RestoreOutcome> apply(RestoreCandidate candidate) async {
    final outcome = await _coordinator.run(() => _engine.apply(candidate));
    try {
      await _aftermath();
    } on Object {
      // Rescheduling also runs on the next app open.
    }
    return outcome;
  }
}
