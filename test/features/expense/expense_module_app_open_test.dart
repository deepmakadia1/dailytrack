import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import '../../helpers/real_container.dart';
import 'fakes.dart';

/// ExpenseModule.onAppOpen runs budget rollover (T041, FR-013) on a real
/// database: the first open of November creates October's repeating
/// budgets, once.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('EXP-08 US1-9 the first app open of a new month rolls budgets over '
      'once', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = MutableClock(DateTime(2026, 10, 20, 9));
    final c = makeRealContainer(
      db,
      overrides: [
        clockProvider.overrideWithValue(clock),
        budgetRepositoryProvider.overrideWith(
          (ref) => DriftBudgetRepository(
            db,
            ref.watch(clockProvider),
            ref.watch(settingsRepositoryProvider),
          ),
        ),
      ],
    );
    final repo = c.read(budgetRepositoryProvider);
    await repo.create(
      const BudgetDraft(
        monthKey: '2026-10',
        limitMinor: 3000000,
        rollover: true,
      ),
    );
    const module = ExpenseModule();
    await module.onAppOpen(c.read);
    expect(
      (await repo.watchOverview('2026-10').first).overall,
      isNotNull,
      reason: 'October itself is untouched',
    );

    clock.value = DateTime(2026, 11, 1, 7);
    await module.onAppOpen(c.read);
    final nov = await repo.watchOverview('2026-11').first;
    expect(nov.overall!.budget.limitMinor, 3000000);

    // Deleting it and opening again the same month does not bring it back.
    await repo.softDelete(nov.overall!.budget.id);
    await module.onAppOpen(c.read);
    expect((await repo.watchOverview('2026-11').first).overall, isNull);
  });

  test('a failing rollover never throws from onAppOpen', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final c = makeRealContainer(db);
    // budgetRepositoryProvider is not bound here, so reading it throws.
    await const ExpenseModule().onAppOpen(c.read);
  });

  test(
    'FR-043 onDisable cancels shown budget alerts and keeps the data',
    () async {
      final f = ExpenseFakes.withDefaults()..addBudget(limit: 1000);
      final c = ProviderContainer(overrides: f.overrides);
      addTearDown(c.dispose);
      await const ExpenseModule().onDisable(c.read);
      expect(f.alertNotifier.cancelAllCalls, 1);
      expect(f.world.budgets, hasLength(1));
    },
  );
}
