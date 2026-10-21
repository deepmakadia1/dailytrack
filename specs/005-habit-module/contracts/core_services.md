# Contract: Core services added or changed by feature 005

## NotificationService (changed, `lib/core/notifications/notification_service.dart`, research R11)

```dart
enum NotificationChannelId { budgetAlerts, habitReminders }   // appended

enum RepeatInterval { daily, weekly }

final class ScheduledNotification {
  final AppNotification notification;
  final DateTime firstAt;          // local wall-clock time of the first fire
  final RepeatInterval repeat;     // daily → match time; weekly → match weekday + time
  final bool exact;                // exactAllowWhileIdle vs inexactAllowWhileIdle
}

abstract interface class NotificationService {
  // existing: initialize, canNotify, show, cancelByTag, launchPayload, taps
  Future<void> schedule(ScheduledNotification n);   // replaces any notification with the same id
  Future<void> cancel(int id);
  Future<bool> canScheduleExact();
  /// Re-reads the device zone (R1); returns false when it cannot be resolved,
  /// in which case callers must not schedule.
  Future<bool> refreshTimeZone();
}
```

- `LocalNotificationService` is still the only importer of `flutter_local_notifications`, and now
  also the only importer of `timezone`. Channel `habit_reminders` (default importance) is created in
  `initialize()`; labels come from ARB (`notif_channelHabitReminders`,
  `notif_channelHabitRemindersDescription`) in `production_overrides.dart`.
- `TimeZoneSource` (`core/notifications/time_zone_source.dart`): `Future<String?> deviceZoneId()`
  over `MethodChannel('dailytrack/timezone')`; `MainActivity.kt` answers `getTimeZone`.
- `stableNotificationId(String key)` moves to `core/notifications/notification_ids.dart`; the
  expense notifier imports it from there (behavior and ids unchanged).
- `FakeNotificationService` (test helpers) records `scheduled` by id and `cancelled` ids, and has a
  settable `exactAllowed` and `zoneResolvable`.

## Share (changed, `lib/core/share/`, research R12)

```dart
abstract interface class ImageSharer {
  Future<void> sharePng(Uint8List png, {required String fileName, String? text});
}
@Riverpod(keepAlive: true) ImageSharer imageSharer(Ref ref) => const SharePlusImageSharer();
```

`core/widgets/share_capture.dart`: `Future<Uint8List?> captureBoundaryPng(GlobalKey key,
{double pixelRatio = 3})`.

## Settings (changed)

`AppSettings.habitRemindersEnabled` (default true) and its codec key; `SettingsRepository` gains
`setHabitRemindersEnabled` for T3.1 (no UI now).

## AppDatabase (changed)

`schemaVersion` 4; tables `Habits`, `HabitSchedules`, `HabitEntries` imported from
`features/habit/data/tables/`; `from3To4` (data-model §1); `drift_schema_v4.json`.

## TrackerModule (unchanged)

The interface is unchanged. `HabitModule` implements all hooks (routes_and_module.md).

## Android (changed)

`AndroidManifest.xml` adds:
- `RECEIVE_BOOT_COMPLETED` and `SCHEDULE_EXACT_ALARM` permissions.
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver` (exported false).
- `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver` (exported false) with
  `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`, and
  `com.htc.intent.action.QUICKBOOT_POWERON` actions.

`MainActivity.kt` registers the `dailytrack/timezone` channel.
