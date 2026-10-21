import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/ports/habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_entry_repository.dart';

/// Every change to a habit day goes through here (research R8): the
/// transactional repository write, then a reminder reconcile when the day
/// is in the current week, because "only if not done" and the weekly
/// target depend on it (FR-039).
final class HabitDayWriter {
  new(this._entries, this._scheduler, this._clock, {this.firstDayOfWeek = 1});

  final HabitEntryRepository _entries;
  final HabitReminderScheduler _scheduler;
  final Clock _clock;

  /// 1 = Monday … 7 = Sunday (settings `firstDayOfWeek`).
  final int firstDayOfWeek;

  /// Applies [op]. Repository errors propagate and nothing is reconciled.
  /// A failed reconcile never fails the write: the next app open
  /// reconciles again.
  Future<DayWriteResult> write(String habitId, LocalDate date, DayOp op) async {
    final result = await _entries.apply(habitId, date, op);
    final today = LocalDate.fromDateTime(_clock.now());
    if (date.startOfWeek(firstDayOfWeek) == today.startOfWeek(firstDayOfWeek)) {
      try {
        await _scheduler.reconcile(habitId);
      } on Object {
        // Best effort (research R10).
      }
    }
    return result;
  }
}
