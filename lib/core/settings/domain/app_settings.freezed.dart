// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

/// `en`, `hi`, `gu`, or null to follow the device.
 String? get locale; String get currencyCode; String get themeMode; String get selectedTheme;/// 1 = Monday … 7 = Sunday.
 int get firstDayOfWeek; bool get lockEnabled; bool get biometricEnabled;/// Enabled module ids. Order is ignored; see [moduleOrder].
 List<String> get enabledModules;/// Every registered module id, in the user's order (SET-06).
 List<String> get moduleOrder; bool get onboardingDone; String? get adConsentStatus;/// UTC epoch milliseconds.
 int? get lastBackupAt; bool get removeAdsPurchased;/// Notifications master switch (SET-01 toggle in T3.1).
 bool get notificationsEnabled;/// "Budget alerts" setting (SET-01 toggle in T3.1, FR-018).
 bool get budgetAlertsEnabled;/// "Habit reminders" setting (SET-01 toggle in T3.1, feature 005 R17).
 bool get habitRemindersEnabled;/// Dev-flavor "Unlock all features (debug)". Ignored in prod (FR-041).
 bool get debugUnlockAll;/// The latest time the app has seen, UTC epoch milliseconds. Only ever
/// raised, so moving the clock back never revives an expired unlock
/// (FR-038).
 int? get latestSeenAt;/// Local `yyyy-MM-dd` day of the stored DSH-01 insight pick. Written
/// together with [dailyInsightId] (feature 006 research R6).
 String? get dailyInsightDate;/// Rule id of the stored DSH-01 insight pick.
 String? get dailyInsightId;/// The DSH-01 Coming soon card was dismissed for good.
 bool get homeComingSoonDismissed;/// Full-date format, one of [dateFormatIds] (SET-01, feature 007 R13).
 String get dateFormat;/// Daily summary reminder time, local `HH:mm` (SET-01). Stored only
/// until T3.4 schedules the reminder.
 String get dailySummaryTime;/// SET-05 "Lock after", one of [lockAfterOptions] (seconds).
 int get lockAfterSeconds;/// SET-05 "Hide app content in recents" (`FLAG_SECURE` app-wide).
 bool get hideInRecents;/// SET-04 font size, one of [fontSizeIds].
 String get fontSize;/// Where the last backup went (SET-02 Last backup; feature 008
/// data-model §1). Written with [lastBackupAt].
 BackupLocation? get lastBackupLocation;/// Size of the last backup file in bytes.
 int? get lastBackupSizeBytes;/// SET-02 "Encrypt backup". True only while the password is stored
/// (feature 008 research R4).
 bool get backupEncrypt;/// SET-02 "Include receipt images".
 bool get backupIncludeReceipts;/// The connected Google account, for display (feature 008 research R10).
 String? get backupAccountEmail;/// SET-02 Auto backup (FR-018). Needs [backupAccountEmail].
 AutoBackupFrequency get autoBackupFrequency;/// SET-02 "Wi-Fi only" for auto backup (FR-019).
 bool get autoBackupWifiOnly;/// UTC ms of the last successful auto backup (catch-up, research R11).
 int? get lastAutoBackupAt;/// Auto backups that failed in a row (FR-020).
 int get autoBackupFailures;/// The "backup failing" notification was shown for this streak.
 bool get autoBackupFailureNotified;/// SET-05 "Show data on widget": amounts and habit names on the home
/// screen widget while the app lock is on (FR-047).
 bool get showDataOnWidget;/// The IANA zone seen at the last app open or time zone trigger, so a
/// change reschedules notifications (FR-041, research R21).
 String? get deviceTimeZoneId;/// First start of this install, UTC ms: the 2-day interstitial rule
/// (spec §11). Kept by Erase all data; never in backups (feature 009
/// data-model §1).
 int? get adsInstallAt;/// When the last interstitial was shown, UTC ms.
 int? get adsLastInterstitialAt;/// Local `yyyy-MM-dd` that [adsInterstitialsToday] counts for.
 String? get adsInterstitialDay;/// Interstitials shown on [adsInterstitialDay].
 int get adsInterstitialsToday;/// Local day the last app session started on (first session of the day).
 String? get adsLastSessionDay;/// Local `yyyy-MM-dd` that [rewardedCounts] counts for (FR-053).
 String? get rewardedDay;/// Rewards earned on [rewardedDay], by feature key storage text.
 Map<String, int> get rewardedCounts;/// Online starts in a row that reported Pro not owned, 0–2 (feature 009
/// clarification Q1).
 int get proNotOwnedStreak;/// A Pro payment is pending in Google Play.
 bool get proPurchasePending;/// Pro was reported not owned twice: removed at the next cold start, so
/// locks and ads return together (analysis I1).
 bool get proRemovalPending;/// The signed-in account's name and photo, for ACC-01 (FR-003).
 String? get accountDisplayName; String? get accountPhotoUrl;/// Copy of the no-backup device ID file (research R4).
 String? get deviceId;/// Raised only by SQLite triggers on writes to backed-up data
/// (research R5).
 int get dataChangeCounter;/// [dataChangeCounter] inside the snapshot of the last successful
/// Drive backup.
 int get backedUpChangeCounter;/// UTC ms of the last background backup request (15-minute rule).
 int? get lastBackgroundBackupAt;/// `createdAt` (UTC ms) and device of the newest Drive backup this
/// phone made or has seen (FR-040).
 int? get lastKnownDriveBackupAt; String? get lastKnownDriveBackupDeviceId;/// Auto backup stopped by a newer backup from another phone (FR-038).
 bool get autoBackupPausedByConflict;/// The pause notification was shown for this pause.
 bool get autoBackupPauseNotified;/// Show the "Finish setting up" sheet once on Home: a restore onto an
/// empty phone skipped the app lock step (research R13).
 bool get finishSetupPending;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.selectedTheme, _this.selectedTheme) || other.selectedTheme == _this.selectedTheme)&&(identical(other.firstDayOfWeek, _this.firstDayOfWeek) || other.firstDayOfWeek == _this.firstDayOfWeek)&&(identical(other.lockEnabled, _this.lockEnabled) || other.lockEnabled == _this.lockEnabled)&&(identical(other.biometricEnabled, _this.biometricEnabled) || other.biometricEnabled == _this.biometricEnabled)&&const DeepCollectionEquality().equals(other.enabledModules, _this.enabledModules)&&const DeepCollectionEquality().equals(other.moduleOrder, _this.moduleOrder)&&(identical(other.onboardingDone, _this.onboardingDone) || other.onboardingDone == _this.onboardingDone)&&(identical(other.adConsentStatus, _this.adConsentStatus) || other.adConsentStatus == _this.adConsentStatus)&&(identical(other.lastBackupAt, _this.lastBackupAt) || other.lastBackupAt == _this.lastBackupAt)&&(identical(other.removeAdsPurchased, _this.removeAdsPurchased) || other.removeAdsPurchased == _this.removeAdsPurchased)&&(identical(other.notificationsEnabled, _this.notificationsEnabled) || other.notificationsEnabled == _this.notificationsEnabled)&&(identical(other.budgetAlertsEnabled, _this.budgetAlertsEnabled) || other.budgetAlertsEnabled == _this.budgetAlertsEnabled)&&(identical(other.habitRemindersEnabled, _this.habitRemindersEnabled) || other.habitRemindersEnabled == _this.habitRemindersEnabled)&&(identical(other.debugUnlockAll, _this.debugUnlockAll) || other.debugUnlockAll == _this.debugUnlockAll)&&(identical(other.latestSeenAt, _this.latestSeenAt) || other.latestSeenAt == _this.latestSeenAt)&&(identical(other.dailyInsightDate, _this.dailyInsightDate) || other.dailyInsightDate == _this.dailyInsightDate)&&(identical(other.dailyInsightId, _this.dailyInsightId) || other.dailyInsightId == _this.dailyInsightId)&&(identical(other.homeComingSoonDismissed, _this.homeComingSoonDismissed) || other.homeComingSoonDismissed == _this.homeComingSoonDismissed)&&(identical(other.dateFormat, _this.dateFormat) || other.dateFormat == _this.dateFormat)&&(identical(other.dailySummaryTime, _this.dailySummaryTime) || other.dailySummaryTime == _this.dailySummaryTime)&&(identical(other.lockAfterSeconds, _this.lockAfterSeconds) || other.lockAfterSeconds == _this.lockAfterSeconds)&&(identical(other.hideInRecents, _this.hideInRecents) || other.hideInRecents == _this.hideInRecents)&&(identical(other.fontSize, _this.fontSize) || other.fontSize == _this.fontSize)&&(identical(other.lastBackupLocation, _this.lastBackupLocation) || other.lastBackupLocation == _this.lastBackupLocation)&&(identical(other.lastBackupSizeBytes, _this.lastBackupSizeBytes) || other.lastBackupSizeBytes == _this.lastBackupSizeBytes)&&(identical(other.backupEncrypt, _this.backupEncrypt) || other.backupEncrypt == _this.backupEncrypt)&&(identical(other.backupIncludeReceipts, _this.backupIncludeReceipts) || other.backupIncludeReceipts == _this.backupIncludeReceipts)&&(identical(other.backupAccountEmail, _this.backupAccountEmail) || other.backupAccountEmail == _this.backupAccountEmail)&&(identical(other.autoBackupFrequency, _this.autoBackupFrequency) || other.autoBackupFrequency == _this.autoBackupFrequency)&&(identical(other.autoBackupWifiOnly, _this.autoBackupWifiOnly) || other.autoBackupWifiOnly == _this.autoBackupWifiOnly)&&(identical(other.lastAutoBackupAt, _this.lastAutoBackupAt) || other.lastAutoBackupAt == _this.lastAutoBackupAt)&&(identical(other.autoBackupFailures, _this.autoBackupFailures) || other.autoBackupFailures == _this.autoBackupFailures)&&(identical(other.autoBackupFailureNotified, _this.autoBackupFailureNotified) || other.autoBackupFailureNotified == _this.autoBackupFailureNotified)&&(identical(other.showDataOnWidget, _this.showDataOnWidget) || other.showDataOnWidget == _this.showDataOnWidget)&&(identical(other.deviceTimeZoneId, _this.deviceTimeZoneId) || other.deviceTimeZoneId == _this.deviceTimeZoneId)&&(identical(other.adsInstallAt, _this.adsInstallAt) || other.adsInstallAt == _this.adsInstallAt)&&(identical(other.adsLastInterstitialAt, _this.adsLastInterstitialAt) || other.adsLastInterstitialAt == _this.adsLastInterstitialAt)&&(identical(other.adsInterstitialDay, _this.adsInterstitialDay) || other.adsInterstitialDay == _this.adsInterstitialDay)&&(identical(other.adsInterstitialsToday, _this.adsInterstitialsToday) || other.adsInterstitialsToday == _this.adsInterstitialsToday)&&(identical(other.adsLastSessionDay, _this.adsLastSessionDay) || other.adsLastSessionDay == _this.adsLastSessionDay)&&(identical(other.rewardedDay, _this.rewardedDay) || other.rewardedDay == _this.rewardedDay)&&const DeepCollectionEquality().equals(other.rewardedCounts, _this.rewardedCounts)&&(identical(other.proNotOwnedStreak, _this.proNotOwnedStreak) || other.proNotOwnedStreak == _this.proNotOwnedStreak)&&(identical(other.proPurchasePending, _this.proPurchasePending) || other.proPurchasePending == _this.proPurchasePending)&&(identical(other.proRemovalPending, _this.proRemovalPending) || other.proRemovalPending == _this.proRemovalPending)&&(identical(other.accountDisplayName, _this.accountDisplayName) || other.accountDisplayName == _this.accountDisplayName)&&(identical(other.accountPhotoUrl, _this.accountPhotoUrl) || other.accountPhotoUrl == _this.accountPhotoUrl)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.dataChangeCounter, _this.dataChangeCounter) || other.dataChangeCounter == _this.dataChangeCounter)&&(identical(other.backedUpChangeCounter, _this.backedUpChangeCounter) || other.backedUpChangeCounter == _this.backedUpChangeCounter)&&(identical(other.lastBackgroundBackupAt, _this.lastBackgroundBackupAt) || other.lastBackgroundBackupAt == _this.lastBackgroundBackupAt)&&(identical(other.lastKnownDriveBackupAt, _this.lastKnownDriveBackupAt) || other.lastKnownDriveBackupAt == _this.lastKnownDriveBackupAt)&&(identical(other.lastKnownDriveBackupDeviceId, _this.lastKnownDriveBackupDeviceId) || other.lastKnownDriveBackupDeviceId == _this.lastKnownDriveBackupDeviceId)&&(identical(other.autoBackupPausedByConflict, _this.autoBackupPausedByConflict) || other.autoBackupPausedByConflict == _this.autoBackupPausedByConflict)&&(identical(other.autoBackupPauseNotified, _this.autoBackupPauseNotified) || other.autoBackupPauseNotified == _this.autoBackupPauseNotified)&&(identical(other.finishSetupPending, _this.finishSetupPending) || other.finishSetupPending == _this.finishSetupPending));
}


@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hashAll([runtimeType,_this.locale,_this.currencyCode,_this.themeMode,_this.selectedTheme,_this.firstDayOfWeek,_this.lockEnabled,_this.biometricEnabled,const DeepCollectionEquality().hash(_this.enabledModules),const DeepCollectionEquality().hash(_this.moduleOrder),_this.onboardingDone,_this.adConsentStatus,_this.lastBackupAt,_this.removeAdsPurchased,_this.notificationsEnabled,_this.budgetAlertsEnabled,_this.habitRemindersEnabled,_this.debugUnlockAll,_this.latestSeenAt,_this.dailyInsightDate,_this.dailyInsightId,_this.homeComingSoonDismissed,_this.dateFormat,_this.dailySummaryTime,_this.lockAfterSeconds,_this.hideInRecents,_this.fontSize,_this.lastBackupLocation,_this.lastBackupSizeBytes,_this.backupEncrypt,_this.backupIncludeReceipts,_this.backupAccountEmail,_this.autoBackupFrequency,_this.autoBackupWifiOnly,_this.lastAutoBackupAt,_this.autoBackupFailures,_this.autoBackupFailureNotified,_this.showDataOnWidget,_this.deviceTimeZoneId,_this.adsInstallAt,_this.adsLastInterstitialAt,_this.adsInterstitialDay,_this.adsInterstitialsToday,_this.adsLastSessionDay,_this.rewardedDay,const DeepCollectionEquality().hash(_this.rewardedCounts),_this.proNotOwnedStreak,_this.proPurchasePending,_this.proRemovalPending,_this.accountDisplayName,_this.accountPhotoUrl,_this.deviceId,_this.dataChangeCounter,_this.backedUpChangeCounter,_this.lastBackgroundBackupAt,_this.lastKnownDriveBackupAt,_this.lastKnownDriveBackupDeviceId,_this.autoBackupPausedByConflict,_this.autoBackupPauseNotified,_this.finishSetupPending]);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(locale: ${_this.locale}, currencyCode: ${_this.currencyCode}, themeMode: ${_this.themeMode}, selectedTheme: ${_this.selectedTheme}, firstDayOfWeek: ${_this.firstDayOfWeek}, lockEnabled: ${_this.lockEnabled}, biometricEnabled: ${_this.biometricEnabled}, enabledModules: ${_this.enabledModules}, moduleOrder: ${_this.moduleOrder}, onboardingDone: ${_this.onboardingDone}, adConsentStatus: ${_this.adConsentStatus}, lastBackupAt: ${_this.lastBackupAt}, removeAdsPurchased: ${_this.removeAdsPurchased}, notificationsEnabled: ${_this.notificationsEnabled}, budgetAlertsEnabled: ${_this.budgetAlertsEnabled}, habitRemindersEnabled: ${_this.habitRemindersEnabled}, debugUnlockAll: ${_this.debugUnlockAll}, latestSeenAt: ${_this.latestSeenAt}, dailyInsightDate: ${_this.dailyInsightDate}, dailyInsightId: ${_this.dailyInsightId}, homeComingSoonDismissed: ${_this.homeComingSoonDismissed}, dateFormat: ${_this.dateFormat}, dailySummaryTime: ${_this.dailySummaryTime}, lockAfterSeconds: ${_this.lockAfterSeconds}, hideInRecents: ${_this.hideInRecents}, fontSize: ${_this.fontSize}, lastBackupLocation: ${_this.lastBackupLocation}, lastBackupSizeBytes: ${_this.lastBackupSizeBytes}, backupEncrypt: ${_this.backupEncrypt}, backupIncludeReceipts: ${_this.backupIncludeReceipts}, backupAccountEmail: ${_this.backupAccountEmail}, autoBackupFrequency: ${_this.autoBackupFrequency}, autoBackupWifiOnly: ${_this.autoBackupWifiOnly}, lastAutoBackupAt: ${_this.lastAutoBackupAt}, autoBackupFailures: ${_this.autoBackupFailures}, autoBackupFailureNotified: ${_this.autoBackupFailureNotified}, showDataOnWidget: ${_this.showDataOnWidget}, deviceTimeZoneId: ${_this.deviceTimeZoneId}, adsInstallAt: ${_this.adsInstallAt}, adsLastInterstitialAt: ${_this.adsLastInterstitialAt}, adsInterstitialDay: ${_this.adsInterstitialDay}, adsInterstitialsToday: ${_this.adsInterstitialsToday}, adsLastSessionDay: ${_this.adsLastSessionDay}, rewardedDay: ${_this.rewardedDay}, rewardedCounts: ${_this.rewardedCounts}, proNotOwnedStreak: ${_this.proNotOwnedStreak}, proPurchasePending: ${_this.proPurchasePending}, proRemovalPending: ${_this.proRemovalPending}, accountDisplayName: ${_this.accountDisplayName}, accountPhotoUrl: ${_this.accountPhotoUrl}, deviceId: ${_this.deviceId}, dataChangeCounter: ${_this.dataChangeCounter}, backedUpChangeCounter: ${_this.backedUpChangeCounter}, lastBackgroundBackupAt: ${_this.lastBackgroundBackupAt}, lastKnownDriveBackupAt: ${_this.lastKnownDriveBackupAt}, lastKnownDriveBackupDeviceId: ${_this.lastKnownDriveBackupDeviceId}, autoBackupPausedByConflict: ${_this.autoBackupPausedByConflict}, autoBackupPauseNotified: ${_this.autoBackupPauseNotified}, finishSetupPending: ${_this.finishSetupPending})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String? locale, String currencyCode, String themeMode, String selectedTheme, int firstDayOfWeek, bool lockEnabled, bool biometricEnabled, List<String> enabledModules, List<String> moduleOrder, bool onboardingDone, String? adConsentStatus, int? lastBackupAt, bool removeAdsPurchased, bool notificationsEnabled, bool budgetAlertsEnabled, bool habitRemindersEnabled, bool debugUnlockAll, int? latestSeenAt, String? dailyInsightDate, String? dailyInsightId, bool homeComingSoonDismissed, String dateFormat, String dailySummaryTime, int lockAfterSeconds, bool hideInRecents, String fontSize, BackupLocation? lastBackupLocation, int? lastBackupSizeBytes, bool backupEncrypt, bool backupIncludeReceipts, String? backupAccountEmail, AutoBackupFrequency autoBackupFrequency, bool autoBackupWifiOnly, int? lastAutoBackupAt, int autoBackupFailures, bool autoBackupFailureNotified, bool showDataOnWidget, String? deviceTimeZoneId, int? adsInstallAt, int? adsLastInterstitialAt, String? adsInterstitialDay, int adsInterstitialsToday, String? adsLastSessionDay, String? rewardedDay, Map<String, int> rewardedCounts, int proNotOwnedStreak, bool proPurchasePending, bool proRemovalPending, String? accountDisplayName, String? accountPhotoUrl, String? deviceId, int dataChangeCounter, int backedUpChangeCounter, int? lastBackgroundBackupAt, int? lastKnownDriveBackupAt, String? lastKnownDriveBackupDeviceId, bool autoBackupPausedByConflict, bool autoBackupPauseNotified, bool finishSetupPending
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? currencyCode = null,Object? themeMode = null,Object? selectedTheme = null,Object? firstDayOfWeek = null,Object? lockEnabled = null,Object? biometricEnabled = null,Object? enabledModules = null,Object? moduleOrder = null,Object? onboardingDone = null,Object? adConsentStatus = freezed,Object? lastBackupAt = freezed,Object? removeAdsPurchased = null,Object? notificationsEnabled = null,Object? budgetAlertsEnabled = null,Object? habitRemindersEnabled = null,Object? debugUnlockAll = null,Object? latestSeenAt = freezed,Object? dailyInsightDate = freezed,Object? dailyInsightId = freezed,Object? homeComingSoonDismissed = null,Object? dateFormat = null,Object? dailySummaryTime = null,Object? lockAfterSeconds = null,Object? hideInRecents = null,Object? fontSize = null,Object? lastBackupLocation = freezed,Object? lastBackupSizeBytes = freezed,Object? backupEncrypt = null,Object? backupIncludeReceipts = null,Object? backupAccountEmail = freezed,Object? autoBackupFrequency = null,Object? autoBackupWifiOnly = null,Object? lastAutoBackupAt = freezed,Object? autoBackupFailures = null,Object? autoBackupFailureNotified = null,Object? showDataOnWidget = null,Object? deviceTimeZoneId = freezed,Object? adsInstallAt = freezed,Object? adsLastInterstitialAt = freezed,Object? adsInterstitialDay = freezed,Object? adsInterstitialsToday = null,Object? adsLastSessionDay = freezed,Object? rewardedDay = freezed,Object? rewardedCounts = null,Object? proNotOwnedStreak = null,Object? proPurchasePending = null,Object? proRemovalPending = null,Object? accountDisplayName = freezed,Object? accountPhotoUrl = freezed,Object? deviceId = freezed,Object? dataChangeCounter = null,Object? backedUpChangeCounter = null,Object? lastBackgroundBackupAt = freezed,Object? lastKnownDriveBackupAt = freezed,Object? lastKnownDriveBackupDeviceId = freezed,Object? autoBackupPausedByConflict = null,Object? autoBackupPauseNotified = null,Object? finishSetupPending = null,}) {
  return _then(AppSettings(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,selectedTheme: null == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as String,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,lockEnabled: null == lockEnabled ? _self.lockEnabled : lockEnabled // ignore: cast_nullable_to_non_nullable
as bool,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,enabledModules: null == enabledModules ? _self.enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,moduleOrder: null == moduleOrder ? _self.moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,adConsentStatus: freezed == adConsentStatus ? _self.adConsentStatus : adConsentStatus // ignore: cast_nullable_to_non_nullable
as String?,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,removeAdsPurchased: null == removeAdsPurchased ? _self.removeAdsPurchased : removeAdsPurchased // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,budgetAlertsEnabled: null == budgetAlertsEnabled ? _self.budgetAlertsEnabled : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
as bool,habitRemindersEnabled: null == habitRemindersEnabled ? _self.habitRemindersEnabled : habitRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,debugUnlockAll: null == debugUnlockAll ? _self.debugUnlockAll : debugUnlockAll // ignore: cast_nullable_to_non_nullable
as bool,latestSeenAt: freezed == latestSeenAt ? _self.latestSeenAt : latestSeenAt // ignore: cast_nullable_to_non_nullable
as int?,dailyInsightDate: freezed == dailyInsightDate ? _self.dailyInsightDate : dailyInsightDate // ignore: cast_nullable_to_non_nullable
as String?,dailyInsightId: freezed == dailyInsightId ? _self.dailyInsightId : dailyInsightId // ignore: cast_nullable_to_non_nullable
as String?,homeComingSoonDismissed: null == homeComingSoonDismissed ? _self.homeComingSoonDismissed : homeComingSoonDismissed // ignore: cast_nullable_to_non_nullable
as bool,dateFormat: null == dateFormat ? _self.dateFormat : dateFormat // ignore: cast_nullable_to_non_nullable
as String,dailySummaryTime: null == dailySummaryTime ? _self.dailySummaryTime : dailySummaryTime // ignore: cast_nullable_to_non_nullable
as String,lockAfterSeconds: null == lockAfterSeconds ? _self.lockAfterSeconds : lockAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,hideInRecents: null == hideInRecents ? _self.hideInRecents : hideInRecents // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as String,lastBackupLocation: freezed == lastBackupLocation ? _self.lastBackupLocation : lastBackupLocation // ignore: cast_nullable_to_non_nullable
as BackupLocation?,lastBackupSizeBytes: freezed == lastBackupSizeBytes ? _self.lastBackupSizeBytes : lastBackupSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,backupEncrypt: null == backupEncrypt ? _self.backupEncrypt : backupEncrypt // ignore: cast_nullable_to_non_nullable
as bool,backupIncludeReceipts: null == backupIncludeReceipts ? _self.backupIncludeReceipts : backupIncludeReceipts // ignore: cast_nullable_to_non_nullable
as bool,backupAccountEmail: freezed == backupAccountEmail ? _self.backupAccountEmail : backupAccountEmail // ignore: cast_nullable_to_non_nullable
as String?,autoBackupFrequency: null == autoBackupFrequency ? _self.autoBackupFrequency : autoBackupFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,autoBackupWifiOnly: null == autoBackupWifiOnly ? _self.autoBackupWifiOnly : autoBackupWifiOnly // ignore: cast_nullable_to_non_nullable
as bool,lastAutoBackupAt: freezed == lastAutoBackupAt ? _self.lastAutoBackupAt : lastAutoBackupAt // ignore: cast_nullable_to_non_nullable
as int?,autoBackupFailures: null == autoBackupFailures ? _self.autoBackupFailures : autoBackupFailures // ignore: cast_nullable_to_non_nullable
as int,autoBackupFailureNotified: null == autoBackupFailureNotified ? _self.autoBackupFailureNotified : autoBackupFailureNotified // ignore: cast_nullable_to_non_nullable
as bool,showDataOnWidget: null == showDataOnWidget ? _self.showDataOnWidget : showDataOnWidget // ignore: cast_nullable_to_non_nullable
as bool,deviceTimeZoneId: freezed == deviceTimeZoneId ? _self.deviceTimeZoneId : deviceTimeZoneId // ignore: cast_nullable_to_non_nullable
as String?,adsInstallAt: freezed == adsInstallAt ? _self.adsInstallAt : adsInstallAt // ignore: cast_nullable_to_non_nullable
as int?,adsLastInterstitialAt: freezed == adsLastInterstitialAt ? _self.adsLastInterstitialAt : adsLastInterstitialAt // ignore: cast_nullable_to_non_nullable
as int?,adsInterstitialDay: freezed == adsInterstitialDay ? _self.adsInterstitialDay : adsInterstitialDay // ignore: cast_nullable_to_non_nullable
as String?,adsInterstitialsToday: null == adsInterstitialsToday ? _self.adsInterstitialsToday : adsInterstitialsToday // ignore: cast_nullable_to_non_nullable
as int,adsLastSessionDay: freezed == adsLastSessionDay ? _self.adsLastSessionDay : adsLastSessionDay // ignore: cast_nullable_to_non_nullable
as String?,rewardedDay: freezed == rewardedDay ? _self.rewardedDay : rewardedDay // ignore: cast_nullable_to_non_nullable
as String?,rewardedCounts: null == rewardedCounts ? _self.rewardedCounts : rewardedCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,proNotOwnedStreak: null == proNotOwnedStreak ? _self.proNotOwnedStreak : proNotOwnedStreak // ignore: cast_nullable_to_non_nullable
as int,proPurchasePending: null == proPurchasePending ? _self.proPurchasePending : proPurchasePending // ignore: cast_nullable_to_non_nullable
as bool,proRemovalPending: null == proRemovalPending ? _self.proRemovalPending : proRemovalPending // ignore: cast_nullable_to_non_nullable
as bool,accountDisplayName: freezed == accountDisplayName ? _self.accountDisplayName : accountDisplayName // ignore: cast_nullable_to_non_nullable
as String?,accountPhotoUrl: freezed == accountPhotoUrl ? _self.accountPhotoUrl : accountPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,dataChangeCounter: null == dataChangeCounter ? _self.dataChangeCounter : dataChangeCounter // ignore: cast_nullable_to_non_nullable
as int,backedUpChangeCounter: null == backedUpChangeCounter ? _self.backedUpChangeCounter : backedUpChangeCounter // ignore: cast_nullable_to_non_nullable
as int,lastBackgroundBackupAt: freezed == lastBackgroundBackupAt ? _self.lastBackgroundBackupAt : lastBackgroundBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastKnownDriveBackupAt: freezed == lastKnownDriveBackupAt ? _self.lastKnownDriveBackupAt : lastKnownDriveBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastKnownDriveBackupDeviceId: freezed == lastKnownDriveBackupDeviceId ? _self.lastKnownDriveBackupDeviceId : lastKnownDriveBackupDeviceId // ignore: cast_nullable_to_non_nullable
as String?,autoBackupPausedByConflict: null == autoBackupPausedByConflict ? _self.autoBackupPausedByConflict : autoBackupPausedByConflict // ignore: cast_nullable_to_non_nullable
as bool,autoBackupPauseNotified: null == autoBackupPauseNotified ? _self.autoBackupPauseNotified : autoBackupPauseNotified // ignore: cast_nullable_to_non_nullable
as bool,finishSetupPending: null == finishSetupPending ? _self.finishSetupPending : finishSetupPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale,  String currencyCode,  String themeMode,  String selectedTheme,  int firstDayOfWeek,  bool lockEnabled,  bool biometricEnabled,  List<String> enabledModules,  List<String> moduleOrder,  bool onboardingDone,  String? adConsentStatus,  int? lastBackupAt,  bool removeAdsPurchased,  bool notificationsEnabled,  bool budgetAlertsEnabled,  bool habitRemindersEnabled,  bool debugUnlockAll,  int? latestSeenAt,  String? dailyInsightDate,  String? dailyInsightId,  bool homeComingSoonDismissed,  String dateFormat,  String dailySummaryTime,  int lockAfterSeconds,  bool hideInRecents,  String fontSize,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  bool backupEncrypt,  bool backupIncludeReceipts,  String? backupAccountEmail,  AutoBackupFrequency autoBackupFrequency,  bool autoBackupWifiOnly,  int? lastAutoBackupAt,  int autoBackupFailures,  bool autoBackupFailureNotified,  bool showDataOnWidget,  String? deviceTimeZoneId,  int? adsInstallAt,  int? adsLastInterstitialAt,  String? adsInterstitialDay,  int adsInterstitialsToday,  String? adsLastSessionDay,  String? rewardedDay,  Map<String, int> rewardedCounts,  int proNotOwnedStreak,  bool proPurchasePending,  bool proRemovalPending,  String? accountDisplayName,  String? accountPhotoUrl,  String? deviceId,  int dataChangeCounter,  int backedUpChangeCounter,  int? lastBackgroundBackupAt,  int? lastKnownDriveBackupAt,  String? lastKnownDriveBackupDeviceId,  bool autoBackupPausedByConflict,  bool autoBackupPauseNotified,  bool finishSetupPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.locale,_that.currencyCode,_that.themeMode,_that.selectedTheme,_that.firstDayOfWeek,_that.lockEnabled,_that.biometricEnabled,_that.enabledModules,_that.moduleOrder,_that.onboardingDone,_that.adConsentStatus,_that.lastBackupAt,_that.removeAdsPurchased,_that.notificationsEnabled,_that.budgetAlertsEnabled,_that.habitRemindersEnabled,_that.debugUnlockAll,_that.latestSeenAt,_that.dailyInsightDate,_that.dailyInsightId,_that.homeComingSoonDismissed,_that.dateFormat,_that.dailySummaryTime,_that.lockAfterSeconds,_that.hideInRecents,_that.fontSize,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.backupEncrypt,_that.backupIncludeReceipts,_that.backupAccountEmail,_that.autoBackupFrequency,_that.autoBackupWifiOnly,_that.lastAutoBackupAt,_that.autoBackupFailures,_that.autoBackupFailureNotified,_that.showDataOnWidget,_that.deviceTimeZoneId,_that.adsInstallAt,_that.adsLastInterstitialAt,_that.adsInterstitialDay,_that.adsInterstitialsToday,_that.adsLastSessionDay,_that.rewardedDay,_that.rewardedCounts,_that.proNotOwnedStreak,_that.proPurchasePending,_that.proRemovalPending,_that.accountDisplayName,_that.accountPhotoUrl,_that.deviceId,_that.dataChangeCounter,_that.backedUpChangeCounter,_that.lastBackgroundBackupAt,_that.lastKnownDriveBackupAt,_that.lastKnownDriveBackupDeviceId,_that.autoBackupPausedByConflict,_that.autoBackupPauseNotified,_that.finishSetupPending);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale,  String currencyCode,  String themeMode,  String selectedTheme,  int firstDayOfWeek,  bool lockEnabled,  bool biometricEnabled,  List<String> enabledModules,  List<String> moduleOrder,  bool onboardingDone,  String? adConsentStatus,  int? lastBackupAt,  bool removeAdsPurchased,  bool notificationsEnabled,  bool budgetAlertsEnabled,  bool habitRemindersEnabled,  bool debugUnlockAll,  int? latestSeenAt,  String? dailyInsightDate,  String? dailyInsightId,  bool homeComingSoonDismissed,  String dateFormat,  String dailySummaryTime,  int lockAfterSeconds,  bool hideInRecents,  String fontSize,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  bool backupEncrypt,  bool backupIncludeReceipts,  String? backupAccountEmail,  AutoBackupFrequency autoBackupFrequency,  bool autoBackupWifiOnly,  int? lastAutoBackupAt,  int autoBackupFailures,  bool autoBackupFailureNotified,  bool showDataOnWidget,  String? deviceTimeZoneId,  int? adsInstallAt,  int? adsLastInterstitialAt,  String? adsInterstitialDay,  int adsInterstitialsToday,  String? adsLastSessionDay,  String? rewardedDay,  Map<String, int> rewardedCounts,  int proNotOwnedStreak,  bool proPurchasePending,  bool proRemovalPending,  String? accountDisplayName,  String? accountPhotoUrl,  String? deviceId,  int dataChangeCounter,  int backedUpChangeCounter,  int? lastBackgroundBackupAt,  int? lastKnownDriveBackupAt,  String? lastKnownDriveBackupDeviceId,  bool autoBackupPausedByConflict,  bool autoBackupPauseNotified,  bool finishSetupPending)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.locale,_that.currencyCode,_that.themeMode,_that.selectedTheme,_that.firstDayOfWeek,_that.lockEnabled,_that.biometricEnabled,_that.enabledModules,_that.moduleOrder,_that.onboardingDone,_that.adConsentStatus,_that.lastBackupAt,_that.removeAdsPurchased,_that.notificationsEnabled,_that.budgetAlertsEnabled,_that.habitRemindersEnabled,_that.debugUnlockAll,_that.latestSeenAt,_that.dailyInsightDate,_that.dailyInsightId,_that.homeComingSoonDismissed,_that.dateFormat,_that.dailySummaryTime,_that.lockAfterSeconds,_that.hideInRecents,_that.fontSize,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.backupEncrypt,_that.backupIncludeReceipts,_that.backupAccountEmail,_that.autoBackupFrequency,_that.autoBackupWifiOnly,_that.lastAutoBackupAt,_that.autoBackupFailures,_that.autoBackupFailureNotified,_that.showDataOnWidget,_that.deviceTimeZoneId,_that.adsInstallAt,_that.adsLastInterstitialAt,_that.adsInterstitialDay,_that.adsInterstitialsToday,_that.adsLastSessionDay,_that.rewardedDay,_that.rewardedCounts,_that.proNotOwnedStreak,_that.proPurchasePending,_that.proRemovalPending,_that.accountDisplayName,_that.accountPhotoUrl,_that.deviceId,_that.dataChangeCounter,_that.backedUpChangeCounter,_that.lastBackgroundBackupAt,_that.lastKnownDriveBackupAt,_that.lastKnownDriveBackupDeviceId,_that.autoBackupPausedByConflict,_that.autoBackupPauseNotified,_that.finishSetupPending);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale,  String currencyCode,  String themeMode,  String selectedTheme,  int firstDayOfWeek,  bool lockEnabled,  bool biometricEnabled,  List<String> enabledModules,  List<String> moduleOrder,  bool onboardingDone,  String? adConsentStatus,  int? lastBackupAt,  bool removeAdsPurchased,  bool notificationsEnabled,  bool budgetAlertsEnabled,  bool habitRemindersEnabled,  bool debugUnlockAll,  int? latestSeenAt,  String? dailyInsightDate,  String? dailyInsightId,  bool homeComingSoonDismissed,  String dateFormat,  String dailySummaryTime,  int lockAfterSeconds,  bool hideInRecents,  String fontSize,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  bool backupEncrypt,  bool backupIncludeReceipts,  String? backupAccountEmail,  AutoBackupFrequency autoBackupFrequency,  bool autoBackupWifiOnly,  int? lastAutoBackupAt,  int autoBackupFailures,  bool autoBackupFailureNotified,  bool showDataOnWidget,  String? deviceTimeZoneId,  int? adsInstallAt,  int? adsLastInterstitialAt,  String? adsInterstitialDay,  int adsInterstitialsToday,  String? adsLastSessionDay,  String? rewardedDay,  Map<String, int> rewardedCounts,  int proNotOwnedStreak,  bool proPurchasePending,  bool proRemovalPending,  String? accountDisplayName,  String? accountPhotoUrl,  String? deviceId,  int dataChangeCounter,  int backedUpChangeCounter,  int? lastBackgroundBackupAt,  int? lastKnownDriveBackupAt,  String? lastKnownDriveBackupDeviceId,  bool autoBackupPausedByConflict,  bool autoBackupPauseNotified,  bool finishSetupPending)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.locale,_that.currencyCode,_that.themeMode,_that.selectedTheme,_that.firstDayOfWeek,_that.lockEnabled,_that.biometricEnabled,_that.enabledModules,_that.moduleOrder,_that.onboardingDone,_that.adConsentStatus,_that.lastBackupAt,_that.removeAdsPurchased,_that.notificationsEnabled,_that.budgetAlertsEnabled,_that.habitRemindersEnabled,_that.debugUnlockAll,_that.latestSeenAt,_that.dailyInsightDate,_that.dailyInsightId,_that.homeComingSoonDismissed,_that.dateFormat,_that.dailySummaryTime,_that.lockAfterSeconds,_that.hideInRecents,_that.fontSize,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.backupEncrypt,_that.backupIncludeReceipts,_that.backupAccountEmail,_that.autoBackupFrequency,_that.autoBackupWifiOnly,_that.lastAutoBackupAt,_that.autoBackupFailures,_that.autoBackupFailureNotified,_that.showDataOnWidget,_that.deviceTimeZoneId,_that.adsInstallAt,_that.adsLastInterstitialAt,_that.adsInterstitialDay,_that.adsInterstitialsToday,_that.adsLastSessionDay,_that.rewardedDay,_that.rewardedCounts,_that.proNotOwnedStreak,_that.proPurchasePending,_that.proRemovalPending,_that.accountDisplayName,_that.accountPhotoUrl,_that.deviceId,_that.dataChangeCounter,_that.backedUpChangeCounter,_that.lastBackgroundBackupAt,_that.lastKnownDriveBackupAt,_that.lastKnownDriveBackupDeviceId,_that.autoBackupPausedByConflict,_that.autoBackupPauseNotified,_that.finishSetupPending);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.locale, this.currencyCode = 'INR', this.themeMode = 'system', this.selectedTheme = 'default', this.firstDayOfWeek = 1, this.lockEnabled = false, this.biometricEnabled = false,  List<String> enabledModules = const ['expense', 'habit'],  List<String> moduleOrder = const ['expense', 'habit'], this.onboardingDone = false, this.adConsentStatus, this.lastBackupAt, this.removeAdsPurchased = false, this.notificationsEnabled = true, this.budgetAlertsEnabled = true, this.habitRemindersEnabled = true, this.debugUnlockAll = false, this.latestSeenAt, this.dailyInsightDate, this.dailyInsightId, this.homeComingSoonDismissed = false, this.dateFormat = 'dMMMy', this.dailySummaryTime = '21:00', this.lockAfterSeconds = 60, this.hideInRecents = false, this.fontSize = 'default', this.lastBackupLocation, this.lastBackupSizeBytes, this.backupEncrypt = false, this.backupIncludeReceipts = false, this.backupAccountEmail, this.autoBackupFrequency = AutoBackupFrequency.off, this.autoBackupWifiOnly = true, this.lastAutoBackupAt, this.autoBackupFailures = 0, this.autoBackupFailureNotified = false, this.showDataOnWidget = false, this.deviceTimeZoneId, this.adsInstallAt, this.adsLastInterstitialAt, this.adsInterstitialDay, this.adsInterstitialsToday = 0, this.adsLastSessionDay, this.rewardedDay,  Map<String, int> rewardedCounts = const {}, this.proNotOwnedStreak = 0, this.proPurchasePending = false, this.proRemovalPending = false, this.accountDisplayName, this.accountPhotoUrl, this.deviceId, this.dataChangeCounter = 0, this.backedUpChangeCounter = 0, this.lastBackgroundBackupAt, this.lastKnownDriveBackupAt, this.lastKnownDriveBackupDeviceId, this.autoBackupPausedByConflict = false, this.autoBackupPauseNotified = false, this.finishSetupPending = false}): _enabledModules = enabledModules,_moduleOrder = moduleOrder,_rewardedCounts = rewardedCounts;
  

/// `en`, `hi`, `gu`, or null to follow the device.
@override final  String? locale;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  String themeMode;
@override@JsonKey() final  String selectedTheme;
/// 1 = Monday … 7 = Sunday.
@override@JsonKey() final  int firstDayOfWeek;
@override@JsonKey() final  bool lockEnabled;
@override@JsonKey() final  bool biometricEnabled;
/// Enabled module ids. Order is ignored; see [moduleOrder].
 final  List<String> _enabledModules;
/// Enabled module ids. Order is ignored; see [moduleOrder].
@override@JsonKey() List<String> get enabledModules {
  if (_enabledModules is EqualUnmodifiableListView) return _enabledModules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledModules);
}

/// Every registered module id, in the user's order (SET-06).
 final  List<String> _moduleOrder;
/// Every registered module id, in the user's order (SET-06).
@override@JsonKey() List<String> get moduleOrder {
  if (_moduleOrder is EqualUnmodifiableListView) return _moduleOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moduleOrder);
}

@override@JsonKey() final  bool onboardingDone;
@override final  String? adConsentStatus;
/// UTC epoch milliseconds.
@override final  int? lastBackupAt;
@override@JsonKey() final  bool removeAdsPurchased;
/// Notifications master switch (SET-01 toggle in T3.1).
@override@JsonKey() final  bool notificationsEnabled;
/// "Budget alerts" setting (SET-01 toggle in T3.1, FR-018).
@override@JsonKey() final  bool budgetAlertsEnabled;
/// "Habit reminders" setting (SET-01 toggle in T3.1, feature 005 R17).
@override@JsonKey() final  bool habitRemindersEnabled;
/// Dev-flavor "Unlock all features (debug)". Ignored in prod (FR-041).
@override@JsonKey() final  bool debugUnlockAll;
/// The latest time the app has seen, UTC epoch milliseconds. Only ever
/// raised, so moving the clock back never revives an expired unlock
/// (FR-038).
@override final  int? latestSeenAt;
/// Local `yyyy-MM-dd` day of the stored DSH-01 insight pick. Written
/// together with [dailyInsightId] (feature 006 research R6).
@override final  String? dailyInsightDate;
/// Rule id of the stored DSH-01 insight pick.
@override final  String? dailyInsightId;
/// The DSH-01 Coming soon card was dismissed for good.
@override@JsonKey() final  bool homeComingSoonDismissed;
/// Full-date format, one of [dateFormatIds] (SET-01, feature 007 R13).
@override@JsonKey() final  String dateFormat;
/// Daily summary reminder time, local `HH:mm` (SET-01). Stored only
/// until T3.4 schedules the reminder.
@override@JsonKey() final  String dailySummaryTime;
/// SET-05 "Lock after", one of [lockAfterOptions] (seconds).
@override@JsonKey() final  int lockAfterSeconds;
/// SET-05 "Hide app content in recents" (`FLAG_SECURE` app-wide).
@override@JsonKey() final  bool hideInRecents;
/// SET-04 font size, one of [fontSizeIds].
@override@JsonKey() final  String fontSize;
/// Where the last backup went (SET-02 Last backup; feature 008
/// data-model §1). Written with [lastBackupAt].
@override final  BackupLocation? lastBackupLocation;
/// Size of the last backup file in bytes.
@override final  int? lastBackupSizeBytes;
/// SET-02 "Encrypt backup". True only while the password is stored
/// (feature 008 research R4).
@override@JsonKey() final  bool backupEncrypt;
/// SET-02 "Include receipt images".
@override@JsonKey() final  bool backupIncludeReceipts;
/// The connected Google account, for display (feature 008 research R10).
@override final  String? backupAccountEmail;
/// SET-02 Auto backup (FR-018). Needs [backupAccountEmail].
@override@JsonKey() final  AutoBackupFrequency autoBackupFrequency;
/// SET-02 "Wi-Fi only" for auto backup (FR-019).
@override@JsonKey() final  bool autoBackupWifiOnly;
/// UTC ms of the last successful auto backup (catch-up, research R11).
@override final  int? lastAutoBackupAt;
/// Auto backups that failed in a row (FR-020).
@override@JsonKey() final  int autoBackupFailures;
/// The "backup failing" notification was shown for this streak.
@override@JsonKey() final  bool autoBackupFailureNotified;
/// SET-05 "Show data on widget": amounts and habit names on the home
/// screen widget while the app lock is on (FR-047).
@override@JsonKey() final  bool showDataOnWidget;
/// The IANA zone seen at the last app open or time zone trigger, so a
/// change reschedules notifications (FR-041, research R21).
@override final  String? deviceTimeZoneId;
/// First start of this install, UTC ms: the 2-day interstitial rule
/// (spec §11). Kept by Erase all data; never in backups (feature 009
/// data-model §1).
@override final  int? adsInstallAt;
/// When the last interstitial was shown, UTC ms.
@override final  int? adsLastInterstitialAt;
/// Local `yyyy-MM-dd` that [adsInterstitialsToday] counts for.
@override final  String? adsInterstitialDay;
/// Interstitials shown on [adsInterstitialDay].
@override@JsonKey() final  int adsInterstitialsToday;
/// Local day the last app session started on (first session of the day).
@override final  String? adsLastSessionDay;
/// Local `yyyy-MM-dd` that [rewardedCounts] counts for (FR-053).
@override final  String? rewardedDay;
/// Rewards earned on [rewardedDay], by feature key storage text.
 final  Map<String, int> _rewardedCounts;
/// Rewards earned on [rewardedDay], by feature key storage text.
@override@JsonKey() Map<String, int> get rewardedCounts {
  if (_rewardedCounts is EqualUnmodifiableMapView) return _rewardedCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rewardedCounts);
}

/// Online starts in a row that reported Pro not owned, 0–2 (feature 009
/// clarification Q1).
@override@JsonKey() final  int proNotOwnedStreak;
/// A Pro payment is pending in Google Play.
@override@JsonKey() final  bool proPurchasePending;
/// Pro was reported not owned twice: removed at the next cold start, so
/// locks and ads return together (analysis I1).
@override@JsonKey() final  bool proRemovalPending;
/// The signed-in account's name and photo, for ACC-01 (FR-003).
@override final  String? accountDisplayName;
@override final  String? accountPhotoUrl;
/// Copy of the no-backup device ID file (research R4).
@override final  String? deviceId;
/// Raised only by SQLite triggers on writes to backed-up data
/// (research R5).
@override@JsonKey() final  int dataChangeCounter;
/// [dataChangeCounter] inside the snapshot of the last successful
/// Drive backup.
@override@JsonKey() final  int backedUpChangeCounter;
/// UTC ms of the last background backup request (15-minute rule).
@override final  int? lastBackgroundBackupAt;
/// `createdAt` (UTC ms) and device of the newest Drive backup this
/// phone made or has seen (FR-040).
@override final  int? lastKnownDriveBackupAt;
@override final  String? lastKnownDriveBackupDeviceId;
/// Auto backup stopped by a newer backup from another phone (FR-038).
@override@JsonKey() final  bool autoBackupPausedByConflict;
/// The pause notification was shown for this pause.
@override@JsonKey() final  bool autoBackupPauseNotified;
/// Show the "Finish setting up" sheet once on Home: a restore onto an
/// empty phone skipped the app lock step (research R13).
@override@JsonKey() final  bool finishSetupPending;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.lockEnabled, lockEnabled) || other.lockEnabled == lockEnabled)&&(identical(other.biometricEnabled, biometricEnabled) || other.biometricEnabled == biometricEnabled)&&const DeepCollectionEquality().equals(other.enabledModules, _enabledModules)&&const DeepCollectionEquality().equals(other.moduleOrder, _moduleOrder)&&(identical(other.onboardingDone, onboardingDone) || other.onboardingDone == onboardingDone)&&(identical(other.adConsentStatus, adConsentStatus) || other.adConsentStatus == adConsentStatus)&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt)&&(identical(other.removeAdsPurchased, removeAdsPurchased) || other.removeAdsPurchased == removeAdsPurchased)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.budgetAlertsEnabled, budgetAlertsEnabled) || other.budgetAlertsEnabled == budgetAlertsEnabled)&&(identical(other.habitRemindersEnabled, habitRemindersEnabled) || other.habitRemindersEnabled == habitRemindersEnabled)&&(identical(other.debugUnlockAll, debugUnlockAll) || other.debugUnlockAll == debugUnlockAll)&&(identical(other.latestSeenAt, latestSeenAt) || other.latestSeenAt == latestSeenAt)&&(identical(other.dailyInsightDate, dailyInsightDate) || other.dailyInsightDate == dailyInsightDate)&&(identical(other.dailyInsightId, dailyInsightId) || other.dailyInsightId == dailyInsightId)&&(identical(other.homeComingSoonDismissed, homeComingSoonDismissed) || other.homeComingSoonDismissed == homeComingSoonDismissed)&&(identical(other.dateFormat, dateFormat) || other.dateFormat == dateFormat)&&(identical(other.dailySummaryTime, dailySummaryTime) || other.dailySummaryTime == dailySummaryTime)&&(identical(other.lockAfterSeconds, lockAfterSeconds) || other.lockAfterSeconds == lockAfterSeconds)&&(identical(other.hideInRecents, hideInRecents) || other.hideInRecents == hideInRecents)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lastBackupLocation, lastBackupLocation) || other.lastBackupLocation == lastBackupLocation)&&(identical(other.lastBackupSizeBytes, lastBackupSizeBytes) || other.lastBackupSizeBytes == lastBackupSizeBytes)&&(identical(other.backupEncrypt, backupEncrypt) || other.backupEncrypt == backupEncrypt)&&(identical(other.backupIncludeReceipts, backupIncludeReceipts) || other.backupIncludeReceipts == backupIncludeReceipts)&&(identical(other.backupAccountEmail, backupAccountEmail) || other.backupAccountEmail == backupAccountEmail)&&(identical(other.autoBackupFrequency, autoBackupFrequency) || other.autoBackupFrequency == autoBackupFrequency)&&(identical(other.autoBackupWifiOnly, autoBackupWifiOnly) || other.autoBackupWifiOnly == autoBackupWifiOnly)&&(identical(other.lastAutoBackupAt, lastAutoBackupAt) || other.lastAutoBackupAt == lastAutoBackupAt)&&(identical(other.autoBackupFailures, autoBackupFailures) || other.autoBackupFailures == autoBackupFailures)&&(identical(other.autoBackupFailureNotified, autoBackupFailureNotified) || other.autoBackupFailureNotified == autoBackupFailureNotified)&&(identical(other.showDataOnWidget, showDataOnWidget) || other.showDataOnWidget == showDataOnWidget)&&(identical(other.deviceTimeZoneId, deviceTimeZoneId) || other.deviceTimeZoneId == deviceTimeZoneId)&&(identical(other.adsInstallAt, adsInstallAt) || other.adsInstallAt == adsInstallAt)&&(identical(other.adsLastInterstitialAt, adsLastInterstitialAt) || other.adsLastInterstitialAt == adsLastInterstitialAt)&&(identical(other.adsInterstitialDay, adsInterstitialDay) || other.adsInterstitialDay == adsInterstitialDay)&&(identical(other.adsInterstitialsToday, adsInterstitialsToday) || other.adsInterstitialsToday == adsInterstitialsToday)&&(identical(other.adsLastSessionDay, adsLastSessionDay) || other.adsLastSessionDay == adsLastSessionDay)&&(identical(other.rewardedDay, rewardedDay) || other.rewardedDay == rewardedDay)&&const DeepCollectionEquality().equals(other.rewardedCounts, _rewardedCounts)&&(identical(other.proNotOwnedStreak, proNotOwnedStreak) || other.proNotOwnedStreak == proNotOwnedStreak)&&(identical(other.proPurchasePending, proPurchasePending) || other.proPurchasePending == proPurchasePending)&&(identical(other.proRemovalPending, proRemovalPending) || other.proRemovalPending == proRemovalPending)&&(identical(other.accountDisplayName, accountDisplayName) || other.accountDisplayName == accountDisplayName)&&(identical(other.accountPhotoUrl, accountPhotoUrl) || other.accountPhotoUrl == accountPhotoUrl)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.dataChangeCounter, dataChangeCounter) || other.dataChangeCounter == dataChangeCounter)&&(identical(other.backedUpChangeCounter, backedUpChangeCounter) || other.backedUpChangeCounter == backedUpChangeCounter)&&(identical(other.lastBackgroundBackupAt, lastBackgroundBackupAt) || other.lastBackgroundBackupAt == lastBackgroundBackupAt)&&(identical(other.lastKnownDriveBackupAt, lastKnownDriveBackupAt) || other.lastKnownDriveBackupAt == lastKnownDriveBackupAt)&&(identical(other.lastKnownDriveBackupDeviceId, lastKnownDriveBackupDeviceId) || other.lastKnownDriveBackupDeviceId == lastKnownDriveBackupDeviceId)&&(identical(other.autoBackupPausedByConflict, autoBackupPausedByConflict) || other.autoBackupPausedByConflict == autoBackupPausedByConflict)&&(identical(other.autoBackupPauseNotified, autoBackupPauseNotified) || other.autoBackupPauseNotified == autoBackupPauseNotified)&&(identical(other.finishSetupPending, finishSetupPending) || other.finishSetupPending == finishSetupPending));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,locale,currencyCode,themeMode,selectedTheme,firstDayOfWeek,lockEnabled,biometricEnabled,const DeepCollectionEquality().hash(_enabledModules),const DeepCollectionEquality().hash(_moduleOrder),onboardingDone,adConsentStatus,lastBackupAt,removeAdsPurchased,notificationsEnabled,budgetAlertsEnabled,habitRemindersEnabled,debugUnlockAll,latestSeenAt,dailyInsightDate,dailyInsightId,homeComingSoonDismissed,dateFormat,dailySummaryTime,lockAfterSeconds,hideInRecents,fontSize,lastBackupLocation,lastBackupSizeBytes,backupEncrypt,backupIncludeReceipts,backupAccountEmail,autoBackupFrequency,autoBackupWifiOnly,lastAutoBackupAt,autoBackupFailures,autoBackupFailureNotified,showDataOnWidget,deviceTimeZoneId,adsInstallAt,adsLastInterstitialAt,adsInterstitialDay,adsInterstitialsToday,adsLastSessionDay,rewardedDay,const DeepCollectionEquality().hash(_rewardedCounts),proNotOwnedStreak,proPurchasePending,proRemovalPending,accountDisplayName,accountPhotoUrl,deviceId,dataChangeCounter,backedUpChangeCounter,lastBackgroundBackupAt,lastKnownDriveBackupAt,lastKnownDriveBackupDeviceId,autoBackupPausedByConflict,autoBackupPauseNotified,finishSetupPending]);
}

@override
String toString() {
    return 'AppSettings(locale: $locale, currencyCode: $currencyCode, themeMode: $themeMode, selectedTheme: $selectedTheme, firstDayOfWeek: $firstDayOfWeek, lockEnabled: $lockEnabled, biometricEnabled: $biometricEnabled, enabledModules: $enabledModules, moduleOrder: $moduleOrder, onboardingDone: $onboardingDone, adConsentStatus: $adConsentStatus, lastBackupAt: $lastBackupAt, removeAdsPurchased: $removeAdsPurchased, notificationsEnabled: $notificationsEnabled, budgetAlertsEnabled: $budgetAlertsEnabled, habitRemindersEnabled: $habitRemindersEnabled, debugUnlockAll: $debugUnlockAll, latestSeenAt: $latestSeenAt, dailyInsightDate: $dailyInsightDate, dailyInsightId: $dailyInsightId, homeComingSoonDismissed: $homeComingSoonDismissed, dateFormat: $dateFormat, dailySummaryTime: $dailySummaryTime, lockAfterSeconds: $lockAfterSeconds, hideInRecents: $hideInRecents, fontSize: $fontSize, lastBackupLocation: $lastBackupLocation, lastBackupSizeBytes: $lastBackupSizeBytes, backupEncrypt: $backupEncrypt, backupIncludeReceipts: $backupIncludeReceipts, backupAccountEmail: $backupAccountEmail, autoBackupFrequency: $autoBackupFrequency, autoBackupWifiOnly: $autoBackupWifiOnly, lastAutoBackupAt: $lastAutoBackupAt, autoBackupFailures: $autoBackupFailures, autoBackupFailureNotified: $autoBackupFailureNotified, showDataOnWidget: $showDataOnWidget, deviceTimeZoneId: $deviceTimeZoneId, adsInstallAt: $adsInstallAt, adsLastInterstitialAt: $adsLastInterstitialAt, adsInterstitialDay: $adsInterstitialDay, adsInterstitialsToday: $adsInterstitialsToday, adsLastSessionDay: $adsLastSessionDay, rewardedDay: $rewardedDay, rewardedCounts: $rewardedCounts, proNotOwnedStreak: $proNotOwnedStreak, proPurchasePending: $proPurchasePending, proRemovalPending: $proRemovalPending, accountDisplayName: $accountDisplayName, accountPhotoUrl: $accountPhotoUrl, deviceId: $deviceId, dataChangeCounter: $dataChangeCounter, backedUpChangeCounter: $backedUpChangeCounter, lastBackgroundBackupAt: $lastBackgroundBackupAt, lastKnownDriveBackupAt: $lastKnownDriveBackupAt, lastKnownDriveBackupDeviceId: $lastKnownDriveBackupDeviceId, autoBackupPausedByConflict: $autoBackupPausedByConflict, autoBackupPauseNotified: $autoBackupPauseNotified, finishSetupPending: $finishSetupPending)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? locale, String currencyCode, String themeMode, String selectedTheme, int firstDayOfWeek, bool lockEnabled, bool biometricEnabled, List<String> enabledModules, List<String> moduleOrder, bool onboardingDone, String? adConsentStatus, int? lastBackupAt, bool removeAdsPurchased, bool notificationsEnabled, bool budgetAlertsEnabled, bool habitRemindersEnabled, bool debugUnlockAll, int? latestSeenAt, String? dailyInsightDate, String? dailyInsightId, bool homeComingSoonDismissed, String dateFormat, String dailySummaryTime, int lockAfterSeconds, bool hideInRecents, String fontSize, BackupLocation? lastBackupLocation, int? lastBackupSizeBytes, bool backupEncrypt, bool backupIncludeReceipts, String? backupAccountEmail, AutoBackupFrequency autoBackupFrequency, bool autoBackupWifiOnly, int? lastAutoBackupAt, int autoBackupFailures, bool autoBackupFailureNotified, bool showDataOnWidget, String? deviceTimeZoneId, int? adsInstallAt, int? adsLastInterstitialAt, String? adsInterstitialDay, int adsInterstitialsToday, String? adsLastSessionDay, String? rewardedDay, Map<String, int> rewardedCounts, int proNotOwnedStreak, bool proPurchasePending, bool proRemovalPending, String? accountDisplayName, String? accountPhotoUrl, String? deviceId, int dataChangeCounter, int backedUpChangeCounter, int? lastBackgroundBackupAt, int? lastKnownDriveBackupAt, String? lastKnownDriveBackupDeviceId, bool autoBackupPausedByConflict, bool autoBackupPauseNotified, bool finishSetupPending
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? currencyCode = null,Object? themeMode = null,Object? selectedTheme = null,Object? firstDayOfWeek = null,Object? lockEnabled = null,Object? biometricEnabled = null,Object? enabledModules = null,Object? moduleOrder = null,Object? onboardingDone = null,Object? adConsentStatus = freezed,Object? lastBackupAt = freezed,Object? removeAdsPurchased = null,Object? notificationsEnabled = null,Object? budgetAlertsEnabled = null,Object? habitRemindersEnabled = null,Object? debugUnlockAll = null,Object? latestSeenAt = freezed,Object? dailyInsightDate = freezed,Object? dailyInsightId = freezed,Object? homeComingSoonDismissed = null,Object? dateFormat = null,Object? dailySummaryTime = null,Object? lockAfterSeconds = null,Object? hideInRecents = null,Object? fontSize = null,Object? lastBackupLocation = freezed,Object? lastBackupSizeBytes = freezed,Object? backupEncrypt = null,Object? backupIncludeReceipts = null,Object? backupAccountEmail = freezed,Object? autoBackupFrequency = null,Object? autoBackupWifiOnly = null,Object? lastAutoBackupAt = freezed,Object? autoBackupFailures = null,Object? autoBackupFailureNotified = null,Object? showDataOnWidget = null,Object? deviceTimeZoneId = freezed,Object? adsInstallAt = freezed,Object? adsLastInterstitialAt = freezed,Object? adsInterstitialDay = freezed,Object? adsInterstitialsToday = null,Object? adsLastSessionDay = freezed,Object? rewardedDay = freezed,Object? rewardedCounts = null,Object? proNotOwnedStreak = null,Object? proPurchasePending = null,Object? proRemovalPending = null,Object? accountDisplayName = freezed,Object? accountPhotoUrl = freezed,Object? deviceId = freezed,Object? dataChangeCounter = null,Object? backedUpChangeCounter = null,Object? lastBackgroundBackupAt = freezed,Object? lastKnownDriveBackupAt = freezed,Object? lastKnownDriveBackupDeviceId = freezed,Object? autoBackupPausedByConflict = null,Object? autoBackupPauseNotified = null,Object? finishSetupPending = null,}) {
  return _then(_AppSettings(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,selectedTheme: null == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as String,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,lockEnabled: null == lockEnabled ? _self.lockEnabled : lockEnabled // ignore: cast_nullable_to_non_nullable
as bool,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,enabledModules: null == enabledModules ? _self._enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,moduleOrder: null == moduleOrder ? _self._moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,adConsentStatus: freezed == adConsentStatus ? _self.adConsentStatus : adConsentStatus // ignore: cast_nullable_to_non_nullable
as String?,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,removeAdsPurchased: null == removeAdsPurchased ? _self.removeAdsPurchased : removeAdsPurchased // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,budgetAlertsEnabled: null == budgetAlertsEnabled ? _self.budgetAlertsEnabled : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
as bool,habitRemindersEnabled: null == habitRemindersEnabled ? _self.habitRemindersEnabled : habitRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,debugUnlockAll: null == debugUnlockAll ? _self.debugUnlockAll : debugUnlockAll // ignore: cast_nullable_to_non_nullable
as bool,latestSeenAt: freezed == latestSeenAt ? _self.latestSeenAt : latestSeenAt // ignore: cast_nullable_to_non_nullable
as int?,dailyInsightDate: freezed == dailyInsightDate ? _self.dailyInsightDate : dailyInsightDate // ignore: cast_nullable_to_non_nullable
as String?,dailyInsightId: freezed == dailyInsightId ? _self.dailyInsightId : dailyInsightId // ignore: cast_nullable_to_non_nullable
as String?,homeComingSoonDismissed: null == homeComingSoonDismissed ? _self.homeComingSoonDismissed : homeComingSoonDismissed // ignore: cast_nullable_to_non_nullable
as bool,dateFormat: null == dateFormat ? _self.dateFormat : dateFormat // ignore: cast_nullable_to_non_nullable
as String,dailySummaryTime: null == dailySummaryTime ? _self.dailySummaryTime : dailySummaryTime // ignore: cast_nullable_to_non_nullable
as String,lockAfterSeconds: null == lockAfterSeconds ? _self.lockAfterSeconds : lockAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,hideInRecents: null == hideInRecents ? _self.hideInRecents : hideInRecents // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as String,lastBackupLocation: freezed == lastBackupLocation ? _self.lastBackupLocation : lastBackupLocation // ignore: cast_nullable_to_non_nullable
as BackupLocation?,lastBackupSizeBytes: freezed == lastBackupSizeBytes ? _self.lastBackupSizeBytes : lastBackupSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,backupEncrypt: null == backupEncrypt ? _self.backupEncrypt : backupEncrypt // ignore: cast_nullable_to_non_nullable
as bool,backupIncludeReceipts: null == backupIncludeReceipts ? _self.backupIncludeReceipts : backupIncludeReceipts // ignore: cast_nullable_to_non_nullable
as bool,backupAccountEmail: freezed == backupAccountEmail ? _self.backupAccountEmail : backupAccountEmail // ignore: cast_nullable_to_non_nullable
as String?,autoBackupFrequency: null == autoBackupFrequency ? _self.autoBackupFrequency : autoBackupFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,autoBackupWifiOnly: null == autoBackupWifiOnly ? _self.autoBackupWifiOnly : autoBackupWifiOnly // ignore: cast_nullable_to_non_nullable
as bool,lastAutoBackupAt: freezed == lastAutoBackupAt ? _self.lastAutoBackupAt : lastAutoBackupAt // ignore: cast_nullable_to_non_nullable
as int?,autoBackupFailures: null == autoBackupFailures ? _self.autoBackupFailures : autoBackupFailures // ignore: cast_nullable_to_non_nullable
as int,autoBackupFailureNotified: null == autoBackupFailureNotified ? _self.autoBackupFailureNotified : autoBackupFailureNotified // ignore: cast_nullable_to_non_nullable
as bool,showDataOnWidget: null == showDataOnWidget ? _self.showDataOnWidget : showDataOnWidget // ignore: cast_nullable_to_non_nullable
as bool,deviceTimeZoneId: freezed == deviceTimeZoneId ? _self.deviceTimeZoneId : deviceTimeZoneId // ignore: cast_nullable_to_non_nullable
as String?,adsInstallAt: freezed == adsInstallAt ? _self.adsInstallAt : adsInstallAt // ignore: cast_nullable_to_non_nullable
as int?,adsLastInterstitialAt: freezed == adsLastInterstitialAt ? _self.adsLastInterstitialAt : adsLastInterstitialAt // ignore: cast_nullable_to_non_nullable
as int?,adsInterstitialDay: freezed == adsInterstitialDay ? _self.adsInterstitialDay : adsInterstitialDay // ignore: cast_nullable_to_non_nullable
as String?,adsInterstitialsToday: null == adsInterstitialsToday ? _self.adsInterstitialsToday : adsInterstitialsToday // ignore: cast_nullable_to_non_nullable
as int,adsLastSessionDay: freezed == adsLastSessionDay ? _self.adsLastSessionDay : adsLastSessionDay // ignore: cast_nullable_to_non_nullable
as String?,rewardedDay: freezed == rewardedDay ? _self.rewardedDay : rewardedDay // ignore: cast_nullable_to_non_nullable
as String?,rewardedCounts: null == rewardedCounts ? _self._rewardedCounts : rewardedCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,proNotOwnedStreak: null == proNotOwnedStreak ? _self.proNotOwnedStreak : proNotOwnedStreak // ignore: cast_nullable_to_non_nullable
as int,proPurchasePending: null == proPurchasePending ? _self.proPurchasePending : proPurchasePending // ignore: cast_nullable_to_non_nullable
as bool,proRemovalPending: null == proRemovalPending ? _self.proRemovalPending : proRemovalPending // ignore: cast_nullable_to_non_nullable
as bool,accountDisplayName: freezed == accountDisplayName ? _self.accountDisplayName : accountDisplayName // ignore: cast_nullable_to_non_nullable
as String?,accountPhotoUrl: freezed == accountPhotoUrl ? _self.accountPhotoUrl : accountPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,dataChangeCounter: null == dataChangeCounter ? _self.dataChangeCounter : dataChangeCounter // ignore: cast_nullable_to_non_nullable
as int,backedUpChangeCounter: null == backedUpChangeCounter ? _self.backedUpChangeCounter : backedUpChangeCounter // ignore: cast_nullable_to_non_nullable
as int,lastBackgroundBackupAt: freezed == lastBackgroundBackupAt ? _self.lastBackgroundBackupAt : lastBackgroundBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastKnownDriveBackupAt: freezed == lastKnownDriveBackupAt ? _self.lastKnownDriveBackupAt : lastKnownDriveBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastKnownDriveBackupDeviceId: freezed == lastKnownDriveBackupDeviceId ? _self.lastKnownDriveBackupDeviceId : lastKnownDriveBackupDeviceId // ignore: cast_nullable_to_non_nullable
as String?,autoBackupPausedByConflict: null == autoBackupPausedByConflict ? _self.autoBackupPausedByConflict : autoBackupPausedByConflict // ignore: cast_nullable_to_non_nullable
as bool,autoBackupPauseNotified: null == autoBackupPauseNotified ? _self.autoBackupPauseNotified : autoBackupPauseNotified // ignore: cast_nullable_to_non_nullable
as bool,finishSetupPending: null == finishSetupPending ? _self.finishSetupPending : finishSetupPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$OnboardingChoices {

 String? get locale; String get currencyCode; List<String> get moduleOrder; List<String> get enabledModules;
/// Create a copy of OnboardingChoices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingChoicesCopyWith<OnboardingChoices> get copyWith => _$OnboardingChoicesCopyWithImpl<OnboardingChoices>(this as OnboardingChoices, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingChoices;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingChoices&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&const DeepCollectionEquality().equals(other.moduleOrder, _this.moduleOrder)&&const DeepCollectionEquality().equals(other.enabledModules, _this.enabledModules));
}


@override
int get hashCode {
  final _this = this as OnboardingChoices;
  return Object.hash(runtimeType,_this.locale,_this.currencyCode,const DeepCollectionEquality().hash(_this.moduleOrder),const DeepCollectionEquality().hash(_this.enabledModules));
}

@override
String toString() {
  final _this = this as OnboardingChoices;
  return 'OnboardingChoices(locale: ${_this.locale}, currencyCode: ${_this.currencyCode}, moduleOrder: ${_this.moduleOrder}, enabledModules: ${_this.enabledModules})';
}


}

/// @nodoc
abstract mixin class $OnboardingChoicesCopyWith<$Res>  {
  factory $OnboardingChoicesCopyWith(OnboardingChoices value, $Res Function(OnboardingChoices) _then) = _$OnboardingChoicesCopyWithImpl;
@useResult
$Res call({
 String? locale, String currencyCode, List<String> moduleOrder, List<String> enabledModules
});




}
/// @nodoc
class _$OnboardingChoicesCopyWithImpl<$Res>
    implements $OnboardingChoicesCopyWith<$Res> {
  _$OnboardingChoicesCopyWithImpl(this._self, this._then);

  final OnboardingChoices _self;
  final $Res Function(OnboardingChoices) _then;

/// Create a copy of OnboardingChoices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? currencyCode = null,Object? moduleOrder = null,Object? enabledModules = null,}) {
  return _then(OnboardingChoices(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,moduleOrder: null == moduleOrder ? _self.moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledModules: null == enabledModules ? _self.enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingChoices].
extension OnboardingChoicesPatterns on OnboardingChoices {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingChoices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingChoices() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingChoices value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingChoices():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingChoices value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingChoices() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingChoices() when $default != null:
return $default(_that.locale,_that.currencyCode,_that.moduleOrder,_that.enabledModules);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules)  $default,) {final _that = this;
switch (_that) {
case _OnboardingChoices():
return $default(_that.locale,_that.currencyCode,_that.moduleOrder,_that.enabledModules);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingChoices() when $default != null:
return $default(_that.locale,_that.currencyCode,_that.moduleOrder,_that.enabledModules);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingChoices implements OnboardingChoices {
  const _OnboardingChoices({required this.locale, required this.currencyCode, required  List<String> moduleOrder, required  List<String> enabledModules}): _moduleOrder = moduleOrder,_enabledModules = enabledModules;
  

@override final  String? locale;
@override final  String currencyCode;
 final  List<String> _moduleOrder;
@override List<String> get moduleOrder {
  if (_moduleOrder is EqualUnmodifiableListView) return _moduleOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moduleOrder);
}

 final  List<String> _enabledModules;
@override List<String> get enabledModules {
  if (_enabledModules is EqualUnmodifiableListView) return _enabledModules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledModules);
}


/// Create a copy of OnboardingChoices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingChoicesCopyWith<_OnboardingChoices> get copyWith => __$OnboardingChoicesCopyWithImpl<_OnboardingChoices>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingChoices&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&const DeepCollectionEquality().equals(other.moduleOrder, _moduleOrder)&&const DeepCollectionEquality().equals(other.enabledModules, _enabledModules));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locale,currencyCode,const DeepCollectionEquality().hash(_moduleOrder),const DeepCollectionEquality().hash(_enabledModules));
}

@override
String toString() {
    return 'OnboardingChoices(locale: $locale, currencyCode: $currencyCode, moduleOrder: $moduleOrder, enabledModules: $enabledModules)';
}


}

/// @nodoc
abstract mixin class _$OnboardingChoicesCopyWith<$Res> implements $OnboardingChoicesCopyWith<$Res> {
  factory _$OnboardingChoicesCopyWith(_OnboardingChoices value, $Res Function(_OnboardingChoices) _then) = __$OnboardingChoicesCopyWithImpl;
@override @useResult
$Res call({
 String? locale, String currencyCode, List<String> moduleOrder, List<String> enabledModules
});




}
/// @nodoc
class __$OnboardingChoicesCopyWithImpl<$Res>
    implements _$OnboardingChoicesCopyWith<$Res> {
  __$OnboardingChoicesCopyWithImpl(this._self, this._then);

  final _OnboardingChoices _self;
  final $Res Function(_OnboardingChoices) _then;

/// Create a copy of OnboardingChoices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? currencyCode = null,Object? moduleOrder = null,Object? enabledModules = null,}) {
  return _then(_OnboardingChoices(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,moduleOrder: null == moduleOrder ? _self._moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledModules: null == enabledModules ? _self._enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
