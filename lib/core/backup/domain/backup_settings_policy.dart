/// Which `settings` keys travel in a backup (FR-009, feature 008 research R6).
/// Only user preferences: lock, PIN, account, backup and widget settings, ad
/// consent, purchase state, and other device state never leave or get
/// replaced, so a restore can never lock the user out.
abstract final class BackupSettingsPolicy {
  static const Set<String> restorableKeys = {
    'locale',
    'currencyCode',
    'firstDayOfWeek',
    'dateFormat',
    'themeMode',
    'selectedTheme',
    'fontSize',
    'enabledModules',
    'moduleOrder',
    'notificationsEnabled',
    'budgetAlertsEnabled',
    'habitRemindersEnabled',
    'dailySummaryTime',
    'homeComingSoonDismissed',
  };

  /// Module state keys (`module.<key>`) belong to the module's data.
  static const String moduleStatePrefix = 'module.';

  static bool isRestorable(String key) =>
      restorableKeys.contains(key) || key.startsWith(moduleStatePrefix);

  /// The subset of [all] that goes into a backup.
  static Map<String, String> exportable(Map<String, String> all) => {
    for (final MapEntry(:key, :value) in all.entries)
      if (isRestorable(key)) key: value,
  };
}
