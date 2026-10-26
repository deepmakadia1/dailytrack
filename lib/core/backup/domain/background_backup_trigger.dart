import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// When going to the background starts a backup (spec §16 "On background",
/// FR-032, research R6). Pure; the caller passes the time.
abstract final class BackgroundBackupTrigger {
  /// The least time between two background backup requests.
  static const Duration minGap = Duration(minutes: 15);

  /// True only when signed in, Auto backup is not Off, onboarding is done,
  /// data changed, and the last request was at least [minGap] ago (or there
  /// was none). A last request in the future (the clock moved back) never
  /// blocks backups.
  static bool shouldEnqueue({
    required bool signedIn,
    required AutoBackupFrequency frequency,
    required bool onboardingDone,
    required bool changed,
    required int? lastBackgroundBackupAt,
    required int nowMs,
  }) {
    if (!signedIn || frequency == AutoBackupFrequency.off) return false;
    if (!onboardingDone || !changed) return false;
    final last = lastBackgroundBackupAt;
    if (last == null || last > nowMs) return true;
    return nowMs - last >= minGap.inMilliseconds;
  }
}
