import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter/widgets.dart';

/// How the restore choice ended.
enum RestoreChoiceResult {
  /// The backup replaced this phone's data.
  restored,

  /// "Keep this phone's data".
  kept,

  /// Closed, cancelled, or failed; nothing changed.
  closed,
}

/// The account screens other features open (feature 010 research R18).
/// Features never import each other, so SET-02 reaches ACC-02 through this
/// port; `production_overrides.dart` binds the account feature's version.
abstract interface class AccountUi {
  /// After sign-in to an account with backups, or ACC-01 "Restore": with
  /// no user data on this phone, [newest] is restored at once behind a
  /// progress view (FR-016); otherwise ACC-02 asks. [afterSignIn] makes the
  /// choice impossible to dismiss without choosing (FR-021).
  Future<RestoreChoiceResult> showRestoreChoice(
    BuildContext context, {
    required DriveBackupEntry newest,
    required bool afterSignIn,
  });
}
