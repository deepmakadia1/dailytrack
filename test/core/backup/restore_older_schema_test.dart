import 'dart:convert';
import 'dart:io';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_migrator.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// SET-02 AC 3: "Restoring a backup from an older schema version succeeds"
/// (feature 008 T031, FR-006, research R7). Backups written at schema v1,
/// v2, and v3 restore into the current v4 database through each module's
/// JSON upgrade steps; a newer one is refused.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late MutableClock clock;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('restore_old');
    clock = MutableClock(DateTime(2026, 10, 21, 9));
    // The device already has data, which the restore replaces.
    await seedRichData(db, docs);
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  Uint8List doc(int version, Map<String, Object?> modules) => utf8.encode(
    jsonEncode({
      'format': 'dailytrack-backup',
      'schemaVersion': version,
      'appVersion': '0.$version.0',
      'createdAt': 1780000000000,
      'modules': modules,
      'settings': {'currencyCode': '"EUR"'},
    }),
  );

  Map<String, Object?> account(String id) => {
    'id': id,
    'name': 'Cash',
    'type': 'cash',
    'openingBalanceMinor': 100,
    'iconKey': 'payments',
    'colorHex': '#0F766E',
    'isArchived': false,
    'sortOrder': 0,
    'createdAt': 1,
    'updatedAt': 1,
    'deletedAt': null,
  };

  Map<String, Object?> category(String id) => {
    'id': id,
    'name': 'expense_cat_food',
    'type': 'expense',
    'iconKey': 'restaurant',
    'colorHex': '#F97316',
    'isDefault': true,
    'isArchived': false,
    'sortOrder': 0,
    'createdAt': 1,
    'updatedAt': 1,
    'deletedAt': null,
  };

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
          .read<int>('c');

  test('the oldest restorable schema is v1, the first ever shipped', () {
    expect(minRestorableSchema, 1);
    expect(db.schemaVersion, greaterThan(minRestorableSchema));
  });

  test(
    'SET-02 AC3 a v1 backup (accounts and categories only) restores',
    () async {
      final engine = engineFor(db, clock, docs);
      final candidate = await engine.open(
        doc(1, {
          'expense': {
            'tables': {
              'accounts': [account('a-v1')],
              'categories': [category('c-v1')],
            },
          },
        }),
      );
      await engine.apply(candidate);
      expect(await count('accounts'), 1);
      expect(await count('categories'), 1);
      for (final table in [
        'transactions',
        'budgets',
        'recurring_rules',
        'habits',
        'habit_schedules',
        'habit_entries',
      ]) {
        expect(await count(table), 0, reason: table);
      }
      expect((await settingsRows(db))['currencyCode'], '"EUR"');
    },
  );

  test('SET-02 AC3 the committed v2 fixture restores; its pre-v3 rule link '
      'is cleared by the upgrade step', () async {
    final bytes = File('test/fixtures/backup/v2_expense.json')
        .readAsBytesSync();
    final engine = engineFor(db, clock, docs);
    final candidate = await engine.open(bytes);
    expect(candidate.preview.appVersion, '0.2.0+2');
    await engine.apply(candidate);

    final txns = await (db.select(
      db.transactions,
    )..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
    expect([for (final t in txns) t.id], ['txn-1', 'txn-2']);
    expect(txns.first.recurringRuleId, isNull);
    expect(txns.first.note, 'સાંજનો નાસ્તો');
    expect(txns.last.deletedAt, 1789000500000);
    expect(await count('habits'), 0);
    expect((await settingsRows(db))['locale'], '"hi"');
  });

  test('SET-02 AC3 a v3 backup with no habit section restores with empty '
      'habit tables', () async {
    final engine = engineFor(db, clock, docs);
    final candidate = await engine.open(
      doc(3, {
        'expense': {
          'tables': {
            'accounts': [account('a3')],
            'categories': [category('c3')],
            'budgets': [
              {
                'id': 'b-v3',
                'categoryId': 'c3',
                'monthKey': '2026-01',
                'limitMinor': 5000,
                'rollover': false,
                'alert80SentAt': null,
                'alert100SentAt': null,
                'createdAt': 1,
                'updatedAt': 1,
                'deletedAt': null,
              },
            ],
          },
        },
      }),
    );
    await engine.apply(candidate);
    expect(await count('budgets'), 1);
    expect(await count('habits'), 0);
    expect(await count('habit_entries'), 0);
  });

  test('SET-02 US1-5 a backup from a newer schema is refused and changes '
      'nothing', () async {
    final before = await tableChecksums(db);
    final engine = engineFor(db, clock, docs);
    await expectLater(
      engine.open(doc(db.schemaVersion + 1, const {})),
      throwsA(
        isA<BackupTooNew>().having(
          (e) => e.schemaVersion,
          'schemaVersion',
          db.schemaVersion + 1,
        ),
      ),
    );
    expect(await tableChecksums(db), before);
  });
}
