# Contract: Core services added or changed by feature 003

All interfaces are pure Dart. Implementations are bound in `lib/app/production_overrides.dart`
(moved out of `main.dart`, research R10). Tests override them with fakes from `test/helpers/fakes.dart`.

## Clock (`package:clock`, research R2)

- `clockProvider` (keep-alive, `core/utils/clock_provider.dart`) returns `package:clock`'s
  `Clock`. Production uses `const Clock()`.
- `core/utils/clock.dart` is deleted. Tests use `Clock.fixed` or
  `test/helpers/mutable_clock.dart`.
- Rule: no `DateTime.now()` in `lib/` (scan test).

## FeatureGate (`lib/core/feature_gate/`, R13)

```dart
final class FeatureKey {               // value class, TEXT storage
  static const exportCsv, exportPdf, advancedReports, adFreeDay, streakFreeze;
  factory premiumTheme(String name);   // 'premiumTheme_<name>'
  final String storageKey;
}

abstract interface class FeatureGate {
  /// Emits now, then on every change. That includes an unlock expiring
  /// (timer), a new grant or revoke, and the debug switch.
  Stream<bool> watch(FeatureKey key);
  Future<bool> isUnlocked(FeatureKey key);
}

abstract interface class UnlockRepository {
  Stream<List<Unlock>> watchLive();
  /// Used by T4.4/T4.5 and tests. [expiresAt] null = permanent.
  Future<Unlock> grant(FeatureKey key, {DateTime? expiresAt, required UnlockSource source});
  Future<void> revoke(String unlockId);
}
```

Providers: `featureGateProvider`, `unlockRepositoryProvider` (keep-alive, throw unless
overridden), and `debugToolsAvailableProvider` (bool, default `false`; production override:
`!FlavorConfig.current.isProd`).

Rules:
- Unlocked if (`debugToolsAvailable && settings.debugUnlockAll`), or a live unlock has
  `expiresAt == null || expiresAt > effectiveNow`.
- `effectiveNow = max(clock.now(), settings.latestSeenAt)`. `latestSeenAt` is raised on each
  evaluation and on app open, and is never lowered.

## Notifications (`lib/core/notifications/`, R15)

```dart
enum NotificationChannelId { budgetAlerts }   // others are added by later features

final class AppNotification {
  final int id; final NotificationChannelId channel;
  final String title; final String body;
  final String payload;   // a go_router location
  final String? tag;
}

abstract interface class NotificationService {
  Future<void> initialize();          // creates channels; idempotent
  Future<bool> canNotify();           // OS-level permission/enabled
  Future<void> show(AppNotification n);
  Future<void> cancelByTag(String tag);
  Future<String?> launchPayload();    // the tap that cold-started the app
  Stream<String> get taps;            // taps while the app is running
}
```

- `notificationServiceProvider` (keep-alive). `LocalNotificationService` is the only importer of
  `flutter_local_notifications`, together with the existing `LocalNotificationPermission`.
- `initialize()` is called in `Bootstrap` (it never blocks or fails startup) and in the background
  dispatcher.

## Background jobs (`lib/core/background/`, R10)

```dart
typedef BackgroundTask = Future<bool> Function(ProviderReader read);

abstract interface class BackgroundScheduler {
  /// Periodic 24 h task, keep policy (no-op if already scheduled).
  Future<void> ensureDaily(String uniqueName);
  Future<void> cancel(String uniqueName);
}
```

- `WorkmanagerBackgroundScheduler` is the only importer of `workmanager`, apart from
  `lib/app/background_dispatcher.dart`, which calls `Workmanager().executeTask`.
- The dispatcher looks the task up by name in `ModuleRegistry.enabled(settings)`. Unknown or
  disabled → `true` (done, nothing to do).

## TrackerModule (changed, `core/module/tracker_module.dart`)

```dart
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

Future<void> onEnable(ProviderReader read);    // signature change
Future<void> onDisable(ProviderReader read);   // signature change
Future<void> onAppOpen(ProviderReader read);   // NEW: cold start + every resume, enabled modules only
Map<String, BackgroundTask> get backgroundTasks; // NEW
```

Callers: `ModulesController` (SET-06) passes `ref.read`. `Bootstrap` and the `app.dart` lifecycle
listener call `onAppOpen` with `ref.read`, `unawaited`, with errors caught and an in-flight guard.
The dispatcher passes `container.read`. `HabitModule` implements all of them as no-ops.

## Settings (changed)

- `AppSettings` gains `notificationsEnabled` (true), `budgetAlertsEnabled` (true), `debugUnlockAll`
  (false), and `latestSeenAt` (int?), with codec keys of the same names.
- `SettingsRepository` gains:
  - `setDebugUnlockAll(bool)` and `raiseLatestSeenAt(int utcMs)` (writes only if larger).
  - `setNotificationsEnabled(bool)` and `setBudgetAlertsEnabled(bool)` (no UI until T3.1; used by
    tests).
  - `readModuleState(String key)` and `writeModuleState(String key, String value)`, stored as
    `module.<key>`.

## AppDatabase (changed)

- `schemaVersion => 3`. Tables gain `RecurringRules`, `Budgets`, `Unlocks`. `from2To3` as in
  data-model §1.
- `open()` uses `DriftNativeOptions(shareAcrossIsolates: true)`. `beforeOpen` adds `PRAGMA
  busy_timeout = 5000`.

## LockedFeatureOverlay (changed, R14)

```dart
const LockedFeatureOverlay({
  required Widget child,
  VoidCallback? onWatchAd,   // null → button not built
  VoidCallback? onGetPro,    // null → shown disabled
  String? message,           // optional explanation line
});
```
