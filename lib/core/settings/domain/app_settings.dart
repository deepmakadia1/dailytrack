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
  }) = _AppSettings;
}

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
