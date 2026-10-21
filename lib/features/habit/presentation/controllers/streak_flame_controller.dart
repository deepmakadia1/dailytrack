import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/streaks/best_streak.dart';
import 'package:dailytrack/features/habit/presentation/controllers/active_habit_streaks_controller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'streak_flame_controller.freezed.dart';
part 'streak_flame_controller.g.dart';

/// What the DSH-01 streak flame shows.
@freezed
abstract class StreakFlameData with _$StreakFlameData {
  const factory({required int current, required StreakUnit unit}) =
      _StreakFlameData;
}

/// The best active streak across active habits (feature 006 research R5),
/// live, from [ActiveHabitStreaksController] (the HAB-01 window, so the
/// flame and HAB-01 always agree). Shows 0 with no habits.
@riverpod
class StreakFlameController extends _$StreakFlameController {
  @override
  AsyncValue<StreakFlameData> build() =>
      ref.watch(activeHabitStreaksControllerProvider).whenData((rows) {
        final best = bestActiveStreak([
          for (final r in rows) (r.habit, r.summary),
        ]);
        return StreakFlameData(
          current: best?.current ?? 0,
          unit: best?.unit ?? StreakUnit.days,
        );
      });
}
