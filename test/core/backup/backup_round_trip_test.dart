import 'dart:convert';
import 'dart:io';

import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// SET-02 AC 1, unit level: backup → erase → restore gives identical data,
/// for the plain, zip, and encrypted forms (feature 008 T029, research R2,
/// R3, R8). The device run is `integration_test/backup_restore_test.dart`.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late MutableClock clock;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('backup_docs');
    clock = MutableClock(DateTime(2026, 10, 21, 21, 30));
    await seedRichData(db, docs);
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  Future<void> roundTrip({
    required bool includeReceipts,
    required String extension,
    String? password,
  }) async {
    final engine = engineFor(db, clock, docs);
    final before = await tableChecksums(db);
    final settingsBefore = await settingsRows(db);

    final file = await engine.create(
      includeReceipts: includeReceipts,
      password: password,
    );
    expect(file.fileName, 'dailytrack_backup_20261021_2130.$extension');

    await eraseEverything(db);
    Directory('${docs.path}/receipts').deleteSync(recursive: true);
    expect((await tableChecksums(db)).values.every((v) => v.$1 == 0), isTrue);

    final candidate = await engine.open(file.bytes, password: password);
    expect(await engine.apply(candidate), RestoreOutcome.done);

    final after = await tableChecksums(db);
    if (includeReceipts) {
      expect(after, before);
      expect(
        File('${docs.path}/receipts/r1.jpg').readAsBytesSync(),
        receiptBytes,
      );
    } else {
      // Without receipts the only difference is t1's receipt path.
      final t1 = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals('t1'))).getSingle();
      expect(t1.receiptPath, isNull);
      for (final table in moduleTables.where((t) => t != 'transactions')) {
        expect(after[table], before[table], reason: table);
      }
      expect(after['transactions']!.$1, before['transactions']!.$1);
    }

    final settingsAfter = await settingsRows(db);
    for (final key in [
      'locale',
      'currencyCode',
      'themeMode',
      'dateFormat',
      'enabledModules',
      'moduleOrder',
      'dailySummaryTime',
      'module.expense.budgetRolloverMonth',
    ]) {
      expect(settingsAfter[key], settingsBefore[key], reason: key);
    }
    // Device state is never restored; erase removed it.
    expect(settingsAfter.containsKey('lockEnabled'), isFalse);
    expect(settingsAfter.containsKey('adConsentStatus'), isFalse);
    expect(await db.select(db.unlocks).get(), isEmpty);
    // Onboarding done and every seeder marked, so seeds never re-run.
    expect(settingsAfter['onboardingDone'], 'true');
    for (final id in realSeederIds()) {
      expect(settingsAfter.containsKey('seed.$id'), isTrue, reason: id);
    }
  }

  test(
    'SET-02 US1 plain JSON round trip keeps every table identical',
    () async {
      await roundTrip(includeReceipts: true, extension: 'zip');
    },
  );

  test(
    'SET-02 US1-2 without receipt images: a .json file, no receipt paths',
    () async {
      await roundTrip(includeReceipts: false, extension: 'json');
    },
  );

  test('SET-02 US4 encrypted round trip (.dtbk) with receipts', () async {
    await roundTrip(
      includeReceipts: true,
      password: 'correct horse',
      extension: 'dtbk',
    );
  });

  test(
    'SET-02 US1 the backup has the documented header and enum names',
    () async {
      final file = await engineFor(
        db,
        clock,
        docs,
      ).create(includeReceipts: false);
      expect(detectForm(file.bytes), ContainerForm.plain);
      final json = jsonDecode(utf8.decode(file.bytes)) as Map<String, Object?>;
      expect(json['format'], BackupDocument.format);
      expect(json['schemaVersion'], db.schemaVersion);
      expect(json['appVersion'], '1.0.0+7');
      expect(json['createdAt'], clock.now().toUtc().millisecondsSinceEpoch);
      final expense = (json['modules']! as Map)['expense'] as Map;
      final txns = (expense['tables'] as Map)['transactions'] as List;
      expect(txns.map((t) => (t as Map)['type']).toSet(), {
        'expense',
        'income',
        'transfer',
      });
      final settings = json['settings']! as Map;
      expect(settings.containsKey('lockEnabled'), isFalse);
      expect(settings.containsKey('adConsentStatus'), isFalse);
      expect(settings['locale'], '"gu"');
    },
  );

  test(
    'SET-02 US1 a missing receipt file is skipped; the backup succeeds',
    () async {
      File('${docs.path}/receipts/r1.jpg').deleteSync();
      final file = await engineFor(
        db,
        clock,
        docs,
      ).create(includeReceipts: true);
      // No files to pack, so it is plain JSON; the row keeps its path.
      expect(detectForm(file.bytes), ContainerForm.plain);
      final candidate = await engineFor(db, clock, docs).open(file.bytes);
      expect(candidate.preview.receiptCount, 0);
    },
  );

  test('SET-02 US1-3 the summary counts live rows per module', () async {
    final engine = engineFor(db, clock, docs);
    final file = await engine.create(includeReceipts: true);
    final preview = (await engine.open(file.bytes)).preview;
    final expense = preview.modules.firstWhere((m) => m.moduleId == 'expense');
    final habit = preview.modules.firstWhere((m) => m.moduleId == 'habit');
    expect(expense.counts['transactions'], 3);
    expect(habit.counts['habits'], 2);
    expect(preview.receiptCount, 1);
    expect(preview.encrypted, isFalse);
    expect(preview.appVersion, '1.0.0+7');
  });

  test('SET-02 US4-3 an encrypted file needs its password', () async {
    final engine = engineFor(db, clock, docs);
    final file = await engine.create(includeReceipts: false, password: 'pw');
    await expectLater(
      engine.open(file.bytes),
      throwsA(isA<BackupNeedsPassword>()),
    );
    await expectLater(
      engine.open(file.bytes, password: 'nope'),
      throwsA(isA<BackupWrongPassword>()),
    );
    final ok = await engine.open(file.bytes, password: 'pw');
    expect(ok.preview.encrypted, isTrue);
  });

  test('SET-02 US1-5 a file that is not a backup is rejected', () async {
    final engine = engineFor(db, clock, docs);
    await expectLater(
      engine.open(utf8.encode('hello, not a backup')),
      throwsA(isA<BackupNotRecognized>()),
    );
    await expectLater(
      engine.open(utf8.encode('{"format":"other"}')),
      throwsA(isA<BackupInvalid>()),
    );
    await expectLater(
      engine.open(utf8.encode('{"format":')),
      throwsA(isA<BackupDamaged>()),
    );
  });
}
