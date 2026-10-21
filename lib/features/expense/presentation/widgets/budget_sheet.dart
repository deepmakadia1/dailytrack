import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_budget.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budget_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-09 Set budget (spec §8, FR-011): category (or Overall), amount on the
/// shared keypad, and "Repeat every month". In edit mode the category is
/// fixed and "Delete budget" is offered. No ads, no route.
abstract final class BudgetSheet {
  /// Returns how the sheet closed, or null if it was dismissed.
  static Future<BudgetSheetOutcome?> show(
    BuildContext context,
    BudgetFormArgs args,
  ) => AppBottomSheet.show<BudgetSheetOutcome>(
    context,
    title: AppLocalizations.of(context).expense_budgetSet,
    child: _BudgetForm(args: args),
  );
}

class _BudgetForm extends ConsumerWidget {
  const new({required this.args});

  final BudgetFormArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final provider = budgetFormControllerProvider(args);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final currency = currencyCodeOf(ref);

    switch (state.status) {
      case BudgetFormStatus.loading:
        return const DelayedSkeleton(child: SkeletonList(itemCount: 2));
      case BudgetFormStatus.loadError:
        return ErrorState(
          message: l10n.expense_loadDataError,
          onRetry: controller.retry,
        );
      case BudgetFormStatus.ready:
        break;
    }

    Future<void> save() async {
      final saved = await controller.save();
      if (saved != null && context.mounted) {
        Navigator.of(context).pop(BudgetSaved(saved));
      }
    }

    Future<void> delete() async {
      final undo = await controller.delete();
      if (undo != null && context.mounted) {
        Navigator.of(context).pop(BudgetDeleted(undo));
      }
    }

    Widget label(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    final amountError = switch (state.errors) {
      final e when e.contains(BudgetError.amountMissing) =>
        l10n.expense_budgetAmountMissing,
      final e when e.contains(BudgetError.amountTooLarge) =>
        l10n.expense_budgetAmountTooLarge,
      _ => null,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label(l10n.expense_category),
                if (state.isEdit)
                  Text(
                    key: const Key('budget_slot_fixed'),
                    l10n.budgetName(state.slot.category),
                    style: theme.textTheme.bodyLarge,
                  )
                else
                  ChipSelector<BudgetSlot>(
                    key: const Key('budget_slot'),
                    options: state.availableSlots,
                    selected: {state.slot},
                    labelBuilder: (s) => l10n.budgetName(s.category),
                    onChanged: (s) => controller.selectSlot(s.single),
                  ),
                FieldError(
                  state.errors.contains(BudgetError.slotTaken)
                      ? l10n.expense_budgetSlotTaken
                      : null,
                ),
                label(l10n.expense_amount),
                Semantics(
                  button: true,
                  label: l10n.expense_amount,
                  child: InkWell(
                    key: const Key('budget_amount'),
                    onTap: () => controller.setKeypadOpen(open: true),
                    borderRadius: BorderRadius.circular(tokens.radiusChip),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: tokens.s12),
                      child: Text(
                        key: const Key('budget_amount_value'),
                        MoneyFormatter.format(
                          controller.limitMinor ?? 0,
                          currencyCode: currency,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
                FieldError(amountError),
                if (state.keypadOpen)
                  NumericKeypad(
                    onKey: controller.key,
                    onBackspace: controller.backspace,
                    onOperator: controller.operator,
                    onDone: () => controller.setKeypadOpen(open: false),
                  ),
                SwitchListTile(
                  key: const Key('budget_rollover'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.expense_budgetRepeatMonthly),
                  value: state.rollover,
                  onChanged: (_) => controller.toggleRollover(),
                ),
                if (state.saveFailed) FieldError(l10n.expense_saveError),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: tokens.s16),
          child: FilledButton(
            key: const Key('save_budget'),
            onPressed: state.saving ? null : () => unawaited(save()),
            child: Text(l10n.expense_budgetSet),
          ),
        ),
        if (state.isEdit)
          TextButton(
            key: const Key('delete_budget'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: state.saving ? null : () => unawaited(delete()),
            child: Text(l10n.expense_budgetDelete),
          ),
      ],
    );
  }
}
