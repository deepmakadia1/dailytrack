import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/expense/presentation/export/transactions_export_dataset.dart';
import 'package:dailytrack/features/habit/habit_bindings.dart';
import 'package:dailytrack/features/habit/presentation/export/habits_export_dataset.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/backup/backup_test_support.dart';
import '../helpers/real_container.dart';

/// The Transactions and Habits export datasets over a real database
/// (feature 008 T086, T087, FR-027 – FR-029).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;
  late ProviderContainer container;
  final clock = Clock.fixed(DateTime(2026, 10, 25, 12));

  setUpAll(initializeDateFormatting);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('export_ds');
    await seedRichData(db, docs);
    container = makeRealContainer(
      db,
      overrides: [
        ...expenseOverrides(),
        ...habitOverrides(),
        clockProvider.overrideWithValue(clock),
      ],
    );
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  ExportContext context(String locale) => ExportContext(
    l10n: lookupAppLocalizations(Locale(locale)),
    locale: locale,
    currencyCode: 'INR',
    dateFormat: FullDateFormat.iso,
    clock: clock,
  );

  ExportRequest request(
    String id, {
    Map<String, Set<String>> filters = const {},
    Period? period,
  }) => ExportRequest(
    datasetId: id,
    period: period ?? MonthPeriod(DateTime(2026, 10)),
    format: ExportFormat.csv,
    filters: filters,
  );

  String text(ExportCell c) => switch (c) {
    TextCell(:final text) => text,
    MoneyCell(:final plain) => plain,
  };

  group('Transactions', () {
    const dataset = TransactionsExportDataset();

    test('SET-03 US5-2 columns, oldest first, soft-deleted rows left out, '
        'names localized, transfer as From → To', () async {
      final doc = await dataset.build(
        request('transactions'),
        context('en'),
        container.read,
      );
      expect(
        [for (final c in doc.columns) c.header],
        [
          'Date',
          'Time',
          'Type',
          'Category',
          'Account',
          'Payment mode',
          'Amount',
          'Note',
        ],
      );
      final rows = [for (final r in doc.rows) r.map(text).toList()];
      expect(rows, hasLength(3));
      // t3 (transfer, oldest), t2 (income), t1 (expense).
      expect(rows[0][2], 'Transfer');
      expect(rows[0][3], '');
      expect(rows[0][4], 'Cash → SBI Savings');
      expect(rows[1][3], 'Salary');
      expect(rows[1][7], hindiNote);
      expect(rows[2][3], 'Food');
      expect(rows[2][6], '125.50');
      expect(rows[2][7], gujaratiNote);
      expect(rows[2][0], startsWith('2026-'));
    });

    test('SET-03 US5-3 summary totals and a category donut', () async {
      final doc = await dataset.build(
        request('transactions'),
        context('en'),
        container.read,
      );
      final summary = {for (final (k, v) in doc.summary) k: v};
      expect(summary['Total income'], '₹99,99,99,999.00');
      expect(summary['Total expense'], '₹125.50');
      expect(summary['Entries'], '3');
      expect(doc.chart, hasLength(1));
      expect(doc.chart!.single.label, 'Food');
      expect(doc.chart!.single.colorHex, '#F97316');
    });

    test(
      'SET-03 US5-5 account and category filters, listed in the summary',
      () async {
        final byAccount = await dataset.build(
          request(
            'transactions',
            filters: {
              'accounts': {'a2'},
            },
          ),
          context('en'),
          container.read,
        );
        // a2 is the income's account and the transfer's destination.
        expect(byAccount.rows, hasLength(2));
        expect(byAccount.filterLines, ['Accounts: SBI Savings']);

        final byCategory = await dataset.build(
          request(
            'transactions',
            filters: {
              'categories': {'c1'},
            },
          ),
          context('en'),
          container.read,
        );
        expect(byCategory.rows, hasLength(1));
        expect(byCategory.filterLines, ['Categories: Food']);
      },
    );

    test('SET-03 US5-6 an empty period is empty', () async {
      final doc = await dataset.build(
        request('transactions', period: MonthPeriod(DateTime(2025))),
        context('en'),
        container.read,
      );
      expect(doc.isEmpty, isTrue);
    });

    test('in Gujarati, seeded names and headers are translated', () async {
      final doc = await dataset.build(
        request('transactions'),
        context('gu'),
        container.read,
      );
      expect(doc.columns.first.header, 'તારીખ');
      final rows = [for (final r in doc.rows) r.map(text).toList()];
      expect(rows[2][3], isNot('expense_cat_food'));
      expect(rows[2][7], gujaratiNote);
    });

    test(
      'filter options list accounts and categories with their names',
      () async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        final accounts = await dataset.filters.first.options(
          container.read,
          l10n,
        );
        expect([for (final o in accounts) o.label], contains('Cash'));
        final categories = await dataset.filters.last.options(
          container.read,
          l10n,
        );
        expect([for (final o in categories) o.label], contains('Food'));
      },
    );
  });

  group('Habits', () {
    const dataset = HabitsExportDataset();

    test('SET-03 US5-4 one row per habit and day with an entry, archived '
        'habits included, with status and notes', () async {
      final doc = await dataset.build(
        request('habits'),
        context('en'),
        container.read,
      );
      expect(
        [for (final c in doc.columns) c.header],
        ['Date', 'Habit', 'Value', 'Target', 'Unit', 'Status', 'Note'],
      );
      final rows = [for (final r in doc.rows) r.map(text).toList()];
      // e2 freeze (19th), e1 done (20th, h1), e3 partial (20th, archived h2);
      // e4 is soft-deleted.
      expect(rows, hasLength(3));
      expect(rows[0].sublist(1, 6), ['વાંચન', '0', '1', '', 'Freeze']);
      expect(rows[1].sublist(1, 6), ['વાંચન', '1', '1', '', 'Done']);
      expect(rows[2].sublist(1, 7), [
        'Read',
        '12',
        '25',
        'pages',
        'Partial',
        'पढ़ा',
      ]);
    });

    test("the summary has each habit's completion rate", () async {
      final doc = await dataset.build(
        request('habits'),
        context('en'),
        container.read,
      );
      final summary = {for (final (k, v) in doc.summary) k: v};
      expect(summary['Entries'], '3');
      expect(summary['વાંચન'], endsWith('% done'));
    });
  });
}
