import 'dart:async';

import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/account_auth.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';

/// The optional Google account (spec §16, feature 010 data-model §6). The
/// one place that signs in and out, shared by ACC-01, SET-02, and SYS-03
/// (research R1). Account state lives in settings; this run's silent
/// sign-in result is kept in memory.
final class AccountService {
  new({required this._auth, required this._settings, required this._scheduler});

  final AccountAuth _auth;
  final SettingsRepository _settings;
  final BackgroundScheduler _scheduler;

  /// This run's silent sign-in failed (research R2).
  bool _silentFailed = false;

  /// The account was forgotten after Drive refused it, until the next
  /// sign-in or sign-out.
  bool _expired = false;
  final StreamController<void> _verifiedChanges =
      StreamController<void>.broadcast();

  /// The account in [s], as this run sees it: signed in only once the
  /// sign-in is committed (`authMode == google`, feature 011 research R4).
  AccountState stateOf(AppSettings s) {
    final email = s.backupAccountEmail;
    if (email == null || s.authMode != AuthMode.google) {
      return SignedOut(expired: _expired);
    }
    return SignedIn(
      AccountProfile(
        email: email,
        displayName: s.accountDisplayName,
        photoUrl: s.accountPhotoUrl,
      ),
      verified: !_silentFailed,
    );
  }

  /// The current state, then again after every change.
  Stream<AccountState> watch() => Stream<AccountState>.multi((controller) {
    AppSettings? last;
    void emit() {
      final s = last;
      if (s != null) controller.add(stateOf(s));
    }

    final settings = _settings.watch().listen((s) {
      last = s;
      emit();
    }, onError: controller.addError);
    final verified = _verifiedChanges.stream.listen((_) => emit());
    controller.onCancel = () async {
      await settings.cancel();
      await verified.cancel();
    };
  });

  Future<AccountState> current() async => stateOf(await _settings.load());

  void _setSilentFailed({required bool failed}) {
    if (_silentFailed == failed) return;
    _silentFailed = failed;
    _verifiedChanges.add(null);
  }

  /// SYS-01, after routing (spec §16 "Account state is local", FR-004,
  /// feature 011 research R5). With `google`: a silent sign-in; no session
  /// (null: token revoked, account removed from the phone) makes the user a
  /// guest with all data kept, and any thrown failure, such as being
  /// offline, keeps them signed in, unverified. With `none` or `guest`,
  /// account keys left by an interrupted sign-in are cleared and Google is
  /// signed out, so the user can sign in again; with no keys, Google is not
  /// called at all. Never throws.
  Future<void> restoreSession() async {
    try {
      final s = await _settings.load();
      if (s.authMode != AuthMode.google) {
        if (s.backupAccountEmail == null) return;
        await _settings.setAccount(null);
        try {
          await _auth.signOut();
        } on Object {
          // Best effort; the keys are gone, so nothing runs.
        }
        return;
      }
      // `google` without keys only happens right after an Android restore,
      // whose own step adopts the session or makes the user a guest.
      if (s.backupAccountEmail == null) return;
      final profile = await _auth.signInSilently();
      if (profile == null) {
        await forgetAfterAuthLoss();
        return;
      }
      await _settings.setAccount(profile);
      _setSilentFailed(failed: false);
    } on Object {
      _setSilentFailed(failed: true);
    }
  }

  /// After an Android Auto Backup restore the stored account is cleared;
  /// a Google session still on this phone is taken over without UI
  /// (spec §16 "First start after an Android Auto Backup restore"). True
  /// when one was. Never throws.
  Future<bool> adoptSilentSession() async {
    try {
      final profile = await _auth.signInSilently();
      if (profile == null) return false;
      await _settings.setAccount(profile);
      _setSilentFailed(failed: false);
      await syncAutoBackupSchedule(await _settings.load(), _scheduler);
      return true;
    } on Object {
      // The caller makes the user a guest; they can sign in from SET-01.
      return false;
    }
  }

  /// The account chooser and Drive consent. Saves the account keys only,
  /// so manual Drive work can run; [commitSignIn] makes it the signed-in
  /// account (feature 011 research R3). Null when the user cancels; other
  /// failures are thrown as `BackupFailure`.
  Future<AccountProfile?> signIn() async {
    final AccountProfile profile;
    try {
      profile = await _auth.signIn();
    } on DriveAuthRequired {
      return null;
    }
    await _settings.setAccount(profile);
    return profile;
  }

  /// After [signIn], once nothing is left to choose (AUTH-01 sets it last,
  /// research R9): `authMode = google`, Auto backup from Off to Daily
  /// (FR-006), and the auto backup schedule.
  Future<void> commitSignIn() async {
    await _settings.setAuthMode(AuthMode.google);
    final s = await _settings.load();
    if (s.autoBackupFrequency == AutoBackupFrequency.off) {
      await _settings.setAutoBackup(
        frequency: AutoBackupFrequency.daily,
        wifiOnly: s.autoBackupWifiOnly,
      );
    }
    _expired = false;
    _setSilentFailed(failed: false);
    await syncAutoBackupSchedule(await _settings.load(), _scheduler);
  }

  /// Signs out and keeps this phone's data and the Drive backups (FR-024).
  /// [to] is written first (ACC-03 `none`, Switch account `guest`), so a
  /// crash never leaves `google` without an account (research R3).
  Future<void> signOut({required AuthMode to}) async {
    await _settings.setAuthMode(to);
    try {
      await _auth.signOut();
    } on Object {
      // Forgetting the account locally is enough to stop backups.
    }
    _expired = false;
    await _forget();
  }

  /// Drive said the account's access is gone (research R2): forget it
  /// locally without calling Google.
  /// A signed-in user becomes a guest; data is kept (feature 011 FR-008).
  /// On AUTH-01 (`none`, keys saved but not committed) the mode stays, so
  /// the user stays on AUTH-01.
  Future<void> forgetAfterAuthLoss() async {
    // First, so every state from here on says the sign-in expired.
    _expired = true;
    if ((await _settings.load()).authMode == AuthMode.google) {
      await _settings.setAuthMode(AuthMode.guest);
    }
    await _forget();
    _verifiedChanges.add(null);
  }

  /// Runs a Drive call made while the user is in the app. When the token
  /// expired or access was removed (`DriveAuthRequired`), the account is
  /// forgotten so it shows as signed out, and the failure is rethrown for
  /// the screen to explain. Background runs don't use this: they can fail
  /// to sign in for ordinary reasons.
  Future<T> guardAuth<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DriveAuthRequired {
      await forgetAfterAuthLoss();
      rethrow;
    }
  }

  /// ACC-01 "Switch account" step 2, before the chooser: signs out of
  /// Google, so the chooser offers every account, and forgets the old
  /// account's backup state. `authMode` stays `google` and the old keys
  /// stay until the chooser ends, so ACC-01 stays open meanwhile; the
  /// caller signs out to `guest` if no new account is chosen. A crash in
  /// between leaves `google` with keys whose silent sign-in fails, which
  /// the next start turns into a guest (feature 011 research R5).
  Future<void> beginSwitch() async {
    try {
      await _auth.signOut();
    } on Object {
      // The chooser may then offer the same account first; still works.
    }
    await _forgetBackupState();
  }

  Future<void> _forget() async {
    await _settings.setAccount(null);
    await _forgetBackupState();
  }

  Future<void> _forgetBackupState() async {
    await _settings.setLastKnownDriveBackup(at: null, deviceId: null);
    await _settings.setLastBackgroundBackupAt(null);
    await _settings.setAutoBackupPause(paused: false, notified: false);
    _setSilentFailed(failed: false);
    for (final name in [autoBackupTaskName, backgroundBackupTaskName]) {
      try {
        await _scheduler.cancel(name);
      } on Object {
        // A job that still runs finds no account and does nothing.
      }
    }
  }
}
