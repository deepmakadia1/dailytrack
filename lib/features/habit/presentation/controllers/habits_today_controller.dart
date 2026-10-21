import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_listing.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_state.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/habit/presentation/controllers/habits_today_state.dart';

part 'habits_today_controller.g.dart';

/// HAB-01 Habits today (T059, contracts/screens.md). The screen's only
/// notifier. Watches the active habits and their entries from
/// `today − 400 days` (research R7); a habit whose current run reaches that
/// window start gets its full history loaded once, cached until its
/// entries change.
@riverpod
class HabitsTodayController extends _$HabitsTodayController {
  /// Days of history HAB-01 watches (covers a 365-day milestone, R7).
  static const int windowDays = 400;

  /// How far back HAB-01 can check in (FR-017).
  static const int maxDaysBack = 7;

  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<List<HabitHistory>>? _historiesSub;
  List<Habit>? _habits;
  Map<String, HabitHistory>? _windowed;

  /// Full histories by habit id, with the windowed history they replace.
  final Map<String, ({HabitHistory windowed, HabitHistory full})> _full = {};
  final Set<String> _loadingFull = {};

  late LocalDate _today;
  late LocalDate _selected;
  var _weekOffset = 0;
  var _reorderMode = false;

  StreakEngine get _engine => ref.read(streakEngineProvider);

  LocalDate _now() => LocalDate.fromDateTime(ref.read(clockProvider).now());

  @override
  HabitsTodayState build() {
    ref
      ..watch(streakEngineProvider)
      ..onDispose(() {
        unawaited(_habitsSub?.cancel());
        unawaited(_historiesSub?.cancel());
      });
    _today = _now();
    _selected = _today;
    _subscribe();
    return const HabitsTodayState();
  }

  void _subscribe() {
    unawaited(_habitsSub?.cancel());
    unawaited(_historiesSub?.cancel());
    _habits = null;
    _windowed = null;
    _habitsSub = ref.read(habitRepositoryProvider).watchActive().listen((
      habits,
    ) {
      _habits = habits;
      _emit();
    }, onError: _onError);
    _historiesSub = ref
        .read(habitEntryRepositoryProvider)
        .watchActiveHistories(from: _today.addDays(-windowDays))
        .listen((histories) {
          _windowed = {for (final h in histories) h.habitId: h};
          _emit();
        }, onError: _onError);
  }

  void _onError(Object e, StackTrace st) {
    if (ref.mounted) state = HabitsTodayState(data: AsyncError(e, st));
  }

  /// The history the rules run on: the full one when the window is too
  /// short for the current run (R7), else the windowed one.
  HabitHistory? _historyOf(Habit habit) {
    final windowed = _windowed?[habit.id];
    if (windowed == null) return null;
    final from = windowed.loadedFrom;
    if (from == null) return windowed;
    final cached = _full[habit.id];
    if (cached != null && cached.windowed == windowed) return cached.full;
    if (_engine.currentRunReaches(windowed, from.addDays(7))) {
      unawaited(_loadFull(habit.id, windowed));
    }
    return windowed;
  }

  Future<void> _loadFull(String habitId, HabitHistory windowed) async {
    if (!_loadingFull.add(habitId)) return;
    try {
      final full = await ref
          .read(habitEntryRepositoryProvider)
          .history(habitId);
      if (full != null && ref.mounted) {
        _full[habitId] = (windowed: windowed, full: full);
        _emit();
      }
    } on Object {
      // The windowed streak stays; the next change retries.
    } finally {
      _loadingFull.remove(habitId);
    }
  }

  void _emit() {
    final habits = _habits;
    if (habits == null || _windowed == null || !ref.mounted) return;
    state = HabitsTodayState(data: AsyncData(_build(habits)));
  }

  bool _listed(HabitHistory h, LocalDate day) => listedOn(_engine, h, day);

  HabitsTodayData _build(List<Habit> habits) {
    final engine = _engine;
    final histories = {
      for (final habit in habits) habit.id: ?_historyOf(habit),
    };
    final scheduled = <HabitCardData>[];
    final notScheduled = <HabitCardData>[];
    for (final habit in habits) {
      final h = histories[habit.id];
      if (h == null) continue;
      final card = _card(habit, h);
      (_listed(h, _selected) ? scheduled : notScheduled).add(card);
    }

    final weekStart = _today
        .startOfWeek(engine.firstDayOfWeek)
        .addDays(7 * _weekOffset);
    final week = [
      for (var i = 0; i < 7; i++)
        _cell(weekStart.addDays(i), habits, histories),
    ];
    final done = scheduled.where((c) => c.isDone).length;
    return HabitsTodayData(
      today: _today,
      selected: _selected,
      weekOffset: _weekOffset,
      week: week,
      doneCount: done,
      scheduledCount: scheduled.length,
      scheduled: scheduled,
      notScheduled: notScheduled,
      habits: habits,
      allDoneToday:
          _selected == _today &&
          scheduled.isNotEmpty &&
          done == scheduled.length,
      reorderMode: _reorderMode,
    );
  }

  WeekDayCell _cell(
    LocalDate day,
    List<Habit> habits,
    Map<String, HabitHistory> histories,
  ) {
    final back = _today.difference(day);
    var scheduled = 0;
    var done = 0;
    if (back >= 0) {
      for (final habit in habits) {
        final h = histories[habit.id];
        if (h == null || !_listed(h, day)) continue;
        scheduled++;
        if (_engine.isDone(h, day)) done++;
      }
    }
    return WeekDayCell(
      date: day,
      done: done,
      scheduled: scheduled,
      selectable: back >= 0 && back <= maxDaysBack,
      isFuture: back < 0,
      isToday: back == 0,
    );
  }

  HabitCardData _card(Habit habit, HabitHistory h) {
    final engine = _engine;
    final day = _selected;
    final entry = h.entries[day];
    final status = engine.dayStatus(h, day);
    final isDone = engine.isDone(h, day);
    final isFreeze = !isDone && (entry?.isFreeze ?? false);
    final summary = engine.summarize(h);
    final week = engine.weekProgress(h, day);
    return HabitCardData(
      habit: habit,
      status: status,
      value: entry?.value ?? 0,
      target: engine.scheduleOn(h, day).target,
      isDone: isDone,
      isFreeze: isFreeze,
      note: entry?.note,
      schedule: scheduleText(
        habit.schedule,
        doneThisWeek: week.done,
        firstDayOfWeek: engine.firstDayOfWeek,
      ),
      currentStreak: summary.current,
      unit: summary.unit,
      canSkipToday:
          day == _today &&
          engine.isScheduledOn(h, day) &&
          !isDone &&
          !isFreeze &&
          status != DayStatus.future,
    );
  }

  void _refresh() {
    if (_habits != null && _windowed != null) _emit();
  }

  /// Selects [day] when it is today or up to 7 days back (FR-017).
  void selectDay(LocalDate day) {
    final back = _today.difference(day);
    if (back < 0 || back > maxDaysBack) return;
    _selected = day;
    _refresh();
  }

  /// Shows the current week (0) or the previous one (-1) (research R14).
  void pageWeek(int offset) {
    _weekOffset = offset.clamp(-1, 0);
    _refresh();
  }

  /// On resume: a new local day resets the selection to the new today and
  /// moves the history window (R14).
  void checkDayRollover() {
    final now = _now();
    if (now == _today) return;
    _today = now;
    _selected = now;
    _weekOffset = 0;
    _full.clear();
    _subscribe();
  }

  void setReorderMode({required bool on}) {
    _reorderMode = on;
    _refresh();
  }

  Future<DayWriteResult?> _write(String id, LocalDate day, DayOp op) async {
    try {
      return await ref.read(habitDayWriterProvider).write(id, day, op);
    } on Object {
      return null;
    }
  }

  /// Yes/no check, or a count habit to its target and back (FR-018).
  Future<DayWriteResult?> toggle(String id) =>
      _write(id, _selected, const Toggle());

  /// Count habits: +1 (FR-018).
  Future<DayWriteResult?> increment(String id) =>
      _write(id, _selected, const Increment());

  /// Count habits: an exact value, 0–9,999 (FR-018).
  Future<DayWriteResult?> setValue(String id, int value) =>
      _write(id, _selected, SetValue(value));

  /// "Add note for today" (or the selected day). Null or blank removes it.
  Future<DayWriteResult?> setNote(String id, String? note) =>
      _write(id, _selected, SetNote(note));

  /// "Skip today": a freeze on today (FR-036, clarification Q1).
  Future<DayWriteResult?> skipToday(String id) =>
      _write(id, _today, const UseFreeze(allowToday: true));

  /// Undo of a day write: puts the day and the freeze count back.
  Future<DayWriteResult?> undo(EntrySnapshot before) =>
      _write(before.habitId, before.date, Restore(before));

  /// Archives [id] and cancels its reminders (US1-10). False on failure.
  Future<bool> archive(String id) async {
    try {
      await ref.read(habitRepositoryProvider).archive(id);
    } on Object {
      return false;
    }
    await _bestEffort(
      () => ref.read(habitReminderSchedulerProvider).cancel(id),
    );
    return true;
  }

  /// Undo of [archive]: back at the same position, reminders rescheduled.
  Future<void> undoArchive(String id) async {
    try {
      await ref.read(habitRepositoryProvider).undoArchive(id);
    } on Object {
      return;
    }
    await _bestEffort(
      () => ref.read(habitReminderSchedulerProvider).reconcile(id),
    );
  }

  /// Persists a drag in reorder mode (FR-021).
  Future<void> reorder(List<String> idsInOrder) async {
    try {
      await ref.read(habitRepositoryProvider).reorder(idsInOrder);
    } on Object {
      // The stream keeps the stored order.
    }
  }

  /// Error state "Try again".
  void retry() {
    state = const HabitsTodayState();
    _subscribe();
  }

  static Future<void> _bestEffort(Future<void> Function() body) async {
    try {
      await body();
    } on Object {
      // Reminders are reconciled again on the next app open.
    }
  }
}
