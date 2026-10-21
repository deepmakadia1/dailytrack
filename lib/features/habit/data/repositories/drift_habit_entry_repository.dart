import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/daos/habit_entries_dao.dart';
import 'package:dailytrack/features/habit/data/daos/habits_dao.dart';
import 'package:dailytrack/features/habit/data/mappers/habit_mapper.dart';
import 'package:dailytrack/features/habit/data/repositories/habit_storage.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_entry_repository.dart';
import 'package:dailytrack/features/habit/domain/streaks/freeze_policy.dart';
import 'package:dailytrack/features/habit/domain/streaks/milestones.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Drift implementation of [HabitEntryRepository] (research R4, R7, R8,
/// data-model.md §6).
final class DriftHabitEntryRepository implements HabitEntryRepository {
  new(AppDatabase db, this._clock, this._engine)
    : _db = db,
      _habits = HabitsDao(db),
      _entries = HabitEntriesDao(db);

  final AppDatabase _db;
  final HabitsDao _habits;
  final HabitEntriesDao _entries;
  final Clock _clock;
  final StreakEngine _engine;
  static const Uuid _uuid = Uuid();

  /// Highest count a day can hold (data-model §3.3).
  static const int maxValue = 9999;

  /// Longest note (data-model §3.3).
  static const int maxNoteLength = 200;

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  List<ResultSetImplementation<dynamic, dynamic>> get _tables => [
    _db.habits,
    _db.habitSchedules,
    _db.habitEntries,
  ];

  HabitHistory _build(
    HabitRow habit,
    List<HabitScheduleRow> versions,
    Iterable<HabitEntryRow> entries, {
    LocalDate? loadedFrom,
  }) {
    final start = LocalDate.fromKey(habit.startDateKey);
    return HabitHistory(
      habitId: habit.id,
      kind: habit.kind,
      startDate: start,
      versions: versions.isEmpty
          ? [ScheduleVersion(effectiveFrom: start, schedule: habit.schedule)]
          : [for (final v in versions) v.toEntity()],
      entries: {
        for (final e in entries) LocalDate.fromKey(e.dateKey): e.toEntity(),
      },
      loadedFrom: loadedFrom != null && start.isBefore(loadedFrom)
          ? loadedFrom
          : null,
    );
  }

  Future<HabitHistory?> _historyOf(String habitId) async {
    final habit = await _habits.liveById(habitId);
    if (habit == null) return null;
    return _build(
      habit,
      await _habits.versionsOf(habitId),
      await _entries.liveOf(habitId),
    );
  }

  @override
  Stream<List<HabitHistory>> watchActiveHistories({required LocalDate from}) =>
      watchHabitTables(_db, _tables, () async {
        final habits = await _habits.active();
        if (habits.isEmpty) return const <HabitHistory>[];
        final ids = [for (final h in habits) h.id];
        final versions = await _habits.versionsOfAll(ids);
        final entries = await _entries.liveSince(ids, from.key);
        return [
          for (final h in habits)
            _build(
              h,
              [
                for (final v in versions)
                  if (v.habitId == h.id) v,
              ],
              entries.where((e) => e.habitId == h.id),
              loadedFrom: from,
            ),
        ];
      });

  @override
  Stream<HabitHistory?> watchHistory(String habitId) =>
      watchHabitTables(_db, _tables, () => _historyOf(habitId));

  @override
  Future<HabitHistory?> history(String habitId) =>
      guardHabitStorage(() => _historyOf(habitId));

  @override
  Stream<List<HabitEntry>> watchNotes(String habitId) =>
      watchHabitTables(_db, [_db.habitEntries], () async {
        return [for (final r in await _entries.notesOf(habitId)) r.toEntity()];
      });

  @override
  Future<DayWriteResult> apply(String habitId, LocalDate date, DayOp op) =>
      guardHabitStorage(
        () => _db.transaction(() async {
          final habit = await _habits.liveById(habitId);
          if (habit == null) throw HabitNotFound(habitId);
          final history = (await _historyOf(habitId))!;
          final today = _engine.today;
          if (op is! Restore &&
              (date.isAfter(today) || date.isBefore(history.startDate))) {
            throw DayNotEditable(date.key);
          }

          final row = await _entries.physicalRow(habitId, date.key);
          final wasLive = row != null && row.deletedAt == null;
          final before = EntrySnapshot(
            habitId: habitId,
            date: date,
            wasLive: wasLive,
            value: wasLive ? row.value : 0,
            isFreeze: wasLive && row.isFreeze,
            note: wasLive ? row.note : null,
            freezesAvailableBefore: habit.freezesAvailable,
          );

          var value = before.value;
          var isFreeze = before.isFreeze;
          var note = before.note;
          var freezes = habit.freezesAvailable;
          bool? live;
          final target = _engine.scheduleOn(history, date).target;
          // A yes/no day is 0 or 1.
          final max = habit.kind == HabitKind.yesNo ? 1 : maxValue;

          switch (op) {
            case Toggle():
              value = value >= target ? 0 : target;
            case Increment():
              value = math.min(value + 1, max);
            case SetValue(value: final v):
              if (v < 0 || v > max) {
                throw InvalidDayInput('value $v is outside 0–$max');
              }
              value = v;
            case SetNote(note: final n):
              final trimmed = n?.trim();
              note = trimmed == null || trimmed.isEmpty ? null : trimmed;
              if (note != null && note.length > maxNoteLength) {
                throw const InvalidDayInput(
                  'note is over $maxNoteLength characters',
                );
              }
            case UseFreeze(:final allowToday):
              switch (FreezePolicy(_engine).check(
                history,
                date,
                allowToday: allowToday,
                available: freezes,
              )) {
                case FreezeRejected(:final reason):
                  throw FreezeNotAllowed(reason);
                case FreezeNoneLeft():
                  throw const NoFreezesLeft();
                case FreezeAllowed():
                  // A freeze row holds no progress (data-model §3.3, §6);
                  // Undo puts any partial count back.
                  isFreeze = true;
                  value = 0;
                  freezes--;
              }
            case Restore(:final snapshot):
              value = snapshot.value;
              isFreeze = snapshot.isFreeze;
              note = snapshot.note;
              freezes = snapshot.freezesAvailableBefore;
              live = snapshot.wasLive;
          }

          // A freeze day that reaches its target becomes a normal done day
          // and gives the freeze back, up to the cap (spec Edge Cases).
          if (op is! Restore && isFreeze && value >= target) {
            isFreeze = false;
            freezes = math.min(freezes + 1, 2);
          }
          live ??= value > 0 || isFreeze || note != null;

          final now = _nowMs();
          if (row == null) {
            if (live) {
              await _entries.insertRow(
                HabitEntriesCompanion.insert(
                  id: _uuid.v4(),
                  habitId: habitId,
                  dateKey: date.key,
                  value: value,
                  isFreeze: Value(isFreeze),
                  note: Value(note),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
            }
          } else if (live || wasLive) {
            await _entries.updateRow(
              row.id,
              HabitEntriesCompanion(
                value: Value(value),
                isFreeze: Value(isFreeze),
                note: Value(note),
                updatedAt: Value(now),
                deletedAt: Value(live ? null : now),
              ),
            );
          }
          if (freezes != habit.freezesAvailable) {
            await _habits.updateLive(
              habitId,
              HabitsCompanion(freezesAvailable: Value(freezes)),
            );
          }

          final entries = {...history.entries};
          if (live) {
            entries[date] = HabitEntry(
              habitId: habitId,
              date: date,
              value: value,
              isFreeze: isFreeze,
              note: note,
            );
          } else {
            entries.remove(date);
          }
          final summary = _engine.summarize(history.copyWith(entries: entries));
          return DayWriteResult(
            before: before,
            summary: summary,
            milestone: await _celebrate(habitId, summary.current),
          );
        }),
      );

  /// Records the milestones [current] reaches with a compare-and-set, so a
  /// milestone is celebrated once even when two screens write at the same
  /// moment (research R8). Returns the one to show, if any.
  Future<Milestone?> _celebrate(String habitId, int current) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final habit = await _habits.liveById(habitId);
      if (habit == null) return null;
      final celebrated = Milestone.fromMask(habit.celebratedMilestones);
      final pick = selectNewMilestones(current, celebrated);
      if (pick.toSet.isEmpty) return null;
      final won = await _habits.casMilestones(
        habitId,
        from: habit.celebratedMilestones,
        to: Milestone.toMask({...celebrated, ...pick.toSet}),
      );
      if (won) return pick.show;
    }
    return null;
  }
}
