# Feature Specification: Login and Guest Mode (§14 T3.6, AUTH-01, ACC-04)

**Feature Branch**: `011-login-guest-mode`

**Created**: 2026-10-27

**Status**: Draft

**Input**: User description: "Feature: Login and guest mode. Implement §14 T3.6 from docs/spec.md: the authMode setting, its migration for existing installs, and the router redirect (§5); SYS-02 Intro without "Restore with Google" or app lock; AUTH-01 Login with Google and guest paths, offline and failure states, and the "Finish setting up" sheet after every login; the SET-01 account card for guest and Google states; guest sign-in from SET-01, SET-02, and ACC-04 (§16 "Guest sign-in"); ACC-04 Log out of guest; and ACC-03 sign-out opening AUTH-01. Replace every interim behavior marked "Replaced in 011" in specs/010-google-account-backup/plan.md. Reuse AccountService, ACC-02, and the backup engine from feature 010. Copy the acceptance criteria for SYS-01, SYS-02, AUTH-01, SET-01, ACC-03, ACC-04, and §16 "Guest sign-in" exactly. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §1 (scope), §4 (`authMode`, `finishSetupPending`, Erase all data keep rules), §5 (startup flow, router redirect, routes), §6 SYS-01, SYS-02, AUTH-01, SYS-03 ("Forgot PIN?"), §10 SET-01 and SET-02 (Drive card), §11 (no ads on AUTH-01 and ACC-04), §12 (rescheduling after restore), §13 (offline, data safety), §14 T3.6 and the T3.5 interim note, §15 UI/UX guidelines, §16 (rules, account state, Android Auto Backup start, Guest sign-in, ACC-01–ACC-04).

**Builds on**: feature 010 (`specs/010-google-account-backup`): `AccountService` (sign-in, sign-out, silent sign-in), `AccountRestore`, ACC-01, ACC-02 (`showRestoreChoice`), ACC-03, `FinishSetupSheet`, `BackupStatusPolicy`, the backup engine, auto backup, the conflict rule, the empty-phone guard, the safety copy, and the Erase all data keep-list (010 FR-006a). This feature changes none of their backup or restore rules; it adds the sign-in mode around them and replaces 010's interim behavior I1–I8 (010 plan "Interim behavior until feature 011").

## Clarifications

### Session 2026-10-27

- Q: Does Erase all data still reset onboarding and the device preferences now that login exists (today it clears every setting and lands on Intro)? → A: No. Erase all data (SET-01, SYS-03 "Forgot PIN?", ACC-03 "Remove data") keeps onboarding done and the device preferences that ACC-04 keeps, and lands on Home (AUTH-01 after ACC-03), never Intro. Recorded in `docs/spec.md` §4 and SET-01.
- Q: When a guest uses SYS-03 "Forgot PIN?" → "Restore from Google Drive" and the restore succeeds, are they signed in or still a guest? → A: Signed in: `authMode = google`, Auto backup Daily if it was Off, and the SET-01 card shows the Google state; a cancelled or failed sign-in or a failed restore keeps them a guest.
- Q: What does the SET-01 account card's status line show when ACC-01 would show "Waiting for Wi-Fi" or "You're offline"? → A: The last successful state: "Backed up to Google · <time>", or "Not backed up yet" when there is none; "Waiting for Wi-Fi" and offline appear on ACC-01 only.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start as a guest, online or offline (Priority: P1)

A new user installs the app, picks language, currency, and modules on the 4-step Intro, and taps "Get started" (or Skip). Intro never offers sign-in, restore, or app lock; it ends by opening AUTH-01 Login. There they read "Keep your data safe" and choose "Continue as guest." The app opens Home at once, with no network request, and the user's data stays only on this phone. From then on, every start goes straight to Home (through SYS-03 Unlock if they later set app lock).

**Why this priority**: Every new user passes through Intro and AUTH-01, and the guest path is the one that must always work, including offline. Without it the app cannot be used at all after this feature lands.

**Independent Test**: On a fresh install with fake sign-in and Drive clients, finish Intro, tap "Continue as guest" online and offline, and check that Home opens, `authMode` is `guest`, back from AUTH-01 never shows Intro, a restart opens Home, and the fakes record zero calls.

**Acceptance Scenarios**:

1. **Given** a fresh install on Intro, **When** the user taps "Get started" or Skip, **Then** onboarding is marked done and AUTH-01 replaces Intro; Android back on AUTH-01 closes the app.
2. **Given** AUTH-01, **When** the user taps "Continue as guest" (online or offline), **Then** `authMode` becomes `guest`, Home opens, and no sign-in, Drive, or other network request is made.
3. **Given** the app is closed on Intro, **When** it starts again, **Then** Intro shows again; **Given** it is closed on AUTH-01, **Then** AUTH-01 shows again, not Intro.
4. **Given** a guest with app lock off, **When** they reach Home after login, **Then** the "Finish setting up" sheet appears once (User Story 4).

**SYS-02 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] Selected language persists and applies after app restart.
- [ ] Denying the notification permission does not block onboarding.
- [ ] User cannot turn off both modules.
- [ ] "Get started" and Skip both mark onboarding done and open AUTH-01; back on AUTH-01 never returns to Intro.
- [ ] Intro shows no "Restore with Google" or "Set app lock" option.
- [ ] Closing the app during Intro shows Intro again on the next start; closing it on AUTH-01 shows AUTH-01, not Intro.

---

### User Story 2 - Sign in with Google on AUTH-01 and get my data back (Priority: P1)

A user who had the app on another phone opens it on a new one, goes through Intro, and taps "Continue with Google" on AUTH-01. After choosing an account, the app finds the newest backup and, because this phone has no user data, restores it at once behind "Restoring your data…" (asking for the backup password first if it is encrypted). Home opens with the backup's data, language, currency, and modules, and Pro comes back quietly if they bought it. A user whose account has no backup is simply signed in, auto backup turns on (Daily) if it was off, and a first backup runs. A user who kept data on this phone after signing out gets the ACC-02 choice and must pick one. When sign-in is cancelled, fails, or the phone is offline, AUTH-01 explains what happened in plain words, nothing is written, and "Continue as guest" stays available. When the restore fails after sign-in, the phone's data is untouched and the user can try again or continue without restoring.

**Why this priority**: Getting data back on a new phone is the reason to sign in at all, and AUTH-01 is now the only place a new install can do it (Intro no longer offers "Restore with Google").

**Independent Test**: With fake Google sign-in and a fake Drive, run "Continue with Google" for an account with no backup, an account with a backup on an empty phone, an account with a backup on a phone with data, an encrypted backup, a cancelled sign-in, a failed sign-in, offline, and a restore that fails, checking the screen, `authMode`, Auto backup, Drive uploads, and local rows after each.

**Acceptance Scenarios**:

1. **Given** AUTH-01 and an account with no backup, **When** sign-in succeeds, **Then** `authMode` becomes `google`, Auto backup becomes Daily if it was Off, a first backup runs, and Home opens.
2. **Given** an account with a backup and no user data on this phone, **When** sign-in succeeds, **Then** the newest backup is restored without a choice sheet (password first if encrypted and the saved one doesn't open it), Home opens with the backup's data, language, currency, and modules, and Restore purchase runs in the background, showing "Pro restored" only if Pro is found.
3. **Given** an account with a backup and user data on this phone, **When** sign-in succeeds, **Then** ACC-02 opens and can't be dismissed; after either choice, `authMode` is `google` and Home opens.
4. **Given** sign-in is cancelled or fails, **Then** AUTH-01 stays open with "Sign-in was cancelled. Try again or continue as a guest." or "Couldn't sign in. Check your connection and try again." and "Try again"; `authMode` stays `none` and no data or account key is written.
5. **Given** the phone is offline, **When** the user taps "Continue with Google", **Then** the inline error "You're offline. Connect to the internet to sign in with Google, or continue as a guest." appears with "Try again" and nothing is written.
6. **Given** the restore after sign-in fails (download, decrypt, validation, or lost connection), **Then** "Couldn't restore. Your data on this phone wasn't changed." is shown with "Try again" and "Continue without restoring"; the latter sets `authMode = google` with this phone's data as it is, the empty-phone guard keeps auto backup from replacing the account's backup with an empty one, and ACC-01 "Restore" stays available.
7. **Given** sign-in is in progress, **Then** "Continue with Google" shows progress and both buttons are disabled.

**AUTH-01 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] On a fresh install, Intro opens AUTH-01; back on AUTH-01 closes the app and never shows Intro.
- [ ] "Continue as guest" sets `authMode = guest` and opens Home without any sign-in, Drive, or network call (a fake sign-in and Drive client record zero calls), online and offline.
- [ ] "Continue with Google" on an account with no backup sets `authMode = google`, turns Auto backup to Daily if it was Off, runs a first backup, and opens Home.
- [ ] "Continue with Google" on an account with a backup and no user data on the phone restores the newest backup without a choice sheet and opens Home with the backup's data, language, currency, and modules; Restore purchase runs.
- [ ] "Continue with Google" with user data on the phone opens ACC-02 before Home, and the sheet can't be dismissed without a choice.
- [ ] Cancelled or failed sign-in stays on AUTH-01 with the inline error and "Try again"; `authMode` stays none and no data or account key is written.
- [ ] Offline, "Continue with Google" shows the offline inline error and writes nothing, and "Continue as guest" still opens Home.
- [ ] A failed restore after sign-in leaves this phone's data unchanged and offers "Try again" and "Continue without restoring."
- [ ] After login on either path with app lock off, the "Finish setting up" sheet appears once on Home and not again after a restart.
- [ ] With app lock on (data kept after sign-out), leaving AUTH-01 on either path shows SYS-03 before Home.
- [ ] No ad is requested while AUTH-01 is open.

---

### User Story 3 - Existing users and returning starts go to the right screen (Priority: P1)

A user who installed an earlier version (before login existed) updates the app. On the first start, the app works out their sign-in mode once: `google` if they were signed in to a Google account, otherwise `guest`; they never see AUTH-01 and keep using the app as before. On every later start, the app routes by onboarding, sign-in mode, and app lock: Intro if onboarding isn't done, AUTH-01 if no login was chosen (even with app lock on), SYS-03 if locked, else Home. The start also tidies up the account: a revoked or removed Google account turns the user into a guest with all data kept; account keys left behind by an interrupted sign-in are cleared; an offline start stays signed in.

**Why this priority**: Without the migration, every existing user would be sent to a login screen they never asked for, or a signed-in user would be treated as signed out. Routing decides what every user sees first.

**Independent Test**: Seed settings for each combination (fresh, updated with and without an account, onboarding not done, `authMode` none/guest/google, lock on/off, revoked token, leftover keys, offline) and check the first screen and the resulting `authMode` and account keys.

**Acceptance Scenarios**:

1. **Given** an updated install with onboarding done, no `authMode`, and an account email saved, **When** the app starts, **Then** `authMode` becomes `google` once and the user lands on SYS-03 or Home; without an account email it becomes `guest`.
2. **Given** an updated install with onboarding not done and no `authMode`, **Then** `authMode` stays `none` and Intro opens, followed by AUTH-01.
3. **Given** onboarding done and `authMode` `none` with app lock on, **Then** AUTH-01 opens, not SYS-03; after login, SYS-03 shows before Home.
4. **Given** `authMode` `google` and silent sign-in fails because the token was revoked or the account was removed, **Then** the account keys are cleared, `authMode` becomes `guest`, all data is kept, and SET-01 shows the guest card; an offline start keeps `authMode = google`.
5. **Given** account keys are found while `authMode` is `none` or `guest` (the app closed during sign-in), **Then** the keys are cleared and the app signs out of Google, so the user can sign in again.
6. **Given** the first start after an Android Auto Backup restore, **Then** silent sign-in is tried: on success a restored `google` stays `google`; on failure it becomes `guest`; a restored `guest` or `none` is kept; Intro is not shown again; AUTH-01 is shown only if the restored `authMode` is `none`.
7. **Given** `authMode` is `none`, **When** the app returns from the background, **Then** no re-lock redirect to SYS-03 happens (AUTH-01 stays).

**SYS-01 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once.
- [ ] Returning user with `authMode` guest or google and lock on lands on SYS-03; without lock lands on DSH-01.
- [ ] Onboarding done with `authMode` none lands on AUTH-01, even with app lock on.
- [ ] An updated install with onboarding done and no `authMode` gets `guest`, or `google` when a Google account is signed in, and never sees AUTH-01.
- [ ] Ads SDK is not initialized when Remove Ads is purchased.

---

### User Story 4 - Finish setting up after every login (Priority: P2)

Right after login on either path, if app lock is off, Home shows the "Finish setting up" bottom sheet once: "Set app lock" (→ SYS-04), "Allow notifications" (only on Android 13+ when the permission isn't granted), and "Not now." Any choice, or dismissing the sheet, means it won't come back until the next login. If app lock is already on, leaving AUTH-01 goes through SYS-03 and the sheet is not shown.

**Why this priority**: Intro no longer offers app lock or relies on the user finding it in Settings; this sheet is now the one prompt that protects a money app after login. It is secondary to getting in at all.

**Independent Test**: Log in as a guest and with Google (lock off, then lock on), check the sheet appears once on Home, choose each action, restart, and check it does not return.

**Acceptance Scenarios**:

1. **Given** login on either AUTH-01 path with app lock off, **Then** Home shows the sheet once; after any choice or dismissal and a restart, it does not show.
2. **Given** notifications are already granted or the phone runs Android 12 or lower, **Then** "Allow notifications" is not offered.
3. **Given** app lock is on when leaving AUTH-01, **Then** SYS-03 shows before Home and the sheet does not.
4. **Given** a later login (after ACC-03 or ACC-04), **Then** the sheet is offered again if app lock is off.

---

### User Story 5 - See my account on More and sign in from there as a guest (Priority: P2)

On the More tab, the first item is now an account card. As a guest it shows a person icon, "Guest · Data saved only on this phone," and a "Sign in with Google" button. Signed in, it shows the profile photo (or initial), name, email, and the backup status ("Backed up to Google · 5 min ago," "Backing up…," "Not backed up yet," or "Backup paused" / "Backup failed" with a warning icon), and tapping it opens ACC-01. A guest can sign in from that card, from the SET-02 Drive card, or from ACC-04 "Sign in with Google instead," without leaving the app: an account with no backup gets this phone's data at once; an account with a backup opens ACC-02, so the result is always either the account's data or this phone's data, never a mix.

**Why this priority**: This is how a guest upgrades to backups later and how a signed-in user sees at a glance that their data is safe. It depends on User Stories 1–3.

**Independent Test**: With fakes, render SET-01 in each state (guest; Google backed up, backing up, not backed up yet, paused, failed; no photo), tap each entry point as a guest for accounts with and without a backup, cancel and fail sign-in, and go offline; check the card, `authMode`, Auto backup, and local rows.

**Acceptance Scenarios**:

1. **Given** a guest on SET-01, **Then** the account card is the first item, is not tappable itself, and "Log out of guest" appears in the Data group.
2. **Given** a guest taps "Sign in with Google" (SET-01 card, SET-02 Drive card, or ACC-04) and signs in to an account with no backup, **Then** this phone's data is backed up, "Signed in. Your data is backed up." is shown, `authMode` is `google`, Auto backup is Daily if it was Off, and the card switches to the Google state; if that first backup fails, the user stays signed in and auto backup retries.
3. **Given** the account has a backup, **Then** ACC-02 opens and can't be dismissed (or, if this phone has no user data, the newest backup is restored without the sheet).
4. **Given** sign-in is cancelled or fails, **Then** the user stays a guest with every local row unchanged; a failure shows "Couldn't sign in. Check your connection and try again."; offline, the button shows "Connect to the internet to sign in with Google" and makes no request.
5. **Given** a signed-in user, **When** they tap the card, **Then** ACC-01 opens; "Log out of guest" is not shown.
6. **Given** ACC-01 "Switch account" and the user cancels the account chooser, **Then** `authMode` becomes `guest`, all data is kept, and SET-01 shows the guest card.
7. **Given** any screen or status text about the account or backups, **Then** it never says "Synced" or "Sync."

**SET-01 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] Changing currency changes formatting only; stored amounts are not converted.
- [ ] "Ad privacy choices" is visible whenever the UMP SDK reports a privacy options requirement.
- [ ] The account card is the first item. As a guest it shows "Guest · Data saved only on this phone" and "Sign in with Google," which starts guest sign-in; signed in with Google it shows the name, email, photo (or initial), and "Backed up to Google" with the last backup's relative time, and opens ACC-01.
- [ ] "Log out of guest" appears in the Data group only in the guest state and opens ACC-04.
- [ ] No text on this screen says "Synced" or "Sync."

**§16 "Guest sign-in" acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] Signing in to an account without a backup backs up this phone's data, sets `authMode = google`, turns Auto backup to Daily if it was Off, and the SET-01 card switches to the Google state.
- [ ] Signing in to an account with a backup opens ACC-02; "Restore from account" replaces this phone's data and "Keep this phone's data" makes this phone's data the account's latest backup, and no rows from the two are combined.
- [ ] Cancelling or failing sign-in leaves `authMode = guest` and every local row unchanged.

---

### User Story 6 - Sign out lands on Login (ACC-03) (Priority: P2)

A signed-in user signs out from ACC-01. ACC-03 still backs up their latest changes first and asks whether to keep or remove the data on this phone (feature 010). After either choice, `authMode` becomes `none` and the app opens AUTH-01 with the back stack cleared, never Intro and never the More tab. Keeping the data shows "Signed out. Your data is still on this phone."; "Continue as guest" then keeps using that data, and "Continue with Google" offers ACC-02 if the account has a backup. Removing the data erases this phone, keeps the Drive backups, and AUTH-01's "Continue with Google" brings it back. App lock stays on if it was on, so leaving AUTH-01 goes through SYS-03.

**Why this priority**: Sign-out exists already (010); this story only changes where it lands and the sign-in mode it leaves behind.

**Independent Test**: Sign out with each choice (backup succeeding, failing, and offline), check AUTH-01 opens with no way back, restart, then continue as a guest and with Google.

**Acceptance Scenarios**:

1. **Given** ACC-03 with "Keep data on this phone", **When** the user signs out, **Then** every local row stays, `authMode` is `none`, AUTH-01 opens with the snackbar, and back closes the app.
2. **Given** ACC-03 with "Remove data from this phone", **When** the user signs out, **Then** local data is erased, Drive backups are kept, `deviceId` is kept, `authMode` is `none`, and AUTH-01 opens, not Intro.
3. **Given** either choice, **When** the app restarts, **Then** AUTH-01 opens; no Drive request is made until the user signs in again.
4. **Given** data was kept and app lock is on, **When** the user leaves AUTH-01 on either path, **Then** SYS-03 shows first.

**ACC-03 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] With changes not yet backed up, sign-out backs up first and enables "Sign out" only after the backup succeeds or the user picks "Sign out anyway."
- [ ] "Keep data on this phone" leaves every local row in place, opens AUTH-01, and "Continue as guest" there shows the same data.
- [ ] "Remove data from this phone" erases local data, keeps the Drive backups, and opens AUTH-01.
- [ ] After sign-out with either choice, `authMode` is `none` and the app opens AUTH-01, never Intro; a restart also opens AUTH-01.
- [ ] After a failed backup, "Remove data from this phone" needs the typed "DELETE" confirmation.
- [ ] After sign-out, no Drive request is made until the user signs in again.

---

### User Story 7 - Log out of guest (ACC-04) (Priority: P3)

A guest who wants to leave guest mode taps "Log out of guest" (in `error` color) in the SET-01 Data group. A dialog makes clear that their data exists only on this phone and will be deleted for good, and offers "Sign in with Google instead" as a safer way out. If they confirm "Log out and delete," every piece of their data, their rewarded unlocks, receipts, the safety copy, the PIN, and the backup password are removed and every scheduled notification and job is cancelled, while their language, currency, theme, modules, and Pro purchase stay. The app opens AUTH-01 with no way back, and a restart opens AUTH-01, not Intro or SYS-03.

**Why this priority**: It completes guest mode but is rarely used and destructive, so it comes last; everything else works without it.

**Independent Test**: As a guest with data, unlocks, receipts, a PIN, a backup password, and scheduled notifications, open ACC-04, cancel (every way), choose "Sign in with Google instead," then "Log out and delete" with a forced failure and a success; check every row, file, secure entry, setting, schedule, and the screen after each.

**Acceptance Scenarios**:

1. **Given** a guest opens ACC-04, **When** they tap "Cancel," press back, or tap outside, **Then** nothing changes.
2. **Given** ACC-04, **When** they tap "Sign in with Google instead," **Then** the dialog closes, nothing is deleted, and guest sign-in starts (User Story 5).
3. **Given** ACC-04, **When** they tap "Log out and delete," **Then** the button shows progress with all actions disabled, the erase runs in one transaction, and AUTH-01 opens with the back stack cleared; no ad appears over the dialog or over AUTH-01 afterwards.
4. **Given** a premium theme selected through a rewarded unlock and no Pro, **When** the guest logs out, **Then** the theme falls back to Default Teal; with Pro it is kept.
5. **Given** the erase transaction fails, **Then** nothing is deleted, the user stays a guest, and the dialog shows "Couldn't delete your data. Try again."

**ACC-04 acceptance criteria** (copied exactly from `docs/spec.md`):

- [ ] "Cancel," back, and tapping outside delete nothing: every row, receipt, unlock, the PIN, scheduled notifications, settings, and `authMode = guest` are unchanged.
- [ ] "Sign in with Google instead" deletes nothing and starts guest sign-in.
- [ ] "Log out and delete" removes all module rows, receipts, the safety copy, rewarded unlocks, the PIN hash and lockout state, and the backup password, and cancels every scheduled notification.
- [ ] After "Log out and delete," language, currency, theme, enabled modules, onboarding done, and Pro are kept, `authMode` is `none`, and the app opens AUTH-01 with no way back; a restart opens AUTH-01, not Intro or SYS-03.
- [ ] "Log out and delete" is shown in `error` color, and "Log out of guest" never appears in the Google state.
- [ ] A failed erase leaves all data and settings in place.

---

### Edge Cases

- **App closed during AUTH-01 sign-in or restore**: `authMode` is still `none`, so the next start opens AUTH-01; any account keys saved before the close are cleared on start (§16). A restore interrupted mid-way changes nothing (single transaction, 010).
- **App lock on while `authMode` is `none`** (data kept after ACC-03): AUTH-01 opens first; SYS-03 applies only after login. Returning from the background while on AUTH-01 does not re-lock.
- **Notification, widget, or deep link opened while `authMode` is `none`**: the router redirects to AUTH-01; while onboarding is not done, to Intro.
- **ACC-01 route reached while not signed in with Google** (for example from a stale pause notification): ACC-01 is not shown; the user lands on SET-01, which shows the guest card. An ACC-01 that is open when the account stops being signed in closes back to SET-01 (010).
- **Guest offline on SET-01/SET-02**: "Sign in with Google" says "Connect to the internet to sign in with Google" and makes no request.
- **Background and scheduled backup tasks while `guest` or `none`**: none run and no Drive request is made; the Auto backup setting is kept for the next sign-in.
- **Erase all data (SET-01) or SYS-03 "Forgot PIN?" erase**: removes data from this phone only; it does not sign out or change `authMode` (§4, SET-01), keeps onboarding done and the device preferences, and opens Home, never Intro (FR-034).
- **SYS-03 "Forgot PIN?" while a guest**: it remains one of the allowed sign-in places (§16); a successful restore there leaves the user signed in (`authMode = google`, Auto backup Daily if Off), while a cancelled sign-in or failed restore keeps them a guest with no account keys (FR-031).
- **ACC-04 with Pro owned**: Pro is kept and verified with Google Play on the next start as usual; "Restore purchase" restores it after a reinstall.
- **Restore on AUTH-01 brings back an `authMode` or account key?** Never: `authMode` and account keys are not in backups (§4, SET-02), so a restore cannot change the sign-in mode chosen on AUTH-01.
- **Long text at 200% font scale or in Hindi/Gujarati on a 360 dp screen**: AUTH-01, the SET-01 card, and ACC-04 must not clip or overflow (§15.10).
- **User taps both AUTH-01 buttons quickly**: while sign-in is in progress both buttons are disabled; a guest tap that already set `authMode` ends the screen.

## Requirements *(mandatory)*

### Functional Requirements

**Sign-in mode and its migration** (§4, SYS-01)

- **FR-001**: The app MUST keep a sign-in mode, `authMode`, with three values: `none` (no login chosen yet), `guest` (data only on this phone), and `google` (signed in; account keys set). New installs MUST start at `none`.
- **FR-002**: `authMode` MUST be the single source of truth for "signed in" everywhere the app checks it (account state, backups, SET-01, SET-02, ACC-01), replacing 010's rule that "signed in" means an account email is saved (interim I1). `authMode` MUST be `google` only while the account keys are set.
- **FR-003**: On the first start of an install updated from a version without `authMode`, before routing, the app MUST set `authMode` once: `google` if onboarding is done and an account email is saved; `guest` if onboarding is done without one; otherwise leave it `none`. Such an install with onboarding done MUST never see AUTH-01.
- **FR-004**: `authMode` MUST never be written to a DailyTrack backup file (Drive or local) or changed by restoring one. Android Auto Backup restores it with the database; FR-010 says what happens on that first start.

**Routing** (§5)

- **FR-005**: Startup MUST route: onboarding not done → Intro; else `authMode` `none` → AUTH-01 (even with app lock on); else app lock on → SYS-03; else Home.
- **FR-006**: The router MUST redirect every route except Splash to Intro while onboarding is not done; while onboarding is done and `authMode` is `none`, every route except Splash and AUTH-01 to AUTH-01; and AUTH-01 to Home (through SYS-03 when locked) once `authMode` is `guest` or `google`. Setting `authMode` to `none` MUST therefore land on AUTH-01 with the back stack cleared.
- **FR-007**: Re-locking on return from the background MUST apply only when app lock is on and `authMode` is not `none`.

**Account checks on start** (§16 "Account state is local", Android Auto Backup; interim I5, I7)

- **FR-008**: On start with `authMode = google`, the app MUST try a silent sign-in. If it fails because the token was revoked or the account was removed, the app MUST clear the account keys, set `authMode = guest`, and keep all data. An offline start MUST keep `authMode = google`. The same MUST happen when a Drive call later reports that sign-in is required.
- **FR-009**: A start that finds account keys while `authMode` is `none` or `guest` MUST clear them and sign out of Google.
- **FR-010**: On the first start after an Android Auto Backup restore, after 010's steps, a restored `google` MUST stay `google` if silent sign-in succeeds and become `guest` if it fails; a restored `guest` or `none` MUST be kept. Intro MUST not be shown again, and AUTH-01 MUST be shown only if the restored `authMode` is `none`.

**SYS-02 Intro**

- **FR-011**: Intro MUST offer no sign-in, restore, or app lock: the step 1 "Restore with Google" button (interim I2) and any app lock step MUST be removed. Step 4 MUST explain that data is kept on this phone and that the next step lets the user back it up with Google or continue as a guest.
- **FR-012**: "Get started" and Skip MUST save the choices, mark onboarding done, and open AUTH-01, replacing Intro so back can't return to it.

**AUTH-01 Login**

- **FR-013**: AUTH-01 MUST be a full screen with no app bar or back arrow showing, top to bottom: logo and app name; "Keep your data safe" and "Sign in with Google to back up your expenses and habits and get them back on a new phone."; primary "Continue with Google"; secondary "Continue as guest"; the note "As a guest, your data stays only on this phone."; and an inline error area, hidden until needed.
- **FR-014**: Android back on AUTH-01 MUST close the app; it MUST never return to Intro or to the screens before a sign-out or log-out.
- **FR-015**: "Continue as guest" MUST set `authMode = guest` and open Home without any sign-in, Drive, or other network request, online or offline, keeping any data already on the phone as the guest's data.
- **FR-016**: "Continue with Google" MUST open Google Sign-In (account chooser and scope consent) and save the account keys on success, then run 010's restore check: (a) backup found and no user data on this phone → restore the newest backup at once behind "Restoring your data…", asking for the password first when the saved one doesn't open an encrypted backup, applying the backup's language, currency, and modules, and running Restore purchase in the background (UI only for "Pro restored"); (b) backup found and user data on this phone → ACC-02, not dismissible; (c) no backup → nothing restored. Then it MUST set `authMode = google`, set Auto backup to Daily if it was Off, start auto backup (with a first backup right away when the account had no backup or the user kept this phone's data), and go to Home.
- **FR-017**: A cancelled or failed sign-in MUST keep AUTH-01 open with `authMode = none` and nothing written (no data, no account key), and show "Sign-in was cancelled. Try again or continue as a guest." or "Couldn't sign in. Check your connection and try again." with "Try again", which reopens Google Sign-In. "Continue as guest" MUST stay available.
- **FR-018**: Offline, "Continue with Google" MUST make no sign-in request, write nothing, and show "You're offline. Connect to the internet to sign in with Google, or continue as a guest." with "Try again."
- **FR-019**: A restore failure after sign-in (download, decrypt, validation, or lost connection) MUST leave this phone's data unchanged and show "Couldn't restore. Your data on this phone wasn't changed." with "Try again" and "Continue without restoring". "Continue without restoring" MUST finish the Google path with this phone's data as it is (`authMode = google`); 010's empty-phone guard then keeps auto backup from replacing the account's backup with an empty one, and ACC-01 "Restore" stays available.
- **FR-020**: While signing in, "Continue with Google" MUST show progress and both buttons MUST be disabled. Errors MUST be plain language with no codes or stack traces. The screen has no loading or empty state (fixed controls; the plan MUST say so, constitution V).
- **FR-021**: Leaving AUTH-01 on either path MUST go through SYS-03 first when app lock is on.
- **FR-022**: No ad of any format MUST be requested or shown while AUTH-01 is open, and no interstitial may appear over it (§11).

**"Finish setting up" after every login** (interim I6)

- **FR-023**: Every successful login on AUTH-01 (guest or Google) with app lock off MUST mark the "Finish setting up" sheet pending, so Home shows it once with "Set app lock" (→ SYS-04), "Allow notifications" (only on Android 13+ when not granted), and "Not now". Any choice or dismissal MUST clear it; it MUST not show again until the next login. With app lock on, it MUST not be shown. 010's other triggers (a restore onto an empty phone, the first start after an Android restore) MUST keep working.

**SET-01 account card** (interim I3, I8)

- **FR-024**: The account card MUST be the first item on SET-01 and follow `authMode`: **guest** — a person icon in the shared avatar, "Guest · Data saved only on this phone," and a primary "Sign in with Google" button that starts guest sign-in; the card itself is not tappable. **Google** — profile photo (initial in the shared avatar when there is none), name, email, and a status line: "Backed up to Google · <relative time>" (last successful Drive backup), "Backing up…," "Not backed up yet," or "Backup paused" / "Backup failed" in `warning` color with an icon; tapping the card opens ACC-01.
- **FR-025**: The card's status MUST come from the same status rules ACC-01 uses (010), so the two never disagree. Where ACC-01 shows "Waiting for Wi-Fi" or "You're offline", the card MUST show the last successful state instead ("Backed up to Google · <relative time>", or "Not backed up yet" when there is no successful backup); those two states appear on ACC-01 only (clarification Q3). The photo MUST load in the background and never delay the card.
- **FR-026**: The SET-01 Data group MUST show "Log out of guest" (`error` color text, → ACC-04) only while `authMode = guest`.
- **FR-027**: No text on SET-01, ACC-01, ACC-02, ACC-03, ACC-04, AUTH-01, or SET-02 MUST say "Synced" or "Sync."
- **FR-028**: ACC-01 MUST be reachable only while `authMode = google` (from the SET-01 card, the SET-02 Drive card email, the pause notification, and "Review"); otherwise the user lands on SET-01.

**Guest sign-in** (§16; interim I2, I4)

- **FR-029**: Guest sign-in MUST be startable from the SET-01 card, the SET-02 Drive card "Sign in with Google," and ACC-04 "Sign in with Google instead," and MUST reuse 010's sign-in flow: on success save the account keys, set `authMode = google`, set Auto backup to Daily if it was Off; then, if the account has no backup, back up this phone's data right away and show "Signed in. Your data is backed up." (a failure keeps the user signed in and auto backup retries); if it has a backup, open ACC-02 (not dismissible), or restore at once when this phone has no user data. No rows from the account and the phone may ever be combined.
- **FR-030**: A cancelled or failed guest sign-in MUST leave `authMode = guest` and every local row unchanged; a failure shows "Couldn't sign in. Check your connection and try again." Offline, the sign-in button MUST show "Connect to the internet to sign in with Google" and make no request.
- **FR-031**: Sign-in MUST be offered only from AUTH-01, the SET-01 account card, the SET-02 Drive card, ACC-04 "Sign in with Google instead," and SYS-03 "Forgot PIN?". A guest's "Forgot PIN?" → "Restore from Google Drive" that signs in and restores successfully MUST leave them signed in: save the account keys, set `authMode = google`, set Auto backup to Daily if it was Off, and show the Google state on the SET-01 card; a cancelled or failed sign-in, or a failed restore, MUST keep `authMode = guest` with no account keys left behind (clarification Q2). ACC-01 "Switch account" MUST, when its chooser is cancelled, set `authMode = guest`, keep all data, and return to SET-01 with the guest card (replacing interim I4).
- **FR-032**: While `authMode` is `guest` or `none`, the app MUST make no Google sign-in or Drive request except one the user starts from the places in FR-031, and MUST run no background or scheduled Drive backup.

**ACC-03 sign-out to AUTH-01** (interim I4)

- **FR-033**: ACC-03 MUST keep 010's backup step and choices, and on "Sign out" MUST sign out of Google, clear the account keys and `lastKnownDriveBackup*`, set `authMode = none`, cancel pending Drive backup tasks, stop background backups, and keep the Auto backup setting. Then: **Keep data on this phone** → open AUTH-01 with "Signed out. Your data is still on this phone."; **Remove data from this phone** → run the Erase all data erase (all module rows, receipts, the safety copy, backup password, and app lock), keep `deviceId` and onboarding done, and open AUTH-01. Neither MUST open the More tab or Intro, before or after a restart. App lock, when kept, MUST stay on.

**Erase all data**

- **FR-034**: SET-01 "Erase all data", the SYS-03 "Forgot PIN?" erase, and ACC-03 "Remove data from this phone" MUST share one erase that removes data from this phone only and keeps `authMode`, the account keys, `deviceId`, `lastKnownDriveBackup*`, the Auto backup settings (§4), ad consent, the Pro state, onboarding done, and the device preferences ACC-04 keeps (language, currency, theme mode and selected theme, enabled modules and their order; a premium theme from a rewarded unlock falls back to Default Teal unless Pro is owned). App lock is off afterwards (the PIN is erased). The user MUST then land on Home, or on AUTH-01 when `authMode` is `none` (ACC-03), and never on Intro, before or after a restart (clarification Q1).

**ACC-04 Log out of guest**

- **FR-035**: ACC-04 MUST be a confirm dialog titled "Log out and delete your data?" with the body "As a guest, your data is stored only on this phone. Logging out permanently deletes all your expenses, habits, budgets, receipts, and unlocks. This can't be undone." and the actions "Sign in with Google instead" (text), "Cancel," and "Log out and delete" (destructive, `error` color). It opens only from SET-01 "Log out of guest" while `authMode = guest`.
- **FR-036**: "Cancel," back, and tapping outside MUST close the dialog and change nothing. "Sign in with Google instead" MUST close it, delete nothing, and start guest sign-in.
- **FR-037**: "Log out and delete" MUST show progress on the button with all actions disabled, then: (1) in one transaction remove every user data row, including rewarded unlocks (streak freezes go with their habits), and reset settings, keeping only language, currency, theme mode and selected theme, enabled modules and their order, onboarding done, `deviceId`, `adsInstallAt`, ad consent, and Pro state (`removeAdsPurchased` and the Pro check keys), with `authMode = none`; a premium theme that came from a rewarded unlock falls back to Default Teal unless Pro is owned; (2) cancel every scheduled notification and pending background job; (3) delete receipt images, the safety copy, and from secure storage the PIN hash, lockout state, and backup password (app lock and biometric off); (4) refresh the home widget and open AUTH-01 with the back stack cleared, never Intro.
- **FR-038**: If the transaction fails, nothing MUST be deleted, the user stays a guest, and the dialog shows "Couldn't delete your data. Try again." Backup or export files saved outside the app MUST not be touched.
- **FR-039**: No ad MUST appear over ACC-04 or over AUTH-01 after it.

**Replacing 010's interim behavior**

- **FR-040**: Every row tagged **Replaced in 011** in `specs/010-google-account-backup/plan.md` MUST be replaced, and its interim code and tests removed or rewritten: I1 → FR-002, FR-003; I2 → FR-011, FR-016, FR-029, FR-031; I3 → FR-024, FR-028; I4 → FR-031, FR-033; I5 → FR-008, FR-009; I6 → FR-023; I7 → FR-010; I8 → FR-024, FR-025. The interim criteria in the 010 spec marked *Replaced in 011* (the SYS-02 "Restore with Google" criteria) MUST no longer be tested; the "Interim until T3.6" note in `docs/spec.md` §14 MUST be removed when this feature is done.
- **FR-041**: This feature MUST reuse 010's account service, restore flow, ACC-02, ACC-03, "Finish setting up" sheet, backup status rules, backup engine, and the Erase all data keep-list, and MUST not duplicate their logic.

**UI, copy, and quality** (§15)

- **FR-042**: AUTH-01, the SET-01 account card, and ACC-04 MUST use only theme tokens and shared components (the shared avatar, confirm dialog, bottom sheet), keep one primary action visible, use 48 dp touch targets with semantic labels and a logical TalkBack order, follow sentence case and verb-first button labels, and work at 200% font scale on a 360 dp-wide screen in light and dark mode, in English, Hindi, and Gujarati.
- **FR-043**: Every new string MUST be added to the English, Hindi, and Gujarati string files with placeholders (relative time, name, email), never concatenation.
- **FR-044**: Every acceptance criterion copied above MUST have at least one automated test named with its Screen ID; widget tests MUST use fake sign-in and Drive clients and no ads.

### Key Entities

- **Sign-in mode (`authMode`)**: one of `none`, `guest`, `google`; local only, never backed up; decides routing, whether backups may run, and the SET-01 card state.
- **Account keys**: the signed-in account's email, display name, and photo address; set only together with `authMode = google` and cleared on sign-out, revoked access, or an interrupted sign-in.
- **Finish setup pending**: a one-shot flag that shows the "Finish setting up" sheet on Home once after a login, a restore onto an empty phone, or an Android restore.
- **Guest log-out keep list**: the settings ACC-04 keeps (language, currency, theme mode and theme, modules and order, onboarding done, device ID, install time, ad consent, Pro state); everything else returns to its default.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user gets from the first Intro screen to Home as a guest in under 60 seconds, with "Continue as guest" a single tap on AUTH-01, online or offline.
- **SC-002**: Across a full guest session (Intro, AUTH-01 guest, use of every module, backgrounding), the app makes zero Google sign-in or Drive requests.
- **SC-003**: 100% of installs updated from a version without a sign-in mode and with onboarding done land on SYS-03 or Home on the first start, never on AUTH-01, and keep their signed-in state.
- **SC-004**: On a new phone, a user with a backup goes from "Continue with Google" to Home with their data in 3 taps or fewer (excluding Google's own account chooser and a backup password).
- **SC-005**: Every cancelled, failed, or offline sign-in on AUTH-01 or from More leaves 100% of local rows and settings unchanged and shows a plain-language message with a next step.
- **SC-006**: After any sign-out or guest log-out, 100% of restarts open AUTH-01, never Intro or Home.
- **SC-007**: A guest who confirms "Log out and delete" has no user data, unlocks, receipts, PIN, or backup password left on the phone, and keeps their language, currency, theme, modules, and Pro.
- **SC-008**: Every acceptance criterion copied in this spec (SYS-01, SYS-02, AUTH-01, SET-01, ACC-03, ACC-04, §16 Guest sign-in) has a passing automated test, and no 010 interim-only test remains.

## Assumptions

- `docs/spec.md` as updated on 2026-10-27 for feature 011 is the source of truth; where it and the 010 interim behavior differ, `docs/spec.md` wins.
- The account state, restore check, ACC-02, ACC-03 backup step, conflict rule, empty-phone guard, safety copy, and Finish setting up sheet from feature 010 work as specified there and are reused unchanged except for the points listed in FR-040.
- The SET-01 "Backed up to Google" relative time uses the app's existing relative-time formatting (for example "5 min ago", "Yesterday").
- "Not backed up yet" shows while signed in with no successful Drive backup recorded on this phone.
- The SYS-03 "Forgot PIN?" restore and erase flows keep their 010 behavior; this feature only sets the sign-in mode and Auto backup after a successful restore there (FR-031) and applies the FR-034 erase.
- Guest sign-in from More does not trigger the "Finish setting up" sheet (it is not a login on AUTH-01), except through 010's empty-phone restore trigger.
- No new database table is needed; `authMode` lives in the existing settings table, and its migration runs at startup rather than as a schema change.
- The installed base updating to this version is small (pre-release), but the migration is still required and tested.

## Out of Scope

- Changes to backup contents, rotation, the conflict rule, ACC-01, or ACC-02 beyond what is listed above.
- Sign-in methods other than Google, live multi-device sync, and merging data from two phones (§16).
- Any interstitial, banner, or native ad on AUTH-01 or ACC-04.
