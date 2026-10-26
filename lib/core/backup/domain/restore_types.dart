import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';

/// A finished backup file, ready to save or share.
final class BackupFile {
  const new({
    required this.bytes,
    required this.fileName,
    this.meta,
    this.changeCounter = 0,
  });

  final Uint8List bytes;

  /// `dailytrack_backup_<yyyyMMdd_HHmm>.<json|zip|dtbk>` (FR-001).
  final String fileName;

  /// The file's `meta`; null when made without a device identity.
  final BackupMeta? meta;

  /// `dataChangeCounter` read inside the backup's own snapshot (feature
  /// 010 research R5).
  final int changeCounter;
}

/// A backup that has been read, checked, and upgraded, but not written
/// (research R8 phases 1–3). Nothing has changed yet.
final class RestoreCandidate {
  const new({
    required this.preview,
    required this.document,
    required this.attachments,
  });

  final RestorePreview preview;

  /// At the current schema, one section per known module.
  final BackupDocument document;

  /// Relative path → bytes, e.g. `receipts/<uuid>.jpg`.
  final Map<String, Uint8List> attachments;
}

/// How a restore ended once the database was written.
enum RestoreOutcome {
  done,

  /// The data was restored, but receipt images could not be moved into
  /// place; affected transactions show no receipt (research R8 phase 6).
  doneWithMissingReceipts,
}
