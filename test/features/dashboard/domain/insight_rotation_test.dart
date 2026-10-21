import 'dart:math';

import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/features/dashboard/domain/insight_rotation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Daily insight rotation (T037, research R6, clarification Q1).
void main() {
  const order = ['expense.a', 'expense.b', 'habit.c', 'habit.d'];
  const today = '2026-10-20';
  const yesterday = '2026-10-19';

  Map<String, Insight> applies(Iterable<String> ids) => {
    for (final id in ids) id: Insight(ruleId: id, text: 'text $id'),
  };

  (String?, bool?) pick(
    Iterable<String> applicable, {
    StoredInsightPick? stored,
    String date = today,
  }) => switch (pickDailyInsight(
    today: date,
    order: order,
    applicable: applies(applicable),
    stored: stored,
  )) {
    Picked(:final insight, :final persist) => (insight.ruleId, persist),
    Starter() => (null, null),
  };

  test('DSH-01 no stored pick takes the first applicable in order and '
      'persists', () {
    expect(pick(['habit.c', 'expense.b']), ('expense.b', true));
  });

  test('same day, stored rule still applies: kept, no write', () {
    expect(
      pick([
        'expense.a',
        'habit.c',
      ], stored: const StoredInsightPick(date: today, ruleId: 'habit.c')),
      ('habit.c', false),
    );
  });

  test('same day, stored rule stopped applying: the next applicable after '
      'it, cycling, and persists', () {
    expect(
      pick([
        'expense.a',
        'expense.b',
      ], stored: const StoredInsightPick(date: today, ruleId: 'habit.c')),
      ('expense.a', true),
    );
    expect(
      pick([
        'expense.a',
        'habit.d',
      ], stored: const StoredInsightPick(date: today, ruleId: 'expense.b')),
      ('habit.d', true),
    );
  });

  test('new day: the first applicable after the stored rule, skipping it, '
      'and persists', () {
    expect(
      pick([
        'expense.a',
        'expense.b',
        'habit.c',
      ], stored: const StoredInsightPick(date: yesterday, ruleId: 'expense.b')),
      ('habit.c', true),
    );
    expect(
      pick([
        'expense.a',
        'habit.d',
      ], stored: const StoredInsightPick(date: yesterday, ruleId: 'habit.d')),
      ('expense.a', true),
    );
  });

  test('new day where only the stored rule applies returns it', () {
    expect(
      pick([
        'habit.c',
      ], stored: const StoredInsightPick(date: yesterday, ruleId: 'habit.c')),
      ('habit.c', true),
    );
  });

  test('a stored rule not in order starts from the top', () {
    expect(
      pick([
        'expense.b',
        'habit.d',
      ], stored: const StoredInsightPick(date: yesterday, ruleId: 'water.x')),
      ('expense.b', true),
    );
    expect(
      pick([
        'habit.d',
      ], stored: const StoredInsightPick(date: today, ruleId: 'water.x')),
      ('habit.d', true),
    );
  });

  test('FR-025 nothing applicable returns Starter with no write', () {
    expect(pick(const []), (null, null));
    expect(
      pickDailyInsight(
        today: today,
        order: order,
        applicable: const {},
        stored: const StoredInsightPick(date: yesterday, ruleId: 'expense.a'),
      ),
      isA<Starter>(),
    );
  });

  test('applicable rules outside the order are ignored', () {
    expect(pick(['water.x', 'habit.d']), ('habit.d', true));
  });

  test('SC-006 7 days with ≥ 2 applicable rules never repeat yesterday', () {
    final random = Random(6);
    for (var run = 0; run < 200; run++) {
      StoredInsightPick? stored;
      String? previous;
      for (var day = 0; day < 7; day++) {
        final date = '2026-10-${(10 + day).toString().padLeft(2, '0')}';
        final set = ([...order]..shuffle(random)).take(2 + random.nextInt(3));
        final result = pickDailyInsight(
          today: date,
          order: order,
          applicable: applies(set),
          stored: stored,
        );
        final picked = (result as Picked).insight.ruleId;
        expect(picked, isNot(previous), reason: 'run $run day $day');
        expect(set, contains(picked));
        // Re-opening Home on the same day keeps the pick.
        expect(
          pickDailyInsight(
            today: date,
            order: order,
            applicable: applies(set),
            stored: StoredInsightPick(date: date, ruleId: picked),
          ),
          isA<Picked>().having((p) => p.persist, 'persist', isFalse),
        );
        stored = StoredInsightPick(date: date, ruleId: picked);
        previous = picked;
      }
    }
  });
}
