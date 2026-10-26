import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/domain/auto_backup_policy.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// WorkManager name of the auto backup job (a core task, run by the
/// background dispatcher before module tasks; feature 008 research R11).
const String autoBackupTaskName = 'core.autoBackup';

/// Registers or cancels the auto backup job to match [s] (FR-018, FR-019):
/// on only with a signed-in account; "Wi-Fi only" waits for an unmetered
/// network, so waiting never counts as a failure. Off also cancels a
/// waiting background backup (feature 010). Call it when the schedule
/// changes; re-registering restarts the period.
Future<void> syncAutoBackupSchedule(
  AppSettings s,
  BackgroundScheduler scheduler,
) async {
  final period = s.autoBackupFrequency.period;
  if (period == null || s.backupAccountEmail == null) {
    await scheduler.cancel(autoBackupTaskName);
    await scheduler.cancel(backgroundBackupTaskName);
    return;
  }
  await scheduler.ensurePeriodic(
    autoBackupTaskName,
    every: period,
    network: s.autoBackupWifiOnly
        ? NetworkRequirement.unmetered
        : NetworkRequirement.connected,
  );
}
