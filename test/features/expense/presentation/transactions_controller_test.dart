import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transactions_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-01 controller intents (T066, contracts/screens.md).
void main() {
  late ExpenseFakes f;
  late ProviderContainer container;

  TransactionsState state() => container.read(transactionsControllerProvider);
  TransactionsController controller() =>
      container.read(transactionsControllerProvider.notifier);

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
  }

  setUp(() async {
    f = ExpenseFakes.withDefaults();
    for (var i = 0; i < 70; i++) {
      f.addTransaction(
        amount: 100 + i,
        category: i.isEven ? 'food' : 'transport',
        at: DateTime(2026, 10, 1 + i % 13, 9),
      );
    }
    container = ProviderContainer(overrides: f.overrides);
    addTearDown(container.dispose);
    container.listen(transactionsControllerProvider, (_, _) {});
    await settle();
  });

  test('starts on the current month with the first page', () {
    expect(state().query.period, MonthPeriod(fakeNow));
    expect(state().pageCount, 1);
    expect(state().rows.value, hasLength(TransactionsState.pageSize));
    expect(state().hasMore, isTrue);
    expect(state().categories, hasLength(17));
  });

  test('loadMore grows the window; setPeriod and resetPaging go back to '
      'page 1', () async {
    controller().loadMore();
    await settle();
    expect(state().pageCount, 2);
    expect(state().rows.value, hasLength(70));
    expect(state().hasMore, isFalse);

    controller().loadMore();
    expect(state().pageCount, 2, reason: 'no more rows to load');

    controller().resetPaging();
    await settle();
    expect(state().pageCount, 1);

    controller()
      ..loadMore()
      ..setPeriod(MonthPeriod(DateTime(2026, 9)));
    await settle();
    expect(state().pageCount, 1);
    expect(state().rows.value, isEmpty);
  });

  test('setSearch waits for the debounce and matches localized category '
      'names', () async {
    controller().setSearch(
      'Khana',
      displayName: (c) => c.id == 'food' ? 'Khana' : c.name,
    );
    expect(state().searchText, 'Khana');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(state().query.search, '', reason: 'still inside the 300 ms');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(state().query.search, 'Khana');
    expect(state().query.matchingCategoryIds, {'food'});
  });

  test('closing search clears it', () async {
    controller().setSearchOpen(open: true);
    controller().setSearch('x', displayName: (c) => c.name);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(state().query.search, 'x');
    controller().setSearchOpen(open: false);
    expect(state().searchOpen, isFalse);
    expect(state().query.search, '');
    expect(state().searchText, '');
  });

  test('applyRouteAccount filters to one account', () {
    controller().applyRouteAccount('cash');
    expect(state().query.accountIds, {'cash'});
  });

  test('delete hides the row at once and its undo brings it back', () async {
    final id = state().rows.value!.first.transaction.id;
    final undo = await controller().delete(id);
    expect(
      state().visibleRows!.map((v) => v.transaction.id),
      isNot(contains(id)),
    );
    await settle();
    expect(f.active.map((t) => t.id), isNot(contains(id)));

    await undo!();
    await settle();
    expect(state().visibleRows!.first.transaction.id, id);
  });

  test('a failed delete keeps the row', () async {
    final id = state().rows.value!.first.transaction.id;
    f.world.failNextWrite = true;
    expect(await controller().delete(id), isNull);
    expect(state().visibleRows!.first.transaction.id, id);
  });

  test('the controller is kept alive, so the query survives listeners '
      'going away', () async {
    controller().applyFilters(
      types: {TxnType.income},
      paymentModes: const {},
      categoryIds: const {},
      accountIds: const {},
      minAmountMinor: null,
      maxAmountMinor: null,
    );
    container.listen(transactionsControllerProvider, (_, _) {}).close();
    await settle();
    expect(state().query.types, {TxnType.income});
  });
}
