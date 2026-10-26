import 'package:dailytrack/core/backup/domain/backup_meta.dart';

/// What the conflict check found before a backup to Drive (spec §16
/// "Conflict rule", research R9, R10). Pure.
sealed class ConflictCheck {
  const new();
}

final class NoConflict extends ConflictCheck {
  const new();
}

/// Another phone backed up data this phone has never seen (FR-038).
final class NewerFromOtherDevice extends ConflictCheck {
  const new(this.newest);

  final BackupMeta newest;
}

/// This phone has no user data, and the newest backup has some (FR-038a).
final class EmptyOverData extends ConflictCheck {
  const new(this.newest);

  final BackupMeta newest;
}

abstract final class BackupConflictPolicy {
  /// [newest] is the newest backup's metadata (null for an empty account or
  /// a backup made before feature 010, FR-043). [lastKnownAt] is
  /// `lastKnownDriveBackupAt`. A newer backup from another phone is checked
  /// first, so an erased phone is pointed at that phone's data.
  static ConflictCheck check({
    required BackupMeta? newest,
    required String thisDeviceId,
    required int? lastKnownAt,
    required bool phoneHasData,
  }) {
    if (newest == null) return const NoConflict();
    if (newest.deviceId != thisDeviceId &&
        newest.createdAt > (lastKnownAt ?? 0)) {
      return NewerFromOtherDevice(newest);
    }
    if (!phoneHasData && newest.totalCount > 0) return EmptyOverData(newest);
    return const NoConflict();
  }
}
