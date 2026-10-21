import 'dart:ui' show Tristate;

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../habit_test_app.dart';

/// HAB-01 Habits today (T053, T080; spec US1, FR-016–FR-023, FR-036).
/// Today is Wednesday 2026-10-21; weeks start on Monday 19.
void main() {
  const mwf = HabitSchedule(
    type: ScheduleType.specificWeekdays,
    target: 1,
    weekdays: {1, 3, 5},
  );
  const pages20 = HabitSchedule(type: ScheduleType.daily, target: 20);

  Finder check(String id) => find.byKey(ValueKey('check_$id'));
  Finder plus(String id) => find.byKey(ValueKey('plus_$id'));
  Finder streak(String id) => find.byKey(ValueKey('streak_$id'));
  String streakText(WidgetTester tester, String id) =>
      tester.widget<Text>(streak(id)).data!;

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('HAB-01 US1-1 empty state', () {
    testWidgets('shows "Build your first habit" and the 6 template chips', (
      tester,
    ) async {
      await pumpHabitApp(tester, habits: habitFakes());
      expect(find.text('Build your first habit'), findsOneWidget);
      for (final name in [
        'Drink water',
        'Read',
        'Walk',
        'Meditate',
        'Wake up early',
        'Study',
      ]) {
        expect(find.widgetWithText(ActionChip, name), findsOneWidget);
      }
    });

    testWidgets('a chip opens HAB-02 prefilled; the FAB opens it empty', (
      tester,
    ) async {
      await pumpHabitApp(tester, habits: habitFakes());
      await tapAndSettle(tester, find.byKey(const ValueKey('template_read')));
      expect(
        tester.widget<HabitFormScreen>(find.byType(HabitFormScreen)).templateId,
        'read',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('habit_name')))
            .controller!
            .text,
        'Read',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('habit_target')))
            .controller!
            .text,
        '20',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('habit_unit')))
            .controller!
            .text,
        'pages',
      );
      routerOf(tester).go(Routes.habits);
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('habit_fab')));
      final form = tester.widget<HabitFormScreen>(find.byType(HabitFormScreen));
      expect((form.id, form.templateId), (null, null));
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('habit_name')))
            .controller!
            .text,
        isEmpty,
      );
    });

    testWidgets('SC-001: the "Read" chip then "Save habit" creates the habit '
        'in 2 taps', (tester) async {
      final f = habitFakes();
      await pumpHabitApp(tester, habits: f);
      await tapAndSettle(tester, find.byKey(const ValueKey('template_read')));
      await tapAndSettle(tester, find.byKey(const Key('save_habit')));
      final created = f.world.habits.values.single;
      expect(created.name, 'Read');
      expect(
        (created.kind, created.schedule.target, created.unit),
        (HabitKind.count, 20, 'pages'),
      );
      expect(find.byType(HabitsTodayScreen), findsOneWidget);
      expect(find.text('Habit saved'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      await flushTimers(tester);
    });
  });

  group('HAB-01 criterion "Toggling a yes/no habit creates or deletes the '
      'habit_entries row for that date key"', () {
    testWidgets('US1-4 check stores value 1 for today; again removes it with '
        'a 5-second Undo', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Meditate').id;
      await pumpHabitApp(tester, habits: f);

      await tapAndSettle(tester, check(id));
      expect(f.entry(id, '2026-10-21')?.value, 1);
      expect(
        find.descendant(
          of: check(id),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);

      await tapAndSettle(tester, check(id));
      expect(f.entry(id, '2026-10-21'), isNull);
      expect(find.text('Check-in removed'), findsOneWidget);
      await tapAndSettle(tester, find.text('Undo'));
      expect(f.entry(id, '2026-10-21')?.value, 1);
      await flushTimers(tester);
    });
  });

  testWidgets('HAB-01 criterion "Streak updates immediately after check-in '
      'and matches the rules in section 4"', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Meditate').id;
    f.doneRange(id, '2026-10-19', '2026-10-20');
    await pumpHabitApp(tester, habits: f);
    expect(streakText(tester, id), '2 days');
    await tester.tap(check(id));
    await tester.pump();
    await tester.pump();
    expect(streakText(tester, id), '3 days');
  });

  testWidgets('HAB-01 criterion "Back-filling yesterday restores a broken '
      'streak" on the first day of the week', (tester) async {
    // Monday 19: yesterday (Sunday 18) is in the previous week.
    final f = habitFakes(now: DateTime(2026, 10, 19, 9));
    final id = f.addHabit('Meditate', start: '2026-10-13').id;
    f.doneRange(id, '2026-10-13', '2026-10-17');
    await pumpHabitApp(tester, habits: f);
    expect(streakText(tester, id), '0 days');
    expect(find.byKey(const ValueKey('day_2026-10-18')), findsNothing);

    await tapAndSettle(tester, find.byKey(const Key('week_previous')));
    await tapAndSettle(tester, find.byKey(const ValueKey('day_2026-10-18')));
    await tapAndSettle(tester, check(id));
    expect(f.entry(id, '2026-10-18')?.value, 1);
    expect(streakText(tester, id), '6 days');
  });

  group('US1-5 count habits', () {
    testWidgets('+ adds 1; long-press sets 0–9,999; values above the target '
        'are kept', (tester) async {
      final f = habitFakes();
      final id = f
          .addHabit(
            'Read',
            kind: HabitKind.count,
            schedule: pages20,
            unit: 'pages',
          )
          .id;
      f.setDay(id, '2026-10-21', value: 12);
      await pumpHabitApp(tester, habits: f);
      expect(find.text('12 / 20 pages'), findsOneWidget);

      await tapAndSettle(tester, plus(id));
      expect(f.entry(id, '2026-10-21')?.value, 13);
      expect(find.text('13 / 20 pages'), findsOneWidget);

      await tester.longPress(plus(id));
      await tester.pumpAndSettle();
      expect(find.text('Set value for Read'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('value_entry_field')), '');
      await tapAndSettle(tester, find.byKey(const Key('value_entry_set')));
      expect(find.text('Enter a whole number from 0 to 9,999'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('value_entry_field')), '25');
      await tapAndSettle(tester, find.byKey(const Key('value_entry_set')));
      expect(f.entry(id, '2026-10-21')?.value, 25);
      expect(find.text('25 / 20 pages'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('reaching the target with + shows done', (tester) async {
      final f = habitFakes();
      final id = f
          .addHabit(
            'Water',
            kind: HabitKind.count,
            schedule: const HabitSchedule(type: ScheduleType.daily, target: 2),
          )
          .id;
      f.setDay(id, '2026-10-21');
      await pumpHabitApp(tester, habits: f);
      expect(find.text('Done'), findsNothing);
      await tapAndSettle(tester, plus(id));
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('1 of 1 done'), findsOneWidget);
    });
  });

  testWidgets('US1-6 card: icon, name, schedule text, streak, check; '
      'scheduled first, then the collapsed "Not scheduled today"', (
    tester,
  ) async {
    final f = habitFakes();
    final a = f.addHabit('Gym', schedule: mwf).id;
    f.doneRange(a, '2026-10-19', '2026-10-19');
    final b = f
        .addHabit(
          'Swim',
          schedule: const HabitSchedule(
            type: ScheduleType.timesPerWeek,
            target: 1,
            timesPerWeek: 3,
          ),
        )
        .id;
    f
      ..setDay(b, '2026-10-20')
      ..addHabit(
        'Tennis',
        schedule: const HabitSchedule(
          type: ScheduleType.specificWeekdays,
          target: 1,
          weekdays: {2},
        ),
      )
      ..addHabit('Later', start: '2026-10-25');
    await pumpHabitApp(tester, habits: f);

    expect(find.text('Mon, Wed, Fri'), findsOneWidget);
    expect(find.text('3× per week · 2 left'), findsOneWidget);
    expect(streakText(tester, a), '1 day');
    expect(check(a), findsOneWidget);
    expect(find.text('0 of 2 done'), findsOneWidget);
    // Tuesday-only and future-start habits are under the collapsed section.
    expect(find.text('Not scheduled today'), findsOneWidget);
    expect(find.text('Tennis'), findsNothing);
    await tapAndSettle(tester, find.text('Not scheduled today'));
    expect(find.text('Tennis'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Gym')).dy,
      lessThan(tester.getTopLeft(find.text('Tennis')).dy),
    );
  });

  group('US1-7 / US1-8 week strip', () {
    testWidgets('7 days from the first day of the week; future days are '
        'disabled; a past day switches the list', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      f.setDay(id, '2026-10-20');
      await pumpHabitApp(tester, habits: f);
      for (final k in [
        '2026-10-19',
        '2026-10-20',
        '2026-10-21',
        '2026-10-22',
        '2026-10-25',
      ]) {
        expect(find.byKey(ValueKey('day_$k')), findsOneWidget, reason: k);
      }
      final future = tester.getSemantics(
        find.byKey(const ValueKey('day_2026-10-22')),
      );
      expect(future.hint, "Future days can't be checked in yet");
      expect(future.flagsCollection.isEnabled, Tristate.isFalse);
      await tapAndSettle(tester, find.byKey(const ValueKey('day_2026-10-22')));
      expect(find.text('0 of 1 done'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const ValueKey('day_2026-10-20')));
      expect(find.text('1 of 1 done'), findsOneWidget);
      expect(find.text('Not scheduled on this day'), findsNothing);
    });

    testWidgets('weeks start on Sunday when the setting says so', (
      tester,
    ) async {
      await pumpHabitApp(
        tester,
        habits: habitFakes()..addHabit('Read'),
        firstDayOfWeek: 7,
      );
      final sunday = tester.getTopLeft(
        find.byKey(const ValueKey('day_2026-10-18')),
      );
      final monday = tester.getTopLeft(
        find.byKey(const ValueKey('day_2026-10-19')),
      );
      expect(sunday.dx, lessThan(monday.dx));
      expect(find.byKey(const ValueKey('day_2026-10-25')), findsNothing);
    });

    testWidgets('one page back: days up to 7 back are selectable, older ones '
        'are disabled with a hint', (tester) async {
      // Tuesday 20: Monday 12 is 8 days back, Tuesday 13 is 7.
      final f = habitFakes(now: DateTime(2026, 10, 20, 9))..addHabit('Read');
      await pumpHabitApp(tester, habits: f);
      await tapAndSettle(tester, find.byKey(const Key('week_previous')));
      final old = tester.getSemantics(
        find.byKey(const ValueKey('day_2026-10-12')),
      );
      expect(old.hint, "Edit older days from the habit's page");
      expect(old.flagsCollection.isEnabled, Tristate.isFalse);
      final ok = tester.getSemantics(
        find.byKey(const ValueKey('day_2026-10-13')),
      );
      expect(ok.flagsCollection.isEnabled, Tristate.isTrue);
      // Back to the current week.
      await tapAndSettle(tester, find.byKey(const Key('week_next')));
      expect(find.byKey(const ValueKey('day_2026-10-25')), findsOneWidget);
    });
  });

  testWidgets('US1-9 "All done for today" appears and disappears', (
    tester,
  ) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    final b = f.addHabit('B').id;
    f.setDay(a, '2026-10-21');
    await pumpHabitApp(tester, habits: f);
    expect(find.byKey(const Key('all_done_banner')), findsNothing);
    await tapAndSettle(tester, check(b));
    expect(find.text('All done for today'), findsOneWidget);
    await tapAndSettle(tester, check(a));
    expect(find.text('All done for today'), findsNothing);
    await flushTimers(tester);
  });

  group('FR-019 check animation', () {
    Future<Duration> switcherDuration(WidgetTester tester, String id) async =>
        tester
            .widget<AnimatedSwitcher>(
              find.descendant(
                of: check(id),
                matching: find.byType(AnimatedSwitcher),
              ),
            )
            .duration;

    testWidgets('runs for 150–250 ms', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(tester, habits: f);
      final d = await switcherDuration(tester, id);
      expect(d.inMilliseconds, inInclusiveRange(150, 250));
    });

    testWidgets('with "Remove animations" the check shows done at once', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(tester, habits: f);
      expect(await switcherDuration(tester, id), Duration.zero);
      await tester.tap(check(id));
      await tester.pump();
      await tester.pump();
      expect(
        find.descendant(
          of: check(id),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: check(id),
          matching: find.byIcon(Icons.radio_button_unchecked),
        ),
        findsNothing,
        reason: 'no outgoing icon still animating',
      );
    });
  });

  group('US1-10 long-press menu', () {
    testWidgets('offers Edit, Add note for today, Skip today, Archive', (
      tester,
    ) async {
      final f = habitFakes()..addHabit('Read', freezes: 1);
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      for (final item in [
        'Edit',
        'Add note for today',
        'Skip today',
        'Archive',
      ]) {
        expect(find.text(item), findsOneWidget, reason: item);
      }
      await tapAndSettle(tester, find.byKey(const Key('menu_edit')));
      expect(
        tester.widget<HabitFormScreen>(find.byType(HabitFormScreen)).id,
        f.world.habits.keys.single,
      );
    });

    testWidgets('"Add note for today" stores the note without marking done', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('menu_add_note')));
      await tester.enterText(find.byKey(const Key('note_field')), 'Tired');
      await tapAndSettle(tester, find.byKey(const Key('note_save')));
      final e = f.entry(id, '2026-10-21')!;
      expect((e.value, e.note, e.isFreeze), (0, 'Tired', false));
      expect(find.text('Note saved'), findsOneWidget);
      expect(find.text('0 of 1 done'), findsOneWidget);
      await flushTimers(tester);
    });

    testWidgets('Archive hides the habit, cancels reminders, and Undo puts it '
        'back in place', (tester) async {
      final f = habitFakes();
      final a = f.addHabit('A').id;
      f.addHabit('B');
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('A'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('menu_archive')));
      expect(find.text('A'), findsNothing);
      expect(find.text('Habit archived'), findsOneWidget);
      expect(f.scheduler.calls, contains('cancel:$a'));
      await tapAndSettle(tester, find.text('Undo'));
      expect(find.text('A'), findsOneWidget);
      expect(f.world.habits[a]!.sortOrder, 0);
      expect(f.habits.calls, containsAllInOrder(['archive', 'undoArchive']));
      expect(f.scheduler.calls.last, 'reconcile:$a');
      await flushTimers(tester);
    });

    testWidgets('Skip today is disabled with "No freezes left" at 0', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      expect(find.text('No freezes left'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.byKey(const Key('menu_skip_today')),
      );
      expect(tile.enabled, isFalse);
      await tester.tap(find.byKey(const Key('menu_skip_today')));
      await tester.pumpAndSettle();
      expect(f.entry(id, '2026-10-21'), isNull);
    });
  });

  group('T080 Skip today (FR-036, clarification Q1)', () {
    testWidgets('uses a freeze on today; Undo restores both', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read', freezes: 1).id;
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      expect(find.text('Uses 1 of your 1 freezes'), findsOneWidget);
      await tapAndSettle(tester, find.byKey(const Key('menu_skip_today')));
      expect(f.entry(id, '2026-10-21')?.isFreeze, isTrue);
      expect(f.world.habits[id]!.freezesAvailable, 0);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.text('Freeze day'), findsOneWidget);
      await tapAndSettle(tester, find.text('Undo'));
      expect(f.entry(id, '2026-10-21'), isNull);
      expect(f.world.habits[id]!.freezesAvailable, 1);
      await flushTimers(tester);
    });

    testWidgets('checking in after Skip today refunds the freeze', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Read', freezes: 1).id;
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('menu_skip_today')));
      await tapAndSettle(tester, check(id));
      final e = f.entry(id, '2026-10-21')!;
      expect((e.value, e.isFreeze), (1, false));
      expect(f.world.habits[id]!.freezesAvailable, 1);
      await flushTimers(tester);
    });

    testWidgets('not offered when today is done', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read', freezes: 2).id;
      f.setDay(id, '2026-10-21');
      await pumpHabitApp(tester, habits: f);
      await tester.longPress(find.text('Read'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('menu_skip_today')), findsNothing);
    });
  });

  testWidgets('US1-11 reorder mode persists the dragged order', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('Alpha').id;
    final b = f.addHabit('Beta').id;
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, find.byKey(const Key('habits_overflow')));
    await tapAndSettle(tester, find.byKey(const Key('menu_reorder')));
    expect(find.byKey(const Key('reorder_list')), findsOneWidget);

    final handle = find.descendant(
      of: find.byKey(ValueKey('reorder_$a')),
      matching: find.byIcon(Icons.drag_handle),
    );
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(f.habits.calls, contains('reorder'));
    expect(
      (f.world.habits[b]!.sortOrder, f.world.habits[a]!.sortOrder),
      (0, 1),
    );
    await tapAndSettle(tester, find.byKey(const Key('reorder_done')));
    expect(
      tester.getTopLeft(find.text('Beta')).dy,
      lessThan(tester.getTopLeft(find.text('Alpha')).dy),
    );
  });

  group('FR-023 states', () {
    testWidgets('the skeleton appears only after 300 ms', (tester) async {
      final f = habitFakes()..world.watchDelay = const Duration(seconds: 1);
      tester.view
        ..physicalSize = const Size(412, 915)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpHabitApp(tester, habits: f, location: Routes.home);
      routerOf(tester).go(Routes.habits);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SkeletonList), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Build your first habit'), findsOneWidget);
    });

    testWidgets('an error shows "Try again", which reloads', (tester) async {
      final f = habitFakes()
        ..world.failWatch = Exception('boom')
        ..addHabit('Read');
      await pumpHabitApp(tester, habits: f);
      expect(find.byType(ErrorState), findsOneWidget);
      expect(
        find.text("Couldn't load your habits. Try again."),
        findsOneWidget,
      );
      f.world.failWatch = null;
      await tapAndSettle(tester, find.text('Try again'));
      expect(find.text('Read'), findsOneWidget);
    });
  });

  testWidgets('FR-049: no ad slot on HAB-01', (tester) async {
    await pumpHabitApp(tester, habits: habitFakes()..addHabit('Read'));
    final scaffold = tester.widget<AppScaffold>(
      find.descendant(
        of: find.byType(HabitsTodayScreen),
        matching: find.byType(AppScaffold),
      ),
    );
    expect(scaffold.bannerSlot, isNull);
  });

  testWidgets('a day rollover on resume selects the new today', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Read').id;
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, find.byKey(const ValueKey('day_2026-10-20')));
    f.clock.value = DateTime(2026, 10, 22, 8);
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, check(id));
    expect(f.entry(id, '2026-10-22')?.value, 1);
    expect(LocalDate.fromDateTime(f.clock.now()).key, '2026-10-22');
  });
}
