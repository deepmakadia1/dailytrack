# Feature Specification: Backup, Export, Notifications, and Home Screen Widget (SET-02, SET-03, §12)

**Feature Branch**: `008-backup-export-notifications-widget`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "Feature: Backup, export, notifications, and home screen widget. Implement tasks T3.2 to T3.4 from docs/spec.md. Scope: Backup format and engine in lib/core/backup/: implement backupSection() export and import in ExpenseModule and HabitModule, a backup file with schemaVersion, appVersion, createdAt, modules, and settings, optional receipt images, optional password encryption (AES-GCM with a PBKDF2-derived key), validation, migration of older schema versions, and restore in a single DB transaction. SET-02 Backup and restore: last backup info, local save and restore via the system file picker / share sheet, Google Drive backup in the appDataFolder (connect, back up now, list and restore backups), auto backup (Off, Daily, Weekly, Wi-Fi only) through workmanager keeping the last 5 Drive backups, and the encrypt toggle. 'Forgot PIN?' on SYS-03: add 'Restore from Google Drive backup' next to erase. SET-03 Export: transactions and habits, period picker, CSV (UTF-8 with BOM) and PDF (bundled Noto fonts for Devanagari and Gujarati, summary, category donut, table), filters, share sheet output. Each export needs an exportCsv/exportPdf unlock through FeatureGate; the dev unlock switch grants them. 'Export this report' in EXP-11 opens SET-03 with the period prefilled. Show the Backup and Export rows in SET-01. Notifications (§12): daily summary at the user's time, habit reminder action buttons 'Mark done' (yes/no habits) and 'Snooze 1 h' handled without opening the app, backup failure after 3 failed auto backups, and rescheduling all notifications on app start, after restore, after timezone change, and after reboot. Exact alarms only if SCHEDULE_EXACT_ALARM is granted, otherwise inexact. Home screen widget (4×2) with home_widget: today's spend, month budget bar, up to 4 habit check buttons working through a background callback, tap elsewhere opens the app (through SYS-03 if locked). When the app lock is on, show only 'Open DailyTrack' unless 'Show data on widget' is enabled in SET-05. Update after relevant DB writes and at midnight. Out of scope (later features): rewarded ads for export unlocks and the interstitial after manual backup (feature 008), and all other ads. Copy the acceptance criteria for SET-02 and SET-03 exactly from the spec, except criteria about ads. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §3 (`TrackerModule.backupSection()`), §4 (data model, settings), §6 SYS-01 (restore on database failure), SYS-03 ("Forgot PIN?"), §8 EXP-11 ("Export this report"), §10 SET-01, SET-02, SET-03, SET-05, §12 (notifications, home widget, localization, accessibility), §13 (data safety, performance), §14 T3.2–T3.4, §15 UI/UX guidelines.

**Numbering note**: The spec directory is `008` because `007` is taken by settings, themes, and app lock. Where `docs/spec.md` and the input above say rewarded ads arrive in "feature 008", that means the later rewarded-ads feature (T4.4). Those references need updating in `docs/spec.md` when this feature's plan updates the spec.

## Clarifications

### Session 2026-10-21

- Q: When a new Google Drive backup pushes the total past 5, should older manual backups be deleted too, or only older automatic ones? → A: Only auto backups are rotated (the 5 newest auto backups are kept); manual backups are kept until the user deletes them from the Drive backup list, which offers a delete action.
- Q: Does an export unlock last for one export only, or for a period of time? → A: One export: a one-time CSV or PDF unlock is used up only when a file of that format is created successfully; a failed, cancelled, or "nothing to export" attempt keeps it. Pro and the dev debug switch are never used up.
- Q: On the home screen widget, what should tapping the check of a yes/no habit that's already done do? → A: Nothing; the check stays done, and unchecking is done in the app (HAB-01), where undo is available.
- Q: Should the backup password be saved on the phone so automatic backups can stay encrypted, or should the user type it every time? → A: Save it only in the phone's secure storage; manual and auto backups encrypt without asking, and Erase all data removes it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Save a backup to the phone and restore it (Priority: P1)

A user wants to protect years of expense and habit records against a lost or reset phone. In Backup and restore (SET-02) they tap "Save backup file", pick a place with the system file picker, and get one file with all their transactions, accounts, categories, budgets, recurring entries, habits, check-ins, and preferences. They can choose to include receipt images. Later, on a fresh install or after erasing data, they tap "Restore from file" and pick that file. The app checks the file, shows what is in it ("1,240 transactions, 8 habits"), asks "Replace current data?", and then replaces everything at once. If anything goes wrong, their current data stays exactly as it was.

**Why this priority**: Backup is the only protection against data loss for an offline-first app, and the local file path works without a Google account or internet. The backup engine built here also powers Drive backup, auto backup, and restore from "Forgot PIN?".

**Independent Test**: Seed data, save a backup file, erase all data, restore the file, and compare row counts and checksums of every table with the original.

**Acceptance Scenarios**:

1. **Given** SET-02, **When** the user taps "Save backup file", **Then** the system file picker opens with the suggested name `dailytrack_backup_<yyyyMMdd_HHmm>` and, after they choose a place, a success message confirms the save and offers "Share" to send the same file through the share sheet.
2. **Given** "Include receipt images" is on and some transactions have receipts, **When** the user saves a backup, **Then** the receipt images are packed into the same backup file; **When** it is off, **Then** the backup holds no images and restored transactions keep no receipt.
3. **Given** a valid backup file, **When** the user taps "Restore from file" and picks it, **Then** a summary shows the backup date, app version, and counts per module (e.g. "1,240 transactions, 8 habits"), and a confirmation dialog states that all current data will be replaced.
4. **Given** the confirmation dialog, **When** the user confirms, **Then** all module data and restorable preferences are replaced in one step, notifications are rescheduled, the home screen widget is refreshed, and a success message is shown; **When** they cancel, **Then** nothing changes.
5. **Given** a file that is not a DailyTrack backup, is damaged, or was made by a newer app version, **When** the user picks it, **Then** a plain-language error explains the problem and offers a next step, and no data is changed.
6. **Given** a backup made by an older app version with an older data format, **When** the user restores it, **Then** it is upgraded and restored successfully.
7. **Given** a restore fails part-way, **Then** every table holds exactly what it held before the restore started.
8. **Given** a successful backup, **Then** the "Last backup" area shows its date, time, location ("This device" or "Google Drive"), and size.

**SET-02 acceptance criteria** (copied from docs/spec.md; the ad rules are excluded):

- [ ] Backup → erase → restore produces identical data (verified by an integration test comparing row counts and checksums).
- [ ] A failed restore leaves existing data untouched.
- [ ] Restoring a backup from an older schema version succeeds.

---

### User Story 2 - Back up to Google Drive and restore from it (Priority: P1)

A user taps "Connect Google account" in SET-02 and signs in, granting access only to the app's private Drive folder. They tap "Back up now" and the backup is stored in their Google Drive, invisible in their normal Drive files. On a new phone, they connect the same account, see a list of their Drive backups with dates, pick one, and restore it.

**Why this priority**: Drive backup survives losing the phone itself, which a local file on the same phone does not. It is the only path by which data may leave the device, and only when the user starts it.

**Independent Test**: Connect a Google account, back up now, install on a second device (or erase), connect the same account, pick the backup from the list, and restore it.

**Acceptance Scenarios**:

1. **Given** no account is connected, **Then** the Drive card shows "Connect Google account" and explains that backups are stored privately in the user's Drive; "Back up now", Auto backup, and the Drive backup list are not available yet.
2. **Given** the user taps "Connect Google account", **Then** Google sign-in asks only for access to the app's own Drive folder; **When** they cancel or decline, **Then** the card stays disconnected with no error beyond a short note.
3. **Given** a connected account, **Then** the card shows the account email, "Back up now", the Auto backup selector, and "Disconnect".
4. **Given** a connected account and internet, **When** the user taps "Back up now", **Then** progress is shown, the backup is uploaded, "Last backup" updates, and a success message is shown.
5. **Given** no internet or a Drive error, **When** the user taps "Back up now", **Then** a plain-language error offers "Try again" and the previous "Last backup" stays unchanged.
6. **Given** a connected account, **Then** "Restore from Google Drive" lists the account's DailyTrack backups, newest first, each with date, time, and size; **When** there are none, **Then** an empty state says so.
7. **Given** the user picks a Drive backup, **Then** the same summary, confirmation, and restore as a local file follow (User Story 1).
8. **Given** a connected account, **When** the user taps "Disconnect", **Then** the account is signed out, auto backup turns Off, and backups already in Drive are kept.
9. **Given** a successful auto backup, **Then** only the 5 newest auto backups are kept in Drive; older auto backups are deleted, and manual backups are never deleted automatically.
10. **Given** the Drive backup list, **Then** each backup is labeled Manual or Auto; **When** the user deletes a backup from the list and confirms, **Then** it is removed from Drive and the list.

---

### User Story 3 - Back up automatically (Priority: P2)

A connected user sets Auto backup to Daily and turns on "Wi-Fi only". From then on the app backs up to Drive in the background about once a day, only when on Wi-Fi, without opening the app. If auto backup fails 3 times in a row, a notification tells them so and opens SET-02 when tapped.

**Why this priority**: Most users forget manual backups; auto backup makes protection real. It depends on Drive backup (Story 2).

**Independent Test**: With an account connected, set Auto backup to Daily with Wi-Fi only, trigger the background job on Wi-Fi and on mobile data, and confirm a backup is made only on Wi-Fi; make 3 runs fail and confirm one failure notification.

**Acceptance Scenarios**:

1. **Given** a connected account, **Then** Auto backup offers Off (default), Daily, and Weekly, plus a "Wi-Fi only" toggle (default on).
2. **Given** Auto backup is Daily, **Then** a background backup runs about once every 24 hours, even when the app is closed, and survives device restart.
3. **Given** "Wi-Fi only" is on, **When** the device is on mobile data only, **Then** auto backup waits until Wi-Fi is available and does not count as a failure.
4. **Given** auto backup runs, **Then** it uses the same backup content and encryption setting as a manual backup and keeps only the 5 newest auto backups in Drive.
5. **Given** 3 auto backups in a row have failed, **Then** one "Backup" notification says that automatic backup is failing; tapping it opens SET-02; no further failure notification is shown until a backup succeeds and then fails 3 times in a row again.
6. **Given** a backup (auto or manual) succeeds, **Then** the consecutive-failure count resets.
7. **Given** Auto backup is set to Off or the account is disconnected, **Then** no background backup runs.

---

### User Story 4 - Protect backups with a password (Priority: P2)

A user who worries about their Drive or a shared file turns on "Encrypt backup", sets a password, and reads the warning that a lost password cannot be recovered. All later backups, manual and automatic, are encrypted. When they restore an encrypted backup, the app asks for the password.

**Why this priority**: Financial data in a file or cloud folder is sensitive; encryption gives users control. Backup works without it.

**Independent Test**: Turn on encryption with a password, make a backup, confirm the file content is unreadable without the password, restore with the wrong password (rejected, no change), then restore with the right password (success).

**Acceptance Scenarios**:

1. **Given** the user turns on "Encrypt backup", **Then** a sheet asks for a password and its confirmation and warns that a lost password cannot be recovered; the toggle turns on only after matching passwords are saved.
2. **Given** encryption is on, **Then** every new backup (local, Drive, and auto) is encrypted with the password; the file content cannot be read without it.
3. **Given** an encrypted backup, **When** the user restores it, **Then** the app asks for the password before showing the summary; a wrong password shows "Wrong password" and changes nothing.
4. **Given** encryption is on, **When** the user turns it off, **Then** future backups are not encrypted; existing encrypted backups still need their password.
5. **Given** encryption is on, **When** the user changes the password, **Then** only future backups use the new password.

---

### User Story 5 - Export transactions and habits as CSV or PDF (Priority: P2)

A user needs their spending for taxes or to share with family. In Export data (SET-03) they choose Transactions, a period, CSV or PDF, and optionally some accounts and categories, then tap "Export". A spreadsheet-ready CSV or a printable PDF report with a summary, a category donut chart, and a transaction table opens in the share sheet. Hindi and Gujarati notes appear correctly in both. They can do the same for habits. From Reports (EXP-11), "Export this report" opens SET-03 with the report's period already chosen.

**Why this priority**: Export is a listed MVP feature and a common reason users trust an expense app, but it does not protect or change data.

**Independent Test**: Seed transactions with Hindi and Gujarati notes, export a month as CSV and as PDF, open the CSV in a spreadsheet app and the PDF in a viewer, and confirm the rows, totals, and scripts are correct.

**Acceptance Scenarios**:

1. **Given** SET-03, **Then** it shows Data type (Transactions, Habits), a period picker (default: current month), Format (CSV, PDF), filters for accounts and categories (Transactions only), and one "Export" button.
2. **Given** Transactions, a period, and CSV, **When** the user exports, **Then** a CSV file with a byte-order mark and the columns Date, Time, Type, Category, Account, Payment mode, Amount, Note, one row per transaction in the period and filters, opens in the share sheet.
3. **Given** Transactions and PDF, **When** the user exports, **Then** the PDF starts with a summary (period, total income, total expense, net), a category donut chart of expenses, and then a transaction table, with Hindi and Gujarati text rendered correctly.
4. **Given** Habits and CSV, **When** the user exports, **Then** the CSV has one row per habit per day with an entry in the period (Date, Habit, Value, Target, Unit, Status, Note); **Given** PDF, **Then** it shows a summary (period, habits, completion rate per habit) and a table of check-ins.
5. **Given** filters for accounts or categories, **Then** only matching transactions are exported and the PDF summary states the filters used.
6. **Given** a period and filters with no matching records, **When** the user taps "Export", **Then** a message says there is nothing to export and no file is made.
7. **Given** the matching export format is locked, **Then** the Export button shows a lock and tapping it shows the locked-feature overlay with "Get Pro" disabled and no "Watch an ad" action; no file is made.
8. **Given** the dev flavor with "Unlock all features (debug)" on, **Then** both CSV and PDF export work without limits.
9. **Given** EXP-11 showing a period, **When** the user taps "Export this report", **Then** SET-03 opens with Transactions and that exact period selected.
10. **Given** the user leaves the share sheet without sharing, **Then** nothing else happens and SET-03 keeps its choices.
11. **Given** CSV export is available only through a one-time unlock, **When** a CSV file is created, **Then** the unlock is used up and the next CSV export is locked again; **When** the export fails or there is nothing to export, **Then** the unlock is kept.

**SET-03 acceptance criteria** (copied from docs/spec.md; the ad criterion is excluded):

- [ ] Gujarati and Hindi notes render correctly in both CSV (opened in Excel) and PDF.

---

### User Story 6 - Helpful notifications that work without opening the app (Priority: P2)

At the time the user chose (default 9:00 PM) they get a daily summary: "Spent ₹X today · 3/5 habits done". When a habit reminder arrives, they tap "Mark done" right in the notification for a yes/no habit, or "Snooze 1 h" to be reminded later, without opening the app. Reminders keep working after a phone restart, a time zone change, or a restore.

**Why this priority**: Notifications drive the daily logging habit the app depends on, and action buttons make check-ins one tap. Basic habit reminders and budget alerts already work, so this extends them.

**Independent Test**: Set the daily summary time a few minutes ahead and confirm the notification text; trigger a habit reminder and use "Mark done" and "Snooze 1 h" with the app closed; restart the device and confirm reminders still fire.

**Acceptance Scenarios**:

1. **Given** notifications are on, **When** the daily summary time arrives, **Then** a "Daily summary" notification shows today's spending and today's habit progress; tapping it opens Home (through SYS-03 if locked).
2. **Given** a module is disabled, **Then** the daily summary leaves out that module's part; **Given** the master notification toggle is off, **Then** no daily summary is shown.
3. **Given** the user changes the daily summary time in SET-01, **Then** the next daily summary arrives at the new time.
4. **Given** a reminder for a yes/no habit not yet done today, **Then** it shows "Mark done" and "Snooze 1 h"; a reminder for a count habit shows only "Snooze 1 h".
5. **Given** the app is closed, **When** the user taps "Mark done", **Then** the habit is marked done for the reminder's day, its streak updates, the notification is dismissed, the widget refreshes, and the app does not open.
6. **Given** the user taps "Snooze 1 h", **Then** the notification is dismissed and the same reminder is shown again about 1 hour later, unless the habit is done by then and "Remind me only if not done yet" is on.
7. **Given** the device restarts, the time zone changes, a backup is restored, or the app starts, **Then** all habit reminders, the daily summary, and other scheduled notifications are rescheduled at the correct local times.
8. **Given** the user has allowed exact alarms, **Then** notifications fire at their exact times; **Given** they have not, **Then** notifications are still scheduled, may arrive a few minutes late, and SET-01 notes the possible delay with a way to allow exact timing.

---

### User Story 7 - See today at a glance on the home screen (Priority: P3)

A user adds the DailyTrack widget (4×2) to their home screen. It shows today's spending, a bar for this month's budget, and up to 4 of today's habits with check buttons. Tapping a check marks the habit done right from the home screen. Tapping anywhere else opens the app, through the PIN screen if the lock is on. If app lock is on, the widget shows only "Open DailyTrack" unless they turn on "Show data on widget" in Security (SET-05).

**Why this priority**: A widget is a convenience that brings users back daily, but every piece of information is already available in the app.

**Independent Test**: Add the widget, log an expense and check a habit in the app and confirm the widget updates; tap a habit check on the widget with the app closed and confirm it is saved; turn on app lock and confirm the widget hides data until "Show data on widget" is on; wait past midnight and confirm it resets.

**Acceptance Scenarios**:

1. **Given** the widget is placed, **Then** it shows today's total spending, the overall monthly budget bar with spent amount and percentage in text, and up to 4 of today's scheduled habits in the user's order, each with its done state.
2. **Given** no overall budget is set for this month, **Then** the budget area says no budget is set instead of showing a bar.
3. **Given** a yes/no habit on the widget, **When** the user taps its check while it is not done, **Then** it is marked done for today without opening the app; **When** it is already done, **Then** the tap does nothing; **Given** a count habit, **Then** a tap adds 1 toward today's target and shows the new progress.
4. **Given** the user taps the widget outside a check button, **Then** the app opens on Home, through SYS-03 when the lock is on.
5. **Given** app lock is on and "Show data on widget" is off, **Then** the widget shows only "Open DailyTrack" and no amounts, budget, or habit names; **Given** "Show data on widget" is on, **Then** it shows the full content and its checks work.
6. **Given** the user adds or edits a transaction, changes a budget, checks a habit, restores a backup, changes currency or language, or changes a lock or widget setting, **Then** the widget shows the new data within a few seconds.
7. **Given** midnight passes, **Then** the widget shows the new day's spending and habits.
8. **Given** the Expense module is disabled, **Then** the widget hides spending and budget; **Given** the Habit module is disabled, **Then** it hides habits.
9. **Given** onboarding is not done or all data was erased, **Then** the widget shows only "Open DailyTrack".

---

### User Story 8 - Recover with a backup when the PIN is forgotten or the database fails (Priority: P3)

A user who forgot their PIN taps "Forgot PIN?" on SYS-03. Besides erasing all data, they can now choose "Restore from Google Drive backup": they sign in to Google, pick a backup, enter its password if encrypted, confirm, and their data comes back with the app lock off, so they can set a new PIN. Separately, if the app's database cannot be opened at startup, the error screen offers "Restore from backup" next to "Retry".

**Why this priority**: These paths are rare but turn a total loss into a recovery. They reuse the restore flow from Stories 1 and 2.

**Independent Test**: Make a Drive backup, set a PIN, use "Forgot PIN?" → "Restore from Google Drive backup", and confirm the data is restored, app lock is off, and the old PIN is gone.

**Acceptance Scenarios**:

1. **Given** SYS-03, **When** the user taps "Forgot PIN?", **Then** the sheet offers "Restore from Google Drive backup" and "Erase all data".
2. **Given** they choose "Restore from Google Drive backup", **Then** Google sign-in follows, then the list of Drive backups; with no backups, a message says so and offers "Erase all data" instead.
3. **Given** they pick a backup, enter its password when needed, and confirm "Replace current data?", **Then** the data is restored, the PIN, biometric setting, and lockout are cleared, app lock is off, and the app opens Home.
4. **Given** they cancel at any step, **Then** nothing changes and SYS-03 stays as it was, including any running lockout.
5. **Given** the database cannot be opened at startup, **Then** the error screen offers "Retry" and "Restore from backup"; restore offers a backup file or Google Drive and, on success, opens the app normally.

---

### Edge Cases

- The backup file is very large (10,000+ transactions, many receipts): progress is shown, the UI stays responsive, and the user cannot start a second backup or restore at the same time.
- The user leaves the app or the phone sleeps during a manual Drive backup: the backup finishes or fails cleanly; a partial upload never counts as a backup and never causes an older backup to be deleted.
- A backup contains a receipt whose image file is missing on the device: the backup still succeeds and that receipt is left out; restore keeps the transaction without its receipt.
- Storage is full while restoring receipt images: the restore fails as a whole and current data stays untouched.
- A backup was made while a module was disabled: its data is restored, and the enabled modules and their order follow the backup (FR-009); a disabled module's data stays hidden until it is turned on.
- A backup contains a module this app version does not know: the summary says that part will be skipped; known modules are restored.
- A backup is from a newer app version: restore is refused with a message to update the app.
- Restoring a backup brings back settings: language, currency, theme, and similar preferences are applied at once; device-specific state (PIN, biometric, lock, Google account, auto backup schedule, ad consent, purchase state) is never taken from the backup.
- The Google sign-in token expires or access is revoked from the Google account: the next backup fails with a "Reconnect Google account" prompt, and auto backup counts it as a failure.
- The Drive account is out of storage: the error says so in plain language.
- Two devices back up to the same Drive account: both sets of backups are listed by date; the 5-auto-backup limit applies across the account's auto backups from all devices.
- Encrypted backup with a forgotten password: restore is impossible; the error says so without hints that weaken the encryption.
- Auto backup with encryption on runs in the background: it uses the saved password without asking.
- The saved password cannot be read (e.g. secure storage was reset): no unencrypted backup is made; manual backup asks the user to enter the password again, and auto backup counts as a failure until they do.
- Export of a period with 10,000 transactions: progress is shown and the export completes; the PDF table spans as many pages as needed.
- The export file is created but the user closes the share sheet without sharing: the one-time unlock is still used up, because the file was made.
- Export of a transfer: Type "Transfer", Category empty, Account shows "From → To".
- Export notes with commas, quotes, or line breaks: the CSV stays valid and opens with each note in one cell.
- A "Mark done" tap from a reminder arrives after midnight: the habit is marked for the day the reminder was for.
- "Mark done" is tapped for a habit that was archived or deleted since the reminder: nothing is written and the notification is dismissed.
- A widget habit check is tapped while app lock is on and "Show data on widget" is on: the check works without unlocking.
- The time zone changes while traveling: reminders and the daily summary fire at the chosen local time in the new zone; widget "today" follows the new local date.
- Notification permission is denied: nothing is scheduled or shown, and SET-01 explains it. Once permission is granted, the next app open reschedules every notification.
- The widget is placed but the app has never been opened since install or update: it shows "Open DailyTrack" until the app has run once.
- Text in Hindi and Gujarati is up to 30% longer: SET-02, SET-03, the widget, and notification texts fit at 360 dp wide and 200% font scale without clipping (the widget truncates habit names with an ellipsis).

## Requirements *(mandatory)*

### Functional Requirements

**Backup format and engine**

- **FR-001**: A backup MUST be one file named `dailytrack_backup_<yyyyMMdd_HHmm>` (local time) that holds a data-format version, the app version, the creation time, one section per tracker module, and the restorable settings.
- **FR-002**: Each tracker module MUST write and read its own section, covering all of its own tables, including soft-deleted rows and history (e.g. habit schedule history); the backup engine MUST NOT read or write a module's tables directly, so new modules (Water, Period) join backup by adding their own section.
- **FR-003**: When "Include receipt images" is on (default off), the backup MUST also carry every receipt image referenced by a backed-up transaction, in the same single file; when off, restored transactions MUST have no receipt.
- **FR-004**: When "Encrypt backup" is on, the whole backup MUST be encrypted with authenticated encryption (AES-GCM) using a key derived from the user's password with a slow, salted key-derivation function (PBKDF2); the salt and parameters MUST be stored in the file, and the password MUST NOT be.
- **FR-005**: Restore MUST validate the file before changing anything: that it is a DailyTrack backup, that it is complete and not damaged, that its version is supported, and (if encrypted) that the password is correct.
- **FR-006**: Restore MUST upgrade backups made with any older data-format version to the current one before restoring; it MUST refuse backups from a newer version with a message to update the app.
- **FR-007**: Before writing, restore MUST show a summary (backup date, app version, record counts per module) and a confirmation dialog stating that all current data will be replaced.
- **FR-008**: Restore MUST replace all module data and restorable settings in a single all-or-nothing operation; if any step fails, all data and settings MUST be exactly as before, and an error with a next step MUST be shown.
- **FR-009**: Restorable settings MUST include language, currency, first day of week, date format, theme mode, color theme, font size, enabled modules and their order, notification preferences, and Home preferences. The PIN, biometric setting, lock state, lockout state, Google account, auto backup and encryption settings, last backup info, ad consent, purchase state, and unlocks MUST NOT be taken from or written to a backup.
- **FR-010**: After a successful restore, the app MUST reschedule all notifications, refresh the home screen widget, mark onboarding as done, and apply restored preferences immediately.
- **FR-011**: Only one backup or restore MUST run at a time; a second request MUST wait or be refused with a message.

**SET-02 Backup and restore**

- **FR-012**: SET-02 MUST show, top to bottom: Last backup (date, time, location, size, or "No backup yet"), the Google Drive backup card, the Local backup card, Encrypt backup, Include receipt images, and Restore from Google Drive.
- **FR-013**: "Save backup file" MUST let the user choose a location with the system file picker and then offer "Share" to send the saved file through the share sheet. "Restore from file" MUST open the system file picker.
- **FR-014**: "Connect Google account" MUST request access only to the app's private Drive app-data folder; the user's other Drive files MUST NOT be readable by the app.
- **FR-015**: A connected Drive card MUST show the account email, "Back up now", the Auto backup selector, and "Disconnect". Disconnect MUST sign out, set Auto backup to Off, and keep existing Drive backups.
- **FR-016**: "Restore from Google Drive" MUST list the account's DailyTrack backups, newest first, with date, time, size, and a Manual or Auto label, and an empty state when there are none. Each backup MUST offer Delete, behind a confirmation dialog.
- **FR-017**: After every successful auto backup, only the 5 newest auto backups in that account's app folder MUST be kept. Manual backups MUST never be deleted automatically; they are removed only by the user (FR-016).
- **FR-018**: Auto backup MUST offer Off (default), Daily, and Weekly, with a "Wi-Fi only" toggle (default on); it MUST run in the background while the app is closed, survive device restart, back up to Drive only, and require a connected account.
- **FR-019**: When "Wi-Fi only" is on, auto backup MUST run only on an unmetered connection; waiting for one MUST NOT count as a failure.
- **FR-020**: The app MUST count consecutive failed auto backups; on the 3rd consecutive failure it MUST show one Backup notification that opens SET-02, and MUST reset the count after any successful backup.
- **FR-021**: "Encrypt backup" MUST, when turned on, require a password entered twice and show a warning that a lost password cannot be recovered. The password MUST be kept only in the device's secure storage so manual and auto backups encrypt without asking; it MUST never be written to a backup, settings, or logs, and Erase all data MUST remove it. Turning it off or changing the password MUST affect only future backups.
- **FR-022**: Long operations (backup, upload, download, restore) MUST show progress and MUST keep the UI responsive.
- **FR-023**: SET-02 MUST show no banner or interstitial ads in this feature.

**SYS-03 and SYS-01 recovery**

- **FR-024**: The SYS-03 "Forgot PIN?" sheet MUST offer "Restore from Google Drive backup" next to "Erase all data". It MUST sign in to Google, list Drive backups, ask for the password when needed, show the summary and confirmation, and restore. On success it MUST clear the PIN, biometric setting, and lockout, turn app lock off, and open Home. Cancelling at any step MUST change nothing.
- **FR-025**: The SYS-01 database-failure screen MUST offer "Restore from backup" next to "Retry", allowing restore from a file or from Google Drive into a fresh database.

**SET-03 Export data**

- **FR-026**: SET-03 MUST offer Data type (Transactions, Habits), a period picker (Week, Month, Year, Custom; default current month), Format (CSV, PDF), filters by accounts and categories (Transactions only; default all), and one "Export" button.
- **FR-027**: CSV files MUST be UTF-8 with a byte-order mark and properly quoted. Transaction CSV columns MUST be Date, Time, Type, Category, Account, Payment mode, Amount, Note. Habit CSV columns MUST be Date, Habit, Value, Target, Unit, Status, Note.
- **FR-028**: Transaction PDFs MUST contain a summary (period, filters, total income, total expense, net), a donut chart of expense by category, and a table of transactions. Habit PDFs MUST contain a summary (period, completion rate per habit) and a table of check-ins. PDFs MUST use the bundled Noto fonts so English, Hindi (Devanagari), and Gujarati text render correctly.
- **FR-029**: PDF amounts MUST use the user's currency formatting; CSV amounts MUST be plain decimals in major units, without symbol or grouping. Exported dates MUST use the user's language and date format; category and account names MUST be the user-visible (translated) names; transfers MUST show "From → To" as the account and no category; soft-deleted records MUST NOT be exported.
- **FR-030**: The finished export MUST open the system share sheet.
- **FR-031**: CSV export MUST be allowed only when the feature gate reports the CSV export key unlocked, and PDF export only when the PDF export key is unlocked. When locked, tapping Export MUST show the shared locked-feature overlay with "Get Pro" disabled and no "Watch an ad" action, and MUST NOT create a file. A one-time export unlock MUST be used up only when a file of its format is created successfully; a failed, cancelled, or empty ("Nothing to export") attempt MUST keep it. Pro and the dev debug switch MUST never be used up.
- **FR-032**: An export with no matching records MUST show a "Nothing to export" message and create no file.
- **FR-033**: "Export this report" in EXP-11 MUST open SET-03 with Transactions and the report's exact period selected.

**SET-01 and SET-05**

- **FR-034**: The SET-01 Data section MUST show, in order, Backup and restore (→ SET-02), Export data (→ SET-03), and Erase all data.
- **FR-035**: SET-05 MUST add a "Show data on widget" toggle (default off), enabled only while app lock is on, with a note that it shows amounts and habit names on the home screen.

**Notifications**

- **FR-036**: The app MUST show a Daily summary notification every day at the user's daily summary time (default 9:00 PM) while notifications are on, stating today's total spending and today's habit progress for enabled modules ("Spent ₹X today · 3/5 habits done"). Tapping it MUST open Home, through SYS-03 when locked.
- **FR-037**: Habit reminders for yes/no habits MUST show "Mark done" and "Snooze 1 h"; reminders for count habits MUST show "Snooze 1 h" only.
- **FR-038**: "Mark done" MUST record the habit as done for the day the reminder was for, update the streak, dismiss the notification, and refresh the widget, without opening the app or the lock screen. If the habit no longer exists or is archived, it MUST only dismiss the notification.
- **FR-039**: "Snooze 1 h" MUST dismiss the notification and show the same reminder about 1 hour later, skipping it if the habit is then done and "Remind me only if not done yet" is on.
- **FR-040**: The Backup notification (FR-020) MUST use its own channel, on by default.
- **FR-041**: All scheduled notifications (habit reminders, daily summary, and any others) MUST be rescheduled on app start, after a restore, after a time zone change, and after device restart, using the settings and data current at that moment.
- **FR-042**: Notifications MUST use exact timing only when the user has granted exact alarms, and otherwise inexact timing; SET-01 MUST note possible delays when exact alarms are not granted and offer to open the system setting.
- **FR-043**: Notifications MUST respect the master toggle, Habit reminders, Budget alerts, and enabled modules from SET-01, and MUST NOT include amounts or habit names in any data sent off the device.

**Home screen widget**

- **FR-044**: The app MUST provide a 4×2 home screen widget showing today's total spending, the current month's overall budget bar with spent amount and percentage as text (or a "No budget set" note), and up to 4 of today's scheduled, non-archived habits in the user's habit order with their done state.
- **FR-045**: Tapping a habit check on the widget MUST, without opening the app, mark a not-done yes/no habit done for today or add 1 to a count habit for today, then update the widget. Tapping the check of a yes/no habit that is already done MUST do nothing; the widget MUST NOT undo check-ins.
- **FR-046**: Tapping the widget outside a check MUST open the app on Home, through SYS-03 when the lock is on.
- **FR-047**: While app lock is on and "Show data on widget" is off, or before onboarding is done, the widget MUST show only "Open DailyTrack" and no data.
- **FR-048**: The widget MUST hide the parts of disabled modules.
- **FR-049**: The widget MUST update after every write that changes what it shows (transactions, budgets, habits, check-ins, restore, erase, currency, language, lock and widget settings, enabled modules) and at local midnight.
- **FR-050**: The widget MUST follow the device's light or dark mode and the app's language and currency formatting, and MUST NOT show budget status by color alone.

**Cross-cutting**

- **FR-051**: No user data MUST leave the device except backups the user starts or schedules to their own Google Drive; no backup, export, notification, or widget content MUST be sent to ad, crash, or analytics services.
- **FR-052**: Every setting in this feature MUST persist across app restarts.
- **FR-053**: All screens in this feature MUST follow the §15 UI/UX rules, including the §15.10 design review checklist: shared tokens and components only, loading, empty, error, and content states, 48 dp touch targets with semantic labels, no clipping at 200% font scale on a 360 dp screen, light and dark mode, confirmation dialogs for restore, and all text from translation files in English, Hindi, and Gujarati.
- **FR-054**: All features in this feature MUST work offline except Google Drive connect, backup, list, and restore.

### Key Entities

- **Backup file**: One file holding the format version, app version, creation time, a section per module, restorable settings, and optionally receipt images; optionally encrypted as a whole with a password-derived key.
- **Module backup section**: A module's own data in a backup (Expense: accounts, categories, transactions, budgets, recurring rules; Habit: habits, schedule history, entries), written and read only by that module.
- **Backup record**: Information about one backup (location, date, size, file name, and for Drive backups whether it is manual or auto); the latest one is shown as "Last backup", and Drive backups are listed for restore.
- **Backup preferences**: Connected Google account, auto backup frequency (Off, Daily, Weekly), Wi-Fi only, encrypt on/off, include receipts on/off, consecutive auto-backup failures, and whether the failure notification was shown.
- **Backup password**: The user's encryption password, kept only in the device's secure storage; removed by Erase all data.
- **Export request**: Data type, period, format, and filters (accounts, categories).
- **Export unlock**: A per-format unlock (CSV, PDF) checked through the feature gate; a one-time unlock is used up when a file of its format is created successfully.
- **Scheduled notification**: Habit reminder, daily summary, budget alert, or backup failure, each with its channel, time, and tap target.
- **Widget snapshot**: The data the widget shows: today's spending, month budget progress, up to 4 habits with done state, and whether data may be shown.
- **Widget preference**: "Show data on widget" on/off.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Backup → erase → restore gives identical row counts and checksums for every table in 100% of tested runs, for plain, encrypted, and receipt-including backups.
- **SC-002**: A failed or cancelled restore leaves 100% of existing data and settings unchanged in every tested failure point.
- **SC-003**: Backups from every earlier data-format version restore successfully.
- **SC-004**: With 10,000 transactions and 50 habits with a year of check-ins, a local backup (without receipts) completes in under 10 seconds and a restore in under 15 seconds on a mid-range device, with the UI staying responsive.
- **SC-005**: A user can make a local or Drive backup in 3 taps or fewer from SET-02, and restore in 4 taps or fewer plus file or backup selection.
- **SC-006**: With Auto backup on, a backup exists in Drive no older than about 2 days (Daily) or 8 days (Weekly) while the device has had suitable connectivity, and Drive never holds more than 5 auto backups.
- **SC-007**: A month's CSV export of 1,000 transactions is ready to share in under 3 seconds, and its PDF in under 10 seconds; Hindi and Gujarati text is readable in both.
- **SC-008**: Tapping "Mark done" in a notification or a widget check saves the check-in within 2 seconds without opening the app, in 100% of tested cases with the app closed.
- **SC-009**: After device restart, time zone change, or restore, 100% of reminders and the daily summary fire at the correct local time (within the inexact-timing window when exact alarms are not allowed).
- **SC-010**: The widget reflects a change made in the app within 5 seconds, and a new day within 1 minute after midnight.
- **SC-011**: With app lock on and "Show data on widget" off, no amount, budget, or habit name is visible on the widget in 100% of tested states.
- **SC-012**: All new screens and the widget render without clipping or overflow at 200% font scale on a 360 dp-wide screen, in English, Hindi, and Gujarati, in light and dark mode.

## Assumptions

- With receipts included, the single backup file is an archive holding the backup data and the receipt images; without receipts it is the backup data alone. The exact container is decided in the plan.
- The encryption password is saved in the device's secure storage so auto backups can run unattended; it is never included in a backup or sent anywhere.
- Auto backup and the 5-auto-backup limit apply to Google Drive only; local backup files are managed by the user.
- Restoring replaces data; there is no merge option.
- The PIN and lock state are never in a backup, so a restore never locks the user out; after a "Forgot PIN?" restore, app lock is off until the user sets a new PIN.
- Rewarded unlocks are not in backups; a Pro purchase is restored from the store.
- Until rewarded ads and Pro (later features) exist, CSV and PDF export are available only through the dev-flavor "Unlock all features (debug)" switch or an existing unlock, matching how premium themes were handled in feature 007.
- The export period picker offers Week, Month, Year, and Custom, like EXP-11; exports are not limited by the free report periods, only by the export unlock.
- In CSV, amounts are plain decimal numbers in major units without a currency symbol (so spreadsheets can sum them), and Type shows whether each is an expense, income, or transfer.
- Habit export Status is one of Done, Partial, or Freeze.
- The widget's budget bar uses the overall monthly budget only; category budgets are not shown.
- The widget habit list shows today's scheduled habits first in the user's order; unscheduled habits are not shown.
- Check-ins are never undone from the widget (count habits are only increased); undoing happens in the app.
- "Show data on widget" also lets widget habit checks work while the app is locked.
- The daily summary is sent every day, including when nothing was logged ("Spent ₹0 today").
- Snooze is fixed at 1 hour.
- Existing habit reminders and budget alerts (features 003 and 005) keep their behavior; this feature adds action buttons, the daily summary, the backup failure notification, and the rescheduling triggers.
- The Google account connection is used only for Drive backup; it is not an app account and does not sync data.
- Rewarded ads for export unlocks, the interstitial after a manual backup, the SET-02 banner, and all other ads are out of scope and arrive in later features.
