import 'dart:ui' show Tristate;

import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../fakes.dart';
import '../habit_test_app.dart';

/// HAB-03 Habit detail (T079; spec US5, FR-029–FR-037). Today is Wednesday
/// 2026-10-21; weeks start on Monday 19.
void main() {
  const tall = Size(412, 2600);

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<HabitFakes> open(
    WidgetTester tester,
    HabitFakes f,
    String id, {
    FakeFeatureGate? gate,
    FakeImageSharer? sharer,
    bool debugTools = false,
    bool debugUnlockAll = false,
  }) async {
    await pumpHabitApp(
      tester,
      habits: f,
      location: '/habits/$id',
      size: tall,
      gate: gate,
      imageSharer: sharer,
      debugTools: debugTools,
      debugUnlockAll: debugUnlockAll,
    );
    return f;
  }

  String tileText(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  SemanticsNode day(WidgetTester tester, String key) =>
      tester.getSemantics(find.byKey(ValueKey('cal_$key')));

  testWidgets('US5-1 sections in order: header, tiles, calendar, heatmap, '
      'chart, notes, freeze card', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Walk').id;
    await open(tester, f, id);
    final order = [
      'detail_header',
      'stat_tiles',
      'section_calendar',
      'section_heatmap',
      'section_chart',
      'section_notes',
      'freeze_card',
    ];
    final ys = [
      for (final k in order) tester.getTopLeft(find.byKey(Key(k))).dy,
    ];
    expect(ys, [...ys]..sort(), reason: order.join(' < '));
    expect(find.text('Walk'), findsWidgets);
    expect(find.text('Daily'), findsOneWidget);
  });

  testWidgets('FR-029: a HAB-01 card tap opens HAB-03', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Walk').id;
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, find.byKey(ValueKey('habit_card_$id')));
    expect(find.byType(HabitDetailScreen), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('detail_edit')));
    expect(tester.widget<HabitFormScreen>(find.byType(HabitFormScreen)).id, id);
  });

  testWidgets('stat tiles: current, best, rate, total', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Walk', start: '2026-10-12').id;
    f
      ..doneRange(id, '2026-10-12', '2026-10-14')
      ..doneRange(id, '2026-10-18', '2026-10-20');
    await open(tester, f, id);
    expect(tileText(tester, 'stat_current'), '3 days');
    expect(tileText(tester, 'stat_best'), '3 days');
    // 6 of 9 past days (today pending): 66.7 % → 67.
    expect(tileText(tester, 'stat_rate'), '67%');
    expect(tileText(tester, 'stat_total'), '6');
  });

  testWidgets('HAB-03 criterion "Completion rate counts only scheduled days" '
      '(Mon/Wed/Fri)', (tester) async {
    final f = habitFakes();
    final id = f
        .addHabit(
          'Gym',
          start: '2026-10-12',
          schedule: const HabitSchedule(
            type: ScheduleType.specificWeekdays,
            target: 1,
            weekdays: {1, 3, 5},
          ),
        )
        .id;
    // Mon 12 ✓, Tue 13 (unscheduled) ✓, Wed 14 ✗, Fri 16 ✓, Mon 19 ✗.
    for (final k in ['2026-10-12', '2026-10-13', '2026-10-16']) {
      f.setDay(id, k);
    }
    await open(tester, f, id);
    expect(tileText(tester, 'stat_rate'), '50%');
    expect(tileText(tester, 'stat_total'), '3');
  });

  testWidgets('a rate with no countable day shows —', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Walk', start: '2026-10-21').id;
    await open(tester, f, id);
    expect(tileText(tester, 'stat_rate'), '—');
  });

  group('US5-2 / US5-3 calendar', () {
    testWidgets('markings have text equivalents; future days are disabled', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Walk', start: '2026-10-15').id;
      f
        ..setDay(id, '2026-10-19')
        ..setDay(id, '2026-10-20', value: 0, freeze: true)
        ..setDay(id, '2026-10-16', value: 0, note: 'Rain');
      await open(tester, f, id);
      expect(day(tester, '2026-10-19').label, contains('done'));
      expect(day(tester, '2026-10-20').label, contains('freeze day'));
      expect(day(tester, '2026-10-18').label, contains('missed'));
      expect(day(tester, '2026-10-16').hint, 'has a note');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('cal_2026-10-20')),
          matching: find.byIcon(Icons.ac_unit),
        ),
        findsOneWidget,
      );
      final future = day(tester, '2026-10-22');
      expect(future.flagsCollection.isEnabled, Tristate.isFalse);
      final before = day(tester, '2026-10-14');
      expect(before.flagsCollection.isEnabled, Tristate.isFalse);
      await tester.tap(find.byKey(const ValueKey('cal_2026-10-22')));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('tapping a past day toggles it and saves a note', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      await open(tester, f, id);
      await tapAndSettle(tester, find.byKey(const ValueKey('cal_2026-10-13')));
      expect(find.text('Edit 13 Oct 2026'), findsOneWidget);
      await tapAndSettle(tester, find.byKey(const Key('day_done')));
      await tester.enterText(
        find.byKey(const Key('day_note')),
        'Rainy, walked indoors',
      );
      await tapAndSettle(tester, find.byKey(const Key('day_save')));
      final e = f.entry(id, '2026-10-13')!;
      expect((e.value, e.note), (1, 'Rainy, walked indoors'));
      expect(find.text('Day saved'), findsOneWidget);
      expect(day(tester, '2026-10-13').label, contains('done'));
      await flushTimers(tester);
    });

    testWidgets('a count day takes a value', (tester) async {
      final f = habitFakes();
      final id = f
          .addHabit(
            'Water',
            kind: HabitKind.count,
            schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
          )
          .id;
      await open(tester, f, id);
      await tapAndSettle(tester, find.byKey(const ValueKey('cal_2026-10-13')));
      await tester.enterText(find.byKey(const Key('day_value')), '5');
      await tapAndSettle(tester, find.byKey(const Key('day_save')));
      expect(f.entry(id, '2026-10-13')?.value, 5);
      expect(day(tester, '2026-10-13').label, contains('5 of 8'));
      await flushTimers(tester);
    });

    testWidgets('pages back to the start month, no further', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk', start: '2026-09-20').id;
      await open(tester, f, id);
      expect(find.text('October 2026'), findsOneWidget);
      await tapAndSettle(tester, find.byKey(const Key('calendar_previous')));
      expect(find.text('September 2026'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('calendar_previous')))
            .onPressed,
        isNull,
      );
    });
  });

  testWidgets('US5-4 heatmap share renders the grid to heatmap.png', (
    tester,
  ) async {
    final f = habitFakes();
    final sharer = FakeImageSharer();
    final id = f.addHabit('Walk', start: '2026-01-01').id;
    f.doneRange(id, '2026-10-01', '2026-10-20');
    await open(tester, f, id, sharer: sharer);
    final summary = tester.getSemantics(find.byKey(const Key('heatmap_paint')));
    expect(
      summary.label,
      contains('20 of 294 days done in the last 12 months'),
    );
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share_heatmap')));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(sharer.shared.single.fileName, 'heatmap.png');
    expect(sharer.shared.single.png.sublist(0, 4), [137, 80, 78, 71]);
  });

  group('US5-5 weekly chart (FR-032)', () {
    testWidgets('locked: the shared overlay, no "Watch an ad", "Get Pro" '
        'disabled', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      await open(tester, f, id, gate: FakeFeatureGate());
      final overlay = tester.widget<LockedFeatureOverlay>(
        find.byType(LockedFeatureOverlay),
      );
      expect(overlay.onWatchAd, isNull);
      expect(overlay.onGetPro, isNull);
      expect(find.text('Watch an ad'), findsNothing);
      final getPro = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Get Pro'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(getPro.onPressed, isNull);
    });

    testWidgets('unlocked (also by the dev switch): the chart is shown', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      final gate = FakeFeatureGate(
        unlocked: {FeatureKey.advancedReports: true},
      );
      await open(tester, f, id, gate: gate);
      expect(find.byType(LockedFeatureOverlay), findsNothing);
      expect(find.byType(BarChart), findsOneWidget);
      gate.set(FeatureKey.advancedReports, unlocked: false);
      await tester.pumpAndSettle();
      expect(find.byType(LockedFeatureOverlay), findsOneWidget);
    });
  });

  group('US5-6 notes', () {
    testWidgets('newest first with dates', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      f
        ..setDay(id, '2026-10-05', value: 0, note: 'Older')
        ..setDay(id, '2026-10-19', note: 'Newer');
      await open(tester, f, id);
      expect(
        tester.getTopLeft(find.text('Newer')).dy,
        lessThan(tester.getTopLeft(find.text('Older')).dy),
      );
      expect(find.text('19 Oct 2026'), findsOneWidget);
    });

    testWidgets('one line when there are none', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      await open(tester, f, id);
      expect(find.text('No notes yet'), findsOneWidget);
    });
  });

  group('US5-7 – US5-9 freeze card', () {
    testWidgets('using a freeze on yesterday: snowflake, streak restored, '
        'Undo returns the freeze', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk', start: '2026-10-15', freezes: 1).id;
      f.doneRange(id, '2026-10-15', '2026-10-19');
      await open(tester, f, id);
      expect(find.text('Freezes available: 1'), findsOneWidget);
      expect(tileText(tester, 'stat_current'), '0 days');

      await tapAndSettle(tester, find.byKey(const Key('use_freeze')));
      await tapAndSettle(
        tester,
        find.byKey(const ValueKey('freeze_day_2026-10-20')),
      );
      expect(f.entry(id, '2026-10-20')?.isFreeze, isTrue);
      expect(find.text('Freezes available: 0'), findsOneWidget);
      expect(tileText(tester, 'stat_current'), '5 days');
      expect(day(tester, '2026-10-20').label, contains('freeze day'));
      expect(find.text('Freeze used'), findsOneWidget);

      await tapAndSettle(tester, find.text('Undo'));
      expect(f.entry(id, '2026-10-20'), isNull);
      expect(find.text('Freezes available: 1'), findsOneWidget);
      await flushTimers(tester);
    });

    testWidgets('HAB-03 criterion "A freeze cannot be applied to today or to '
        'a day older than 3 days"', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk', freezes: 2).id;
      await open(tester, f, id);
      await tapAndSettle(tester, find.byKey(const Key('use_freeze')));
      for (final k in ['2026-10-20', '2026-10-19', '2026-10-18']) {
        expect(
          find.byKey(ValueKey('freeze_day_$k')),
          findsOneWidget,
          reason: k,
        );
      }
      expect(find.byKey(const ValueKey('freeze_day_2026-10-21')), findsNothing);
      expect(find.byKey(const ValueKey('freeze_day_2026-10-17')), findsNothing);
    });

    testWidgets('no freezes or no missed day: "Use a freeze" is disabled', (
      tester,
    ) async {
      final f = habitFakes();
      final none = f.addHabit('A').id;
      await open(tester, f, none);
      expect(
        tester
            .widget<ButtonStyleButton>(find.byKey(const Key('use_freeze')))
            .onPressed,
        isNull,
      );
      final g = habitFakes();
      final clean = g.addHabit('B', freezes: 1).id;
      g.doneRange(clean, '2026-10-01', '2026-10-20');
      await open(tester, g, clean);
      expect(find.byKey(const Key('no_freezeable_day')), findsOneWidget);
    });

    testWidgets('US5-8 / US5-9: the debug grant adds 1 up to 2 (cap)', (
      tester,
    ) async {
      final f = habitFakes();
      final id = f.addHabit('Walk', freezes: 1).id;
      await open(tester, f, id, debugTools: true, debugUnlockAll: true);
      await tapAndSettle(tester, find.byKey(const Key('add_freeze_debug')));
      expect(f.world.habits[id]!.freezesAvailable, 2);
      expect(find.text('Freezes available: 2'), findsOneWidget);
      expect(find.text('You can keep up to 2 freezes'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('add_freeze_debug')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('US5-9: the debug button is absent without dev tools or with '
        'the switch off', (tester) async {
      final f = habitFakes();
      final id = f.addHabit('Walk').id;
      await open(tester, f, id, debugUnlockAll: true);
      expect(find.byKey(const Key('add_freeze_debug')), findsNothing);
      final g = habitFakes();
      final id2 = g.addHabit('Walk').id;
      await open(tester, g, id2, debugTools: true);
      expect(find.byKey(const Key('add_freeze_debug')), findsNothing);
    });
  });

  testWidgets('a write that reaches a milestone shows the sheet', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f.addHabit('Walk', start: '2026-10-14').id;
    f
      ..doneRange(id, '2026-10-14', '2026-10-16')
      ..doneRange(id, '2026-10-18', '2026-10-21');
    await open(tester, f, id);
    await tapAndSettle(tester, find.byKey(const ValueKey('cal_2026-10-17')));
    await tapAndSettle(tester, find.byKey(const Key('day_done')));
    await tapAndSettle(tester, find.byKey(const Key('day_save')));
    expect(find.text('7-day streak!'), findsOneWidget);
  });

  testWidgets('error state with Try again; no ad slot (FR-049)', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f.addHabit('Walk').id;
    f.world.failWatch = Exception('boom');
    await open(tester, f, id);
    expect(find.byType(ErrorState), findsOneWidget);
    f.world.failWatch = null;
    await tapAndSettle(tester, find.text('Try again'));
    expect(find.byKey(const Key('stat_tiles')), findsOneWidget);
    final scaffold = tester.widget<AppScaffold>(
      find.descendant(
        of: find.byType(HabitDetailScreen),
        matching: find.byType(AppScaffold),
      ),
    );
    expect(scaffold.bannerSlot, isNull);
  });
}
