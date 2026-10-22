/// Local notification channels (spec §12). Later features append theirs.
enum NotificationChannelId {
  budgetAlerts,
  habitReminders,

  /// Auto backup kept failing (FR-020, feature 008).
  backup,

  /// The daily summary (FR-036, feature 008).
  dailySummary,
}

/// A button on a notification, handled without opening the app (feature
/// 008 research R16), e.g. "Mark done".
final class NotificationActionSpec {
  const new({required this.id, required this.label});

  /// Stable action id, e.g. `habit.markDone`; it names the `AppAction`.
  final String id;

  /// Localized button text.
  final String label;
}

/// A tapped notification button (research R16).
final class NotificationActionEvent {
  const new({required this.actionId, required this.payload});

  final String actionId;

  /// The notification's payload, a go_router location with query
  /// parameters the action reads.
  final String payload;
}

/// How a scheduled notification repeats (feature 005 research R10).
enum RepeatInterval {
  /// Every day at the time of [ScheduledNotification.firstAt].
  daily,

  /// Every week on the weekday and time of [ScheduledNotification.firstAt].
  weekly,
}

/// One local notification (contracts/core_services.md).
final class AppNotification {
  const new({
    required this.id,
    required this.channel,
    required this.title,
    required this.body,
    required this.payload,
    this.tag,
    this.actions = const [],
  });

  final int id;
  final NotificationChannelId channel;
  final String title;
  final String body;

  /// A go_router location opened when the notification is tapped.
  final String payload;

  /// Groups notifications so they can be cancelled together (Android tag).
  final String? tag;

  /// Buttons, at most 3 (Android).
  final List<NotificationActionSpec> actions;
}

/// A notification registered with the operating system, so it fires even
/// when the app is closed and survives a reboot (research R10, R11).
/// Repeating, or one-shot when [repeat] is null (feature 008 R16).
final class ScheduledNotification {
  const new({
    required this.notification,
    required this.firstAt,
    required this.repeat,
    required this.exact,
  });

  final AppNotification notification;

  /// Local wall-clock time of the first fire. Later fires keep the same
  /// wall-clock time in the device's zone.
  final DateTime firstAt;

  /// Null fires once at [firstAt] (snooze, daily summary).
  final RepeatInterval? repeat;

  /// Exact alarm (`exactAllowWhileIdle`) or inexact fallback.
  final bool exact;
}

/// Shows local notifications and reports taps (research R15). Pure Dart, so
/// domain ports and presentation can depend on it without the plugin.
abstract interface class NotificationService {
  /// Creates the channels. Idempotent; never throws.
  Future<void> initialize();

  /// Whether the operating system lets the app show notifications.
  Future<bool> canNotify();

  Future<void> show(AppNotification notification);

  /// Cancels every shown notification with [tag].
  Future<void> cancelByTag(String tag);

  /// Cancels every scheduled and shown notification (erase all data,
  /// feature 007 research R16).
  Future<void> cancelAll();

  /// The payload of the tap that cold-started the app, if any.
  Future<String?> launchPayload();

  /// Payloads of taps while the app is running.
  Stream<String> get taps;

  /// Buttons tapped while the app is running (feature 008 R16). When the
  /// app is not running, the background handler receives them instead.
  Stream<NotificationActionEvent> get actions;

  /// Registers [notification], replacing any with the same id.
  Future<void> schedule(ScheduledNotification notification);

  /// Cancels the shown or scheduled notification with [id].
  Future<void> cancel(int id);

  /// Whether exact alarms are allowed (Android 12+ `SCHEDULE_EXACT_ALARM`).
  Future<bool> canScheduleExact();

  /// Opens the system "Alarms & reminders" page (FR-042). True when exact
  /// alarms are allowed afterwards.
  Future<bool> requestExactAlarms();

  /// Re-reads the device time zone (research R1). Returns false when it
  /// cannot be resolved; callers must then not schedule, so nothing fires
  /// at a wrong time.
  Future<bool> refreshTimeZone();
}
