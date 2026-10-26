import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_meta.dart';

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
    this.meta,
  });

  final String id;
  final String name;

  /// UTC epoch milliseconds.
  final int createdAt;
  final int sizeBytes;
  final BackupKind kind;

  /// The device that made it, shown in the list. Backups made before
  /// feature 010 have only this.
  final String? device;

  /// From `appProperties`; null for backups made before feature 010
  /// (FR-043).
  final BackupMeta? meta;
}

/// The user's Google Drive app folder (`appDataFolder`, `drive.appdata`
/// scope only; FR-014, research R10). Signing in is `AccountService`'s job
/// (feature 010 research R1). Every failure is a `BackupFailure`
/// (`DriveAuthRequired`, `DriveQuotaExceeded`, `DriveOffline`,
/// `DriveUnavailable`).
abstract interface class DriveBackupStore {
  /// DailyTrack backups, newest first.
  Future<List<DriveBackupEntry>> list();

  /// Uploads a backup with [meta] as its `appProperties`.
  Future<void> upload(
    Uint8List bytes, {
    required String fileName,
    required BackupMeta meta,
  });

  Future<Uint8List> download(String fileId);

  Future<void> delete(String fileId);

  /// ACC-01 "Delete my backups": every DailyTrack file, manual and auto.
  /// Keeps going past a failed delete, then throws the first failure
  /// (research R16).
  Future<void> deleteAll();
}
