import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/backup/data/backup_engine.dart';
import 'package:dailytrack/core/backup/domain/backup_envelope.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';

/// The module tables a backup carries (feature 008 data-model §3).
const List<String> moduleTables = [
  'accounts',
  'categories',
  'transactions',
  'budgets',
  'recurring_rules',
  'habits',
  'habit_schedules',
  'habit_entries',
];

/// Fast key derivation for tests; the production count is pinned in
/// `backup_envelope_test.dart`.
BackupEnvelope testEnvelope() => BackupEnvelope(iterations: 1000);

/// The real Expense and Habit sections.
List<BackupSection> realSections() => [
  for (final m in registeredModules) ?m.backupSection(),
];

List<String> realSeederIds() => [
  for (final m in registeredModules)
    for (final s in m.seeders) s.id,
];

BackupEngine engineFor(
  AppDatabase db,
  Clock clock,
  Directory docs, {
  List<BackupSection>? sections,
}) => BackupEngine(
  db: db,
  sections: sections ?? realSections(),
  seederIds: realSeederIds(),
  clock: clock,
  appVersion: () async => '1.0.0+7',
  documentsDir: () async => docs,
  envelope: testEnvelope(),
);

/// Receipt image used by the seed.
final Uint8List receiptBytes = Uint8List.fromList(
  List.generate(2048, (i) => i % 251),
);

const String gujaratiNote = 'આજે ચા ☕ અને ક્ષમા';
const String hindiNote = 'दूध, ब्रेड "और" क्षमा';

/// One of everything a real user could have: every module table, soft
/// deleted rows, a transfer, a recurring rule, budgets with alert markers,
/// archived and deleted habits, schedule history, freezes, notes in Hindi
/// and Gujarati, a receipt file, preferences, device state, and an unlock.
Future<void> seedRichData(AppDatabase db, Directory docs) async {
  const t = 1792540800000; // 2026-10-21 UTC
  await db.batch((b) {
    b
      ..insertAll(db.accounts, [
        const AccountRow(
          id: 'a1',
          name: 'expense_account_cash',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          iconKey: 'payments',
          colorHex: '#0F766E',
          isArchived: false,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        const AccountRow(
          id: 'a2',
          name: 'SBI Savings',
          type: AccountType.bank,
          openingBalanceMinor: 1500000,
          iconKey: 'account_balance',
          colorHex: '#2B7ACA',
          isArchived: true,
          sortOrder: 1,
          createdAt: t,
          updatedAt: t + 1,
        ),
        const AccountRow(
          id: 'a3',
          name: 'Old wallet',
          type: AccountType.wallet,
          openingBalanceMinor: -500,
          iconKey: 'wallet',
          colorHex: '#B91C1C',
          isArchived: false,
          sortOrder: 2,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 5,
        ),
      ])
      ..insertAll(db.categories, [
        const CategoryRow(
          id: 'c1',
          name: 'expense_cat_food',
          type: CategoryType.expense,
          iconKey: 'restaurant',
          colorHex: '#F97316',
          isDefault: true,
          isArchived: false,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        const CategoryRow(
          id: 'c2',
          name: 'income_cat_salary',
          type: CategoryType.income,
          iconKey: 'work',
          colorHex: '#15803D',
          isDefault: true,
          isArchived: false,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        const CategoryRow(
          id: 'c3',
          name: 'ચા',
          type: CategoryType.expense,
          iconKey: 'local_cafe',
          colorHex: '#7C3AED',
          isDefault: false,
          isArchived: true,
          sortOrder: 1,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 9,
        ),
      ])
      ..insertAll(db.recurringRules, [
        const RecurringRuleRow(
          id: 'r1',
          templateType: TxnType.expense,
          amountMinor: 99900,
          accountId: 'a1',
          categoryId: 'c1',
          paymentMode: PaymentMode.upi,
          note: 'Tiffin',
          frequency: Frequency.monthly,
          interval: 1,
          anchorAt: t,
          nextRunAt: t + 86400000,
          isActive: true,
          createdAt: t,
          updatedAt: t,
        ),
        const RecurringRuleRow(
          id: 'r2',
          templateType: TxnType.transfer,
          amountMinor: 500000,
          accountId: 'a1',
          toAccountId: 'a2',
          paymentMode: PaymentMode.netBanking,
          frequency: Frequency.weekly,
          interval: 1,
          anchorAt: t,
          nextRunAt: t,
          endAt: t + 1000,
          isActive: false,
          createdAt: t,
          updatedAt: t,
        ),
      ])
      ..insertAll(db.transactions, [
        const TransactionRow(
          id: 't1',
          type: TxnType.expense,
          amountMinor: 12550,
          accountId: 'a1',
          categoryId: 'c1',
          paymentMode: PaymentMode.cash,
          note: gujaratiNote,
          occurredAt: t,
          receiptPath: 'receipts/r1.jpg',
          recurringRuleId: 'r1',
          createdAt: t,
          updatedAt: t,
        ),
        const TransactionRow(
          id: 't2',
          type: TxnType.income,
          amountMinor: 99999999900,
          accountId: 'a2',
          categoryId: 'c2',
          paymentMode: PaymentMode.netBanking,
          note: hindiNote,
          occurredAt: t - 1,
          createdAt: t,
          updatedAt: t,
        ),
        const TransactionRow(
          id: 't3',
          type: TxnType.transfer,
          amountMinor: 1,
          accountId: 'a1',
          toAccountId: 'a2',
          paymentMode: PaymentMode.other,
          occurredAt: t - 2,
          createdAt: t,
          updatedAt: t,
        ),
        const TransactionRow(
          id: 't4',
          type: TxnType.expense,
          amountMinor: 700,
          accountId: 'a3',
          categoryId: 'c3',
          paymentMode: PaymentMode.card,
          occurredAt: t - 3,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 4,
        ),
      ])
      ..insertAll(db.budgets, [
        const BudgetRow(
          id: 'b1',
          monthKey: '2026-10',
          limitMinor: 1000000,
          rollover: true,
          alert80SentAt: t,
          alert100SentAt: t + 1,
          createdAt: t,
          updatedAt: t,
        ),
        const BudgetRow(
          id: 'b2',
          categoryId: 'c1',
          monthKey: '2026-10',
          limitMinor: 300000,
          rollover: false,
          createdAt: t,
          updatedAt: t,
        ),
        const BudgetRow(
          id: 'b3',
          monthKey: '2026-10',
          limitMinor: 5,
          rollover: false,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 2,
        ),
      ])
      ..insertAll(db.habits, [
        const HabitRow(
          id: 'h1',
          name: 'વાંચન',
          iconKey: 'menu_book',
          colorHex: '#2B7ACA',
          kind: HabitKind.yesNo,
          targetValue: 1,
          scheduleType: ScheduleType.daily,
          weekdaysMask: 0,
          reminderTimes: '["08:00","21:30"]',
          remindOnlyIfNotDone: true,
          startDateKey: '2026-10-01',
          isArchived: false,
          sortOrder: 0,
          freezesAvailable: 2,
          celebratedMilestones: 1,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitRow(
          id: 'h2',
          name: 'Read',
          iconKey: 'book',
          colorHex: '#15803D',
          kind: HabitKind.count,
          targetValue: 25,
          unit: 'pages',
          scheduleType: ScheduleType.timesPerWeek,
          weekdaysMask: 0,
          timesPerWeek: 3,
          reminderTimes: '[]',
          remindOnlyIfNotDone: false,
          startDateKey: '2026-09-01',
          isArchived: true,
          archivedAt: t + 3,
          sortOrder: 1,
          freezesAvailable: 0,
          celebratedMilestones: 0,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitRow(
          id: 'h3',
          name: 'Gone',
          iconKey: 'close',
          colorHex: '#000000',
          kind: HabitKind.yesNo,
          targetValue: 1,
          scheduleType: ScheduleType.specificWeekdays,
          weekdaysMask: 21,
          reminderTimes: '[]',
          remindOnlyIfNotDone: true,
          startDateKey: '2026-10-10',
          isArchived: false,
          sortOrder: 2,
          freezesAvailable: 0,
          celebratedMilestones: 0,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 7,
        ),
      ])
      ..insertAll(db.habitSchedules, [
        const HabitScheduleRow(
          id: 's1',
          habitId: 'h1',
          effectiveFromKey: '2026-10-01',
          scheduleType: ScheduleType.daily,
          weekdaysMask: 0,
          targetValue: 1,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitScheduleRow(
          id: 's2',
          habitId: 'h2',
          effectiveFromKey: '2026-09-01',
          scheduleType: ScheduleType.timesPerWeek,
          weekdaysMask: 0,
          timesPerWeek: 2,
          targetValue: 20,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitScheduleRow(
          id: 's3',
          habitId: 'h2',
          effectiveFromKey: '2026-10-05',
          scheduleType: ScheduleType.timesPerWeek,
          weekdaysMask: 0,
          timesPerWeek: 3,
          targetValue: 25,
          createdAt: t,
          updatedAt: t,
        ),
      ])
      ..insertAll(db.habitEntries, [
        const HabitEntryRow(
          id: 'e1',
          habitId: 'h1',
          dateKey: '2026-10-20',
          value: 1,
          isFreeze: false,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitEntryRow(
          id: 'e2',
          habitId: 'h1',
          dateKey: '2026-10-19',
          value: 0,
          isFreeze: true,
          createdAt: t,
          updatedAt: t,
        ),
        const HabitEntryRow(
          id: 'e3',
          habitId: 'h2',
          dateKey: '2026-10-20',
          value: 12,
          isFreeze: false,
          note: 'पढ़ा',
          createdAt: t,
          updatedAt: t,
        ),
        const HabitEntryRow(
          id: 'e4',
          habitId: 'h2',
          dateKey: '2026-10-18',
          value: 3,
          isFreeze: false,
          createdAt: t,
          updatedAt: t,
          deletedAt: t + 1,
        ),
      ])
      ..insertAll(db.settings, [
        for (final MapEntry(:key, :value) in {
          'locale': 'gu',
          'currencyCode': 'USD',
          'themeMode': 'dark',
          'dateFormat': 'iso',
          'enabledModules': ['expense', 'habit'],
          'moduleOrder': ['habit', 'expense'],
          'dailySummaryTime': '20:30',
          'module.expense.budgetRolloverMonth': '2026-10',
          'onboardingDone': true,
          'seed.expense.defaults': t,
          // Device state: never in a backup.
          'lockEnabled': true,
          'adConsentStatus': 'obtained',
          'backupEncrypt': false,
        }.entries)
          SettingsCompanion.insert(
            key: key,
            value: jsonEncode(value),
            updatedAt: t,
          ),
      ])
      ..insert(
        db.unlocks,
        UnlocksCompanion.insert(
          id: 'u1',
          featureKey: 'premiumTheme_saffron',
          source: UnlockSource.rewardedAd,
          createdAt: t,
          updatedAt: t,
        ),
      );
  });
  final receipts = Directory('${docs.path}/receipts')
    ..createSync(recursive: true);
  File('${receipts.path}/r1.jpg').writeAsBytesSync(receiptBytes);
}

/// Row count and SHA-256 of every row (all columns, ordered by id) for each
/// module table: equal checksums mean identical data (SET-02 AC 1).
Future<Map<String, (int, String)>> tableChecksums(AppDatabase db) async {
  final result = <String, (int, String)>{};
  for (final table in moduleTables) {
    final rows = await db
        .customSelect('SELECT * FROM $table ORDER BY id')
        .get();
    final canonical = jsonEncode([for (final r in rows) r.data]);
    final hash = await Sha256().hash(utf8.encode(canonical));
    result[table] = (rows.length, base64.encode(hash.bytes));
  }
  return result;
}

/// The `settings` rows as key → JSON text.
Future<Map<String, String>> settingsRows(AppDatabase db) async => {
  for (final r in await db.select(db.settings).get()) r.key: r.value,
};

/// Deletes every row of every table, like "Erase all data".
Future<void> eraseEverything(AppDatabase db) => db.transaction(() async {
  await db.customStatement('PRAGMA defer_foreign_keys = ON');
  for (final table in db.allTables) {
    await db.delete(table).go();
  }
});
