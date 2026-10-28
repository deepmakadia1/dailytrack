import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/network_state_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.freezed.dart';
part 'account_controller.g.dart';

/// What ACC-01 is doing right now. While [switching] or [signingOut], the
/// account is briefly signed out without the screen closing.
enum AccountBusy { none, backingUp, deleting, switching, signingOut }

/// What ACC-01 shows (feature 010 contracts/screens.md "ACC-01").
@freezed
abstract class AccountScreenState with _$AccountScreenState {
  const factory({
    /// Signed out, or signed in without a working session this run, closes
    /// the screen (feature 010 research R2; feature 011 rule 7).
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

    /// UTC epoch milliseconds of the last background backup request.
    int? lastBackgroundBackupAt,

    /// The network, read when the screen opens and on resume (data-model
    /// §7). Offline disables Back up now, Restore, Switch account, and
    /// Delete my backups.
    @Default(NetworkState.unknown) NetworkState network,

    /// Reading Drive failed with `DriveOffline`: shown as offline.
    @Default(false) bool driveOffline,

    /// The last backup started on this screen failed, this session.
    Object? failure,

    /// "Encrypt backup" is on but the password is missing (research R13).
    @Default(false) bool missingPassword,

    /// The account's Drive backups, newest first; null while signed out.
    AsyncValue<List<DriveBackupEntry>>? drive,
    @Default(AccountBusy.none) AccountBusy busy,

    /// A backup holds the lease right now, in any isolate (feature 011
    /// research R11), so ACC-01 and the SET-01 card agree on "Backing up…".
    @Default(false) bool leaseHeld,
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

  /// No network, or Drive said it can't be reached.
  bool get offline => !network.online || driveOffline;

  /// The state line (data-model §7).
  BackupStatus get status => BackupStatusPolicy.derive(
    online: !offline,
    backingUp: busy == AccountBusy.backingUp || leaseHeld,
    paused: paused,
    autoBackupFailures: autoBackupFailures,
    lastBackupAt: lastBackupAt,
    failure: missingPassword ? const BackupNeedsPassword() : failure,
    lastBackgroundBackupAt: lastBackgroundBackupAt,
    wifiOnly: wifiOnly && autoFrequency != AutoBackupFrequency.off,
    metered: network.metered,
  );
}

/// ACC-01 Account controller (spec §16): Back up now, Switch account, and
/// Delete my backups for a signed-in account. Restore and Sign out open
/// ACC-02 and ACC-03, which have their own controllers. Signing in never
/// happens on ACC-01.
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
    final missingPassword =
        s.backupEncrypt &&
        (previous?.missingPassword ?? await _passwordMissing());
    final next = AccountScreenState(
      account: ref.read(accountServiceProvider).stateOf(s),
      driveAvailable: available,
      autoFrequency: s.autoBackupFrequency,
      wifiOnly: s.autoBackupWifiOnly,
      paused: s.autoBackupPausedByConflict,
      autoBackupFailures: s.autoBackupFailures,
      lastBackupAt: s.lastBackupAt,
      lastBackgroundBackupAt: s.lastBackgroundBackupAt,
      network: previous?.network ?? await _network(),
      driveOffline: previous?.driveOffline ?? false,
      failure: previous?.failure,
      missingPassword: missingPassword,
      busy: previous?.busy ?? AccountBusy.none,
      leaseHeld:
          (s.backupLeaseUntil ?? 0) >
          ref.read(clockProvider).now().toUtc().millisecondsSinceEpoch,
    );
    final email = next.profile?.email;
    if (email == null) return next;
    // Settings change often (every backup writes several keys); the Drive
    // list is read again only for a different account.
    final kept = previous?.profile?.email == email ? previous?.drive : null;
    if (kept != null) return next.copyWith(drive: kept);
    if (!next.network.online) return next;
    // After build returns, so the list lands on the new state.
    unawaited(Future<void>(refreshDrive));
    return next.copyWith(drive: const AsyncLoading());
  }

  Future<NetworkState> _network() =>
      ref.read(networkStateSourceProvider).load();

  Future<bool> _passwordMissing() async =>
      await ref.read(backupPasswordStoreProvider).read() == null;

  void _update(AccountScreenState Function(AccountScreenState) change) {
    if (!ref.mounted) return;
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

  /// When the app resumes: reads the network and the password again, then
  /// Drive when online.
  Future<void> refresh() async {
    final network = await _network();
    final settings = await ref.read(settingsRepositoryProvider).load();
    final missing = settings.backupEncrypt && await _passwordMissing();
    _update(
      (s) => s.copyWith(
        network: network,
        driveOffline: false,
        missingPassword: missing,
      ),
    );
    if (network.online) await refreshDrive();
  }

  /// Keeps ACC-01 open while ACC-03 signs out; the sheet then moves on.
  Future<T> holdForSignOut<T>(Future<T> Function() sheet) =>
      _busy(AccountBusy.signingOut, sheet);

  /// Drive calls made on this screen: an expired sign-in signs the
  /// account out (research R2).
  Future<T> _drive<T>(Future<T> Function() body) =>
      ref.read(accountServiceProvider).guardAuth(body);

  /// Reads the account's backups for the status area. `DriveOffline`
  /// shows as the offline state, not as an error.
  Future<void> refreshDrive() async {
    if (state.value?.profile == null) return;
    _update((s) => s.copyWith(drive: const AsyncLoading()));
    final result = await AsyncValue.guard(
      () => _drive(ref.read(driveBackupStoreProvider).list),
    );
    _update(
      (s) =>
          s.copyWith(drive: result, driveOffline: result.error is DriveOffline),
    );
  }

  /// "Back up now": a manual backup with the conflict rule, ignoring
  /// "Wi-Fi only". [overwrite] is "Back up anyway" after the warning.
  /// Throws a `BackupFailure`.
  Future<DriveBackupResult> backUpNow({bool overwrite = false}) async {
    final DriveBackupResult result;
    try {
      result = await _busy(AccountBusy.backingUp, () => _backUp(overwrite));
    } on Object catch (e) {
      _update((s) => s.copyWith(failure: e));
      rethrow;
    }
    if (result is Uploaded) {
      _update((s) => s.copyWith(failure: null, missingPassword: false));
      await refreshDrive();
    }
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

  /// "Switch account" step 2: the account chooser, without touching this
  /// phone's data; the new account goes on like "Sign in with Google".
  /// Cancelling (or offline, or a failure) signs out to `guest` with all
  /// data kept, and the router's rule 7 closes ACC-01 back to SET-01, which
  /// shows the guest card (feature 011 US5 scenario 6).
  Future<SignInOutcome> switchAccount() async {
    final account = ref.read(accountServiceProvider);
    final signIn = ref.read(accountSignInProvider);
    final outcome = await _busy(AccountBusy.switching, () async {
      await account.beginSwitch();
      final SignInOutcome outcome;
      try {
        outcome = await signIn.run();
      } on Object {
        await account.signOut(to: AuthMode.guest);
        rethrow;
      }
      if (outcome is SignInCancelled || outcome is SignInOffline) {
        await account.signOut(to: AuthMode.guest);
      }
      return outcome;
    });
    if (!ref.mounted) return outcome;
    await refreshDrive();
    return outcome;
  }
}
