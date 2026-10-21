import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budgets_state.freezed.dart';

/// EXP-08 state (contracts/screens.md): the selected month and its budgets.
@freezed
abstract class BudgetsState with _$BudgetsState {
  const factory({
    /// `yyyy-MM`.
    required String monthKey,
    @Default(AsyncLoading<BudgetsOverview>())
    AsyncValue<BudgetsOverview> overview,
  }) = _BudgetsState;
}
