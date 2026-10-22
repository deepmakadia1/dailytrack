import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// How often each Auto backup option runs (FR-018).
extension AutoBackupPeriod on AutoBackupFrequency {
  /// The WorkManager period; null when off.
  Duration? get period => switch (this) {
    AutoBackupFrequency.off => null,
    AutoBackupFrequency.daily => const Duration(hours: 24),
    AutoBackupFrequency.weekly => const Duration(days: 7),
  };
}

/// The consecutive-failure counter after one auto backup run (FR-020,
/// data-model §9).
final class AutoBackupCounter {
  const new({required this.failures, required this.notified});

  final int failures;

  /// The "backup failing" notification has been shown for this streak.
  final bool notified;
}

/// Pure rules for auto backup (feature 008 research R11). No Flutter.
abstract final class AutoBackupPolicy {
  /// Failures in a row before the user is told.
  static const int failuresBeforeNotice = 3;

  /// How late a scheduled backup may be before the app runs one itself on
  /// open (the background run may be unable to sign in).
  static const Duration catchUpGrace = Duration(hours: 6);

  /// The counter after a run, and whether to show the notification now:
  /// once per streak of failures, on the third.
  static (AutoBackupCounter, bool) afterRun(
    AutoBackupCounter current, {
    required bool success,
  }) {
    if (success) {
      return (const AutoBackupCounter(failures: 0, notified: false), false);
    }
    final failures = current.failures + 1;
    final notifyNow = !current.notified && failures >= failuresBeforeNotice;
    return (
      AutoBackupCounter(
        failures: failures,
        notified: current.notified || notifyNow,
      ),
      notifyNow,
    );
  }

  /// True when auto backup is on with an account, and the last auto backup
  /// is older than its period plus [catchUpGrace] (or there is none).
  static bool catchUpDue({
    required AutoBackupFrequency frequency,
    required bool connected,
    required int? lastAutoBackupAtMs,
    required int nowMs,
  }) {
    final period = frequency.period;
    if (period == null || !connected) return false;
    if (lastAutoBackupAtMs == null) return true;
    return nowMs - lastAutoBackupAtMs > (period + catchUpGrace).inMilliseconds;
  }
}
