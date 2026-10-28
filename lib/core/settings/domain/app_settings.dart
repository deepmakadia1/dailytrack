import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Typed view of the `settings` table with defaults (data-model.md §1).
/// Pure Dart: no Flutter imports (Constitution II).
@freezed
abstract class AppSettings with _$AppSettings {
  const factory({
    /// `en`, `hi`, `gu`, or null to follow the device.
    String? locale,
    @Default('INR') String currencyCode,
    @Default('system') String themeMode,
    @Default('default') String selectedTheme,

    /// 1 = Monday … 7 = Sunday.
    @Default(1) int firstDayOfWeek,
    @Default(false) bool lockEnabled,
    @Default(false) bool biometricEnabled,

    /// Enabled module ids. Order is ignored; see [moduleOrder].
    @Default(['expense', 'habit']) List<String> enabledModules,

    /// Every registered module id, in the user's order (SET-06).
    @Default(['expense', 'habit']) List<String> moduleOrder,
    @Default(false) bool onboardingDone,
    String? adConsentStatus,

    /// UTC epoch milliseconds.
    int? lastBackupAt,
    @Default(false) bool removeAdsPurchased,

    /// Notifications master switch (SET-01 toggle in T3.1).
    @Default(true) bool notificationsEnabled,

    /// "Budget alerts" setting (SET-01 toggle in T3.1, FR-018).
    @Default(true) bool budgetAlertsEnabled,

    /// "Habit reminders" setting (SET-01 toggle in T3.1, feature 005 R17).
    @Default(true) bool habitRemindersEnabled,

    /// Dev-flavor "Unlock all features (debug)". Ignored in prod (FR-041).
    @Default(false) bool debugUnlockAll,

    /// The latest time the app has seen, UTC epoch milliseconds. Only ever
    /// raised, so moving the clock back never revives an expired unlock
    /// (FR-038).
    int? latestSeenAt,

    /// Local `yyyy-MM-dd` day of the stored DSH-01 insight pick. Written
    /// together with [dailyInsightId] (feature 006 research R6).
    String? dailyInsightDate,

    /// Rule id of the stored DSH-01 insight pick.
    String? dailyInsightId,

    /// The DSH-01 Coming soon card was dismissed for good.
    @Default(false) bool homeComingSoonDismissed,

    /// Full-date format, one of [dateFormatIds] (SET-01, feature 007 R13).
    @Default('dMMMy') String dateFormat,

    /// Daily summary reminder time, local `HH:mm` (SET-01). Stored only
    /// until T3.4 schedules the reminder.
    @Default('21:00') String dailySummaryTime,

    /// SET-05 "Lock after", one of [lockAfterOptions] (seconds).
    @Default(60) int lockAfterSeconds,

    /// SET-05 "Hide app content in recents" (`FLAG_SECURE` app-wide).
    @Default(false) bool hideInRecents,

    /// SET-04 font size, one of [fontSizeIds].
    @Default('default') String fontSize,

    /// Where the last backup went (SET-02 Last backup; feature 008
    /// data-model §1). Written with [lastBackupAt].
    BackupLocation? lastBackupLocation,

    /// Size of the last backup file in bytes.
    int? lastBackupSizeBytes,

    /// SET-02 "Encrypt backup". True only while the password is stored
    /// (feature 008 research R4).
    @Default(false) bool backupEncrypt,

    /// SET-02 "Include receipt images".
    @Default(false) bool backupIncludeReceipts,

    /// The connected Google account, for display (feature 008 research R10).
    String? backupAccountEmail,

    /// SET-02 Auto backup (FR-018). Needs [backupAccountEmail].
    @Default(AutoBackupFrequency.off) AutoBackupFrequency autoBackupFrequency,

    /// SET-02 "Wi-Fi only" for auto backup (FR-019).
    @Default(true) bool autoBackupWifiOnly,

    /// UTC ms of the last successful auto backup (catch-up, research R11).
    int? lastAutoBackupAt,

    /// Auto backups that failed in a row (FR-020).
    @Default(0) int autoBackupFailures,

    /// The "backup failing" notification was shown for this streak.
    @Default(false) bool autoBackupFailureNotified,

    /// SET-05 "Show data on widget": amounts and habit names on the home
    /// screen widget while the app lock is on (FR-047).
    @Default(false) bool showDataOnWidget,

    /// The IANA zone seen at the last app open or time zone trigger, so a
    /// change reschedules notifications (FR-041, research R21).
    String? deviceTimeZoneId,

    /// First start of this install, UTC ms: the 2-day interstitial rule
    /// (spec §11). Kept by Erase all data; never in backups (feature 009
    /// data-model §1).
    int? adsInstallAt,

    /// When the last interstitial was shown, UTC ms.
    int? adsLastInterstitialAt,

    /// Local `yyyy-MM-dd` that [adsInterstitialsToday] counts for.
    String? adsInterstitialDay,

    /// Interstitials shown on [adsInterstitialDay].
    @Default(0) int adsInterstitialsToday,

    /// Local day the last app session started on (first session of the day).
    String? adsLastSessionDay,

    /// Local `yyyy-MM-dd` that [rewardedCounts] counts for (FR-053).
    String? rewardedDay,

    /// Rewards earned on [rewardedDay], by feature key storage text.
    @Default({}) Map<String, int> rewardedCounts,

    /// Online starts in a row that reported Pro not owned, 0–2 (feature 009
    /// clarification Q1).
    @Default(0) int proNotOwnedStreak,

    /// A Pro payment is pending in Google Play.
    @Default(false) bool proPurchasePending,

    /// Pro was reported not owned twice: removed at the next cold start, so
    /// locks and ads return together (analysis I1).
    @Default(false) bool proRemovalPending,

    // Feature 010 (data-model §1). None of these is ever restored.

    /// The signed-in account's name and photo, for ACC-01 (FR-003).
    String? accountDisplayName,
    String? accountPhotoUrl,

    /// Copy of the no-backup device ID file (research R4).
    String? deviceId,

    /// Raised only by SQLite triggers on writes to backed-up data
    /// (research R5).
    @Default(0) int dataChangeCounter,

    /// [dataChangeCounter] inside the snapshot of the last successful
    /// Drive backup.
    @Default(0) int backedUpChangeCounter,

    /// UTC ms of the last background backup request (15-minute rule).
    int? lastBackgroundBackupAt,

    /// `createdAt` (UTC ms) and device of the newest Drive backup this
    /// phone made or has seen (FR-040).
    int? lastKnownDriveBackupAt,
    String? lastKnownDriveBackupDeviceId,

    /// Auto backup stopped by a newer backup from another phone (FR-038).
    @Default(false) bool autoBackupPausedByConflict,

    /// The pause notification was shown for this pause.
    @Default(false) bool autoBackupPauseNotified,

    /// Show the "Finish setting up" sheet once on Home: after every login
    /// on AUTH-01 and after a restore onto an empty phone (feature 011
    /// research R10).
    @Default(false) bool finishSetupPending,

    /// How the user chose to keep their data on AUTH-01 (spec §4, feature
    /// 011 research R1). Never backed up.
    @Default(AuthMode.none) AuthMode authMode,

    /// UTC ms until which a backup holds the lease, in any isolate: a
    /// read-only view of `BackupCoordinator.leaseKey` ("Backing up…",
    /// feature 011 research R11). No setter; only the coordinator writes it.
    int? backupLeaseUntil,
  }) = _AppSettings;
}

/// The sign-in mode (spec §4): no login chosen yet (AUTH-01 shows), a
/// guest whose data stays on this phone, or signed in with Google.
enum AuthMode { none, guest, google }

/// Where a backup was saved (SET-02 Last backup).
enum BackupLocation { device, drive }

/// SET-02 Auto backup options (FR-018).
enum AutoBackupFrequency { off, daily, weekly }

/// What SYS-02 saves when the user taps "Get started" or "Skip".
@freezed
abstract class OnboardingChoices with _$OnboardingChoices {
  const factory({
    required String? locale,
    required String currencyCode,
    required List<String> moduleOrder,
    required List<String> enabledModules,
  }) = _OnboardingChoices;
}

/// Thrown when a write would leave no module enabled.
final class LastModuleError implements Exception {
  const new();

  @override
  String toString() => 'LastModuleError: at least one module must stay enabled';
}

/// Locales the app ships (spec §1).
const List<String> supportedLanguageCodes = ['en', 'hi', 'gu'];

/// Allowed `themeMode` values (SET-04).
const List<String> themeModeIds = ['system', 'light', 'dark'];

/// Color theme ids in catalog order (SET-04, feature 007 data-model §4).
/// Mirrors `appColorThemes` in `core/theme/color_themes.dart`; kept here so
/// the settings codec stays free of theme imports.
const List<String> colorThemeIds = [
  'default',
  'indigo',
  'saffron',
  'forest',
  'rose',
  'midnight',
  'ocean',
  'mono',
];

/// Allowed `fontSize` values (SET-04).
const List<String> fontSizeIds = ['default', 'large'];

/// Allowed `dateFormat` values (SET-01); patterns in `FullDateFormat`.
const List<String> dateFormatIds = ['dMMMy', 'ddMMy', 'mmddy', 'iso'];

/// Allowed first days of week: Monday, Saturday, Sunday (SET-01).
const List<int> firstDayOfWeekOptions = [1, 6, 7];

/// Allowed "Lock after" values in seconds (SET-05).
const List<int> lockAfterOptions = [0, 60, 300];

/// True for a two-digit local `HH:mm` time of day.
bool isValidTimeOfDay(String value) =>
    RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);
