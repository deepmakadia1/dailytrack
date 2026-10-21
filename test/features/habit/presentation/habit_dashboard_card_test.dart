import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import '../habit_test_app.dart';

/// Home habit card (T089; spec US7, FR-046). Today is Wednesday 2026-10-21.
void main() {
  Finder check(String id) => find.byKey(ValueKey('home_check_$id'));

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> home(WidgetTester tester, HabitFakes f) =>
      pumpHabitApp(tester, habits: f, location: Routes.home);

  testWidgets('US7-1 ring "X of Y done today" and one check per scheduled '
      'habit in sort order', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    final b = f.addHabit('B').id;
    f
      ..addHabit(
        'Tue only',
        schedule: const HabitSchedule(
          type: ScheduleType.specificWeekdays,
          target: 1,
          weekdays: {2},
        ),
      )
      ..setDay(a, '2026-10-21');
    await home(tester, f);
    expect(find.text('1 of 2 done today'), findsOneWidget);
    expect(check(a), findsOneWidget);
    expect(check(b), findsOneWidget);
    expect(
      tester.getTopLeft(check(a)).dx,
      lessThan(tester.getTopLeft(check(b)).dx),
    );
    expect(find.bySemanticsLabel('Mark A not done'), findsOneWidget);
    expect(find.bySemanticsLabel('Mark B done'), findsOneWidget);
    expect(tester.getSize(check(a)).width, greaterThanOrEqualTo(48));
  });

  testWidgets('US7-2 a yes/no tap checks it; the ring updates', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    await home(tester, f);
    expect(find.text('0 of 1 done today'), findsOneWidget);
    await tapAndSettle(tester, check(a));
    expect(f.entry(a, '2026-10-21')?.value, 1);
    expect(find.text('1 of 1 done today'), findsOneWidget);
    expect(f.scheduler.calls, ['reconcile:$a']);
  });

  testWidgets('US7-2 a count tap offers +1 and a custom value', (tester) async {
    final f = habitFakes();
    final w = f
        .addHabit(
          'Water',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
          unit: 'glasses',
        )
        .id;
    await home(tester, f);
    expect(find.bySemanticsLabel('Water, 0 of 8 glasses'), findsOneWidget);
    await tapAndSettle(tester, check(w));
    await tapAndSettle(tester, find.byKey(const Key('count_add_one')));
    expect(f.entry(w, '2026-10-21')?.value, 1);
    await tapAndSettle(tester, check(w));
    await tapAndSettle(tester, find.byKey(const Key('count_custom')));
    await tester.enterText(find.byKey(const Key('value_entry_field')), '8');
    await tapAndSettle(tester, find.byKey(const Key('value_entry_set')));
    expect(f.entry(w, '2026-10-21')?.value, 8);
    expect(find.text('1 of 1 done today'), findsOneWidget);
  });

  testWidgets('US7-3 a long-press opens HAB-03', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    await home(tester, f);
    await tester.longPress(check(a));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailScreen), findsOneWidget);
  });

  testWidgets('US7-4 without habits: "Create your first habit" opens HAB-02', (
    tester,
  ) async {
    await home(tester, habitFakes());
    await tapAndSettle(tester, find.text('Create your first habit'));
    expect(find.byType(HabitFormScreen), findsOneWidget);
  });

  testWidgets('nothing scheduled today says so', (tester) async {
    final f = habitFakes()..addHabit('Later', start: '2026-11-01');
    await home(tester, f);
    expect(find.text('Nothing scheduled today'), findsOneWidget);
  });

  testWidgets('a milestone from the card shows the sheet', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A', start: '2026-10-15').id;
    f.doneRange(a, '2026-10-15', '2026-10-20');
    await home(tester, f);
    await tapAndSettle(tester, check(a));
    expect(find.text('7-day streak!'), findsOneWidget);
  });

  testWidgets('an error offers Try again', (tester) async {
    final f = habitFakes()
      ..addHabit('A')
      ..world.failWatch = Exception('boom');
    await home(tester, f);
    expect(find.byKey(const Key('habit_card_error')), findsOneWidget);
    f.world.failWatch = null;
    await tapAndSettle(tester, find.text('Try again'));
    expect(find.text('0 of 1 done today'), findsOneWidget);
  });
  // --- Feature 006 (T029): DSH-01 habit card upgrade.

  List<String> haptics(WidgetTester tester) {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return calls;
  }

  testWidgets('DSH-01 US2-1 yes/no check updates the ring with a light '
      'haptic', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    f.addHabit('B');
    await home(tester, f);
    final calls = haptics(tester);
    expect(find.text('0 of 2 done today'), findsOneWidget);
    await tapAndSettle(tester, check(a));
    expect(find.text('1 of 2 done today'), findsOneWidget);
    expect(find.bySemanticsLabel('Mark A not done'), findsOneWidget);
    expect(calls, ['HapticFeedbackType.lightImpact']);
  });

  testWidgets('DSH-01 US2-2 unchecking offers Undo, which restores done', (
    tester,
  ) async {
    final f = habitFakes();
    final a = f.addHabit('Read').id;
    f.setDay(a, '2026-10-21');
    await home(tester, f);
    expect(find.text('1 of 1 done today'), findsOneWidget);
    await tapAndSettle(tester, check(a));
    expect(find.text('0 of 1 done today'), findsOneWidget);
    expect(find.text('Read unchecked'), findsOneWidget);
    await tapAndSettle(tester, find.text('Undo'));
    expect(f.entry(a, '2026-10-21')?.value, 1);
    expect(find.text('1 of 1 done today'), findsOneWidget);
  });

  testWidgets('DSH-01 US2-3 count 12/20: +1 records 13; custom sets a value', (
    tester,
  ) async {
    final f = habitFakes();
    final w = f
        .addHabit(
          'Pages',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 20),
        )
        .id;
    f.setDay(w, '2026-10-21', value: 12);
    await home(tester, f);
    await tapAndSettle(tester, check(w));
    await tapAndSettle(tester, find.byKey(const Key('count_add_one')));
    expect(f.entry(w, '2026-10-21')?.value, 13);
    await tapAndSettle(tester, check(w));
    await tapAndSettle(tester, find.byKey(const Key('count_custom')));
    await tester.enterText(find.byKey(const Key('value_entry_field')), '18');
    await tapAndSettle(tester, find.byKey(const Key('value_entry_set')));
    expect(f.entry(w, '2026-10-21')?.value, 18);
  });

  testWidgets('DSH-01 US2-4 long-press opens /habits/<id>', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    await home(tester, f);
    await tester.longPress(check(a));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailScreen), findsOneWidget);
    expect(
      tester.widget<HabitDetailScreen>(find.byType(HabitDetailScreen)).id,
      a,
    );
  });

  testWidgets('DSH-01 US2-5 a milestone opens the sheet once', (tester) async {
    final f = habitFakes();
    final a = f.addHabit('A', start: '2026-10-15').id;
    f.doneRange(a, '2026-10-15', '2026-10-20');
    await home(tester, f);
    await tapAndSettle(tester, check(a));
    expect(find.text('7-day streak!'), findsOneWidget);
  });

  testWidgets('DSH-01 the check row is a horizontal list that scrolls with '
      '12 habits', (tester) async {
    final f = habitFakes();
    final ids = [for (var i = 0; i < 12; i++) f.addHabit('Habit $i').id];
    await home(tester, f);
    final list = find.byKey(const Key('habit_card_checks'));
    expect(tester.widget<ListView>(list).scrollDirection, Axis.horizontal);
    expect(check(ids.last).hitTestable(), findsNothing);
    await tester.drag(list, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(check(ids.last).hitTestable(), findsOneWidget);
  });

  testWidgets('DSH-01 the check row does not overflow at 200% text on a '
      '360 dp screen', (tester) async {
    final f = habitFakes();
    for (var i = 0; i < 12; i++) {
      f.addHabit('A long habit name $i');
    }
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHabitApp(
      tester,
      habits: f,
      location: Routes.home,
      size: const Size(360, 780),
    );
    expect(tester.takeException(), isNull);
    final row = tester.getRect(find.byKey(const Key('habit_card_checks')));
    final button = tester.getRect(check(f.world.active.first.id));
    expect(row.contains(button.topLeft), isTrue);
    expect(button.bottom, lessThanOrEqualTo(row.bottom));
  });

  testWidgets('DSH-01 SC-002 a yes/no check-in is one tap; a count +1 is two', (
    tester,
  ) async {
    final f = habitFakes();
    final a = f.addHabit('A').id;
    final w = f
        .addHabit(
          'Water',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
        )
        .id;
    await home(tester, f);
    var taps = 0;
    Future<void> tap(Finder finder) async {
      taps++;
      await tapAndSettle(tester, finder);
    }

    await tap(check(a));
    expect(f.entry(a, '2026-10-21')?.value, 1);
    expect(taps, 1);
    taps = 0;
    await tap(check(w));
    await tap(find.byKey(const Key('count_add_one')));
    expect(f.entry(w, '2026-10-21')?.value, 1);
    expect(taps, 2);
  });
}
