import 'package:dailytrack/core/notifications/notification_ids.dart';

/// Reminder slots per habit (FR-038: up to 3 reminder times).
const int maxReminders = 3;

/// The stable notification id of one reminder (research R10): [index] is
/// the reminder's position (0–2) and [weekday] 0 for a daily repeat or the
/// weekday (1 = Monday … 7 = Sunday) of a weekly one.
int reminderIdFor(String habitId, int index, int weekday) =>
    stableNotificationId('habit:$habitId:$index:$weekday');

/// Every id a habit can ever use (3 indexes × 8 weekday values). The
/// scheduler cancels all of them before scheduling, so removed slots never
/// linger.
List<int> reminderIdsFor(String habitId) => [
  for (var index = 0; index < maxReminders; index++)
    for (var weekday = 0; weekday <= 7; weekday++)
      reminderIdFor(habitId, index, weekday),
];

/// The one-shot "Snooze 1 h" copy of a habit's reminder (feature 008
/// data-model §7). One per habit: snoozing again replaces it.
int snoozeIdFor(String habitId) =>
    stableNotificationId('habit-snooze:$habitId');

/// Notification and widget action names (feature 008 research R17, R20).
abstract final class HabitActions {
  static const String markDone = 'habit.markDone';
  static const String snooze = 'habit.snooze';
  static const String widgetCheck = 'habit.widgetCheck';
}

/// The reminder payload: HAB-01 plus what the actions need, e.g.
/// `/habits?habit=<id>&at=08:00&wd=0` ([weekday] 0 = daily).
String reminderPayload(String habitId, DateTime firstAt, int weekday) =>
    reminderPayloadOf(
      habitId,
      '${firstAt.hour.toString().padLeft(2, '0')}:'
          '${firstAt.minute.toString().padLeft(2, '0')}',
      '$weekday',
    );

/// The same payload from its parts (a snoozed copy reuses them). The time
/// keeps its colon; the routes ignore these parameters.
String reminderPayloadOf(String habitId, String at, String weekday) =>
    '/habits?habit=${Uri.encodeQueryComponent(habitId)}'
    '&at=${Uri.encodeQueryComponent(at).replaceAll('%3A', ':')}'
    '&wd=${Uri.encodeQueryComponent(weekday)}';
