import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/today_and_month_spend.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_dashboard_controller.freezed.dart';
part 'expense_dashboard_controller.g.dart';

/// The Home Expense card (DSH-01, feature 006 data-model.md §5).
@freezed
abstract class ExpenseDashboardData with _$ExpenseDashboardData {
  const factory({
    required int todayMinor,
    required int monthMinor,
    required bool hasAnyTransaction,

    /// This month's Overall budget, or null when none is set.
    BudgetStatus? overall,
  }) = _ExpenseDashboardData;
}

/// The Home Expense card (T111, FR-030; DSH-01 budget bar, research R9):
/// spent today and this month (expenses only) plus the Overall budget,
/// live. Rebuilds itself at the next local midnight so "today" moves on
/// without a restart.
@riverpod
class ExpenseDashboardController extends _$ExpenseDashboardController {
  StreamSubscription<TodayAndMonthSpend>? _spendSub;
  StreamSubscription<BudgetStatus?>? _budgetSub;
  TodayAndMonthSpend? _spend;
  BudgetStatus? _overall;
  var _hasOverview = false;

  @override
  AsyncValue<ExpenseDashboardData> build() {
    final now = ref.watch(clockProvider).now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timer = Timer(midnight.difference(now), ref.invalidateSelf);
    _spend = null;
    _overall = null;
    _hasOverview = false;
    ref.onDispose(() {
      timer.cancel();
      unawaited(_spendSub?.cancel());
      unawaited(_budgetSub?.cancel());
    });
    _spendSub = ref
        .read(transactionRepositoryProvider)
        .watchTodayAndMonthSpend(now)
        .listen((s) {
          _spend = s;
          _emit();
        }, onError: _onError);
    _budgetSub = ref
        .read(budgetRepositoryProvider)
        .watchOverview(monthKeyOf(now))
        .map((o) => o.overall)
        .listen((o) {
          _overall = o;
          _hasOverview = true;
          _emit();
        }, onError: _onError);
    return const AsyncLoading();
  }

  void _onError(Object e, StackTrace st) {
    if (ref.mounted) state = AsyncError(e, st);
  }

  void _emit() {
    final spend = _spend;
    if (spend == null || !_hasOverview || !ref.mounted) return;
    state = AsyncData(
      ExpenseDashboardData(
        todayMinor: spend.todayMinor,
        monthMinor: spend.monthMinor,
        hasAnyTransaction: spend.hasAnyTransaction,
        overall: _overall,
      ),
    );
  }

  void retry() => ref.invalidateSelf();
}
