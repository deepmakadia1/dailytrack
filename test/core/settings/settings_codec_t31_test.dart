import 'dart:convert';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _known = ['expense', 'habit'];

/// T3.1 settings keys (T006, feature 007 data-model.md §1).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  AppSettings decode(Map<String, Object?> json) => SettingsCodec.decode({
    for (final e in json.entries) e.key: jsonEncode(e.value),
  }, knownModuleIds: _known);

  test('new keys decode to their defaults when missing', () {
    final s = decode(const {});
    expect(s.dateFormat, 'dMMMy');
    expect(s.dailySummaryTime, '21:00');
    expect(s.lockAfterSeconds, 60);
    expect(s.hideInRecents, isFalse);
    expect(s.fontSize, 'default');
  });

  test('allowed values decode as stored', () {
    final s = decode(const {
      'dateFormat': 'iso',
      'dailySummaryTime': '07:05',
      'lockAfterSeconds': 300,
      'hideInRecents': true,
      'fontSize': 'large',
      'themeMode': 'dark',
      'selectedTheme': 'saffron',
      'firstDayOfWeek': 7,
    });
    expect(s.dateFormat, 'iso');
    expect(s.dailySummaryTime, '07:05');
    expect(s.lockAfterSeconds, 300);
    expect(s.hideInRecents, isTrue);
    expect(s.fontSize, 'large');
    expect(s.themeMode, 'dark');
    expect(s.selectedTheme, 'saffron');
    expect(s.firstDayOfWeek, 7);
  });

  test('values outside the allowed sets decode to the defaults', () {
    final s = decode(const {
      'dateFormat': 'yyyy',
      'lockAfterSeconds': 30,
      'fontSize': 'huge',
      'themeMode': 'sepia',
      'selectedTheme': 'neon',
      'firstDayOfWeek': 3,
    });
    expect(s.dateFormat, 'dMMMy');
    expect(s.lockAfterSeconds, 60);
    expect(s.fontSize, 'default');
    expect(s.themeMode, 'system');
    expect(s.selectedTheme, 'default');
    expect(s.firstDayOfWeek, 1);
  });

  for (final bad in ['21:5', '24:00', '9:00', '12:60', 'x']) {
    test('daily summary time "$bad" decodes to 21:00', () {
      expect(decode({'dailySummaryTime': bad}).dailySummaryTime, '21:00');
    });
  }

  group('SettingsRepositoryImpl', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db, knownModuleIds: _known);
    });
    tearDown(() => db.close());

    test('every setter round-trips an allowed value', () async {
      await repo.setThemeMode('light');
      await repo.setSelectedTheme('indigo');
      await repo.setFontSize('large');
      await repo.setFirstDayOfWeek(6);
      await repo.setDateFormat('ddMMy');
      await repo.setDailySummaryTime('20:30');
      await repo.setLockEnabled(enabled: true);
      await repo.setBiometricEnabled(enabled: true);
      await repo.setLockAfterSeconds(0);
      await repo.setHideInRecents(enabled: true);

      final s = await repo.load();
      expect(s.themeMode, 'light');
      expect(s.selectedTheme, 'indigo');
      expect(s.fontSize, 'large');
      expect(s.firstDayOfWeek, 6);
      expect(s.dateFormat, 'ddMMy');
      expect(s.dailySummaryTime, '20:30');
      expect(s.lockEnabled, isTrue);
      expect(s.biometricEnabled, isTrue);
      expect(s.lockAfterSeconds, 0);
      expect(s.hideInRecents, isTrue);
    });

    test('setters ignore values outside the allowed sets', () async {
      await repo.setThemeMode('sepia');
      await repo.setSelectedTheme('neon');
      await repo.setFontSize('huge');
      await repo.setFirstDayOfWeek(3);
      await repo.setDateFormat('yyyy');
      await repo.setDailySummaryTime('25:00');
      await repo.setLockAfterSeconds(30);

      final rows = await db.select(db.settings).get();
      expect(rows, isEmpty);
    });
  });
}
