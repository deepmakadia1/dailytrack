import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Inserts one category, then fails, to prove the transaction rolls back.
class _FailingSeeder implements Seeder {
  @override
  String get id => 'test.failing';

  @override
  Future<void> seed(AppDatabase db) async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'x',
            name: 'Partial',
            type: CategoryType.expense,
            iconKey: 'category',
            colorHex: '#123456',
            sortOrder: 0,
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    throw StateError('seeding failed midway');
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> countCategories(CategoryType type) async {
    final rows = await (db.select(
      db.categories,
    )..where((c) => c.type.equalsValue(type) & c.isDefault.equals(true))).get();
    return rows.length;
  }

  Future<List<AccountRow>> accounts() => db.select(db.accounts).get();

  Future<void> expectSeededOnce() async {
    expect(await countCategories(CategoryType.expense), 12);
    expect(await countCategories(CategoryType.income), 5);
    final accs = await accounts();
    expect(accs, hasLength(1));
    expect(accs.single.name, ExpenseDefaultsSeeder.cashAccountKey);
    expect(accs.single.type, AccountType.cash);
    expect(accs.single.openingBalanceMinor, 0);
  }

  test('SYS-01 first launch seeds 12 expense categories, 5 income '
      'categories, and one Cash account, exactly once', () async {
    await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
    await expectSeededOnce();

    for (var i = 0; i < 3; i++) {
      await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
    }
    await expectSeededOnce();

    // US3 regression (T080): the criterion holds on schema v4 (feature 005),
    // and seeding never writes transactions, rules, budgets, unlocks or
    // habit rows (no habit seed data, research R17 of feature 005).
    expect(db.schemaVersion, 5);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.recurringRules).get(), isEmpty);
    expect(await db.select(db.budgets).get(), isEmpty);
    expect(await db.select(db.unlocks).get(), isEmpty);
    expect(await db.select(db.habits).get(), isEmpty);
    expect(await db.select(db.habitSchedules).get(), isEmpty);
    expect(await db.select(db.habitEntries).get(), isEmpty);
  });

  test(
    'seeded rows use l10n keys, palette colors, and are not deleted',
    () async {
      await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
      final cats = await db.select(db.categories).get();
      expect(
        cats.map((c) => c.name),
        containsAll([
          ...ExpenseDefaultsSeeder.expenseKeys,
          ...ExpenseDefaultsSeeder.incomeKeys,
        ]),
      );
      for (final c in cats) {
        expect(c.colorHex, matches(RegExp(r'^#[0-9A-F]{6}$')));
        expect(c.deletedAt, isNull);
        expect(c.id, hasLength(36), reason: 'UUID v4');
      }
      final expenseOrder = cats
          .where((c) => c.type == CategoryType.expense)
          .map((c) => c.sortOrder)
          .toList();
      expect(expenseOrder..sort(), List.generate(12, (i) => i));
    },
  );

  test(
    'a failing seeder rolls back completely and can succeed later',
    () async {
      await expectLater(
        SeedRunner(db).runAll([_FailingSeeder()]),
        throwsA(isA<StateError>()),
      );
      expect(await db.select(db.categories).get(), isEmpty);
      final marker =
          await (db.select(db.settings)..where(
                (s) => s.key.equals(SettingsCodec.seedKey('test.failing')),
              ))
              .getSingleOrNull();
      expect(marker, isNull);

      await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
      await expectSeededOnce();
    },
  );

  test('the seed marker is recorded in settings', () async {
    await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
    final marker =
        await (db.select(db.settings)..where(
              (s) => s.key.equals(
                SettingsCodec.seedKey(const ExpenseDefaultsSeeder().id),
              ),
            ))
            .getSingleOrNull();
    expect(marker, isNotNull);
  });
}
