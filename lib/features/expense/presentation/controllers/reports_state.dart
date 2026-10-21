import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/usecases/report_access.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_state.freezed.dart';

/// Everything EXP-11's tabs draw for one period (contracts/screens.md).
@freezed
abstract class ReportData with _$ReportData {
  const factory({
    /// Any transaction in the period, transfers included (else the empty
    /// state shows).
    required bool hasTransactions,
    required OverviewVm overview,
    required DonutVm donut,
    required BarsVm bars,

    /// Trends tab only: needs the previous period's ledger.
    TrendVm? trend,
  }) = _ReportData;
}

/// EXP-11 state (contracts/screens.md).
@freezed
abstract class ReportsState with _$ReportsState {
  const factory({
    required Period period,
    @Default(ReportTab.overview) ReportTab tab,

    /// From `FeatureGate.watch(advancedReports)`.
    @Default(false) bool advancedUnlocked,

    /// The current tab and period need the unlock and it is missing.
    @Default(false) bool locked,

    /// The selected donut slice key (a category id or "Other").
    String? selectedKey,

    /// The selected slice's transactions, newest first.
    @Default(<TransactionView>[]) List<TransactionView> selected,
    @Default(AsyncLoading<ReportData>()) AsyncValue<ReportData> data,
  }) = _ReportsState;

  const new _();

  /// Whether [tab] for this period would be locked (tab lock icons).
  bool isTabLocked(ReportTab tab, DateTime now) =>
      !advancedUnlocked && requiresAdvanced(tab, period, now);
}
