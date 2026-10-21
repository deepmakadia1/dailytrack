---

description: "Task list for Settings, Themes, and App Lock (SET-01, SET-04, SET-05, SYS-03, SYS-04, T3.1)"
---

# Tasks: Settings, Themes, and App Lock (SET-01, SET-04, SET-05, SYS-03, SYS-04, T3.1)

**Input**: Design documents from `specs/007-settings-themes-app-lock/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and the plan input ("PIN hashing and lockout timing are pure
logic with unit tests and an injected clock") require:
- At least one automated test per copied acceptance criterion (SET-01 ×1, SYS-03 ×3, SYS-04 ×2) and
  per user-story scenario (map in quickstart §5).
- Pure unit tests for `PinHasher`, `LockoutPolicy`, and `shouldLockOnResume` with
  `Clock.fixed`/`MutableClock`.
- Widget tests with fakes and `NoAdsService`.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US9). Test names start with the
Screen ID and the scenario, e.g. `SYS-03 US2-3 next wrong PIN after lockout doubles` (Constitution I).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US9 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`.
- **Strings**:
  - Add keys to `tool/l10n/phase0_strings.py` with en, hi, and gu together, then run
    `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit ARB files by hand.
  - Use sentence case, start buttons with a verb, and use ICU placeholders and plurals, never
    concatenation.
  - Language names in the picker (English, हिन्दी, ગુજરાતી) and the confirmation word `DELETE` are
    not translated.
- **Codegen**: after changing any `@riverpod` or `@freezed` file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: read time only from `clockProvider` or an injected `Clock`. Never call `DateTime.now()`
  (scan-enforced).
- **Layering** (scan-enforced from T012):
  - `lib/core/security/domain/**` and `lib/core/reset/domain/**` import nothing matching
    `package:flutter/` or `package:flutter_riverpod`.
  - `lib/features/{lock,settings,onboarding}/**` import nothing from `package:local_auth`,
    `package:flutter_secure_storage`, `package:cryptography`, `package:in_app_review`,
    `package:package_info_plus`, `package:url_launcher`, `package:drift`, or any `/data/` path.
  - `package:webview_flutter` is allowed only in
    `lib/features/settings/presentation/screens/web_page_screen.dart` and its controller.
  - `features/settings` and `features/lock` never import each other, `features/expense`, or
    `features/habit`.
- **Screens and widgets**:
  - Use only `AppTokens` and `lib/core/widgets/`.
  - Every screen has loading (skeleton only after 300 ms), error with "Try again", and content states.
  - Never show status by color alone.
  - Respect `MediaQuery.disableAnimations`.
  - 48 dp minimum targets with semantic labels.
  - No ad widgets and no reserved ad slot on any screen in this feature.
- **The PIN** is never logged, put in a `toString`, kept in freezed state beyond the current entry
  step, or exposed through semantics (only "N of 4 digits entered").
- **Widget tests**:
  - Use `pumpTestApp` (`test/helpers/test_app.dart`) with fakes from `test/helpers/fakes.dart`,
    `MutableClock`, and `NoAdsService`.
  - Assert that no `AppNativeAd`/`AppBannerAd` is in the tree.
- **Real-DB tests**: `makeRealContainer` (`test/helpers/real_container.dart`).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Packages, Android host, folder skeletons, and strings

- [X] T001 Add the packages to `pubspec.yaml` (research R1) with `flutter pub add`:
  - `local_auth:^3.0.2`, `flutter_secure_storage:^11.2.0`, `cryptography:^2.9.0`;
  - `in_app_review:^2.0.12`, `url_launcher:^6.3.3`, `package_info_plus:^10.2.2`,
    `webview_flutter:^4.14.1`.

  Keep `share_plus` as it is. Commit the updated `pubspec.lock`.
- [X] T002 Write `test/android/main_activity_test.dart`, and extend `test/android/manifest_test.dart`
  (research R2, R8). They read the files as text and assert:
  - `android/app/src/main/kotlin/**/MainActivity.kt` declares `: FlutterFragmentActivity()` and
    registers channels `dailytrack/timezone` and `dailytrack/window` with the methods `setSecure` and
    `getDeviceInfo`;
  - `AndroidManifest.xml` has `android.permission.USE_BIOMETRIC` and `android:allowBackup="false"`;
  - every `LaunchTheme`/`NormalTheme` in `android/app/src/main/res/values*/styles.xml` has a parent
    starting with `Theme.AppCompat`.

  The tests must fail until T003.
- [ ] T003 Update the Android host (research R2, R8, R9; contracts/services.md "Android"):
  - `MainActivity.kt`:
    - extend `io.flutter.embedding.android.FlutterFragmentActivity`, keeping the timezone channel
      unchanged;
    - add a `MethodChannel` `dailytrack/window`: `setSecure` takes a bool argument and runs
      `window.addFlags`/`clearFlags(WindowManager.LayoutParams.FLAG_SECURE)` on the UI thread, then
      `result.success(null)`; `getDeviceInfo` returns
      `mapOf("manufacturer" to Build.MANUFACTURER, "model" to Build.MODEL, "release" to Build.VERSION.RELEASE, "sdkInt" to Build.VERSION.SDK_INT)`.
  - `AndroidManifest.xml`: add `USE_BIOMETRIC` and set `android:allowBackup="false"` on
    `<application>` (spec §13: no data leaves the device except user-initiated Drive backup).
  - Styles: change the `LaunchTheme` and `NormalTheme` parents to
    `Theme.AppCompat.DayNight.NoActionBar` in `values/`, `values-night/`, `values-v31/`, and
    `values-night-v31/styles.xml`. Keep every existing `<item>`.
  - If `flutter build apk --flavor dev --debug` reports missing AppCompat attributes, add
    `implementation("androidx.appcompat:appcompat:1.7.1")` to `android/app/build.gradle.kts`.
  - Run `dart run flutter_native_splash:create` again, then confirm that the parents are still
    AppCompat (T002 checks this).
- [X] T004 [P] Create the folders:
  - `lib/core/security/{domain,data}/`, `lib/core/reset/{domain,data}/`, `lib/core/support/`,
    `lib/core/config/`;
  - `lib/features/lock/presentation/{controllers,screens,widgets}/`;
  - `lib/features/settings/presentation/{widgets}/` (controllers and screens already exist);
  - `test/core/{security,reset,support}/`, `test/features/lock/`.
- [X] T005 Add all new strings to `tool/l10n/phase0_strings.py` (en, hi, gu) and regenerate
  (contracts/screens.md). Keys:
  - **Settings sections**: `settings_general` ("General"), `settings_appearance` ("Appearance"),
    `settings_modules` ("Modules"), `settings_notifications` ("Notifications"),
    `settings_security` ("Security"), `settings_data` ("Data"), `settings_privacy` ("Privacy"),
    `settings_about` ("About").
  - **General rows**:
    - `settings_language` ("Language"), `settings_languageSystem` ("System default");
    - `settings_currency` ("Currency"), `settings_currencySearch` ("Search currencies");
    - `settings_firstDayOfWeek` ("First day of week"), `settings_monday`, `settings_saturday`,
      `settings_sunday`;
    - `settings_dateFormat` ("Date format");
    - `settings_themeEntry` ("Theme and colors"), `settings_modulesEntry` ("Enable or reorder
      trackers").
  - **Notifications**:
    - `settings_notificationsMaster` ("Notifications");
    - `settings_dailySummaryTime` ("Daily summary time"), `settings_dailySummaryHelp` ("Did you log
      today's expenses?");
    - `settings_budgetAlerts` ("Budget alerts"), `settings_habitReminders` ("Habit reminders");
    - `settings_notificationsBlocked` ("Notifications are blocked for DailyTrack"),
      `settings_openSystemSettings` ("Open settings").
  - **Security and data entries**:
    - `settings_appLockEntry` ("App lock"), `settings_on` ("On"), `settings_off` ("Off");
    - `settings_eraseAll` ("Erase all data").
  - **Privacy and About**:
    - `settings_privacyPolicy` ("Privacy policy"), `settings_terms` ("Terms");
    - `settings_rateUs` ("Rate us"), `settings_shareApp` ("Share app"),
      `settings_shareAppText` (`{url}`: "I track my money and habits with DailyTrack: {url}");
    - `settings_sendFeedback` ("Send feedback"), `settings_feedbackSubject` (`{version}`),
      `settings_noEmailApp` (`{email}`: "No email app found. Write to us at {email}"),
      `settings_copyEmail` ("Copy email"), `settings_emailCopied` ("Email copied");
    - `settings_appVersion` ("App version"), `settings_appVersionValue` (`{version}`, `{build}`:
      "{version} ({build})"), `settings_licenses` ("Open-source licenses").
  - **Web page**: `web_loadError` ("Couldn't load this page. Check your connection and try again.").
  - **Themes**:
    - `themes_title` ("Theme and colors"), `themes_mode` ("Theme mode"), `themes_system`,
      `themes_light`, `themes_dark`, `themes_colors` ("Colors");
    - `themes_fontSize` ("Font size"), `themes_fontDefault` ("Default"), `themes_fontLarge`
      ("Large"), `themes_preview` ("Preview");
    - `themes_selected` ("Selected"), `themes_pro` ("Pro");
    - `themes_tileLabel` (`{name}`, `{state}`), `themes_lockedMessage` ("Get Pro to use this
      theme");
    - `theme_default` ("Default teal"), `theme_indigo`, `theme_saffron`, `theme_forest`,
      `theme_rose`, `theme_midnight`, `theme_ocean`, `theme_mono`.
  - **Security**:
    - `security_title` ("Security"), `security_appLock` ("App lock"), `security_changePin`
      ("Change PIN");
    - `security_biometric` ("Use fingerprint / face unlock"), `security_needsLock` ("Turn on app
      lock first"), `security_biometricNotEnrolled` ("Set up fingerprint or face unlock in your
      phone's settings"), `security_biometricNone` ("This phone doesn't support fingerprint or face
      unlock");
    - `security_lockAfter` ("Lock after"), `security_immediately` ("Immediately"),
      `security_after1Min` ("After 1 minute"), `security_after5Min` ("After 5 minutes");
    - `security_hideInRecents` ("Hide app content in recents"), `security_hideInRecentsHelp`
      ("Also blocks screenshots.");
    - `security_lockOn` ("App lock is on"), `security_lockOff` ("App lock is off"),
      `security_pinChanged` ("PIN changed").
  - **Lock**:
    - `lock_enterPin` ("Enter PIN"), `lock_wrongPin` ("Wrong PIN"), `lock_attemptsLeft` (plural
      `{count}`: "Wrong PIN. {count} attempts left"), `lock_tryAgainIn` (`{time}`: "Try again in
      {time}"), `lock_nextLockoutWarning` (`{time}`: "Next wrong PIN locks the app for {time}");
    - `lock_forgotPin` ("Forgot PIN?"), `lock_forgotTitle` ("Forgot your PIN?"), `lock_forgotBody`
      ("Your PIN can't be recovered. You can erase all data and start fresh.");
    - `lock_credentialUnavailable` ("App lock can't be checked on this phone. Erase all data to
      start fresh.");
    - `lock_biometricReason` ("Unlock DailyTrack"), `lock_useBiometric` ("Use fingerprint"),
      `lock_delete` ("Delete"), `lock_dotsLabel` (`{count}`: "{count} of 4 digits entered").
  - **PIN**:
    - `pin_enterCurrent` ("Enter current PIN"), `pin_enterNew` ("Enter new PIN"), `pin_confirmNew`
      ("Confirm new PIN"), `pin_mismatch` ("PINs don't match. Try again.");
    - `pin_offerBiometric` ("Use fingerprint / face unlock"), `pin_done` ("Done");
    - `onboarding_setAppLock` ("Set app lock"), `onboarding_changePin` ("Change PIN").
  - **Erase**:
    - `erase_title` ("Erase all data?"), `erase_body` ("This deletes your transactions, accounts,
      categories, budgets, recurring entries, habits and check-ins, settings, and app lock. This
      can't be undone.");
    - `erase_continue` ("Continue"), `erase_typeTitle` ("Type DELETE to confirm"), `erase_typeHint`
      ("DELETE"), `erase_confirm` ("Erase everything");
    - `erase_inProgress` ("Erasing…"), `erase_failed` ("Couldn't erase your data. Nothing was
      deleted.").

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Settings keys, lock core (without lockout), lock session, secure screen, erase core,
module hooks, routes, the SET-01 shell, and fakes

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Write `test/core/settings/settings_codec_t31_test.dart`. Cover each new key (data-model.md §1):
  - **Defaults**: `dateFormat` → `dMMMy`, `dailySummaryTime` → `21:00`, `lockAfterSeconds` → `60`,
    `hideInRecents` → `false`, `fontSize` → `default`.
  - **Allowed sets**: anything else decodes to the default. Allowed values are `dateFormat` ∈
    {`dMMMy`,`ddMMy`,`mmddy`,`iso`}, `lockAfterSeconds` ∈ {`0`,`60`,`300`}, `fontSize` ∈
    {`default`,`large`}, `themeMode` ∈ {`system`,`light`,`dark`}, `selectedTheme` ∈ the 8 catalog
    ids (an unknown id → `default`), and `firstDayOfWeek` ∈ {`1`,`6`,`7`} (anything else → `1`).
  - **Daily summary time**: `"21:5"`, `"24:00"`, and `"9:00"` decode to `21:00`.
  - **Round-trip**: each value round-trips through `SettingsRepositoryImpl` on a real in-memory DB.
    A setter given a value outside the allowed set writes nothing.
- [X] T007 Implement the settings keys (data-model.md §1, contracts/services.md "settings_repository"):
  - **`lib/core/settings/domain/app_settings.dart`**: add
    `@Default('dMMMy') String dateFormat`, `@Default('21:00') String dailySummaryTime`,
    `@Default(60) int lockAfterSeconds`, `@Default(false) bool hideInRecents`, and
    `@Default('default') String fontSize`.
  - **`lib/core/settings/data/settings_codec.dart`**: add the constants and validated decoding. Also
    validate `themeMode`, `firstDayOfWeek`, and `selectedTheme`, using
    `const colorThemeIds = ['default','indigo','saffron','forest','rose','midnight','ocean','mono']`.
    Declare that list in `lib/core/settings/domain/app_settings.dart`, so the codec doesn't import
    the theme.
  - **Setters**: add the 10 setters to `lib/core/settings/domain/settings_repository.dart`,
    `lib/core/settings/data/settings_repository_impl.dart`, and `FakeSettingsRepository` in
    `test/helpers/fakes.dart`. They are `setThemeMode`, `setSelectedTheme`, `setFontSize`,
    `setFirstDayOfWeek`, `setDateFormat`, `setDailySummaryTime`, `setLockEnabled`,
    `setBiometricEnabled`, `setLockAfterSeconds`, and `setHideInRecents`. Each ignores values outside
    its allowed set.
  - Doc-comment `setLockEnabled` and `setBiometricEnabled`: "Written only by `LockService`".
- [X] T008 [P] Write `test/core/security/pin_hasher_test.dart` (research R3):
  - two hashes of `1234` have different salts and hashes;
  - `verify` is true for `1234` and false for `1235`, `0000`, and `12345`;
  - a record with `iter: 1000` verifies using its stored count;
  - the default is `iterations == 120000`;
  - one known PBKDF2-HMAC-SHA256 vector (password `"password"`, salt `"salt"`, 1 iteration, 32 bytes
    = `120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b`) matches;
  - `PinRecord` JSON round-trips `{v:1, alg:"pbkdf2-sha256", iter, salt, hash}`;
  - an unknown `v` throws `FormatException`.

  Tests construct `PinHasher(iterations: 1000)` for speed. Also add
  `test/core/security/pin_hasher_perf_test.dart` (tag `perf`): `hash` and `verify` with the default
  120,000 iterations inside `Isolate.run`. Print both durations, and fail if either takes longer than
  1 s on the host. This is a host stand-in for the plan's ≤ 300 ms device goal (SC-002).
- [X] T009 Create `lib/core/security/domain/pin_hasher.dart` (pure Dart: `package:cryptography`
  only):
  - `PinRecord` (`v`, `alg`, `iter`, `salt` base64, `hash` base64; `toJson`/`fromJson`);
  - `PinHasher({int iterations = 120000, Random? random})` with `hash(String pin)` (16-byte salt
    from `SecureRandom.safe` or the injected `random`; `Pbkdf2(macAlgorithm: Hmac.sha256(), iterations, bits: 256)`)
    and `verify(String pin, PinRecord r)` (uses `r.iter`; constant-time byte compare).

  `toString` must never include the PIN.
- [X] T010 [P] Create the pure domain types and ports per contracts/services.md:
  - `lib/core/security/domain/lock_types.dart`:
    - `enum LockStatus { disabled, enabled, credentialUnavailable }`;
    - `sealed class UnlockResult` with `UnlockSuccess`, `UnlockWrong({int? attemptsLeft, Duration? nextLockout})`, and
      `UnlockLockedOut(Duration remaining)`;
    - `enum BiometricAvailability { none, notEnrolled, available }`;
    - `enum LockAfter { immediately(0), oneMinute(60), fiveMinutes(300) }` with `fromSeconds`.
  - `lib/core/security/domain/secure_key_value_store.dart`: `read`, `write`, `delete`, and
    `deleteWhere`.
  - `lib/core/security/domain/biometric_authenticator.dart`: `availability()` and
    `authenticate(String localizedReason)`.
  - `lib/core/security/domain/lock_service.dart`: the `LockService` interface, with each method's
    doc comment copied from contracts/services.md.
- [X] T011 [P] Write `test/core/security/secure_lock_service_test.dart` (no lockout yet; US2 extends
  it), using `InMemorySecureStore`, `FakeBiometricAuthenticator`, `FakeSettingsRepository`, and
  `PinHasher(iterations: 1000)`:
  - `status()` is `disabled` by default. After `setPin('1234')` it is `enabled`: `lock.pin` exists
    and `lockEnabled` is true, and the credential is written **before** the setting (assert the order
    through a recording store and repository).
  - `setPin('12a4')` throws `ArgumentError`.
  - `verifyPin('1234')` → `UnlockSuccess`; `verifyPin('9999')` → `UnlockWrong(null)`.
  - `changePin` with a wrong current PIN changes nothing. With the right one, the old PIN fails and
    the new one succeeds.
  - `disable('9999')` keeps the lock on. `disable('1234')` writes `lockEnabled=false` and
    `biometricEnabled=false`, **then** deletes `lock.*`.
  - `lockEnabled=true` with no `lock.pin`, or with an unreadable `lock.pin` (the store throws),
    gives `credentialUnavailable`.
  - `setBiometricEnabled(enabled: true)` writes only after the fake authenticates. A cancel leaves
    it false. Turning it off always succeeds.
  - `unlockWithBiometrics` returns false when the status is `credentialUnavailable`.
  - `reset()` removes every `lock.*` key and no other key.
- [X] T012 [P] Extend `test/core/theme/no_hardcoded_style_test.dart` with the layering rules in
  "Conventions" (research R20). Add a `DateFormat.yMMMd`/`yMMMEd`/`yMd` ban under `lib/features/`,
  disabled with a `skip:` until T051 lands, then enabled in T051.
- [X] T013 Implement the data adapters and `SecureLockService`:
  - `lib/core/security/data/flutter_secure_key_value_store.dart` (`FlutterSecureStorage()`,
    `deleteWhere` via `readAll` keys).
  - `lib/core/security/data/local_auth_biometric_authenticator.dart`:
    - `availability()`: `isDeviceSupported` false → `none`; supported with no enrolled biometrics
      → `notEnrolled`; otherwise `available`.
    - `authenticate()`: `biometricOnly: true`, `persistAcrossBackgrounding: true`; any exception →
      `false`.
  - `lib/core/security/data/secure_lock_service.dart` implements T011's behavior. Hashing runs in
    `Isolate.run`, with an injectable `runner` for tests. The keys are `lock.pin` and `lock.lockout`
    (the latter is reserved for US2).
- [X] T014 Create `lib/core/security/security_providers.dart` (`@Riverpod(keepAlive: true)`, each
  throwing until overridden): `lockServiceProvider`, `biometricAuthenticatorProvider`, and
  `secureScreenServiceProvider`. Bind the real implementations in
  `lib/app/production_overrides.dart`. Add `InMemorySecureStore`, `FakeLockService` (configurable
  status, PIN `1234`, a recorded call log, settable `UnlockResult` overrides),
  `FakeBiometricAuthenticator`, and `FakeSecureScreenService` (call log) to
  `test/helpers/fakes.dart`, and bind them in `test/helpers/test_app.dart` defaults.
- [X] T015 [P] Write `test/core/security/lock_session_test.dart` (data-model §3, research R7, R15)
  with `MutableClock`. Test `shouldLockOnResume`:
  - `lockEnabled=false` → false; not backgrounded → false.
  - `lockAfterSeconds 0` → true after 1 ms.
  - With 60: 59 s → false, 60 s → true, 61 s → true.
  - Negative elapsed (clock moved back) → true.
  - `externalActivity` with 60 s setting: 4 min → false, 5 min 1 s → true. `externalActivity` with
    0 s setting: 30 s → false.

  Test `LockSession`:
  - After bootstrap with `lockEnabled` it starts `locked=true, mode=route`; without, `locked=false`.
  - `markBackgrounded` + `onResumed` past the limit → `locked=true, mode=overlay`.
  - With lockAfter 0 (and no external activity expected), `markBackgrounded` at `onHide` locks
    immediately (research R7, no flash).
  - `deferLocation('/habits')` then `unlocked()` returns `/habits` and clears it.
  - `expectExternalActivity` is cleared by the next `onResumed`.
  - `reset()` → unlocked and empty.
- [X] T016 Create the session pieces:
  - `lib/core/security/domain/lock_rules.dart`: the pure `shouldLockOnResume` with the exact rule
    from data-model §3.
  - `lib/core/security/lock_session.dart`: a `@Riverpod(keepAlive: true)` notifier with a freezed
    `LockSessionState {locked, mode (route|overlay), backgroundedAt, externalActivity,
    pendingLocation}` and the API from contracts/services.md.
  - `lib/core/security/external_activity_guard.dart`: a provider exposing
    `void expectExternalActivity()` that delegates to the session.

  The initial `locked` is computed once, when `bootstrapProvider` first becomes `BootstrapReady`:
  read `settings.lockEnabled`.
- [X] T017 [P] Write `test/core/security/secure_screen_controller_test.dart`:
  - with `hideInRecents=false` and no unlock visible, no `setSecure(true)` call;
  - `unlockVisible=true` → `setSecure(true)`; back to false → `setSecure(false)`;
  - `hideInRecents=true` → `setSecure(true)`, and it stays true when unlock visibility changes;
  - turning `hideInRecents` off while unlock is visible keeps it true;
  - identical consecutive values make no extra calls.

  Then create `lib/core/security/secure_screen_service.dart`:
  - the `SecureScreenService` interface;
  - `ChannelSecureScreenService` (`MethodChannel('dailytrack/window')`, `setSecure`);
  - a `@Riverpod(keepAlive: true) SecureScreenController` with `setUnlockVisible(bool)` that listens
    to `appSettingsProvider.select((s) => s.hideInRecents)`.

  Read it once from `lib/app/app.dart` so it starts.
- [X] T018 [P] Write `test/core/reset/drift_app_reset_service_test.dart` (research R16, data-model
  §6) on a real in-memory `AppDatabase`. Seed rows in all 10 tables, including `settings`
  (`onboardingDone`, `seed.*`, `lockEnabled`) and `unlocks`.
  - After `eraseAll()`, every table in `db.allTables` has 0 rows.
  - Each registered fake module's `onEraseAll` was called once.
  - `NotificationService.cancelAll` and `LockService.reset` were called.
  - `LockSession.reset` was called, and `bootstrapProvider` was invalidated (it rebuilds).
  - A database that throws mid-transaction (inject a failing table delete) leaves **every** row in
    place and rethrows, and no later step runs.
  - A throwing `onEraseAll`, `cancelAll`, or `reset` does not stop the remaining steps or rethrow.
- [X] T019 Implement erase core:
  - `lib/core/module/tracker_module.dart`: add `Future<void> onEraseAll(ProviderReader read) async {}`
    and `Future<void> onNotificationSettingsChanged(ProviderReader read) async {}`, with the doc
    comments from contracts/services.md. Add constructor params `onErase`/`onNotificationsChanged`
    callbacks to `FakeTrackerModule`.
  - `lib/core/notifications/notification_service.dart` and its implementation: add
    `Future<void> cancelAll()` (`FlutterLocalNotificationsPlugin.cancelAll()`). Add it to
    `FakeNotificationService` too.
  - `lib/core/reset/domain/app_reset_service.dart` (the interface).
  - `lib/core/reset/data/drift_app_reset_service.dart`, running the steps in data-model §6 order.
    Step 1 is one `db.transaction` that runs `customStatement('PRAGMA defer_foreign_keys = ON')`,
    then `delete(table).go()` for each of `db.allTables`.
  - `lib/core/reset/reset_providers.dart` (`appResetServiceProvider`, throwing until overridden).
    Bind it in `production_overrides.dart`, and add `FakeAppResetService` (call count, settable
    failure) to the fakes.
- [X] T020 [P] Implement the module hooks (contracts/services.md table):
  - `lib/features/expense/expense_module.dart`:
    - `onEraseAll` deletes the `receipts/` folder through the module's `ReceiptStore`. Add a
      `Future<void> deleteAll()` to `lib/features/expense/domain/receipts/receipt_store.dart` and
      `lib/features/expense/data/receipts/file_receipt_store.dart`.
    - `onNotificationSettingsChanged` calls `budgetAlertNotifier.cancelAll()` when
      `SettingsNotificationGate.budgetAlertsAllowed()` is false.
  - `lib/features/habit/habit_module.dart`: `onEraseAll` → `reminderScheduler.cancelAll()`;
    `onNotificationSettingsChanged` → `reminderScheduler.reconcileAll()`.

  Extend `test/features/expense/expense_module_test.dart` and
  `test/features/habit/habit_module_test.dart` with one test per hook.
- [X] T021 Add the routes (contracts/routes.md):
  - In `lib/app/router/routes.dart`: `lockPath({String? from})`, `pin = '/settings/security/pin'`,
    `pinPath(String mode)`, `themes = '/more/themes'` + `themesSegment`,
    `security = '/more/security'` + `securitySegment`, `webPage = '/more/web/:page'` +
    `webPagePath(String page)`, and names `pin`, `themes`, `security`, `webPage`.
  - `PinFlowMode` (`set`/`change`/`disable`) lives in `lib/features/lock/presentation/pin_flow_mode.dart`.
    The route parses the query string itself, so `routes.dart` stays import-free.
  - Register the routes in `lib/app/router/app_router.dart`, with placeholder builders for
    themes/security/pin/web (`Scaffold` + title only). Stories replace them.
  - Add `test/app/router/routes_test.dart` path-builder tests.
- [X] T022 Replace the More placeholder with the SET-01 shell:
  - Create `lib/features/settings/presentation/controllers/settings_controller.dart` and
    `settings_state.dart` (freezed `SettingsViewData {settings, visibleModuleIds, devTools}` as
    `AsyncValue`).
  - Create `lib/features/settings/presentation/screens/settings_screen.dart`:
    - `AppScaffold(title: nav_more, largeTitle, showBack: false)`;
    - a `ListView` of `SettingsSection`s in the FR-001 order. For now only Appearance, Modules, and
      Security entries (→ `/more/themes`, `/more/modules`, `/more/security`);
    - the **Developer** section moved verbatim from `more_placeholder_screen.dart` (keys
      `developer_section`, `debug_unlock_all`), shown only when `debugToolsAvailableProvider`.
  - Create `lib/core/widgets/settings_section.dart` (contracts/screens.md "Shared core widgets") with
    `test/core/widgets/settings_section_test.dart` (header is a semantics header; children render).
  - Route `/more` to `SettingsScreen`. Delete
    `lib/features/settings/presentation/screens/more_placeholder_screen.dart`, and move its tests to
    `test/features/settings/settings_screen_test.dart` (dev shows Developer, prod hides it, the switch
    writes `debugUnlockAll`).

**Checkpoint**: Foundation ready. The app runs, More shows the new list shell, and all existing
tests are green.

---

## Phase 3: User Story 1 - Protect the app with a PIN (Priority: P1) 🎯 MVP

**Goal**: The user turns on app lock from SET-05 by setting a PIN in SYS-04 (with an optional
biometric). From then on, SYS-03 guards cold start and resume after "Lock after", returns the user to
the same screen with their unsaved input, and back closes the app.

**Independent Test**: Turn the lock on, background the app past the lock-after time, return, and
confirm SYS-03 appears, the correct PIN returns to the same screen, wrong PINs are rejected, and back
closes the app (quickstart §4 steps 2–4).

### Tests for User Story 1 ⚠️

- [X] T023 [P] [US1] Write `test/features/lock/pin_widgets_test.dart`:
  - `PinDots` shows N filled dots, and its semantics read "2 of 4 digits entered";
  - `shake()` runs about 300 ms, or does nothing with `disableAnimations`;
  - `PinKeypad` has 12 cells, every key ≥ 48 dp with a label ("1"…"0", "Delete", "Use
    fingerprint");
  - the biometric cell is empty when `showBiometric=false`;
  - all keys ignore taps when `enabled=false`;
  - a light haptic fires on each key (mock `SystemChannels.platform`).
- [X] T024 [P] [US1] Write `test/features/lock/pin_screen_test.dart` for set mode and change mode
  (disable mode is T029):
  - **SYS-04 AC1** "PIN cannot be set without matching confirmation": enter 1234, then confirm 1243
    → the dots shake, the confirm step restarts with the title "Confirm new PIN", and
    `FakeLockService.setPin` is never called. Confirm 1234 → `setPin('1234')`.
  - **US1-3**: with biometric `available`, after confirming, the "Use fingerprint / face unlock"
    switch and "Done" show. Turning the switch on calls `setBiometricEnabled(true)`. "Done" pops
    `true` and shows the snackbar "App lock is on". With `none`, it pops straight after confirming.
  - The session is marked unlocked after a successful set.
  - **Change mode**: current (wrong → `lock_wrongPin`, stays on the step) → new → confirm →
    `changePin` is called; pops `true` with "PIN changed".
  - **FR-041**: back at any step pops `false`, and no `LockService` write happens.
  - Backgrounding (`AppLifecycleState.hidden`) clears the partial entry.
  - **Rotation**: enter 2 digits, then switch `tester.view.physicalSize` from portrait to
    landscape. The entry is cleared, the step is unchanged, and an already-entered first PIN on the
    confirm step is kept.
- [X] T025 [P] [US1] Write `test/features/lock/unlock_screen_test.dart` (US1 parts; US2 extends it):
  - On open, it calls `secureScreenController.setUnlockVisible(true)` (assert
    `FakeSecureScreenService` got `setSecure(true)`), and `false` on dispose when `hideInRecents` is
    off (**SYS-03 AC3**).
  - With biometric enabled and `available`, the prompt shows automatically exactly once (**US1-8**).
    Cancelling leaves the keypad enabled. The biometric key shows the prompt again. With biometric
    off, there is no key and no prompt.
  - The 4th digit of a wrong PIN shakes, clears, and shows "Wrong PIN".
  - **Rotation**: entering 2 digits and then rotating clears the dots.
  - The correct PIN in route mode calls `router.go(from)` (it goes to `from`, or `/home` when
    absent). In overlay mode it calls `session.unlocked()`.
  - No `AppBannerAd`/`AppNativeAd`.
- [X] T026 [P] [US1] Write `test/app/router/redirect_test.dart`, extending the existing `redirectFor`
  tests:
  - **Rule 4**: when `lockEnabled && sessionLocked` in route mode, `/expenses/123` →
    `/lock?from=%2Fexpenses%2F123`. With `sessionLocked=false` → null. In overlay mode, `/habits` →
    `/lock?from=%2Fhabits`, `LockSession` switches to `route` mode, and the overlay is gone.
  - **Rule 4b**: on `/lock?from=/habits` with `sessionLocked=false` → `/habits`. On `/lock` with
    `lockEnabled=false` → `/home`.
  - **Rule 3 exception**: `/settings/security/pin?mode=set` is allowed before onboarding;
    `?mode=change` is not.

  Also add `test/app/bootstrap_test.dart` cases: `initialLocationFor` with lock on and payload
  `/habits` → `/lock?from=%2Fhabits`; with no payload → `/lock?from=%2Fhome`.
- [X] T027 [P] [US1] Write `test/app/lock_resume_test.dart` (**SYS-03 AC1**, US1-5/6/7, FR-044) with
  the real router, real modules on an in-memory DB, `FakeLockService` (PIN 1234), and `MutableClock`.
  Simulate the lifecycle with `tester.binding.handleAppLifecycleStateChanged`.
  - **(a) Lock after 1 min**: open EXP-03 for a seeded transaction from EXP-01.
    - Hide, advance 30 s, resume → no SYS-03.
    - Hide, advance 61 s, resume → `UnlockScreen` is visible, and the EXP-03 widgets are `Offstage`
      (`find.byType(TransactionDetailScreen, skipOffstage: false)` is found, and it is excluded from
      semantics).
    - Enter 1234 → EXP-03 is visible again. `Navigator.pop` returns to EXP-01.
  - **(b) Unsaved draft**: open EXP-02 and type amount 250 and a note. Lock and unlock → the same
    amount and note are present.
  - **(c) Notification tap while locked**: a tap on `/habits` while the overlay shows does not
    navigate. After unlock, HAB-01 is shown.
  - **(d) Immediately**: with `lockAfterSeconds=0`, the overlay is already present after `hidden`,
    before resume.
- [X] T028 [P] [US1] Write `test/app/lock_back_button_test.dart`: while the overlay shows on EXP-03,
  a simulated back (`tester.binding.handlePopRoute()`) calls `SystemNavigator.pop` (recorded through
  the `SystemChannels.platform` mock), and the route stack is unchanged. On the `/lock` route the
  same holds. When unlocked, back pops normally.
- [X] T029 [P] [US1] Write `test/features/settings/security_screen_test.dart` (US1 part):
  - with the lock off, tapping the App lock switch pushes `/settings/security/pin?mode=set`, and the
    switch stays off until `FakeSettingsRepository` emits `lockEnabled=true`;
  - with the lock on, turning it off pushes `?mode=disable`.

  In `pin_screen_test.dart`, add **SYS-04 AC2** "Disabling lock requires the current PIN": in
  disable mode, a wrong PIN shows "Wrong PIN", `disable` returns `UnlockWrong`, and the lock stays
  on. The correct PIN calls `disable('1234')`, pops `true`, and shows "App lock is off".

### Implementation for User Story 1

- [X] T030 [P] [US1] Create the shared lock widgets (contracts/screens.md "Shared within
  features/lock"):
  - `lib/features/lock/presentation/widgets/pin_dots.dart`: a `PinDotsController` with `shake()`,
    a tokens-based size, and the semantics `lock_dotsLabel`.
  - `lib/features/lock/presentation/widgets/pin_keypad.dart`: a 3×4 grid, `onDigit`,
    `onBackspace`, an optional `onBiometric`, `enabled`, `HapticFeedback.lightImpact`, and
    `ExcludeSemantics` digits with explicit labels.
- [X] T031 [US1] Create SYS-04:
  - `lib/features/lock/presentation/controllers/pin_controller.dart` + `pin_state.dart`: a family
    on `PinFlowMode`. State: `step: PinFlowStep {current, enterNew, confirmNew, offerBiometric,
    done}`, `entered` (length only exposed to UI), private `_firstEntry`, `error`, and
    `biometricOffer`. It handles the steps per contracts/screens.md "SYS-04" and clears `_firstEntry`
    in `ref.onDispose`.
  - `lib/features/lock/presentation/screens/pin_screen.dart`: full screen, the title per step,
    `PinDots` + `PinKeypad`, and the offerBiometric step with a `SwitchListTile` and "Done". It pops
    `bool`, shows the snackbar through `rootMessengerKey`, and clears the current entry on
    `AppLifecycleListener.onHide` and when `MediaQuery.orientationOf(context)` changes (checked in
    `didChangeDependencies`). The manifest handles orientation changes itself, so the screen is
    not rebuilt from scratch.
  - Replace the T021 placeholder builder for `Routes.pin`.
- [X] T032 [US1] Create SYS-03 (US1 scope):
  - `lib/features/lock/presentation/controllers/unlock_controller.dart` + `unlock_state.dart`
    (`status`, `enteredLength`, `error`, `biometricAvailable`, `biometricPromptShown`).
  - `lib/features/lock/presentation/screens/unlock_screen.dart`:
    - `UnlockScreen({required LockMode mode, String? from})`;
    - registers `setUnlockVisible` in `initState`/`dispose`;
    - clears the entered digits when `MediaQuery.orientationOf(context)` changes
      (`didChangeDependencies`), as in SYS-04;
    - shows the auto biometric prompt once via `addPostFrameCallback`;
    - on success, in route mode `context.go(from ?? Routes.home)`, otherwise
      `final pending = session.unlocked(); if (pending != null) router.go(pending);`;
    - route mode wraps in `PopScope(canPop: false, onPopInvokedWithResult: (_, _) => SystemNavigator.pop())`.

  Replace `LockPlaceholderScreen` in `/lock` (reading `from` from the query), and delete
  `lib/features/lock/presentation/screens/lock_placeholder_screen.dart` and its test references.
- [X] T033 [US1] Wire the router and the app:
  - `lib/app/router/app_router.dart`:
    - `redirectFor` gains `required bool sessionLocked` (no mode parameter: rule 4 applies in both
      modes). When rule 4 fires while in overlay mode, the `/lock` route's `initState` switches
      `lockSessionProvider` to route mode, which removes the overlay;
    - implement rules 3 (exception), 4, and 4b exactly per contracts/routes.md;
    - `refreshListenable` also listens to `lockSessionProvider`.
  - `lib/app/bootstrap.dart`: `initialLocationFor` returns
    `Routes.lockPath(from: payload ?? Routes.home)` when the lock is on. Update its doc comment.
  - Create `lib/app/router/lock_back_button_dispatcher.dart`: `LockAwareBackButtonDispatcher extends
    RootBackButtonDispatcher`, overriding `didPopRoute` to call `SystemNavigator.pop()` and return
    `true` while `lockSessionProvider.locked`.
  - `lib/app/app.dart`:
    - switch `MaterialApp.router` to `routerDelegate`/`routeInformationParser`/
      `routeInformationProvider` from the `GoRouter`, plus
      `backButtonDispatcher: LockAwareBackButtonDispatcher(ref)`;
    - add a `builder` that, when `locked && mode == overlay`, returns
      `Stack(children: [Offstage(child: child), const UnlockScreen(mode: LockMode.overlay)])`;
    - extend the `AppLifecycleListener` with `onHide`/`onPause` → `markBackgrounded(clock.now())`
      and `onResume` → `onResumed(clock.now())` before `AppOpenRunner.run()`;
    - change the notification `taps` listener to `deferLocation(payload)` while locked, else
      `go(payload)`;
    - read `secureScreenControllerProvider` once.
- [X] T034 [US1] Create SET-05 (US1 scope):
  - `lib/features/settings/presentation/controllers/security_controller.dart` + `security_state.dart`
    (from `appSettingsProvider` + `LockService.status()` + `biometricAvailability()`).
  - `lib/features/settings/presentation/screens/security_screen.dart`: the App lock switch (pushes
    `pinPath('set')` or `pinPath('disable')`) and Change PIN (pushes `pinPath('change')`; enabled
    only when the lock is on).

  Replace the T021 placeholder for `Routes.security`. The remaining rows come in US3.
- [X] T035 [US1] Wire the external-activity guard (research R15):
  - `lib/core/share/text_sharer.dart` and `lib/core/share/image_sharer.dart` call
    `expectExternalActivity()` before `SharePlus.instance.share`. Pass the guard through their
    providers.
  - `lib/features/expense/data/receipts/image_receipt_picker.dart` gets `ExternalActivityGuard`
    through `expense_bindings.dart` and calls it before `pickImage`.

  Add one test each in the existing sharer and picker tests: the guard was called.

**Checkpoint**: US1 is fully functional. SYS-03 AC1 and AC3 and SYS-04 AC1 and AC2 pass.

---

## Phase 4: User Story 2 - Stop guessing, and recover from a forgotten PIN (Priority: P1)

**Goal**: 5 wrong PINs → 30 s lockout, then each wrong PIN doubles it up to 15 min (Q1). It survives
restart, biometrics clear it (Q3), and "Forgot PIN?" erases everything after typing DELETE.

**Independent Test**: Enter 5 wrong PINs, see the countdown, restart, see it continue, and then
erase via "Forgot PIN?" to land on onboarding (quickstart §4 steps 5–6).

### Tests for User Story 2 ⚠️

- [X] T036 [P] [US2] Write `test/core/security/lockout_policy_test.dart` (research R4, data-model
  §2 transitions) with `Clock.fixed`/`MutableClock`:
  - **Lengths**: `lengthFor(1..7)` = 30 s, 60 s, 120 s, 240 s, 480 s, 900 s, 900 s.
  - **Counting before the first lockout**: failures 1–4 stay at level 0, with
    `attemptsLeftBeforeLockout` null, null, 2, 1. Failure 5 → level 1, locked for 30 s.
  - **Warning after a lockout**: `nextLockoutLength` is null at level 0 and while locked. After
    the level 1 lockout ends it is 60 s; after level 5 it is 900 s; after level 6 it stays 900 s.
  - **Expiry**: `remaining` at +29.999 s is > 0; at +30 s it is 0.
  - **Q1 sequence**: after expiry, 1 failure → level 2, 60 s. Repeat through level 7 (900 s cap).
  - `registerSuccess()` → `failedAttempts 0, level 0`.
  - **Clock moved back** 1 h during a lockout: `remaining` ≤ the full length, and the state
    re-anchors.
  - **Clock moved forward** past `lockedUntil`: the lockout is over (the documented limit).
  - JSON round-trips. Corrupt JSON → initial state.
- [X] T037 [P] [US2] Extend `test/core/security/secure_lock_service_test.dart`:
  - **Lockout during verify**: 5 wrong `verifyPin` → the 5th returns `UnlockLockedOut(30 s)`. During
    the lockout, `verifyPin('1234')` returns `UnlockLockedOut` **without hashing** (the hashing
    runner was not called).
  - **SYS-03 AC2** "Lockout timer survives app restart": build a **new** `SecureLockService` over
    the same `InMemorySecureStore` at +10 s → `lockoutRemaining()` = 20 s.
  - **Persist before returning**: the store already holds the new `lock.lockout` when the
    `verifyPin` future completes (use a recording store).
  - `unlockWithBiometrics` success during a lockout → the state resets (Q3).
  - `changePin` and `disable` with a wrong current PIN count toward the same lockout (FR-039).
  - **Fails safe**: a store read error on `lock.lockout` while `lock.pin` exists →
    `UnlockLockedOut(15 min)`.
- [X] T038 [P] [US2] Extend `test/features/lock/unlock_screen_test.dart`:
  - **US2-1**: the 3rd wrong attempt shows "Wrong PIN. 2 attempts left", and the 4th shows 1.
    After the 30 s lockout ends, the screen shows "Next wrong PIN locks the app for 1:00" (live
    region). A successful unlock removes the warning.
  - **US2-2**: the 5th disables the keypad and shows "Try again in 0:30". Advancing the clock and
    pumping 1 s steps counts down. At 0 the keypad is enabled.
  - **US2-4**: opening SYS-03 with a persisted 20 s lockout shows "Try again in 0:20" immediately.
  - **US2-6**: during a lockout, the biometric key is still enabled, and success unlocks.
  - **credentialUnavailable**: no keypad, the explanation text, and only "Forgot PIN?".
  - **US2-7/8**: "Forgot PIN?" opens the sheet. Cancel keeps the lockout countdown. "Erase all data"
    starts the `EraseAllDataFlow` (`FakeAppResetService` is called only after `DELETE`).
- [X] T039 [P] [US2] Write `test/core/widgets/erase_all_data_flow_test.dart` (FR-047):
  - the first dialog lists what will be deleted; cancel → no reset;
  - Continue → `TypedConfirmDialog`; typing `delete`, `DELETE ` (with a trailing space), or `DELET`
    keeps "Erase everything" disabled; `DELETE` enables it; cancel → no reset;
  - confirm → the progress state, then `FakeAppResetService.eraseAll` is called once;
  - a failing reset shows "Couldn't erase your data. Nothing was deleted." with "Try again", which
    retries.

  Also write `test/core/widgets/typed_confirm_dialog_test.dart` (the exact-match rule, the
  destructive button uses the `error` color, no autocorrect).
- [X] T040 [P] [US2] Write `test/app/erase_flow_test.dart` with real modules on an in-memory DB and
  the real `DriftAppResetService`, plus fake notifications and a fake lock. Go through "Forgot PIN?"
  → erase. The app lands on `/onboarding`, the seeded default categories and the Cash account exist
  again (reseeded once), `lockEnabled` is false, and the session is unlocked.

### Implementation for User Story 2

- [X] T041 [US2] Create `lib/core/security/domain/lockout_policy.dart` (pure Dart, contracts/services.md):
  - `LockoutState` (freezed or a hand-written immutable class with `toJson`/`fromJson`; fields
    `failedAttempts`, `level`, `lockedAtUtcMs?`, `lockedUntilUtcMs?`);
  - `LockoutPolicy` with `attemptsBeforeFirstLockout = 5`, `base = 30 s`, `max = 15 min`,
    `lengthFor`, `registerFailure`, `registerSuccess`, `remaining` (re-anchors when
    `now < lockedAt`), and `attemptsLeftBeforeLockout` ("non-null only at level 0 with failed ≥ 3"), and
    `nextLockoutLength` ("level ≥ 1 and not locked: lengthFor(level + 1); else null").
- [X] T042 [US2] Integrate the lockout into `lib/core/security/data/secure_lock_service.dart`:
  - `verifyPin`, `changePin`, and `disable` all read `lock.lockout` first and return `lockedOut`
    without hashing while it is active;
  - a failure goes through `registerFailure` and is persisted before returning;
  - a success goes through `registerSuccess`;
  - `unlockWithBiometrics` success → `registerSuccess`;
  - `lockoutRemaining()` and `nextLockoutLength()`;
  - a storage error → max lockout (fail safe).

  The clock comes from an injected `Clock`, read from `clockProvider` in `security_providers.dart`.
- [X] T043 [P] [US2] Create the erase UI shared in core:
  - `lib/core/widgets/typed_confirm_dialog.dart`;
  - `lib/core/widgets/erase_all_data_flow.dart` (`Future<void> showEraseAllDataFlow(BuildContext,
    WidgetRef)`: `ConfirmDialog` → `TypedConfirmDialog(word: 'DELETE')` → a non-dismissible progress
    dialog → `appResetServiceProvider.eraseAll()` → error dialog with "Try again" on failure).
- [X] T044 [US2] Finish SYS-03:
  - `unlock_controller.dart`:
    - map `UnlockWrong(attemptsLeft, nextLockout)` and `UnlockLockedOut(remaining)`;
    - when a lockout ends (the ticker reaches 0) and on open, read `nextLockoutLength()` and show
      `lock_nextLockoutWarning` with `m:ss` until a successful unlock;
    - a 1 s `Timer.periodic` ticker while locked out (cancelled on dispose and when it reaches 0);
    - keep the biometric key enabled during a lockout;
    - the `credentialUnavailable` state.
  - `unlock_screen.dart`: the countdown text uses `lock_tryAgainIn` with `m:ss`. Add the live
    region.
  - Create `lib/features/lock/presentation/widgets/forgot_pin_sheet.dart` (`AppBottomSheet` with the
    title, body, "Erase all data" → `showEraseAllDataFlow`, and "Cancel"). Hook it to the "Forgot
    PIN?" `TextButton`.
  - `pin_screen.dart`/`pin_controller.dart`: show the same countdown and disable input during a
    lockout (spec edge case).

**Checkpoint**: The lock is safe to ship. SYS-03 AC2 passes. US1 and US2 make up the security MVP.

---

## Phase 5: User Story 3 - Manage app lock settings (Priority: P2)

**Goal**: SET-05 completes with Change PIN, biometric, Lock after, and Hide in recents.

**Independent Test**: With a PIN set, change it, switch biometrics, change "Lock after", toggle
"Hide in recents", and turn the lock off, confirming each effect (quickstart §4 step 9).

### Tests for User Story 3 ⚠️

- [X] T045 [P] [US3] Extend `test/features/settings/security_screen_test.dart`:
  - **US3-4**: with the lock off, Change PIN, biometric, and Lock after are disabled with the
    subtitle "Turn on app lock first".
  - **US3-5**: availability `notEnrolled` or `none` → the biometric switch is disabled with the
    matching subtitle.
  - **US3-6**: switching biometric on calls `setBiometricEnabled(true)`. A fake cancel leaves it
    off.
  - **Lock after**: the sheet shows 3 radio options, and choosing "After 5 minutes" writes `300`.
  - **US3-7**: the Hide in recents switch writes `hideInRecents`, and `FakeSecureScreenService` gets
    `setSecure(true)`.
  - **US3-1**: Change PIN → pushes `pinPath('change')`; a `true` result shows "PIN changed".
  - With US1's `lock_session_test`, **US3-8** (Immediately) is covered.

### Implementation for User Story 3

- [X] T046 [US3] Complete `lib/features/settings/presentation/screens/security_screen.dart` and
  `security_controller.dart` per contracts/screens.md "SET-05":
  - the biometric switch, with disabled reasons from `BiometricAvailability`;
  - the Lock after row with an `AppBottomSheet` of `RadioListTile`s;
  - the Hide in recents switch with its help subtitle;
  - every row with a semantic label.

**Checkpoint**: SET-05 is complete.

---

## Phase 6: User Story 4 - Change general preferences from the More tab (Priority: P2)

**Goal**: The SET-01 General section, plus the shared full-date format applied app-wide (Q5).

**Independent Test**: Change language, currency, first day of week, and date format, restart, and
see each persisted and applied (quickstart §4 step 11).

### Tests for User Story 4 ⚠️

- [X] T047 [P] [US4] Write `test/core/utils/date_formats_test.dart`. For 5 March 2026:
  - `dMMMy` → `5 Mar 2026`, `ddMMy` → `05/03/2026`, `mmddy` → `03/05/2026`, `iso` → `2026-03-05`
    in `en`;
  - `gu` and `hi` produce localized month names for `dMMMy`;
  - `formatFullDateTime` appends the localized `jm` time;
  - an unknown storage value → `dMMMy`.
- [X] T048 [P] [US4] Extend `test/features/settings/settings_screen_test.dart`:
  - **US4-1**: the section order is General, Appearance, Modules, Notifications, Security, Data,
    Privacy, About (+ Developer in dev). There is no backup, export, premium, or ad-privacy row, and
    no ad widget.
  - **US4-2**: Language → ગુજરાતી writes `gu`, and the screen re-renders in Gujarati in the same
    pump sequence, keeping its scroll offset. "System default" writes `null`.
  - **SET-01 AC** "Changing currency changes formatting only; stored amounts are not converted": with
    a real in-memory DB, a transaction of 125000 paise shows ₹1,250.00 on EXP-01. Set USD → $1,250.00
    and `amountMinor` stays 125000. Back to INR → ₹1,250.00.
  - **US4-4**: First day of week → Sunday writes `7`. Only Monday, Saturday, and Sunday are offered.
  - **US4-5**: the Date format sheet shows today in all 4 formats; choosing `dd/MM/yyyy` writes
    `ddMMy`.
- [X] T049 [P] [US4] Extend `test/core/utils/period_test.dart` and the habit
  `test/features/habit/domain/streak_engine_test.dart` with `firstDayOfWeek` 6 (Saturday) and 7
  (Sunday) cases: `WeekPeriod` bounds and `timesPerWeek` week boundaries. Extend
  `test/features/expense/presentation/transaction_detail_screen_test.dart` (**US4-5**): with
  `dateFormat=ddMMy`, the detail shows `05/03/2026`, and the EXP-01 list header still shows
  `EEE, d MMM`.

### Implementation for User Story 4

- [X] T050 [P] [US4] Create `lib/core/utils/date_formats.dart`:
  - `enum FullDateFormat { dMMMy('d MMM y'), ddMMy('dd/MM/y'), mmddy('MM/dd/y'), iso('y-MM-dd') }`
    with `fromStorage`;
  - `formatFullDate(DateTime local, FullDateFormat f, String locale)`;
  - `formatFullDateTime(...)`.

  Add `@riverpod FullDateFormat fullDateFormat(Ref ref)` to
  `lib/core/settings/settings_providers.dart`.
- [ ] T051 [US4] Migrate the 10 full-date call sites (research R13) to `formatFullDate` /
  `formatFullDateTime` with `ref.watch(fullDateFormatProvider)`. Pass the format as a parameter where
  the site is a pure function.
  - Habit: `lib/features/habit/presentation/widgets/habit_calendar.dart` (`dayLabel`),
    `lib/features/habit/presentation/widgets/freeze_card.dart:145`,
    `lib/features/habit/presentation/screens/habit_form_screen.dart:521`,
    `lib/features/habit/presentation/screens/archived_habits_screen.dart:74`.
  - Expense: `lib/features/expense/presentation/widgets/repeat_section.dart:99`,
    `lib/features/expense/presentation/widgets/recurring_row.dart:58`,
    `lib/features/expense/presentation/widgets/occurred_at_chips.dart:57`,
    `lib/features/expense/presentation/controllers/transaction_detail_controller.dart:58`,
    `lib/features/expense/presentation/screens/transaction_detail_screen.dart:259` (keeps a leading
    `EEE, `).
  - Core: `lib/core/utils/period.dart:201` (`CustomPeriod.label` takes the format).

  Leave `relativeDayLabel`, month and year labels, and week ranges unchanged. Update affected
  existing tests to the `d MMM y` default output. Remove the `skip:` from the T012 date-format scan.
  The new default changes date text on screens covered by golden images: EXP-02
  (`occurred_at_chips.dart`) for certain, and check HAB-01, DSH-01, and EXP-01. On Linux, run
  `flutter test --tags golden --update-goldens test/goldens/`, review every changed image, and
  confirm that only date text changed. Commit the new baselines with this task.
- [X] T052 [US4] Move the currency list to core:
  - Move the searchable currency list out of
    `lib/features/onboarding/presentation/widgets/currency_step.dart` into
    `lib/core/widgets/currency_picker_list.dart` (`CurrencyPickerList({selected, onSelected})`).
  - `currency_step.dart` now wraps it. Move the list's tests to
    `test/core/widgets/currency_picker_list_test.dart`, and keep the onboarding tests green.
- [X] T053 [US4] Add the General section to SET-01:
  - `lib/features/settings/presentation/widgets/general_pickers.dart`: the language sheet (System
    default + 3 native names), the currency sheet (`CurrencyPickerList`), the first day sheet
    (Monday/Saturday/Sunday), and the date format sheet (each option rendered with today's date).
  - Add the controller write methods (`setLocale`, `setCurrency`, `setFirstDayOfWeek`,
    `setDateFormat`) to `settings_controller.dart`.
  - Rows show the current value as subtitle.

**Checkpoint**: The General section works, and full dates follow the setting app-wide.

---

## Phase 7: User Story 5 - Personalize the look (Priority: P2)

**Goal**: SET-04 with theme mode, 8 seed themes (6 gated via `FeatureGate`), a live preview with
`LockedFeatureOverlay` for locked themes, and font size.

**Independent Test**: Change mode, theme, and font size; confirm immediate and persistent effect.
Premium themes are locked until the dev unlock switch is turned on (quickstart §4 step 10).

### Tests for User Story 5 ⚠️

- [X] T054 [P] [US5] Write `test/core/theme/color_themes_test.dart`:
  - the catalog has exactly the 8 ids of data-model §4, in order, with `default` and `indigo` free;
  - `colorThemeById('x')` → default;
  - **WCAG AA** for every seed in light and dark: `primary`/`onPrimary` ≥ 4.5:1 and
    `surface`/`onSurface` ≥ 4.5:1. If a seed fails, adjust it in `app_colors.dart` and update
    data-model §4.
  - `AppTheme.light(seed: x)` keeps the `AppTokens` income, expense, warning, and success values and
    the `TextTheme` identical to the default (FR-016).
- [X] T055 [P] [US5] Write `test/core/theme/effective_color_theme_test.dart` with `FakeFeatureGate`:
  - a stored free theme → itself;
  - a stored premium theme while locked → `default`; the gate emits unlocked → the premium theme,
    with no settings write;
  - the gate emits locked again → `default` (FR-020, US5-5).
- [X] T056 [P] [US5] Write `test/core/theme/app_text_scaler_test.dart`: with factor 1.15, system 1.0
  → 1.15; 1.5 → 1.725; 2.0 → 2.0 (capped); default font → identity.
- [X] T057 [P] [US5] Write `test/features/settings/themes_screen_test.dart`:
  - **US5-1**: Dark writes `dark`, and the `MaterialApp` `themeMode` becomes dark within one pump.
  - **US5-2**: tapping Indigo writes `indigo`, and the preview and app primary colors use the indigo
    scheme.
  - **US5-3**: 6 tiles have a lock icon and a "Pro" chip, with a label like "Saffron, Pro, locked".
    Tapping Saffron writes nothing; the preview card shows `LockedFeatureOverlay` with no "Watch an
    ad" button and a disabled "Get Pro".
  - **US5-4**: the debug unlock emits → the badges disappear live, and tapping Saffron writes
    `saffron`.
  - **US5-6**: Large writes `large`.
  - Every tile is ≥ 48 dp.

### Implementation for User Story 5

- [X] T058 [P] [US5] Theme core:
  - `lib/core/theme/app_colors.dart`: add `seedIndigo` #4F46E5, `seedSaffron` #D97706,
    `seedForest` #15803D, `seedRose` #E11D48, `seedMidnight` #1E3A8A, `seedOcean` #0369A1, and
    `seedMono` #525252.
  - Create `lib/core/theme/color_themes.dart` (`AppColorTheme`, `appColorThemes`,
    `colorThemeById`, with ids equal to `colorThemeIds`).
  - `lib/core/theme/app_theme.dart`: `light({Color seed = AppColors.seed})` and
    `dark({Color seed = AppColors.seed})`.
  - Create `lib/core/theme/app_text_scaler.dart` (factor 1.15, `maxScale` 2.0).
- [X] T059 [US5] Create `lib/core/theme/theme_providers.dart`:
  - `effectiveColorThemeProvider` (keep-alive stream combining `appSettingsProvider.select(selectedTheme)`
    and `featureGateProvider.watch(FeatureKey.premiumTheme(id))` for premium ids);
  - `colorThemeUnlockedProvider(id)`.

  Wire `lib/app/app.dart`: `theme`/`darkTheme` from the effective seed, `themeMode` from settings,
  and the builder wraps the child in `MediaQuery(textScaler: AppTextScaler(...))` when
  `fontSize == 'large'`, inside the lock overlay `Stack`.
- [X] T060 [US5] Create SET-04:
  - `lib/features/settings/presentation/controllers/themes_controller.dart` + `themes_state.dart`
    (`previewThemeId` screen-local, never persisted for locked themes);
  - `lib/features/settings/presentation/widgets/theme_preview_card.dart` (a sample summary card,
    progress bar, `AmountText`, and chip in `Theme(data: …)`, wrapped in `LockedFeatureOverlay(
    onWatchAd: null, onGetPro: null, message: l10n.themes_lockedMessage)` when the preview is
    locked);
  - `lib/features/settings/presentation/widgets/theme_tile.dart` (swatch + name + check/lock icon +
    "Pro" chip, with semantics `themes_tileLabel`);
  - `lib/features/settings/presentation/screens/themes_screen.dart` (preview → mode `ChipSelector` →
    an adaptive colors grid with a min tile of 96 dp → font `ChipSelector`).

  Replace the T021 placeholder for `Routes.themes`.

**Checkpoint**: SET-04 is complete, and the dev unlock unlocks the premium themes live.

---

## Phase 8: User Story 6 - Control notifications (Priority: P3)

**Goal**: The Notifications section: the master switch, the daily summary time (stored only), budget
alerts, and habit reminders (only when the Habit module is on, Q2).

**Independent Test**: Turn the master off and see habit reminders cancelled and the rows disabled.
Set a time and see it persist (quickstart §4 step 12).

### Tests for User Story 6 ⚠️

- [X] T061 [P] [US6] Extend `test/features/settings/settings_screen_test.dart` ("notifications"),
  with `FakeTrackerModule`s for `expense` and `habit` recording `onNotificationSettingsChanged`:
  - **US6-1**: master off → writes `notificationsEnabled=false`. The other 3 rows are disabled and
    keep their values. The hook is called on both visible modules.
  - **US6-2**: budget alerts off → writes `false`, and the hook is called.
  - **US6-4**: with `habit` enabled, the Habit reminders row is shown, and toggling it writes and
    calls the hook. With `habit` disabled, the row is absent.
  - **US6-3**: the daily summary time opens `showTimePicker`; choosing 20:30 writes `20:30`, and the
    row shows "8:30 PM" (`alwaysUse24HourFormat: false`) or "20:30" (`true`).
  - **US6-5**: master on with `FakeNotificationService.canNotify == false` → the blocked note and
    "Open settings" (the fake launcher records `openNotificationSettings`).
  - No daily summary notification is scheduled (`FakeNotificationService.schedule` is not called).

### Implementation for User Story 6

- [X] T062 [P] [US6] Create `lib/core/support/external_launcher.dart`:
  - the `ExternalLauncher` interface;
  - `UrlLauncherExternalLauncher`, which calls `expectExternalActivity()` first in each method;
    `email` uses a `mailto:` `Uri` with encoded subject and body; `openNotificationSettings` uses
    `app-settings:`, falling back to `NotificationPermission.request()`;
  - `externalLauncherProvider`, bound in `production_overrides.dart`, plus `FakeExternalLauncher`.
- [X] T063 [US6] Create `lib/features/settings/presentation/widgets/notifications_section.dart` and
  the controller methods in `settings_controller.dart`:
  - each switch writes via the repository, then calls `onNotificationSettingsChanged(ref.read)` on
    `moduleRegistry.visible(settings)` (best effort);
  - the Habit reminders row is shown when `visibleModuleIds.contains('habit')`;
  - the daily summary row uses `showTimePicker` and `MaterialLocalizations.formatTimeOfDay`;
  - the blocked note uses `NotificationService.canNotify()`, re-checked on resume.

**Checkpoint**: Notifications preferences are complete.

---

## Phase 9: User Story 7 - Erase all data (Priority: P3)

**Goal**: The SET-01 Data section offers Erase all data with double confirmation, ending on
onboarding.

**Independent Test**: Seed data, erase with the double confirmation, and land on onboarding with no
data, default settings, no PIN, and no notifications (quickstart §4 step 6).

### Tests for User Story 7 ⚠️

- [X] T064 [P] [US7] Extend `test/features/settings/settings_screen_test.dart`:
  - **US7-1..4**: the Data section has only "Erase all data", in the `error` color. Tapping it runs
    the shared flow; cancelling at either step calls no reset; confirming with `DELETE` calls
    `FakeAppResetService.eraseAll` once.
  - Extend `test/app/erase_flow_test.dart` with the SET-01 entry path (same assertions as T040).

### Implementation for User Story 7

- [X] T065 [US7] Add the Data section to `lib/features/settings/presentation/screens/settings_screen.dart`:
  one `ListTile` "Erase all data" (`error`-colored text and icon `Icons.delete_forever_outlined`
  with a semantic label) → `showEraseAllDataFlow(context, ref)`.

**Checkpoint**: Erase is reachable from both SET-01 and "Forgot PIN?".

---

## Phase 10: User Story 8 - Privacy, help, and app information (Priority: P3)

**Goal**: The Privacy section (in-app web view) and the About section (rate, share, feedback,
version, licenses).

**Independent Test**: Tap each row and see the right page, sheet, or app (quickstart §4 step 13).

### Tests for User Story 8 ⚠️

- [X] T066 [P] [US8] Write `test/core/support/feedback_email_test.dart`:
  - the subject contains the app version;
  - the body lists the app version and build, Android release and SDK, manufacturer and model, and
    the device language (from an injected locale, not `AppSettings.locale`);
  - with the app language set to `gu` and the device locale `en_IN`, the body says `en_IN` and
    does not contain `gu`;
  - the body contains no amount, category, habit name, note, or settings value (build it from a
    fully seeded fake state and assert none of the seeded strings appear).
- [X] T067 [P] [US8] Write `test/features/settings/web_page_screen_test.dart` with a fake
  `WebViewPlatform` (`webview_flutter_platform_interface` test doubles):
  - `privacy` loads `AppLinks.privacyPolicyUrl` with JavaScript disabled;
  - a `WebResourceError` shows `ErrorState` with `web_loadError` and "Try again", which reloads;
  - an off-host navigation request is prevented and passed to `FakeExternalLauncher.openUrl`;
  - an unknown `:page` redirects to `/more`.
- [X] T068 [P] [US8] Extend `test/features/settings/settings_screen_test.dart` ("about"):
  - Rate us → `FakeAppReviewService.rateApp`;
  - Share app → `FakeTextSharer` received `settings_shareAppText` with the store URL;
  - Send feedback → `FakeExternalLauncher.email`; when it returns `false`, a dialog with the support
    address and "Copy email" (which writes the clipboard);
  - App version shows "1.0.0 (1)" from `FakeAppInfoSource`;
  - Open-source licenses → `LicensePage` is pushed;
  - Privacy policy and Terms push `/more/web/privacy` and `/more/web/terms`.

### Implementation for User Story 8

- [X] T069 [P] [US8] Create the support core:
  - `lib/core/config/app_links.dart` (`privacyPolicyUrl`, `termsUrl`, `supportEmail` via
    `String.fromEnvironment` with placeholder defaults, plus a `storeUrl(String packageName)`
    helper);
  - `lib/core/support/app_info_source.dart` (`package_info_plus`);
  - `lib/core/support/device_info_source.dart` (`MethodChannel('dailytrack/window')`
    `getDeviceInfo`);
  - `lib/core/support/app_review_service.dart` (`InAppReview.instance`: `isAvailable` →
    `requestReview`, otherwise `openStoreListing()`, guarded by `expectExternalActivity()`);
  - `lib/core/support/feedback_email.dart` (pure builder).

  Add providers and their fakes, and bind them in `production_overrides.dart`.
- [X] T070 [US8] Create the web view and the Privacy and About sections:
  - `lib/features/settings/presentation/controllers/web_page_controller.dart` and
    `lib/features/settings/presentation/screens/web_page_screen.dart` (contracts/screens.md "Web
    page"). Replace the T021 placeholder for `Routes.webPage`.
  - `lib/features/settings/presentation/widgets/about_section.dart`, plus the Privacy and About
    sections in `settings_screen.dart`. The App version subtitle comes from the controller's
    `AppInfo`; the licenses row calls `showLicensePage(context: context, applicationVersion: …)`.

**Checkpoint**: SET-01 is complete.

---

## Phase 11: User Story 9 - Set app lock during onboarding (Priority: P3)

**Goal**: SYS-02 step 4 "Set app lock" opens SYS-04 and returns. The user is not asked to unlock
afterwards.

**Independent Test**: Onboard, set a PIN at step 4, tap "Get started", and see no SYS-03 until the
next lock event (quickstart §4 step 1).

### Tests for User Story 9 ⚠️

- [X] T071 [P] [US9] Extend `test/features/onboarding/privacy_step_test.dart` and
  `test/features/onboarding/onboarding_screen_test.dart`:
  - **US9-1**: step 4 shows "Set app lock" (key `onboarding_set_app_lock`) under "Allow
    notifications".
  - **US9-2**: tapping it pushes `/settings/security/pin?mode=set` (allowed by the rule 3
    exception). On a `true` result with `lockEnabled` now true, the step shows "App lock is on" and
    the button reads "Change PIN". Tapping "Get started" lands on `/home` with no `UnlockScreen`.
  - **US9-3**: a `false` result keeps the lock off.

### Implementation for User Story 9

- [X] T072 [US9] Update the onboarding files:
  - `lib/features/onboarding/presentation/widgets/privacy_step.dart`: add `appLockOn` and
    `onSetAppLock` parameters, the `OutlinedButton.icon` (lock icon), and the status row. Remove the
    "hidden until SYS-04 exists" doc note.
  - `lib/features/onboarding/presentation/controllers/onboarding_controller.dart` and `onboarding_screen.dart`:
    read `lockEnabled` from `appSettingsProvider`, and push `Routes.pinPath('set')` (or `'change'`) with
    `context.push<bool>`.

  Check that `docs/spec.md` SYS-02 step 4 no longer says the button is hidden. Edit it to "shown
  from T3.1" (that wording is already present).

**Checkpoint**: All user stories are functional.

---

## Phase 12: Polish & Cross-Cutting Concerns

**Purpose**: Accessibility, notification-tap regression, docs, the design review, and the quality
gates

- [X] T073 [P] Write `test/a11y/settings_font_scale_test.dart` (SC-010). Cover SET-01, SET-04,
  SET-05, SYS-03 (including the lockout and `credentialUnavailable` states), SYS-04 (each step), the
  erase dialogs, and onboarding step 4:
  - at 200% text scale on a 360×780 dp surface, in en, hi, and gu, light and dark;
  - no `RenderFlex` overflow;
  - `androidTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` pass;
  - SET-04 with Large font at 200% system scale → the effective scale is 2.0 and there is no
    overflow.
- [X] T074 [P] Extend `test/app/notification_tap_test.dart` (SC-001): a tap while the app runs
  locked is deferred and opened after unlock. A cold-start launch payload with the lock on goes
  `/lock?from=<payload>` → payload after unlock. With the lock off, behavior is unchanged.
- [ ] T075 [P] Update `docs/CLAUDE.md`:
  - "Lock state: `settings.lockEnabled` is the switch; the PIN and lockout live only in
    `flutter_secure_storage` via `LockService` (`lib/core/security/`)";
  - "Erase goes through `AppResetService`; modules clean their own files and alarms in
    `TrackerModule.onEraseAll`";
  - "Apps the user opens from DailyTrack (share, camera, email) call `ExternalActivityGuard` first".

  Check that `docs/spec.md` §4, §5, SYS-03, SET-01, and SET-04 match the final code (the
  2026-10-21 Changes entry). Tick `T3.1` in §14 only after T077 passes.
- [X] T076 Run the §15.10 design review checklist on SET-01, SET-04, SET-05, SYS-03, SYS-04, the
  web page, and onboarding step 4 (excluding the ad items, which are out of scope). Fix findings and
  record the results for the summary. Confirm the screens without an empty state match the plan's
  Complexity Tracking list; any other screen without one fails review.
- [ ] T077 Run the quality gates and fix all findings:
  - `dart run build_runner build --delete-conflicting-outputs`;
  - `flutter analyze` (zero warnings);
  - `dart format --set-exit-if-changed .`;
  - `flutter test --exclude-tags golden` on Windows, plus `flutter test` on Linux/CI;
  - `flutter test --tags golden` on Linux/CI, with no baseline updates needed after T051;
  - `flutter build apk --flavor dev --debug` (AppCompat and FragmentActivity link).

  Then walk through quickstart.md §4 on a device or emulator. Include the API 26 biometric prompt
  check (research R2) and the `FLAG_SECURE` screenshot and recents checks. On a mid-range device
  (about 4 GB RAM), time 5 PIN unlocks from the 4th digit to the first unlocked frame (debug
  overlay or `flutter run --profile` timeline). The median must be ≤ 300 ms for verification and
  < 3 s overall, and the biometric prompt must appear < 1 s after SYS-03 opens (SC-002). If
  verification is over 300 ms, lower the default iteration count in `PinHasher` (records keep their
  own `iter`, research R3), update T008, and note it in the summary. Write the task summary:
  files changed, tests added, §15.10 results, and open items (Drive restore in Forgot PIN and the
  backup/export rows → T3.2/T3.3; the daily summary notification → T3.4; the SET-01 banner, premium
  card, "Ad privacy choices", and "Watch an ad" for themes → feature 008).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies. T001 comes before T003 (the Gradle sync needs the plugins).
  T002 comes before T003.
- **Foundational (Phase 2)**: depends on Setup and blocks all stories.
  - T007 → T013, T016, T017 (settings fields).
  - T009 + T010 → T013 → T014.
  - T016 → T018/T019 (the reset uses the session).
  - T019 → T020.
  - T021 → T022.
- **User stories**: all depend on Phase 2.
  - **US1 (P1)**: no story dependency.
  - **US2 (P1)**: extends the US1 screens (T032) and the service (T013). Run it after US1.
  - **US3 (P2)**: extends the US1 SET-05 (T034).
  - **US4 (P2)**: independent of US1–US3.
  - **US5 (P2)**: independent. Its T059 edits `app.dart` after T033; serialize those edits.
  - **US6 (P3)**: independent. It needs T019/T020 hooks (foundational).
  - **US7 (P3)**: needs T043 (the erase flow from US2). If US2 is not done, do T039 + T043 first.
  - **US8 (P3)**: independent. It shares T062 `ExternalLauncher` with US6; if US6 is not done, do
    T062 first.
  - **US9 (P3)**: needs the US1 SYS-04 (T031) and the rule 3 exception (T033).
- **Polish**: after the desired stories. T073 needs all screens.

### Within Each User Story

- Tests are written first and fail, then implementation follows.
- Pure domain code (hasher, policy, rules, formats) comes before data adapters, which come before
  controllers, which come before screens, which come before app wiring.
- Run codegen after each `@riverpod`/`@freezed` change.

### Parallel Opportunities

- **Phase 1**: T004 runs alongside T001–T003.
- **Phase 2**: T006, T008, T010, T011, T012, T015, T017, and T018 (tests and pure types, different
  files); T020 runs after T019.
- **US1**: tests T023–T029 in parallel; T030 runs alongside T031's controller once T023 exists.
- **US2**: tests T036–T040 in parallel; T043 runs alongside T041/T042.
- **US4/US5**: T047–T049 and T054–T057 in parallel; T050 and T058 in parallel.
- **Stories**: after US1, the stories US4, US5, US6, and US8 touch disjoint files except
  `settings_screen.dart`, `settings_controller.dart`, and `app.dart`. Serialize edits to those three.
- **Polish**: T073, T074, and T075 in parallel.

---

## Parallel Example: User Story 2

```text
# Tests together:
Task: "T036 test/core/security/lockout_policy_test.dart"
Task: "T037 test/core/security/secure_lock_service_test.dart (lockout cases)"
Task: "T038 test/features/lock/unlock_screen_test.dart (lockout + forgot PIN)"
Task: "T039 test/core/widgets/erase_all_data_flow_test.dart + typed_confirm_dialog_test.dart"
Task: "T040 test/app/erase_flow_test.dart"

# Then, in parallel:
Task: "T041 lib/core/security/domain/lockout_policy.dart"
Task: "T043 lib/core/widgets/typed_confirm_dialog.dart + erase_all_data_flow.dart"
```

## Parallel Example: User Story 5

```text
Task: "T054 test/core/theme/color_themes_test.dart"
Task: "T055 test/core/theme/effective_color_theme_test.dart"
Task: "T056 test/core/theme/app_text_scaler_test.dart"
Task: "T057 test/features/settings/themes_screen_test.dart"
```

---

## Implementation Strategy

### MVP First (P1 stories)

1. Phase 1 Setup (packages, Android host, strings), then Phase 2 Foundational (settings keys, lock
   core, session, secure screen, erase core, routes, SET-01 shell).
2. US1: set a PIN, unlock on start and resume with screens kept, back closes. **Validate**: SYS-03
   AC1/AC3, SYS-04 AC1/AC2, quickstart §4 steps 2–4.
3. US2: lockout and Forgot PIN. **Validate**: SYS-03 AC2, quickstart §4 steps 5–6. **The MVP is
   done**: the app lock is safe to ship.

### Incremental Delivery

4. US3 (finish SET-05) → US4 (General + date format) → US5 (themes).
5. US6 (notifications) → US7 (erase from SET-01) → US8 (privacy/about) → US9 (onboarding lock).
6. Polish: a11y, notification taps, docs, design review, gates.

---

## Notes

- [P] means different files and no dependency on an incomplete task.
- The copied acceptance criteria map to:
  - SET-01 AC → T048
  - SYS-03 AC1 → T027 (and T025)
  - SYS-03 AC2 → T037 (and T038)
  - SYS-03 AC3 → T025 (plus the manual check in T077)
  - SYS-04 AC1 → T024
  - SYS-04 AC2 → T029
- Out of scope, and no placeholders left for them (§15.8): the SET-01 banner, premium card, "Ad
  privacy choices", "Watch an ad" for themes, backup and export rows, Drive restore in Forgot PIN,
  and the daily summary notification.
- Commit after each task or logical group, with the Screen ID in the message (e.g. `SYS-03: add
  lockout policy`).
