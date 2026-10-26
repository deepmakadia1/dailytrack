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

  /// The account in [s], as this run sees it.
  AccountState stateOf(AppSettings s) {
    final email = s.backupAccountEmail;
    if (email == null) return SignedOut(expired: _expired);
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

  /// SYS-01, after routing: a silent sign-in for the stored account. On
  /// failure the email is kept and the account shows as signed out until
  /// the user signs in again or out (FR-004). Never throws.
  Future<void> restoreSession() async {
    try {
      if ((await _settings.load()).backupAccountEmail == null) return;
      final profile = await _auth.signInSilently();
      if (profile == null) {
        _setSilentFailed(failed: true);
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
  /// (spec §16 "First start after an Android Auto Backup restore"). Never
  /// throws.
  Future<void> adoptSilentSession() async {
    try {
      final profile = await _auth.signInSilently();
      if (profile == null) return;
      await _settings.setAccount(profile);
      _setSilentFailed(failed: false);
      await syncAutoBackupSchedule(await _settings.load(), _scheduler);
    } on Object {
      // Stays signed out; the user can sign in from ACC-01.
    }
  }

  /// The account chooser and Drive consent. Saves the account and turns
  /// Auto backup from Off to Daily (FR-006). Null when the user cancels;
  /// other failures are thrown as `BackupFailure`.
  Future<AccountProfile?> signIn() async {
    final AccountProfile profile;
    try {
      profile = await _auth.signIn();
    } on DriveAuthRequired {
      return null;
    }
    await _settings.setAccount(profile);
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
    return profile;
  }

  /// Signs out and keeps this phone's data and the Drive backups (FR-024).
  Future<void> signOut() async {
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
  Future<void> forgetAfterAuthLoss() async {
    _expired = true;
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

  Future<void> _forget() async {
    await _settings.setAccount(null);
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
