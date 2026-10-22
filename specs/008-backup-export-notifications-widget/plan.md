# Implementation Plan: Backup, Export, Notifications, and Home Screen Widget (SET-02, SET-03, §12, T3.2–T3.4)

**Branch**: `008-backup-export-notifications-widget` | **Date**: 2026-10-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/008-backup-export-notifications-widget/spec.md`

## Summary

This feature delivers T3.2–T3.4 (`docs/spec.md` §10 SET-02, SET-03, §12, §14):
- backup and restore (local file, Google Drive, auto backup, encryption)
- CSV and PDF export
- notification upgrades (daily summary, reminder actions, backup failure, rescheduling)
- the 4×2 home screen widget

**Approach**:
- **Backup engine** (`lib/core/backup/`, R2–R9):
  - One file: JSON, a zip with receipts, or an AES-256-GCM envelope with a PBKDF2 key.
  - Modules own their data through a real `BackupSection` (Expense: 5 tables; Habit: 3) with
    explicit codecs, validation, and JSON upgrade steps.
  - Restore runs read-only phases, then stages receipts, then writes everything in one Drift
    transaction with deferred foreign keys, then swaps the receipt folder. Any failure before commit
    leaves data untouched.
  - Only preference settings are restored. Lock, account, and device state never are.
  - A cross-isolate lease keeps one run at a time.
- **Drive** (R10, R11):
  - `google_sign_in` 7 + `googleapis` in `appDataFolder` with the `drive.appdata` scope.
  - `appProperties.kind` separates manual from auto. Only auto backups rotate to 5 (Q1), and the
    user can delete manual ones.
  - Auto backup is a new core WorkManager task with an unmetered-network constraint, plus an app-open
    catch-up in case background auth fails.
  - The password is kept in secure storage (Q4).
- **Export** (R12–R15):
  - Modules provide `ExportDataset`s through a new `TrackerModule` hook.
  - `lib/features/settings/` has pure-Dart `CsvBuilder` (BOM, CRLF, RFC 4180) and `PdfReportBuilder`
    (`pdf`: summary, vector donut, table).
  - The `pdf` package cannot shape Devanagari or Gujarati, so Indic strings are rendered by a
    `ShapedTextRenderer` port (Flutter `TextPainter` → PNG).
  - `FeatureGate` checks access. `consumeOne` uses up a rewarded one-time unlock only after the file
    is written (Q2).
  - EXP-11 links to SET-03 with a period query.
- **Notifications** (R16–R18):
  - New `dailySummary` and `backup` channels, one-shot scheduling, and action buttons.
  - A background response entry point and the `ActionBroadcastReceiver`.
  - "Mark done" writes an idempotent `SetValue` for the day resolved from the reminder time; snooze
    is a one-shot.
  - The daily summary is a one-shot whose text is rebuilt from the glance on every data change.
- **Widget and system triggers** (R19–R21):
  - `GlanceRefresher` listens to Drift `tableUpdates` (shared across isolates) and writes a localized
    `glance.v1` payload with today and next-day blocks.
  - Kotlin `TodayWidgetProvider` renders `RemoteViews`.
  - A single top-level Dart callback (`home_widget` background intent) handles widget checks
    (no-undo, Q3), the midnight alarm, boot, and time zone changes.
- **Shared restore flow** (R22) for SET-02, the SYS-03 "Forgot PIN?" Drive restore, and SYS-01
  database-failure recovery.
- **Background entry points**: top-level `@pragma('vm:entry-point')` functions. Each builds its own
  `ProviderContainer` and so opens its own Drift connection, as the user specified. All date logic
  uses the injected `Clock`.
- **No Drift schema change** (v4): 13 new settings keys and one secure-storage key.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged); Kotlin 2.4 / AGP 9.1 for the
Android host

**Primary Dependencies**:
- Existing (spec §2): `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0,
  `drift` 2.35 + `drift_flutter` 0.3 (`shareAcrossIsolates`), `freezed` 4.0, `intl` 0.20,
  `clock` 1.1, `cryptography` 2.9, `flutter_secure_storage` 11.2, `flutter_local_notifications`
  22.3, `timezone` 0.11, `workmanager` 0.10, `share_plus` 13.3, `path_provider` 2.1.
- **New** (user-specified, research R1): `google_sign_in` ^7.2.0, `googleapis` ^17.0.0, `archive`
  ^4.5.2 (made direct), `csv` ^8.0.0, `pdf` ^3.13.1, `file_picker` ^13.1.0, `home_widget` ^0.10.0.
- **Also added**: `extension_google_sign_in_as_googleapis_auth` ^3.0.0, a flutter.dev bridge to the
  `DriveApi` auth client.
- **Not added**: `printing` (R1, see Complexity Tracking).

**Storage**:
- SQLite through Drift `AppDatabase`, **schema v4 unchanged**.
- New `settings` keys: `lastBackupLocation`, `lastBackupSizeBytes`, `lastAutoBackupAt`,
  `backupAccountEmail`, `autoBackupFrequency`, `autoBackupWifiOnly`, `backupEncrypt`,
  `backupIncludeReceipts`, `autoBackupFailures`, `autoBackupFailureNotified`, `backupLeaseUntil`,
  `showDataOnWidget`, `deviceTimeZoneId`. The existing `lastBackupAt` gets a setter.
- Secure storage gains `backup.password`.
- Backup files live in `<cache>/backups/`, exports in `<cache>/exports/`, and receipts in
  `<docs>/receipts/` (staged in `receipts.restore/`).
- Widget data goes to the `home_widget` shared preferences (`glance.v1`).

See [data-model.md](data-model.md).

**Testing**: `flutter_test` + `mocktail` + `integration_test`.
- **Unit tests** (pure): envelope (PBKDF2 vector, tampering), form detection, migrator, settings
  policy, section codecs and validators, `resolveReminderDay`, CSV bytes, PDF builder (fake
  renderer), glance and payload, daily summary text, period query codec, using
  `Clock.fixed`/`MutableClock`.
- **Data tests** (in-memory Drift via `makeRealContainer`):
  - round-trip checksums for every form
  - failure injection at each restore phase
  - the committed v4 fixtures
  - export datasets
  - `consumeOne`
  - `GlanceRefresher` with `tableUpdates`
  - reset clearing `backup.*`
- **Integration test**: `integration_test/backup_restore_test.dart` (spec §13).
- **Widget tests** with fakes and `NoAdsService`: SET-02, SET-03, the restore flow (three entries),
  SET-01 rows, the SET-05 toggle, EXP-11 action, splash recovery.
- **Golden tests**: only the shaped-text renderer image (Linux CI). There are no new constitution
  golden screens.
- **Manual device checks**: background Google auth, killed-app notification actions and widget
  clicks, midnight and time zone, exact alarms, Excel (quickstart §4).

**Target Platform**: Android API 24+ (iOS-ready Dart, not tested; the widget and system receivers
are Android-only)

**Project Type**: Mobile app (single Flutter project with an Android host)

**Performance Goals**:
- Backup of 10k transactions + 50 habits × 1 year: under 10 s; restore under 15 s (SC-004).
  Encoding, zipping, and crypto run in `Isolate.run`.
- A month's CSV of 1,000 rows in under 3 s, and PDF in under 10 s (SC-007).
- Widget check or "Mark done" in under 2 s with a cold background engine (SC-008).
- Widget refreshed within 5 s of a change, using a 750 ms debounce (SC-010).
- No added cold-start cost: `GlanceRefresher`, `registerBackgroundCallback`, and `armMidnight` start
  after the first frame, unawaited.

**Constraints**:
- Offline, except Drive (FR-054).
- No user data leaves the device except user-started or user-scheduled Drive backups and
  user-shared exports (Constitution III, FR-051).
- The password and PIN stay only in secure storage.
- No ads (the SET-02 banner, interstitial, and rewarded export unlock come with T4.x).
- ARB strings in en, hi, gu with placeholders. 200% font scale at 360 dp. Status never shown by
  color alone, including on the widget.

**Scale/Scope**:
- 2 screens built (SET-02, SET-03) and 1 shared restore flow with 3 entries.
- 5 screens changed: SET-01, SET-05, EXP-11, SYS-03 sheet, SYS-01.
- 1 home screen widget.
- 4 new core areas (`core/backup`, `core/export`, `core/widget`, `core/module/app_action`).
- 3 new optional `TrackerModule` hooks; `backupSection` becomes real.
- 2 module backup sections with 8 table codecs, and 2 export datasets.
- 2 background entry points; 1 new WorkManager task.
- Android: about 5 Kotlin files, 6 resource files, and the manifest.
- About 140 new ARB keys × 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs used; spec updated before code | ✅ `docs/spec.md` was updated on 2026-10-21 (Changes line). It covers Q1–Q4 in SET-02, SET-03, and §12; the backup file layout and restorable settings; SYS-01 recovery; the SET-05 widget toggle; §12 "Mark done" day rule, snooze, and summary refresh; §4 new settings keys and `backup.password`; and rewarded-ads references renamed from "feature 008" to T4.4. Code comments that say "feature 008" are renamed in tasks. Tests use `SET-02/03/05`, `SYS-01/03`, `EXP-11` |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; registry; one notifier per screen | ✅ The backup engine, export model, glance, and actions live in `core/`. Modules contribute only through `TrackerModule` hooks (`backupSection`, `exportDatasets`, `contributeGlance`, `handleAction`), each implemented in the module's own `data/` folder (user request). Export lives in `features/settings/` and imports no module (R14). The PDF and CSV builders are pure Dart in `settings/domain/export/`; the Flutter `TextPainter` renderer is in presentation behind a port. Plugins are confined to `data/` adapters, with new layering rules (R24). `lib/app/background_entry_points.dart` composes like `background_dispatcher.dart`. SET-02 and SET-03 each have one controller |
| III. Data integrity & privacy | int money; UTC ms; migrations; no egress; secrets | ✅ Money stays int minor units in backups; CSV converts to major units only in output. Timestamps are UTC ms and habit days are date keys. No schema change, so no migration; backup upgrade steps are tested against every schema version (R7). Data leaves the device only through user-initiated or user-scheduled Drive backups to the user's own `appDataFolder` and user-chosen exports and shares. Nothing goes to analytics or ads. The backup password is in secure storage only (Q4). The Google client ID comes from `--dart-define` and is never committed. Restore replaces all module rows in one transaction, as constitution 1.0.2 allows (second user-confirmed exception to soft delete). Exports, shares, and scheduled Drive backups are user-started or user-scheduled egress, also allowed by 1.0.2 |
| IV. Test-backed acceptance | ≥ 1 test per criterion; fakes + NoAdsService | ✅ The 4 copied ACs and every user story map to tests ([quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests)), including the required "backup serialization round-trip" unit tests and the §13 backup → erase → restore integration test. Clock-dependent logic (reminder day, glance, rotation, failure counter, file names) uses an injected `Clock` |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; ARB; 48 dp; 200%; never color only | ✅ Screens use `AppScaffold`, `SettingsSection`, `ChipSelector`, `PeriodSelector`, `ConfirmDialog`, `AppBottomSheet`, `ErrorState`, `EmptyState`, `SkeletonCard`, and `LockedFeatureOverlay`. SET-02 and SET-03 are fixed-control screens with no empty state (constitution 1.0.1; listed in Complexity Tracking). The SET-02 Drive list has its own empty and error states. The widget shows the budget percent and status as text, has 48 dp slots, content descriptions, and night colors. Heavy work runs in isolates (60 fps) |
| VI. Isolated monetization | ads only via AdService; none on lock/forms | ✅ By exclusion: no ad code. The SET-02 banner and post-backup interstitial, and "Watch an ad" for exports, come with T4.x. The locked export shows `LockedFeatureOverlay` with `onWatchAd: null`. Nothing fills those slots (§15.8) |
| VII. Locked stack, YAGNI | §2 packages only; new deps justified | ✅ Every added package is in §2 or the user's list, apart from the official `google_sign_in` → `googleapis` auth bridge (R1). `printing` was listed but is not needed (Complexity Tracking). No connectivity, glance, or HarfBuzz plugin is added |

**Result**: PASS. **After Phase 1 design**: PASS, with the items below justified in Complexity
Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/008-backup-export-notifications-widget/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R24
├── data-model.md        # Phase 1: settings keys, secure key, backup document/containers/envelope, Drive file, widget payload, notifications, export model, state machines
├── quickstart.md        # Phase 1: Google setup, gates, focused runs, manual walkthrough, AC→test map
├── contracts/
│   ├── services.md      # core/backup, core/export, core/widget, notifications, module hooks, background, reset, settings
│   ├── routes.md        # /more/backup, /more/export, period query codec, launch locations
│   ├── screens.md       # SET-02, restore flow, SET-03, SET-01/05, EXP-11, SYS-03, SYS-01, widget, notification copy
│   └── android.md       # manifest, Kotlin provider/receivers/alarm, resources
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
android/app/src/main/
  AndroidManifest.xml                         # ActionBroadcastReceiver, home_widget receiver/service, widget provider, system receivers
  kotlin/com/midexcode/daily/track/dailytrack/
    MainActivity.kt                           # + dailytrack/glance (armMidnight)
    widget/TodayWidgetProvider.kt             # NEW
    system/{GlanceAlarmScheduler,MidnightAlarmReceiver,SystemEventsReceiver}.kt   # NEW
  res/{layout/widget_today.xml,layout/widget_hidden.xml,xml/today_widget_info.xml,values*/widget_colors.xml,values*/strings.xml,drawable/ic_widget_*.xml}  # NEW
lib/
  app/
    background_entry_points.dart              # NEW notificationActionEntryPoint, widgetBackgroundEntryPoint
    background_dispatcher.dart                # + core tasks (core.autoBackup), refreshNow
    bootstrap.dart                            # widget launch location; start GlanceRefresher, registerBackgroundCallback, armMidnight
    app.dart                                  # actions stream → AppActionDispatcher; widget launches → deferral
    app_open_runner.dart                      # time zone change check, daily summary, auto backup catch-up
    production_overrides.dart                 # bind backup, drive, files, password, export, widget bridge providers
    router/{routes,app_router}.dart           # /more/backup, /more/export (root navigator)
    splash/splash_screen.dart                 # "Restore from backup"
  core/
    backup/
      backup_section.dart                     # NEW interface (replaces placeholder)
      domain/{backup_errors,backup_envelope,backup_archive,backup_document,backup_migrator,backup_settings_policy,restore_preview,drive_backup_store,local_backup_files,backup_password_store,backup_progress}.dart   # NEW, pure
      data/{backup_engine,backup_service,restore_service,backup_coordinator,google_drive_backup_store,google_auth,file_picker_local_backup_files,secure_backup_password_store,auto_backup_task}.dart   # NEW
      presentation/{restore_flow,backup_password_sheet}.dart   # NEW shared UI
      backup_providers.dart                   # NEW
    database/database_recovery.dart           # NEW
    export/{export_dataset,export_document,export_request}.dart   # NEW, pure
    widget/
      domain/{home_glance,glance_builder,widget_payload,home_widget_bridge}.dart   # NEW, pure
      data/home_widget_plugin_bridge.dart     # NEW (only home_widget importer besides entry points)
      glance_refresher.dart                   # NEW keep-alive provider
    module/{tracker_module,app_action}.dart   # hooks + AppAction/AppActionDispatcher
    notifications/{notification_service,local_notification_service,notification_providers,daily_summary_scheduler}.dart   # channels, one-shot, actions, exact request, summary
    background/{background_scheduler,workmanager_background_scheduler}.dart   # ensurePeriodic + constraints
    feature_gate/{domain/unlock_repository,data/drift_unlock_repository}.dart   # consumeOne
    reset/data/drift_app_reset_service.dart   # + backup.* keys, disconnect, cancel job, widget refresh
    settings/                                 # codec (+13 keys), AppSettings fields, repository setters
    share/file_sharer.dart                    # NEW FileSharer (share_plus)
    utils/period.dart                         # query codec
    l10n/ (via tool/l10n/phase0_strings.py)   # backup_*, export_*, notif_*, widget_*, restore_*
  features/
    settings/
      domain/export/{csv_builder,pdf_report_builder,export_use_case,shaped_text_renderer}.dart   # NEW, pure
      presentation/
        controllers/{backup,export}_controller.dart (+ states)   # NEW
        screens/{backup,export}_screen.dart   # NEW
        widgets/{last_backup_card,drive_backup_card,local_backup_card,drive_backup_list,export_filters}.dart   # NEW
        export/flutter_shaped_text_renderer.dart   # NEW
        screens/{settings,security}_screen.dart, widgets/notifications_section.dart   # rows
        controllers/{settings,security}_controller.dart
    expense/
      data/backup/{expense_backup_section,account_codec,category_codec,transaction_codec,budget_codec,recurring_rule_codec}.dart   # NEW
      data/export/transactions_export_dataset.dart   # NEW
      data/repositories/drift_transaction_repository.dart + domain repo   # listForExport
      expense_module.dart                     # backupSection, exportDatasets, contributeGlance
      presentation/screens/reports_screen.dart   # "Export this report"
    habit/
      data/backup/{habit_backup_section,habit_codec,habit_schedule_codec,habit_entry_codec}.dart   # NEW
      data/export/habits_export_dataset.dart  # NEW
      data/repositories/drift_habit_entry_repository.dart + domain repo   # entriesBetween
      data/reminders/local_habit_reminder_scheduler.dart   # actions, query payload, snooze cancel
      domain/reminders/resolve_reminder_day.dart   # NEW
      habit_module.dart                       # backupSection, exportDatasets, contributeGlance, handleAction
    lock/presentation/widgets/forgot_pin_sheet.dart   # Drive restore
test/
  fixtures/backup/v4_full.{json,zip,dtbk}     # NEW committed fixtures (password documented in test)
  core/{backup,export,widget,notifications,feature_gate,background,reset,settings}/
  features/{settings,expense/data/{backup,export},habit/{data/{backup,export},domain/reminders},lock}/
  app/{background_entry_points_test,widget_launch_test,splash/}.dart
  android/widget_manifest_test.dart
  a11y/backup_export_font_scale_test.dart
integration_test/backup_restore_test.dart     # NEW
```

**Structure Decision**: This is a single Flutter project with the existing feature-first layout and
the user's folder choices:
- the backup engine in `lib/core/backup/`
- module sections in each module's `data/backup/`
- export screens and pure builders in `lib/features/settings/`
- notifications in `lib/core/notifications/`
- the widget bridge in `lib/core/widget/`, with native code under `android/`

The export data model is in `lib/core/export/` so modules and settings can share it without
importing each other (Constitution II). Background entry points sit in `lib/app/`, next to the
existing WorkManager dispatcher, because they compose modules.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| Three new optional `TrackerModule` hooks (`exportDatasets`, `contributeGlance`, `handleAction`) | Export, the widget and daily summary, and notification and widget actions all need module data or writes. Settings and core may not import modules | Per-module code in settings or core breaks Constitution II and the layering scan. One generic hook would be an untyped grab bag |
| Indic text in PDFs is rendered as images through a Flutter `ShapedTextRenderer` (R12) | The `pdf` package does no OpenType shaping, so Hindi and Gujarati conjuncts would render wrong, failing the SET-03 AC | `pdf_text_shaper` (native or WASM HarfBuzz) is an unverified new dependency. `printing`'s `WidgetWrapper` needs widgets in the tree. The cost is that Indic PDF text is not selectable |
| `printing` not added although the user listed it | No requirement needs printing or preview. Output is shared through the existing `core/share` port, and the PDF is built in pure Dart | Adding an unused native plugin violates Constitution VII (YAGNI). It can be added when a "Print" action is specified |
| `extension_google_sign_in_as_googleapis_auth` added although not listed | `googleapis` needs a `googleapis_auth` `AuthClient`. This flutter.dev package is the supported bridge from `google_sign_in` 7 | A hand-written bearer client needs `http` as a direct dependency plus token refresh handling |
| Native Kotlin: widget provider, midnight alarm, boot and time zone receivers (R20, R21) | `home_widget` needs a native `AppWidgetProvider`. Midnight within a minute (SC-010), and time zone and reboot rescheduling (FR-041), need system broadcasts | WorkManager's 15-minute minimum misses midnight. Enqueueing the workmanager plugin's worker from Kotlin relies on private input keys |
| Widget and daily summary data precomputed for today and the next day | A scheduled notification's text and the widget's data are fixed when written. Without a next-day block, the widget would show yesterday's numbers until Dart runs after midnight | Alarm-only refresh can be delayed under Doze. A WorkManager job at the summary time can be 15+ minutes late |
| Auto backup has two paths: the background worker, and an app-open catch-up | Silent Google authorization in a background engine is not guaranteed on every device (R11) | A worker-only design could fail silently on some devices. App-open only misses SC-006 for users who rarely open the app |
| No empty state on SET-02 and SET-03 (constitution 1.0.1 allows this for fixed controls) | Both are fixed sets of controls. Their data either loads or fails | An invented empty state could never be reached and would be untestable. The SET-02 Drive list does have its own empty state |
