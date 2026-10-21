import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// HAB-03 view models (research R13): plain data built once per history
// change by the controller, so the calendar, heatmap, and chart only paint.

/// Days the heatmap covers: the last 12 months, today included.
const int heatmapDays = 365;

/// Heatmap columns (weeks) and rows (weekdays).
const int heatmapColumns = 53;
const int heatmapRows = 7;

/// Weeks in the weekly bar chart (FR-032).
const int weeklyBarCount = 12;

/// One day of a habit as HAB-03 shows it.
@immutable
final class DayCell {
  const new({
    required this.date,
    required this.status,
    required this.intensity,
    required this.value,
    required this.target,
    required this.hasNote,
    this.note,
  });

  final LocalDate date;
  final DayStatus status;

  /// 0–4: quarters of `min(value / target, 1)`; 0 without progress.
  final int intensity;
  final int value;
  final int target;
  final bool hasNote;
  final String? note;

  /// Days that can be edited from the calendar (FR-030).
  bool get editable =>
      status != DayStatus.future && status != DayStatus.beforeStart;

  @override
  bool operator ==(Object other) =>
      other is DayCell &&
      other.date == date &&
      other.status == status &&
      other.intensity == intensity &&
      other.value == value &&
      other.target == target &&
      other.note == note;

  @override
  int get hashCode => Object.hash(date, status, intensity, value, target, note);
}

/// Heatmap intensity: quarters of the day's progress, capped at 100%.
int intensityOf(int value, int target) {
  if (value <= 0 || target <= 0) return 0;
  final ratio = value >= target ? 1.0 : value / target;
  return (ratio * 4).ceil().clamp(1, 4);
}

/// The cell of [date] in [history].
DayCell dayCellOf(StreakEngine engine, HabitHistory history, LocalDate date) {
  final entry = history.entries[date];
  final target = engine.scheduleOn(history, date).target;
  final value = entry?.value ?? 0;
  return DayCell(
    date: date,
    status: engine.dayStatus(history, date),
    intensity: intensityOf(value, target),
    value: value,
    target: target,
    hasNote: entry?.note != null,
    note: entry?.note,
  );
}

/// Cells from the earlier of the start date and the heatmap's first day
/// through today.
Map<LocalDate, DayCell> buildDayMap(StreakEngine engine, HabitHistory history) {
  final today = engine.today;
  final heatStart = today.addDays(-(heatmapDays - 1));
  final from = history.startDate.isBefore(heatStart)
      ? history.startDate
      : heatStart;
  return {
    for (var d = from; !d.isAfter(today); d = d.addDays(1))
      d: dayCellOf(engine, history, d),
  };
}

/// Statuses counted as days the habit was due ("X of Y days done").
const Set<DayStatus> _countable = {
  DayStatus.done,
  DayStatus.partial,
  DayStatus.missed,
  DayStatus.freeze,
  DayStatus.pending,
};

/// Done and due days of one month in the heatmap range, for screen readers.
@immutable
final class HeatmapMonth {
  const new({
    required this.year,
    required this.month,
    required this.done,
    required this.total,
  });

  final int year;
  final int month;
  final int done;
  final int total;
}

/// The year heatmap (US5-4): 53 week columns × 7 weekday rows aligned to
/// the first day of the week; cells outside the last 12 months are null.
@immutable
final class HeatmapModel {
  const new({
    required this.columns,
    required this.done,
    required this.total,
    required this.months,
  });

  /// `columns[week][row]`, oldest week first; row 0 is the first day of
  /// the week.
  final List<List<DayCell?>> columns;
  final int done;
  final int total;
  final List<HeatmapMonth> months;
}

HeatmapModel buildHeatmap(
  Map<LocalDate, DayCell> days, {
  required LocalDate today,
  required int firstDayOfWeek,
}) {
  final from = today.addDays(-(heatmapDays - 1));
  final firstColumn = today
      .startOfWeek(firstDayOfWeek)
      .addDays(-7 * (heatmapColumns - 1));
  var done = 0;
  var total = 0;
  final months = <(int, int), (int, int)>{};
  final columns = [
    for (var c = 0; c < heatmapColumns; c++)
      [
        for (var r = 0; r < heatmapRows; r++)
          () {
            final date = firstColumn.addDays(c * 7 + r);
            if (date.isBefore(from) || date.isAfter(today)) return null;
            final cell = days[date];
            if (cell != null && _countable.contains(cell.status)) {
              final isDone = cell.status == DayStatus.done ? 1 : 0;
              done += isDone;
              total++;
              final key = (date.year, date.month);
              final (d, t) = months[key] ?? (0, 0);
              months[key] = (d + isDone, t + 1);
            }
            return cell;
          }(),
      ],
  ];
  return HeatmapModel(
    columns: columns,
    done: done,
    total: total,
    months: [
      for (final MapEntry(key: (y, m), value: (d, t)) in months.entries)
        HeatmapMonth(year: y, month: m, done: d, total: t),
    ],
  );
}

/// One calendar month (US5-2): leading blanks up to the first day of the
/// week, then every day, then trailing blanks to whole weeks.
@immutable
final class CalendarMonth {
  const new({required this.year, required this.month, required this.cells});

  final int year;
  final int month;

  /// Null cells are blanks.
  final List<DayCell?> cells;
}

CalendarMonth buildCalendarMonth(
  Map<LocalDate, DayCell> days, {
  required int year,
  required int month,
  required int firstDayOfWeek,
  required LocalDate startDate,
  required LocalDate today,
}) {
  final first = LocalDate(year, month, 1);
  final lead = (first.weekday - firstDayOfWeek) % 7;
  final cells = <DayCell?>[for (var i = 0; i < lead; i++) null];
  for (var d = first; d.month == month; d = d.addDays(1)) {
    cells.add(
      days[d] ??
          DayCell(
            date: d,
            status: d.isAfter(today)
                ? DayStatus.future
                : d.isBefore(startDate)
                ? DayStatus.beforeStart
                : DayStatus.unscheduled,
            intensity: 0,
            value: 0,
            target: 1,
            hasNote: false,
          ),
    );
  }
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return CalendarMonth(year: year, month: month, cells: cells);
}

/// Completions in one week of the bar chart.
@immutable
final class WeekBar {
  const new({required this.weekStart, required this.done});

  final LocalDate weekStart;
  final int done;
}

/// The last 12 weeks of completions, oldest first, ending with the current
/// week (FR-032).
List<WeekBar> buildWeeklyBars(
  Map<LocalDate, DayCell> days, {
  required LocalDate today,
  required int firstDayOfWeek,
}) {
  final current = today.startOfWeek(firstDayOfWeek);
  return [
    for (var w = weeklyBarCount - 1; w >= 0; w--)
      () {
        final start = current.addDays(-7 * w);
        var done = 0;
        for (var i = 0; i < 7; i++) {
          if (days[start.addDays(i)]?.status == DayStatus.done) done++;
        }
        return WeekBar(weekStart: start, done: done);
      }(),
  ];
}

/// Everything HAB-03 draws, built once per history change.
@immutable
final class HabitDetailViewModel {
  const new({
    required this.days,
    required this.heatmap,
    required this.weeklyBars,
    required this.today,
    required this.startDate,
    required this.firstDayOfWeek,
  });

  final Map<LocalDate, DayCell> days;
  final HeatmapModel heatmap;
  final List<WeekBar> weeklyBars;
  final LocalDate today;
  final LocalDate startDate;
  final int firstDayOfWeek;

  /// Months the calendar pages through, oldest first: from the start date
  /// (or this month, for a future start) through this month.
  List<(int, int)> get months {
    final first = startDate.isAfter(today) ? today : startDate;
    final out = <(int, int)>[];
    var y = first.year;
    var m = first.month;
    while (y < today.year || (y == today.year && m <= today.month)) {
      out.add((y, m));
      if (m == 12) {
        y++;
        m = 1;
      } else {
        m++;
      }
    }
    return out;
  }

  /// Built when a calendar page is shown (research R13).
  CalendarMonth month(int year, int month) => buildCalendarMonth(
    days,
    year: year,
    month: month,
    firstDayOfWeek: firstDayOfWeek,
    startDate: startDate,
    today: today,
  );
}

HabitDetailViewModel buildDetailViewModel(
  StreakEngine engine,
  HabitHistory history,
) {
  final today = engine.today;
  final days = buildDayMap(engine, history);
  return HabitDetailViewModel(
    days: days,
    heatmap: buildHeatmap(
      days,
      today: today,
      firstDayOfWeek: engine.firstDayOfWeek,
    ),
    weeklyBars: buildWeeklyBars(
      days,
      today: today,
      firstDayOfWeek: engine.firstDayOfWeek,
    ),
    today: today,
    startDate: history.startDate,
    firstDayOfWeek: engine.firstDayOfWeek,
  );
}
