import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_transaction.dart';
import 'package:dailytrack/features/expense/presentation/controllers/receipt_prune_controller.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/account_chips.dart';
import 'package:dailytrack/features/expense/presentation/widgets/category_grid.dart';
import 'package:dailytrack/features/expense/presentation/widgets/category_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:dailytrack/features/expense/presentation/widgets/occurred_at_chips.dart';
import 'package:dailytrack/features/expense/presentation/widgets/receipt_field.dart';
import 'package:dailytrack/features/expense/presentation/widgets/repeat_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EXP-02 Add / edit transaction (spec §8, contracts/screens.md). Full
/// screen above the shell. Speed is the goal: after typing the amount, a
/// category tap and Save log an expense. No Repeat toggle (T1.6) and no ads.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const new({required this.args, super.key});

  final TransactionFormArgs args;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _note = TextEditingController();
  final _noteFocus = FocusNode();

  /// Set once a save or delete succeeded, so leaving skips "Discard?".
  var _leaving = false;

  TransactionFormControllerProvider get _provider =>
      transactionFormControllerProvider(widget.args);

  @override
  void initState() {
    super.initState();
    // Housekeeping, once per app process (research R8).
    unawaited(ref.read(receiptPruneProvider.future));
  }

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.expenses);
    }
  }

  Future<void> _save({bool addAnother = false}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = rootMessengerKey.currentState;
    final result = await ref
        .read(_provider.notifier)
        .save(addAnother: addAnother);
    if (result == null || !mounted) return;
    unawaited(HapticFeedback.lightImpact());
    UndoSnackBar.show(
      context,
      message: switch (result.kind) {
        SaveKind.saved => l10n.expense_saved,
        SaveKind.ruleDeleted => l10n.expense_recurringDeleted,
      },
      onUndo: () => unawaited(result.undo()),
      messenger: messenger,
    );
    if (addAnother) {
      _note.clear();
    } else {
      setState(() => _leaving = true);
      _close();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = rootMessengerKey.currentState;
    final undo = await ref.read(_provider.notifier).delete();
    if (undo == null || !mounted) return;
    UndoSnackBar.show(
      context,
      message: l10n.expense_deleted,
      onUndo: () => unawaited(undo()),
      messenger: messenger,
    );
    setState(() => _leaving = true);
    _close();
  }

  Future<void> _saveMenu() async {
    final l10n = AppLocalizations.of(context);
    final addAnother = await AppBottomSheet.show<bool>(
      context,
      title: l10n.expense_addTitle,
      child: ListTile(
        key: const Key('save_and_add_another'),
        leading: const Icon(Icons.playlist_add),
        title: Text(l10n.expense_saveAndAddAnother),
        onTap: () => Navigator.of(context).pop(true),
      ),
    );
    if (addAnother ?? false) await _save(addAnother: true);
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await ConfirmDialog.show(
      context,
      title: l10n.expense_discardTitle,
      consequence: l10n.expense_discardBody,
      confirmLabel: l10n.expense_discardConfirm,
      destructive: true,
    );
    if (!discard || !mounted) return;
    setState(() => _leaving = true);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);

    ref.listen(_provider, (previous, next) {
      if (next.status == FormStatus.notFound &&
          previous?.status != FormStatus.notFound &&
          !_leaving) {
        rootMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.expense_noLongerExists)),
        );
        _leaving = true;
        context.go(Routes.expenses);
      }
      // Keep the note field in step with resets ("Save and add another").
      if (!_noteFocus.hasFocus && _note.text != next.draft.note) {
        _note.text = next.draft.note;
      }
    });

    return PopScope(
      canPop: !state.isDirty || _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmDiscard());
      },
      child: AppScaffold(
        title: state.isRuleEdit
            ? l10n.expense_ruleEditTitle
            : state.isEdit
            ? l10n.expense_editTitle
            : l10n.expense_addTitle,
        actions: [
          if (state.isEdit)
            IconButton(
              key: const Key('delete_transaction'),
              tooltip: l10n.expense_deleteAction,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
        body: switch (state.status) {
          FormStatus.loading => const DelayedSkeleton(child: SkeletonList()),
          FormStatus.loadError => ErrorState(
            message: l10n.expense_loadError,
            onRetry: controller.retry,
          ),
          FormStatus.notFound => const SizedBox.shrink(),
          FormStatus.ready => _Form(
            state: state,
            controller: controller,
            note: _note,
            noteFocus: _noteFocus,
            onSave: _save,
          ),
        },
        bottomBar: state.status == FormStatus.ready
            ? _BottomBar(
                state: state,
                controller: controller,
                onSave: _save,
                onSaveMenu: _saveMenu,
              )
            : null,
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const new({
    required this.state,
    required this.controller,
    required this.note,
    required this.noteFocus,
    required this.onSave,
  });

  final TransactionFormState state;
  final TransactionFormController controller;
  final TextEditingController note;
  final FocusNode noteFocus;
  final Future<void> Function() onSave;

  String? _message(AppLocalizations l10n, String currency, TxnField field) =>
      switch (state.errors[field]) {
        null => null,
        TxnError.amountRequired => l10n.expense_errAmountRequired,
        TxnError.amountTooLarge => l10n.expense_errAmountTooLarge(
          MoneyFormatter.format(AmountEntry.maxMinor, currencyCode: currency),
        ),
        TxnError.amountInvalid => l10n.expense_errAmountInvalid,
        TxnError.categoryRequired => l10n.expense_errCategoryRequired,
        TxnError.toAccountRequired => l10n.expense_errToAccountRequired,
        TxnError.sameAccount => l10n.expense_errSameAccount,
        TxnError.noteTooLong => l10n.expense_errNoteTooLong,
        TxnError.repeatEndBeforeStart => l10n.expense_repeatEndBeforeStart,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final draft = state.draft;
    final isTransfer = draft.type == TxnType.transfer;
    final now = ref.watch(clockProvider).now();

    Widget label(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    // A touch scroll of the form hides the keypad (feature 004). Only user
    // drags and flings send UserScrollNotification, so ensureVisible does
    // not; depth 0 ignores the horizontal chip rows.
    return NotificationListener<UserScrollNotification>(
      onNotification: (n) {
        if (n.depth == 0 &&
            n.direction != ScrollDirection.idle &&
            state.keypadOpen) {
          controller.setKeypadOpen(open: false);
        }
        return false;
      },
      // Not lazy: the form is short, and every field must exist for screen
      // readers and inline errors.
      child: SingleChildScrollView(
        key: const Key('transaction_form'),
        padding: EdgeInsets.symmetric(vertical: tokens.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TxnType>(
              segments: [
                for (final t in TxnType.values)
                  ButtonSegment(value: t, label: Text(l10n.txnType(t))),
              ],
              selected: {draft.type},
              showSelectedIcon: false,
              onSelectionChanged: (s) => controller.setType(s.single),
            ),
            _AmountDisplay(
              expression: state.expression,
              amountMinor: draft.amountMinor,
              currency: currency,
              onTap: () => controller.setKeypadOpen(open: true),
            ),
            FieldError(_message(l10n, currency, TxnField.amount)),
            if (!isTransfer) ...[
              label(l10n.expense_category),
              if (state.categories.isEmpty)
                Text(
                  key: const Key('no_categories'),
                  l10n.expense_noCategories,
                  style: theme.textTheme.bodyMedium,
                ),
              CategoryGrid(
                categories: state.categories,
                selectedId: draft.categoryId,
                onSelected: controller.selectCategory,
                // "+ New" opens EXP-05; the new category is selected (US1-3).
                onNew: () async {
                  final created = await CategorySheet.show(
                    context,
                    type: draft.type == TxnType.income
                        ? CategoryType.income
                        : CategoryType.expense,
                  );
                  if (created != null) controller.onCategoryCreated(created);
                },
              ),
              FieldError(_message(l10n, currency, TxnField.category)),
            ],
            label(l10n.expense_account),
            AccountChips(
              accounts: state.accounts,
              accountId: draft.accountId,
              onAccount: controller.selectAccount,
              isTransfer: isTransfer,
              toAccountId: draft.toAccountId,
              onToAccount: controller.selectToAccount,
            ),
            FieldError(_message(l10n, currency, TxnField.toAccount)),
            label(l10n.expense_paymentMode),
            ChipSelector<PaymentMode>(
              options: PaymentMode.values,
              selected: {draft.paymentMode},
              labelBuilder: l10n.paymentMode,
              onChanged: (s) => controller.setPaymentMode(s.single),
            ),
            SizedBox(height: tokens.s16),
            // Rule-edit: the date is the next occurrence (research R16).
            if (state.isRuleEdit)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.s8),
                child: Text(
                  key: const Key('next_date_label'),
                  l10n.expense_nextDate,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            OccurredAtChips(
              value: draft.occurredAt.toLocal(),
              now: now,
              onChanged: controller.setOccurredAt,
            ),
            SizedBox(height: tokens.s16),
            TextField(
              key: const Key('note_field'),
              controller: note,
              focusNode: noteFocus,
              maxLength: maxNoteLength,
              textInputAction: TextInputAction.done,
              onTap: () => controller.setKeypadOpen(open: false),
              onChanged: controller.setNote,
              onSubmitted: (_) => unawaited(onSave()),
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => Text(l10n.expense_noteLimit(currentLength)),
              decoration: InputDecoration(labelText: l10n.expense_noteLabel),
            ),
            FieldError(_message(l10n, currency, TxnField.note)),
            if (state.noteSuggestions.isNotEmpty)
              Wrap(
                spacing: tokens.s8,
                children: [
                  for (final s in state.noteSuggestions.take(3))
                    ActionChip(
                      label: Text(s),
                      onPressed: () {
                        note.text = s;
                        controller.setNote(s);
                      },
                    ),
                ],
              ),
            // Rules have no receipts.
            if (!state.isRuleEdit) ...[
              SizedBox(height: tokens.s16),
              ReceiptField(
                receiptPath: draft.receiptPath,
                failed: state.receiptFailed,
                onPick: (source) => unawaited(controller.pickReceipt(source)),
                onRemove: controller.removeReceipt,
              ),
            ],
            // Hidden for an entry that belongs to a rule (US3 s13).
            if (state.showRepeat) ...[
              SizedBox(height: tokens.s8),
              RepeatSection(
                repeat: state.repeat,
                firstLocal: draft.occurredAt.toLocal(),
                onToggle: controller.toggleRepeat,
                onFrequency: controller.setFrequency,
                onEndDate: controller.setEndDate,
                onClearEndDate: controller.clearEndDate,
                error: _message(l10n, currency, TxnField.repeat),
              ),
            ],
            if (state.saveFailed)
              FieldError(key: const Key('save_error'), l10n.expense_saveError),
          ],
        ),
      ),
    );
  }
}

/// EXP-02 sticky bottom: the keypad while the amount is being typed, and
/// the Save button (long-press: "Save and add another"). Lives in
/// `AppScaffold.bottomBar`, so snackbars never cover it.
class _BottomBar extends StatelessWidget {
  const new({
    required this.state,
    required this.controller,
    required this.onSave,
    required this.onSaveMenu,
  });

  final TransactionFormState state;
  final TransactionFormController controller;
  final Future<void> Function() onSave;
  final Future<void> Function() onSaveMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.keypadOpen)
          NumericKeypad(
            onKey: controller.key,
            onBackspace: controller.backspace,
            onOperator: controller.operator,
            onDone: () => controller.setKeypadOpen(open: false),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.s8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('save_transaction'),
              onLongPress: state.isEdit || state.saving ? null : onSaveMenu,
              onPressed: state.saving ? null : () => unawaited(onSave()),
              child: Text(switch (state.draft.type) {
                TxnType.expense => l10n.expense_saveExpense,
                TxnType.income => l10n.expense_saveIncome,
                TxnType.transfer => l10n.expense_saveTransfer,
              }),
            ),
          ),
        ),
      ],
    );
  }
}

/// The large amount: the formatted value (Indian grouping for INR), and the
/// calculation above it while one is being typed. Tapping opens the keypad.
class _AmountDisplay extends StatelessWidget {
  const new({
    required this.expression,
    required this.amountMinor,
    required this.currency,
    required this.onTap,
  });

  final String expression;
  final int? amountMinor;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final formatted = MoneyFormatter.format(
      amountMinor ?? 0,
      currencyCode: currency,
    );
    final hasOperator = RegExp('[+−×÷]').hasMatch(expression);
    // Muted until there is a valid amount.
    final color = amountMinor == null
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      label: l10n.expense_amountValue(formatted),
      // excludeSemantics drops the InkWell's tap action, so give it here.
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: const Key('amount_display'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusChip),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.s12),
          child: Column(
            children: [
              if (hasOperator)
                Text(
                  key: const Key('amount_expression'),
                  expression,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              FittedBox(
                child: Text(
                  key: const Key('amount_value'),
                  formatted,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
