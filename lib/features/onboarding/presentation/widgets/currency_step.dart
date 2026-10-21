import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/currency_picker_list.dart';
import 'package:flutter/material.dart';

/// SYS-02 step 2: searchable currency list with the current choice marked.
/// The list itself is the shared `CurrencyPickerList` (feature 007 T052).
class CurrencyStep extends StatelessWidget {
  const new({
    required this.selectedCode,
    required this.query,
    required this.onQueryChanged,
    required this.onSelected,
    super.key,
  });

  final String selectedCode;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: tokens.s24),
        Text(
          l10n.onboarding_currencyTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: tokens.s16),
        Expanded(
          child: CurrencyPickerList(
            selectedCode: selectedCode,
            onSelected: onSelected,
            initialQuery: query,
            onQueryChanged: onQueryChanged,
            searchFieldKey: const Key('onboarding_currency_search'),
          ),
        ),
      ],
    );
  }
}
