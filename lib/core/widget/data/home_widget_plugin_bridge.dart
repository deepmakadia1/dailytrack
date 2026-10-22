import 'dart:async';

import 'package:dailytrack/core/widget/domain/home_widget_bridge.dart';
import 'package:dailytrack/core/widget/domain/widget_payload.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

/// The Kotlin widget provider (contracts/android.md).
const String todayWidgetProvider =
    'com.midexcode.daily.track.dailytrack.widget.TodayWidgetProvider';

/// Where any widget launch goes: Home (FR-046). The lock deferral in
/// `app.dart` sends it through SYS-03 first.
const String widgetLaunchLocation = '/home';

/// [HomeWidgetBridge] over `home_widget` (feature 008 research R20, R21).
/// With `lib/app/background_entry_points.dart`, the only importer of the
/// plugin (layering rule).
// Plugin calls: exercised on a device (quickstart §5), not in unit tests.
// coverage:ignore-start
final class HomeWidgetPluginBridge implements HomeWidgetBridge {
  const new();

  static const MethodChannel _glance = MethodChannel('dailytrack/glance');

  @override
  Future<void> save(String payloadJson) async {
    await HomeWidget.saveWidgetData<String>(widgetPayloadKey, payloadJson);
    await HomeWidget.updateWidget(qualifiedAndroidName: todayWidgetProvider);
  }

  @override
  Future<void> armMidnight() async {
    try {
      await _glance.invokeMethod<void>('armMidnight');
    } on MissingPluginException {
      // Not running on the Android host.
    }
  }

  @override
  Future<String?> launchLocation() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    return uri == null ? null : widgetLaunchLocation;
  }

  @override
  Stream<String> get launches => HomeWidget.widgetClicked
      .where((uri) => uri != null)
      .map((_) => widgetLaunchLocation);

  @override
  Future<void> registerBackgroundCallback(
    Future<void> Function(Uri? uri) callback,
  ) async {
    await HomeWidget.registerInteractivityCallback(callback);
  }
}
// coverage:ignore-end
