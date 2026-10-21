import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budgets_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/budgets_state.dart';

part 'budgets_controller.g.dart';

/// Undo of a budget delete: true when restored, false when the slot was
/// filled meanwhile (research R4).
typedef BudgetUndo = Future<bool> Function();

/// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
/// Family argument: the `yyyy-MM` month to open, or null for this month.
@riverpod
class BudgetsController extends _$BudgetsController {
  StreamSubscription<BudgetsOverview>? _sub;

  @override
  BudgetsState build(String? month) {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    final key = _valid(month) ?? monthKeyOf(ref.read(clockProvider).now());
    _listen(key);
    return BudgetsState(monthKey: key);
  }

  static String? _valid(String? month) {
    if (month == null) return null;
    try {
      monthStartLocal(month);
      return month;
    } on FormatException {
      return null;
    }
  }

  void _listen(String monthKey) {
    unawaited(_sub?.cancel());
    _sub = ref
        .read(budgetRepositoryProvider)
        .watchOverview(monthKey)
        .listen(
          (overview) => _set(monthKey, AsyncData(overview)),
          onError: (Object e, StackTrace st) =>
              _set(monthKey, AsyncError(e, st)),
        );
  }

  void _set(String monthKey, AsyncValue<BudgetsOverview> value) {
    if (!ref.mounted || state.monthKey != monthKey) return;
    state = state.copyWith(overview: value);
  }

  void _show(String monthKey) {
    state = BudgetsState(monthKey: monthKey);
    _listen(monthKey);
  }

  void previousMonth() => _show(shiftMonthKey(state.monthKey, -1));

  void nextMonth() => _show(shiftMonthKey(state.monthKey, 1));

  /// "Copy last month's budgets" (US1 s8): the number copied, or null when
  /// the write failed.
  Future<int?> copyLastMonth() async {
    try {
      return await ref
          .read(budgetRepositoryProvider)
          .copyPreviousMonth(state.monthKey);
    } on ExpenseStorageFailure {
      return null;
    }
  }

  /// Deletes [id] (US1 s7); returns its undo, or null when the write failed.
  Future<BudgetUndo?> deleteBudget(String id) async {
    final repo = ref.read(budgetRepositoryProvider);
    try {
      await repo.softDelete(id);
    } on ExpenseStorageFailure {
      return null;
    }
    return () async {
      try {
        await repo.undelete(id);
        return true;
      } on BudgetSlotTaken {
        return false;
      } on ExpenseStorageFailure {
        return false;
      }
    };
  }

  /// Error state "Try again".
  void retry() => _show(state.monthKey);
}
