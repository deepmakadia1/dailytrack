import 'package:dailytrack/core/database/app_database.steps.dart';
import 'package:dailytrack/core/database/tables/settings_table.dart';
import 'package:dailytrack/core/database/tables/unlocks_table.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
// The one core file allowed to import feature code: Drift needs every table
// in a single database class (plan.md Complexity Tracking, features 001-005:
// categories, accounts, transactions, recurring_rules, budgets, habits,
// habit_schedules, habit_entries).
import 'package:dailytrack/features/expense/data/tables/accounts_table.dart';
import 'package:dailytrack/features/expense/data/tables/budgets_table.dart';
import 'package:dailytrack/features/expense/data/tables/categories_table.dart';
import 'package:dailytrack/features/expense/data/tables/recurring_rules_table.dart';
import 'package:dailytrack/features/expense/data/tables/transactions_table.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/habit/data/tables/habit_entries_table.dart';
import 'package:dailytrack/features/habit/data/tables/habit_schedules_table.dart';
import 'package:dailytrack/features/habit/data/tables/habits_table.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Settings,
    Categories,
    Accounts,
    Transactions,
    RecurringRules,
    Budgets,
    Unlocks,
    Habits,
    HabitSchedules,
    HabitEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  // The generated superclass names its parameter `e`.
  new(super.e);

  /// The on-device database file; covered by the integration test. Shared
  /// across isolates so the background job (T1.6) writes through the same
  /// connection as the UI (research R9).
  // coverage:ignore-start
  factory open() => AppDatabase(
    driftDatabase(
      name: 'dailytrack',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );
  // coverage:ignore-end

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Each step uses the frozen schema snapshot from app_database.steps.dart
    // (`dart run drift_dev make-migrations`), never the live tables, so later
    // table changes cannot alter an old upgrade. Every step has a test in
    // test/drift/app_database/migration_test.dart.
    onUpgrade: stepByStep(
      // v2 (002-expense-core): transactions + its 3 indexes. Existing
      // settings, categories and accounts rows are not touched.
      from1To2: (m, schema) async {
        await m.createTable(schema.transactions);
        await m.createIndex(schema.transactionsOccurred);
        await m.createIndex(schema.transactionsCategoryOccurred);
        await m.createIndex(schema.transactionsAccountOccurred);
      },
      // v3 (003-budgets-recurring-reports, data-model.md §1): three new
      // tables, then `transactions` is rebuilt so recurring_rule_id gains its
      // foreign key (SQLite cannot add one to an existing column). Every
      // transaction row is copied unchanged.
      from2To3: (m, schema) async {
        await m.createTable(schema.recurringRules);
        await m.createIndex(schema.recurringRulesDue);
        await m.createTable(schema.budgets);
        await m.createIndex(schema.budgetsMonth);
        await m.createIndex(schema.budgetsMonthCategoryUnique);
        await m.createTable(schema.unlocks);
        await m.createIndex(schema.unlocksFeature);

        await customStatement('PRAGMA foreign_keys = OFF');
        await m.alterTable(TableMigration(schema.transactions));
        // Re-create the 3 existing indexes whether or not the rebuild kept
        // them, and add the new rule index.
        for (final index in [
          schema.transactionsOccurred,
          schema.transactionsCategoryOccurred,
          schema.transactionsAccountOccurred,
          schema.transactionsRule,
        ]) {
          await customStatement('DROP INDEX IF EXISTS ${index.entityName}');
          await m.createIndex(index);
        }
        final broken = await customSelect('PRAGMA foreign_key_check').get();
        if (broken.isNotEmpty) {
          throw StateError(
            'Schema v3 upgrade left ${broken.length} broken foreign keys',
          );
        }
        await customStatement('PRAGMA foreign_keys = ON');
      },
      // v4 (005-habit-module, data-model.md §1): the three habit tables and
      // their indexes. No existing table or row is touched.
      from3To4: (m, schema) async {
        await m.createTable(schema.habits);
        await m.createIndex(schema.habitsActiveOrder);
        await m.createTable(schema.habitSchedules);
        await m.createIndex(schema.habitSchedulesHabitFromUnique);
        await m.createTable(schema.habitEntries);
        await m.createIndex(schema.habitEntriesHabitDateUnique);
        await m.createIndex(schema.habitEntriesDate);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Two isolates (UI and background job) may write at once (R9).
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}
