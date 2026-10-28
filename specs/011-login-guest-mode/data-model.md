# Data Model: Login and Guest Mode

**Feature**: `011-login-guest-mode` · **Spec**: [spec.md](spec.md) · **Research**: [research.md](research.md)

No Drift schema change: the database stays at schema 5 (feature 010), and the backup `schemaVersion` is unchanged. Everything below is a `settings` row or an in-memory type.

## 1. Settings keys

| Key | Type (JSON) | Default | Written by | Backed up | Kept by erase `thisPhoneData` | Kept by erase `guestLogOut` |
| --- | --- | --- | --- | --- | --- | --- |
| `authMode` **(new)** | string: `none`, `guest`, `google` | `none` (row written on first start, R2) | `migrateAuthMode`, `AccountService` (`commitSignIn`, `signOut`, `forgetAfterAuthLoss`, `restoreSession`), `LoginController` (guest path), erase `guestLogOut` | Never | Yes | No: set to `none` |
| `backupLeaseUntil` (existing row, **newly decoded**) | int, UTC ms | null | `BackupCoordinator` only | Never | No (no backup runs during erase) | No |

Existing keys whose rules change in 011:

| Key | Change |
| --- | --- |
| `backupAccountEmail`, `accountDisplayName`, `accountPhotoUrl` | Only meaningful while `authMode == google`. Cleared at start when found with `none` or `guest` (R5). Kept by erase `thisPhoneData` (010 T041), cleared by `guestLogOut`. |
| `finishSetupPending` | Also set by both AUTH-01 paths (R10). Reset by `guestLogOut`. |
| `onboardingDone`, `locale`, `currencyCode`, `themeMode`, `selectedTheme`, `enabledModules`, `moduleOrder` | `devicePreferenceKeys`: kept by both erase scopes (clarification Q1). |
| `adConsentStatus`, `removeAdsPurchased`, `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending` | Kept by both erase scopes (`docs/spec.md` §4, analysis I2), so erasing never costs a Pro user their ad-free state or premium theme. |
| `autoBackupFrequency`, `autoBackupWifiOnly`, `lastKnownDriveBackupAt`, `lastKnownDriveBackupDeviceId` | Kept by `thisPhoneData` (§4); reset by `guestLogOut`. |

`BackupSettingsPolicy` (the list of restorable settings) is unchanged except that a test asserts `authMode` and `backupLeaseUntil` are never in a backup's `settings` section and are never written by a restore.

## 2. `AuthMode`

```text
enum AuthMode { none, guest, google }      // lib/core/settings/domain/app_settings.dart (pure Dart)
AppSettings.authMode: AuthMode = none      // unknown stored value → none
AppSettings.backupLeaseUntil: int?         // read-only view of BackupCoordinator.leaseKey
```

Invariant: `authMode == google` ⇒ `backupAccountEmail != null`. The write order in research R3 keeps it true across crashes; `restoreSession` (R5) repairs the only reachable violation of the converse (keys present with `none`/`guest`).

### State transitions

| From | Event | To | Side effects |
| --- | --- | --- | --- |
| (missing row) | SYS-01 `migrateAuthMode` | `none` / `guest` / `google` | R2 table; written once |
| `none` | AUTH-01 "Continue as guest" | `guest` | `finishSetupPending = true`; no Google or Drive call |
| `none` | AUTH-01 Google path settles (no backup, restored, kept, or "Continue without restoring") | `google` | keys already saved by `signIn()`; `finishSetupPending = true`; Auto backup Off → Daily; schedule synced; first backup when no backup or kept |
| `none` | AUTH-01 sign-in cancelled, failed, offline, or Drive list failed | `none` | nothing written (keys cleared again if they were saved) |
| `guest` | Guest sign-in succeeds (SET-01, SET-02, ACC-04, SYS-03 "Forgot PIN?" restore) | `google` | `signIn()` + `commitSignIn()`; then backup or ACC-02 (010) |
| `guest` | Guest sign-in cancelled or failed | `guest` | nothing written |
| `guest` | ACC-04 "Log out and delete" | `none` | erase `guestLogOut` in the same transaction; AUTH-01 by redirect |
| `google` | ACC-03 Sign out (either choice) | `none` | `signOut(to: none)`: mode first, then keys, `lastKnownDriveBackup*`, background jobs; "Remove data" then runs erase `thisPhoneData` |
| `google` | ACC-01 Switch account | `guest`, then `google` again or stays `guest` if the chooser is cancelled | `signOut(to: guest)`, then guest sign-in |
| `google` | Silent sign-in returns no session, or Drive reports `DriveAuthRequired` | `guest` | `forgetAfterAuthLoss()`; data kept |
| `google` | Offline start | `google` | unverified this run |
| `none`/`guest` + keys present | SYS-01 start | unchanged | keys cleared, `AccountAuth.signOut()` |
| any | First start after Android Auto Backup restore | `google` stays if silent sign-in succeeds, else `guest`; `guest`/`none` kept | R5; Google is called only for a restored `google` |
| any | SET-01 Erase all data, SYS-03 erase | unchanged | erase `thisPhoneData` |

## 3. `EraseScope`

```text
enum EraseScope { thisPhoneData, guestLogOut }   // lib/core/reset/domain/app_reset_service.dart
AppResetService.eraseAll({EraseScope scope = EraseScope.thisPhoneData})
```

| | `thisPhoneData` (SET-01, SYS-03, ACC-03 Remove) | `guestLogOut` (ACC-04) |
| --- | --- | --- |
| Module rows, `unlocks` | Deleted | Deleted |
| Settings kept | `devicePreferenceKeys`, `authMode`, account keys, `deviceId`, `adsInstallAt`, `lastKnownDriveBackup*`, `autoBackupFrequency`, `autoBackupWifiOnly`, `adConsentStatus`, Pro keys | `devicePreferenceKeys`, `deviceId`, `adsInstallAt`, `adConsentStatus`, Pro keys |
| Settings written | change counters = 0 | `authMode = none`, change counters = 0 |
| Notifications, background jobs | Cancelled | Cancelled |
| Receipts, safety copy, PIN + lockout, backup password | Deleted | Deleted |
| Google calls | None | None |
| Then | lock session reset, bootstrap re-run → Home (or `/login` when `authMode` is `none`) | same → `/login` |

The database step is one transaction; if it throws, nothing was deleted (both scopes). The later steps are best effort, as in feature 007.

## 4. Login flow state (`LoginState`, presentation)

```text
LoginState (freezed)
  busy: LoginBusy { none, signingIn, restoring, finishing }
  error: LoginError? { cancelled, failed, offline }      // inline error under the buttons
  restoreFailed: bool                                     // restore error view with Try again / Continue without restoring
  pendingBackup: DriveBackupEntry?                        // the newest backup, for Try again
```

`LoginNext { done, chooseRestore(DriveBackupEntry newest) }` is what the controller's Google actions return; on `chooseRestore`, the screen opens ACC-02 and passes its result to `LoginController.onRestoreChoice` (the controller holds no `BuildContext`). Both buttons are disabled while `busy != none`. Loading is `busy` (signing-in progress and the restoring view); the empty state is omitted because AUTH-01 is a fixed set of controls (constitution V; this plan says so).

## 5. Account card view (`AccountCardView`, presentation)

```text
sealed AccountCardView
  GuestCard(offline: bool)                                // "Sign in with Google" says "Connect to the internet…" when offline
  GoogleCard(profile: AccountProfile, status: CardStatus)
CardStatus = backedUp(lastBackupAt) | notBackedUpYet | backingUp | paused | failed
```

`accountCardViewProvider` (`lib/core/account/account_providers.dart`, a plain `@riverpod` function provider, not a Notifier) derives `AccountCardView` from `appSettingsProvider`, `accountStateProvider`, the network state, and the clock, using `AccountCardPolicy.derive` (pure, in `lib/core/backup/domain/backup_status_policy.dart`). It runs `BackupStatusPolicy.derive` first, then maps `Offline`/`WaitingForWifi` to `backedUp`/`notBackedUpYet` (clarification Q3), and reports `backingUp` when `backupLeaseUntil > now`. `AccountCardView` and `CardStatus` live in `lib/core/account/domain/account_card_view.dart` (pure Dart). SET-01 therefore keeps `SettingsController` as its only Notifier (constitution II). `authMode == none` never renders the card (the router keeps the user on AUTH-01).

## 6. Login outcomes (core)

```text
sealed LoginOutcome     // lib/core/account/account_sign_in.dart
  LoginOffline | LoginCancelled | LoginFailed(error) | LoginNoBackup | LoginHasBackups(newest)
```

See research R9 for what each one writes.
