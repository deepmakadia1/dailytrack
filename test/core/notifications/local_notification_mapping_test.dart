import 'package:dailytrack/core/notifications/local_notification_service.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide RepeatInterval;
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Pure mapping helpers of LocalNotificationService (feature 005 T022,
/// research R10, R11). Plugin calls are checked on a device.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('channel ids are stable', () {
    expect(
      androidChannelId(NotificationChannelId.budgetAlerts),
      'budget_alerts',
    );
    expect(
      androidChannelId(NotificationChannelId.habitReminders),
      'habit_reminders',
    );
  });

  test('repeat → matched components', () {
    expect(matchFor(RepeatInterval.daily), DateTimeComponents.time);
    expect(
      matchFor(RepeatInterval.weekly),
      DateTimeComponents.dayOfWeekAndTime,
    );
  });

  test('exact → exactAllowWhileIdle, else the inexact fallback', () {
    expect(
      scheduleModeFor(exact: true),
      AndroidScheduleMode.exactAllowWhileIdle,
    );
    expect(
      scheduleModeFor(exact: false),
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
  });

  group('tzWallTime keeps the wall-clock fields', () {
    test('in Asia/Kolkata', () {
      final kolkata = tz.getLocation('Asia/Kolkata');
      final t = tzWallTime(DateTime(2026, 10, 21, 7, 30), kolkata);
      expect((t.year, t.month, t.day, t.hour, t.minute), (2026, 10, 21, 7, 30));
      expect(t.timeZoneOffset, const Duration(hours: 5, minutes: 30));
    });

    test('in America/New_York across the November DST change', () {
      final ny = tz.getLocation('America/New_York');
      // EDT (UTC−4) before 1 Nov 2026, EST (UTC−5) after.
      final before = tzWallTime(DateTime(2026, 10, 31, 7), ny);
      final after = tzWallTime(DateTime(2026, 11, 2, 7), ny);
      expect((before.hour, after.hour), (7, 7));
      expect(before.timeZoneOffset, const Duration(hours: -4));
      expect(after.timeZoneOffset, const Duration(hours: -5));
      expect(after.toUtc().hour, 12);
      expect(before.toUtc().hour, 11);
    });

    test('in America/New_York across the March DST change', () {
      final ny = tz.getLocation('America/New_York');
      final t = tzWallTime(DateTime(2027, 3, 15, 21), ny);
      expect((t.hour, t.timeZoneOffset), (21, const Duration(hours: -4)));
    });

    test('ignores seconds and the source zone of the DateTime', () {
      final utc = tz.UTC;
      final t = tzWallTime(DateTime.utc(2026, 10, 21, 7, 5, 59), utc);
      expect((t.hour, t.minute, t.second), (7, 5, 0));
    });
  });
}
