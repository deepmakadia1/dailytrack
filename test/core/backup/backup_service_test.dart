import 'dart:io';

import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// SET-02 backup and restore services and the single-run lease (feature 008
/// T032, T033, FR-011, FR-013, research R4, R8).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late Directory cache;
  late MutableClock clock;
  late SettingsRepositoryImpl settings;
  late FakeLocalBackupFiles files;
  late FakeBackupPasswordStore passwords;
  late FakeFileSharer sharer;
  late FakeDriveBackupStore drive;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('svc_docs');
    cache = await Directory.systemTemp.createTemp('svc_cache');
    clock = MutableClock(DateTime(2026, 10, 21, 18, 5));
    await seedRichData(db, docs);
    settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    files = FakeLocalBackupFiles();
    passwords = FakeBackupPasswordStore();
    sharer = FakeFileSharer();
    drive = FakeDriveBackupStore();
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
    await cache.delete(recursive: true);
  });

  BackupService service() => BackupService(
    engine: engineFor(db, clock, docs),
    coordinator: BackupCoordinator(db, clock),
    settings: settings,
    files: files,
    passwords: passwords,
    sharer: sharer,
    cacheDir: () async => cache,
    nowUtcMs: () => clock.now().toUtc().millisecondsSinceEpoch,
    drive: drive,
    device: () async =>
        const DeviceIdentity(id: 'this-phone', name: 'Google Pixel 7'),
  );

  /// A backup another phone made [minutesLater] after the clock's now.
  BackupMeta otherPhone({int minutesLater = 1, int transactions = 3}) =>
      BackupMeta(
        deviceId: 'other-phone',
        deviceName: 'Redmi Note 12',
        appVersion: '1.0.0+7',
        createdAt: clock
            .now()
            .add(Duration(minutes: minutesLater))
            .toUtc()
            .millisecondsSinceEpoch,
        kind: BackupKind.manual,
        counts: {'expense.transactions': transactions},
        schemaVersion: 5,
        encrypted: false,
      );

  test('SET-02 US1-1 saves through the picker with the suggested name and '
      'records the last backup', () async {
    final saved = await service().backupToDevice();
    expect(saved, isNotNull);
    expect(files.saved.single.$1, 'dailytrack_backup_20261021_1805.json');
    final s = await settings.load();
    expect(s.lastBackupAt, clock.now().toUtc().millisecondsSinceEpoch);
    expect(s.lastBackupLocation, BackupLocation.device);
    expect(s.lastBackupSizeBytes, files.saved.single.$2.length);
  });

  test('SET-02 US1-1 a cancelled save records nothing', () async {
    files.saveResult = false;
    expect(await service().backupToDevice(), isNull);
    expect((await settings.load()).lastBackupAt, isNull);
  });

  test('SET-02 US1-1 Share sends the saved file', () async {
    final svc = service();
    await svc.backupToDevice();
    await svc.shareLastFile();
    expect(sharer.shared.single, endsWith('.json'));
    expect(File(sharer.shared.single).existsSync(), isTrue);
  });

  test('SET-02 US1-2 receipts on makes a zip with the image', () async {
    await settings.setBackupIncludeReceipts(enabled: true);
    await service().backupToDevice();
    final (name, bytes) = files.saved.single;
    expect(name, endsWith('.zip'));
    expect(detectForm(bytes), ContainerForm.zip);
  });

  test('SET-02 US4-2 encryption on uses the stored password', () async {
    passwords.value = 's3cret';
    await settings.setBackupEncrypt(enabled: true);
    await service().backupToDevice();
    final (name, bytes) = files.saved.single;
    expect(name, endsWith('.dtbk'));
    final opened = await engineFor(
      db,
      clock,
      docs,
    ).open(bytes, password: 's3cret');
    expect(opened.preview.encrypted, isTrue);
  });

  test(
    'SET-02 US4 encryption on without a password never makes a plain file',
    () async {
      await settings.setBackupEncrypt(enabled: true);
      await expectLater(
        service().backupToDevice(),
        throwsA(isA<BackupNeedsPassword>()),
      );
      expect(files.saved, isEmpty);
    },
  );

  test(
    'SET-02 FR-011 a second run while one holds the lease is BackupBusy',
    () async {
      final coordinator = BackupCoordinator(db, clock);
      final other = BackupCoordinator(db, clock); // another isolate's view
      await coordinator.run(() async {
        await expectLater(
          coordinator.run(() async => 1),
          throwsA(isA<BackupBusy>()),
        );
        await expectLater(other.run(() async => 1), throwsA(isA<BackupBusy>()));
      });
      // Released afterwards.
      expect(await other.run(() async => 2), 2);
    },
  );

  test('SET-02 FR-011 an expired lease (crashed run) is taken over', () async {
    final crashed = BackupCoordinator(db, clock);
    // Hold the lease, then abandon it without releasing.
    await db.customStatement(
      'INSERT INTO settings (key, value, updated_at) VALUES '
      "('${BackupCoordinator.leaseKey}', "
      "'${clock.now().toUtc().millisecondsSinceEpoch + 60000}', 0)",
    );
    await expectLater(crashed.run(() async => 1), throwsA(isA<BackupBusy>()));
    clock.advance(BackupCoordinator.leaseLength);
    expect(await BackupCoordinator(db, clock).run(() async => 3), 3);
  });

  test('SET-02 FR-010 restore runs the aftermath; its failure does not fail '
      'the restore', () async {
    final engine = engineFor(db, clock, docs);
    final file = await engine.create(includeReceipts: false);
    var aftermathRuns = 0;
    final restore = RestoreService(
      engine: engine,
      coordinator: BackupCoordinator(db, clock),
      files: files..picked = file.bytes,
      aftermath: () async {
        aftermathRuns++;
        throw StateError('notifications unavailable');
      },
    );
    final bytes = await restore.pickFile();
    final candidate = await restore.open(bytes!);
    expect(await restore.apply(candidate), RestoreOutcome.done);
    expect(aftermathRuns, 1);
  });

  group('Google Drive (US2, US3)', () {
    test('SET-02 US2-4 Back up now uploads a manual backup with metadata, '
        'records Drive as the last backup, and never rotates', () async {
      final result = await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      expect(result, isA<Uploaded>());
      final f = drive.files.single;
      expect(f.kind, BackupKind.manual);
      expect(f.name, 'dailytrack_backup_20261021_1805.json');
      expect(drive.deleted, isEmpty);
      final meta = drive.uploads.single;
      expect(meta.deviceId, 'this-phone');
      expect(meta.deviceName, 'Google Pixel 7');
      expect(meta.kind, BackupKind.manual);
      expect(meta.schemaVersion, 5);
      expect(meta.encrypted, isFalse);
      expect(meta.counts['expense.transactions'], greaterThan(0));
      final s = await settings.load();
      expect(s.lastBackupLocation, BackupLocation.drive);
      expect(s.lastBackupSizeBytes, f.sizeBytes);
      expect(s.lastAutoBackupAt, isNull);
      expect(s.lastKnownDriveBackupAt, meta.createdAt);
      expect(s.lastKnownDriveBackupDeviceId, 'this-phone');
    });

    test(
      '§16 the file carries the same meta as the Drive properties',
      () async {
        await service().backupToDrive(
          kind: BackupKind.manual,
          conflict: ConflictMode.ask,
        );
        final bytes = await drive.download(drive.files.single.id);
        final candidate = await engineFor(db, clock, docs).open(bytes);
        final inFile = candidate.document.meta!;
        expect(inFile.deviceId, 'this-phone');
        expect(inFile.createdAt, drive.uploads.single.createdAt);
        expect(inFile.counts, drive.uploads.single.counts);
      },
    );

    test('SET-02 Q1 auto backups rotate by day; manual backups stay', () async {
      final svc = service();
      await svc.backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      for (var i = 0; i < 4; i++) {
        await svc.backupToDrive(
          kind: BackupKind.auto,
          conflict: ConflictMode.pause,
        );
      }
      final kinds = [for (final f in await drive.list()) f.kind];
      expect(kinds.where((k) => k == BackupKind.auto), hasLength(1));
      expect(kinds.where((k) => k == BackupKind.manual), hasLength(1));
      expect(
        (await settings.load()).lastAutoBackupAt,
        clock.now().toUtc().millisecondsSinceEpoch,
      );
    });

    test('SET-02 US2-5 a failed upload records nothing', () async {
      drive.failNext = const DriveOffline();
      await expectLater(
        service().backupToDrive(
          kind: BackupKind.manual,
          conflict: ConflictMode.overwrite,
        ),
        throwsA(isA<DriveOffline>()),
      );
      final s = await settings.load();
      expect(s.lastBackupAt, isNull);
      expect(s.backedUpChangeCounter, 0);
      expect(s.lastKnownDriveBackupAt, isNull);
    });

    test('a failed rotation does not fail the auto backup', () async {
      // The upload is dated now, after the earlier one from today.
      drive.clockMs = clock.now().toUtc().millisecondsSinceEpoch;
      final old = drive.seed(
        kind: BackupKind.auto,
        createdAt: drive.clockMs - 60000,
      );
      drive.failDeleteOf.add(old.id);
      await service().backupToDrive(
        kind: BackupKind.auto,
        conflict: ConflictMode.overwrite,
      );
      expect(drive.files, hasLength(2));
      expect((await settings.load()).lastBackupLocation, BackupLocation.drive);
    });

    test('SET-02 US3-6 any successful backup ends a failure streak', () async {
      await settings.setAutoBackupFailures(failures: 4, notified: true);
      await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      var s = await settings.load();
      expect((s.autoBackupFailures, s.autoBackupFailureNotified), (0, false));

      await settings.setAutoBackupFailures(failures: 2, notified: false);
      await service().backupToDevice();
      s = await settings.load();
      expect(s.autoBackupFailures, 0);
    });

    test('SET-02 US2-7 a Drive backup restores like a file', () async {
      await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      final bytes = await drive.download(drive.files.single.id);
      final candidate = await engineFor(db, clock, docs).open(bytes);
      expect(candidate.preview.modules, hasLength(2));
    });
  });

  group('§16 change counter (FR-031, FR-033)', () {
    test('a backup stores the counter from its own snapshot; a later write '
        'counts as changed again', () async {
      final svc = service();
      final before = (await settings.load()).dataChangeCounter;
      expect(before, greaterThan(0), reason: 'seeded rows were counted');
      await svc.backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      var s = await settings.load();
      expect(s.backedUpChangeCounter, s.dataChangeCounter);

      expect(await svc.backupIfChanged(), isA<Unchanged>());
      expect(drive.files, hasLength(1));

      await settings.setLocale('hi');
      s = await settings.load();
      expect(s.dataChangeCounter, isNot(s.backedUpChangeCounter));
      expect(await svc.backupIfChanged(), isA<Uploaded>());
      expect(drive.files.last.kind, BackupKind.auto);
    });

    test('a local backup file does not mark the data backed up', () async {
      await service().backupToDevice();
      expect((await settings.load()).backedUpChangeCounter, 0);
    });
  });

  group('§16 conflict rule (FR-038 – FR-040)', () {
    test('ask: a newer backup from another phone needs confirmation and '
        'uploads nothing', () async {
      drive.seed(meta: otherPhone());
      final result = await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      expect(
        result,
        isA<NeedsConfirmation>().having(
          (r) => r.conflict,
          'conflict',
          isA<NewerFromOtherDevice>(),
        ),
      );
      expect(drive.uploads, isEmpty);
      expect((await settings.load()).lastBackupAt, isNull);
    });

    test('overwrite ("Back up anyway") uploads, ends a pause, and updates '
        'the last known backup', () async {
      drive.seed(meta: otherPhone());
      await settings.setAutoBackupPause(paused: true, notified: true);
      await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.overwrite,
      );
      final s = await settings.load();
      expect(drive.uploads, hasLength(1));
      expect(s.autoBackupPausedByConflict, isFalse);
      expect(s.autoBackupPauseNotified, isFalse);
      expect(s.lastKnownDriveBackupDeviceId, 'this-phone');
    });

    test('pause: auto backup uploads nothing and pauses', () async {
      final newer = otherPhone();
      drive.seed(meta: newer);
      final result = await service().backupToDrive(
        kind: BackupKind.auto,
        conflict: ConflictMode.pause,
      );
      expect(
        result,
        isA<PausedByConflict>().having(
          (r) => r.newest.deviceId,
          'device',
          'other-phone',
        ),
      );
      expect(drive.uploads, isEmpty);
      expect((await settings.load()).autoBackupPausedByConflict, isTrue);
    });

    test('a backup this phone already knows about is no conflict', () async {
      final seen = otherPhone();
      drive.seed(meta: seen);
      await settings.setLastKnownDriveBackup(
        at: seen.createdAt,
        deviceId: seen.deviceId,
      );
      expect(
        await service().backupToDrive(
          kind: BackupKind.auto,
          conflict: ConflictMode.pause,
        ),
        isA<Uploaded>(),
      );
    });

    test('a backup made before feature 010 (no meta) is no conflict', () async {
      drive.seed(createdAt: clock.now().toUtc().millisecondsSinceEpoch + 60000);
      expect(
        await service().backupToDrive(
          kind: BackupKind.manual,
          conflict: ConflictMode.ask,
        ),
        isA<Uploaded>(),
      );
    });
  });
}
