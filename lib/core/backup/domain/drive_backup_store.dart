import 'dart:typed_data';

/// Whether a Drive backup came from "Back up now" or from auto backup
/// (clarification Q1: only auto backups rotate).
enum BackupKind { manual, auto }

/// One backup file in the user's Drive app folder (data-model §5).
final class DriveBackupEntry {
  const new({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
    required this.kind,
    this.device,
  });

  final String id;
  final String name;

  /// UTC epoch milliseconds.
  final int createdAt;
  final int sizeBytes;
  final BackupKind kind;

  /// The device that made it, shown in the list.
  final String? device;
}

/// The user's Google Drive app folder (`appDataFolder`, `drive.appdata`
/// scope only; FR-014, research R10). Every failure is a `BackupFailure`
/// (`DriveAuthRequired`, `DriveQuotaExceeded`, `DriveOffline`,
/// `DriveUnavailable`).
abstract interface class DriveBackupStore {
  /// Interactive sign-in and authorization. Returns the account email.
  Future<String> connect();

  /// Signs out and revokes access. Backups in Drive are kept.
  Future<void> disconnect();

  /// DailyTrack backups, newest first.
  Future<List<DriveBackupEntry>> list();

  Future<void> upload(
    Uint8List bytes, {
    required String fileName,
    required BackupKind kind,
  });

  Future<Uint8List> download(String fileId);

  Future<void> delete(String fileId);

  /// Deletes all but the [keep] newest auto backups; never a manual one
  /// (FR-017).
  Future<void> pruneAuto({int keep = 5});
}
