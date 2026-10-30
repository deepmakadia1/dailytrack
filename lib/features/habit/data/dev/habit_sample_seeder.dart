import 'dart:math';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/features/habit/data/daos/habits_dao.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// One sample habit: what HAB-02 would save for it.
final class _Sample {
  const new({
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.kind,
    required this.target,
    this.unit,
    this.scheduleType = ScheduleType.daily,
    this.weekdaysMask = 0,
    this.timesPerWeek,
  });

  final String name;
  final String iconKey;
  final String colorHex;
  final HabitKind kind;
  final int target;
  final String? unit;
  final ScheduleType scheduleType;
  final int weekdaysMask;
  final int? timesPerWeek;
}

/// Dev-only sample habits, added with "Seed 10,000 transactions"
/// (`DevAction.withSampleData`, feature 012 contracts/dev-seed.md). Adds a
/// few habits covering every kind and schedule type, each started a year
/// ago with about a year of check-ins and today left open. A habit whose
/// name is already live is skipped, so running the seed again never piles
/// up duplicates. Writes rows directly, never through the use cases, so no
/// reminder is scheduled and no milestone is celebrated.
final class HabitSampleSeeder {
  const new(this._db, this._clock, this._coordinator);

  final AppDatabase _db;
  final Clock _clock;
  final BackupCoordinator _coordinator;

  static const Uuid _uuid = Uuid();

  /// Fixed seed, so every run makes the same data.
  static const int randomSeed = 42;

  /// Days of history before today.
  static const int historyDays = 365;

  /// Share of due days checked in; some count days are only partly done.
  static const double doneRate = 0.75;
  static const double partialRate = 0.2;

  static const List<_Sample> _samples = [
    _Sample(
      name: 'Drink water',
      iconKey: 'water_drop',
      colorHex: '#2B7ACA',
      kind: HabitKind.count,
      target: 8,
      unit: 'glasses',
    ),
    _Sample(
      name: 'Read',
      iconKey: 'menu_book',
      colorHex: '#AD6925',
      kind: HabitKind.count,
      target: 20,
      unit: 'pages',
    ),
    _Sample(
      name: 'Wake up early',
      iconKey: 'alarm',
      colorHex: '#CA532B',
      kind: HabitKind.yesNo,
      target: 1,
    ),
    // Mon, Wed, Fri.
    _Sample(
      name: 'Walk',
      iconKey: 'directions_walk',
      colorHex: '#1D8B39',
      kind: HabitKind.count,
      target: 30,
      unit: 'minutes',
      scheduleType: ScheduleType.specificWeekdays,
      weekdaysMask: 1 | 4 | 16,
    ),
    _Sample(
      name: 'Meditate',
      iconKey: 'self_improvement',
      colorHex: '#7B68DF',
      kind: HabitKind.yesNo,
      target: 1,
      scheduleType: ScheduleType.timesPerWeek,
      timesPerWeek: 3,
    ),
  ];

  /// Adds the sample habits that are not there yet. Runs under the backup
  /// lease: if a backup or restore holds it, returns [DevActionBusy] and
  /// writes nothing. The count is the habits added.
  Future<DevActionResult> seed() async {
    try {
      return await _coordinator.run(_seed);
    } on BackupBusy {
      return const DevActionBusy();
    }
  }

  Future<DevActionResult> _seed() async {
    final habits = HabitsDao(_db);
    final live = {for (final h in await habits.active()) h.name};
    final random = Random(randomSeed);
    final nowMs = _clock.now().toUtc().millisecondsSinceEpoch;
    final today = LocalDate.fromDateTime(_clock.now());
    final start = today.addDays(-historyDays);
    var made = 0;
    for (final s in _samples) {
      if (live.contains(s.name)) continue;
      final id = _uuid.v4();
      final entries = <HabitEntriesCompanion>[
        for (var day = start; day.isBefore(today); day = day.addDays(1))
          if (_due(s, day) && random.nextDouble() < doneRate)
            HabitEntriesCompanion.insert(
              id: _uuid.v4(),
              habitId: id,
              dateKey: day.key,
              value: _value(s, random),
              createdAt: nowMs,
              updatedAt: nowMs,
            ),
      ];
      await _db.transaction(() async {
        await habits.insertHabit(
          HabitsCompanion.insert(
            id: id,
            name: s.name,
            iconKey: s.iconKey,
            colorHex: s.colorHex,
            kind: s.kind,
            targetValue: s.target,
            unit: Value(s.unit),
            scheduleType: s.scheduleType,
            weekdaysMask: s.weekdaysMask,
            timesPerWeek: Value(s.timesPerWeek),
            startDateKey: start.key,
            sortOrder: await habits.nextSortOrder(),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        await habits.insertVersion(
          HabitSchedulesCompanion.insert(
            id: _uuid.v4(),
            habitId: id,
            effectiveFromKey: start.key,
            scheduleType: s.scheduleType,
            weekdaysMask: s.weekdaysMask,
            timesPerWeek: Value(s.timesPerWeek),
            targetValue: s.target,
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        await _db.batch((b) => b.insertAll(_db.habitEntries, entries));
      });
      made++;
    }
    return DevActionDone(made);
  }

  /// Whether [day] is a check-in day. A times-per-week habit is tried on
  /// the first `timesPerWeek + 1` days of each week, so with [doneRate]
  /// about `timesPerWeek` are done.
  static bool _due(_Sample s, LocalDate day) => switch (s.scheduleType) {
    ScheduleType.daily => true,
    ScheduleType.specificWeekdays =>
      s.weekdaysMask & (1 << (day.weekday - 1)) != 0,
    ScheduleType.timesPerWeek => day.weekday <= s.timesPerWeek! + 1,
  };

  /// The target, or for some count days a partial amount below it.
  static int _value(_Sample s, Random random) {
    if (s.kind == HabitKind.yesNo || random.nextDouble() >= partialRate) {
      return s.target;
    }
    return 1 + random.nextInt(s.target - 1);
  }
}
