# Contract: Core services and interfaces (T3.1)

Signatures are Dart-like and show the shape, not final code. Every provider is typed to the domain
interface, throws until `lib/app/production_overrides.dart` binds it, and is bound to a fake in
widget tests (the existing pattern in `feature_gate_providers.dart`).

## `lib/core/security/`

### `LockService` (`domain/lock_service.dart`, pure Dart)

```dart
abstract interface class LockService {
  /// Combines settings.lockEnabled with the stored credential (research R6).
  Future<LockStatus> status();

  /// Hashes in an isolate. Writes `lock.pin`, then settings.lockEnabled = true.
  /// Clears the lockout state. Precondition: pin matches ^[0-9]{4}$.
  Future<void> setPin(String pin);

  /// Checks the lockout first; while locked out, returns lockedOut without hashing.
  /// Persists the new LockoutState before returning.
  Future<UnlockResult> verifyPin(String pin);

  /// Requires verifyPin(current) == success, then setPin(newPin). Returns the verify result.
  Future<UnlockResult> changePin({required String current, required String newPin});

  /// Requires verifyPin(current) == success. Writes lockEnabled = false and
  /// biometricEnabled = false, then deletes lock.pin and lock.lockout.
  Future<UnlockResult> disable(String current);

  /// Shows the system prompt. On success it resets the lockout (clarification Q3).
  /// It is allowed during a lockout. It is never allowed when status() is credentialUnavailable.
  Future<bool> unlockWithBiometrics({required String reason});

  /// Turning on needs a successful prompt first (FR-026). Turning off always succeeds.
  Future<bool> setBiometricEnabled({required bool enabled, required String reason});

  Future<BiometricAvailability> biometricAvailability();

  /// Remaining lockout, or Duration.zero. The UI polls it once per second while locked out.
  Future<Duration> lockoutRemaining();

  /// The length the next lockout would have if the next PIN is wrong, or null
  /// before the first lockout (level 0). Drives the post-lockout warning (US2-1).
  Future<Duration?> nextLockoutLength();

  /// Deletes every lock.* key (used by erase all data).
  Future<void> reset();
}
```

**Guarantees**
- The plain PIN never leaves the call. Nothing is logged.
- Every error path (a storage failure, or a `local_auth` exception) maps to a result value. Nothing
  throws into widgets, except `setPin`'s precondition `ArgumentError`.
- `verifyPin`, `changePin`, and `disable` share the same lockout (FR-039).

### Ports (`domain/`), implemented in `data/`

```dart
abstract interface class SecureKeyValueStore {      // data: FlutterSecureStorage
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteWhere(bool Function(String key) test);
}

abstract interface class BiometricAuthenticator {   // data: local_auth 3.x
  Future<BiometricAvailability> availability();
  /// biometricOnly: true, persistAcrossBackgrounding: true; any exception → false.
  Future<bool> authenticate(String localizedReason);
}
```

### Pure logic (`domain/`)

```dart
final class PinHasher {
  new({int iterations = 120000, Random? random});
  Future<PinRecord> hash(String pin);                    // new salt each call
  Future<bool> verify(String pin, PinRecord record);     // uses record.iter; constant-time compare
}

abstract final class LockoutPolicy {
  static const int attemptsBeforeFirstLockout = 5;
  static const Duration base = Duration(seconds: 30);
  static const Duration max = Duration(minutes: 15);
  static Duration lengthFor(int level);                  // level ≥ 1
  static LockoutState registerFailure(LockoutState s, DateTime nowUtc);
  static LockoutState registerSuccess();
  static Duration remaining(LockoutState s, DateTime nowUtc);   // re-anchors when the clock moves back
  static int? attemptsLeftBeforeLockout(LockoutState s);        // non-null only at level 0 with failed ≥ 3
  static Duration? nextLockoutLength(LockoutState s);           // level ≥ 1 and not locked: lengthFor(level + 1); else null
}

/// Pure rule used by LockSession (data-model §3).
bool shouldLockOnResume({
  required bool lockEnabled,
  required DateTime? backgroundedAt,
  required DateTime now,
  required int lockAfterSeconds,
  required bool externalActivity,
});
```

### `LockSession` (`lock_session.dart`, keep-alive Riverpod notifier)

```dart
class LockSession extends _$LockSession {
  LockSessionState build();                 // locked = settings.lockEnabled at first read after bootstrap
  void markBackgrounded(DateTime now);      // AppLifecycleListener onHide/onPause
  void onResumed(DateTime now);             // applies shouldLockOnResume → locked + mode overlay
  void expectExternalActivity();            // research R15
  void deferLocation(String location);      // notification tap while locked
  String? unlocked();                       // locked = false; returns and clears pendingLocation
  void reset();                             // erase all data
}
```

`ExternalActivityGuard` (`lib/core/security/external_activity_guard.dart`) is a provider exposing
just `void expectExternalActivity()`. The receipt picker and core sharers use it, so they never see
the full session.

### `SecureScreenService` (`secure_screen_service.dart`)

```dart
abstract interface class SecureScreenService {
  Future<void> setSecure(bool on);          // channel "dailytrack/window", method "setSecure"
}
```

A keep-alive `secureScreenController` sets `secure = settings.hideInRecents || unlockVisible` and
calls the service only when that value changes (research R9). `UnlockScreen` sets `unlockVisible` in
`initState`/`dispose`.

## `lib/core/reset/`

```dart
abstract interface class AppResetService {
  /// All-or-nothing on the database; later steps are best effort (data-model §6).
  /// Throws only when the database step fails.
  Future<void> eraseAll();
}
```

## `lib/core/module/tracker_module.dart` (two optional hooks)

```dart
abstract class TrackerModule {
  // … existing members …

  /// Called after "Erase all data" has deleted all rows. Remove module-owned
  /// files and scheduled alarms. Must not throw (errors are swallowed).
  Future<void> onEraseAll(ProviderReader read) async {}

  /// Called after the notifications master, budget alerts, or habit reminders
  /// setting changes. Reconcile scheduled notifications with the new settings.
  Future<void> onNotificationSettingsChanged(ProviderReader read) async {}
}
```

| Module | `onEraseAll` | `onNotificationSettingsChanged` |
| --- | --- | --- |
| Expense | Delete `<docs>/receipts/` through `ReceiptStore` | `budgetAlertNotifier.cancelAll()` if `SettingsNotificationGate.budgetAlertsAllowed()` is false |
| Habit | `reminderScheduler.cancelAll()` | `reminderScheduler.reconcileAll()` |

## `lib/core/notifications/notification_service.dart`

New `Future<void> cancelAll()`, which cancels every scheduled and shown notification.

## `lib/core/settings/domain/settings_repository.dart` (new methods)

```dart
Future<void> setThemeMode(String mode);          // system | light | dark
Future<void> setSelectedTheme(String id);        // catalog id
Future<void> setFontSize(String size);           // default | large
Future<void> setFirstDayOfWeek(int day);         // 1 | 6 | 7
Future<void> setDateFormat(String format);       // dMMMy | ddMMy | mmddy | iso
Future<void> setDailySummaryTime(String hhmm);   // HH:mm
Future<void> setLockEnabled({required bool enabled});       // LockService only
Future<void> setBiometricEnabled({required bool enabled});  // LockService only
Future<void> setLockAfterSeconds(int seconds);   // 0 | 60 | 300
Future<void> setHideInRecents({required bool enabled});
```

A value outside the allowed set is ignored (the same rule as the existing `setLocale`).
`FakeSettingsRepository` (`test/helpers/fakes.dart`) implements them all.

## `lib/core/theme/`

```dart
final class AppColorTheme { final String id; final Color seed; final bool isPremium; }
const List<AppColorTheme> appColorThemes;                     // data-model §4 order
AppColorTheme colorThemeById(String id);                      // unknown → default

abstract final class AppTheme {
  static ThemeData light({Color seed = AppColors.seed});
  static ThemeData dark({Color seed = AppColors.seed});
}

@Riverpod(keepAlive: true) Stream<AppColorTheme> effectiveColorTheme(Ref ref);
@riverpod Stream<bool> colorThemeUnlocked(Ref ref, String id);   // free → true; else featureGate.watch

/// MediaQuery text scaler: system × factor, capped at maxScale.
final class AppTextScaler extends TextScaler { new(TextScaler system, {double factor, double maxScale}); }
```

## `lib/core/support/` and `lib/core/config/`

```dart
abstract interface class AppReviewService { Future<void> rateApp(); }   // in_app_review, store fallback
abstract interface class AppInfoSource { Future<AppInfo> load(); }      // version, build, package name
abstract interface class DeviceInfoSource { Future<DeviceInfo> load(); } // channel getDeviceInfo
abstract interface class ExternalLauncher {                             // url_launcher
  Future<bool> email({required String to, required String subject, required String body});
  Future<bool> openUrl(Uri uri);
  Future<bool> openNotificationSettings();
}
abstract final class AppLinks {                                         // String.fromEnvironment
  static const String privacyPolicyUrl, termsUrl, supportEmail;
}
```

Each launcher call runs `ExternalActivityGuard.expectExternalActivity()` before it leaves the app.

## Android (`MainActivity.kt`)

- `class MainActivity : FlutterFragmentActivity()`.
- The `dailytrack/timezone` channel is unchanged.
- New `dailytrack/window` channel:
  - `setSecure(bool)` adds or clears `WindowManager.LayoutParams.FLAG_SECURE` on the UI thread;
  - `getDeviceInfo` returns `{manufacturer, model, release, sdkInt}`.
