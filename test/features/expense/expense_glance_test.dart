import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import 'fakes.dart';

/// ExpenseModule.contributeGlance (feature 008 T018, research R19).
void main() {
  const module = ExpenseModule();
  final now = DateTime(2026, 10, 21, 12);

  Future<HomeGlance> glanceFor(ExpenseFakes f, DateTime at) async {
    final c = ProviderContainer(
      overrides: [
        ...f.overrides,
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            initial: const AppSettings(currencyCode: 'USD'),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    final b = GlanceBuilder(DateTime(at.year, at.month, at.day));
    await module.contributeGlance(b, c.read, at);
    return b.build();
  }

  test(
    "today's expenses, the currency, and the month's Overall budget",
    () async {
      final f = ExpenseFakes.withDefaults(now: now)
        ..addTransaction(
          amount: 125000,
          category: 'food',
          at: DateTime(2026, 10, 21, 9),
        )
        ..addTransaction(
          amount: 495000,
          category: 'rent',
          at: DateTime(2026, 10, 2, 9),
        )
        ..addTransaction(
          amount: 999900,
          type: TxnType.income,
          category: 'income_salary',
          at: DateTime(2026, 10, 21, 8),
        )
        ..addBudget(limit: 1000000);
      final g = await glanceFor(f, now);
      final spend = g.spend!;
      expect(spend.todayMinor, 125000);
      expect(spend.currencyCode, 'USD');
      expect(spend.monthStart, DateTime(2026, 10));
      expect(spend.budget!.spentMinor, 620000);
      expect(spend.budget!.limitMinor, 1000000);
      expect(spend.budget!.percent, 62);
    },
  );

  test('no Overall budget → budget null', () async {
    final f = ExpenseFakes.withDefaults(now: now)
      ..addBudget(limit: 50000, category: 'food');
    expect((await glanceFor(f, now)).spend!.budget, isNull);
  });

  test("tomorrow's block starts at 0 spent", () async {
    final f = ExpenseFakes.withDefaults(now: now)
      ..addTransaction(
        amount: 125000,
        category: 'food',
        at: DateTime(2026, 10, 21, 9),
      );
    final g = await glanceFor(f, DateTime(2026, 10, 22));
    expect(g.spend!.todayMinor, 0);
  });
}
