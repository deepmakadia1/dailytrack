import 'dart:io';

import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/expense/data/backup/expense_backup_section.dart';
import 'package:dailytrack/features/habit/data/backup/habit_backup_section.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// Wraps the real Habit section and fails where told (restore only).
final class _FailingHabitSection extends BackupSection {
  const new({this.throwAfterRestore = false, this.danglingEntry = false});

  final bool throwAfterRestore;
  final bool danglingEntry;
  static const HabitBackupSection _real = HabitBackupSection();

  @override
  String get moduleId => _real.moduleId;
  @override
  int get sinceSchemaVersion => _real.sinceSchemaVersion;
  @override
  Set<String> get tables => _real.tables;
  @override
  Future<bool> hasUserData(AppDatabase db) => _real.hasUserData(db);
  @override
  Future<Map<String, Object?>> export(AppDatabase db) => _real.export(db);
  @override
  void validate(Map<String, Object?> section) => _real.validate(section);
  @override
  Map<String, int> counts(Map<String, Object?> s) => _real.counts(s);
  @override
  String summary(AppLocalizations l10n, Map<String, int> c) =>
      _real.summary(l10n, c);

  @override
  Future<void> restore(AppDatabase db, Map<String, Object?> section) async {
    await _real.restore(db, section);
    if (danglingEntry) {
      // Slips past validation, so only the database's own check sees it.
      await db
          .into(db.habitEntries)
          .insert(
            HabitEntriesCompanion.insert(
              id: 'dangling',
              habitId: 'no-such-habit',
              dateKey: '2026-10-21',
              value: 1,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
    if (throwAfterRestore) throw StateError('disk went away mid-restore');
  }
}

/// SET-02 AC 2: "A failed restore leaves existing data untouched" (feature
/// 008 T030, FR-008, research R8). Every failure point, before and inside
/// the database transaction, leaves every table, the settings, and the
/// receipt files exactly as they were.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late MutableClock clock;
  late Uint8List backupBytes;
  late Map<String, (int, String)> before;
  late Map<String, String> settingsBefore;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('restore_fail');
    clock = MutableClock(DateTime(2026, 10, 21, 9));
    await seedRichData(db, docs);
    // A valid backup whose content differs from what the device now holds.
    backupBytes = (await engineFor(
      db,
      clock,
      docs,
    ).create(includeReceipts: true)).bytes;
    await (db.delete(db.habitEntries)..where((e) => e.id.equals('e1'))).go();
    await db.customStatement(
      "UPDATE transactions SET note = 'changed on device' WHERE id = 't2'",
    );
    await db.customStatement(
      "UPDATE settings SET value = '\"hi\"' WHERE key = 'locale'",
    );
    File('${docs.path}/receipts/r1.jpg').writeAsBytesSync([1, 2, 3]);
    before = await tableChecksums(db);
    settingsBefore = await settingsRows(db);
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  Future<void> expectUntouched() async {
    expect(await tableChecksums(db), before);
    expect(await settingsRows(db), settingsBefore);
    expect(File('${docs.path}/receipts/r1.jpg').readAsBytesSync(), [1, 2, 3]);
    expect(Directory('${docs.path}/receipts.restore').existsSync(), isFalse);
  }

  test('SET-02 AC2 a section throws mid-transaction after other modules were '
      'written: everything rolls back', () async {
    final engine = engineFor(
      db,
      clock,
      docs,
      sections: [
        const ExpenseBackupSection(),
        const _FailingHabitSection(throwAfterRestore: true),
      ],
    );
    final candidate = await engine.open(backupBytes);
    await expectLater(engine.apply(candidate), throwsA(isA<StateError>()));
    await expectUntouched();
  });

  test('SET-02 AC2 a broken reference found by the foreign key check rolls '
      'everything back', () async {
    final engine = engineFor(
      db,
      clock,
      docs,
      sections: [
        const ExpenseBackupSection(),
        const _FailingHabitSection(danglingEntry: true),
      ],
    );
    final candidate = await engine.open(backupBytes);
    await expectLater(engine.apply(candidate), throwsA(isA<BackupInvalid>()));
    await expectUntouched();
  });

  test(
    'SET-02 AC2 staging receipts fails (no space): nothing is written',
    () async {
      // A file where the staging folder must go makes creating it fail.
      File('${docs.path}/receipts.restore').writeAsStringSync('blocker');
      final engine = engineFor(db, clock, docs);
      final candidate = await engine.open(backupBytes);
      await expectLater(
        engine.apply(candidate),
        throwsA(isA<BackupStorageFull>()),
      );
      File('${docs.path}/receipts.restore').deleteSync();
      await expectUntouched();
    },
  );

  test('SET-02 AC2 a backup that fails validation changes nothing', () async {
    final engine = engineFor(db, clock, docs);
    // A zip cannot be edited as text, so use a plain backup for this case.
    // Byte-wise strings keep the UTF-8 notes intact when turned back.
    final plain = await engine.create(includeReceipts: false);
    final broken = String.fromCharCodes(plain.bytes)
        .replaceFirst('"weekdaysMask":21', '"weekdaysMask":128');
    expect(broken, isNot(String.fromCharCodes(plain.bytes)));
    await expectLater(
      engine.open(Uint8List.fromList(broken.codeUnits)),
      throwsA(isA<BackupInvalid>()),
    );
    await expectUntouched();
  });

  test('SET-02 AC2 a wrong password changes nothing', () async {
    final engine = engineFor(db, clock, docs);
    final encrypted = await engine.create(
      includeReceipts: false,
      password: 'right',
    );
    await expectLater(
      engine.open(encrypted.bytes, password: 'wrong'),
      throwsA(isA<BackupWrongPassword>()),
    );
    await expectUntouched();
  });

  test('SET-02 US1-7 a failed receipt swap after commit restores the data '
      'and reports missing receipts', () async {
    // A file named like the swap's temporary folder makes the swap fail.
    File('${docs.path}/receipts.old').writeAsStringSync('blocker');
    final engine = engineFor(db, clock, docs);
    final candidate = await engine.open(backupBytes);
    expect(
      await engine.apply(candidate),
      RestoreOutcome.doneWithMissingReceipts,
    );
    // The database now equals the backup (e1 is back, t2's note restored).
    final e1 = await (db.select(
      db.habitEntries,
    )..where((e) => e.id.equals('e1'))).getSingleOrNull();
    expect(e1, isNotNull);
  });
}
