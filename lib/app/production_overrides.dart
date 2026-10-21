import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/flavor.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/background/workmanager_background_scheduler.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/feature_gate/data/drift_feature_gate.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/local_notification_service.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/security/data/flutter_secure_key_value_store.dart';
import 'package:dailytrack/core/security/data/local_auth_biometric_authenticator.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/habit/habit_bindings.dart';
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
    settingsRepositoryProvider.overrideWith(
      (ref) => SettingsRepositoryImpl(
        ref.watch(appDatabaseProvider),
        knownModuleIds: registry.ids,
      ),
    ),
    // Feature 003: notifications, background jobs, unlocks and the feature
    // gate (research R10, R13, R15).
    notificationServiceProvider.overrideWith(
      (ref) => LocalNotificationService((channel) {
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
        };
      }, ref.watch(timeZoneSourceProvider)),
    ),
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
        resetLock: () => ref.read(lockServiceProvider).reset(),
        afterErase: () {
          ref.read(lockSessionProvider.notifier).reset();
          ref.invalidate(bootstrapProvider);
        },
      ),
    ),
    ...expenseOverrides(),
    ...habitOverrides(),
  ];
}
// coverage:ignore-end
