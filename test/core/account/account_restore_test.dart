import 'dart:io';

import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/data/backup_engine.dart';
import 'package:dailytrack/core/backup/data/safety_copy_store.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import '../backup/backup_test_support.dart';

/// The account restore (feature 010 T039, T040, T066, T070; ACC-02
/// criteria at the data level, FR-019a, FR-019b, FR-020, FR-041). Real
/// Drift on an in-memory database; Drive is the fake store.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late Directory support;
  late MutableClock clock;
  late SettingsRepositoryImpl settings;
  late FakeDriveBackupStore drive;
  late FakeBackupPasswordStore passwords;
  late BackupEngine engine;
  late Directory safetyRoot;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('acr_docs');
    support = await Directory.systemTemp.createTemp('acr_support');
    safetyRoot = support;
    clock = MutableClock(DateTime(2026, 10, 26, 9));
    await seedRichData(db, docs);
    settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    drive = FakeDriveBackupStore();
    passwords = FakeBackupPasswordStore();
    engine = engineFor(db, clock, docs);
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
    await support.delete(recursive: true);
  });

  AccountRestore subject() {
    final coordinator = BackupCoordinator(db, clock);
    return AccountRestore(
      drive: drive,
      restore: RestoreService(
        engine: engine,
        coordinator: coordinator,
        files: FakeLocalBackupFiles(),
        aftermath: () async {},
      ),
      engine: engine,
      backup: BackupService(
        engine: engine,
        coordinator: coordinator,
        settings: settings,
        files: FakeLocalBackupFiles(),
        passwords: passwords,
        sharer: FakeFileSharer(),
        cacheDir: () async => support,
        nowUtcMs: () => clock.now().toUtc().millisecondsSinceEpoch,
        drive: drive,
        device: () async =>
            const DeviceIdentity(id: 'this-phone', name: 'Pixel 7'),
      ),
      safety: FileSafetyCopyStore(() async => safetyRoot),
      passwords: passwords,
      settings: settings,
      clock: clock,
    );
  }

  /// The phone's data as a Drive backup "from another phone".
  Future<(Uint8List, DriveBackupEntry)> backupOfNow({String? password}) async {
    final file = await engine.create(
      includeReceipts: true,
      password: password,
      device: const DeviceIdentity(id: 'other-phone', name: 'Redmi Note 12'),
    );
    final entry = drive.seed(meta: file.meta);
    drive.contents[entry.id] = file.bytes;
    return (file.bytes, entry);
  }

  Future<void> addHabit() => db.customStatement(
    'INSERT INTO habits (id, name, icon_key, color_hex, kind, target_value, '
    'schedule_type, weekdays_mask, start_date_key, sort_order, created_at, '
    "updated_at) VALUES ('later', 'Read', 'book', '#00897B', 0, 1, 0, 127, "
    "'2026-10-26', 9, 0, 0)",
  );

  test('ACC-02 "Restore from account" replaces all module rows; the data the '
      'phone had is saved first and restores exactly', () async {
    final (bytes, entry) = await backupOfNow();
    final inBackup = await tableChecksums(db);
    await addHabit();
    final onPhone = await tableChecksums(db);
    expect(onPhone, isNot(inBackup));

    final restore = subject();
    final opened = await restore.open(bytes);
    final result = await restore.apply(
      opened,
      entry: entry,
      fromEmptyPhone: false,
    );
    expect(result, isA<Restored>());
    expect(await tableChecksums(db), inBackup);

    // FR-019a: the safety copy holds the phone's earlier data.
    final copy = (await restore.safetyCopy())!;
    expect(copy.counts['habit.habits'], greaterThan(0));
    final copyBytes = await restore.readSafetyCopy();
    await engine.apply(await engine.open(copyBytes!));
    expect(await tableChecksums(db), onPhone);
  });

  test("ACC-02 when the safety copy can't be saved, nothing is written "
      '(FR-019a)', () async {
    final (bytes, entry) = await backupOfNow();
    await addHabit();
    final before = await tableChecksums(db);
    // A file where the folder should go: saving fails like a full disk.
    safetyRoot = Directory(
      (await File('${support.path}/blocker').create()).path,
    );
    final restore = subject();
    final result = await restore.apply(
      await restore.open(bytes),
      entry: entry,
      fromEmptyPhone: false,
    );
    expect(result, isA<SafetyCopyFailed>());
    expect(await tableChecksums(db), before);
    expect((await settings.load()).lastKnownDriveBackupAt, isNull);
  });

  test('after a restore nothing counts as changed, the pause ends, and the '
      "file's meta becomes the last known backup (FR-041)", () async {
    final (bytes, listed) = await backupOfNow();
    // The listing disagrees with the file: the file wins.
    final wrong = BackupMeta(
      deviceId: 'listing-says',
      deviceName: 'Wrong',
      appVersion: '',
      createdAt: listed.createdAt - 1000,
      kind: BackupKind.manual,
      counts: const {},
      schemaVersion: 5,
      encrypted: false,
    );
    final entry = DriveBackupEntry(
      id: listed.id,
      name: listed.name,
      createdAt: listed.createdAt,
      sizeBytes: listed.sizeBytes,
      kind: listed.kind,
      meta: wrong,
    );
    await settings.setAutoBackupPause(paused: true, notified: true);
    final restore = subject();
    final opened = await restore.open(bytes);
    await restore.apply(opened, entry: entry, fromEmptyPhone: false);
    final s = await settings.load();
    expect(s.backedUpChangeCounter, s.dataChangeCounter);
    expect(s.lastKnownDriveBackupDeviceId, 'other-phone');
    expect(s.lastKnownDriveBackupAt, opened.candidate.document.meta!.createdAt);
    expect(s.autoBackupPausedByConflict, isFalse);
    expect(s.finishSetupPending, isFalse);
  });

  test('SYS-02 a restore onto an empty phone asks for "Finish setting up" '
      'when app lock is off', () async {
    final (bytes, entry) = await backupOfNow();
    // The seed turns app lock on; a fresh phone has it off.
    await settings.setLockEnabled(enabled: false);
    final restore = subject();
    await restore.apply(
      await restore.open(bytes),
      entry: entry,
      fromEmptyPhone: true,
    );
    expect((await settings.load()).finishSetupPending, isTrue);
  });

  group('encrypted backups (FR-019b)', () {
    test('ACC-02 the saved password is tried first; only when it fails is '
        'the user asked, and a wrong one writes nothing', () async {
      final (bytes, entry) = await backupOfNow(password: 'right');
      final restore = subject();
      await expectLater(
        restore.open(bytes),
        throwsA(isA<BackupNeedsPassword>()),
      );
      passwords.value = 'old';
      await expectLater(
        restore.open(bytes),
        throwsA(isA<BackupNeedsPassword>()),
      );
      await expectLater(
        restore.open(bytes, password: 'nope'),
        throwsA(isA<BackupWrongPassword>()),
      );
      expect((await settings.load()).backupEncrypt, isFalse);

      passwords.value = 'right';
      final opened = await restore.open(bytes);
      expect(opened.password, 'right');
      await restore.apply(opened, entry: entry, fromEmptyPhone: false);
    });

    test('after an encrypted restore, "Encrypt backup" is on with that '
        'password; a failed one saves nothing', () async {
      final (bytes, entry) = await backupOfNow(password: 'right');
      await addHabit();
      final realRoot = safetyRoot;
      safetyRoot = Directory(
        (await File('${support.path}/blocker').create()).path,
      );
      var restore = subject();
      var opened = await restore.open(bytes, password: 'right');
      expect(
        await restore.apply(opened, entry: entry, fromEmptyPhone: false),
        isA<SafetyCopyFailed>(),
      );
      expect(passwords.value, isNull);
      expect((await settings.load()).backupEncrypt, isFalse);

      safetyRoot = realRoot;
      restore = subject();
      opened = await restore.open(bytes, password: 'right');
      await restore.apply(opened, entry: entry, fromEmptyPhone: false);
      expect(passwords.value, 'right');
      expect((await settings.load()).backupEncrypt, isTrue);
    });
  });

  test('ACC-02 "Keep this phone\'s data" writes nothing locally, starts a '
      'backup, and the declined backup never warns again', () async {
    final (_, entry) = await backupOfNow();
    await addHabit();
    final before = await tableChecksums(db);
    await settings.setAutoBackupPause(paused: true, notified: true);
    await subject().keepThisPhone(entry);
    expect(await tableChecksums(db), before);
    var s = await settings.load();
    expect(s.lastKnownDriveBackupAt, entry.meta!.createdAt);
    expect(s.autoBackupPausedByConflict, isFalse);
    // The backup runs on its own; wait for it.
    for (var i = 0; i < 200 && drive.uploads.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(drive.uploads.single.deviceId, 'this-phone');
    s = await settings.load();
    expect(s.lastKnownDriveBackupDeviceId, 'this-phone');
  });

  test(
    'the safety copy expires after 7 days, not at 6 days 23 hours',
    () async {
      final (bytes, entry) = await backupOfNow();
      await addHabit();
      final restore = subject();
      await restore.apply(
        await restore.open(bytes),
        entry: entry,
        fromEmptyPhone: false,
      );
      clock.advance(const Duration(days: 6, hours: 23));
      expect(await restore.safetyCopy(), isNotNull);
      clock.advance(const Duration(hours: 1));
      expect(await restore.safetyCopy(), isNull);
      expect(await restore.readSafetyCopy(), isNull);
    },
  );
}
