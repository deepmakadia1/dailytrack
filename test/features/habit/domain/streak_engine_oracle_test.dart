import 'dart:math';

import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// SC-002: the engine agrees with a deliberately literal reading of the
/// streak rules (spec §4, research R6) on 150 seeded random histories.
void main() {
  final random = Random(42);
  const histories = 150;

  for (var i = 0; i < histories; i++) {
    final c = _randomCase(random, i);
    test('STREAK oracle #$i ${c.describe()}', () {
      final engine = StreakEngine(
        Clock.fixed(c.now),
        firstDayOfWeek: c.firstDayOfWeek,
      );
      final expected = _Oracle(c.history, c.today, c.firstDayOfWeek).summary();
      expect(engine.summarize(c.history), expected);
    });
  }

  test('the generator covers every schedule type, both kinds, all week '
      'starts, freezes, several versions, and future starts', () {
    final r = Random(42);
    final cases = [for (var i = 0; i < histories; i++) _randomCase(r, i)];
    final types = {
      for (final c in cases)
        for (final v in c.history.versions) v.schedule.type,
    };
    expect(types, ScheduleType.values.toSet());
    expect({for (final c in cases) c.history.kind}, HabitKind.values.toSet());
    expect({for (final c in cases) c.firstDayOfWeek}, {1, 6, 7});
    expect(cases.where((c) => c.history.versions.length == 3), isNotEmpty);
    expect(
      cases.where((c) => c.history.startDate.isAfter(c.today)),
      isNotEmpty,
    );
    expect(
      cases.where((c) => c.history.entries.values.any((e) => e.isFreeze)),
      isNotEmpty,
    );
  });
}

final class _Case {
  const new(this.history, this.now, this.firstDayOfWeek);

  final HabitHistory history;
  final DateTime now;
  final int firstDayOfWeek;

  LocalDate get today => LocalDate.fromDateTime(now);

  String describe() =>
      '(${history.kind.name}, '
      '${[for (final v in history.versions) v.schedule.type.name].join('→')}, '
      'start ${history.startDate}, today $today, week $firstDayOfWeek)';
}

_Case _randomCase(Random r, int index) {
  // Today anywhere from Oct 2026 to the end of 2028 (month, year, and
  // 29 February boundaries), at a random time of day.
  final today = const LocalDate(2026, 10, 1).addDays(r.nextInt(820));
  final now = DateTime(
    today.year,
    today.month,
    today.day,
    r.nextInt(24),
    r.nextInt(60),
    r.nextInt(60),
  );
  final firstDayOfWeek = const [1, 6, 7][r.nextInt(3)];
  final kind = r.nextBool() ? HabitKind.yesNo : HabitKind.count;
  // About one in ten starts in the future.
  final start = r.nextInt(10) == 0
      ? today.addDays(1 + r.nextInt(5))
      : today.addDays(-r.nextInt(801));

  HabitSchedule schedule() {
    final target = kind == HabitKind.yesNo ? 1 : 1 + r.nextInt(5);
    return switch (ScheduleType.values[r.nextInt(3)]) {
      ScheduleType.daily => HabitSchedule(
        type: ScheduleType.daily,
        target: target,
      ),
      ScheduleType.specificWeekdays => HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: target,
        weekdays: {
          for (var d = 1; d <= 7; d++)
            if (r.nextInt(3) > 0) d,
        }..add(1 + r.nextInt(7)),
      ),
      ScheduleType.timesPerWeek => HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: target,
        timesPerWeek: 1 + r.nextInt(6),
      ),
    };
  }

  // Version 1 from the start (sometimes later, as after moving the start
  // date earlier), then 0–2 changes on distinct later days.
  final first = r.nextInt(8) == 0 ? start.addDays(1 + r.nextInt(20)) : start;
  final span = max(1, today.difference(first));
  final changeDays = <int>{
    for (var k = r.nextInt(3); k > 0; k--) 1 + r.nextInt(span),
  }.toList()..sort();
  final versions = [
    ScheduleVersion(effectiveFrom: first, schedule: schedule()),
    for (final offset in changeDays)
      ScheduleVersion(
        effectiveFrom: first.addDays(offset),
        schedule: schedule(),
      ),
  ];

  // Entries from a few days before the start to a few days after today
  // (clock moved back), with a per-history density.
  final density = 0.2 + r.nextDouble() * 0.75;
  final freezeRate = r.nextInt(4) == 0 ? 0.0 : r.nextDouble() * 0.08;
  final entries = <LocalDate, HabitEntry>{};
  final from = start.addDays(-3);
  final to = today.addDays(3);
  for (var day = from; !day.isAfter(to); day = day.addDays(1)) {
    final roll = r.nextDouble();
    if (roll < freezeRate) {
      entries[day] = HabitEntry(
        habitId: 'h$index',
        date: day,
        value: 0,
        isFreeze: true,
      );
    } else if (roll < density) {
      final maxValue = kind == HabitKind.yesNo ? 1 : 7;
      entries[day] = HabitEntry(
        habitId: 'h$index',
        date: day,
        value: r.nextInt(maxValue + 1),
        isFreeze: r.nextInt(40) == 0,
        note: r.nextInt(6) == 0 ? 'note' : null,
      );
    }
  }

  return _Case(
    HabitHistory(
      habitId: 'h$index',
      kind: kind,
      startDate: start,
      versions: versions,
      entries: entries,
    ),
    now,
    firstDayOfWeek,
  );
}

/// One streak unit as the rules read: a due day, or the "times per week"
/// days of one calendar week.
enum _Kind { hit, frozen, miss, open }

final class _OracleUnit {
  new(this.kind, this.days);

  final _Kind kind;
  final List<LocalDate> days;
}

/// The rules written out as plainly as possible, with no shortcuts: every
/// lookup scans all versions, every week is rebuilt from its days, and the
/// best streak tries every starting unit.
final class _Oracle {
  new(this.h, this.today, this.firstDayOfWeek);

  final HabitHistory h;
  final LocalDate today;
  final int firstDayOfWeek;

  HabitSchedule scheduleFor(LocalDate day) {
    final started = [
      for (final v in h.versions)
        if (v.effectiveFrom.compareTo(day) <= 0) v,
    ];
    return started.isEmpty ? h.versions.first.schedule : started.last.schedule;
  }

  bool done(LocalDate day) {
    final e = h.entries[day];
    return e != null && e.value >= scheduleFor(day).target;
  }

  bool frozen(LocalDate day) =>
      !done(day) && (h.entries[day]?.isFreeze ?? false);

  bool weekly(LocalDate day) =>
      scheduleFor(day).type == ScheduleType.timesPerWeek;

  bool dueDay(LocalDate day) {
    final s = scheduleFor(day);
    return switch (s.type) {
      ScheduleType.daily => true,
      ScheduleType.specificWeekdays => s.weekdays.contains(day.weekday),
      ScheduleType.timesPerWeek => false,
    };
  }

  LocalDate weekOf(LocalDate day) {
    var x = day;
    while (x.weekday != firstDayOfWeek) {
      x = x.addDays(-1);
    }
    return x;
  }

  List<LocalDate> get days => [
    for (var x = h.startDate; !x.isAfter(today); x = x.addDays(1)) x,
  ];

  List<_OracleUnit> units() {
    final out = <_OracleUnit>[];
    var week = <LocalDate>[];

    void endWeek() {
      if (week.isEmpty) return;
      final target = scheduleFor(week.last).timesPerWeek!;
      final count = week.where(done).length;
      final isCurrent = weekOf(week.last) == weekOf(today);
      final _Kind kind;
      if (count >= target) {
        kind = _Kind.hit;
      } else if (isCurrent) {
        kind = _Kind.open;
      } else if (week.any(frozen)) {
        kind = _Kind.frozen;
      } else {
        kind = _Kind.miss;
      }
      out.add(_OracleUnit(kind, week));
      week = <LocalDate>[];
    }

    for (final day in days) {
      if (weekly(day)) {
        if (week.isNotEmpty && weekOf(week.first) != weekOf(day)) endWeek();
        week.add(day);
        continue;
      }
      endWeek();
      if (!dueDay(day)) continue;
      final _Kind kind;
      if (done(day)) {
        kind = _Kind.hit;
      } else if (frozen(day)) {
        kind = _Kind.frozen;
      } else if (day == today) {
        kind = _Kind.open;
      } else {
        kind = _Kind.miss;
      }
      out.add(_OracleUnit(kind, [day]));
    }
    endWeek();
    return out;
  }

  StreakSummary summary() {
    final all = units();

    // Current: count back from today until a miss.
    var current = 0;
    for (var i = all.length - 1; i >= 0; i--) {
      if (all[i].kind == _Kind.miss) break;
      if (all[i].kind == _Kind.hit) current++;
    }

    // Best: the most hits in any stretch without a miss.
    var best = 0;
    for (var i = 0; i < all.length; i++) {
      var hits = 0;
      for (var j = i; j < all.length && all[j].kind != _Kind.miss; j++) {
        if (all[j].kind == _Kind.hit) hits++;
      }
      best = max(best, hits);
    }

    // Rate: units with a day in the last 30 days (today included).
    final windowStart = today.addDays(-29);
    var hit = 0;
    var counted = 0;
    for (final u in all) {
      if (!u.days.any((day) => !day.isBefore(windowStart))) continue;
      if (u.kind == _Kind.hit) {
        hit++;
        counted++;
      } else if (u.kind == _Kind.miss) {
        counted++;
      }
    }
    final rate = counted == 0 ? null : (hit * 100 / counted + 0.5).floor();

    final total = days.where(done).length;
    final unit = weekly(today) ? StreakUnit.weeks : StreakUnit.days;
    return StreakSummary(
      current: current,
      best: best,
      completionRate: rate,
      totalCompletions: total,
      unit: unit,
    );
  }
}
