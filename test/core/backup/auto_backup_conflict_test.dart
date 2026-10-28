import 'dart:io';

import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/app/background_dispatcher.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// A Drive whose upload runs [beforeUpload] first, as if the user wrote
/// data while the backup was on its way.
final class _SlowDrive extends FakeDriveBackupStore {
  Future<void> Function()? beforeUpload;

  @override
  Future<void> upload(
    Uint8List bytes, {
    required String fileName,
    required BackupMeta meta,
  }) async {
    await beforeUpload?.call();
    await super.upload(bytes, fileName: fileName, meta: meta);
  }
}

/// The auto backup job against the real backup service, a fake Drive, and
/// an injected clock (feature 010 T084; spec §16 "Auto backup while signed
/// in" and "Conflict rule: last backup wins"; FR-031 – FR-040, FR-038a).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late Directory cache;
  late MutableClock clock;
  late SettingsRepositoryImpl settings;
  late _SlowDrive drive;
  late FakeNotificationService notifications;
  late FakeAdService ads;
  late ProviderContainer container;

  const thisPhone = 'this-phone';

  BackupService service() => BackupService(
    engine: engineFor(db, clock, docs),
    coordinator: BackupCoordinator(db, clock),
    settings: settings,
    files: FakeLocalBackupFiles(),
    passwords: FakeBackupPasswordStore(),
    sharer: FakeFileSharer(),
    cacheDir: () async => cache,
    nowUtcMs: () => clock.now().toUtc().millisecondsSinceEpoch,
    drive: drive,
    device: () async =>
        const DeviceIdentity(id: thisPhone, name: 'Google Pixel 7'),
  );

  int nowMs() => clock.now().toUtc().millisecondsSinceEpoch;

  BackupMeta backupFrom(
    String deviceId, {
    int minutesFromNow = 1,
    int transactions = 3,
  }) => BackupMeta(
    deviceId: deviceId,
    deviceName: 'Redmi Note 12',
    appVersion: '1.0.0+7',
    createdAt: nowMs() + minutesFromNow * 60000,
    kind: BackupKind.auto,
    counts: {'expense.transactions': transactions},
    schemaVersion: 5,
    encrypted: false,
  );

  Future<void> signIn() async {
    await settings.setBackupAccountEmail('me@example.com');
    await settings.setAuthMode(AuthMode.google);
    await settings.setAutoBackup(
      frequency: AutoBackupFrequency.daily,
      wifiOnly: false,
    );
  }

  var edits = 0;

  /// A write to module state (always a new value), so the data counts as
  /// changed.
  Future<void> changeSomething() =>
      settings.writeModuleState('test.edit', '${++edits}');

  Future<void> runJob() => runAutoBackup(container.read);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('auto_docs');
    cache = await Directory.systemTemp.createTemp('auto_cache');
    clock = MutableClock(DateTime(2026, 10, 27, 21, 30));
    await seedRichData(db, docs);
    settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    await signIn();
    drive = _SlowDrive()..clockMs = nowMs();
    notifications = FakeNotificationService();
    ads = FakeAdService();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        backupServiceProvider.overrideWithValue(service()),
        notificationServiceProvider.overrideWithValue(notifications),
        adServiceProvider.overrideWithValue(ads),
        clockProvider.overrideWithValue(clock),
        moduleRegistryProvider.overrideWithValue(ModuleRegistry(const [])),
        backgroundSchedulerProvider.overrideWithValue(
          FakeBackgroundScheduler(),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
    await docs.delete(recursive: true);
    await cache.delete(recursive: true);
  });

  group('§16 auto backup while signed in', () {
    test('a changed phone makes an auto backup with metadata, and the last '
        'backup time and last known backup point to it', () async {
      await runJob();
      final s = await settings.load();
      final uploaded = drive.uploads.single;
      expect(uploaded.kind, BackupKind.auto);
      expect(uploaded.deviceId, thisPhone);
      expect(s.lastBackupAt, nowMs());
      expect(s.lastKnownDriveBackupAt, uploaded.createdAt);
      expect(s.lastKnownDriveBackupDeviceId, thisPhone);
      expect(s.backedUpChangeCounter, s.dataChangeCounter);
    });

    test('the scheduled job skips the upload when nothing changed since the '
        'last successful backup, and makes no Drive call at all', () async {
      await runJob();
      drive.calls.clear();
      clock.advance(const Duration(days: 1));
      await runJob();
      expect(drive.calls, isEmpty);
      expect(drive.uploads, hasLength(1));
      expect((await settings.load()).autoBackupFailures, 0);
    });

    test("backedUpChangeCounter comes from the backup's own snapshot: a "
        'write made while it uploads still counts as changed', () async {
      drive.beforeUpload = changeSomething;
      await runJob();
      final s = await settings.load();
      expect(drive.uploads, hasLength(1));
      expect(s.backedUpChangeCounter, lessThan(s.dataChangeCounter));

      drive.beforeUpload = null;
      clock.advance(const Duration(hours: 1));
      await runJob();
      expect(drive.uploads, hasLength(2));
    });

    test('changes made while signed out are backed up by the first backup '
        'after signing in', () async {
      await settings.setBackupAccountEmail(null);
      await settings.setAuthMode(AuthMode.guest);
      await changeSomething();
      await runJob();
      expect(drive.uploads, isEmpty, reason: 'signed out: nothing runs');

      await signIn();
      await runJob();
      final s = await settings.load();
      expect(drive.uploads, hasLength(1));
      expect(s.backedUpChangeCounter, s.dataChangeCounter);
    });

    test(
      'a background backup counts toward the 3-failures notification',
      () async {
        for (var i = 0; i < 3; i++) {
          await changeSomething();
          drive.failNext = const DriveOffline();
          expect(
            await runBackgroundTask(backgroundBackupTaskName, container),
            isTrue,
          );
        }
        expect(notifications.shown.single.id, backupFailingNotificationId);
        expect((await settings.load()).autoBackupFailures, 3);
      },
    );

    test('background backups count toward day-based rotation', () async {
      for (var d = 7; d >= 1; d--) {
        drive.seed(
          createdAt: clock
              .now()
              .subtract(Duration(days: d))
              .toUtc()
              .millisecondsSinceEpoch,
          kind: BackupKind.auto,
        );
      }
      await runBackgroundTask(backgroundBackupTaskName, container);
      final auto = drive.files.where((f) => f.kind == BackupKind.auto);
      expect(auto, hasLength(6));
    });

    test('auto backups never trigger ads', () async {
      await runJob();
      await runBackgroundTask(backgroundBackupTaskName, container);
      expect(ads.triggers, isEmpty);
    });
  });

  group('§16 conflict rule: last backup wins', () {
    test('an auto backup does not upload over a newer backup from another '
        'phone: it pauses and shows the Backup notification once, opening '
        'ACC-01', () async {
      drive.seed(meta: backupFrom('other-phone'));
      await runJob();
      await changeSomething();
      await runJob();

      final s = await settings.load();
      expect(drive.uploads, isEmpty);
      expect(s.autoBackupPausedByConflict, isTrue);
      expect(s.autoBackupPauseNotified, isTrue);
      final n = notifications.shown.single;
      expect(n.id, backupPausedNotificationId);
      expect(n.payload, Routes.account);
      expect(s.autoBackupFailures, 0, reason: 'a pause is not a failure');
    });

    test('the pause ends after a manual backup ("Back up anyway"), and auto '
        'backups resume', () async {
      drive.seed(meta: backupFrom('other-phone'));
      await runJob();
      expect((await settings.load()).autoBackupPausedByConflict, isTrue);

      // The user taps "Back up anyway" after the other phone's backup.
      clock.advance(const Duration(minutes: 5));
      await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.overwrite,
      );
      var s = await settings.load();
      expect(s.autoBackupPausedByConflict, isFalse);
      expect(s.autoBackupPauseNotified, isFalse);

      clock.advance(const Duration(minutes: 20));
      await changeSomething();
      await runJob();
      s = await settings.load();
      expect(drive.uploads.last.kind, BackupKind.auto);
      expect(s.autoBackupPausedByConflict, isFalse);
    });

    test('a manual backup over a newer backup from another phone needs '
        'confirmation naming that backup, and uploads nothing', () async {
      final newer = backupFrom('other-phone');
      drive.seed(meta: newer);
      final result = await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      expect(
        result,
        isA<NeedsConfirmation>().having(
          (r) => r.conflict,
          'conflict',
          isA<NewerFromOtherDevice>().having(
            (c) => c.newest.createdAt,
            'createdAt',
            newer.createdAt,
          ),
        ),
      );
      expect(drive.uploads, isEmpty);
    });

    test('a newer backup made by this same phone never triggers the '
        'warning', () async {
      drive.seed(meta: backupFrom(thisPhone));
      await runJob();
      expect(drive.uploads, hasLength(1));
      expect((await settings.load()).autoBackupPausedByConflict, isFalse);
    });

    test('a backup older than lastKnownDriveBackupAt never triggers the '
        'warning', () async {
      final older = backupFrom('other-phone', minutesFromNow: -30);
      drive.seed(meta: older);
      await settings.setLastKnownDriveBackup(
        at: older.createdAt + 1000,
        deviceId: thisPhone,
      );
      await runJob();
      expect(drive.uploads, hasLength(1));
    });

    test('the newest backup is the one compared, by createdAt', () async {
      drive
        ..seed(meta: backupFrom(thisPhone, minutesFromNow: 5))
        ..seed(meta: backupFrom('other-phone', minutesFromNow: 10));
      await runJob();
      expect(drive.uploads, isEmpty);
      expect((await settings.load()).autoBackupPausedByConflict, isTrue);
    });
  });

  group('§16 empty phone over a backup with data', () {
    Future<void> emptyThePhone() async {
      await eraseEverything(db);
      await signIn();
      await changeSomething();
    }

    test('an auto backup does not upload, and it is neither a failure nor a '
        'pause', () async {
      drive.seed(meta: backupFrom(thisPhone, minutesFromNow: -60));
      await emptyThePhone();
      await runJob();
      final s = await settings.load();
      expect(drive.uploads, isEmpty);
      expect(s.autoBackupPausedByConflict, isFalse);
      expect(s.autoBackupFailures, 0);
      expect(notifications.shown, isEmpty);
    });

    test('a manual backup asks first ("This phone has no data")', () async {
      drive.seed(meta: backupFrom(thisPhone, minutesFromNow: -60));
      await emptyThePhone();
      final result = await service().backupToDrive(
        kind: BackupKind.manual,
        conflict: ConflictMode.ask,
      );
      expect(
        result,
        isA<NeedsConfirmation>().having(
          (r) => r.conflict,
          'conflict',
          isA<EmptyOverData>(),
        ),
      );
      expect(drive.uploads, isEmpty);
    });

    test('an empty phone over an empty backup uploads as usual', () async {
      drive.seed(
        meta: backupFrom(thisPhone, minutesFromNow: -60, transactions: 0),
      );
      await emptyThePhone();
      await runJob();
      expect(drive.uploads, hasLength(1));
    });
  });
}
