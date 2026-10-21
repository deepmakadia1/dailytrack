import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';

/// Short helpers for streak tests: dates as `yyyy-MM-dd` keys, schedules by
/// name, and an engine whose clock sits at `hour` on `today`.

LocalDate d(String key) => LocalDate.fromKey(key);

const HabitSchedule daily = HabitSchedule(type: ScheduleType.daily, target: 1);

HabitSchedule weekdays(Set<int> days, {int target = 1}) => HabitSchedule(
  type: ScheduleType.specificWeekdays,
  target: target,
  weekdays: days,
);

/// Monday, Wednesday, Friday.
final HabitSchedule mwf = weekdays({1, 3, 5});

HabitSchedule perWeek(int times, {int target = 1}) => HabitSchedule(
  type: ScheduleType.timesPerWeek,
  target: target,
  timesPerWeek: times,
);

HabitSchedule count(int target) =>
    HabitSchedule(type: ScheduleType.daily, target: target);

StreakEngine engineAt(
  String today, {
  int hour = 12,
  int minute = 0,
  int second = 0,
  int firstDayOfWeek = 1,
}) {
  final t = d(today);
  return StreakEngine(
    Clock.fixed(DateTime(t.year, t.month, t.day, hour, minute, second)),
    firstDayOfWeek: firstDayOfWeek,
  );
}

/// All keys from [from] to [to], both included.
List<String> span(String from, String to) {
  final out = <String>[];
  for (var x = d(from); !x.isAfter(d(to)); x = x.addDays(1)) {
    out.add(x.key);
  }
  return out;
}

/// A history. [done] days get the target in effect (or 1); [values] set
/// exact counts; [freezes] are freeze days; [versions] are
/// (effective-from key, schedule) pairs, oldest first, defaulting to
/// [schedule] from [start].
HabitHistory history({
  required String start,
  HabitSchedule schedule = daily,
  List<(String, HabitSchedule)>? versions,
  Iterable<String> done = const [],
  Map<String, int> values = const {},
  Iterable<String> freezes = const [],
  Map<String, String> notes = const {},
  HabitKind? kind,
}) {
  final vs = versions ?? [(start, schedule)];
  final versionList = [
    for (final (from, s) in vs)
      ScheduleVersion(effectiveFrom: d(from), schedule: s),
  ];
  int targetOn(LocalDate day) {
    var t = versionList.first.schedule.target;
    for (final v in versionList) {
      if (v.effectiveFrom.isAfter(day)) break;
      t = v.schedule.target;
    }
    return t;
  }

  final entries = <LocalDate, HabitEntry>{};
  void put(String key, {int? value, bool freeze = false, String? note}) {
    final day = d(key);
    final old = entries[day];
    entries[day] = HabitEntry(
      habitId: 'h',
      date: day,
      value: value ?? old?.value ?? 0,
      isFreeze: freeze || (old?.isFreeze ?? false),
      note: note ?? old?.note,
    );
  }

  for (final k in done) {
    put(k, value: targetOn(d(k)));
  }
  values.forEach((k, v) => put(k, value: v));
  for (final k in freezes) {
    put(k, freeze: true);
  }
  notes.forEach((k, n) => put(k, note: n));

  final allCount = vs.every((v) => v.$2.target == 1);
  return HabitHistory(
    habitId: 'h',
    kind: kind ?? (allCount ? HabitKind.yesNo : HabitKind.count),
    startDate: d(start),
    versions: versionList,
    entries: entries,
  );
}
