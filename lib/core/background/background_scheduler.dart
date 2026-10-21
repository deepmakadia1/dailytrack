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

  Future<void> cancel(String uniqueName);
}
