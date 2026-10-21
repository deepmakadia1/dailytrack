# Contract: Core services (settings, ads, notifications permission, bootstrap)

The domain interfaces are pure Dart. Implementations live in `data/` subfolders. Screens use
these only through Riverpod providers. Tests override the providers with fakes.

## SettingsRepository: `lib/core/settings/`

```dart
// domain/settings_repository.dart
abstract interface class SettingsRepository {
  Future<AppSettings> load();                 // missing/corrupt keys -> defaults (never throws on bad JSON)
  Stream<AppSettings> watch();                // emits on every change
  Future<void> setLocale(String? languageCode);           // null = follow device
  Future<void> setCurrency(String code);
  /// Throws LastModuleError if [enabled] is empty. Unknown ids are rejected.
  Future<void> setModules({required List<String> order, required List<String> enabled});
  /// Atomic: writes locale, currency, modules and onboardingDone=true in one transaction.
  Future<void> completeOnboarding(OnboardingChoices choices);
  // Typed getters for later phases (lockEnabled, removeAdsPurchased, ...) are read via load()/watch().
}

final class LastModuleError implements Exception {}
```

`settings_providers.dart` declares `settingsRepositoryProvider` typed to this interface. It throws unless overridden and has no `data/` or Drift imports. `main.dart` binds it to `SettingsRepositoryImpl`, and tests bind fakes or use `makeRealContainer`. `data/settings_repository_impl.dart` implements this on top of the Drift `settings` table and
does JSON encoding through `SettingsCodec`.

## AdService: `lib/core/ads/ad_service.dart` (FR-027)

```dart
abstract interface class AdService {
  Future<void> initialize();       // Phase 0: only member. T4.x adds banner/native/interstitial/rewarded.
}
final class NoAdsService implements AdService {
  const NoAdsService();
  @override Future<void> initialize() async {}
}
```

**Rule (tested)**: bootstrap calls `initialize()` if and only if `removeAdsPurchased == false`.

## NotificationPermission: `lib/core/notifications/`

This is split into three files so presentation code never imports the platform plugin: `notification_permission.dart` (the interface only, pure Dart), `local_notification_permission.dart` (the plugin-backed implementation), and `notification_providers.dart` (`notificationPermissionProvider`).

```dart
abstract interface class NotificationPermission {
  /// Requests POST_NOTIFICATIONS on Android 13+. Returns granted state; returns true on
  /// Android ≤ 12 (no runtime permission). MUST NOT throw; denial is a normal result.
  Future<bool> request();
}
```

The implementation uses
`AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`. SYS-02 ignores the
result for navigation, so denial never blocks onboarding.

## Bootstrap: `lib/app/bootstrap.dart` (SYS-01 behavior)

```dart
sealed class BootstrapResult { }
final class BootstrapReady extends BootstrapResult { final String initialLocation; }
final class BootstrapFailed extends BootstrapResult { final Object error; }

/// Order:
///  1. open DB (runs migrations) and load settings, in parallel where independent
///  2. SeedRunner.runAll(registry.all.expand((m) => m.seeders))   // exactly-once, transactional
///  3. if (!settings.removeAdsPurchased) adService.initialize()     // consent added in T4.1
///  4. initialLocation = !onboardingDone ? '/onboarding' : lockEnabled ? '/lock' : '/home'
/// Any exception in 1–2 -> BootstrapFailed (shown as ErrorState with "Retry").
/// A failure in step 3 is logged and ignored (ads never block startup).
Future<BootstrapResult> bootstrap(Ref ref);
```

## SeedRunner: `lib/core/database/seed_runner.dart`

```dart
class SeedRunner {
  SeedRunner(this.db);
  /// For each seeder: in ONE transaction, if settings has no 'seed.<id>' row,
  /// run seeder.seed(db) then write 'seed.<id>' = now. Rolls back fully on error.
  Future<void> runAll(Iterable<Seeder> seeders);
}
```
