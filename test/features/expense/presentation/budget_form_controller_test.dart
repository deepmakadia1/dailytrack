import 'package:dailytrack/features/expense/domain/usecases/validate_budget.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budget_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-09 controller (T034, contracts/screens.md) over fake repositories.
void main() {
  late ExpenseFakes f;
  late ProviderContainer c;

  setUp(() {
    f = ExpenseFakes.withDefaults();
    c = ProviderContainer(overrides: f.overrides);
    addTearDown(c.dispose);
  });

  Future<BudgetFormController> open(BudgetFormArgs args) async {
    final provider = budgetFormControllerProvider(args);
    c.listen(provider, (_, _) {});
    await pumpEventQueue();
    final notifier = c.read(provider.notifier);
    return notifier;
  }

  BudgetFormState stateOf(BudgetFormArgs args) =>
      c.read(budgetFormControllerProvider(args));

  void type(BudgetFormController n, String digits) =>
      digits.split('').forEach(n.key);

  const october = BudgetFormArgs(monthKey: '2026-10');

  test(
    'new: Overall plus categories without a budget, preselected slot',
    () async {
      f.addBudget(limit: 1000, category: 'food');
      await open(const BudgetFormArgs(monthKey: '2026-10', categoryId: 'rent'));
      final s = stateOf(
        const BudgetFormArgs(monthKey: '2026-10', categoryId: 'rent'),
      );
      expect(s.status, BudgetFormStatus.ready);
      expect(s.availableSlots.first.categoryId, isNull, reason: 'Overall');
      expect(
        s.availableSlots.map((x) => x.categoryId),
        isNot(contains('food')),
      );
      expect(s.slot.categoryId, 'rent');
      expect(s.keypadOpen, isTrue);
    },
  );

  test('Overall is not offered when it already has a budget', () async {
    f.addBudget(limit: 1000);
    await open(october);
    expect(stateOf(october).availableSlots.map((x) => x.categoryId), [
      for (final id in [
        'food',
        'groceries',
        'transport',
        'fuel',
        'shopping',
        'bills',
        'rent',
        'health',
        'education',
        'entertainment',
        'travel',
        'other',
      ])
        id,
    ]);
  });

  test('save creates the budget for the sheet month', () async {
    final n = await open(october);
    type(n, '6000');
    n.toggleRollover();
    final saved = await n.save();
    expect(saved!.limitMinor, 600000);
    expect(saved.monthKey, '2026-10');
    expect(saved.categoryId, isNull);
    expect(saved.rollover, isFalse);
  });

  test('empty, zero and too large amounts are rejected inline', () async {
    final n = await open(october);
    expect(await n.save(), isNull);
    expect(stateOf(october).errors, {BudgetError.amountMissing});
    type(n, '0');
    expect(await n.save(), isNull);
    expect(stateOf(october).errors, {BudgetError.amountMissing});
    n.backspace();
    type(n, '1000000000');
    expect(await n.save(), isNull);
    expect(stateOf(october).errors, {BudgetError.amountTooLarge});
    expect(f.budgets.calls['create'], isNull);
  });

  test('edit: fixed category, prefilled, update keeps the slot', () async {
    final b = f.addBudget(limit: 250050, category: 'food', rollover: false);
    final args = BudgetFormArgs(monthKey: '2026-10', budgetId: b.id);
    final n = await open(args);
    final s = stateOf(args);
    expect(s.isEdit, isTrue);
    expect(s.slot.categoryId, 'food');
    expect(s.availableSlots, hasLength(1));
    expect(s.expression, '2500.50');
    expect(s.rollover, isFalse);
    n
      ..selectSlot(s.availableSlots.single)
      ..backspace()
      ..backspace()
      ..backspace();
    final saved = await n.save();
    expect(saved!.limitMinor, 250000);
    expect(saved.categoryId, 'food');
    expect(f.budgets.calls['update'], 1);
  });

  test('a slot taken meanwhile shows the slot error', () async {
    final n = await open(october);
    f.addBudget(limit: 1);
    type(n, '100');
    expect(await n.save(), isNull);
    expect(stateOf(october).errors, contains(BudgetError.slotTaken));
  });

  test('a failed save keeps the input and flags it', () async {
    final n = await open(october);
    type(n, '100');
    f.world.failNextWrite = true;
    expect(await n.save(), isNull);
    final s = stateOf(october);
    expect(s.saveFailed, isTrue);
    expect(s.expression, '100');
    expect(await n.save(), isNotNull, reason: 'a retry works');
  });

  test('delete returns an Undo', () async {
    final b = f.addBudget(limit: 1000, category: 'food');
    final args = BudgetFormArgs(monthKey: '2026-10', budgetId: b.id);
    final n = await open(args);
    final undo = await n.delete();
    expect(f.world.deletedBudgets, contains(b.id));
    expect(await undo!(), isTrue);
    expect(f.world.deletedBudgets, isEmpty);
  });

  test('a missing budget is a load error', () async {
    const args = BudgetFormArgs(monthKey: '2026-10', budgetId: 'nope');
    await open(args);
    expect(stateOf(args).status, BudgetFormStatus.loadError);
  });
}
