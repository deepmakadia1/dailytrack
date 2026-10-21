import 'package:dailytrack/features/habit/domain/ports/habit_reminder_scheduler.dart';

/// A scheduler that does nothing (tasks.md T031): bound where reminders are
/// not available, so saving, archiving, or deleting a habit never throws.
final class NoopHabitReminderScheduler implements HabitReminderScheduler {
  const new();

  @override
  Future<void> reconcile(String habitId) async {}

  @override
  Future<void> reconcileAll() async {}

  @override
  Future<void> cancel(String habitId) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool> exactAlarmsAllowed() async => true;
}
