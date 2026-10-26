import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/domain/native_ad_slots.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/period_picker_sheet.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/presentation/controllers/receipt_prune_controller.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transactions_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/day_header.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/filter_chips.dart';
import 'package:dailytrack/features/expense/presentation/widgets/summary_strip.dart';
import 'package:dailytrack/features/expense/presentation/widgets/transaction_filter_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EXP-01 Transactions list, the Expenses tab (spec §8, contracts/
/// screens.md, research R4 and R6): period selector, exact summary strip,
/// filter chips, and rows grouped under sticky day headers, with the
/// bottom banner and native ads after row 8, then every 15 rows (spec §11).
class TransactionsScreen extends ConsumerStatefulWidget {
  const new({super.key, this.accountId});

  /// From `/expenses?accountId=` (EXP-06 tap), applied once on arrival.
  final String? accountId;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  var _fabVisible = true;

  TransactionsController get _controller =>
      ref.read(transactionsControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(receiptPruneProvider.future));
    _search.text = ref.read(transactionsControllerProvider).searchText;
    _scroll.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.resetPaging();
      _applyRouteAccount();
    });
  }

  @override
  void didUpdateWidget(TransactionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accountId != oldWidget.accountId) {
      // Providers may not change while the tree builds (EXP-06 → EXP-01).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyRouteAccount();
      });
    }
  }

  void _applyRouteAccount() {
    if (widget.accountId case final id?) _controller.applyRouteAccount(id);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  /// Loads the next page within about 10 rows of the end (FR-021).
  void _maybeLoadMore() {
    final extent = MediaQuery.textScalerOf(context).scale(transactionRowHeight);
    if (_scroll.position.extentAfter < extent * 10) _controller.loadMore();
  }

  /// §15.3: the FAB hides while scrolling down and returns on scroll up.
  bool _onUserScroll(UserScrollNotification n) {
    final visible = switch (n.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _fabVisible,
    };
    if (visible != _fabVisible) setState(() => _fabVisible = visible);
    return false;
  }

  Future<void> _delete(String id) async {
    final l10n = AppLocalizations.of(context);
    final undo = await _controller.delete(id);
    if (undo == null || !mounted) return;
    UndoSnackBar.show(
      context,
      message: l10n.expense_deleted,
      onUndo: () => unawaited(undo()),
    );
  }

  void _duplicate(String id) =>
      unawaited(context.push(Routes.expenseAddPath(duplicateOf: id)));

  Future<void> _rowMenu(TransactionView view) async {
    final l10n = AppLocalizations.of(context);
    final id = view.transaction.id;
    final action = await AppBottomSheet.show<String>(
      context,
      title: l10n.expense_detailTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('row_menu_duplicate'),
            leading: const Icon(Icons.copy_outlined),
            title: Text(l10n.expense_duplicate),
            onTap: () => Navigator.of(context).pop('duplicate'),
          ),
          ListTile(
            key: const Key('row_menu_delete'),
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(l10n.expense_delete),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
    switch (action) {
      case 'duplicate':
        _duplicate(id);
      case 'delete':
        await _delete(id);
    }
  }

  Future<void> _openFilters(TransactionsState state) async {
    final result = await TransactionFilterSheet.show(
      context,
      query: state.query,
      categories: state.categories.values.toList(),
      accounts: state.accounts.values.toList(),
      currency: currencyCodeOf(ref),
    );
    if (result == null) return;
    _controller.applyFilters(
      types: result.types,
      paymentModes: result.paymentModes,
      categoryIds: result.categoryIds,
      accountIds: result.accountIds,
      minAmountMinor: result.minAmountMinor,
      maxAmountMinor: result.maxAmountMinor,
    );
  }

  Future<void> _pickPeriod(TransactionsState state) async {
    final settings = ref.read(appSettingsProvider).value;
    final picked = await PeriodPickerSheet.show(
      context,
      current: state.query.period,
      firstDayOfWeek: settings?.firstDayOfWeek ?? 1,
      now: ref.read(clockProvider).now(),
    );
    if (picked != null) _controller.setPeriod(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final state = ref.watch(transactionsControllerProvider);
    final currency = currencyCodeOf(ref);
    final now = ref.watch(clockProvider).now();

    final rows = state.visibleRows;
    final error = state.rows.hasError && rows == null
        ? state.rows.error
        : (state.ledger.hasError ? state.ledger.error : null);
    final ledger = state.ledger.value;

    final slivers = <Widget>[
      if (state.searchOpen)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: tokens.s8),
            child: TextField(
              key: const Key('search_field'),
              controller: _search,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (text) =>
                  _controller.setSearch(text, displayName: l10n.categoryName),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.expense_search,
                suffixIcon: IconButton(
                  tooltip: l10n.expense_closeSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    _controller.setSearchOpen(open: false);
                  },
                ),
              ),
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: PeriodSelector(
          key: const Key('period_selector'),
          period: state.query.period,
          now: now,
          onChanged: _controller.setPeriod,
          onPick: () => unawaited(_pickPeriod(state)),
        ),
      ),
      if (ledger != null)
        SliverToBoxAdapter(
          child: SummaryStrip(ledger: ledger, currency: currency),
        ),
      if (state.query.chips.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: tokens.s8),
            child: FilterChips(
              query: state.query,
              categories: state.categories,
              accounts: state.accounts,
              currency: currency,
              onRemove: _controller.removeFilter,
            ),
          ),
        ),
      if (error != null)
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            message: l10n.expense_loadError,
            onRetry: _controller.retry,
          ),
        )
      else if (rows == null)
        const SliverToBoxAdapter(child: DelayedSkeleton(child: SkeletonList()))
      else if (rows.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: state.query.isFiltered
              ? EmptyState(
                  key: const Key('no_matches'),
                  title: l10n.expense_noMatches,
                  actionLabel: l10n.expense_clearFilters,
                  onAction: () {
                    _search.clear();
                    _controller.clearFilters();
                  },
                )
              : EmptyState(
                  key: const Key('empty_period'),
                  illustration: Icon(
                    Icons.receipt_long_outlined,
                    size: tokens.s48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: l10n.expense_emptyPeriod(
                    state.query.period.label(
                      l10n.localeName,
                      RelativeDayLabels(
                        today: l10n.common_today,
                        yesterday: l10n.common_yesterday,
                      ),
                      now: now,
                      fullDatePattern: FullDateFormatScope.of(context).pattern,
                    ),
                  ),
                  actionLabel: l10n.expense_addExpense,
                  onAction: () =>
                      unawaited(context.push(Routes.expenseAddPath())),
                ),
        )
      else
        ..._dayGroups(
          rows: rows,
          ledger: ledger ?? const PeriodLedger(),
          now: now,
          currency: currency,
        ),
      SliverToBoxAdapter(child: SizedBox(height: tokens.s48 + tokens.s48)),
    ];

    return AppScaffold(
      title: l10n.expense_listTitle,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      largeTitle: true,
      showBack: false,
      actions: [
        IconButton(
          key: const Key('open_search'),
          tooltip: l10n.expense_search,
          icon: const Icon(Icons.search),
          onPressed: () => _controller.setSearchOpen(open: !state.searchOpen),
        ),
        IconButton(
          key: const Key('open_filters'),
          tooltip: l10n.expense_filter,
          icon: const Icon(Icons.filter_list),
          onPressed: () => unawaited(_openFilters(state)),
        ),
        PopupMenuButton<String>(
          key: const Key('expenses_overflow'),
          onSelected: (path) => unawaited(context.push(path)),
          itemBuilder: (context) => [
            PopupMenuItem(
              key: const Key('menu_categories'),
              value: Routes.expenseCategories,
              child: Text(l10n.expense_menuCategories),
            ),
            PopupMenuItem(
              key: const Key('menu_accounts'),
              value: Routes.expenseAccounts,
              child: Text(l10n.expense_menuAccounts),
            ),
            PopupMenuItem(
              key: const Key('menu_budgets'),
              value: Routes.expenseBudgets,
              child: Text(l10n.expense_menuBudgets),
            ),
            PopupMenuItem(
              key: const Key('menu_recurring'),
              value: Routes.expenseRecurring,
              child: Text(l10n.expense_menuRecurring),
            ),
            PopupMenuItem(
              key: const Key('menu_reports'),
              value: Routes.expenseReports,
              child: Text(l10n.expense_menuReports),
            ),
          ],
        ),
      ],
      // §15.1: one primary action. An empty state brings its own button, so
      // the FAB steps aside while it shows.
      fab: _fabVisible && (rows == null || rows.isNotEmpty)
          ? FloatingActionButton(
              key: const Key('add_transaction'),
              tooltip: l10n.expense_addExpense,
              onPressed: () => unawaited(
                context.push(Routes.expenseAddPath(type: 'expense')),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onUserScroll,
        child: CustomScrollView(
          key: const Key('transactions_list'),
          controller: _scroll,
          slivers: slivers,
        ),
      ),
    );
  }

  /// One sliver group per local day: a pinned header and fixed-extent rows
  /// (research R6), so 10,000 rows scroll smoothly. Native ads go after row
  /// 8, then every 15 rows, at most 3 per load (spec §11); a day holding an
  /// ad is split into two fixed-extent lists around it (feature 009 R8).
  List<Widget> _dayGroups({
    required List<TransactionView> rows,
    required PeriodLedger ledger,
    required DateTime now,
    required String currency,
  }) {
    final groups = <String, List<TransactionView>>{};
    for (final v in rows) {
      final key = DateKeys.fromLocal(v.transaction.occurredAt.toLocal());
      (groups[key] ??= []).add(v);
    }
    final extent = MediaQuery.textScalerOf(context).scale(transactionRowHeight);
    // Global row indexes an ad goes in front of.
    final adSlots = nativeAdRowIndexes(rows.length);
    var start = 0;
    var adNumber = 0;
    final slivers = <Widget>[];
    for (final MapEntry(key: dayKey, value: dayRows) in groups.entries) {
      final end = start + dayRows.length;
      // Ads that fall inside this day, or right after its last row.
      final cuts = [
        for (final s in adSlots)
          if (s > start && s <= end) s - start,
      ];
      final parts = <Widget>[];
      var from = 0;
      for (final cut in cuts) {
        parts
          ..add(_rowList(dayRows.sublist(from, cut), extent, currency))
          ..add(
            SliverToBoxAdapter(
              child: AppNativeAd(
                key: Key('transactions_native_${adNumber++}'),
                placement: NativePlacement.transactions,
              ),
            ),
          );
        from = cut;
      }
      if (from < dayRows.length) {
        parts.add(_rowList(dayRows.sublist(from), extent, currency));
      }
      slivers.add(
        SliverMainAxisGroup(
          key: ValueKey('day_$dayKey'),
          slivers: [
            PinnedHeaderSliver(
              child: DayHeader(
                day: DateKeys.parse(dayKey),
                total: ledger.dayTotals[dayKey] ?? const DayTotal(),
                now: now,
                currency: currency,
              ),
            ),
            ...parts,
          ],
        ),
      );
      start = end;
    }
    return slivers;
  }

  Widget _rowList(List<TransactionView> rows, double extent, String currency) =>
      SliverFixedExtentList.builder(
        itemExtent: extent,
        itemCount: rows.length,
        itemBuilder: (context, i) => _dismissible(rows[i], currency),
      );

  /// Swipe left deletes with Undo (no dialog); swipe right duplicates
  /// (§15.5). Both are also in the long-press menu.
  Widget _dismissible(TransactionView view, String currency) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final id = view.transaction.id;

    Widget background(
      Alignment align,
      IconData icon,
      Color color,
      String text,
    ) => ColoredBox(
      color: color,
      child: Align(
        alignment: align,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.s16),
          child: Icon(icon, color: scheme.onError, semanticLabel: text),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('row_$id'),
      background: background(
        Alignment.centerLeft,
        Icons.copy_outlined,
        scheme.primary,
        l10n.expense_duplicate,
      ),
      secondaryBackground: background(
        Alignment.centerRight,
        Icons.delete_outline,
        scheme.error,
        l10n.expense_delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _duplicate(id);
          return false;
        }
        return true;
      },
      onDismissed: (_) => unawaited(_delete(id)),
      child: TransactionRow(
        key: ValueKey('txn_$id'),
        view: view,
        currency: currency,
        onTap: () => unawaited(context.push(Routes.expenseDetailPath(id))),
        onLongPress: () => unawaited(_rowMenu(view)),
      ),
    );
  }
}
