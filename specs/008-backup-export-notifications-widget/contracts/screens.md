# Contract: Screens and UI Changes

Every screen uses `AppScaffold`, `AppTokens`, and shared widgets only. Each has one controller with
an immutable state that has explicit loading, data, and error (Constitution II and V). It follows
§15. No ads appear in this feature.

## SET-02 Backup and restore: `lib/features/settings/presentation/screens/backup_screen.dart`

**Controller**: `BackupController` → `BackupState`, with these fields:
- `lastBackup` (at, location, size)?
- `account` (email)?
- `autoFrequency`, `wifiOnly`, `encrypt`, `includeReceipts`
- `drive`: `AsyncValue<List<DriveBackupEntry>>`
- `busy`: `BackupBusyKind?` (backingUp, uploading, restoring, connecting) with progress 0–1
- `message`: a one-shot snackbar event

**Layout**, top to bottom:

1. **Last backup** card: "Last backup" with a full date-time, location ("This device" / "Google
   Drive"), and size. Otherwise "No backup yet".
2. **Google Drive** card:
   - Disconnected: an explanation plus "Connect Google account".
   - Connected: email, "Back up now" (primary), the Auto backup choice row (Off, Daily, Weekly →
     `showChoiceSheet`), the "Wi-Fi only" switch (disabled when Off), and "Disconnect" (text
     button, `ConfirmDialog`).
3. **Local backup** card: "Save backup file", which shows a snackbar with "Share" on success, and
   "Restore from file".
4. **Options**:
   - "Encrypt backup" switch. Turning it on opens `showBackupPasswordSheet` (password twice, a
     warning, and "Save password"); it stays off if cancelled. When on, "Change password" appears.
   - "Include receipt images" switch.
5. **Restore from Google Drive** (connected only): a list of `DriveBackupEntry` rows.
   - Each row shows the date-time, size, a Manual/Auto label chip, and the device.
   - Tapping a row runs `showRestoreFlow`. An overflow menu offers Delete, behind `ConfirmDialog`.
   - States: skeleton while loading, an `EmptyState`-style text ("No backups in Drive yet"), and an
     `ErrorState` with "Try again" (offline or auth, the latter with "Reconnect Google account").

**States**:
- Loading: skeleton cards.
- Error (settings stream): `ErrorState`.
- Empty: SET-02 is a fixed-control screen, so it has no empty state (constitution V). Only the
  Drive list has one.
- Busy: a progress row in the affected card. Other actions are disabled, but the screen does not
  block and Back works.

**Only one primary action is visible**: "Back up now" when connected, otherwise "Save backup file".

## Restore flow (shared): `lib/core/backup/presentation/restore_flow.dart`

The steps, as sheets and dialogs over the current screen:
1. Source: file or Drive. SYS-03 skips this step and uses Drive.
2. For Drive: connect if needed, then a list with dates (`AppBottomSheet`).
3. Password prompt if the backup is encrypted. "Wrong password or damaged file" stays in the sheet
   so the user can retry.
4. Summary: date, app version, per-module counts, "Includes receipt images", and skipped modules.
5. `ConfirmDialog`: title "Replace current data?", the consequence text stating that all current
   data is replaced, and a destructive "Replace data" action.
6. A progress dialog (not dismissible), then a success snackbar or an `ErrorState`-styled dialog
   with "Try again" and the plain-language failure text.

## SET-03 Export data: `lib/features/settings/presentation/screens/export_screen.dart`

**Controller**: `ExportController(initial: ExportArgs?)` → `ExportState`, with these fields:
- `datasets`: from the enabled modules' `exportDatasets()`
- `datasetId`
- `period`: default `MonthPeriod(now)`, or from the route query
- `format`: CSV or PDF
- `filters`: `Map<id, Set<String>>`
- `filterOptions`: `AsyncValue`
- `unlocked`: a live `FeatureGate.watch` result for the chosen format
- `running`, `outcome`

**Layout**:
1. Data type: `ChipSelector` (Transactions, Habits; only enabled modules).
2. Period: `PeriodSelector` with `PeriodPickerSheet`. Week, Month, Year, and Custom are all
   available, since export is not limited by free report periods.
3. Format: `ChipSelector` (CSV, PDF).
4. Filters (Transactions only): "Accounts" and "Categories" rows opening multi-select sheets, each
   showing "All" or "3 selected".
5. A sticky primary "Export" button. When locked, the area shows
   `LockedFeatureOverlay(onWatchAd: null, onGetPro: null, message: export_lockedMessage)` with a
   lock icon and text, and the button is disabled.

**Outcomes**:
- Nothing to export → a snackbar "Nothing to export for this period".
- Failure → `ErrorState` text in a dialog with "Try again".
- Ready → the share sheet. Afterwards the screen keeps its choices.

A progress indicator appears on the button while running. Indic text rendering shows a determinate
progress for large PDFs.

**States**: loading (skeleton) and error (`ErrorState`). No empty state: this is a fixed-control
form (constitution V), and "nothing to export" is an outcome, not a screen state.

## SET-01 changes: `settings_screen.dart`, `notifications_section.dart`

- **Data**: "Backup and restore" (subtitle "Last backup: {relative date}" or "Not backed up yet") →
  `/more/backup`; "Export data" → `/more/export`; then the existing "Erase all data".
- **Notifications**: when `canScheduleExact()` is false and notifications are on, a note row reads
  "Reminders may arrive a few minutes late" with an "Allow exact timing" action
  (`requestExactAlarms()`). Changing the daily summary time calls
  `DailySummaryScheduler.reschedule()`.

## SET-05 change: `security_screen.dart`

- New `security_show_widget_data` `SwitchListTile`: "Show data on widget", with the helper "Shows
  amounts and habit names on your home screen".
- It is enabled only while app lock is on. When the lock is off, it shows disabled with "Needs app
  lock", like the existing rows.

## EXP-11 change: `reports_screen.dart`

- An app bar action (icon `ios_share` / Material Symbols "file_export", with the semantic label
  "Export this report") → `context.push(Routes.exportPath(period: state.period, dataset:
  'transactions'))`.
- Shown whenever the module is enabled. The report's own locked state does not hide it.

## SYS-03 change: `forgot_pin_sheet.dart`

The sheet offers "Restore from Google Drive backup" (primary) above "Erase all data"
(error-styled), with Cancel. Restoring runs `showRestoreFlow(entry: forgotPin)`. On success: lock
reset, then Home. With no backups: the message plus an "Erase all data" action.

## SYS-01 change: `splash_screen.dart`

`ErrorState(... secondaryAction: TextButton('Restore from backup'))` →
`showRestoreFlow(entry: databaseFailure)`.

## Home screen widget (native, see contracts/android.md)

| Mode | Shows |
| --- | --- |
| `data` | "Spent today" + amount; budget bar with "62% used · ₹6,200 of ₹10,000" or "No budget set"; up to 4 habit rows (check circle or "12 / 20" + "+" target, name ellipsized) |
| `hidden` | App icon + "Open DailyTrack" |

Every tappable slot is at least 48 dp and has a content description from the payload's `a11y`
strings.

## Notifications (copy, ARB keys under `notif_`)

| Item | Text (en) |
| --- | --- |
| Daily summary title | "Today in DailyTrack" |
| Daily summary body | "Spent {amount} today · {done}/{total} habits done" · "Spent {amount} today" · "{done}/{total} habits done" |
| Habit actions | "Mark done", "Snooze 1 h" |
| Backup failing | title "Automatic backup isn't working", body "Your last 3 backups to Google Drive failed. Tap to check." |
