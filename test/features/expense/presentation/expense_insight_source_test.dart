import 'dart:ui';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/expense/presentation/insights/expense_insight_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../fakes.dart';

/// ExpenseInsightSource (T040, research R4, R8). "Now" is 2026-10-14 10:00:
/// Food is +50% versus 1–14 September, and the Overall budget is on track.
void main() {
  const source = ExpenseInsightSource();

  ExpenseFakes seeded() => ExpenseFakes.withDefaults()
    ..addBudget(limit: 1000000)
    ..addTransaction(
      amount: 150000,
      category: 'food',
      at: DateTime(2026, 10, 5),
    )
    ..addTransaction(amount: 100000, category: 'food', at: DateTime(2026, 9, 3))
    // Outside the same-days window of last month: ignored.
    ..addTransaction(
      amount: 900000,
      category: 'food',
      at: DateTime(2026, 9, 20),
    );

  Future<List<Insight>> evaluate(
    ExpenseFakes f, {
    String locale = 'en',
    List<Override> overrides = const [],
  }) async {
    final container = ProviderContainer(
      overrides: [
        ...f.overrides,
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(initial: AppSettings(locale: locale)),
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingsProvider, (_, _) {});
    await container.read(appSettingsProvider.future);
    return await source.evaluate(container.read);
  }

  test('ruleIds are the documented order', () {
    expect(source.ruleIds, [
      'expense.categoryVsLastMonth',
      'expense.budgetOnTrack',
      'expense.budgetNearLimit',
    ]);
  });

  test('DSH-01 US4 localized English text, amounts, and locations', () async {
    final insights = await evaluate(seeded());
    expect(insights, [
      const Insight(
        ruleId: 'expense.categoryVsLastMonth',
        text: 'Food spending is 50% higher than last month',
        location: Routes.expenseReports,
        semanticLabel:
            'Opens reports: Food spending is 50% higher than last month',
      ),
      const Insight(
        ruleId: 'expense.budgetOnTrack',
        text: "You're on track: ₹8,500.00 left for 18 days",
        location: Routes.expenseBudgets,
        semanticLabel:
            "Opens budgets: You're on track: ₹8,500.00 left for 18 days",
      ),
    ]);
  });

  test('DSH-01 US4 localized Gujarati text', () async {
    final gu = lookupAppLocalizations(const Locale('gu'));
    final insights = await evaluate(seeded(), locale: 'gu');
    expect(insights.map((i) => i.text), [
      gu.expense_insightCategoryHigher(gu.expense_cat_food, 50),
      gu.expense_insightBudgetOnTrack('₹8,500.00', 18),
    ]);
  });

  test('a budget near or over its limit points to EXP-08', () async {
    final over = ExpenseFakes.withDefaults()
      ..addBudget(limit: 10000)
      ..addTransaction(amount: 10500, category: 'food');
    final [insight] = await evaluate(over);
    expect(insight.ruleId, 'expense.budgetNearLimit');
    expect(
      insight.text,
      "You're ₹5.00 over this month's budget. A no-spend day helps.",
    );
    expect(insight.location, Routes.expenseBudgets);
  });

  test('a failing input is skipped; the other rules still return', () async {
    final f = seeded();
    f.transactions.failBreakdown = StateError('breakdown failed');
    final insights = await evaluate(f);
    expect(insights.map((i) => i.ruleId), ['expense.budgetOnTrack']);
  });

  test('at most one insight per rule id', () async {
    final f = seeded()
      ..addTransaction(amount: 300000, category: 'transport')
      ..addTransaction(
        amount: 100000,
        category: 'transport',
        at: DateTime(2026, 9, 2),
      );
    final ids = [for (final i in await evaluate(f)) i.ruleId];
    expect(ids.toSet(), hasLength(ids.length));
  });
}
