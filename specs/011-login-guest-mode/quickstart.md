# Quickstart: Login and Guest Mode

How to check feature 011 end to end. Design details are in [data-model.md](data-model.md) and [contracts/](contracts/); this file only says what to run and what to expect.

## 1. Prerequisites

- Feature 010 complete: its open tasks (T003, T041, T042, T064, T071, T083, T085, T090, T104–T106) done and its quality gates green (research R0).
- Flutter 3.47.7 / Dart 3.13.5, `flutter pub get`.
- New strings added in `tool/l10n/phase0_strings.py`, then `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`.

## 2. Quality gates (constitution)

```sh
dart run build_runner build --delete-conflicting-outputs
flutter analyze                         # zero warnings
dart format --set-exit-if-changed .
flutter test --exclude-tags golden      # Windows/macOS
flutter test --tags golden              # Linux/CI only
```

## 3. Focused test runs

| What | Command | Expect |
| --- | --- | --- |
| `authMode` migration, one test per case (R2) | `flutter test test/core/settings/auth_mode_migration_test.dart` | 9 cases green |
| Redirect rules (contracts/routes.md) | `flutter test test/app/router/redirect_test.dart` | every row, SYS-01 combinations |
| Start-up account checks (R5) | `flutter test test/core/account/account_service_test.dart test/app/android_restore_start_test.dart` | revoked → guest, offline stays google, leftover keys cleared, Android restore cases |
| AUTH-01 (11 ACs) | `flutter test test/features/auth/` | guest path records zero Google/Drive calls online and offline |
| SYS-02 (6 ACs) | `flutter test test/features/onboarding/` | no "Restore with Google", no "Set app lock" |
| SET-01 card and Log out of guest | `flutter test test/features/account/account_card_test.dart test/features/settings/settings_screen_test.dart` | guest/Google states, Q3 status mapping |
| Guest sign-in (§16, 3 ACs) | `flutter test test/features/account/guest_sign_in_test.dart` | SET-01, SET-02, ACC-04 entry points |
| ACC-03 (6 ACs) | `flutter test test/features/account/sign_out_sheet_test.dart` | AUTH-01 after both choices and after restart |
| ACC-04 (6 ACs) | `flutter test test/features/account/log_out_guest_test.dart test/core/reset/drift_app_reset_service_test.dart` | keep-lists per scope, failed erase changes nothing |
| No interim left | `rg -n "Replaced in 011\|interim I[1-8]" lib test` | no matches |
| Integration | `flutter test integration_test/login_flow_test.dart` (device or emulator) | Intro → AUTH-01 guest → data → ACC-04 → AUTH-01 → Google (fake) → restore → same data |

## 4. Device checks (dev flavor, real phone)

1. Fresh install → Intro → "Get started" → AUTH-01. Back closes the app; reopening shows AUTH-01, not Intro.
2. Airplane mode on AUTH-01: "Continue with Google" shows the offline error; "Continue as guest" opens Home and the "Finish setting up" sheet.
3. Install the previous release, finish onboarding (signed in on one phone, not on another), update to this build: neither sees AUTH-01; the signed-in one shows the Google card on More.
4. Signed in with app lock on: ACC-03 "Keep data" → AUTH-01 (no SYS-03 first) → "Continue as guest" → SYS-03 → Home with the same data.
5. Guest: More → "Log out of guest" → "Log out and delete" → AUTH-01; restart → AUTH-01; language and theme unchanged.
6. Remove the app's access in the Google account settings, restart: More shows the guest card, data intact.
