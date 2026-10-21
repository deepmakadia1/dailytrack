import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/utils/result.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// What the filter sheet returns.
typedef TransactionFilters = ({
  Set<TxnType> types,
  Set<PaymentMode> paymentModes,
  Set<String> categoryIds,
  Set<String> accountIds,
  int? minAmountMinor,
  int? maxAmountMinor,
});

/// EXP-01 filter sheet (FR-020): type, payment mode, category, account and
/// an amount range entered with the custom keypad (§15.5).
abstract final class TransactionFilterSheet {
  static Future<TransactionFilters?> show(
    BuildContext context, {
    required TxnQuery query,
    required List<Category> categories,
    required List<Account> accounts,
    required String currency,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppBottomSheet.show<TransactionFilters>(
      context,
      title: l10n.expense_filterTitle,
      child: _FilterForm(
        query: query,
        categories: categories,
        accounts: accounts,
        currency: currency,
      ),
    );
  }
}

class _FilterForm extends StatefulWidget {
  const new({
    required this.query,
    required this.categories,
    required this.accounts,
    required this.currency,
  });

  final TxnQuery query;
  final List<Category> categories;
  final List<Account> accounts;
  final String currency;

  @override
  State<_FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends State<_FilterForm> {
  late Set<TxnType> _types = {...widget.query.types};
  late Set<PaymentMode> _modes = {...widget.query.paymentModes};
  late Set<String> _categories = {...widget.query.categoryIds};
  late Set<String> _accounts = {...widget.query.accountIds};
  late int? _min = widget.query.minAmountMinor;
  late int? _max = widget.query.maxAmountMinor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);

    Widget section(String title, Widget child) => Padding(
      padding: EdgeInsets.only(bottom: tokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          SizedBox(height: tokens.s8),
          child,
        ],
      ),
    );

    Widget amountButton(
      Key key,
      String label,
      int? value,
      ValueChanged<int?> set,
    ) => OutlinedButton(
      key: key,
      onPressed: () async {
        final picked = await _AmountKeypadSheet.show(
          context,
          title: label,
          initial: value,
          currency: widget.currency,
        );
        if (picked != null) setState(() => set(picked.value));
      },
      child: Text(
        value == null
            ? label
            : MoneyFormatter.format(value, currencyCode: widget.currency),
      ),
    );

    final byName = {
      for (final c in widget.categories) c.id: l10n.categoryName(c),
    };
    final accountNames = {
      for (final a in widget.accounts) a.id: l10n.accountName(a),
    };

    return ListView(
      shrinkWrap: true,
      children: [
        section(
          l10n.expense_filterType,
          ChipSelector<TxnType>(
            multi: true,
            options: TxnType.values,
            selected: _types,
            labelBuilder: l10n.txnType,
            onChanged: (s) => setState(() => _types = s),
          ),
        ),
        section(
          l10n.expense_paymentMode,
          ChipSelector<PaymentMode>(
            multi: true,
            options: PaymentMode.values,
            selected: _modes,
            labelBuilder: l10n.paymentMode,
            onChanged: (s) => setState(() => _modes = s),
          ),
        ),
        section(
          l10n.expense_category,
          ChipSelector<String>(
            multi: true,
            options: byName.keys.toList(),
            selected: _categories,
            labelBuilder: (id) => byName[id] ?? id,
            onChanged: (s) => setState(() => _categories = s),
          ),
        ),
        section(
          l10n.expense_menuAccounts,
          ChipSelector<String>(
            multi: true,
            options: accountNames.keys.toList(),
            selected: _accounts,
            labelBuilder: (id) => accountNames[id] ?? id,
            onChanged: (s) => setState(() => _accounts = s),
          ),
        ),
        section(
          l10n.expense_amount,
          Wrap(
            spacing: tokens.s8,
            runSpacing: tokens.s8,
            children: [
              amountButton(
                const Key('filter_min'),
                l10n.expense_filterAmountMin,
                _min,
                (v) => _min = v,
              ),
              amountButton(
                const Key('filter_max'),
                l10n.expense_filterAmountMax,
                _max,
                (v) => _max = v,
              ),
            ],
          ),
        ),
        FilledButton(
          key: const Key('apply_filters'),
          onPressed: () => Navigator.of(context).pop((
            types: _types,
            paymentModes: _modes,
            categoryIds: _categories,
            accountIds: _accounts,
            minAmountMinor: _min,
            maxAmountMinor: _max,
          )),
          child: Text(l10n.expense_applyFilters),
        ),
      ],
    );
  }
}

/// A small keypad sheet for an amount. Returns `(value: null)` when cleared,
/// or null when dismissed.
abstract final class _AmountKeypadSheet {
  static Future<({int? value})?> show(
    BuildContext context, {
    required String title,
    required int? initial,
    required String currency,
  }) => AppBottomSheet.show<({int? value})>(
    context,
    title: title,
    child: _AmountKeypad(initial: initial, currency: currency),
  );
}

class _AmountKeypad extends StatefulWidget {
  const new({required this.initial, required this.currency});

  final int? initial;
  final String currency;

  @override
  State<_AmountKeypad> createState() => _AmountKeypadState();
}

class _AmountKeypadState extends State<_AmountKeypad> {
  late String _expression = switch (widget.initial) {
    null => '',
    final v => '${v ~/ 100}.${(v % 100).toString().padLeft(2, '0')}',
  };

  int? get _value => switch (AmountEntry.parse(_expression)) {
    Ok(:final value) => value,
    Err() => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key: const Key('filter_amount_value'),
          MoneyFormatter.format(_value ?? 0, currencyCode: widget.currency),
          style: theme.textTheme.headlineSmall,
        ),
        NumericKeypad(
          onKey: (k) => setState(() => _expression += k),
          onBackspace: () => setState(() {
            if (_expression.isNotEmpty) {
              _expression = _expression.substring(0, _expression.length - 1);
            }
          }),
          onOperator: (op) => setState(() {
            if (op != NumericKeypad.equals && _expression.isNotEmpty) {
              _expression += op;
            }
          }),
          onDone: () => Navigator.of(context).pop((value: _value)),
        ),
      ],
    );
  }
}
