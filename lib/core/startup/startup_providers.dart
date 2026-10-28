import 'package:dailytrack/core/startup/startup_reporter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'startup_providers.g.dart';

/// Bound to the platform channel in `lib/app/production_overrides.dart`.
@Riverpod(keepAlive: true)
StartupReporter startupReporter(Ref ref) => const NoStartupReporter();

/// Calls [StartupReporter.homeShown] once per app run, however often DSH-01
/// builds (feature 012 T043).
@Riverpod(keepAlive: true)
void Function() reportHomeShown(Ref ref) {
  var done = false;
  return () {
    if (done) return;
    done = true;
    ref.read(startupReporterProvider).homeShown();
  };
}
