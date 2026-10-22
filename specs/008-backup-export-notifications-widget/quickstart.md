# Quickstart: Backup, Export, Notifications, and Home Screen Widget (T3.2–T3.4)

How to check that the feature works.
- Contracts: [services.md](contracts/services.md), [routes.md](contracts/routes.md),
  [screens.md](contracts/screens.md), [android.md](contracts/android.md).
- Data and file formats: [data-model.md](data-model.md).
- Decisions: [research.md](research.md).

## 1. Prerequisites

- Flutter 3.47.7 / Dart 3.13.5 (unchanged). Run `flutter pub get` after the packages from research R1
  are added.
- An Android emulator or device at API 24 or later, with Google Play services (for sign-in), and one
  at API 34 or later (exact-alarm permission is off by default there).
- **Google Drive setup** (R10, once per developer machine or CI secret store):
  1. Create a Google Cloud project, enable the **Google Drive API**, and configure the OAuth consent
     screen (scope `.../auth/drive.appdata`, plus test users while unverified).
  2. Create **Android** OAuth clients for `com.midexcode.daily.track.dailytrack.dev` and
     `com.midexcode.daily.track.dailytrack`, using the SHA-1 of the signing key
     (`./gradlew signingReport`).
  3. Create a **Web** OAuth client and pass its ID as `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>`.
     It is not committed; CI reads it from secrets.
- Without step 3, Drive features show "Google Drive isn't available in this build". Local backup,
  export, notifications, and the widget work as usual.

## 2. Quality gates (constitution)

```sh
dart run build_runner build --delete-conflicting-outputs
python tool/l10n/phase0_strings.py && flutter gen-l10n
flutter analyze                      # zero warnings
dart format --set-exit-if-changed .
flutter test --exclude-tags golden   # on Windows/macOS; full `flutter test` on Linux CI
flutter build apk --flavor dev --release --dart-define=GOOGLE_SERVER_CLIENT_ID=<id>   # R8 keep rules (contracts/android.md)
```

## 3. Focused test runs

```sh
flutter test test/core/backup/                 # envelope, archive detection, migrator, settings policy, engine round-trip, failure injection, coordinator lease
flutter test test/features/expense/data/backup/ test/features/habit/data/backup/   # section codecs + validators
flutter test test/core/export/ test/features/settings/domain/export/               # ExportDocument, CSV builder, PDF builder (fake renderer)
flutter test test/features/expense/data/export/ test/features/habit/data/export/   # datasets over in-memory Drift
flutter test test/core/notifications/          # one-shot, actions, channels, daily summary text + scheduler
flutter test test/features/habit/domain/reminders/   # resolveReminderDay, reminder actions
flutter test test/core/widget/                 # glance building, payload encoding, GlanceRefresher debounce
flutter test test/core/feature_gate/           # consumeOne
flutter test test/app/                         # background entry points (fake plugins), dispatcher core task, widget launch routing
flutter test test/features/settings/           # SET-01 rows, SET-02, SET-03, SET-05 toggle
flutter test test/features/lock/ test/app/splash/    # Forgot PIN restore, SYS-01 restore
flutter test test/android/                     # manifest receivers, widget info, channel
flutter test integration_test/backup_restore_test.dart -d <device>   # backup → erase → restore
```

## 4. Manual walkthrough (dev flavor, real device)

1. **Local backup round-trip**: add a few transactions (one with a receipt and a Gujarati note) and
   two habits with check-ins. In SET-02, turn on "Include receipt images", then "Save backup file"
   to Downloads. Erase all data (SET-01), finish onboarding, then go to SET-02 → "Restore from file"
   and pick the file. The summary shows the counts. Confirm: all data, the receipt, and preferences
   return; app lock stays as it was.
2. **Damaged or newer file**: pick a random `.json` → "This isn't a DailyTrack backup", nothing
   changes. Edit a backup's `schemaVersion` to 99 → "Update DailyTrack to restore this backup".
3. **Encryption**: turn on "Encrypt backup" with a password and save a backup (a `.dtbk` file).
   Restore with a wrong password → error, nothing changes. Restore with the right one → success.
4. **Drive**: connect Google, "Back up now" → the list shows a Manual backup. Set Auto backup to
   Daily with Wi-Fi only. Force-run the job:
   `adb shell cmd jobscheduler run -f com.midexcode.daily.track.dailytrack.dev <jobId>`, or the
   WorkManager diagnostics broadcast. Confirm an Auto entry appears **while the app is swiped away**
   (background auth, R11). Run it 6 times: only 5 Auto entries remain and the Manual one is kept.
   Delete one from the list.
5. **Failure notification**: turn on airplane mode with Wi-Fi only off and run the job 3 times → one
   "Automatic backup isn't working" notification. Tapping it opens SET-02 (through SYS-03 if
   locked). A 4th failure shows no new notification.
6. **Forgot PIN**: set a PIN, lock, then "Forgot PIN?" → "Restore from Google Drive backup" → pick →
   confirm. Data is restored, the lock is off, and Home opens.
7. **Export**: in the dev flavor, turn on "Unlock all features (debug)". SET-03 → Transactions, this
   month, CSV → share to Drive or Gmail. Open it in **Excel**: ₹ and Hindi/Gujarati notes are
   correct, and amounts sum. Then PDF → the summary, donut, and table are right, and Indic notes are
   shaped correctly (conjuncts such as "ક્ષ", "क्ष"). With the debug switch off: a lock overlay and
   no file. From EXP-11 (e.g. last month) → "Export this report" opens SET-03 with that month.
8. **Notification actions**: create a yes/no habit with a reminder 2 minutes ahead, then swipe the
   app away. On the reminder, tap "Mark done": the notification closes, the app does not open, and
   HAB-01 later shows it done. Next day, "Snooze 1 h" re-shows the reminder an hour later.
9. **Daily summary**: set the time 2 minutes ahead. The text matches today's spending and habits.
   Add an expense before it fires: the text updates.
10. **Exact alarms (API 34+)**: with exact alarms denied, SET-01 shows the delay note. "Allow exact
    timing" opens the system screen. After granting, reminders fire on time.
11. **Reboot and time zone**: reboot, then confirm reminders and the summary still fire. Change the
    device time zone by +3 h: a reminder set for 8:00 still fires at 8:00 local.
12. **Widget**: add the DailyTrack widget (4×2). It shows today's spend, the budget bar with a
    percent label, and up to 4 habits. Tap a check with the app swiped away: it fills within about
    2 s. Tap it again: nothing changes. Tap elsewhere: the app opens on Home (SYS-03 first if
    locked). Turn on app lock: the widget shows only "Open DailyTrack". Turn on "Show data on
    widget" in SET-05: data returns. Leave it over midnight: the new day shows within a minute. Set
    the language to ગુજરાતી: the widget text follows. With the app open on HAB-01, tap a widget
    check: HAB-01 and Home update within 5 s (cross-isolate updates, research R19).

## 5. Acceptance criteria → automated tests

| Criterion / scenario | Test |
| --- | --- |
| SET-02: Backup → erase → restore produces identical data (row counts and checksums) | `integration_test/backup_restore_test.dart` (device: seed → backup to file → `AppResetService.eraseAll` → restore → per-table count + SHA-256 of sorted canonical rows equal) + `test/core/backup/backup_round_trip_test.dart` (same in memory, for plain, zip, and encrypted forms) |
| SET-02: A failed restore leaves existing data untouched | `test/core/backup/restore_failure_test.dart` (fails in validate, upgrade, staging, mid-transaction after the first section's insert, and FK check; each time the checksums equal the pre-restore state and the staging folder is removed) |
| SET-02: Restoring a backup from an older schema version succeeds | `test/core/backup/restore_fixture_test.dart` (committed `test/fixtures/backup/v4_full.{json,zip,dtbk}` restore into the current schema) + `backup_migrator_test.dart` (a synthetic v4→v5 step) + `test/drift/app_database/migration_test.dart` "backup upgrade steps cover every schema version" |
| SET-03: Gujarati and Hindi notes render correctly in CSV and PDF | `test/features/settings/domain/export/csv_builder_test.dart` "BOM + exact UTF-8 bytes for Gujarati and Hindi notes" + `pdf_report_builder_test.dart` "Indic strings go to the renderer unchanged; Latin stays vector" + `flutter_shaped_text_renderer_test.dart` (golden, Linux) + manual §4.7 |
| US1 save/share, receipts on/off, summary, confirm/cancel, invalid/newer file, last backup | `backup_screen_test.dart`, `restore_flow_test.dart`, `backup_service_test.dart`, `expense_backup_section_test.dart` (`withoutAttachments`) |
| US2 connect/cancel, back up now, errors, list/empty, restore, disconnect, rotation, labels/delete | `backup_screen_test.dart` (fake `DriveBackupStore`), `google_drive_backup_store_test.dart` (mocked `DriveApi`: query, appProperties, rotation keeps manual) |
| US3 auto options, background run, Wi-Fi only, 3-failure notification once, reset | `auto_backup_task_test.dart`, `workmanager_background_scheduler_test.dart` (constraints, update policy), `settings_repository_test.dart` `recordAutoBackupResult`, `app_open_runner_test.dart` catch-up |
| US4 encrypt on/off/change, wrong password, unreadable saved password | `backup_envelope_test.dart`, `backup_password_sheet_test.dart`, `backup_service_test.dart` "never plain when encrypt on" |
| US5 layout, CSV/PDF content, habits export, filters, nothing to export, locked, debug, EXP-11 prefill, one-time unlock | `export_screen_test.dart`, `export_use_case_test.dart` (consume after file only), `transactions_export_dataset_test.dart`, `habits_export_dataset_test.dart`, `reports_screen_test.dart` "export this report", `period_query_test.dart`, `drift_unlock_repository_test.dart` `consumeOne` |
| US6 daily summary content/modules/time, actions, mark done day, snooze, reschedule triggers, exact/inexact | `daily_summary_scheduler_test.dart`, `resolve_reminder_day_test.dart`, `habit_module_actions_test.dart`, `local_habit_reminder_scheduler_test.dart` (actions, snooze cancel), `background_entry_points_test.dart`, `notifications_section_test.dart` (exact note) |
| US7 widget content, no budget, check/no-undo/count, open via lock, hidden mode, updates, midnight, module off | `glance_test.dart`, `widget_payload_test.dart`, `glance_refresher_test.dart`, `background_entry_points_test.dart` "widget check", `widget_launch_test.dart`, `security_screen_test.dart` "show data on widget", `test/android/widget_manifest_test.dart` |
| US8 forgot PIN restore, cancel keeps lockout, SYS-01 restore | `forgot_pin_sheet_test.dart`, `restore_flow_test.dart` (forgotPin), `database_recovery_test.dart`, `splash_screen_test.dart` |
| SC-004 performance | `test/core/backup/backup_perf_test.dart` (tag `slow`) |
| SC-012 200% / 360 dp, en/hi/gu, light/dark | `test/a11y/backup_export_font_scale_test.dart` (SET-02, SET-03, restore sheets) |
| Layering (Constitution II) | `no_hardcoded_style_test.dart` extended (research R24) |
