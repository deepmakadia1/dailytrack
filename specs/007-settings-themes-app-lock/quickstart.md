# Quickstart: Settings, Themes, and App Lock (T3.1)

How to check that the feature works.
- Contracts: [services.md](contracts/services.md), [routes.md](contracts/routes.md),
  [screens.md](contracts/screens.md).
- Data: [data-model.md](data-model.md).
- Decisions: [research.md](research.md).

## 1. Prerequisites

- Flutter 3.47.7 / Dart 3.13.5 (unchanged).
- An Android emulator or device at API 24 or later. For biometrics, an emulator with a fingerprint
  enrolled (Settings → Security). For the "Android 8 and below" theme check, also one API 26
  emulator.
- Branch `007-settings-themes-app-lock`. Run `flutter pub get` after the packages from research R1
  are added.

## 2. Quality gates (constitution)

```sh
dart run build_runner build --delete-conflicting-outputs
flutter analyze                      # zero warnings
dart format --set-exit-if-changed .
flutter test                         # all green
```

## 3. Focused test runs

```sh
flutter test test/core/security/                     # PinHasher, LockoutPolicy, SecureLockService, LockSession, shouldLockOnResume
flutter test test/core/reset/                        # DriftAppResetService (in-memory DB, all-or-nothing)
flutter test test/core/theme/                        # color themes contrast, effective theme, AppTextScaler, layering scan
flutter test test/core/settings/                     # codec + new setters
flutter test test/core/utils/date_formats_test.dart  # FullDateFormat
flutter test test/app/router/                        # redirectFor rules 3, 4, 4b; lock/resume app-level tests
flutter test test/features/lock/                     # SYS-03, SYS-04, PinDots, PinKeypad
flutter test test/features/settings/                 # SET-01, SET-04, SET-05, web page, SET-06 (existing)
flutter test test/features/onboarding/               # step 4 "Set app lock"
flutter test test/android/                           # manifest + MainActivity checks
```

## 4. Manual walkthrough (dev flavor, real device or emulator)

1. **Onboarding lock**: fresh install. On step 4, tap "Set app lock", then enter 1234 and confirm
   1234. Turn fingerprint on, then tap Done. Step 4 shows "App lock is on". Tap "Get started": Home
   opens with no unlock prompt.
2. **Cold start**: force-stop and reopen the app. The fingerprint prompt appears; cancel it. Enter
   1234: Home opens. Try a screenshot on SYS-03: it is blocked. The recents preview of SYS-03 is
   blank.
3. **Resume keeps the form**: set Lock after = 1 min. Open + → Add expense, type 250 and a note,
   then press Home.
   - Return after 30 s: no lock.
   - Leave again for more than 1 min and return: SYS-03 shows. Unlock: the form still shows 250 and
     the note. Back goes to the screen under it.
4. **Back on lock**: while SYS-03 shows, press the system back button. The app closes, and reopening
   shows SYS-03 again.
5. **Lockout**:
   - Enter a wrong PIN 5 times: "Try again in 0:30".
   - Force-stop and reopen: the countdown continues.
   - After it ends, enter one wrong PIN: a 60 s lockout starts at once.
   - Use fingerprint during the lockout: it unlocks, and the next wrong PIN shows the attempt count
     again from the start.
6. **Forgot PIN**: on SYS-03, tap "Forgot PIN?" → Erase all data → confirm → type `delete` (the
   button stays disabled) → type `DELETE` → erase. Onboarding appears in the default state.
7. **Immediately + camera**: with Lock after = Immediately, attach a receipt photo in EXP-02. You
   return to the form without SYS-03. Then switch to another app and back: SYS-03 shows, and there
   is no flash of the form.
8. **Notification while locked**: enable a habit reminder 1 min ahead, background the app for more
   than 1 min, and tap the notification. SYS-03 shows first, and HAB-01 opens after unlocking.
9. **Security settings**:
   - Change the PIN (old → new → confirm); the old PIN stops working.
   - Turn the lock off: it asks for the current PIN.
   - Turn on "Hide app content in recents": recents is blank on every screen, and screenshots are
     blocked everywhere.
10. **Themes**:
    - Switch Dark, then Light, then System.
    - Pick Indigo: the app changes at once and keeps it after a restart.
    - Tap Saffron: only the preview changes, behind the lock overlay with "Get Pro" disabled.
    - In More → Developer, turn on "Unlock all features (debug)": the badges disappear, and Saffron
      applies.
    - Turn the debug switch off: the app shows Default Teal. Turn it on again: Saffron returns.
    - Font size Large at 200% system font: no clipping.
11. **General**:
    - Language → ગુજરાતી: everything switches at once and stays after a restart.
    - Currency → USD: ₹1,250.00 shows as $1,250.00, and switching back restores it.
    - First day of week → Sunday: the HAB-01 week strip and the weekly reports start on Sunday.
    - Date format → dd/MM/yyyy: EXP-03 shows 05/03/2026, and list headers are unchanged.
12. **Notifications**:
    - Turn the master switch off: the rows are disabled and the scheduled habit reminders are gone
      (`adb shell dumpsys alarm` shows none for the app).
    - Turn Habit reminders off and on: they are rescheduled.
    - Disable the Habit module: the Habit reminders row disappears.
13. **About and Privacy**:
    - Rate us asks for the review sheet (on an internal track build) or opens the store.
    - Share app opens the share sheet.
    - Send feedback opens an email with the version and device info and no user data.
    - Licenses opens the license list.
    - Privacy policy loads in-app. In airplane mode it shows the error with "Try again".
14. **Prod flavor**: the Developer section is absent.

## 5. Acceptance criteria → automated tests

| Criterion / scenario | Test |
| --- | --- |
| SET-01: Changing currency changes formatting only; stored amounts are not converted | `test/features/settings/settings_screen_test.dart` "currency change reformats only" (a real in-memory DB with a ₹1,250.00 transaction; switching to USD shows $1,250.00, `amountMinor` is still 125000, and switching back restores ₹) |
| SYS-03: Correct PIN unlocks and returns the user to the screen they were on before backgrounding | `test/app/lock_resume_test.dart` "resume lock keeps EXP-03 and back stack" + "keeps EXP-02 draft" (real router, `FakeLockService`, simulated lifecycle with `MutableClock`) |
| SYS-03: Lockout timer survives app restart | `test/core/security/secure_lock_service_test.dart` "lockout persists across service instances" (a new service over the same in-memory store resumes the remaining time) + `unlock_screen_test.dart` "shows the persisted countdown on open" |
| SYS-03: Screenshots are blocked on this screen (`FLAG_SECURE`) | `unlock_screen_test.dart` "sets secure on mount, clears on dispose unless hideInRecents" (fake `SecureScreenService` call log) + `test/android/main_activity_test.dart` (channel handler present) + manual §4.2 |
| SYS-04: PIN cannot be set without matching confirmation | `test/features/lock/pin_screen_test.dart` "mismatch shakes, restarts confirm, saves nothing" |
| SYS-04: Disabling lock requires the current PIN | `pin_screen_test.dart` "disable mode: wrong PIN keeps lock on; correct PIN turns it off" + `security_screen_test.dart` "turning off pushes disable mode" |
| US1 set from SET-05, biometric offer, cold start, lock after, back closes, auto prompt | `security_screen_test.dart`, `pin_screen_test.dart`, `test/app/router/redirect_test.dart` (rules 4/4b, `from`), `lock_session_test.dart` (`shouldLockOnResume` at 59/60/61 s, 0 s, clock back), `test/app/lock_back_button_test.dart` (`SystemNavigator.pop` observed), `unlock_screen_test.dart` "auto biometric once" |
| US2 lockout sequence, hint, reset, biometric during lockout, forgot PIN | `test/core/security/lockout_policy_test.dart` (all levels, cap, Q1 sequence, clock back/forward), `unlock_screen_test.dart` "attempts left from 3rd", "biometric clears lockout", "forgot PIN cancel keeps lockout", `erase_all_data_flow_test.dart` |
| US3 change PIN, disabled rows, biometric unavailable/confirm, hide in recents, immediately | `security_screen_test.dart`, `secure_screen_controller_test.dart`, `lock_session_test.dart` |
| US4 section order, language, first day, date format, dev section | `settings_screen_test.dart` (dev/prod via `debugToolsAvailableProvider`), `date_formats_test.dart`, `period_test.dart` + streak engine tests (Sat/Sun weeks), `test/core/theme/no_hardcoded_style_test.dart` (no `yMMMd` in features) |
| US5 theme mode, free theme, locked preview, debug unlock live, fallback, font size, seed-only | `themes_screen_test.dart`, `effective_color_theme_test.dart`, `color_themes_contrast_test.dart`, `app_text_scaler_test.dart`, `test/a11y/settings_font_scale_test.dart` |
| US6 master toggle, budget alerts, habit reminders row + reconcile, time, blocked note | `settings_screen_test.dart` "notifications" (fake modules record `onNotificationSettingsChanged`), `habit_module_test.dart` / `expense_module_test.dart` (hook behavior) |
| US7 erase double confirm, all-or-nothing, onboarding after | `test/core/reset/drift_app_reset_service_test.dart` (every table empty; a thrown transaction leaves all rows), `erase_all_data_flow_test.dart` (`delete` vs `DELETE`, cancel at each step), `test/app/erase_flow_test.dart` (lands on SYS-02, reseeded) |
| US8 web view, rate, share, feedback, version, licenses | `web_page_screen_test.dart` (fake `WebViewPlatform`: load error → "Try again"), `settings_screen_test.dart` "about" (fake launcher, review, sharer), `feedback_email_test.dart` (no user data) |
| US9 onboarding set app lock | `test/features/onboarding/privacy_step_test.dart`, `onboarding_screen_test.dart` "set lock then Get started: no unlock" |
| SC-001 no content before unlock (start, resume, notification, widget path) | `redirect_test.dart`, `lock_resume_test.dart` "overlay offstage hides semantics", `notification_tap_test.dart` extended ("tap while locked defers") |
| SC-006 changes within 300 ms, no restart | `themes_screen_test.dart` / `settings_screen_test.dart` "applies in one pump" |
| SC-010 200% / 360 dp, en/hi/gu, light/dark | `test/a11y/settings_font_scale_test.dart` (SET-01, SET-04, SET-05, SYS-03, SYS-04) |
| Layering (Constitution II) | `no_hardcoded_style_test.dart` extended (research R20) |
