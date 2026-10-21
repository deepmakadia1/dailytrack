import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/notification_permission.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
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
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
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

  /// Simulates the user tapping a notification while the app runs.
  void tap(String payload) => _taps.add(payload);

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

  /// When set, the next run throws it once (nothing was deleted).
  Exception? failNext;

  @override
  Future<void> eraseAll() async {
    calls++;
    if (failNext case final e?) {
      failNext = null;
      throw e;
    }
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
class FakeDeviceInfoSource implements DeviceInfoSource {
  @override
  Future<DeviceInfo> load() async => const DeviceInfo(
    manufacturer: 'Google',
    model: 'Pixel 7',
    release: '14',
    sdkInt: 34,
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

  @override
  Future<void> cancel(String uniqueName) async => cancelled.add(uniqueName);
}
