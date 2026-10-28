import 'dart:async';

import 'package:dailytrack/core/startup/startup_reporter.dart';
import 'package:flutter/services.dart';

/// Calls `Activity.reportFullyDrawn()` through `MainActivity`'s
/// `dailytrack/startup` channel (feature 012 research R10), at most once per
/// process.
final class ChannelStartupReporter implements StartupReporter {
  const new();

  static const MethodChannel _channel = MethodChannel('dailytrack/startup');
  static bool _reported = false;

  @override
  void homeShown() {
    if (_reported) return;
    _reported = true;
    unawaited(
      _channel.invokeMethod<void>('reportFullyDrawn').catchError((Object _) {
        // No channel (tests, other platforms): nothing to report.
      }),
    );
  }
}
