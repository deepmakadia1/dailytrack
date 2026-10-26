# Contract: Screens and Sheets

Every screen has one Riverpod Notifier with an immutable state (Constitution II) and uses only `AppTokens` and `lib/core/widgets/` components (§15). Strings go through `tool/l10n/phase0_strings.py` (en, hi, gu). No ads on any of them (FR-049).

## ACC-01 Account — `lib/features/account/presentation/screens/account_screen.dart`

Route `/more/account` (push from SET-01; also from SET-02's account email, the pause notification, and the "Review" link).

**Controller** `AccountController` → `AccountScreenState`:

```text
AccountScreenState {
  account: AccountState            // SignedOut | SignedIn
  status: AsyncValue<BackupStatus> // loading → skeleton; error → ErrorState in the status area only
  lastBackup: { at, deviceName }?
  autoBackup: { frequency, wifiOnly }
  network: { online, metered }
  busy: none | signingIn | backingUp | deleting | switching
  backupCount: int?                // for the Delete dialog text
}
```

**Actions**: `signIn()` → (ACC-02 if the account has a backup | first backup + snackbar | stays signed out); `backUpNow()` (manual, `ConflictMode.ask` → ConfirmDialog → `overwrite`); `restore()` → ACC-02 for the newest; `switchAccount()` (ACC-03 step 1 backup, "Switch anyway", sign out, chooser); `signOut()` → ACC-03; `deleteMyBackups()` → ConfirmDialog with count and email → `deleteAll()`.

**States**: signed out = the empty state (illustration, three points, primary "Sign in with Google", PIN footnote). Signed in = content. Offline disables Back up now, Restore, Switch account, Delete my backups with the offline reason; Sign out stays enabled (FR-014). One primary button: "Sign in with Google" or "Back up now".

**Test keys**: `acc01.signIn`, `acc01.backUpNow`, `acc01.restore`, `acc01.switch`, `acc01.signOut`, `acc01.deleteBackups`, `acc01.status`.

## ACC-02 Restore choice — `lib/features/account/presentation/widgets/restore_choice_sheet.dart`

`AppBottomSheet`. Opened with `showRestoreChoice(context, {required DriveBackupEntry newest, required bool afterSignIn})` → `Future<RestoreChoiceResult>` (`restored`, `kept`, `closed`).

- `afterSignIn: true`: `isDismissible: false`, `enableDrag: false`, no close button (FR-021).
- Summary card from `entry.meta` only (no download until "Restore from account"); "From this phone" when `meta.deviceId == thisDeviceId`; entries without meta show the device name stored by feature 008, or "Unknown device" (FR-043).
- "This phone" counts from `AccountRestore.phoneCounts()` (local, no network). Presentation never calls `BackupEngine`, which lives in `core/backup/data/` (Constitution II).
- Password field appears only after `AccountRestore.open` throws `BackupNeedsPassword`/`BackupWrongPassword` with the saved password; inline error "That password didn't work".
- Primary "Restore from account" → `AccountRestore.apply` → snackbar with counts; `SafetyCopyFailed` → error text "Not enough free space…"; other failures → "Couldn't restore. Your data on this phone wasn't changed." + "Try again".
- Secondary "Keep this phone's data" → `AccountRestore.keepThisPhone` → starts a manual backup in the background.
- Link "See all backups" → `/more/backup` (Drive list).
- Never shown when `phoneHasData()` is false: callers restore directly behind a progress view (FR-016).

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
- `keep` → `AccountService.signOut()` → pop to ACC-01 + snackbar. `remove` → `signOut()` then `AppResetService.eraseAll()` → router goes to `/onboarding` (FR-025).

## Finish setting up — `lib/features/account/presentation/widgets/finish_setup_sheet.dart`

Shown by `lib/app/app.dart` on Home when `finishSetupPending` (R13). Title "Finish setting up", body explaining the PIN isn't backed up; "Set app lock" (primary, → `Routes.pin?mode=set`), "Allow notifications" (Android 13+ only, requests `POST_NOTIFICATIONS`), "Not now". Any action clears `finishSetupPending`.

## SET-01 Account row — `lib/features/settings/presentation/widgets/account_row.dart`

Above General. Signed out: Google icon, "Sign in to back up your data", helper "Optional". Signed in: `CategoryAvatar` photo or initial, name, email, "Last backup: …" or "Backup paused"/"Backup failed" with a warning icon and `warning` color (never color alone). Tap → `/more/account`.

## SET-02 changes — `backup_screen.dart`, `backup_controller.dart`

- Drive card: signed out → "Sign in with Google" (AccountService.signIn; ACC-02 through `accountUiProvider` when the account has a backup). Signed in → email (tap → ACC-01), Back up now, Auto backup, Wi-Fi only. "Connect" and "Disconnect" are removed.
- Drive list rows show `meta.deviceName` and counts, Manual/Auto; restore goes through `AccountRestore` (safety copy, FR-019b).
- New "Restore previous phone data" tile, only while a safety copy exists: date and counts → existing `restore_flow.dart` with the safety copy bytes → deleted after success.

## SYS-02 changes — `language_step.dart`, `onboarding_controller.dart`

- Secondary "Restore with Google" under the language chips (`sys02.restoreWithGoogle`).
- Flow: `AccountService.signIn()` → cancelled: nothing. → `drive.list()` empty: snackbar "No backup found on this account", stay on step 1. → newest: `AccountRestore.open` (password via core `backup_password_sheet.dart`) → full-screen "Restoring your data…" → `apply(fromEmptyPhone: true)` → `go(Routes.home)`; `ProService.restore()` unawaited, "Pro restored" snackbar when owned. Failure → SET-02 error text + "Try again", onboarding continues.
- Onboarding "Get started" while signed in starts a manual backup in the background (User Story 1 scenario 4).
