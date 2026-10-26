import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/app/background_dispatcher.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/auto_backup_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

final class _ScriptedBackupService implements BackupService {
  /// One entry per run: null uploads, a [DriveBackupResult] is returned,
  /// a failure is thrown.
  final results = <Object?>[];
  final kinds = <BackupKind>[];

  static const _meta = BackupMeta(
    deviceId: 'this-phone',
    deviceName: 'Pixel 7',
    appVersion: '1.0.0+7',
    createdAt: 1792540800000,
    kind: BackupKind.auto,
    counts: {},
    schemaVersion: 5,
    encrypted: false,
  );

  @override
  Future<DriveBackupResult> backupToDrive({
    required BackupKind kind,
    required ConflictMode conflict,
  }) async {
    kinds.add(kind);
    final result = results.isEmpty ? null : results.removeAt(0);
    if (result is BackupFailure) throw result;
    if (result is DriveBackupResult) return result;
    return const Uploaded(meta: _meta, sizeBytes: 1);
  }

  @override
  Future<DriveBackupResult> backupIfChanged() =>
      backupToDrive(kind: BackupKind.auto, conflict: ConflictMode.pause);

  @override
  Future<SavedBackup?> backupToDevice() => throw UnimplementedError();

  @override
  Future<void> shareLastFile() => throw UnimplementedError();
}

/// Auto backup (feature 008 T062 – T067, FR-018 – FR-020, research R11).
void main() {
  group('AutoBackupPolicy (pure)', () {
    test('the third failure in a row notifies once; success resets', () {
      var counter = const AutoBackupCounter(failures: 0, notified: false);
      final notices = <bool>[];
      for (var i = 0; i < 5; i++) {
        final (next, notify) = AutoBackupPolicy.afterRun(
          counter,
          success: false,
        );
        counter = next;
        notices.add(notify);
      }
      expect(notices, [false, false, true, false, false]);
      expect(counter.failures, 5);
      expect(counter.notified, isTrue);
      final (reset, notify) = AutoBackupPolicy.afterRun(counter, success: true);
      expect((reset.failures, reset.notified, notify), (0, false, false));
    });

    test('catch-up is due only when on, connected, and overdue by period + '
        '6 h', () {
      const day = 86400000;
      const hour = 3600000;
      bool due(AutoBackupFrequency f, {bool connected = true, int? last}) =>
          AutoBackupPolicy.catchUpDue(
            frequency: f,
            connected: connected,
            lastAutoBackupAtMs: last,
            nowMs: 100 * day,
          );
      expect(due(AutoBackupFrequency.off, last: 0), isFalse);
      expect(due(AutoBackupFrequency.daily, connected: false), isFalse);
      expect(due(AutoBackupFrequency.daily), isTrue);
      expect(
        due(AutoBackupFrequency.daily, last: 100 * day - 31 * hour),
        isTrue,
      );
      expect(
        due(AutoBackupFrequency.daily, last: 100 * day - 30 * hour),
        isFalse,
      );
      expect(
        due(AutoBackupFrequency.weekly, last: 100 * day - 8 * day),
        isTrue,
      );
      expect(
        due(AutoBackupFrequency.weekly, last: 100 * day - 7 * day),
        isFalse,
      );
    });
  });

  group('syncAutoBackupSchedule (FR-018, FR-019)', () {
    test('Daily with Wi-Fi only waits for an unmetered network', () async {
      final scheduler = FakeBackgroundScheduler();
      await syncAutoBackupSchedule(
        const AppSettings(
          backupAccountEmail: 'me@example.com',
          autoBackupFrequency: AutoBackupFrequency.daily,
        ),
        scheduler,
      );
      expect(scheduler.periodic[autoBackupTaskName], (
        const Duration(hours: 24),
        NetworkRequirement.unmetered,
      ));
    });

    test('Weekly without Wi-Fi only needs any connection', () async {
      final scheduler = FakeBackgroundScheduler();
      await syncAutoBackupSchedule(
        const AppSettings(
          backupAccountEmail: 'me@example.com',
          autoBackupFrequency: AutoBackupFrequency.weekly,
          autoBackupWifiOnly: false,
        ),
        scheduler,
      );
      expect(scheduler.periodic[autoBackupTaskName], (
        const Duration(days: 7),
        NetworkRequirement.connected,
      ));
    });

    test('Off, or no account, cancels the job', () async {
      for (final s in const [
        AppSettings(backupAccountEmail: 'me@example.com'),
        AppSettings(autoBackupFrequency: AutoBackupFrequency.daily),
      ]) {
        final scheduler = FakeBackgroundScheduler();
        await syncAutoBackupSchedule(s, scheduler);
        expect(scheduler.cancelled, [
          autoBackupTaskName,
          backgroundBackupTaskName,
        ]);
        expect(scheduler.periodic, isEmpty);
      }
    });
  });

  group('runAutoBackup (the core.autoBackup job)', () {
    late FakeSettingsRepository settings;
    late _ScriptedBackupService backups;
    late FakeNotificationService notifications;
    late ProviderContainer container;

    setUp(() {
      settings = FakeSettingsRepository(
        initial: const AppSettings(
          locale: 'en',
          backupAccountEmail: 'me@example.com',
          autoBackupFrequency: AutoBackupFrequency.daily,
        ),
      );
      backups = _ScriptedBackupService();
      notifications = FakeNotificationService();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          backupServiceProvider.overrideWithValue(backups),
          notificationServiceProvider.overrideWithValue(notifications),
          moduleRegistryProvider.overrideWithValue(ModuleRegistry(const [])),
          backgroundSchedulerProvider.overrideWithValue(
            FakeBackgroundScheduler(),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test('SET-02 US3-4 a run makes an auto backup to Drive', () async {
      expect(await runAutoBackup(container.read), isTrue);
      expect(backups.kinds, [BackupKind.auto]);
      expect(notifications.shown, isEmpty);
    });

    test('SET-02 US3-5 three failures in a row show one notification that '
        'opens SET-02; a fourth shows none', () async {
      backups.results.addAll(const [
        DriveOffline(),
        DriveAuthRequired(),
        DriveUnavailable('500'),
        DriveOffline(),
      ]);
      for (var i = 0; i < 4; i++) {
        expect(await runAutoBackup(container.read), isTrue);
      }
      final n = notifications.shown.single;
      expect(n.channel, NotificationChannelId.backup);
      expect(n.id, backupFailingNotificationId);
      expect(n.payload, Routes.backup);
      expect(n.title, "Automatic backup isn't working");
      expect(
        n.body,
        'Your last 3 backups to Google Drive failed. Tap to check.',
      );
      expect(settings.current.autoBackupFailures, 4);
      expect(settings.current.autoBackupFailureNotified, isTrue);
    });

    test('another backup holding the lease is not a failure', () async {
      backups.results.add(const BackupBusy());
      await runAutoBackup(container.read);
      expect(settings.current.autoBackupFailures, 0);
    });

    test(
      'with notifications off the streak is counted but nothing shows',
      () async {
        await settings.setNotificationsEnabled(enabled: false);
        backups.results.addAll(const [
          DriveOffline(),
          DriveOffline(),
          DriveOffline(),
        ]);
        for (var i = 0; i < 3; i++) {
          await runAutoBackup(container.read);
        }
        expect(notifications.shown, isEmpty);
        expect(settings.current.autoBackupFailures, 3);
      },
    );

    test('SET-02 US3-7 Off or disconnected: nothing runs', () async {
      await settings.setAutoBackup(
        frequency: AutoBackupFrequency.off,
        wifiOnly: true,
      );
      await runAutoBackup(container.read);
      await settings.setAutoBackup(
        frequency: AutoBackupFrequency.daily,
        wifiOnly: true,
      );
      await settings.setBackupAccountEmail(null);
      await runAutoBackup(container.read);
      expect(backups.kinds, isEmpty);
    });

    test('the dispatcher runs core.autoBackup before module tasks', () async {
      expect(await runBackgroundTask(autoBackupTaskName, container), isTrue);
      expect(backups.kinds, [BackupKind.auto]);
    });

    test('§16 the background backup task runs the same job', () async {
      expect(
        await runBackgroundTask(backgroundBackupTaskName, container),
        isTrue,
      );
      expect(backups.kinds, [BackupKind.auto]);
    });

    test('§16 unchanged data is a finished run, not a failure', () async {
      await settings.setAutoBackupFailures(failures: 2, notified: false);
      backups.results.add(const Unchanged());
      await runAutoBackup(container.read);
      expect(settings.current.autoBackupFailures, 0);
      expect(settings.current.lastAutoBackupAt, isNotNull);
      expect(notifications.shown, isEmpty);
    });

    test('§16 a conflict pause notifies once, opening ACC-01', () async {
      const newer = BackupMeta(
        deviceId: 'other-phone',
        deviceName: 'Redmi Note 12',
        appVersion: '1.0.0+7',
        createdAt: 1792540900000,
        kind: BackupKind.auto,
        counts: {'expense.transactions': 3},
        schemaVersion: 5,
        encrypted: false,
      );
      backups.results.addAll(const [
        PausedByConflict(newer),
        PausedByConflict(newer),
      ]);
      // The service sets the pause; the job shows the notice once.
      await settings.setAutoBackupPause(paused: true, notified: false);
      await runAutoBackup(container.read);
      await runAutoBackup(container.read);
      final n = notifications.shown.single;
      expect(n.id, backupPausedNotificationId);
      expect(n.payload, Routes.account);
      expect(n.title, 'Backup paused');
      expect(settings.current.autoBackupPauseNotified, isTrue);
      expect(settings.current.autoBackupFailures, 0);
    });
  });
}
