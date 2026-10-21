import 'package:dailytrack/app/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/habit/fakes.dart';
import '../features/habit/habit_test_app.dart';

/// §15.10 / T094: HAB-01 to HAB-04, the milestone sheet, and the Home card
/// at 200% font scale on a 360 dp wide screen in en, hi and gu: no
/// overflow (reported as a test failure), 48 dp tap targets, and labelled
/// controls. Same checks as `font_scale_test.dart`.
void main() {
  const languages = ['en', 'hi', 'gu'];
  const phone = Size(360, 800);

  void scale(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Scrolls the list keyed [list] until [target] is visible.
  Future<void> scrollTo(WidgetTester tester, Finder target, String list) =>
      tester.scrollUntilVisible(
        target,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(Key(list)),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  Future<void> expectAccessible(WidgetTester tester) async {
    final screen = tester.element(find.byType(Scaffold).last);
    expect(MediaQuery.textScalerOf(screen).scale(10), 20);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  for (final lang in languages) {
    group(lang, () {
      Future<HabitFakes> open(
        WidgetTester tester,
        String location, {
        HabitFakes? habits,
      }) async {
        scale(tester);
        final f = habits ?? sampleHabits();
        await pumpHabitApp(
          tester,
          habits: f,
          location: location,
          locale: lang,
          size: phone,
        );
        return f;
      }

      testWidgets('HAB-01 with 5 habits at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester, Routes.habits);
        await expectAccessible(tester);
        // The collapsed section and the bottom of the list too.
        await scrollTo(
          tester,
          find.byKey(const Key('not_scheduled_section')),
          'habits_list',
        );
        await tester.tap(find.byKey(const Key('not_scheduled_section')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('HAB-01 empty state at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester, Routes.habits, habits: habitFakes());
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('HAB-01 long-press menu at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        final f = await open(tester, Routes.habits);
        final id = f.world.habits.values.first.id;
        await tester.longPress(find.byKey(ValueKey('habit_card_$id')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('HAB-02 new and edit at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        final f = await open(tester, Routes.habitAddPath(template: 'read'));
        await expectAccessible(tester);
        await scrollTo(
          tester,
          find.byKey(const Key('start_today')),
          'habit_form',
        );
        await expectAccessible(tester);
        final id = f.world.habits.values.first.id;
        routerOf(tester).go(Routes.habitEditPath(id));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('HAB-03 at 200%, top to bottom', (tester) async {
        final semantics = tester.ensureSemantics();
        final f = sampleHabits();
        final id = f.world.habits.values.elementAt(1).id;
        await open(tester, Routes.habitDetailPath(id), habits: f);
        await expectAccessible(tester);
        for (final key in [
          'section_calendar',
          'section_heatmap',
          'section_chart',
          'section_notes',
          'freeze_card',
        ]) {
          await scrollTo(tester, find.byKey(Key(key)), 'habit_detail');
          await expectAccessible(tester);
        }
        semantics.dispose();
      });

      testWidgets('HAB-04 with rows and empty at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        final f = habitFakes()
          ..addHabit('Swim every morning before work', archived: true)
          ..addHabit('Guitar', archived: true);
        await open(tester, Routes.habitArchived, habits: f);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('HAB-04 empty at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester, Routes.habitArchived, habits: habitFakes());
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('milestone sheet at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        final f = habitFakes();
        final id = f.addHabit('Read', start: '2026-10-15').id;
        f.doneRange(id, '2026-10-15', '2026-10-20');
        await open(tester, Routes.habits, habits: f);
        await tester.tap(find.byKey(ValueKey('check_$id')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('Home habit card at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester, Routes.home);
        await tester.scrollUntilVisible(
          find.byKey(const Key('habit_dashboard_card')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await expectAccessible(tester);
        semantics.dispose();
      });
    });
  }
}
