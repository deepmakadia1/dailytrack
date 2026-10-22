# Data Model: Backup, Export, Notifications, and Home Screen Widget

**Feature**: `specs/008-backup-export-notifications-widget` · **Date**: 2026-10-21

**No Drift schema change.** `AppDatabase.schemaVersion` stays **4**. The feature adds `settings`
keys, one secure-storage entry, file formats, and in-memory value types. Research decisions are cited
as R#.

## 1. Settings keys (`settings` table, JSON values)

### New keys

| Key | Type / allowed values | Default | Restorable | Written by |
| --- | --- | --- | --- | --- |
| `lastBackupLocation` | `"device"` \| `"drive"` \| null | null | No | `BackupService` after a successful backup |
| `lastBackupSizeBytes` | int ≥ 0 \| null | null | No | same |
| `lastAutoBackupAt` | int UTC ms \| null | null | No | auto backup success (catch-up check, R11) |
| `backupAccountEmail` | string \| null | null | No | connect / disconnect |
| `autoBackupFrequency` | `"off"` \| `"daily"` \| `"weekly"` | `"off"` | No | SET-02; set to `"off"` on disconnect |
| `autoBackupWifiOnly` | bool | true | No | SET-02 |
| `backupEncrypt` | bool | false | No | SET-02, only after `backup.password` is written (R4) |
| `backupIncludeReceipts` | bool | false | No | SET-02 |
| `autoBackupFailures` | int ≥ 0 | 0 | No | auto backup task; reset to 0 by any successful backup |
| `autoBackupFailureNotified` | bool | false | No | set when the 3rd failure notifies; reset by success |
| `backupLeaseUntil` | int UTC ms \| null | null | No | `BackupCoordinator` compare-and-set (R8) |
| `showDataOnWidget` | bool | false | No | SET-05 |
| `deviceTimeZoneId` | IANA id string \| null | null | No | app open, system time zone trigger (R21) |

The existing key `lastBackupAt` (int UTC ms) gets its first setter: `setLastBackup({at, location,
sizeBytes})` writes all three keys in one transaction.

### Rules

- Every new key decodes independently through `SettingsCodec`. An invalid value falls back to its
  default, as existing keys do.
- `showDataOnWidget` takes effect only while `lockEnabled` is true. The SET-05 switch is disabled,
  keeping its value, while the lock is off.
- If `backupEncrypt` is true and `backup.password` is missing, the backup is never made unencrypted
  (R4).
- `autoBackupFrequency != "off"` requires `backupAccountEmail != null`. Disconnect sets `"off"` and
  cancels the job.

### Restorable keys (`BackupSettingsPolicy`, R6)

The allowlist: `locale`, `currencyCode`, `firstDayOfWeek`, `dateFormat`, `themeMode`,
`selectedTheme`, `fontSize`, `enabledModules`, `moduleOrder`, `notificationsEnabled`,
`budgetAlertsEnabled`, `habitRemindersEnabled`, `dailySummaryTime`, `homeComingSoonDismissed`, and
`module.*`. Any other key is never exported, deleted, or overwritten by a restore. A restore also
writes `onboardingDone = true` and a `seed.<id>` marker for every registered seeder.

## 2. Secure storage (`SecureKeyValueStore`)

| Key | Value | Lifecycle |
| --- | --- | --- |
| `backup.password` | UTF-8 password string | Written when "Encrypt backup" is turned on or the password is changed. Deleted when encryption is turned off, and by Erase all data (`DriftAppResetService` deletes the `backup.` and `lock.` prefixes) |

## 3. Backup document (`backup.json`, or the whole `.json` file)

```text
{
  "format": "dailytrack-backup",          // required, exact
  "schemaVersion": 4,                     // int, minRestorableSchema(1) ≤ v ≤ current
  "appVersion": "1.0.0+12",               // string, informational
  "createdAt": 1792540800000,             // int UTC ms
  "modules": {
    "expense": { "tables": { "accounts": [...], "categories": [...], "transactions": [...],
                             "budgets": [...], "recurringRules": [...] } },
    "habit":   { "tables": { "habits": [...], "habitSchedules": [...], "habitEntries": [...] } }
  },
  "settings": { "<restorable key>": "<JSON-encoded value as stored>" }
}
```

### Row encoding (per-table codecs, R5)

- Every row includes `id`, `createdAt`, `updatedAt`, and `deletedAt` (nullable). Soft-deleted rows
  are included.
- Field names are the Dart column names in camelCase, e.g. `openingBalanceMinor`, `occurredAt`,
  `toAccountId`, `receiptPath`.
- **Enums are written by name**: `"expense"`, `"netBanking"`, `"timesPerWeek"`, and so on. Decoding
  rejects unknown names with `BackupInvalid`.
- Money is int minor units, and timestamps are int UTC ms. Date keys are `yyyy-MM-dd` and month
  keys are `yyyy-MM`.
- `habits.reminderTimes` stays the JSON list string as stored.
- `transactions.receiptPath` is relative (`receipts/<uuid>.jpg`) or null. It is null for every row
  when receipts are not included (FR-003).

### Validation (`BackupSection.validate`, before any write)

- **Header**: `format` must match, `schemaVersion` must be in range (`BackupTooNew` when higher), and
  `modules` must be an object.
- **Per row**: required fields are present with the right types. Every table CHECK is mirrored:
  - name lengths and the note limit (≤ 200)
  - `amountMinor` within 1..99,999,999,900
  - the transaction type shape (a transfer has `toAccountId` and no category; others have a
    category)
  - `monthKey` and `dateKey` formats
  - `weekdaysMask` within 0..127, `timesPerWeek` within 1..6, `freezesAvailable` within 0..2
  - habit `value` within 0..9999
  - `alert100SentAt` only when `alert80SentAt` is set
- **Uniqueness**: `id` across each table; `(habitId, dateKey)` in entries; `(habitId,
  effectiveFromKey)` among non-deleted schedules; `(monthKey, categoryId)` among non-deleted budgets.
- **References inside the section**: every account, category, recurring rule, and habit id that a
  row refers to must exist in the same section. Deleted rows count as existing.

## 4. Container forms (R2) and encrypted envelope (R3)

| Form | Detection (first bytes) | Layout |
| --- | --- | --- |
| Plain | `{` (after optional whitespace) | The backup document, UTF-8 |
| Zip | `50 4B 03 04` | `backup.json` + `receipts/<file>`, entries relative to the app documents folder |
| Encrypted | `44 54 42 4B` (`DTBK`) | See below |

The encrypted envelope (`.dtbk`):

```text
"DTBK" | 0x01 | uint32 BE headerLength | header (UTF-8 JSON) | ciphertext | GCM tag (16 bytes)
header = {"kdf":"pbkdf2-sha256","iter":600000,"salt":"<b64 16B>","nonce":"<b64 12B>","inner":"json"|"zip"}
key    = PBKDF2-HMAC-SHA256(password, salt, iter, 256 bits)
AAD    = header bytes
```

Errors: `BackupNotRecognized` (no known prefix), `BackupWrongPassword` (authentication failed,
whether from a wrong password or tampering), `BackupDamaged` (bad zip, bad JSON, or a truncated
envelope), `BackupTooLargeToEncrypt` (over 256 MB).

## 5. Drive backup file (`appDataFolder`)

| Field | Value |
| --- | --- |
| `name` | `dailytrack_backup_<yyyyMMdd_HHmm>.<json|zip|dtbk>` |
| `parents` | `["appDataFolder"]` |
| `appProperties.app` | `"dailytrack"` (list filter) |
| `appProperties.kind` | `"manual"` \| `"auto"` (Q1) |
| `appProperties.schemaVersion` | `"4"` |
| `appProperties.device` | device model (shown in the list's secondary line) |
| `size`, `createdTime` | from Drive (list display) |

**Rotation** (after each successful **auto** upload): list `kind=auto`, sort by `createdTime`
descending, and delete index ≥ 5. Manual files are deleted only by the user (FR-016, FR-017).

**`DriveBackupEntry`** (value type): `{id, name, createdAt, sizeBytes, kind, device}`.

## 6. Widget payload (`home_widget` key `glance.v1`, JSON string)

```text
{
  "v": 1,
  "mode": "data" | "hidden",
  "openLabel": "Open DailyTrack",                 // always present
  "today": DayBlock?,                             // null when hidden
  "next":  DayBlock?                              // the next local day, precomputed (R20)
}
DayBlock = {
  "dateKey": "2026-10-21",
  "spend":  { "label": "Spent today", "amount": "₹1,250", "a11y": "Spent today, rupees one thousand two hundred fifty" }?,
  "budget": { "label": "October budget", "percent": 62, "text": "62% used · ₹6,200 of ₹10,000",
              "level": "under" | "warning" | "over" } | { "none": "No budget set" } | null,
  "habits": [ { "id", "name", "kind": "yesNo" | "count", "done": bool,
                "progress": "12 / 20 pages" | null, "colorHex", "a11y" } ]   // ≤ 4, may be empty
}
```

- **Section rules**:
  - `spend` and `budget` are null when Expense is disabled, and `habits` is empty when Habit is
    disabled (FR-048).
  - `mode = hidden` when onboarding is not done, or when the lock is on and `showDataOnWidget` is
    false (FR-047).
- **Native choice of block**: Kotlin shows `today` if its `dateKey` equals the device's local date,
  otherwise `next` if that matches, otherwise only `openLabel`.
- **Click URIs**: `dailytrack://widget/check?habit=<id>&day=<dateKey>` (background) and
  `dailytrack://widget/open` (launch → `/home`).

### `HomeGlance` (pure Dart, `lib/core/widget/domain/`)

| Field | Type |
| --- | --- |
| `date` | `DateTime` (local day) |
| `spend` | `GlanceSpend? {int todayMinor, String currencyCode, GlanceBudget? budget}` |
| `GlanceBudget` | `{int limitMinor, int spentMinor}` → `percent`, `level` (under < 80 ≤ warning ≤ 100 < over) |
| `habits` | `GlanceHabits? {int scheduled, int done, List<GlanceHabit> items}` |
| `GlanceHabit` | `{String id, String name, HabitKindName kind, int value, int target, String colorHex}` → `done` |

## 7. Notifications

| Purpose | Channel | ID | Repeat | Payload (tap) | Actions |
| --- | --- | --- | --- | --- | --- |
| Habit reminder | `habitReminders` | `reminderIdFor(habitId, index, weekday)` (existing) | daily / weekly | `/habits?habit=<id>&at=<HH:mm>&wd=<0-7>` | yes/no: `habit.markDone`, `habit.snooze`; count: `habit.snooze` |
| Snoozed reminder | `habitReminders` | `stableNotificationId('habit-snooze:<habitId>')` | one-shot (now + 1 h) | same as the reminder | same as the reminder |
| Daily summary | `dailySummary` (new) | `stableNotificationId('daily-summary')` | one-shot, next `dailySummaryTime` | `/home` | none |
| Budget alert | `budgetAlerts` | existing | shown immediately | existing | none |
| Backup failing | `backup` (new) | `stableNotificationId('backup-failing')` | shown immediately | `/more/backup` | none |

**`NotificationActionEvent`**: `{String actionId, String payload}`.

**`AppAction`** (core, `lib/core/module/app_action.dart`):
`{AppActionSource source (notification|widget|system), String name, Map<String,String> params}`.

**Reminder day resolution** (`resolveReminderDay`, R17): given `now` (local), `at` (`HH:mm`), and
`wd` (0 = daily, 1–7 = ISO weekday), it returns the latest local date `d` such that the occurrence
`d at` ≤ `now` and (`wd == 0` or `d.weekday == wd`).

## 8. Export model (`lib/core/export/`, pure Dart, R14)

| Type | Fields |
| --- | --- |
| `ExportFormat` | `csv`, `pdf` → `FeatureKey.exportCsv` / `exportPdf` |
| `ExportRequest` | `String datasetId`, `Period period`, `ExportFormat format`, `Map<String, Set<String>> filters` (empty set = all) |
| `ExportContext` | `AppLocalizations l10n`, `String locale`, `String currencyCode`, `FullDateFormat dateFormat`, `Clock clock` |
| `ExportDocument` | `String title`, `String periodLabel`, `List<(String, String)> summary`, `List<String> filterLines`, `List<ExportSlice>? chart`, `List<ExportColumn> columns`, `List<List<ExportCell>> rows` → `isEmpty` |
| `ExportColumn` | `String header`, `ExportAlign align`, `double flex` |
| `ExportCell` | `TextCell(String)` \| `MoneyCell(int minor, String currency)` (CSV: plain decimal; PDF: formatted) |
| `ExportSlice` | `String label`, `int valueMinor`, `String colorHex` |
| `ExportFilterSpec` | `String id`, `String labelKey`, `Future<List<ExportOption>> options(ProviderReader)` |
| `ExportOption` | `String id`, `String label` |

**Transactions columns**: Date, Time, Type, Category, Account, Payment mode, Amount, Note. Filters
are `accounts` and `categories`.

**Habits columns**: Date, Habit, Value, Target, Unit, Status (Done, Partial, Freeze), Note. There
are no filters.

**File name**: `dailytrack_<datasetId>_<period slug>.<csv|pdf>`. The period slug is `2026-10` for a
month, `2026-W43` for a week, `2026` for a year, and `2026-10-01_2026-10-21` for a custom range.

## 9. State machines

### Backup run (`BackupService.backupNow(target)`)

```text
idle → leasing ─busy→ failed(BackupBusy)
        └→ reading → packing → [encrypting] → writing(file) → [uploading → rotating(auto only)]
            → succeeded(setLastBackup; reset failures)        any step ─error→ failed(reason)
```

### Restore run (R8)

```text
idle → opening → [password? → decrypting] → validating → upgrading → previewing
     → (user cancels → idle, nothing changed)
     → confirmed → staging receipts → db transaction → swapping receipts → aftermath → done
       any step up to and including the db transaction ─error→ failed (data untouched)
       swapping receipts ─error→ done with warning (receipts missing)
```

### Auto backup failure counter (FR-020)

```text
success (any backup)            → failures = 0, notified = false
failure, failures + 1 < 3       → failures += 1
failure, failures + 1 ≥ 3 and !notified → failures += 1, show "backup failing", notified = true
failure, notified               → failures += 1 (no notification)
```

### Export run (FR-031, Q2)

```text
tap Export → gate locked? → overlay (no file) | building → empty? → "Nothing to export" (unlock kept)
           → writing file ─error→ error (unlock kept)
           → file written → consumeOne(key) → share sheet (unlock already used even if dismissed)
```

## 10. TrackerModule additions (all optional with defaults, except `backupSection`)

| Member | Expense | Habit |
| --- | --- | --- |
| `BackupSection? backupSection()` | `ExpenseBackupSection` (5 tables, attachments = receipts) | `HabitBackupSection` (3 tables) |
| `List<ExportDataset> exportDatasets()` | `TransactionsExportDataset` | `HabitsExportDataset` |
| `Future<void> contributeGlance(GlanceBuilder, ProviderReader, DateTime)` | today spend + overall month budget | today's scheduled habits (≤ 4 items) |
| `Future<bool> handleAction(AppAction, ProviderReader)` | false | `habit.markDone`, `habit.snooze`, `habit.widgetCheck` |
