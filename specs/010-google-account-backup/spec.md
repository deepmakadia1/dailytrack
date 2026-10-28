# Feature Specification: Google Account and Cloud Backup (§16, ACC-01, ACC-02, ACC-03)

**Feature Branch**: `010-google-account-backup`

**Created**: 2026-10-23 · **Updated**: 2026-10-27 (matched to `docs/spec.md` after feature 011)

**Status**: Draft

**Input**: User description: "Feature: Google account and cloud backup. Implement section 16 of docs/spec.md: optional Google sign-in, ACC-01 Account, ACC-02 Restore choice, ACC-03 Sign out, the SYS-02 'Restore with Google' flow, automatic backup while signed in, the conflict warning, backup metadata, post-restore app lock prompt and restore purchase, 'Delete my backups', and Android Auto Backup with secure storage excluded. Reuse the backup engine and Drive code from feature 007; don't duplicate it. Copy the acceptance criteria from section 16 exactly. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §1 (scope), §4 (account, backup, and device settings; device identity), §5 (ACC-01–ACC-03 routes), SYS-03 ("Forgot PIN?"), §10 SET-02 (Drive card, Drive list, auto backup, restore), PRM-01 (Restore purchase), §12 (Backup notification, rescheduling after restore), §13 (offline, data safety), §14 T3.5 and T3.6, §15 UI/UX guidelines, §16 Google account and cloud backup.

**Numbering note**: The input says to reuse the backup engine and Drive code from "feature 007". That code was built in feature 008 (`specs/008-backup-export-notifications-widget`: backup engine, Drive store, Google sign-in, auto backup, restore flows); 007 is settings, themes, and app lock. This spec reuses feature 008's code.

## Scope after feature 011

`docs/spec.md` was updated on 2026-10-27 for feature 011 (`specs/011-login-guest-mode`, §14 T3.6): SYS-02 Intro → AUTH-01 Login (Google or guest) → Home, with the `authMode` setting. This spec follows `docs/spec.md` §4, §5, §10 SET-02, §13, and §16 as they now read, split between the two features (§14 T3.5, T3.6):

**In 010**: `deviceId` and Android restore detection; change counter triggers; backup metadata and count labels; auto backup on background and on schedule with day-based rotation; the conflict rule with pause and notification; the empty-phone guard; ACC-01, ACC-02, ACC-03, Switch account, Delete my backups; the safety copy and "Restore previous phone data"; silent sign-in on start and revoked-token handling; Android Auto Backup rules and the first start after an Android restore; the "Finish setting up" sheet; sign-in from the SET-02 Drive card (the §16 "Guest sign-in" steps).

**Deferred to 011**: the `authMode` setting, its migration, and its router redirect; AUTH-01 Login; the SYS-02 Intro changes (removing "Restore with Google" and "Set app lock"); the SET-01 account card (which replaces the former SET-01 Account row; this feature does not build that row); ACC-04 Log out of guest; the guest sign-in entry points in SET-01 and ACC-04.

**Interim behavior in 010 until 011 lands** (each item is marked *Replaced in 011* where it appears, and in plan.md):

- I1. "Signed in" means `backupAccountEmail` is set. Where `docs/spec.md` says `authMode = google`, read "signed in"; where it says `guest`, read "signed out".
- I2. Sign-in starts from the SET-02 Drive card, SYS-02 "Restore with Google" (step 1 of onboarding, as before 011), and SYS-03 "Forgot PIN?". ACC-01 "Switch account" opens the account chooser.
- I3. ACC-01 opens from the SET-02 Drive card's account email (and from the pause notification and "Review"), not from SET-01.
- I4. After ACC-03 Sign out, the app opens the More tab. A cancelled Switch account chooser also returns to the More tab.
- I5. A revoked token or removed account clears the account keys and leaves the user signed out with all data kept (011 sets `authMode = guest`).
- I6. The "Finish setting up" sheet follows a restore onto an empty phone (SYS-02 "Restore with Google" or the ACC-02 no-data rule) and the first start after an Android restore (011 shows it after every login).

## Clarifications

### Session 2026-10-23

- Q: Should background backups count toward the same "keep the last 5 auto backups" limit as the daily backup? → A: No single count of 5: keep the newest auto backup of each of the last 5 local days (before today) that had one, plus today's newest auto backup, so at most 6 auto backups are kept; manual backups are unchanged.
- Q: After an encrypted backup is restored on a new phone, should that phone's new backups also be encrypted? → A: Yes: after any successful restore of an encrypted backup, "Encrypt backup" is turned on and the password that opened it is saved in this phone's secure storage, so later backups are encrypted with the same password.
- Q: When "Restore from account" replaces a phone that has its own data, should that data be saved first? → A: Yes: a copy of the current data is saved in the app's private storage before restoring, kept for 7 days (latest copy only), and SET-02 offers "Restore previous phone data" while it exists.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Get my data back on a new phone (Priority: P1)

A user has a new phone (or reinstalled the app). They sign in with Google, and the app finds their newest backup and restores it straight away, because this phone has nothing to lose (the ACC-02 no-data rule). The app opens on Home with their language, currency, modules, transactions, and habits. Home then shows a one-time "Finish setting up" sheet offering to set an app lock and allow notifications, since the PIN is never backed up, and Pro is restored quietly if they bought it.

In 010 the sign-in for this starts from SYS-02 "Restore with Google" on the first onboarding step *(interim I2; Replaced in 011 by AUTH-01 "Continue with Google")*.

**Why this priority**: Getting data back after losing or changing a phone is the main reason to sign in at all. It also reuses feature 008's restore engine end to end, so it proves the account layer works.

**Independent Test**: Sign in on a fresh install from SYS-02 with an account that has a backup, and compare the restored data with the source phone; then repeat with an account that has no backup and with a cancelled sign-in.

**Acceptance Scenarios**:

1. **Given** a fresh install on SYS-02 step 1, **When** the user taps "Restore with Google" and signs in to an account with backups, **Then** the newest backup is restored without a choice sheet behind a "Restoring your data…" progress view, onboarding is marked done, and the app opens DSH-01 with the backup's language, currency, and modules. *(Replaced in 011.)*
2. **Given** the newest backup is encrypted and no saved password opens it, **When** the restore starts, **Then** the user is asked for the backup password first; a wrong password writes nothing; after a successful restore, "Encrypt backup" is on and the next backup is encrypted with that password.
3. **Given** a restore onto an empty phone finished, **Then** Home shows the "Finish setting up" sheet once if app lock is off, with "Set app lock" (→ SYS-04), "Allow notifications" (Android 13+, only when not granted), and "Not now", and Restore purchase runs in the background, showing "Pro restored" only if Pro is found.
4. **Given** the account has no backup, **Then** the user stays signed in, sees "No backup found on this account", continues onboarding from step 1, and their data is backed up once onboarding is done. *(Replaced in 011.)*
5. **Given** sign-in is cancelled or the restore fails, **Then** onboarding continues from step 1 with nothing written; a failed restore shows the SET-02 error message with "Try again". *(Replaced in 011.)*

**Interim SYS-02 acceptance criteria** (from `docs/spec.md` before 011; *Replaced in 011* by the AUTH-01 criteria):

- [ ] "Restore with Google" on an account with a backup restores it without a choice sheet, skips steps 2–4, and lands on DSH-01 with the backup's language, currency, and modules.
- [ ] After a restore from onboarding, the "Finish setting up" sheet appears once and Restore purchase runs.
- [ ] Cancelling sign-in, or an account with no backup, returns to onboarding with no data written.

---

### User Story 2 - Sign in and manage my account (ACC-01) (Priority: P1)

A signed-out user taps "Sign in with Google" on the SET-02 Drive card. If the account has no backup, this phone's data is backed up at once and auto backup turns on (Daily) if it was off; if it has one, ACC-02 asks what to keep. Signed in, the Drive card shows their email, which opens ACC-01 *(interim I3; Replaced in 011: also from the SET-01 account card)*. ACC-01 shows their photo, name, email, when and from which phone the last backup was made, and its state ("Backed up to Google"), with "Back up now", "Restore", the auto backup setting, "Switch account", "Sign out", and "Delete my backups". ACC-01 is for a signed-in account only; signing in never happens on it.

**Why this priority**: This is the home of the feature; every other flow starts here or reports its state here.

**Independent Test**: With a fake Google account and fake Drive, sign in from the SET-02 Drive card, open ACC-01, back up now, switch account, and delete backups, checking the screen and the Drive files after each step.

**Acceptance Scenarios**:

1. **Given** a signed-out user on SET-02, **When** they sign in from the Drive card to an account with no backup, **Then** this phone's data is backed up, Auto backup becomes Daily if it was Off, and "Signed in. Your data is backed up." is shown; **When** the account has a backup, **Then** ACC-02 opens and can't be dismissed (or the backup is restored at once if this phone has no user data).
2. **Given** sign-in is cancelled or fails, **Then** the user stays signed out and nothing changes; a failure shows "Couldn't sign in. Check your connection and try again."; offline, the button shows "Connect to the internet to sign in with Google" and makes no request.
3. **Given** a signed-in user, **When** they tap "Back up now", **Then** a manual backup runs (ignoring "Wi-Fi only") with progress on the button and a success message; no interstitial follows.
4. **Given** a signed-in user, **When** they tap "Switch account", **Then** the app backs up to the current account first (a failure offers "Switch anyway"), signs out keeping all local data, and opens the account chooser; the new account then follows the SET-02 sign-in flow; a cancelled chooser leaves the user signed out with all data kept, on the More tab. *(Cancelled chooser: interim I4; Replaced in 011 by `authMode = guest` and the SET-01 guest card.)*
5. **Given** a signed-in user, **When** they tap "Delete my backups" and confirm a dialog naming the number of backups and the account, **Then** every DailyTrack backup in that account is deleted, local data and the sign-in stay, and the next auto backup makes a fresh one.
6. **Given** the phone is offline, **Then** account details still show, the status says "You're offline. Backups resume when you're back online.", and Back up now, Restore, Switch account, and Delete my backups are disabled with that reason while Sign out still works.
7. **Given** SET-02, **Then** its Drive card shows "Sign in with Google" when signed out and the account email (tap → ACC-01) when signed in.
8. **Given** ACC-01 is open, **When** the account stops being signed in (sign-out or a revoked token), **Then** ACC-01 closes.

**ACC-01 acceptance criteria** (copied from docs/spec.md):

- [ ] Shows name, email, photo (or initial), "Backed up to Google" with the last backup time and device, and all actions.
- [ ] ACC-01 can't be opened as a guest; the SET-01 guest card starts guest sign-in instead. *(Interim I1, I3: ACC-01 can't be opened while signed out; the SET-02 Drive card starts sign-in instead. Replaced in 011.)*
- [ ] "Back up now" with a newer backup from another device shows the warning, and "Cancel" uploads nothing.
- [ ] "Delete my backups" removes every backup file in the app folder and leaves local data and the sign-in in place.
- [ ] Switch account backs up to the old account before signing out and never removes local data.
- [ ] Offline, the network actions are disabled with an explanation and Sign out still works.

**Guest sign-in acceptance criteria** (copied from docs/spec.md §16 "Guest sign-in"; in 010 from the SET-02 Drive card only, read with interim I1):

- [ ] Signing in to an account without a backup backs up this phone's data, sets `authMode = google`, turns Auto backup to Daily if it was Off, and the SET-01 card switches to the Google state. *(010: `backupAccountEmail` is set and the SET-02 Drive card shows the account; the `authMode` and SET-01 parts are Replaced in 011.)*
- [ ] Signing in to an account with a backup opens ACC-02; "Restore from account" replaces this phone's data and "Keep this phone's data" makes this phone's data the account's latest backup, and no rows from the two are combined.
- [ ] Cancelling or failing sign-in leaves `authMode = guest` and every local row unchanged. *(010: stays signed out; Replaced in 011.)*

---

### User Story 3 - Choose between my backup and this phone's data (ACC-02) (Priority: P1)

A user who already has data on this phone signs in to an account that also has a backup. A sheet shows the backup (date, which phone made it, counts like "1,240 transactions · 8 habits", Manual or Auto, encrypted or not) next to this phone's counts, and asks them to choose: "Restore from account" (replaces this phone's data) or "Keep this phone's data" (this phone's data becomes the account's latest backup). There is no merging. They can also open the full list of backups.

**Why this priority**: Without this choice, signing in on a phone with data would either overwrite it silently or leave the account's backup out of date. It protects data in both directions.

**Independent Test**: Seed different data on the phone and in a fake Drive backup, sign in, and check each choice's outcome on local rows and on Drive.

**Acceptance Scenarios**:

1. **Given** this phone has user data and the account has a backup, **When** sign-in finishes, **Then** ACC-02 opens and cannot be dismissed by dragging or tapping outside; opened from ACC-01 "Restore", it also has a close button that changes nothing.
2. **Given** ACC-02, **When** the user taps "Restore from account", **Then** a copy of this phone's current data is saved privately on the phone first (FR-019a), and the backup replaces all module data in one step, notifications are rescheduled, the widget refreshes, and "Restored 1,240 transactions and 8 habits." is shown; no second confirmation is asked, because the sheet already says the phone's data will be replaced.
3. **Given** ACC-02, **When** the user taps "Keep this phone's data", **Then** nothing is written locally, a backup of this phone starts and becomes the newest, so this phone's data replaces the account backup as the one restored by default; the declined backup stays in the SET-02 list until rotation or deletion, and no conflict warning appears for it later.
4. **Given** this phone has only the seeded categories and Cash account, **When** the user signs in to an account with a backup, **Then** no sheet is shown and the newest backup is restored at once, followed by the "Finish setting up" sheet if app lock is off.
5. **Given** a restore from account replaced this phone's data within the last 7 days, **Then** SET-02 shows "Restore previous phone data" with the copy's date and counts, and restoring it brings back exactly the data the phone had before; after 7 days the option and the copy are gone.
6. **Given** a download or restore failure, **Then** "Couldn't restore. Your data on this phone wasn't changed." is shown with "Try again"; offline, restore is disabled with "Connect to the internet to restore" and "Keep this phone's data" still works.

**ACC-02 acceptance criteria** (copied from docs/spec.md):

- [ ] The summary shows the backup's date, device name, counts, and encryption from metadata without downloading the file.
- [ ] With no user data on the phone, the newest backup is restored without showing the choice.
- [ ] Seeded categories and the Cash account alone count as no data.
- [ ] "Restore from account" replaces all module rows in one transaction; a failure leaves this phone's data unchanged.
- [ ] "Keep this phone's data" writes nothing locally, starts a backup, and no conflict warning appears for the declined backup.
- [ ] An encrypted backup asks for the password only when the saved one fails; a wrong password writes nothing.

---

### User Story 4 - Stay backed up without thinking about it (Priority: P2)

While signed in with auto backup on, the user's changes are backed up when they leave the app (at most every 15 minutes, only if something changed) and by the daily job. With "Wi-Fi only" on, backups wait for Wi-Fi. Each backup records which phone made it, the app version, and how many records it holds, so lists and choices can show that without downloading anything.

**Why this priority**: Makes the account useful day to day, but depends on sign-in (Story 2) and builds on feature 008's auto backup.

**Independent Test**: With fake clock, network, and Drive, change data and send the app to the background repeatedly; check when uploads happen and what metadata they carry.

**Acceptance Scenarios**:

1. **Given** signed in with auto backup not Off and data changed, **When** the app goes to the background and the last background backup started 15 or more minutes ago, **Then** a backup runs and finishes even if the app is closed.
2. **Given** the same, **When** the app goes to the background again within 15 minutes, or nothing changed, **Then** no backup starts.
3. **Given** "Wi-Fi only" is on and the phone is on mobile data, **Then** background and scheduled backups wait and run once Wi-Fi is back; a waiting background backup is replaced by the next one, never queued twice.
4. **Given** a background backup, **Then** it counts toward the auto backup rotation (FR-035) and the 3-failures notification, and never triggers an ad.
5. **Given** today has 4 auto backups and the 7 earlier days each have 2, **When** a new auto backup succeeds, **Then** Drive keeps only today's newest auto backup plus the newest auto backup of each of the 5 most recent earlier days, and every manual backup.
6. **Given** any Drive backup, **Then** it records the device ID, device name, app version, creation time, Manual or Auto, and per-module counts, readable both from the Drive listing and inside the file (the file wins if they disagree); local backup files also carry it.
7. **Given** the SET-02 Drive list, **Then** each backup shows its device name and counts and is labeled Manual or Auto; restoring from it follows ACC-02's rules.

---

### User Story 5 - Don't overwrite another phone's newer backup (Priority: P2)

A user has two phones signed in to the same account. Phone B backed up this morning; phone A hasn't seen that backup. When phone A is about to back up, it notices. A manual backup asks "A newer backup from Redmi Note 12 (Today, 8:15 PM) exists. Backing up now makes this phone's data the latest." with "Back up anyway" and "Cancel". An auto backup doesn't upload; it pauses, notifies once, and shows "Backup paused" with "Review" until the user restores, keeps this phone's data, or backs up manually.

**Why this priority**: Prevents silent loss of a newer backup when the last backup wins, but only matters to users with more than one phone.

**Independent Test**: With a fake Drive holding a newer backup from another device ID, trigger manual and auto backups and check uploads, dialogs, notifications, and the pause state.

**Acceptance Scenarios**:

1. **Given** the newest backup comes from another device and is newer than any this phone has made, restored, or kept its data over, **When** a manual backup starts (ACC-01, SET-02, or the sign-out backup), **Then** the warning dialog appears; "Cancel" uploads nothing and "Back up anyway" uploads and makes this phone's backup the newest.
2. **Given** the same, **When** an auto backup runs, **Then** nothing is uploaded, the Backup notification is shown once (tap → ACC-01), and ACC-01 shows "Backup paused". (`docs/spec.md` also shows it on SET-01; that part comes with the 011 account card.)
3. **Given** a pause, **When** the user restores, chooses "Keep this phone's data", or makes a manual backup, **Then** the pause ends and auto backups resume.
4. **Given** the newest backup was made by this same phone, or is older than this phone's last known backup, **Then** no warning appears.

---

### User Story 6 - Sign out without losing anything (ACC-03) (Priority: P2)

A user taps "Sign out". The sheet first backs up any changes not yet backed up, then asks whether to keep the data on this phone or remove it. If the backup fails, they can try again or sign out anyway, but removing data after a failed backup needs the typed "DELETE" confirmation.

**Why this priority**: Needed for handing a phone on or switching accounts safely; less frequent than signing in.

**Independent Test**: With a fake Drive, sign out in each combination (backup succeeds or fails × keep or remove) and check local rows, Drive files, and the screen afterwards.

**Acceptance Scenarios**:

1. **Given** changes not yet backed up, **When** the sheet opens, **Then** it shows "Backing up your latest changes…" and "Sign out" stays disabled until the backup succeeds or the user picks "Sign out anyway"; with nothing to back up, it shows "Backed up".
2. **Given** the backup fails (offline, error, or a declined conflict warning), **Then** it shows "Couldn't back up your latest changes" with "Try again" and "Sign out anyway".
3. **Given** "Keep data on this phone" (default), **When** the user signs out, **Then** the app opens the More tab with "Signed out. Your data is still on this phone." and the app works fully. *(Interim I4; Replaced in 011: opens AUTH-01.)*
4. **Given** "Remove data from this phone", **When** the user signs out, **Then** the same erase as "Erase all data" runs (module data, receipts, the safety copy, backup password, app lock), the Drive backups stay, and the erase's existing redirect opens SYS-02 onboarding, where "Restore with Google" brings the data back. *(Interim; Replaced in 011: opens AUTH-01.)*
5. **Given** a signed-out user, **Then** no Drive request is made, pending Drive backups are cancelled, and the Auto backup setting is kept for the next sign-in.

**ACC-03 acceptance criteria** (copied from docs/spec.md):

- [ ] With changes not yet backed up, sign-out backs up first and enables "Sign out" only after the backup succeeds or the user picks "Sign out anyway."
- [ ] "Keep data on this phone" leaves every local row in place, opens AUTH-01, and "Continue as guest" there shows the same data. *(010: leaves every local row in place, opens the More tab, and the app stays fully usable signed out. Replaced in 011.)*
- [ ] "Remove data from this phone" erases local data, keeps the Drive backups, and opens AUTH-01. *(010: erases local data, keeps the Drive backups, and opens SYS-02 through the erase's redirect. Replaced in 011.)*
- [ ] After sign-out with either choice, `authMode` is `none` and the app opens AUTH-01, never Intro; a restart also opens AUTH-01. *(Deferred to 011.)*
- [ ] After a failed backup, "Remove data from this phone" needs the typed "DELETE" confirmation.
- [ ] After sign-out, no Drive request is made until the user signs in again.

---

### User Story 7 - Android's own backup brings the app back safely (Priority: P3)

A user moves to a new phone with Android's built-in backup or device transfer, whether or not they signed in. The app's data comes along, but secure storage (PIN, backup password) does not. On the first start the app notices it was restored this way: it gets a new device ID, turns the app lock off if there is no PIN (so the user isn't locked out), clears the stored account and tries a silent sign-in, reschedules notifications, restores Pro, and shows the "Finish setting up" sheet on Home instead of onboarding.

**Why this priority**: A free fallback for users who never sign in, but it depends on Android and needs little UI.

**Independent Test**: Simulate an Android restore (database present, no device ID file, no PIN hash, lock on) and start the app; inspect the backup rules files.

**Acceptance Scenarios**:

1. **Given** Android's backup rules, **Then** they include the app database and exclude secure storage, the no-backup folder with the device ID, receipt images, the safety copy, and caches, for both cloud backup and device-to-device transfer, on old and new Android versions.
2. **Given** the first start after such a restore, **Then** the app makes a new device ID, turns lock and biometric off when no PIN hash exists, clears the stored account and tries a silent sign-in (signed in again only if it succeeds), applies the conflict rule as if no backup were known, reschedules notifications, runs Restore purchase, and shows the "Finish setting up" sheet; onboarding is not shown. (The `authMode` handling in `docs/spec.md` §16 comes with 011.)
3. **Given** "Encrypt backup" was on before the restore, **Then** backups fail with "Set your backup password in Backup and restore" and are never made unencrypted.

**Section 16 acceptance criteria** (copied from docs/spec.md):

- [ ] Every screen outside this section works the same as a guest, and only the places listed at the top of this section offer sign-in. *(010: works the same signed out, and only the interim entry points (I2) offer sign-in. Replaced in 011.)*
- [ ] As a guest, the app makes no Google sign-in or Drive request (a fake client records zero calls across a full session). *(010: signed out, the app makes no Drive request and no sign-in request unless the user starts one. The guest form is Deferred to 011.)*
- [ ] No account or backup text in the app says "Synced" or "Sync"; status uses "Backed up to Google."
- [ ] Neither a Drive backup file nor Android Auto Backup data contains the PIN hash, lockout state, or backup password (a test inspects the backup JSON and the backup rules XML).
- [ ] Going to the background with changed data starts a backup; going to the background again within 15 minutes does not; nothing starts when no data changed.
- [ ] With "Wi-Fi only" on, background and scheduled auto backups don't upload on mobile data and run once Wi-Fi is back.
- [ ] Auto backup does not upload over a newer backup from another device; it pauses, notifies once, and resumes after a restore, "Keep this phone's data," or a manual backup.
- [ ] Each Drive backup has `deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, and `counts` in both `appProperties` and the file's `meta`.
- [ ] Two installs never share a `deviceId`, including after a Drive restore or an Android Auto Backup restore.
- [ ] On the first start after an Android Auto Backup restore with app lock on and no PIN hash, the lock is turned off and the "Finish setting up" sheet is shown instead of locking the user out.

---

### Edge Cases

- **Silent sign-in fails at start**: if the token was revoked or the account was removed from the phone, the app clears the account keys and keeps all data; the user is signed out and auto backups stop until they sign in again *(interim I5; Replaced in 011: `authMode` becomes `guest`)*. An offline start keeps the user signed in, and backups resume when the network is back.
- **Data written while a backup runs**: the "changed" mark stays set, so the next trigger backs up again.
- **Backup made before this feature** (no metadata): listed with date, size, and the device name feature 008 already stored ("Unknown device" only when there is none), without counts; never counted as "from another device" by the conflict rule; restorable as before.
- **Encrypted backup on a new phone**: the password is not on the phone, so it is asked for at restore; once the restore succeeds, "Encrypt backup" is turned on and that password is saved in secure storage (FR-019b), so no unencrypted backup is uploaded afterwards. A failed or cancelled restore saves nothing.
- **Sign-in from SYS-03 "Forgot PIN?"**: follows the feature 008 flow, now using the shared account sign-in and `AccountRestore`; the user ends up signed in.
- **Switch to the same account** in the chooser: treated as a normal sign-in to that account.
- **Delete my backups while a background backup is uploading**: the upload finishes and becomes the only backup; nothing is restored or lost locally.
- **No room for the safety copy**: the restore from account does not start, and the error explains that the phone needs more free space; this phone's data is untouched.
- **Second restore within 7 days**: the new safety copy replaces the previous one, so only the data from just before the latest restore can be recovered.
- **Sign out while offline**: goes straight to the failed-backup state; "Remove data" then needs the typed "DELETE".
- **Pro check after restore offline**: Restore purchase fails quietly and runs again on the next start, as in PRM-01.
- **"Finish setting up" when app lock is already on** (e.g. Drive restore on a phone with a PIN): not shown.
- **Two backgroundings during a Wi-Fi wait**: only one backup is queued.
- **Empty phone, account with data** (e.g. after Erase all data while signed in): auto backups don't upload an empty backup over it; a manual backup warns first (FR-038a). The data can come back through ACC-01 "Restore" (in 010 also SYS-02 "Restore with Google" after an erase, *Replaced in 011* by AUTH-01).
- **Long text**: account names, emails, and device names are shown as given, never translated, and wrap or ellipsize without clipping at 200% font scale.

## Requirements *(mandatory)*

### Functional Requirements

**Account and sign-in**

- **FR-001**: Signing in with Google MUST be optional; every feature outside this one MUST work the same signed out. In 010, sign-in MUST be offered only from the SET-02 Drive card, SYS-02 step 1 "Restore with Google", SYS-03 "Forgot PIN?", and ACC-01 "Switch account" (interim I2; *Replaced in 011* by AUTH-01, the SET-01 account card, the SET-02 Drive card, ACC-04, and SYS-03).
- **FR-002**: Sign-in MUST request only the account's email and basic profile plus access to the app's own hidden Drive folder; one account is signed in at a time.
- **FR-003**: The account's email, display name, and photo address MUST be stored on the phone on sign-in, cleared on sign-out, and never included in any backup. "Signed in" means the stored email is set (interim I1; *Replaced in 011* by `authMode = google`).
- **FR-004**: On start, while signed in, the app MUST try a silent sign-in. If it fails because the token was revoked or the account was removed from the phone, the app MUST clear the account keys and keep all data (interim I5; *Replaced in 011*: also sets `authMode = guest`). An offline start MUST keep the user signed in. A Drive call that reports the authorization is gone MUST be handled the same way.
- **FR-005**: Feature 008's existing sign-in, Drive storage, backup engine, restore flow, auto backup schedule, and backup password store MUST be reused; this feature MUST NOT add a second implementation of any of them. SET-02's Drive card MUST use the same sign-in and sign-out as ACC-01 (replacing its separate "Connect" and "Disconnect").
- **FR-006**: Signing in MUST set Auto backup to Daily if it was Off.
- **FR-006a**: SET-01 "Erase all data" MUST remove data from this phone only: it MUST keep the sign-in, the Auto backup settings, the device ID, `lastKnownDriveBackup*`, and every Drive backup (it no longer signs out, unlike feature 008), and reset both change counters to 0. It still deletes the backup password and the safety copy. The settings it keeps MUST be passed in, not hard-coded, so 011's ACC-04 can reuse the erase with its own list.

**Sign-in from the SET-02 Drive card** (§16 "Guest sign-in"; the SET-01 and ACC-04 entry points are Deferred to 011)

- **FR-007**: On success, sign-in MUST save the account keys and set Auto backup to Daily if it was Off. If the account has no backup, it MUST back up this phone's data right away and show "Signed in. Your data is backed up."; if that first backup fails, the user stays signed in and auto backup retries as usual. If the account has a backup, ACC-02 MUST open (not dismissible), or, if this phone has no user data, the newest backup MUST be restored without the sheet (FR-016).
- **FR-009**: A cancelled or failed sign-in MUST change nothing (the user stays signed out); a failure MUST show "Couldn't sign in. Check your connection and try again."; offline, the sign-in button MUST show "Connect to the internet to sign in with Google" and make no request.

**ACC-01 Account**

- **FR-008**: ACC-01 (`/more/account`) MUST be opened only while signed in, from the SET-02 Drive card's account email, the pause notification, and "Review" (interim I3; *Replaced in 011*: also from the SET-01 account card). It MUST show the account card (photo or initial in a `CategoryAvatar`, name, email); the backup status ("Last backup: Today, 9:41 PM · Redmi Note 12" and one of "Backed up to Google," "Backing up…," "Waiting for Wi-Fi," "Backup paused: a newer backup from another phone exists" with "Review" → ACC-02 for that backup, or "Backup failed" with the error message); Back up now (primary); Restore; the Auto backup row → SET-02; Switch account and Sign out; Delete my backups (`error` color); and the footnote "Your app lock PIN is never backed up." Status MUST never be shown by color alone. ACC-01 MUST NOT offer sign-in, and MUST close if the account stops being signed in while it is open.
- **FR-010**: "Back up now" MUST run a manual Drive backup under the conflict rule, ignoring "Wi-Fi only", with progress and a success message, and MUST NOT trigger an interstitial.
- **FR-011**: "Restore" MUST open ACC-02 for the newest backup, with "See all backups" opening the SET-02 Drive list.
- **FR-012**: "Switch account" MUST back up to the current account first ("Switch anyway" on failure), sign out without touching local data, and open the account chooser; the new account then follows FR-007. A cancelled chooser MUST leave the user signed out with data kept and return to the More tab (interim I4; *Replaced in 011* by `authMode = guest` and the SET-01 guest card).
- **FR-013**: "Delete my backups" MUST confirm with a dialog naming the backup count and account, then delete every DailyTrack backup (manual and auto) in that account's app folder, keep local data and the sign-in, and reset the last known backup so the next auto backup starts fresh.
- **FR-014**: ACC-01 MUST show local account details immediately and load backup status in the background (skeleton while loading); offline it MUST disable the network actions with the offline message and keep Sign out enabled; a Drive read error MUST show an error with "Try again" in the status area only. ACC-01 has no empty state (it is opened only while signed in).
- **FR-015**: *(Deferred to 011.)* The SET-01 Account row is not built; 011's SET-01 account card replaces it, including its "Backup paused" and "Backup failed" lines.

**ACC-02 Restore choice**

- **FR-016**: The phone MUST count as having no data when every module reports zero user rows, seeded defaults excluded; in that case the newest backup MUST be restored without showing ACC-02, then the "Finish setting up" sheet MUST be shown if app lock is off.
- **FR-017**: Otherwise ACC-02 MUST show the backup summary (date and time, device name or "From this phone", counts, Manual or Auto, encrypted badge) read from metadata without downloading the file, this phone's counts, and the choices "Restore from account", "Keep this phone's data", and "See all backups".
- **FR-018**: A password field MUST appear only for an encrypted backup the saved password cannot open; a wrong password MUST show "That password didn't work" and write nothing.
- **FR-019**: "Restore from account" MUST run feature 008's restore (validate, upgrade, replace in one transaction), then mark that backup as the last known one, clear the "changed" mark and any pause, reschedule notifications, refresh the widget, and show a success message with counts. A failure MUST leave all data unchanged.
- **FR-019a**: Before "Restore from account" (or a restore from the SET-02 Drive list) replaces a phone that has user data (FR-016), the app MUST save a copy of the current data, in feature 008's backup format with receipts, in the app's private storage, replacing any earlier copy. If the copy cannot be saved (e.g. storage full), the restore MUST NOT start and a plain-language error MUST say why. The copy MUST be kept for 7 days, never uploaded, excluded from Android Auto Backup, and deleted by Erase all data and "Remove data from this phone". While it exists, SET-02 MUST show "Restore previous phone data" with the copy's date and counts; it restores through feature 008's summary and "Replace current data?" confirmation, and the copy is deleted after it is restored successfully.
- **FR-019b**: After any successful restore of an encrypted backup (ACC-02, FR-016, SYS-02, the SET-02 Drive list, or a SET-02 local backup file), the app MUST turn "Encrypt backup" on and save the password that opened the backup in secure storage, replacing any saved one, before any later backup runs. The password MUST NOT be saved when the restore fails or is cancelled.
- **FR-020**: "Keep this phone's data" MUST write no local data, mark the newest backup as the last known one, clear any pause, and start a backup, which becomes the account's latest backup; the declined backup stays in the SET-02 list until rotation or deletion. No rows from the two sides are ever combined.
- **FR-021**: After sign-in ACC-02 MUST NOT be dismissible by drag or outside tap; from ACC-01 "Restore" it MUST also have a close button that changes nothing.

**ACC-03 Sign out**

- **FR-022**: ACC-03 MUST first back up changes not yet backed up as a manual backup under the conflict rule (a declined warning counts as a failure), then offer "Keep data on this phone" (default) or "Remove data from this phone".
- **FR-023**: On backup failure it MUST offer "Try again" and "Sign out anyway"; after "Sign out anyway", "Remove data from this phone" MUST need the typed "DELETE" confirmation.
- **FR-024**: Sign out MUST sign the account out, clear the account details and last known backup, cancel pending Drive backups, and stop background backups, keeping the Auto backup setting.
- **FR-025**: "Keep data on this phone" MUST open the More tab with "Signed out. Your data is still on this phone." (interim I4). "Remove data from this phone" MUST run the same erase as SET-01 "Erase all data" (all module rows, receipts, the safety copy, backup password, and app lock), keep the device ID and the Drive backups, and then follow the erase's existing redirect to SYS-02 onboarding. *Replaced in 011*: both choices set `authMode = none` and open AUTH-01.

**SYS-02 Restore with Google** *(interim I2; Replaced in 011 by AUTH-01)*

- **FR-026**: SYS-02 step 1 MUST show a secondary "Restore with Google" button below the language chips that signs in and restores the newest backup under FR-016 behind a full-screen progress view, asking for the password first when needed.
- **FR-027**: After a successful restore from onboarding, the remaining steps MUST be skipped, onboarding marked done, and the app MUST open DSH-01 with the restored preferences.
- **FR-030**: If the account has no backup, SYS-02 MUST show "No backup found on this account" and continue from step 1 signed in, and back up once onboarding is done; a cancelled sign-in or failed restore MUST continue from step 1 with nothing written.

**Finish setting up and Restore purchase**

- **FR-028**: After a restore onto an empty phone (SYS-02 or FR-016) and on the first start after an Android restore (FR-046), while app lock is off, Home MUST show the "Finish setting up" sheet once (`finishSetupPending`), with "Set app lock" (→ SYS-04), "Allow notifications" (only on Android 13+ when the permission isn't granted), and "Not now". Any choice, or dismissing it, clears the flag. *(Interim I6; Replaced in 011: the sheet also follows every login.)*
- **FR-029**: After a restore onto an empty phone from SYS-02 or an Android Auto Backup restore, Restore purchase (PRM-01) MUST run in the background without UI, except a "Pro restored" message when Pro is found. *(SYS-02 part Replaced in 011 by the AUTH-01 restore.)*

**Auto backup while signed in**

- **FR-031**: Any write to a backed-up table or a restorable preference MUST raise a change counter; data counts as changed since the last backup while the counter differs from the value captured in the last successful backup or restore, so a write made while a backup runs keeps the data changed.
- **FR-032**: While signed in and Auto backup is not Off, going to the background MUST start a background backup when onboarding is done, data changed, and the last background backup was requested at least 15 minutes earlier; it MUST finish even if the app is closed.
- **FR-033**: Feature 008's scheduled daily or weekly auto backup MUST keep running and MUST skip the upload when nothing changed.
- **FR-034**: Background and scheduled auto backups MUST wait for Wi-Fi when "Wi-Fi only" is on; at most one background backup may wait at a time.
- **FR-035**: Background and scheduled backups are both auto backups. After each successful auto backup, Drive MUST keep only today's newest auto backup plus the newest auto backup of each of the 5 most recent earlier local days that had one (at most 6 auto backups), and delete the other auto backups of that account; manual backups MUST never be deleted automatically. This replaces feature 008's "keep the last 5 auto backups" rule. Background backups MUST count toward the 3-failures notification and MUST never trigger ads.
- **FR-036**: Changes made while signed out MUST be included in the first backup after sign-in.

**Conflict rule**

- **FR-037**: The newest backup by creation time MUST be the default restore target.
- **FR-038**: Before any Drive backup, the app MUST read the newest backup's metadata; if it was made by a different device and is newer than this phone's last known backup, a manual backup MUST show the warning dialog ("Back up anyway" / "Cancel") and an auto backup MUST NOT upload, MUST set a paused state, show the Backup notification once (tap → ACC-01), and show "Backup paused" in ACC-01 (the SET-01 line comes with the 011 account card).
- **FR-038a**: Before any Drive backup, if this phone has no user data (FR-016) and the newest backup on the account has user data, an auto backup MUST NOT upload (not counted as a failure or a pause), and a manual backup MUST show a warning ("This phone has no data. Backing up now makes an empty backup the latest.") with "Back up anyway" and "Cancel".
- **FR-039**: The pause MUST end after a restore, "Keep this phone's data", or a manual backup; backups from the same device or older than the last known backup MUST never trigger the warning.
- **FR-040**: Every successful backup, restore, or "Keep this phone's data" MUST update this phone's last known backup (time and device).

**Backup metadata**

- **FR-041**: Every Drive backup MUST carry device ID, device name (manufacturer and model at backup time), app version and build, creation time, kind (manual or auto), per-module counts of non-deleted rows, schema version, and whether it is encrypted, both in the Drive file's listing properties and inside the backup file; the file's copy MUST win on disagreement. Local backup files MUST carry the same metadata inside the file.
- **FR-042**: Each module MUST provide its own count labels through its backup section, shown with plural-aware strings; the SET-02 Drive list MUST show device name and counts.
- **FR-043**: Backups without metadata (made before this feature) MUST stay listable and restorable, MUST show the device name stored by feature 008 when present ("Unknown device" otherwise), and MUST NOT trigger the conflict warning.

**Device identity and Android Auto Backup**

- **FR-044**: The device ID MUST be a random ID made on the first start and kept in a file Android never backs up; it MUST NOT be restored from any backup, and Erase all data and sign-out MUST keep it.
- **FR-045**: Android's backup rules MUST include the app database and exclude secure storage, the no-backup folder, receipt images, the safety copy (FR-019a), WorkManager's database, and caches, for cloud backup and device transfer, on Android 11 and lower and Android 12+.
- **FR-046**: On the first start where the settings table has a device ID copy but the device ID file is missing, or the two differ, the app MUST make a new device ID, turn app lock and biometric off when no PIN hash exists, clear the stored account and try a silent sign-in, treat the last known backup as none, reschedule notifications, run Restore purchase, show the "Finish setting up" sheet, and not show onboarding. If "Encrypt backup" was on, backups MUST fail with "Set your backup password in Backup and restore" and never be made unencrypted. (*Deferred to 011*: what happens to a restored `authMode`.)

**Privacy, notifications, and quality**

- **FR-047**: No backup of any kind MUST contain the PIN hash, lockout state, backup password, app lock or biometric settings, Google account details, purchase state, unlocks, or ad consent (011 adds `authMode` to this list).
- **FR-047a**: While signed out, user data MUST leave the device only in backup or export files the user saves or shares, or through Android's own device backup and device transfer (`docs/spec.md` §13); the app MUST make no Drive request. Drive backups go only to the signed-in user's own hidden app folder.
- **FR-048**: The Backup notification channel MUST also carry the one-time conflict pause notice, opening ACC-01; failure notices keep opening SET-02.
- **FR-049**: ACC-01, ACC-02, ACC-03, the SYS-02 button, and the "Finish setting up" sheet MUST show no ads.
- **FR-050**: All new screens and sheets MUST follow §15: shared components and tokens only, one primary action, loading/empty/error/content states (ACC-01 has no empty state; ACC-02, ACC-03, and Finish setting up are fixed-control sheets and MAY omit an empty state, as the plan says), `ConfirmDialog` for destructive actions, 48 dp targets, semantic labels, no clipping at 200% font scale, light and dark themes, and all strings from ARB files in English, Hindi, and Gujarati with placeholders and plurals.
- **FR-051**: Backup status text MUST say "Backed up to Google," never "Synced" or "Sync"; live multi-device sync is out of scope.

### Key Entities

- **Signed-in account**: the Google account used for backups on this phone: email, display name, photo address. Local only; one at a time. Signed in means the email is stored (interim I1).
- **Device identity**: a random ID unique to this install plus the device name read at backup time. Never backed up or restored.
- **Backup metadata**: device ID, device name, app version, creation time, kind, per-module counts, schema version, encrypted flag, attached to every backup.
- **Backup state**: change counter and the value captured at the last backup or restore, last background backup time, last known backup (time and device), paused-by-conflict flag and its notified flag, plus feature 008's last backup time, failures count, and auto backup settings.
- **Safety copy**: one local backup of this phone's data taken just before a restore from account replaced it; creation time, counts; deleted after 7 days or once restored.
- **Drive backup**: a feature 008 backup file in the account's hidden app folder, now with metadata; listed newest first.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user on a new phone can go from the first onboarding screen to Home with all their data restored in under 2 minutes for a backup of 10,000 transactions on a typical connection, with no more than 3 taps besides choosing the account. *(010 measures it through SYS-02 "Restore with Google"; Replaced in 011 by the path through Intro and AUTH-01.)*
- **SC-002**: After a restore, row counts and checksums of every module table match the source phone's backup in 100% of tested cases.
- **SC-003**: While signed in with auto backup on, changes are in a Drive backup no later than the next scheduled auto backup; and when the user leaves the app on an allowed network and no background backup was requested in the previous 15 minutes, they are backed up without waiting for the scheduled one (subject to Android's background work timing).
- **SC-004**: In tests, an auto backup never replaces a newer backup from another device without the user's choice (0 occurrences).
- **SC-005**: No backup of any kind contains the PIN, lockout state, or backup password (verified by inspecting every backup format and the Android backup rules).
- **SC-006**: A user who never signs in sees no difference in any other feature, and is never asked to sign in outside the places in FR-001.
- **SC-007**: Signing out or switching accounts never loses local data unless the user chose "Remove data from this phone", and after a failed backup only with the typed confirmation; for 7 days after a restore from account replaced a phone's data, 100% of that data can be brought back.
- **SC-008**: Every acceptance criterion copied above has at least one automated test, except those marked *Deferred to 011*.

## Assumptions

- **Built on feature 008**: the backup file format, encryption, receipts, restore (validate, upgrade, single transaction), Drive app-folder store, auto backup rotation (its rule changes per FR-035), 3-failures notification, Wi-Fi-only scheduling, backup password store, and the existing Google sign-in are reused; this feature adds the profile scopes, account state, metadata, background trigger, conflict rule, and the new screens.
- **Built on feature 009**: Restore purchase (PRM-01's ownership check) is called as is.
- **Built on feature 007**: SYS-04 for "Set app lock", Erase all data for "Remove data from this phone", and the lock rules are reused.
- **Feature 011 follows**: it adds `authMode`, AUTH-01, the SYS-02 Intro changes, the SET-01 account card, ACC-04, and the guest sign-in entry points in SET-01 and ACC-04, and replaces every interim behavior (I1–I6). It reuses `AccountService`, `AccountRestore`, ACC-02, ACC-03, the erase with a keep-list (FR-006a), and `FinishSetupSheet`.
- **Device name** comes from the system's manufacturer and model; when unavailable, "Android phone" is shown.
- **"Finish setting up"** is shown once per trigger (FR-028); "Not now" doesn't bring it back. It is not shown when app lock is already on.
- **Rotation days** are local calendar days of each backup's creation time; only backups made by DailyTrack in the account's app folder are rotated, whichever phone made them (`docs/spec.md` SET-02 and §16).
- **SET-02 "Disconnect"** from feature 008 becomes "Sign out" through ACC-03; disconnecting no longer turns Auto backup Off, since the setting is now kept for the next sign-in.
- **Google Cloud setup** (OAuth client, consent screen verification for the profile and app-folder scopes) is done by the developer outside the repository; without it, sign-in shows as unavailable as in feature 008.
- **Out of scope**: live multi-device sync (status says "Backed up to Google," never "Synced"), merging data from two phones, sign-in methods other than Google, other clouds, iOS, and any server.
