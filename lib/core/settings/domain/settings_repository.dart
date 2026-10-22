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

  /// A module's own string state, stored as `module.<key>`, or null.
  Future<String?> readModuleState(String key);

  Future<void> writeModuleState(String key, String value);
}
