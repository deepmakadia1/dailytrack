import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Provider container over a real database, for UNIT tests only (never
/// widget tests). Binds the providers that throw unless overridden.
ProviderContainer makeRealContainer(
  AppDatabase db, {
  ModuleRegistry? registry,
  AdService? ads,
  NotificationService? notifications,
  List<Override> overrides = const [],
}) {
  final reg = registry ?? ModuleRegistry(registeredModules);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      settingsRepositoryProvider.overrideWith(
        (ref) => SettingsRepositoryImpl(db, knownModuleIds: reg.ids),
      ),
      moduleRegistryProvider.overrideWithValue(reg),
      adServiceProvider.overrideWithValue(ads ?? const NoAdsService()),
      notificationServiceProvider.overrideWithValue(
        notifications ?? FakeNotificationService(),
      ),
      backgroundSchedulerProvider.overrideWithValue(FakeBackgroundScheduler()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}
