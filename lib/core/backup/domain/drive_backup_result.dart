import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';

/// How a backup to Drive treats the conflict check (spec §16 "Conflict
/// rule", research R9).
enum ConflictMode {
  /// Manual: return [NeedsConfirmation] and upload nothing.
  ask,

  /// Manual, after "Back up anyway": no check.
  overwrite,

  /// Auto: pause on a newer backup from another phone; skip quietly over
  /// a backup with data when this phone has none.
  pause,
}

/// How a backup to Drive ended (feature 010 data-model §8). Failures are
/// thrown as `BackupFailure`.
sealed class DriveBackupResult {
  const new();
}

final class Uploaded extends DriveBackupResult {
  const new({required this.meta, required this.sizeBytes});

  final BackupMeta meta;
  final int sizeBytes;
}

/// Auto only: nothing changed since the last backup (FR-033).
final class Unchanged extends DriveBackupResult {
  const new();
}

/// Manual with [ConflictMode.ask]: [conflict] is [NewerFromOtherDevice] or
/// [EmptyOverData]. Nothing was uploaded.
final class NeedsConfirmation extends DriveBackupResult {
  const new(this.conflict);

  final ConflictCheck conflict;
}

/// Auto: another phone made a newer backup; auto backup is paused
/// (FR-038).
final class PausedByConflict extends DriveBackupResult {
  const new(this.newest);

  final BackupMeta newest;
}

/// Auto: this phone has no data and the newest backup has some (FR-038a).
/// Not a failure and not a pause.
final class SkippedEmpty extends DriveBackupResult {
  const new();
}
