import 'package:clock/clock.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/planned_reminder.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/ports/habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/reminders/plan_reminders.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_entry_repository.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_repository.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';

/// [HabitReminderScheduler] over the core [NotificationService] (research
/// R10, R11, FR-038–FR-043).
///
/// Reconciling cancels all 24 ids of the habit, then registers the plan
/// from `planReminders`, so saving again replaces rather than duplicates
/// and removed slots never linger (SC-005). Nothing is scheduled when the
/// notifications switch or "Habit reminders" is off or the OS blocks
/// notifications (the habit's reminders are cancelled instead). When the
/// device time zone cannot be read, nothing is touched, so no reminder
/// moves to a wrong time; the next app open tries again.
///
/// Text comes from ARB in the saved or device language and holds only the
/// habit name and an encouragement (FR-043).
///
/// Feature 008 (research R17): yes/no reminders carry "Mark done" and
/// "Snooze 1 h", count reminders only "Snooze 1 h", and the payload names
/// the habit, time, and weekday so the actions find the reminder's day.
/// A snoozed copy is cancelled once the habit is done for today.
final class LocalHabitReminderScheduler implements HabitReminderScheduler {
  new({
    required this.service,
    required this.habits,
    required this.entries,
    required this.settings,
    required this.clock,
    required this.l10n,
  });

  final NotificationService service;
  final HabitRepository habits;
  final HabitEntryRepository entries;
  final SettingsRepository settings;
  final Clock clock;

  /// Localizations to use now (the saved language may change).
  final AppLocalizations Function() l10n;

  @override
  Future<void> reconcile(String habitId) async {
    if (!await service.refreshTimeZone()) return;
    final allowed = await _allowed();
    final habit = await habits.byId(habitId);
    if (habit == null || habit.isArchived || !allowed.on) {
      await cancel(habitId);
      return;
    }
    await _reconcile(habit, allowed.firstDayOfWeek, await canExact());
  }

  @override
  Future<void> reconcileAll() async {
    if (!await service.refreshTimeZone()) return;
    final allowed = await _allowed();
    final active = await habits.activeHabits();
    final exact = await canExact();
    for (final habit in active) {
      if (allowed.on) {
        await _reconcile(habit, allowed.firstDayOfWeek, exact);
      } else {
        await cancel(habit.id);
      }
    }
  }

  /// Also cancels a snoozed copy.
  @override
  Future<void> cancel(String habitId) async {
    await _cancelReminders(habitId);
    await service.cancel(snoozeIdFor(habitId));
  }

  Future<void> _cancelReminders(String habitId) async {
    for (final id in reminderIdsFor(habitId)) {
      await service.cancel(id);
    }
  }

  /// Every active and archived habit, so nothing is left behind when the
  /// module is turned off (FR-040).
  @override
  Future<void> cancelAll() async {
    final all = [
      ...await habits.activeHabits(),
      ...await habits.watchArchived().first,
    ];
    for (final habit in all) {
      await cancel(habit.id);
    }
  }

  @override
  Future<bool> exactAlarmsAllowed() => canExact();

  Future<bool> canExact() async {
    try {
      return await service.canScheduleExact();
    } on Object {
      return false;
    }
  }

  Future<({bool on, int firstDayOfWeek})> _allowed() async {
    final s = await settings.load();
    final on =
        s.notificationsEnabled &&
        s.habitRemindersEnabled &&
        await service.canNotify();
    return (on: on, firstDayOfWeek: s.firstDayOfWeek);
  }

  Future<void> _reconcile(Habit habit, int firstDayOfWeek, bool exact) async {
    final now = clock.now();
    final today = LocalDate.fromDateTime(now);
    final engine = StreakEngine(clock, firstDayOfWeek: firstDayOfWeek);
    final history = await entries.history(habit.id);
    final doneToday = history != null && engine.isDone(history, today);
    var weekTargetMet = false;
    if (history != null && habit.schedule.type == ScheduleType.timesPerWeek) {
      final week = engine.weekProgress(history, today);
      weekTargetMet = week.done >= week.target;
    }

    await _cancelReminders(habit.id);
    // A snoozed reminder of a habit already done today never shows.
    if (doneToday && habit.remindOnlyIfNotDone) {
      await service.cancel(snoozeIdFor(habit.id));
    }
    final t = l10n();
    final actions = reminderActions(habit, t);
    for (final plan in planReminders(
      habit,
      now: now,
      doneToday: doneToday,
      weekTargetMet: weekTargetMet,
      firstDayOfWeek: firstDayOfWeek,
    )) {
      await service.schedule(
        ScheduledNotification(
          notification: AppNotification(
            id: plan.id,
            channel: NotificationChannelId.habitReminders,
            title: t.notif_habitReminderTitle(habit.name),
            body: t.notif_habitReminderBody(habit.name),
            payload: reminderPayload(
              habit.id,
              plan.firstAt,
              plan.repeat == ReminderRepeat.weekly ? plan.firstAt.weekday : 0,
            ),
            actions: actions,
          ),
          firstAt: plan.firstAt,
          repeat: switch (plan.repeat) {
            ReminderRepeat.daily => RepeatInterval.daily,
            ReminderRepeat.weekly => RepeatInterval.weekly,
          },
          exact: exact,
        ),
      );
    }
  }
}

/// The buttons on [habit]'s reminders (FR-038, FR-039): "Mark done" only
/// for yes/no habits, since a count needs a number.
List<NotificationActionSpec> reminderActions(
  Habit habit,
  AppLocalizations t,
) => [
  if (habit.kind == HabitKind.yesNo)
    NotificationActionSpec(
      id: HabitActions.markDone,
      label: t.notif_actionMarkDone,
    ),
  NotificationActionSpec(id: HabitActions.snooze, label: t.notif_actionSnooze),
];
