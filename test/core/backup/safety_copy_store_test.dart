import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/data/safety_copy_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 7-day copy of a phone's data taken before a restore from the account
/// replaces it (feature 010 T066, data-model §5, FR-019a, clarification
/// Q3). The restore path and expiry at start are in
/// test/core/account/account_restore_test.dart.
void main() {
  late Directory root;
  late FileSafetyCopyStore store;

  BackupFile file(String name, List<int> bytes) =>
      BackupFile(bytes: Uint8List.fromList(bytes), fileName: name);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('safety');
    store = FileSafetyCopyStore(() async => root);
  });
  tearDown(() => root.delete(recursive: true));

  group('§16 SafetyCopyPolicy', () {
    const createdAt = 1792540800000;
    int after(Duration d) => createdAt + d.inMilliseconds;

    test('kept for 6 days 23 hours, gone at exactly 7 days', () {
      expect(
        SafetyCopyPolicy.expired(
          createdAt: createdAt,
          nowMs: after(const Duration(days: 6, hours: 23)),
        ),
        isFalse,
      );
      expect(
        SafetyCopyPolicy.expired(
          createdAt: createdAt,
          nowMs: after(const Duration(days: 7)),
        ),
        isTrue,
      );
    });

    test('keepFor is 7 days', () {
      expect(SafetyCopyPolicy.keepFor, const Duration(days: 7));
    });
  });

  group('§16 FileSafetyCopyStore', () {
    test(
      'saves the file with its date and counts, and reads it back',
      () async {
        await store.save(
          file('dailytrack_backup_20261027_2130.zip', [1, 2, 3]),
          counts: const {'expense.transactions': 3, 'habit.habits': 1},
          createdAt: 1792540800000,
        );
        final info = await store.info();
        expect(info?.createdAt, 1792540800000);
        expect(info?.fileName, 'dailytrack_backup_20261027_2130.zip');
        expect(info?.counts, {'expense.transactions': 3, 'habit.habits': 1});
        expect(await store.read(), [1, 2, 3]);
      },
    );

    test('a new copy replaces the earlier one (latest copy only)', () async {
      await store.save(file('a.json', [1]), counts: const {}, createdAt: 1);
      await store.save(file('b.json', [2]), counts: const {}, createdAt: 2);
      expect((await store.info())?.fileName, 'b.json');
      expect(await store.read(), [2]);
      final names = Directory('${root.path}/${FileSafetyCopyStore.folder}')
          .listSync()
          .map((e) => e.uri.pathSegments.last)
          .toSet();
      expect(names, {'b.json', FileSafetyCopyStore.sidecar});
    });

    test('delete removes it; reading afterwards gives nothing', () async {
      await store.save(file('a.json', [1]), counts: const {}, createdAt: 1);
      await store.delete();
      expect(await store.info(), isNull);
      expect(await store.read(), isNull);
    });

    test(
      'a copy without its sidecar (an interrupted save) does not count',
      () async {
        await store.save(file('a.json', [1]), counts: const {}, createdAt: 1);
        File(
          '${root.path}/${FileSafetyCopyStore.folder}/'
          '${FileSafetyCopyStore.sidecar}',
        ).deleteSync();
        expect(await store.info(), isNull);
        expect(await store.read(), isNull);
      },
    );

    test('the copy lives in restore_safety/, outside the Android backup '
        'rules (FR-045)', () {
      expect(FileSafetyCopyStore.folder, 'restore_safety');
    });
  });
}
