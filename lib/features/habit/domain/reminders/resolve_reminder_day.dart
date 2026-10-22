import 'package:dailytrack/features/habit/domain/dates.dart';

/// The day a reminder was for (feature 008 data-model §7, research R17).
/// Reminders repeat, so the payload holds the time [at] (`HH:mm`) and the
/// weekday [weekday] (0 = daily, 1–7 = ISO weekday) instead of a date.
/// Returns the latest local day `d` whose occurrence `d at` is at or before
/// [now] and, for a weekly reminder, falls on [weekday]: a "Mark done"
/// tapped after midnight marks the reminder's day, not the new one.
/// Returns null when [at] or [weekday] is malformed.
LocalDate? resolveReminderDay(DateTime now, String at, int weekday) {
  final parts = at.split(':');
  if (parts.length != 2 || weekday < 0 || weekday > 7) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  var day = LocalDate.fromDateTime(now);
  // At most a week back finds any weekday.
  for (var i = 0; i < 8; i++, day = day.addDays(-1)) {
    final occurrence = DateTime(day.year, day.month, day.day, hour, minute);
    if (occurrence.isAfter(now)) continue;
    if (weekday == 0 || day.weekday == weekday) return day;
  }
  return null;
}
