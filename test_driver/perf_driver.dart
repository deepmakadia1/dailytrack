import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Driver for the device performance tests in `integration_test/perf/`
/// (feature 012 T044, research R10). Each key the test reports with
/// `binding.reportData` is written to `build/<key>.perf.json`, for
/// `specs/012-release-readiness/performance-report.md`.
///
/// flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart
///   --target integration_test/perf/exp01_scroll_perf_test.dart
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final MapEntry(:key, :value) in data.entries) {
      final file = File('build/$key.perf.json')..createSync(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(value),
      );
      stdout.writeln('$key: ${file.path}');
    }
  },
);
