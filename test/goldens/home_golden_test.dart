@Tags(['golden'])
library;

import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/fakes.dart';
import '../features/habit/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// §15.9, §15.10 / Constitution IV goldens for DSH-01 (T059): seeded content
/// and the first day in light/dark × English/Gujarati, plus only-Expense and
/// only-Habit in light English, on a 360×800 surface with fakes only. "Now"
/// is 2026-10-14 10:00. Baselines are made and compared on Linux:
/// `flutter test --tags golden --update-goldens`.
void main() {
  ({ExpenseFakes expense, HabitFakes habits}) seeded() {
    final expense = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addBudget(limit: 1000000)
      ..addTransaction(amount: 85000, category: 'food', note: 'Lunch')
      ..addTransaction(amount: 120000, category: 'groceries')
      ..addTransaction(amount: 500000, type: TxnType.transfer, toAccount: 'sbi')
      ..addTransaction(amount: 30000, category: 'transport')
      ..addTransaction(
        amount: 50000,
        category: 'food',
        at: DateTime(2026, 9, 5),
      );
    final habits = HabitFakes(expense.clock);
    final read = habits.addHabit('Read').id;
    final walk = habits.addHabit('Walk').id;
    habits
      ..addHabit('Meditate')
      ..doneRange(read, '2026-10-08', '2026-10-13')
      ..setDay(walk, '2026-10-14');
    return (expense: expense, habits: habits);
  }

  ({ExpenseFakes expense, HabitFakes habits}) firstDay() {
    final expense = ExpenseFakes.withDefaults();
    return (expense: expense, habits: HabitFakes(expense.clock));
  }

  Future<void> pump(
    WidgetTester tester,
    ({ExpenseFakes expense, HabitFakes habits}) data, {
    required String theme,
    required String lang,
    List<String> enabled = const ['expense', 'habit'],
  }) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTestApp(
      tester,
      expense: data.expense,
      habit: data.habits,
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          locale: lang,
          themeMode: theme,
          enabledModules: enabled,
        ),
      ),
    );
  }

  final scenarios =
      <
        String,
        ({
          List<String> themes,
          List<String> langs,
          Future<void> Function(WidgetTester, String theme, String lang) build,
        })
      >{
        'DSH-01 seeded': (
          themes: ['light', 'dark'],
          langs: ['en', 'gu'],
          build: (tester, theme, lang) =>
              pump(tester, seeded(), theme: theme, lang: lang),
        ),
        'DSH-01 first day': (
          themes: ['light', 'dark'],
          langs: ['en', 'gu'],
          build: (tester, theme, lang) =>
              pump(tester, firstDay(), theme: theme, lang: lang),
        ),
        'DSH-01 only expense': (
          themes: ['light'],
          langs: ['en'],
          build: (tester, theme, lang) => pump(
            tester,
            seeded(),
            theme: theme,
            lang: lang,
            enabled: const ['expense'],
          ),
        ),
        'DSH-01 only habit': (
          themes: ['light'],
          langs: ['en'],
          build: (tester, theme, lang) => pump(
            tester,
            seeded(),
            theme: theme,
            lang: lang,
            enabled: const ['habit'],
          ),
        ),
      };

  for (final MapEntry(key: name, value: s) in scenarios.entries) {
    for (final theme in s.themes) {
      for (final lang in s.langs) {
        testWidgets('$name golden $theme $lang', (tester) async {
          await s.build(tester, theme, lang);
          final file =
              '${name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '')}'
              '_${theme}_$lang.png';
          await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        });
      }
    }
  }
}
