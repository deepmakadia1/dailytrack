import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/background_dispatcher.dart';
import 'package:dailytrack/app/firebase_setup.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/background/workmanager_background_scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App entry point. The bindings live in `app/production_overrides.dart`,
/// shared with the background dispatcher (research R10).
Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash until bootstrap() has a result (it calls remove()).
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Crash reporting first, so startup errors are caught (prod only).
  await startFirebase();
  try {
    await initializeBackground(backgroundDispatcher);
  } on Object {
    // The daily job is best effort; app open still runs the generator.
  }

  runApp(
    ProviderScope(
      overrides: productionOverrides(),
      child: const DailyTrackApp(),
    ),
  );
}
