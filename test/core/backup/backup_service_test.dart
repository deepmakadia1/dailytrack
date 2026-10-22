import 'dart:io';

import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
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
    test('SET-02 US2-4 Back up now uploads a manual backup, records Drive as '
        'the last backup, and never prunes', () async {
      await service().backupToDrive(kind: BackupKind.manual);
      final f = drive.files.single;
      expect(f.kind, BackupKind.manual);
      expect(f.name, 'dailytrack_backup_20261021_1805.json');
      expect(drive.pruneCalls, 0);
      final s = await settings.load();
      expect(s.lastBackupLocation, BackupLocation.drive);
      expect(s.lastBackupSizeBytes, f.sizeBytes);
      expect(s.lastAutoBackupAt, isNull);
    });

    test('SET-02 US3-4 Q1 auto backups keep the 5 newest auto backups; '
        'manual backups stay', () async {
      final svc = service();
      await svc.backupToDrive(kind: BackupKind.manual);
      for (var i = 0; i < 7; i++) {
        await svc.backupToDrive(kind: BackupKind.auto);
      }
      final kinds = [for (final f in await drive.list()) f.kind];
      expect(kinds.where((k) => k == BackupKind.auto), hasLength(5));
      expect(kinds.where((k) => k == BackupKind.manual), hasLength(1));
      expect(drive.deleted, ['f1', 'f2']);
      expect(
        (await settings.load()).lastAutoBackupAt,
        clock.now().toUtc().millisecondsSinceEpoch,
      );
    });

    test('SET-02 US2-5 a failed upload records nothing', () async {
      drive.failNext = const DriveOffline();
      await expectLater(
        service().backupToDrive(kind: BackupKind.manual),
        throwsA(isA<DriveOffline>()),
      );
      expect((await settings.load()).lastBackupAt, isNull);
    });

    test('a failed prune does not fail the auto backup', () async {
      drive.failPrune = const DriveOffline();
      await service().backupToDrive(kind: BackupKind.auto);
      expect(drive.files, hasLength(1));
      expect((await settings.load()).lastBackupLocation, BackupLocation.drive);
    });

    test('SET-02 US3-6 any successful backup ends a failure streak', () async {
      await settings.setAutoBackupFailures(failures: 4, notified: true);
      await service().backupToDrive(kind: BackupKind.manual);
      var s = await settings.load();
      expect((s.autoBackupFailures, s.autoBackupFailureNotified), (0, false));

      await settings.setAutoBackupFailures(failures: 2, notified: false);
      await service().backupToDevice();
      s = await settings.load();
      expect(s.autoBackupFailures, 0);
    });

    test('SET-02 US2-7 a Drive backup restores like a file', () async {
      final svc = service();
      await svc.backupToDrive(kind: BackupKind.manual);
      final bytes = await drive.download(drive.files.single.id);
      final candidate = await engineFor(db, clock, docs).open(bytes);
      expect(candidate.preview.modules, hasLength(2));
    });
  });
}
