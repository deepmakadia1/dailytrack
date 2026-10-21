import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../domain/history_builder.dart';

/// HAB-03 view-model builders (T076, research R13). Today is Wednesday
/// 2026-10-21; weeks start on Monday unless set.
void main() {
  final wed = engineAt('2026-10-21');

  group('intensity', () {
    test('quarters of min(value / target, 1)', () {
      expect(intensityOf(0, 20), 0);
      expect(intensityOf(1, 20), 1);
      expect(intensityOf(5, 20), 1);
      expect(intensityOf(6, 20), 2);
      expect(intensityOf(10, 20), 2);
      expect(intensityOf(15, 20), 3);
      expect(intensityOf(19, 20), 4);
      expect(intensityOf(20, 20), 4);
      expect(intensityOf(99, 20), 4, reason: 'capped at 100%');
      expect(intensityOf(1, 1), 4);
    });
  });

  group('day map', () {
    test('statuses, values, and notes per day', () {
      final h = history(
        start: '2026-10-19',
        schedule: count(4),
        values: {'2026-10-19': 4, '2026-10-20': 2},
        notes: {'2026-10-20': 'Busy'},
      );
      final days = buildDayMap(wed, h);
      expect(days[d('2026-10-19')]!.status, DayStatus.done);
      expect(days[d('2026-10-19')]!.intensity, 4);
      final tue = days[d('2026-10-20')]!;
      expect(
        (tue.status, tue.intensity, tue.value, tue.target),
        (DayStatus.partial, 2, 2, 4),
      );
      expect((tue.hasNote, tue.note), (true, 'Busy'));
      expect(days[d('2026-10-21')]!.status, DayStatus.pending);
      expect(days[d('2026-10-18')]!.status, DayStatus.beforeStart);
      expect(days.containsKey(d('2026-10-22')), isFalse, reason: 'to today');
      expect(days[d('2026-10-18')]!.editable, isFalse);
      expect(days[d('2026-10-20')]!.editable, isTrue);
    });

    test('covers at least the heatmap year, or back to an older start', () {
      expect(buildDayMap(wed, history(start: '2026-10-19')).length, 365);
      expect(buildDayMap(wed, history(start: '2024-10-21')).length, 731);
    });
  });

  group('heatmap', () {
    test('53 × 7 aligned to the week start; outside 12 months is empty', () {
      final h = history(
        start: '2025-01-01',
        done: span('2025-10-22', '2026-10-21'),
      );
      for (final first in [1, 7]) {
        final e = engineAt('2026-10-21', firstDayOfWeek: first);
        final m = buildHeatmap(
          buildDayMap(e, h),
          today: d('2026-10-21'),
          firstDayOfWeek: first,
        );
        expect(m.columns, hasLength(53));
        expect(m.columns.every((c) => c.length == 7), isTrue);
        // Row 0 is the first day of the week.
        final lastWeek = m.columns.last;
        final row0 = lastWeek.first!.date;
        expect(row0.weekday, first);
        // Today is in the last column; days after it are empty.
        final todayRow = (3 - first) % 7; // Wednesday
        expect(lastWeek[todayRow]!.date, d('2026-10-21'));
        for (var r = todayRow + 1; r < 7; r++) {
          expect(lastWeek[r], isNull, reason: 'future');
        }
        // Exactly 365 non-empty cells.
        final cells = [for (final c in m.columns) ...c.whereType<DayCell>()];
        expect(cells, hasLength(365));
        expect(cells.first.date, d('2025-10-22'));
        expect((m.done, m.total), (365, 365));
      }
    });

    test('done of due days, and per-month lines for screen readers', () {
      // Mon/Wed/Fri since Oct 1; 3 done.
      final h = history(
        start: '2026-10-01',
        schedule: mwf,
        done: ['2026-10-02', '2026-10-05', '2026-10-07'],
      );
      final m = buildHeatmap(
        buildDayMap(wed, h),
        today: d('2026-10-21'),
        firstDayOfWeek: 1,
      );
      // Due Oct 2, 5, 7, 9, 12, 14, 16, 19, 21 (pending) = 9.
      expect((m.done, m.total), (3, 9));
      expect(m.months, hasLength(1));
      expect((m.months.single.month, m.months.single.done), (10, 3));
    });
  });

  group('calendar month', () {
    test('leading and trailing blanks for Monday and Sunday starts', () {
      final h = history(start: '2026-10-01');
      final days = buildDayMap(wed, h);
      // 1 Oct 2026 is a Thursday.
      final mon = buildCalendarMonth(
        days,
        year: 2026,
        month: 10,
        firstDayOfWeek: 1,
        startDate: d('2026-10-01'),
        today: d('2026-10-21'),
      );
      expect(mon.cells.take(3), everyElement(isNull));
      expect(mon.cells[3]!.date, d('2026-10-01'));
      expect(mon.cells.length % 7, 0);
      expect(mon.cells.whereType<DayCell>(), hasLength(31));
      final sun = buildCalendarMonth(
        days,
        year: 2026,
        month: 10,
        firstDayOfWeek: 7,
        startDate: d('2026-10-01'),
        today: d('2026-10-21'),
      );
      expect(sun.cells.take(4), everyElement(isNull));
      // Days after today are future.
      final oct22 = mon.cells.whereType<DayCell>().firstWhere(
        (c) => c.date == d('2026-10-22'),
      );
      expect((oct22.status, oct22.editable), (DayStatus.future, false));
    });

    test('months run from the start date to this month', () {
      final vm = buildDetailViewModel(wed, history(start: '2025-11-15'));
      expect(vm.months.first, (2025, 11));
      expect(vm.months.last, (2026, 10));
      expect(vm.months, hasLength(12));
      expect(vm.month(2025, 11).cells[0], isNull);
      final future = buildDetailViewModel(wed, history(start: '2026-12-01'));
      expect(future.months, [(2026, 10)]);
    });
  });

  test('weekly bars: 12 weeks ending this week, done days per week', () {
    final h = history(
      start: '2026-07-01',
      done: [
        ...span('2026-10-19', '2026-10-21'),
        '2026-10-12',
        '2026-08-03',
        '2026-07-27',
      ],
    );
    final bars = buildWeeklyBars(
      buildDayMap(wed, h),
      today: d('2026-10-21'),
      firstDayOfWeek: 1,
    );
    expect(bars, hasLength(12));
    expect(bars.last.weekStart, d('2026-10-19'));
    expect(bars.first.weekStart, d('2026-08-03'));
    expect(
      [for (final b in bars) b.done],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3],
    );
  });
}
