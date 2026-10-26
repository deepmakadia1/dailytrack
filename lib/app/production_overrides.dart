import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/flavor.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router_ad_screen_probe.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/data/admob_ad_service.dart';
import 'package:dailytrack/core/ads/data/ump_consent_service.dart';
import 'package:dailytrack/core/ads/domain/ad_unit_ids.dart';
import 'package:dailytrack/core/ads/interstitial_coordinator.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/background/workmanager_background_scheduler.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/billing/data/in_app_purchase_pro_store.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/feature_gate/data/drift_feature_gate.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/local_notification_service.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/security/data/flutter_secure_key_value_store.dart';
import 'package:dailytrack/core/security/data/local_auth_biometric_authenticator.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widget/data/home_widget_plugin_bridge.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/habit/habit_bindings.dart';
import 'package:dailytrack/features/premium/presentation/rewarded_unlock_sheet.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:flutter_riverpod/misc.dart' show Override;

/// The production bindings: the composition root, the only place that binds
/// implementations to the provider interfaces (Constitution II). Shared by
/// `main.dart`, the background dispatcher (research R10) and the
/// integration tests, so all run the app exactly as shipped.
// Device bindings; exercised by integration_test/, not unit tests.
// coverage:ignore-start
List<Override> productionOverrides() {
  final registry = ModuleRegistry(registeredModules);
  return [
    moduleRegistryProvider.overrideWithValue(registry),
    // The one Google sign-in wrapper (feature 010 research R1).
    accountAuthProvider.overrideWith((ref) => ref.watch(googleAuthProvider)),
    // ACC-02 for SET-02 (feature 010 research R18).
    accountUiProvider.overrideWithValue(const AccountFeatureUi()),
    // Feature 009: UMP consent and AdMob (research R3–R5). Prod release
    // requests no ads until T117 wires the release IDs; dev and debug
    // builds always use Google's test IDs.
    consentServiceProvider.overrideWithValue(
      UmpConsentService.fromEnvironment(isProd: FlavorConfig.current.isProd),
    ),
    adUnitIdsProvider.overrideWithValue(
      AdUnitIds.resolve(
        isProd: FlavorConfig.current.isProd,
        isRelease: kReleaseMode,
        manifestUsesTestAppId: true,
        fromEnv: AdUnitIds.none,
      ),
    ),
    adServiceProvider.overrideWith(bindAdService),
    // Google Play Billing for Pro (research R13).
    proStoreProvider.overrideWithValue(InAppPurchaseProStore()),
    // PRM-02 lives in the premium feature (research R11).
    rewardedUnlockPresenterProvider.overrideWithValue(
      const PremiumRewardedUnlockPresenter(),
    ),
    // Full-screen ads only over reading screens, never while locked
    // (research R10).
    adScreenProbeProvider.overrideWith(
      (ref) => RouterAdScreenProbe(
        location: () => ref
            .read(appRouterProvider)
            .routerDelegate
            .currentConfiguration
            .uri
            .path,
        locked: () => ref.read(lockSessionProvider).locked,
      ),
    ),
    interstitialCoordinatorProvider.overrideWith((ref) {
      final coordinator = InterstitialCoordinator(
        settings: ref.watch(settingsRepositoryProvider),
        clock: ref.watch(clockProvider),
        config: ref.watch(adConfigProvider),
        probe: ref.watch(adScreenProbeProvider),
        // A full-screen ad is the app's own trip out: no SYS-03 on return.
        beforeFullScreen: () =>
            ref.read(externalActivityGuardProvider).expectExternalActivity(),
      )..attachLifecycle();
      ref.onDispose(coordinator.dispose);
      return coordinator;
    }),
    settingsRepositoryProvider.overrideWith(
      (ref) => SettingsRepositoryImpl(
        ref.watch(appDatabaseProvider),
        knownModuleIds: registry.ids,
      ),
    ),
    // Feature 003: notifications, background jobs, unlocks and the feature
    // gate (research R10, R13, R15).
    notificationServiceProvider.overrideWith(
      (ref) => LocalNotificationService(
        (channel) {
          final l10n = l10nFor(ref.read(appSettingsProvider).value?.locale);
          return switch (channel) {
            NotificationChannelId.budgetAlerts => (
              name: l10n.notif_channelBudgetAlerts,
              description: l10n.notif_channelBudgetAlertsDescription,
            ),
            // Feature 005 (T026).
            NotificationChannelId.habitReminders => (
              name: l10n.notif_channelHabitReminders,
              description: l10n.notif_channelHabitRemindersDescription,
            ),
            // Feature 008 (FR-020, FR-036, FR-040).
            NotificationChannelId.backup => (
              name: l10n.notif_channelBackup,
              description: l10n.notif_channelBackupDescription,
            ),
            NotificationChannelId.dailySummary => (
              name: l10n.notif_channelDailySummary,
              description: l10n.notif_channelDailySummaryDescription,
            ),
          };
        },
        ref.watch(timeZoneSourceProvider),
        // Reminder buttons while the app is not running (feature 008 R16).
        backgroundHandler: notificationActionEntryPoint,
      ),
    ),
    // The home screen widget (feature 008 research R20).
    homeWidgetBridgeProvider.overrideWithValue(const HomeWidgetPluginBridge()),
    backgroundSchedulerProvider.overrideWithValue(
      const WorkmanagerBackgroundScheduler(),
    ),
    debugToolsAvailableProvider.overrideWithValue(!FlavorConfig.current.isProd),
    unlockRepositoryProvider.overrideWith(
      (ref) => DriftUnlockRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(clockProvider),
      ),
    ),
    featureGateProvider.overrideWith(
      (ref) => DriftFeatureGate(
        ref.watch(unlockRepositoryProvider),
        ref.watch(settingsRepositoryProvider),
        ref.watch(clockProvider),
        debugToolsAvailable: ref.watch(debugToolsAvailableProvider),
      ),
    ),
    // Feature 007: the app lock and FLAG_SECURE (research R5, R9).
    lockServiceProvider.overrideWith(
      (ref) => SecureLockService(
        store: const FlutterSecureKeyValueStore(),
        biometrics: LocalAuthBiometricAuthenticator(),
        settings: ref.watch(settingsRepositoryProvider),
        clock: ref.watch(clockProvider),
      ),
    ),
    secureScreenServiceProvider.overrideWithValue(
      const ChannelSecureScreenService(),
    ),
    // Erase all data (feature 007 research R16).
    appResetServiceProvider.overrideWith(
      (ref) => DriftAppResetService(
        db: ref.watch(appDatabaseProvider),
        modules: registry.all,
        read: ref.read,
        notifications: ref.watch(notificationServiceProvider),
        // Device state outside the database: the lock and the backup
        // password in secure storage (feature 008 research R4), the Google
        // session, and both auto backup jobs (research R10, R11; feature
        // 010). Keeping the sign-in through an erase is task T041. Best
        // effort.
        resetLock: () async {
          await ref.read(lockServiceProvider).reset();
          for (final step in <Future<void> Function()>[
            ref.read(backupPasswordStoreProvider).delete,
            // The 7-day copy of earlier data (feature 010 FR-019a).
            ref.read(safetyCopyStoreProvider).delete,
            () => ref
                .read(backgroundSchedulerProvider)
                .cancel(autoBackupTaskName),
            () => ref
                .read(backgroundSchedulerProvider)
                .cancel(backgroundBackupTaskName),
            if (ref.read(driveAvailableProvider))
              ref.read(accountAuthProvider).signOut,
          ]) {
            try {
              await step();
            } on Object {
              // Never blocks the erase.
            }
          }
        },
        afterErase: () {
          ref.read(lockSessionProvider.notifier).reset();
          ref.invalidate(bootstrapProvider);
        },
        // The widget shows "Open DailyTrack" again (feature 008 R19).
        refreshGlance: () => ref.read(glanceRefresherProvider).refreshNow(),
      ),
    ),
    // After a restore: reschedule and rerun app-open work (feature 008
    // research R8). Core never imports lib/app/, so it is bound here.
    restoreAftermathProvider.overrideWith(bindRestoreAftermath),
    ...expenseOverrides(),
    ...habitOverrides(),
  ];
}
// coverage:ignore-end

/// The ad service for this moment (feature 009 research R5): AdMob while
/// ads are allowed, otherwise `NoAdsService`. When a Pro purchase turns ads
/// off, the AdMob service is disposed and every ad slot collapses. A new
/// AdMob service starts itself; it still requests nothing until consent
/// allows ads.
AdService bindAdService(Ref ref) {
  if (!ref.watch(adsAllowedProvider)) return const NoAdsService();
  final service = AdMobAdService(
    consent: ref.watch(consentServiceProvider),
    ids: ref.watch(adUnitIdsProvider),
    coordinator: ref.watch(interstitialCoordinatorProvider),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  unawaited(service.init());
  return service;
}

/// What runs after a restore (feature 008 research R8, R18, R19): clear
/// every notification, rerun the app-open work (it reschedules reminders),
/// then the daily summary and the widget. A failing step never fails the
/// restore or skips the later steps.
Future<void> Function() bindRestoreAftermath(Ref ref) => () async {
  for (final step in <Future<void> Function()>[
    () => ref.read(notificationServiceProvider).cancelAll(),
    () => ref.read(appOpenRunnerProvider).run(),
    () => ref.read(dailySummarySchedulerProvider).reschedule(),
    () => ref.read(glanceRefresherProvider).refreshNow(),
  ]) {
    try {
      await step();
    } on Object {
      // Best effort; the next app open reschedules again.
    }
  }
};
