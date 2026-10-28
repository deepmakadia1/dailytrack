# Contract: Services

Dart signatures in outline (primary-constructor style, as in the codebase). "Pure" means no Flutter imports (Constitution II); each pure type takes an injected clock or `now` and has unit tests. R# = research.md. Matched to `docs/spec.md` as updated for feature 011; members tagged **Replaced in 011** carry interim behavior (plan.md).

## `lib/core/account/` (new)

```dart
// domain/account.dart (pure)
final class AccountProfile { const new({required this.email, this.displayName, this.photoUrl}); }
sealed class AccountState;
final class SignedOut extends AccountState;
final class SignedIn extends AccountState { AccountProfile profile; bool verified; }

// domain/account_auth.dart (pure port; implemented by GoogleAuth, R1)
abstract interface class AccountAuth {
  Future<AccountProfile> signIn();            // interactive; throws DriveAuthRequired on cancel,
                                              // DriveUnavailable/DriveOffline on failure
  Future<AccountProfile?> signInSilently();   // null when no session
  Future<void> signOut();                     // keeps consent
}

// account_service.dart
final class AccountService {
  new({required AccountAuth auth, required SettingsRepository settings,
       required BackgroundScheduler scheduler, required Clock clock});
  Stream<AccountState> watch();               // from settings + this run's silent result;
                                              // signed in = backupAccountEmail set (interim I1, Replaced in 011)
  Future<AccountState> current();
  Future<void> restoreSession();              // SYS-01, best effort, never throws (FR-004):
                                              // no session → clear keys, keep data (interim I5, Replaced in 011);
                                              // offline/error → stay signed in, unverified
  Future<AccountProfile?> signIn();           // null when cancelled; saves profile;
                                              // autoBackupFrequency off → daily (FR-006);
                                              // syncs the periodic job
  Future<void> signOut();                     // clears keys + lastKnown*, cancels jobs (FR-024)
  Future<void> forgetAfterAuthLoss();         // called on DriveAuthRequired (R2): clear keys, keep data
                                              // (interim I5, Replaced in 011: also authMode = guest)
}

// domain/device_identity.dart (pure)
final class DeviceIdentity { const new({required this.id, required this.name}); }
enum DeviceIdOrigin { existing, created, restoredFromAndroidBackup }
abstract final class DeviceIdentityPolicy {
  static DeviceIdOrigin resolve({required String? fileId, required String? settingsId}); // R4 table
  static String displayName(String manufacturer, String model);   // "Android phone" fallback, ≤ 60 chars
}

// data/no_backup_device_id_store.dart
abstract interface class DeviceIdFile { Future<String?> read(); Future<void> write(String id); }
final class ChannelDeviceIdFile implements DeviceIdFile;   // getNoBackupDir on dailytrack/window

// device_identity_service.dart
final class DeviceIdentityService {
  Future<DeviceIdOrigin> ensure();            // SYS-01, before routing
  Future<DeviceIdentity> current();           // id + live name
}

// account_restore.dart (one restore path for ACC-02, SYS-02 (interim), the SET-02 Drive card and
// Drive list, SYS-03, and later 011's AUTH-01; R12)
sealed class AccountRestoreResult;
final class Restored extends AccountRestoreResult { RestoreOutcome outcome; RestorePreview preview; }
final class RestoreCancelled extends AccountRestoreResult;   // password sheet dismissed
final class SafetyCopyFailed extends AccountRestoreResult;   // nothing written (FR-019a)

final class AccountRestore {
  new({required DriveBackupStore drive, required RestoreService restore, required BackupEngine engine,
       required SafetyCopyStore safety, required BackupPasswordStore passwords,
       required SettingsRepository settings, required Clock clock});
  Future<bool> phoneHasData();                              // BackupEngine.hasUserData (R11)
  Future<Map<String, int>> phoneCounts();                   // ACC-02 "This phone" line; keeps data/ out of presentation
  Future<void> rememberEncryption(String password);         // FR-019b, also used by SET-02 local file restore
  Future<RestoreCandidate> open(DriveBackupEntry entry, {required Future<String?> Function() askPassword});
  Future<AccountRestoreResult> apply(RestoreCandidate c, {required DriveBackupEntry entry,
       required String? usedPassword, required bool fromEmptyPhone});
       // safety copy if phone has data → RestoreService.apply → counters, lastKnown*, pause cleared,
       // FR-019b encryption, finishSetupPending when fromEmptyPhone && !lockEnabled (interim I6)
  Future<void> keepThisPhone(DriveBackupEntry newest);      // ACC-02 Keep (FR-020)
}
```

## `lib/core/backup/` (extended)

```dart
// backup_section.dart — two new members
abstract class BackupSection {
  Set<String> get tables;                                   // for the trigger check (R5)
  Future<bool> hasUserData(AppDatabase db);                 // seeded rows excluded (R11)
}

// domain/backup_meta.dart (pure)
final class BackupMeta { deviceId, deviceName, appVersion, createdAt, kind, counts, schemaVersion, encrypted;
  Map<String, Object?> toJson(); factory fromJson(Map<String, Object?>); }
abstract final class BackupMetaCodec {
  static Map<String, String> toProperties(BackupMeta m);   // ≤ 30 entries, ≤ 124 bytes each
  static BackupMeta? fromProperties(Map<String, String?> p);
}

// domain/backup_document.dart — optional meta
final class BackupDocument { final BackupMeta? meta; /* toJson writes it when present */ }

// domain/change_counter.dart (pure)
abstract final class ChangeCounter {
  static bool changed({required int current, required int backedUp}) => current != backedUp;
}

// domain/background_backup_trigger.dart (pure, R6)
abstract final class BackgroundBackupTrigger {
  static const Duration minGap = Duration(minutes: 15);
  static bool shouldEnqueue({required bool signedIn, required AutoBackupFrequency frequency,
      required bool onboardingDone, required bool changed, required int? lastBackgroundBackupAt,
      required int nowMs});
}

// domain/backup_conflict_policy.dart (pure, R9, R10)
sealed class ConflictCheck; final class NoConflict; final class NewerFromOtherDevice { BackupMeta newest; }
final class EmptyOverData { BackupMeta newest; }
abstract final class BackupConflictPolicy {
  static ConflictCheck check({required BackupMeta? newest, required String thisDeviceId,
      required int? lastKnownAt, required bool phoneHasData});
}

// domain/auto_backup_rotation.dart (pure, R15)
abstract final class AutoBackupRotation {
  static const int earlierDays = 5;
  static List<DriveBackupEntry> toDelete(List<DriveBackupEntry> entries, {required DateTime nowLocal});
}

// domain/safety_copy_policy.dart (pure)
abstract final class SafetyCopyPolicy {
  static const Duration keepFor = Duration(days: 7);
  static bool expired({required int createdAt, required int nowMs});
}

// domain/backup_status_policy.dart (pure; data-model §7)
sealed class BackupStatus; /* backedUp, backingUp, paused, failed, waitingForWifi, offline */
abstract final class BackupStatusPolicy { static BackupStatus derive(...); }

// domain/drive_backup_store.dart — changed members
final class DriveBackupEntry { /* + */ final BackupMeta? meta; }
abstract interface class DriveBackupStore {
  Future<void> upload(Uint8List bytes, {required String fileName, required BackupMeta meta}); // was kind:
  Future<void> deleteAll();                                  // Delete my backups (R16)
  // removed: connect(), disconnect(), pruneAuto()  — sign-in moves to AccountService
}

// backup_service.dart — changed
enum ConflictMode { ask, overwrite, pause }
Future<DriveBackupResult> backupToDrive({required BackupKind kind, required ConflictMode conflict});
   // reads counter inside the export txn; conflict + empty check (R9, R10); upload with meta;
   // on success: backedUpChangeCounter, lastKnownDriveBackup*, pause cleared; auto → rotation (R15)
Future<DriveBackupResult> backupIfChanged();               // auto runs: Unchanged when counter equal (R7)

// data/safety_copy_store.dart
abstract interface class SafetyCopyStore {
  Future<void> save(BackupFile file, {required Map<String, int> counts, required int createdAt}); // BackupStorageFull
  Future<SafetyCopyInfo?> info();
  Future<Uint8List?> read();
  Future<void> delete();
}

// background_backup_scheduler.dart (R6)
final class BackgroundBackupScheduler {
  Future<void> onAppHidden();                                // app.dart onHide
}
const String backgroundBackupTaskName = 'core.backgroundBackup';
```

## `lib/core/background/`

```dart
abstract interface class BackgroundScheduler {
  // + one-off, replacing any waiting one (R6)
  Future<void> enqueueOnce(String uniqueName, {NetworkRequirement network = NetworkRequirement.none});
}
```

## `lib/core/database/`

`AppDatabase.schemaVersion` 5: `onUpgrade` from 4 creates the change-counter triggers (data-model §2); `onCreate` creates them after `createAll`. Migration test 4 → 5 and a fresh-create test.

## `lib/app/` (glue)

- `auto_backup_task.dart`: `runAutoBackup` uses `backupIfChanged()` with `ConflictMode.pause`, shows the pause notice once (`stableNotificationId('backup-paused')`, payload `Routes.account`), treats `SkippedEmpty`/`Unchanged` as success, calls `AccountService.forgetAfterAuthLoss` on `DriveAuthRequired`. The background dispatcher maps both `core.autoBackup` and `core.backgroundBackup` to it.
- `app.dart`: `onHide` → `BackgroundBackupScheduler.onAppHidden()`; shows `FinishSetupSheet` on Home when `finishSetupPending` (R13).
- `bootstrap.dart` (SYS-01): `DeviceIdentityService.ensure()`; when `restoredFromAndroidBackup`, runs the post-Android-restore steps (R13; no `authMode` handling, interim I7, **Replaced in 011**); `AccountService.restoreSession()`; deletes an expired safety copy. 011 adds the `authMode` migration here, before routing.
- `production_overrides.dart`: binds `accountAuthProvider` to `GoogleAuth`, `accountUiProvider` (opens ACC-02 / ACC-03 from other features, R18), and Erase all data changes (R16).

```dart
// lib/core/reset/domain/app_reset_service.dart — the keep-list becomes a parameter (FR-006a)
abstract interface class AppResetService {
  Future<void> eraseAll({Set<String> keepSettings = AppResetService.eraseAllKeeps});
  static const Set<String> eraseAllKeeps = { /* account keys, deviceId, lastKnownDriveBackup*,
      autoBackupFrequency, autoBackupWifiOnly (data-model §1) */ };
}
// 011's ACC-04 calls eraseAll(keepSettings: <device preferences, onboarding done, deviceId,
// adsInstallAt, ad consent, Pro state>) and adds authMode to eraseAllKeeps.
```
