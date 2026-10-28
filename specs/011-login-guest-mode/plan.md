# Implementation Plan: Login and Guest Mode

**Branch**: `011-login-guest-mode` | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/011-login-guest-mode/spec.md`

## Summary

Add a sign-in mode, `authMode` (`none`, `guest`, `google`), as a settings key with a once-per-install migration in SYS-01. The go_router redirect reads it through `authModeProvider`, so `none` always lands on a new AUTH-01 Login screen, and leaving it goes to SYS-03 or Home. These parts are built on feature 010 without copying it:

- **AUTH-01** (`lib/features/auth/`) offers "Continue as guest", which makes no network call, and "Continue with Google". The Google path reuses `AccountService`, a new `AccountSignIn.login()`, and ACC-02 through the existing `AccountUi` port. It writes `authMode = google` only after the restore check settles.
- **The "Finish setting up" sheet** now follows every login.
- **SET-01 account card and ACC-04 Log out of guest** live in `lib/features/account/` and reach SET-01 through `AccountUi`.
- **One erase for every path.** ACC-04 reuses the existing erase through a second `EraseScope` that keeps device preferences, and SET-01 Erase all data, SYS-03 and ACC-03 keep onboarding and preferences too (clarification Q1).
- **ACC-03** signs out to `none`, and the redirect opens AUTH-01.
- **010's interim behavior is removed.** Every "Replaced in 011" path from the 010 plan (I1–I8) is deleted, including SYS-02 "Restore with Google" and the Intro app lock button.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: the `docs/spec.md` §2 stack, unchanged. That is `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0, `drift` 2.35 and `freezed` 4.0, plus `google_sign_in` 7.2.0 and `googleapis` 17.0.0 through 010's `GoogleAuth`/`DriveBackupStore`, `flutter_secure_storage` 11.2, and `in_app_purchase` 3.3.1 (Restore purchase through `ProService`). **New dependencies: none.**

**Storage**:
- No schema change: Drift stays at schema 5 and the backup `schemaVersion` is unchanged.
- New settings row `authMode`, never backed up.
- The existing `backupLeaseUntil` row is decoded read-only into `AppSettings`.
- `EraseScope` gives the erase two keep-lists.

See [data-model.md](data-model.md).

**Testing**: `flutter_test` + `mocktail` + `fake_async`, as in 010.
- **Pure unit tests**: `redirectFor` (every rule × `authMode` × lock), `initialLocationFor`, `AccountCardPolicy` (clarification Q3 mapping), and the `AuthMode` codec (unknown value → `none`).
- **Migration tests, one per case** (planning input; research R2): 9 cases over a real in-memory database (`makeRealContainer`), plus a bootstrap-order test.
- **Service tests**:
  - `AccountService` (`signIn` saves keys only, `commitSignIn`, `signOut(to:)` write order, `forgetAfterAuthLoss` → guest, `restoreSession` R5 table) over `FakeAccountAuth`.
  - `AccountSignIn.login()` outcomes over the fake Drive store.
  - `DriftAppResetService` with both scopes over a real in-memory database (keep-lists, a single transaction, a failed transaction deletes nothing, no Google call).
  - Auto backup gates read `authMode`.
- **Widget tests** (`pumpTestApp`, fakes, `NoAdsService`, no database): AUTH-01, SYS-02, the SET-01 card and Data row, guest sign-in from SET-01/SET-02/ACC-04, ACC-03, ACC-04, Finish setting up after login, and app lock after login. Each copied acceptance criterion gets a test named with its Screen ID.
- **Recording fakes** (planning input; research R13): `FakeAccountAuth.calls` with `FakeDriveBackupStore.calls`, checked with `expectNoGoogleCalls`.
- **Goldens**: AUTH-01 and the SET-01 account card (guest and Google), light/dark, English/Gujarati, rendered on Linux only.
- **Integration**: `integration_test/login_flow_test.dart` replaces 010's T103.

**Target Platform**: Android, min API 24, target the latest Play-required API (unchanged); iOS-ready, untested.

**Project Type**: Mobile app (Flutter, single project).

**Performance Goals**: cold start to Home stays under 1.5 s. The migration is one settings read plus at most one write, and the guest path adds no network read. AUTH-01 shows on the first frame after the splash because it reads no data. The account card shows local details at once, and the photo loads in the background.

**Constraints**:
- No Google or Drive call for a guest (spec FR-032, SC-002), proven by the recording fakes.
- `authMode == google` is never stored without account keys (research R3).
- No ad on AUTH-01 or ACC-04, or over AUTH-01 after ACC-04.
- Features don't import each other: SET-01 reaches the account card and ACC-04, SET-01 and SET-02 reach guest sign-in, and AUTH-01 reaches ACC-02, only through `AccountUi`.

**Scale/Scope**:
- New: 1 screen (AUTH-01), 1 card, 1 dialog.
- Changed: 6 existing screens (SYS-02, SET-01, SET-02, ACC-01, ACC-03, SYS-03), plus the router, bootstrap, `AccountService`, the erase, and auto backup gates.
- 42 copied acceptance criteria.

**Fixed-control screens without an empty state** (constitution V): AUTH-01 (a fixed set of buttons, it reads no data) and ACC-04 (a fixed dialog). The SET-01 account card has no empty state: `authMode` `none` never reaches SET-01.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | How |
| --- | --- | --- |
| I. Spec is the source of truth | Pass | Clarifications Q1–Q3 were recorded in `docs/spec.md` (§4, SET-01, SYS-03, Changes) before this plan. The planning input's `lib/features/auth/` was recorded in `docs/spec.md` §3 on 2026-10-27. Screen IDs AUTH-01, SYS-01, SYS-02, SET-01, ACC-01–ACC-04 are used throughout. The §14 interim note is removed when the feature is done (FR-040). |
| II. Layered, feature-first | Pass | `AuthMode`, `LoginOutcome`, `EraseScope` and `AccountCardPolicy` are pure Dart in `core/…/domain` or core services. `features/auth` and `features/account` import only `core/`; SET-01 uses the `AccountUi` port (R11) and AUTH-01 uses it for ACC-02 (R8). One Notifier per screen: `LoginController` (AUTH-01) and `LogOutGuestController` (ACC-04, a dialog). The SET-01 account card reads the plain `accountCardViewProvider`, so SET-01 keeps `SettingsController` as its only Notifier. Guest sign-in reaches SET-02 through `AccountUi.startGuestSignIn`, so settings imports nothing from the account feature. |
| III. Data integrity and privacy | Pass | Both erase scopes run one transaction, and a failure deletes nothing. ACC-03 "Remove data" and ACC-04 are named entry points of the Erase all data exception (constitution 1.1.2), and both reuse the same erase. `authMode` and the lease are never backed up. A guest sends nothing anywhere, and the erase no longer calls Google. PIN, lockout and backup password are still deleted locally only. |
| IV. Test-backed acceptance | Pass | All 42 copied criteria map to tests (Testing above, quickstart §3). Migration has one test per case. Widget tests use fakes and `NoAdsService`. Goldens cover the new screens. |
| V. Offline-first, fast, accessible | Pass | "Continue as guest" works offline, and signing in stays optional. The guest path adds no network read and the migration is one row. AUTH-01 and ACC-04 are fixed-control screens, declared above. Every screen gets the §15.10 checklist, and strings go to the ARB files through `phase0_strings.py`. |
| VI. Respectful monetization | Pass | No ad slots on AUTH-01 or ACC-04, and a router-probe test confirms no interstitial over `/login`. |
| VII. Simplicity, locked stack | Pass | No new package. `EraseScope` (two values) replaces a free-form keep-list. The 010 interim code is deleted, not flagged. |

**Gate result**: pass. Prerequisite: feature 010's open tasks and quality gates (research R0).

**Post-design re-check (after Phase 1)**: still pass. Revised after `/speckit-analyze` (C1–C3): guest sign-in goes through the port, the card uses a plain provider, and constitution 1.1.2 names ACC-03 and ACC-04 in principle III. The design adds two members to the existing `AccountUi` port and one parameter to `eraseAll`. `ConfirmDialog` may gain an optional third action for ACC-04, which is a shared-widget change with its own widget test (contracts/screens.md). No Complexity Tracking entry needed.

## Project Structure

### Documentation (this feature)

```text
specs/011-login-guest-mode/
├── plan.md              # This file
├── research.md          # Phase 0: R0–R15
├── data-model.md        # Phase 1: authMode, EraseScope, view types
├── quickstart.md        # Phase 1: gates, focused runs, device checks
├── contracts/
│   ├── routes.md        # /login, redirect rules 3b, 3c, 7
│   ├── services.md      # SettingsRepository, AccountService, AccountSignIn, AccountUi, AppResetService, bootstrap, fakes
│   └── screens.md       # AUTH-01, SYS-02, SET-01 card + Data row, ACC-04, ACC-01/03 and SYS-03 changes
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
lib/
  app/
    app.dart                          # authMode listener: lock session on login/logout (R7)
    bootstrap.dart                    # migrateAuthMode first; Android-restore authMode; lock start condition
    production_overrides.dart         # erase scopes; AccountFeatureUi binding
    auto_backup_task.dart             # gate on authMode == google (R4)
    router/routes.dart                # Routes.login, RouteNames.login
    router/app_router.dart            # /login route; authModeProvider listen; rules 3b, 3c, 7; settingPin removed
  core/
    settings/domain/app_settings.dart       # AuthMode enum, authMode, backupLeaseUntil
    settings/domain/settings_repository.dart # setAuthMode, migrateAuthMode
    settings/data/settings_codec.dart       # authMode key, lease decode
    settings/data/settings_repository_impl.dart
    settings/settings_providers.dart        # authModeProvider
    account/account_service.dart            # signIn / commitSignIn / signOut(to:) / restoreSession (R3, R5)
    account/account_sign_in.dart            # LoginOutcome, login()
    account/account_ui.dart                 # accountCard(), showLogOutGuest(), startGuestSignIn()
    account/account_providers.dart          # accountCardViewProvider (plain provider)
    account/domain/account_card_view.dart   # AccountCardView, CardStatus (pure)
    backup/auto_backup_schedule.dart        # authMode gate
    backup/background_backup_scheduler.dart # authMode gate
    backup/domain/backup_status_policy.dart # AccountCardPolicy
    backup/domain/backup_settings_policy.dart # authMode never restored (assert)
    reset/domain/app_reset_service.dart     # EraseScope
    reset/data/drift_app_reset_service.dart # keep-lists per scope; no Google call
    widgets/confirm_dialog.dart             # optional secondary action (if needed)
  features/
    auth/presentation/
      screens/login_screen.dart             # AUTH-01 (new feature folder)
      controllers/login_controller.dart     # + login_state (freezed)
    account/presentation/
      account_feature_ui.dart               # AccountUi impl (moved from restore_choice_sheet.dart)
      widgets/account_card.dart             # SET-01 item 1 (reads core accountCardViewProvider)
      widgets/guest_sign_in.dart            # runGuestSignIn, behind AccountUi.startGuestSignIn
      widgets/log_out_guest_dialog.dart     # ACC-04
      controllers/log_out_guest_controller.dart
      screens/account_screen.dart           # interim I4 removed; Switch account → guest
      widgets/sign_out_sheet.dart           # no navigation; signOut(to: none)
      controllers/account_controller.dart, sign_out_controller.dart
    onboarding/presentation/…               # Restore with Google and Set app lock removed (I2)
    settings/presentation/screens/settings_screen.dart  # card first; Log out of guest row
    settings/presentation/screens/backup_screen.dart     # Drive card sign-in = guest sign-in (unchanged flow)
    lock/presentation/widgets/forgot_pin_sheet.dart, screens/unlock_screen.dart  # Q2 commit rule; erase scope
tool/l10n/phase0_strings.py                 # new strings (R15)
test/
  helpers/backup_fakes.dart                 # FakeAccountAuth.calls, expectNoGoogleCalls
  helpers/fakes.dart, helpers/test_app.dart # FakeSettingsRepository authMode/migration, FakeAppResetService.scopes, drive param, FakeBootstrap
  core/settings/auth_mode_migration_test.dart
  core/account/account_service_test.dart, account_sign_in_test.dart
  core/reset/drift_app_reset_service_test.dart
  app/router/redirect_test.dart, app/bootstrap_auth_mode_test.dart, app/android_restore_start_test.dart
  features/auth/login_screen_test.dart, login_controller_test.dart
  features/onboarding/…                     # SYS-02 ACs
  features/account/account_card_test.dart, guest_sign_in_test.dart, log_out_guest_test.dart, sign_out_sheet_test.dart
  features/settings/settings_screen_test.dart
  goldens/auth_golden_test.dart, goldens/account_card_golden_test.dart
integration_test/login_flow_test.dart
```

**Structure Decision**: the single Flutter project with feature-first layout, as in features 001–010. As the planning input asked, AUTH-01 is a new `lib/features/auth/` feature, and the account card and ACC-04 go in `lib/features/account/`. `authMode` lives in the settings repository and reaches the router through `authModeProvider`. Guest sign-in reuses `AccountService`, `AccountSignIn` and ACC-02 from 010, and ACC-04 reuses the erase through `EraseScope`.

## Replaced interim behavior (from `specs/010-google-account-backup/plan.md`)

Each row of 010's "Interim behavior until feature 011" table is replaced as research R14 lists. When this feature is done:
- `rg "Replaced in 011|interim I[1-8]" lib test` finds nothing.
- 010's T103 is marked replaced by `integration_test/login_flow_test.dart`.
- `docs/spec.md` §14 loses the "Interim until T3.6" note.

## Complexity Tracking

No constitution violations to justify.
