import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/core/account/data/no_backup_device_id_store.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/ads/domain/rewarded_outcome.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_permission.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/notifications/time_zone_source.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/domain/biometric_authenticator.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:dailytrack/core/security/domain/secure_key_value_store.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/widget/domain/home_widget_bridge.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

/// In-memory [SettingsRepository] for widget tests (Constitution IV: widget
/// tests use fake repositories). Validates like the real one, records calls,
/// and can be shared across `restartTestApp` to simulate persistence.
class FakeSettingsRepository implements SettingsRepository {
  new({
    AppSettings initial = const AppSettings(),
    this.knownModuleIds = const ['expense', 'habit'],
    this.failNextCompleteOnboarding = false,
  }) : _settings = initial;

  final List<String> knownModuleIds;

  /// When true, the next [completeOnboarding] throws and then resets.
  bool failNextCompleteOnboarding;

  AppSettings _settings;
  final _changes = StreamController<AppSettings>.broadcast();
  final Map<String, int> calls = {};
  final Set<String> _seeded = {};

  AppSettings get current => _settings;

  /// Number of write calls of any kind.
  int get writeCount => calls.entries
      .where((e) => e.key != 'load' && e.key != 'isSeeded')
      .fold(0, (sum, e) => sum + e.value);

  /// Called with each write's method name, to check write order.
  void Function(String name)? onWrite;

  void _count(String name) {
    calls[name] = (calls[name] ?? 0) + 1;
    if (name != 'load' && name != 'isSeeded') onWrite?.call(name);
  }

  /// Replaces the settings as another part of the app would (e.g. a Pro
  /// purchase), and notifies watchers.
  void replace(AppSettings next) => _set(next);

  void _set(AppSettings next) {
    _settings = next;
    _changes.add(next);
  }

  void _checkModules(List<String> enabled) {
    if (enabled.where(knownModuleIds.contains).isEmpty) {
      throw const LastModuleError();
    }
  }

  @override
  Future<AppSettings> load() async {
    _count('load');
    return _settings;
  }

  @override
  Stream<AppSettings> watch() => Stream<AppSettings>.multi((controller) {
    controller.add(_settings);
    final sub = _changes.stream.listen(controller.add);
    controller.onCancel = sub.cancel;
  });

  @override
  Future<void> setLocale(String? languageCode) async {
    _count('setLocale');
    if (languageCode != null &&
        !supportedLanguageCodes.contains(languageCode)) {
      return;
    }
    _set(_settings.copyWith(locale: languageCode));
  }

  @override
  Future<void> setCurrency(String code) async {
    _count('setCurrency');
    _set(_settings.copyWith(currencyCode: code));
  }

  @override
  Future<void> setModules({
    required List<String> order,
    required List<String> enabled,
  }) async {
    _count('setModules');
    _checkModules(enabled);
    _set(_settings.copyWith(moduleOrder: order, enabledModules: enabled));
  }

  @override
  Future<void> completeOnboarding(OnboardingChoices choices) async {
    _count('completeOnboarding');
    if (failNextCompleteOnboarding) {
      failNextCompleteOnboarding = false;
      throw StateError('simulated save failure');
    }
    _checkModules(choices.enabledModules);
    _set(
      _settings.copyWith(
        locale: choices.locale,
        currencyCode: choices.currencyCode,
        moduleOrder: choices.moduleOrder,
        enabledModules: choices.enabledModules,
        onboardingDone: true,
      ),
    );
  }

  @override
  Future<bool> isSeeded(String seederId) async {
    _count('isSeeded');
    return _seeded.contains(seederId);
  }

  @override
  Future<void> markSeeded(String seederId) async {
    _count('markSeeded');
    _seeded.add(seederId);
  }

  final Map<String, String> moduleState = {};

  @override
  Future<void> setNotificationsEnabled({required bool enabled}) async {
    _count('setNotificationsEnabled');
    _set(_settings.copyWith(notificationsEnabled: enabled));
  }

  @override
  Future<void> setBudgetAlertsEnabled({required bool enabled}) async {
    _count('setBudgetAlertsEnabled');
    _set(_settings.copyWith(budgetAlertsEnabled: enabled));
  }

  @override
  Future<void> setHabitRemindersEnabled({required bool enabled}) async {
    _count('setHabitRemindersEnabled');
    _set(_settings.copyWith(habitRemindersEnabled: enabled));
  }

  @override
  Future<void> setDebugUnlockAll({required bool enabled}) async {
    _count('setDebugUnlockAll');
    _set(_settings.copyWith(debugUnlockAll: enabled));
  }

  @override
  Future<void> raiseLatestSeenAt(int utcMs) async {
    final current = _settings.latestSeenAt;
    if (current != null && current >= utcMs) return;
    _count('raiseLatestSeenAt');
    _set(_settings.copyWith(latestSeenAt: utcMs));
  }

  @override
  Future<String?> readModuleState(String key) async => moduleState[key];

  @override
  Future<void> writeModuleState(String key, String value) async {
    _count('writeModuleState');
    moduleState[key] = value;
  }

  @override
  Future<void> setDailyInsight({
    required String dateKey,
    required String ruleId,
  }) async {
    _count('setDailyInsight');
    _set(_settings.copyWith(dailyInsightDate: dateKey, dailyInsightId: ruleId));
  }

  @override
  Future<void> setHomeComingSoonDismissed({required bool dismissed}) async {
    _count('setHomeComingSoonDismissed');
    _set(_settings.copyWith(homeComingSoonDismissed: dismissed));
  }

  // T3.1 setters (feature 007 T007): same validation as the real repository.

  @override
  Future<void> setThemeMode(String mode) async {
    _count('setThemeMode');
    if (!themeModeIds.contains(mode)) return;
    _set(_settings.copyWith(themeMode: mode));
  }

  @override
  Future<void> setSelectedTheme(String id) async {
    _count('setSelectedTheme');
    if (!colorThemeIds.contains(id)) return;
    _set(_settings.copyWith(selectedTheme: id));
  }

  @override
  Future<void> setFontSize(String size) async {
    _count('setFontSize');
    if (!fontSizeIds.contains(size)) return;
    _set(_settings.copyWith(fontSize: size));
  }

  @override
  Future<void> setFirstDayOfWeek(int day) async {
    _count('setFirstDayOfWeek');
    if (!firstDayOfWeekOptions.contains(day)) return;
    _set(_settings.copyWith(firstDayOfWeek: day));
  }

  @override
  Future<void> setDateFormat(String format) async {
    _count('setDateFormat');
    if (!dateFormatIds.contains(format)) return;
    _set(_settings.copyWith(dateFormat: format));
  }

  @override
  Future<void> setDailySummaryTime(String hhmm) async {
    _count('setDailySummaryTime');
    if (!isValidTimeOfDay(hhmm)) return;
    _set(_settings.copyWith(dailySummaryTime: hhmm));
  }

  @override
  Future<void> setLockEnabled({required bool enabled}) async {
    _count('setLockEnabled');
    _set(_settings.copyWith(lockEnabled: enabled));
  }

  @override
  Future<void> setBiometricEnabled({required bool enabled}) async {
    _count('setBiometricEnabled');
    _set(_settings.copyWith(biometricEnabled: enabled));
  }

  @override
  Future<void> setLockAfterSeconds(int seconds) async {
    _count('setLockAfterSeconds');
    if (!lockAfterOptions.contains(seconds)) return;
    _set(_settings.copyWith(lockAfterSeconds: seconds));
  }

  @override
  Future<void> setHideInRecents({required bool enabled}) async {
    _count('setHideInRecents');
    _set(_settings.copyWith(hideInRecents: enabled));
  }

  @override
  Future<void> setLastBackup({
    required int at,
    required BackupLocation location,
    required int sizeBytes,
  }) async {
    _count('setLastBackup');
    _set(
      _settings.copyWith(
        lastBackupAt: at,
        lastBackupLocation: location,
        lastBackupSizeBytes: sizeBytes,
      ),
    );
  }

  @override
  Future<void> setBackupEncrypt({required bool enabled}) async {
    _count('setBackupEncrypt');
    _set(_settings.copyWith(backupEncrypt: enabled));
  }

  @override
  Future<void> setBackupIncludeReceipts({required bool enabled}) async {
    _count('setBackupIncludeReceipts');
    _set(_settings.copyWith(backupIncludeReceipts: enabled));
  }

  @override
  Future<void> setBackupAccountEmail(String? email) async {
    _count('setBackupAccountEmail');
    _set(_settings.copyWith(backupAccountEmail: email));
  }

  @override
  Future<void> setAutoBackup({
    required AutoBackupFrequency frequency,
    required bool wifiOnly,
  }) async {
    _count('setAutoBackup');
    _set(
      _settings.copyWith(
        autoBackupFrequency: frequency,
        autoBackupWifiOnly: wifiOnly,
      ),
    );
  }

  @override
  Future<void> setLastAutoBackupAt(int at) async {
    _count('setLastAutoBackupAt');
    _set(_settings.copyWith(lastAutoBackupAt: at));
  }

  @override
  Future<void> setAutoBackupFailures({
    required int failures,
    required bool notified,
  }) async {
    _count('setAutoBackupFailures');
    _set(
      _settings.copyWith(
        autoBackupFailures: failures,
        autoBackupFailureNotified: notified,
      ),
    );
  }

  @override
  Future<void> setShowDataOnWidget({required bool enabled}) async {
    _count('setShowDataOnWidget');
    _set(_settings.copyWith(showDataOnWidget: enabled));
  }

  @override
  Future<void> setDeviceTimeZoneId(String id) async {
    _count('setDeviceTimeZoneId');
    _set(_settings.copyWith(deviceTimeZoneId: id));
  }

  @override
  Future<void> setAdsInstallAtIfMissing(int utcMs) async {
    _count('setAdsInstallAtIfMissing');
    if (_settings.adsInstallAt != null) return;
    _set(_settings.copyWith(adsInstallAt: utcMs));
  }

  @override
  Future<void> recordInterstitialShown({
    required int at,
    required String dayKey,
    required int countToday,
  }) async {
    _count('recordInterstitialShown');
    _set(
      _settings.copyWith(
        adsLastInterstitialAt: at,
        adsInterstitialDay: dayKey,
        adsInterstitialsToday: countToday,
      ),
    );
  }

  @override
  Future<void> setAdsLastSessionDay(String dayKey) async {
    _count('setAdsLastSessionDay');
    _set(_settings.copyWith(adsLastSessionDay: dayKey));
  }

  @override
  Future<void> setProState({
    required bool owned,
    required int notOwnedStreak,
    required bool pending,
    bool removalPending = false,
  }) async {
    _count('setProState');
    _set(
      _settings.copyWith(
        removeAdsPurchased: owned,
        proNotOwnedStreak: notOwnedStreak,
        proPurchasePending: pending,
        proRemovalPending: removalPending,
      ),
    );
  }

  @override
  Future<void> setRewardedCounts({
    required String dayKey,
    required Map<String, int> counts,
  }) async {
    _count('setRewardedCounts');
    _set(_settings.copyWith(rewardedDay: dayKey, rewardedCounts: counts));
  }

  @override
  Future<void> setAccount(AccountProfile? profile) async {
    _count('setAccount');
    _set(
      _settings.copyWith(
        backupAccountEmail: profile?.email,
        accountDisplayName: profile?.displayName,
        accountPhotoUrl: profile?.photoUrl,
      ),
    );
  }

  @override
  Future<void> setDeviceIdCopy(String id) async {
    _count('setDeviceIdCopy');
    _set(_settings.copyWith(deviceId: id));
  }

  @override
  Future<void> setBackedUpChangeCounter(int value) async {
    _count('setBackedUpChangeCounter');
    _set(_settings.copyWith(backedUpChangeCounter: value));
  }

  @override
  Future<void> setLastBackgroundBackupAt(int? at) async {
    _count('setLastBackgroundBackupAt');
    _set(_settings.copyWith(lastBackgroundBackupAt: at));
  }

  @override
  Future<void> setLastKnownDriveBackup({
    required int? at,
    required String? deviceId,
  }) async {
    _count('setLastKnownDriveBackup');
    _set(
      _settings.copyWith(
        lastKnownDriveBackupAt: at,
        lastKnownDriveBackupDeviceId: deviceId,
      ),
    );
  }

  @override
  Future<void> setFinishSetupPending({required bool pending}) async {
    _count('setFinishSetupPending');
    _set(_settings.copyWith(finishSetupPending: pending));
  }

  @override
  Future<void> setAutoBackupPause({
    required bool paused,
    required bool notified,
  }) async {
    _count('setAutoBackupPause');
    _set(
      _settings.copyWith(
        autoBackupPausedByConflict: paused,
        autoBackupPauseNotified: notified,
      ),
    );
  }

  @override
  Future<void> resetAdCounters({required int installAt}) async {
    _count('resetAdCounters');
    _set(
      _settings.copyWith(
        adsInstallAt: installAt,
        adsLastInterstitialAt: null,
        adsInterstitialDay: null,
        adsInterstitialsToday: 0,
      ),
    );
  }
}

/// Stand-in for `bootstrapProvider` in widget tests: no database involved.
/// Either replays a queue of `results` (each `retry()` takes the next one) or
/// derives the first route from [settings] with the real startup rule.
class FakeBootstrap extends Bootstrap {
  new({List<BootstrapResult>? results, this.settings})
    : _results = results == null ? null : List.of(results);

  factory fromSettings(FakeSettingsRepository settings) =>
      FakeBootstrap(settings: settings);

  final List<BootstrapResult>? _results;
  final FakeSettingsRepository? settings;
  int runs = 0;

  Future<BootstrapResult> _next() async {
    runs++;
    final queue = _results;
    final current = settings?.current ?? const AppSettings();
    final result = queue == null
        ? BootstrapReady(initialLocationFor(current))
        : (queue.length > 1 ? queue.removeAt(0) : queue.first);
    // Like the real startup: a cold start with app lock on begins locked.
    // After a microtask, as the real one does, since a provider may not
    // change another while it builds.
    await Future<void>.microtask(() {});
    if (result is BootstrapReady) {
      ref
          .read(lockSessionProvider.notifier)
          .start(lockEnabled: current.onboardingDone && current.lockEnabled);
    }
    return result;
  }

  @override
  Future<BootstrapResult> build() => _next();

  @override
  Future<void> retry() async {
    state = const AsyncLoading();
    state = AsyncData(await _next());
  }
}

class FakeNotificationPermission implements NotificationPermission {
  new({this.result = true, this.throws = false});

  final bool result;

  /// Simulates a broken plugin. The real implementation never throws, but
  /// onboarding must survive it anyway.
  final bool throws;
  int requests = 0;

  @override
  Future<bool> request() async {
    requests++;
    if (throws) throw StateError('permission plugin failed');
    return result;
  }
}

class MockAdService extends Mock implements AdService;

/// Scripted ad consent (feature 009). [stored] is what the SDK remembers from
/// earlier sessions; [gatherResult] is what a fresh check (and form) gives.
class FakeConsentService implements ConsentService {
  new({
    this.stored = false,
    this.gatherResult = ConsentResult.none,
    this.showsForm = false,
    this.throwOnCheck = false,
    bool privacyRequired = false,
  }) : _privacy = privacyRequired;

  bool stored;
  ConsentResult gatherResult;

  /// [gather] calls `beforeForm` first, as when a form must show.
  bool showsForm;
  bool throwOnCheck;
  int canRequestCalls = 0;
  int gatherCalls = 0;
  int beforeFormCalls = 0;
  int privacyFormCalls = 0;
  bool _privacy;
  final _privacyChanges = StreamController<bool>.broadcast();

  @override
  Future<bool> canRequestAds() async {
    canRequestCalls++;
    if (throwOnCheck) throw StateError('consent down');
    return stored;
  }

  @override
  Future<ConsentResult> gather({
    required Future<void> Function() beforeForm,
    required Duration timeout,
  }) async {
    gatherCalls++;
    if (throwOnCheck) throw StateError('consent down');
    if (showsForm) {
      beforeFormCalls++;
      await beforeForm();
    }
    stored = gatherResult.canRequestAds;
    setPrivacyRequired(required: gatherResult.privacyOptionsRequired);
    return gatherResult;
  }

  void setPrivacyRequired({required bool required}) {
    _privacy = required;
    _privacyChanges.add(required);
  }

  @override
  Stream<bool> get privacyOptionsRequired async* {
    yield _privacy;
    yield* _privacyChanges.stream;
  }

  @override
  Future<void> showPrivacyOptionsForm() async => privacyFormCalls++;

  int resetCalls = 0;

  @override
  Future<void> resetForDebug() async => resetCalls++;
}

/// A scripted PRM-02 (feature 009): records requests and, when [earn] is
/// true, runs the grant as an earned reward would.
class FakeRewardedUnlockPresenter implements RewardedUnlockPresenter {
  new({this.earn = true, this.runGrant = false});

  bool earn;

  /// Runs the request's grant on an earned reward. Off by default, since
  /// the default grant needs the unlocks store.
  bool runGrant;
  final List<RewardedUnlockRequest> requests = [];

  @override
  Future<bool> present(
    BuildContext context,
    RewardedUnlockRequest request,
  ) async {
    requests.add(request);
    if (earn && runGrant) await request.grant();
    return earn;
  }
}

/// Google Play Billing for Pro, scripted (feature 009). [purchases] pushes
/// purchase updates as the store would.
class FakeProStore implements ProStore {
  new({
    this.available = true,
    this.product = const StoreProduct(
      id: proProductId,
      title: 'DailyTrack Pro',
      price: '₹299.00',
    ),
    this.ownership = OwnershipCheck.notOwned,
  });

  bool available;
  StoreProduct? product;
  OwnershipCheck ownership;
  final purchases = StreamController<List<StorePurchase>>.broadcast();
  final List<StoreProduct> bought = [];
  final List<StorePurchase> completed = [];
  int ownershipQueries = 0;
  int listens = 0;

  @override
  Stream<List<StorePurchase>> get purchaseUpdates {
    listens++;
    return purchases.stream;
  }

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<StoreProduct?> loadProduct() async => available ? product : null;

  @override
  Future<void> buy(StoreProduct product) async => bought.add(product);

  @override
  Future<OwnershipCheck> queryOwnership() async {
    ownershipQueries++;
    return available ? ownership : OwnershipCheck.unavailable;
  }

  @override
  Future<void> complete(StorePurchase purchase) async =>
      completed.add(purchase);

  /// Sends one Pro purchase update.
  void emit(StorePurchaseStatus status, {bool needsCompletion = false}) =>
      purchases.add([
        StorePurchase(
          productId: proProductId,
          status: status,
          needsCompletion: needsCompletion,
        ),
      ]);
}

/// A loaded ad of a fixed [height] (feature 009 widget tests).
class FakeAdView implements AdView {
  new({this.height = 60});

  @override
  final double height;
  int disposeCalls = 0;

  @override
  Widget build(BuildContext context) =>
      SizedBox(key: const Key('fake_ad_view'), height: height);

  @override
  void dispose() => disposeCalls++;
}

/// An [AdService] that hands out [FakeAdView]s (or null) and records loads,
/// without any ads SDK (constitution 1.0.3, IV).
class FakeAdService implements AdService {
  new({this.enabled = true, this.view, this.bannerView});

  /// What the next [prepareRewarded] answers; null never answers (PRM-02's
  /// 8 s timeout).
  bool? rewardedReady = true;

  /// Outcomes of the next [showRewarded] calls, in order; then `earned`.
  final List<RewardedOutcome> rewardedOutcomes = [];
  int prepareCalls = 0;
  int rewardedShows = 0;

  final bool enabled;

  /// What every load returns; null means a failed load.
  FakeAdView? view;

  /// What banner loads return instead of [view], when set (a real adaptive
  /// banner is at most 15% of the screen height).
  FakeAdView? bannerView;
  int bannerLoads = 0;
  int nativeLoads = 0;

  /// Every interstitial trigger, in order.
  final List<AdTrigger> triggers = [];

  /// Runs on each trigger, e.g. to see which screen is showing then.
  void Function(AdTrigger trigger)? onTrigger;

  @override
  bool get adsEnabled => enabled;

  @override
  Stream<bool> get adsEnabledStream => Stream.value(enabled);

  @override
  Future<AdView?> loadBanner({required double width}) async {
    bannerLoads++;
    return bannerView ?? view;
  }

  @override
  Future<AdView?> loadNative(
    NativePlacement placement,
    NativeAdLook look,
  ) async {
    nativeLoads++;
    return view;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {
    triggers.add(trigger);
    onTrigger?.call(trigger);
  }

  @override
  Future<bool> prepareRewarded() {
    prepareCalls++;
    final ready = rewardedReady;
    return ready == null ? Completer<bool>().future : Future.value(ready);
  }

  /// Like the SDK: [onEarned] runs only for an earned reward, before the
  /// outcome completes.
  @override
  Future<RewardedOutcome> showRewarded(
    FeatureKey key, {
    required Future<void> Function() onEarned,
  }) async {
    rewardedShows++;
    final outcome = rewardedOutcomes.isEmpty
        ? RewardedOutcome.earned
        : rewardedOutcomes.removeAt(0);
    if (outcome == RewardedOutcome.earned) await onEarned();
    return outcome;
  }

  @override
  Future<void> dispose() async {}
}

/// Configurable [TrackerModule] that records enable/disable calls
/// (used by T047, T086 and T111).
class FakeTrackerModule extends TrackerModule {
  new({
    required this.id,
    String? rootPath,
    this._routes,
    this.name,
    this.icon = Icons.extension_outlined,
    this.selectedIcon = Icons.extension,
    this.backgroundTasks = const {},
    this.quickAdds = const [],
    this.sections = const [],
    this.insightSource,
    this.badge,
    this.cardHeight = 0,
  }) : rootPath = rootPath ?? '/$id';

  /// Extra height under the card text, so Home can scroll in tests.
  final double cardHeight;

  final List<QuickAddAction> quickAdds;
  final List<DashboardSection> sections;
  final InsightSource? insightSource;

  /// The app bar badge; null shows none.
  final Widget? badge;

  @override
  final Map<String, BackgroundTask> backgroundTasks;

  @override
  final String id;

  final String? name;

  @override
  final String rootPath;

  @override
  final IconData icon;

  @override
  final IconData selectedIcon;

  final List<RouteBase>? _routes;
  int enableCalls = 0;
  int disableCalls = 0;

  String get label => name ?? 'Module $id';

  @override
  String displayName(BuildContext context) => label;

  @override
  String tabLabel(BuildContext context) => label;

  @override
  List<RouteBase> get routes =>
      _routes ??
      [
        GoRoute(
          path: rootPath,
          builder: (context, state) => Scaffold(body: Text('$label screen')),
        ),
      ];

  @override
  Widget dashboardCard(BuildContext context) => cardHeight == 0
      ? Text('$label card')
      : Column(
          children: [
            Text('$label card'),
            SizedBox(height: cardHeight),
          ],
        );

  @override
  List<QuickAddAction> quickAddActions() => quickAdds;

  @override
  List<DashboardSection> dashboardSections() => sections;

  @override
  InsightSource? insights() => insightSource;

  @override
  Widget? appBarBadge(BuildContext context) => badge;

  @override
  BackupSection? backupSection() => null;

  @override
  List<Seeder> get seeders => const [];

  int appOpenCalls = 0;

  /// What [onAppOpen] does after counting; null does nothing.
  Future<void> Function()? onAppOpenBody;

  @override
  Future<void> onEnable(ProviderReader read) async => enableCalls++;

  @override
  Future<void> onDisable(ProviderReader read) async => disableCalls++;

  @override
  Future<void> onAppOpen(ProviderReader read) async {
    appOpenCalls++;
    await onAppOpenBody?.call();
  }

  /// SET-01 notification switches (feature 007 T019).
  int notificationSettingsChangedCalls = 0;

  @override
  Future<void> onNotificationSettingsChanged(ProviderReader read) async =>
      notificationSettingsChangedCalls++;

  /// Erase all data (feature 007 T019); [onEraseAllBody] may throw.
  int eraseAllCalls = 0;
  Future<void> Function()? onEraseAllBody;

  @override
  Future<void> onEraseAll(ProviderReader read) async {
    eraseAllCalls++;
    await onEraseAllBody?.call();
  }

  /// Actions offered to this module (feature 008 T016).
  final List<AppAction> actions = [];

  /// What [handleAction] returns.
  bool handles = false;

  /// Thrown by [handleAction] instead, when set.
  Error? handleError;

  @override
  Future<bool> handleAction(AppAction action, ProviderReader read) async {
    actions.add(action);
    if (handleError case final e?) throw e;
    return handles;
  }

  /// Fills the builder in [contributeGlance] (feature 008 T016).
  void Function(GlanceBuilder b, DateTime nowLocal)? glance;
  int glanceCalls = 0;

  @override
  Future<void> contributeGlance(
    GlanceBuilder b,
    ProviderReader read,
    DateTime nowLocal,
  ) async {
    glanceCalls++;
    glance?.call(b, nowLocal);
  }
}

/// Records shared text instead of opening the share sheet.
class FakeTextSharer implements TextSharer {
  final List<({String text, String? subject})> shared = [];

  @override
  Future<void> shareText(String text, {String? subject}) async =>
      shared.add((text: text, subject: subject));
}

/// Records shared images instead of opening the share sheet (feature 005
/// T027).
class FakeImageSharer implements ImageSharer {
  final List<({String fileName, Uint8List png, String? text})> shared = [];

  /// When set, [sharePng] throws it once.
  Exception? failNext;

  @override
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
  }) async {
    if (failNext case final e?) {
      failNext = null;
      throw e;
    }
    shared.add((fileName: fileName, png: png, text: text));
  }
}

/// [FeatureGate] with a settable answer per key; everything is locked by
/// default (feature 003 T028). Changes reach `watch` listeners at once.
class FakeFeatureGate implements FeatureGate {
  new({Map<FeatureKey, bool> unlocked = const {}}) : _unlocked = {...unlocked};

  final Map<FeatureKey, bool> _unlocked;
  final _changes = StreamController<void>.broadcast();

  void set(FeatureKey key, {required bool unlocked}) {
    _unlocked[key] = unlocked;
    _changes.add(null);
  }

  bool _value(FeatureKey key) => _unlocked[key] ?? false;

  @override
  Future<bool> isUnlocked(FeatureKey key) async => _value(key);

  @override
  Stream<bool> watch(FeatureKey key) => Stream<bool>.multi((c) {
    c.add(_value(key));
    final sub = _changes.stream
        .map((_) => _value(key))
        .distinct()
        .listen(c.add);
    c.onCancel = sub.cancel;
  });
}

/// Records notifications instead of showing them (feature 003 T028).
class FakeNotificationService implements NotificationService {
  new({this.allowed = true, this.payloadAtLaunch});

  /// What [canNotify] returns (the OS permission).
  bool allowed;

  /// What [launchPayload] returns.
  String? payloadAtLaunch;

  final List<AppNotification> shown = [];
  final List<String> cancelledTags = [];
  int initializeCalls = 0;
  final _taps = StreamController<String>.broadcast();
  final _actions = StreamController<NotificationActionEvent>.broadcast();

  /// Simulates the user tapping a notification while the app runs.
  void tap(String payload) => _taps.add(payload);

  /// Simulates a notification button tapped while the app runs (feature
  /// 008 R16).
  void tapAction(String actionId, String payload) => _actions.add(
    NotificationActionEvent(actionId: actionId, payload: payload),
  );

  @override
  Stream<NotificationActionEvent> get actions => _actions.stream;

  int requestExactCalls = 0;

  /// What [exactAllowed] becomes after [requestExactAlarms].
  bool grantExactOnRequest = false;

  @override
  Future<bool> requestExactAlarms() async {
    requestExactCalls++;
    if (grantExactOnRequest) exactAllowed = true;
    return exactAllowed;
  }

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<bool> canNotify() async => allowed;

  @override
  Future<void> show(AppNotification notification) async =>
      shown.add(notification);

  @override
  Future<void> cancelByTag(String tag) async {
    cancelledTags.add(tag);
    shown.removeWhere((n) => n.tag == tag);
  }

  int cancelAllCalls = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    shown.clear();
    scheduled.clear();
  }

  @override
  Future<String?> launchPayload() async => payloadAtLaunch;

  @override
  Stream<String> get taps => _taps.stream;

  // --- Scheduled notifications (feature 005 T025) ---

  /// Registered notifications by id; [schedule] replaces by id.
  final Map<int, ScheduledNotification> scheduled = {};

  /// Every id passed to [cancel], in order.
  final List<int> cancelled = [];

  /// What [canScheduleExact] returns.
  bool exactAllowed = true;

  /// What [refreshTimeZone] returns.
  bool zoneResolvable = true;
  int refreshTimeZoneCalls = 0;

  @override
  Future<void> schedule(ScheduledNotification notification) async =>
      scheduled[notification.notification.id] = notification;

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<bool> canScheduleExact() async => exactAllowed;

  @override
  Future<bool> refreshTimeZone() async {
    refreshTimeZoneCalls++;
    return zoneResolvable;
  }
}

// --- 007-settings-themes-app-lock: app lock ports ---

/// In-memory [SecureKeyValueStore] that can simulate unreadable storage.
class InMemorySecureStore implements SecureKeyValueStore {
  new({this.onWrite});

  final Map<String, String> values = {};
  final void Function(String key)? onWrite;

  /// Every read throws, like wiped Keystore keys after a device restore.
  bool failReads = false;

  /// Reads of this one key throw.
  String? failReadsOf;

  @override
  Future<String?> read(String key) async {
    if (failReads || key == failReadsOf) {
      throw StateError('secure storage unreadable');
    }
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
    onWrite?.call(key);
  }

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteWhere(bool Function(String key) test) async =>
      values.removeWhere((key, _) => test(key));
}

/// Fingerprint/face unlock with a settable availability and answer.
class FakeBiometricAuthenticator implements BiometricAuthenticator {
  BiometricAvailability available = BiometricAvailability.available;

  /// What the next prompt returns.
  bool result = true;

  /// Number of prompts shown.
  int prompts = 0;

  @override
  Future<BiometricAvailability> availability() async => available;

  @override
  Future<bool> authenticate(String localizedReason) async {
    prompts++;
    return result;
  }
}

/// The real [SecureLockService] over an in-memory store, fake biometrics
/// (unavailable by default, so no prompt opens unless a test asks), and a
/// fast hasher: widget tests exercise the real lockout rules.
class TestLock {
  new({required this.settings, Clock? clock})
    : clock = clock ?? const Clock(),
      biometrics = FakeBiometricAuthenticator()
        ..available = BiometricAvailability.none;

  final FakeSettingsRepository settings;
  final Clock clock;
  final InMemorySecureStore store = InMemorySecureStore();
  final FakeBiometricAuthenticator biometrics;

  late final PinHasher hasher = PinHasher(
    iterations: 1000,
    runner: (f) async => await f(),
  );

  late final SecureLockService service = SecureLockService(
    store: store,
    biometrics: biometrics,
    settings: settings,
    clock: clock,
    hasher: hasher,
  );

  /// Stores [pin] as the credential without touching settings; pair it
  /// with `AppSettings(lockEnabled: true)`.
  Future<void> seedPin(String pin) async {
    final record = await hasher.hash(pin);
    store.values[SecureLockService.pinKey] = jsonEncode(record.toJson());
  }

  bool get hasPin => store.values.containsKey(SecureLockService.pinKey);
}

/// Counts "Erase all data" runs; can fail like a broken database.
class FakeAppResetService implements AppResetService {
  int calls = 0;

  /// What the erase does to the app, e.g. clear settings (feature 010).
  void Function()? onErase;

  /// When set, the next run throws it once (nothing was deleted).
  Exception? failNext;

  @override
  Future<void> eraseAll() async {
    calls++;
    if (failNext case final e?) {
      failNext = null;
      throw e;
    }
    onErase?.call();
  }
}

/// Records FLAG_SECURE changes instead of touching the window.
class FakeSecureScreenService implements SecureScreenService {
  final List<bool> calls = [];

  bool get secure => calls.isNotEmpty && calls.last;

  @override
  Future<void> setSecure({required bool on}) async => calls.add(on);
}

// --- 007-settings-themes-app-lock: SET-01 support ports ---

/// A fixed installed version (SET-01 About).
class FakeAppInfoSource implements AppInfoSource {
  new({
    this.info = const AppInfo(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.midexcode.daily.track.dailytrack',
    ),
  });

  final AppInfo info;

  @override
  Future<AppInfo> load() async => info;
}

/// Fixed device facts for the feedback email.
/// The no-backup device ID file in memory (feature 010 research R4).
/// [unavailable] acts like a platform without the folder.
class FakeDeviceIdFile implements DeviceIdFile {
  String? value;
  bool unavailable = false;

  @override
  Future<String?> read() async => unavailable ? null : value;

  @override
  Future<void> write(String id) async {
    if (unavailable) throw StateError('no no-backup folder');
    value = id;
  }
}

class FakeDeviceInfoSource implements DeviceInfoSource {
  new({this.sdkInt = 34});

  final int sdkInt;

  @override
  Future<DeviceInfo> load() async => DeviceInfo(
    manufacturer: 'Google',
    model: 'Pixel 7',
    release: '14',
    sdkInt: sdkInt,
  );
}

/// Counts "Rate us" requests.
class FakeAppReviewService implements AppReviewService {
  int calls = 0;

  @override
  Future<void> rateApp() async => calls++;
}

/// Records launches instead of leaving the app.
class FakeExternalLauncher implements ExternalLauncher {
  /// What [email] returns; false simulates a phone without an email app.
  bool emailHandled = true;

  final List<({String to, String subject, String body})> emails = [];
  final List<Uri> urls = [];
  int notificationSettingsCalls = 0;

  @override
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  }) async {
    emails.add((to: to, subject: subject, body: body));
    return emailHandled;
  }

  @override
  Future<bool> openUrl(Uri uri) async {
    urls.add(uri);
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async {
    notificationSettingsCalls++;
    return true;
  }
}

/// Records daily background jobs instead of scheduling them (T028).
class FakeBackgroundScheduler implements BackgroundScheduler {
  final List<String> ensured = [];
  final List<String> cancelled = [];

  @override
  Future<void> ensureDaily(String uniqueName) async => ensured.add(uniqueName);

  /// Periodic jobs by name: period and network (feature 008).
  final Map<String, (Duration, NetworkRequirement)> periodic = {};

  @override
  Future<void> ensurePeriodic(
    String uniqueName, {
    required Duration every,
    NetworkRequirement network = NetworkRequirement.none,
  }) async {
    ensured.add(uniqueName);
    periodic[uniqueName] = (every, network);
  }

  /// One-off jobs by name: the network each waits for (feature 010).
  final Map<String, NetworkRequirement> oneOff = {};

  @override
  Future<void> enqueueOnce(
    String uniqueName, {
    NetworkRequirement network = NetworkRequirement.none,
  }) async {
    ensured.add(uniqueName);
    oneOff[uniqueName] = network;
  }

  @override
  Future<void> cancel(String uniqueName) async => cancelled.add(uniqueName);
}

/// Records shared files instead of opening the share sheet (feature 008).
class FakeFileSharer implements FileSharer {
  final shared = <String>[];

  @override
  Future<void> shareFile(String path, {required String mimeType}) async =>
      shared.add(path);
}

/// The system save and open dialogs (SET-02, feature 008): [saveResult]
/// false means the user cancelled; [picked] is what "Restore from file"
/// returns.
class FakeLocalBackupFiles implements LocalBackupFiles {
  bool saveResult = true;
  Uint8List? picked;
  final saved = <(String, Uint8List)>[];

  @override
  Future<bool> saveAs(Uint8List bytes, {required String suggestedName}) async {
    saved.add((suggestedName, bytes));
    return saveResult;
  }

  @override
  Future<Uint8List?> pick() async => picked;
}

/// The backup password in memory (feature 008 research R4).
class FakeBackupPasswordStore implements BackupPasswordStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String password) async => value = password;

  @override
  Future<void> delete() async => value = null;
}

/// The user's Drive app folder in memory (feature 008 research R10).
/// [failNext] makes the next call of any method throw. Uploads keep their
/// metadata like Drive's `appProperties` (feature 010).
class FakeDriveBackupStore implements DriveBackupStore {
  BackupFailure? failNext;
  final files = <DriveBackupEntry>[];
  final contents = <String, Uint8List>{};
  final deleted = <String>[];
  final uploads = <BackupMeta>[];

  /// Every call by name, to check that nothing reached Drive.
  final calls = <String>[];
  int _next = 0;

  /// Upload time for the next file (UTC ms); increases by one per upload.
  int clockMs = 1792540800000;

  /// Ids whose delete fails once.
  final failDeleteOf = <String>{};

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  /// Adds a backup as if another phone (or an older app) had made it.
  DriveBackupEntry seed({
    int? createdAt,
    BackupKind kind = BackupKind.manual,
    BackupMeta? meta,
    String? device = 'Test phone',
  }) {
    final entry = DriveBackupEntry(
      id: 'f${_next++}',
      name: 'dailytrack_backup.json',
      createdAt: createdAt ?? meta?.createdAt ?? clockMs++,
      sizeBytes: 10,
      kind: kind,
      device: device,
      meta: meta,
    );
    files.add(entry);
    contents[entry.id] = Uint8List(10);
    return entry;
  }

  @override
  Future<List<DriveBackupEntry>> list() async {
    calls.add('list');
    _maybeFail();
    return [...files]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> upload(
    Uint8List bytes, {
    required String fileName,
    required BackupMeta meta,
  }) async {
    calls.add('upload');
    _maybeFail();
    uploads.add(meta);
    final id = 'f${_next++}';
    files.add(
      DriveBackupEntry(
        id: id,
        name: fileName,
        createdAt: clockMs++,
        sizeBytes: bytes.length,
        kind: meta.kind,
        device: meta.deviceName,
        meta: meta,
      ),
    );
    contents[id] = bytes;
  }

  @override
  Future<Uint8List> download(String fileId) async {
    calls.add('download');
    _maybeFail();
    return contents[fileId]!;
  }

  @override
  Future<void> delete(String fileId) async {
    calls.add('delete');
    _maybeFail();
    if (failDeleteOf.remove(fileId)) throw const DriveUnavailable('test');
    deleted.add(fileId);
    files.removeWhere((f) => f.id == fileId);
    contents.remove(fileId);
  }

  @override
  Future<void> deleteAll() async {
    calls.add('deleteAll');
    BackupFailure? first;
    for (final entry in await list()) {
      try {
        await delete(entry.id);
      } on BackupFailure catch (e) {
        first ??= e;
      }
    }
    if (first != null) throw first;
  }
}

// --- 008-backup-export-notifications-widget: widget and glance (T3.4) ---

/// Records widget payloads and launches instead of using `home_widget`.
class FakeHomeWidgetBridge implements HomeWidgetBridge {
  new({this.launchAt});

  /// What [launchLocation] returns (a cold start from the widget).
  String? launchAt;

  /// Decoded `glance.v1` payloads, in order.
  final List<Map<String, Object?>> saved = [];
  int armMidnightCalls = 0;
  final List<Future<void> Function(Uri?)> callbacks = [];
  final _launches = StreamController<String>.broadcast();

  /// Simulates a widget tap while the app runs.
  void launch([String location = '/home']) => _launches.add(location);

  @override
  Future<void> save(String payloadJson) async =>
      saved.add(jsonDecode(payloadJson) as Map<String, Object?>);

  @override
  Future<void> armMidnight() async => armMidnightCalls++;

  @override
  Future<String?> launchLocation() async => launchAt;

  @override
  Stream<String> get launches => _launches.stream;

  @override
  Future<void> registerBackgroundCallback(
    Future<void> Function(Uri? uri) callback,
  ) async => callbacks.add(callback);
}

/// Records daily summary reschedules.
class FakeDailySummaryScheduler extends DailySummaryScheduler {
  new({List<String>? log})
    : log = log ?? [],
      super(
        notifications: FakeNotificationService(),
        settings: FakeSettingsRepository(),
        clock: Clock.fixed(DateTime(2026, 10, 21)),
        glanceFor: (day) async => HomeGlance(date: day),
      );

  /// Shared call log, e.g. with [FakeGlanceRefresher].
  final List<String> log;
  final List<(HomeGlance?, HomeGlance?)> calls = [];

  /// Thrown by [reschedule] when set.
  Error? fail;

  @override
  Future<void> reschedule({HomeGlance? today, HomeGlance? next}) async {
    calls.add((today, next));
    log.add('summary');
    if (fail case final e?) throw e;
  }
}

/// Counts refreshes instead of building glances.
class FakeGlanceRefresher implements GlanceRefresher {
  new({List<String>? log}) : log = log ?? [];

  final List<String> log;
  int refreshCalls = 0;
  int startCalls = 0;

  /// Thrown by [refreshNow] when set.
  Error? fail;

  @override
  Future<void> refreshNow() async {
    refreshCalls++;
    log.add('refresh');
    if (fail case final e?) throw e;
  }

  @override
  void start() => startCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A fixed device zone (feature 008 R21); null when unreadable.
class FakeTimeZoneSource implements TimeZoneSource {
  new([this.zone = 'Asia/Kolkata']);

  String? zone;

  @override
  Future<String?> deviceZoneId() async => zone;
}
