import 'dart:async';
import 'dart:math' as math;

import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/ports/habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_entry_repository.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_repository.dart';
import 'package:dailytrack/features/habit/domain/streaks/freeze_policy.dart';
import 'package:dailytrack/features/habit/domain/streaks/milestones.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../helpers/mutable_clock.dart';

/// One in-memory store behind the fake habit repositories, with the same
/// rules as the Drift ones (contracts/repositories.md, data-model §6).
/// Widget tests use these instead of a database (Constitution IV).
final class FakeHabitWorld {
  new(this.clock);

  final MutableClock clock;

  /// Live and archived habits by id; deleted ones are removed.
  final Map<String, Habit> habits = {};

  /// Schedule versions by habit id, oldest first.
  final Map<String, List<ScheduleVersion>> versions = {};

  /// Live entries by habit id and day.
  final Map<String, Map<LocalDate, HabitEntry>> entries = {};

  /// First day of the week the fake engine uses (settings).
  int firstDayOfWeek = 1;

  final _changes = StreamController<void>.broadcast();

  /// When set, every watch stream emits this error instead of data.
  Object? failWatch;

  /// When true, the next write throws [HabitStorageFailure], then resets.
  bool failNextWrite = false;

  /// Delay before every watch stream's first emission (loading states).
  Duration watchDelay = Duration.zero;

  var _seq = 0;
  String nextId() => 'habit-${++_seq}';

  StreakEngine get engine =>
      StreakEngine(clock, firstDayOfWeek: firstDayOfWeek);

  LocalDate get today => LocalDate.fromDateTime(clock.now());

  void changed() => _changes.add(null);

  void checkWrite() {
    if (failNextWrite) {
      failNextWrite = false;
      throw const HabitStorageFailure('fake failure');
    }
  }

  HabitHistory historyOf(Habit h, {LocalDate? from}) {
    final all = entries[h.id] ?? const {};
    return HabitHistory(
      habitId: h.id,
      kind: h.kind,
      startDate: h.startDate,
      versions:
          versions[h.id] ??
          [ScheduleVersion(effectiveFrom: h.startDate, schedule: h.schedule)],
      entries: {
        for (final MapEntry(:key, :value) in all.entries)
          if (from == null || !key.isBefore(from)) key: value,
      },
      loadedFrom: from != null && h.startDate.isBefore(from) ? from : null,
    );
  }

  /// A stream that emits [compute] now (after [watchDelay]) and after every
  /// change, like a Drift watch query.
  Stream<T> watch<T>(T Function() compute) => Stream.multi((c) {
    StreamSubscription<void>? sub;
    var cancelled = false;
    void emit() {
      if (cancelled) return;
      if (failWatch case final e?) {
        c.addError(e);
      } else {
        c.add(compute());
      }
    }

    Future<void>.delayed(watchDelay, () {
      if (cancelled) return;
      sub = _changes.stream.listen((_) => emit());
      emit();
    });
    // Not awaited: under fake time `.first` would otherwise wait on this
    // inner cancel, which a Drift stream never makes it do.
    c.onCancel = () {
      cancelled = true;
      unawaited(sub?.cancel());
    };
  });

  List<Habit> get active =>
      habits.values.where((h) => !h.isArchived).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

/// Test fakes for the Habit module, plus provider overrides.
final class HabitFakes {
  new(MutableClock clock) : this._(FakeHabitWorld(clock));

  new _(this.world)
    : habits = FakeHabitRepository(world),
      entries = FakeHabitEntryRepository(world);

  final FakeHabitWorld world;
  final FakeHabitRepository habits;
  final FakeHabitEntryRepository entries;
  final FakeHabitReminderScheduler scheduler = FakeHabitReminderScheduler();

  MutableClock get clock => world.clock;

  List<Override> get overrides => [
    habitRepositoryProvider.overrideWithValue(habits),
    habitEntryRepositoryProvider.overrideWithValue(entries),
    habitReminderSchedulerProvider.overrideWithValue(scheduler),
  ];

  /// Adds a habit directly (no validation), at the end of the list.
  Habit addHabit(
    String name, {
    String? id,
    HabitKind kind = HabitKind.yesNo,
    HabitSchedule schedule = const HabitSchedule(
      type: ScheduleType.daily,
      target: 1,
    ),
    String? unit,
    String start = '2026-10-01',
    int freezes = 0,
    Set<Milestone> celebrated = const {},
    List<ReminderTime> reminders = const [],
    bool archived = false,
    List<(String, HabitSchedule)>? versions,
  }) {
    final now = clock.now().toUtc();
    final h = Habit(
      id: id ?? world.nextId(),
      name: name,
      iconKey: 'menu_book',
      colorHex: '#2B7ACA',
      kind: kind,
      schedule: versions?.last.$2 ?? schedule,
      unit: unit,
      reminderTimes: reminders,
      remindOnlyIfNotDone: true,
      startDate: LocalDate.fromKey(start),
      isArchived: archived,
      archivedAt: archived ? now : null,
      sortOrder: world.habits.length,
      freezesAvailable: freezes,
      celebratedMilestones: celebrated,
      createdAt: now,
      updatedAt: now,
    );
    world.habits[h.id] = h;
    world.versions[h.id] = [
      for (final (from, s) in versions ?? [(start, schedule)])
        ScheduleVersion(effectiveFrom: LocalDate.fromKey(from), schedule: s),
    ];
    world.changed();
    return h;
  }

  /// Sets a day directly (no rules). Value 0 without freeze or note removes
  /// it.
  void setDay(
    String habitId,
    String key, {
    int value = 1,
    bool freeze = false,
    String? note,
  }) {
    final day = LocalDate.fromKey(key);
    final map = world.entries.putIfAbsent(habitId, () => {});
    if (value == 0 && !freeze && note == null) {
      map.remove(day);
    } else {
      map[day] = HabitEntry(
        habitId: habitId,
        date: day,
        value: value,
        isFreeze: freeze,
        note: note,
      );
    }
    world.changed();
  }

  /// Marks every day from [from] to [to] (keys, inclusive) done.
  void doneRange(String habitId, String from, String to, {int value = 1}) {
    for (
      var d = LocalDate.fromKey(from);
      !d.isAfter(LocalDate.fromKey(to));
      d = d.addDays(1)
    ) {
      setDay(habitId, d.key, value: value);
    }
  }

  HabitEntry? entry(String habitId, String key) =>
      world.entries[habitId]?[LocalDate.fromKey(key)];
}

final class FakeHabitRepository implements HabitRepository {
  new(this._w);

  final FakeHabitWorld _w;

  /// Method names, in call order.
  final List<String> calls = [];

  @override
  Stream<List<Habit>> watchActive() => _w.watch(() => _w.active);

  @override
  Stream<List<Habit>> watchArchived() => _w.watch(
    () =>
        _w.habits.values.where((h) => h.isArchived).toList()
          ..sort((a, b) => b.archivedAt!.compareTo(a.archivedAt!)),
  );

  @override
  Stream<Habit?> watchById(String id) => _w.watch(() => _w.habits[id]);

  @override
  Future<Habit?> byId(String id) async => _w.habits[id];

  @override
  Future<List<Habit>> activeHabits() async => _w.active;

  @override
  Future<Habit> create(HabitDraft draft) async {
    calls.add('create');
    _w.checkWrite();
    final now = _w.clock.now().toUtc();
    final h = Habit(
      id: _w.nextId(),
      name: draft.name.trim(),
      iconKey: draft.iconKey,
      colorHex: draft.colorHex,
      kind: draft.kind,
      schedule: draft.schedule,
      unit: draft.kind == HabitKind.count ? draft.unit : null,
      reminderTimes: [
        ...{...draft.reminderTimes},
      ]..sort(),
      remindOnlyIfNotDone: draft.remindOnlyIfNotDone,
      startDate: draft.startDate,
      isArchived: false,
      sortOrder: _w.active.length,
      freezesAvailable: 0,
      celebratedMilestones: const {},
      createdAt: now,
      updatedAt: now,
    );
    _w.habits[h.id] = h;
    _w.versions[h.id] = [
      ScheduleVersion(effectiveFrom: draft.startDate, schedule: draft.schedule),
    ];
    _w.changed();
    return h;
  }

  @override
  Future<Habit> update(String id, HabitDraft draft) async {
    calls.add('update');
    _w.checkWrite();
    final old = _w.habits[id];
    if (old == null) throw HabitNotFound(id);
    if (old.kind != draft.kind) throw const KindLocked();
    if (draft.schedule != old.schedule) {
      final today = _w.today;
      final from = today.isBefore(draft.startDate) ? draft.startDate : today;
      final list = _w.versions[id]!
        ..removeWhere((v) => v.effectiveFrom == from)
        ..add(ScheduleVersion(effectiveFrom: from, schedule: draft.schedule))
        ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
      _w.versions[id] = list;
    }
    final h = old.copyWith(
      name: draft.name.trim(),
      iconKey: draft.iconKey,
      colorHex: draft.colorHex,
      schedule: draft.schedule,
      unit: draft.kind == HabitKind.count ? draft.unit : null,
      reminderTimes: [
        ...{...draft.reminderTimes},
      ]..sort(),
      remindOnlyIfNotDone: draft.remindOnlyIfNotDone,
      startDate: draft.startDate,
      updatedAt: _w.clock.now().toUtc(),
    );
    _w.habits[id] = h;
    _w.changed();
    return h;
  }

  Habit _get(String id) => _w.habits[id] ?? (throw HabitNotFound(id));

  @override
  Future<void> archive(String id) async {
    calls.add('archive');
    _w.checkWrite();
    _w.habits[id] = _get(id)
        .copyWith(isArchived: true, archivedAt: _w.clock.now().toUtc());
    _w.changed();
  }

  @override
  Future<void> undoArchive(String id) async {
    calls.add('undoArchive');
    _w.habits[id] = _get(id).copyWith(isArchived: false, archivedAt: null);
    _w.changed();
  }

  @override
  Future<void> restore(String id) async {
    calls.add('restore');
    final end = _w.active.fold(-1, (m, h) => math.max(m, h.sortOrder)) + 1;
    _w.habits[id] = _get(id)
        .copyWith(isArchived: false, archivedAt: null, sortOrder: end);
    _w.changed();
  }

  @override
  Future<void> delete(String id) async {
    calls.add('delete');
    _w.checkWrite();
    _get(id);
    _w.habits.remove(id);
    _w.versions.remove(id);
    _w.entries.remove(id);
    _w.changed();
  }

  @override
  Future<void> reorder(List<String> idsInOrder) async {
    calls.add('reorder');
    var position = 0;
    for (final id in idsInOrder) {
      final h = _w.habits[id];
      if (h == null || h.isArchived) continue;
      _w.habits[id] = h.copyWith(sortOrder: position++);
    }
    _w.changed();
  }

  @override
  Future<int> addFreeze(String id) async {
    calls.add('addFreeze');
    final h = _get(id);
    final n = math.min(h.freezesAvailable + 1, 2);
    _w.habits[id] = h.copyWith(freezesAvailable: n);
    _w.changed();
    return n;
  }
}

final class FakeHabitEntryRepository implements HabitEntryRepository {
  new(this._w);

  final FakeHabitWorld _w;

  /// Every applied operation, in order.
  final List<({String habitId, LocalDate date, DayOp op})> applied = [];

  @override
  Stream<List<HabitHistory>> watchActiveHistories({required LocalDate from}) =>
      _w.watch(() => [for (final h in _w.active) _w.historyOf(h, from: from)]);

  @override
  Stream<HabitHistory?> watchHistory(String habitId) => _w.watch(() {
    final h = _w.habits[habitId];
    return h == null ? null : _w.historyOf(h);
  });

  @override
  Future<HabitHistory?> history(String habitId) async {
    final h = _w.habits[habitId];
    return h == null ? null : _w.historyOf(h);
  }

  @override
  Stream<List<HabitEntry>> watchNotes(String habitId) => _w.watch(
    () =>
        (_w.entries[habitId]?.values ?? const <HabitEntry>[])
            .where((e) => e.note != null)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
  );

  /// Same rules as `DriftHabitEntryRepository.apply` (data-model §6).
  @override
  Future<DayWriteResult> apply(String habitId, LocalDate date, DayOp op) async {
    applied.add((habitId: habitId, date: date, op: op));
    _w.checkWrite();
    final habit = _w.habits[habitId];
    if (habit == null) throw HabitNotFound(habitId);
    final engine = _w.engine;
    final history = _w.historyOf(habit);
    final today = engine.today;
    if (op is! Restore &&
        (date.isAfter(today) || date.isBefore(habit.startDate))) {
      throw DayNotEditable(date.key);
    }
    final old = history.entries[date];
    final before = EntrySnapshot(
      habitId: habitId,
      date: date,
      wasLive: old != null,
      value: old?.value ?? 0,
      isFreeze: old?.isFreeze ?? false,
      note: old?.note,
      freezesAvailableBefore: habit.freezesAvailable,
    );
    var value = before.value;
    var isFreeze = before.isFreeze;
    var note = before.note;
    var freezes = habit.freezesAvailable;
    bool? live;
    final target = engine.scheduleOn(history, date).target;
    final max = habit.kind == HabitKind.yesNo ? 1 : 9999;
    switch (op) {
      case Toggle():
        value = value >= target ? 0 : target;
      case Increment():
        value = math.min(value + 1, max);
      case SetValue(value: final v):
        if (v < 0 || v > max) throw InvalidDayInput('value $v');
        value = v;
      case SetNote(note: final n):
        final t = n?.trim();
        note = t == null || t.isEmpty ? null : t;
      case UseFreeze(:final allowToday):
        switch (FreezePolicy(engine)
            .check(history, date, allowToday: allowToday, available: freezes)) {
          case FreezeRejected(:final reason):
            throw FreezeNotAllowed(reason);
          case FreezeNoneLeft():
            throw const NoFreezesLeft();
          case FreezeAllowed():
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
    if (op is! Restore && isFreeze && value >= target) {
      isFreeze = false;
      freezes = math.min(freezes + 1, 2);
    }
    live ??= value > 0 || isFreeze || note != null;
    final map = _w.entries.putIfAbsent(habitId, () => {});
    if (live) {
      map[date] = HabitEntry(
        habitId: habitId,
        date: date,
        value: value,
        isFreeze: isFreeze,
        note: note,
      );
    } else {
      map.remove(date);
    }
    var updated = habit.copyWith(freezesAvailable: freezes);
    final summary = engine.summarize(_w.historyOf(updated));
    final pick = selectNewMilestones(
      summary.current,
      updated.celebratedMilestones,
    );
    if (pick.toSet.isNotEmpty) {
      updated = updated.copyWith(
        celebratedMilestones: {...updated.celebratedMilestones, ...pick.toSet},
      );
    }
    _w.habits[habitId] = updated;
    _w.changed();
    return DayWriteResult(
      before: before,
      summary: summary,
      milestone: pick.show,
    );
  }
}

/// Records reminder calls instead of scheduling (feature 005 T032).
class FakeHabitReminderScheduler implements HabitReminderScheduler {
  /// `reconcile:<id>`, `reconcileAll`, `cancel:<id>`, `cancelAll`, in order.
  final List<String> calls = [];

  /// What [exactAlarmsAllowed] returns.
  bool exact = true;

  @override
  Future<void> reconcile(String habitId) async =>
      calls.add('reconcile:$habitId');

  @override
  Future<void> reconcileAll() async => calls.add('reconcileAll');

  @override
  Future<void> cancel(String habitId) async => calls.add('cancel:$habitId');

  @override
  Future<void> cancelAll() async => calls.add('cancelAll');

  @override
  Future<bool> exactAlarmsAllowed() async => exact;
}
