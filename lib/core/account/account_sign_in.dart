import 'package:dailytrack/core/account/account_service.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/support/network_state_source.dart';

/// How "Sign in with Google" ended (ACC-01, SET-02).
sealed class SignInOutcome {
  const new();
}

/// The chooser was closed; nothing changed.
final class SignInCancelled extends SignInOutcome {
  const new();
}

/// The phone is offline; nothing was asked of Google (spec §16 "Offline,
/// the sign-in button shows "Connect to the internet to sign in with
/// Google" and makes no request").
final class SignInOffline extends SignInOutcome {
  const new();
}

/// The account had no backup; the first one was made (ACC-01 "Signed in.
/// Your data is backed up.").
final class SignedInAndBackedUp extends SignInOutcome {
  const new();
}

/// The account already has backups; nothing was uploaded. The caller
/// opens the restore choice for [newest] (ACC-02, FR-016).
final class SignedInWithBackups extends SignInOutcome {
  const new(this.newest);

  final DriveBackupEntry newest;
}

/// Signed in, but listing Drive or the first backup failed.
final class SignedInBackupFailed extends SignInOutcome {
  const new(this.error);

  final Object error;
}

/// How AUTH-01 "Continue with Google" ended before the restore check
/// (feature 011 research R9). None of them sets `authMode`.
sealed class LoginOutcome {
  const new();
}

/// The phone is offline; nothing was asked of Google.
final class LoginOffline extends LoginOutcome {
  const new();
}

/// The chooser was closed; nothing was written.
final class LoginCancelled extends LoginOutcome {
  const new();
}

/// Signing in, or listing Drive after it, failed; nothing is left written.
final class LoginFailed extends LoginOutcome {
  const new(this.error);

  final Object error;
}

/// Signed in (keys saved, not committed); the account has no backup.
final class LoginNoBackup extends LoginOutcome {
  const new();
}

/// Signed in (keys saved, not committed); [newest] is the account's newest
/// backup, for the ACC-02 restore check.
final class LoginHasBackups extends LoginOutcome {
  const new(this.newest);

  final DriveBackupEntry newest;
}

/// The shared "Sign in with Google" (spec §16 ACC-01 Behavior), so ACC-01
/// and SET-02 behave the same (research R1).
final class AccountSignIn {
  new({
    required this._account,
    required this._settings,
    required this._drive,
    required this._backup,
    required this._network,
  });

  final AccountService _account;
  final SettingsRepository _settings;
  final DriveBackupStore _drive;
  final BackupService _backup;
  final NetworkStateSource _network;

  /// Throws a `BackupFailure` when signing in itself fails. A failed first
  /// backup keeps the sign-in; auto backup tries again (spec §16).
  Future<SignInOutcome> run() async {
    if (!(await _network.load()).online) return const SignInOffline();
    final profile = await _account.signIn();
    if (profile == null) return const SignInCancelled();
    await _account.commitSignIn();
    try {
      return await _account.guardAuth(() async {
        final backups = await _drive.list();
        if (backups.isNotEmpty) return SignedInWithBackups(backups.first);
        await _backup.backupToDrive(
          kind: BackupKind.manual,
          conflict: ConflictMode.overwrite,
        );
        return const SignedInAndBackedUp();
      });
    } on Object catch (e) {
      return SignedInBackupFailed(e);
    }
  }

  /// AUTH-01 "Continue with Google" (feature 011 research R9): the chooser,
  /// then the account's backups. Saves the account keys only; the caller
  /// commits the sign-in once the restore check settles. Never throws.
  Future<LoginOutcome> login() async {
    if (!(await _network.load()).online) return const LoginOffline();
    final AccountProfile? profile;
    try {
      profile = await _account.signIn();
    } on Object catch (e) {
      return LoginFailed(e);
    }
    if (profile == null) return const LoginCancelled();
    try {
      // Not through `guardAuth`: losing access here must leave the user on
      // AUTH-01 with `authMode` none, not make them a guest.
      final backups = await _drive.list();
      return backups.isEmpty
          ? const LoginNoBackup()
          : LoginHasBackups(backups.first);
    } on Object catch (e) {
      try {
        await _settings.setAccount(null);
      } on Object {
        // The next start clears leftover keys (research R5).
      }
      return LoginFailed(e);
    }
  }
}
