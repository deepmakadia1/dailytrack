import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/daos/habit_entries_dao.dart';
import 'package:dailytrack/features/habit/data/daos/habits_dao.dart';
import 'package:dailytrack/features/habit/data/mappers/habit_mapper.dart';
import 'package:dailytrack/features/habit/data/repositories/habit_storage.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Keeps only the fields a schedule type uses, so equal schedules compare
/// equal and stored rows stay tidy.
HabitSchedule normalizeSchedule(HabitSchedule s) => HabitSchedule(
  type: s.type,
  target: s.target,
  weekdays: s.type == ScheduleType.specificWeekdays ? s.weekdays : const {},
  timesPerWeek: s.type == ScheduleType.timesPerWeek ? s.timesPerWeek : null,
);

/// Drift implementation of [HabitRepository] (research R3, R9,
/// data-model.md §6–§7).
final class DriftHabitRepository implements HabitRepository {
  new(AppDatabase db, this._clock)
    : _db = db,
      _habits = HabitsDao(db),
      _entries = HabitEntriesDao(db);

  final AppDatabase _db;
  final HabitsDao _habits;
  final HabitEntriesDao _entries;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  LocalDate get _today => LocalDate.fromDateTime(_clock.now());

  HabitSchedulesCompanion _version(
    String habitId,
    LocalDate from,
    HabitSchedule s,
    int now,
  ) => HabitSchedulesCompanion.insert(
    id: _uuid.v4(),
    habitId: habitId,
    effectiveFromKey: from.key,
    scheduleType: s.type,
    weekdaysMask: s.weekdaysMask,
    timesPerWeek: Value(s.timesPerWeek),
    targetValue: s.target,
    createdAt: now,
    updatedAt: now,
  );

  @override
  Stream<List<Habit>> watchActive() => _habits
      .watchActive()
      .map((rows) => [for (final r in rows) r.toEntity()])
      .guardHabitStorage();

  @override
  Stream<List<Habit>> watchArchived() => _habits
      .watchArchived()
      .map((rows) => [for (final r in rows) r.toEntity()])
      .guardHabitStorage();

  @override
  Stream<Habit?> watchById(String id) =>
      _habits.watchLiveById(id).map((r) => r?.toEntity()).guardHabitStorage();

  @override
  Future<Habit?> byId(String id) =>
      guardHabitStorage(() async => (await _habits.liveById(id))?.toEntity());

  @override
  Future<List<Habit>> activeHabits() => guardHabitStorage(
    () async => [for (final r in await _habits.active()) r.toEntity()],
  );

  @override
  Future<Habit> create(HabitDraft draft) => guardHabitStorage(
    () => _db.transaction(() async {
      final id = _uuid.v4();
      final now = _nowMs();
      final schedule = normalizeSchedule(draft.schedule);
      await _habits.insertHabit(
        HabitsCompanion.insert(
          id: id,
          name: draft.name.trim(),
          iconKey: draft.iconKey,
          colorHex: draft.colorHex,
          kind: draft.kind,
          targetValue: schedule.target,
          unit: Value(draft.kind == HabitKind.count ? draft.unit : null),
          scheduleType: schedule.type,
          weekdaysMask: schedule.weekdaysMask,
          timesPerWeek: Value(schedule.timesPerWeek),
          reminderTimes: Value(encodeReminderTimes(draft.reminderTimes)),
          remindOnlyIfNotDone: Value(draft.remindOnlyIfNotDone),
          startDateKey: draft.startDate.key,
          sortOrder: await _habits.nextSortOrder(),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _habits.insertVersion(_version(id, draft.startDate, schedule, now));
      return (await _habits.liveById(id))!.toEntity();
    }),
  );

  @override
  Future<Habit> update(String id, HabitDraft draft) => guardHabitStorage(
    () => _db.transaction(() async {
      final row = await _habits.liveById(id);
      if (row == null) throw HabitNotFound(id);
      if (row.kind != draft.kind) throw const KindLocked();
      final now = _nowMs();
      final schedule = normalizeSchedule(draft.schedule);

      // A new start date moves a lone first version with it.
      final versions = await _habits.versionsOf(id);
      final oldStart = LocalDate.fromKey(row.startDateKey);
      if (draft.startDate != oldStart && versions.length == 1) {
        await _habits.updateVersion(
          versions.single.id,
          HabitSchedulesCompanion(
            effectiveFromKey: Value(draft.startDate.key),
            updatedAt: Value(now),
          ),
        );
      }

      // A schedule or target change applies from today onward, or from the
      // start date when the habit has not started yet (research R3).
      if (schedule != normalizeSchedule(row.schedule)) {
        final today = _today;
        final from = today.isBefore(draft.startDate) ? draft.startDate : today;
        final existing = await _habits.versionAt(id, from.key);
        if (existing == null) {
          await _habits.insertVersion(_version(id, from, schedule, now));
        } else {
          await _habits.updateVersion(
            existing.id,
            HabitSchedulesCompanion(
              scheduleType: Value(schedule.type),
              weekdaysMask: Value(schedule.weekdaysMask),
              timesPerWeek: Value(schedule.timesPerWeek),
              targetValue: Value(schedule.target),
              updatedAt: Value(now),
            ),
          );
        }
      }

      await _habits.updateLive(
        id,
        HabitsCompanion(
          name: Value(draft.name.trim()),
          iconKey: Value(draft.iconKey),
          colorHex: Value(draft.colorHex),
          targetValue: Value(schedule.target),
          unit: Value(draft.kind == HabitKind.count ? draft.unit : null),
          scheduleType: Value(schedule.type),
          weekdaysMask: Value(schedule.weekdaysMask),
          timesPerWeek: Value(schedule.timesPerWeek),
          reminderTimes: Value(encodeReminderTimes(draft.reminderTimes)),
          remindOnlyIfNotDone: Value(draft.remindOnlyIfNotDone),
          startDateKey: Value(draft.startDate.key),
          updatedAt: Value(now),
        ),
      );
      return (await _habits.liveById(id))!.toEntity();
    }),
  );

  Future<void> _write(String id, HabitsCompanion row) async {
    final changed = await _habits.updateLive(id, row);
    if (changed == 0) throw HabitNotFound(id);
  }

  @override
  Future<void> archive(String id) => guardHabitStorage(
    () => _write(
      id,
      HabitsCompanion(
        isArchived: const Value(true),
        archivedAt: Value(_nowMs()),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<void> undoArchive(String id) => guardHabitStorage(
    () => _write(
      id,
      HabitsCompanion(
        isArchived: const Value(false),
        archivedAt: const Value(null),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<void> restore(String id) => guardHabitStorage(
    () => _db.transaction(() async {
      await _write(
        id,
        HabitsCompanion(
          isArchived: const Value(false),
          archivedAt: const Value(null),
          sortOrder: Value(await _habits.nextSortOrder()),
          updatedAt: Value(_nowMs()),
        ),
      );
    }),
  );

  @override
  Future<void> delete(String id) => guardHabitStorage(
    () => _db.transaction(() async {
      final now = _nowMs();
      await _write(
        id,
        HabitsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await _habits.softDeleteVersions(id, now);
      await _entries.softDeleteAllOf(id, now);
    }),
  );

  @override
  Future<void> reorder(List<String> idsInOrder) => guardHabitStorage(
    () => _db.transaction(() async {
      final active = {for (final r in await _habits.active()) r.id};
      var position = 0;
      for (final id in idsInOrder) {
        if (!active.contains(id)) continue;
        await _habits.updateLive(
          id,
          HabitsCompanion(sortOrder: Value(position++)),
        );
      }
    }),
  );

  @override
  Future<int> addFreeze(String id) => guardHabitStorage(
    () => _db.transaction(() async {
      if (await _habits.liveById(id) == null) throw HabitNotFound(id);
      await _habits.addFreezes(id, 1);
      return (await _habits.liveById(id))!.freezesAvailable;
    }),
  );
}
