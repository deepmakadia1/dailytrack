---

description: "Task list for Backup, Export, Notifications, and Home Screen Widget (SET-02, SET-03, §12, T3.2–T3.4)"
---

# Tasks: Backup, Export, Notifications, and Home Screen Widget (SET-02, SET-03, §12, T3.2–T3.4)

**Input**: Design documents from `specs/008-backup-export-notifications-widget/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and spec §13 require:
- At least one automated test per copied acceptance criterion (SET-02 ×3, SET-03 ×1) and per
  user-story scenario (map in quickstart §5).
- Unit tests for the backup serialization round-trip and migrations.
- The backup → erase → restore integration test.
- Widget tests with fakes and `NoAdsService`.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US8). Test names start with the
Screen ID or area and the scenario, e.g. `SET-02 US1-7 failed restore leaves data untouched`
(Constitution I).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US8 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`. The Kotlin root is
  `android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/` (written `<kt>/` below).
- **Strings**:
  - Add keys to `tool/l10n/phase0_strings.py` (en, hi, gu together), then run
    `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit ARB files by hand.
  - Use sentence case, start buttons with a verb, and use ICU placeholders and plurals, never
    concatenation.
  - Prefixes: `backup_`, `restore_`, `export_`, `notif_`, `widget_`.
- **Codegen**: after changing any `@riverpod` or `@freezed` file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: read time only from `clockProvider` or an injected `Clock`. Never call `DateTime.now()`
  (scan-enforced). That includes file names, rotation, the failure counter, reminder day
  resolution, glance dates, and midnight logic.
- **Background entry points** (`notificationActionEntryPoint`, `widgetBackgroundEntryPoint`, the
  WorkManager `backgroundDispatcher`):
  - They are top-level `@pragma('vm:entry-point')` functions.
  - Each builds its own `ProviderContainer(overrides: productionOverrides())`, which opens its own
    Drift connection through `AppDatabase.open()` (`shareAcrossIsolates: true`).
  - They never throw, and always `dispose()` the container in `finally`.
- **Layering** (scan-enforced from T005):
  - `lib/core/backup/domain/**`, `lib/core/export/**`, `lib/core/widget/domain/**`, and
    `lib/features/settings/domain/**` import no `package:flutter/` or Riverpod.
  - `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`, and
    `file_picker` are allowed only in `lib/core/backup/data/`.
  - `home_widget` is allowed only in `lib/core/widget/data/` and
    `lib/app/background_entry_points.dart`.
  - `pdf` and `csv` are allowed only in `lib/features/settings/domain/export/`.
  - `features/settings` never imports `features/expense` or `features/habit`. Modules never import
    `features/settings`.
  - `lib/core/**` never imports `lib/app/`. App-layer functions (background entry points,
    `AppOpenRunner`) reach core through constructor parameters or providers bound in
    `production_overrides.dart`.
- **Screens and widgets**:
  - Use only `AppTokens` and `lib/core/widgets/`.
  - Loading uses a skeleton after 300 ms. Errors offer "Try again". Never show status by color
    alone. Respect `MediaQuery.disableAnimations`. Targets are 48 dp minimum with semantic labels.
  - No ad widgets and no reserved ad slot (§15.8).
- **Secrets**: the backup password is never logged, put in a `toString`, kept in freezed state
  beyond the sheet, or sent anywhere except secure storage. The Google client ID comes only from
  `--dart-define`.
- **External activities**: every file picker, Google sign-in, and share call is preceded by
  `ExternalActivityGuard.expectExternalActivity()` (feature 007 R15).
- **Widget tests**: `pumpTestApp` (`test/helpers/test_app.dart`), fakes from
  `test/helpers/fakes.dart`, `MutableClock`, and `NoAdsService`.
- **Real-DB tests**: `makeRealContainer` (`test/helpers/real_container.dart`).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Packages, build config, strings, layering rules, and doc renames

- [ ] T001 Add the packages to `pubspec.yaml` with `flutter pub add` (research R1):
  - `google_sign_in:^7.2.0`, `googleapis:^17.0.0`,
    `extension_google_sign_in_as_googleapis_auth:^3.0.0`;
  - `archive:^4.5.2`, `csv:^8.0.0`, `pdf:^3.13.1`, `file_picker:^13.1.0`, `home_widget:^0.10.0`.

  Do **not** add `printing` (plan, Complexity Tracking). Commit the updated `pubspec.lock`.
- [ ] T002 [P] Create `lib/core/config/google_config.dart`:
  - `abstract final class GoogleConfig { static const serverClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'); static bool get driveAvailable =>
    serverClientId.isNotEmpty; }`
  - Add a test in `test/core/config/google_config_test.dart` that no client ID literal
    (`apps.googleusercontent.com`) appears anywhere under `lib/` or `android/`.
- [ ] T003 [P] Add every string listed in contracts/screens.md (SET-02, restore flow, SET-03,
  SET-01 rows, SET-05 toggle, EXP-11 action, Forgot PIN, SYS-01, widget, notification copy, channel
  names and descriptions for `dailySummary` and `backup`, and all `BackupFailure` and export
  messages) to `tool/l10n/phase0_strings.py`. Include ICU placeholders: `{amount}`, `{done}`,
  `{total}`, `{count}` plurals for summary counts, `{percent}`, `{date}`, `{size}`.
  Run `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`.
  - Extend `tool/l10n/phase0_strings.py` to also write
    `android/app/src/main/res/values{,-hi,-gu}/strings.xml` from the keys `widget_label`,
    `widget_description`, and `widget_open`, with a "Generated by tool/l10n/phase0_strings.py — do
    not edit" header (Constitution V: strings only from the ARB source).
- [ ] T004 [P] Rename "feature 008" in code comments and test descriptions that mean rewarded ads
  to "the rewarded-ads feature (T4.4)". The files are `lib/core/widgets/locked_feature_overlay.dart`,
  `lib/features/dashboard/presentation/screens/home_screen.dart`,
  `lib/features/expense/presentation/screens/reports_screen.dart`,
  `lib/features/settings/presentation/widgets/about_section.dart`,
  `test/features/dashboard/fakes.dart`, and
  `test/features/expense/presentation/reports_screen_test.dart`. Confirm with
  `grep -rn "feature 008" lib test` that none remain.
- [ ] T005 Extend `test/core/theme/no_hardcoded_style_test.dart` with the layering rules in
  "Conventions" above (research R24), plus "`lib/core/**` imports nothing from
  `package:dailytrack/app/`". Each rule gets its own `test(...)`. The rules pass vacuously
  until the files exist.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Settings keys, module hook contracts, notification service extensions, the glance
model, file sharing, and the period codec. Every story depends on these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Tests for Foundational ⚠️

- [ ] T006 [P] Write `test/core/settings/settings_codec_backup_keys_test.dart` (data-model §1). For
  each new key, check the default when missing and the fallback when invalid:
  - `lastBackupLocation`: `"device"|"drive"|null`
  - `lastBackupSizeBytes`: `int ≥ 0|null`
  - `lastAutoBackupAt`: `int UTC ms|null`
  - `backupAccountEmail`: `string|null`
  - `autoBackupFrequency`: `"off"|"daily"|"weekly"`, default `"off"`
  - `autoBackupWifiOnly`: bool, default true
  - `backupEncrypt`: default false
  - `backupIncludeReceipts`: default false
  - `autoBackupFailures`: `int ≥ 0`, default 0
  - `autoBackupFailureNotified`: default false
  - `backupLeaseUntil`: `int|null`
  - `showDataOnWidget`: default false
  - `deviceTimeZoneId`: `string|null`
- [ ] T007 [P] Write `test/core/settings/settings_repository_backup_test.dart` (real in-memory DB):
  - `setLastBackup` writes `lastBackupAt`, `lastBackupLocation`, and `lastBackupSizeBytes` in one
    transaction.
  - `recordAutoBackupResult` follows the data-model §9 counter table:
    - 3rd failure → `notified` becomes true;
    - 4th failure → stays true, and the count increments;
    - success → resets both.
  - `setAutoBackup`, `setBackupEncrypt`, `setBackupIncludeReceipts`, `setShowDataOnWidget`,
    `setDeviceTimeZoneId`, and `setBackupAccountEmail` round-trip.
- [X] T008 [P] Write `test/core/notifications/local_notification_service_test.dart` additions
  (fake plugin seam):
  - The channels `daily_summary` and `backup` are created.
  - `ScheduledNotification(repeat: null)` schedules without `matchDateTimeComponents`.
  - `AppNotification.actions` map to `AndroidNotificationAction(showsUserInterface: false,
    cancelNotification: true)`.
  - A response with an `actionId` is emitted on `actions`, not `taps`.
  - `requestExactAlarms()` delegates to `requestExactAlarmsPermission`.
- [X] T009 [P] Write `test/core/widget/glance_builder_test.dart` (pure):
  - `GlanceBudget.percent` and `level` (under < 80 ≤ warning ≤ 100 < over).
  - `GlanceHabit.done` is `value >= target`.
  - The builder keeps at most 4 habit items, in insertion order.
  - A builder with no contributions gives null `spend` and `habits`.
- [X] T010 [P] Write `test/core/utils/period_query_test.dart` (contracts/routes.md):
  - Round-trips for day, week (first day Mon and Sun), month, year, and custom.
  - Invalid or missing parameters → null.
  - A week whose `start`/`end` don't match the current first day of week → custom with the same
    days.
- [X] T011 [P] Write `test/core/module/app_action_dispatcher_test.dart`:
  - Dispatch stops at the first visible module returning true.
  - Disabled modules are skipped.
  - A throwing module counts as not handled and does not stop later modules.
  - The result is false when no module handles the action.
- [ ] T012 [P] Write `test/core/share/file_sharer_test.dart`: the `share_plus` seam receives one
  `XFile` with the given path and MIME type. `expectExternalActivity` is called first.

### Implementation for Foundational

- [X] T013 Add the 13 keys (T006) to `lib/core/settings/domain/app_settings.dart` (fields and
  enums `BackupLocation`, `AutoBackupFrequency`), `lib/core/settings/data/settings_codec.dart`
  (keys, validation), `lib/core/settings/domain/settings_repository.dart`, and
  `lib/core/settings/data/settings_repository_impl.dart`.
  - Add the setters from contracts/services.md "Settings", plus
    `restoreSettings(Map<String,String> restorable, {required Iterable<String> seederIds})`, which
    is meant to be called inside the caller's transaction.
  - Update `FakeSettingsRepository` in `test/helpers/fakes.dart`.
  - Makes T006 and T007 pass.
- [X] T014 Create the shared types that the module hooks reference, before the hooks themselves:
  - `lib/core/module/app_action.dart`: `AppActionSource` (notification, widget, system) and
    `AppAction` (no dispatcher yet).
  - The pure export model in `lib/core/export/`, following data-model §8 verbatim:
    - `export_dataset.dart` (`ExportDataset`, `ExportFilterSpec`, `ExportOption`)
    - `export_request.dart` (`ExportFormat` → `FeatureKey`, `ExportRequest`, `ExportContext`)
    - `export_document.dart` (`ExportDocument`, `ExportColumn`, `ExportAlign`, a sealed
      `ExportCell` with `TextCell`/`MoneyCell`, `ExportSlice`, `isEmpty`)
  - The pure glance model in `lib/core/widget/domain/home_glance.dart` and `glance_builder.dart`
    (data-model §6: `HomeGlance`, `GlanceSpend`, `GlanceBudget`, `GlanceHabits`, `GlanceHabit`,
    `GlanceBuilder`), plus the `HomeWidgetBridge` interface in
    `lib/core/widget/domain/home_widget_bridge.dart`.

  Makes T009 pass.
- [ ] T015 [P] Write `test/core/module/tracker_module_defaults_test.dart`:
  - A minimal `TrackerModule` subclass gets the defaults: `exportDatasets()` is empty,
    `contributeGlance` leaves the builder untouched, and `handleAction` returns false.
  - `ExpenseModule` and `HabitModule` still construct and return `null` from `backupSection()`
    until US1.
- [X] T016 Replace the `BackupSection` placeholder (`lib/core/module/tracker_module.dart:112`)
  with the interface in the new `lib/core/backup/backup_section.dart` (contracts/services.md).
  Add the optional hooks to `TrackerModule`, using the T014 types:
  - `List<ExportDataset> exportDatasets() => const []`
  - `Future<void> contributeGlance(GlanceBuilder b, ProviderReader read, DateTime nowLocal) async {}`
  - `Future<bool> handleAction(AppAction action, ProviderReader read) async => false`

  Keep `ExpenseModule` and `HabitModule` compiling, and update `FakeTrackerModule` with recordable
  versions of the hooks. Makes T015 pass.
- [X] T017 Add `AppActionDispatcher` to `lib/core/module/app_action.dart`. It loops over
  `moduleRegistryProvider.visible(settings)` and calls `handleAction` (T016). Add its provider.
  Makes T011 pass.
- [X] T018 Implement `contributeGlance` in the modules:
  - In `lib/features/expense/expense_module.dart`: today spend from
    `watchTodayAndMonthSpend(nowLocal).first`, plus the overall budget for the current month.
    Add `BudgetRepository.overallFor(String monthKey)` if no one-shot read exists, along with its
    spent amount. The currency code comes from settings.
  - In `lib/features/habit/habit_module.dart`: today's scheduled, non-archived habits in
    `sortOrder`. Use `StreakEngine` day rules for "scheduled today", and today's value, target,
    colorHex, and kind. Set `scheduled`, `done`, and at most 4 items.
  - Tests: `test/features/expense/expense_glance_test.dart` and
    `test/features/habit/habit_glance_test.dart` (real in-memory DB, `Clock.fixed`).
- [X] T019 Extend `lib/core/notifications/notification_service.dart` and
  `local_notification_service.dart` (research R16):
  - Append `dailySummary` and `backup` to `NotificationChannelId`.
  - Add `NotificationActionSpec` and `AppNotification.actions`. Make `ScheduledNotification.repeat`
    nullable.
  - Add `Stream<NotificationActionEvent> actions` and `requestExactAlarms()`.
  - `LocalNotificationService` takes a `DidReceiveBackgroundNotificationResponseCallback?
    backgroundHandler` constructor parameter and passes it to `initialize(...,
    onDidReceiveBackgroundNotificationResponse: backgroundHandler)`. Core never imports
    `lib/app/`. `lib/app/production_overrides.dart` passes `notificationActionEntryPoint`, a stub
    top-level function in `lib/app/background_entry_points.dart` that returns immediately until
    T119.
  - Add ARB channel labels in `lib/app/production_overrides.dart`, and update
    `FakeNotificationService` (records actions, one-shots, and exact requests).
  - Makes T008 pass.
- [X] T020 [P] Add `periodToQuery` / `periodFromQuery` to `lib/core/utils/period.dart`. Makes T010
  pass.
- [ ] T021 [P] Create `lib/core/share/file_sharer.dart`: the `FileSharer` port, a `share_plus`
  implementation, and `fileSharerProvider`. Bind it in `production_overrides.dart` and add
  `FakeFileSharer` to `fakes.dart`. Makes T012 pass.
- [ ] T022 Make `externalActivityGuardProvider` (`lib/core/security/external_activity_guard.dart`)
  the single way every new caller announces an external activity. `FileSharer` (T021),
  `LocalBackupFiles` (T044), and `google_auth.dart` (T057) take an `ExternalActivityGuard` in their
  constructor and call `expectExternalActivity()` before opening the other app. Add a
  `FakeExternalActivityGuard` (call counter) to `test/helpers/fakes.dart` for their tests.

**Checkpoint**: settings keys, hooks, notification extensions, glance, export model, period codec,
and file sharing exist. User stories can begin.

---

## Phase 3: User Story 1 - Save a backup to the phone and restore it (Priority: P1) 🎯 MVP

**Goal**:
- Back up all module data and preference settings to one file, optionally with receipts.
- Restore it with validation, a summary, confirmation, an all-or-nothing write, and schema
  upgrades.

**Independent Test**: Seed data, save a backup file, erase all data, restore the file, and compare
row counts and checksums of every table (SET-02 AC 1).

### Tests for User Story 1 ⚠️

- [X] T023 [P] [US1] Write `test/core/backup/backup_archive_test.dart`:
  - `detectForm` recognizes `{` (after whitespace), `PK\x03\x04`, and `DTBK`, and returns `unknown`
    otherwise.
  - `packZip`/`unpackZip` round-trip `backup.json` + `receipts/a.jpg`.
  - A truncated zip → `BackupDamaged`.
- [X] T024 [P] [US1] Write `test/core/backup/backup_document_test.dart`:
  - The header rules: `format` must be exactly `"dailytrack-backup"`, `schemaVersion` must be an
    int within range, and `modules` must be an object.
  - Missing `settings` → empty.
  - `toJson`/`fromJson` round-trip.
- [X] T025 [P] [US1] Write `test/core/backup/backup_migrator_test.dart` (research R7):
  - A v4 document at current v4 is unchanged.
  - A synthetic section with a v4→v5 step upgrades a v4 document at current 5.
  - `schemaVersion` 99 → `BackupTooNew(99)`.
  - A section missing from an older file → empty section.
  - An unknown module id → listed in `skippedModuleIds`.
- [X] T026 [P] [US1] Write `test/core/backup/backup_settings_policy_test.dart`: exactly the
  allowlist in data-model §1 "Restorable keys" is exportable and restorable, plus `module.*`.
  Specifically, `lockEnabled`, `biometricEnabled`, `lockAfterSeconds`, `hideInRecents`, every
  backup key, `showDataOnWidget`, `adConsentStatus`, `removeAdsPurchased`, `latestSeenAt`,
  `debugUnlockAll`, `dailyInsightDate`, `dailyInsightId`, `deviceTimeZoneId`, `seed.*`, and
  `backupLeaseUntil` are not.
- [X] T027 [P] [US1] Write `test/features/expense/data/backup/expense_backup_section_test.dart`
  (real in-memory DB):
  - **Export/restore round-trip**: equal rows for accounts, categories, transactions, budgets, and
    recurring_rules, including soft-deleted rows and a transfer.
  - **Enums by name**: `"netBanking"`, `"transfer"`.
  - **`validate` rejects**, each with `BackupInvalid`:
    - an unknown enum name
    - a name over 40 chars
    - a note over 200 chars
    - `amountMinor` 0 and 99,999,999,901
    - a transfer with a `categoryId`
    - an expense without a category
    - a bad `monthKey`
    - `alert100SentAt` without `alert80SentAt`
    - a duplicate `id`
    - two non-deleted budgets with the same `(monthKey, categoryId)`
    - a transaction whose `accountId` is missing from the section
  - `attachments` lists non-null relative `receiptPath`s, and `withoutAttachments` nulls them.
  - `counts` and `summary` ("1,240 transactions") in en, hi, and gu.
- [X] T028 [P] [US1] Write `test/features/habit/data/backup/habit_backup_section_test.dart`:
  - Round-trip of habits, habit_schedules, and habit_entries, including archived habits, freezes,
    notes, and soft-deleted rows.
  - **`validate` rejects**, each with `BackupInvalid`:
    - `weekdaysMask` 128
    - `timesPerWeek` 7
    - `freezesAvailable` 3
    - `value` 10000
    - a bad `dateKey`
    - a duplicate `(habitId, dateKey)`
    - a duplicate non-deleted `(habitId, effectiveFromKey)`
    - an entry for a habit missing from the section
  - `summary` ("8 habits").
- [X] T029 [P] [US1] Write `test/core/backup/backup_round_trip_test.dart` (real DB, `Clock.fixed`):
  - Seed both modules, settings, and a receipt file in a temp docs folder.
  - Export in plain and zip forms → erase → restore. Then, per table, the row count and the SHA-256
    of sorted canonical rows equal the originals.
  - Receipt bytes are equal.
  - Restorable settings are restored. `lockEnabled` and the backup keys are unchanged.
  - `onboardingDone` is true and every `seed.*` marker is present.
  - File name `dailytrack_backup_20261021_2130.json` from the fixed clock (SET-02 AC 1, unit level).
- [X] T030 [P] [US1] Write `test/core/backup/restore_failure_test.dart` (SET-02 AC 2). For each
  injected failure, check that checksums equal the pre-restore state, the `receipts.restore/`
  folder is removed, and `receipts/` is unchanged:
  - `validate` throws
  - `upgrade` throws
  - staging fails (fake file system, storage full → `BackupStorageFull`)
  - the habit section's `restore` throws after expense rows were inserted
  - `PRAGMA foreign_key_check` returns a row
  - A swap failure after commit → the outcome is "done with warning", and the database equals the
    backup.
- [ ] T031 [P] [US1] Write `test/core/backup/restore_fixture_test.dart` (SET-02 AC 3):
  - Generate and commit `test/fixtures/backup/v4_full.json` and `v4_full.zip` (and later
    `v4_full.dtbk` in US4) with a generator test guarded by `--dart-define=WRITE_FIXTURES=true`.
  - Restoring each into the current schema succeeds with the expected counts.
  - Add a check in `test/drift/app_database/migration_test.dart` that, for each registered section,
    `upgrade` handles every `from` in `minRestorableSchema..AppDatabase.schemaVersion-1`.
- [X] T032 [P] [US1] Write `test/core/backup/backup_coordinator_test.dart`:
  - In-isolate single flight.
  - The lease compare-and-set in `backupLeaseUntil`: a second runner gets `BackupBusy`.
  - An expired lease (> 10 min, `MutableClock`) is taken over.
  - The lease is released in `finally`.
- [X] T033 [P] [US1] Write `test/core/backup/backup_service_test.dart` (fakes for
  `LocalBackupFiles`, `FileSharer`):
  - `backupToDevice` emits reading, packing, writing, and done. It writes into `<cache>/backups/`
    after clearing old files, and calls `saveAs` with the suggested name.
  - On success, `setLastBackup(location: device)` is called and auto failures reset. A cancelled
    `saveAs` → no `setLastBackup`.
  - `shareLastFile` shares that file.
  - `backupIncludeReceipts` false → `.json` and no attachments; true → `.zip`.
  - A missing receipt file is skipped and the backup still succeeds (spec Edge Case).
- [X] T034 [P] [US1] Write `test/core/backup/restore_flow_test.dart` (widget, `RestoreEntry.settings`,
  fakes):
  - Choose file → preview shows the date, app version, "1,240 transactions", and "8 habits".
  - Confirm dialog "Replace current data?" with a destructive action. Cancel → no `apply`.
  - Confirm → progress → success snackbar.
  - Errors show plain-language text with "Try again": `BackupNotRecognized` ("This isn't a
    DailyTrack backup"), `BackupTooNew` ("Update DailyTrack to restore this backup"), and
    `BackupDamaged`.
- [X] T035 [P] [US1] Write `test/features/settings/backup_screen_test.dart` (local parts):
  - Last backup card: "No backup yet", or the date, time, "This device", and size.
  - "Save backup file" → busy row → snackbar with "Share" → `FileSharer` called.
  - The "Include receipt images" switch persists.
  - "Restore from file" opens the restore flow.
  - Only one primary button is visible.
  - Loading skeleton and error state.
  - No `AppBannerAd`/`AppNativeAd` in the tree.
- [X] T036 [P] [US1] Write `test/features/settings/settings_screen_data_rows_test.dart` (FR-034):
  - The Data section shows Backup and restore before Erase all data.
  - The subtitle is "Last backup: …" or "Not backed up yet".
  - Tapping it goes to `/more/backup`.
  - US5 (T090) extends this file for the Export data row between them.
- [ ] T037 [US1] Write `integration_test/backup_restore_test.dart` (spec §13, SET-02 AC 1, device):
  1. Real app via `productionOverrides()` with a fake `LocalBackupFiles` writing to a temp folder.
  2. Seed through repositories: 200 transactions with one receipt and Hindi and Gujarati notes, 3
     habits with 30 days of entries, and settings.
  3. Back up to file, then `AppResetService.eraseAll()`, complete onboarding, and restore.
  4. Row counts and per-table SHA-256 checksums are equal.

### Implementation for User Story 1

- [X] T038 [P] [US1] Create the pure backup domain in `lib/core/backup/domain/`:
  - `backup_errors.dart`: sealed `BackupFailure` and every subtype in contracts/services.md, each
    with an `l10nMessage(AppLocalizations)` mapping (an extension in presentation if l10n is not
    allowed in domain; keep the domain free of Flutter).
  - `backup_archive.dart`: `detectForm`, `packZip`, `unpackZip`.
  - `backup_document.dart`, `backup_migrator.dart` (`minRestorableSchema = 1`, research R7),
    `backup_settings_policy.dart`, `restore_preview.dart`, `backup_progress.dart`.
  - Makes T023–T026 pass.
- [X] T039 [P] [US1] Create the Expense table codecs in `lib/features/expense/data/backup/` (one
  file per table: `account_codec.dart`, `category_codec.dart`, `transaction_codec.dart`,
  `budget_codec.dart`, `recurring_rule_codec.dart`):
  - Row ↔ JSON map with camelCase Dart column names and enums by **name** (data-model §3).
  - Validation that mirrors the table CHECKs verbatim:
    - account and category `name`: 1–40 chars
    - `colorHex`: `#RRGGBB`
    - transaction `amountMinor`: 1..99,999,999,900; `note` ≤ 200; the type shape rule
    - budget `monthKey`: `yyyy-MM`; `alert100SentAt` only with `alert80SentAt`
    - recurring `interval` ≥ 1, `endAt` ≥ `anchorAt`, plus the same type shape rule
- [X] T040 [US1] Create `lib/features/expense/data/backup/expense_backup_section.dart` implementing
  `BackupSection` (`moduleId 'expense'`, `sinceSchemaVersion 1`):
  - `export`: all rows including deleted.
  - `validate`: the codecs, plus in-section uniqueness and references.
  - `upgrade`: identity for v4.
  - `restore`: delete the 5 tables' rows, then `batch` insert in FK-safe order.
  - `counts`, `summary` (ICU plurals), `attachments`, `withoutAttachments`.

  Return it from `ExpenseModule.backupSection()`. Makes T027 pass.
- [X] T041 [P] [US1] Create the Habit codecs and `lib/features/habit/data/backup/habit_backup_section.dart`
  (`moduleId 'habit'`, `sinceSchemaVersion 4`):
  - Codecs `habit_codec.dart`, `habit_schedule_codec.dart`, `habit_entry_codec.dart`.
  - Validation, verbatim:
    - `name`: trimmed 1–40
    - `unit` ≤ 20
    - `targetValue`: 1 for yesNo, 1–9999 for count
    - `weekdaysMask` 0..127; `timesPerWeek` 1..6 or null
    - `reminderTimes`: a JSON list of 0–3 `HH:mm`
    - `startDateKey` and `dateKey`: `yyyy-MM-dd`
    - `freezesAvailable` 0..2; `celebratedMilestones` 0..63
    - entry `value` 0..9999; entry `note` ≤ 200

  Return it from `HabitModule.backupSection()`. Makes T028 pass.
- [X] T042 [US1] Create `lib/core/backup/data/backup_engine.dart`:
  - **`exportDocument()`**: one Drift read transaction across `registry.all` sections, settings
    through `BackupSettingsPolicy.exportable`, `appVersion` from `AppInfoSource`, and `createdAt`
    from the clock.
  - **`packFile(document, {receipts})`**: JSON encode and zip in `Isolate.run`, with receipt bytes
    read from `<docs>/` by relative path, skipping missing files.
  - **`openFile(bytes)`**: detect → (US4 adds decrypt) → unzip → parse → header check → `validate`
    each known section → migrate → `RestorePreview`, returning a `RestoreCandidate`.
  - **`apply(candidate)`**, research R8 phases 4–7:
    1. Stage receipts into `<docs>/receipts.restore/`.
    2. One transaction: `PRAGMA defer_foreign_keys = ON`, each section's `restore`, then
       `restoreSettings(..., seederIds: registry.all.expand(seeders).map(id))`, then
       `PRAGMA foreign_key_check` (throw on rows).
    3. Swap the folders.
    4. Aftermath through `restoreAftermathProvider` (`lib/core/backup/backup_providers.dart`,
       `Future<void> Function()`, throws unless overridden). Core never imports `lib/app/`.
       `lib/app/production_overrides.dart` binds it to, each step best effort:
       `NotificationService.cancelAll()`, then `AppOpenRunner.run()`. US6 (T124) adds
       `DailySummaryScheduler.reschedule()` and `GlanceRefresher.refreshNow()`. Tests override the
       provider with a recorder.

  Makes T029–T031 pass.
- [X] T043 [US1] Create `lib/core/backup/data/backup_coordinator.dart`: an in-isolate mutex plus the
  `backupLeaseUntil` compare-and-set in a short transaction, with a 10 min expiry from the clock.
  Makes T032 pass.
- [X] T044 [P] [US1] Create the `LocalBackupFiles` port in `lib/core/backup/domain/local_backup_files.dart`
  and `lib/core/backup/data/file_picker_local_backup_files.dart`:
  - `saveAs` uses `FilePicker.platform.saveFile(fileName:, bytes:)` and returns false on cancel.
  - `pick` uses `pickFiles(type: FileType.any)` and returns a readable `File` (copied to cache if
    needed).
  - Both call `expectExternalActivity()` first.
  - Add `FakeLocalBackupFiles` to `fakes.dart`.
- [X] T045 [US1] Create `lib/core/backup/data/backup_service.dart` (`backupToDevice`,
  `shareLastFile`) and `restore_service.dart` (`open(FileSource)`, `apply`), both through
  `BackupCoordinator`. Create `lib/core/backup/backup_providers.dart` and bind it in
  `production_overrides.dart`. Makes T033 pass.
- [X] T046 [US1] Create `lib/core/backup/presentation/restore_flow.dart`, `showRestoreFlow(context,
  {required RestoreEntry entry})` (contracts/screens.md "Restore flow"):
  - Source sheet (file only until US2).
  - Preview sheet.
  - `ConfirmDialog` ("Replace current data?", consequence text, destructive "Replace data").
  - A non-dismissible progress dialog.
  - Result snackbar, or an error dialog with a plain-language `BackupFailure` message and "Try
    again".

  Makes T034 pass.
- [X] T047 [US1] Add the route `/more/backup` (segment `backup`, name `backup`) in
  `lib/app/router/routes.dart` and `app_router.dart` as a child of the More branch.
- [X] T048 [US1] Create `lib/features/settings/presentation/controllers/backup_controller.dart`
  (`BackupState` per contracts/screens.md) and
  `lib/features/settings/presentation/screens/backup_screen.dart`, with widgets
  `last_backup_card.dart` and `local_backup_card.dart`:
  - Last backup card, Local backup card, and the "Include receipt images" switch.
  - Busy rows with progress.
  - Loading skeleton and error state. No empty state (fixed controls; plan Complexity Tracking).

  Makes T035 pass.
- [X] T049 [US1] Update the SET-01 Data section in
  `lib/features/settings/presentation/screens/settings_screen.dart` and `settings_controller.dart`:
  Backup and restore (relative last-backup subtitle) above Erase all data. Remove the "arrive with
  T3.2/T3.3" comment. The Export data row is added with its route in T100, so no placeholder ships.
  Makes T036 pass.
- [ ] T050 [US1] Commit the generated fixtures from T031 and run T037 on an emulator. Record the
  run in the task summary.

**Checkpoint**: Local backup and restore work end to end. SET-02 AC 1–3 pass. **MVP increment.**

---

## Phase 4: User Story 2 - Back up to Google Drive and restore from it (Priority: P1)

**Goal**: Connect Google with the `drive.appdata` scope only. Back up now, list, restore, delete,
and disconnect. Rotation applies to auto backups only (Q1).

**Independent Test**: Connect, back up now, erase, connect again, pick the Drive backup, and
restore.

### Tests for User Story 2 ⚠️

- [X] T051 [P] [US2] Write `test/core/backup/google_drive_backup_store_test.dart` (mocked `DriveApi`
  through an injectable factory):
  - `upload` sets `parents ['appDataFolder']` and `appProperties {app: 'dailytrack', kind, schemaVersion: '4', device}`
    with resumable upload options.
  - `list` uses `spaces 'appDataFolder'`, the `appProperties` query, `orderBy 'createdTime desc'`,
    and maps to `DriveBackupEntry`.
  - `pruneAuto(keep: 5)` with 7 auto and 2 manual files deletes the 2 oldest **auto** files only.
  - `delete` calls `files.delete`.
  - HTTP 401/403 → `DriveAuthRequired`. `storageQuotaExceeded` → `DriveQuotaExceeded`.
    `SocketException` → `DriveOffline`.
- [ ] T052 [P] [US2] Write `test/core/backup/google_auth_test.dart` (fake `GoogleSignIn` seam):
  - `connect` requests exactly `[DriveApi.driveAppdataScope]`.
  - Cancel → no email stored.
  - `disconnect` calls `disconnect()`, sets `backupAccountEmail` to null and `autoBackupFrequency`
    to `"off"`, and cancels `core.autoBackup`.
  - A silent authorization returning null → `DriveAuthRequired`.
  - `GoogleConfig.driveAvailable == false` → "Google Drive isn't available in this build".
- [X] T053 [P] [US2] Extend `test/features/settings/backup_screen_test.dart` (Drive parts, fake
  `DriveBackupStore`):
  - Disconnected card with "Connect Google account". Connect → email shown.
  - "Back up now" (primary) → progress → "Last backup … Google Drive".
  - Offline → an error with "Try again", and the last backup unchanged.
  - The Drive list: loading skeleton; empty "No backups in Drive yet"; error with "Reconnect Google
    account" for auth errors.
  - Rows show the date-time, size, a Manual/Auto chip, and the device.
  - Delete → `ConfirmDialog` → removed.
  - Tap → restore flow with `DriveSource`.
  - Disconnect → `ConfirmDialog` → the card resets.
- [X] T054 [P] [US2] Extend `test/core/backup/backup_service_test.dart`:
  - `backupToDrive(kind: manual)` uploads with `kind manual`, calls `setLastBackup(location:
    drive)`, and never calls `pruneAuto`.
  - `kind: auto` calls `pruneAuto(keep: 5)` after a successful upload only.
  - Upload failure → no `setLastBackup`, and the previous value is kept.
- [ ] T055 [P] [US2] Extend `test/core/reset/drift_app_reset_service_test.dart`: erase also calls
  `DriveBackupStore.disconnect()`. Best effort: a throw does not fail the erase.

### Implementation for User Story 2

- [X] T056 [P] [US2] Create the `DriveBackupStore` port and `DriveBackupEntry`/`BackupKind` in
  `lib/core/backup/domain/drive_backup_store.dart`. Add `FakeDriveBackupStore` to `fakes.dart`.
- [X] T057 [US2] Create `lib/core/backup/data/google_auth.dart`, wrapping `GoogleSignIn.instance`:
  - `initialize(serverClientId: GoogleConfig.serverClientId)`.
  - `connect()`: `authenticate()` then `authorizeScopes([driveAppdataScope])`, after
    `expectExternalActivity()`.
  - `silentClient()`: `attemptLightweightAuthentication()` then `authorizationForScopes(...)` then
    `authClient(...)` from the extension package, or `DriveAuthRequired`.
  - `disconnect()`.

  Makes T052 pass.
- [X] T058 [US2] Create `lib/core/backup/data/google_drive_backup_store.dart` implementing the port
  over `googleapis` `drive.DriveApi` (research R10), with streamed resumable upload, download to
  `<cache>/backups/`, list, delete, and `pruneAuto`. Map errors to `BackupFailure` types. Makes T051
  pass.
- [X] T059 [US2] Add `backupToDrive({required BackupKind kind})` to `BackupService` and
  `DriveSource` to `RestoreService.open`. Add Drive as a source in `restore_flow.dart`, with connect
  if needed and a list sheet. Bind providers in `production_overrides.dart`. Makes T054 pass.
- [X] T060 [US2] Create `lib/features/settings/presentation/widgets/drive_backup_card.dart` and
  `drive_backup_list.dart`, and wire them into `backup_screen.dart` and `backup_controller.dart`:
  - Connect, email, "Back up now" (primary when connected), and Disconnect behind `ConfirmDialog`.
  - The list with Manual/Auto chips, an overflow Delete behind `ConfirmDialog`, and empty and error
    states.
  - When `!GoogleConfig.driveAvailable`, the card shows the unavailable note.

  Makes T053 pass.
- [X] T061 [US2] Extend `lib/core/reset/data/drift_app_reset_service.dart` with a best-effort Drive
  disconnect. Makes T055 pass.

**Checkpoint**: Manual Drive backups and restores work. Both P1 stories are complete.

---

## Phase 5: User Story 3 - Back up automatically (Priority: P2)

**Goal**:
- Daily or Weekly Drive backups in the background, with Wi-Fi only.
- Rotation to the 5 newest auto backups.
- One failure notification after 3 consecutive failures.
- An app-open catch-up.

**Independent Test**: Set Daily with Wi-Fi only, run the job on Wi-Fi and on mobile data, then
force 3 failures.

### Tests for User Story 3 ⚠️

- [ ] T062 [P] [US3] Write `test/core/background/workmanager_background_scheduler_test.dart`
  additions (fake Workmanager seam):
  - `ensurePeriodic('core.autoBackup', every: 24h, network: unmetered)` registers with
    `Constraints(networkType: NetworkType.unmetered)` and `ExistingPeriodicWorkPolicy.update`.
  - Weekly uses 7 days. `connected` maps to `NetworkType.connected`.
- [X] T063 [P] [US3] Write `test/core/backup/auto_backup_task_test.dart` (fakes, `MutableClock`):
  - Success → `backupToDrive(kind: auto)`, `setLastAutoBackupAt`, and `recordAutoBackupResult(success)`.
  - 3 consecutive failures (`DriveOffline`, `DriveAuthRequired`, `BackupBusy` lease) → exactly one
    `show` on channel `backup` with id `stableNotificationId('backup-failing')`, payload
    `/more/backup`, and the title and body from contracts/screens.md.
  - A 4th failure → no new show. A success resets.
  - Auto backup off or no account → returns true without running.
  - The task always returns true.
- [X] T064 [P] [US3] Write `test/app/background_dispatcher_test.dart` additions:
  `runBackgroundTask('core.autoBackup', container)` runs the core task even with no module task of
  that name. Module tasks are unchanged.
- [ ] T065 [P] [US3] Write `test/app/app_open_runner_auto_backup_test.dart`:
  - Auto Daily with `lastAutoBackupAt` older than 30 h → one catch-up `backupToDrive(kind: auto)`,
    unawaited, after the first frame.
  - Within 30 h → none. Weekly uses 7 d + 6 h. Off → none.
- [X] T066 [P] [US3] Extend `backup_screen_test.dart`:
  - The Auto backup choice row (Off, Daily, Weekly) calls `setAutoBackup` and
    `ensurePeriodic`/`cancel`.
  - "Wi-Fi only" is disabled when Off and re-registers with the new network requirement.
  - Rows are hidden while disconnected.
- [ ] T067 [P] [US3] Extend `drift_app_reset_service_test.dart`: erase cancels `core.autoBackup`.

### Implementation for User Story 3

- [X] T068 [US3] Add `NetworkRequirement` and `ensurePeriodic` to
  `lib/core/background/background_scheduler.dart`, and implement them in
  `workmanager_background_scheduler.dart`. Update `FakeBackgroundScheduler` to record periodic
  registrations with their constraints. Makes T062 pass.
- [X] T069 [US3] Create `lib/core/backup/data/auto_backup_task.dart` `runAutoBackup(ProviderReader
  read)` (research R11, data-model §9 counter). Register `coreBackgroundTasks = {'core.autoBackup':
  runAutoBackup}` in `lib/app/background_dispatcher.dart`, checked before module tasks. Makes T063
  and T064 pass.
- [X] T070 [US3] Add the auto backup UI to `drive_backup_card.dart` and `backup_controller.dart`:
  the frequency choice through `showChoiceSheet`, the Wi-Fi only switch, and scheduling through
  `ensurePeriodic`/`cancel`. Makes T066 pass.
- [X] T071 [US3] Add the catch-up to `lib/app/app_open_runner.dart` (thresholds from T065,
  injected clock). Makes T065 pass.
- [X] T072 [US3] Extend `drift_app_reset_service.dart` to cancel `core.autoBackup`. Makes T067
  pass.

**Checkpoint**: Auto backup runs, rotates, and reports repeated failure.

---

## Phase 6: User Story 4 - Protect backups with a password (Priority: P2)

**Goal**: AES-256-GCM with a PBKDF2-SHA256 key from a password kept in secure storage (Q4). A
restore asks for the password.

**Independent Test**: Encrypt, back up, restore with a wrong password (no change), then the right
one (success).

### Tests for User Story 4 ⚠️

- [X] T073 [P] [US4] Write `test/core/backup/backup_envelope_test.dart` (research R3, data-model §4):
  - The layout is `"DTBK" | 0x01 | uint32 BE header length | header | ciphertext | 16-byte tag`.
  - The header has `kdf "pbkdf2-sha256"`, `iter`, a 16-byte `salt`, a 12-byte `nonce`, and `inner`.
  - Round-trips for json and zip inner forms, with `iterations: 1000`.
  - A wrong password, a flipped ciphertext bit, and a flipped header byte each →
    `BackupWrongPassword`.
  - A truncated file → `BackupDamaged`.
  - Over 256 MB → `BackupTooLargeToEncrypt` (fake size).
  - One test pins the default `iterations == 600000` and checks a known PBKDF2-HMAC-SHA256 vector.
- [ ] T074 [P] [US4] Write `test/core/backup/secure_backup_password_store_test.dart`
  (`InMemorySecureStore`): read, write, and delete key `backup.password`. Erase deletes the
  `backup.` prefix (extend `drift_app_reset_service_test.dart`).
- [X] T075 [P] [US4] Write `test/core/backup/backup_password_sheet_test.dart`:
  - Two fields, with "Save password" enabled only when both match and are non-empty.
  - The warning "If you lose this password, this backup can't be restored" is visible.
  - Cancel → returns false and `backupEncrypt` stays false.
  - Save → the password is written before `setBackupEncrypt(true)`.
  - Change mode overwrites the password.
- [ ] T076 [P] [US4] Extend `backup_service_test.dart` and `backup_round_trip_test.dart`:
  - Encrypt on → a `.dtbk` file that round-trips.
  - Encrypt on with a missing saved password → a manual backup asks again (the flow returns
    `BackupNeedsPassword`) and **never** writes a plain file.
  - Turning off → `.json`/`.zip` again.
  - Generate and commit `test/fixtures/backup/v4_full.dtbk` (password `fixture-password`,
    documented in the test).
- [X] T077 [P] [US4] Extend `restore_flow_test.dart`: an encrypted file → password prompt. A wrong
  password → "Wrong password or damaged file" stays in the sheet, and nothing changes. The right
  password → preview.

### Implementation for User Story 4

- [X] T078 [P] [US4] Create `lib/core/backup/domain/backup_envelope.dart` (pure; `cryptography`
  `Pbkdf2` + `AesGcm.with256bits`; KDF and crypto in `Isolate.run`). Makes T073 pass.
- [X] T079 [P] [US4] Create the `BackupPasswordStore` port and
  `lib/core/backup/data/secure_backup_password_store.dart` over `SecureKeyValueStore` (key
  `backup.password`). Extend `DriftAppResetService` to also delete the `backup.` prefix. Makes T074
  pass.
- [X] T080 [US4] Create `lib/core/backup/presentation/backup_password_sheet.dart` and wire the
  "Encrypt backup" switch and "Change password" into `backup_screen.dart` and
  `backup_controller.dart`. Makes T075 pass.
- [X] T081 [US4] Wire the envelope into `BackupEngine.packFile` (seal when `backupEncrypt`) and
  `openFile` (detect `DTBK` → require a password → open). The restore flow gets a password step.
  Makes T076 and T077 pass.

**Checkpoint**: Encrypted backups, manual and auto, work. The fixture set is complete.

---

## Phase 7: User Story 5 - Export transactions and habits as CSV or PDF (Priority: P2)

**Goal**:
- SET-03 with datasets from modules, a period, a format, filters, and a share sheet.
- CSV with BOM, and PDF with summary, donut, and table, plus correct Indic shaping.
- Gated by `FeatureGate`, with one-time unlocks used only on success.
- An entry from EXP-11.

**Independent Test**: Seed Hindi and Gujarati notes, then export a month as CSV and as PDF. Check
the bytes, the renderer calls, and the manual Excel and PDF check.

### Tests for User Story 5 ⚠️

- [X] T082 [US5] **Spike** (research R12): write `test/features/settings/domain/export/pdf_shaping_spike_test.dart`.
  It builds a one-line PDF with "ક્ષમા" and "क्षमा" in Noto fonts with `pdf` 3.13.1, extracts glyph
  ids, and records whether conjunct glyphs are used.
  - If `pdf` shapes correctly, note it in research R12 and skip the renderer (T085, T098), using vector
    text instead.
  - Otherwise keep the renderer.
  - Delete the spike test afterwards, recording the result in the summary.
- [X] T083 [P] [US5] Write `test/features/settings/domain/export/csv_builder_test.dart`
  (SET-03 AC, CSV part):
  - The output starts with bytes `EF BB BF`, uses CRLF, and has a header row with exactly Date,
    Time, Type, Category, Account, Payment mode, Amount, Note.
  - A Gujarati note "આજે ચા ☕" and a Hindi note "दूध, ब्रेड" come out as exact UTF-8 bytes.
  - Notes with a comma, a quote, and a newline are RFC 4180 quoted.
  - `MoneyCell(125050, 'INR')` → `1250.50`; `MoneyCell(500, 'JPY')` → `500`. No symbol and no
    grouping.
  - The habits header is Date, Habit, Value, Target, Unit, Status, Note.
- [X] T084 [P] [US5] Write `test/features/settings/domain/export/pdf_report_builder_test.dart`
  (fake `ShapedTextRenderer`):
  - `needsShaping` returns exactly the strings with U+0900–U+0DFF.
  - The built PDF has a first page with the summary lines and filter lines, a chart only when
    `chart != null`, and a table that repeats headers across pages (1,000 rows → more than 1 page).
  - Indic cells are embedded as images with the renderer's size. Latin text and amounts are not
    sent to the renderer.
  - A 10,000-row document builds without error (tag `slow`).
- [X] T085 [P] [US5] Write `test/features/settings/presentation/export/flutter_shaped_text_renderer_test.dart`:
  - The PNG size scales with text and font size at 3×.
  - A golden image for "ક્ષમા" and "क्षमा" (tag `golden`, Linux only per CLAUDE.md).
- [X] T086 [P] [US5] Write `test/features/expense/data/export/transactions_export_dataset_test.dart`
  (real DB, `Clock.fixed`):
  - Rows are oldest first, within the period, excluding soft-deleted ones.
  - Account and category filters work. The account filter matches the source or the destination.
  - Seeded names are localized (en, gu).
  - A transfer → Type "Transfer", empty category, and Account "Cash → SBI Savings".
  - The summary has total income, total expense, and net. The chart slices are expense by
    category, using category colors.
  - The empty period → `isEmpty`.
  - Also tests `TransactionRepository.listForExport`.
- [X] T087 [P] [US5] Write `test/features/habit/data/export/habits_export_dataset_test.dart`:
  - One row per habit per day with an entry in the period, including archived habits.
  - Status is Done (value ≥ target), Partial, or Freeze.
  - Notes are included.
  - The summary has the completion rate per habit, using the same rules as HAB-03 (freeze days
    excluded).
  - Also tests `HabitEntryRepository.entriesBetween`.
- [X] T088 [P] [US5] Write `test/core/feature_gate/drift_unlock_repository_consume_test.dart`
  (research R15):
  - `consumeOne(exportCsv)` revokes the **oldest** live, unexpired `rewardedAd` unlock and returns
    true.
  - With only a `purchase` unlock → false, nothing revoked.
  - With an expired one → false.
  - The gate stream then reports locked if none remain.
- [X] T089 [P] [US5] Write `test/features/settings/domain/export/export_use_case_test.dart`
  (data-model §9 "Export run", Q2):
  - Locked → `ExportLocked`, no file, no consume.
  - Empty → `ExportNothing`, no consume.
  - A builder or file write throws → `ExportFailed`, no consume.
  - Success → the file is written to `<cache>/exports/dailytrack_transactions_2026-10.csv`, then
    `consumeOne(exportCsv)`, then `ExportReady`.
  - With the debug unlock or Pro → `consumeOne` returns false and the export still succeeds.
  - Old export files are deleted first.
- [X] T090 [P] [US5] Write `test/features/settings/export_screen_test.dart`:
  - The layout from contracts/screens.md.
  - Data type chips only for enabled modules. With Habit disabled, there is no Habits chip.
  - The default period is the current month. Filters show only for Transactions, "All" vs "3
    selected".
  - Locked → `LockedFeatureOverlay` with no "Watch an ad" and "Get Pro" disabled. Export is
    disabled.
  - Debug unlock on (dev flavor) → enabled.
  - Nothing to export → a snackbar.
  - Ready → `FileSharer` called. After closing the share sheet, the choices are kept.
  - Loading and error states. No ads.
  - Extend `settings_screen_data_rows_test.dart`: the Data order is Backup and restore, Export
    data, Erase all data, and Export data goes to `/more/export` (FR-034).
- [X] T091 [P] [US5] Write the EXP-11 test additions in
  `test/features/expense/presentation/reports_screen_test.dart`:
  - The "Export this report" action has a semantic label.
  - Tapping with the period on September 2026 pushes
    `/more/export?dataset=transactions&kind=month&start=2026-09-01&end=2026-09-30`.
  - SET-03 opens with Transactions and that month. Back returns to Reports.
  - The action is visible even when the tab is locked.

### Implementation for User Story 5

- [X] T092 [P] [US5] Add `TransactionRepository.listForExport(TxnQuery)` (unpaged, oldest first,
  with joined account, category, and to-account) to
  `lib/features/expense/domain/repositories/transaction_repository.dart`, the DAO, and
  `drift_transaction_repository.dart`. Add
  `HabitEntryRepository.entriesBetween(LocalDate from, LocalDate to)` (all habits including
  archived, non-deleted entries, notes loaded) to the habit domain repo, DAO, and
  `drift_habit_entry_repository.dart`.
- [X] T093 [US5] Create `lib/features/expense/data/export/transactions_export_dataset.dart`:
  - `ExportDataset` id `transactions`.
  - Filters `accounts` and `categories`, with localized options.
  - Columns per data-model §8. Slices reuse the `buildDonut` grouping logic (move the pure part to
    `lib/features/expense/domain/usecases/` if it lives in presentation).

  Return it from `ExpenseModule.exportDatasets()`. Makes T086 pass.
- [X] T094 [US5] Create `lib/features/habit/data/export/habits_export_dataset.dart` (id `habits`,
  no filters) and return it from `HabitModule.exportDatasets()`. Makes T087 pass.
- [X] T095 [P] [US5] Add `consumeOne` to `lib/core/feature_gate/domain/unlock_repository.dart` and
  `data/drift_unlock_repository.dart`, and update `FakeFeatureGate`/`FakeUnlockRepository`. Makes
  T088 pass.
- [X] T096 [P] [US5] Create `lib/features/settings/domain/export/csv_builder.dart` (the `csv`
  encoder, `\uFEFF`, CRLF; `MoneyCell` via `Currencies` decimals). Makes T083 pass.
- [X] T097 [US5] Create `lib/features/settings/domain/export/shaped_text_renderer.dart` (the port
  and `ShapedImage`) and `pdf_report_builder.dart`:
  - `pdf` `MultiPage` A4 layout, with the summary page first.
  - `pw.Chart` with `PieDataSet` as a donut, plus a legend.
  - A table with repeated headers.
  - NotoSans for Latin text. Shaped images for Indic strings (from T082's outcome).
  - Built in `Isolate.run`.

  Makes T084 pass.
- [X] T098 [US5] Create `lib/features/settings/presentation/export/flutter_shaped_text_renderer.dart`:
  `TextPainter` with the bundled Noto Devanagari and Gujarati fonts → `PictureRecorder` → PNG at 3×,
  batched with `await Future<void>.delayed(Duration.zero)` between items. Makes T085 pass.
- [X] T099 [US5] Create `lib/features/settings/domain/export/export_use_case.dart` (gate check →
  build → font bytes loaded through an injected loader → write → `consumeOne` → outcome), plus
  providers. Makes T089 pass.
- [X] T100 [US5] Add the route `/more/export` (segment `export`, name `export`,
  `parentNavigatorKey: rootNavigatorKey`, reading the `dataset` and period query through
  `periodFromQuery`) and `Routes.exportPath({Period? period, String? dataset})`. Add the SET-01
  "Export data" row between Backup and restore and Erase all data in `settings_screen.dart`.
- [X] T101 [US5] Create `lib/features/settings/presentation/controllers/export_controller.dart`,
  `screens/export_screen.dart`, and `widgets/export_filters.dart` (contracts/screens.md SET-03).
  Datasets come from the enabled modules' `exportDatasets()` through the registry, and unlock state
  is live from `FeatureGate.watch`. Makes T090 pass.
- [X] T102 [US5] Add the "Export this report" app bar action to
  `lib/features/expense/presentation/screens/reports_screen.dart` (remove the "no 'Export this
  report'" doc comment). It calls `context.push(Routes.exportPath(period: state.period, dataset:
  'transactions'))`. Makes T091 pass.

**Checkpoint**: Exports work with the gate. The SET-03 AC is automated (CSV bytes, PDF renderer
routing, renderer golden) and checked manually.

---

## Phase 8: User Story 6 - Helpful notifications that work without opening the app (Priority: P2)

**Goal**:
- A daily summary with current text.
- "Mark done" and "Snooze 1 h" actions handled in the background.
- Rescheduling on start, restore, time zone change, and reboot.
- An exact-alarm note.

**Independent Test**: Set the summary time a few minutes ahead and check its text. Use the actions
with the app closed. Reboot and change the time zone.

### Tests for User Story 6 ⚠️

- [X] T103 [P] [US6] Write `test/features/habit/domain/reminders/resolve_reminder_day_test.dart`
  (pure, data-model §7 rule):
  - `at 08:00`: now 09:00 → today; now 07:00 → yesterday; a tap at 00:30 for a 21:00 reminder →
    the previous day.
  - Weekly `wd 3` (Wed) when now is Thu 10:00 → Wed.
  - Across a DST change (Clock-based local times).
- [X] T104 [P] [US6] Write `test/features/habit/habit_module_actions_test.dart` (real DB, fakes):
  - `habit.markDone` with the payload `/habits?habit=<id>&at=08:00&wd=0` writes
    `SetValue(target)` for the resolved day. Running it twice keeps it done (idempotent; never
    `Toggle`).
  - An archived or deleted habit → no write, returns true.
  - A count habit → no write.
  - `habit.snooze` schedules a one-shot at now + 1 h with id
    `stableNotificationId('habit-snooze:<id>')`, the same title, body, actions, and payload, and
    `exact` per `canScheduleExact()`.
- [X] T105 [P] [US6] Extend `test/features/habit/data/reminders/local_habit_reminder_scheduler_test.dart`:
  - yes/no reminders carry actions `habit.markDone` + `habit.snooze`; count reminders carry only
    `habit.snooze`.
  - The payload is `/habits?habit=<id>&at=<HH:mm>&wd=<0-7>`.
  - When done today and `remindOnlyIfNotDone`, reconcile cancels the snooze id.
- [X] T106 [P] [US6] Write `test/core/notifications/daily_summary_scheduler_test.dart`:
  - `textFor` variants: both modules → "Spent ₹1,250 today · 3/5 habits done"; Expense only → "Spent
    ₹1,250 today"; Habit only → "3/5 habits done". Check en, hi, and gu with placeholders.
  - `reschedule` schedules one one-shot (`repeat: null`) with id `stableNotificationId('daily-summary')`
    on channel `dailySummary` at the next `dailySummaryTime` from the clock, with payload `/home`.
  - After the time today → it uses tomorrow's glance (₹0, 0/N).
  - Master off or `canNotify()` false → cancel only.
- [X] T107 [P] [US6] Write `test/core/widget/glance_refresher_test.dart` (real DB, `fakeAsync`):
  - Writes to transactions, budgets, habits, habit_schedules, habit_entries, and settings trigger
    one refresh after 750 ms (debounced bursts).
  - Writes to other tables do not trigger a refresh.
  - `refreshNow` builds glances for today and the next day from the clock and calls
    `DailySummaryScheduler.reschedule`.
  - Widget saving is covered in US7.
- [X] T108 [P] [US6] Write `test/app/background_entry_points_test.dart` (notification part):
  - `handleNotificationAction(response, container)`, the testable core of the entry point, parses
    `actionId` and payload, dispatches `AppAction(source: notification, name: actionId, params:
    query)`, then calls `refreshNow`.
  - A throwing dispatch does not throw out of the entry point.
  - The container is disposed.
- [X] T109 [P] [US6] Write `test/app/notification_actions_foreground_test.dart`: while the app
  runs, an `actions` event goes through the same dispatcher with the app container, with no
  navigation and no unlock prompt.
- [X] T110 [P] [US6] Write `test/app/system_triggers_test.dart`:
  - `handleSystemTrigger(Uri, container)` for `dailytrack://system/{boot,timezone,midnight}` calls
    `refreshTimeZone`, each visible module's `onNotificationSettingsChanged` (boot, timezone),
    `DailySummaryScheduler.reschedule`, and `refreshNow`.
  - It records `deviceTimeZoneId`.
- [X] T111 [P] [US6] Write `test/app/app_open_runner_timezone_test.dart`:
  - A changed zone vs `deviceTimeZoneId` → reschedule (habit `reconcileAll`, daily summary) and the
    stored id updates.
  - An unchanged zone → no extra reschedule beyond the existing `onAppOpen`.
- [X] T112 [P] [US6] Write `test/features/settings/notifications_section_test.dart` additions:
  - `canScheduleExact` false with notifications on → the note "Reminders may arrive a few minutes
    late" and "Allow exact timing" → `requestExactAlarms()`.
  - true → no note.
  - Changing the daily summary time → `reschedule` called.
- [X] T113 [P] [US6] Write `test/app/restore_aftermath_test.dart`:
  - After `apply`, the `restoreAftermathProvider` bound in `production_overrides.dart` calls
    `cancelAll`, `AppOpenRunner.run`, `DailySummaryScheduler.reschedule`, and `refreshNow`, in that
    order.
  - A throw in any step does not fail the restore and does not skip the later steps.
- [X] T114 [P] [US6] Write `test/android/manifest_notifications_test.dart`: the manifest declares
  `com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver`, `SystemEventsReceiver` with
  `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, and `TIMEZONE_CHANGED`, and `MidnightAlarmReceiver`, plus
  `home_widget`'s background receiver and service (contracts/android.md).

### Implementation for User Story 6

- [X] T115 [P] [US6] Create `lib/features/habit/domain/reminders/resolve_reminder_day.dart`. Makes
  T103 pass.
- [X] T116 [US6] Update `lib/features/habit/data/reminders/local_habit_reminder_scheduler.dart`
  (actions by kind, the query payload, cancelling the snooze id when done) and implement
  `HabitModule.handleAction` for `habit.markDone`/`habit.snooze` in
  `lib/features/habit/habit_module.dart`. This uses `HabitDayWriter.write(id, day,
  SetValue(targetOn(day)))` and `NotificationService.schedule(repeat: null)`. Makes T104 and T105
  pass.
- [X] T117 [US6] Create `lib/core/notifications/daily_summary_scheduler.dart` and its provider.
  Makes T106 pass.
- [X] T118 [US6] Create `lib/core/widget/glance_refresher.dart`:
  - A keep-alive provider with `start()` (`db.tableUpdates(TableUpdateQuery.onAllTables([...6
    tables]))`, debounced by 750 ms) and `refreshNow()`.
  - `refreshNow()` builds today and next-day glances through modules' `contributeGlance`, then
    `DailySummaryScheduler.reschedule`, then a widget save hook (no-op until US7).
  - Start it from `lib/app/bootstrap.dart` after the first frame, unawaited.

  Makes T107 pass.
- [X] T119 [US6] Implement `notificationActionEntryPoint` in `lib/app/background_entry_points.dart`
  (replacing the T019 stub) with the testable `handleNotificationAction`. Subscribe to
  `NotificationService.actions` in `lib/app/app.dart` and route through `AppActionDispatcher`.
  Makes T108 and T109 pass.
- [X] T120 [US6] Add the shared `widgetBackgroundEntryPoint(Uri?)` in
  `lib/app/background_entry_points.dart` with `handleSystemTrigger` for `system/*` URIs.
  - Add `HomeWidgetBridge.registerBackgroundCallback(Future<void> Function(Uri?) callback)`,
    implemented in `lib/core/widget/data/home_widget_plugin_bridge.dart` with
    `HomeWidget.registerInteractivityCallback(callback)`. The bridge never imports `lib/app/`.
  - Add `armMidnight()` (method channel `dailytrack/glance`).
  - `lib/app/bootstrap.dart` calls `registerBackgroundCallback(widgetBackgroundEntryPoint)` and
    `armMidnight()` after the first frame.

  Makes T110 pass.
- [X] T121 [US6] Add the Android host pieces for notifications and system triggers
  (contracts/android.md):
  - The manifest receivers (`ActionBroadcastReceiver`, `HomeWidgetBackgroundReceiver` and service,
    `SystemEventsReceiver`, `MidnightAlarmReceiver`).
  - `<kt>/system/GlanceAlarmScheduler.kt`, `MidnightAlarmReceiver.kt`, `SystemEventsReceiver.kt`.
  - The `dailytrack/glance` channel in `<kt>/MainActivity.kt`.

  Makes T114 pass.
- [X] T122 [US6] Add the time zone check to `lib/app/app_open_runner.dart` (compare
  `TimeZoneSource.deviceZoneId()` with `deviceTimeZoneId`; on change, reschedule and store). Makes
  T111 pass.
- [X] T123 [US6] Add the exact-alarm note row and summary rescheduling to
  `lib/features/settings/presentation/widgets/notifications_section.dart` and
  `settings_controller.dart`. Makes T112 pass.
- [X] T124 [US6] Extend the `restoreAftermathProvider` binding in `lib/app/production_overrides.dart`
  (T042 contract) with `DailySummaryScheduler.reschedule()` and `GlanceRefresher.refreshNow()`, after
  `AppOpenRunner.run()`. Makes T113 pass.

**Checkpoint**: The daily summary, actions, and every rescheduling trigger work.

---

## Phase 9: User Story 7 - See today at a glance on the home screen (Priority: P3)

**Goal**:
- A 4×2 widget with today's spend, the budget bar, and up to 4 habit checks.
- Checks without opening the app, and no undo (Q3).
- A hidden mode when locked.
- Updates on data changes and at midnight.

**Independent Test**: Place the widget. Log and check in the app, tap a check with the app killed,
toggle the lock, and wait past midnight.

**Depends on**: US6 (the background callback, `GlanceRefresher`, and system triggers).

### Tests for User Story 7 ⚠️

- [X] T125 [P] [US7] Write `test/core/widget/widget_payload_test.dart` (pure, data-model §6):
  - `encodeWidgetPayload` produces `v: 1`, `mode`, `openLabel`, and `today` and `next` blocks.
  - Amounts are formatted with `MoneyFormatter` and the currency.
  - Budget `text` is like "62% used · ₹6,200 of ₹10,000", with `level` under, warning, or over, or
    `{none: "No budget set"}`.
  - Habits have at most 4 items, with `progress` "12 / 20 pages" for count habits and `a11y`
    strings.
  - Expense disabled → `spend`/`budget` null. Habit disabled → `habits` empty.
  - `hidden: true` → `today`/`next` null.
  - Output in en and gu.
- [X] T126 [P] [US7] Extend `test/core/widget/glance_refresher_test.dart`:
  - Hidden when `onboardingDone == false`, or `lockEnabled && !showDataOnWidget`; data when the lock
    is off or `showDataOnWidget` is true.
  - `HomeWidgetBridge.save` is called with the payload after every refresh.
- [X] T127 [P] [US7] Extend `test/app/background_entry_points_test.dart` (widget part):
  - `dailytrack://widget/check?habit=<id>&day=<today>` → `AppAction(source: widget, name:
    'habit.widgetCheck')`.
  - Habit: a not-done yes/no habit → `SetValue(target)`. A done yes/no habit → no write (Q3). A
    count habit → `Increment`.
  - `day` ≠ today (stale widget) → no write.
  - A hidden-mode guard (lock on, `showDataOnWidget` false) → no write.
  - `refreshNow` is always called.
- [X] T128 [P] [US7] Write `test/app/widget_launch_test.dart`:
  - Cold start with `launchLocation() == '/home'` and the lock on → `/lock?from=/home`, then Home
    after unlock.
  - A warm `launches` event while locked → deferred, then Home after unlock.
  - Lock off → Home.
- [X] T129 [P] [US7] Extend `test/features/settings/security_screen_test.dart`: the
  `security_show_widget_data` switch reads "Show data on widget" with the helper "Shows amounts and
  habit names on your home screen". It is disabled with "Needs app lock" when the lock is off, and
  toggling calls `setShowDataOnWidget`.
- [X] T130 [P] [US7] Extend `drift_app_reset_service_test.dart`: erase calls `refreshNow` (the
  widget becomes hidden).
- [X] T131 [P] [US7] Write `test/android/widget_manifest_test.dart`:
  - The `.widget.TodayWidgetProvider` receiver has `APPWIDGET_UPDATE` and meta-data
    `@xml/today_widget_info`.
  - `today_widget_info.xml` has `targetCellWidth 4`, `targetCellHeight 2`, `minWidth 250dp`,
    `minHeight 110dp`, and `updatePeriodMillis 0`.
  - `widget_today.xml` has 4 habit slots with `minHeight` ≥ 48dp.
  - `values-night/widget_colors.xml` exists.
  - `strings.xml` exists in `values`, `values-hi`, and `values-gu`, with `widget_label`.

### Implementation for User Story 7

- [X] T132 [P] [US7] Create `lib/core/widget/domain/widget_payload.dart` (`encodeWidgetPayload`).
  Makes T125 pass.
- [X] T133 [US7] Complete `lib/core/widget/data/home_widget_plugin_bridge.dart` (`save` through
  `HomeWidget.saveWidgetData('glance.v1', json)` + `updateWidget(qualifiedAndroidName:
  '...widget.TodayWidgetProvider')`, `launchLocation`, `launches`). Plug the save into
  `GlanceRefresher.refreshNow` with the hidden-mode rules. Makes T126 pass.
- [X] T134 [US7] Implement `HabitModule.handleAction` for `habit.widgetCheck` and the widget branch
  of `widgetBackgroundEntryPoint` (`handleWidgetCheck`, with the guard). Makes T127 pass.
- [X] T135 [US7] Route widget launches: in `lib/app/bootstrap.dart`, after `launchPayload()`, fall
  back to `HomeWidgetBridge.launchLocation()`. In `lib/app/app.dart`, subscribe to `launches` with
  the same lock deferral as notification taps. Makes T128 pass.
- [X] T136 [US7] Add the SET-05 "Show data on widget" switch to
  `lib/features/settings/presentation/screens/security_screen.dart` and `security_controller.dart`.
  Makes T129 pass.
- [X] T137 [US7] Extend `drift_app_reset_service.dart` with a best-effort `refreshNow`. Makes T130
  pass.
- [X] T137a [P] [US7] Create `tool/android/widget_colors.dart` (run with `dart run
  tool/android/widget_colors.dart`). It writes `android/app/src/main/res/values/widget_colors.xml`
  and `values-night/widget_colors.xml` from the light and dark `AppColors` tokens in
  `lib/core/theme/app_colors.dart`: surface, onSurface, onSurfaceVariant, success, warning,
  expense. Add `test/android/widget_colors_sync_test.dart`, which fails if the XML and the tokens
  differ (Constitution V, §15.2: hex values come from one source).
- [X] T138 [US7] Add the native widget (contracts/android.md):
  - `<kt>/widget/TodayWidgetProvider.kt`: picks `today` or `next` by local date, binds
    `RemoteViews`, check `PendingIntent`s through `HomeWidgetBackgroundIntent`, the root through
    `HomeWidgetLaunchIntent`, and content descriptions from `a11y`.
  - `res/layout/widget_today.xml`, `widget_hidden.xml`, `res/xml/today_widget_info.xml`,
    `res/values{,-night}/widget_colors.xml`, `res/values{,-hi,-gu}/strings.xml`, and
    `res/drawable/ic_widget_check.xml`, `ic_widget_check_done.xml`, `ic_widget_plus.xml`.
  - Colors come only from the generated `widget_colors.xml` (T137a), and strings only from the
    generated `strings.xml` (T003). Text colors meet 4.5:1 in both modes.
  - The manifest receiver.

  Makes T131 pass.

**Checkpoint**: The widget works with the app killed, follows the lock rules, and rolls over at
midnight.

---

## Phase 10: User Story 8 - Recover with a backup when the PIN is forgotten or the database fails (Priority: P3)

**Goal**: "Restore from Google Drive backup" in SYS-03 "Forgot PIN?" (lock cleared on success), and
"Restore from backup" on the SYS-01 database-failure screen.

**Independent Test**: Make a Drive backup and set a PIN. Use Forgot PIN → restore. Data is back,
the lock is off, and Home opens.

### Tests for User Story 8 ⚠️

- [X] T139 [P] [US8] Extend `test/features/lock/forgot_pin_sheet_test.dart`:
  - The sheet shows "Restore from Google Drive backup" (primary) above "Erase all data" and Cancel.
  - Restore → `showRestoreFlow(entry: forgotPin)` with no source step (Drive only).
  - No Drive backups → the message and an "Erase all data" action.
  - Cancel at each step → no change, and a running lockout keeps counting (`TestLock`).
- [X] T140 [P] [US8] Extend `restore_flow_test.dart` (forgotPin): success →
  `LockService.reset()`, `setLockEnabled(false)`, `setBiometricEnabled(false)`, and
  `LockSession.reset()`, then `go('/home')`.
- [ ] T141 [P] [US8] Write `test/core/database/database_recovery_test.dart` (temp directory):
  - `moveBrokenDatabaseAside` renames `dailytrack.sqlite`, `-wal`, and `-shm` to
    `dailytrack.broken-<ts>.*` (clock time) and invalidates `appDatabaseProvider`. A new database
    opens at v4.
  - The broken files are never deleted.
  - A failure → the original files stay where they were.
- [ ] T142 [P] [US8] Extend `test/app/splash/splash_screen_test.dart`:
  - `BootstrapFailed` → `ErrorState` with "Retry" and "Restore from backup".
  - Restore → `showRestoreFlow(entry: databaseFailure)` (file or Drive).
  - Success → `bootstrap.retry()`.
  - A failure → error with "Try again", and the broken file stays aside.

### Implementation for User Story 8

- [X] T143 [US8] Update `lib/features/lock/presentation/widgets/forgot_pin_sheet.dart` (remove the
  "arrives with T3.2" comment) and add the `forgotPin` entry behavior in `restore_flow.dart`
  (Drive-only source, lock clearing, go Home). Makes T139 and T140 pass.
- [ ] T144 [US8] Create `lib/core/database/database_recovery.dart` and its provider. Makes T141
  pass.
- [ ] T145 [US8] Add `secondaryAction` "Restore from backup" to `lib/app/splash/splash_screen.dart`
  and the `databaseFailure` entry in `restore_flow.dart` (calls `moveBrokenDatabaseAside` before
  apply, then `bootstrapProvider.notifier.retry()`). Makes T142 pass.

**Checkpoint**: Every story is complete.

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Accessibility, performance, docs, the constitution follow-up, the design review, and
the quality gates

- [ ] T146 [P] Write `test/a11y/backup_export_font_scale_test.dart` (SC-012). Cover SET-02 (all
  card states), the restore flow sheets and dialogs, the password sheet, SET-03 (unlocked and
  locked), the SET-01 Data and Notifications rows, and SET-05:
  - at 200% text scale on a 360×780 dp surface, in en, hi, and gu, light and dark;
  - no `RenderFlex` overflow;
  - `androidTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` pass.
- [ ] T147a [P] Write `test/features/settings/domain/export/export_perf_test.dart` (tag `slow`,
  SC-007): with 1,000 transactions, CSV is ready in under 3 s, and the PDF with the fake renderer
  is built in under 10 s.
- [ ] T147 [P] Write `test/core/backup/backup_perf_test.dart` (tag `slow`, SC-004): seed 10,000
  transactions and 50 habits × 365 entries in memory. Export plus pack is under 10 s; open plus
  apply is under 15 s.
- [X] T148 [P] Update `docs/CLAUDE.md`:
  - "Backups: each module owns a `BackupSection` (codecs + validation + upgrade steps); every Drift
    migration that changes a backed-up table adds an upgrade step"
  - "Export data comes from `TrackerModule.exportDatasets()`; settings never imports modules"
  - "Widget and daily summary refresh from `GlanceRefresher` (Drift `tableUpdates`); don't add
    manual refresh calls in repositories"
  - "Background entry points are top-level in `lib/app/background_entry_points.dart` and open their
    own container"

  Check that `docs/spec.md` SET-02, SET-03, SET-05, §4, and §12 match the final code (the
  2026-10-21 feature 008 Changes entry).
- [ ] T149 [P] Verify the code matches constitution 1.0.2 Principle III (amended 2026-10-21 before
  implementation): restore is the only hard delete besides Erase all data, and data leaves the
  device only through Drive backups and user-saved or user-shared files. Check that
  `docs/CLAUDE.md` "Data rules" still states both exceptions.
- [ ] T150 Run the §15.10 design review checklist on SET-02, the restore flow, the password sheet,
  SET-03, the SET-01 and SET-05 changes, the EXP-11 action, the Forgot PIN sheet, the SYS-01 error
  screen, and the widget (excluding ad items). Fix findings and record the results. Confirm that the
  screens without an empty state are exactly SET-02 and SET-03 (plan Complexity Tracking).
- [ ] T151 Run the quality gates (quickstart §2) and fix all findings:
  - `dart run build_runner build --delete-conflicting-outputs`
  - `flutter analyze` (zero warnings)
  - `dart format --set-exit-if-changed .`
  - `flutter test --exclude-tags golden` on Windows, plus `flutter test` (golden included) on
    Linux/CI
  - `flutter build apk --flavor dev --release --dart-define=GOOGLE_SERVER_CLIENT_ID=<id>`, to check
    the R8 rules for `home_widget` and notifications

  Then:
  1. Walk through quickstart.md §4 steps 1–12 on a device. Include the background Google auth check
     (research R11; if silent auth fails in the worker, confirm the app-open catch-up and record it),
     killed-app actions and widget clicks, midnight, time zone, reboot, exact vs inexact, and Excel
     plus a PDF viewer for Hindi and Gujarati.
     Also check cross-isolate updates (research R19): with the app open on HAB-01, tap a widget
     check, and HAB-01 and Home update within 5 s. If they don't, add a resume-time refresh
     (invalidate the habit streams on `AppLifecycleState.resumed`) and record it in the summary.
  2. Tick `T3.2`, `T3.3`, and `T3.4` in `docs/spec.md` §14 only after this passes.
  3. Write the task summary: files changed, tests added, §15.10 results, the spike result (T082),
     and open items (the SET-02 banner and post-backup interstitial, "Watch an ad" for exports →
     T4.x).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies. T001 comes before everything that imports a new package.
  T003 comes before UI tasks. T005 can land any time (vacuous until files exist).
- **Foundational (Phase 2)**: depends on Setup and blocks all stories.
  - T013 → T018, and every story's settings use.
  - T014 (shared types) → T016 (hooks) → T017 (dispatcher) and T018. T015 is the test for T016.
  - T019 → US3 (backup notification) and US6.
- **US1 (P1)**: depends on Phase 2. T038 → T040/T041 → T042 → T043 → T045 → T046 → T048. T047
  comes before T048. T049 can run alongside T048.
- **US2 (P1)**: depends on US1 (engine, service, restore flow, SET-02 screen).
- **US3 (P2)**: depends on US2 (`backupToDrive(kind: auto)`, `pruneAuto`).
- **US4 (P2)**: depends on US1 (engine). It is independent of US2 and US3, but its UI edits
  `backup_screen.dart`, so serialize with them.
- **US5 (P2)**: depends only on Phase 2. It can run in parallel with US1–US4. It edits
  `settings_screen.dart` only through the route that T049 already added.
- **US6 (P2)**: depends on Phase 2. T124 needs US1's T042. Everything else is independent.
- **US7 (P3)**: depends on US6 (T118, T120, T121).
- **US8 (P3)**: depends on US2 (Drive restore) and US1 (restore flow).
- **Polish**: after the desired stories. T146 needs all screens.

### Within Each User Story

- Tests are written first and fail, then implementation follows.
- Pure domain code comes before data adapters, which come before services, then controllers, then
  screens, then app wiring and native code.
- Run codegen after each `@riverpod`/`@freezed` change. Run the l10n scripts after string changes.

### Parallel Opportunities

- **Phase 1**: T002, T003, and T004 alongside T001. T005 any time.
- **Phase 2**: tests T006–T012 and T015 together. After T014: T016, then T017 and T018. T020 and
  T021 run any time alongside.
- **US1**: tests T023–T036 together. T038, T039, T041, and T044 together.
- **US5**: tests T083–T091 together (after the T082 spike). T092, T095, and T096 together.
- **US6**: tests T103–T114 together. T115 and T117 together.
- **Across stories**: once Phase 2 is done, US1 → US2 → US3 (one developer) can run alongside US5
  (a second developer) and US6 → US7 (a third). Serialize edits to `backup_screen.dart`,
  `restore_flow.dart`, `app.dart`, `bootstrap.dart`, `drift_app_reset_service.dart`,
  `production_overrides.dart`, and `AndroidManifest.xml`.

---

## Parallel Example: User Story 1

```text
# Tests together:
Task: "T023 test/core/backup/backup_archive_test.dart"
Task: "T024 test/core/backup/backup_document_test.dart"
Task: "T025 test/core/backup/backup_migrator_test.dart"
Task: "T026 test/core/backup/backup_settings_policy_test.dart"
Task: "T027 test/features/expense/data/backup/expense_backup_section_test.dart"
Task: "T028 test/features/habit/data/backup/habit_backup_section_test.dart"
Task: "T029 test/core/backup/backup_round_trip_test.dart"
Task: "T030 test/core/backup/restore_failure_test.dart"

# Then, in parallel:
Task: "T038 lib/core/backup/domain/*"
Task: "T039 lib/features/expense/data/backup/*_codec.dart"
Task: "T041 lib/features/habit/data/backup/*"
Task: "T044 lib/core/backup/data/file_picker_local_backup_files.dart"
```

## Parallel Example: User Story 5

```text
Task: "T083 test/features/settings/domain/export/csv_builder_test.dart"
Task: "T084 test/features/settings/domain/export/pdf_report_builder_test.dart"
Task: "T086 test/features/expense/data/export/transactions_export_dataset_test.dart"
Task: "T087 test/features/habit/data/export/habits_export_dataset_test.dart"
Task: "T088 test/core/feature_gate/drift_unlock_repository_consume_test.dart"
```

---

## Implementation Strategy

### MVP First (P1 stories)

1. Phase 1 Setup, then Phase 2 Foundational.
2. US1: local backup and restore. **Validate**: SET-02 AC 1–3 (T029–T031, T037) and quickstart §4
   steps 1–2. **This is the first shippable increment**: users can protect their data with no
   Google setup.
3. US2: Drive backup and restore. **Validate**: quickstart §4 step 4 (manual parts). **The MVP is
   done.**

### Incremental Delivery

4. US3 (auto backup) → US4 (encryption).
5. US5 (export, in parallel with steps 3–4 if staffed). **Validate**: SET-03 AC (T083, T084, T085,
   and quickstart §4 step 7).
6. US6 (notifications) → US7 (widget).
7. US8 (recovery paths).
8. Polish: a11y, performance, docs, constitution PATCH, design review, gates.

---

## Notes

- [P] means different files and no dependency on an incomplete task.
- The copied acceptance criteria map to:
  - SET-02 AC1 → T029, T037
  - SET-02 AC2 → T030
  - SET-02 AC3 → T031 (+ T025)
  - SET-03 AC → T083 (CSV), T084 + T085 (PDF), and the manual check in T151
- Out of scope, with no placeholders left for them (§15.8): the SET-02 banner, the interstitial
  after a manual backup, and "Watch an ad" for exports. All arrive with T4.x.
- Commit after each task or logical group, with the Screen ID or area in the message (e.g.
  `SET-02: add backup envelope`, `§12: daily summary scheduler`).
