import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Android host for the app lock (feature 007 T002, research R2, R8, R9):
/// checkable from source; the prompt and FLAG_SECURE are device checks.
void main() {
  final activity = File(
    'android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/'
    'MainActivity.kt',
  ).readAsStringSync();
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  test('MainActivity is a FlutterFragmentActivity (local_auth needs one)', () {
    expect(
      activity,
      contains('class MainActivity : FlutterFragmentActivity()'),
    );
    expect(activity, isNot(contains(': FlutterActivity()')));
  });

  test('the platform channels keep their methods', () {
    expect(activity, contains('"dailytrack/timezone"'));
    expect(activity, contains('"dailytrack/window"'));
    for (final method in [
      'getTimeZone',
      'setSecure',
      'getDeviceInfo',
      'openNotificationSettings',
      'getNoBackupDir',
      'getNetworkState',
    ]) {
      expect(activity, contains('"$method"'), reason: method);
    }
    expect(activity, contains('FLAG_SECURE'));
    // The device ID file lives where Android never backs up (feature 010).
    expect(activity, contains('noBackupFilesDir'));
  });

  test('the manifest declares biometrics; OS backup uses the include-list '
      'rules (feature 010)', () {
    expect(
      manifest,
      contains(
        '<uses-permission android:name="android.permission.USE_BIOMETRIC"/>',
      ),
    );
    // test/android/backup_rules_test.dart checks the rules themselves.
    expect(manifest, contains('android:allowBackup="true"'));
    // Online checks before sign-in (feature 010 T057).
    expect(
      manifest,
      contains(
        '<uses-permission '
        'android:name="android.permission.ACCESS_NETWORK_STATE"/>',
      ),
    );
  });

  test('every launch and normal theme descends from Theme.AppCompat', () {
    for (final dir in [
      'values',
      'values-night',
      'values-v31',
      'values-night-v31',
    ]) {
      final styles = File('android/app/src/main/res/$dir/styles.xml')
          .readAsStringSync();
      final parents = RegExp(
        '<style name="(LaunchTheme|NormalTheme)" parent="([^"]+)"',
      ).allMatches(styles).toList();
      expect(parents, hasLength(2), reason: dir);
      for (final m in parents) {
        expect(
          m.group(2),
          startsWith('Theme.AppCompat'),
          reason: '$dir ${m.group(1)}',
        );
      }
    }
  });
}
