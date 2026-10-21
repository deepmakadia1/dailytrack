import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budgets_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-08 controller (T032, contracts/screens.md) over fake repositories.
void main() {
  late ExpenseFakes f;
  late ProviderContainer c;

  setUp(() {
    f = ExpenseFakes.withDefaults();
    c = ProviderContainer(overrides: f.overrides);
    addTearDown(c.dispose);
  });

  Future<BudgetsState> settle(String? month) async {
    final provider = budgetsControllerProvider(month);
    c.listen(provider, (_, _) {});
    await pumpEventQueue();
    final state = c.read(provider);
    return state;
  }

  test('defaults to the current month', () async {
    final s = await settle(null);
    expect(s.monthKey, '2026-10');
    expect(s.overview.value, isA<BudgetsOverview>());
  });

  test('opens the month argument; a malformed one falls back', () async {
    expect((await settle('2026-09')).monthKey, '2026-09');
    expect((await settle('2026-9')).monthKey, '2026-10');
  });

  test('previousMonth and nextMonth move and reload', () async {
    f.addBudget(limit: 5000, month: '2026-09');
    final provider = budgetsControllerProvider(null);
    await settle(null);
    c.read(provider.notifier).previousMonth();
    await pumpEventQueue();
    var s = c.read(provider);
    expect(s.monthKey, '2026-09');
    expect(s.overview.value!.overall!.budget.limitMinor, 5000);
    c.read(provider.notifier)
      ..nextMonth()
      ..nextMonth();
    await pumpEventQueue();
    s = c.read(provider);
    expect(s.monthKey, '2026-11');
    expect(s.overview.value!.isEmpty, isTrue);
  });

  test('copyLastMonth returns the number copied', () async {
    f
      ..addBudget(limit: 5000, month: '2026-09')
      ..addBudget(limit: 700, category: 'food', month: '2026-09');
    await settle(null);
    final n = c.read(budgetsControllerProvider(null).notifier);
    expect(await n.copyLastMonth(), 2);
    expect(await n.copyLastMonth(), 0);
  });

  test('copyLastMonth reports a failed write as null', () async {
    await settle(null);
    f.world.failNextWrite = true;
    expect(
      await c.read(budgetsControllerProvider(null).notifier).copyLastMonth(),
      isNull,
    );
  });

  test('deleteBudget returns an Undo that calls undelete', () async {
    final b = f.addBudget(limit: 5000, category: 'food');
    await settle(null);
    final n = c.read(budgetsControllerProvider(null).notifier);
    final undo = await n.deleteBudget(b.id);
    await pumpEventQueue();
    expect(
      c.read(budgetsControllerProvider(null)).overview.value!.isEmpty,
      isTrue,
    );
    expect(await undo!(), isTrue);
    expect(f.budgets.calls['undelete'], 1);
    await pumpEventQueue();
    expect(
      c.read(budgetsControllerProvider(null)).overview.value!.categories,
      hasLength(1),
    );
  });

  test('Undo reports false when the slot was filled meanwhile', () async {
    final b = f.addBudget(limit: 5000, category: 'food');
    await settle(null);
    final undo = await c
        .read(budgetsControllerProvider(null).notifier)
        .deleteBudget(b.id);
    f.addBudget(limit: 9000, category: 'food');
    expect(await undo!(), isFalse);
  });

  test('a load error shows the error state, and retry reloads', () async {
    f.world.failWatch = StateError('db');
    var s = await settle(null);
    expect(s.overview, isA<AsyncError<BudgetsOverview>>());
    f.world.failWatch = null;
    c.read(budgetsControllerProvider(null).notifier).retry();
    await pumpEventQueue();
    s = c.read(budgetsControllerProvider(null));
    expect(s.overview.value, isA<BudgetsOverview>());
  });
}
