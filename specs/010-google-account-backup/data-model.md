# Data Model: Google Account and Cloud Backup

No new tables. Drift `schemaVersion` 4 → 5 adds SQLite triggers only (research R5). New state is in the `settings` key-value table (none of it restorable, so `BackupSettingsPolicy.restorableKeys` is unchanged), in one no-backup file, in a safety-copy folder, and in Drive file properties.

Matched to `docs/spec.md` §4 and §16 as updated on 2026-10-27 for feature 011. The `authMode` key (`none`, `guest`, `google`) and its migration in §4 belong to 011; until then "signed in" means `backupAccountEmail` is set (plan.md interim I1, **Replaced in 011**).

## 1. Settings keys

Typed in `AppSettings` (`lib/core/settings/domain/app_settings.dart`) and encoded by `SettingsCodec`, like the existing keys.

| Key | Type (JSON) | Default | Written by | Notes |
| --- | --- | --- | --- | --- |
| `backupAccountEmail` | string? | null | AccountService | Existing (feature 008). Now "the signed-in account" (empty when signed out); set means signed in (interim I1, **Replaced in 011** by `authMode = google`, which 011 keeps true only while this is set). |
| `accountDisplayName` | string? | null | AccountService | Set on sign-in, cleared on sign-out (FR-003). |
| `accountPhotoUrl` | string? | null | AccountService | Same. |
| `deviceId` | string? | null | DeviceIdentity (SYS-01) | Copy of the no-backup file; used to detect an Android restore (R4). Kept by Erase all data. |
| `dataChangeCounter` | int | 0 | SQLite triggers only | Raised on every write to a backed-up table or restorable setting (R5). |
| `backedUpChangeCounter` | int | 0 | BackupService, AccountRestore | Counter in the snapshot of the last successful backup or restore. |
| `lastBackgroundBackupAt` | int? (UTC ms) | null | BackgroundBackupScheduler | Time the last background backup was enqueued (15-minute rule). |
| `lastKnownDriveBackupAt` | int? (UTC ms) | null | BackupService, AccountRestore, ACC-02 Keep | `createdAt` of the newest Drive backup this phone made, restored, or kept its data over (FR-040). |
| `lastKnownDriveBackupDeviceId` | string? | null | same | Its device ID. |
| `autoBackupPausedByConflict` | bool | false | runAutoBackup; cleared by restore, Keep, manual backup | FR-038, FR-039. |
| `autoBackupPauseNotified` | bool | false | runAutoBackup | The pause notice was shown for this pause; reset when the pause ends. |
| `finishSetupPending` | bool | false | AccountRestore, Android-restore path | Shows the Finish setting up sheet once on Home (R13), after a restore onto an empty phone or an Android Auto Backup restore (interim I6; **Replaced in 011**: also after every login). |

Existing keys used as is: `autoBackupFrequency` (set to `daily` on sign-in if `off`, FR-006), `autoBackupWifiOnly`, `lastAutoBackupAt`, `autoBackupFailures`, `autoBackupFailureNotified`, `backupEncrypt` (set to true by FR-019b), `lastBackupAt`, `lastBackupLocation`, `lastBackupSizeBytes`.

**Erase all data** keeps `backupAccountEmail`, `accountDisplayName`, `accountPhotoUrl`, `deviceId`, `lastKnownDriveBackup*`, and `autoBackupFrequency`/`autoBackupWifiOnly` (SET-01: erase doesn't sign out). It resets both change counters to 0, so the erased phone counts as unchanged until the user adds data. The keep-list is a parameter of the erase (default: the keys above), so 011's ACC-04 can pass its own list (FR-006a); 011 also adds `authMode` to the default list. **Sign-out** clears the account keys, `lastKnownDriveBackup*`, `lastBackgroundBackupAt`, and the pause flags.

**Android restore start** sets `lastKnownDriveBackupAt` to null. `docs/spec.md` §16 says "0"; both mean "no backup known" to `BackupConflictPolicy` (`lastKnownAt ?? 0`).

## 2. Change counter triggers (schema 5)

For each table in each `BackupSection.tables` (expense: `accounts`, `categories`, `transactions`, `budgets`, `recurring_rules`; habit: `habits`, `habit_schedules`, `habit_entries`), three triggers `bk_<table>_ins|upd|del`:

```sql
CREATE TRIGGER bk_transactions_ins AFTER INSERT ON transactions BEGIN
  INSERT INTO settings(key, value, updated_at) VALUES ('dataChangeCounter', '1', <now>)
  ON CONFLICT(key) DO UPDATE SET value = CAST(value AS INTEGER) + 1;
END;
```

Plus `bk_settings_ins|upd|del` on `settings` with `WHEN NEW.key IN (<restorableKeys>) OR NEW.key LIKE 'module.%'` (`OLD.key` for delete). The exact SQL (timestamp expression, column names) follows the existing `settings` table definition; the migration test checks it.

**Validation**: a unit test (real Drift via `makeRealContainer`) asserts (a) every table of every registered section has all three triggers in `sqlite_master`, (b) the settings trigger's key list equals `BackupSettingsPolicy.restorableKeys`, (c) writing `dataChangeCounter` or a device key (e.g. `latestSeenAt`) does not raise the counter, (d) a module write in a background container raises it.

## 3. Device identity

| Item | Where | Notes |
| --- | --- | --- |
| `device_id` file | `<noBackupFilesDir>/device_id` | UUID v4, one line. Never backed up or transferred by Android (FR-044). |
| `DeviceIdentity { id, name }` | `lib/core/account/domain/device_identity.dart` | `name` = "manufacturer model", read at backup time from `DeviceInfoSource`; "Android phone" when empty. |
| `DeviceIdOrigin` | pure enum from `DeviceIdentityPolicy.resolve(fileId, settingsId)` | `existing`, `created`, `restoredFromAndroidBackup` (R4 table). |

## 4. Backup metadata

```text
BackupMeta {
  deviceId: String
  deviceName: String          // ≤ 60 chars on Drive
  appVersion: String          // "1.4.0+23"
  createdAt: int              // UTC ms, same as the document's createdAt
  kind: BackupKind            // manual | auto
  counts: Map<String, int>    // "<moduleId>.<kind>" → non-deleted rows, e.g. "expense.transactions": 1240
  schemaVersion: int
  encrypted: bool
}
```

- **In the file**: `BackupDocument.meta` (optional; `toJson` writes `"meta": {...}` after `"format"`). Absent in feature 008 files (FR-043).
- **On Drive** (`appProperties`, ≤ 30 entries, each key + value ≤ 124 bytes UTF-8): `app=dailytrack`, `kind`, `schemaVersion`, `device` (name), `deviceId`, `appVersion`, `createdAt`, `encrypted` (`0`/`1`), `c.<moduleId>.<kind>` per count. `BackupMetaCodec.fromProperties` returns null when `deviceId` or `createdAt` is missing.
- `DriveBackupEntry` gains `BackupMeta? meta`. The existing `device` field stays for display of pre-feature backups.

## 5. Safety copy

| Item | Where |
| --- | --- |
| Backup file | `<app support>/restore_safety/<feature-008 file name>` (unencrypted JSON or zip with receipts) |
| Sidecar | `<app support>/restore_safety/safety.json`: `{ "createdAt": int, "counts": {...}, "fileName": string }` |

One copy at most; a new one replaces the folder. Deleted when restored, when older than 7 days (`SafetyCopyPolicy.expired`: `now - createdAt >= 7 days`, checked at app start and when SET-02 opens), by Erase all data, and by ACC-03 "Remove data from this phone". Not in the Android backup rules (FR-019a, FR-045).

## 6. Account state

```text
AccountState =
  | SignedOut
  | SignedIn { email, displayName?, photoUrl?, verified: bool }   // verified: silent sign-in succeeded this run

AccountProfile { email, displayName?, photoUrl? }    // from AccountAuth.signIn()
```

Transitions (`AccountService`):

```text
SignedOut --signIn ok--> SignedIn(verified)        [save profile; autoBackupFrequency off→daily]
SignedOut --signIn cancel/fail--> SignedOut
SignedIn  --app start, silent ok--> SignedIn(verified)
SignedIn  --app start, no session (token revoked, account removed)--> SignedOut   [clear keys; data kept]
SignedIn  --app start, offline / transient error--> SignedIn(!verified)   [still signed in; Drive calls report offline]
SignedIn  --Drive DriveAuthRequired--> SignedOut   [clear keys; data kept]
SignedIn  --signOut--> SignedOut                   [clear keys + lastKnown*; cancel jobs]
SignedIn  --switchAccount--> SignedOut --chooser ok--> SignedIn(new)
                                       --chooser cancelled--> SignedOut   [data kept; More tab]
```

"No session" is `attemptLightweightAuthentication()` returning null; a thrown network error is "offline" (research R2). The `SignedOut` results of a revoked token and a cancelled Switch account chooser are interim (I4, I5): **Replaced in 011**, where they become `authMode = guest`. ACC-01 closes whenever the state becomes `SignedOut` while it is open.

## 7. Backup status (ACC-01; the SET-01 account card in 011)

Derived, not stored (`BackupStatusPolicy.derive`, pure). 010 shows it on ACC-01; 011's SET-01 account card reuses it (interim I8, **Replaced in 011**).

| Status | When | Text |
| --- | --- | --- |
| `backingUp` | the backup coordinator lease is held | "Backing up…" |
| `paused` | `autoBackupPausedByConflict` | "Backup paused: a newer backup from another phone exists" |
| `failed(reason)` | `autoBackupFailures > 0`, or the last manual backup failed this session | "Backup failed" + the error message |
| `waitingForWifi` | a background backup is pending (`lastBackgroundBackupAt` > `lastBackupAt`), Wi-Fi only is on, and the network is metered | "Waiting for Wi-Fi" |
| `offline` | no network, or the status read failed with `DriveOffline` | "You're offline. Backups resume when you're back online." |
| `backedUp` | otherwise, with `lastBackupAt` and the device name of the last backup | "Backed up to Google" (never "Synced") |

Precedence: offline > backingUp > paused > failed > waitingForWifi > backedUp.

Network state comes from a new `getNetworkState` method on the existing `dailytrack/window` channel (`ConnectivityManager`: `{online, metered}`), read when ACC-01 opens and on resume. No connectivity plugin is added.

## 8. Drive backup results

```text
DriveBackupResult =
  | Uploaded { meta, sizeBytes }
  | Unchanged                                     // auto only: nothing to back up (FR-033)
  | NeedsConfirmation { newest: BackupMeta, reason: newerFromOtherDevice | emptyOverData }   // manual (R9, R10)
  | PausedByConflict { newest: BackupMeta }       // auto (FR-038)
  | SkippedEmpty                                  // auto, empty phone over data (R10)
```
