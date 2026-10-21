import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_entry_repository.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';

/// A real in-memory database with the two habit repositories, for UNIT
/// tests only (never widget tests). The clock starts on Wednesday
/// 2026-10-21 at 10:00 local; weeks start on Monday.
final class HabitDb {
  new _(this.db, this.clock)
    : engine = StreakEngine(clock),
      habits = DriftHabitRepository(db, clock) {
    entries = DriftHabitEntryRepository(db, clock, engine);
  }

  final AppDatabase db;
  final MutableClock clock;
  final StreakEngine engine;
  final DriftHabitRepository habits;
  late final DriftHabitEntryRepository entries;

  static Future<HabitDb> open() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return HabitDb._(db, MutableClock(DateTime(2026, 10, 21, 10)));
  }

  LocalDate get today => LocalDate.fromDateTime(clock.now());

  Future<Habit> habit({
    String name = 'Read',
    HabitKind kind = HabitKind.yesNo,
    HabitSchedule schedule = const HabitSchedule(
      type: ScheduleType.daily,
      target: 1,
    ),
    String start = '2026-10-01',
  }) => habits.create(
    HabitDraft(
      name: name,
      iconKey: 'book',
      colorHex: '#0F766E',
      kind: kind,
      schedule: schedule,
      startDate: LocalDate.fromKey(start),
    ),
  );

  /// Physical `habit_entries` rows of [habitId] on [dateKey], live or not.
  Future<List<HabitEntryRow>> physical(String habitId, String dateKey) =>
      (db.select(db.habitEntries)..where(
            (e) => e.habitId.equals(habitId) & e.dateKey.equals(dateKey),
          ))
          .get();
}
