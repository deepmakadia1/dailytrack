import 'dart:io';

import 'package:dailytrack/features/expense/data/receipts/file_receipt_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';

/// Receipt files: relative paths, and pruning that never removes a file a
/// row (even a soft-deleted one) refers to (research R8).
void main() {
  late Directory root;
  late MutableClock clock;
  late FileReceiptStore store;

  setUp(() {
    root = Directory.systemTemp.createTempSync('receipts_test');
    addTearDown(() => root.deleteSync(recursive: true));
    clock = MutableClock(DateTime(2026, 10, 14, 12));
    store = FileReceiptStore(() async => root, clock);
  });

  File write(String name, {required Duration age}) {
    final f = File('${root.path}/receipts/$name')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3])
      ..setLastModifiedSync(clock.now().subtract(age));
    return f;
  }

  test('resolve returns the absolute path, or null when missing', () async {
    final f = write('a.jpg', age: Duration.zero);
    expect(await store.resolve('receipts/a.jpg'), f.path);
    expect(await store.resolve('receipts/missing.jpg'), isNull);
  });

  test('newPath is a unique relative JPEG path under receipts/', () async {
    final a = store.newRelativePath();
    final b = store.newRelativePath();
    expect(a, matches(RegExp(r'^receipts/[0-9a-f-]{36}\.jpg$')));
    expect(a, isNot(b));
    expect(await store.absolute(a), '${root.path}/$a');
  });

  test('prune deletes only unreferenced files older than 24 hours', () async {
    write('kept_referenced_old.jpg', age: const Duration(days: 3));
    write('kept_recent_orphan.jpg', age: const Duration(hours: 23));
    final old = write('old_orphan.jpg', age: const Duration(hours: 25));

    final deleted = await store.pruneOrphans({
      'receipts/kept_referenced_old.jpg',
    });

    expect(deleted, 1);
    expect(old.existsSync(), isFalse);
    expect(
      Directory('${root.path}/receipts')
          .listSync()
          .map((e) => e.uri.pathSegments.last)
          .toSet(),
      {'kept_referenced_old.jpg', 'kept_recent_orphan.jpg'},
    );
  });

  test('prune is a no-op when no receipt was ever saved', () async {
    expect(await store.pruneOrphans({}), 0);
  });

  test('erase all data: deleteAll removes every receipt, new or old, and '
      'leaves other files (feature 007 T020)', () async {
    write('new.jpg', age: Duration.zero);
    write('old.jpg', age: const Duration(days: 9));
    final other = File('${root.path}/app.db')..writeAsBytesSync([1]);
    await store.deleteAll();
    expect(Directory('${root.path}/receipts').existsSync(), isFalse);
    expect(other.existsSync(), isTrue);
    // Nothing left to delete is fine.
    await store.deleteAll();
  });
}
