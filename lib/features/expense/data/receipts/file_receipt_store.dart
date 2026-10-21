import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_store.dart';
import 'package:uuid/uuid.dart';

/// Receipts under `<root>/receipts/`, referenced by RELATIVE path so a
/// restored backup resolves against the new install's directory (research
/// R8). The root is the app documents directory in production.
final class FileReceiptStore implements ReceiptStore {
  new(this._root, this._clock);

  static const String folder = 'receipts';

  /// Files younger than this are never pruned: a form may still be open.
  static const Duration graceAge = Duration(hours: 24);

  final Future<Directory> Function() _root;
  final Clock _clock;

  /// A fresh `receipts/<uuid>.jpg` path for a new receipt.
  String newRelativePath() => '$folder/${const Uuid().v4()}.jpg';

  Future<String> absolute(String relativePath) async =>
      '${(await _root()).path}/$relativePath';

  @override
  Future<String?> resolve(String relativePath) async {
    final path = await absolute(relativePath);
    return File(path).existsSync() ? path : null;
  }

  @override
  Future<int> pruneOrphans(Set<String> referencedRelativePaths) async {
    final dir = Directory('${(await _root()).path}/$folder');
    if (!dir.existsSync()) return 0;
    final cutoff = _clock.now().subtract(graceAge);
    var deleted = 0;
    for (final file in dir.listSync().whereType<File>()) {
      final relative = '$folder/${file.uri.pathSegments.last}';
      if (referencedRelativePaths.contains(relative)) continue;
      if (file.lastModifiedSync().isAfter(cutoff)) continue;
      file.deleteSync();
      deleted++;
    }
    return deleted;
  }

  @override
  Future<void> deleteAll() async {
    final dir = Directory('${(await _root()).path}/$folder');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
