import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/account_ui.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/auth/presentation/controllers/login_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

/// AUTH-01 Login controller (spec §6 AUTH-01, feature 011 research R9).
/// `authMode` is written only once every branch has settled, so the user
/// stays on AUTH-01 (and nothing backs up on its own) until then. Setting
/// it makes the router leave AUTH-01; this controller never navigates.
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void _set(LoginState next) {
    if (ref.mounted) state = next;
  }

  /// "Continue as guest": no sign-in, Drive, or network call (FR-032).
  Future<void> continueAsGuest() async {
    if (state.isBusy) return;
    _set(const LoginState(busy: LoginBusy.finishing));
    final settings = ref.read(settingsRepositoryProvider);
    try {
      // The sheet's flag first, so Home finds it (research R10).
      await settings.setFinishSetupPending(pending: true);
      await settings.setAuthMode(AuthMode.guest);
    } on Object {
      _set(const LoginState(error: LoginError.failed));
    }
  }

  /// "Continue with Google": the chooser, then the restore check. Nothing
  /// is written when it is cancelled, fails, or the phone is offline.
  Future<LoginNext> continueWithGoogle() async {
    if (state.isBusy) return const LoginDone();
    _set(const LoginState(busy: LoginBusy.signingIn));
    final outcome = await ref.read(accountSignInProvider).login();
    switch (outcome) {
      case LoginOffline():
        _set(const LoginState(error: LoginError.offline));
      case LoginCancelled():
        _set(const LoginState(error: LoginError.cancelled));
      case LoginFailed():
        _set(const LoginState(error: LoginError.failed));
      case LoginNoBackup():
        await _finish(backUp: true);
      case LoginHasBackups(:final newest):
        return await _chooseRestore(newest);
    }
    return const LoginDone();
  }

  /// "Try again" under the inline error.
  Future<LoginNext> tryAgain() => continueWithGoogle();

  /// "Try again" on the restore error view: the restore check again.
  Future<LoginNext> retryRestore() async {
    final newest = state.pendingBackup;
    if (newest == null || state.isBusy) return const LoginDone();
    return await _chooseRestore(newest);
  }

  Future<LoginNext> _chooseRestore(DriveBackupEntry newest) async {
    bool hasData;
    try {
      hasData = await ref.read(accountRestoreProvider).phoneHasData();
    } on Object {
      // Unknown: ACC-02 asks rather than replaces.
      hasData = true;
    }
    // With no user data the backup is restored at once behind the
    // full-screen progress view; otherwise ACC-02 asks.
    _set(
      LoginState(
        busy: hasData ? LoginBusy.choosing : LoginBusy.restoring,
        pendingBackup: newest,
      ),
    );
    return LoginChooseRestore(newest);
  }

  /// How the ACC-02 restore check ended. [onProRestored] runs when the
  /// background Restore purchase finds Pro after a restore (PRM-01).
  Future<void> onRestoreChoice(
    RestoreChoiceResult result, {
    void Function()? onProRestored,
  }) async {
    switch (result) {
      case RestoreChoiceResult.restored:
        final pro = ref.read(proServiceProvider);
        unawaited(
          pro.restore().then((r) {
            if (r == RestoreResult.restored) onProRestored?.call();
          }, onError: (Object _) {}),
        );
        await _finish(backUp: false);
      case RestoreChoiceResult.kept:
        // ACC-02 already started the backup of this phone's data.
        await _finish(backUp: false);
      case RestoreChoiceResult.closed:
        // A failed or cancelled restore; this phone's data is unchanged.
        _set(
          LoginState(restoreFailed: true, pendingBackup: state.pendingBackup),
        );
    }
  }

  /// "Continue without restoring": signed in with this phone's data as it
  /// is. The empty-phone guard keeps auto backup from replacing the
  /// account's backup with an empty one (spec §16).
  Future<void> continueWithoutRestoring() async {
    if (state.isBusy) return;
    await _finish(backUp: false);
  }

  /// Every finished Google branch: the "Finish setting up" flag, then
  /// `authMode = google` with Auto backup Daily if it was Off. [backUp]
  /// runs the first backup for an account that had none; a failure is
  /// quiet, since auto backup tries again.
  Future<void> _finish({required bool backUp}) async {
    _set(state.copyWith(busy: LoginBusy.finishing, restoreFailed: false));
    // Read now: committing makes the router leave AUTH-01, which disposes
    // this controller.
    final settings = ref.read(settingsRepositoryProvider);
    final account = ref.read(accountServiceProvider);
    final backups = ref.read(backupServiceProvider);
    try {
      await settings.setFinishSetupPending(pending: true);
      await account.commitSignIn();
    } on Object {
      _set(const LoginState(error: LoginError.failed));
      return;
    }
    if (backUp) {
      unawaited(
        backups
            .backupToDrive(
              kind: BackupKind.manual,
              conflict: ConflictMode.overwrite,
            )
            .then((_) {}, onError: (Object _) {}),
      );
    }
  }
}
