import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

/// Migration harness (FR-012, Constitution III). Regenerate the helpers after
/// every schema change with:
///   dart run drift_dev make-migrations
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('a fresh database matches the committed v5 schema', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final schema = await verifier.schemaAt(5);
    await verifier.migrateAndValidate(AppDatabase(schema.newConnection()), 5);
    // Opening the app database itself must also work at v5.
    expect(db.schemaVersion, 5);
    await db.customSelect('SELECT 1').get();
  });

  test('every committed schema version is known to the helper', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(GeneratedHelper.versions, containsAll([1, 2, 3, 4, 5]));
    expect(GeneratedHelper.versions, contains(db.schemaVersion));
  });

  test('upgrade from v1 to v2', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  // US3 / SC-006: the upgrade keeps every v1 row byte-identical, creates an
  // empty transactions table, and never re-runs the first-launch seed.
  test('upgrade from v1 to v2 preserves data and does not re-seed', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    _insertV1Data(raw.execute);
    List<Map<String, Object?>> snapshot(String table) => raw
        .select('SELECT * FROM $table ORDER BY 1')
        .map(Map<String, Object?>.of)
        .toList();

    final before = {
      for (final t in ['settings', 'categories', 'accounts']) t: snapshot(t),
    };
    expect(before['categories'], hasLength(18), reason: '17 defaults + 1');
    expect(before['accounts'], hasLength(2));

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    Future<List<Map<String, Object?>>> after(String table) async =>
        (await db.customSelect('SELECT * FROM $table ORDER BY 1').get())
            .map((r) => r.data)
            .toList();

    for (final t in before.keys) {
      expect(await after(t), before[t], reason: '$t rows must be unchanged');
    }
    final txCount = await db
        .customSelect('SELECT COUNT(*) AS c FROM transactions')
        .getSingle();
    expect(txCount.read<int>('c'), 0);

    // The seed marker survived, so the seeder must not insert anything.
    await SeedRunner(db).runAll(const [ExpenseDefaultsSeeder()]);
    expect(await after('categories'), before['categories']);
    expect(await after('accounts'), before['accounts']);
  });
  // --- 003-budgets-recurring-reports (T012, research R3) ---

  test('upgrade from v2 to v3', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);
  });

  for (final from in [1, 2]) {
    test(
      'upgrade from v$from to v4 preserves every row and adds the rule FK',
      () async {
        final schema = await verifier.schemaAt(from);
        final raw = schema.rawDatabase;
        _insertV1Data(raw.execute);
        if (from == 2) _insertV2Transactions(raw.execute);
        List<Map<String, Object?>> snapshot(String table) => raw
            .select('SELECT * FROM $table ORDER BY 1')
            .map(Map<String, Object?>.of)
            .toList();
        final tables = [
          'settings',
          'categories',
          'accounts',
          if (from == 2) 'transactions',
        ];
        final before = {for (final t in tables) t: snapshot(t)};
        if (from == 2) {
          expect(before['transactions'], hasLength(51));
        }

        final db = AppDatabase(schema.newConnection());
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, 4);

        Future<List<Map<String, Object?>>> rows(String sql) async =>
            (await db.customSelect(sql).get()).map((r) => r.data).toList();

        for (final t in tables) {
          expect(
            await rows('SELECT * FROM $t ORDER BY 1'),
            before[t],
            reason: '$t rows must be identical after the upgrade',
          );
        }

        final fks = await rows('PRAGMA foreign_key_list(transactions)');
        expect(
          fks.any(
            (fk) =>
                fk['from'] == 'recurring_rule_id' &&
                fk['table'] == 'recurring_rules' &&
                fk['to'] == 'id',
          ),
          isTrue,
          reason: 'recurring_rule_id must reference recurring_rules(id)',
        );

        final indexes = {
          for (final r in await rows(
            "SELECT name FROM sqlite_master WHERE type = 'index'",
          ))
            r['name'],
        };
        expect(
          indexes,
          containsAll([
            'transactions_occurred',
            'transactions_category_occurred',
            'transactions_account_occurred',
            'transactions_rule',
            'recurring_rules_due',
            'budgets_month',
            'budgets_month_category_unique',
            'unlocks_feature',
          ]),
        );
        expect(await rows('PRAGMA foreign_key_check'), isEmpty);
        for (final t in ['recurring_rules', 'budgets', 'unlocks']) {
          expect(await rows('SELECT * FROM $t'), isEmpty, reason: t);
        }

        // The seed marker survived, so the seeder must not insert anything.
        await SeedRunner(db).runAll(const [ExpenseDefaultsSeeder()]);
        expect(
          await rows('SELECT * FROM categories ORDER BY 1'),
          before['categories'],
        );
        expect(
          await rows('SELECT * FROM accounts ORDER BY 1'),
          before['accounts'],
        );
      },
    );
  }

  // --- 005-habit-module (T016, research R2) ---

  test('upgrade from v3 to v4', () async {
    final connection = await verifier.startAt(3);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);
  });

  for (final from in [1, 2, 3]) {
    test('upgrade from v$from to v4 keeps every row and adds the habit '
        'tables', () async {
      final schema = await verifier.schemaAt(from);
      final raw = schema.rawDatabase;
      _insertV1Data(raw.execute);
      if (from >= 2) _insertV2Transactions(raw.execute);
      if (from >= 3) _insertV3Data(raw.execute);
      List<Map<String, Object?>> snapshot(String table) => raw
          .select('SELECT * FROM $table ORDER BY 1')
          .map(Map<String, Object?>.of)
          .toList();
      final tables = [
        'settings',
        'categories',
        'accounts',
        if (from >= 2) 'transactions',
        if (from >= 3) ...['recurring_rules', 'budgets', 'unlocks'],
      ];
      final before = {for (final t in tables) t: snapshot(t)};
      if (from >= 3) {
        expect(before['budgets'], hasLength(2));
        expect(before['unlocks'], hasLength(1));
      }

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 4);

      Future<List<Map<String, Object?>>> rows(String sql) async =>
          (await db.customSelect(sql).get()).map((r) => r.data).toList();

      for (final t in tables) {
        expect(
          await rows('SELECT * FROM $t ORDER BY 1'),
          before[t],
          reason: '$t rows must be identical after the upgrade',
        );
      }

      final indexes = {
        for (final r in await rows(
          "SELECT name FROM sqlite_master WHERE type = 'index'",
        ))
          r['name'],
      };
      expect(
        indexes,
        containsAll([
          'habits_active_order',
          'habit_schedules_habit_from_unique',
          'habit_entries_habit_date_unique',
          'habit_entries_date',
        ]),
      );
      for (final t in ['habits', 'habit_schedules', 'habit_entries']) {
        expect(await rows('SELECT * FROM $t'), isEmpty, reason: t);
      }
      expect(await rows('PRAGMA foreign_key_check'), isEmpty);

      // The seed marker survived, so the seeder must not insert anything.
      await SeedRunner(db).runAll(const [ExpenseDefaultsSeeder()]);
      expect(
        await rows('SELECT * FROM categories ORDER BY 1'),
        before['categories'],
      );
      expect(
        await rows('SELECT * FROM accounts ORDER BY 1'),
        before['accounts'],
      );
    });
  }

  // --- 010-google-account-backup (T014, data-model §2) ---

  test('upgrade from v4 to v5', () async {
    final connection = await verifier.startAt(4);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 5);
  });

  test('upgrade from v4 to v5 keeps every row and adds only the '
      'change-counter triggers', () async {
    final schema = await verifier.schemaAt(4);
    final raw = schema.rawDatabase;
    _insertV1Data(raw.execute);
    _insertV2Transactions(raw.execute);
    _insertV3Data(raw.execute);
    const tables = [
      'settings',
      'categories',
      'accounts',
      'transactions',
      'recurring_rules',
      'budgets',
      'unlocks',
    ];
    List<Map<String, Object?>> snapshot(String table) => raw
        .select('SELECT * FROM $table ORDER BY 1')
        .map(Map<String, Object?>.of)
        .toList();
    final before = {for (final t in tables) t: snapshot(t)};
    final objectsBefore = raw
        .select("SELECT name FROM sqlite_master WHERE type != 'trigger'")
        .map((r) => r['name'])
        .toSet();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 5);

    Future<List<Map<String, Object?>>> rows(String sql) async =>
        (await db.customSelect(sql).get()).map((r) => r.data).toList();
    for (final t in tables) {
      expect(
        await rows('SELECT * FROM $t ORDER BY 1'),
        before[t],
        reason: '$t rows must be identical after the upgrade',
      );
    }
    final objectsAfter = {
      for (final r in await rows(
        "SELECT name FROM sqlite_master WHERE type != 'trigger'",
      ))
        r['name'],
    };
    expect(objectsAfter, objectsBefore);
    final triggers = await rows(
      "SELECT name FROM sqlite_master WHERE type = 'trigger'",
    );
    // 8 backed-up tables and settings, 3 each.
    expect(triggers, hasLength(27));
  });
}

/// Feature-003-shaped rows (a recurring rule, two budgets, an unlock) written
/// with raw SQL against the v3 schema, on top of [_insertV2Transactions].
void _insertV3Data(void Function(String sql, List<Object?> args) exec) {
  const t0 = 1760000000000;
  exec(
    'INSERT INTO recurring_rules (id, template_type, amount_minor, account_id, '
    'to_account_id, category_id, payment_mode, note, frequency, interval, '
    'anchor_at, next_run_at, end_at, is_active, created_at, updated_at, '
    'deleted_at) VALUES (?, 0, 50000, ?, NULL, ?, 1, ?, 2, 1, ?, ?, NULL, 1, '
    '?, ?, NULL)',
    ['r-rent', 'a-cash', 'c-custom', 'Rent', t0, t0 + 86400000, t0, t0],
  );
  exec('UPDATE transactions SET recurring_rule_id = ? WHERE id = ?', [
    'r-rent',
    't-00',
  ]);
  const budgetSql =
      'INSERT INTO budgets (id, category_id, month_key, limit_minor, rollover, '
      'alert80_sent_at, alert100_sent_at, created_at, updated_at, deleted_at) '
      'VALUES (?, ?, ?, ?, ?, ?, NULL, ?, ?, NULL)';
  exec(budgetSql, ['b-all', null, '2026-10', 3000000, 1, t0, t0, t0]);
  exec(budgetSql, ['b-food', 'c-custom', '2026-10', 600000, 0, null, t0, t0]);
  exec(
    'INSERT INTO unlocks (id, feature_key, expires_at, source, created_at, '
    'updated_at, deleted_at) VALUES (?, ?, ?, 0, ?, ?, NULL)',
    ['u-1', 'advancedReports', t0 + 86400000, t0, t0],
  );
}

/// Feature-002-shaped transactions (all 3 types, with notes, receipts and
/// one soft-deleted row) written with raw SQL against the v2 schema, on top
/// of [_insertV1Data].
void _insertV2Transactions(void Function(String sql, List<Object?> args) exec) {
  const t0 = 1760000000000;
  const sql =
      'INSERT INTO transactions (id, type, amount_minor, account_id, '
      'to_account_id, category_id, payment_mode, note, occurred_at, '
      'receipt_path, recurring_rule_id, created_at, updated_at, deleted_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, ?)';
  for (var i = 0; i < 51; i++) {
    final type = i % 3;
    final at = t0 + i * 3600000;
    exec(sql, [
      't-${i.toString().padLeft(2, '0')}',
      type,
      (i + 1) * 1250,
      'a-cash',
      if (type == 2) 'a-sbi' else null,
      switch (type) {
        0 => 'c-custom',
        1 => 'c-${ExpenseDefaultsSeeder.incomeKeys.first}',
        _ => null,
      },
      i % 5,
      if (i.isEven) 'Note $i' else null,
      at,
      if (i % 7 == 0) 'receipts/r$i.jpg' else null,
      at,
      at,
      if (i == 50) at + 1 else null,
    ]);
  }
}

/// Feature-001-shaped data written with raw SQL against the v1 schema.
void _insertV1Data(void Function(String sql, List<Object?> args) exec) {
  const t0 = 1760000000000;
  const settingSql =
      'INSERT INTO settings (key, value, updated_at) VALUES (?, ?, ?)';
  exec(settingSql, ['locale', '"gu"', t0]);
  exec(settingSql, ['onboardingDone', 'true', t0]);
  exec(settingSql, [SettingsCodec.seedKey('expense.defaults.v1'), '$t0', t0]);

  var order = 0;
  void category(String id, String name, int type, {bool isDefault = true}) =>
      exec(
        'INSERT INTO categories (id, name, type, icon_key, color_hex, '
        'is_default, is_archived, sort_order, created_at, updated_at, '
        'deleted_at) VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, ?, NULL)',
        [
          id,
          name,
          type,
          'category',
          '#0F766E',
          if (isDefault) 1 else 0,
          order++,
          t0,
          t0,
        ],
      );

  for (final key in ExpenseDefaultsSeeder.expenseKeys) {
    category('c-$key', key, 0);
  }
  for (final key in ExpenseDefaultsSeeder.incomeKeys) {
    category('c-$key', key, 1);
  }
  category('c-custom', 'Chai & snacks', 0, isDefault: false);

  void account(String id, String name, int type, int opening) => exec(
    'INSERT INTO accounts (id, name, type, opening_balance_minor, icon_key, '
    'color_hex, is_archived, sort_order, created_at, updated_at, deleted_at) '
    'VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, ?, NULL)',
    [id, name, type, opening, 'wallet', '#0F766E', order++, t0, t0],
  );
  account('a-cash', ExpenseDefaultsSeeder.cashAccountKey, 0, 0);
  account('a-sbi', 'SBI Savings', 1, 1000000);
}
