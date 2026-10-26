import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_engine.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';

/// A backup that was read, decrypted, and checked; nothing is written yet.
final class OpenedBackup {
  const new(this.candidate, {this.password});

  final RestoreCandidate candidate;

  /// The password that opened it; null for a plain backup.
  final String? password;
}

/// How [AccountRestore.apply] ended. Other failures are thrown as
/// `BackupFailure`, with this phone's data unchanged.
sealed class AccountRestoreResult {
  const new();
}

final class Restored extends AccountRestoreResult {
  const new({required this.outcome, required this.preview});

  final RestoreOutcome outcome;
  final RestorePreview preview;
}

/// The safety copy couldn't be saved, so nothing was restored (FR-019a).
final class SafetyCopyFailed extends AccountRestoreResult {
  const new();
}

/// The one place that restores a Drive backup (feature 010 research R12),
/// used by ACC-02, SYS-02, and the SET-02 Drive list: the safety copy
/// first, feature 008's restore, then the account's bookkeeping. Also keeps
/// "Encrypt backup" on after an encrypted restore (FR-019b).
class AccountRestore {
  new({
    required this._drive,
    required this._restore,
    required this._engine,
    required this._backup,
    required this._safety,
    required this._passwords,
    required this._settings,
    required this._clock,
  });

  final DriveBackupStore _drive;
  final RestoreService _restore;
  final BackupEngine _engine;
  final BackupService _backup;
  final SafetyCopyStore _safety;
  final BackupPasswordStore _passwords;
  final SettingsRepository _settings;
  final Clock _clock;

  /// User data beyond the seeded defaults (research R11).
  Future<bool> phoneHasData() => _engine.hasUserData();

  /// This phone's counts for ACC-02 "This phone", keyed like
  /// `BackupMeta.counts`, so presentation never touches the engine.
  Future<Map<String, int>> phoneCounts() => _engine.counts();

  /// Future backups are encrypted with [password] (FR-019b). The password
  /// is stored before encryption turns on (feature 008 research R4).
  Future<void> rememberEncryption(String password) async {
    await _passwords.write(password);
    await _settings.setBackupEncrypt(enabled: true);
  }

  Future<Uint8List> download(DriveBackupEntry entry) =>
      _drive.download(entry.id);

  /// Opens [bytes]. Without [password] the saved backup password is tried;
  /// when it is missing or fails, throws `BackupNeedsPassword` so the
  /// caller asks. A wrong [password] throws `BackupWrongPassword`. Writes
  /// nothing.
  Future<OpenedBackup> open(Uint8List bytes, {String? password}) async {
    if (password != null) {
      return OpenedBackup(
        await _restore.open(bytes, password: password),
        password: password,
      );
    }
    final saved = await _passwords.read();
    try {
      return OpenedBackup(
        await _restore.open(bytes, password: saved),
        password: saved,
      );
    } on BackupWrongPassword {
      throw const BackupNeedsPassword();
    }
  }

  /// Replaces this phone's data with [backup] in one transaction (FR-019).
  /// When the phone has data, the safety copy is saved first; if that
  /// fails, nothing is written. [entry] is the Drive backup it came from
  /// (null for the safety copy): it becomes the last known backup, from the
  /// file's `meta` when it has one (FR-041). [fromEmptyPhone] restores
  /// (SYS-02, ACC-02 without the choice) ask for "Finish setting up" when
  /// app lock is off (research R13).
  Future<AccountRestoreResult> apply(
    OpenedBackup backup, {
    required DriveBackupEntry? entry,
    required bool fromEmptyPhone,
  }) async {
    if (await phoneHasData()) {
      try {
        final copy = await _engine.create(includeReceipts: true);
        await _safety.save(
          copy,
          counts: await _engine.counts(),
          createdAt: _clock.now().toUtc().millisecondsSinceEpoch,
        );
      } on BackupStorageFull {
        return const SafetyCopyFailed();
      }
    }
    final outcome = await _restore.apply(backup.candidate);

    // The restored data is what Drive holds: nothing to back up yet.
    final s = await _settings.load();
    await _settings.setBackedUpChangeCounter(s.dataChangeCounter);
    if (entry != null) {
      final meta = backup.candidate.document.meta ?? entry.meta;
      await _settings.setLastKnownDriveBackup(
        at: meta?.createdAt ?? entry.createdAt,
        deviceId: meta?.deviceId,
      );
    }
    await _settings.setAutoBackupPause(paused: false, notified: false);
    final password = backup.password;
    if (backup.candidate.preview.encrypted && password != null) {
      await rememberEncryption(password);
    }
    if (fromEmptyPhone && !s.lockEnabled) {
      await _settings.setFinishSetupPending(pending: true);
    }
    return Restored(outcome: outcome, preview: backup.candidate.preview);
  }

  /// ACC-02 "Keep this phone's data" (FR-020): nothing is written locally;
  /// the declined backup becomes known, so it never warns again, and a
  /// backup of this phone starts and becomes the newest. Ends a pause.
  Future<void> keepThisPhone(DriveBackupEntry newest) async {
    await _settings.setLastKnownDriveBackup(
      at: newest.meta?.createdAt ?? newest.createdAt,
      deviceId: newest.meta?.deviceId,
    );
    await _settings.setAutoBackupPause(paused: false, notified: false);
    unawaited(
      _backup
          .backupToDrive(
            kind: BackupKind.manual,
            conflict: ConflictMode.overwrite,
          )
          .then((_) {}, onError: (Object _) {}),
    );
  }

  /// SET-02 "Restore previous phone data": the safety copy, if it hasn't
  /// expired.
  Future<SafetyCopyInfo?> safetyCopy() async {
    final copy = await _safety.info();
    if (copy == null) return null;
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    if (SafetyCopyPolicy.expired(createdAt: copy.createdAt, nowMs: now)) {
      await _safety.delete();
      return null;
    }
    return copy;
  }

  Future<Uint8List?> readSafetyCopy() => _safety.read();

  Future<void> deleteSafetyCopy() => _safety.delete();
}
