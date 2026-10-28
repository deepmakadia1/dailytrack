# Contract: Screens and Sheets

Every screen has one Riverpod Notifier with an immutable state (Constitution II) and uses only `AppTokens` and `lib/core/widgets/` components (§15). Strings go through `tool/l10n/phase0_strings.py` (en, hi, gu). No ads on any of them (FR-049). Status text says "Backed up to Google," never "Synced" (FR-051).

Matched to `docs/spec.md` §16 as updated on 2026-10-27 for feature 011. Items tagged **Replaced in 011** are interim behavior (plan.md "Interim behavior until feature 011").

## ACC-01 Account — `lib/features/account/presentation/screens/account_screen.dart`

Route `/more/account`, pushed under the More branch, opened only while signed in: from the SET-02 Drive card's account email, the pause notification, and the "Review" link (interim I3; **Replaced in 011**: also from the SET-01 account card).

**Controller** `AccountController` → `AccountScreenState`:

```text
AccountScreenState {
  account: SignedIn                // the screen pops when the account becomes SignedOut
  status: AsyncValue<BackupStatus> // loading → skeleton; error → ErrorState in the status area only
  lastBackup: { at, deviceName }?
  autoBackup: { frequency, wifiOnly }
  network: { online, metered }
  busy: none | backingUp | deleting | switching
  backupCount: int?                // for the Delete dialog text
}
```

**Actions**: `backUpNow()` (manual, `ConflictMode.ask` → ConfirmDialog → `overwrite`); `restore()` → ACC-02 for the newest; `switchAccount()` (ACC-03 step 1 backup, "Switch anyway", sign out, chooser; the new account follows the SET-02 sign-in flow below; a cancelled chooser leaves the user signed out and goes to `Routes.more`, interim I4, **Replaced in 011**); `signOut()` → ACC-03; `deleteMyBackups()` → ConfirmDialog with count and email → `deleteAll()`. There is no `signIn()` action on this screen; the shared sign-in logic lives in `AccountService` and is called by the SET-02 Drive card and Switch account.

**Layout**: account card (`CategoryAvatar` with the photo, or the initial); backup status ("Last backup: Today, 9:41 PM · Redmi Note 12" plus `BackupStatusLine`); "Back up now" (the one primary button); "Restore" (secondary) with "See all backups"; Auto backup row → SET-02; "Switch account" and "Sign out" (text buttons); "Delete my backups" (text button, `error` color); footnote "Your app lock PIN is never backed up."

**States**: loading = status skeleton, local details at once; offline disables Back up now, Restore, Switch account, Delete my backups with the offline reason, Sign out stays enabled (FR-014); Drive read error = `ErrorState` in the status area. No empty state: the screen pops back to the More tab when the account becomes signed out while it is open (sign-out, revoked token).

**Test keys**: `acc01.backUpNow`, `acc01.restore`, `acc01.switch`, `acc01.signOut`, `acc01.deleteBackups`, `acc01.status`.

## ACC-02 Restore choice — `lib/features/account/presentation/widgets/restore_choice_sheet.dart`

`AppBottomSheet`. Opened with `showRestoreChoice(context, {required DriveBackupEntry newest, required bool afterSignIn})` → `Future<RestoreChoiceResult>` (`restored`, `kept`, `closed`).

- `afterSignIn: true`: `isDismissible: false`, `enableDrag: false`, no close button (FR-021).
- Summary card from `entry.meta` only (no download until "Restore from account"); "From this phone" when `meta.deviceId == thisDeviceId`; entries without meta show the device name stored by feature 008, or "Unknown device" (FR-043).
- "This phone" counts from `AccountRestore.phoneCounts()` (local, no network). Presentation never calls `BackupEngine`, which lives in `core/backup/data/` (Constitution II).
- Password field appears only after `AccountRestore.open` throws `BackupNeedsPassword`/`BackupWrongPassword` with the saved password; inline error "That password didn't work".
- Primary "Restore from account" → `AccountRestore.apply` → snackbar with counts; `SafetyCopyFailed` → error text "Not enough free space…"; other failures → "Couldn't restore. Your data on this phone wasn't changed." + "Try again".
- Secondary "Keep this phone's data" → `AccountRestore.keepThisPhone` → starts a manual backup in the background, which becomes the account's latest backup; the declined one stays in the Drive list. Nothing is merged.
- Link "See all backups" → `/more/backup` (Drive list).
- Never shown when `phoneHasData()` is false: callers restore directly behind a progress view, then the Finish setting up sheet if app lock is off (FR-016).

## ACC-03 Sign out — `lib/features/account/presentation/widgets/sign_out_sheet.dart`

`AppBottomSheet` with controller `SignOutController`:

```text
SignOutState { step1: checking | backingUp | backedUp | failed(reason), choice: keep | remove,
               signedOutAnyway: bool, typedConfirmOk: bool, working: bool }
```

- Opens with `changed ? backingUp : backedUp`. The backup is `backupToDrive(kind: manual, conflict: ask)`; a declined conflict dialog → `failed`.
- `failed` shows "Try again" and "Sign out anyway". "Sign out" is enabled when `backedUp`, or `failed && signedOutAnyway`.
- With `remove` after a failure, "Sign out" opens the typed "DELETE" dialog used by SET-01 Erase all data (FR-023).
- "Sign out" button uses the `error` color when `remove` is chosen.
- `keep` → `AccountService.signOut()` → `go(Routes.more)` + snackbar "Signed out. Your data is still on this phone." (ACC-01 closes). `remove` → `signOut()` then `AppResetService.eraseAll()` (deletes the safety copy too) → the erase resets settings, so the bootstrap redirect goes to `/onboarding` (FR-025). Both are interim I4, **Replaced in 011** (`authMode = none` → `/login` for both).

## Finish setting up — `lib/features/account/presentation/widgets/finish_setup_sheet.dart`

Shown by `lib/app/app.dart` on Home when `finishSetupPending` and the app is unlocked (R13). Title "Finish setting up", body explaining the PIN isn't backed up; "Set app lock" (primary, → `Routes.pin?mode=set`), "Allow notifications" (only on Android 13+ when `POST_NOTIFICATIONS` isn't granted), "Not now". Any action, or dismissing the sheet, clears `finishSetupPending`. In 010 the flag is set after a restore onto an empty phone and after an Android restore (interim I6, **Replaced in 011**: also after every login).

## SET-01 — no change in 010

The former SET-01 Account row is not built. Feature 011 adds the SET-01 account card (guest and Google states) and the "Log out of guest" row (`docs/spec.md` §10). 010 adds nothing to SET-01.

## SET-02 changes — `backup_screen.dart`, `backup_controller.dart`

- **Drive card, signed out**: "Sign in with Google" runs the `docs/spec.md` §16 "Guest sign-in" steps through `AccountService.signIn()`:
  - success → account keys saved, Auto backup Daily if it was Off; no backup on the account → `backupToDrive(manual, overwrite)` and "Signed in. Your data is backed up." (a failed first backup leaves the user signed in; auto backup retries); a backup on the account → ACC-02 through `accountUiProvider` with `afterSignIn: true`, or a direct restore behind a progress view when `phoneHasData()` is false;
  - cancelled → nothing; failed → "Couldn't sign in. Check your connection and try again.";
  - offline → the button shows "Connect to the internet to sign in with Google" and makes no request.
- **Drive card, signed in**: the account email (tap → ACC-01, interim I3), Back up now (`ConflictMode.ask` with the dialog), Auto backup selector, Wi-Fi only. "Connect" and "Disconnect" are removed.
- Drive list rows show `meta.deviceName` and counts, Manual/Auto; restore goes through `AccountRestore` (safety copy, FR-019b).
- New "Restore previous phone data" tile, only while a safety copy exists: date and counts → existing `restore_flow.dart` with the safety copy bytes → deleted after success.

## SYS-02 changes — `language_step.dart`, `onboarding_controller.dart` (interim I2, **Replaced in 011**)

011 removes all of this and moves the restore to AUTH-01 "Continue with Google".

- Secondary "Restore with Google" under the language chips (`sys02.restoreWithGoogle`).
- Flow: `AccountService.signIn()` → cancelled: nothing. → `drive.list()` empty: snackbar "No backup found on this account", stay on step 1. → newest: `AccountRestore.open` (password via core `backup_password_sheet.dart`) → full-screen "Restoring your data…" → `apply(fromEmptyPhone: true)` → `go(Routes.home)`; `ProService.restore()` unawaited, "Pro restored" snackbar when owned. Failure → SET-02 error text + "Try again", onboarding continues.
- Onboarding "Get started" while signed in starts a manual backup in the background (User Story 1 scenario 4).
