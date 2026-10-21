import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_query_ops.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transactions_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/transaction_query_ops.dart';
export 'package:dailytrack/features/expense/presentation/controllers/transactions_state.dart';

part 'transactions_controller.g.dart';

/// EXP-01 Transactions list (T071, contracts/screens.md). The screen's only
/// notifier. Kept alive so the session filter survives tab switches and
/// navigation, and resets when the app restarts (FR-020).
@Riverpod(keepAlive: true)
class TransactionsController extends _$TransactionsController {
  StreamSubscription<Object?>? _rows;
  StreamSubscription<Object?>? _ledger;
  StreamSubscription<Object?>? _categories;
  StreamSubscription<Object?>? _accounts;
  Timer? _searchDebounce;

  static const Duration searchDebounce = Duration(milliseconds: 300);

  @override
  TransactionsState build() {
    ref.onDispose(() {
      unawaited(_rows?.cancel());
      unawaited(_ledger?.cancel());
      unawaited(_categories?.cancel());
      unawaited(_accounts?.cancel());
      _searchDebounce?.cancel();
    });
    final query = TxnQuery(period: MonthPeriod(ref.read(clockProvider).now()));
    _categories = ref
        .read(categoryRepositoryProvider)
        .watchAll()
        .listen(
          (list) => state = state.copyWith(
            categories: {for (final c in list) c.id: c},
          ),
          onError: (Object _) {},
        );
    _accounts = ref
        .read(accountRepositoryProvider)
        .watchAllWithBalances()
        .listen(
          (list) => state = state.copyWith(
            accounts: {for (final a in list) a.account.id: a.account},
          ),
          onError: (Object _) {},
        );
    _subscribe(query, 1);
    return TransactionsState(
      query: query,
      rows: const AsyncLoading(),
      ledger: const AsyncLoading(),
    );
  }

  /// (Re)subscribes the page and ledger streams. Previous rows stay on
  /// screen until the new ones arrive, so changing a filter never flashes.
  void _subscribe(TxnQuery query, int pageCount) {
    final repo = ref.read(transactionRepositoryProvider);
    unawaited(_rows?.cancel());
    unawaited(_ledger?.cancel());
    _rows = repo
        .watchPage(query, limit: pageCount * TransactionsState.pageSize)
        .listen(
          (rows) => state = state.copyWith(rows: AsyncData(rows)),
          onError: (Object e, StackTrace st) =>
              state = state.copyWith(rows: AsyncError(e, st)),
        );
    _ledger = repo
        .watchLedger(query)
        .listen(
          (ledger) => state = state.copyWith(ledger: AsyncData(ledger)),
          onError: (Object e, StackTrace st) =>
              state = state.copyWith(ledger: AsyncError(e, st)),
        );
  }

  /// A new query always starts again at the first page.
  void _setQuery(TxnQuery query) {
    state = state.copyWith(query: query, pageCount: 1);
    _subscribe(query, 1);
  }

  void setPeriod(Period period) => _setQuery(state.query.withPeriod(period));

  void setSearchOpen({required bool open}) {
    state = state.copyWith(searchOpen: open);
    if (!open && state.query.hasSearch) {
      state = state.copyWith(searchText: '');
      _setQuery(state.query.withSearch('', const {}));
    }
  }

  /// Updates the field now and the query after 300 ms. [displayName] gives a
  /// category's name in the current language, so default categories match
  /// by their translated name (research R5).
  void setSearch(
    String text, {
    required String Function(Category) displayName,
  }) {
    state = state.copyWith(searchText: text);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(searchDebounce, () {
      final q = text.trim().toLowerCase();
      final matching = q.isEmpty
          ? const <String>{}
          : {
              for (final c in state.categories.values)
                if (displayName(c).toLowerCase().contains(q)) c.id,
            };
      _setQuery(state.query.withSearch(text, matching));
    });
  }

  void applyFilters({
    required Set<TxnType> types,
    required Set<PaymentMode> paymentModes,
    required Set<String> categoryIds,
    required Set<String> accountIds,
    required int? minAmountMinor,
    required int? maxAmountMinor,
  }) => _setQuery(
    state.query.applyFilters(
      types: types,
      paymentModes: paymentModes,
      categoryIds: categoryIds,
      accountIds: accountIds,
      minAmountMinor: minAmountMinor,
      maxAmountMinor: maxAmountMinor,
    ),
  );

  void removeFilter(FilterChipId chip) =>
      _setQuery(state.query.removeChip(chip));

  void clearFilters() {
    _searchDebounce?.cancel();
    state = state.copyWith(searchText: '', searchOpen: false);
    _setQuery(state.query.cleared());
  }

  /// EXP-06 tap: show only that account's transactions.
  void applyRouteAccount(String accountId) =>
      _setQuery(state.query.withRouteAccount(accountId));

  /// Called when the screen is (re)entered: back to the first page.
  void resetPaging() {
    if (state.pageCount == 1) return;
    _setQuery(state.query);
  }

  /// Grows the page window by one page when the list is full so far.
  void loadMore() {
    if (!state.hasMore) return;
    final pages = state.pageCount + 1;
    state = state.copyWith(pageCount: pages);
    _subscribe(state.query, pages);
  }

  /// Soft-deletes [id] (hidden at once) and returns its undo, or null if
  /// the delete failed (the row comes back).
  Future<Future<void> Function()?> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    state = state.copyWith(hiddenIds: {...state.hiddenIds, id});
    try {
      await repo.softDelete(id);
    } on ExpenseStorageFailure {
      if (ref.mounted) {
        state = state.copyWith(hiddenIds: {...state.hiddenIds}..remove(id));
      }
      return null;
    }
    return () async {
      if (ref.mounted) {
        state = state.copyWith(hiddenIds: {...state.hiddenIds}..remove(id));
      }
      await repo.undelete(id);
    };
  }

  /// Error state "Try again".
  void retry() {
    state = state.copyWith(
      rows: const AsyncLoading(),
      ledger: const AsyncLoading(),
    );
    _subscribe(state.query, state.pageCount);
  }
}
