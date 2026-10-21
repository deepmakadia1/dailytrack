# Research: Settings, Themes, and App Lock (T3.1)

**Feature**: `specs/007-settings-themes-app-lock` · **Date**: 2026-10-21

Technical Context had no open NEEDS CLARIFICATION items. The user's plan input fixed the stack,
package list, and folders. The decisions below settle how the feature fits the existing code. Each was
checked against the code as of 2026-10-21 (files cited). Package versions are the ones
`flutter pub add --dry-run` resolved against the current lockfile.

---

## R1. New packages and versions

- **Decision**: Add the eight packages the user listed. Six are new; `share_plus` is already a
  dependency.

  | Package | Version | Used for |
  | --- | --- | --- |
  | `local_auth` | ^3.0.2 | Biometric check and prompt (SYS-03, SYS-04, SET-05) |
  | `flutter_secure_storage` | ^11.2.0 | PIN hash, salt, KDF params, lockout state |
  | `cryptography` | ^2.9.0 | PBKDF2-HMAC-SHA256 PIN hashing and secure random salt |
  | `in_app_review` | ^2.0.12 | Rate us |
  | `share_plus` | ^13.3.1 (existing) | Share app, through the existing `TextSharer` |
  | `url_launcher` | ^6.3.3 | `mailto:` feedback, store page fallback, system settings |
  | `package_info_plus` | ^10.2.2 | App version and build number (About, feedback email) |
  | `webview_flutter` | ^4.14.1 | Privacy policy and Terms in-app web view |

- **Rationale**: These are the spec §2 security packages plus the minimum needed for the SET-01
  About and Privacy rows. Every one is a first-party Flutter or long-maintained community plugin with
  Android support at API 24.
- **Alternatives considered**:
  - `device_info_plus` for the device model in feedback: rejected as an extra dependency. R14 uses
    the existing `MainActivity` method channel instead.
  - `flutter_windowmanager` for `FLAG_SECURE`: unmaintained. R9 uses a method channel instead.
  - `crypto` (HMAC only, no KDF): would mean writing PBKDF2 by hand.

## R2. Android host changes for `local_auth`

- **Decision**:
  1. `MainActivity` extends `FlutterFragmentActivity` instead of `FlutterActivity`; the existing
     `dailytrack/timezone` channel moves over unchanged.
  2. `LaunchTheme` and `NormalTheme` (in `values`, `values-night`, `values-v31`, and
     `values-night-v31`) take `Theme.AppCompat.DayNight.NoActionBar` as parent.
     `android:windowBackground` and the splash items stay as they are.
  3. Add `androidx.appcompat:appcompat` to `android/app/build.gradle.kts` if the build does not
     already get it through `local_auth_android`.
  4. Add `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`.
  5. Set `android:allowBackup="false"` on `<application>` (see R8).
  6. Run `dart run flutter_native_splash:create` again, and check that it keeps the AppCompat parents.
- **Rationale**: `local_auth` needs a `FragmentActivity`, because `BiometricPrompt` is a fragment. Its
  README warns that on Android 8 and below (inside our API 24 minimum) the activity theme must
  descend from `Theme.AppCompat`, or the prompt crashes. `test/android/` already holds manifest
  checks; a new test asserts the activity superclass, the permission, and `allowBackup`.
- **Alternatives considered**: Keep `FlutterActivity` and use a different biometric plugin. No such
  plugin is maintained, and the user chose `local_auth`.

## R3. PIN hashing: PBKDF2-HMAC-SHA256, run off the UI thread

- **Decision**: `PinHasher` (pure Dart, `lib/core/security/domain/pin_hasher.dart`) wraps
  `cryptography`:
  - `Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: n, bits: 256)`
  - a 16-byte salt from `SecureRandom.safe`
  - **n = 120,000** by default
  - the record stores `{v: 1, alg: "pbkdf2-sha256", iter, salt (base64), hash (base64)}` (data-model
    §2), so the iteration count can be raised later without breaking old PINs
  - verifying uses a constant-time compare
  - `LockService` runs hashing with `Isolate.run`, so the keypad never janks

  Unit tests inject a low iteration count so they run fast. One test pins the production default and
  checks a known PBKDF2 test vector.
- **Rationale**: The constitution (III) and SYS-03 require a salted PBKDF2 or Argon2 hash. PBKDF2 is
  pure Dart in `cryptography`, so it has no native build risk. 120k iterations measures about
  150–300 ms on a mid-range device in an isolate, which keeps SC-002 (unlock in under 3 s).
  **Threat note**: a 4-digit PIN has only 10,000 values, so no KDF stops an offline brute force by
  itself. The real protection is that the record lives in Android Keystore-backed secure storage and
  never leaves the device (R8), plus the online lockout (R4). The hash keeps the plain PIN off disk,
  as the constitution requires.
- **Alternatives considered**:
  - Argon2id (`cryptography`'s `Argon2id`): pure-Dart Argon2 with a useful memory cost is several
    seconds on low-end phones.
  - `cryptography_flutter` for native speed-up: one more plugin for a 4-digit PIN with no gain.
  - SHA-256 with salt and no stretching: not a slow hash, so it violates SYS-03.

## R4. Lockout policy: pure logic with an injected clock

- **Decision**: `LockoutPolicy` (pure Dart, `lib/core/security/domain/lockout_policy.dart`) works
  on an immutable `LockoutState {failedAttempts, level, lockedUntilUtcMs?, lockedAtUtcMs?}`:
  - `registerFailure(state, now)`: before any lockout (`level == 0`), the 5th failure starts lockout
    level 1 (30 s). After a lockout has ended (`level ≥ 1`), every failure starts the next level at
    once (clarification Q1). The length is `min(30 s × 2^(level−1), 15 min)`, which gives 30 s, 60 s,
    2, 4, 8, 15, 15 … min.
  - `remaining(state, now)`:
    - Normal case: `lockedUntil − now`, but never more than the level's full length.
    - If `now < lockedAt` (the clock moved backward), it re-anchors to `lockedAt = now` with the full
      length, so the lockout is never longer than one full period.
    - If `now ≥ lockedUntil`, the lockout is over.
  - `registerSuccess()`: returns the initial state (PIN or biometric success, clarification Q3).
  - `attemptsLeftBeforeLockout(state)`: drives the "N attempts left" hint before the first lockout
    (shown from the 3rd failure, US2-1).
  - `nextLockoutLength(state)`: after a lockout ends, drives the warning "Next wrong PIN locks the
    app for m:ss" (US2-1).

  Time comes from `clockProvider` (`lib/core/utils/clock_provider.dart`). Tests use `Clock.fixed` and
  `MutableClock` (`test/helpers/mutable_clock.dart`). Boundary tests cover 4/5 failures, each level,
  the 15-minute cap, an exact-expiry tick, clock-back, and clock-forward (accepted as a known limit;
  spec Assumptions).
- **Rationale**: This is the user's request ("pure logic with unit tests and an injected clock").
  It keeps FR-031 and FR-032 testable without plugins.
- **Alternatives considered**:
  - A monotonic `Stopwatch`: cannot survive a restart (SYS-03 AC "Lockout timer survives app
    restart").
  - `elapsedRealtime` from the platform: resets at reboot, so it needs a wall clock anyway.

## R5. `LockService`: one port over secure storage, hashing, biometrics, and lockout

- **Decision**: `lib/core/security/` follows the core layering used by `feature_gate/`:
  - `domain/`: pure Dart. `LockService` interface, `PinHasher`, `LockoutPolicy`, value types
    (`PinRecord`, `LockoutState`, `UnlockResult`, `BiometricAvailability`).
  - `data/`: `SecureLockService` implements `LockService` using `SecureKeyValueStore` (a thin port
    over `flutter_secure_storage`) and `BiometricAuthenticator` (a port over `local_auth`).
  - `security_providers.dart`: `lockServiceProvider`, `lockSessionProvider`,
    `secureScreenServiceProvider`, and `biometricAuthenticatorProvider`, all throwing until
    `production_overrides.dart` binds them (the existing pattern). Widget tests bind
    `FakeLockService` and `FakeBiometricAuthenticator`.

  The methods are listed in [contracts/lock_service.md](contracts/lock_service.md).
  `verifyPin` checks the lockout first and never hashes while locked out. It persists the new
  `LockoutState` **before** returning, so killing the app right after a wrong guess still counts it.
- **Rationale**: Presentation (SYS-03, SYS-04, SET-05, onboarding) sees only the domain interface
  (Constitution II). The ports make every branch unit-testable with in-memory fakes.
- **Alternatives considered**: Put the lock in a Drift table. That fails the constitution rule that
  the PIN lives only in `flutter_secure_storage`, and Drive backup (T3.2) would copy it.

## R6. Where lock state lives, and keeping `settings` and secure storage consistent

- **Decision**:
  - `settings.lockEnabled` and `settings.biometricEnabled` (existing keys) stay the source of truth
    for "is the lock on", because the router and the UI already watch `appSettingsProvider`.
  - The credential and the lockout state live only in secure storage (data-model §2).
  - Order of writes:
    - Set PIN: write the credential first, then `lockEnabled = true`. A crash in between leaves an
      unused credential, which is harmless.
    - Turn off: set `lockEnabled = false` first, then delete the credential.
    - Biometric: `biometricEnabled` is written only after a successful prompt (FR-026).
  - If `lockEnabled == true` but the credential is missing or unreadable (secure storage was wiped,
    or a device migration), `LockService.status()` returns `credentialUnavailable`. SYS-03 then shows
    an explanation and only "Forgot PIN?" (spec edge case). Biometric unlock is not offered in this
    state, because there is no PIN to fall back to.
- **Rationale**: This reuses the existing reactive settings, and no order of crashes can leave the
  lock "on" without a way out.
- **Alternatives considered**: Derive "lock on" from whether a credential exists. That needs an async
  secure-storage read in the router's redirect, which is synchronous.

## R7. Lock session and lifecycle: cold start uses the redirect, resume uses a covering overlay

- **Decision**:
  - **`LockSession`** (a Riverpod notifier in `lib/core/security/`) holds `{locked: bool,
    backgroundedAt: DateTime?, pendingLocation: String?}`. It starts locked when bootstrap loads
    settings with `lockEnabled`. Saving a PIN (SYS-04 set mode, including from onboarding) marks the
    session unlocked (FR-046).
  - **Lifecycle observer**: the existing `AppLifecycleListener` in `lib/app/app.dart` gains
    `onHide`/`onPause` → `session.markBackgrounded(clock.now())` and `onResume` →
    `session.onResumed(clock.now(), lockAfter)`. This locks when `lockEnabled` and either lockAfter
    is 0 or the elapsed time ≥ lockAfter. A negative elapsed time (clock moved back) also locks
    (fail-safe). It listens for `paused`/`hidden`, not `inactive`, so the notification shade, the
    biometric prompt, and translucent system dialogs (permissions, share chooser) never count as
    leaving the app.
  - **No flash of content on return**: with "Immediately" (and no external activity expected),
    the session locks already at `onHide`, so the first frame built on the way back is SYS-03.
    Flutter draws no frames while the app is hidden (found during implementation), so the recents
    preview keeps the last screen; `hideInRecents` blanks it. For 1 and 5 min, the lock is decided
    on resume, and the overlay is in the first frame that is built.
  - **Covered location** (found during implementation): the router re-runs its redirect on every
    settings change, and `AppOpenRunner` writes a setting on each resume. So rule 4 cannot apply to
    the location the overlay covers, or the first refresh would replace the screens anyway. The
    session stores that location (`coveredLocation`, the router's current URI when it locked), and
    rule 4 skips only that exact location. Any other location (a deep link) still goes through
    `/lock`.
  - **Cold start: go_router redirect** (user request). Bootstrap's `initialLocationFor` keeps
    returning `/lock` and now carries the target: `Routes.lockPath(from: payload ?? home)`. Rule 4 of
    `redirectFor` becomes: while `settings.lockEnabled && session.locked`, any location other than
    `/lock` (and the onboarding PIN exception, R10) redirects to `/lock?from=<location>`. After
    unlocking, SYS-03 calls `router.go(from)`. There is no screen history on a cold start, so nothing
    is lost (FR-044).
  - **Resume: covering overlay** (clarification Q4). If the redirect replaced the location on
    resume, go_router would dispose the tab shell and any full-screen form on the root navigator, and
    unsaved input (EXP-02, HAB-02) would be lost, which breaks FR-044 and the SYS-03 AC. So when the
    session locks while the app is running, `MaterialApp.router(builder:)` renders
    `Stack[Offstage(child: router), UnlockScreen()]` instead of navigating.
    - `Offstage` keeps every route and its state mounted, but not painted, not hit-testable, and
      removed from semantics, so TalkBack cannot reach the content behind the lock.
    - After unlocking, the overlay is removed and the user sees exactly what was there.
  - **Navigation while locked**: notification taps go through the existing `taps` listener in
    `app.dart`. It now stores the payload as `session.pendingLocation` instead of calling `go` while
    locked. After unlocking, the app goes to that location. Any other navigation (a deep link) is
    redirected by rule 4 to `/lock?from=`, and the session switches to `route` mode. That
    navigation was replacing the screen history anyway, so nothing more is lost (FR-045).
  - **Back button**: in overlay mode SYS-03 is not inside the navigator, so `PopScope` cannot catch
    back. `MaterialApp.router` gets an explicit `backButtonDispatcher: LockAwareBackButtonDispatcher`
    (a `RootBackButtonDispatcher` subclass) that calls `SystemNavigator.pop()` and swallows the event
    while the session is locked (FR-034). The `/lock` route keeps `PopScope(canPop: false)` doing the
    same. This means passing `routerDelegate`, `routeInformationParser`, and
    `routeInformationProvider` from the `GoRouter` instead of `routerConfig`. Predictive back is not
    enabled in the manifest, so back arrives as `didPopRoute`.
- **Rationale**: This meets the user's architecture (redirect plus lifecycle observer) and the
  clarified behavior (Q4), with one shared `UnlockScreen` widget for both modes.
- **Alternatives considered**:
  - Redirect only: loses form state on every resume lock (rejected by Q4).
  - Push a pageless route on `rootNavigatorKey`: go_router drops pageless routes whenever it rebuilds
    the page list. `AppOpenRunner` writes `latestSeenAt` on every resume, which refreshes the router,
    so this is fragile.
  - `Overlay.insert` on the root navigator: back would still pop the route underneath.

## R8. Secure storage options and no OS auto backup

- **Decision**:
  - Use `FlutterSecureStorage` with its default Android options (v10+ ciphers with Keystore-wrapped
    keys).
  - Key names are prefixed `lock.` (data-model §2). The lockout state is stored there too, so a user
    cannot reset it by clearing the `settings` table.
  - Set `android:allowBackup="false"`.
- **Rationale**: Android Auto Backup restores the encrypted secure-storage prefs without their
  Keystore key, so a restored app cannot read them. It would also copy the Drift database to Google
  without the user starting it, which breaks spec §13 ("No user data leaves the device except
  user-initiated Drive backup") and Constitution III. The app's own backup (T3.2) replaces it.
- **Alternatives considered**: A `dataExtractionRules` file excluding only the secure-storage file.
  It still uploads the database without the user's consent.

## R9. `SecureScreenService`: `FLAG_SECURE` through the existing method channel

- **Decision**:
  - `lib/core/security/secure_screen_service.dart` defines `SecureScreenService { Future<void>
    setSecure(bool on) }`.
  - `ChannelSecureScreenService` calls `dailytrack/window` → `setSecure`, which `MainActivity` handles
    with `window.addFlags` / `clearFlags(FLAG_SECURE)` on the UI thread.
  - A keep-alive provider `secureScreenController` computes `secure = settings.hideInRecents ||
    unlockVisible` and calls the service only when that value changes.
  - `unlockVisible` is true while the `/lock` route or the overlay is shown. `UnlockScreen` registers
    on mount and unregisters on dispose.
  - Turning "Hide app content in recents" off while SYS-03 is up keeps the flag set (spec edge case).
- **Rationale**: `FLAG_SECURE` both blocks screenshots and blanks the recents preview, which covers
  FR-027 and FR-033 at once. It is about 15 lines of Kotlin next to the existing timezone channel.
- **Alternatives considered**: A plugin (see R1).

## R10. SYS-04 route and the onboarding exception

- **Decision**: `Routes.pin = '/settings/security/pin'` (spec §5) is a top-level `GoRoute` on the
  root navigator.
  - The query `mode=set|change|disable` is parsed into `PinFlowMode`.
  - Callers use `context.push(Routes.pinPath('set', from: <their location>))` (the mode is a
    String, so callers never import `features/lock`). The screen leaves with `go(from)`, not
    `pop`: go_router updates its route information only on the frame after a pop, and the router
    refresh that follows the `lockEnabled` write re-parsed the stale location and opened SYS-04
    again (found during implementation). `go` updates it at once, and the screen below keeps its
    state because it stays in the page stack. Callers follow the settings stream, not a result.
  - Redirect rule 3 (onboarding first) allows `/settings/security/pin?mode=set` while onboarding is
    not done, so SYS-02 step 4 can push it.
  - A successful set from onboarding writes the credential and `lockEnabled = true`, and marks the
    session unlocked. The user is not asked to unlock after "Get started" (FR-046).
  - `PrivacyStep` gains `appLockOn` and `onSetAppLock`. The `OnboardingController` reads lock status
    from `appSettingsProvider` and does not import the lock feature (it pushes a route).
- **Rationale**: This matches spec §5 and keeps features talking only through routes and `core/`
  (Constitution II).
- **Alternatives considered**: Show SYS-04 as a modal widget from onboarding. That would import
  `features/lock` into `features/onboarding`.

## R11. Theme catalog, the effective theme, and font size live in `lib/core/theme/`

- **Decision**:
  - `app_colors.dart` (the only file allowed to hold color literals) gains 8 seed constants:
    - Default Teal #0F766E (existing `seed`)
    - Indigo #4F46E5
    - Saffron #D97706
    - Forest #15803D
    - Rose #E11D48
    - Midnight #1E3A8A
    - Ocean #0369A1
    - Mono #525252
  - `color_themes.dart` defines `AppColorTheme {id, seed, isPremium, labelKey}` and the ordered
    catalog `appColorThemes`. Ids are stable storage values: `default`, `indigo`, `saffron`, `forest`,
    `rose`, `midnight`, `ocean`, `mono`; `default` matches the existing `selectedTheme` default.
  - `AppTheme.light({Color seed})` and `AppTheme.dark({Color seed})` take the seed. Semantic colors in
    `AppTokens` do not change (FR-016, §15.9).
  - `theme_providers.dart` adds `effectiveColorThemeProvider`: the stored theme if it is free or
    `featureGate.watch(FeatureKey.premiumTheme(id))` is true, otherwise Default Teal. The stored value
    is kept (FR-020). It updates live with the debug switch, because `FakeFeatureGate`/`DriftFeatureGate`
    already re-emit on `debugUnlockAll` (feature 003).
  - `app.dart` builds `theme`/`darkTheme` from that provider.
  - **Font size**: `fontSize: default|large` applies in the `MaterialApp.router` builder as
    `MediaQuery(textScaler: AppTextScaler(system, factor: 1.15, maxScale: 2.0))`. Large is 15% on top
    of the system scale, and the result is capped at 2.0. That keeps the spec's 200% test envelope
    (§12, §15.10) as the worst case even with Large on (FR-021, US5-6).
  - A unit test checks WCAG AA for every seed: `onPrimary`/`primary` ≥ 4.5:1 and `onSurface`/`surface`
    ≥ 4.5:1 in light and dark (spec Assumptions).
- **Rationale**: This is the user's folder request. One seed parameter is all §15.9 allows themes to
  change.
- **Alternatives considered**:
  - A full hand-made `ColorScheme` per theme: more surface area, and it breaks "only the seed
    changes".
  - Font size through `TextTheme` multipliers: it would not stack with the system scale, and widgets
    that read `MediaQuery.textScaler` would ignore it.

## R12. Locked theme behavior until PRM-02

- **Decision**: Tapping a locked theme sets a screen-local `previewThemeId` in `ThemesController`. It
  does not persist anything.
  - The `ThemePreviewCard` renders the sample dashboard inside `Theme(data: AppTheme.x(seed))`.
  - When the previewed theme is locked, the card is wrapped in the existing `LockedFeatureOverlay`
    (`lib/core/widgets/locked_feature_overlay.dart`) with `onWatchAd: null` (button not built) and
    `onGetPro: null` (shown disabled). Both behaviors are already documented on that widget.
  - Each grid tile shows a lock badge: an icon with the semantic label `premium_lockedLabel`, plus a
    "Pro" text chip, so the state is never shown by color alone.
- **Rationale**: The user asked for "Locked themes show LockedFeatureOverlay" with ads and PRM-01 out
  of scope. `docs/spec.md` SET-04 was updated to say PRM-02 takes over in T4.4.
- **Alternatives considered**: Overlay each locked grid tile. A blurred 64 dp swatch with two buttons
  does not fit at 200% scale.

## R13. Date format and first day of week reach existing screens

- **Decision**:
  - **Date format** (clarification Q5): add `lib/core/utils/date_formats.dart`:
    - `enum FullDateFormat { dMMMy('d MMM y'), ddMMy('dd/MM/y'), mmddy('MM/dd/y'), iso('y-MM-dd') }`
      (`y` is intl's full year)
    - `String formatFullDate(DateTime local, FullDateFormat f, String locale)`
    - `formatFullDateTime(...)`, which appends `jm`
  - A core provider `fullDateFormatProvider` (in `settings_providers.dart`) maps the setting. The 10
    full-date call sites found in the survey switch to it:
    - `habit_calendar.dart:10`, `freeze_card.dart:145`, `habit_form_screen.dart:521`,
      `archived_habits_screen.dart:74`
    - `repeat_section.dart:99`, `recurring_row.dart:58`, `occurred_at_chips.dart:57`
    - `transaction_detail_controller.dart:58`, `transaction_detail_screen.dart:259` (keeps its
      weekday as `EEE, ` + format)
    - `CustomPeriod.label` (`period.dart:201`)

    `relativeDayLabel` (`EEE, d MMM`), month/year labels, and week ranges do not change. A scan test
    fails if `DateFormat.yMMMd`/`yMMMEd` reappear under `lib/features/`.
  - **First day of week**: add `setFirstDayOfWeek(int)`, allowing 1 (Mon), 6 (Sat), or 7 (Sun);
    other values are ignored.
    - Every consumer already reads `appSettings.firstDayOfWeek` or `firstDayOfWeekProvider` (habit
      `StreakEngine`, `WeekPeriod`, `PeriodPickerSheet`, reports, transactions, reminders, insights).
      So FR-004 needs no feature edits.
    - `LocalDate.startOfWeek` and `WeekPeriod` already accept any 1–7 value. Tests add Saturday and
      Sunday cases to `period_test` and the streak engine `timesPerWeek` tests.
- **Rationale**: One helper keeps the setting from drifting between screens, and the default
  `d MMM y` matches Indian convention.
- **Alternatives considered**: Apply the setting to every date, including list headers (rejected by
  Q5).

## R14. SET-01 About and Privacy integrations

- **Decision**: Each integration sits behind a small core port, so widget tests use fakes:
  - **Rate us**: `AppReviewService` (`lib/core/support/`) wraps `InAppReview`: `isAvailable()` →
    `requestReview()`, otherwise `openStoreListing()`. The Play quota means a call may show nothing;
    that is expected and needs no message.
  - **Share app**: the existing `TextSharer` with `settings_shareAppText(storeUrl)`.
  - **Send feedback**:
    - `FeedbackEmail` (pure) builds the subject and body from app version and build
      (`package_info_plus`), Android release and SDK, manufacturer and model, and the device language
      (`PlatformDispatcher.locale`, not the app setting).
    - Device facts come from a new `getDeviceInfo` method on `MainActivity`'s channel, so
      `device_info_plus` is not needed.
    - `url_launcher` opens `mailto:` and returns `false` when no email app exists. The screen then
      shows a dialog with the support address and a Copy action (US8-4).
    - No transactions, habits, notes, or settings values (including the app language) go into
      the body (Constitution III).
  - **App version**: `PackageInfo.fromPlatform()` through `AppInfoSource`.
  - **Open-source licenses**: Flutter's `showLicensePage` (no package).
  - **Privacy policy / Terms**: `WebPageScreen` (`lib/features/settings/presentation/screens/`) uses a
    `WebViewController` with JavaScript off, restricted to the configured host.
    - Off-host links open in the browser through `url_launcher`.
    - States: loading (linear progress), error (`ErrorState` + "Try again" calling `reload`), and
      content.
  - **Configuration**: URLs and the support address come from `lib/core/config/app_links.dart`
    (`String.fromEnvironment` with placeholder defaults, per build like ad IDs). The store URL is
    built from the package name that `package_info_plus` reports.
- **Rationale**: These are the user-listed packages, they keep feature code testable, and they send
  no data off the device.
- **Alternatives considered**: Open the policy in Custom Tabs. The spec says in-app web view.

## R15. External activities the app starts itself don't trigger "Immediately"

- **Decision**: `LockSession.expectExternalActivity()` marks the **next** background period as
  app-initiated. That period does not lock on return unless it lasts longer than 5 minutes. The flag
  clears on the next resume. It is called before:
  - the mailto intent, store listing, and system notification settings (this feature);
  - the existing receipt `ImagePicker` (camera or gallery, `image_receipt_picker.dart`) and the
    `ImageSharer`/`TextSharer` share sheets (`lib/core/share/`). The core sharers call it themselves;
    the expense receipt picker calls it through a new core `ExternalActivityGuard` provider, so expense
    does not import security internals.

  `inactive`-only transitions (biometric prompt, permission dialog) never count as leaving the app
  (R7).
- **Rationale**: Without this, with "Immediately", taking a receipt photo, sending feedback, or
  sharing would show SYS-03 on return. That fails "speed first" (§15.1), and FR-043's intent is the
  user leaving the app. The 5-minute cap keeps an abandoned phone from staying unlocked.
- **Alternatives considered**: No exemption: a lock prompt mid-task, every time. An open-ended
  exemption: a phone left in the camera app would never lock.

## R16. Erase all data: `AppResetService` in core, all-or-nothing on the database

- **Decision**: New `lib/core/reset/`:
  - `domain/app_reset_service.dart` defines `Future<void> eraseAll()`.
  - `data/drift_app_reset_service.dart` runs these steps in order:
    1. One Drift transaction with `PRAGMA defer_foreign_keys = ON` deletes every row of every table in
       `AppDatabase.allTables` (settings, unlocks, and all module tables), including seed markers. If
       it throws, nothing has changed, the error propagates, and the UI shows "Try again" (FR-048).
    2. Best effort: every registered module's new `TrackerModule.onEraseAll(read)` hook (default
       no-op). Expense deletes its `receipts/` folder; Habit calls `cancelAll` on its reminder
       scheduler.
    3. `NotificationService.cancelAll()` (new method).
    4. `LockService.reset()` clears every `lock.*` secure key.
    5. `LockSession.reset()`.
    6. `ref.invalidate(bootstrapProvider)`. Bootstrap runs again: it opens the database, reseeds the
       defaults (the markers are gone), and loads default settings with `onboardingDone == false`. The
       router lands on SYS-02.

  Steps 2–5 cannot bring data back, and with the settings rows gone, `lockEnabled` is false. If
  `lock.*` cleanup fails, the next "set PIN" overwrites it.
  - **Shared UI**: one `EraseAllDataFlow` (`lib/core/widgets/erase_all_data_flow.dart`), used by
    SET-01 and "Forgot PIN?":
    1. `ConfirmDialog` with the deletion list.
    2. New `TypedConfirmDialog`: the erase button is enabled only when the text equals `DELETE`
       exactly (case-sensitive, not translated; spec Assumptions).
    3. A progress state, then the reset.
- **Rationale**: Settings and lock are separate features, so both reach the erase only through
  `core/` (Constitution II). The hook keeps module-owned files and alarms inside their modules.
  Deleting rows, rather than deleting the database file, avoids closing and reopening a live Drift
  connection under active streams.
- **Alternatives considered**:
  - Delete the database file and restart the engine: Flutter cannot restart itself cleanly.
  - Soft-delete (`deletedAt`): "erase" must remove the data, and soft deletes would come back from
    backups.
  - Per-repository `deleteAll` methods: 6 new repository methods that could miss a table added later.

## R17. Notification toggles cancel and reschedule through modules

- **Decision**:
  - New optional `TrackerModule.onNotificationSettingsChanged(ProviderReader read)`, default no-op:
    - `HabitModule` calls `reminderScheduler.reconcileAll()`. That already cancels when
      `notificationsEnabled && habitRemindersEnabled && canNotify()` is false
      (`local_habit_reminder_scheduler.dart:107`).
    - `ExpenseModule` calls `budgetAlertNotifier.cancelAll()` when budget alerts are no longer
      allowed. Future alerts are already blocked by `SettingsNotificationGate`.
  - The SET-01 `SettingsController` calls it on the visible modules after each write of the master,
    budget, or habit-reminders toggle. The Habit reminders row is shown only when `habit` is in
    `enabledModules` (clarification Q2), using `moduleRegistry.visible(settings)` ids. Settings never
    imports Habit.
  - The daily summary time is stored as `dailySummaryTime` (`HH:mm`, default `21:00`) and shown with
    `MaterialLocalizations.formatTimeOfDay` (device 12/24 h). Nothing is scheduled (FR-008).
  - When notifications are on but `NotificationService.canNotify()` is false, the section shows a
    "Notifications are blocked" note with "Open settings". This uses `url_launcher` on
    `app-settings:`, falling back to the existing `NotificationPermission.request()` on Android 13+.
- **Rationale**: Reuses the gates and schedulers that features 003 and 005 built for exactly these
  settings, with no cross-feature imports.
- **Alternatives considered**: Run `AppOpenRunner.run()` after each toggle: it also runs rollovers and
  other module work, which is too broad.

## R18. Biometric availability and prompts

- **Decision**:
  - `BiometricAuthenticator` port:
    - `Future<BiometricAvailability> availability()`: `none` / `notEnrolled` / `available`, from
      `isDeviceSupported` + `canCheckBiometrics` + `getAvailableBiometrics`.
    - `Future<bool> authenticate(String reason)`, with `biometricOnly: true` and
      `persistAcrossBackgrounding: true`. No device-credential fallback: the app PIN is the fallback.
  - SYS-03 opens the prompt automatically once per lock event when `biometricEnabled` and
    availability is `available` (FR-029). It does so during a lockout too (clarification Q3). Cancel
    or error leaves the keypad ready. The biometric key reopens the prompt.
  - If enrollment was removed (`notEnrolled`), the key is hidden and SET-05 shows the toggle disabled
    with its reason. `biometricEnabled` is kept, so re-enrolling brings it back.
  - Platform exceptions (`LocalAuthException` in v3) map to `false`, so they never crash the lock.
- **Rationale**: Covers FR-026, FR-028, FR-029, and the biometric edge cases.
- **Alternatives considered**: Allowing the device PIN or pattern as a fallback: that would bypass
  the app PIN and its lockout.

## R19. One controller per screen and shared widgets

- **Decision**:
  - Controllers: `SettingsController` (SET-01), `ThemesController` (SET-04), `SecurityController`
    (SET-05), `UnlockController` (SYS-03), `PinController` (SYS-04), and `WebPageController`. Each
    exposes a freezed state with explicit loading, data, and error (Constitution II).
  - New shared widgets:
    - `lib/core/widgets/`: `SettingsSection` (header + grouped tiles), `TypedConfirmDialog`,
      `EraseAllDataFlow`, and `CurrencyPickerList`, moved from `features/onboarding/.../currency_step.dart`
      so SET-01 can reuse it without a cross-feature import.
    - `lib/features/lock/presentation/widgets/`: `PinDots` (with a shake animation that respects
      `disableAnimations`) and `PinKeypad` (1–9, biometric/empty, 0, backspace; 48 dp minimum keys,
      semantic labels).
  - SYS-03 and SYS-04 share those two widgets inside `features/lock` ("same keypad", spec SYS-04).
  - The keypad is `PinKeypad`, not the calculator `NumericKeypad`. The amount keypad has operators
    and a decimal point that a PIN must not have.
- **Rationale**: §15.4 asks for shared components. The PIN pad is shared only within the lock feature,
  because nothing else uses it.
- **Alternatives considered**: Generalize `NumericKeypad` with a PIN mode. That adds flags to a
  heavily used widget for one consumer.

## R20. Tests and layering scan

- **Decision**:
  - **Unit**: `PinHasher`, `LockoutPolicy`, `SecureLockService` (in-memory store + fake biometrics +
    `MutableClock`), `LockSession` lifecycle math, `redirectFor` (new rules), `AppTextScaler`, theme
    contrast, `FullDateFormat`, `FeedbackEmail`, `SettingsCodec` (new keys), and
    `DriftAppResetService` on an in-memory database (every table is empty afterwards, and a failing
    transaction changes nothing).
  - **Widget**: SET-01, SET-04, SET-05, SYS-03, SYS-04, `WebPageScreen` (fake platform), onboarding
    step 4, and the erase flow. All use fakes and `NoAdsService`.
  - **App-level widget tests** with the real router and a fake lock service:
    - resume lock preserves an EXP-02 draft;
    - cold-start redirect and return to the notification target;
    - back closes the app (`SystemNavigator.pop` observed through the `SystemChannels.platform` mock).
  - **Platform**: `FLAG_SECURE` is checked through a fake `SecureScreenService` call log; the Kotlin
    side is checked manually (quickstart).
  - The existing `test/core/theme/no_hardcoded_style_test.dart` scan is extended:
    - `features/lock` and `features/settings` must not import `local_auth`, `flutter_secure_storage`,
      `cryptography`, `webview_flutter` (except `WebPageScreen`), or any `data/` file.
    - `lib/core/security/domain/` must be pure Dart.
- **Rationale**: Constitution IV. Each acceptance criterion maps to a test in
  [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests).
- **Alternatives considered**: Integration tests on a device for the lock. These stay manual
  (quickstart §4), because CI has no emulator, as in features 003–006.
