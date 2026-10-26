import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/utils/date_keys.dart';

/// Day-based rotation of auto backups (SET-02, FR-035, research R15):
/// today's newest auto backup plus the newest auto backup of each of the
/// [earlierDays] most recent earlier local days that had one. Manual
/// backups are never deleted. Pure.
abstract final class AutoBackupRotation {
  static const int earlierDays = 5;

  /// The auto backups to delete. Days are local calendar days of
  /// `createdAt`. A backup dated after today (a wrong clock) is kept as the
  /// newest of its own day.
  static List<DriveBackupEntry> toDelete(
    List<DriveBackupEntry> entries, {
    required DateTime nowLocal,
  }) {
    final today = DateKeys.fromLocal(nowLocal);
    final byDay = <String, List<DriveBackupEntry>>{};
    for (final e in entries) {
      if (e.kind != BackupKind.auto) continue;
      final day = DateKeys.fromLocal(Epoch.toLocal(e.createdAt));
      (byDay[day] ??= []).add(e);
    }
    final earlier = [
      for (final day in byDay.keys)
        if (day.compareTo(today) < 0) day,
    ]..sort((a, b) => b.compareTo(a));
    final keptDays = {
      for (final day in byDay.keys)
        if (day.compareTo(today) >= 0) day,
      ...earlier.take(earlierDays),
    };
    final remove = <DriveBackupEntry>[];
    for (final MapEntry(key: day, value: list) in byDay.entries) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      remove.addAll(keptDays.contains(day) ? list.skip(1) : list);
    }
    return remove;
  }
}
