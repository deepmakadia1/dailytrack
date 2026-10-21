import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_budget.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_form_state.freezed.dart';

/// How EXP-09 was opened: edit [budgetId], or a new budget for
/// [categoryId] (null = Overall) in [monthKey].
@freezed
abstract class BudgetFormArgs with _$BudgetFormArgs {
  const factory({
    required String monthKey,
    String? budgetId,
    String? categoryId,
  }) = _BudgetFormArgs;
}

enum BudgetFormStatus { loading, ready, loadError }

/// One choice in EXP-09's category picker; [category] null = Overall.
@freezed
abstract class BudgetSlot with _$BudgetSlot {
  const factory({Category? category}) = _BudgetSlot;

  const new _();

  String? get categoryId => category?.id;
}

/// EXP-09 state (contracts/screens.md).
@freezed
abstract class BudgetFormState with _$BudgetFormState {
  const factory({
    required BudgetFormStatus status,

    /// The selected slot.
    @Default(BudgetSlot()) BudgetSlot slot,

    /// New mode: Overall (if free) plus expense categories without a
    /// budget that month. Edit mode: the fixed slot only.
    @Default(<BudgetSlot>[]) List<BudgetSlot> availableSlots,

    /// Keypad input; empty = no amount yet.
    @Default('') String expression,
    @Default(true) bool rollover,
    @Default(true) bool keypadOpen,
    @Default(<BudgetError>{}) Set<BudgetError> errors,
    @Default(false) bool saving,
    @Default(false) bool saveFailed,

    /// The budget being edited; null for a new one.
    Budget? original,
  }) = _BudgetFormState;

  const new _();

  bool get isEdit => original != null;
}

/// How EXP-09 closed, for EXP-08's snackbars.
sealed class BudgetSheetOutcome {
  const new();
}

final class BudgetSaved extends BudgetSheetOutcome {
  const new(this.budget);

  final Budget budget;
}

final class BudgetDeleted extends BudgetSheetOutcome {
  const new(this.undo);

  /// True when restored; false when the slot was filled meanwhile.
  final Future<bool> Function() undo;
}
