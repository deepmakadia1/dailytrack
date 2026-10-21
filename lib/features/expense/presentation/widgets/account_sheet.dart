import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_account.dart';
import 'package:dailytrack/features/expense/presentation/controllers/account_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-07 Add / edit account (spec §8, FR-028): name, type, opening balance
/// (keypad plus a +/− toggle, so card debts can be negative), icon and
/// color. No ads.
abstract final class AccountSheet {
  /// Returns the saved account, or null if dismissed.
  static Future<Account?> show(BuildContext context, {String? id}) {
    final l10n = AppLocalizations.of(context);
    return AppBottomSheet.show<Account>(
      context,
      title: id == null
          ? l10n.expense_newAccountTitle
          : l10n.expense_editAccountTitle,
      child: _AccountForm(id: id),
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  const new({required this.id});

  final String? id;

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final _name = TextEditingController();

  AccountFormControllerProvider get _provider =>
      accountFormControllerProvider(widget.id);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref.read(_provider.notifier).save();
    if (saved != null && mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);
    final currency = currencyCodeOf(ref);

    ref.listen(_provider, (previous, next) {
      if (previous?.status != AccountFormStatus.ready &&
          next.status == AccountFormStatus.ready &&
          next.original != null) {
        _name.text = l10n.accountName(next.original!);
        controller.setName(_name.text);
      }
    });

    switch (state.status) {
      case AccountFormStatus.loading:
        return const DelayedSkeleton(child: SkeletonList());
      case AccountFormStatus.loadError:
        return ErrorState(
          message: l10n.expense_loadDataError,
          onRetry: controller.retry,
        );
      case AccountFormStatus.ready:
        break;
    }

    String? error(AccountField f) => switch (state.errors[f]) {
      null => null,
      AccountError.nameRequired => l10n.expense_errAccountNameRequired,
      AccountError.nameTooLong => l10n.expense_errAccountNameTooLong,
      AccountError.balanceOutOfRange => l10n.expense_errBalanceRange(
        MoneyFormatter.format(-maxBalanceMinor, currencyCode: currency),
        MoneyFormatter.format(maxBalanceMinor, currencyCode: currency),
      ),
    };

    Widget label(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    final balance = controller.openingBalanceMinor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CategoryAvatar(
                      icon: AppIcons.byKey(state.iconKey),
                      color: colorFromHex(state.colorHex),
                      semanticLabel: state.name,
                    ),
                    SizedBox(width: tokens.s12),
                    Expanded(
                      child: TextField(
                        key: const Key('account_name'),
                        controller: _name,
                        autofocus: !state.isEdit,
                        maxLength: maxAccountNameLength,
                        textInputAction: TextInputAction.done,
                        onTap: () => controller.setKeypadOpen(open: false),
                        onChanged: controller.setName,
                        decoration: InputDecoration(
                          labelText: l10n.expense_accountName,
                        ),
                      ),
                    ),
                  ],
                ),
                FieldError(error(AccountField.name)),
                label(l10n.expense_accountType),
                ChipSelector<AccountType>(
                  options: AccountType.values,
                  selected: {state.type},
                  labelBuilder: l10n.accountType,
                  onChanged: (s) => controller.setType(s.single),
                ),
                label(l10n.expense_openingBalance),
                Row(
                  children: [
                    SegmentedButton<bool>(
                      key: const Key('balance_sign'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: const Text('+'),
                          tooltip: l10n.expense_balancePositive,
                        ),
                        ButtonSegment(
                          value: true,
                          label: const Text('−'),
                          tooltip: l10n.expense_balanceNegative,
                        ),
                      ],
                      selected: {state.negative},
                      onSelectionChanged: (s) =>
                          controller.setNegative(negative: s.single),
                    ),
                    SizedBox(width: tokens.s12),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.expense_openingBalance,
                        child: InkWell(
                          key: const Key('opening_balance'),
                          onTap: () => controller.setKeypadOpen(open: true),
                          borderRadius: BorderRadius.circular(
                            tokens.radiusChip,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: tokens.s12),
                            child: Text(
                              key: const Key('opening_balance_value'),
                              MoneyFormatter.format(
                                balance ?? 0,
                                currencyCode: currency,
                              ),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                FieldError(error(AccountField.openingBalance)),
                if (state.keypadOpen)
                  NumericKeypad(
                    onKey: controller.key,
                    onBackspace: controller.backspace,
                    onOperator: controller.operator,
                    onDone: () => controller.setKeypadOpen(open: false),
                  ),
                label(l10n.expense_icon),
                IconPickerGrid(
                  selectedKey: state.iconKey,
                  onSelected: controller.setIcon,
                ),
                label(l10n.expense_color),
                ColorPickerRow(
                  selectedHex: state.colorHex,
                  onSelected: controller.setColor,
                ),
                if (state.saveFailed) FieldError(l10n.expense_saveError),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: tokens.s16),
          child: FilledButton(
            key: const Key('save_account'),
            onPressed: state.saving ? null : () => unawaited(_save()),
            child: Text(l10n.expense_saveAccount),
          ),
        ),
      ],
    );
  }
}
