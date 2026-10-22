import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/auto_backup_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';

/// Notification id of "Automatic backup isn't working" (data-model §7).
final int backupFailingNotificationId = stableNotificationId('backup-failing');

/// The `core.autoBackup` job (FR-018 – FR-020, feature 008 research R11):
/// backs up to Drive as an auto backup, which keeps the 5 newest. After
/// the third failure in a row it shows one notification that opens SET-02;
/// any success ends the streak. Always returns true, so WorkManager keeps
/// the periodic schedule instead of stacking retries. Lives in `lib/app/`
/// because it links to a route.
Future<bool> runAutoBackup(ProviderReader read) async {
  try {
    final settings = read(settingsRepositoryProvider);
    final s = await settings.load();
    if (s.autoBackupFrequency == AutoBackupFrequency.off ||
        s.backupAccountEmail == null) {
      return true;
    }
    try {
      await read(backupServiceProvider).backupToDrive(kind: BackupKind.auto);
      return true;
    } on BackupBusy {
      // Another backup is running (the lease); this is not a failure.
      return true;
    } on Object {
      // Counted below.
    }
    final (next, notifyNow) = AutoBackupPolicy.afterRun(
      AutoBackupCounter(
        failures: s.autoBackupFailures,
        notified: s.autoBackupFailureNotified,
      ),
      success: false,
    );
    await settings.setAutoBackupFailures(
      failures: next.failures,
      notified: next.notified,
    );
    if (notifyNow && s.notificationsEnabled) {
      final l10n = l10nFor(s.locale);
      await read(notificationServiceProvider).show(
        AppNotification(
          id: backupFailingNotificationId,
          channel: NotificationChannelId.backup,
          title: l10n.notif_backupFailingTitle,
          body: l10n.notif_backupFailingBody,
          payload: Routes.backup,
        ),
      );
    }
  } on Object {
    // Best effort; the next run tries again.
  }
  return true;
}

/// When the app opens and a scheduled auto backup is overdue (the
/// background run may be unable to sign in), runs one now (research R11).
bool autoBackupCatchUpDue(AppSettings s, int nowMs) =>
    AutoBackupPolicy.catchUpDue(
      frequency: s.autoBackupFrequency,
      connected: s.backupAccountEmail != null,
      lastAutoBackupAtMs: s.lastAutoBackupAt,
      nowMs: nowMs,
    );
