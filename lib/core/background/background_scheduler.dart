import 'package:dailytrack/core/module/provider_reader.dart';

/// A module's background job (research R10): runs in the background isolate
/// with a fresh provider container. Returns false to ask the operating
/// system to retry later.
typedef BackgroundTask = Future<bool> Function(ProviderReader read);

/// Schedules daily background jobs (contracts/core_services.md). Pure Dart;
/// `WorkmanagerBackgroundScheduler` is the only implementation.
abstract interface class BackgroundScheduler {
  /// A periodic 24 h job named [uniqueName]; a no-op if already scheduled.
  Future<void> ensureDaily(String uniqueName);

  /// A periodic job every [every] that runs only with [network]
  /// (feature 008 research R11). Re-registering replaces the job and
  /// restarts its period, so call it only when the schedule changes.
  Future<void> ensurePeriodic(
    String uniqueName, {
    required Duration every,
    NetworkRequirement network = NetworkRequirement.none,
  });

  /// A one-off job named [uniqueName] that runs once [network] is there,
  /// replacing one still waiting (feature 010 research R6).
  Future<void> enqueueOnce(
    String uniqueName, {
    NetworkRequirement network = NetworkRequirement.none,
  });

  Future<void> cancel(String uniqueName);
}

/// The network a periodic job waits for. `unmetered` is Wi-Fi only.
enum NetworkRequirement { none, connected, unmetered }
