# Contract: Services and ports

All signatures are Dart. `core/` types are pure Dart unless noted (constitution II).

## SettingsRepository (`lib/core/settings/domain/settings_repository.dart`)

```dart
Future<void> setAuthMode(AuthMode mode);

/// SYS-01, once per start before routing (research R2). Writes the
/// `authMode` row only when it is missing: google (onboarding done + email),
/// guest (onboarding done), else none. Never throws on bad data.
Future<void> migrateAuthMode();
```

`FakeSettingsRepository` implements both with the same rules over its in-memory map, and records whether the row existed.

## Providers (`lib/core/settings/settings_providers.dart`)

```dart
@Riverpod(keepAlive: true)
AuthMode authMode(Ref ref);   // appSettingsProvider.select((s) => s.value?.authMode ?? AuthMode.none)
```

Read by `appRouter`, `app.dart` (lock session, R7), SET-01, and the account card.

## AccountService (`lib/core/account/account_service.dart`)

| Member | 010 | 011 |
| --- | --- | --- |
| `stateOf(s)` | `SignedIn` when email set | `SignedIn` only when `authMode == google` and email set |
| `signIn()` | chooser, save keys, Auto backup Daily, sync schedule | chooser, **save keys only**; null when cancelled; throws `BackupFailure` on failure |
| `commitSignIn()` **new** | — | `authMode = google`, Auto backup Off → Daily, clear `_expired`, mark verified, sync schedule |
| `signOut({required AuthMode to})` | sign out, clear keys | write `authMode = to` first, then sign out of Google and clear keys, `lastKnownDriveBackup*`, `lastBackgroundBackupAt`, the pause, and both background jobs. Auto backup setting kept |
| `forgetAfterAuthLoss()` | clear keys | `authMode = guest`, then clear keys; data kept |
| `restoreSession()` | silent sign-in when email set | R5: `google` → silent sign-in (null → `forgetAfterAuthLoss`; throw → unverified); `none`/`guest` with keys → clear keys + `AccountAuth.signOut()`; otherwise no call |
| `adoptSilentSession()` | after Android restore | unchanged, but bootstrap calls it only when the restored `authMode` was `google`; on null result bootstrap writes `guest` |

## AccountSignIn (`lib/core/account/account_sign_in.dart`)

```dart
/// Guest sign-in (SET-01 card, SET-02 Drive card, ACC-04, Switch account).
/// Unchanged outcomes; now calls signIn() then commitSignIn().
Future<SignInOutcome> run();

/// AUTH-01 "Continue with Google" (research R9). Never sets authMode.
/// Offline → LoginOffline without any request. On LoginFailed after a
/// successful chooser, the saved keys are cleared again.
Future<LoginOutcome> login();
```

## AccountUi port (`lib/core/account/account_ui.dart`)

```dart
abstract interface class AccountUi {
  Future<RestoreChoiceResult> showRestoreChoice(BuildContext context,
      {required DriveBackupEntry newest, required bool afterSignIn});  // 010, unchanged

  /// SET-01 item 1 (spec §10): guest or Google state, from authMode.
  Widget accountCard();                                               // new

  /// ACC-04 Log out of guest (spec §16). Opened only while authMode == guest.
  Future<void> showLogOutGuest(BuildContext context);                 // new

  /// Guest sign-in (spec §16) with its outcome UI: snackbar, ACC-02
  /// (afterSignIn: true), offline and failure messages. Used by the SET-01
  /// card, the SET-02 Drive card, and ACC-04 "Sign in with Google instead".
  Future<void> startGuestSignIn(BuildContext context);                // new
}
```

`AccountFeatureUi` (`lib/features/account/presentation/account_feature_ui.dart`, moved out of `restore_choice_sheet.dart`) implements all four; `production_overrides.dart` and `pumpTestApp` bind it.

## AppResetService (`lib/core/reset/domain/app_reset_service.dart`)

```dart
enum EraseScope { thisPhoneData, guestLogOut }

/// One transaction for the database step; throws only when it fails, and
/// then nothing was deleted. Never calls Google. See data-model §3.
Future<void> eraseAll({EraseScope scope = EraseScope.thisPhoneData});
```

`DriftAppResetService` takes the keep-lists from `EraseScope` (data layer); `FakeAppResetService` records the scope of each call (`scopes`).

## Auto backup gates

`syncAutoBackupSchedule`, `BackgroundBackupScheduler.onAppHidden`, and `runAutoBackup` check `s.authMode == AuthMode.google` instead of `s.backupAccountEmail != null` (research R4). Manual Drive work (ACC-02 keep, AUTH-01 first backup, restore download, ACC-01 Back up now, ACC-03 step 1) keeps checking the account keys.

## Bootstrap (`lib/app/bootstrap.dart`)

Order after the database opens and seeds:

1. `settingsRepository.migrateAuthMode()`, then reload settings.
2. Device ID check; on Android restore: lock off when no PIN; clear keys; `lastKnownDriveBackup*` cleared; pause cleared; `finishSetupPending` when onboarding done; if the restored `authMode` was `google` → `adoptSilentSession()` then `guest` on failure (unawaited, best effort).
3. Ads, notifications, widget host (unchanged).
4. `restoreSession()` unawaited (R5), safety copy expiry.
5. `lockSession.start(lockEnabled: onboardingDone && lockEnabled && authMode != none)`.
6. `BootstrapReady(initialLocationFor(settings, launchPayload))`.

## Test fakes (research R13)

- `FakeAccountAuth.calls: List<String>` (`signIn`, `signInSilently`, `signOut`), kept next to the counters.
- `FakeDriveBackupStore.calls` (existing).
- `expectNoGoogleCalls(FakeAccountAuth auth, FakeDriveBackupStore drive)` in `test/helpers/backup_fakes.dart`.
- `pumpTestApp(..., FakeDriveBackupStore? drive)` binds `driveBackupStoreProvider`.
- `FakeBootstrap` starts the lock session with the R7 condition and uses the new `initialLocationFor`.
