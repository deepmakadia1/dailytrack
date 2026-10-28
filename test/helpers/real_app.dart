import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/network_state_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/account/presentation/account_feature_ui.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/habit/habit_bindings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'backup_fakes.dart';
import 'fakes.dart';
import 'mutable_clock.dart';

/// Pumps the whole app over a REAL in-memory database with the production
/// Expense and Habit bindings (DSH-01 AC1, feature 006 T030). Device-only
/// services stay fakes and ads stay off (`NoAdsService`). The app opens on
/// Home with onboarding treated as done.
Future<void> pumpRealDbApp(
  WidgetTester tester, {
  required AppDatabase db,
  required MutableClock clock,
  Size size = const Size(412, 915),
  List<Override> overrides = const [],
  bool migrateAuthMode = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final registry = ModuleRegistry(registeredModules);
  // As SYS-01 does before routing (feature 011 research R2). A test that
  // times the first screen runs it while seeding and passes false.
  if (migrateAuthMode) {
    await tester.runAsync(
      () => SettingsRepositoryImpl(
        db,
        knownModuleIds: registry.ids,
      ).migrateAuthMode(),
    );
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWith(
          (ref) => SettingsRepositoryImpl(db, knownModuleIds: registry.ids),
        ),
        bootstrapProvider.overrideWith(
          () => FakeBootstrap(results: const [BootstrapReady(Routes.home)]),
        ),
        clockProvider.overrideWithValue(clock),
        adServiceProvider.overrideWithValue(const NoAdsService()),
        notificationPermissionProvider.overrideWithValue(
          FakeNotificationPermission(),
        ),
        moduleRegistryProvider.overrideWithValue(registry),
        textSharerProvider.overrideWithValue(FakeTextSharer()),
        featureGateProvider.overrideWithValue(FakeFeatureGate()),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(),
        ),
        debugToolsAvailableProvider.overrideWithValue(false),
        backgroundSchedulerProvider.overrideWithValue(
          FakeBackgroundScheduler(),
        ),
        imageSharerProvider.overrideWithValue(FakeImageSharer()),
        // SET-01's account card (feature 011) without Google.
        accountUiProvider.overrideWithValue(const AccountFeatureUi()),
        accountAuthProvider.overrideWithValue(FakeAccountAuth()),
        networkStateSourceProvider.overrideWithValue(FakeNetworkStateSource()),
        ...expenseOverrides(),
        ...habitOverrides(),
        ...overrides,
      ],
      child: const DailyTrackApp(),
    ),
  );
}

/// Lets real database work (and the streams it feeds) finish, then renders
/// the result. Bounded, so a looping animation can never hang the test.
Future<void> settleRealDb(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}
