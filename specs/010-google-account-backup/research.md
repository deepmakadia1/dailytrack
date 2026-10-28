# Research: Google Account and Cloud Backup

All Technical Context unknowns are resolved below. Each decision cites the spec (FR-###) it serves. "Feature 008" is `specs/008-backup-export-notifications-widget`, whose code in `lib/core/backup/` this feature extends.

Re-checked on 2026-10-27 against `docs/spec.md` as updated for feature 011. Decisions that touch what 011 owns (`authMode`, AUTH-01, the SET-01 account card, ACC-04) describe 010's interim behavior; plan.md lists each one under "Interim behavior until feature 011" with the tag **Replaced in 011**.

## R1. Where the account lives, and what it reuses

**Decision**: A new `lib/core/account/` holds `AccountService` (sign in, silent sign-in, sign out, switch, `Stream<AccountState>`) and the device identity. It talks to Google only through a port, `AccountAuth`, implemented by the existing `GoogleAuth` (`lib/core/backup/data/google_auth.dart`), which stays the app's only `google_sign_in` wrapper. `GoogleAuth.connect()` is widened to return an `AccountProfile` (email, display name, photo URL) instead of an email, and gains `signOut()` next to `disconnect()`. Drive backup, restore, the engine, the coordinator, the password store, and the auto backup job stay in `lib/core/backup/` and are extended, not copied (FR-005). Screens ACC-01–ACC-03 live in `lib/features/account/`.

**Rationale**: Settings (SET-02), onboarding (SYS-02, interim), lock (SYS-03 "Forgot PIN?"), and account screens all need the same sign-in and restore rules, and feature 011 adds AUTH-01, the SET-01 account card, and ACC-04 on top of them. Features may not import each other (Constitution II), so the shared behavior must be in `core/`.

**Alternatives considered**: A second `google_sign_in` wrapper in `core/account` (rejected: two initializations and duplicated error mapping, FR-005). Keeping account state inside `BackupService` (rejected: sign-in is no longer just a backup setting; ACC-01, SET-02, and later 011's SET-01 card and router watch it).

## R2. Sign-in scopes and profile

**Decision**: `GoogleSignIn.instance.authenticate()` (google_sign_in 7.2.0) already returns the account's email, display name, and photo URL with the default `openid email profile` scopes; `authorizeScopes([drive.appdata])` is then requested as today. No new scope beyond FR-002. Silent sign-in at start uses `attemptLightweightAuthentication()` (FR-004, `docs/spec.md` §16 "Account state is local"):

- returns a profile: signed in and verified;
- returns null (no session: token revoked or account removed from the phone): clear the account keys and keep all data, so the user is signed out;
- throws (offline or a transient error): stay signed in, unverified; Drive calls report offline and backups resume when the network is back.

A `DriveAuthRequired` from Drive later (token revoked while running) clears the account the same way. Clearing the keys is interim I5 (**Replaced in 011**, which also sets `authMode = guest`).

**Rationale**: No extra consent screen; the Play data safety and OAuth verification items in spec §13 cover exactly these scopes.

## R3. Device name: reuse the existing channel, not `device_info_plus`

**Decision**: Use the existing `DeviceInfoSource` (`lib/core/support/device_info_source.dart`), which already reads manufacturer and model from `MainActivity`'s `dailytrack/window` channel, and which `driveBackupStoreProvider` already uses to write the `device` Drive property. Do **not** add `device_info_plus`. When both values are empty the name is "Android phone" (spec Assumptions).

**Rationale**: The planning input asked for `device_info_plus`, but feature 007 deliberately read device facts over its own channel "so the app needs no device-info plugin", and this feature needs only those same two strings. Constitution VII requires every new dependency to be justified; nothing here justifies a second source of the same data. If the user still prefers the plugin, it replaces `ChannelDeviceInfoSource` behind the same interface without touching anything else.

**Alternatives considered**: `device_info_plus` (rejected as above).

## R4. Device ID outside every backup

**Decision**: The device ID is a UUID v4 (existing `uuid` package) in a file `device_id` under Android's no-backup folder (`Context.getNoBackupFilesDir()`), read through a new `getNoBackupDir` method on the existing `dailytrack/window` channel (`MainActivity.kt`). A copy is also kept in the `settings` table as `deviceId` (not restorable). At start, `DeviceIdentityPolicy.resolve(fileId, settingsId)` (pure) decides:

| no-backup file | settings `deviceId` | Meaning | Action |
| --- | --- | --- | --- |
| present | same | normal start | none |
| missing | missing | first start, or update from a version before this feature | new ID, write both |
| missing | present | the database came from Android Auto Backup or device transfer | new ID, write both, run the post-Android-restore steps (R13) |
| present | different or missing | database replaced from elsewhere | treat as an Android restore (R13) |

Erase all data and sign-out keep the file; the settings copy is rewritten from the file at start (FR-044).

**Rationale**: The no-backup folder is the one place Android promises never to back up or transfer, so two installs can never share an ID. The settings copy is what makes an Android restore detectable: it travels with the database, the file does not. Upgrading users (no copy yet) are not mistaken for a restore.

**Alternatives considered**: `ANDROID_ID` (rejected: a hardware identifier, a Play policy concern, and shared across reinstalls); the ID in secure storage (rejected: secure storage is also excluded from backup, but it can't tell a fresh install from a restore).

## R5. Detecting changed data: a change counter kept by SQLite triggers

**Decision**: The spec's "changed since backup" mark (FR-031) becomes two numbers: `dataChangeCounter`, raised by SQLite triggers on every insert, update, or delete in a backed-up table and on writes to restorable `settings` keys, and `backedUpChangeCounter`, the counter value inside the snapshot of the last successful backup or restore. "Changed" is `dataChangeCounter != backedUpChangeCounter` (pure `ChangeCounter.changed`). The backup reads the counter inside the engine's export transaction, so a write during upload leaves the data "changed" (FR-031). The triggers are created by a Drift migration (schema 4 → 5) with a migration test; the trigger on `settings` has a `WHEN NEW.key IN (…) OR NEW.key LIKE 'module.%'` clause generated from `BackupSettingsPolicy`, so writing the counter itself, or any device-state key, never counts. Recursive triggers stay off (SQLite default).

To keep the trigger list honest, `BackupSection` gains `Set<String> get tables`, and a test asserts that every table of every registered section has its three triggers and that the `settings` trigger's key list equals `BackupSettingsPolicy.restorableKeys`. A future module adds its triggers in its own migration; the test fails until it does.

**Rationale**: Writes come from the UI isolate, WorkManager (recurring entries), notification buttons, and widget checks in background isolates. A trigger sees all of them, atomically with the write, without listeners. The planning input asked for a pure, unit-tested change counter: the comparison and the snapshot rule are pure; only the counting is in SQL.

**Alternatives considered**: Drift `tableUpdates` listener writing a flag (rejected: misses writes made while the app is closed, and the flag write itself is a `settings` update, so it can't tell restorable from device keys). Hashing the full export on each trigger (rejected: reads every row on every background; still needs a stored hash).

**Effect on backups**: The schema bump adds no table and changes no backed-up table, so the backup `schemaVersion` goes to 5 with a no-op upgrade step for each section (docs/CLAUDE.md rule). The `settings` key `dataChangedSinceBackup` named in `docs/spec.md` §4 is replaced by these two counters; §4 is updated before implementation.

## R6. The background backup trigger

**Decision**: `app.dart`'s existing `AppLifecycleListener.onHide` also calls `BackgroundBackupScheduler.onAppHidden()` (core/backup). It reads settings and asks the pure `BackgroundBackupTrigger.shouldEnqueue({signedIn, frequency, changed, onboardingDone, lastBackgroundBackupAt, now})`: true only when signed in, Auto backup is not Off, onboarding is done, data changed, and `now - lastBackgroundBackupAt >= 15 min` (FR-032). On true it writes `lastBackgroundBackupAt = now` and enqueues a WorkManager one-off task `core.backgroundBackup` with `ExistingWorkPolicy.replace` and the Wi-Fi-only network constraint (FR-034). The task runs the same `runAutoBackup` as the scheduled job, so failures, rotation, conflict, and notifications behave the same (FR-035). The clock is injected (`clockProvider`).

`BackgroundScheduler` gains `enqueueOnce(String uniqueName, {NetworkRequirement network})`, implemented in `WorkmanagerBackgroundScheduler` with `registerOneOffTask(..., existingWorkPolicy: replace)`.

**Rationale**: WorkManager keeps the task alive after the app is swiped away and waits for the network on its own, so "finishes even if the app is closed" and "waits for Wi-Fi" need no extra code. `replace` gives "never queued twice".

**Alternatives considered**: Uploading directly from `onHide` (rejected: Android may kill the process seconds after the app is hidden).

## R7. Skipping unchanged scheduled backups

**Decision**: `runAutoBackup` returns early without uploading when `ChangeCounter.changed` is false (FR-033). The existing catch-up rule (`AutoBackupPolicy.catchUpDue`) is unchanged.

## R8. Backup metadata

**Decision**: A pure `BackupMeta { deviceId, deviceName, appVersion, createdAt, kind, counts: Map<String,int> (keys "<moduleId>.<kind>"), schemaVersion, encrypted }` (FR-041).

- **In the file**: `BackupDocument` gains an optional `meta` object next to `format`, written by `BackupEngine.create` (counts from each section's existing `counts()`, which already excludes soft-deleted rows). Old files without `meta` still decode (FR-043). Local backup files carry it too.
- **On Drive**: `appProperties`, which Drive limits to 30 entries per app and 124 bytes per key + value: `app`, `kind`, `schemaVersion`, `device` (existing keys), plus `deviceId`, `appVersion`, `createdAt`, `encrypted`, and one `c.<moduleId>.<kind>` per count (7 today). The device name is cut to fit. A pure `BackupMetaCodec.toProperties/fromProperties` enforces the limits and returns null for entries without `deviceId` (pre-feature backups).
- `DriveBackupEntry` gets `BackupMeta? meta`; `DriveBackupStore.upload` takes the meta. If the file's `meta` (read at restore) disagrees with the listing, the file wins for the restore summary and the "last known backup" (FR-041).

**Rationale**: Listing reads `appProperties` in the same call already made, so ACC-02 and the conflict check never download a file (ACC-02 criterion 1).

## R9. Conflict rule

**Decision**: A pure `BackupConflictPolicy.check({required BackupMeta? newest, required String thisDeviceId, required int? lastKnownAt})` returns `none` or `newerFromOtherDevice(newest)`: the latter only when `newest.deviceId != thisDeviceId` and `newest.createdAt > (lastKnownAt ?? 0)`; a null meta is `none` (FR-038, FR-039, FR-043). `BackupService.backupToDrive` gains a `ConflictMode`:

- `ConflictMode.ask` (manual): returns `DriveBackupResult.needsConfirmation(entry)` without uploading; the caller shows the `ConfirmDialog` and calls again with `ConflictMode.overwrite`.
- `ConflictMode.pause` (auto): sets `autoBackupPausedByConflict`, shows the Backup notification once per pause (`autoBackupPauseNotified`), returns `paused`.

Every successful upload, restore, and "Keep this phone's data" writes `lastKnownDriveBackupAt` / `lastKnownDriveBackupDeviceId` and clears the pause (FR-040).

## R10. Empty phone over a backup with data

**Decision**: The same check also returns `emptyOverData` when this phone has no user data (R11) and the newest backup's counts show user data. Auto backup skips silently (not a failure, not a pause); a manual backup gets a variant of the conflict dialog ("This phone has no data. Backing up now makes an empty backup the latest."). Recorded as spec FR-038a and in `docs/spec.md` §16 Conflict rule (task T002).

**Rationale**: `docs/spec.md` SET-01 now says Erase all data keeps the sign-in. Without this rule, erasing and then leaving the app would upload an empty backup as "the latest", which ACC-02 and SYS-02 then restore by default, and day-based rotation could later delete the older ones. The conflict rule doesn't catch it, because the empty backup comes from the same device.

**Alternatives considered**: Signing out on Erase all data, as feature 008 does today (rejected: contradicts the updated SET-01 and loses auto backup without warning).

## R11. "No data on this phone"

**Decision**: `BackupSection` gains `Future<bool> hasUserData(AppDatabase db)`. Expense: any non-deleted transaction, budget, or recurring rule; any non-default category; or any account other than the single seeded Cash account. Habit: any non-deleted habit. `BackupEngine.hasUserData()` is true if any section says so (FR-016, ACC-02 criterion 3). Edits to seeded rows only (e.g. renaming Cash) don't count.

## R12. Restoring from the account, safety copy, and encryption

**Decision**: A core use case `AccountRestore` (`lib/core/account/account_restore.dart`) is the one place that restores from Drive, used by ACC-02, SYS-02 (interim), SET-02's Drive card sign-in and Drive list, and SYS-03; feature 011's AUTH-01 uses it too:

1. Download, then `RestoreService.open` (existing). Password: try the saved one, else ask through the existing `backup_password_sheet.dart`.
2. If `BackupEngine.hasUserData()`, write the safety copy (`BackupEngine.create(includeReceipts: true, password: null)`) to `<app support>/restore_safety/` with a `safety.json` sidecar (`createdAt`, counts). On failure (`BackupStorageFull`), stop before writing anything (FR-019a).
3. `RestoreService.apply` (existing, one transaction).
4. Afterwards: `backedUpChangeCounter = dataChangeCounter`, `lastKnownDriveBackup* =` the backup's meta, clear the pause; if the backup was encrypted, `backupEncrypt = true` and the password that opened it is saved (FR-019b). Then the existing restore aftermath (notifications, widget).

"Restore previous phone data" in SET-02 opens the safety copy through the existing `restore_flow.dart` (summary, then "Replace current data?"), deletes it after success, and its controller deletes copies older than 7 days on open and at app start (pure `SafetyCopyPolicy.expired(createdAt, now)`). Erase all data deletes it. It's never uploaded and isn't in the Android backup rules (R14).

**Rationale**: One code path for four entry points; reuses feature 008's open/apply and aftermath untouched.

## R13. Post-restore steps and "Finish setting up"

**Decision**: A non-restorable setting `finishSetupPending` is set by `AccountRestore` when the phone had no data (SYS-02 or FR-016) and app lock is off, and by the Android-restore path in R4. `lib/app/app.dart` listens to it and, when the router is on `/home`, shows `FinishSetupSheet` (from `lib/features/account/`) once, then clears it (FR-028). "Allow notifications" shows only on Android 13+ when the permission isn't granted. The SYS-02 path and the Android-restore path also call `ProService.restore()` in the background and show "Pro restored" only when it returns owned (FR-029). In `docs/spec.md` the sheet now follows every AUTH-01 login; 010 sets the flag only on the triggers above (interim I6, **Replaced in 011**), and 011 sets the same flag after login.

The Android-restore path (R4) runs in SYS-01 before routing: turn `lockEnabled` and `biometricEnabled` off when `LockService.status()` reports no PIN; clear the account keys and try a silent sign-in; set `lastKnownDriveBackupAt` to null (§16 says 0; same meaning to the conflict check); set `finishSetupPending`; and reschedule notifications through the existing restore aftermath (FR-046). What happens to a restored `authMode` is 011's (interim I7, **Replaced in 011**). If `backupEncrypt` is on but the password is missing, backups fail with `BackupNeedsPassword` and ACC-01 shows "Backup failed: set your backup password in Backup and restore". They never fall back to unencrypted backups (feature 008 R4).

## R14. Android Auto Backup rules

**Decision**: In `AndroidManifest.xml`, `android:allowBackup="true"`, `android:fullBackupContent="@xml/backup_rules"` (Android 11 and lower), and `android:dataExtractionRules="@xml/data_extraction_rules"` (Android 12+, `<cloud-backup>` and `<device-transfer>`). Both files use an include list, so nothing else is backed up: `<include domain="root" path="app_flutter/dailytrack.sqlite"/>` plus the `-wal` and `-shm` files. drift_flutter keeps the database in `getApplicationDocumentsDirectory()`, which is `app_flutter/` under the app's data root on Android; the device check confirms the path. Explicit `<exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>` documents the secure-storage exclusion even though the include list already leaves it out. Not included: secure storage, the no-backup folder (Android never backs it up anyway), receipts (`app_flutter/receipts/`), the safety copy (`files/restore_safety/`), WorkManager's own database, and caches (FR-045). A test parses both XML files and checks the includes and excludes (§16 criterion 2).

**Rationale**: An include list is the safest form. A new file can never start leaking into backups by accident, and the backup stays far below Android's 25 MB limit.

**Note**: Feature 007 (research R8) set `allowBackup="false"` because data would leave the device without the user starting it. Constitution 1.1.0 (task T001) now allows Android device backup with exactly these limits: database only, secure storage and receipts excluded.

## R15. Day-based rotation

**Decision**: A pure `AutoBackupRotation.toDelete(List<DriveBackupEntry> entries, {required DateTime now})` groups auto backups by local calendar day of `createdAt` (`DateTime.fromMillisecondsSinceEpoch(...).toLocal()` under the injected clock's zone), keeps the newest of today and the newest of each of the 5 most recent earlier days, and returns the rest. Manual backups are never returned (FR-035). `BackupService` calls it after each auto backup and deletes through `DriveBackupStore.delete`. `pruneAuto` is removed.

## R16. Delete my backups and sign-out

**Decision**: `DriveBackupStore.deleteAll()` lists every DailyTrack file and deletes it, continuing past individual failures and then rethrowing the first (FR-013). `AccountService.signOut()` calls `GoogleAuth.signOut()` (not `disconnect()`, so the next sign-in doesn't ask for consent again), clears the account keys and `lastKnownDriveBackup*`, and cancels `core.backgroundBackup` and the periodic job (FR-024). The SET-02 "Disconnect" button becomes "Sign out" → ACC-03 (spec Assumptions).

After sign-out, "Keep data on this phone" goes to the More tab with the snackbar, and ACC-01 closes because the account is signed out. "Remove data from this phone" runs Erase all data, which resets settings to defaults (including onboarding done), so the existing bootstrap redirect opens `/onboarding`. Both are interim I4 (**Replaced in 011**: `authMode = none` and AUTH-01 for both choices; 011 must keep onboarding done in the erase it runs here, since `docs/spec.md` §16 ACC-03 says Intro is never shown after sign-out). A cancelled Switch account chooser also returns to the More tab signed out.

**Erase all data** (`production_overrides.dart`) stops calling `driveBackupStore.disconnect` and keeps the account keys and the device ID (SET-01, FR-044). It still deletes the backup password, which leaves auto backup failing with `BackupNeedsPassword` if encryption was on (R13), and the safety copy. The keys it keeps are a parameter (FR-006a), so 011's ACC-04 Log out of guest reuses the same erase with its own keep-list.

## R17. Profile photo

**Decision**: `Image.network` with an `errorBuilder` and a `loadingBuilder`, both falling back to the initial in a `CategoryAvatar`. Flutter's in-memory image cache is enough; no `cached_network_image` (Constitution VII). ACC-01 never waits for it (FR-014).

## R18. Where the "Finish setting up" sheet and the restore UI live

**Decision**: `FinishSetupSheet`, `RestoreChoiceSheet` (ACC-02), and `SignOutSheet` (ACC-03) are in `lib/features/account/presentation/widgets/`. SYS-02 (onboarding feature) and SET-02 (settings feature) don't import them; neither will 011's AUTH-01 and SET-01 account card. They call `AccountRestore` (core) and the core password sheet, and open ACC-02 only through `lib/app/` glue (an `accountUi` provider bound in `production_overrides.dart`, like `restoreAftermathProvider`). `lib/app/app.dart` shows the Finish setting up sheet.

**Rationale**: Constitution II forbids feature-to-feature imports; `lib/app/` is already where features meet.
