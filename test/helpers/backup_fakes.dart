import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';

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

  @override
  Future<SavedBackup> backupToDrive({required BackupKind kind}) async {
    driveBackups++;
    if (error case final e?) throw e;
    return const SavedBackup(
      fileName: 'dailytrack_backup_20261021_2130.json',
      sizeBytes: 2048,
    );
  }
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
