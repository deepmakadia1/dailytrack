import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_permission.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:dailytrack/features/premium/presentation/rewarded_unlock_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/fakes.dart';
import '../features/habit/fakes.dart';
import 'backup_fakes.dart';
import 'fakes.dart';

/// Pumps the whole app with fakes only (Constitution IV): fake settings,
/// fake bootstrap, `NoAdsService`, a fake notification permission, and a
/// database provider that fails loudly if anything touches it.
/// Expense repositories default to [ExpenseFakes.empty] (one Cash account),
/// the clock to [fakeNow], and sharing to a recording [FakeTextSharer];
/// pass [expense] or [sharer] to inspect or seed them.
/// The feature gate defaults to a [FakeFeatureGate] with everything locked,
/// notifications to a recording [FakeNotificationService], and developer
/// tools to off (feature 003 T028); pass [gate] or [notifications] to
/// inspect them, or override the providers. Habit repositories default to an
/// empty [HabitFakes] on the expense clock, and image sharing to a
/// recording [FakeImageSharer] (feature 005 T032).
/// Returns the settings fake so tests can inspect writes.
Future<FakeSettingsRepository> pumpTestApp(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
  FakeBootstrap? bootstrap,
  AdService? ads,
  RewardedUnlockPresenter? rewardedPresenter,
  FakeProStore? proStore,
  NotificationPermission? notif,
  ModuleRegistry? registry,
  ExpenseFakes? expense,
  FakeTextSharer? sharer,
  FakeFeatureGate? gate,
  FakeNotificationService? notifications,
  FakeBackgroundScheduler? background,
  HabitFakes? habit,
  FakeImageSharer? imageSharer,
  FakeExternalLauncher? launcher,
  FakeAppReviewService? review,
  FakeAppInfoSource? appInfo,
  TestLock? lock,
  FakeSecureScreenService? secureScreen,
  FakeAppResetService? reset,
  FakeGlanceRefresher? glance,
  FakeAccountAuth? accountAuth,
  FakeAccountRestore? accountRestore,
  int androidSdk = 34,
  bool debugTools = false,
  List<Override> overrides = const [],
  bool settle = true,
}) async {
  final repo = settings ?? FakeSettingsRepository();
  final expenseFakes = expense ?? ExpenseFakes.empty();
  final habitFakes = habit ?? HabitFakes(expenseFakes.clock);
  final testLock = lock ?? TestLock(settings: repo, clock: expenseFakes.clock);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        bootstrapProvider.overrideWith(
          () => bootstrap ?? FakeBootstrap.fromSettings(repo),
        ),
        adServiceProvider.overrideWithValue(ads ?? const NoAdsService()),
        // Feature 009: Google Play Billing is a fake; pass [proStore] to
        // script purchases.
        proStoreProvider.overrideWithValue(proStore ?? FakeProStore()),
        // The real PRM-02 sheet over the (fake) ad service (feature 009).
        rewardedUnlockPresenterProvider.overrideWithValue(
          rewardedPresenter ?? const PremiumRewardedUnlockPresenter(),
        ),
        notificationPermissionProvider.overrideWithValue(
          notif ?? FakeNotificationPermission(),
        ),
        moduleRegistryProvider.overrideWithValue(
          registry ?? ModuleRegistry(registeredModules),
        ),
        appDatabaseProvider.overrideWith(
          (ref) => throw StateError('widget tests must not touch the database'),
        ),
        ...expenseFakes.overrides,
        textSharerProvider.overrideWithValue(sharer ?? FakeTextSharer()),
        featureGateProvider.overrideWithValue(gate ?? FakeFeatureGate()),
        notificationServiceProvider.overrideWithValue(
          notifications ?? FakeNotificationService(),
        ),
        debugToolsAvailableProvider.overrideWithValue(debugTools),
        backgroundSchedulerProvider.overrideWithValue(
          background ?? FakeBackgroundScheduler(),
        ),
        ...habitFakes.overrides,
        imageSharerProvider.overrideWithValue(imageSharer ?? FakeImageSharer()),
        // SET-01 support ports never reach the platform in widget tests
        // (feature 007); pass [launcher], [review], or [appInfo] to
        // inspect them.
        appInfoSourceProvider.overrideWithValue(appInfo ?? FakeAppInfoSource()),
        deviceInfoSourceProvider.overrideWithValue(
          FakeDeviceInfoSource(sdkInt: androidSdk),
        ),
        appReviewServiceProvider.overrideWithValue(
          review ?? FakeAppReviewService(),
        ),
        externalLauncherProvider.overrideWithValue(
          launcher ?? FakeExternalLauncher(),
        ),
        // App lock (feature 007): the real lock service over in-memory
        // storage; pass [lock] to seed a PIN or inspect it.
        lockServiceProvider.overrideWithValue(testLock.service),
        secureScreenServiceProvider.overrideWithValue(
          secureScreen ?? FakeSecureScreenService(),
        ),
        appResetServiceProvider.overrideWithValue(
          reset ?? FakeAppResetService(),
        ),
        // The widget refresher reads the database (feature 008).
        glanceRefresherProvider.overrideWithValue(
          glance ?? FakeGlanceRefresher(),
        ),
        // Feature 010: Google sign-in and the no-backup device ID file.
        accountAuthProvider.overrideWithValue(accountAuth ?? FakeAccountAuth()),
        deviceIdFileProvider.overrideWithValue(FakeDeviceIdFile()),
        accountRestoreProvider.overrideWithValue(
          accountRestore ?? FakeAccountRestore(settings: repo),
        ),
        accountUiProvider.overrideWithValue(const AccountFeatureUi()),
        ...overrides,
      ],
      child: const DailyTrackApp(),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return repo;
}

/// Simulates an app restart: disposes the widget tree and provider container,
/// then pumps the app again over the same [settings] instance.
Future<FakeSettingsRepository> restartTestApp(
  WidgetTester tester, {
  required FakeSettingsRepository settings,
  TestLock? lock,
  NotificationPermission? notif,
  ModuleRegistry? registry,
  ExpenseFakes? expense,
  HabitFakes? habit,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
  return await pumpTestApp(
    tester,
    settings: settings,
    notif: notif,
    registry: registry,
    expense: expense,
    habit: habit,
    lock: lock,
    overrides: overrides,
  );
}

/// Scrolls SET-01 until [finder] is built and on screen. SET-01 is a lazy
/// list and the premium card (feature 009) leads it, so lower rows are not
/// built until scrolled to.
Future<void> scrollSettingsTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('settings_list')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
