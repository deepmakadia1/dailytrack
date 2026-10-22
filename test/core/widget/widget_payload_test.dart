import 'dart:convert';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/core/widget/domain/widget_payload.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The `glance.v1` widget payload (feature 008 T125, data-model §6).

/// Reads a decoded JSON value at [path] (map keys and list indexes).
Object? at(Object? json, List<Object> path) {
  var v = json;
  for (final k in path) {
    v = k is int ? (v! as List<Object?>)[k] : (v! as Map<String, Object?>)[k];
  }
  return v;
}

void main() {
  setUpAll(initializeDateFormatting);

  final en = lookupAppLocalizations(const Locale('en'));
  final gu = lookupAppLocalizations(const Locale('gu'));

  HomeGlance glance({
    DateTime? date,
    GlanceBudget? budget,
    bool expense = true,
    bool habits = true,
  }) => HomeGlance(
    date: date ?? DateTime(2026, 10, 21),
    spend: expense
        ? GlanceSpend(
            todayMinor: 125000,
            currencyCode: 'INR',
            monthStart: DateTime(2026, 10),
            budget: budget,
          )
        : null,
    habits: habits
        ? const GlanceHabits(
            scheduled: 5,
            done: 1,
            items: [
              GlanceHabit(
                id: 'h1',
                name: 'Meditate',
                kind: GlanceHabitKind.yesNo,
                value: 1,
                target: 1,
                colorHex: '#2B7ACA',
              ),
              GlanceHabit(
                id: 'h2',
                name: 'Walk',
                kind: GlanceHabitKind.yesNo,
                value: 0,
                target: 1,
                colorHex: '#1D8B39',
              ),
              GlanceHabit(
                id: 'h3',
                name: 'Read',
                kind: GlanceHabitKind.count,
                value: 12,
                target: 20,
                colorHex: '#D74242',
                unit: 'pages',
              ),
            ],
          )
        : null,
  );

  Map<String, Object?> decode(
    HomeGlance? today, {
    HomeGlance? next,
    bool hidden = false,
    AppLocalizations? l10n,
  }) => jsonDecode(
    encodeWidgetPayload(
      today,
      next,
      hidden: hidden,
      l10n: l10n ?? en,
      locale: (l10n ?? en).localeName,
    ),
  ) as Map<String, Object?>;

  test('v1 with mode, open label, and the today and next blocks', () {
    final p = decode(glance(), next: glance(date: DateTime(2026, 10, 22)));
    expect(at(p, ['v']), 1);
    expect(at(p, ['mode']), 'data');
    expect(at(p, ['openLabel']), 'Open DailyTrack');
    expect(at(p, ['today', 'dateKey']), '2026-10-21');
    expect(at(p, ['next', 'dateKey']), '2026-10-22');
  });

  test('spend is formatted with the currency, with an a11y text', () {
    final spend = at(decode(glance()), ['today', 'spend']);
    expect(at(spend, ['label']), 'Spent today');
    expect(at(spend, ['amount']), '₹1,250.00');
    expect(at(spend, ['a11y']), 'Spent today, ₹1,250.00');
  });

  test('the budget states the percent in words and its level', () {
    final budget = at(
      decode(
        glance(
          budget: const GlanceBudget(limitMinor: 1000000, spentMinor: 620000),
        ),
      ),
      ['today', 'budget'],
    );
    expect(at(budget, ['label']), 'October budget');
    expect(at(budget, ['percent']), 62);
    expect(at(budget, ['text']), '62% used · ₹6,200.00 of ₹10,000.00');
    expect(at(budget, ['level']), 'under');
    final over = at(
      decode(
        glance(
          budget: const GlanceBudget(limitMinor: 100000, spentMinor: 120000),
        ),
      ),
      ['today', 'budget'],
    );
    expect(at(over, ['level']), 'over');
  });

  test('no Overall budget → "No budget set"', () {
    expect(at(decode(glance()), ['today', 'budget']), {
      'none': 'No budget set',
    });
  });

  test('habits with progress for count habits and a11y strings', () {
    final habits = at(decode(glance()), ['today', 'habits'])! as List<Object?>;
    expect(habits, hasLength(3));
    expect(at(habits, [0]), {
      'id': 'h1',
      'name': 'Meditate',
      'kind': 'yesNo',
      'done': true,
      'progress': null,
      'colorHex': '#2B7ACA',
      'a11y': 'Meditate, done',
    });
    expect(at(habits, [1, 'a11y']), 'Walk, not done. Double tap to mark done');
    expect(at(habits, [2, 'progress']), '12 / 20 pages');
    expect(
      at(habits, [2, 'a11y']),
      'Read, 12 / 20 pages. Double tap to add one',
    );
  });

  test('FR-048 Expense disabled → no spend or budget; Habit disabled → no '
      'habits', () {
    final noExpense = at(decode(glance(expense: false)), ['today']);
    expect(at(noExpense, ['spend']), isNull);
    expect(at(noExpense, ['budget']), isNull);
    expect(at(decode(glance(habits: false)), ['today', 'habits']), isEmpty);
  });

  test('FR-047 hidden: only the open label', () {
    final p = decode(glance(), next: glance(), hidden: true);
    expect(at(p, ['mode']), 'hidden');
    expect(at(p, ['today']), isNull);
    expect(at(p, ['next']), isNull);
    expect(at(p, ['openLabel']), 'Open DailyTrack');
  });

  test('Gujarati text and month names', () {
    final p = decode(
      glance(
        budget: const GlanceBudget(limitMinor: 1000000, spentMinor: 620000),
      ),
      l10n: gu,
    );
    expect(at(p, ['openLabel']), 'DailyTrack ખોલો');
    expect(at(p, ['today', 'spend', 'label']), 'આજનો ખર્ચ');
    expect(at(p, ['today', 'budget', 'label']), contains('ઑક્ટોબર'));
    expect(
      at(p, ['today', 'budget', 'text']),
      '62% વપરાયું · ₹10,000.00 માંથી ₹6,200.00',
    );
  });
}
