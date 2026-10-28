import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The settings keys added by feature 010 (T007, data-model §1, spec §4).
/// Real Drift.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
  });
  tearDown(() => db.close());

  const keys = [
    SettingsCodec.accountDisplayName,
    SettingsCodec.accountPhotoUrl,
    SettingsCodec.deviceId,
    SettingsCodec.dataChangeCounter,
    SettingsCodec.backedUpChangeCounter,
    SettingsCodec.lastBackgroundBackupAt,
    SettingsCodec.lastKnownDriveBackupAt,
    SettingsCodec.lastKnownDriveBackupDeviceId,
    SettingsCodec.autoBackupPausedByConflict,
    SettingsCodec.autoBackupPauseNotified,
    SettingsCodec.finishSetupPending,
  ];

  test(
    '§4 defaults: no account, no device ID copy, both counters at 0',
    () async {
      final s = await repo.load();
      expect(s.backupAccountEmail, isNull);
      expect(s.accountDisplayName, isNull);
      expect(s.accountPhotoUrl, isNull);
      expect(s.deviceId, isNull);
      expect(s.dataChangeCounter, 0);
      expect(s.backedUpChangeCounter, 0);
      expect(s.lastBackgroundBackupAt, isNull);
      expect(s.lastKnownDriveBackupAt, isNull);
      expect(s.lastKnownDriveBackupDeviceId, isNull);
      expect(s.autoBackupPausedByConflict, isFalse);
      expect(s.autoBackupPauseNotified, isFalse);
      expect(s.finishSetupPending, isFalse);
    },
  );

  test('§4 each new key round-trips through the repository', () async {
    await repo.setAccount(
      const AccountProfile(
        email: 'user@gmail.com',
        displayName: 'Asha',
        photoUrl: 'https://example.com/a.png',
      ),
    );
    await repo.setDeviceIdCopy('6f1c2c8e');
    await repo.setBackedUpChangeCounter(7);
    await repo.setLastBackgroundBackupAt(1792540800000);
    await repo.setLastKnownDriveBackup(at: 1792540900000, deviceId: 'other');
    await repo.setAutoBackupPause(paused: true, notified: true);
    await repo.setFinishSetupPending(pending: true);

    final s = await SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    ).load();
    expect(s.backupAccountEmail, 'user@gmail.com');
    expect(s.accountDisplayName, 'Asha');
    expect(s.accountPhotoUrl, 'https://example.com/a.png');
    expect(s.deviceId, '6f1c2c8e');
    expect(s.backedUpChangeCounter, 7);
    expect(s.lastBackgroundBackupAt, 1792540800000);
    expect(s.lastKnownDriveBackupAt, 1792540900000);
    expect(s.lastKnownDriveBackupDeviceId, 'other');
    expect(s.autoBackupPausedByConflict, isTrue);
    expect(s.autoBackupPauseNotified, isTrue);
    expect(s.finishSetupPending, isTrue);
  });

  test(
    '§4 dataChangeCounter is read as written by the SQLite triggers',
    () async {
      await repo.setLocale('hi');
      expect((await repo.load()).dataChangeCounter, greaterThan(0));
    },
  );

  test('§4 none of the new keys is restorable, so no backup carries them', () {
    for (final key in keys) {
      expect(
        BackupSettingsPolicy.restorableKeys,
        isNot(contains(key)),
        reason: key,
      );
    }
  });

  test('§16 setAccount(null) clears email, name, and photo together', () async {
    await repo.setAccount(
      const AccountProfile(
        email: 'user@gmail.com',
        displayName: 'Asha',
        photoUrl: 'https://example.com/a.png',
      ),
    );
    await repo.setAccount(null);
    final s = await repo.load();
    expect(s.backupAccountEmail, isNull);
    expect(s.accountDisplayName, isNull);
    expect(s.accountPhotoUrl, isNull);
  });
}
