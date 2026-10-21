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
