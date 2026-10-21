# Implementation Plan: Settings, Themes, and App Lock (SET-01, SET-04, SET-05, SYS-03, SYS-04, T3.1)

**Branch**: `007-settings-themes-app-lock` | **Date**: 2026-10-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/007-settings-themes-app-lock/spec.md`

## Summary

This feature replaces the More placeholder and the lock placeholder with these screens
(`docs/spec.md` §5, §6, §10, §14 T3.1):
- **SET-01** Settings: General, Appearance, Modules, Notifications, Security, Data, Privacy, About,
  and a dev-only Developer section.
- **SET-04** Themes: mode, 8 seed themes (6 gated), live preview, and font size.
- **SET-05** Security.
- **SYS-03** Unlock and **SYS-04** Set / change PIN, backed by a new `LockService`.

**Approach**:
- **Lock core** (`lib/core/security/`, research R3–R6, R18):
  - `LockService` sits over three ports: secure storage, `local_auth`, and the pure `PinHasher`
    (PBKDF2-SHA256 in an isolate).
  - `LockoutPolicy` is pure: 5 attempts, then 30 s; every later wrong PIN doubles the lockout up to
    15 min (Q1). Biometrics clear it (Q3). It survives restart and moving the clock back, and is
    tested with an injected `Clock`.
- **Routing** (R7, user request):
  - Cold start goes through the go_router redirect (`/lock?from=`).
  - Resume is driven by the `AppLifecycleListener`. The lock covers the app as an overlay (the router
    stays mounted `Offstage`), so the open screens and unsaved input survive (Q4).
  - A lock-aware back button dispatcher closes the app.
  - Notification taps are deferred until unlock.
  - Exits the app starts itself (camera, share, email) don't trigger "Immediately" (R15).
- **`SecureScreenService`** (R9): `FLAG_SECURE` through a method channel. It is on while SYS-03 shows,
  or app-wide with "Hide app content in recents".
- **Themes** (`lib/core/theme/`, R11–R12):
  - a seed catalog;
  - an effective theme that falls back to Teal while locked, live from `FeatureGate`;
  - `AppTextScaler` for Large (×1.15, combined scale capped at 200%);
  - locked themes preview behind `LockedFeatureOverlay`.
- **Settings** (R13, R14, R17):
  - new setters;
  - one shared full-date formatter applied to the 10 existing full-date call sites (Q5);
  - module hooks for notification toggles and the Habit reminders row (Q2);
  - About and Privacy through small core ports (review, launcher, app and device info, web view).
- **Erase all data** (R16): `AppResetService` deletes every Drift row in one transaction. Then module
  `onEraseAll` hooks run, notifications and `lock.*` are cleared, and bootstrap reruns into
  onboarding. The flow is shared by SET-01 and "Forgot PIN?".
- **Android** (R2, R8, R9): `FlutterFragmentActivity`, AppCompat launch themes, `USE_BIOMETRIC`,
  `allowBackup="false"`, and the `dailytrack/window` channel.
- **No schema change**: 5 new settings keys, and secure-storage entries for the lock.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Existing (spec §2): `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0,
  `drift` 2.35, `freezed` 4.0, `intl` 0.20, `clock` 1.1, `share_plus` 13.3,
  `flutter_local_notifications` 22.3.
- **New** (user-specified, research R1): `local_auth` ^3.0.2, `flutter_secure_storage` ^11.2.0,
  `cryptography` ^2.9.0, `in_app_review` ^2.0.12, `url_launcher` ^6.3.3, `package_info_plus` ^10.2.2,
  `webview_flutter` ^4.14.1.

**Storage**:
- SQLite through Drift `AppDatabase`, schema **v4 unchanged**. It gains 5 `settings` keys
  (`dateFormat`, `dailySummaryTime`, `lockAfterSeconds`, `hideInRecents`, `fontSize`) and setters
  for 5 existing ones.
- `flutter_secure_storage` holds `lock.pin` and `lock.lockout`.

See [data-model.md](data-model.md).

**Testing**: `flutter_test` + `mocktail`.
- **Unit tests** cover:
  - `PinHasher` (fast iterations + one production-parameter vector) and `LockoutPolicy` (every level,
    cap, clock back);
  - `SecureLockService` over an in-memory store and `shouldLockOnResume`, using
    `Clock.fixed`/`MutableClock`;
  - `redirectFor`, the codec, `FullDateFormat`, `AppTextScaler`, and theme contrast.
- **Data tests** cover `DriftAppResetService` on an in-memory database.
- **Widget tests** cover each screen with fakes and `NoAdsService`.
- **App-level widget tests** use the real router: resume keeps the EXP-02 draft, back closes the app,
  and a notification tap while locked is deferred.
- **No new golden screens**: the constitution lists DSH-01, EXP-01, EXP-02, and HAB-01 only.
  Existing EXP-02 (and any other affected) baselines are regenerated in T051, because the default
  full-date format changes.
- **Manual device checks**: `FLAG_SECURE`, real biometrics, and the API 26 AppCompat prompt
  (quickstart §4).

**Target Platform**: Android API 24+ (iOS-ready code, not tested)

**Project Type**: Mobile app (single Flutter project)

**Performance Goals**:
- PIN verification ≤ 300 ms on a mid-range device, with hashing in an isolate (unlock under 3 s,
  SC-002).
- The biometric prompt shows within 1 s of SYS-03 opening.
- Theme, mode, font, and language changes apply within one frame sequence (< 300 ms, SC-006).
- No added cold-start cost when the lock is off. Lock status reads one setting that is already loaded.

**Constraints**:
- Offline, except the policy/terms web pages and the store, email, and review intents the user
  starts.
- The PIN never leaves secure storage. No user data goes in the feedback email.
- No ads on these screens (SET-01 banner is feature 008).
- ARB strings in en, hi, and gu with placeholders. 200% font scale and 360 dp width. Status never by
  color only.

**Scale/Scope**:
- 5 screens built (SET-01, SET-04, SET-05, SYS-03, SYS-04), 1 helper screen (web page), and
  1 onboarding step changed.
- 2 placeholders deleted.
- About 6 new core ports/services and 2 `TrackerModule` hooks.
- 10 date call sites migrated.
- About 120 new ARB keys × 3 languages.
- Android host: 1 activity, 4 style files, the manifest, and Gradle.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs used; spec updated before code | ✅ `docs/spec.md` was updated on 2026-10-21. The Changes line, SYS-03 lockout and biometric rule (Q1, Q3), §5 resume keeps screens (Q4), the SET-01 Habit reminders toggle (Q2), the §4 new settings keys and secure-storage note, and the SET-04 locked-theme behavior before PRM-02. Tests and files use `SET-01/04/05`, `SYS-03/04` |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; registry; one notifier per screen | ✅ Lock, theme, reset, and support logic live in `lib/core/` behind domain interfaces. Plugins are confined to `data/` adapters, and `core/security/domain` is pure Dart. Settings and lock talk only through `core/` and routes. Onboarding pushes the SYS-04 route and imports nothing from `features/lock`. Settings reaches modules only through two new optional `TrackerModule` hooks and `moduleRegistry.visible`. Each screen has one controller (R19). The layering scan is extended (R20). `WebPageScreen` uses `webview_flutter` directly; it is a UI widget, not data access |
| III. Data integrity & privacy | int money; UTC ms; migrations; no egress; PIN only as salted hash in secure storage | ✅ The PIN is stored only as PBKDF2-SHA256 + random salt in `flutter_secure_storage` (R3). No schema change, so no migration. Currency change formats only (SET-01 AC). `allowBackup="false"` stops the OS backup from copying data off-device (R8). The feedback email carries device and app facts only, with the device language rather than the app language setting (R14). Erase deletes every row in one transaction (R16). The soft-delete rule (`deletedAt`) does not apply here: "Erase all data" is the user's explicit request to destroy all data, and soft-deleted rows would survive in later backups and contradict "erase". Constitution 1.0.1 allows this exception (Complexity Tracking) |
| IV. Test-backed acceptance | ≥ 1 test per criterion; fakes + NoAdsService | ✅ The 6 copied acceptance criteria and every user story are mapped in [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests). The pure lock logic is unit tested at its boundaries with an injected clock. No new golden screens are required by the constitution |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; ARB; 48 dp; 200%; never color only | ✅ Uses `AppScaffold`, `SettingsSection`, `ChipSelector`, `ConfirmDialog`, `AppBottomSheet`, `ErrorState`, `LockedFeatureOverlay`, and the new shared `TypedConfirmDialog`, `EraseAllDataFlow`, and `CurrencyPickerList`. Each screen has loading, error, and content states. SET-01, SET-04, SET-05, SYS-03, and SYS-04 always show a fixed set of rows or keys, so there is no data whose absence would need an empty state. Constitution 1.0.1 allows this, and Complexity Tracking lists it. The web page screen's "nothing loaded" case is its error state. Lock badges and toggle states use text and icons. Large font is capped at the 200% envelope (R11) |
| VI. Isolated monetization | ads only via AdService; none on lock or forms | ✅ By exclusion: no ad code. SYS-03 and SYS-04 never get ads. The SET-01 banner, premium card, "Ad privacy choices", and "Watch an ad" for themes are deferred to feature 008, with nothing in their place (§15.8) |
| VII. Locked stack, YAGNI | §2 packages only; new deps justified | ✅ `local_auth` and `flutter_secure_storage` are in §2. `cryptography`, `in_app_review`, `url_launcher`, `package_info_plus`, and `webview_flutter` were named by the user and are each needed for one listed SET-01 or SYS-03 behavior (R1). `device_info_plus` and a `FLAG_SECURE` plugin were avoided with the existing channel. Drive restore, the backup and export rows, and the daily summary notification stay out |

**Result**: PASS. **After Phase 1 design**: PASS, with the two items below justified in Complexity
Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/007-settings-themes-app-lock/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R20
├── data-model.md        # Phase 1: settings keys, secure entries, lockout and session states, theme catalog, erase steps
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── services.md      # LockService, LockSession, SecureScreenService, AppResetService, TrackerModule hooks, settings/theme/support APIs
│   ├── routes.md        # new routes, redirect rules 3/4/4b, MaterialApp.router wiring
│   └── screens.md       # SET-01, SET-04, SET-05, SYS-03, SYS-04, onboarding step 4, web page, shared widgets
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
android/app/
  build.gradle.kts                            # + androidx.appcompat if not transitive (R2)
  src/main/AndroidManifest.xml                # USE_BIOMETRIC, allowBackup="false"
  src/main/kotlin/.../MainActivity.kt         # FlutterFragmentActivity; + dailytrack/window (setSecure, getDeviceInfo)
  src/main/res/values{,-night,-v31,-night-v31}/styles.xml   # AppCompat parents
lib/
  app/
    app.dart                                  # router delegate wiring, LockAwareBackButtonDispatcher, builder (text scaler + lock overlay), effective theme, lifecycle → LockSession, deferred taps
    bootstrap.dart                            # initialLocationFor → /lock?from=
    production_overrides.dart                 # bind lock, secure screen, reset, support, launcher providers
    router/app_router.dart                    # redirect rules 3/4/4b; SettingsScreen, Themes, Security, Pin, WebPage, UnlockScreen routes
    router/routes.dart                        # lockPath, pin, themes, security, webPage
    router/lock_back_button_dispatcher.dart   # NEW
  core/
    security/
      domain/{lock_service,pin_hasher,lockout_policy,lock_types,secure_key_value_store,biometric_authenticator,lock_rules}.dart  # NEW, pure
      data/{secure_lock_service,flutter_secure_key_value_store,local_auth_biometric_authenticator}.dart  # NEW
      lock_session.dart                       # NEW notifier
      external_activity_guard.dart            # NEW
      secure_screen_service.dart              # NEW port + channel impl + controller
      security_providers.dart                 # NEW
    reset/
      domain/app_reset_service.dart           # NEW
      data/drift_app_reset_service.dart       # NEW
      reset_providers.dart                    # NEW
    support/                                  # NEW app_review_service, app_info_source, device_info_source, external_launcher, feedback_email
    config/app_links.dart                     # NEW
    theme/
      app_colors.dart                         # + 7 seeds
      color_themes.dart                       # NEW catalog
      app_theme.dart                          # seed parameter
      app_text_scaler.dart                    # NEW
      theme_providers.dart                    # NEW effectiveColorTheme, colorThemeUnlocked
    settings/                                 # app_settings (+5 fields), codec (+5 keys, validation), repository (+10 setters), providers (+fullDateFormat)
    utils/date_formats.dart                   # NEW FullDateFormat, formatFullDate(Time)
    utils/period.dart                         # CustomPeriod.label uses the setting
    module/tracker_module.dart                # + onEraseAll, onNotificationSettingsChanged
    notifications/notification_service.dart   # + cancelAll (+ impl)
    share/{text_sharer,image_sharer}.dart     # expectExternalActivity before sharing
    widgets/{settings_section,typed_confirm_dialog,erase_all_data_flow,currency_picker_list}.dart  # NEW (currency list moved from onboarding)
    l10n/app_{en,hi,gu}.arb                   # + settings_*, themes_*, security_*, lock_*, pin_*, erase_*, about_*
  features/
    settings/presentation/
      controllers/{settings,themes,security,web_page}_controller.dart (+ states)   # NEW
      screens/{settings,themes,security,web_page}_screen.dart                      # NEW (more_placeholder_screen.dart deleted)
      widgets/{theme_preview_card,theme_tile,general_pickers,notifications_section,about_section}.dart  # NEW
    lock/presentation/
      controllers/{unlock,pin}_controller.dart (+ states)                          # NEW
      screens/{unlock,pin}_screen.dart                                             # NEW (lock_placeholder_screen.dart deleted)
      widgets/{pin_dots,pin_keypad,forgot_pin_sheet}.dart                          # NEW
    onboarding/presentation/
      widgets/privacy_step.dart               # + Set app lock / App lock is on
      widgets/currency_step.dart              # uses core CurrencyPickerList
      controllers/onboarding_controller.dart  # + lock status
    expense/
      expense_module.dart                     # + onEraseAll (receipts), onNotificationSettingsChanged
      data/receipts/image_receipt_picker.dart # expectExternalActivity
      presentation/...                        # 6 full-date call sites → formatFullDate (R13)
    habit/
      habit_module.dart                       # + onEraseAll, onNotificationSettingsChanged
      presentation/...                        # 4 full-date call sites → formatFullDate (R13)
test/
  helpers/fakes.dart                          # FakeLockService, FakeBiometricAuthenticator, InMemorySecureStore, FakeSecureScreenService, FakeAppResetService, FakeExternalLauncher, FakeAppReviewService, settings fake + setters, FakeTrackerModule hooks
  core/{security,reset,theme,settings,utils,support,widgets}/
  app/{router/redirect_test,lock_resume_test,lock_back_button_test,erase_flow_test,notification_tap_test}.dart
  features/{lock,settings,onboarding}/
  a11y/settings_font_scale_test.dart          # NEW
  android/                                    # manifest + MainActivity assertions
```

**Structure Decision**: Single Flutter project, following the existing feature-first layout and the
user's folder choices:
- `LockService` and `SecureScreenService` in `lib/core/security/`;
- theme logic in `lib/core/theme/`;
- screens in `lib/features/settings/` and `lib/features/lock/`.

Erase all data lives in `lib/core/reset/`, because both features use it (Constitution II).

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| Resume lock is an overlay over an `Offstage` router, plus a custom back button dispatcher, not only a go_router redirect (R7) | Clarification Q4 requires the same screen, back history, and unsaved input after unlock. A redirect to `/lock` disposes the tab shell and root-navigator modals | Redirect-only loses EXP-02/HAB-02 drafts on every resume lock. A pageless pushed route is dropped when go_router rebuilds pages, which happens on every resume because `AppOpenRunner` writes `latestSeenAt`. The redirect is still used for cold start and as the guard, as the user asked |
| Two new optional `TrackerModule` hooks (`onEraseAll`, `onNotificationSettingsChanged`) | Erasing receipts and reminder alarms, and reconciling notifications after a toggle, are module-owned. Settings may not import modules | Per-module code in settings breaks Constitution II. Running all of `AppOpenRunner` after a toggle is too broad (R17) |
| Erase all data hard-deletes every row (Constitution III requires soft delete; exception added in constitution 1.0.1) | FR-047/048 and the SYS-03 "Forgot PIN?" path promise that the data is gone. Soft-deleted rows would still be on disk and would come back in a T3.2 backup | Soft delete only hides the data. Erasing the database file would mean restarting the Flutter engine (R16) |
| No empty state on SET-01, SET-04, SET-05, SYS-03, and SYS-04 (Constitution V requires four states; constitution 1.0.1 allows this for fixed controls) | These screens show a fixed list or keypad that is always there; only their data (values) loads or fails | An invented empty state could never be reached and would be untestable, which breaks Constitution IV |
| `android:allowBackup="false"` changes OS-level behavior | Restored secure storage is unreadable without its Keystore key. Auto Backup would also upload the database without the user's action, which spec §13 forbids | A partial `dataExtractionRules` still uploads the database (R8) |
