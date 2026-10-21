import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

/// Runs the background task [name] (research R10): finds it among the
/// enabled modules' `backgroundTasks` and runs it with [container]'s
/// reader. Unknown tasks and tasks of disabled modules are done (`true`);
/// a task that throws returns `false`, so the OS retries with backoff.
Future<bool> runBackgroundTask(String name, ProviderContainer container) async {
  try {
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
    final container = ProviderContainer(overrides: productionOverrides());
    try {
      try {
        await container.read(notificationServiceProvider).initialize();
      } on Object {
        // Alerts are optional; the job still runs.
      }
      return await runBackgroundTask(task, container);
    } finally {
      container.dispose();
    }
  });
}
// coverage:ignore-end
