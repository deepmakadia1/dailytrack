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
/// Features never import each other, so SET-01, SET-02, and AUTH-01 reach
/// the account feature through this port; `production_overrides.dart`
/// binds the account feature's version.
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

  /// SET-01 item 1 (spec §10): the guest or Google state, from `authMode`
  /// (feature 011 research R11).
  Widget accountCard();

  /// Guest sign-in (spec §16) with its outcome UI: the snackbars, ACC-02
  /// (afterSignIn: true), and the offline and failure messages. Used by the
  /// SET-01 card, the SET-02 Drive card, and ACC-04 "Sign in with Google
  /// instead".
  Future<void> startGuestSignIn(BuildContext context);

  /// ACC-04 Log out of guest (spec §16). Opened only while `authMode ==
  /// guest`, from the SET-01 Data group.
  Future<void> showLogOutGuest(BuildContext context);
}
