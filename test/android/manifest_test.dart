import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// HAB-02 criterion "Reminders fire at the set local time, including after a
/// device reboot (RECEIVE_BOOT_COMPLETED reschedule)", the part checkable
/// without a device (feature 005 T024): the permissions and the plugin's
/// receivers are declared. The reboot itself is a device check (T098).
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  /// The `<receiver …>…</receiver>` or self-closed element for [name].
  String receiver(String name) {
    final match = RegExp(
      r'<receiver\b[^>]*android:name="' +
          RegExp.escape(name) +
          r'"[^>]*?(/>|>[\s\S]*?</receiver>)',
    ).firstMatch(manifest);
    expect(match, isNotNull, reason: '$name is declared');
    return match!.group(0)!;
  }

  test('declares INTERNET for Google Drive backup in release builds '
      '(feature 008)', () {
    expect(
      manifest,
      contains('<uses-permission android:name="android.permission.INTERNET"/>'),
    );
  });

  test('declares the boot and exact-alarm permissions', () {
    for (final permission in [
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.SCHEDULE_EXACT_ALARM',
      'android.permission.POST_NOTIFICATIONS',
    ]) {
      expect(
        manifest,
        contains('<uses-permission android:name="$permission"/>'),
        reason: permission,
      );
    }
    expect(
      manifest,
      isNot(contains('USE_EXACT_ALARM"')),
      reason: 'the Play-restricted permission is not used (research R10)',
    );
  });

  test('declares the scheduled notification receiver, not exported', () {
    final r = receiver(
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
    );
    expect(r, contains('android:exported="false"'));
  });

  test('declares the boot receiver with the 4 boot actions', () {
    final r = receiver(
      'com.dexterous.flutterlocalnotifications.'
      'ScheduledNotificationBootReceiver',
    );
    expect(r, contains('android:exported="false"'));
    for (final action in [
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
      'android.intent.action.QUICKBOOT_POWERON',
      'com.htc.intent.action.QUICKBOOT_POWERON',
    ]) {
      expect(r, contains('<action android:name="$action"/>'), reason: action);
    }
  });

  test('MainActivity answers the time zone channel (research R1)', () {
    final activity = File(
      'android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/'
      'MainActivity.kt',
    ).readAsStringSync();
    expect(activity, contains('"dailytrack/timezone"'));
    expect(activity, contains('"getTimeZone"'));
    expect(activity, contains('TimeZone.getDefault().id'));
  });

  group('feature 008 notifications and widget (T114, T131; '
      'contracts/android.md)', () {
    test('reminder buttons: the plugin action receiver', () {
      expect(
        receiver(
          'com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver',
        ),
        contains('android:exported="false"'),
      );
    });

    test("home_widget's background receiver runs the Dart callback", () {
      final r = receiver(
        'es.antonborri.home_widget.HomeWidgetBackgroundReceiver',
      );
      expect(r, contains('es.antonborri.home_widget.action.BACKGROUND'));
      expect(r, contains('android:exported="false"'));
    });

    test('system triggers: boot, app update, and time zone change', () {
      final r = receiver('.system.SystemEventsReceiver');
      for (final action in [
        'android.intent.action.BOOT_COMPLETED',
        'android.intent.action.MY_PACKAGE_REPLACED',
        'android.intent.action.TIMEZONE_CHANGED',
      ]) {
        expect(r, contains('<action android:name="$action" />'));
      }
      expect(r, contains('android:exported="false"'));
      expect(
        receiver('.system.MidnightAlarmReceiver'),
        contains('android:exported="false"'),
      );
    });

    test('the widget provider: APPWIDGET_UPDATE and its info', () {
      final r = receiver('.widget.TodayWidgetProvider');
      expect(r, contains('android.appwidget.action.APPWIDGET_UPDATE'));
      expect(r, contains('android:resource="@xml/today_widget_info"'));
      expect(r, contains('android:label="@string/widget_label"'));
    });
  });

  group('feature 008 widget resources (T131)', () {
    const res = 'android/app/src/main/res';
    String read(String path) => File('$res/$path').readAsStringSync();

    test('4×2, at least 250×110 dp, no periodic updates', () {
      final info = read('xml/today_widget_info.xml');
      for (final attr in [
        'android:targetCellWidth="4"',
        'android:targetCellHeight="2"',
        'android:minWidth="250dp"',
        'android:minHeight="110dp"',
        'android:updatePeriodMillis="0"',
        'android:resizeMode="horizontal|vertical"',
      ]) {
        expect(info, contains(attr));
      }
    });

    test('4 habit slots, each at least 48 dp tall', () {
      final layout = read('layout/widget_today.xml');
      for (var i = 0; i < 4; i++) {
        final slot = RegExp(
          '<LinearLayout\\s+android:id="@\\+id/habit_slot_$i"[^>]*>',
        ).firstMatch(layout);
        expect(slot, isNotNull, reason: 'slot $i');
        final min = RegExp(r'android:minHeight="(\d+)dp"')
            .firstMatch(slot!.group(0)!);
        expect(int.parse(min!.group(1)!), greaterThanOrEqualTo(48));
      }
      expect(read('layout/widget_hidden.xml'), contains('@string/widget_open'));
    });

    test('colors only from the generated widget colors, light and dark', () {
      expect(File('$res/values-night/widget_colors.xml').existsSync(), isTrue);
      for (final file in [
        'layout/widget_today.xml',
        'layout/widget_hidden.xml',
        'drawable/widget_background.xml',
        'drawable/ic_widget_check.xml',
        'drawable/ic_widget_check_done.xml',
        'drawable/ic_widget_plus.xml',
      ]) {
        expect(
          RegExp('#[0-9A-Fa-f]{6}').hasMatch(read(file)),
          isFalse,
          reason: '$file has a hard-coded color',
        );
      }
    });

    test('strings in English, Hindi, and Gujarati', () {
      for (final folder in ['values', 'values-hi', 'values-gu']) {
        final strings = read('$folder/strings.xml');
        for (final key in [
          'widget_label',
          'widget_description',
          'widget_open',
        ]) {
          expect(strings, contains('name="$key"'), reason: folder);
        }
      }
    });
  });
}
