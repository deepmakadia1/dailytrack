import 'dart:async';
import 'dart:ui';

import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/module/app_action.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/domain/home_widget_bridge.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The query parameters of a notification payload (a go_router location).
Map<String, String> payloadParams(String payload) {
  try {
    return Uri.parse(payload).queryParameters;
  } on FormatException {
    return const {};
  }
}

/// The testable core of [notificationActionEntryPoint] (feature 008
/// research R16, R17): dispatches the button as an [AppAction], then
/// refreshes the widget and the daily summary. Also used for buttons
/// tapped while the app runs (`app.dart`). Never throws.
Future<void> handleNotificationAction(
  String actionId,
  String payload,
  ProviderReader read,
) async {
  try {
    await read(appActionDispatcherProvider).dispatch(
      AppAction(
        source: AppActionSource.notification,
        name: actionId,
        params: payloadParams(payload),
      ),
      read,
    );
  } on Object {
    // A failed action changes nothing; the reminder stays as it was.
  }
  await _refresh(read);
}

/// Redraws the widget and reschedules the summary. Never throws.
Future<void> _refresh(ProviderReader read) async {
  try {
    await read(glanceRefresherProvider).refreshNow();
  } on Object {
    // The next write or trigger refreshes again.
  }
}

/// A widget habit check (research R20). Checks the glance guard again: while
/// the widget is hidden (lock on without "Show data on widget", or no
/// onboarding) no data is changed, even from an old widget state.
Future<void> handleWidgetCheck(Uri uri, ProviderContainer container) async {
  try {
    final settings = await container.read(settingsRepositoryProvider).load();
    if (widgetHidden(settings)) return;
    await container
        .read(appActionDispatcherProvider)
        .dispatch(
          AppAction(
            source: AppActionSource.widget,
            name: 'habit.widgetCheck',
            params: uri.queryParameters,
          ),
          container.read,
        );
  } on Object {
    // Nothing changes; the refresh below redraws the widget.
  }
}

/// Midnight, reboot, and time zone triggers (research R21): re-reads the
/// zone, lets each enabled module reschedule its notifications (after a
/// reboot or zone change), reschedules the summary through the refresh,
/// and records the zone so the next app open does not do it again.
Future<void> handleSystemTrigger(
  String trigger,
  ProviderContainer container,
) async {
  final read = container.read;
  try {
    await read(notificationServiceProvider).refreshTimeZone();
    if (trigger != 'midnight') {
      final settings = await read(settingsRepositoryProvider).load();
      for (final module in read(moduleRegistryProvider).visible(settings)) {
        try {
          await module.onNotificationSettingsChanged(read);
        } on Object {
          // One module never stops the others.
        }
      }
    }
    await read(dailySummarySchedulerProvider).reschedule();
  } on Object {
    // Best effort; the next trigger or app open tries again.
  }
  await recordTimeZone(container.read);
}

/// Stores the device zone (research R21). Best effort.
Future<void> recordTimeZone(ProviderReader read) async {
  try {
    final zone = await read(timeZoneSourceProvider).deviceZoneId();
    if (zone != null) {
      await read(settingsRepositoryProvider).setDeviceTimeZoneId(zone);
    }
  } on Object {
    // Checked again on the next app open.
  }
}

/// The testable core of [widgetBackgroundEntryPoint]: a widget check or a
/// system trigger, then a refresh. Never throws.
Future<void> handleWidgetUri(Uri? uri, ProviderContainer container) async {
  if (uri != null) {
    if (WidgetUris.isCheck(uri)) {
      await handleWidgetCheck(uri, container);
    } else if (WidgetUris.systemTrigger(uri) case final trigger?) {
      await handleSystemTrigger(trigger, container);
    }
  }
  await _refresh(container.read);
}

/// Runs [body] with a fresh container on the shared database, as the
/// WorkManager dispatcher does (research R10), and always disposes it.
// Platform entry points: exercised on a device (quickstart §4, §5).
// coverage:ignore-start
Future<void> _inBackground(
  Future<void> Function(ProviderContainer container) body,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final container = ProviderContainer(overrides: productionOverrides());
  try {
    await initializeDateFormatting();
    try {
      await container.read(notificationServiceProvider).initialize();
    } on Object {
      // Notifications are optional; the action still runs.
    }
    await body(container);
  } on Object {
    // Never throws out of an entry point.
  } finally {
    container.dispose();
  }
}

/// `flutter_local_notifications` background handler: a reminder button
/// tapped while the app is not running (research R16).
@pragma('vm:entry-point')
void notificationActionEntryPoint(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId == null || actionId.isEmpty) return;
  unawaited(
    _inBackground(
      (c) => handleNotificationAction(actionId, response.payload ?? '', c.read),
    ),
  );
}

/// `home_widget` interactivity callback: `dailytrack://widget/check` and
/// `dailytrack://system/{midnight,boot,timezone}` (research R20, R21).
@pragma('vm:entry-point')
Future<void> widgetBackgroundEntryPoint(Uri? uri) =>
    _inBackground((c) => handleWidgetUri(uri, c));

// coverage:ignore-end

/// Registers [widgetBackgroundEntryPoint] and arms the midnight alarm
/// (research R21). Called by bootstrap on every start; never throws.
Future<void> registerWidgetHost(HomeWidgetBridge bridge) async {
  try {
    await bridge.registerBackgroundCallback(widgetBackgroundEntryPoint);
    await bridge.armMidnight();
  } on Object {
    // No widget host; nothing to register.
  }
}
