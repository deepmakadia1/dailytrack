# Research: Login and Guest Mode

**Feature**: `011-login-guest-mode` · **Date**: 2026-10-27 · **Spec**: [spec.md](spec.md)

No item in the Technical Context was left as NEEDS CLARIFICATION: the stack is fixed (constitution VII, `docs/spec.md` §2), and the three product questions were settled in the spec's Clarifications (Q1–Q3). The decisions below are about fitting the feature into the code that features 007–010 left behind.

## R0. Dependency on feature 010

- **Decision**: 011 starts only after feature 010's open tasks are done and its quality gates (010 T105) pass. 011 builds on T041 (the erase keep-list), T042 (startup wiring for device ID and silent sign-in), T064 (SYS-03 "Forgot PIN?" restore through `AccountService` and `AccountRestore`), and T071 (safety copy deletion in erase). 010's T103 (the interim "Restore with Google" integration flow) is not done; 011 writes the AUTH-01 version of that flow instead.
- **Rationale**: on 2026-10-27, 12 of 010's 111 tasks are open, and the working tree holds 010's uncommitted changes. Planning 011 on code that isn't there yet would make tasks guess.
- **Alternatives considered**: folding the open 010 tasks into 011. Rejected: 010's spec and tests own them, and mixing them in would hide which feature an acceptance test belongs to.

## R1. Where `authMode` lives

- **Decision**: a new settings key `authMode` (`SettingsCodec.authMode`), decoded into `AppSettings.authMode` (enum `AuthMode { none, guest, google }`, default `none`; an unknown value decodes to `none`). `SettingsRepository` gains `setAuthMode(AuthMode)` and `migrateAuthMode()` (R2). The key is added to the list of settings that are never backed up or restored (`BackupSettingsPolicy`), next to the account keys.
- **Rationale**: the planning input puts `authMode` in the settings repository; every other sign-in and device key already lives there, and `appSettingsProvider` already drives the router's refresh. No schema change: the settings table is key-value.
- **Alternatives considered**: deriving the mode from `backupAccountEmail` (010's interim I1). Rejected: it can't tell `none` from `guest`, which is the whole point of AUTH-01. A separate Drift table: rejected (YAGNI, constitution VII).

## R2. Migrating existing installs

- **Decision**: `SettingsRepository.migrateAuthMode()` runs once per start in SYS-01, before the Android-restore check and before routing. If the `authMode` row exists, it does nothing. If it is missing, it writes, in one transaction: `google` when onboarding is done and `backupAccountEmail` is set; `guest` when onboarding is done without it; otherwise `none`. A fresh install therefore writes `none` on its first start, so finishing Intro later is never mistaken for an old install.
- **Rationale**: "missing row" is the only reliable sign of an install updated from a version without `authMode`, and writing the row every time it is missing makes the migration run exactly once (SYS-01 AC, spec FR-003). Running it before routing means no updated user ever sees AUTH-01.
- **Tests (one per case, `test/core/settings/auth_mode_migration_test.dart` over a real in-memory database)**: fresh install (no rows) → `none`; onboarding not done, no email → `none`; onboarding not done, email set → `none` (then R5 clears the keys); onboarding done, no email → `guest`; onboarding done, email set → `google`; row already `guest`/`google`/`none` → unchanged; corrupt value (`"x"`) → row kept, decodes to `none`, not re-migrated; migration called twice → second call writes nothing. A bootstrap test checks the order (migrate before routing) and that an updated install with onboarding done lands on SYS-03 or Home.
- **Alternatives considered**: a Drift schema migration. Rejected: a settings row is not schema, and the value depends on other settings rows, which `SettingsCodec` already reads safely.

## R3. Keeping `authMode` and the account keys consistent

- **Decision**: split `AccountService.signIn()` into two steps:
  1. `signIn()` — the account chooser and Drive consent; on success saves the account keys only (no `authMode`, no Auto backup change, no schedule). Null when cancelled.
  2. `commitSignIn()` — sets `authMode = google`, turns Auto backup Off → Daily, clears `_expired`, and syncs the schedule.
  
  Guest sign-in (`AccountSignIn.run`) calls both at once, as before. AUTH-01 calls `signIn()`, runs the restore check, and calls `commitSignIn()` last (spec FR-016). `signOut({required AuthMode to})` writes `authMode = to` **first**, then clears the keys; ACC-03 passes `none`, Switch account passes `guest`. `forgetAfterAuthLoss()` writes `guest` (spec FR-008).
- **Rationale**: the write order makes every crash land in a state that the start check (R5) repairs: keys present with `authMode` `none` or `guest` → keys cleared. `authMode = google` is never stored without keys.
- **Alternatives considered**: one transaction writing keys and mode together at sign-in. Rejected for AUTH-01: the mode must not become `google` before the restore check finishes, or a crash during ACC-02 would leave the user signed in with auto backup able to run over the account's backup.

## R4. What "signed in" means for each kind of Drive work

- **Decision**:
  - **Auto and background backups** (`syncAutoBackupSchedule`, `BackgroundBackupScheduler`, `runAutoBackup`) require `authMode == google` (they read `backupAccountEmail` today; interim I1).
  - **Manual Drive work started by the user** (ACC-02 "Keep this phone's data" backup, AUTH-01's first backup, restore download) requires the account keys only, so it works during AUTH-01 before `commitSignIn()`.
  - `AccountService.stateOf` returns `SignedOut` unless `authMode == google` and the keys are set.
- **Rationale**: nothing may upload on its own while the user is still choosing on AUTH-01 (spec FR-032), but the choices on AUTH-01 themselves need Drive.
- **Alternatives considered**: committing `google` before ACC-02. Rejected (R3).

## R5. Start-up account checks

- **Decision**: `AccountService.restoreSession()` becomes:
  - `authMode == google`: silent sign-in. No session (null) → `forgetAfterAuthLoss()` (keys cleared, `authMode = guest`, data kept). A thrown failure (offline) → stays `google`, unverified.
  - `authMode` `none` or `guest` with keys present: clear the keys and call `AccountAuth.signOut()` (spec FR-009). With no keys: no Google call at all (spec SC-002).
  
  `_afterAndroidRestore` (bootstrap) clears the keys as today, then calls `adoptSilentSession()` only when the restored `authMode` is `google`; on success the keys come back and `google` stays; on failure `authMode = guest`. A restored `guest` or `none` makes no Google call (spec FR-010; replaces interim I7).
- **Rationale**: matches `docs/spec.md` §16 "Account state is local" and "First start after an Android Auto Backup restore" word for word, and keeps a guest's start free of Google calls.

## R6. Routing

- **Decision**: a new `authModeProvider` (`lib/core/settings/settings_providers.dart`, keepAlive) selects `AppSettings.authMode` from `appSettingsProvider`. `appRouter` listens to it, and `redirectFor` takes `authMode` as a parameter:
  - Rule 3 (onboarding) stays first. The SYS-04 exception for onboarding (`settingPin`) is removed: Intro no longer opens SYS-04.
  - New rule 3b: onboarding done and `authMode == none` → every location except `/splash` and `/login` goes to `/login`.
  - New rule 3c: `/login` with `authMode` `guest` or `google` → Home (rule 4 then puts SYS-03 first when locked).
  - Rule 4 (lock) applies only when `authMode != none`.
  - New rule 7: `/more/account` while `authMode != google` → `/more` (spec FR-028).
  
  `initialLocationFor(settings)` returns `/onboarding`, else `/login` when `authMode == none` (a notification or widget payload is dropped), else the lock or target path as today.
- **Rationale**: the planning input asks for the redirect to read `authMode` through a provider; `redirectFor` stays a pure function so every rule keeps its unit test (`test/app/router/redirect_test.dart`).
- **Alternatives considered**: navigating to `/login` imperatively from ACC-03 and ACC-04. Rejected: `docs/spec.md` §5 makes the redirect the single mechanism ("setting `authMode` to `none` therefore lands on AUTH-01 with the back stack cleared"), which also covers restarts.

## R7. App lock across login and logout

- **Decision**: the lock session starts locked only when `onboardingDone && lockEnabled && authMode != none` (bootstrap and `FakeBootstrap`). `app.dart` listens to `authModeProvider`: on `none` → `guest`/`google` it calls `lockSession.start(lockEnabled: settings.lockEnabled)`, so leaving AUTH-01 with app lock on shows SYS-03 first (AUTH-01 AC); on → `none` it resets the session. The resume re-lock (`docs/spec.md` §5 step 7) checks `authMode != none`.
- **Rationale**: AUTH-01 must show before SYS-03 even with app lock on (SYS-01 AC), and SYS-03 must follow login.

## R8. Where AUTH-01 lives and how it reaches ACC-02

- **Decision**: `lib/features/auth/` (planning input) with `presentation/screens/login_screen.dart` and one controller, `presentation/controllers/login_controller.dart`. It depends only on `core/`: `accountServiceProvider`, a new `AccountSignIn.login()` (R9), `accountUiProvider.showRestoreChoice(afterSignIn: true)` for ACC-02 and the no-data restore, `proServiceProvider.restore()` for Restore purchase, `networkStateSourceProvider`, and `settingsRepositoryProvider` (`setAuthMode`, `setFinishSetupPending`). It never imports `lib/features/account/` (constitution II). The route `/login` is added to `routes.dart` and `app_router.dart` as a top-level `GoRoute`.
- **Rationale**: reuses 010's ACC-02, safety copy, password prompt, and no-data rule through the existing `AccountUi` port (010 research R18) instead of porting `OnboardingController.restoreWithGoogle`.
- **Alternatives considered**: putting AUTH-01 in `lib/features/account/` as `docs/spec.md` §3 sketches. Rejected because the planning input names `lib/features/auth/`; `docs/spec.md` §3's folder comment is updated to match (task in the plan).

## R9. The AUTH-01 Google path

- **Decision**: `AccountSignIn.login()` returns a `LoginOutcome`:
  - offline → `LoginOffline` (no request);
  - chooser cancelled → `LoginCancelled`; sign-in failed → `LoginFailed(error)` (nothing written in either);
  - signed in (keys saved, not committed), Drive list empty → `LoginNoBackup`;
  - Drive list has backups → `LoginHasBackups(newest)`;
  - listing Drive failed after sign-in → `LoginFailed(error)` and the keys are cleared again (the user is still on AUTH-01 with `authMode` `none`).
  
  `LoginController` never takes a `BuildContext`: for `LoginHasBackups`, it returns `LoginNext.chooseRestore(newest)`, the screen opens `showRestoreChoice(afterSignIn: true)`, and the result comes back through `LoginController.onRestoreChoice(result)`. `restored` → Restore purchase in the background; `kept` → (ACC-02 already started the backup); `closed` (a failed or cancelled no-data restore, or a failed ACC-02 restore) → the restore error view with "Try again" (shows the choice again) and "Continue without restoring". For `LoginNoBackup` and every finished path: `commitSignIn()`, `setFinishSetupPending(true)`, and for `LoginNoBackup` a first manual backup to Drive (failure is quiet: auto backup retries). The router then leaves `/login` by itself.
- **Rationale**: one place writes `authMode` on the Google path, after every branch has settled, which is what the spec's "Then it sets `authMode = google` … and goes to Home" describes.

## R10. The "Finish setting up" sheet after every login

- **Decision**: both AUTH-01 paths call `setFinishSetupPending(pending: true)` just before setting `authMode`. `app.dart`'s existing `_maybeFinishSetup` already shows the sheet once on Home and clears the flag when app lock is on, so no change is needed there. Guest sign-in from More does not set it (spec Assumptions).
- **Rationale**: replaces interim I6 with one line per path and reuses 010's sheet and host unchanged.

## R11. The SET-01 account card and ACC-04 behind the `AccountUi` port

- **Decision**: `AccountUi` (`lib/core/account/account_ui.dart`) gains `Widget accountCard()` and `Future<void> showLogOutGuest(BuildContext context)`. It also gains `Future<void> startGuestSignIn(BuildContext context)`, so SET-02's Drive card, the SET-01 card and ACC-04 share one guest sign-in without settings importing the account feature (analysis C1). The account feature implements all of them (`AccountFeatureUi`): `widgets/account_card.dart` reading the plain core `accountCardViewProvider` (no second Notifier on SET-01; analysis C2), `widgets/guest_sign_in.dart`, and `widgets/log_out_guest_dialog.dart` with `controllers/log_out_guest_controller.dart`. SET-01 (`lib/features/settings/`) places the card first in its list and shows the "Log out of guest" row (Data group, `error` color) while `authMode == guest`; both go through the port.
- **Card status**: the card controller derives `BackupStatusPolicy.derive(...)` from the same settings fields ACC-01 uses, then maps `BackupStatusOffline` and `BackupStatusWaitingForWifi` to `BackupStatusBackedUp(lastBackupAt)` (clarification Q3). "Backing up…" comes from the backup lease that `BackupCoordinator` writes while any backup runs, in any isolate (`backupLeaseUntil`, UTC ms). Today it is a raw settings row; 011 decodes it read-only into `AppSettings.backupLeaseUntil` (no setter: only the coordinator writes it), and the card shows "Backing up…" while it is later than now. ACC-01 keeps its own `busy` flag for the button and also reads the lease, so the two never disagree (spec FR-025). A restore holds the same lease, but the card is not on screen during a restore. `BackupStatusBackedUp(lastBackupAt: null)` reads "Not backed up yet."
- **Rationale**: features don't import each other (constitution II); 010 already solved this for ACC-02 with the same port.
- **Alternatives considered**: moving the card into `lib/core/widgets/`. Rejected: it needs account controllers and the planning input puts it in `lib/features/account/`.

## R12. One erase with a keep-list (SET-01, SYS-03, ACC-03, ACC-04)

- **Decision**: 010 T041 turns `AppResetService.eraseAll()` into `eraseAll({EraseScope scope = EraseScope.thisPhoneData})`. 011 adds the second scope and the shared preference set:
  - `devicePreferenceKeys` = `locale`, `currencyCode`, `themeMode`, `selectedTheme`, `enabledModules`, `moduleOrder`, `onboardingDone` (clarification Q1).
  - `EraseScope.thisPhoneData` (SET-01 Erase all data, SYS-03 "Forgot PIN?", ACC-03 "Remove data") keeps `devicePreferenceKeys` + `authMode`, the account keys, `deviceId`, `adsInstallAt`, `lastKnownDriveBackup*`, `autoBackupFrequency`, `autoBackupWifiOnly`, `adConsentStatus`, and the Pro keys (`removeAdsPurchased`, `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending`; analysis I2, so a Pro user never loses Pro to an erase); resets both change counters to 0.
  - `EraseScope.guestLogOut` (ACC-04) keeps `devicePreferenceKeys` + `deviceId`, `adsInstallAt`, `adConsentStatus`, `removeAdsPurchased`, `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending`, and writes `authMode = none` inside the same transaction.
  
  Both scopes delete every module row and the `unlocks` rows, then (best effort, as today) module files, notifications, background jobs, receipts, the safety copy, the PIN and lockout state, and the backup password. Neither scope calls Google: the erase's current `accountAuth.signOut` step is dropped (T041 keeps the sign-in; a guest has none). `afterErase` still resets the lock session and re-runs bootstrap, which now routes to Home or `/login` because onboarding is kept.
- **Premium theme fallback**: the selected theme is kept; with its `unlocks` row gone and Pro not owned, the existing theme gate already shows Default Teal (feature 007 FR-020), so no extra write is needed.
- **Rationale**: the planning input asks ACC-04 to reuse the existing erase with an option to keep device preferences; a named scope keeps both keep-lists in one tested place (`drift_app_reset_service_test.dart`) instead of two hard-coded lists.
- **Alternatives considered**: a free-form `Set<String> keep` parameter (010 T041's first idea). Rejected: callers in presentation would then name storage keys, which belong to `data/`.

## R13. Fakes that record calls

- **Decision**: extend the existing fakes instead of adding new ones:
  - `FakeAccountAuth` (`test/helpers/backup_fakes.dart`) gains `final calls = <String>[]` (`signIn`, `signInSilently`, `signOut`) alongside its counters.
  - `FakeDriveBackupStore` (`test/helpers/fakes.dart`) already records `calls`.
  - A helper `expectNoGoogleCalls(FakeAccountAuth auth, FakeDriveBackupStore drive)` in `test/helpers/backup_fakes.dart` asserts both lists are empty; AUTH-01 "Continue as guest" (online and offline), the guest session test (§16 section AC), and ACC-04 use it.
  - `pumpTestApp` gains a `drive` parameter so tests can pass the recording store.
- **Rationale**: the planning input asks for a fake sign-in and Drive client that records calls; both fakes exist and are already used by 010's tests, so extending them keeps one source of truth.

## R14. Removing 010's interim paths

- **Decision**: each **Replaced in 011** row is removed in code and tests, not left behind a flag:

| 010 interim | Removed in 011 |
| --- | --- |
| I1 signed in = email set | `AccountService.stateOf`, the three auto backup checks (R4) read `authMode` |
| I2 SYS-02 "Restore with Google" | `_RestoreWithGoogle`, `OnboardingController.restoreWithGoogle`, `GoogleRestoreStatus`, `googleRestore*` state fields, `LanguageStep.restore`, their strings (`onboarding_restoreWithGoogle`, `onboarding_noBackupFound`), `test/app/sign_in_entry_points_test.dart` SYS-02 cases; also the SYS-02 step 4 app lock button (`PrivacyStep.onSetAppLock`, `appLockOn`) and the router's `settingPin` exception |
| I3 ACC-01 only from SET-02 | the SET-01 card opens ACC-01; SET-02 email entry stays |
| I4 sign-out / cancelled switch → More tab | `router.go(Routes.more)` in `sign_out_sheet.dart` and `account_screen.dart`; ACC-03 relies on the redirect to `/login`; Switch account signs out to `guest` and ACC-01 closes back to SET-01 by rule 7 |
| I5 revoked token keeps "signed out" | R5 |
| I6 Finish setting up only after restores | R10 |
| I7 Android restore without `authMode` | R5 |
| I8 paused/failed only on ACC-01 | R11 |

  The `// Interim (Replaced in 011)` comments and the tests named "(interim …)" are rewritten for the new behavior. 010's T103 is closed as replaced by 011's integration flow. `docs/spec.md` §14's "Interim until T3.6" note is removed when 011 is done (spec FR-040).
- **Rationale**: spec FR-040; leaving dead branches would keep an untested sign-in path in SYS-02 that the spec forbids ("Intro shows no 'Restore with Google' or 'Set app lock' option").

## R15. Strings

- **Decision**: new strings go in `tool/l10n/phase0_strings.py` (en, hi, gu together), regenerated with `python tool/l10n/phase0_strings.py` and `flutter gen-l10n` (docs/CLAUDE.md). Keys: `auth_title`, `auth_body`, `auth_continueWithGoogle`, `auth_continueAsGuest`, `auth_guestNote`, `auth_signInCancelled`, `auth_signInFailed`, `auth_offline`, `auth_tryAgain`, `auth_restoring`, `auth_restoreFailed`, `auth_continueWithoutRestoring`, `auth_signedOutKept`; `accountCard_guestTitle`, `accountCard_signIn`, `accountCard_backedUp({time})`, `accountCard_backingUp`, `accountCard_notBackedUp`, `accountCard_paused`, `accountCard_failed`; `settings_logOutGuest`; `logOutGuest_title`, `logOutGuest_body`, `logOutGuest_signInInstead`, `logOutGuest_confirm`, `logOutGuest_failed`; the reworded SYS-02 step 4 body. Existing account strings are reused where the text is identical ("Couldn't sign in…", "Connect to the internet to sign in with Google", "Signed in. Your data is backed up.", "Couldn't restore…"). `test/core/l10n/no_sync_wording_test.dart` covers the new keys.
