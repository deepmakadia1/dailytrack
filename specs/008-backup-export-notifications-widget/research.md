# Research: Backup, Export, Notifications, and Home Screen Widget (T3.2–T3.4)

**Feature**: `specs/008-backup-export-notifications-widget` · **Date**: 2026-10-21

Technical Context had no open NEEDS CLARIFICATION items. The spec's four clarifications (Q1–Q4) and
the user's plan input fixed the stack, package list, and folders. The decisions below settle how the
feature fits the existing code, checked against the code as of 2026-10-21 (files cited). Package
versions are the ones `flutter pub add --dry-run` resolved against the current lockfile.

---

## R1. New packages and versions

- **Decision**: Add these packages:

  | Package | Version | Used for |
  | --- | --- | --- |
  | `google_sign_in` | ^7.2.0 | Connect Google account; Drive `appdata` authorization (SET-02, "Forgot PIN?") |
  | `googleapis` | ^17.0.0 | `DriveApi` v3 in `appDataFolder`: list, upload, download, delete |
  | `extension_google_sign_in_as_googleapis_auth` | ^3.0.0 | Turns a `google_sign_in` authorization into the `AuthClient` that `DriveApi` takes |
  | `archive` | ^4.5.2 (now transitive, made direct) | Zip container for backups with receipts |
  | `csv` | ^8.0.0 | CSV encoding with RFC 4180 quoting (SET-03) |
  | `pdf` | ^3.13.1 | PDF document, table, and donut chart (SET-03) |
  | `file_picker` | ^13.1.0 | System "save to" picker and "Restore from file" picker |
  | `home_widget` | ^0.10.0 | Widget data bridge, background click callback, launch intent |

  These existing packages get new uses: `cryptography` (AES-GCM, PBKDF2), `workmanager` (auto
  backup), `flutter_local_notifications` (actions, new channels), `share_plus` (file sharing, still
  only under `core/share/`).

- **Not added**: `printing`. The user listed it, but nothing in this feature needs it. Output goes
  to the share sheet through the existing `core/share` port, and the PDF is built in pure Dart.
  `printing` would add a native plugin only for print and preview, which the spec does not ask for
  (Constitution VII, YAGNI). Its `WidgetWrapper` could rasterize Indic text (R12), but a
  `TextPainter` renderer does that without the plugin. Add it later if a "Print" action is specified.
- **Rationale**:
  - `extension_google_sign_in_as_googleapis_auth` is published by flutter.dev. It is the supported
    bridge from `google_sign_in` 7 to `googleapis_auth`, and saves writing an authenticated
    `http.Client` by hand.
  - Every package listed above is pure Dart or has Android support at API 24.
- **Alternatives considered**:
  - A hand-written bearer-token `http.Client`: needs `http` as a direct dependency plus token
    refresh logic.
  - `pdf_text_shaper` (HarfBuzz shaping for `pdf`): see R12.

## R2. Backup file layout

- **Decision**: One file named `dailytrack_backup_<yyyyMMdd_HHmm>` (local time, from the injected
  `Clock`). It takes one of three forms, recognized by its first bytes, not its extension:

  | Form | Extension | First bytes | Content |
  | --- | --- | --- | --- |
  | Plain | `.json` | `{` | The backup document (data-model §3) |
  | With receipts | `.zip` | `PK\x03\x04` | `backup.json` + `receipts/<uuid>.jpg` |
  | Encrypted | `.dtbk` | `DTBK` | Envelope (R3) around either form above |

  - The document holds `format: "dailytrack-backup"`, `schemaVersion` (the Drift schema version
    that wrote it, now 4), `appVersion`, `createdAt` (UTC ms), `modules` (one section per module
    id), and `settings` (restorable keys only, R6).
  - Enums are written by **name**, not by index. Rows are written through explicit per-table codecs
    (R5), not Drift's generated `toJson`, so the file format stays stable when Drift code changes.
- **Rationale**:
  - The spec allows "receipts zipped alongside". One zip keeps a single file to save, share,
    upload, and pick, and matches FR-001 and FR-003.
  - Sniffing the first bytes lets a renamed or shared file still restore.
  - Names instead of indexes make the backup readable, and keep it valid even if an enum is ever
    reordered by mistake.
- **Alternatives considered**:
  - Two files (JSON + receipts zip): restore would need both files picked together.
  - Base64 receipts inside the JSON: about 33% larger, and the whole thing sits in memory as one
    string.

## R3. Encryption envelope

- **Decision**: `BackupEnvelope` (pure Dart, `lib/core/backup/domain/backup_envelope.dart`) uses
  `cryptography`:
  - The key comes from `Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 600000, bits: 256)` with a
    16-byte salt from `SecureRandom.safe`.
  - The cipher is `AesGcm.with256bits()` with a 12-byte random nonce.
  - The binary layout: `"DTBK"` + version byte `1` + `uint32` header length + header JSON
    `{kdf: "pbkdf2-sha256", iter, salt, nonce, inner: "json"|"zip"}` + ciphertext + 16-byte tag.
    The header bytes are the AEAD associated data, so a header that was tampered with fails
    authentication.
  - A wrong password and a damaged file both surface as `BackupWrongPassword`, because GCM cannot
    tell them apart. The message says "Wrong password or damaged file" without hints (spec Edge
    Cases).
  - Key derivation, encryption, and decryption run in `Isolate.run`.
  - Unit tests inject a low iteration count. One test pins 600,000 and checks a known PBKDF2 vector.
- **Rationale**: FR-004 and SET-02 name AES-GCM with a password-derived key, and PBKDF2 is the KDF
  the user named. 600,000 iterations follows current OWASP guidance for PBKDF2-SHA256. In pure Dart
  that is roughly 1–1.5 s in an isolate on a mid-range phone (R3 of feature 007 measured 120k at
  150–300 ms). That cost is paid once per backup or restore, not per tap.
- **Alternatives considered**:
  - Argon2id: several seconds in pure Dart on low-end phones.
  - Encrypting each section: leaks module names and sizes, and is more complex.
  - Streaming GCM in chunks: `cryptography`'s pure-Dart `AesGcm` works on whole buffers. Backups
    with receipts are bounded by receipt count (images are compressed to ~200 KB each, feature 002).
    A typical heavy user (500 receipts, ~100 MB) fits in memory on a 4 GB device. The size is
    checked before backing up, and a "too large to encrypt" error appears above 256 MB.

## R4. Backup password storage (clarification Q4)

- **Decision**: `BackupPasswordStore` keeps the password in the existing `SecureKeyValueStore` under
  key `backup.password` (data-model §2).
  - Turning "Encrypt backup" on goes through a sheet that asks for the password twice and shows the
    "cannot be recovered" warning. The setting `backupEncrypt` becomes true only after the password
    is written.
  - Turning it off deletes the key. Changing the password overwrites it.
  - `DriftAppResetService` (feature 007, R16) also deletes the `backup.` prefix, alongside `lock.`.
  - If `backupEncrypt` is true but the key cannot be read, no plain backup is ever made. A manual
    backup asks the user for the password again, and an auto backup fails with
    `BackupNeedsPassword`, which counts toward the 3 failures.
- **Rationale**: Auto backups run unattended (Q4). Android Keystore-backed storage is already
  trusted for the PIN, and `allowBackup="false"` keeps it off Google's Auto Backup (feature 007,
  R8).
- **Alternatives considered**: Storing only the derived key: it is equally sensitive, and every
  backup would then reuse one salt.

## R5. `BackupSection`: module-owned codecs, engine-owned transaction

- **Decision**: Replace the `BackupSection` placeholder (`lib/core/module/tracker_module.dart:112`)
  with a real interface in `lib/core/backup/backup_section.dart` (contracts/services.md). Each
  module implements it in its own folder:
  - Expense in `lib/features/expense/data/backup/expense_backup_section.dart` covers accounts,
    categories, transactions, budgets, and recurring_rules.
  - Habit in `lib/features/habit/data/backup/habit_backup_section.dart` covers habits,
    habit_schedules, and habit_entries.

  `backupSection()` returns them in place of `null`. Each section:
  - **`export(db)`**: reads all rows of its tables, soft-deleted included (FR-002), inside the
    engine's read transaction, so all modules see one snapshot.
  - **`validate(section)`**: checks shapes, ranges, enum names, uniqueness, and in-section foreign
    keys before anything is written. It mirrors the table CHECKs, so a bad file fails as
    `BackupInvalid` and never as a SQLite error halfway through a write.
  - **`upgrade(section, from:)`**: JSON upgrade steps, from the section's `sinceSchemaVersion` to
    the current version (R7).
  - **`restore(db, section)`**: deletes the module's rows and batch-inserts the backup rows. It runs
    only inside the engine's write transaction.
  - **`counts(section)`** and **`summary(l10n, counts)`**: give the localized summary ("1,240
    transactions, 8 habits").
  - **`attachments(section)`**: Expense returns the non-null `receiptPath`s, which are relative
    `receipts/<uuid>.jpg` paths per `FileReceiptStore`. **`withoutAttachments(section)`** clears
    `receiptPath` when receipts are not included (FR-003).
- **Rationale**: Constitution II and FR-002. The engine never touches module tables, so Water and
  Period add a section and nothing else. Drift access stays in each module's `data/` layer. Explicit
  codecs (R2) make the file format a deliberate contract.
- **Alternatives considered**:
  - The engine dumps `AppDatabase.allTables` generically: this breaks module ownership, and old
    files would be tied to Drift column names.
  - Drift row `toJson`: enums come out as indexes, and its keys follow Drift's serializer settings.

## R6. Restorable settings (FR-009)

- **Decision**: `BackupSettingsPolicy` (pure, `core/backup/domain/`) holds the allowlist of
  restorable keys:
  - `locale`, `currencyCode`, `firstDayOfWeek`, `dateFormat`, `themeMode`, `selectedTheme`,
    `fontSize`
  - `enabledModules`, `moduleOrder`
  - `notificationsEnabled`, `budgetAlertsEnabled`, `habitRemindersEnabled`, `dailySummaryTime`
  - `homeComingSoonDismissed`, plus `module.*` module state keys

  How the allowlist is applied:
  - **Export** writes only allowlisted keys.
  - **Restore** deletes only allowlisted keys and writes the backup's values. The values are
    decoded through `SettingsCodec`, so invalid ones fall back to defaults.
  - **Restore** then sets `onboardingDone = true` and writes `seed.<id>` markers for every
    registered seeder, so seeds never re-run over restored data.
  - Every other key is device state and is left as it is: lock and biometric, `lockAfterSeconds`,
    `hideInRecents`, backup settings, `showDataOnWidget`, `adConsentStatus`, `removeAdsPurchased`,
    `latestSeenAt`, `debugUnlockAll`, the daily insight pick, and `deviceTimeZoneId`.
  - The `unlocks` table is never backed up or restored.
- **Rationale**: A restore must never lock the user out (spec Assumptions). Ad consent and purchase
  are per device and per store. Unlocks follow feature 007's erase rule.
- **Alternatives considered**: Restoring all keys: this would carry over a `lockEnabled = true`
  without the PIN that goes with it.

## R7. Schema versions and upgrading older backups

- **Decision**:
  - `schemaVersion` in the file is `AppDatabase.schemaVersion` (4).
  - Supported range: `minRestorableSchema = 1` up to the current version (changed during
    implementation from 4). Schemas v1–v3 only lacked tables and never changed a column, so each
    module upgrades older sections with real JSON steps: missing tables read as empty, the Habit
    section starts at v4, and Expense clears a v2 `recurringRuleId` because rules (and the foreign
    key) arrived in v3.
  - Newer than current → `BackupTooNew` ("Update DailyTrack to restore this backup").
  - Older within range → `BackupMigrator` applies each module's `upgrade` steps in order. A
    section missing from an older file (e.g. a module added later) is treated as empty. A section
    for an unknown module id is skipped, and the summary says so (spec Edge Cases).
  - Every future Drift migration that changes a backed-up table MUST add the matching
    `BackupSection.upgrade` step. `migration_test.dart` gains a check that `minRestorableSchema` to
    current has a step for each version of each section.
- **SET-02 AC "Restoring a backup from an older schema version succeeds"** is covered in three ways:
  1. `test/core/backup/restore_older_schema_test.dart` restores v1, v2 (the committed fixture
     `test/fixtures/backup/v2_expense.json`), and v3 backups into the current v4 database, and
     refuses a newer one.
  2. A migrator unit test registers a synthetic v4→v5 step and upgrades a v4 document through it.
  3. The step-coverage check above (still to add, T031).
- **Rationale**: Drift's generated old-schema classes exist only in tests (`test/drift/...`), so a
  restore cannot run old Drift migrations on a temporary database. JSON steps per section keep each
  upgrade with the module that owns the table.
- **Alternatives considered**:
  - A separate backup format version: one more number to keep in step with the schema.
  - Restoring into a temporary database file at the old schema: there is no way to create an old
    schema at runtime.

## R8. Restore pipeline and the "untouched on failure" guarantee

- **Decision**: `BackupEngine.restore` runs these phases. Phases 1–3 are read-only. A failure in
  phases 1–5 leaves data untouched (FR-008, SET-02 AC 2).
  1. **Read and open**: detect the form → decrypt (asking for the password when needed) → unzip →
     parse → check the header (`format`, version range).
  2. **Validate and upgrade**: each module's `validate`, then `BackupMigrator` (R7).
  3. **Preview**: `RestorePreview` (date, app version, per-module counts, skipped modules) → the
     screen shows the summary and the replace `ConfirmDialog`.
  4. **Stage receipts**: extract `receipts/` into `<docs>/receipts.restore/`. On failure (for
     example, storage full), delete the staging folder and stop.
  5. **Database write**: one Drift `transaction` runs `PRAGMA defer_foreign_keys = ON`, then each
     module's `restore`, then the settings policy (R6), then `PRAGMA foreign_key_check` (throws on
     any row). Any throw rolls back everything and deletes the staging folder.
  6. **Swap receipts** (after commit): rename `receipts/` to `receipts.old/`, rename the staging
     folder to `receipts/`, then delete `receipts.old/`. If the swap fails, the restored rows point
     at missing files, which `ReceiptStore.resolve` already treats as no receipt. The next
     `pruneOrphans` cleans up. This partial outcome is logged and reported.
  7. **Aftermath**, best effort, through `restoreAftermathProvider`. Core never imports
     `lib/app/`; `production_overrides.dart` binds the provider:
     - `NotificationService.cancelAll()`, then `AppOpenRunner.run()`, which reschedules habit
       reminders, and `DailySummaryScheduler.reschedule()`
     - the glance refresh (R19)
     - `lastBackup*` is left as it is
- Only one backup or restore runs at a time (FR-011):
  - `BackupCoordinator` is a single-flight mutex in the isolate.
  - Across isolates (foreground vs. the auto backup worker), a settings row `backupLeaseUntil` is
    taken with a compare-and-set inside a short transaction. It expires after 10 minutes so a
    crashed run cannot block forever.
  - A second request gets `BackupBusy` ("A backup is already running").
- **Rationale**: SQLite transactions give all-or-nothing behavior for rows. Files cannot join that
  transaction, so they are staged first and swapped after commit, which is the smallest window
  possible. Deferred foreign keys let sections insert in any order.
- **Alternatives considered**:
  - Copying the database file aside and swapping files: needs closing the shared Drift connection
    under live streams (rejected in feature 007, R16).
  - Merging rows: the spec says replace.

## R9. Backup content generation and performance

- **Decision**:
  - The export reads every section inside one Drift read transaction. It builds plain maps on the
    main isolate (Drift requires that), then runs JSON encoding, zipping, and encryption in
    `Isolate.run`.
  - Receipt bytes are read by path inside the isolate.
  - The produced file is written to `<cache>/backups/` and then:
    - **saved** through `file_picker`'s `saveFile` (SAF on Android)
    - **shared** through the new `FileSharer` (R13)
    - **uploaded** to Drive by streaming the file
  - The cache folder is cleared on the next backup.
  - **Performance target (SC-004)**: 10,000 transactions plus 50 habits × 365 entries is about
    6 MB of JSON. Encoding takes under 1 s in an isolate, so the 10 s budget is met with room to
    spare. A benchmark-style test in `test/core/backup/backup_perf_test.dart` asserts under 10 s on
    CI as a smoke check (tag `slow`).
- **Rationale**: This keeps the UI at 60 fps (FR-022), and progress is reported per phase
  (`BackupProgress` stream: reading, packing, encrypting, uploading x/y bytes).

## R10. Google Drive integration (`appDataFolder`)

- **Decision**: `DriveBackupStore` port (`core/backup/domain/`) with `GoogleDriveBackupStore` in
  `core/backup/data/`.
  - **Auth**: `GoogleSignIn.instance.initialize(serverClientId: GoogleConfig.serverClientId)`.
    `serverClientId` comes from `--dart-define=GOOGLE_SERVER_CLIENT_ID`; it is not a secret, but it
    is configured per flavor and never committed (Constitution III).
    - **Connect**: `authenticate()`, then
      `authorizationClient.authorizeScopes([DriveApi.driveAppdataScope])`. Only the `drive.appdata`
      scope is requested (FR-014).
    - **Silent reuse**: `attemptLightweightAuthentication()` and `authorizationForScopes(...)`.
    - **Disconnect**: `disconnect()`.
    - The account email is stored in setting `backupAccountEmail` for display.
  - **Files**: `files.create` with `parents: ['appDataFolder']`, a resumable upload, and
    `appProperties` `{app: 'dailytrack', kind: 'manual'|'auto', schemaVersion, device}`. Drive only
    creates the file when the upload completes, so a partial upload never appears (spec Edge Case).
  - **List**: `spaces: 'appDataFolder'`, query `appProperties has {key='app' and value='dailytrack'}`,
    `orderBy: 'createdTime desc'`, fields `id,name,size,createdTime,appProperties`.
  - **Rotation (Q1)**: after a successful **auto** upload, list `kind='auto'` and delete everything
    after the 5 newest. This covers all devices on the account. Manual files are never deleted
    automatically. Delete from the list is user-initiated, behind a `ConfirmDialog`.
  - **Errors** map to `DriveAuthRequired` (show "Reconnect Google account"), `DriveQuotaExceeded`,
    `DriveOffline`, and `DriveUnavailable`, each with plain-language text (§15.6).
- **Rationale**: `appDataFolder` hides backups from the user's Drive UI, and the narrow scope needs
  no restricted-scope verification. `appProperties` separate manual from auto without a local
  record, so this works across reinstalls and devices.
- **Setup prerequisite** (quickstart §1): a Google Cloud project with the Drive API enabled, an OAuth
  consent screen, Android OAuth clients for the `.dev` and prod package names with their SHA-1, and
  a Web client ID passed as `GOOGLE_SERVER_CLIENT_ID`.
- **Alternatives considered**: a visible Drive folder with the `drive.file` scope: it clutters the
  user's Drive, and the spec names `appDataFolder`.

## R11. Auto backup scheduling and failure counting

- **Decision**:
  - **Scheduler**: `BackgroundScheduler` gains
    `ensurePeriodic(name, {required Duration every, NetworkRequirement network})`, implemented with
    `registerPeriodicTask(... constraints: Constraints(networkType: unmetered|connected),
    existingWorkPolicy: replace)`. workmanager 0.10 has no `update` policy, and `replace`
    restarts the period, so the job is registered only when the schedule changes (frequency,
    Wi-Fi only, connect, disconnect; `syncAutoBackupSchedule` in `core/backup/`), never on app
    open. Daily is 24 h and Weekly is 7 days. Off and Disconnect call `cancel`. `ensureDaily`
    stays as it is for `expense.recurring`.
  - **Core task**: `background_dispatcher.dart` gains a core task map checked before module tasks:
    `{'core.autoBackup': runAutoBackup}`. `runAutoBackup` lives in `lib/app/auto_backup_task.dart`
    (not `core/backup/data/`), because its notification links to a route and core never imports
    `lib/app/`. Its container is built as today (`productionOverrides()`),
    which opens its own Drift connection through `AppDatabase.open()` with `shareAcrossIsolates`.
  - **"Wi-Fi only" (FR-019)**: the `unmetered` constraint keeps WorkManager from running the job at
    all on metered data, so waiting never counts as a failure.
  - **Failure counting**: each run that ends in failure increments `autoBackupFailures`. On reaching
    3 with `autoBackupFailureNotified == false`, it shows the Backup notification (R16) and sets the
    flag. Any successful backup, manual or auto, resets both. Failures include auth required,
    password unreadable, Drive errors, and lease busy for more than 10 minutes. The task returns
    `true`, so WorkManager does not stack its own retries on the periodic schedule.
  - **Background auth risk**: `google_sign_in` 7 on Android uses Credential Manager and
    `AuthorizationClient`. Silent `authorizationForScopes` is expected to work in a background
    engine, but this is unverified (quickstart §4 device check). As a fallback, `AppOpenRunner`
    runs a catch-up: if auto backup is on and `lastAutoBackupAt` is older than its period plus 6 h,
    it runs one auto backup in the foreground, after the first frame and unawaited. Either path
    satisfies SC-006.
- **Rationale**: This reuses the existing dispatcher and its container pattern (user input:
  top-level entry points that open their own Drift connection), and WorkManager's own constraints
  are more reliable than checking connectivity by hand.
- **Alternatives considered**: `connectivity_plus` checks inside the task: one more plugin, and the
  task would wake up on mobile data for nothing.

## R12. PDF: pure-Dart builder, with shaped text rendered for Indic scripts

- **Decision**:
  - `PdfReportBuilder` (pure Dart, `lib/features/settings/domain/export/pdf_report_builder.dart`)
    takes an `ExportDocument` (R14) and font bytes. It uses `pdf` widgets:
    - a `MultiPage` A4 layout, with the summary page first
    - a donut `pw.Chart` with `PieDataSet`, drawn as vectors with category colors
    - a legend
    - a `TableHelper`-style table with repeated headers
  - **Known `pdf` limitation (checked)**: the `pdf` package maps code points straight to glyphs. It
    does not do OpenType shaping (GSUB/GPOS), so Devanagari and Gujarati conjuncts and matras come
    out wrong. The SET-03 AC requires correct rendering. So:
    - Any cell or label that contains an Indic code point (U+0900–U+0DFF) goes through a
      `ShapedTextRenderer` port and is embedded as a high-resolution image (`pw.Image`, rendered at
      3×). Latin text, numbers, and amounts stay vector text in Noto Sans.
    - The Flutter implementation, `FlutterShapedTextRenderer` in
      `features/settings/presentation/export/`, uses `TextPainter` with the bundled Noto
      Devanagari and Gujarati fonts. Flutter shapes with HarfBuzz. It draws into a
      `PictureRecorder` and produces PNG bytes, on the UI isolate, batched with yields.
    - Then `Isolate.run` assembles the PDF.
  - Font bytes come from the existing `assets/fonts/*.ttf` through `rootBundle`.
- **Rationale**: This gives correct shaping today with no new dependency. The builder stays pure
  Dart and testable (the renderer is a port; tests use a fake that returns a 1×1 PNG and records the
  strings). The trade-off is that Indic text in the PDF is not selectable or searchable.
- **Alternatives considered**:
  - `pdf_text_shaper` (HarfBuzz for `pdf`): gives selectable text, but it is a new native or WASM
    dependency with unverified Android support.
  - `printing`'s `WidgetWrapper`: rasterizes widgets that are already in the tree.
  - Android's native `PdfDocument` through a channel: a second rendering stack.
- **Spike (done, kept as a guard test)**: `pdf` 3.13.1 has no GSUB support, and
  `test/features/settings/presentation/export/indic_shaping_test.dart` shows it lays out "ક્ષ" letter
  by letter while Flutter's `TextPainter` forms one cluster (also "क्ष", "त्र"). The renderer stays.
  That test replaces the planned golden image, so the SET-03 PDF check also runs on Windows.

## R13. CSV, files, and sharing

- **Decision**:
  - **`CsvBuilder`** (pure Dart, `features/settings/domain/export/csv_builder.dart`): uses the `csv`
    encoder with `\r\n` line endings and RFC 4180 quoting (commas, quotes, line breaks; spec Edge
    Case), and prefixes `﻿`. The bytes are UTF-8.
    - **Amounts**: plain decimal in major units using the currency's decimals (`Currencies`), `.`
      as the separator, no grouping and no symbol, always positive. `Type` gives the direction.
    - **Dates**: the user's full-date format. **Times**: `HH:mm`.
    - **Category and account names**: localized through `localizedSeedName`.
    - **Transfers**: Category is empty and Account is "From → To".
  - **`FileSharer`**: a new port in `lib/core/share/` beside `TextSharer`/`ImageSharer`, built on
    `share_plus` `ShareParams(files: [XFile(path, mimeType)])`. `share_plus` stays confined to
    `core/share/` (layering scan rule c).
  - **Export files**: written to `<cache>/exports/` as
    `dailytrack_<transactions|habits>_<period-slug>.<csv|pdf>`. Old files are deleted on the next
    export.
  - **External activities**: every file picker, Google sign-in, and share call goes through
    `LockSession.expectExternalActivity()` (feature 007, R15), so "Lock after: Immediately" does
    not lock mid-flow.

## R14. Export data comes from modules through a core port

- **Decision**: New optional hook `List<ExportDataset> exportDatasets()` on `TrackerModule` (default
  empty).
  - Types live in `lib/core/export/` (pure Dart):
    - **`ExportDataset`**:
      - `id` (`transactions`, `habits`)
      - `labelKey`
      - `filters`: a list of `ExportFilterSpec {id, labelKey, Future<List<ExportOption>> options(read)}`
      - `Future<ExportDocument> build(ExportRequest, ExportContext)`
    - **`ExportDocument`**:
      - `title`, `periodLabel`
      - `summaryLines` (label and value pairs)
      - `chart?` (a list of `ExportSlice {label, valueMinor, colorHex}`)
      - `columns`
      - `rows` (`List<List<ExportCell>>`, where a cell is text or money)
      - `isEmpty`
    - **`ExportContext`**: localizations, locale, currency code, full-date format, and the clock.
  - Expense implements the "transactions" dataset in `features/expense/presentation/export/`
    (beside its insight source, which also reads providers and localizes; changed during
    implementation from `data/export/`). It adds a
    one-shot `TransactionRepository.listForExport(TxnQuery)` (unpaged, oldest first) and reuses
    `foldBreakdown`/`buildDonut` logic for the slices.
  - Habit implements the "habits" dataset in `features/habit/presentation/export/`. It reads
    active and archived habits and each habit's full history through the existing repositories
    (no new repository method was needed), and computes per-habit completion with the existing
    `StreakEngine` rules.
  - SET-03 lists the datasets from enabled modules only (data type chips), so with the Habit module
    off, "Habits" is not offered.
- **Rationale**: The user asked for export in `lib/features/settings/`, and Constitution II forbids
  settings from importing module internals. The registry hook keeps the settings feature generic,
  like the dashboard. The CSV and PDF builders render any `ExportDocument`.
- **Alternatives considered**:
  - Export code inside each module: this duplicates CSV and PDF, and does not match the user's
    folder choice.
  - Settings importing the expense and habit repositories: breaks the layering scan.

## R15. Export unlocks: gate and one-time use (clarification Q2)

- **Decision**:
  - Before building, SET-03 checks `FeatureGate.isUnlocked(FeatureKey.exportCsv | exportPdf)`. When
    locked, it shows `LockedFeatureOverlay(onWatchAd: null, onGetPro: null)` over the Export button
    area. No file is made (FR-031).
  - **One-time use**: a one-time export unlock is any live `exportCsv`/`exportPdf` unlock with
    `source == rewardedAd` (§11: a rewarded ad "grants one export").
    - `UnlockRepository` gains `Future<bool> consumeOne(FeatureKey key)`. It revokes (soft-deletes)
      the oldest live, unexpired rewarded unlock for that key and returns whether one was used.
    - `ExportUseCase` calls it only after the file is written successfully and before sharing.
    - Purchase-source unlocks, Pro (`removeAdsPurchased`), and the dev debug switch are never
      consumed: `consumeOne` is a no-op when the gate is open for one of those reasons.
- **Rationale**: This needs no schema change (the `unlocks` table stays v4), and it matches how
  rewarded unlocks will be granted in T4.4.
- **Alternatives considered**: A `usesRemaining` column: needs a v5 migration for a single meaning
  that the source already encodes.

## R16. Notification service extensions

- **Decision** (`lib/core/notifications/`):
  - **Channels**: `NotificationChannelId` appends `dailySummary` and `backup`, with Android channel
    IDs `daily_summary` and `backup` and ARB labels. Both are on by default (FR-040).
  - **One-shot scheduling**: `ScheduledNotification.repeat` becomes nullable; `null` means a one-time
    `zonedSchedule` without `matchDateTimeComponents`. Used for snooze and the daily summary (R18).
  - **Actions**: `AppNotification` gains `List<NotificationActionSpec> actions` `{id, labelKey}`.
    These map to `AndroidNotificationAction(id, label, showsUserInterface: false,
    cancelNotification: true)`. Action IDs are `habit.markDone` and `habit.snooze`.
  - **Payload**: it stays a go_router location, now with query parameters, e.g.
    `/habits?habit=<id>&at=HH:mm&wd=<0-7>`. A tap opens HAB-01, since the routes ignore unknown
    query parameters, and actions parse the parameters.
  - **Responses**:
    - `NotificationService.actions` is a new `Stream<NotificationActionEvent>` (`actionId`,
      `payload`) for responses that arrive while the app runs.
    - `LocalNotificationService` takes a `backgroundHandler` constructor parameter and passes it
      to `initialize` as `onDidReceiveBackgroundNotificationResponse`. `production_overrides.dart`
      supplies `notificationActionEntryPoint`, a top-level `@pragma('vm:entry-point')` function
      in `lib/app/background_entry_points.dart` that receives responses when the app is not
      running. Core never imports `lib/app/`.
    - The manifest gains the plugin's `ActionBroadcastReceiver`.
  - **Exact alarms**: the existing `canScheduleExact()`, plus new `requestExactAlarms()` (plugin
    `requestExactAlarmsPermission`). SET-01 Notifications shows an "Exact timing" note row only
    when exact alarms are not allowed (FR-042), with an "Allow" action. No new permission is needed:
    `SCHEDULE_EXACT_ALARM` is already declared.
- **Rationale**: These are small, additive changes to the existing port, and every
  `flutter_local_notifications` call stays in `core/notifications/local_*` (layering rule d).
- **Alternatives considered**: JSON payloads: the existing tap routing expects a location string,
  and query parameters keep it backward compatible.

## R17. Habit reminder actions: day resolution and idempotency

- **Decision**:
  - **Mark done (FR-038)**:
    - Reminders are repeating, so the payload cannot carry the day.
    - `resolveReminderDay(now, at, weekday)` (pure, `features/habit/domain/reminders/`) returns the
      latest reminder occurrence at or before `now`: today if `HH:mm` ≤ now, otherwise the previous
      matching day. So a tap after midnight marks the reminder's day.
    - It writes `DayOp.SetValue(targetOn(day))` through `HabitDayWriter`. `Toggle` is not used: it
      flips, so a double tap would undo (`drift_habit_entry_repository.dart:124-160`).
    - Skipped silently if the habit is archived, deleted, or count-kind, or the day is not editable.
  - **Snooze 1 h (FR-039)**: schedules a one-shot at `now + 1 h` with id
    `stableNotificationId('habit-snooze:<habitId>')`, the same title, body, actions, and payload,
    and `exact` per `canScheduleExact()`. `LocalHabitReminderScheduler._reconcile` also cancels the
    snooze id when the habit is done for today and `remindOnlyIfNotDone` is on. Every check-in in
    the current week already reconciles, so a snoozed reminder for a done habit never shows.
  - **Count habits**: their reminders carry only "Snooze 1 h".
  - **Dispatch**: core cannot import Habit, so a new optional hook
    `Future<bool> handleAction(AppAction action, ProviderReader read)` on `TrackerModule` (default
    `false`) receives `AppAction{source: notification|widget, name, params}`. The core
    `AppActionDispatcher` offers it to each visible module until one handles it.
- **Rationale**: The fix is pure, testable with an injected `Clock`, and idempotent. It works the
  same in the foreground and in background isolates.

## R18. Daily summary content and scheduling

- **Decision**:
  - `DailySummaryScheduler` (`core/notifications/daily_summary_scheduler.dart`) schedules **one
    one-shot** notification for the next occurrence of `dailySummaryTime`, with fixed id
    `stableNotificationId('daily-summary')`.
  - Its text is built from the current `HomeGlance` (R19) at scheduling time:
    "Spent {amount} today · {done}/{total} habits done". Each part is included only for enabled
    modules, through ARB variants with placeholders, not concatenation.
  - It is rescheduled:
    - after every glance refresh (R19), which runs after every relevant database write
    - at midnight
    - on settings changes (time, master toggle)
    - on app open, after restore, after a time zone change, and after reboot
  - If the next occurrence is tomorrow, the text is computed for tomorrow: ₹0 spent and 0/N habits,
    with N from tomorrow's schedules.
  - It is cancelled when the master toggle is off or `canNotify()` is false.
  - The tap payload is `/home` (FR-036). The text is localized with `l10nFor(settings.locale)`.
- **Rationale**: A scheduled notification's text is fixed when it is scheduled. Refreshing on every
  data change makes it current at fire time without waking the app at 9 PM. A WorkManager job at the
  summary time can be 15+ minutes late and would need a second isolate start-up every day.
- **Alternatives considered**: A repeating daily notification: its text would be stale.

## R19. Glance snapshot: one data source for the widget and the daily summary

- **Decision**: New `lib/core/widget/` holds the following.
  - **`HomeGlance`** (pure Dart):
    - `dateKey`
    - `spend?`: `{todayMinor, currencyCode, budget?: {limitMinor, spentMinor, percent}}`
    - `habits?`: `{scheduled, done, items: up to 4 × {id, name, kind, value, target, colorHex}}`
  - **Modules fill it**: a new optional hook
    `Future<void> contributeGlance(GlanceBuilder b, ProviderReader read, DateTime nowLocal)`.
    - Expense uses `watchTodayAndMonthSpend(now).first` and the current month's overall budget.
    - Habit uses today's scheduled, non-archived habits in `sortOrder`, through `StreakEngine` day
      rules.
  - **`GlanceRefresher`**: a keep-alive provider started by bootstrap.
    - It listens to `db.tableUpdates(TableUpdateQuery.onAllTables([transactions, budgets,
      habits, habit_schedules, habit_entries, settings]))`. Drift's shared-isolate server forwards
      updates from other isolates too.
    - Debounced by 750 ms, it builds the glance and its next-day variant from the injected
      `Clock`, then:
      1. writes the widget payload (R20) and calls `HomeWidget.updateWidget`
      2. calls `DailySummaryScheduler.reschedule(glance)`
    - It also runs once at startup.
  - **Background isolates** (notification action, widget click, midnight, time zone, and boot
    callbacks, plus `core.autoBackup` and `expense.recurring` tasks) call `GlanceRefresher.refreshNow()`
    before they exit, since the app may not be running.
- **Rationale**: No module write path needs to change. One debounced listener covers every write
  in FR-049, including currency, language, lock, and widget settings, which all live in `settings`.
- **Alternatives considered**: Calling a refresh after each repository write: over 25 call sites
  (exploration of `TransactionRepository`, `BudgetRepository`, `RecurringRuleRepository`, the
  habit repositories), and easy to miss.

## R20. Home screen widget (Android, `home_widget`)

- **Decision**:
  - **Native** (under `android/app/src/main/`):
    - `kotlin/.../widget/TodayWidgetProvider.kt` extends `HomeWidgetProvider`. It renders a
      `RemoteViews` XML layout, `res/layout/widget_today.xml`: a spend row, a budget
      `ProgressBar` with a text label, and 4 habit slots (icon/check + name + progress text), with
      separate `-night` colors.
    - `res/xml/today_widget_info.xml` sets `targetCellWidth=4`, `targetCellHeight=2`,
      `minWidth=250dp`, `minHeight=110dp`, `resizeMode=horizontal|vertical`, and
      `updatePeriodMillis=0`.
    - The manifest declares the provider receiver plus `home_widget`'s
      `HomeWidgetBackgroundReceiver` and `HomeWidgetBackgroundService`.
  - **Data**: Dart writes one JSON string, `glance.v1`, with `HomeWidget.saveWidgetData`
    (data-model §6).
    - It contains every display string already localized and formatted: amounts through
      `MoneyFormatter`, and a percent text so status is never shown by color alone (FR-050).
    - It contains `mode: data|hidden` and both a `today` and a `next` day block. Kotlin picks the
      block whose `dateKey` matches the device's local date, so the widget is correct right after
      midnight even before Dart runs.
    - In hidden mode (lock on without `showDataOnWidget`, or onboarding not done; FR-047) it holds
      only the "Open DailyTrack" label.
  - **Clicks**:
    - Habit slots use `HomeWidgetBackgroundIntent.getBroadcast(context,
      "dailytrack://widget/check?habit=<id>&day=<key>")`.
    - The root uses `HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java,
      "dailytrack://widget/open")`.
    - Dart registers `HomeWidget.registerInteractivityCallback(widgetBackgroundEntryPoint)`, a
      top-level `@pragma('vm:entry-point')` function in `lib/app/background_entry_points.dart`.
    - It builds a `ProviderContainer(overrides: productionOverrides())`, which opens its own Drift
      connection, and checks the glance guard again: no data mode means no write.
    - It dispatches `AppAction(source: widget, name: 'habit.widgetCheck', ...)`. Habit handles it
      as follows:
      - A not-done yes/no habit gets `SetValue(target)`.
      - A done yes/no habit is a no-op (Q3).
      - A count habit gets `Increment`, applied only if the day key is still today.
    - It then calls `refreshNow()`.
  - **Launch**:
    - Bootstrap's launch payload logic also checks `HomeWidget.initiallyLaunchedFromHomeWidget()`.
    - Warm launches arrive on `HomeWidget.widgetClicked`.
    - Both map to `/home`, through the existing lock deferral (`LockSession.deferLocation`,
      feature 007 R7), so SYS-03 comes first when locked (FR-046).
  - **Plugin access**: all `home_widget` calls stay in `lib/core/widget/data/` and
    `lib/app/background_entry_points.dart` (new layering rule).
- **Rationale**: `home_widget` is the spec §2 choice. Pre-rendered strings keep localization,
  currency, and date logic in Dart with the injected clock. The native side only displays.
- **Alternatives considered**:
  - Jetpack Glance: Compose-based, needs Kotlin Compose setup, and is heavier for one fixed layout.
  - Computing the data in Kotlin: duplicates the business rules.

- **Implementation notes (2026-10-21)**:
  - `home_widget` 0.10.0 runs the Dart callback through a WorkManager worker started by
    `HomeWidgetBackgroundReceiver`. Its `HomeWidgetBackgroundService` is deprecated, so the
    manifest declares only the receiver (contracts/android.md listed both).
  - The widget colors need `ColorScheme.fromSeed`, which runs only under the Flutter engine, so
    `tool/android/widget_colors.dart` holds the XML writer and
    `UPDATE_WIDGET_COLORS=1 flutter test test/android/widget_colors_sync_test.dart` regenerates
    the files (a plain `dart run` cannot).
  - The budget bar uses three `ProgressBar`s (under, warning, over), one shown per level, because
    `RemoteViews` cannot change a progress tint before API 31.

## R21. Midnight, time zone, and reboot triggers

- **Decision**: A single Dart background entry point serves every system trigger, reusing
  `home_widget`'s background intent mechanism.
  - **`GlanceAlarmScheduler.kt`** schedules an `AlarmManager` alarm for the next local midnight +
    1 min. The alarm is exact when `canScheduleExactAlarms()`, otherwise
    `setWindow(..., 10 min)`. It fires `HomeWidgetBackgroundIntent` with
    `dailytrack://system/midnight`. It is re-armed:
    - on each fire
    - from Dart at startup (method channel `dailytrack/glance`, `armMidnight`)
    - on boot
    - on time zone change
  - **`SystemEventsReceiver.kt`** is a manifest receiver for `BOOT_COMPLETED`,
    `MY_PACKAGE_REPLACED`, and `TIMEZONE_CHANGED`. All three are exempt from Android 8+ implicit
    broadcast limits. It re-arms the midnight alarm and sends `dailytrack://system/boot` or
    `/timezone`.
  - **Dart side**: `widgetBackgroundEntryPoint` handles `system/*`:
    1. `refreshTimeZone()`
    2. each visible module's `onNotificationSettingsChanged`, which reschedules its notifications
       (habit `reconcileAll`)
    3. `DailySummaryScheduler.reschedule`
    4. `GlanceRefresher.refreshNow()`
    5. it records `deviceTimeZoneId`
  - **App start and resume**: `AppOpenRunner` compares the current zone with `deviceTimeZoneId` and
    reschedules on a change, which covers OEMs that drop broadcasts (FR-041).
  - **Existing behavior**: `flutter_local_notifications`'s own boot receiver still restores its
    stored alarms. Our boot handler then recomputes them against current data.
  - **First run**: `HomeWidgetBackgroundIntent` needs the callback handle saved by
    `registerInteractivityCallback`, which bootstrap calls on every start. Before the first app run
    after install, triggers are no-ops. That is acceptable: no data exists yet.
- **Rationale**: This gives one Dart background entry point instead of three. It needs no private
  WorkManager plugin APIs, and the triggers are timely. WorkManager's minimum period of 15 minutes
  cannot hit midnight within a minute (SC-010).
- **Alternatives considered**:
  - A WorkManager one-off with `initialDelay` to midnight: inexact by up to 15+ minutes.
  - Enqueueing the workmanager plugin's `BackgroundWorker` from Kotlin: depends on undocumented
    input keys.

## R22. "Forgot PIN?" Drive restore and SYS-01 recovery

- **Decision**: One shared flow, `showRestoreFlow(context, {RestoreEntry entry})`, in
  `lib/core/backup/presentation/restore_flow.dart`, used by SET-02, SYS-03, and SYS-01. It drives:
  1. pick a source (file or Drive)
  2. sign in and list (Drive)
  3. ask for the password if needed
  4. preview the summary
  5. confirm with a `ConfirmDialog` that states what will be replaced (§15.5)
  6. show progress, then the result

  It talks only to domain ports through providers (Constitution II).

  The entries differ as follows:
  - **SYS-03** (`RestoreEntry.forgotPin`): Drive only (FR-024). On success it calls
    `LockService.reset()`, `setLockEnabled(false)`, `setBiometricEnabled(false)`, and
    `LockSession.reset()`, then `go(Routes.home)`. Cancelling at any step returns with nothing
    changed, and a running lockout is untouched.
  - **SYS-01** (`RestoreEntry.databaseFailure`): file or Drive (FR-025).
    - Before writing, `DatabaseRecovery` (`core/database/database_recovery.dart`) closes the
      `appDatabaseProvider` connection and renames `dailytrack.sqlite` (plus `-wal` and `-shm`) to
      `dailytrack.broken-<ts>`, keeping it for support.
    - It then invalidates the provider, so a fresh database is created and migrated, and restores
      into it with the same engine.
    - Finally `bootstrapProvider.notifier.retry()` runs.
    - If the restore fails, the broken file stays aside, the fresh empty database remains, and the
      error offers "Try again". The original broken file is never deleted.
  - **SET-02**: file or Drive. Lock state is unchanged (R6).
- **Rationale**: One flow, three entries, the same validation, and the same untouched-on-failure
  guarantee.

## R23. Settings, SET-01, and SET-05 changes

- **Decision**:
  - **New `settings` keys** (data-model §1): `lastBackupLocation`, `lastBackupSizeBytes`,
    `lastAutoBackupAt`, `backupAccountEmail`, `autoBackupFrequency`, `autoBackupWifiOnly`,
    `backupEncrypt`, `backupIncludeReceipts`, `autoBackupFailures`, `autoBackupFailureNotified`,
    `showDataOnWidget`, `deviceTimeZoneId`, and `backupLeaseUntil`. The lease is read and written only
    by `BackupCoordinator` with a compare-and-set, not through `AppSettings`.
  - **`SettingsRepository`** gets setters for these, plus `setLastBackup({at, location, sizeBytes})`.
  - **No Drift schema change** (still v4).
  - **SET-01 Data**: Backup and restore → `/more/backup`, Export data → `/more/export`, then Erase
    all data (FR-034).
  - **SET-01 Notifications**: the "Exact timing" note row (R16). The daily summary time setter now
    calls `DailySummaryScheduler.reschedule`.
  - **SET-05**: "Show data on widget" switch below "Hide app content in recents". It is enabled
    only while the lock is on, with a helper text (FR-035).
  - **EXP-11**: an app bar action "Export this report" goes to
    `Routes.exportPath(period: state.period)`. `Period` gains a query codec in
    `core/utils/period.dart`: `kind`, `start`, and `end` as `yyyy-MM-dd`.
- **Routes**:
  - `/more/backup` is a child of More.
  - `/more/export` uses `parentNavigatorKey: rootNavigatorKey`, like `webPage`, so EXP-11 can push
    it above the shell and back returns to Reports.

## R24. Tests and layering scan

- **Decision**:
  - **Unit tests (pure)**:
    - envelope (vectors, wrong password, tampered header)
    - archive form detection
    - `BackupMigrator` (including a synthetic step)
    - the settings policy
    - section codecs and validators
    - `resolveReminderDay`
    - CSV builder (BOM, quoting, amounts)
    - PDF builder with a fake renderer (page count, Indic strings routed to the renderer)
    - glance building
    - daily summary text variants
    - `consumeOne`
  - **Data tests (real Drift in memory, `makeRealContainer`)**:
    - backup → erase → restore checksums for every table (SET-02 AC 1)
    - a failure injected in each phase leaves data unchanged (AC 2)
    - the v4 fixture restore (AC 3)
    - export dataset queries
    - `GlanceRefresher` debouncing with `tableUpdates`
  - **Integration test** `integration_test/backup_restore_test.dart`: backup → erase → restore with
    row counts and checksums (spec §13, SET-02 AC 1).
  - **Widget tests** with fakes and `NoAdsService`:
    - SET-02 states (disconnected, connected, list empty, busy, error)
    - SET-03 (locked, unlocked, nothing to export, EXP-11 prefill)
    - the restore flow from SYS-03 and SYS-01
    - the SET-05 toggle
    - the SET-01 rows
  - **SET-03 AC "Gujarati and Hindi notes render correctly in CSV and PDF"**:
    - CSV: byte-level test (BOM + exact UTF-8 bytes of a Gujarati and a Hindi note).
    - PDF: the Indic strings reach the renderer unchanged. A widget test also renders
      `FlutterShapedTextRenderer` for "ક્ષમા" and "क्षमा" and compares against a golden image
      (tag `golden`, Linux only, per CLAUDE.md).
    - Manual: open the CSV in Excel and the PDF in a viewer (quickstart §4).
  - **Layering scan additions** (`test/core/theme/no_hardcoded_style_test.dart`):
    - `google_sign_in`, `googleapis`, and the extension only in `lib/core/backup/data/`
    - `file_picker` only in `lib/core/backup/data/`
    - `home_widget` only in `lib/core/widget/data/` and `lib/app/background_entry_points.dart`
    - `pdf` and `csv` only in `lib/features/settings/domain/export/`
    - `archive` and `cryptography` allowed in `core/backup/domain/` (pure Dart) and
      `core/security/`
    - `workmanager` rule unchanged
- **Manual device checks** (quickstart §4):
  - background Google auth
  - a notification action with the app killed
  - widget clicks while the app is not running
  - midnight rollover and a time zone change
  - an exact vs. inexact alarm
  - Excel opening the CSV
