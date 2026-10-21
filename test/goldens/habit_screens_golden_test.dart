@Tags(['golden'])
library;

import 'package:dailytrack/app/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/habit/fakes.dart';
import '../features/habit/habit_test_app.dart';

/// §15.10 / Constitution IV screen goldens for the Habit module (T093):
/// HAB-01 with 5 habits in light/dark × English/Gujarati, and HAB-01 empty,
/// HAB-02, HAB-03 (locked chart), HAB-04, and the milestone sheet in
/// light/dark English, on a 360×800 surface with fakes only. Baselines are
/// made and compared on Linux: `flutter test --tags golden --update-goldens`.
void main() {
  Future<void> pump(
    WidgetTester tester,
    HabitFakes habits,
    String location, {
    required String theme,
    required String lang,
  }) => pumpHabitApp(
    tester,
    habits: habits,
    location: location,
    locale: lang,
    themeMode: theme,
    size: const Size(360, 800),
  );

  final scenarios =
      <
        String,
        ({
          List<String> langs,
          Future<void> Function(WidgetTester, String theme, String lang) build,
        })
      >{
        'HAB-01 five habits': (
          langs: ['en', 'gu'],
          build: (tester, theme, lang) => pump(
            tester,
            sampleHabits(),
            Routes.habits,
            theme: theme,
            lang: lang,
          ),
        ),
        'HAB-01 empty': (
          langs: ['en'],
          build: (tester, theme, lang) => pump(
            tester,
            habitFakes(),
            Routes.habits,
            theme: theme,
            lang: lang,
          ),
        ),
        'HAB-02 template read': (
          langs: ['en'],
          build: (tester, theme, lang) => pump(
            tester,
            habitFakes(),
            Routes.habitAddPath(template: 'read'),
            theme: theme,
            lang: lang,
          ),
        ),
        'HAB-03 locked chart': (
          langs: ['en'],
          build: (tester, theme, lang) {
            final f = sampleHabits();
            final id = f.world.habits.values.first.id;
            return pump(
              tester,
              f,
              Routes.habitDetailPath(id),
              theme: theme,
              lang: lang,
            );
          },
        ),
        'HAB-04 archived': (
          langs: ['en'],
          build: (tester, theme, lang) {
            final f = habitFakes()..addHabit('Swim', archived: true);
            return pump(
              tester,
              f,
              Routes.habitArchived,
              theme: theme,
              lang: lang,
            );
          },
        ),
        'milestone sheet': (
          langs: ['en'],
          build: (tester, theme, lang) async {
            final f = habitFakes();
            final id = f.addHabit('Read', start: '2026-10-15').id;
            f.doneRange(id, '2026-10-15', '2026-10-20');
            await pump(tester, f, Routes.habits, theme: theme, lang: lang);
            await tester.tap(find.byKey(ValueKey('check_$id')));
            await tester.pumpAndSettle();
          },
        ),
      };

  for (final MapEntry(key: name, value: s) in scenarios.entries) {
    for (final theme in const ['light', 'dark']) {
      for (final lang in s.langs) {
        testWidgets('$name golden $theme $lang', (tester) async {
          await s.build(tester, theme, lang);
          final file =
              '${name.toLowerCase().replaceAll(' ', '_')}'
              '_${theme}_$lang.png';
          await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        });
      }
    }
  }
}
