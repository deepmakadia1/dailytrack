import 'package:dailytrack/core/account/account_service.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';

/// How "Sign in with Google" ended (ACC-01, SET-02).
sealed class SignInOutcome {
  const new();
}

/// The chooser was closed; nothing changed.
final class SignInCancelled extends SignInOutcome {
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

/// The shared "Sign in with Google" (spec §16 ACC-01 Behavior), so ACC-01
/// and SET-02 behave the same (research R1).
final class AccountSignIn {
  new({required this._account, required this._drive, required this._backup});

  final AccountService _account;
  final DriveBackupStore _drive;
  final BackupService _backup;

  /// Throws a `BackupFailure` when signing in itself fails.
  Future<SignInOutcome> run() async {
    final profile = await _account.signIn();
    if (profile == null) return const SignInCancelled();
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
}
