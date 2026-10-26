import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// Read and write user settings (FR-013, contracts/services.md).
/// Screens use this only through `settingsRepositoryProvider`.
abstract interface class SettingsRepository {
  /// Missing or unreadable keys fall back to their defaults; never throws on
  /// bad JSON.
  Future<AppSettings> load();

  /// Emits the current settings, then again after every write.
  Stream<AppSettings> watch();

  /// `null` follows the device language. Unsupported codes are ignored.
  Future<void> setLocale(String? languageCode);

  Future<void> setCurrency(String code);

  /// Throws [LastModuleError] if [enabled] is empty.
  Future<void> setModules({
    required List<String> order,
    required List<String> enabled,
  });

  /// Writes locale, currency, modules and `onboardingDone = true` atomically.
  Future<void> completeOnboarding(OnboardingChoices choices);

  /// Exactly-once seeding markers (`seed.<id>`), used by SeedRunner inside
  /// its transaction.
  Future<bool> isSeeded(String seederId);

  Future<void> markSeeded(String seederId);

  /// Notifications master switch. No UI until T3.1.
  Future<void> setNotificationsEnabled({required bool enabled});

  /// "Budget alerts" setting. No UI until T3.1.
  Future<void> setBudgetAlertsEnabled({required bool enabled});

  /// "Habit reminders" setting. No UI until T3.1.
  Future<void> setHabitRemindersEnabled({required bool enabled});

  /// Dev-flavor debug switch (FR-041).
  Future<void> setDebugUnlockAll({required bool enabled});

  /// Raises `latestSeenAt` to [utcMs]; never lowers it (FR-038).
  Future<void> raiseLatestSeenAt(int utcMs);

  /// Stores the DSH-01 daily insight pick: both keys in one transaction, so
  /// they never disagree (feature 006 data-model.md §1).
  Future<void> setDailyInsight({
    required String dateKey,
    required String ruleId,
  });

  /// Hides (or, from Undo, shows again) the DSH-01 Coming soon card.
  Future<void> setHomeComingSoonDismissed({required bool dismissed});

  // T3.1 setters (feature 007 data-model.md §1). Each one ignores a value
  // outside its allowed set, like [setLocale].

  /// One of [themeModeIds].
  Future<void> setThemeMode(String mode);

  /// One of [colorThemeIds]. Stored even when the theme is locked; the app
  /// shows Default teal until it is unlocked (FR-020).
  Future<void> setSelectedTheme(String id);

  /// One of [fontSizeIds].
  Future<void> setFontSize(String size);

  /// One of [firstDayOfWeekOptions].
  Future<void> setFirstDayOfWeek(int day);

  /// One of [dateFormatIds].
  Future<void> setDateFormat(String format);

  /// Local `HH:mm` ([isValidTimeOfDay]).
  Future<void> setDailySummaryTime(String hhmm);

  /// Written only by `LockService`, after the credential (feature 007 R6).
  Future<void> setLockEnabled({required bool enabled});

  /// Written only by `LockService`, after a successful prompt.
  Future<void> setBiometricEnabled({required bool enabled});

  /// One of [lockAfterOptions].
  Future<void> setLockAfterSeconds(int seconds);

  Future<void> setHideInRecents({required bool enabled});

  // Feature 008 (SET-02, data-model §1).

  /// Records a finished backup: time, location, and size in one transaction.
  Future<void> setLastBackup({
    required int at,
    required BackupLocation location,
    required int sizeBytes,
  });

  /// SET-02 "Encrypt backup". Turn on only after the password is stored.
  Future<void> setBackupEncrypt({required bool enabled});

  /// SET-02 "Include receipt images".
  Future<void> setBackupIncludeReceipts({required bool enabled});

  /// The connected Google account, or null after disconnect.
  Future<void> setBackupAccountEmail(String? email);

  /// SET-02 Auto backup and "Wi-Fi only".
  Future<void> setAutoBackup({
    required AutoBackupFrequency frequency,
    required bool wifiOnly,
  });

  /// UTC ms of the last successful auto backup.
  Future<void> setLastAutoBackupAt(int at);

  /// The auto backup failure streak (FR-020).
  Future<void> setAutoBackupFailures({
    required int failures,
    required bool notified,
  });

  /// SET-05 "Show data on widget" (FR-047).
  Future<void> setShowDataOnWidget({required bool enabled});

  /// The device zone last seen (research R21).
  Future<void> setDeviceTimeZoneId(String id);

  /// Records the install time for the interstitial cap, only if none is
  /// stored yet (feature 009 data-model §1).
  Future<void> setAdsInstallAtIfMissing(int utcMs);

  /// An interstitial was shown at [at] (UTC ms); [countToday] is the count
  /// for local day [dayKey]. Written together.
  Future<void> recordInterstitialShown({
    required int at,
    required String dayKey,
    required int countToday,
  });

  /// The local day the current app session started on.
  Future<void> setAdsLastSessionDay(String dayKey);

  /// Dev-only "Reset ad counters": sets the install time and clears the
  /// last interstitial and today's count.
  Future<void> resetAdCounters({required int installAt});

  /// Pro ownership (feature 009 data-model §5): [owned] is
  /// `removeAdsPurchased`. All four are written together.
  Future<void> setProState({
    required bool owned,
    required int notOwnedStreak,
    required bool pending,
    bool removalPending = false,
  });

  /// Rewards earned on local day [dayKey], by feature key (FR-053).
  /// Written together.
  Future<void> setRewardedCounts({
    required String dayKey,
    required Map<String, int> counts,
  });

  // Feature 010 (data-model §1). `dataChangeCounter` has no setter: only
  // the SQLite triggers write it.

  /// The signed-in account (email, name, photo together), or null to clear
  /// all three.
  Future<void> setAccount(AccountProfile? profile);

  /// The settings copy of the device ID (research R4).
  Future<void> setDeviceIdCopy(String id);

  /// The change counter inside the last successful backup's snapshot.
  Future<void> setBackedUpChangeCounter(int value);

  /// UTC ms of the last background backup request, or null.
  Future<void> setLastBackgroundBackupAt(int? at);

  /// The newest Drive backup this phone made or has seen (FR-040). Both
  /// written together.
  Future<void> setLastKnownDriveBackup({
    required int? at,
    required String? deviceId,
  });

  /// The conflict pause and whether its notification was shown.
  Future<void> setAutoBackupPause({
    required bool paused,
    required bool notified,
  });

  /// Whether Home shows the "Finish setting up" sheet (research R13).
  Future<void> setFinishSetupPending({required bool pending});

  /// A module's own string state, stored as `module.<key>`, or null.
  Future<String?> readModuleState(String key);

  Future<void> writeModuleState(String key, String value);
}
