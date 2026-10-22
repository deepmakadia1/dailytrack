import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bootstrap.g.dart';

/// Outcome of SYS-01 startup (contracts/services.md).
sealed class BootstrapResult {
  const new();
}

final class BootstrapReady extends BootstrapResult {
  const new(this.initialLocation);

  final String initialLocation;
}

final class BootstrapFailed extends BootstrapResult {
  const new(this.error);

  final Object error;
}

/// The first screen for a user with these settings (spec §5 startup flow).
/// A tapped notification's [launchPayload] (a go_router location) is where
/// the user goes once onboarding is done; with app lock on, SYS-03 comes
/// first and sends them there after unlocking (feature 007
/// contracts/routes.md).
String initialLocationFor(AppSettings settings, {String? launchPayload}) {
  if (!settings.onboardingDone) return Routes.onboarding;
  final target = launchPayload != null && launchPayload.startsWith('/')
      ? launchPayload
      : Routes.home;
  return settings.lockEnabled ? Routes.lockPath(from: target) : target;
}

/// SYS-01 startup (T080):
///  1. open the database (runs migrations) and load settings,
///  2. seed defaults for every registered module, exactly once,
///  3. start the ads SDK unless Remove Ads was purchased (never blocks),
///  4. start notifications, the app-open hooks, and the home screen widget
///     host (never block),
///  5. pick the first route (a tapped notification's or the widget's
///     location if allowed).
/// A failure in steps 1–2 gives [BootstrapFailed], shown with "Retry".
@Riverpod(keepAlive: true)
class Bootstrap extends _$Bootstrap {
  @override
  Future<BootstrapResult> build() => _run();

  /// Runs startup again after a failure (the splash "Retry" button).
  Future<void> retry() async {
    state = const AsyncLoading();
    state = AsyncData(await _run());
  }

  Future<BootstrapResult> _run() async {
    final result = await _start();
    // Hand over from the native splash once there is something to show.
    FlutterNativeSplash.remove();
    return result;
  }

  Future<BootstrapResult> _start() async {
    final AppSettings settings;
    try {
      final db = ref.read(appDatabaseProvider);
      // Drift opens lazily; the first query opens the file and migrates.
      await db.customSelect('SELECT 1').get();
      // Seed for every registered module, enabled or not, so turning a module
      // on later never finds it empty (research R7).
      final registry = ref.read(moduleRegistryProvider);
      await SeedRunner(db).runAll(registry.all.expand((m) => m.seeders));
      settings = await ref.read(settingsRepositoryProvider).load();
    } on Object catch (e) {
      return BootstrapFailed(e);
    }

    // Consent (UMP) is resolved before this in T4.1.
    if (!settings.removeAdsPurchased) {
      try {
        await ref.read(adServiceProvider).initialize();
      } on Object {
        // Ads must never block startup.
      }
    }

    final notifications = ref.read(notificationServiceProvider);
    unawaited(notifications.initialize().catchError((Object _) {}));
    String? payload;
    try {
      payload = await notifications.launchPayload().timeout(
        const Duration(seconds: 1),
      );
    } on Object {
      payload = null;
    }
    // A widget tap that started the app opens Home (feature 008 R20).
    if (payload == null) {
      try {
        payload = await ref
            .read(homeWidgetBridgeProvider)
            .launchLocation()
            .timeout(const Duration(seconds: 1));
      } on Object {
        payload = null;
      }
    }
    // Budget rollover and similar work run behind the first screen (R10).
    unawaited(ref.read(appOpenRunnerProvider).run());
    // The widget's background callback, midnight alarm, and live refresh
    // (feature 008 research R19 – R21).
    unawaited(_startWidgetHost());
    // A cold start with app lock on begins locked (feature 007 R7).
    ref
        .read(lockSessionProvider.notifier)
        .start(lockEnabled: settings.onboardingDone && settings.lockEnabled);
    return BootstrapReady(initialLocationFor(settings, launchPayload: payload));
  }

  Future<void> _startWidgetHost() async {
    try {
      await registerWidgetHost(ref.read(homeWidgetBridgeProvider));
      ref.read(glanceRefresherProvider).start();
    } on Object {
      // The widget is optional; the app works without it.
    }
  }
}
