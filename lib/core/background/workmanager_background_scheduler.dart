import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:workmanager/workmanager.dart';

// Plugin calls: exercised on a device (quickstart §4 step 7), not in unit
// tests. With `app/background_dispatcher.dart`, the only importer of
// `workmanager` (layering scan).
// coverage:ignore-start

/// Registers [dispatcher] (a top-level `@pragma('vm:entry-point')` function)
/// as the background entry point. Called once in `main()`.
Future<void> initializeBackground(Function dispatcher) =>
    Workmanager().initialize(dispatcher);

/// [BackgroundScheduler] over Android WorkManager (research R10): a 24 h
/// periodic task with no network constraint and the keep policy.
final class WorkmanagerBackgroundScheduler implements BackgroundScheduler {
  const new();

  @override
  Future<void> ensureDaily(String uniqueName) =>
      Workmanager().registerPeriodicTask(
        uniqueName,
        uniqueName,
        frequency: const Duration(hours: 24),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );

  @override
  Future<void> ensurePeriodic(
    String uniqueName, {
    required Duration every,
    NetworkRequirement network = NetworkRequirement.none,
  }) => Workmanager().registerPeriodicTask(
    uniqueName,
    uniqueName,
    frequency: every,
    constraints: Constraints(networkType: _networkType(network)),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );

  @override
  Future<void> enqueueOnce(
    String uniqueName, {
    NetworkRequirement network = NetworkRequirement.none,
  }) => Workmanager().registerOneOffTask(
    uniqueName,
    uniqueName,
    constraints: Constraints(networkType: _networkType(network)),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  @override
  Future<void> cancel(String uniqueName) =>
      Workmanager().cancelByUniqueName(uniqueName);

  static NetworkType _networkType(NetworkRequirement network) =>
      switch (network) {
        NetworkRequirement.none => NetworkType.notRequired,
        NetworkRequirement.connected => NetworkType.connected,
        NetworkRequirement.unmetered => NetworkType.unmetered,
      };
}
// coverage:ignore-end
