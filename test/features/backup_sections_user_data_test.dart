import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/habit/habit_module.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// "No data on this phone" (feature 010 T011, research R11, ACC-02 criterion
/// "Seeded categories and the Cash account alone count as no data.").
/// Real Drift.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late List<BackupSection> sections;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
    sections = [
      const ExpenseModule().backupSection()!,
      const HabitModule().backupSection()!,
    ];
  });
  tearDown(() => db.close());

  Future<bool> hasUserData() async {
    for (final s in sections) {
      if (await s.hasUserData(db)) return true;
    }
    return false;
  }

  Future<String> firstId(String table) async =>
      (await db
              .customSelect('SELECT id FROM $table ORDER BY sort_order LIMIT 1')
              .getSingle())
          .read<String>('id');

  Future<void> softDelete(String table, String id) =>
      db.customStatement('UPDATE $table SET deleted_at = 1 WHERE id = ?', [id]);

  test('ACC-02 seeded categories and the Cash account alone count as no '
      'data', () async {
    expect(
      await db.customSelect('SELECT id FROM categories').get(),
      isNotEmpty,
    );
    expect(await hasUserData(), isFalse);
  });

  test(
    'ACC-02 editing a seeded row (renaming Cash) still counts as no data',
    () async {
      await db.customStatement(
        "UPDATE accounts SET name = 'Wallet' WHERE id = ?",
        [await firstId('accounts')],
      );
      expect(await hasUserData(), isFalse);
    },
  );

  test(
    'ACC-02 one transaction is user data; soft-deleted, it is not',
    () async {
      await db.customStatement(
        'INSERT INTO transactions (id, type, amount_minor, account_id, '
        'category_id, payment_mode, occurred_at, created_at, updated_at) '
        'VALUES (?, 0, 1050, ?, ?, 0, 0, 0, 0)',
        ['t1', await firstId('accounts'), await firstId('categories')],
      );
      expect(await hasUserData(), isTrue);
      await softDelete('transactions', 't1');
      expect(await hasUserData(), isFalse);
    },
  );

  test('ACC-02 a category the user made is user data', () async {
    await db.customStatement(
      'INSERT INTO categories (id, name, type, icon_key, color_hex, '
      'is_default, is_archived, sort_order, created_at, updated_at) '
      "VALUES ('c1', 'Chai', 0, 'food', '#0F766E', 0, 0, 99, 0, 0)",
    );
    expect(await hasUserData(), isTrue);
    await softDelete('categories', 'c1');
    expect(await hasUserData(), isFalse);
  });

  test('ACC-02 a second account is user data', () async {
    await db.customStatement(
      'INSERT INTO accounts (id, name, type, opening_balance_minor, icon_key, '
      'color_hex, is_archived, sort_order, created_at, updated_at) '
      "VALUES ('a2', 'SBI', 1, 0, 'bank', '#0F766E', 0, 1, 0, 0)",
    );
    expect(await hasUserData(), isTrue);
    await softDelete('accounts', 'a2');
    expect(await hasUserData(), isFalse);
  });

  test('ACC-02 one habit is user data', () async {
    await db.customStatement(
      'INSERT INTO habits (id, name, icon_key, color_hex, kind, target_value, '
      'schedule_type, weekdays_mask, start_date_key, sort_order, created_at, '
      'updated_at) '
      "VALUES ('h1', 'Walk', 'walk', '#00897B', 0, 1, 0, 127, '2026-10-26', 0, "
      '0, 0)',
    );
    expect(await hasUserData(), isTrue);
    await softDelete('habits', 'h1');
    expect(await hasUserData(), isFalse);
  });
}
