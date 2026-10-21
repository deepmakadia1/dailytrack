import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_form_controller.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../fakes.dart';
import '../habit_test_app.dart';

/// HAB-02 Add / edit habit (T051, T065; spec US1-2, US1-3, US1-12, US1-13,
/// US4, FR-024–FR-028, FR-038). Today is Wednesday 2026-10-21.
void main() {
  Finder field(String key) => find.byKey(Key(key));
  String text(WidgetTester tester, String key) =>
      tester.widget<TextField>(field(key)).controller!.text;

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  /// Tall enough that the whole form fits without scrolling.
  const tall = Size(412, 2400);

  Future<void> save(WidgetTester tester) =>
      tapAndSettle(tester, field('save_habit'));

  testWidgets('US1-2 the fields are in order, with a sticky "Save habit"', (
    tester,
  ) async {
    await pumpHabitApp(
      tester,
      habits: habitFakes(),
      location: '/habits/add',
      size: tall,
    );
    final order = [
      'Name',
      'Icon',
      'Color',
      'Goal type',
      'Schedule',
      'Reminders',
      'Start date',
    ];
    final ys = [
      for (final label in order) tester.getTopLeft(find.text(label).first).dy,
    ];
    expect(ys, [...ys]..sort(), reason: order.join(' < '));
    expect(find.text('New habit'), findsOneWidget);
    // Defaults: yes/no, every day, start today, "only if not done" on.
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Yes / No'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Every day'))
          .selected,
      isTrue,
    );
    expect(tester.widget<ChoiceChip>(field('start_today')).selected, isTrue);
    expect(
      tester.widget<SwitchListTile>(field('remind_only_if_not_done')).value,
      isTrue,
    );
    // The save button lives in the bottom bar, outside the scrolling form.
    expect(
      find.descendant(of: field('habit_form'), matching: field('save_habit')),
      findsNothing,
    );
  });

  testWidgets('template prefill: Read, count 20 pages, every day', (
    tester,
  ) async {
    await pumpHabitApp(
      tester,
      size: tall,
      habits: habitFakes(),
      location: '/habits/add?template=read',
    );
    expect(text(tester, 'habit_name'), 'Read');
    expect(text(tester, 'habit_target'), '20');
    expect(text(tester, 'habit_unit'), 'pages');
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Count'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Every day'))
          .selected,
      isTrue,
    );
  });

  testWidgets('name suggestions come from the templates as the user types', (
    tester,
  ) async {
    await pumpHabitApp(
      tester,
      size: tall,
      habits: habitFakes(),
      location: '/habits/add',
    );
    await tester.enterText(field('habit_name'), 'me');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('suggestion_meditate')), findsOneWidget);
    expect(find.byKey(const ValueKey('suggestion_read')), findsNothing);
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('suggestion_meditate')),
    );
    expect(text(tester, 'habit_name'), 'Meditate');
    expect(text(tester, 'habit_target'), '10');
    expect(text(tester, 'habit_unit'), 'minutes');
    expect(find.byKey(const ValueKey('suggestion_meditate')), findsNothing);
  });

  group('validation (FR-025)', () {
    testWidgets('HAB-02 criterion "Specific days requires at least one '
        'weekday" (US1-3)', (tester) async {
      final f = habitFakes();
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/add',
      );
      await tester.enterText(field('habit_name'), 'Gym');
      await tapAndSettle(tester, find.text('Specific days'));
      await save(tester);
      expect(find.text('Choose at least one weekday'), findsOneWidget);
      expect(f.world.habits, isEmpty);
      expect(find.byType(HabitFormScreen), findsOneWidget);
      // Picking a weekday clears the error and saves.
      await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Mon'));
      expect(find.text('Choose at least one weekday'), findsNothing);
      await save(tester);
      expect(f.world.habits.values.single.schedule.weekdays, {1});
      await flushTimers(tester);
    });

    testWidgets('an empty name and an out-of-range target are explained '
        'next to the field', (tester) async {
      final f = habitFakes();
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/add',
      );
      await tapAndSettle(tester, find.text('Count'));
      await tester.enterText(field('habit_target'), '0');
      await save(tester);
      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a target from 1 to 9,999'), findsOneWidget);
      expect(f.world.habits, isEmpty);
      await tester.enterText(field('habit_name'), 'x' * 41);
      await save(tester);
      expect(find.text('Use at most 40 characters'), findsOneWidget);
    });

    testWidgets('weekday chips follow the first day of the week', (
      tester,
    ) async {
      await pumpHabitApp(
        tester,
        size: tall,
        habits: habitFakes(),
        location: '/habits/add',
        firstDayOfWeek: 7,
      );
      await tapAndSettle(tester, find.text('Specific days'));
      expect(
        tester.getTopLeft(find.widgetWithText(FilterChip, 'Sun')).dx,
        lessThan(tester.getTopLeft(find.widgetWithText(FilterChip, 'Mon')).dx),
      );
    });

    testWidgets('X times per week uses a 1–6 stepper', (tester) async {
      final f = habitFakes();
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/add',
      );
      await tester.enterText(field('habit_name'), 'Swim');
      await tapAndSettle(tester, find.text('X times per week'));
      expect(find.text('3× per week'), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        await tapAndSettle(tester, field('times_plus'));
      }
      expect(find.text('6× per week'), findsOneWidget);
      expect(tester.widget<IconButton>(field('times_plus')).onPressed, isNull);
      await tapAndSettle(tester, field('times_minus'));
      await save(tester);
      final s = f.world.habits.values.single.schedule;
      expect((s.type, s.timesPerWeek), (ScheduleType.timesPerWeek, 5));
      await flushTimers(tester);
    });
  });

  testWidgets('Save creates the habit, reconciles reminders, and returns '
      'with "Habit saved" (FR-026)', (tester) async {
    final f = habitFakes();
    await pumpHabitApp(tester, size: tall, habits: f, location: '/habits/add');
    await tester.enterText(field('habit_name'), '  Stretch  ');
    await tapAndSettle(tester, field('start_yesterday'));
    await save(tester);
    final h = f.world.habits.values.single;
    expect((h.name, h.startDate.key), ('Stretch', '2026-10-20'));
    expect(f.habits.calls, ['create']);
    expect(f.scheduler.calls, ['reconcile:${h.id}']);
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    expect(find.text('Habit saved'), findsOneWidget);
    await flushTimers(tester);
  });

  group('edit mode (US1-12)', () {
    testWidgets('the goal type is read-only', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/$id/edit',
      );
      expect(find.text('Edit habit'), findsOneWidget);
      expect(field('goal_locked'), findsOneWidget);
      expect(
        find.text("The goal type can't be changed after the habit is created"),
        findsOneWidget,
      );
      expect(field('goal_type'), findsNothing);
      expect(text(tester, 'habit_name'), 'Read');
    });

    testWidgets('changing the schedule calls update and keeps the history', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      f.doneRange(id, '2026-10-01', '2026-10-20');
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/$id/edit',
      );
      await tapAndSettle(tester, find.text('Specific days'));
      await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Wed'));
      await save(tester);
      expect(f.habits.calls, ['update']);
      expect(
        [for (final v in f.world.versions[id]!) v.effectiveFrom.key],
        ['2026-10-01', '2026-10-21'],
      );
      expect(f.world.entries[id], hasLength(20));
      expect(f.scheduler.calls, ['reconcile:$id']);
      await flushTimers(tester);
    });

    testWidgets('overflow Archive leaves with an Undo that restores the '
        'position', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      f.addHabit('Walk');
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/$id/edit',
      );
      await tapAndSettle(tester, field('habit_form_overflow'));
      await tapAndSettle(tester, field('form_archive'));
      expect(find.byType(HabitsTodayScreen), findsOneWidget);
      expect(find.text('Habit archived'), findsOneWidget);
      expect(f.world.habits[id]!.isArchived, isTrue);
      expect(f.scheduler.calls, ['cancel:$id']);
      await tapAndSettle(tester, find.text('Undo'));
      expect(f.world.habits[id]!.isArchived, isFalse);
      expect(f.world.habits[id]!.sortOrder, 0);
      expect(f.habits.calls, ['archive', 'undoArchive']);
      expect(f.scheduler.calls, ['cancel:$id', 'reconcile:$id']);
      await flushTimers(tester);
    });

    testWidgets('overflow Delete asks in a ConfirmDialog naming the history', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Read').id;
      await pumpHabitApp(
        tester,
        size: tall,
        habits: f,
        location: '/habits/$id/edit',
      );
      await tapAndSettle(tester, field('habit_form_overflow'));
      await tapAndSettle(tester, field('form_delete'));
      expect(find.text('Delete habit?'), findsOneWidget);
      expect(
        find.text('This removes Read and all its history.'),
        findsOneWidget,
      );
      await tapAndSettle(tester, find.text('Cancel'));
      expect(f.world.habits, contains(id));
      await tapAndSettle(tester, field('habit_form_overflow'));
      await tapAndSettle(tester, field('form_delete'));
      await tapAndSettle(tester, find.text('Delete habit'));
      expect(f.world.habits, isEmpty);
      expect(f.scheduler.calls, ['cancel:$id']);
      expect(find.text('Habit deleted'), findsOneWidget);
      expect(find.byType(HabitsTodayScreen), findsOneWidget);
      await flushTimers(tester);
    });

    testWidgets('a deleted habit says so and returns to HAB-01', (
      tester,
    ) async {
      await pumpHabitApp(
        tester,
        size: tall,
        habits: habitFakes(),
        location: '/habits/nope/edit',
      );
      expect(find.text('This habit no longer exists'), findsOneWidget);
      expect(find.byType(HabitsTodayScreen), findsOneWidget);
      await flushTimers(tester);
    });
  });

  group('US1-13 discard guard', () {
    testWidgets('leaving with changes asks "Discard changes?"', (tester) async {
      await pumpHabitApp(
        tester,
        size: tall,
        habits: habitFakes(),
        location: '/habits/add',
      );
      await tester.enterText(field('habit_name'), 'Gym');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Cancel'));
      expect(find.byType(HabitFormScreen), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text('Discard'));
      expect(find.byType(HabitsTodayScreen), findsOneWidget);
    });

    testWidgets(
      'leaving without changes (also after a template) does not ask',
      (tester) async {
        await pumpHabitApp(
          tester,
          size: tall,
          habits: habitFakes(),
          location: '/habits/add?template=read',
        );
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.text('Discard changes?'), findsNothing);
        expect(find.byType(HabitsTodayScreen), findsOneWidget);
      },
    );
  });

  group('reminders (T065, US4)', () {
    Future<void> addReminder(WidgetTester tester) async {
      await tapAndSettle(tester, field('add_reminder'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    testWidgets('"+ Add reminder" up to 3, then hidden; remove one; save '
        'reconciles', (tester) async {
      final f = habitFakes();
      await pumpHabitApp(
        tester,
        habits: f,
        location: '/habits/add',
        size: tall,
      );
      await tester.enterText(field('habit_name'), 'Water');
      for (var i = 0; i < 3; i++) {
        await addReminder(tester);
      }
      expect(find.byKey(const ValueKey('reminder_08:00')), findsOneWidget);
      expect(find.byKey(const ValueKey('reminder_09:00')), findsOneWidget);
      expect(find.byKey(const ValueKey('reminder_10:00')), findsOneWidget);
      expect(field('add_reminder'), findsNothing);
      expect(find.text('You can add up to 3 reminders'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Tooltip &&
              (w.message ?? '').startsWith('Remove reminder at 9:00'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('reminder_09:00')), findsNothing);
      expect(field('add_reminder'), findsOneWidget);

      await tapAndSettle(tester, field('remind_only_if_not_done'));
      await save(tester);
      final h = f.world.habits.values.single;
      expect(h.reminderTimes, const [ReminderTime(8, 0), ReminderTime(10, 0)]);
      expect(h.remindOnlyIfNotDone, isFalse);
      expect(f.scheduler.calls, ['reconcile:${h.id}']);
      await flushTimers(tester);
    });

    testWidgets('US4-7: denied notifications show a hint; saving still works', (
      tester,
    ) async {
      final f = habitFakes();
      await pumpHabitApp(
        tester,
        habits: f,
        location: '/habits/add',
        notifications: FakeNotificationService(allowed: false),
        size: tall,
      );
      expect(
        find.text('Reminders need notification permission'),
        findsOneWidget,
      );
      await tester.enterText(field('habit_name'), 'Water');
      await save(tester);
      expect(f.world.habits, hasLength(1));
      await flushTimers(tester);
    });

    testWidgets('FR-041: without exact alarms a reminder shows the "may be '
        'late" hint', (tester) async {
      final f = habitFakes()..scheduler.exact = false;
      await pumpHabitApp(
        tester,
        habits: f,
        location: '/habits/add',
        size: tall,
      );
      expect(field('inexact_hint'), findsNothing);
      await addReminder(tester);
      expect(find.text('Reminders may be a few minutes late'), findsOneWidget);
    });
  });

  group('HabitFormController reminders', () {
    late ProviderContainer c;
    late HabitFakes f;

    setUp(() {
      f = habitFakes();
      c = ProviderContainer(
        overrides: [
          ...f.overrides,
          clockProvider.overrideWithValue(f.clock),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
        ],
      );
      addTearDown(c.dispose);
    });

    test('a duplicate time is rejected; a 4th is rejected', () async {
      final p = habitFormControllerProvider(null);
      c.listen(p, (_, _) {});
      await pumpEventQueue();
      final ctl = c.read(p.notifier)
        ..addReminder(const ReminderTime(7, 0))
        ..addReminder(const ReminderTime(7, 0));
      expect(c.read(p).reminderError, HabitFieldError.duplicateReminder);
      ctl
        ..addReminder(const ReminderTime(12, 0))
        ..addReminder(const ReminderTime(21, 0));
      expect(c.read(p).reminderError, isNull);
      ctl.addReminder(const ReminderTime(22, 0));
      expect(c.read(p).reminderError, HabitFieldError.tooManyReminders);
      expect(c.read(p).draft.reminderTimes, hasLength(3));
      ctl.removeReminder(const ReminderTime(12, 0));
      expect(c.read(p).reminderError, isNull);
      expect(c.read(p).draft.reminderTimes, const [
        ReminderTime(7, 0),
        ReminderTime(21, 0),
      ]);
    });

    test('a failed save keeps the form and reports it', () async {
      final p = habitFormControllerProvider(null);
      c.listen(p, (_, _) {});
      await pumpEventQueue();
      final ctl = c.read(p.notifier)..setName('Read');
      f.world.failNextWrite = true;
      expect(await ctl.save(), isNull);
      expect(c.read(p).saveFailed, isTrue);
      expect(c.read(p).saving, isFalse);
    });

    test('a kind change resets a yes/no target to 1', () async {
      final p = habitFormControllerProvider(null);
      c.listen(p, (_, _) {});
      await pumpEventQueue();
      final ctl = c.read(p.notifier)
        ..setKind(HabitKind.count)
        ..setTarget('12');
      expect(c.read(p).draft.schedule.target, 12);
      ctl.setKind(HabitKind.yesNo);
      expect(
        c.read(p).draft.schedule,
        const HabitSchedule(type: ScheduleType.daily, target: 1),
      );
    });
  });
}
