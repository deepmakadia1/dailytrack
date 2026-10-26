import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.freezed.dart';
part 'account_controller.g.dart';

/// What ACC-01 is doing right now.
enum AccountBusy { none, signingIn, backingUp, deleting, switching }

/// What ACC-01 shows (feature 010 contracts/screens.md "ACC-01").
@freezed
abstract class AccountScreenState with _$AccountScreenState {
  const factory({
    /// Signed out, or signed in without a working session this run, shows
    /// the signed-out content (research R2).
    required AccountState account,

    /// Google Drive is configured in this build.
    required bool driveAvailable,
    required AutoBackupFrequency autoFrequency,
    required bool wifiOnly,

    /// Auto backup is paused by a newer backup from another phone.
    required bool paused,
    required int autoBackupFailures,

    /// UTC epoch milliseconds of the last backup, or null.
    int? lastBackupAt,

    /// The account's Drive backups, newest first; null while signed out.
    AsyncValue<List<DriveBackupEntry>>? drive,
    @Default(AccountBusy.none) AccountBusy busy,
  }) = _AccountScreenState;
}

/// What [AccountScreenState] derives.
extension AccountScreenView on AccountScreenState {
  /// The account, when it can be used for Drive this run.
  AccountProfile? get profile {
    if (!this.driveAvailable) return null;
    return switch (account) {
      SignedIn(:final profile, verified: true) => profile,
      _ => null,
    };
  }

  /// The state line (data-model §7).
  BackupStatus get status => BackupStatusPolicy.derive(
    backingUp: busy == AccountBusy.backingUp,
    paused: paused,
    autoBackupFailures: autoBackupFailures,
    lastBackupAt: lastBackupAt,
  );
}

/// ACC-01 Account controller (spec §16): sign in, Back up now, Switch
/// account, and Delete my backups. Restore and Sign out open ACC-02 and
/// ACC-03, which have their own controllers.
@riverpod
class AccountController extends _$AccountController {
  @override
  Future<AccountScreenState> build() async {
    final settings = ref.watch(appSettingsProvider.future);
    // Rebuilds when this run's silent sign-in result changes.
    ref.watch(accountStateProvider);
    final available = ref.watch(driveAvailableProvider);
    final s = await settings;
    final previous = state.value;
    final next = AccountScreenState(
      account: ref.read(accountServiceProvider).stateOf(s),
      driveAvailable: available,
      autoFrequency: s.autoBackupFrequency,
      wifiOnly: s.autoBackupWifiOnly,
      paused: s.autoBackupPausedByConflict,
      autoBackupFailures: s.autoBackupFailures,
      lastBackupAt: s.lastBackupAt,
      busy: previous?.busy ?? AccountBusy.none,
    );
    final email = next.profile?.email;
    if (email == null) return next;
    // Settings change often (every backup writes several keys); the Drive
    // list is read again only for a different account.
    final kept = previous?.profile?.email == email ? previous?.drive : null;
    if (kept != null) return next.copyWith(drive: kept);
    // After build returns, so the list lands on the new state.
    unawaited(Future<void>(refreshDrive));
    return next.copyWith(drive: const AsyncLoading());
  }

  void _update(AccountScreenState Function(AccountScreenState) change) {
    final current = state.value;
    if (current != null) state = AsyncData(change(current));
  }

  Future<T> _busy<T>(AccountBusy busy, Future<T> Function() body) async {
    _update((s) => s.copyWith(busy: busy));
    try {
      return await body();
    } finally {
      _update((s) => s.copyWith(busy: AccountBusy.none));
    }
  }

  /// Error state "Try again".
  void retry() => ref.invalidateSelf();

  /// Drive calls made on this screen: an expired sign-in signs the
  /// account out (research R2).
  Future<T> _drive<T>(Future<T> Function() body) =>
      ref.read(accountServiceProvider).guardAuth(body);

  /// Reads the account's backups for the status area.
  Future<void> refreshDrive() async {
    if (state.value?.profile == null) return;
    _update((s) => s.copyWith(drive: const AsyncLoading()));
    final result = await AsyncValue.guard(
      () => _drive(ref.read(driveBackupStoreProvider).list),
    );
    _update((s) => s.copyWith(drive: result));
  }

  /// "Sign in with Google". Throws a `BackupFailure` when signing in fails.
  Future<SignInOutcome> signIn() async {
    final outcome = await _busy(
      AccountBusy.signingIn,
      ref.read(accountSignInProvider).run,
    );
    await refreshDrive();
    return outcome;
  }

  /// "Back up now": a manual backup with the conflict rule, ignoring
  /// "Wi-Fi only". [overwrite] is "Back up anyway" after the warning.
  /// Throws a `BackupFailure`.
  Future<DriveBackupResult> backUpNow({bool overwrite = false}) async {
    final result = await _busy(AccountBusy.backingUp, () => _backUp(overwrite));
    if (result is Uploaded) await refreshDrive();
    return result;
  }

  Future<DriveBackupResult> _backUp(bool overwrite) => _drive(
    () => ref
        .read(backupServiceProvider)
        .backupToDrive(
          kind: BackupKind.manual,
          conflict: overwrite ? ConflictMode.overwrite : ConflictMode.ask,
        ),
  );

  /// "Delete my backups": every DailyTrack file in the app folder. Local
  /// data and the sign-in stay; the next auto backup starts fresh. Throws a
  /// `BackupFailure` after deleting what it could.
  Future<void> deleteMyBackups() async {
    try {
      await _busy(AccountBusy.deleting, () async {
        await _drive(ref.read(driveBackupStoreProvider).deleteAll);
        await ref
            .read(settingsRepositoryProvider)
            .setLastKnownDriveBackup(at: null, deviceId: null);
      });
    } finally {
      await refreshDrive();
    }
  }

  /// "Switch account" step 1: back up to the current account first (as in
  /// ACC-03), with the conflict rule. Throws a `BackupFailure`; the screen
  /// then offers "Switch anyway".
  Future<DriveBackupResult> backUpBeforeSwitch({bool overwrite = false}) =>
      _busy(AccountBusy.switching, () => _backUp(overwrite));

  /// "Switch account" step 2: signs out without touching this phone's
  /// data, then the account chooser; the new account goes on like "Sign in
  /// with Google". Cancelling leaves the user signed out with data kept.
  Future<SignInOutcome> switchAccount() async {
    final outcome = await _busy(AccountBusy.switching, () async {
      await ref.read(accountServiceProvider).signOut();
      return await ref.read(accountSignInProvider).run();
    });
    await refreshDrive();
    return outcome;
  }
}
