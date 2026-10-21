import 'package:dailytrack/core/l10n/currency_names.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/currencies.dart';
import 'package:flutter/material.dart';

/// Searchable list of the supported currencies with the current choice
/// marked (SYS-02 step 2, SET-01 Currency; feature 007 T052). Needs a
/// bounded height. Rows are keyed `currency_<CODE>`.
class CurrencyPickerList extends StatefulWidget {
  const new({
    required this.selectedCode,
    required this.onSelected,
    super.key,
    this.initialQuery = '',
    this.onQueryChanged,
    this.searchFieldKey = const Key('currency_search'),
  });

  final String selectedCode;
  final ValueChanged<String> onSelected;
  final String initialQuery;

  /// Reports every search change, e.g. so onboarding keeps the query.
  final ValueChanged<String>? onQueryChanged;
  final Key searchFieldKey;

  @override
  State<CurrencyPickerList> createState() => _CurrencyPickerListState();
}

class _CurrencyPickerListState extends State<CurrencyPickerList> {
  late final TextEditingController _search = TextEditingController(
    text: widget.initialQuery,
  );
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _changed(String query) {
    setState(() => _query = query);
    widget.onQueryChanged?.call(query);
  }

  void _clear() {
    _search.clear();
    _changed('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final matches = filterCurrencies(
      _query,
      (code) => currencyName(l10n, code),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: widget.searchFieldKey,
          controller: _search,
          onChanged: _changed,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.onboarding_currencySearchHint,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        SizedBox(height: tokens.s8),
        Expanded(
          child: matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.onboarding_noMatches),
                      TextButton(
                        onPressed: _clear,
                        child: Text(l10n.onboarding_clearSearch),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, i) {
                    final c = matches[i];
                    final selected = c.code == widget.selectedCode;
                    return ListTile(
                      key: Key('currency_${c.code}'),
                      selected: selected,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: tokens.s48,
                        child: Center(
                          child: Text(
                            c.symbol,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      title: Text(currencyName(l10n, c.code)),
                      subtitle: Text(c.code),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () => widget.onSelected(c.code),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
