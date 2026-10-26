# Feature Specification: Google Account and Cloud Backup (§16, ACC-01, ACC-02, ACC-03)

**Feature Branch**: `010-google-account-backup`

**Created**: 2026-10-23

**Status**: Draft

**Input**: User description: "Feature: Google account and cloud backup. Implement section 16 of docs/spec.md: optional Google sign-in, ACC-01 Account, ACC-02 Restore choice, ACC-03 Sign out, the SYS-02 'Restore with Google' flow, automatic backup while signed in, the conflict warning, backup metadata, post-restore app lock prompt and restore purchase, 'Delete my backups', and Android Auto Backup with secure storage excluded. Reuse the backup engine and Drive code from feature 007; don't duplicate it. Copy the acceptance criteria from section 16 exactly. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §1 (scope), §4 (account, backup, and device settings; device identity), §5 (ACC-01–ACC-03 routes), §6 SYS-02 (Restore with Google), SYS-03 ("Forgot PIN?"), §10 SET-01 (Account row), SET-02 (Drive card, Drive list, auto backup, restore), PRM-01 (Restore purchase), §12 (Backup notification, rescheduling after restore), §13 (offline, data safety, Play compliance), §15 UI/UX guidelines, §16 Google account and cloud backup.

**Numbering note**: The input says to reuse the backup engine and Drive code from "feature 007". That code was built in feature 008 (`specs/008-backup-export-notifications-widget`: backup engine, Drive store, Google sign-in, auto backup, restore flows); 007 is settings, themes, and app lock. This spec reuses feature 008's code.

## Clarifications

### Session 2026-10-23

- Q: Should background backups count toward the same "keep the last 5 auto backups" limit as the daily backup? → A: No single count of 5: keep the newest auto backup of each of the last 5 local days (before today) that had one, plus today's newest auto backup, so at most 6 auto backups are kept; manual backups are unchanged.
- Q: After an encrypted backup is restored on a new phone, should that phone's new backups also be encrypted? → A: Yes: after any successful restore of an encrypted backup, "Encrypt backup" is turned on and the password that opened it is saved in this phone's secure storage, so later backups are encrypted with the same password.
- Q: When "Restore from account" replaces a phone that has its own data, should that data be saved first? → A: Yes: a copy of the current data is saved in the app's private storage before restoring, kept for 7 days (latest copy only), and SET-02 offers "Restore previous phone data" while it exists.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Get my data back on a new phone (Priority: P1)

A user has a new phone (or reinstalled the app). On the first onboarding step they tap "Restore with Google", pick their Google account, and the app finds their newest backup and restores it straight away, because this phone has nothing to lose. Onboarding is skipped; the app opens on Home with their language, currency, modules, transactions, and habits. Home then shows a one-time "Finish setting up" sheet offering to set an app lock and allow notifications, since the PIN is never backed up, and Pro is restored quietly if they bought it.

**Why this priority**: Getting data back after losing or changing a phone is the main reason to sign in at all. It also reuses feature 008's restore engine end to end, so it proves the account layer works.

**Independent Test**: Sign in on a fresh install from SYS-02 with an account that has a backup, and compare the restored data with the source phone; then repeat with an account that has no backup and with a cancelled sign-in.

**Acceptance Scenarios**:

1. **Given** a fresh install on SYS-02 step 1, **When** the user taps "Restore with Google" and signs in to an account with backups, **Then** the newest backup is restored without a choice sheet behind a "Restoring your data…" progress view, onboarding is marked done, and the app opens DSH-01 with the backup's language, currency, and modules.
2. **Given** the newest backup is encrypted and no saved password opens it, **When** the restore starts, **Then** the user is asked for the backup password first; a wrong password writes nothing; after a successful restore, "Encrypt backup" is on and the next backup is encrypted with that password.
3. **Given** a restore from onboarding finished, **Then** Home shows the "Finish setting up" sheet once, with "Set app lock" (→ SYS-04), "Allow notifications" (Android 13+), and "Not now", and Restore purchase runs in the background, showing "Pro restored" only if Pro is found.
4. **Given** the account has no backup, **Then** the user stays signed in, sees "No backup found on this account", continues onboarding from step 1, and their data is backed up once onboarding is done.
5. **Given** sign-in is cancelled or the restore fails, **Then** onboarding continues from step 1 with nothing written; a failed restore shows the SET-02 error message with "Try again".

**SYS-02 acceptance criteria** (copied from docs/spec.md):

- [ ] "Restore with Google" on an account with a backup restores it without a choice sheet, skips steps 2–4, and lands on DSH-01 with the backup's language, currency, and modules.
- [ ] After a restore from onboarding, the "Finish setting up" sheet appears once and Restore purchase runs.
- [ ] Cancelling sign-in, or an account with no backup, returns to onboarding with no data written.

---

### User Story 2 - Sign in and manage my account (ACC-01) (Priority: P1)

An existing user opens More → Account. Signed out, the screen explains that signing in is optional and backs up their data to their own Google Drive. They tap "Sign in with Google". If the account has no backup, a first backup is made at once and auto backup turns on (Daily) if it was off. Signed in, the screen shows their photo, name, email, when and from which phone the last backup was made, and its state, with "Back up now", "Restore", the auto backup setting, "Switch account", "Sign out", and "Delete my backups".

**Why this priority**: This is the home of the feature; every other flow starts here or reports its state here.

**Independent Test**: With a fake Google account and fake Drive, sign in, back up now, switch account, and delete backups, checking the screen and the Drive files after each step.

**Acceptance Scenarios**:

1. **Given** SET-01, **Then** the Account row shows "Sign in to back up your data" (helper "Optional") when signed out, and the photo, name, email, and "Last backup: …" (or "Backup paused" / "Backup failed" with an icon in `warning` color) when signed in; in both states it opens ACC-01.
2. **Given** ACC-01 signed out, **When** the user signs in to an account with a backup, **Then** ACC-02 opens; **When** it has none, **Then** a first backup runs and "Signed in. Your data is backed up." is shown.
3. **Given** a signed-in user, **When** they tap "Back up now", **Then** a manual backup runs (ignoring "Wi-Fi only") with progress on the button and a success message; no interstitial follows.
4. **Given** a signed-in user, **When** they tap "Switch account", **Then** the app backs up to the current account first (a failure offers "Switch anyway"), signs out keeping all local data, and opens the account chooser; the new account then follows the sign-in flow.
5. **Given** a signed-in user, **When** they tap "Delete my backups" and confirm a dialog naming the number of backups and the account, **Then** every DailyTrack backup in that account is deleted, local data and the sign-in stay, and the next auto backup makes a fresh one.
6. **Given** the phone is offline, **Then** account details still show, the status says "You're offline. Backups resume when you're back online.", and Back up now, Restore, Switch account, and Delete my backups are disabled with that reason while Sign out still works.
7. **Given** SET-02, **Then** its Drive card offers the same "Sign in with Google" when signed out and shows the account email (tap → ACC-01) when signed in.

**ACC-01 acceptance criteria** (copied from docs/spec.md):

- [ ] Signed out shows only the sign-in content; signed in shows name, email, photo (or initial), last backup time and device, and all actions.
- [ ] Signing in to an account without a backup makes a first backup, and Auto backup becomes Daily if it was Off.
- [ ] Signing in to an account with a backup opens ACC-02.
- [ ] Cancelling sign-in changes nothing.
- [ ] "Back up now" with a newer backup from another device shows the warning, and "Cancel" uploads nothing.
- [ ] "Delete my backups" removes every backup file in the app folder and leaves local data and the sign-in in place.
- [ ] Switch account backs up to the old account before signing out and never removes local data.
- [ ] Offline, the network actions are disabled with an explanation and Sign out still works.

**SET-01 acceptance criterion** (copied from docs/spec.md):

- [ ] The Account row shows the signed-out text when signed out and the account's name, email, and last backup time when signed in, and opens ACC-01 in both states.

---

### User Story 3 - Choose between my backup and this phone's data (ACC-02) (Priority: P1)

A user who already has data on this phone signs in to an account that also has a backup. A sheet shows the backup (date, which phone made it, counts like "1,240 transactions · 8 habits", Manual or Auto, encrypted or not) next to this phone's counts, and asks them to choose: "Restore from account" (replaces this phone's data) or "Keep this phone's data" (this phone's data becomes the newest backup). They can also open the full list of backups.

**Why this priority**: Without this choice, signing in on a phone with data would either overwrite it silently or leave the account's backup out of date. It protects data in both directions.

**Independent Test**: Seed different data on the phone and in a fake Drive backup, sign in, and check each choice's outcome on local rows and on Drive.

**Acceptance Scenarios**:

1. **Given** this phone has user data and the account has a backup, **When** sign-in finishes, **Then** ACC-02 opens and cannot be dismissed by dragging or tapping outside; opened from ACC-01 "Restore", it also has a close button that changes nothing.
2. **Given** ACC-02, **When** the user taps "Restore from account", **Then** a copy of this phone's current data is saved privately on the phone first (FR-019a), and the backup replaces all module data in one step, notifications are rescheduled, the widget refreshes, and "Restored 1,240 transactions and 8 habits." is shown; no second confirmation is asked, because the sheet already says the phone's data will be replaced.
3. **Given** ACC-02, **When** the user taps "Keep this phone's data", **Then** nothing is written locally, a backup of this phone starts and becomes the newest, the declined backup stays in the list, and no conflict warning appears for it later.
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
2. **Given** the same, **When** an auto backup runs, **Then** nothing is uploaded, the Backup notification is shown once (tap → ACC-01), and ACC-01 and SET-01 show "Backup paused".
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
3. **Given** "Keep data on this phone" (default), **When** the user signs out, **Then** ACC-01 shows signed out with "Signed out. Your data is still on this phone." and the app works fully.
4. **Given** "Remove data from this phone", **When** the user signs out, **Then** the same erase as "Erase all data" runs (module data, receipts, backup password, app lock), the Drive backups stay, and SYS-02 onboarding opens.
5. **Given** a signed-out user, **Then** no Drive request is made, pending Drive backups are cancelled, and the Auto backup setting is kept for the next sign-in.

**ACC-03 acceptance criteria** (copied from docs/spec.md):

- [ ] With changes not yet backed up, sign-out backs up first and enables "Sign out" only after the backup succeeds or the user picks "Sign out anyway."
- [ ] "Keep data on this phone" leaves every local row in place and the app fully usable.
- [ ] "Remove data from this phone" erases local data, keeps the Drive backups, and opens onboarding.
- [ ] After a failed backup, "Remove data from this phone" needs the typed "DELETE" confirmation.
- [ ] After sign-out, no Drive request is made until the user signs in again.

---

### User Story 7 - Android's own backup brings the app back safely (Priority: P3)

A user who never signed in moves to a new phone with Android's built-in backup or device transfer. The app's data comes along, but secure storage (PIN, backup password) does not. On the first start the app notices it was restored this way: it gets a new device ID, turns the app lock off if there is no PIN (so the user isn't locked out), treats the account as signed out until a silent sign-in works, reschedules notifications, restores Pro, and shows the "Finish setting up" sheet on Home instead of onboarding.

**Why this priority**: A free fallback for users who never sign in, but it depends on Android and needs little UI.

**Independent Test**: Simulate an Android restore (database present, no device ID file, no PIN hash, lock on) and start the app; inspect the backup rules files.

**Acceptance Scenarios**:

1. **Given** Android's backup rules, **Then** they include the app database and exclude secure storage, the no-backup folder with the device ID, receipt images, and caches, for both cloud backup and device-to-device transfer, on old and new Android versions.
2. **Given** the first start after such a restore, **Then** the app makes a new device ID, turns lock and biometric off when no PIN hash exists, clears the stored account and tries a silent sign-in, applies the conflict rule as if no backup were known, reschedules notifications, runs Restore purchase, and shows the "Finish setting up" sheet; onboarding is not shown.

**Section 16 acceptance criteria** (copied from docs/spec.md):

- [ ] Every screen outside this section works the same with no account signed in, and only the places listed at the top of this section offer sign-in.
- [ ] Neither a Drive backup file nor Android Auto Backup data contains the PIN hash, lockout state, or backup password (a test inspects the backup JSON and the backup rules XML).
- [ ] Going to the background with changed data starts a backup; going to the background again within 15 minutes does not; nothing starts when no data changed.
- [ ] With "Wi-Fi only" on, background and scheduled auto backups don't upload on mobile data and run once Wi-Fi is back.
- [ ] Auto backup does not upload over a newer backup from another device; it pauses, notifies once, and resumes after a restore, "Keep this phone's data," or a manual backup.
- [ ] Each Drive backup has `deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, and `counts` in both `appProperties` and the file's `meta`.
- [ ] Two installs never share a `deviceId`, including after a Drive restore or an Android Auto Backup restore.
- [ ] On the first start after an Android Auto Backup restore with app lock on and no PIN hash, the lock is turned off and the "Finish setting up" sheet is shown instead of locking the user out.

---

### Edge Cases

- **Silent sign-in fails at start** (token revoked, account removed from the phone): the account shows as signed out, all data stays, auto backups stop until the user signs in again.
- **Data written while a backup runs**: the "changed" mark stays set, so the next trigger backs up again.
- **Backup made before this feature** (no metadata): listed with date, size, and the device name feature 008 already stored ("Unknown device" only when there is none), without counts; never counted as "from another device" by the conflict rule; restorable as before.
- **Encrypted backup on a new phone**: the password is not on the phone, so it is asked for at restore; once the restore succeeds, "Encrypt backup" is turned on and that password is saved in secure storage (FR-019b), so no unencrypted backup is uploaded afterwards. A failed or cancelled restore saves nothing.
- **Sign-in from SYS-03 "Forgot PIN?"**: follows the feature 008 flow, now using the shared account sign-in; the user ends up signed in.
- **Switch to the same account** in the chooser: treated as a normal sign-in to that account.
- **Delete my backups while a background backup is uploading**: the upload finishes and becomes the only backup; nothing is restored or lost locally.
- **No room for the safety copy**: the restore from account does not start, and the error explains that the phone needs more free space; this phone's data is untouched.
- **Second restore within 7 days**: the new safety copy replaces the previous one, so only the data from just before the latest restore can be recovered.
- **Sign out while offline**: goes straight to the failed-backup state; "Remove data" then needs the typed "DELETE".
- **Pro check after restore offline**: Restore purchase fails quietly and runs again on the next start, as in PRM-01.
- **"Finish setting up" when app lock is already on** (e.g. Drive restore on a phone with a PIN): not shown.
- **Two backgroundings during a Wi-Fi wait**: only one backup is queued.
- **Empty phone, account with data** (e.g. after Erase all data while signed in): auto backups don't upload an empty backup over it; a manual backup warns first (FR-038a), and SYS-02 offers "Restore with Google".
- **Long text**: account names, emails, and device names are shown as given, never translated, and wrap or ellipsize without clipping at 200% font scale.

## Requirements *(mandatory)*

### Functional Requirements

**Account and sign-in**

- **FR-001**: Signing in with Google MUST be optional; every feature outside this one MUST work the same with no account, and sign-in MUST be offered only from SYS-02 step 1, the SET-01 Account row (ACC-01), the SET-02 Drive card, and SYS-03 "Forgot PIN?".
- **FR-002**: Sign-in MUST request only the account's email and basic profile plus access to the app's own hidden Drive folder; one account is signed in at a time.
- **FR-003**: The account's email, display name, and photo address MUST be stored on the phone on sign-in, cleared on sign-out, and never included in any backup.
- **FR-004**: On start, the app MUST try a silent sign-in; if it fails, the account MUST show as signed out and all data MUST stay.
- **FR-005**: Feature 008's existing sign-in, Drive storage, backup engine, restore flow, auto backup schedule, and backup password store MUST be reused; this feature MUST NOT add a second implementation of any of them. SET-02's Drive card MUST use the same sign-in and sign-out as ACC-01 (replacing its separate "Connect" and "Disconnect").
- **FR-006**: Signing in MUST set Auto backup to Daily if it was Off.
- **FR-006a**: SET-01 "Erase all data" MUST remove data from this phone only: it MUST keep the sign-in, the Auto backup setting, the device ID, and every Drive backup (it no longer signs out, unlike feature 008). It still deletes the backup password and the safety copy.

**ACC-01 Account**

- **FR-007**: ACC-01 (`/more/account`, pushed from SET-01) MUST show the signed-out layout (illustration, title, three benefit points, "Sign in with Google", PIN footnote) or the signed-in layout (account card, backup status, Back up now, Restore, Auto backup row → SET-02, Switch account, Sign out, Delete my backups) as described in §16.
- **FR-008**: The backup status MUST show the last backup's time and device and one of: Backed up, Backing up…, Waiting for Wi-Fi, Backup paused (with "Review" → ACC-02 for that backup), or Backup failed (with the error message); status MUST never be shown by color alone.
- **FR-009**: Sign-in success MUST open ACC-02 if the account has a backup, or make a first backup and show "Signed in. Your data is backed up." if not; cancel MUST change nothing; failure MUST show "Couldn't sign in. Check your connection and try again."
- **FR-010**: "Back up now" MUST run a manual Drive backup under the conflict rule, ignoring "Wi-Fi only", with progress and a success message, and MUST NOT trigger an interstitial.
- **FR-011**: "Restore" MUST open ACC-02 for the newest backup, with "See all backups" opening the SET-02 Drive list.
- **FR-012**: "Switch account" MUST back up to the current account first ("Switch anyway" on failure), sign out without touching local data, and open the account chooser; a cancelled chooser MUST leave the user signed out with data kept.
- **FR-013**: "Delete my backups" MUST confirm with a dialog naming the backup count and account, then delete every DailyTrack backup (manual and auto) in that account's app folder, keep local data and the sign-in, and reset the last known backup so the next auto backup starts fresh.
- **FR-014**: ACC-01 MUST show local account details immediately and load backup status in the background (skeleton while loading); offline it MUST disable the network actions with the offline message and keep Sign out enabled; a Drive read error MUST show an error with "Try again" in the status area only. Signed out is the screen's empty state.
- **FR-015**: The SET-01 Account row MUST appear above General and show the signed-out or signed-in content described in User Story 2.

**ACC-02 Restore choice**

- **FR-016**: The phone MUST count as having no data when every module reports zero user rows, seeded defaults excluded; in that case the newest backup MUST be restored without showing ACC-02.
- **FR-017**: Otherwise ACC-02 MUST show the backup summary (date and time, device name or "From this phone", counts, Manual or Auto, encrypted badge) read from metadata without downloading the file, this phone's counts, and the choices "Restore from account", "Keep this phone's data", and "See all backups".
- **FR-018**: A password field MUST appear only for an encrypted backup the saved password cannot open; a wrong password MUST show "That password didn't work" and write nothing.
- **FR-019**: "Restore from account" MUST run feature 008's restore (validate, upgrade, replace in one transaction), then mark that backup as the last known one, clear the "changed" mark and any pause, reschedule notifications, refresh the widget, and show a success message with counts. A failure MUST leave all data unchanged.
- **FR-019a**: Before "Restore from account" (or a restore from the SET-02 Drive list) replaces a phone that has user data (FR-016), the app MUST save a copy of the current data, in feature 008's backup format with receipts, in the app's private storage, replacing any earlier copy. If the copy cannot be saved (e.g. storage full), the restore MUST NOT start and a plain-language error MUST say why. The copy MUST be kept for 7 days, never uploaded, excluded from Android Auto Backup, and deleted by Erase all data and "Remove data from this phone". While it exists, SET-02 MUST show "Restore previous phone data" with the copy's date and counts; it restores through feature 008's summary and "Replace current data?" confirmation, and the copy is deleted after it is restored successfully.
- **FR-019b**: After any successful restore of an encrypted backup (ACC-02, FR-016, SYS-02, the SET-02 Drive list, or a SET-02 local backup file), the app MUST turn "Encrypt backup" on and save the password that opened the backup in secure storage, replacing any saved one, before any later backup runs. The password MUST NOT be saved when the restore fails or is cancelled.
- **FR-020**: "Keep this phone's data" MUST write no local data, mark the newest backup as the last known one, clear any pause, and start a backup.
- **FR-021**: After sign-in ACC-02 MUST NOT be dismissible by drag or outside tap; from ACC-01 "Restore" it MUST also have a close button that changes nothing.

**ACC-03 Sign out**

- **FR-022**: ACC-03 MUST first back up changes not yet backed up as a manual backup under the conflict rule (a declined warning counts as a failure), then offer "Keep data on this phone" (default) or "Remove data from this phone".
- **FR-023**: On backup failure it MUST offer "Try again" and "Sign out anyway"; after "Sign out anyway", "Remove data from this phone" MUST need the typed "DELETE" confirmation.
- **FR-024**: Sign out MUST sign the account out, clear the account details and last known backup, cancel pending Drive backups, and stop background backups, keeping the Auto backup setting.
- **FR-025**: "Remove data from this phone" MUST run the same erase as SET-01 "Erase all data", keep the device ID, keep the Drive backups, and open SYS-02; "Keep data on this phone" MUST return to ACC-01 signed out with "Signed out. Your data is still on this phone."

**SYS-02 Restore with Google and Finish setting up**

- **FR-026**: SYS-02 step 1 MUST show a secondary "Restore with Google" button below the language chips that signs in and restores the newest backup under FR-016 behind a full-screen progress view, asking for the password first when needed.
- **FR-027**: After a successful restore from onboarding, the remaining steps MUST be skipped, onboarding marked done, and the app MUST open DSH-01 with the restored preferences.
- **FR-028**: After any restore made by this feature (SYS-02, FR-016, or the Android Auto Backup start) while app lock is off, Home MUST show the "Finish setting up" sheet once, with "Set app lock" (→ SYS-04), "Allow notifications" (Android 13+ only), and "Not now".
- **FR-029**: After a restore from SYS-02 or an Android Auto Backup restore, Restore purchase (PRM-01) MUST run in the background without UI, except a "Pro restored" message when Pro is found.
- **FR-030**: If the account has no backup, SYS-02 MUST show "No backup found on this account" and continue from step 1 signed in; a cancelled sign-in or failed restore MUST continue from step 1 with nothing written.

**Auto backup while signed in**

- **FR-031**: Any write to a backed-up table or a restorable preference MUST raise a change counter; data counts as changed since the last backup while the counter differs from the value captured in the last successful backup or restore, so a write made while a backup runs keeps the data changed.
- **FR-032**: While signed in and Auto backup is not Off, going to the background MUST start a background backup when onboarding is done, data changed, and the last background backup was requested at least 15 minutes earlier; it MUST finish even if the app is closed.
- **FR-033**: Feature 008's scheduled daily or weekly auto backup MUST keep running and MUST skip the upload when nothing changed.
- **FR-034**: Background and scheduled auto backups MUST wait for Wi-Fi when "Wi-Fi only" is on; at most one background backup may wait at a time.
- **FR-035**: Background and scheduled backups are both auto backups. After each successful auto backup, Drive MUST keep only today's newest auto backup plus the newest auto backup of each of the 5 most recent earlier local days that had one (at most 6 auto backups), and delete the other auto backups of that account; manual backups MUST never be deleted automatically. This replaces feature 008's "keep the last 5 auto backups" rule. Background backups MUST count toward the 3-failures notification and MUST never trigger ads.
- **FR-036**: Changes made while signed out MUST be included in the first backup after sign-in.

**Conflict rule**

- **FR-037**: The newest backup by creation time MUST be the default restore target.
- **FR-038**: Before any Drive backup, the app MUST read the newest backup's metadata; if it was made by a different device and is newer than this phone's last known backup, a manual backup MUST show the warning dialog ("Back up anyway" / "Cancel") and an auto backup MUST NOT upload, MUST set a paused state, show the Backup notification once (tap → ACC-01), and show "Backup paused" in ACC-01 and SET-01.
- **FR-038a**: Before any Drive backup, if this phone has no user data (FR-016) and the newest backup on the account has user data, an auto backup MUST NOT upload (not counted as a failure or a pause), and a manual backup MUST show a warning ("This phone has no data. Backing up now makes an empty backup the latest.") with "Back up anyway" and "Cancel".
- **FR-039**: The pause MUST end after a restore, "Keep this phone's data", or a manual backup; backups from the same device or older than the last known backup MUST never trigger the warning.
- **FR-040**: Every successful backup, restore, or "Keep this phone's data" MUST update this phone's last known backup (time and device).

**Backup metadata**

- **FR-041**: Every Drive backup MUST carry device ID, device name (manufacturer and model at backup time), app version and build, creation time, kind (manual or auto), per-module counts of non-deleted rows, schema version, and whether it is encrypted, both in the Drive file's listing properties and inside the backup file; the file's copy MUST win on disagreement. Local backup files MUST carry the same metadata inside the file.
- **FR-042**: Each module MUST provide its own count labels through its backup section, shown with plural-aware strings; the SET-02 Drive list MUST show device name and counts.
- **FR-043**: Backups without metadata (made before this feature) MUST stay listable and restorable, MUST show the device name stored by feature 008 when present ("Unknown device" otherwise), and MUST NOT trigger the conflict warning.

**Device identity and Android Auto Backup**

- **FR-044**: The device ID MUST be a random ID made on the first start and kept in a file Android never backs up; it MUST NOT be restored from any backup, and Erase all data and sign-out MUST keep it.
- **FR-045**: Android's backup rules MUST include the app database and exclude secure storage, the no-backup folder, receipt images, the safety copy (FR-019a), and caches, for cloud backup and device transfer, on Android 11 and lower and Android 12+.
- **FR-046**: On the first start where the database exists but the device ID file does not, the app MUST make a new device ID, turn app lock and biometric off when no PIN hash exists, clear the stored account and try a silent sign-in, treat the last known backup as none, reschedule notifications, run Restore purchase, show the "Finish setting up" sheet, and not show onboarding.

**Privacy, notifications, and quality**

- **FR-047**: No backup of any kind MUST contain the PIN hash, lockout state, backup password, app lock or biometric settings, Google account details, purchase state, unlocks, or ad consent.
- **FR-048**: The Backup notification channel MUST also carry the one-time conflict pause notice, opening ACC-01; failure notices keep opening SET-02.
- **FR-049**: ACC-01, ACC-02, ACC-03, the SET-01 Account row, the SYS-02 button, and the "Finish setting up" sheet MUST show no ads.
- **FR-050**: All new screens and sheets MUST follow §15: shared components and tokens only, one primary action, loading/empty/error/content states (ACC-02 and ACC-03 are fixed-control sheets and MAY omit an empty state if the plan says so), `ConfirmDialog` for destructive actions, 48 dp targets, semantic labels, no clipping at 200% font scale, light and dark themes, and all strings from ARB files in English, Hindi, and Gujarati with placeholders and plurals.

### Key Entities

- **Signed-in account**: the Google account used for backups on this phone: email, display name, photo address. Local only; one at a time.
- **Device identity**: a random ID unique to this install plus the device name read at backup time. Never backed up or restored.
- **Backup metadata**: device ID, device name, app version, creation time, kind, per-module counts, schema version, encrypted flag, attached to every backup.
- **Backup state**: change counter and the value captured at the last backup or restore, last background backup time, last known backup (time and device), paused-by-conflict flag, plus feature 008's last backup time, failures count, and auto backup settings.
- **Safety copy**: one local backup of this phone's data taken just before a restore from account replaced it; creation time, counts; deleted after 7 days or once restored.
- **Drive backup**: a feature 008 backup file in the account's hidden app folder, now with metadata; listed newest first.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user on a new phone can go from the first onboarding screen to Home with all their data restored in under 2 minutes for a backup of 10,000 transactions on a typical connection, with no more than 3 taps besides choosing the account.
- **SC-002**: After a restore, row counts and checksums of every module table match the source phone's backup in 100% of tested cases.
- **SC-003**: While signed in with auto backup on, changes are in a Drive backup no later than the next scheduled auto backup; and when the user leaves the app on an allowed network and no background backup was requested in the previous 15 minutes, they are backed up without waiting for the scheduled one (subject to Android's background work timing).
- **SC-004**: In tests, an auto backup never replaces a newer backup from another device without the user's choice (0 occurrences).
- **SC-005**: No backup of any kind contains the PIN, lockout state, or backup password (verified by inspecting every backup format and the Android backup rules).
- **SC-006**: A user who never signs in sees no difference in any other feature, and is never asked to sign in outside the four listed places.
- **SC-007**: Signing out or switching accounts never loses local data unless the user chose "Remove data from this phone", and after a failed backup only with the typed confirmation; for 7 days after a restore from account replaced a phone's data, 100% of that data can be brought back.
- **SC-008**: Every acceptance criterion copied above has at least one automated test.

## Assumptions

- **Built on feature 008**: the backup file format, encryption, receipts, restore (validate, upgrade, single transaction), Drive app-folder store, auto backup rotation (its rule changes per FR-035), 3-failures notification, Wi-Fi-only scheduling, backup password store, and the existing Google sign-in are reused; this feature adds the profile scopes, account state, metadata, background trigger, conflict rule, and the new screens.
- **Built on feature 009**: Restore purchase (PRM-01's ownership check) is called as is.
- **Built on feature 007**: SYS-04 for "Set app lock", Erase all data for "Remove data from this phone", and the lock rules are reused.
- **Device name** comes from the system's manufacturer and model; when unavailable, "Android phone" is shown.
- **"Finish setting up"** is shown once per restore; "Not now" doesn't bring it back. It is not shown when app lock is already on.
- **Rotation days** are local calendar days of each backup's creation time; only backups made by DailyTrack in the account's app folder are rotated, whichever phone made them. `docs/spec.md` SET-02 and §16 still say "keep the last 5 auto backups" and must be updated to the FR-035 rule before implementation (Constitution I).
- **SET-02 "Disconnect"** from feature 008 becomes "Sign out" through ACC-03; disconnecting no longer turns Auto backup Off, since the setting is now kept for the next sign-in.
- **Google Cloud setup** (OAuth client, consent screen verification for the profile and app-folder scopes) is done by the developer outside the repository; without it, sign-in shows as unavailable as in feature 008.
- **Out of scope**: live sync between phones, merging data from two phones, sign-in methods other than Google, other clouds, iOS, and any server.
