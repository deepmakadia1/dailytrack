import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_controller.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_habit_streaks_controller.g.dart';

/// One active habit with its HAB-01-window history and streak summary.
typedef HabitStreakRow = ({
  Habit habit,
  HabitHistory history,
  StreakSummary summary,
});

/// Active habits (in sort order) with the same 400-day history window as
/// HAB-01 and their streak summaries, live, rebuilt at local midnight.
/// Shared by the DSH-01 streak flame and the habit insight source, so Home
/// loads that window once (feature 006 research R5, R15).
@riverpod
class ActiveHabitStreaksController extends _$ActiveHabitStreaksController {
  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<List<HabitHistory>>? _historiesSub;
  List<Habit>? _habits;
  Map<String, HabitHistory>? _histories;

  @override
  AsyncValue<List<HabitStreakRow>> build() {
    ref.watch(streakEngineProvider);
    final now = ref.watch(clockProvider).now();
    final today = LocalDate.fromDateTime(now);
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timer = Timer(midnight.difference(now), ref.invalidateSelf);
    _habits = null;
    _histories = null;
    ref.onDispose(() {
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
        .watchActiveHistories(
          from: today.addDays(-HabitsTodayController.windowDays),
        )
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
    state = AsyncData([
      for (final habit in habits)
        if (histories[habit.id] case final h?)
          (habit: habit, history: h, summary: engine.summarize(h)),
    ]);
  }
}
