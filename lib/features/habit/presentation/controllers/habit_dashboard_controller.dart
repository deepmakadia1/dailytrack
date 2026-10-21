import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_listing.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_dashboard_controller.freezed.dart';
part 'habit_dashboard_controller.g.dart';

/// One check button on the Home card.
@freezed
abstract class HabitCheckData with _$HabitCheckData {
  const factory({
    required Habit habit,
    required bool isDone,
    required int value,
    required int target,
  }) = _HabitCheckData;
}

/// The Home card (contracts/screens.md "Home card").
@freezed
abstract class HabitDashboardData with _$HabitDashboardData {
  const factory({
    required int doneCount,
    required int scheduledCount,

    /// Today's scheduled habits, in sort order.
    required List<HabitCheckData> checks,
    required bool hasHabits,
  }) = _HabitDashboardData;
}

/// `HabitModule.dashboardCard()` (T092, US7; DSH-01). Watches active habits
/// with the current week of entries (enough for today and the weekly
/// listing). Rebuilds at local midnight so "today" moves on without a
/// restart (feature 006 research R18).
@riverpod
class HabitDashboardController extends _$HabitDashboardController {
  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<List<HabitHistory>>? _historiesSub;
  List<Habit>? _habits;
  Map<String, HabitHistory>? _histories;

  LocalDate get _today => LocalDate.fromDateTime(ref.read(clockProvider).now());

  @override
  AsyncValue<HabitDashboardData> build() {
    final now = ref.watch(clockProvider).now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timer = Timer(midnight.difference(now), ref.invalidateSelf);
    _habits = null;
    _histories = null;
    ref
      ..watch(streakEngineProvider)
      ..onDispose(() {
        timer.cancel();
        unawaited(_habitsSub?.cancel());
        unawaited(_historiesSub?.cancel());
      });
    _habitsSub = ref.read(habitRepositoryProvider).watchActive().listen((h) {
      _habits = h;
      _emit();
    }, onError: _onError);
    _historiesSub = ref
        .read(habitEntryRepositoryProvider)
        .watchActiveHistories(from: _today.addDays(-7))
        .listen((h) {
          _histories = {for (final x in h) x.habitId: x};
          _emit();
        }, onError: _onError);
    return const AsyncLoading();
  }

  void _onError(Object e, StackTrace st) {
    if (ref.mounted) state = AsyncError(e, st);
  }

  void _emit() {
    final habits = _habits;
    final histories = _histories;
    if (habits == null || histories == null || !ref.mounted) return;
    final engine = ref.read(streakEngineProvider);
    final today = _today;
    final checks = [
      for (final habit in habits)
        if (histories[habit.id] case final h? when listedOn(engine, h, today))
          HabitCheckData(
            habit: habit,
            isDone: engine.isDone(h, today),
            value: h.entries[today]?.value ?? 0,
            target: engine.scheduleOn(h, today).target,
          ),
    ];
    state = AsyncData(
      HabitDashboardData(
        doneCount: checks.where((c) => c.isDone).length,
        scheduledCount: checks.length,
        checks: checks,
        hasHabits: habits.isNotEmpty,
      ),
    );
  }

  Future<DayWriteResult?> _write(String id, DayOp op, {LocalDate? date}) async {
    try {
      return await ref
          .read(habitDayWriterProvider)
          .write(id, date ?? _today, op);
    } on Object {
      return null;
    }
  }

  /// Yes/no tap (US7-2).
  Future<DayWriteResult?> toggle(String id) => _write(id, const Toggle());

  /// Count popup "+1".
  Future<DayWriteResult?> increment(String id) => _write(id, const Increment());

  /// Count popup custom value.
  Future<DayWriteResult?> setValue(String id, int value) =>
      _write(id, SetValue(value));

  /// Undo of a write from the card: puts the day back as it was, the same
  /// way HAB-01's Undo does (DSH-01, §15.5).
  Future<DayWriteResult?> undo(DayWriteResult previous) => _write(
    previous.before.habitId,
    Restore(previous.before),
    date: previous.before.date,
  );

  void retry() => ref.invalidateSelf();
}
