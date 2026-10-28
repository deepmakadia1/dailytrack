import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// What AUTH-01 is waiting for (feature 011 data-model §4).
enum LoginBusy {
  none,

  /// Google Sign-In and the account's backups.
  signingIn,

  /// ACC-02 asks over the screen (this phone has data): buttons disabled,
  /// nothing spins while the user chooses.
  choosing,

  /// The full-screen "Restoring your data…" view (no user data on the
  /// phone, so the newest backup is restored without a choice).
  restoring,

  /// Committing the login; the router leaves AUTH-01 next.
  finishing,
}

/// The inline error under the buttons (spec AUTH-01).
enum LoginError { cancelled, failed, offline }

/// AUTH-01 Login state (feature 011 data-model §4).
@freezed
abstract class LoginState with _$LoginState {
  const factory({
    @Default(LoginBusy.none) LoginBusy busy,
    LoginError? error,

    /// The restore error view, with "Try again" and "Continue without
    /// restoring".
    @Default(false) bool restoreFailed,

    /// The account's newest backup, for "Try again" on the restore error.
    DriveBackupEntry? pendingBackup,
  }) = _LoginState;

  const new _();

  /// Both buttons are disabled.
  bool get isBusy => busy != LoginBusy.none;
}

/// What the screen does after a Google action (the controller holds no
/// `BuildContext`).
sealed class LoginNext {
  const new();
}

/// Nothing to show: an error, or the login finished and the router leaves.
final class LoginDone extends LoginNext {
  const new();
}

/// Open the ACC-02 restore check for [newest] and pass its result to
/// `LoginController.onRestoreChoice`.
final class LoginChooseRestore extends LoginNext {
  const new(this.newest);

  final DriveBackupEntry newest;
}
