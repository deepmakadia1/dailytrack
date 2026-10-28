import 'dart:convert';

import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/utils/date_keys.dart';

/// Converts between `settings` rows (key → JSON text) and [AppSettings].
/// Every key decodes independently: a corrupt or wrongly typed value falls
/// back to that key's default and never breaks startup.
abstract final class SettingsCodec {
  static const String locale = 'locale';
  static const String currencyCode = 'currencyCode';
  static const String themeMode = 'themeMode';
  static const String selectedTheme = 'selectedTheme';
  static const String firstDayOfWeek = 'firstDayOfWeek';
  static const String lockEnabled = 'lockEnabled';
  static const String biometricEnabled = 'biometricEnabled';
  static const String enabledModules = 'enabledModules';
  static const String moduleOrder = 'moduleOrder';
  static const String onboardingDone = 'onboardingDone';
  static const String adConsentStatus = 'adConsentStatus';
  static const String lastBackupAt = 'lastBackupAt';
  static const String removeAdsPurchased = 'removeAdsPurchased';
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String budgetAlertsEnabled = 'budgetAlertsEnabled';
  static const String habitRemindersEnabled = 'habitRemindersEnabled';
  static const String debugUnlockAll = 'debugUnlockAll';
  static const String latestSeenAt = 'latestSeenAt';
  static const String dailyInsightDate = 'dailyInsightDate';
  static const String dailyInsightId = 'dailyInsightId';
  static const String homeComingSoonDismissed = 'homeComingSoonDismissed';
  static const String dateFormat = 'dateFormat';
  static const String dailySummaryTime = 'dailySummaryTime';
  static const String lockAfterSeconds = 'lockAfterSeconds';
  static const String hideInRecents = 'hideInRecents';
  static const String fontSize = 'fontSize';

  // Feature 008 (SET-02, data-model §1).
  static const String lastBackupLocation = 'lastBackupLocation';
  static const String lastBackupSizeBytes = 'lastBackupSizeBytes';
  static const String backupEncrypt = 'backupEncrypt';
  static const String backupIncludeReceipts = 'backupIncludeReceipts';
  static const String backupAccountEmail = 'backupAccountEmail';
  static const String autoBackupFrequency = 'autoBackupFrequency';
  static const String autoBackupWifiOnly = 'autoBackupWifiOnly';
  static const String lastAutoBackupAt = 'lastAutoBackupAt';
  static const String autoBackupFailures = 'autoBackupFailures';
  static const String autoBackupFailureNotified = 'autoBackupFailureNotified';
  static const String showDataOnWidget = 'showDataOnWidget';
  static const String deviceTimeZoneId = 'deviceTimeZoneId';

  // Feature 009: the interstitial cap (data-model §1). Never restored.
  static const String adsInstallAt = 'adsInstallAt';
  static const String adsLastInterstitialAt = 'adsLastInterstitialAt';
  static const String adsInterstitialDay = 'adsInterstitialDay';
  static const String adsInterstitialsToday = 'adsInterstitialsToday';
  static const String adsLastSessionDay = 'adsLastSessionDay';

  // Feature 009: rewarded unlocks per feature key per day (FR-053).
  static const String rewardedDay = 'rewardedDay';
  static const String rewardedCounts = 'rewardedCounts';

  // Feature 009: Pro ownership checks (data-model §1, §5).
  static const String proNotOwnedStreak = 'proNotOwnedStreak';
  static const String proPurchasePending = 'proPurchasePending';
  static const String proRemovalPending = 'proRemovalPending';

  // Feature 010: account, device, and auto backup state (data-model §1).
  static const String accountDisplayName = 'accountDisplayName';
  static const String accountPhotoUrl = 'accountPhotoUrl';
  static const String deviceId = 'deviceId';
  static const String dataChangeCounter = 'dataChangeCounter';
  static const String backedUpChangeCounter = 'backedUpChangeCounter';
  static const String lastBackgroundBackupAt = 'lastBackgroundBackupAt';
  static const String lastKnownDriveBackupAt = 'lastKnownDriveBackupAt';
  static const String lastKnownDriveBackupDeviceId =
      'lastKnownDriveBackupDeviceId';
  static const String autoBackupPausedByConflict = 'autoBackupPausedByConflict';
  static const String autoBackupPauseNotified = 'autoBackupPauseNotified';
  static const String finishSetupPending = 'finishSetupPending';

  /// Feature 011: `none`, `guest`, or `google`.
  static const String authMode = 'authMode';

  /// `BackupCoordinator.leaseKey`, declared here so the codec never imports
  /// core/backup/data/ (read only).
  static const String backupLeaseUntil = 'backupLeaseUntil';

  static String seedKey(String seederId) => 'seed.$seederId';

  /// A module's own state, e.g. `module.expense.budgetRolloverMonth`.
  static String moduleStateKey(String key) => 'module.$key';

  static String encode(Object? value) => jsonEncode(value);

  /// Builds settings from raw rows. Module lists are normalized against
  /// [knownModuleIds]: unknown ids are dropped, missing known ids are appended
  /// to the order, and an empty enabled list falls back to the first module.
  static AppSettings decode(
    Map<String, String> rows, {
    required List<String> knownModuleIds,
  }) {
    const d = AppSettings();
    T read<T>(String key, T fallback) {
      final raw = rows[key];
      if (raw == null) return fallback;
      try {
        final v = jsonDecode(raw);
        return v is T ? v : fallback;
      } on FormatException {
        return fallback;
      }
    }

    List<String> readList(String key, List<String> fallback) {
      final v = read<List<dynamic>?>(key, null);
      if (v == null || v.any((e) => e is! String)) return fallback;
      return v.cast<String>();
    }

    // A JSON object of non-negative ints; anything else is dropped.
    Map<String, int> readCounts(String key) {
      final v = read<Map<String, dynamic>?>(key, null);
      if (v == null) return const {};
      return {
        for (final MapEntry(:key, :value) in v.entries)
          if (value is int && value >= 0) key: value,
      };
    }

    // Must parse as a `yyyy-MM-dd` date key, otherwise null.
    String? readDateKey(String key) {
      final v = read<String?>(key, null);
      if (v == null) return null;
      try {
        DateKeys.parse(v);
        return v;
      } on FormatException {
        return null;
      }
    }

    // One of [allowed], otherwise the default.
    T oneOf<T>(String key, List<T> allowed, T fallback) {
      final v = read<T?>(key, null);
      return v != null && allowed.contains(v) ? v : fallback;
    }

    final rawLocale = read<String?>(locale, null);
    final rawTime = read<String?>(dailySummaryTime, null);
    final rawInsightId = read<String?>(dailyInsightId, null);
    final rawLocation = read<String?>(lastBackupLocation, null);
    final rawSize = read<int?>(lastBackupSizeBytes, null);
    final rawFrequency = read<String?>(autoBackupFrequency, null);
    final rawFailures = read<int?>(autoBackupFailures, null);
    final rawEmail = read<String?>(backupAccountEmail, null);
    final rawAuthMode = read<String?>(authMode, null);
    final rawZone = read<String?>(deviceTimeZoneId, null);
    final rawShownToday = read<int?>(adsInterstitialsToday, null);
    final rawStreak = read<int?>(proNotOwnedStreak, null);

    // Non-empty text, otherwise null.
    String? readText(String key) {
      final v = read<String?>(key, null);
      return v == null || v.isEmpty ? null : v;
    }

    // A non-negative count, otherwise 0.
    int readCounter(String key) {
      final v = read<int?>(key, null);
      return v != null && v >= 0 ? v : 0;
    }

    final order = [
      ...readList(moduleOrder, d.moduleOrder).where(knownModuleIds.contains),
    ];
    for (final id in knownModuleIds) {
      if (!order.contains(id)) order.add(id);
    }
    var enabled = readList(
      enabledModules,
      d.enabledModules,
    ).where(knownModuleIds.contains).toList();
    if (enabled.isEmpty && order.isNotEmpty) enabled = [order.first];

    return AppSettings(
      locale: supportedLanguageCodes.contains(rawLocale) ? rawLocale : null,
      currencyCode: read(currencyCode, d.currencyCode),
      themeMode: oneOf(themeMode, themeModeIds, d.themeMode),
      selectedTheme: oneOf(selectedTheme, colorThemeIds, d.selectedTheme),
      firstDayOfWeek: oneOf(
        firstDayOfWeek,
        firstDayOfWeekOptions,
        d.firstDayOfWeek,
      ),
      lockEnabled: read(lockEnabled, d.lockEnabled),
      biometricEnabled: read(biometricEnabled, d.biometricEnabled),
      enabledModules: enabled,
      moduleOrder: order,
      onboardingDone: read(onboardingDone, d.onboardingDone),
      adConsentStatus: read<String?>(adConsentStatus, null),
      lastBackupAt: read<int?>(lastBackupAt, null),
      removeAdsPurchased: read(removeAdsPurchased, d.removeAdsPurchased),
      notificationsEnabled: read(notificationsEnabled, d.notificationsEnabled),
      budgetAlertsEnabled: read(budgetAlertsEnabled, d.budgetAlertsEnabled),
      habitRemindersEnabled: read(
        habitRemindersEnabled,
        d.habitRemindersEnabled,
      ),
      debugUnlockAll: read(debugUnlockAll, d.debugUnlockAll),
      latestSeenAt: read<int?>(latestSeenAt, null),
      dailyInsightDate: readDateKey(dailyInsightDate),
      dailyInsightId: rawInsightId == null || rawInsightId.isEmpty
          ? null
          : rawInsightId,
      homeComingSoonDismissed: read(
        homeComingSoonDismissed,
        d.homeComingSoonDismissed,
      ),
      dateFormat: oneOf(dateFormat, dateFormatIds, d.dateFormat),
      dailySummaryTime: rawTime != null && isValidTimeOfDay(rawTime)
          ? rawTime
          : d.dailySummaryTime,
      lockAfterSeconds: oneOf(
        lockAfterSeconds,
        lockAfterOptions,
        d.lockAfterSeconds,
      ),
      hideInRecents: read(hideInRecents, d.hideInRecents),
      fontSize: oneOf(fontSize, fontSizeIds, d.fontSize),
      lastBackupLocation: BackupLocation.values
          .where((l) => l.name == rawLocation)
          .firstOrNull,
      lastBackupSizeBytes: rawSize != null && rawSize >= 0 ? rawSize : null,
      backupEncrypt: read(backupEncrypt, d.backupEncrypt),
      backupIncludeReceipts: read(
        backupIncludeReceipts,
        d.backupIncludeReceipts,
      ),
      backupAccountEmail: rawEmail == null || rawEmail.isEmpty
          ? null
          : rawEmail,
      autoBackupFrequency:
          AutoBackupFrequency.values
              .where((f) => f.name == rawFrequency)
              .firstOrNull ??
          d.autoBackupFrequency,
      autoBackupWifiOnly: read(autoBackupWifiOnly, d.autoBackupWifiOnly),
      lastAutoBackupAt: read<int?>(lastAutoBackupAt, null),
      autoBackupFailures: rawFailures != null && rawFailures >= 0
          ? rawFailures
          : d.autoBackupFailures,
      autoBackupFailureNotified: read(
        autoBackupFailureNotified,
        d.autoBackupFailureNotified,
      ),
      showDataOnWidget: read(showDataOnWidget, d.showDataOnWidget),
      deviceTimeZoneId: rawZone == null || rawZone.isEmpty ? null : rawZone,
      adsInstallAt: read<int?>(adsInstallAt, null),
      adsLastInterstitialAt: read<int?>(adsLastInterstitialAt, null),
      adsInterstitialDay: readDateKey(adsInterstitialDay),
      adsInterstitialsToday: rawShownToday != null && rawShownToday >= 0
          ? rawShownToday
          : d.adsInterstitialsToday,
      adsLastSessionDay: readDateKey(adsLastSessionDay),
      rewardedDay: readDateKey(rewardedDay),
      rewardedCounts: readCounts(rewardedCounts),
      proNotOwnedStreak: rawStreak == null ? 0 : rawStreak.clamp(0, 2),
      proPurchasePending: read(proPurchasePending, d.proPurchasePending),
      proRemovalPending: read(proRemovalPending, d.proRemovalPending),
      accountDisplayName: readText(accountDisplayName),
      accountPhotoUrl: readText(accountPhotoUrl),
      deviceId: readText(deviceId),
      dataChangeCounter: readCounter(dataChangeCounter),
      backedUpChangeCounter: readCounter(backedUpChangeCounter),
      lastBackgroundBackupAt: read<int?>(lastBackgroundBackupAt, null),
      lastKnownDriveBackupAt: read<int?>(lastKnownDriveBackupAt, null),
      lastKnownDriveBackupDeviceId: readText(lastKnownDriveBackupDeviceId),
      autoBackupPausedByConflict: read(
        autoBackupPausedByConflict,
        d.autoBackupPausedByConflict,
      ),
      autoBackupPauseNotified: read(
        autoBackupPauseNotified,
        d.autoBackupPauseNotified,
      ),
      finishSetupPending: read(finishSetupPending, d.finishSetupPending),
      authMode:
          AuthMode.values.where((m) => m.name == rawAuthMode).firstOrNull ??
          d.authMode,
      backupLeaseUntil: read<int?>(backupLeaseUntil, null),
    );
  }
}
