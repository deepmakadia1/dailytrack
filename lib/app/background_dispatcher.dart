import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/app/firebase_setup.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart' show BackgroundTask;
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

/// App-wide jobs, checked before module jobs (feature 008 research R11).
final Map<String, BackgroundTask> coreBackgroundTasks = {
  autoBackupTaskName: runAutoBackup,
  // The one-off backup when the app is hidden (feature 010 research R6).
  backgroundBackupTaskName: runAutoBackup,
};

/// Runs the background task [name] (research R10): a core task, or one of
/// the enabled modules' `backgroundTasks`, with [container]'s reader.
/// Unknown tasks and tasks of disabled modules are done (`true`); a task
/// that throws returns `false`, so the OS retries with backoff.
Future<bool> runBackgroundTask(String name, ProviderContainer container) async {
  try {
    final core = coreBackgroundTasks[name];
    if (core != null) return await core(container.read);
    final settings = await container.read(settingsRepositoryProvider).load();
    final modules = container.read(moduleRegistryProvider).visible(settings);
    for (final module in modules) {
      final task = module.backgroundTasks[name];
      if (task != null) return await task(container.read);
    }
    return true;
  } on Object {
    return false;
  }
}

/// WorkManager's entry point, in its own isolate (research R10). Builds
/// the same container as the app, so the generator writes through the
/// shared database, and disposes it when the task is done.
// Platform entry point: exercised on a device (quickstart §4 step 7).
// coverage:ignore-start
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    await startFirebase();
    final container = ProviderContainer(overrides: productionOverrides());
    try {
      try {
        await container.read(notificationServiceProvider).initialize();
      } on Object {
        // Alerts are optional; the job still runs.
      }
      final done = await runBackgroundTask(task, container);
      // A job may have written data the widget shows (feature 008 R19).
      await container.read(glanceRefresherProvider).refreshNow();
      return done;
    } finally {
      container.dispose();
    }
  });
}
// coverage:ignore-end
