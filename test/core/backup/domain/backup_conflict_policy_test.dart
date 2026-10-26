import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// The conflict check before a backup to Drive (spec §16 "Conflict rule:
/// last backup wins", FR-038 – FR-040, FR-038a, FR-043, research R9, R10).
/// Pure.
void main() {
  const thisPhone = 'this-phone';
  const lastKnownAt = 1792540800000;

  BackupMeta backup({
    String deviceId = 'other-phone',
    int createdAt = lastKnownAt + 60000,
    Map<String, int> counts = const {'expense.transactions': 12},
  }) => BackupMeta(
    deviceId: deviceId,
    deviceName: 'Redmi Note 12',
    appVersion: '1.0.0+7',
    createdAt: createdAt,
    kind: BackupKind.auto,
    counts: counts,
    schemaVersion: 5,
    encrypted: false,
  );

  ConflictCheck check(
    BackupMeta? newest, {
    int? lastKnown = lastKnownAt,
    bool phoneHasData = true,
  }) => BackupConflictPolicy.check(
    newest: newest,
    thisDeviceId: thisPhone,
    lastKnownAt: lastKnown,
    phoneHasData: phoneHasData,
  );

  test('§16 a newer backup from another phone is a conflict', () {
    final newest = backup();
    expect(
      check(newest),
      isA<NewerFromOtherDevice>().having((c) => c.newest, 'newest', newest),
    );
  });

  test('§16 an older backup from another phone is not', () {
    expect(check(backup(createdAt: lastKnownAt - 1)), isA<NoConflict>());
    // The one this phone already knows about.
    expect(check(backup(createdAt: lastKnownAt)), isA<NoConflict>());
  });

  test('§16 a backup from this phone never warns, however new', () {
    expect(
      check(backup(deviceId: thisPhone, createdAt: lastKnownAt * 2)),
      isA<NoConflict>(),
    );
  });

  test('§16 with no known backup, any backup from another phone is newer', () {
    expect(
      check(backup(createdAt: 1), lastKnown: null),
      isA<NewerFromOtherDevice>(),
    );
  });

  test('FR-043 a backup without metadata, or an empty account, is no '
      'conflict', () {
    expect(check(null), isA<NoConflict>());
    expect(check(null, phoneHasData: false), isA<NoConflict>());
  });

  test('FR-038a an empty phone over a backup with data is flagged, even '
      'from this phone', () {
    final mine = backup(deviceId: thisPhone);
    expect(
      check(mine, phoneHasData: false),
      isA<EmptyOverData>().having((c) => c.newest, 'newest', mine),
    );
    expect(
      check(backup(createdAt: lastKnownAt - 1), phoneHasData: false),
      isA<EmptyOverData>(),
    );
  });

  test('FR-038a an empty phone over an empty backup is no conflict', () {
    expect(
      check(backup(deviceId: thisPhone, counts: const {}), phoneHasData: false),
      isA<NoConflict>(),
    );
    expect(
      check(
        backup(
          deviceId: thisPhone,
          counts: const {'expense.transactions': 0, 'habit.habits': 0},
        ),
        phoneHasData: false,
      ),
      isA<NoConflict>(),
    );
  });

  test('an empty phone under a newer backup from another phone gets the '
      'conflict, so auto backup pauses and points at that backup', () {
    expect(check(backup(), phoneHasData: false), isA<NewerFromOtherDevice>());
  });
}
