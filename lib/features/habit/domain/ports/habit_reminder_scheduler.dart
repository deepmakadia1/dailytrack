/// Schedules habit reminders through the core notification service
/// (research R10). Implemented in data/; the domain only calls it.
abstract interface class HabitReminderScheduler {
  /// Cancels every reminder id of the habit, then schedules its plan.
  Future<void> reconcile(String habitId);

  /// [reconcile] for every active habit.
  Future<void> reconcileAll();

  Future<void> cancel(String habitId);

  /// The Habit module was turned off.
  Future<void> cancelAll();

  /// False when reminders fall back to inexact timing (HAB-02 hint).
  Future<bool> exactAlarmsAllowed();
}
