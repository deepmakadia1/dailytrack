import 'dart:async';

import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_open_runner.g.dart';

/// Runs every enabled module's `onAppOpen` hook on cold start and on each
/// resume (feature 003 research R10), and raises `latestSeenAt` for the
/// feature gate (FR-038). Failures are swallowed so they never affect the
/// UI, and a run is skipped while the previous one is still in flight.
final class AppOpenRunner {
  new(this._ref);

  final Ref _ref;
  Future<void>? _inFlight;

  bool get isRunning => _inFlight != null;

  /// Completes when this run (or the one already in flight) is done.
  Future<void> run() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<void> _run() async {
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      final now = _ref.read(clockProvider).now().toUtc();
      unawaited(
        settingsRepo
            .raiseLatestSeenAt(now.millisecondsSinceEpoch)
            .catchError((Object _) {}),
      );
      final settings = await settingsRepo.load();
      final modules = _ref.read(moduleRegistryProvider).visible(settings);
      for (final module in modules) {
        try {
          await module.onAppOpen(_ref.read);
        } on Object {
          // One module's failure never stops the others.
        }
      }
      await _checkTimeZone(settings.deviceTimeZoneId, modules);
      // An overdue auto backup runs now, unawaited (feature 008 R11).
      if (autoBackupCatchUpDue(settings, now.millisecondsSinceEpoch)) {
        unawaited(runAutoBackup(_ref.read, foreground: true));
      }
    } on Object {
      // App-open work is best effort; the next open retries.
    }
  }

  /// When the device zone differs from the last one seen, reschedules every
  /// notification for the new zone, for OEMs that drop the system broadcast
  /// (FR-041, feature 008 research R21). The first open only records it.
  Future<void> _checkTimeZone(
    String? stored,
    List<TrackerModule> modules,
  ) async {
    try {
      final zone = await _ref.read(timeZoneSourceProvider).deviceZoneId();
      if (zone == null || zone == stored) return;
      if (stored != null) {
        for (final module in modules) {
          try {
            await module.onNotificationSettingsChanged(_ref.read);
          } on Object {
            // One module's failure never stops the others.
          }
        }
        await _ref.read(dailySummarySchedulerProvider).reschedule();
      }
      await recordTimeZone(_ref.read);
    } on Object {
      // Checked again on the next open.
    }
  }
}

@Riverpod(keepAlive: true)
AppOpenRunner appOpenRunner(Ref ref) => AppOpenRunner(ref);
