import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';

/// Result of [FreezePolicy.check].
sealed class FreezeDecision {
  const new();
}

final class FreezeAllowed extends FreezeDecision {
  const new();
}

final class FreezeRejected extends FreezeDecision {
  const new(this.reason);

  final FreezeRejection reason;
}

/// The habit has no freeze left to use.
final class FreezeNoneLeft extends FreezeDecision {
  const new();
}

/// Where a freeze may go (spec Edge Cases "Freeze window", FR-035, FR-036,
/// research R8):
/// - the HAB-03 freeze card: a missed due day 1 to 3 days before today;
/// - HAB-01 "Skip today" (`allowToday`): also today, when due and not done.
/// Never on a done, frozen, future, or before-start day.
final class FreezePolicy {
  const new(this._engine);

  final StreakEngine _engine;

  /// Days a freeze can reach back from the freeze card.
  static const int maxDaysBack = 3;

  FreezeDecision check(
    HabitHistory history,
    LocalDate day, {
    required bool allowToday,
    required int available,
  }) {
    final today = _engine.today;
    if (day.isAfter(today)) return const FreezeRejected(FreezeRejection.future);
    if (day.isBefore(history.startDate)) {
      return const FreezeRejected(FreezeRejection.beforeStart);
    }
    if (_engine.isDone(history, day)) {
      return const FreezeRejected(FreezeRejection.alreadyDone);
    }
    if (history.entries[day]?.isFreeze ?? false) {
      return const FreezeRejected(FreezeRejection.alreadyFrozen);
    }
    if (!_engine.isScheduledOn(history, day)) {
      return const FreezeRejected(FreezeRejection.notScheduled);
    }
    final daysBack = today.difference(day);
    if (daysBack == 0 && !allowToday) {
      return const FreezeRejected(FreezeRejection.today);
    }
    if (daysBack > maxDaysBack) {
      return const FreezeRejected(FreezeRejection.tooOld);
    }
    if (available <= 0) return const FreezeNoneLeft();
    return const FreezeAllowed();
  }
}
