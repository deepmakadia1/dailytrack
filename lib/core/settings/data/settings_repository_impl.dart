import 'dart:convert';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/utils/date_keys.dart';

/// Drift-backed [SettingsRepository]. Bound only in `production_overrides.dart`
/// (T058).
class SettingsRepositoryImpl implements SettingsRepository {
  new(this._db, {required List<String> knownModuleIds})
    : _knownModuleIds = List.unmodifiable(knownModuleIds);

  final AppDatabase _db;
  final List<String> _knownModuleIds;

  AppSettings _decode(List<SettingRow> rows) => SettingsCodec.decode({
    for (final r in rows) r.key: r.value,
  }, knownModuleIds: _knownModuleIds);

  @override
  Future<AppSettings> load() async =>
      _decode(await _db.select(_db.settings).get());

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.settings).watch().map(_decode).distinct();

  Future<void> _put(String key, Object? value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: SettingsCodec.encode(value),
          updatedAt: Epoch.nowUtcMs(),
        ),
      );

  @override
  Future<void> setLocale(String? languageCode) async {
    if (languageCode != null &&
        !supportedLanguageCodes.contains(languageCode)) {
      return;
    }
    await _put(SettingsCodec.locale, languageCode);
  }

  @override
  Future<void> setCurrency(String code) =>
      _put(SettingsCodec.currencyCode, code);

  void _checkModules(List<String> enabled) {
    if (enabled.where(_knownModuleIds.contains).isEmpty) {
      throw const LastModuleError();
    }
  }

  @override
  Future<void> setModules({
    required List<String> order,
    required List<String> enabled,
  }) async {
    _checkModules(enabled);
    await _db.transaction(() async {
      await _put(SettingsCodec.moduleOrder, order);
      await _put(SettingsCodec.enabledModules, enabled);
    });
  }

  @override
  Future<void> completeOnboarding(OnboardingChoices choices) async {
    _checkModules(choices.enabledModules);
    final locale = supportedLanguageCodes.contains(choices.locale)
        ? choices.locale
        : null;
    await _db.transaction(() async {
      await _put(SettingsCodec.locale, locale);
      await _put(SettingsCodec.currencyCode, choices.currencyCode);
      await _put(SettingsCodec.moduleOrder, choices.moduleOrder);
      await _put(SettingsCodec.enabledModules, choices.enabledModules);
      // Written last, so an interrupted save never marks onboarding done.
      await _put(SettingsCodec.onboardingDone, true);
    });
  }

  @override
  Future<bool> isSeeded(String seederId) async {
    return await _row(SettingsCodec.seedKey(seederId)) != null;
  }

  @override
  Future<void> markSeeded(String seederId) =>
      _put(SettingsCodec.seedKey(seederId), Epoch.nowUtcMs());

  @override
  Future<void> setNotificationsEnabled({required bool enabled}) =>
      _put(SettingsCodec.notificationsEnabled, enabled);

  @override
  Future<void> setBudgetAlertsEnabled({required bool enabled}) =>
      _put(SettingsCodec.budgetAlertsEnabled, enabled);

  @override
  Future<void> setHabitRemindersEnabled({required bool enabled}) =>
      _put(SettingsCodec.habitRemindersEnabled, enabled);

  @override
  Future<void> setDebugUnlockAll({required bool enabled}) =>
      _put(SettingsCodec.debugUnlockAll, enabled);

  @override
  Future<void> setDailyInsight({
    required String dateKey,
    required String ruleId,
  }) => _db.transaction(() async {
    await _put(SettingsCodec.dailyInsightDate, dateKey);
    await _put(SettingsCodec.dailyInsightId, ruleId);
  });

  @override
  Future<void> setHomeComingSoonDismissed({required bool dismissed}) =>
      _put(SettingsCodec.homeComingSoonDismissed, dismissed);

  @override
  Future<void> setThemeMode(String mode) async {
    if (!themeModeIds.contains(mode)) return;
    await _put(SettingsCodec.themeMode, mode);
  }

  @override
  Future<void> setSelectedTheme(String id) async {
    if (!colorThemeIds.contains(id)) return;
    await _put(SettingsCodec.selectedTheme, id);
  }

  @override
  Future<void> setFontSize(String size) async {
    if (!fontSizeIds.contains(size)) return;
    await _put(SettingsCodec.fontSize, size);
  }

  @override
  Future<void> setFirstDayOfWeek(int day) async {
    if (!firstDayOfWeekOptions.contains(day)) return;
    await _put(SettingsCodec.firstDayOfWeek, day);
  }

  @override
  Future<void> setDateFormat(String format) async {
    if (!dateFormatIds.contains(format)) return;
    await _put(SettingsCodec.dateFormat, format);
  }

  @override
  Future<void> setDailySummaryTime(String hhmm) async {
    if (!isValidTimeOfDay(hhmm)) return;
    await _put(SettingsCodec.dailySummaryTime, hhmm);
  }

  @override
  Future<void> setLockEnabled({required bool enabled}) =>
      _put(SettingsCodec.lockEnabled, enabled);

  @override
  Future<void> setBiometricEnabled({required bool enabled}) =>
      _put(SettingsCodec.biometricEnabled, enabled);

  @override
  Future<void> setLockAfterSeconds(int seconds) async {
    if (!lockAfterOptions.contains(seconds)) return;
    await _put(SettingsCodec.lockAfterSeconds, seconds);
  }

  @override
  Future<void> setHideInRecents({required bool enabled}) =>
      _put(SettingsCodec.hideInRecents, enabled);

  @override
  Future<void> raiseLatestSeenAt(int utcMs) => _db.transaction(() async {
    final current = (await load()).latestSeenAt;
    if (current != null && current >= utcMs) return;
    await _put(SettingsCodec.latestSeenAt, utcMs);
  });

  Future<SettingRow?> _row(String key) => (_db.select(
    _db.settings,
  )..where((t) => t.key.equals(key))).getSingleOrNull();

  @override
  Future<String?> readModuleState(String key) async {
    final row = await _row(SettingsCodec.moduleStateKey(key));
    if (row == null) return null;
    try {
      final v = jsonDecode(row.value);
      return v is String ? v : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> writeModuleState(String key, String value) =>
      _put(SettingsCodec.moduleStateKey(key), value);
}
