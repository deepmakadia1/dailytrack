import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/auto_backup_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';

/// Notification id of "Automatic backup isn't working" (data-model §7).
final int backupFailingNotificationId = stableNotificationId('backup-failing');

/// Notification id of "Backup paused" (feature 010, spec §12).
final int backupPausedNotificationId = stableNotificationId('backup-paused');

/// The auto backup job (FR-018 – FR-020, feature 008 research R11), run by
/// both `core.autoBackup` (scheduled) and `core.backgroundBackup` (app
/// hidden; feature 010 research R6). Skips the upload when nothing changed
/// (FR-033), and never uploads over a newer backup from another phone: it
/// pauses and shows one notification that opens ACC-01 (FR-038, FR-039).
/// After the third failure in a row it shows one notification that opens
/// SET-02; any success ends the streak. Always returns true, so WorkManager
/// keeps the periodic schedule instead of stacking retries. Lives in
/// `lib/app/` because it links to routes. [foreground] is the app-open
/// catch-up: there an expired sign-in signs the account out (research R2);
/// a background run only counts it as a failure, since signing in from the
/// background can fail for ordinary reasons.
Future<bool> runAutoBackup(
  ProviderReader read, {
  bool foreground = false,
}) async {
  try {
    final settings = read(settingsRepositoryProvider);
    final s = await settings.load();
    if (s.autoBackupFrequency == AutoBackupFrequency.off ||
        s.backupAccountEmail == null) {
      return true;
    }
    try {
      final result = await read(backupServiceProvider).backupIfChanged();
      switch (result) {
        case Uploaded():
          break;
        // Nothing to upload counts as a finished run, so the app-open
        // catch-up doesn't retry it.
        case Unchanged() || SkippedEmpty():
          await settings.setLastAutoBackupAt(_nowMs(read));
          await settings.setAutoBackupFailures(failures: 0, notified: false);
        case PausedByConflict():
          await _notifyPaused(read, await settings.load());
        case NeedsConfirmation():
          // Not returned in pause mode.
          break;
      }
      return true;
    } on BackupBusy {
      // Another backup is running (the lease); this is not a failure.
      return true;
    } on DriveAuthRequired {
      if (foreground) {
        await read(accountServiceProvider).forgetAfterAuthLoss();
        return true;
      }
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

int _nowMs(ProviderReader read) =>
    read(clockProvider).now().toUtc().millisecondsSinceEpoch;

/// The pause notification, once per pause (FR-039). With notifications off
/// it is not marked shown, so turning them on still tells the user.
Future<void> _notifyPaused(ProviderReader read, AppSettings s) async {
  if (s.autoBackupPauseNotified || !s.notificationsEnabled) return;
  final l10n = l10nFor(s.locale);
  await read(notificationServiceProvider).show(
    AppNotification(
      id: backupPausedNotificationId,
      channel: NotificationChannelId.backup,
      title: l10n.notif_backupPausedTitle,
      body: l10n.notif_backupPausedBody,
      payload: Routes.account,
    ),
  );
  await read(settingsRepositoryProvider)
      .setAutoBackupPause(paused: true, notified: true);
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
