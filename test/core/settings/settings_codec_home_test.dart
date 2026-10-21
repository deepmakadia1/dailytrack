import 'dart:convert';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _known = ['expense', 'habit'];

/// DSH-01 settings keys (T008, feature 006 data-model.md §1).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  AppSettings decode(Map<String, Object?> json) => SettingsCodec.decode({
    for (final e in json.entries) e.key: jsonEncode(e.value),
  }, knownModuleIds: _known);

  test('the three keys decode to their defaults when missing', () {
    final s = decode(const {});
    expect(s.dailyInsightDate, isNull);
    expect(s.dailyInsightId, isNull);
    expect(s.homeComingSoonDismissed, isFalse);
  });

  test('valid values decode', () {
    final s = decode(const {
      'dailyInsightDate': '2026-10-20',
      'dailyInsightId': 'habit.comeback',
      'homeComingSoonDismissed': true,
    });
    expect(s.dailyInsightDate, '2026-10-20');
    expect(s.dailyInsightId, 'habit.comeback');
    expect(s.homeComingSoonDismissed, isTrue);
  });

  test('a malformed date decodes to null', () {
    for (final bad in <Object>['2026-13-40', 'x', 42, '2026-2-1']) {
      expect(
        decode({'dailyInsightDate': bad}).dailyInsightDate,
        isNull,
        reason: '$bad',
      );
    }
  });

  test('a non-string or empty id decodes to null', () {
    expect(decode(const {'dailyInsightId': 7}).dailyInsightId, isNull);
    expect(decode(const {'dailyInsightId': ''}).dailyInsightId, isNull);
  });

  test('a non-bool dismissed flag decodes to false', () {
    expect(
      decode(const {'homeComingSoonDismissed': 'yes'}).homeComingSoonDismissed,
      isFalse,
    );
  });

  group('SettingsRepositoryImpl', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db, knownModuleIds: _known);
    });
    tearDown(() => db.close());

    test('round-trips the daily insight and the dismissed flag', () async {
      await repo.setDailyInsight(
        dateKey: '2026-10-20',
        ruleId: 'expense.budgetOnTrack',
      );
      await repo.setHomeComingSoonDismissed(dismissed: true);
      var s = await repo.load();
      expect(s.dailyInsightDate, '2026-10-20');
      expect(s.dailyInsightId, 'expense.budgetOnTrack');
      expect(s.homeComingSoonDismissed, isTrue);
      await repo.setHomeComingSoonDismissed(dismissed: false);
      s = await repo.load();
      expect(s.homeComingSoonDismissed, isFalse);
    });

    test('setDailyInsight writes both keys in one transaction', () async {
      final emissions = <(String?, String?)>[];
      final sub = repo.watch().listen(
        (s) => emissions.add((s.dailyInsightDate, s.dailyInsightId)),
      );
      await pumpEventQueue();
      await repo.setDailyInsight(dateKey: '2026-10-20', ruleId: 'a.one');
      await pumpEventQueue();
      await repo.setDailyInsight(dateKey: '2026-10-21', ruleId: 'b.two');
      await pumpEventQueue();
      await sub.cancel();
      // Never a half-written pair such as ('2026-10-21', 'a.one').
      expect(emissions, [
        (null, null),
        ('2026-10-20', 'a.one'),
        ('2026-10-21', 'b.two'),
      ]);
    });
  });
}
