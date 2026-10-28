import 'package:dailytrack/core/backup/domain/auto_backup_rotation.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Day-based rotation of auto backups (feature 010 T033, SET-02, spec §16
/// "Background backups count as auto backups for SET-02's day-based
/// rotation", FR-035, clarification Q1, research R15). Pure; the test runs
/// in the machine's zone, so days are built from local times.
void main() {
  var next = 0;

  DriveBackupEntry backup(
    DateTime local, {
    BackupKind kind = BackupKind.auto,
  }) => DriveBackupEntry(
    id: 'b${next++}',
    name: 'dailytrack_backup.json',
    createdAt: local.toUtc().millisecondsSinceEpoch,
    sizeBytes: 10,
    kind: kind,
  );

  final now = DateTime(2026, 10, 27, 21, 30);

  Set<String> kept(List<DriveBackupEntry> all) {
    final gone = {
      for (final e in AutoBackupRotation.toDelete(all, nowLocal: now)) e.id,
    };
    return {
      for (final e in all)
        if (!gone.contains(e.id)) e.id,
    };
  }

  setUp(() => next = 0);

  test('SET-02 Q1 4 auto backups today and 2 on each of the 7 earlier days '
      "keep 6: today's newest and the newest of the 5 latest earlier days", () {
    final today = [
      for (final h in [9, 12, 15, 20]) backup(DateTime(2026, 10, 27, h)),
    ];
    final earlier = [
      for (var d = 1; d <= 7; d++) ...[
        backup(DateTime(2026, 10, 27 - d, 8)),
        backup(DateTime(2026, 10, 27 - d, 22)),
      ],
    ];
    final result = kept([...today, ...earlier]);
    expect(result, hasLength(6));
    expect(result, contains(today.last.id));
    for (var d = 1; d <= 5; d++) {
      expect(result, contains(earlier[(d - 1) * 2 + 1].id), reason: 'day -$d');
    }
  });

  test('SET-02 Q1 manual backups are never deleted', () {
    final manual = [
      for (var d = 0; d < 10; d++)
        backup(DateTime(2026, 10, 27 - d, 10), kind: BackupKind.manual),
    ];
    expect(AutoBackupRotation.toDelete(manual, nowLocal: now), isEmpty);
    final mixed = [
      ...manual,
      backup(DateTime(2026, 10, 27, 9)),
      backup(DateTime(2026, 10, 27, 10)),
    ];
    final gone = AutoBackupRotation.toDelete(mixed, nowLocal: now);
    expect(gone.single.id, mixed[10].id);
  });

  test(
    '§16 backups either side of local midnight belong to different days',
    () {
      final lateYesterday = backup(DateTime(2026, 10, 26, 23, 59));
      final earlyToday = backup(DateTime(2026, 10, 27, 0, 1));
      expect(kept([lateYesterday, earlyToday]), {
        lateYesterday.id,
        earlyToday.id,
      });
    },
  );

  test('§16 days with no backup are skipped, so the 5 earlier days are the '
      '5 most recent days that had one', () {
    final days = [3, 6, 9, 12, 15, 18, 21];
    final all = [for (final d in days) backup(DateTime(2026, 10, 27 - d, 10))];
    final result = kept(all);
    expect(result, {for (final e in all.take(5)) e.id});
  });

  test('§16 grouping uses the local calendar day, not the UTC day (in '
      'India 00:15 is still the previous UTC day)', () {
    final sameLocalDay = backup(DateTime(2026, 10, 27, 0, 15));
    final laterSameDay = backup(DateTime(2026, 10, 27, 18));
    expect(kept([sameLocalDay, laterSameDay]), {laterSameDay.id});
  });

  test('a backup dated after today (a wrong clock) is kept as the newest of '
      'its own day', () {
    final future = backup(DateTime(2026, 10, 29, 10));
    final today = backup(DateTime(2026, 10, 27, 10));
    expect(kept([future, today]), {future.id, today.id});
  });

  test('only one backup per kept day survives', () {
    final a = backup(DateTime(2026, 10, 25, 9));
    final b = backup(DateTime(2026, 10, 25, 11));
    final c = backup(DateTime(2026, 10, 25, 10));
    expect(kept([a, b, c]), {b.id});
  });

  test('earlierDays is 5', () {
    expect(AutoBackupRotation.earlierDays, 5);
  });
}
