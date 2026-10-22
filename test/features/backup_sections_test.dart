import 'dart:io';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/expense/data/backup/expense_backup_section.dart';
import 'package:dailytrack/features/habit/data/backup/habit_backup_section.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/backup/backup_test_support.dart';

/// The Expense and Habit backup sections (feature 008 T027, T028, research
/// R5, data-model §3): export by name, the CHECK mirrors in `validate`,
/// receipts, and summaries.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late Map<String, Object?> expense;
  late Map<String, Object?> habit;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('sections');
    await seedRichData(db, docs);
    expense = await const ExpenseBackupSection().export(db);
    habit = await const HabitBackupSection().export(db);
  });
  tearDownAll(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  /// [section] with row [index] of [table] changed by [edit].
  Map<String, Object?> withRow(
    Map<String, Object?> section,
    String table,
    int index,
    Map<String, Object?> Function(Map<String, Object?>) edit,
  ) {
    final tables = Map<String, Object?>.from(section['tables']! as Map);
    final rows = [
      for (final r in tables[table]! as List)
        Map<String, Object?>.from(r as Map),
    ];
    rows[index] = edit(rows[index]);
    tables[table] = rows;
    return {...section, 'tables': tables};
  }

  Map<String, Object?> withExtraRow(
    Map<String, Object?> section,
    String table,
    Map<String, Object?> row,
  ) {
    final tables = Map<String, Object?>.from(section['tables']! as Map);
    tables[table] = [...tables[table]! as List, row];
    return {...section, 'tables': tables};
  }

  Map<String, Object?> rowOf(Map<String, Object?> s, String table, int i) =>
      Map<String, Object?>.from(
        ((s['tables']! as Map)[table]! as List)[i] as Map,
      );

  group('ExpenseBackupSection', () {
    const section = ExpenseBackupSection();

    test('exports every table, soft-deleted rows included, enums by name', () {
      final tables = expense['tables']! as Map;
      expect((tables['accounts'] as List).length, 3);
      expect((tables['transactions'] as List).length, 4);
      expect((tables['recurringRules'] as List).length, 2);
      expect((tables['budgets'] as List).length, 3);
      final t3 = rowOf(expense, 'transactions', 2);
      expect(t3['type'], 'transfer');
      expect(t3['paymentMode'], 'other');
      section.validate(expense);
    });

    final cases = <String, (String, int, Map<String, Object?>)>{
      'unknown enum name': ('transactions', 0, {'paymentMode': 'cheque'}),
      'account name over 40': ('accounts', 0, {'name': 'x' * 41}),
      'empty category name': ('categories', 0, {'name': ''}),
      'bad color': ('categories', 0, {'colorHex': 'teal'}),
      'note over 200': ('transactions', 0, {'note': 'n' * 201}),
      'zero amount': ('transactions', 0, {'amountMinor': 0}),
      'amount too large': ('transactions', 0, {'amountMinor': 99999999901}),
      'transfer with a category': ('transactions', 2, {'categoryId': 'c1'}),
      'expense without category': ('transactions', 0, {'categoryId': null}),
      'transfer to itself': ('transactions', 2, {'toAccountId': 'a1'}),
      'bad month key': ('budgets', 0, {'monthKey': '2026-1'}),
      '100% alert without 80%': ('budgets', 1, {'alert100SentAt': 5}),
      'interval 0': ('recurringRules', 0, {'interval': 0}),
      'end before anchor': ('recurringRules', 1, {'endAt': 0}),
      'missing account': ('transactions', 0, {'accountId': 'nope'}),
      'missing rule': ('transactions', 0, {'recurringRuleId': 'nope'}),
      'receipt outside receipts/': (
        'transactions',
        0,
        {'receiptPath': '../db.sqlite'},
      ),
      'string where an integer belongs': (
        'transactions',
        0,
        {'occurredAt': '5'},
      ),
    };
    for (final MapEntry(key: name, value: (table, index, change))
        in cases.entries) {
      test('validate rejects: $name', () {
        expect(
          () => section.validate(
            withRow(expense, table, index, (r) => {...r, ...change}),
          ),
          throwsA(isA<BackupInvalid>()),
        );
      });
    }

    test(
      'validate rejects duplicate ids and two live budgets for one month',
      () {
        expect(
          () => section.validate(
            withExtraRow(expense, 'accounts', rowOf(expense, 'accounts', 0)),
          ),
          throwsA(isA<BackupInvalid>()),
        );
        expect(
          () => section.validate(
            withExtraRow(expense, 'budgets', {
              ...rowOf(expense, 'budgets', 0),
              'id': 'b-dup',
            }),
          ),
          throwsA(isA<BackupInvalid>()),
        );
        // A deleted duplicate (b3) is allowed, as by the partial index.
        section.validate(expense);
      },
    );

    test('attachments list receipt paths; withoutAttachments clears them', () {
      expect(section.attachments(expense).toList(), ['receipts/r1.jpg']);
      final stripped = section.withoutAttachments(expense);
      expect(section.attachments(stripped), isEmpty);
      expect(rowOf(stripped, 'transactions', 0)['receiptPath'], isNull);
    });

    test('summary uses plurals in every language', () {
      final counts = section.counts(expense);
      expect(counts['transactions'], 3);
      expect(
        section.summary(lookupAppLocalizations(const Locale('en')), {
          'transactions': 1240,
        }),
        '1,240 transactions',
      );
      expect(
        section.summary(lookupAppLocalizations(const Locale('en')), {
          'transactions': 1,
        }),
        '1 transaction',
      );
      for (final lang in ['hi', 'gu']) {
        expect(
          section.summary(lookupAppLocalizations(Locale(lang)), counts),
          contains('3'),
        );
      }
    });
  });

  group('HabitBackupSection', () {
    const section = HabitBackupSection();

    test('exports habits, schedule history, and entries with notes', () {
      final tables = habit['tables']! as Map;
      expect((tables['habits'] as List).length, 3);
      expect((tables['habitSchedules'] as List).length, 3);
      expect((tables['habitEntries'] as List).length, 4);
      expect(rowOf(habit, 'habits', 1)['kind'], 'count');
      section.validate(habit);
    });

    final cases = <String, (String, int, Map<String, Object?>)>{
      'weekdays mask 128': ('habits', 0, {'weekdaysMask': 128}),
      'times per week 7': ('habits', 1, {'timesPerWeek': 7}),
      'three freezes': ('habits', 0, {'freezesAvailable': 3}),
      'milestones over 63': ('habits', 0, {'celebratedMilestones': 64}),
      'yes/no target 2': ('habits', 0, {'targetValue': 2}),
      'count target 10000': ('habits', 1, {'targetValue': 10000}),
      'blank name': ('habits', 0, {'name': '   '}),
      'unit over 20': ('habits', 1, {'unit': 'u' * 21}),
      'four reminders': (
        'habits',
        0,
        {'reminderTimes': '["01:00","02:00","03:00","04:00"]'},
      ),
      'bad reminder time': ('habits', 0, {'reminderTimes': '["25:00"]'}),
      'bad start date': ('habits', 0, {'startDateKey': '21-10-2026'}),
      'entry value 10000': ('habitEntries', 0, {'value': 10000}),
      'bad entry day': ('habitEntries', 0, {'dateKey': '2026/10/20'}),
      'entry for a missing habit': ('habitEntries', 0, {'habitId': 'nope'}),
      'schedule target 0': ('habitSchedules', 0, {'targetValue': 0}),
    };
    for (final MapEntry(key: name, value: (table, index, change))
        in cases.entries) {
      test('validate rejects: $name', () {
        expect(
          () => section.validate(
            withRow(habit, table, index, (r) => {...r, ...change}),
          ),
          throwsA(isA<BackupInvalid>()),
        );
      });
    }

    test(
      'validate rejects two entries for one habit and day, even deleted',
      () {
        expect(
          () => section.validate(
            withExtraRow(habit, 'habitEntries', {
              ...rowOf(habit, 'habitEntries', 0),
              'id': 'e-dup',
              'deletedAt': 1,
            }),
          ),
          throwsA(isA<BackupInvalid>()),
        );
      },
    );

    test('summary counts live habits', () {
      expect(section.counts(habit)['habits'], 2);
      expect(
        section.summary(lookupAppLocalizations(const Locale('en')), {
          'habits': 8,
        }),
        '8 habits',
      );
    });
  });
}
