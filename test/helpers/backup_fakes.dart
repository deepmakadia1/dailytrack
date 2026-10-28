import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/account_auth.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// SET-02 backup actions without a database (feature 008).
final class FakeBackupService implements BackupService {
  BackupFailure? error;
  bool cancel = false;
  int saves = 0;
  int shares = 0;

  @override
  Future<SavedBackup?> backupToDevice() async {
    saves++;
    if (error case final e?) throw e;
    if (cancel) return null;
    return const SavedBackup(
      fileName: 'dailytrack_backup_20261021_2130.json',
      sizeBytes: 2048,
    );
  }

  @override
  Future<void> shareLastFile() async => shares++;

  int driveBackups = 0;

  /// The conflict mode of each Drive backup request (feature 010).
  final conflicts = <ConflictMode>[];

  /// Answers a [ConflictMode.ask] request instead of uploading; then the
  /// next request (with [ConflictMode.overwrite]) uploads.
  ConflictCheck? conflict;

  static const BackupMeta meta = BackupMeta(
    deviceId: 'this-phone',
    deviceName: 'Google Pixel 7',
    appVersion: '1.0.0+7',
    createdAt: 1792540800000,
    kind: BackupKind.manual,
    counts: {},
    schemaVersion: 5,
    encrypted: false,
  );

  /// Holds every Drive backup until completed, to see "backing up".
  Completer<void>? gate;

  @override
  Future<DriveBackupResult> backupToDrive({
    required BackupKind kind,
    required ConflictMode conflict,
  }) async {
    conflicts.add(conflict);
    await gate?.future;
    if (error case final e?) throw e;
    final pending = this.conflict;
    if (conflict == ConflictMode.ask && pending != null) {
      return NeedsConfirmation(pending);
    }
    driveBackups++;
    return const Uploaded(meta: meta, sizeBytes: 2048);
  }

  int changedChecks = 0;

  @override
  Future<DriveBackupResult> backupIfChanged() async {
    changedChecks++;
    return await backupToDrive(
      kind: BackupKind.auto,
      conflict: ConflictMode.pause,
    );
  }
}

/// Google sign-in without the plugin (feature 010): [signInResult] is the
/// profile a sign-in returns, or a `BackupFailure` to throw
/// (`DriveAuthRequired` = cancelled).
final class FakeAccountAuth implements AccountAuth {
  Object signInResult = const AccountProfile(
    email: 'me@example.com',
    displayName: 'Asha Patel',
  );

  /// What a silent sign-in returns, or a failure to throw.
  Object? silentResult = const AccountProfile(email: 'me@example.com');
  int signIns = 0;
  int silentSignIns = 0;
  int signOuts = 0;

  /// Every call by name, to check that nothing reached Google (feature 011
  /// research R13).
  final calls = <String>[];

  /// Holds the next sign-ins until completed, to see "Signing in".
  Completer<void>? signInGate;

  @override
  Future<AccountProfile> signIn() async {
    signIns++;
    calls.add('signIn');
    await signInGate?.future;
    final result = signInResult;
    if (result is BackupFailure) throw result;
    return result as AccountProfile;
  }

  @override
  Future<AccountProfile?> signInSilently() async {
    silentSignIns++;
    calls.add('signInSilently');
    final result = silentResult;
    if (result is BackupFailure) throw result;
    return result as AccountProfile?;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    calls.add('signOut');
  }
}

/// Neither Google sign-in nor Drive was called (feature 011 FR-032).
void expectNoGoogleCalls(FakeAccountAuth auth, FakeDriveBackupStore drive) {
  expect(auth.calls, isEmpty, reason: 'no Google sign-in call');
  expect(drive.calls, isEmpty, reason: 'no Drive call');
}

/// SET-02 restore steps without a database: [onOpen] answers by the
/// password given (null = none).
final class FakeRestoreService implements RestoreService {
  Uint8List? picked = Uint8List.fromList(utf8.encode('{}'));

  /// Answers [open] by the password given (null = none).
  Object Function(String? password) onOpen = (_) => candidate();
  BackupFailure? applyError;
  final passwords = <String?>[];
  int applies = 0;

  static RestoreCandidate candidate() => const RestoreCandidate(
    preview: RestorePreview(
      createdAt: 1792540800000,
      appVersion: '1.0.0+7',
      modules: [
        ModuleSummary(moduleId: 'expense', counts: {'transactions': 1240}),
        ModuleSummary(moduleId: 'habit', counts: {'habits': 8}),
      ],
      skippedModuleIds: [],
      receiptCount: 3,
      encrypted: false,
    ),
    document: BackupDocument(
      schemaVersion: 4,
      appVersion: '1.0.0+7',
      createdAt: 0,
      modules: {},
      settings: {},
    ),
    attachments: {},
  );

  @override
  Future<Uint8List?> pickFile() async => picked;

  @override
  Future<RestoreCandidate> open(Uint8List bytes, {String? password}) async {
    passwords.add(password);
    final result = onOpen(password);
    if (result is RestoreCandidate) return result;
    throw result as BackupFailure;
  }

  @override
  Future<RestoreOutcome> apply(RestoreCandidate candidate) async {
    applies++;
    if (applyError case final e?) throw e;
    return RestoreOutcome.done;
  }
}

/// Returns [outcome] and records requests instead of writing files
/// (SET-03, feature 008).
final class FakeExportUseCase implements ExportUseCase {
  ExportOutcome outcome = const ExportReady(
    path: '/cache/exports/dailytrack_transactions_2026-10.csv',
    mimeType: 'text/csv',
  );
  final requests = <ExportRequest>[];

  @override
  Future<ExportOutcome> run(
    ExportDataset dataset,
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  ) async {
    requests.add(request);
    return outcome;
  }
}

/// The account restore without a database (feature 010): a backup
/// encrypted with [encryptedWith] opens with the saved [savedPassword] or a
/// typed one. [onApply] lets a test write what the backup holds; the
/// bookkeeping a real restore does to settings is mirrored on [settings].
final class FakeAccountRestore implements AccountRestore {
  new({this.settings});

  final FakeSettingsRepository? settings;

  bool hasData = false;
  Map<String, int> counts = const {'expense.transactions': 3};

  /// The backup's password, or null for a plain backup.
  String? encryptedWith;

  /// The saved backup password.
  String? savedPassword;

  /// Thrown by the next download.
  BackupFailure? failDownload;

  /// Holds every download until completed, to see "Restoring…".
  Completer<void>? downloadGate;

  /// Thrown by the next apply (nothing written).
  BackupFailure? failApply;

  /// The next apply can't save the safety copy.
  bool safetyFails = false;

  void Function()? onApply;

  final downloads = <String>[];
  final applied = <(String?, bool)>[];
  final kept = <String>[];
  String? remembered;

  SafetyCopyInfo? copy;
  Uint8List copyBytes = Uint8List.fromList(utf8.encode('{}'));
  int copyDeletes = 0;

  static RestoreCandidate candidate({bool encrypted = false}) =>
      RestoreCandidate(
        preview: RestorePreview(
          createdAt: 1792540800000,
          appVersion: '1.0.0+7',
          modules: const [
            ModuleSummary(moduleId: 'expense', counts: {'transactions': 1240}),
            ModuleSummary(moduleId: 'habit', counts: {'habits': 8}),
          ],
          skippedModuleIds: const [],
          receiptCount: 0,
          encrypted: encrypted,
        ),
        document: const BackupDocument(
          schemaVersion: 5,
          appVersion: '1.0.0+7',
          createdAt: 1792540800000,
          modules: {},
          settings: {},
        ),
        attachments: const {},
      );

  @override
  Future<bool> phoneHasData() async => hasData;

  @override
  Future<Map<String, int>> phoneCounts() async => counts;

  @override
  Future<void> rememberEncryption(String password) async {
    remembered = password;
    await settings?.setBackupEncrypt(enabled: true);
  }

  @override
  Future<Uint8List> download(DriveBackupEntry entry) async {
    downloads.add(entry.id);
    await downloadGate?.future;
    if (failDownload case final e?) {
      failDownload = null;
      throw e;
    }
    return Uint8List.fromList(utf8.encode('{}'));
  }

  @override
  Future<OpenedBackup> open(Uint8List bytes, {String? password}) async {
    final key = encryptedWith;
    if (key == null) return OpenedBackup(candidate());
    if (password == null) {
      if (savedPassword == key) {
        return OpenedBackup(candidate(encrypted: true), password: key);
      }
      throw const BackupNeedsPassword();
    }
    if (password != key) throw const BackupWrongPassword();
    return OpenedBackup(candidate(encrypted: true), password: password);
  }

  @override
  Future<AccountRestoreResult> apply(
    OpenedBackup backup, {
    required DriveBackupEntry? entry,
    required bool fromEmptyPhone,
  }) async {
    if (hasData && safetyFails) return const SafetyCopyFailed();
    if (failApply case final e?) {
      failApply = null;
      throw e;
    }
    applied.add((entry?.id, fromEmptyPhone));
    onApply?.call();
    final s = settings;
    if (s != null) {
      final password = backup.password;
      if (backup.candidate.preview.encrypted && password != null) {
        await rememberEncryption(password);
      }
      if (fromEmptyPhone && !s.current.lockEnabled) {
        await s.setFinishSetupPending(pending: true);
      }
      await s.setAutoBackupPause(paused: false, notified: false);
    }
    return Restored(
      outcome: RestoreOutcome.done,
      preview: backup.candidate.preview,
    );
  }

  @override
  Future<void> keepThisPhone(DriveBackupEntry newest) async {
    kept.add(newest.id);
    await settings?.setLastKnownDriveBackup(
      at: newest.meta?.createdAt ?? newest.createdAt,
      deviceId: newest.meta?.deviceId,
    );
  }

  @override
  Future<SafetyCopyInfo?> safetyCopy() async => copy;

  @override
  Future<Uint8List?> readSafetyCopy() async => copy == null ? null : copyBytes;

  @override
  Future<void> deleteSafetyCopy() async {
    copyDeletes++;
    copy = null;
  }
}
