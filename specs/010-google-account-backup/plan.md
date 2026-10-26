# Implementation Plan: Google Account and Cloud Backup

**Branch**: `010-google-account-backup` | **Date**: 2026-10-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/010-google-account-backup/spec.md`

## Summary

Add optional Google sign-in as an account layer over feature 008's Drive backup. A new `lib/core/account/` holds `AccountService` (sign in, silent sign-in, sign out, account state stream), the device identity (an ID kept in Android's no-backup folder), and `AccountRestore`. `AccountRestore` is the single path that restores from Drive: it takes the safety copy, keeps backups encrypted after restoring an encrypted one, and updates the last known backup. `lib/core/backup/` is extended, not copied:

- backup metadata in the file and in Drive `appProperties`
- a change counter kept by SQLite triggers
- a pure background backup trigger (15 minutes, injected clock) that enqueues a WorkManager one-off task
- a pure conflict check, plus an empty-phone guard
- day-based rotation of auto backups

Screens ACC-01–ACC-03 and the Finish setting up sheet live in `lib/features/account/`. SYS-02, SET-01, and SET-02 get their new entry points, and Android Auto Backup is turned on for the database file only.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged); Kotlin 2.4 / AGP 9.1 for the Android host

**Primary Dependencies**:
- Existing (spec §2): `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0, `drift` 2.35, `freezed` 4.0, `intl` 0.20, `clock` 1.1, `uuid` 4.6, `path_provider` 2.1.
- Existing, reused for this feature: `google_sign_in` 7.2.0, `googleapis` 17.0.0 (Drive v3, `appDataFolder`), `extension_google_sign_in_as_googleapis_auth` 3.0.0, `workmanager` 0.10.10, `flutter_secure_storage` 11.2, `in_app_purchase` 3.3.1 (Restore purchase through `ProService`).
- **New**: none. The planning input named `device_info_plus`; the existing `DeviceInfoSource` channel already supplies manufacturer and model, so the plugin is not added (research R3, Constitution VII).

**Storage**:
- SQLite through Drift `AppDatabase`, **schema 4 → 5**: change-counter triggers only, no new table and no backed-up table change. The backup `schemaVersion` becomes 5 with no-op section upgrades.
- New non-restorable `settings` keys: `accountDisplayName`, `accountPhotoUrl`, `deviceId`, `dataChangeCounter`, `backedUpChangeCounter`, `lastBackgroundBackupAt`, `lastKnownDriveBackupAt`, `lastKnownDriveBackupDeviceId`, `autoBackupPausedByConflict`, `autoBackupPauseNotified`, `finishSetupPending`.
- Files: the device ID file in the no-backup folder; the safety copy in `<app support>/restore_safety/`.
- Drive: `appProperties` metadata on each backup.

See [data-model.md](data-model.md).

**Testing**: `flutter_test` + `mocktail` + `fake_async`.
- **Pure unit tests** (fixed or mutable `Clock`): `BackgroundBackupTrigger`, `ChangeCounter`, `BackupConflictPolicy` (other device, same device, older, no meta, empty phone over data), `AutoBackupRotation` (days, time zones, manual kept), `BackupMetaCodec` (limits, truncation, missing keys), `DeviceIdentityPolicy` (the R4 table), `SafetyCopyPolicy`, `BackupStatusPolicy`.
- **Service tests**: `AccountService` over a fake `AccountAuth`; `AccountRestore` and `BackupService.backupToDrive` over the existing fake Drive store, with a real engine on an in-memory database (`makeRealContainer`); `runAutoBackup` (pause notice once, unchanged skip, auth loss).
- **Data tests**: migration 4 → 5 and the trigger coverage test (data-model §2); the backup document with and without `meta`; Erase all data keeping the account and device ID.
- **Widget tests**: ACC-01, ACC-02, ACC-03, Finish setting up, SET-01 Account row, SET-02 Drive card and safety tile, SYS-02 Restore with Google. They use `pumpTestApp` with fakes and `NoAdsService`, and none opens a database. Every acceptance criterion copied into spec.md has a test named with its Screen ID.
- **Android**: a Dart test parses `backup_rules.xml` and `data_extraction_rules.xml`.
- **Device checks**: quickstart §4.

**Target Platform**: Android, min API 24, target the latest Play-required API (unchanged); iOS-ready code, untested.

**Project Type**: Mobile app (Flutter, single project).

**Performance Goals**:
- Going to the background adds no visible delay: one settings read and, at most, one WorkManager enqueue.
- ACC-01 shows local account details on first frame; status loads in the background.
- The conflict check is one Drive `files.list` call already made today.
- Restore of 10,000 transactions stays within feature 008's budget plus the safety copy write.

**Constraints**:
- Offline-first: no feature outside this one needs an account (FR-001).
- PIN, lockout, and backup password never leave the device (FR-047).
- Drive `appProperties` limit: 30 entries, 124 bytes each.
- Android Auto Backup limit: 25 MB. Only the database file is included.
- WorkManager may delay one-off work; the 15-minute rule is a minimum, not an exact schedule.

**Scale/Scope**: 3 new screens or sheets plus the Finish setting up sheet; changes to SYS-01, SYS-02, SET-01, SET-02, the app shell, the Android manifest, and the backup engine; about 40 new strings in 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | How |
| --- | --- | --- |
| I. Spec is the source of truth | Pass | Screen IDs ACC-01–03, SYS-02, SET-01, SET-02 are used throughout. `docs/spec.md` was updated first to match clarifications Q1–Q3 and the research decisions (rotation, safety copy, encryption after restore, change counter keys, empty-phone guard, Android backup rules): task T002, done 2026-10-23. |
| II. Layered, feature-first | Pass | Account and restore logic in `lib/core/account/` and `lib/core/backup/`; screens in `lib/features/account/`; SYS-02 and SET-02 reach ACC-02 only through `lib/app/` glue (R18). Pure policies in `domain/`. One Notifier per screen. |
| III. Data integrity and privacy | Pass (constitution 1.1.0) | Money, dates, and soft delete untouched. Restore stays one transaction. PIN, lockout, and password stay in secure storage and never leave the device. Android device backup is allowed by the 1.1.0 amendment (task T001), and the design follows its limits: an include list with only the database file, with secure storage and receipts excluded (R14). |
| IV. Test-backed acceptance | Pass | Every copied criterion gets a named test; pure logic gets unit tests with an injected clock; migration test for schema 5; widget tests use fakes and `NoAdsService`. |
| V. Offline-first, fast, accessible | Pass | Signing in is never required; ACC screens implement loading, error, and content states (signed out is ACC-01's empty state; ACC-02, ACC-03, and Finish setting up are fixed-control sheets and omit an empty state, as allowed when the plan says so). Tokens and shared widgets only; status never by color alone; ARB strings in en/hi/gu; §15.10 checklist per screen. |
| VI. Respectful monetization | Pass | No ads on ACC screens, the SYS-02 button, or the sheets; no interstitial after ACC-01 "Back up now"; background backups never trigger ads. |
| VII. Simplicity and locked stack | Pass | No new packages (R3, R17). No new state, routing, or database packages. `device_info_plus` from the planning input is deliberately not added. |

**Post-design re-check (after Phase 1)**: all gates pass. The design adds no package and no feature-to-feature import. The Constitution III gate was cleared by the 1.1.0 amendment (T001, with `docs/CLAUDE.md`) and the Constitution I gate by updating `docs/spec.md` (T002).

## Project Structure

### Documentation (this feature)

```text
specs/010-google-account-backup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── services.md
│   ├── screens.md
│   ├── routes.md
│   └── android.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/
  app/
    app.dart                         # onHide → BackgroundBackupScheduler; Finish setting up on Home
    bootstrap.dart                   # SYS-01: device identity, Android-restore steps, silent sign-in, safety copy expiry
    auto_backup_task.dart            # runAutoBackup: backupIfChanged, pause notice, auth loss
    background_dispatcher.dart       # + core.backgroundBackup → runAutoBackup
    production_overrides.dart        # accountAuth, accountUi bindings; Erase all data keeps the account
    router/routes.dart, app_router.dart   # /more/account
  core/
    account/                         # NEW
      account_providers.dart
      account_service.dart
      account_restore.dart
      device_identity_service.dart
      domain/  account.dart, account_auth.dart, device_identity.dart
      data/    no_backup_device_id_store.dart
    backup/
      backup_section.dart            # + tables, hasUserData
      backup_service.dart            # backupToDrive(conflict:), backupIfChanged, rotation, meta
      background_backup_scheduler.dart   # NEW
      data/  google_auth.dart (profile, signOut; implements AccountAuth),
             google_drive_backup_store.dart (meta properties, deleteAll),
             backup_engine.dart (meta, counter snapshot, hasUserData),
             safety_copy_store.dart (NEW)
      domain/ backup_meta.dart, change_counter.dart, background_backup_trigger.dart,
              backup_conflict_policy.dart, auto_backup_rotation.dart, safety_copy_policy.dart,
              backup_status_policy.dart (all NEW, pure); backup_document.dart (+ meta);
              drive_backup_store.dart (+ meta, deleteAll, − connect/disconnect/pruneAuto)
    background/ background_scheduler.dart, workmanager_background_scheduler.dart  # + enqueueOnce
    database/  app_database.dart     # schema 5 + triggers
    settings/  domain/app_settings.dart, data/settings_codec.dart, settings_repository*.dart  # new keys
    support/   network_state_source.dart (NEW, channel)
  features/
    account/                         # NEW
      presentation/
        controllers/ account_controller.dart, sign_out_controller.dart, restore_choice_controller.dart
        screens/     account_screen.dart                 # ACC-01
        widgets/     restore_choice_sheet.dart (ACC-02), sign_out_sheet.dart (ACC-03),
                     finish_setup_sheet.dart, backup_status_line.dart
    onboarding/presentation/ widgets/language_step.dart, controllers/onboarding_controller.dart  # Restore with Google
    settings/presentation/   widgets/account_row.dart (NEW), screens/backup_screen.dart,
                             controllers/backup_controller.dart                               # SET-01, SET-02
    expense/data/backup/expense_backup_section.dart      # tables, hasUserData
    habit/data/backup/habit_backup_section.dart          # tables, hasUserData
android/app/src/main/
  AndroidManifest.xml                # allowBackup, rules, ACCESS_NETWORK_STATE
  res/xml/backup_rules.xml, data_extraction_rules.xml     # NEW
  kotlin/.../MainActivity.kt         # getNoBackupDir, getNetworkState
tool/l10n/phase0_strings.py          # account strings (en, hi, gu)
test/
  core/account/, core/backup/domain/, core/database/, features/account/,
  features/onboarding/, features/settings/, android/
docs/spec.md, docs/CLAUDE.md, .specify/memory/constitution.md   # updated first (gates I and III)
```

**Structure Decision**: The single Flutter project with feature-first layout, as in features 001–009. As the planning input asked, `AccountService` goes in `lib/core/account/` and the screens in `lib/features/account/`. Drive backup and restore stay in `lib/core/backup/`, extended in place.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --- | --- | --- |
| Schema 5 adds SQLite triggers that new modules must extend | Writes come from four isolates and must be counted whether or not the app is open (R5) | A Drift `tableUpdates` listener misses writes made while the app is closed and can't tell restorable settings from device state; hashing the full export on every background reads every row. A test fails when a module's table lacks triggers. |
