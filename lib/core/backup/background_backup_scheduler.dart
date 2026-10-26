import 'package:clock/clock.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/domain/background_backup_trigger.dart';
import 'package:dailytrack/core/backup/domain/change_counter.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';

/// WorkManager name of the one-off backup started when the app goes to the
/// background (spec §16, research R6). It runs the same job as
/// `core.autoBackup`.
const String backgroundBackupTaskName = 'core.backgroundBackup';

/// Starts a background backup when the app is hidden (FR-032, FR-034). A
/// one-off WorkManager task finishes even if the app is closed, waits for
/// Wi-Fi when "Wi-Fi only" is on, and replaces one still waiting, so it is
/// never queued twice.
final class BackgroundBackupScheduler {
  new({
    required this._settings,
    required this._scheduler,
    required this._clock,
  });

  final SettingsRepository _settings;
  final BackgroundScheduler _scheduler;
  final Clock _clock;

  /// One settings read and at most one enqueue, so leaving the app is never
  /// slowed down. Never throws.
  Future<void> onAppHidden() async {
    try {
      final s = await _settings.load();
      final now = _clock.now().toUtc().millisecondsSinceEpoch;
      final enqueue = BackgroundBackupTrigger.shouldEnqueue(
        signedIn: s.backupAccountEmail != null,
        frequency: s.autoBackupFrequency,
        onboardingDone: s.onboardingDone,
        changed: ChangeCounter.changed(
          current: s.dataChangeCounter,
          backedUp: s.backedUpChangeCounter,
        ),
        lastBackgroundBackupAt: s.lastBackgroundBackupAt,
        nowMs: now,
      );
      if (!enqueue) return;
      await _settings.setLastBackgroundBackupAt(now);
      await _scheduler.enqueueOnce(
        backgroundBackupTaskName,
        network: s.autoBackupWifiOnly
            ? NetworkRequirement.unmetered
            : NetworkRequirement.connected,
      );
    } on Object {
      // The scheduled auto backup still runs.
    }
  }
}
