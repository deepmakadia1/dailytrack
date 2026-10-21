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
}
