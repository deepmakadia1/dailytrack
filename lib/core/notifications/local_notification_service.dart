import 'dart:async';

import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/notifications/time_zone_source.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide RepeatInterval;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Localized name and description of a channel, resolved by the caller
/// (from ARB, without a `BuildContext`).
typedef ChannelLabels = ({String name, String description});

/// Android channel id for [channel]. Stable: users see channel settings.
String androidChannelId(NotificationChannelId channel) => switch (channel) {
  NotificationChannelId.budgetAlerts => 'budget_alerts',
  NotificationChannelId.habitReminders => 'habit_reminders',
  NotificationChannelId.backup => 'backup',
  NotificationChannelId.dailySummary => 'daily_summary',
};

/// What must match for a repeating notification to fire again (R10); null
/// for a one-shot (feature 008 R16).
DateTimeComponents? matchFor(RepeatInterval? repeat) => switch (repeat) {
  RepeatInterval.daily => DateTimeComponents.time,
  RepeatInterval.weekly => DateTimeComponents.dayOfWeekAndTime,
  null => null,
};

/// Buttons handled without opening the app; tapping one dismisses the
/// notification (feature 008 R16). The plugin's defaults already are
/// `showsUserInterface: false` and `cancelNotification: true`.
List<AndroidNotificationAction> androidActionsFor(
  List<NotificationActionSpec> actions,
) => [for (final a in actions) AndroidNotificationAction(a.id, a.label)];

/// A button response as an event, or null for a plain tap.
NotificationActionEvent? actionOf(NotificationResponse response) {
  final id = response.actionId;
  if (id == null || id.isEmpty) return null;
  return NotificationActionEvent(actionId: id, payload: response.payload ?? '');
}

/// Exact alarm when allowed, else the inexact fallback (FR-041).
AndroidScheduleMode scheduleModeFor({required bool exact}) => exact
    ? AndroidScheduleMode.exactAllowWhileIdle
    : AndroidScheduleMode.inexactAllowWhileIdle;

/// The zoned time with the same wall-clock fields as [local] in [location].
/// Built from the fields, never converted from the instant, so a reminder
/// set for 07:00 fires at 07:00 in the device zone even across a DST change.
tz.TZDateTime tzWallTime(DateTime local, tz.Location location) => tz.TZDateTime(
  location,
  local.year,
  local.month,
  local.day,
  local.hour,
  local.minute,
);

/// Notification details for [channel] (research R15: default importance).
AndroidNotificationDetails androidDetailsFor(
  NotificationChannelId channel,
  ChannelLabels labels, {
  String? tag,
  List<NotificationActionSpec> actions = const [],
}) => AndroidNotificationDetails(
  androidChannelId(channel),
  labels.name,
  channelDescription: labels.description,
  tag: tag,
  actions: actions.isEmpty ? null : androidActionsFor(actions),
);

/// The tap payload, or null when there is none.
String? payloadOf(NotificationResponse? response) {
  final payload = response?.payload;
  return payload == null || payload.isEmpty ? null : payload;
}

/// [NotificationService] backed by `flutter_local_notifications` (R15). The
/// only importer of the plugin besides `LocalNotificationPermission`.
///
/// [backgroundHandler] receives button taps while the app is not running
/// (feature 008 R16). It must be a top-level `@pragma('vm:entry-point')`
/// function; `production_overrides.dart` passes it, so core never imports
/// `lib/app/`.
final class LocalNotificationService implements NotificationService {
  new(this._labels, this._zones, {this.backgroundHandler});

  final DidReceiveBackgroundNotificationResponseCallback? backgroundHandler;

  /// Resolves the localized channel labels when [initialize] runs.
  final ChannelLabels Function(NotificationChannelId channel) _labels;

  /// The device zone for scheduled notifications (feature 005 R1).
  final TimeZoneSource _zones;

  final _taps = StreamController<String>.broadcast();
  final _actions = StreamController<NotificationActionEvent>.broadcast();
  Future<void>? _initialized;

  // Plugin calls: exercised on a device (quickstart §4), not in unit tests.
  // coverage:ignore-start
  FlutterLocalNotificationsPlugin get _plugin =>
      FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize() => _initialized ??= _initialize();

  Future<void> _initialize() async {
    try {
      await refreshTimeZone();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (actionOf(response) case final action?) {
            _actions.add(action);
          } else if (payloadOf(response) case final payload?) {
            _taps.add(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: backgroundHandler,
      );
      for (final channel in NotificationChannelId.values) {
        final labels = _labels(channel);
        await _android?.createNotificationChannel(
          AndroidNotificationChannel(
            androidChannelId(channel),
            labels.name,
            description: labels.description,
          ),
        );
      }
    } on Object {
      // Notifications must never break startup; a later call retries.
      _initialized = null;
    }
  }

  @override
  Future<bool> canNotify() async {
    try {
      return await _android?.areNotificationsEnabled() ?? true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> show(AppNotification notification) async {
    await initialize();
    await _plugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
      notificationDetails: NotificationDetails(
        android: androidDetailsFor(
          notification.channel,
          _labels(notification.channel),
          tag: notification.tag,
          actions: notification.actions,
        ),
      ),
    );
  }

  @override
  Future<void> cancelByTag(String tag) async {
    final active = await _plugin.getActiveNotifications();
    for (final n in active) {
      if (n.tag == tag && n.id != null) {
        await _plugin.cancel(id: n.id!, tag: tag);
      }
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return payloadOf(details.notificationResponse);
  }

  @override
  Future<void> schedule(ScheduledNotification scheduled) async {
    await initialize();
    final n = scheduled.notification;
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      payload: n.payload,
      scheduledDate: tzWallTime(scheduled.firstAt, tz.local),
      notificationDetails: NotificationDetails(
        android: androidDetailsFor(
          n.channel,
          _labels(n.channel),
          tag: n.tag,
          actions: n.actions,
        ),
      ),
      androidScheduleMode: scheduleModeFor(exact: scheduled.exact),
      matchDateTimeComponents: matchFor(scheduled.repeat),
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<bool> canScheduleExact() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestExactAlarms() async {
    try {
      await _android?.requestExactAlarmsPermission();
    } on Object {
      // The settings page may be missing on some devices.
    }
    return await canScheduleExact();
  }

  /// Loads the zone database once per process.
  static bool _zonesLoaded = false;

  @override
  Future<bool> refreshTimeZone() async {
    final id = await _zones.deviceZoneId();
    if (id == null) return false;
    try {
      if (!_zonesLoaded) {
        tz_data.initializeTimeZones();
        _zonesLoaded = true;
      }
      tz.setLocalLocation(tz.getLocation(id));
      return true;
    } on Object {
      return false;
    }
  }
  // coverage:ignore-end

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Stream<NotificationActionEvent> get actions => _actions.stream;
}
