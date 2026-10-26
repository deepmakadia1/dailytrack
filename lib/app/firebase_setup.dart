import 'dart:async';

import 'package:dailytrack/app/flavor.dart';
import 'package:dailytrack/core/config/firebase_config.dart';
import 'package:dailytrack/core/support/crash_redaction.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Data goes to Firebase only from prod release builds; dev and debug
/// builds never report.
bool get firebaseCollects => FlavorConfig.current.isProd && kReleaseMode;

/// Starts Firebase for crash reporting and analytics (spec §2), in `main()`
/// and in the WorkManager isolate. Off when the build has no Firebase
/// values. Crash reports carry the error's type and stack trace only
/// ([redactError]); analytics sends Firebase's automatic events only, with
/// no custom events, user ID, or user properties (Constitution III). Never
/// throws: the app starts without Firebase if it fails.
// Plugin calls: checked on a device, not in unit tests.
// coverage:ignore-start
Future<void> startFirebase() async {
  final options = FirebaseConfig.options;
  if (options == null) return;
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
    final collect = firebaseCollects;
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(collect);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(collect);
    if (!collect) return;
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        crashlytics.recordError(redactError(details.exception), details.stack),
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        crashlytics.recordError(redactError(error), stack, fatal: true),
      );
      return true;
    };
  } on Object {
    // Crash reporting and analytics are optional.
  }
}

// coverage:ignore-end
