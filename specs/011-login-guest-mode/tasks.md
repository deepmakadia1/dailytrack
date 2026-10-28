---

description: "Task list for feature 011 Login and Guest Mode"
---

# Tasks: Login and Guest Mode

**Input**: Design documents from `/specs/011-login-guest-mode/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ (routes.md, services.md, screens.md), quickstart.md

**Tests**: Required. Constitution IV says every acceptance criterion needs at least one automated test, and spec FR-044 says each copied criterion gets a test named with its Screen ID. Widget tests use `pumpTestApp` with fakes and `NoAdsService` and never open a database (docs/CLAUDE.md). Write each story's tests first and confirm they fail.

**Organization**: Tasks are grouped by the user stories in spec.md (US1–US7), so each story can be built and tested on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story (US1–US7) the task belongs to
- Paths are from the repository root (single Flutter project, plan.md "Project Structure")

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Gate on feature 010, add strings, and give tests fakes that record calls.

- [X] T001 Confirm feature 010 is complete before any other task (research R0). In `specs/010-google-account-backup/tasks.md`, T003, T041, T042, T064, T071, T083, T085, T090, T104 and T105 must be checked, and 010's quality gates must pass (`specs/010-google-account-backup/quickstart.md` §2). If any is open, stop and report it. Don't do 010's work under this feature. T103 stays open; T080 replaces it.

- [X] T003 [P] Extend the test fakes to record calls (research R13):
  - In `test/helpers/backup_fakes.dart`, give `FakeAccountAuth` a `final calls = <String>[]` that `signIn`, `signInSilently` and `signOut` append to (keep the counters).
  - In the same file, add `void expectNoGoogleCalls(FakeAccountAuth auth, FakeDriveBackupStore drive)`, which asserts that `auth.calls` and `drive.calls` are both empty.
  - In `test/helpers/test_app.dart`, add a `FakeDriveBackupStore? drive` parameter to `pumpTestApp` that overrides `driveBackupStoreProvider`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The `authMode` setting and its migration, the account service split, the redirect, the lock-session rule, the auto backup gates, and the erase scopes. Every story depends on them.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Tests for the foundation (write first)


- [X] T005 [P] Migration tests in `test/core/settings/auth_mode_migration_test.dart` over a real in-memory database (`makeRealContainer`), one test per case from research R2:
  1. fresh install (no rows) → `none`;
  2. onboarding not done, no email → `none`;
  3. onboarding not done, email set → `none`;
  4. onboarding done, no email → `guest`;
  5. onboarding done, email set → `google`;
  6. existing row `guest` unchanged, plus `google` and `none` unchanged (3 sub-cases);
  7. corrupt value `"x"` → row kept, decodes to `none`, not re-migrated;
  8. calling `migrateAuthMode()` twice → the second call writes nothing;
  9. `authMode` is never in a backup's `settings` section and a restore never writes it (`BackupSettingsPolicy`).
- [X] T006 [P] `AccountService` tests in `test/core/account/account_service_test.dart` over `FakeAccountAuth` and `FakeSettingsRepository` (contracts/services.md):
  - `signIn()` saves the account keys only: `authMode`, Auto backup and the schedule are unchanged.
  - `commitSignIn()` sets `google`, turns Auto backup Off → Daily, and syncs the schedule.
  - `signOut(to: none)` and `signOut(to: guest)` write `authMode` before clearing the keys (check the write order the fake records), keep the Auto backup setting, and cancel both background jobs.
  - `forgetAfterAuthLoss()` → `guest`, data untouched.
  - `stateOf` is `SignedIn` only when `authMode == google` and an email is set.
  
  Rewrite the existing interim-era cases in this file to match.

- [X] T008 [P] Erase tests in `test/core/reset/drift_app_reset_service_test.dart` over a real in-memory database. For each `EraseScope`, assert the exact kept and reset settings rows from data-model.md §3:
  - Module rows and `unlocks` are deleted.
  - Change counters are 0.
  - `guestLogOut` writes `authMode = none` in the same transaction.
  - A forced failure in the database step leaves every row in place.
  - The fake `AccountAuth` records zero calls for both scopes.
  - Build the service the way `production_overrides.dart` does, with recording fakes for `NotificationService`, `BackgroundScheduler`, `SafetyCopyStore`, `BackupPasswordStore`, the lock service (`InMemorySecureStore`), a `FakeTrackerModule.onEraseAll`, and `refreshGlance`. For both scopes assert:
    - `cancelAll` was called;
    - every module's background jobs and both auto backup tasks were cancelled;
    - receipts were deleted (module `onEraseAll`);
    - the safety copy and backup password were deleted;
    - the `lock.*` secure entries are gone;
    - the widget was refreshed.
    
    A failure in one of these steps must not stop the next one. Name the `guestLogOut` cases `ACC-04 …` (ACC-04 criteria 3, 4 and 6 at the data level).
- [X] T009 [P] Auto backup gate tests in `test/core/backup/auto_backup_gate_test.dart`: with account keys set but `authMode` `none` or `guest`, `syncAutoBackupSchedule` schedules nothing, `BackgroundBackupScheduler.onAppHidden` enqueues nothing, and `runAutoBackup` returns without a Drive call. With `google`, all three behave as in 010.

### Implementation for the foundation


- [X] T011 Add `Future<void> setAuthMode(AuthMode mode)` and `Future<void> migrateAuthMode()` to `lib/core/settings/domain/settings_repository.dart`, and implement them in `lib/core/settings/data/settings_repository_impl.dart`. The migration runs in one transaction: if the `authMode` row is missing, write `google` when onboarding is done and `backupAccountEmail` is non-empty, `guest` when onboarding is done, else `none`; if the row exists, do nothing. Mirror both in `FakeSettingsRepository` in `test/helpers/fakes.dart`, recording the order of writes for T006.
- [X] T012 Assert in `lib/core/backup/domain/backup_settings_policy.dart` that `authMode` and `backupLeaseUntil` are not restorable (add them to the never-restored list next to the account keys, if the policy is a deny-list).
- [X] T013 Add `authModeProvider` (`@Riverpod(keepAlive: true)`, `appSettingsProvider.select((s) => s.value?.authMode ?? AuthMode.none)`) to `lib/core/settings/settings_providers.dart` and regenerate.
- [X] T014 Split sign-in in `lib/core/account/account_service.dart` per research R3 and contracts/services.md:
  - `signIn()` saves keys only.
  - New `commitSignIn()` sets `google`, Auto backup Off → Daily, `_expired = false`, verified, and syncs the schedule.
  - `signOut({required AuthMode to})` writes `authMode = to` first, then signs out of Google and runs `_forget()`.
  - `forgetAfterAuthLoss()` writes `guest` before `_forget()`.
  - `stateOf` requires `authMode == google`.
  
  Remove the `// Interim (Replaced in 011)` comment. Update every caller so it compiles with unchanged behavior for now: `lib/core/account/account_sign_in.dart` `run()` calls `signIn()` then `commitSignIn()`; ACC-03 calls `signOut(to: AuthMode.none)` and Switch account calls `signOut(to: AuthMode.guest)`; `lib/features/lock/presentation/screens/unlock_screen.dart` is handled in T050. Between this task and T053, ACC-03 sets `none` while `sign_out_sheet.dart` still navigates to the More tab; the redirect wins, so the existing "(interim I4)" case in `test/features/account/sign_out_sheet_test.dart` is expected to fail until T051 and T053 replace it. Skip it with a `skip:` reason pointing to T051 rather than editing it here.
- [X] T015 Gate auto backups on `authMode == AuthMode.google` instead of `backupAccountEmail != null` (research R4). There are three checks: `lib/core/backup/auto_backup_schedule.dart:20`, `lib/core/backup/background_backup_scheduler.dart:34` and `lib/app/auto_backup_task.dart:42`, `:128`. Manual Drive paths keep checking the account keys.

- [X] T017 Lock session follows `authMode` (research R7):
  - In `lib/app/bootstrap.dart`, start the session locked only when `onboardingDone && lockEnabled && authMode != AuthMode.none`. Make the same change in `FakeBootstrap` in `test/helpers/fakes.dart`.
  - In `lib/app/app.dart`, listen to `authModeProvider`. On `none` → `guest`/`google`, call `lockSession.start(lockEnabled: settings.lockEnabled)`; on a change to `none`, reset the session.
  - Make the resume re-lock check `authMode != none`.
- [X] T018 Add `enum EraseScope { thisPhoneData, guestLogOut }` to `lib/core/reset/domain/app_reset_service.dart` and change it to `eraseAll({EraseScope scope = EraseScope.thisPhoneData})`. In `lib/core/reset/data/drift_app_reset_service.dart`, implement the keep-lists from data-model.md §3, verbatim:
  - `devicePreferenceKeys` = `locale`, `currencyCode`, `themeMode`, `selectedTheme`, `enabledModules`, `moduleOrder`, `onboardingDone`.
  - `thisPhoneData` keeps `devicePreferenceKeys` + `authMode`, `backupAccountEmail`, `accountDisplayName`, `accountPhotoUrl`, `deviceId`, `adsInstallAt`, `lastKnownDriveBackupAt`, `lastKnownDriveBackupDeviceId`, `autoBackupFrequency`, `autoBackupWifiOnly`, `adConsentStatus`, `removeAdsPurchased`, `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending`.
  - `guestLogOut` keeps `devicePreferenceKeys` + `deviceId`, `adsInstallAt`, `adConsentStatus`, `removeAdsPurchased`, `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending`, and inserts `authMode = "none"` inside the transaction.
  
  Both scopes reset the change counters to 0. In `lib/app/production_overrides.dart`, remove the `accountAuth.signOut` step from `resetLock` (no Google call from an erase). Update `FakeAppResetService` in `test/helpers/fakes.dart` to record `scopes`. Update the class doc comment: the erase restarts at Home or `/login`, not onboarding. Update `lib/core/widgets/erase_all_data_flow.dart`'s comment "On success the app restarts at onboarding by itself" to match.

**Checkpoint**: T004–T009 pass. The app routes by `authMode` and every story can start.

---

## Phase 3: User Story 1 - Start as a guest, online or offline (Priority: P1) 🎯 MVP

**Goal**: Intro without sign-in or app lock ends on AUTH-01; "Continue as guest" opens Home with no network call.

**Independent Test**: Fresh install with recording fakes. Finish Intro, then tap "Continue as guest" online and offline. Home opens, `authMode` is `guest`, back on AUTH-01 never shows Intro, a restart opens Home, and `expectNoGoogleCalls` passes.

### Tests for User Story 1 ⚠️

- [X] T019 [P] [US1] SYS-02 widget tests in `test/features/onboarding/onboarding_screen_test.dart`, one per SYS-02 acceptance criterion copied in spec.md and named `SYS-02 …`:
  - language persists after `restartTestApp`;
  - a denied notification permission doesn't block;
  - both modules can't be off;
  - "Get started" and Skip mark onboarding done and open AUTH-01, and back never returns to Intro;
  - no `sys02.restoreWithGoogle` and no `onboarding_set_app_lock` key exists on any step;
  - closing on Intro reopens Intro, and closing on AUTH-01 reopens AUTH-01.
  
  Delete the SYS-02 "Restore with Google" cases from `test/app/sign_in_entry_points_test.dart`.
- [X] T020 [P] [US1] AUTH-01 guest tests in `test/features/auth/login_screen_test.dart`, named `AUTH-01 …`, for these criteria:
  - "On a fresh install, Intro opens AUTH-01; back on AUTH-01 closes the app and never shows Intro" (assert `SystemNavigator.pop` through a `SystemChannels.platform` mock).
  - "Continue as guest sets `authMode = guest` and opens Home without any sign-in, Drive, or network call … online and offline" (use `expectNoGoogleCalls`; `FakeNetworkStateSource.loads == 0`).
  - "No ad is requested while AUTH-01 is open" (a recording `FakeAdService` sees no request, and `maybeShowInterstitial` is never called).

### Implementation for User Story 1

- [X] T021 [US1] Create `lib/features/auth/presentation/controllers/login_state.dart` (freezed `LoginState`: `busy` `LoginBusy { none, signingIn, restoring, finishing }`, `error` `LoginError? { cancelled, failed, offline }`, `restoreFailed` bool, `pendingBackup` `DriveBackupEntry?`; data-model.md §4). Create `lib/features/auth/presentation/controllers/login_controller.dart` (`@riverpod class LoginController`) with `continueAsGuest()`, which runs `setFinishSetupPending(pending: true)` then `setAuthMode(AuthMode.guest)` and reads nothing else. Leave `continueWithGoogle()` as a stub that T028 fills in.
- [X] T022 [US1] Create `lib/features/auth/presentation/screens/login_screen.dart` per contracts/screens.md AUTH-01:
  - No app bar. Centered logo and app name, title, body, `FilledButton` "Continue with Google" (`auth01_google`), `OutlinedButton` "Continue as guest" (`auth01_guest`), guest note in `bodySmall`, and a hidden inline error area (`auth01_error`, `auth01_tryAgain`).
  - Both buttons are disabled while busy.
  - `PopScope(canPop: false)`, whose pop calls `SystemNavigator.pop()`.
  - Max content width 600 dp, `AppTokens` only, semantic labels.
  
  Wire it as the builder of the `/login` route in `lib/app/router/app_router.dart`.
- [X] T023 [US1] Remove SYS-02 "Restore with Google" (interim I2) and the step 4 app lock:
  - In `lib/features/onboarding/presentation/screens/onboarding_screen.dart`, delete `_RestoreWithGoogle`, the restoring view, and the `restore:` argument.
  - In `lib/features/onboarding/presentation/widgets/language_step.dart`, delete the `restore` parameter.
  - In `lib/features/onboarding/presentation/controllers/onboarding_controller.dart`, delete `restoreWithGoogle` and its imports.
  - In `lib/features/onboarding/presentation/controllers/onboarding_state.dart`, delete `GoogleRestoreStatus`, `googleRestore` and `googleRestoreError`.
  - In `lib/features/onboarding/presentation/widgets/privacy_step.dart`, delete `appLockOn` and `onSetAppLock` and set the reworded step 4 body (T002).
  - Remove the unused strings `onboarding_restoreWithGoogle` and `onboarding_noBackupFound` from `tool/l10n/phase0_strings.py`. Regenerate code and l10n.

**Checkpoint**: US1 alone works. A fresh install reaches Home as a guest without any Google or Drive call.

---

## Phase 4: User Story 2 - Sign in with Google on AUTH-01 and get my data back (Priority: P1)

**Goal**: "Continue with Google" restores the newest backup on an empty phone, opens ACC-02 when the phone has data, and backs up when the account has none, with clear offline, cancel, failure and restore-failure states.

**Independent Test**: With fake sign-in and Drive, run every branch of research R9 and check the screen, `authMode`, Auto backup, Drive uploads and local rows after each.

### Tests for User Story 2 ⚠️

- [X] T024 [P] [US2] `AccountSignIn.login()` tests in `test/core/account/account_sign_in_test.dart`:
  - offline → `LoginOffline` with zero auth and Drive calls;
  - cancel → `LoginCancelled`, no key written;
  - auth failure → `LoginFailed`, no key written;
  - empty Drive → `LoginNoBackup` with keys saved and `authMode` still `none`;
  - backups → `LoginHasBackups(newest)`;
  - a list failure after sign-in → `LoginFailed` with the keys cleared again.
  
  Rewrite this file's interim-era header comment.
- [X] T025 [P] [US2] AUTH-01 Google tests in `test/features/auth/login_google_test.dart`, named `AUTH-01 …`, for each criterion:
  - no backup → `google`, Auto backup Daily, one manual upload, Home;
  - backup and no user data → restored without a choice sheet, the backup's language, currency and modules applied, `FakeProStore` restore called;
  - user data → ACC-02 opens and can't be dismissed by dragging or tapping outside;
  - cancel or failure → the inline error and "Try again", `authMode` `none`, no key;
  - offline → the offline error, nothing written, and "Continue as guest" still opens Home;
  - a failed restore leaves rows unchanged and offers "Try again" and "Continue without restoring", and the latter sets `google`.
  
  Also cover these scenarios: an encrypted backup asks for the password first, and both buttons are disabled while signing in.
- [X] T026 [P] [US2] Controller tests in `test/features/auth/login_controller_test.dart`: `authMode` is written only after every branch settles (R9). A `Completer`-gated ACC-02 fake shows `authMode == none` while the sheet is open.

### Implementation for User Story 2

- [X] T027 [US2] Add `sealed class LoginOutcome` (`LoginOffline`, `LoginCancelled`, `LoginFailed(Object error)`, `LoginNoBackup`, `LoginHasBackups(DriveBackupEntry newest)`) and `Future<LoginOutcome> login()` to `lib/core/account/account_sign_in.dart`, following research R9: check the network first; `AccountService.signIn()` (never `commitSignIn`); `guardAuth(drive.list)`; on a list failure, clear the keys with `SettingsRepository.setAccount(null)` and return `LoginFailed`.
- [X] T028 [US2] Implement `LoginController.continueWithGoogle()`, `tryAgain()`, `retryRestore()`, `onRestoreChoice(RestoreChoiceResult result)` and `continueWithoutRestoring()` in `lib/features/auth/presentation/controllers/login_controller.dart` (research R9). The controller never takes a `BuildContext`:
  - `continueWithGoogle()`, `tryAgain()` and `retryRestore()` return `Future<LoginNext>` (`LoginNext.done` or `LoginNext.chooseRestore(DriveBackupEntry newest)`, defined next to `LoginState`).
  - `LoginHasBackups` → keep `pendingBackup` and return `chooseRestore(newest)`. The screen (T029) calls `ref.read(accountUiProvider).showRestoreChoice(context, newest: newest, afterSignIn: true)` and passes the result to `onRestoreChoice`.
  - `restored`: start `proServiceProvider.restore()` without awaiting it, and report "Pro restored" through a callback, as SYS-02 did.
  - `closed`: set `restoreFailed`.
  - Every finished branch: `setFinishSetupPending(pending: true)`, then `AccountService.commitSignIn()`.
  - `LoginNoBackup`: then a manual `backupToDrive`; a failure is quiet.
  
  `restored` and `kept` finish the same way.
- [X] T029 [US2] Add the Google states to `lib/features/auth/presentation/screens/login_screen.dart`. When a controller call returns `LoginNext.chooseRestore(newest)`, the screen opens ACC-02 through `AccountUi.showRestoreChoice(..., afterSignIn: true)` and hands the result to `LoginController.onRestoreChoice`. The screen also adds:
  - progress on `auth01_google` while `signingIn`;
  - the inline error texts for cancelled, failed and offline;
  - the full-screen restoring view (`auth01_restoring`, "Restoring your data…");
  - the restore error view (`auth01_restoreFailed`, `auth01_restoreTryAgain`, `auth01_continueWithoutRestoring`);
  - a "Pro restored" snackbar through `rootMessengerKey`.
  
  No stack traces or codes.

**Checkpoint**: US1 and US2 work. AUTH-01 is complete.

---

## Phase 5: User Story 3 - Existing users and returning starts go to the right screen (Priority: P1)

**Goal**: Updated installs migrate once and never see AUTH-01, and every start routes correctly and repairs the account state.

**Independent Test**: Seed settings for each case (fresh, updated with and without an account, onboarding not done, `authMode` none/guest/google, lock on/off, revoked token, leftover keys, offline, Android restore) and check the first screen, `authMode` and the account keys.

### Tests for User Story 3 ⚠️

- [ ] T030 [P] [US3] SYS-01 tests in `test/app/bootstrap_auth_mode_test.dart`, named `SYS-01 …`, one per criterion:
  - seeding happens once (keep the existing test and reference it);
  - `guest`/`google` with lock on → SYS-03, without lock → DSH-01;
  - onboarding done with `none` → AUTH-01 even with lock on;
  - an updated install with onboarding done and no `authMode` gets `guest`, or `google` with an email, and never sees AUTH-01;
  - the ads SDK is not initialized with Pro (keep the existing test and reference it).
  
  Add an order test: `migrateAuthMode` runs before `initialLocationFor` and before the Android-restore step.
  - **Partly done (2026-10-28):** `test/app/bootstrap_auth_mode_test.dart` covers every SYS-01 criterion and that the migration runs before routing. Still open: the order check against the Android-restore step (US3, with T036).
- [X] T031 [P] [US3] Start-up account check tests in `test/core/account/account_service_test.dart` (the `restoreSession` group, research R5):
  - `google` with a null silent result → keys cleared, `guest`, rows kept;
  - `google` with a thrown `DriveOffline` → stays `google`, unverified;
  - `none` or `guest` with keys → keys cleared, `signOut` called once;
  - `guest` with no keys → `FakeAccountAuth.calls` is empty;
  - `DriveAuthRequired` from `guardAuth` → `guest`.
- [X] T032 [P] [US3] Android restore tests in `test/app/android_restore_start_test.dart`, rewritten for spec FR-010:
  - restored `google` with silent success → `google` with the keys back;
  - restored `google` with silent failure → `guest`;
  - restored `guest` → kept, zero auth calls;
  - restored `none` → kept, AUTH-01 shown;
  - Intro is never shown.
- [X] T033 [P] [US3] Resume re-lock test in `test/app/lock_resume_test.dart` (or the existing feature 007 resume test file): with `authMode == none` on AUTH-01, going to the background and back does not redirect to SYS-03.

### Implementation for User Story 3

- [X] T034 [US3] In `lib/app/bootstrap.dart`, call `await ref.read(settingsRepositoryProvider).migrateAuthMode()` right after seeding and before `load()`, inside the startup try block, so a failure gives `BootstrapFailed`.
- [X] T035 [US3] Rewrite `AccountService.restoreSession()` in `lib/core/account/account_service.dart` per research R5:
  - `google` → silent sign-in; null → `forgetAfterAuthLoss()`; a throw → unverified.
  - `none`/`guest` with keys → `_settings.setAccount(null)` and `_auth.signOut()` (best effort).
  - Otherwise, no auth call.
- [X] T036 [US3] Rewrite `_afterAndroidRestore` in `lib/app/bootstrap.dart` (interim I7, research R5): keep the lock, keys, `lastKnownDriveBackup*`, pause and `finishSetupPending` steps. Then call `adoptSilentSession()` only when the restored `settings.authMode == AuthMode.google`, and on a null profile call `setAuthMode(AuthMode.guest)`. Make `AccountService.adoptSilentSession()` return whether a session was adopted. Update the doc comment.

**Checkpoint**: US1–US3 work. Existing users are unaffected by the new login.

---

## Phase 6: User Story 4 - Finish setting up after every login (Priority: P2)

**Goal**: The "Finish setting up" sheet appears once after each AUTH-01 login when app lock is off.

**Independent Test**: Log in as a guest and with Google, with lock off and then on. The sheet appears once on Home, not again after a restart, and never with lock on (SYS-03 first).

### Tests for User Story 4 ⚠️

- [X] T037 [P] [US4] Tests in `test/features/auth/login_finish_setup_test.dart`, named `AUTH-01 …`:
  - "After login on either path with app lock off, the 'Finish setting up' sheet appears once on Home and not again after a restart" (guest and Google, `restartTestApp`).
  - "With app lock on (data kept after sign-out), leaving AUTH-01 on either path shows SYS-03 before Home" (`TestLock` with a PIN, `authMode` `none`).
  - "Allow notifications" is hidden on SDK ≤ 32 and when the permission is granted.
  - After ACC-03 or ACC-04, a later login offers the sheet again.

### Implementation for User Story 4

- [X] T038 [US4] Check that both AUTH-01 paths set `finishSetupPending` before `authMode` (T021, T028) and that `lib/app/app.dart` `_maybeFinishSetup` needs no change. Update its doc comment: the sheet follows every login on AUTH-01 as well as restores (interim I6; research R10). Update the `finishSetupPending` doc in `lib/core/settings/domain/app_settings.dart`.

**Checkpoint**: The sheet follows every login.

---

## Phase 7: User Story 5 - See my account on More and sign in from there as a guest (Priority: P2)

**Goal**: The SET-01 account card (guest and Google states), guest sign-in from SET-01, SET-02 and ACC-04 (the ACC-04 entry is wired in US7), Switch account to guest, and the SYS-03 "Forgot PIN?" commit rule.

**Independent Test**: Render SET-01 in every state, tap each entry point as a guest for accounts with and without a backup, cancel, fail and go offline, and check the card, `authMode`, Auto backup and rows.

### Tests for User Story 5 ⚠️

- [X] T039 [P] [US5] `AccountCardPolicy` unit tests in `test/core/backup/domain/account_card_policy_test.dart`: every `BackupStatusPolicy` result maps per data-model.md §5.
  - Offline and waiting-for-Wi-Fi → `backedUp(lastBackupAt)`, or `notBackedUpYet` when null (clarification Q3).
  - Lease later than now → `backingUp`; an expired lease → not backing up.
  - Paused and failed pass through.
- [X] T040 [P] [US5] SET-01 tests in `test/features/settings/settings_screen_test.dart`, named `SET-01 …`:
  - currency changes formatting only (keep the existing test and reference it);
  - "Ad privacy choices" is visible when required (keep the existing test and reference it);
  - the account card is the first item, with the guest texts and "Sign in with Google" starting guest sign-in, and the Google name, email, photo or initial and "Backed up to Google · …" opening ACC-01;
  - "No text on this screen says 'Synced' or 'Sync.'" (scan every `Text` in both states).
  
  The "Log out of guest" criterion is in T054.
- [X] T041 [P] [US5] Guest sign-in tests in `test/features/account/guest_sign_in_test.dart`, one per §16 "Guest sign-in" criterion, named `§16 Guest sign-in …`, run from both the SET-01 card and the SET-02 Drive card:
  - no backup → upload, `google`, Daily, the card switches to the Google state;
  - backup → ACC-02, where "Restore from account" replaces rows and "Keep this phone's data" makes this phone the latest, with no combined rows;
  - cancel or failure → `guest` and every row unchanged.
  
  Also cover offline: "Connect to the internet to sign in with Google" and no request.
- [ ] T042 [P] [US5] ACC-01 tests in `test/features/account/account_screen_test.dart`, rewritten from the interim I1/I3/I4 versions:
  - ACC-01 opens from the SET-01 card;
  - "ACC-01 can't be opened as a guest; the SET-01 guest card starts guest sign-in instead" (rule 7);
  - Switch account with a cancelled chooser → `guest`, back on SET-01 with the guest card;
  - status shows "Backing up…" while the lease is held.
  
  Rewrite `test/app/router/account_route_test.dart` for rule 7.
  - **Partly done (2026-10-28):** the SET-01 card opens ACC-01, a guest can't open ACC-01 (rule 7), and a cancelled Switch account chooser ends as a guest on SET-01. Switch account now keeps `google` and the old keys until the chooser ends (`AccountService.beginSwitch`), because writing `guest` first let rule 7 close ACC-01 mid-switch. Still open: an ACC-01 widget test for "Backing up…" while the lease is held (the card has one).
- [ ] T043 [P] [US5] SYS-03 "Forgot PIN?" tests in `test/features/lock/forgot_pin_test.dart` (clarification Q2):
  - as a guest, a successful restore → `google`, Auto backup Daily, Google card;
  - a cancelled sign-in or failed restore → `guest`, no keys;
  - as `google`, the mode stays `google`;
  - the erase path calls `eraseAll(scope: thisPhoneData)` and lands on Home, not Intro.
- [ ] T044 [P] [US5] Golden tests in `test/goldens/account_card_golden_test.dart` (tag `golden`): the guest card and Google card (backed up, paused), light/dark × English/Gujarati. Generate on Linux only.

### Implementation for User Story 5

- [X] T045 [P] [US5] Add `sealed class CardStatus` (`backedUp(int lastBackupAt)`, `notBackedUpYet`, `backingUp`, `paused`, `failed`) to `lib/core/account/domain/account_card_view.dart`, and `AccountCardPolicy.derive({required AppSettings s, required NetworkState network, required DateTime now})` returning it to `lib/core/backup/domain/backup_status_policy.dart`. Implement it per data-model.md §5, calling `BackupStatusPolicy.derive` first.
- [X] T046 [US5] Add `accountCardViewProvider` (a plain `@riverpod` function provider, not a Notifier, so SET-01 keeps `SettingsController` as its only Notifier) to `lib/core/account/account_providers.dart`. Put the view types in `lib/core/account/domain/account_card_view.dart` (pure Dart; `AccountCardView`: `GuestCard(offline)` or `GoogleCard(profile, status)`), derived from `appSettingsProvider`, `accountStateProvider`, `networkStateSourceProvider` and the clock (data-model §5). Create `lib/features/account/presentation/widgets/account_card.dart` per contracts/screens.md:
  - It re-reads the network with `ref.invalidate(accountCardViewProvider)` from an `AppLifecycleListener.onResume`.
  - The guest card's primary "Sign in with Google" (`set01_accountSignIn`) calls `ref.read(accountUiProvider).startGuestSignIn(context)`.
  - Implement the outcome handling once, in `lib/features/account/presentation/widgets/guest_sign_in.dart` (`runGuestSignIn(BuildContext, WidgetRef)`): `accountSignInProvider.run()`, then each `SignInOutcome` handled exactly as `backup_screen.dart` `_signIn` does today.
  - The Google card has a `CategoryAvatar` or cached photo, name, email and status line (`warning` color plus an icon for paused and failed), and taps → `context.push(Routes.account)`.
- [X] T047 [US5] Add `Widget accountCard()` and `Future<void> startGuestSignIn(BuildContext context)` to `AccountUi` in `lib/core/account/account_ui.dart` (contracts/services.md). Move `AccountFeatureUi` from `lib/features/account/presentation/widgets/restore_choice_sheet.dart` to `lib/features/account/presentation/account_feature_ui.dart` and implement both there (`startGuestSignIn` calls `runGuestSignIn` from T046). Update the imports in `lib/app/production_overrides.dart` and `test/helpers/test_app.dart`. In `lib/features/settings/presentation/screens/backup_screen.dart`:
  - replace `_signIn` and its outcome `switch` with `ref.read(accountUiProvider).startGuestSignIn(context)`;
  - make `reconnect` call the same method.
  
  Delete `signIn()` from `lib/features/settings/presentation/controllers/backup_controller.dart`. Settings must import nothing from `lib/features/account/` (constitution II).
- [X] T048 [US5] In `lib/features/settings/presentation/screens/settings_screen.dart`, put `ref.read(accountUiProvider).accountCard()` first in `_SettingsList`, before `_PremiumCard`. Update the class doc comment. Adjust the existing SET-01 tests that assumed the premium card leads the list (`scrollSettingsTo` comment in `test/helpers/test_app.dart`).
- [X] T049 [US5] ACC-01 changes in `lib/features/account/presentation/screens/account_screen.dart` and `lib/features/account/presentation/controllers/account_controller.dart` (interim I3, I4):
  - delete both `router.go(Routes.more)` branches and their interim comments;
  - `switchAccount()` calls `signOut(to: AuthMode.guest)` then `AccountSignIn.run()`;
  - a cancelled chooser leaves `guest`, and the router's rule 7 closes ACC-01;
  - the status also reads `backupLeaseUntil` (backing up while the lease is later than now).
- [ ] T050 [US5] SYS-03 "Forgot PIN?" in `lib/features/lock/presentation/screens/unlock_screen.dart` (and `lib/core/backup/presentation/drive_restore_flow.dart` if it owns the sign-in callback):
  - The `signIn` callback calls `AccountService.signIn()`.
  - After a successful restore it calls `commitSignIn()`.
  - On a cancel or failure, a guest's saved keys are cleared (`setAccount(null)`).
  - Erase uses `eraseAll(scope: EraseScope.thisPhoneData)`.
  - Remove `GoRouter.of(context).go(Routes.home)` if the redirect now covers it.

**Checkpoint**: The SET-01 card and guest sign-in work from More.

---

## Phase 8: User Story 6 - Sign out lands on Login (ACC-03) (Priority: P2)

**Goal**: Both ACC-03 choices set `authMode = none`, and the redirect opens AUTH-01 with the stack cleared, never Intro or the More tab.

**Independent Test**: Sign out with each choice (backup succeeding, failing, offline), check AUTH-01 with no way back, restart, then continue as a guest and with Google.

### Tests for User Story 6 ⚠️

- [X] T051 [P] [US6] ACC-03 tests in `test/features/account/sign_out_sheet_test.dart`, one per criterion, named `ACC-03 …` (replace the `(interim I4)` case at line 101):
  - backup first, with "Sign out" enabled only after success or "Sign out anyway";
  - "Keep data" leaves every row, opens AUTH-01 with the `auth01_signedOutKept` snackbar, and "Continue as guest" shows the same data;
  - "Remove data" erases with `thisPhoneData`, keeps the Drive backups and opens AUTH-01;
  - `authMode` `none` and AUTH-01, never Intro, also after `restartTestApp`;
  - a failed backup → "Remove data" needs the typed DELETE;
  - after sign-out, `FakeDriveBackupStore.calls` stays empty until a new sign-in.

- [ ] T052 [P] [US6] Return-path tests in `test/features/auth/login_after_sign_out_test.dart`:
  - after ACC-03 "Keep data", "Continue with Google" to an account with a backup opens ACC-02 (the phone has data), and the sheet can't be dismissed;
  - after "Remove data", "Continue with Google" restores without the sheet;
  - with app lock on and data kept, both AUTH-01 paths show SYS-03 first.

### Implementation for User Story 6

- [X] T053 [US6] ACC-03 in `lib/features/account/presentation/controllers/sign_out_controller.dart` and `lib/features/account/presentation/widgets/sign_out_sheet.dart` (interim I4):
  - call `signOut(to: AuthMode.none)`;
  - "Remove data" then runs `eraseAll(scope: EraseScope.thisPhoneData)`;
  - delete `router.go(Routes.more)` and the interim comment;
  - after "Keep data", show the `auth01_signedOutKept` snackbar through `rootMessengerKey` once the redirect has run.

**Checkpoint**: Sign-out lands on AUTH-01.

---

## Phase 9: User Story 7 - Log out of guest (ACC-04) (Priority: P3)

**Goal**: A guest can delete all their data with a clear warning, keep their preferences and Pro, and land on AUTH-01.

**Independent Test**: As a guest with data, unlocks, receipts, a PIN, a backup password and scheduled notifications, cancel ACC-04 every way, choose "Sign in with Google instead", then confirm with a forced failure and with success, checking everything after each.

### Tests for User Story 7 ⚠️

- [X] T054 [P] [US7] ACC-04 tests in `test/features/account/log_out_guest_test.dart`, one per criterion, named `ACC-04 …`:
  - "Cancel", back and tapping outside → `FakeAppResetService.calls == 0` and settings unchanged;
  - "Sign in with Google instead" → no erase, and guest sign-in starts (`FakeAccountAuth.calls == ['signIn']`);
  - "Log out and delete" → `scopes == [EraseScope.guestLogOut]`;
  - after it, AUTH-01 with no way back, and `restartTestApp` → AUTH-01, not Intro or SYS-03 (with a PIN set before);
  - the confirm button uses `error` color;
  - SET-01 "'Log out of guest' appears in the Data group only in the guest state and opens ACC-04" (absent as `google`), and its text uses `colorScheme.error` (spec FR-026);
  - a failed erase shows `acc04_failed` and the user stays a guest.
  
  Add a router-probe assertion: no interstitial over AUTH-01 after ACC-04. Criteria 3, 4 and 6 at the data level are tested in T008 (rows, settings, files, secure storage, notifications, jobs), whose cases are also named `ACC-04 …`.

### Implementation for User Story 7

- [X] T055 [P] [US7] If `ConfirmDialog` in `lib/core/widgets/confirm_dialog.dart` can't show a third action, add an optional `secondaryActionLabel` with an `onSecondaryAction` (text button, left of "Cancel"), with a widget test in `test/core/widgets/confirm_dialog_test.dart`. Otherwise skip this task and note why.
  - **Skipped (2026-10-28):** `ConfirmDialog` is a stateless dialog that pops true or false; ACC-04 also needs the deleting and error states, so `log_out_guest_dialog.dart` follows its layout rules (title, consequence, Cancel, destructive action in `error` color) in its own `AlertDialog` instead of changing the shared widget.
- [X] T056 [US7] Create `lib/features/account/presentation/controllers/log_out_guest_controller.dart` (`ready` → `deleting` → `error`; `confirm()` calls `appResetServiceProvider.eraseAll(scope: EraseScope.guestLogOut)`) and `lib/features/account/presentation/widgets/log_out_guest_dialog.dart` per contracts/screens.md ACC-04:
  - keys `acc04_*`;
  - progress on the confirm button and every action disabled while deleting, with a non-dismissible barrier;
  - "Sign in with Google instead" pops and then calls `AccountUi.startGuestSignIn(context)`.
- [X] T057 [US7] Add `Future<void> showLogOutGuest(BuildContext context)` to `AccountUi` in `lib/core/account/account_ui.dart` and implement it in `lib/features/account/presentation/account_feature_ui.dart`. In `lib/features/settings/presentation/screens/settings_screen.dart`, add the Data group row "Log out of guest" (`set01_logOutGuest`, `error` color text), shown only while `ref.watch(authModeProvider) == AuthMode.guest` and calling `accountUi.showLogOutGuest(context)`.

**Checkpoint**: All seven stories work independently.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Section-wide criteria, removing what's left of the interim behavior, docs, and the quality gates.

- [ ] T058 [P] §16 section tests in `test/features/account/guest_session_test.dart`:
  - "As a guest, the app makes no Google sign-in or Drive request (a fake client records zero calls across a full session)": Intro → guest → add an expense and a habit check-in → background and resume → open SET-01, SET-02, Export → `expectNoGoogleCalls`.
  - "Every screen outside this section works the same as a guest, and only the places listed at the top of this section offer sign-in": scan every route for an `account_signIn`/`auth01_google` widget outside AUTH-01, SET-01, SET-02, ACC-04 and SYS-03.
- [X] T059 [P] Extend `test/core/l10n/no_sync_wording_test.dart` to the new `auth_*`, `accountCard_*` and `logOutGuest_*` keys in all three languages.
- [ ] T060 [P] Golden tests in `test/goldens/auth_golden_test.dart` (tag `golden`): AUTH-01 default, inline error and restore error, light/dark × English/Gujarati. Generate on Linux only.
- [X] T061 [P] Accessibility tests in `test/a11y/auth_font_scale_test.dart` (and extend `test/a11y/account_font_scale_test.dart`): AUTH-01, the SET-01 card and ACC-04 at 200% font scale on a 360 dp-wide surface in Gujarati, with no overflow, every touch target ≥ 48 dp, and every icon with a semantic label.
- [ ] T062 Write `integration_test/login_flow_test.dart` (replaces 010's T103) with fakes for Google and Drive: fresh install → Intro → AUTH-01 guest → add data → SET-01 card sign-in → backup → ACC-03 "Remove data" → AUTH-01 → "Continue with Google" → restore without a choice sheet → same row counts and checksums. In `specs/010-google-account-backup/tasks.md`, mark T103 replaced by this test.
- [X] T063 Search for and delete any remaining interim code and tests: `rg -n "Replaced in 011|interim I[1-8]|Interim \(Replaced" lib test integration_test` must return nothing. Rewrite the doc comments it finds, including `account_controller.dart:29`, `test/features/account/restore_choice_sheet_test.dart:151`, `test/core/account/account_sign_in_test.dart:12` and `test/app/sign_in_entry_points_test.dart`, for the new behavior. If nothing is left in `sign_in_entry_points_test.dart`, delete it.
- [ ] T064 [P] Docs: in `docs/spec.md` §14, check T3.6 and remove the "Interim until T3.6" note under T3.5. In `specs/010-google-account-backup/plan.md`, mark the "Interim behavior until feature 011" section as replaced by feature 011. In `docs/CLAUDE.md`, add one Architecture line: AUTH-01 is in `lib/features/auth/`, and SET-01 reaches the account card and ACC-04 only through the `AccountUi` port.
  - **Partly done (2026-10-28):** the §14 "Interim until T3.6" note is removed, 010's plan marks its interim section replaced, and `docs/CLAUDE.md` has the AUTH-01 / `AccountUi` line. T3.6 stays unchecked until T066–T067 pass.
- [ ] T065 Add a table at the end of this file mapping every acceptance criterion copied in `specs/011-login-guest-mode/spec.md` (42 in all: SYS-01 5, SYS-02 6, AUTH-01 11, SET-01 5, ACC-03 6, ACC-04 6, Guest sign-in 3) and the §16 section criteria touched here to the test that covers each (constitution IV).
- [ ] T066 Run the quality gates in `specs/011-login-guest-mode/quickstart.md` §2 (`build_runner`, l10n, `flutter analyze` with zero warnings, `dart format --set-exit-if-changed .`, `flutter test --exclude-tags golden`) and the focused runs in §3. Fix every failure. Report the §15.10 design review checklist for AUTH-01, the SET-01 card and ACC-04 in the task summary.
- [ ] T067 Run the device checks in `specs/011-login-guest-mode/quickstart.md` §4 on a real phone (dev flavor), including the update from the previous release. Record the results in the task summary.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001 blocks everything. T002 and T003 can run in parallel after it.
- **Foundational (Phase 2)**: depends on Setup and blocks every user story. T010 → T011 → T013; T014 depends on T011; T015 and T016 depend on T010 and T013; T017 depends on T016; T018 depends on T010. Tests T004–T009 are written first, in parallel.
- **US1 (Phase 3)**: after Foundational.
- **US2 (Phase 4)**: after US1 (it extends `login_controller.dart` and `login_screen.dart`).
- **US3 (Phase 5)**: after Foundational. It doesn't depend on US1 or US2 and can run alongside them.
- **US4 (Phase 6)**: after US1 and US2 (it checks both login paths).
- **US5 (Phase 7)**: after Foundational. T050 also depends on T014.
- **US6 (Phase 8)**: after Foundational. Its AUTH-01 assertions need US1's screen.
- **US7 (Phase 9)**: after US5 (it calls `AccountUi.startGuestSignIn` from T046–T047 and extends `account_feature_ui.dart` from T047).
- **Polish (Phase 10)**: after every story.

### Within Each User Story

- Tests first, and they must fail before implementation.
- Pure domain → controllers → widgets → wiring.
- Regenerate code (`build_runner`) after each freezed or riverpod change.

### Parallel Opportunities

- T002 ∥ T003; T004–T009 together.
- After Foundational: US1 → US2 on one track, US3 on a second, US5 → US7 on a third, US6 on a fourth.
- Within US5: T039–T044 together, then T045 in parallel with the test work.
- Polish: T058–T061 and T064 together.

---

## Parallel Example: User Story 5

```bash
# Tests together:
Task: "AccountCardPolicy unit tests in test/core/backup/domain/account_card_policy_test.dart"
Task: "SET-01 tests in test/features/settings/settings_screen_test.dart"
Task: "Guest sign-in tests in test/features/account/guest_sign_in_test.dart"
Task: "ACC-01 tests in test/features/account/account_screen_test.dart"
Task: "SYS-03 Forgot PIN tests in test/features/lock/forgot_pin_test.dart"

# Then the pure policy alongside the controller groundwork:
Task: "CardStatus + AccountCardPolicy in lib/core/backup/domain/backup_status_policy.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 (with the 010 gate in T001) and Phase 2.
2. Phase 3 (US1): Intro → AUTH-01 → guest → Home.
3. **Stop and validate**: quickstart §3 rows for SYS-02 and the AUTH-01 guest tests, then device check 1–2.

The MVP alone is not shippable to users who used 010's sign-in, because a signed-in updated user needs US3 and a Google login needs US2. Ship together with US2 and US3 (all three are P1).

### Incremental Delivery

1. Foundation → US1 → US2 → US3: the full P1 login.
2. US4 → US5 → US6: the full sign-in and sign-out loop from More.
3. US7: guest log-out.
4. Polish: the section criteria, interim cleanup, gates and device checks.

---

## Notes

- [P] tasks touch different files and depend on no unfinished task.
- Name every test with its Screen ID (constitution I).
- Commit after each task or logical group, with the Screen ID in the message.
- Never commit goldens rendered on Windows or macOS.
