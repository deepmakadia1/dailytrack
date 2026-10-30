import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/security_providers.dart';
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
/// contracts/routes.md). With no login chosen yet, AUTH-01 opens and the
/// payload is dropped, even with app lock on (feature 011
/// contracts/routes.md).
String initialLocationFor(AppSettings settings, {String? launchPayload}) {
  if (!settings.onboardingDone) return Routes.onboarding;
  if (settings.authMode == AuthMode.none) return Routes.login;
  final target = launchPayload != null && launchPayload.startsWith('/')
      ? launchPayload
      : Routes.home;
  return settings.lockEnabled ? Routes.lockPath(from: target) : target;
}

/// Whether a cold start begins locked (feature 007 R7): only after login,
/// so AUTH-01 shows before SYS-03 (feature 011 research R7).
bool lockAtStart(AppSettings settings) =>
    settings.onboardingDone &&
    settings.lockEnabled &&
    settings.authMode != AuthMode.none;

/// SYS-01 startup (T080):
///  1. open the database (runs migrations) and load settings,
///  2. seed defaults for every registered module, exactly once,
///  3. resolve ad consent, then start the ads SDK, unless Remove Ads was
///     purchased (waits only while consent is still unknown; never fails),
///  4. start notifications, the app-open hooks, and the home screen widget
///     host (never block),
///  5. pick the first route (a tapped notification's or the widget's
///     location if allowed).
/// Feature 011: the sign-in mode is migrated once, right after seeding.
/// Feature 010: the device ID is checked before routing, and the Google
/// account's silent sign-in runs behind the first screen (spec §16).
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
    AppSettings settings;
    try {
      final db = ref.read(appDatabaseProvider);
      // Drift opens lazily; the first query opens the file and migrates.
      await db.customSelect('SELECT 1').get();
      // Seed for every registered module, enabled or not, so turning a module
      // on later never finds it empty (research R7).
      final registry = ref.read(moduleRegistryProvider);
      await SeedRunner(db).runAll(registry.all.expand((m) => m.seeders));
      // Before routing and the Android-restore check, so an updated install
      // never sees AUTH-01 (feature 011 research R2).
      await ref.read(settingsRepositoryProvider).migrateAuthMode();
      settings = await ref.read(settingsRepositoryProvider).load();
    } on Object catch (e) {
      return BootstrapFailed(e);
    }

    if (await _ensureDeviceId() == DeviceIdOrigin.restoredFromAndroidBackup) {
      await _afterAndroidRestore(settings);
      try {
        settings = await ref.read(settingsRepositoryProvider).load();
      } on Object catch (e) {
        return BootstrapFailed(e);
      }
    }
    await _startAds(settings);

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
    // Best effort; a failure shows the account as signed out (FR-004).
    unawaited(_restoreAccount());
    // A cold start with app lock on begins locked (feature 007 R7).
    ref
        .read(lockSessionProvider.notifier)
        .start(lockEnabled: lockAtStart(settings));
    return BootstrapReady(initialLocationFor(settings, launchPayload: payload));
  }

  /// Step 3: consent (UMP), then the ads SDK (feature 009 research R4,
  /// contracts/services.md §12). With Pro cached, neither the consent SDK
  /// nor the ads SDK is touched (SYS-01 AC). A user whose stored consent
  /// already allows ads starts at once and refreshes consent in the
  /// background; otherwise startup waits for the consent check (and form)
  /// first, so no ad is requested before consent is resolved (§11 AC).
  /// Never throws: on any failure ads stay off for this session.
  Future<void> _startAds(AppSettings settings) async {
    // A cold start is a new session for the interstitial cap; the first one
    // ever also records the install time (research R9).
    unawaited(ref.read(interstitialCoordinatorProvider).startSession());
    // Pro (spec PRM-01, research R13): listen for purchases first, then
    // apply a removal staged by an earlier start, so locks and ads return
    // together (analysis I1). The ownership check runs in the background;
    // this start decides ads from the saved flag (offline: trust it).
    final pro = ref.read(proServiceProvider)..start();
    var proOwned = settings.removeAdsPurchased;
    if (await pro.applyStagedRemoval()) proOwned = false;
    unawaited(pro.verifyOwnership());
    // "Unlock all features (debug)" acts as Pro: no consent, no ads SDK.
    if (ref.read(debugToolsAvailableProvider) && settings.debugUnlockAll) {
      proOwned = true;
    }
    final gate = ref.read(adsSessionGateProvider.notifier);
    if (proOwned) {
      gate.startedWithAds = false;
      return;
    }
    try {
      final consent = ref.read(consentServiceProvider);
      final timeout = ref.read(adConfigProvider).consentUpdateTimeout;
      // The form appears over the Flutter splash, not behind the system one.
      Future<void> removeSplash() async => FlutterNativeSplash.remove();
      final bool allowed;
      if (await consent.canRequestAds()) {
        allowed = true;
        unawaited(
          consent
              .gather(beforeForm: removeSplash, timeout: timeout)
              .then((_) {}, onError: (Object _) {}),
        );
      } else {
        final result = await consent.gather(
          beforeForm: removeSplash,
          timeout: timeout,
        );
        allowed = result.canRequestAds;
      }
      gate.startedWithAds = allowed;
      if (allowed) {
        unawaited(ref.read(adServiceProvider).init().catchError((Object _) {}));
      }
    } on Object {
      // Ads must never block startup.
      gate.startedWithAds = false;
    }
  }

  /// The device ID file and its settings copy agree (feature 010 R4).
  Future<DeviceIdOrigin> _ensureDeviceId() async {
    try {
      return await ref.read(deviceIdentityServiceProvider).ensure();
    } on Object {
      // Backups read the ID again when they need it.
      return DeviceIdOrigin.existing;
    }
  }

  /// The first start after Android restored the database from its own
  /// backup or a device transfer (spec §16, research R13, FR-046). The PIN
  /// and backup password stayed behind (secure storage is excluded), so:
  /// app lock and biometrics go off when no PIN can be read, instead of
  /// locking the user out; the account keys are cleared; a restored
  /// `google` tries a silent sign-in and becomes `guest` without one, while
  /// a restored `guest` or `none` is kept with no Google call (feature 011
  /// research R5, FR-010); the conflict rule applies as if no backup were
  /// known; Home shows "Finish setting up"; notifications are rescheduled
  /// and Restore purchase runs. Onboarding is not shown again, and AUTH-01
  /// only for a restored `none`. Each step is best effort.
  Future<void> _afterAndroidRestore(AppSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    Future<void> step(Future<void> Function() body) async {
      try {
        await body();
      } on Object {
        // The next step still runs.
      }
    }

    await step(() async {
      final lock = ref.read(lockServiceProvider);
      if (await lock.status() == LockStatus.credentialUnavailable) {
        await lock.reset();
        await repo.setBiometricEnabled(enabled: false);
        await repo.setLockEnabled(enabled: false);
      }
    });
    await step(() => repo.setAccount(null));
    await step(() => repo.setLastKnownDriveBackup(at: null, deviceId: null));
    await step(() => repo.setAutoBackupPause(paused: false, notified: false));
    if (settings.onboardingDone) {
      await step(() => repo.setFinishSetupPending(pending: true));
    }
    if (settings.authMode == AuthMode.google) {
      unawaited(
        step(() async {
          if (!await ref.read(accountServiceProvider).adoptSilentSession()) {
            await repo.setAuthMode(AuthMode.guest);
          }
        }),
      );
    }
    unawaited(step(() => ref.read(restoreAftermathProvider)()));
    unawaited(step(() => ref.read(proServiceProvider).restore()));
  }

  Future<void> _restoreAccount() async {
    try {
      await ref.read(accountServiceProvider).restoreSession();
    } on Object {
      // No account binding (tests) or no Google services: stays as stored.
    }
    try {
      // Deletes a safety copy older than 7 days (feature 010 FR-019a).
      await ref.read(accountRestoreProvider).safetyCopy();
    } on Object {
      // Tried again at the next start.
    }
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
