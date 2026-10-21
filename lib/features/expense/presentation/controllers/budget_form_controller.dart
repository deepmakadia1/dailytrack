import 'dart:async';

import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/utils/result.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_budget.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budget_form_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/budget_form_state.dart';

part 'budget_form_controller.g.dart';

/// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
/// notifier.
@riverpod
class BudgetFormController extends _$BudgetFormController {
  StreamSubscription<BudgetsOverview>? _sub;

  @override
  BudgetFormState build(BudgetFormArgs args) {
    _sub = ref
        .read(budgetRepositoryProvider)
        .watchOverview(args.monthKey)
        .listen(
          (o) => unawaited(_onOverview(o)),
          onError: (Object _) => _onLoadError(),
        );
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const BudgetFormState(status: BudgetFormStatus.loading);
  }

  void _onLoadError() {
    if (ref.mounted && state.status == BudgetFormStatus.loading) {
      state = state.copyWith(status: BudgetFormStatus.loadError);
    }
  }

  /// The first emission fills the form; later ones are ignored so typing
  /// is never overwritten.
  Future<void> _onOverview(BudgetsOverview overview) async {
    if (state.status != BudgetFormStatus.loading) return;
    unawaited(_sub?.cancel());
    final repo = ref.read(budgetRepositoryProvider);
    try {
      final id = args.budgetId;
      if (id != null) {
        final budget = await repo.findById(id);
        if (!ref.mounted) return;
        if (budget == null) {
          state = state.copyWith(status: BudgetFormStatus.loadError);
          return;
        }
        final status = [
          ?overview.overall,
          ...overview.categories,
        ].where((s) => s.budget.id == id).firstOrNull;
        final slot = BudgetSlot(category: status?.category);
        state = state.copyWith(
          status: BudgetFormStatus.ready,
          original: budget,
          slot: slot,
          availableSlots: [slot],
          expression: _toExpression(budget.limitMinor),
          rollover: budget.rollover,
          keypadOpen: false,
        );
        return;
      }
      final slots = [
        if (overview.overall == null) const BudgetSlot(),
        for (final c in overview.withoutBudget) BudgetSlot(category: c),
      ];
      final wanted = slots
          .where((s) => s.categoryId == args.categoryId)
          .firstOrNull;
      state = state.copyWith(
        status: BudgetFormStatus.ready,
        availableSlots: slots,
        slot: wanted ?? slots.firstOrNull ?? const BudgetSlot(),
      );
    } on Object {
      _onLoadError();
    }
  }

  static String _toExpression(int minor) => minor % 100 == 0
      ? '${minor ~/ 100}'
      : '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';

  /// The typed limit in paise, or null when there is none or it is invalid.
  int? get limitMinor =>
      switch (KeypadExpression.evaluateToMinor(state.expression)) {
        Ok(:final value) => value,
        Err() => null,
      };

  void selectSlot(BudgetSlot slot) {
    if (state.isEdit) return;
    state = state.copyWith(
      slot: slot,
      errors: {...state.errors}..remove(BudgetError.slotTaken),
    );
  }

  void toggleRollover() => state = state.copyWith(rollover: !state.rollover);

  void setKeypadOpen({required bool open}) =>
      state = state.copyWith(keypadOpen: open);

  void key(String digitOrPoint) {
    final e = state.expression;
    final last = e.split(RegExp('[+−×÷]')).last;
    if (digitOrPoint == '.' && last.contains('.')) return;
    _setExpression(
      digitOrPoint == '.' && last.isEmpty ? '${e}0.' : '$e$digitOrPoint',
    );
  }

  void operator(String op) {
    if (op == '=') {
      if (KeypadExpression.evaluateToMinor(state.expression) case Ok(
        :final value,
      )) {
        _setExpression(value <= 0 ? '' : _toExpression(value));
      }
      return;
    }
    if (state.expression.isEmpty) return;
    _setExpression('${state.expression}$op');
  }

  void backspace() {
    final e = state.expression;
    if (e.isNotEmpty) _setExpression(e.substring(0, e.length - 1));
  }

  void _setExpression(String e) => state = state.copyWith(
    expression: e,
    errors: {...state.errors}
      ..remove(BudgetError.amountMissing)
      ..remove(BudgetError.amountTooLarge),
  );

  /// Validates (FR-011) and saves for the sheet's month (US1 s5). Returns
  /// null when invalid or when saving failed; the input stays.
  Future<Budget?> save() async {
    final limit = limitMinor;
    final errors = validateBudget(limitMinor: limit);
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return null;
    }
    state = state.copyWith(saving: true, saveFailed: false);
    final repo = ref.read(budgetRepositoryProvider);
    try {
      final original = state.original;
      final saved = original == null
          ? await repo.create(
              BudgetDraft(
                monthKey: args.monthKey,
                categoryId: state.slot.categoryId,
                limitMinor: limit!,
                rollover: state.rollover,
              ),
            )
          : await repo.update(
              original.id,
              limitMinor: limit!,
              rollover: state.rollover,
            );
      if (ref.mounted) state = state.copyWith(saving: false);
      return saved;
    } on BudgetSlotTaken {
      if (ref.mounted) {
        state = state.copyWith(
          saving: false,
          errors: {...state.errors, BudgetError.slotTaken},
        );
      }
      return null;
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(saving: false, saveFailed: true);
      }
      return null;
    }
  }

  /// Edit mode only: deletes the budget (US1 s7) and returns its undo.
  Future<Future<bool> Function()?> delete() async {
    final original = state.original;
    if (original == null) return null;
    final repo = ref.read(budgetRepositoryProvider);
    try {
      await repo.softDelete(original.id);
    } on ExpenseStorageFailure {
      if (ref.mounted) state = state.copyWith(saveFailed: true);
      return null;
    }
    return () async {
      try {
        await repo.undelete(original.id);
        return true;
      } on Object {
        return false;
      }
    };
  }

  /// Load error "Try again".
  void retry() => ref.invalidateSelf();
}
