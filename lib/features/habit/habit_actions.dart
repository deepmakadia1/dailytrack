import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/data/reminders/local_habit_reminder_scheduler.dart'
    show reminderActions;
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/habit/domain/reminders/resolve_reminder_day.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_listing.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';

/// How long "Snooze 1 h" waits (FR-039).
const Duration snoozeDelay = Duration(hours: 1);

/// `HabitModule.handleAction` (feature 008 research R17, R20): reminder
/// buttons and widget checks, in the app or a background isolate. Every
/// write goes through `HabitDayWriter`, so reminders reconcile as after a
/// check-in on HAB-01. An action for a missing, archived, or wrong-kind
/// habit is handled with no write, so no other module gets it.
Future<bool> handleHabitAction(AppAction action, ProviderReader read) async {
  final habitId = action.params['habit'];
  switch (action.name) {
    case HabitActions.markDone when habitId != null:
      await _markDone(habitId, action.params, read);
      return true;
    case HabitActions.snooze when habitId != null:
      await _snooze(habitId, action.params, read);
      return true;
    case HabitActions.widgetCheck when habitId != null:
      await _widgetCheck(habitId, action.params['day'], read);
      return true;
    default:
      return false;
  }
}

/// A live habit, or null when it was archived or deleted.
Future<Habit?> _live(String id, ProviderReader read) async {
  final habit = await read(habitRepositoryProvider).byId(id);
  return habit == null || habit.isArchived ? null : habit;
}

Future<StreakEngine> _engine(ProviderReader read) async {
  final s = await read(settingsRepositoryProvider).load();
  return StreakEngine(read(clockProvider), firstDayOfWeek: s.firstDayOfWeek);
}

/// "Mark done" (FR-038): sets the reminder's day to its target. Setting a
/// value, never toggling, so a second tap keeps it done.
Future<void> _markDone(
  String id,
  Map<String, String> params,
  ProviderReader read,
) async {
  final habit = await _live(id, read);
  if (habit == null || habit.kind != HabitKind.yesNo) return;
  final day = resolveReminderDay(
    read(clockProvider).now(),
    params['at'] ?? '',
    int.tryParse(params['wd'] ?? '') ?? -1,
  );
  if (day == null) return;
  await _setDone(habit, day, read);
}

Future<void> _setDone(Habit habit, LocalDate day, ProviderReader read) async {
  final history = await read(habitEntryRepositoryProvider).history(habit.id);
  if (history == null) return;
  final engine = await _engine(read);
  if (engine.isDone(history, day)) return;
  final target = engine.scheduleOn(history, day).target;
  try {
    await read(habitDayWriterProvider).write(
      habit.id,
      day,
      SetValue(habit.kind == HabitKind.yesNo ? 1 : target),
    );
  } on Object {
    // The day is not editable (before the start date); nothing to do.
  }
}

/// "Snooze 1 h" (FR-039): the same reminder once more, an hour from now.
Future<void> _snooze(
  String id,
  Map<String, String> params,
  ProviderReader read,
) async {
  final habit = await _live(id, read);
  if (habit == null) return;
  final s = await read(settingsRepositoryProvider).load();
  if (!s.notificationsEnabled || !s.habitRemindersEnabled) return;
  final service = read(notificationServiceProvider);
  final t = l10nFor(s.locale);
  bool exact;
  try {
    exact = await service.canScheduleExact();
  } on Object {
    exact = false;
  }
  await service.schedule(
    ScheduledNotification(
      notification: AppNotification(
        id: snoozeIdFor(habit.id),
        channel: NotificationChannelId.habitReminders,
        title: t.notif_habitReminderTitle(habit.name),
        body: t.notif_habitReminderBody(habit.name),
        payload: reminderPayloadOf(
          habit.id,
          params['at'] ?? '',
          params['wd'] ?? '0',
        ),
        actions: reminderActions(habit, t),
      ),
      firstAt: read(clockProvider).now().add(snoozeDelay),
      repeat: null,
      exact: exact,
    ),
  );
}

/// A widget check (FR-045, clarification Q3): a yes/no habit that is not
/// done becomes done, a done one stays done (no undo from the widget), and
/// a count habit gets +1. Only for today: a stale widget showing yesterday
/// changes nothing.
Future<void> _widgetCheck(
  String id,
  String? dayKey,
  ProviderReader read,
) async {
  final today = LocalDate.fromDateTime(read(clockProvider).now());
  if (dayKey != today.key) return;
  final habit = await _live(id, read);
  if (habit == null) return;
  if (habit.kind == HabitKind.yesNo) {
    await _setDone(habit, today, read);
    return;
  }
  try {
    await read(habitDayWriterProvider)
        .write(habit.id, today, const Increment());
  } on Object {
    // Not editable; nothing to do.
  }
}

/// `HabitModule.contributeGlance` (research R19): the day's listed habits
/// in the user's order, as on the Home card.
Future<void> contributeHabitGlance(
  GlanceBuilder b,
  ProviderReader read,
  DateTime nowLocal,
) async {
  final day = LocalDate.fromDateTime(nowLocal);
  final engine = await _engine(read);
  final habits = [...await read(habitRepositoryProvider).activeHabits()]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final histories = {
    for (final h in await read(
      habitEntryRepositoryProvider,
    ).watchActiveHistories(from: day.addDays(-7)).first)
      h.habitId: h,
  };
  final items = <GlanceHabit>[];
  for (final habit in habits) {
    final h = histories[habit.id];
    if (h == null || !listedOn(engine, h, day)) continue;
    items.add(
      GlanceHabit(
        id: habit.id,
        name: habit.name,
        kind: habit.kind == HabitKind.yesNo
            ? GlanceHabitKind.yesNo
            : GlanceHabitKind.count,
        value: h.entries[day]?.value ?? 0,
        target: engine.scheduleOn(h, day).target,
        colorHex: habit.colorHex,
        unit: habit.unit,
      ),
    );
  }
  b.setHabits(
    GlanceHabits(
      scheduled: items.length,
      done: items.where((i) => i.done).length,
      items: items,
    ),
  );
}
