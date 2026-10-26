import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/restore_types.dart';

/// The safety copy kept before a restore replaces this phone's data
/// (feature 010 FR-019a, clarification Q3, data-model §5). Never encrypted,
/// never uploaded, kept for [SafetyCopyPolicy.keepFor].
final class SafetyCopyInfo {
  const new({
    required this.createdAt,
    required this.counts,
    required this.fileName,
  });

  /// UTC epoch milliseconds.
  final int createdAt;

  /// `"<moduleId>.<kind>"` → rows, as in `BackupMeta.counts`.
  final Map<String, int> counts;
  final String fileName;
}

/// One safety copy at most; a new one replaces it.
abstract interface class SafetyCopyStore {
  /// Throws `BackupStorageFull` when it can't be written; then no copy
  /// exists and the restore must not start.
  Future<void> save(
    BackupFile file, {
    required Map<String, int> counts,
    required int createdAt,
  });

  /// Null when there is no readable copy.
  Future<SafetyCopyInfo?> info();

  /// The copy's bytes, or null when there is none.
  Future<Uint8List?> read();

  Future<void> delete();
}

/// How long the safety copy is kept. Pure.
abstract final class SafetyCopyPolicy {
  static const Duration keepFor = Duration(days: 7);

  static bool expired({required int createdAt, required int nowMs}) =>
      nowMs - createdAt >= keepFor.inMilliseconds;
}
