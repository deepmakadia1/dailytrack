---

description: "Task list for feature 010: Google account and cloud backup"
---

# Tasks: Google Account and Cloud Backup (§16, ACC-01, ACC-02, ACC-03)

**Regenerated**: 2026-10-27 by `/speckit-tasks` from the design documents re-matched to `docs/spec.md` after feature 011. Task IDs and completion marks from the earlier run are kept, so finished work stays finished; new tasks use a letter suffix next to the task they follow (for example T024a).

**Input**: Design documents from `/specs/010-google-account-backup/`

**Prerequisites**: plan.md, spec.md, research.md (R#), data-model.md, contracts/ (services.md, screens.md, routes.md, android.md), quickstart.md

**Tests**: Required. Constitution IV says every acceptance criterion copied into spec.md needs at least one automated test. Test names start with the Screen ID or `§16` (for example `ACC-02 restores without the choice when the phone has no data`). Widget tests use `pumpTestApp` with fakes from `test/helpers/fakes.dart` and `test/helpers/backup_fakes.dart` and `NoAdsService`, and never open a database. Data tests use `makeRealContainer`. Pure tests use `test/helpers/mutable_clock.dart`.

**Organization**: Tasks are grouped by user story (spec.md US1–US7) so each can be built and checked on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story (US1–US7) the task belongs to
- UI strings are added only in `tool/l10n/phase0_strings.py` (en, hi, gu), then `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`; ARB files are never edited by hand (docs/CLAUDE.md)

## Scope (after feature 011)

From spec.md "Scope after feature 011" and plan.md "Interim behavior until feature 011":

- **In 010**: device ID and Android restore detection, change counter triggers, metadata and count labels, background and scheduled auto backup with day-based rotation, the conflict rule with pause and notification, the empty-phone guard, ACC-01, ACC-02, ACC-03, Switch account, Delete my backups, the safety copy and "Restore previous phone data", silent sign-in and revoked-token handling, Android Auto Backup rules and the first start after an Android restore, the "Finish setting up" sheet, and sign-in from the SET-02 Drive card.
- **Not in 010** (feature 011): `authMode` with its migration and redirect, AUTH-01, the SYS-02 Intro changes, the SET-01 account card (so there is no SET-01 Account row task), ACC-04, and the guest sign-in entry points in SET-01 and ACC-04.
- **Interim (Replaced in 011)**: tasks with this label build plan.md's interim behavior I1–I8 (signed in = `backupAccountEmail` set; sign-in from the SET-02 Drive card, SYS-02 "Restore with Google", SYS-03, and Switch account; ACC-01 from the SET-02 Drive card; the More tab after ACC-03 "Keep" and a cancelled Switch account chooser). Implement them as written; 011 replaces them.

Checkboxes from the earlier run may lag behind the code (for example `account_screen.dart` and `account_controller.dart` exist while T059 and T060 are open). Before implementing an open task, check what already exists and change it to match the task instead of starting over.

---

## Phase 1: Setup (Governance, Spec, Strings)

**Purpose**: Resolve the plan's gate items (Constitution I and III) and add shared strings and routes before any code.

- [x] T001 Amend Constitution III with `/speckit-constitution` (MINOR, 1.0.3 → 1.1.0): user data may also leave the device through Android's own device backup, which the user turns on in system settings, limited to the database file with secure storage and receipts excluded. Update the matching "Data rules" line in `docs/CLAUDE.md` in the same change (plan Complexity Tracking row 1) in `.specify/memory/constitution.md`
- [x] T002 Update `docs/spec.md` to match this feature before code (Constitution I; plan gate I), and add a 2026-10-23 entry to the Changes line:
  - SET-02 Behavior: replace "keeps the last 5 auto backups in Drive" with the FR-035 day-based rule (clarification Q1).
  - §16 Auto backup: background backups use that rule too.
  - §16 ACC-02: add the safety copy and SET-02 "Restore previous phone data" (Q3), and turning "Encrypt backup" on with the restored password after an encrypted restore (Q2).
  - §16 Conflict rule: add the empty-phone guard (research R10).
  - §4 settings: replace `dataChangedSinceBackup` with `dataChangeCounter` + `backedUpChangeCounter`, and add `deviceId` (copy), `autoBackupPauseNotified`, `finishSetupPending` (research R5, data-model §1).
  - §4 Device identity: note the settings copy used to detect an Android restore (R4).
  - §16 Android Auto Backup: the include-list rules (R14).
  - §14: add task T3.5 for this feature.
- [X] T003 [P] Add every account string to `tool/l10n/phase0_strings.py` (en, hi, gu), then regenerate with `python tool/l10n/phase0_strings.py` and `flutter gen-l10n` (output in `lib/core/l10n/gen/`). Use placeholders and plurals, never concatenation. Strings: ACC-01 texts and footnote, status lines ("Backed up to Google," never "Synced"), offline text, errors, the Delete dialog with `{count}` and `{email}`, the conflict and empty-phone dialogs with `{device}` and `{time}`, ACC-02 texts including "From this phone" and "From unknown device", ACC-03 texts, Finish setting up, the SYS-02 button and messages (interim), the SET-02 "Sign in with Google", "Signed in. Your data is backed up.", "Couldn't sign in. Check your connection and try again.", "Connect to the internet to sign in with Google", and "Restore previous phone data" texts, the ACC-03 "Signed out. Your data is still on this phone." snackbar, the pause notification title and body, "Android phone", and count labels such as "{count, plural, one{1 habit} other{{count} habits}}"
- [X] T004 [P] Add `Routes.account = '/more/account'` and `Routes.accountSegment = 'account'` in `lib/app/router/routes.dart` (contracts/routes.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The account layer, device identity, metadata, change counter, and the extended Drive store and backup service. Every story needs these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Settings state

- [X] T005 Add the new keys to `AppSettings` in `lib/core/settings/domain/app_settings.dart`, with defaults from data-model §1: `accountDisplayName` String? null, `accountPhotoUrl` String? null, `deviceId` String? null, `dataChangeCounter` int 0, `backedUpChangeCounter` int 0, `lastBackgroundBackupAt` int? null, `lastKnownDriveBackupAt` int? null, `lastKnownDriveBackupDeviceId` String? null, `autoBackupPausedByConflict` bool false, `autoBackupPauseNotified` bool false, `finishSetupPending` bool false. Add the key constants and encode/decode to `lib/core/settings/data/settings_codec.dart`, then run build_runner
- [X] T006 Add setters to `lib/core/settings/domain/settings_repository.dart` and implement them in `lib/core/settings/data/settings_repository_impl.dart`:
  - `setAccount(AccountProfile?)`: writes or clears email, name, and photo together.
  - `setDeviceIdCopy(String)`
  - `setBackedUpChangeCounter(int)`
  - `setLastBackgroundBackupAt(int)`
  - `setLastKnownDriveBackup({int? at, String? deviceId})`
  - `setAutoBackupPause({required bool paused, required bool notified})`
  - `setFinishSetupPending(bool)`

  `dataChangeCounter` has no setter; only the SQLite triggers write it. Mirror all setters in the fake in `test/helpers/fakes.dart`.
- [X] T007 [P] Settings tests in `test/core/settings/settings_account_keys_test.dart`:
  - each new key round-trips through the codec;
  - none is in `BackupSettingsPolicy.restorableKeys`;
  - `setAccount(null)` clears all three account keys.

### Change counter (research R5, data-model §2)

- [X] T008 Add `Set<String> get tables` and `Future<bool> hasUserData(AppDatabase db)` to `BackupSection` in `lib/core/backup/backup_section.dart` (contracts/services.md)
- [X] T009 [P] Implement `tables` and `hasUserData` in `lib/features/expense/data/backup/expense_backup_section.dart` (R11). Tables: `accounts`, `categories`, `transactions`, `budgets`, `recurring_rules`. `hasUserData` is true when there is any non-deleted transaction, budget, or recurring rule, any category with `isDefault = false`, or any account other than the single seeded Cash account.
- [X] T010 [P] Implement `tables` and `hasUserData` in `lib/features/habit/data/backup/habit_backup_section.dart`. Tables: `habits`, `habit_schedules`, `habit_entries`. `hasUserData` is true when there is any non-deleted habit.
- [X] T011 [P] Tests in `test/features/backup_sections_test.dart` (real Drift): `hasUserData` is false right after seeding, true after one transaction, one non-default category, one habit, or a second account, and false again once those rows are soft-deleted (ACC-02 criterion "Seeded categories and the Cash account alone count as no data.")
- [X] T012 Bump `AppDatabase.schemaVersion` to 5 in `lib/core/database/app_database.dart`, and add `from4To5` creating the triggers from data-model §2, with the same triggers created after `createAll` in `onCreate`:
  - `bk_<table>_ins|upd|del` on every table listed in T009/T010;
  - `bk_settings_ins|upd|del` with `WHEN NEW.key IN (<BackupSettingsPolicy.restorableKeys>) OR NEW.key LIKE 'module.%'` (`OLD.key` for delete).

  Each trigger upserts `settings` key `dataChangeCounter` (+1). Then run `dart run drift_dev make-migrations` so `drift_schemas/app_database/` and `lib/core/database/app_database.steps.dart` are regenerated.
- [X] T013 Add a no-op section upgrade from backup schema 4 to 5 for the expense and habit sections (the docs/CLAUDE.md rule; no backed-up table changed). Update `GoogleDriveBackupStore.schemaVersion` to follow `AppDatabase.schemaVersion` instead of the hard-coded `4` in `lib/core/backup/data/google_drive_backup_store.dart`
- [X] T014 [P] Migration test 4 → 5 and a fresh-create test in `test/drift/app_database/migration_4_to_5_test.dart`. The data is unchanged, and the triggers exist after both paths.
- [X] T015 [P] Trigger coverage test in `test/core/database/change_counter_triggers_test.dart` (real Drift):
  - (a) every table of every registered `BackupSection.tables` has all three triggers in `sqlite_master`;
  - (b) the settings trigger's key list equals `BackupSettingsPolicy.restorableKeys`;
  - (c) writing `latestSeenAt` or `dataChangeCounter` doesn't raise the counter;
  - (d) a transaction insert, a habit check-in from a second container, and a `locale` change each raise it by one.
- [X] T016 [P] Create pure `ChangeCounter.changed({current, backedUp})` in `lib/core/backup/domain/change_counter.dart` with tests in `test/core/backup/domain/change_counter_test.dart`

### Device identity (research R4)

- [X] T017 [P] Create pure `DeviceIdentity`, `DeviceIdOrigin`, and `DeviceIdentityPolicy.resolve({fileId, settingsId})` (the R4 table) plus `displayName(manufacturer, model)` ("Android phone" when both are empty; at most 60 chars) in `lib/core/account/domain/device_identity.dart`
- [X] T018 [P] Tests for every R4 row and the `displayName` cases in `test/core/account/device_identity_policy_test.dart`
- [X] T019 Add a `getNoBackupDir` channel method (`noBackupFilesDir.absolutePath`) to the `dailytrack/window` channel in `android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/MainActivity.kt` (check the package path with `find android -name MainActivity.kt`), and extend `test/android/main_activity_test.dart`
- [X] T020 Create the `DeviceIdFile` interface and `ChannelDeviceIdFile` (reads and writes `<noBackupDir>/device_id`, never throws on read) in `lib/core/account/data/no_backup_device_id_store.dart`; add `FakeDeviceIdFile` to `test/helpers/fakes.dart`
- [X] T021 Create `DeviceIdentityService` in `lib/core/account/device_identity_service.dart`:
  - `ensure()` reads the file and the settings copy, resolves them, writes a new UUID v4 (`uuid`) to both when needed, and returns the origin.
  - `current()` returns the ID plus the live name from `DeviceInfoSource`.

  Add tests in `test/core/account/device_identity_service_test.dart`.

### Account layer (research R1, R2; data-model §6)

- [X] T022 [P] Create the `AccountProfile` and `AccountState` (`SignedOut`, `SignedIn{profile, verified}`) types in `lib/core/account/domain/account.dart` and the `AccountAuth` port in `lib/core/account/domain/account_auth.dart` (contracts/services.md)
- [X] T023 Change `GoogleAuth` in `lib/core/backup/data/google_auth.dart` to implement `AccountAuth`:
  - `signIn()` returns `AccountProfile` (email, `displayName`, `photoUrl`) and keeps the scope authorization.
  - `signInSilently()` uses `attemptLightweightAuthentication`.
  - `signOut()` calls `GoogleSignIn.instance.signOut()`; `disconnect()` stays.

  Update the callers of the old `connect()`.
- [X] T024 Create `AccountService` in `lib/core/account/account_service.dart` with the transitions in data-model §6:
  - `watch()`, `current()`;
  - `restoreSession()` (never throws; a silent failure keeps the stored email with `verified: false`);
  - `signIn()`: saves the profile, sets `autoBackupFrequency` off → daily, calls `syncAutoBackupSchedule`, returns null when cancelled;
  - `signOut()`: clears the account keys, `lastKnownDriveBackup*`, `lastBackgroundBackupAt`, and the pause flags, and cancels `core.autoBackup` and `core.backgroundBackup`;
  - `forgetAfterAuthLoss()`.

  Add providers in `lib/core/account/account_providers.dart` (`accountAuthProvider`, `accountServiceProvider`, `accountStateProvider`, `deviceIdentityServiceProvider`) and run build_runner.
- [X] T025 [P] `AccountService` tests over a fake `AccountAuth` in `test/core/account/account_service_test.dart`:
  - sign-in saves the profile and turns Off → Daily, but leaves Weekly as is;
  - a cancelled sign-in changes nothing (ACC-01 criterion "Cancelling sign-in changes nothing.");
  - sign-out clears the keys and cancels both jobs;
  - silent-sign-in transitions: no session (null) clears the keys and keeps data; a thrown error keeps the user signed in and unverified; auth loss clears the keys (data-model §6, interim I5).
- [X] T024a **Interim (Replaced in 011)** Change `AccountService.restoreSession()` in `lib/core/account/account_service.dart` to match `docs/spec.md` §16 "Account state is local" (FR-004, research R2): when `signInSilently()` returns null (token revoked, account removed), clear the account keys and keep all data; when it throws (offline, transient), keep the stored account with `verified: false`. `forgetAfterAuthLoss()` keeps clearing the keys. Covered by T025. Write T025's silent-sign-in cases first: `FakeAccountAuth.signInSilently()` returning null must clear the keys; throwing `DriveOffline`, `DriveUnavailable`, or a `PlatformException` must keep the account with `verified: false`. Any other exception also keeps the account; only a null result clears it. 011 adds `authMode = guest` to both clearing paths.
- [X] T026 Bind `accountAuthProvider` to `googleAuthProvider` in `lib/app/production_overrides.dart`; add `FakeAccountAuth` to `test/helpers/backup_fakes.dart`

### Metadata and Drive store (research R8, R15, R16)

- [X] T027 [P] Create `BackupMeta` (`deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, `counts` keyed `"<moduleId>.<kind>"`, `schemaVersion`, `encrypted`) with `toJson`/`fromJson`, and `BackupMetaCodec.toProperties`/`fromProperties`, in `lib/core/backup/domain/backup_meta.dart`. The codec enforces Drive's limit of "≤ 30 entries, each key + value ≤ 124 bytes UTF-8", cuts `device` to fit, writes counts as `c.<moduleId>.<kind>` and `encrypted` as `0`/`1`, and returns null when `deviceId` or `createdAt` is missing.
- [X] T028 [P] Codec tests in `test/core/backup/domain/backup_meta_test.dart`: round trip, a 200-char device name cut to fit, the 30-entry limit, a missing `deviceId` giving null, and a Gujarati device name counted in bytes, not chars.
- [X] T029 Add optional `BackupMeta? meta` to `BackupDocument` in `lib/core/backup/domain/backup_document.dart`: `toJson` writes `"meta"` when present, `fromJson` accepts files without it (FR-043), and `copyWith` keeps it. Extend `test/core/backup/backup_domain_test.dart`.
- [X] T030 Change `DriveBackupStore` in `lib/core/backup/domain/drive_backup_store.dart`:
  - `DriveBackupEntry` gains `BackupMeta? meta`;
  - `upload(bytes, {fileName, meta})` replaces `kind:`;
  - add `deleteAll()`;
  - remove `connect`, `disconnect`, and `pruneAuto`.

  Implement the changes in `lib/core/backup/data/google_drive_backup_store.dart`: properties from `BackupMetaCodec`, `meta` parsed in `list()`, and `deleteAll` that continues past failures and rethrows the first one. Update `driveBackupStoreProvider` in `lib/core/backup/backup_providers.dart` and the fake in `test/helpers/backup_fakes.dart`.
- [X] T031 [P] Update `test/core/backup/google_drive_backup_store_test.dart`: properties are written and read through the fake Drive client; entries without `deviceId` have `meta == null`; `deleteAll` removes every DailyTrack file and keeps going after one failure.
- [X] T032 [P] Create pure `AutoBackupRotation.toDelete(entries, {nowLocal})` in `lib/core/backup/domain/auto_backup_rotation.dart` (R15, FR-035). It keeps today's newest auto backup plus the newest auto backup of each of the 5 most recent earlier local days that had one, never returns a manual backup, and groups days with `toLocal()`.
- [X] T033 [P] Rotation tests in `test/core/backup/domain/auto_backup_rotation_test.dart`, including spec US4 scenario 5 (4 today and 2 on each of the 7 earlier days keep 6), backups around midnight, a +05:30 offset, gaps of days with no backup, and manual backups that are never deleted.

### Engine and backup service (research R5, R8, R9, R10)

- [X] T034 Extend `BackupEngine` in `lib/core/backup/data/backup_engine.dart`:
  - `exportDocument()` also reads `dataChangeCounter` inside its transaction and returns it with the document (as a record);
  - `create()` takes the `DeviceIdentity` and `BackupKind` and writes `meta` (counts from each section's `counts()`, `encrypted` from the password);
  - add `hasUserData()` (any section);
  - `open()` exposes the file's `meta` on `RestorePreview`.

  Update `backupEngineProvider`.
- [X] T035 [P] Create the pure `BackupConflictPolicy.check({newest, thisDeviceId, lastKnownAt, phoneHasData})` in `lib/core/backup/domain/backup_conflict_policy.dart`, returning `NoConflict`, `NewerFromOtherDevice`, or `EmptyOverData` (R9, R10; FR-038, FR-038a). A null meta is `NoConflict`; `EmptyOverData` is returned only when this phone has no data and the newest backup's counts sum to more than 0.
- [X] T036 [P] Conflict policy tests in `test/core/backup/domain/backup_conflict_policy_test.dart`: other device and newer; other device and older; same device; null `lastKnownAt`; null meta (FR-043); empty phone over data; empty phone over an empty backup.
- [X] T037 Change `BackupService.backupToDrive` in `lib/core/backup/backup_service.dart` (data-model §8):
  - signature `({required BackupKind kind, required ConflictMode conflict})`, returning `DriveBackupResult`;
  - it lists Drive, runs the conflict policy, returns `NeedsConfirmation` for `ask`, `PausedByConflict` (setting the pause) or `SkippedEmpty` for `pause`, and skips the check for `overwrite`;
  - it uploads with meta;
  - on success it writes `backedUpChangeCounter` (the snapshot value), `lastKnownDriveBackup*`, and clears the pause;
  - after an auto backup it deletes `AutoBackupRotation.toDelete` (failures ignored, as today).

  Add `backupIfChanged()`, which returns `Unchanged` when `ChangeCounter.changed` is false (R7). Remove the `pruneAuto` call.
- [X] T038 [P] Update `test/core/backup/backup_service_test.dart` (real engine on an in-memory database, fake Drive):
  - meta is uploaded;
  - the counter snapshot is taken in the transaction, so a write during upload leaves the data "changed" (FR-031);
  - each conflict mode;
  - rotation deletes the right IDs;
  - `backupIfChanged` returns `Unchanged`.
- [X] T039 Create the core `AccountRestore` in `lib/core/account/account_restore.dart` without the safety copy yet (US3 adds it), covering `phoneHasData`, `phoneCounts` (this phone's non-deleted counts per module, from `BackupEngine.exportDocument`, for ACC-02 so presentation never touches `data/`), `open`, `apply`, and `keepThisPhone`:
  - `open(entry, askPassword)`: downloads the backup and tries the saved password, then `askPassword`.
  - `apply(...)` uses `RestoreService.apply` and afterwards sets `backedUpChangeCounter = dataChangeCounter` and `lastKnownDriveBackup*` from the file's meta (the file wins, FR-041), and clears the pause.
  - FR-019b: if the backup was encrypted, `setBackupEncrypt(true)` and save the used password with `BackupPasswordStore.write`, only after success.
  - `finishSetupPending` is set when `fromEmptyPhone` and the lock is off.
  - `keepThisPhone(newest)` writes `lastKnownDriveBackup*`, clears the pause, and starts `backupToDrive(manual, overwrite)` unawaited.

  Add `accountRestoreProvider`.
- [X] T040 [P] `AccountRestore` tests in `test/core/account/account_restore_test.dart`:
  - a failed apply writes nothing and saves no password;
  - FR-019b turns encryption on with the restored password;
  - "Keep this phone's data" writes nothing locally and starts a backup;
  - `lastKnownDriveBackupAt` comes from the file's meta when it disagrees with the listing.
- [X] T041 (FR-006a) Change Erase all data in `lib/app/production_overrides.dart` and `lib/core/reset/data/drift_app_reset_service.dart`:
  - stop calling `driveBackupStore.disconnect`;
  - keep the account keys, `deviceId`, `lastKnownDriveBackup*`, `autoBackupFrequency`, and `autoBackupWifiOnly`;
  - reset both change counters to 0;
  - keep deleting the backup password;
  - take the settings to keep as a parameter (default: the list above) instead of hard-coding it, so 011's ACC-04 Log out of guest can run the same erase with its own keep-list (device preferences, onboarding done, `deviceId`, `adsInstallAt`, ad consent, Pro state). Don't build ACC-04 here.

  Update `test/core/reset/drift_app_reset_service_test.dart` and `test/app/erase_flow_test.dart` (SET-01: erase doesn't sign out; R16).
- [X] T042 Wire SYS-01 in `lib/app/bootstrap.dart`: call `DeviceIdentityService.ensure()` before routing and `AccountService.restoreSession()` unawaited after routing. Keep the `restoredFromAndroidBackup` origin for US7 (store it in a provider; no action yet). Extend `test/app/bootstrap_test.dart`.

**Checkpoint**: The app builds and behaves as before, and backups now carry metadata. User stories can start.

---

## Phase 3: User Story 1 - Get my data back on a new phone (Priority: P1) 🎯 MVP

**Goal**: A fresh install signs in and gets the newest backup restored without a choice (the ACC-02 no-data rule), then Finish setting up and a background Restore purchase. In 010 the entry point is SYS-02 "Restore with Google" (**Interim (Replaced in 011)** by AUTH-01 "Continue with Google").

**Status**: built. `AccountRestore`, the progress view, the Pro restore callback, and `FinishSetupSheet` are reused by 011's AUTH-01; only the SYS-02 button and its controller code are removed there.

**Independent Test**: On a fresh install with a fake account that has a backup, tap Restore with Google and compare the restored data, then repeat with no backup and with a cancelled sign-in (spec US1).

### Tests for User Story 1

- [X] T043 [P] [US1] Widget tests in `test/features/onboarding/onboarding_restore_test.dart` for the copied SYS-02 criteria:
  - "Restore with Google" on an account with a backup restores it without a choice sheet, skips steps 2–4, and lands on DSH-01 with the backup's language, currency, and modules.
  - After a restore from onboarding, the "Finish setting up" sheet appears once and Restore purchase runs.
  - Cancelling sign-in, or an account with no backup, returns to onboarding with no data written.

  Also cover the encrypted backup asking for the password, a wrong password writing nothing, and after success "Encrypt backup" being on.
- [X] T044 [P] [US1] Widget tests for the Finish setting up sheet in `test/features/account/finish_setup_sheet_test.dart`: the three actions, "Allow notifications" hidden below Android 13, any action clears `finishSetupPending`, and the sheet isn't shown when the lock is on.

### Implementation for User Story 1

- [X] T045 [US1] Add the secondary "Restore with Google" button (key `sys02.restoreWithGoogle`) below the language chips in `lib/features/onboarding/presentation/widgets/language_step.dart`
- [X] T046 [US1] Add `restoreWithGoogle()` to `lib/features/onboarding/presentation/controllers/onboarding_controller.dart` and its state in `onboarding_state.dart`. Flow per contracts/screens.md "SYS-02 changes":
  - `AccountService.signIn()`; cancelled → no change.
  - `drive.list()` empty → the "No backup found on this account" message, staying on step 1.
  - Otherwise `AccountRestore.open` with the core `backup_password_sheet.dart`, then `apply(fromEmptyPhone: true)`, then `go(Routes.home)`.
  - On failure, the SET-02 error text with "Try again".
- [X] T047 [US1] Show the full-screen "Restoring your data…" progress view while the restore runs in `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (back is blocked while it runs)
- [X] T048 [US1] After a SYS-02 restore, call `ProService.restore()` unawaited and show the "Pro restored" snackbar only when it returns owned. Wire this through a callback bound in `lib/app/production_overrides.dart` (core never imports billing UI) into `lib/features/onboarding/presentation/controllers/onboarding_controller.dart` (FR-029)
- [X] T049 [US1] When "Get started" finishes onboarding while signed in, start a backup unawaited (spec US1 scenario 4). Use `backupToDrive(kind: manual, conflict: ConflictMode.pause)`: there is no screen to show a dialog here, and the account had no backup (otherwise the user would have restored), so normally nothing conflicts; if another phone backed up in the meantime, the pause shows up in ACC-01 instead of being dropped. Change in `lib/features/onboarding/presentation/controllers/onboarding_controller.dart`
- [X] T050 [P] [US1] Create `FinishSetupSheet` in `lib/features/account/presentation/widgets/finish_setup_sheet.dart` (contracts/screens.md): "Set app lock" → `Routes.pin` with mode `set`, "Allow notifications" (Android 13+, existing permission service), and "Not now". Each action clears `finishSetupPending`.
- [X] T050a [US1] Bring `FinishSetupSheet` in line with `docs/spec.md` (FR-028): "Allow notifications" shows only on Android 13+ when `POST_NOTIFICATIONS` isn't granted, and dismissing the sheet clears `finishSetupPending` like any action. Extend `test/features/account/finish_setup_sheet_test.dart`.
- [X] T051 [US1] In `lib/app/app.dart`, listen to `finishSetupPending` and show `FinishSetupSheet` once when the router location is `/home` and the app is unlocked (R13)

**Checkpoint**: A fresh install can be fully restored from Google (MVP).

---

## Phase 4: User Story 2 - Sign in and manage my account (ACC-01) (Priority: P1)

**Goal**: Sign-in from the SET-02 Drive card (the §16 "Guest sign-in" steps), and ACC-01 for a signed-in account, opened from the Drive card's email: Back up now, Restore, Switch account, Sign out, Delete my backups, and the offline state.

**Scope**: ACC-01 has no signed-out layout and no sign-in button; it pops to the More tab when the account signs out. The SET-01 entry point comes with 011's account card.

**Independent Test**: With the fake account and fake Drive, sign in from the SET-02 Drive card, open ACC-01, back up now, switch account, and delete backups, checking ACC-01 and the Drive files after each step (spec US2).

### Tests for User Story 2

- [X] T052 [P] [US2] Widget tests in `test/features/account/account_screen_test.dart` for every copied ACC-01 criterion (spec US2 list), plus offline Sign out still enabled, no interstitial requested after "Back up now" (fake `AdService` records nothing), and the status line never using color alone. Use the ACC-01 criteria as they now read in `docs/spec.md` §16: the signed-in layout shows "Backed up to Google," and the screen pops to the More tab if the account signs out while it is open. Test "ACC-01 can't be opened as a guest" as 010 reads it (can't be opened while signed out; the SET-02 Drive card starts sign-in). The sign-in criteria are tested on the SET-02 Drive card (T054a). Also cover FR-012: "Switch account" with the fake chooser cancelled leaves the user signed out, keeps every local row, closes ACC-01, and lands on the More tab (`Routes.more`).
- [X] T054 [P] [US2] Update `test/features/settings/backup_screen_test.dart`: the Drive card shows "Sign in with Google" when signed out and the email (tap → ACC-01) when signed in, and "Connect"/"Disconnect" are gone.
- [X] T054a [P] [US2] Widget tests in `test/features/settings/backup_screen_sign_in_test.dart` for the §16 "Guest sign-in" criteria as read in 010 (spec.md US2, interim I1): signing in from the Drive card to an account without a backup backs up this phone's data, sets `backupAccountEmail`, turns Auto backup to Daily if it was Off, and the card shows the account; an account with a backup opens ACC-02 (not dismissible), and neither choice combines rows; a cancelled or failed sign-in leaves the user signed out and every row unchanged; offline shows "Connect to the internet to sign in with Google" and makes no request; a failed first backup leaves the user signed in. Also cover FR-036 with the real engine on an in-memory database (`makeRealContainer`, in `test/core/backup/backup_service_test.dart` if the widget test can't open a database): add a transaction while signed out, sign in to an account with no backup, and check the first uploaded backup contains that transaction and `backedUpChangeCounter` equals `dataChangeCounter`.
- [X] T055 [P] [US2] Pure tests for `BackupStatusPolicy.derive` (data-model §7 precedence: offline > backingUp > paused > failed > waitingForWifi > backedUp) in `test/core/backup/domain/backup_status_policy_test.dart`

### Implementation for User Story 2

- [X] T056 [P] [US2] Create pure `BackupStatus` and `BackupStatusPolicy.derive` in `lib/core/backup/domain/backup_status_policy.dart` (data-model §7)
- [X] T057 [P] [US2] Add a `getNetworkState` channel method (`{online, metered}` from `ConnectivityManager`) to `MainActivity.kt`, add `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>` to `android/app/src/main/AndroidManifest.xml`, and create `NetworkStateSource` plus `ChannelNetworkStateSource` with a provider in `lib/core/support/network_state_source.dart`. Add a fake to `test/helpers/fakes.dart`; extend `test/android/main_activity_test.dart` and `test/android/manifest_test.dart`.
- [X] T058 [US2] Register the ACC-01 route under the More branch in `lib/app/router/app_router.dart` (`Routes.accountSegment`), and extend `test/app/router/` with a route test.
- [X] T059 [US2] Create `AccountController` and `AccountScreenState` (contracts/screens.md) in `lib/features/account/presentation/controllers/account_controller.dart`:
  - `signIn()`: if the account has backups and `phoneHasData()`, open ACC-02 through `accountUiProvider` (provided by US3; until then, restore directly when the phone has no data); with no backups, a first `backupToDrive(manual, overwrite)` and the snackbar "Signed in. Your data is backed up.". Keep this logic only for `switchAccount()`; ACC-01 shows no "Sign in with Google" button. 011 moves it into the shared guest sign-in flow.
  - `backUpNow()`: `ask`, then the `ConfirmDialog` on `NeedsConfirmation`, then `overwrite`.
  - `restore()`
  - `switchAccount()`: back up first, "Switch anyway" on failure, `signOut`, then `signIn`; a cancelled chooser leaves the user signed out and goes to `Routes.more` (interim I4, **Replaced in 011**).
  - `deleteMyBackups()`: dialog with the count and email, then `deleteAll()`, then reset `lastKnownDriveBackup*`.
  - Status is derived with `BackupStatusPolicy` and refreshed on resume.

  Run build_runner.
- [X] T060 [US2] Create the ACC-01 screen in `lib/features/account/presentation/screens/account_screen.dart` (layouts from docs/spec.md §16 ACC-01, test keys from contracts/screens.md):
  - signed-in layout only, with the "Your app lock PIN is never backed up." footnote; no signed-out layout (remove it if already built). If the account stops being signed in while the screen is open, pop back to the More tab;
  - the account card uses `CategoryAvatar` with `Image.network` and an initial fallback (R17);
  - a skeleton status while loading; `ErrorState` only in the status area;
  - offline disables the network actions with the reason;
  - one primary button;
  - "Delete my backups" uses the `error` color through `ConfirmDialog`.
- [X] T061 [P] [US2] Create the `BackupStatusLine` widget (icon plus text, `warning` color for paused and failed) in `lib/features/account/presentation/widgets/backup_status_line.dart`
- [X] T061a [P] [US2] Make `BackupStatusLine` in `lib/features/account/presentation/widgets/backup_status_line.dart` use the data-model §7 texts: "Backed up to Google" for `backedUp` (never "Synced"), "Backup paused: a newer backup from another phone exists", "Waiting for Wi-Fi", "Backing up…", and the offline text (FR-008, FR-051). Extend its widget test in `test/features/account/backup_status_line_test.dart`.
- [X] T063 [US2] Rework the SET-02 Drive card in `lib/features/settings/presentation/screens/backup_screen.dart` and `lib/features/settings/presentation/controllers/backup_controller.dart`:
  - signed out → "Sign in with Google" (`AccountService.signIn`, then ACC-02 through `accountUiProvider` when the account has a backup);
  - signed in → the email row → ACC-01, Back up now (`ConflictMode.ask` with the dialog), Auto backup, and Wi-Fi only;
  - remove `connect`/`disconnect` and the Disconnect dialog;
  - point `lib/core/backup/presentation/drive_restore_flow.dart` at `AccountService.signIn`.
- [X] T063a [US2] Finish the SET-02 Drive card sign-in in `lib/features/settings/presentation/controllers/backup_controller.dart` and `backup_screen.dart` to match `docs/spec.md` §16 "Guest sign-in" (FR-007, FR-009): with no backup on the account, run the first backup and show "Signed in. Your data is backed up." (a failed first backup keeps the user signed in); with no phone data, restore directly behind a progress view; failure text "Couldn't sign in. Check your connection and try again."; offline, show "Connect to the internet to sign in with Google" and make no request. Makes T054a pass.
- [X] T064 [US2] Route SYS-03 "Forgot PIN?" Drive restore through `AccountService.signIn` and `AccountRestore` (spec Edge Cases) in `lib/features/lock/presentation/` (the existing forgot-PIN flow that calls `drive_restore_flow.dart`); update its existing test.

**Checkpoint**: ACC-01 (signed in) and the SET-02 card work end to end with a fake account.

---

## Phase 5: User Story 3 - Choose between my backup and this phone's data (ACC-02) (Priority: P1)

**Goal**: The ACC-02 sheet, the no-data shortcut, the safety copy, and SET-02 "Restore previous phone data". The SET-02 Drive list uses the same restore path.

**Independent Test**: Seed different data on the phone and in a fake Drive backup, sign in, and check both choices and the safety copy (spec US3).

### Tests for User Story 3

- [X] T065 [P] [US3] Widget tests in `test/features/account/restore_choice_sheet_test.dart` for every copied ACC-02 criterion (spec US3 list), plus: not dismissible after sign-in; a close button when opened from ACC-01; "From this phone" for the same device ID; a backup without meta shows the device name stored by feature 008, or "Unknown device" when there is none (FR-043); the offline state; the restore failure message.
- [X] T066 [P] [US3] Safety copy tests:
  - `SafetyCopyPolicy.expired` with a mutable clock at 6 days 23 h and at 7 days, in `test/core/backup/domain/safety_copy_policy_test.dart`;
  - store save, read, and replace, and that `BackupStorageFull` makes `AccountRestore.apply` return `SafetyCopyFailed` with nothing written, in `test/core/account/account_restore_safety_test.dart`;
  - restoring the copy brings back exactly the phone's earlier data (row counts and checksums, as in `test/core/backup/backup_round_trip_test.dart`).
- [X] T067 [P] [US3] Widget tests in `test/features/settings/backup_screen_safety_copy_test.dart`: "Restore previous phone data" shows the copy's date and counts only while it exists, goes through the existing summary and "Replace current data?" dialog, and disappears after a successful restore; Drive list rows show the device name and counts; restoring an encrypted local file from "Restore from file" turns "Encrypt backup" on with that password, and a failed one saves nothing (FR-019b).

### Implementation for User Story 3

- [X] T068 [P] [US3] Create pure `SafetyCopyPolicy` (`keepFor = 7 days`, `expired({createdAt, nowMs})` true when `now - createdAt >= 7 days`) in `lib/core/backup/domain/safety_copy_policy.dart`
- [X] T069 [US3] Create the `SafetyCopyStore` interface and a file implementation in `lib/core/backup/data/safety_copy_store.dart` (data-model §5): one backup file plus `safety.json` (`createdAt`, `counts`, `fileName`) in `<getApplicationSupportDirectory>/restore_safety/`; a new copy replaces the folder; save failures throw `BackupStorageFull`. Add a provider in `lib/core/backup/backup_providers.dart` and a fake to `test/helpers/backup_fakes.dart`.
- [X] T070 [US3] Add the safety copy step to `AccountRestore.apply` in `lib/core/account/account_restore.dart` (FR-019a): when `phoneHasData()`, `BackupEngine.create(includeReceipts: true, password: null)` goes to the store first; on `BackupStorageFull` it returns `SafetyCopyFailed` before anything is written.
- [X] T071 [US3] Delete the safety copy in Erase all data (`lib/app/production_overrides.dart` resetLock steps) and delete an expired copy in SYS-01 (`lib/app/bootstrap.dart`), extending `test/app/erase_flow_test.dart` and `test/app/bootstrap_test.dart`
- [X] T072 [US3] Create `RestoreChoiceController` in `lib/features/account/presentation/controllers/restore_choice_controller.dart`. Its state covers the summary from `entry.meta`, this phone's counts from `AccountRestore.phoneCounts()` (never from `BackupEngine`, which is in `core/backup/data/`: Constitution II), `passwordNeeded`, `passwordError`, `working`, and `error`. Actions: `restore(password?)`, `keep()`.
- [X] T073 [US3] Create the ACC-02 sheet and `showRestoreChoice(context, {newest, afterSignIn})` in `lib/features/account/presentation/widgets/restore_choice_sheet.dart` (contracts/screens.md). It uses `AppBottomSheet` with `isDismissible`/`enableDrag` false after sign-in, the summary card, "This phone" counts, an inline password field and error, the primary and secondary buttons, the "See all backups" link → `Routes.backup`, and the success snackbar with counts.
- [X] T074 [US3] Add `accountUiProvider` (`showRestoreChoice`, `showSignOutSheet`), declared in `lib/core/account/account_providers.dart` (throws until overridden) and bound to the account feature in `lib/app/production_overrides.dart` (R18), and switch ACC-01 `signIn()` and `restore()` to it in `lib/features/account/presentation/controllers/account_controller.dart`. When `phoneHasData()` is false, callers restore directly behind a progress view and never show the sheet (FR-016).
- [X] T075 [US3] SET-02 Drive list in `lib/features/settings/presentation/screens/backup_screen.dart` and `lib/core/backup/presentation/drive_backup_tile.dart`: show `meta.deviceName` and counts (`device` fallback for old entries), restore through `AccountRestore` (safety copy, FR-019b), and add the "Restore previous phone data" tile backed by `SafetyCopyStore` using `lib/core/backup/presentation/restore_flow.dart`, deleting the copy after success. Apply FR-019b to SET-02 "Restore from file" too: after a successful restore of an encrypted local file, turn "Encrypt backup" on and save the password that opened it (in `lib/core/backup/presentation/restore_flow.dart` through a shared `AccountRestore.rememberEncryption(password)` helper, so the rule lives in one place).

**Checkpoint**: Signing in on a phone with data offers the choice; replaced data can be recovered for 7 days.

---

## Phase 6: User Story 4 - Stay backed up without thinking about it (Priority: P2)

**Goal**: Background backups when the app is hidden (15 minutes, changed data, Wi-Fi only), skipping unchanged scheduled backups, and day-based rotation in use.

**Independent Test**: With a fake clock, scheduler, and Drive, change data and send the app to the background repeatedly; check enqueues, uploads, and metadata (spec US4).

### Tests for User Story 4

- [X] T076 [P] [US4] Pure tests for `BackgroundBackupTrigger.shouldEnqueue` in `test/core/backup/domain/background_backup_trigger_test.dart` with a mutable clock: true at exactly 15 minutes and false at 14:59; false when signed out, when Auto backup is Off, before onboarding, or when unchanged (§16 criterion "Going to the background with changed data starts a backup; going to the background again within 15 minutes does not; nothing starts when no data changed.")
- [X] T077 [P] [US4] `BackgroundBackupScheduler` tests with a fake `BackgroundScheduler` in `test/core/backup/background_backup_scheduler_test.dart`: one `enqueueOnce('core.backgroundBackup')` with `NetworkRequirement.unmetered` when Wi-Fi only (otherwise `connected`), `lastBackgroundBackupAt` written, and a second hide within 15 minutes enqueuing nothing (§16 criterion "With "Wi-Fi only" on, background and scheduled auto backups don't upload on mobile data and run once Wi-Fi is back.", scheduler side)
- [X] T078 [P] [US4] Update `test/core/backup/auto_backup_test.dart`: `runAutoBackup` skips unchanged data (no upload), counts background runs in the 3-failures notice, applies rotation, and calls `forgetAfterAuthLoss` on `DriveAuthRequired`. Update `test/app/background_dispatcher_test.dart`: `core.backgroundBackup` maps to `runAutoBackup`.

### Implementation for User Story 4

- [X] T079 [P] [US4] Create pure `BackgroundBackupTrigger` (`minGap = 15 min`) in `lib/core/backup/domain/background_backup_trigger.dart` (contracts/services.md)
- [X] T080 [US4] Add `enqueueOnce(uniqueName, {network})` to `BackgroundScheduler` in `lib/core/background/background_scheduler.dart`, implemented in `lib/core/background/workmanager_background_scheduler.dart` with `registerOneOffTask(..., existingWorkPolicy: ExistingWorkPolicy.replace, constraints: Constraints(networkType: ...))`. Update the fake in `test/helpers/fakes.dart`.
- [X] T081 [US4] Create `BackgroundBackupScheduler.onAppHidden()` and `backgroundBackupTaskName = 'core.backgroundBackup'` in `lib/core/backup/background_backup_scheduler.dart`, with a provider. It reads settings, asks the trigger (clock from `clockProvider`), writes `lastBackgroundBackupAt`, and enqueues; it never throws.
- [X] T082 [US4] Call `BackgroundBackupScheduler.onAppHidden()` from the existing `onHide` in `lib/app/app.dart`, after `markBackgrounded`
- [X] T083 [US4] Update `runAutoBackup` in `lib/app/auto_backup_task.dart` to use `backupIfChanged()` with `ConflictMode.pause`, treat `Unchanged`/`SkippedEmpty` as success, and call `AccountService.forgetAfterAuthLoss` on `DriveAuthRequired`. Map `backgroundBackupTaskName` to `runAutoBackup` in `lib/app/background_dispatcher.dart`. Cancel `core.backgroundBackup` wherever `core.autoBackup` is cancelled (`lib/core/backup/auto_backup_schedule.dart` when Off, sign-out, Erase all data).

**Checkpoint**: Changes are backed up shortly after leaving the app, and old auto backups rotate by day.

---

## Phase 7: User Story 5 - Don't overwrite another phone's newer backup (Priority: P2)

**Goal**: The manual conflict and empty-phone dialogs, the auto backup pause with one notification, and the "Backup paused" status with Review.

**Independent Test**: With a fake Drive holding a newer backup from another device ID, trigger manual and auto backups and check dialogs, uploads, the notification, and the pause (spec US5).

### Tests for User Story 5

- [X] T084 [P] [US5] Tests in `test/core/backup/auto_backup_conflict_test.dart`: an auto run against a newer other-device backup uploads nothing, sets the pause, and shows the notification once across two runs (§16 criterion "Auto backup does not upload over a newer backup from another device; it pauses, notifies once, and resumes after a restore, "Keep this phone's data," or a manual backup."). The pause ends after `AccountRestore.apply`, `keepThisPhone`, or a manual `overwrite`. An auto run with an empty phone over data uploads nothing and doesn't pause.
- [X] T085 [P] [US5] Widget tests in `test/features/account/conflict_dialog_test.dart`: from ACC-01 Back up now and from SET-02 Back up now, the dialog names the device and time, "Cancel" uploads nothing, and "Back up anyway" uploads; the empty-phone variant text; ACC-01 shows "Backup paused" with Review → ACC-02 for that backup.

### Implementation for User Story 5

- [X] T086 [P] [US5] Create a shared `showBackupConflictDialog(context, ConflictCheck)` returning `Future<bool>`, using `ConfirmDialog` with "Back up anyway"/"Cancel" and both texts, in `lib/core/backup/presentation/backup_conflict_dialog.dart` (core presentation, so SET-02, ACC-01, and ACC-03 share it). Use it in `account_controller.dart` and `backup_controller.dart`.
- [X] T087 [US5] Show the pause notification in `lib/app/auto_backup_task.dart` on `PausedByConflict` when `!autoBackupPauseNotified` and notifications are on. Use `stableNotificationId('backup-paused')`, channel `NotificationChannelId.backup`, and payload `Routes.account`, then set `autoBackupPauseNotified`. Clear both pause flags in `BackupService` and `AccountRestore` when the pause ends (FR-039, FR-048).
- [X] T088 [US5] Add "Review" to the paused status in `lib/features/account/presentation/screens/account_screen.dart`, opening `showRestoreChoice` for the newest backup (afterSignIn: false). Skip the "Backup paused" text on the SET-01 row; 011's account card shows it.

**Checkpoint**: Two phones on one account never silently replace each other's newer backup.

---

## Phase 8: User Story 6 - Sign out without losing anything (ACC-03) (Priority: P2)

**Goal**: The ACC-03 sheet: back up first, keep or remove data, "Sign out anyway", and typed DELETE after a failure.

**Independent Test**: With a fake Drive, sign out in each combination (backup ok or failed × keep or remove) and check local rows, Drive files, and the screen afterwards (spec US6).

### Tests for User Story 6

- [X] T089 [P] [US6] Widget tests in `test/features/account/sign_out_sheet_test.dart` for every copied ACC-03 criterion (spec US6 list), plus offline going straight to the failed state, a declined conflict dialog counting as a failure, and the `error` color on the button when Remove is chosen.
- [X] T090 [P] [US6] Controller tests in `test/features/account/sign_out_controller_test.dart`: the step 1 state machine (`checking` → `backingUp` → `backedUp`/`failed`); "Sign out" enabled only when `backedUp` or `failed && signedOutAnyway`; Remove calling `signOut` then `eraseAll`; no Drive call after sign-out (ACC-03 criterion "After sign-out, no Drive request is made until the user signs in again.", checked through the fake Drive's call log).

### Implementation for User Story 6

- [X] T091 [US6] Create `SignOutController` and `SignOutState` (contracts/screens.md) in `lib/features/account/presentation/controllers/sign_out_controller.dart`. The backup is `backupToDrive(manual, ask)` with the shared conflict dialog; Remove after a failure requires the typed-DELETE dialog already used by SET-01 Erase all data (reuse that widget from `lib/core/widgets/`, or move it there if it lives in the settings feature).
- [X] T092 [US6] Create the ACC-03 sheet and `showSignOutSheet(context)` in `lib/features/account/presentation/widgets/sign_out_sheet.dart`:
  - Keep → `AccountService.signOut()`, back to ACC-01, snackbar "Signed out. Your data is still on this phone.";
  - Remove → `signOut()`, then `AppResetService` erase plus deleting the safety copy, then the onboarding redirect.

  Hook it up to `accountUiProvider` and to ACC-01 "Sign out".

- [X] T092a [US6] **Interim (Replaced in 011)** Change ACC-03 "Keep data on this phone" in `lib/features/account/presentation/widgets/sign_out_sheet.dart` to `go(Routes.more)` with the snackbar "Signed out. Your data is still on this phone." instead of returning to ACC-01 (FR-025, interim I4). "Remove data from this phone" keeps the erase's redirect to `/onboarding`. Update `test/features/account/sign_out_sheet_test.dart`. 011 changes both choices to `authMode = none` → AUTH-01.

**Checkpoint**: All account actions are complete and safe.

---

## Phase 9: User Story 7 - Android's own backup brings the app back safely (Priority: P3)

**Goal**: Android Auto Backup on for the database only, and safe first-start handling after an Android restore.

**Independent Test**: Simulate an Android restore (database present, no device ID file, no PIN hash, lock on) and start the app; parse the rules files (spec US7).

### Tests for User Story 7

- [X] T093 [P] [US7] Rules test in `test/android/backup_rules_test.dart`. Parse `backup_rules.xml` and `data_extraction_rules.xml`. Includes must be exactly `app_flutter/dailytrack.sqlite`, `-wal`, and `-shm` in `root`, for both `cloud-backup` and `device-transfer`. The exclude must be `sharedpref` `FlutterSecureStorage.xml`. The manifest must reference both files with `allowBackup="true"`. (§16 criterion "Neither a Drive backup file nor Android Auto Backup data contains the PIN hash, lockout state, or backup password (a test inspects the backup JSON and the backup rules XML).", XML side.)
- [X] T094 [P] [US7] Backup JSON test in `test/core/backup/backup_secrets_excluded_test.dart`: with a PIN, lockout state, and backup password set, a created backup (plain, zip, and decrypted encrypted) contains none of them and no account keys (§16 criterion above, JSON side; FR-047).
- [X] T095 [P] [US7] Bootstrap tests in `test/app/android_restore_start_test.dart` (§16 criteria "Two installs never share a `deviceId`, including after a Drive restore or an Android Auto Backup restore." and "On the first start after an Android Auto Backup restore with app lock on and no PIN hash, the lock is turned off and the "Finish setting up" sheet is shown instead of locking the user out."):
  - a settings `deviceId` without the file gets a new ID, lock and biometric off when there is no PIN, account keys cleared, `lastKnownDriveBackupAt` null, `finishSetupPending` set, Restore purchase called, notifications rescheduled, and no onboarding;
  - an upgrade with neither the file nor the settings copy does none of this;
  - a Drive restore keeps the device ID.

### Implementation for User Story 7

- [X] T096 [P] [US7] Create `android/app/src/main/res/xml/backup_rules.xml` and `android/app/src/main/res/xml/data_extraction_rules.xml` exactly as in contracts/android.md
- [X] T097 [US7] Set `android:allowBackup="true"`, `android:fullBackupContent="@xml/backup_rules"`, and `android:dataExtractionRules="@xml/data_extraction_rules"` in `android/app/src/main/AndroidManifest.xml`, and replace the feature 007 comment above `<application>` with the new rationale (spec §16, research R14). Update `test/android/manifest_test.dart`, which currently expects `allowBackup="false"`.
- [X] T098 [US7] Add the post-Android-restore steps to `lib/app/bootstrap.dart` for `DeviceIdOrigin.restoredFromAndroidBackup`, run before routing (R13, FR-046):
  - `LockService.status()` reports no PIN → `setLockEnabled(false)` and `setBiometricEnabled(false)`;
  - `setAccount(null)`, then `restoreSession()`;
  - `setLastKnownDriveBackup(at: null, deviceId: null)`;
  - `setFinishSetupPending(true)`;
  - `restoreAftermath` (notifications) and `ProService.restore()`, both unawaited.
- [X] T099 [US7] When `backupEncrypt` is on but the password is missing, ACC-01 shows "Backup failed: set your backup password in Backup and restore" (R13) in `lib/features/account/presentation/screens/account_screen.dart` and `lib/core/backup/presentation/backup_failure_text.dart`; add a case to `test/features/account/account_screen_test.dart`. Keep the text in `backup_failure_text.dart` so 011's SET-01 account card can show it too.

**Checkpoint**: Android device backup and transfer bring the data back without locking the user out or sharing a device ID.

---

## Phase 10: Polish & Cross-Cutting Concerns

- [X] T100 [P] Run the §15.10 design review checklist for ACC-01, ACC-02, ACC-03, Finish setting up, the SET-01 Account row, the SET-02 changes, and the SYS-02 button: tokens only, one primary action, states, 200% font scale on a 360 dp width, light and dark, 48 dp targets and semantic labels, and Hindi and Gujarati text 30% longer. Add a11y checks to `test/a11y/` following the existing tests there.
- [X] T101 [P] **Interim (Replaced in 011)** Confirm that no screen outside the listed places offers sign-in (§16 criterion "Every screen outside this section works the same with no account signed in, and only the places listed at the top of this section offer sign-in."): add `test/app/sign_in_entry_points_test.dart`, which searches `lib/` for `AccountService.signIn` and `showRestoreChoice` callers and allows only SET-02, SYS-02, SYS-03, and ACC-01 Switch account (FR-001, interim I2), and runs the existing smoke flow signed out with a fake Drive client that must record zero calls. In 011 the allowed list becomes AUTH-01, the SET-01 account card, SET-02, ACC-04, SYS-03, and ACC-01 Switch account, and the smoke flow runs as a guest.
- [X] T101a [P] Add `test/core/l10n/no_sync_wording_test.dart` (§16 criterion "No account or backup text in the app says "Synced" or "Sync"; status uses "Backed up to Google."", FR-051): load `lib/core/l10n/app_en.arb`; every value whose key starts with `account_` or `backup_` contains no "sync" (case-insensitive); and `account_statusBackedUp` equals "Backed up to Google". Run it after T003 and T061a.
- [X] T102 [P] Check the Drive metadata criterion (§16 "Each Drive backup has `deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, and `counts` in both `appProperties` and the file's `meta`.") end to end in `test/core/backup/backup_meta_end_to_end_test.dart`: upload through `BackupService` to the fake Drive client, then read both the properties and the decoded file.
- [ ] T103 **Interim (Replaced in 011)** Add the integration flow "sign in → back up → erase → Restore with Google → same data" to `integration_test/` next to the existing backup round trip (spec §13 integration tests), using the fake account seam. Seed 10,000 transactions and assert the restore step (from tapping "Restore with Google" to Home) takes under 2 minutes on the CI emulator, with no taps besides choosing the account in the fake chooser (SC-001). In 011 the flow becomes "sign in → back up → erase → AUTH-01 Continue with Google → same data," timed from tapping "Continue with Google."
- [X] T104 Map every acceptance criterion copied into `specs/010-google-account-backup/spec.md` to its test name in a short table at the end of this file (Constitution IV), and fix any gaps. Criteria marked *Deferred to 011* in spec.md get "Deferred to 011" in the table instead of a test; criteria with a 010 reading (interim) are tested as 010 reads them.
- [X] T105 Run the quality gates from quickstart §2 (`build_runner`, l10n, `flutter analyze` with zero warnings, `dart format --set-exit-if-changed .`, `flutter test --exclude-tags golden`) and fix everything they report.
- [ ] T106 Run the device checks in quickstart §4 on real devices (two phones, API ≥ 31 and ≤ 30), including the `adb shell run-as` check of the database path used in the backup rules. Also time SC-001 on a mid-range phone: a 10,000-transaction backup from the first onboarding screen to Home in under 2 minutes on Wi-Fi, with at most 3 taps besides choosing the account. Record the results and anything left open in the task summary. **Interim (Replaced in 011)**: time SC-001 through SYS-02 "Restore with Google" now; 011 re-times it through Intro and AUTH-01. Also check silent sign-in on device A: signed in, turn on airplane mode, force-stop, and cold start. The account must still be signed in (ACC-01 shows the offline status). Then remove the Google account from Android settings and cold start. The account must be cleared, with data kept (FR-004).

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: T001 and T002 come first (Constitution I and III gates). T003 and T004 can run alongside them.
- **Foundational (Phase 2)**: depends on Setup and blocks every story.
  - Settings first (T005–T007).
  - Then three chains that can run in parallel:
    - change counter: T008 → T009/T010 → T011, T012 → T013 → T014/T015, T016;
    - device identity: T017 → T019 → T020 → T021;
    - account layer: T022 → T023 → T024 → T025/T026.
  - Then metadata and Drive: T027 → T029 → T030 → T031; rotation T032/T033 in parallel.
  - Then the engine and service: T034 → T035/T036 → T037 → T038.
  - Then `AccountRestore` (T039/T040), Erase all data (T041), and bootstrap (T042).
- **User stories (Phases 3–9)**: all depend on Phase 2.
  - **US1 (P1)**: independent; MVP.
  - **US2 (P1)**: independent. ACC-01 sign-in on a phone with data needs ACC-02 from US3 (T074); until then it restores only on an empty phone.
  - **US3 (P1)**: independent of US1 and US2. T074 changes `account_controller.dart` from US2, so do it after T059 when both are built.
  - **US4 (P2)**: independent.
  - **US5 (P2)**: the dialogs need ACC-01 (US2) and SET-02 (T063); the pause logic needs US4's `runAutoBackup` change (T083).
  - **US6 (P2)**: needs ACC-01 (US2) as its entry point and the shared conflict dialog (T086).
  - **US7 (P3)**: independent; reuses the Finish setting up sheet from US1 (T050/T051).
- **Polish (Phase 10)**: after the stories you plan to ship.
- **New tasks from the 2026-10-27 regeneration**: T024a after T024 (T025 tests it); T050a after T050; T054a ∥ T063a after T063 (T054a fails until T063a); T061a after T061; T092a after T092 (T089 updated with it); T101a after T003 and T061a.
- **Feature 011** starts after this feature's quality gates (T105) pass. It depends on T041's keep-list, `AccountService`, `AccountRestore`, ACC-02, ACC-03, and `FinishSetupSheet`, and rewrites T101, T103, and the SC-001 timing for AUTH-01.

### Within each story

Tests are written first and must fail; then pure domain, then data and services, then controllers, then screens, then `lib/app/` wiring.

### Parallel opportunities

- Phase 1: T003 ∥ T004.
- Phase 2: the change-counter, device-identity, and account-layer chains run in parallel. T027/T028 ∥ T032/T033 ∥ T035/T036.
- After Phase 2: US1, US2, US3 (except T074), US4, and US7 can be worked on in parallel.
- All test tasks marked [P] in a story can be written together.
- The open follow-ups T024a, T050a, T061a, and T092a touch different files and can run in parallel.

---

## Parallel Example: Phase 2 pure domain

```text
Task: "T017 Create DeviceIdentityPolicy in lib/core/account/domain/device_identity.dart"
Task: "T027 Create BackupMeta and BackupMetaCodec in lib/core/backup/domain/backup_meta.dart"
Task: "T032 Create AutoBackupRotation in lib/core/backup/domain/auto_backup_rotation.dart"
Task: "T035 Create BackupConflictPolicy in lib/core/backup/domain/backup_conflict_policy.dart"
```

## Parallel Example: User Story 4

```text
Task: "T076 BackgroundBackupTrigger tests in test/core/backup/domain/background_backup_trigger_test.dart"
Task: "T077 BackgroundBackupScheduler tests in test/core/backup/background_backup_scheduler_test.dart"
Task: "T078 runAutoBackup and dispatcher test updates"
Task: "T079 Create BackgroundBackupTrigger in lib/core/backup/domain/background_backup_trigger.dart"
```

---

## Implementation Strategy

### MVP first (User Story 1)

1. Phase 1 (governance and spec updates first), then Phase 2.
2. Phase 3 (US1): a new phone can restore everything from Google.
3. **Stop and validate**: quickstart §4 step 5 and the SYS-02 tests.

### Incremental delivery

1. US1 → restore on a new phone (MVP).
2. US2 + US3 → manage the account on an existing phone and choose safely, with the 7-day safety copy.
3. US4 → automatic background backups with day-based rotation.
4. US5 → two-phone safety.
5. US6 → safe sign-out.
6. US7 → Android device backup fallback.

Each step ends with the quality gates (T105) and a summary, one task per session (docs/CLAUDE.md).

---

## Notes

- [P] tasks touch different files and depend on no unfinished task.
- Never import one feature from another. SYS-02 and SET-02 reach ACC-02 and ACC-03 only through `accountUiProvider` (R18).
- No new packages (plan Technical Context). If `device_info_plus` is wanted after all, it replaces `ChannelDeviceInfoSource` behind `DeviceInfoSource` only.
- A new module that joins backup must add its tables' triggers in its own migration; T015 fails until it does.

---

## Acceptance criteria → tests (T104, Constitution IV)

Every acceptance criterion copied into `spec.md`, read as 010 reads it (interim), with the tests that check it. "…" shortens a long test name.

| Criterion (spec.md) | Tests (file: name) |
|---|---|
| SYS-02 (interim) "Restore with Google" on an account with a backup restores it without a choice sheet, skips steps 2–4, and lands on DSH-01 with the backup's language, currency, and modules | `test/features/onboarding/onboarding_restore_test.dart`: SYS-02 "Restore with Google" on an account with a backup restores it without a choice sheet, skips steps 2–4, and lands on DSH-01 … |
| SYS-02 (interim) after a restore from onboarding, "Finish setting up" appears once and Restore purchase runs | `onboarding_restore_test.dart`: SYS-02 after a restore from onboarding, the "Finish setting up" sheet appears once and Restore purchase runs |
| SYS-02 (interim) cancelling sign-in, or an account with no backup, returns to onboarding with no data written | `onboarding_restore_test.dart`: SYS-02 cancelling sign-in returns to onboarding with no data written; SYS-02 an account with no backup stays signed in, says so, continues onboarding, … |
| ACC-01 shows name, email, photo (or initial), "Backed up to Google" with the last backup time and device, and all actions | `test/features/account/account_screen_test.dart`: ACC-01 shows name, email, photo or initial, "Backed up to Google" with the last backup time and device, and all actions |
| ACC-01 can't be opened signed out; the SET-02 Drive card starts sign-in instead (interim I1, I3) | `account_screen_test.dart`: ACC-01 closes to the More tab when the account signs out while it is open; `test/app/sign_in_entry_points_test.dart`: §16 only the listed places start sign-in or open ACC-02. Guest card form: Deferred to 011 |
| ACC-01 "Back up now" with a newer backup from another device shows the warning, and "Cancel" uploads nothing | `account_screen_test.dart`: ACC-01 "Back up now" with a newer backup from another device shows the warning, and "Cancel" uploads nothing; `test/features/account/conflict_dialog_test.dart`: ACC-01 Back up now over a newer backup from another phone: the dialog names the device and time; … (and the SET-02 variant) |
| ACC-01 "Delete my backups" removes every backup file and leaves local data and the sign-in in place | `account_screen_test.dart`: ACC-01 "Delete my backups" removes every backup file in the app folder and leaves local data and the sign-in in place |
| ACC-01 Switch account backs up to the old account first and never removes local data | `account_screen_test.dart`: ACC-01 Switch account backs up to the old account before signing out and never removes local data |
| ACC-01 offline, the network actions are disabled with an explanation and Sign out still works | `account_screen_test.dart`: ACC-01 offline, the network actions are disabled with an explanation and Sign out still works |
| Guest sign-in (010: from the SET-02 Drive card) to an account without a backup backs up this phone, saves the account, and turns Auto backup to Daily if it was Off | `test/features/settings/backup_screen_test.dart`: SET-02 "Sign in with Google" is the shared sign-in: it shows the account, Back up now, and Auto backup, turns Auto backup to Daily, and makes the first backup; `test/core/account/account_sign_in_test.dart`: §16 an account without a backup: this phone is backed up right away. `authMode` and SET-01 card: Deferred to 011 |
| Guest sign-in to an account with a backup opens ACC-02; "Restore from account" replaces, "Keep this phone's data" makes this phone the latest; no rows combined | `test/features/settings/backup_screen_sign_in_test.dart`: SET-02 signing in to an account with a backup opens ACC-02; neither choice combines rows |
| Cancelling or failing sign-in changes nothing (010: stays signed out) | `backup_screen_test.dart`: SET-02 US2-2 cancelling sign-in changes nothing and shows no error; SET-02 a failed sign-in says so; `account_sign_in_test.dart`: §16 cancelled sign-in changes nothing |
| ACC-02 the summary shows date, device name, counts, and encryption from metadata without downloading the file | `test/features/account/restore_choice_sheet_test.dart`: ACC-02 the summary shows the backup's date, device name, counts, and encryption from metadata without downloading the file |
| ACC-02 with no user data on the phone, the newest backup is restored without the choice | `restore_choice_sheet_test.dart`: ACC-02 with no user data on the phone, the newest backup is restored without showing the choice |
| ACC-02 seeded categories and the Cash account alone count as no data | `test/features/backup_sections_user_data_test.dart`: ACC-02 seeded categories and the Cash account alone count as no data |
| ACC-02 "Restore from account" replaces all module rows in one transaction; a failure leaves this phone's data unchanged | `test/core/account/account_restore_test.dart`: ACC-02 "Restore from account" replaces all module rows; …; `restore_choice_sheet_test.dart`: ACC-02 "Restore from account" restores and closes; a failure leaves this phone's data unchanged …; `test/core/backup/restore_failure_test.dart`: SET-02 AC2 a section throws mid-transaction after other modules were written: everything rolls back |
| ACC-02 "Keep this phone's data" writes nothing locally, starts a backup, and no warning appears for the declined backup | `account_restore_test.dart` and `restore_choice_sheet_test.dart`: ACC-02 "Keep this phone's data" writes nothing locally, starts a backup, and the declined backup … never warns |
| ACC-02 an encrypted backup asks for the password only when the saved one fails; a wrong password writes nothing | `restore_choice_sheet_test.dart`: ACC-02 the password is asked only when the saved one fails; a wrong password writes nothing; …; `account_restore_test.dart`: ACC-02 the saved password is tried first; … |
| ACC-03 with changes not yet backed up, sign-out backs up first and enables "Sign out" only after success or "Sign out anyway" | `test/features/account/sign_out_sheet_test.dart`: ACC-03 with changes not yet backed up, it backs up first and enables "Sign out" only after the backup succeeds; ACC-03 a failed backup offers "Try again" and "Sign out anyway"; …; `test/features/account/sign_out_controller_test.dart`: ACC-03 only when backedUp, or failed after "Sign out anyway" |
| ACC-03 "Keep data on this phone" leaves every local row in place (010: opens the More tab, fully usable signed out) | `sign_out_sheet_test.dart`: ACC-03 "Keep data on this phone" leaves every local row in place, opens the More tab, … (interim I4); `sign_out_controller_test.dart`: ACC-03 "Keep data on this phone" signs out without erasing |
| ACC-03 "Remove data from this phone" erases local data and keeps the Drive backups (010: opens SYS-02 through the erase's redirect) | `sign_out_sheet_test.dart`: ACC-03 "Remove data from this phone" erases local data, keeps the Drive backups, and opens onboarding; `sign_out_controller_test.dart`: ACC-03 "Remove data from this phone" signs out, then erases |
| ACC-03 after sign-out, `authMode` is `none` and the app opens AUTH-01 | Deferred to 011 |
| ACC-03 after a failed backup, "Remove data from this phone" needs the typed "DELETE" confirmation | `sign_out_sheet_test.dart`: ACC-03 after a failed backup, "Remove data from this phone" needs the typed DELETE confirmation; `sign_out_controller_test.dart`: ACC-03 "Remove data" after a failed backup needs the typed DELETE; … |
| ACC-03 after sign-out, no Drive request is made until the user signs in again | `sign_out_sheet_test.dart` and `sign_out_controller_test.dart`: ACC-03 after sign-out, no Drive request is made until the user signs in again |
| §16 every screen works the same signed out; only the interim entry points (I2) offer sign-in | `sign_in_entry_points_test.dart`: §16 only the listed places start sign-in or open ACC-02 |
| §16 signed out, the app makes no Drive or sign-in request unless the user starts one (guest form: Deferred to 011) | `sign_in_entry_points_test.dart`: §16 signed out, a full session makes no Google sign-in or Drive request |
| §16 no account or backup text says "Synced" or "Sync"; status uses "Backed up to Google" | `test/core/l10n/no_sync_wording_test.dart`: §16 no account_ or backup_ text says "sync" ($lang); §16 the status says "Backed up to Google" |
| §16 neither a Drive backup nor Android Auto Backup data contains the PIN hash, lockout state, or backup password | `test/core/backup/backup_secrets_excluded_test.dart`: §16 a $name backup holds no PIN, lock, password, or account state; `test/android/backup_rules_test.dart`: §16 Android 11 and lower back up only the database, never secure storage; §16 Android 12+ cloud backup and device transfer back up only the database, never secure storage |
| §16 going to the background with changed data starts a backup; again within 15 minutes does not; nothing starts when no data changed | `test/core/backup/background_backup_scheduler_test.dart`: §16 going to the background with changed data starts one one-off backup task …; §16 going to the background again within 15 minutes does not start another; …; §16 nothing starts when no data changed |
| §16 with "Wi-Fi only" on, background and scheduled auto backups don't upload on mobile data and run once Wi-Fi is back | `background_backup_scheduler_test.dart`: §16 with "Wi-Fi only" on the task waits for an unmetered network; `test/core/backup/auto_backup_test.dart`: Daily with Wi-Fi only waits for an unmetered network; `account_screen_test.dart`: ACC-01 a background backup waiting on a metered network says "Waiting for Wi-Fi" |
| §16 auto backup does not upload over a newer backup from another device; it pauses, notifies once, and resumes after a restore, "Keep this phone's data", or a manual backup | `test/core/backup/auto_backup_conflict_test.dart`: an auto backup does not upload over a newer backup from another phone: it pauses and shows the Backup notification once, …; the pause ends after a manual backup ("Back up anyway"), and auto backups resume; `account_restore_test.dart`: after a restore nothing counts as changed, the pause ends, …; `conflict_dialog_test.dart`: ACC-01 a paused auto backup shows "Backup paused"; Review opens ACC-02 … |
| §16 each Drive backup has `deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, and `counts` in both `appProperties` and `meta` | `test/core/backup/backup_meta_end_to_end_test.dart`: §16 each Drive backup has deviceId, deviceName, appVersion, createdAt, kind, and counts in both appProperties and the file's meta |
| §16 two installs never share a `deviceId`, including after a Drive restore or an Android Auto Backup restore | `test/core/account/device_identity_service_test.dart`: §16 two installs never share a deviceId: …; `test/app/android_restore_start_test.dart`: §16 after an Android restore with app lock on and no PIN: a new device ID, …; `test/app/bootstrap_test.dart`: SYS-01 the device ID is made before routing on a fresh install … |
| §16 first start after an Android Auto Backup restore with app lock on and no PIN hash: the lock is turned off and "Finish setting up" is shown | `android_restore_start_test.dart`: §16 after an Android restore with app lock on and no PIN: …, the lock off, …, "Finish setting up", … and no onboarding |

Gaps found and closed while building this table: SET-01 Erase all data keeping the sign-in (T041: `test/core/reset/drift_app_reset_service_test.dart`, `test/app/erase_flow_test.dart`); the device ID, silent sign-in, and expired safety copy at start (T042, T071: `test/app/bootstrap_test.dart`); the conflict dialog from both screens and its empty-phone text (T085); the ACC-03 controller (T090); auto backup's `SkippedEmpty` and `DriveAuthRequired` handling (T083: `test/core/backup/auto_backup_test.dart`).
