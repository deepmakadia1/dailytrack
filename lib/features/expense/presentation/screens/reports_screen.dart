import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/period_picker_sheet.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/report_access.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:dailytrack/features/expense/presentation/controllers/reports_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/breakdown_bars.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/category_donut.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/income_expense_bar.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/trend_line.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

String _tabLabel(AppLocalizations l10n, ReportTab t) => switch (t) {
  ReportTab.overview => l10n.expense_reportTabOverview,
  ReportTab.categories => l10n.expense_reportTabCategories,
  ReportTab.trends => l10n.expense_reportTabTrends,
  ReportTab.accounts => l10n.expense_reportTabAccounts,
};

/// EXP-11 Reports (spec §8, FR-030–FR-036, FR-039–FR-040): a period
/// selector (Week, Month, Year, Custom; no Day) and the Overview,
/// Categories, Trends and Accounts tabs. Locked content is shown blurred
/// under `LockedFeatureOverlay` with sample data, never the user's numbers.
/// No ads (the banner slot stays empty). "Export this report" opens SET-03
/// with this period (feature 008, FR-033).
class ReportsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: ReportTab.values.length,
    vsync: this,
  )..addListener(_onTab);

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    ref
        .read(reportsControllerProvider.notifier)
        .setTab(ReportTab.values[_tabs.index]);
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTab)
      ..dispose();
    super.dispose();
  }

  Future<void> _pick(ReportsState state, DateTime now) async {
    final firstDay = ref.read(appSettingsProvider).value?.firstDayOfWeek ?? 1;
    final picked = await PeriodPickerSheet.show(
      context,
      current: state.period,
      firstDayOfWeek: firstDay,
      now: now,
      kinds: const {
        PeriodKind.week,
        PeriodKind.month,
        PeriodKind.year,
        PeriodKind.custom,
      },
      lockedKinds: state.advancedUnlocked
          ? const {}
          : const {PeriodKind.year, PeriodKind.custom},
    );
    if (picked != null && mounted) {
      ref.read(reportsControllerProvider.notifier).setPeriod(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final state = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);
    final now = ref.watch(clockProvider).now();

    return AppScaffold(
      title: l10n.expense_reportsTitle,
      actions: [
        IconButton(
          key: const Key('reports_export'),
          tooltip: l10n.export_reportAction,
          icon: Icon(Icons.ios_share, semanticLabel: l10n.export_reportAction),
          onPressed: () => unawaited(
            context.push(
              Routes.exportPath(
                dataset: 'transactions',
                period: periodToQuery(state.period),
              ),
            ),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PeriodSelector(
            key: const Key('reports_period'),
            period: state.period,
            now: now,
            onChanged: controller.setPeriod,
            onPick: () => unawaited(_pick(state, now)),
            locked: state.isTabLocked(ReportTab.overview, now),
          ),
          TabBar(
            key: const Key('reports_tabs'),
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final t in ReportTab.values)
                Tab(
                  key: ValueKey('tab_${t.name}'),
                  child: state.isTabLocked(t, now)
                      ? Semantics(
                          label: l10n.expense_reportLockedTab(
                            _tabLabel(l10n, t),
                          ),
                          excludeSemantics: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_tabLabel(l10n, t)),
                              SizedBox(width: tokens.s4),
                              Icon(
                                Icons.lock,
                                key: ValueKey('tab_lock_${t.name}'),
                                size: tokens.chipIconSize,
                              ),
                            ],
                          ),
                        )
                      : Text(_tabLabel(l10n, t)),
                ),
            ],
          ),
          SizedBox(height: tokens.s8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: state.locked
                  ? _LockedPreview(tab: state.tab)
                  : _TabBody(state: state, now: now),
            ),
          ),
        ],
      ),
    );
  }
}

/// The blurred preview of a locked tab (FR-040): sample data only, under
/// the overlay with a disabled "Get Pro" and no "Watch an ad" (feature 008).
class _LockedPreview extends StatelessWidget {
  const new({required this.tab});

  final ReportTab tab;

  static const String _sampleCurrency = 'INR';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sample = switch (tab) {
      ReportTab.trends => TrendLine(
        currencyCode: _sampleCurrency,
        vm: TrendVm(
          granularity: TrendGranularity.day,
          current: [
            for (var i = 0; i < 14; i++)
              TrendPoint(x: i, yMinor: (i % 5 + 1) * 10000),
          ],
          previous: [
            for (var i = 0; i < 14; i++)
              TrendPoint(x: i, yMinor: (4 - i % 4) * 10000),
          ],
          maxYMinor: 50000,
          currentTotalMinor: 0,
          previousTotalMinor: 0,
          startLocal: DateTime(2026),
        ),
      ),
      _ => BreakdownBars(
        title: l10n.expense_reportByPaymentMode,
        currencyCode: _sampleCurrency,
        maxYMinor: 50000,
        // Arbitrary sample values, never the user's data.
        items: const [
          BarItem(mode: PaymentMode.upi, amountMinor: 43210),
          BarItem(mode: PaymentMode.card, amountMinor: 27180),
          BarItem(mode: PaymentMode.cash, amountMinor: 9870),
        ],
      ),
    };
    return ListView(
      key: const Key('reports_locked'),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        LockedFeatureOverlay(
          message: l10n.premium_advancedReportsMessage,
          child: sample,
        ),
      ],
    );
  }
}

class _TabBody extends ConsumerWidget {
  const new({required this.state, required this.now});

  final ReportsState state;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(reportsControllerProvider.notifier);
    Widget scrollable(Widget child) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [child],
    );
    return switch (state.data) {
      AsyncValue(:final value?) when !value.hasTransactions => scrollable(
        EmptyState(
          title: l10n.expense_reportEmpty(
            state.period.label(
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
          onAction: () => unawaited(
            context.push(Routes.expenseAddPath(type: TxnType.expense.name)),
          ),
        ),
      ),
      AsyncValue(:final value?) => switch (state.tab) {
        ReportTab.overview => _Overview(vm: value.overview),
        ReportTab.categories => _Categories(state: state, data: value),
        ReportTab.trends => _Trends(vm: value.trend),
        ReportTab.accounts => _Accounts(vm: value.bars),
      },
      AsyncError() => scrollable(
        ErrorState(
          message: l10n.expense_loadDataError,
          onRetry: controller.retry,
        ),
      ),
      _ => const DelayedSkeleton(child: SkeletonList()),
    };
  }
}

class _Overview extends ConsumerWidget {
  const new({required this.vm});

  final OverviewVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final net = vm.netMinor;
    final valueStyle = theme.textTheme.titleLarge;

    return ListView(
      key: const Key('report_overview'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: tokens.s48),
      children: [
        SummaryCard(
          key: const Key('report_net'),
          title: l10n.expense_reportNetSavings,
          value: AmountText(
            amountMinor: net.abs(),
            currencyCode: currency,
            kind: net < 0 ? AmountKind.expense : AmountKind.income,
            showSign: net != 0,
            style: valueStyle,
          ),
        ),
        SummaryCard(
          key: const Key('report_savings_rate'),
          title: l10n.expense_reportSavingsRate,
          value: Text(switch (vm.savingsRatePercent) {
            final p? => l10n.expense_reportSavingsRateValue(p),
            null => l10n.expense_reportNoValue,
          }, style: valueStyle),
        ),
        SummaryCard(
          key: const Key('report_avg_daily'),
          title: l10n.expense_reportAvgDaily,
          value: switch (vm.avgDailySpendMinor) {
            final v? => AmountText(
              amountMinor: v,
              currencyCode: currency,
              style: valueStyle,
            ),
            null => Text(l10n.expense_reportNoValue, style: valueStyle),
          },
        ),
        SummaryCard(
          title: l10n.expense_reportIncomeVsExpense,
          value: IncomeExpenseBar(vm: vm, currencyCode: currency),
        ),
        if (vm.top.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
            child: Text(
              l10n.expense_reportTopCategories,
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final t in vm.top)
            ListTile(
              key: ValueKey('top_${t.categoryId}'),
              contentPadding: EdgeInsets.zero,
              leading: CategoryAvatar(
                icon: AppIcons.byKey(t.category?.iconKey ?? 'category'),
                color: t.category == null
                    ? theme.colorScheme.primary
                    : colorFromHex(t.category!.colorHex),
                semanticLabel: t.category == null
                    ? l10n.expense_category
                    : l10n.categoryName(t.category!),
              ),
              title: Text(
                t.category == null
                    ? l10n.expense_category
                    : l10n.categoryName(t.category!),
              ),
              subtitle: Text(l10n.expense_reportShare(t.sharePercent)),
              trailing: AmountText(
                amountMinor: t.amountMinor,
                currencyCode: currency,
                kind: AmountKind.expense,
                showSign: true,
              ),
            ),
        ],
      ],
    );
  }
}

class _Categories extends ConsumerWidget {
  const new({required this.state, required this.data});

  final ReportsState state;
  final ReportData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final controller = ref.read(reportsControllerProvider.notifier);
    final donut = data.donut;

    if (donut.slices.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            title: l10n.expense_reportEmpty(
              state.period.label(
                l10n.localeName,
                RelativeDayLabels(
                  today: l10n.common_today,
                  yesterday: l10n.common_yesterday,
                ),
                now: ref.read(clockProvider).now(),
                fullDatePattern: FullDateFormatScope.of(context).pattern,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      key: const Key('report_categories'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: tokens.s48),
      children: [
        CategoryDonut(
          vm: donut,
          currencyCode: currency,
          selectedKey: state.selectedKey,
          onSelect: controller.selectSlice,
        ),
        SizedBox(height: tokens.s8),
        for (final s in donut.slices)
          ListTile(
            key: ValueKey('legend_${s.key}'),
            contentPadding: EdgeInsets.zero,
            selected: s.key == state.selectedKey,
            selectedTileColor: theme.colorScheme.secondaryContainer,
            leading: Icon(
              s.key == state.selectedKey
                  ? Icons.radio_button_checked
                  : Icons.circle,
              color: s.isOther || s.category == null
                  ? theme.colorScheme.outline
                  : colorFromHex(s.category!.colorHex),
            ),
            title: Text(donutSliceName(l10n, s)),
            subtitle: Text(l10n.expense_reportShare(s.percent)),
            trailing: AmountText(
              amountMinor: s.amountMinor,
              currencyCode: currency,
            ),
            onTap: () => controller.selectSlice(s.key),
          ),
        if (state.selected.isNotEmpty) ...[
          const Divider(),
          for (final v in state.selected)
            TransactionRow(
              key: ValueKey('report_txn_${v.transaction.id}'),
              view: v,
              currency: currency,
              onTap: () => unawaited(
                context.push(Routes.expenseDetailPath(v.transaction.id)),
              ),
              onLongPress: () {},
            ),
        ],
      ],
    );
  }
}

class _Trends extends ConsumerWidget {
  const new({required this.vm});

  final TrendVm? vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = vm;
    return ListView(
      key: const Key('report_trends'),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (trend == null)
          const DelayedSkeleton(child: SkeletonList(itemCount: 1))
        else
          TrendLine(vm: trend, currencyCode: currencyCodeOf(ref)),
      ],
    );
  }
}

class _Accounts extends ConsumerWidget {
  const new({required this.vm});

  final BarsVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final currency = currencyCodeOf(ref);
    return ListView(
      key: const Key('report_accounts'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: tokens.s48),
      children: [
        BreakdownBars(
          key: const Key('bars_by_account'),
          title: l10n.expense_reportByAccount,
          items: vm.byAccount,
          maxYMinor: vm.maxYMinor,
          currencyCode: currency,
        ),
        SizedBox(height: tokens.s24),
        BreakdownBars(
          key: const Key('bars_by_mode'),
          title: l10n.expense_reportByPaymentMode,
          items: vm.byPaymentMode,
          maxYMinor: vm.maxYMinor,
          currencyCode: currency,
        ),
      ],
    );
  }
}
