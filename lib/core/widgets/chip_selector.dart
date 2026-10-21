import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Single- or multi-select chips (§15.4), e.g. payment mode, weekdays,
/// language. Chips keep the default padded 48 dp tap target.
class ChipSelector<T> extends StatelessWidget {
  const new({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
    this.multi = false,
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T option) labelBuilder;
  final ValueChanged<Set<T>> onChanged;

  /// When false, tapping a chip selects only that chip.
  final bool multi;

  void _toggle(T option) {
    if (!multi) {
      onChanged({option});
      return;
    }
    final next = {...selected};
    if (!next.remove(option)) next.add(option);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Wrap(
      spacing: tokens.s8,
      runSpacing: tokens.s8,
      children: [
        for (final option in options)
          if (multi)
            FilterChip(
              label: Text(labelBuilder(option)),
              selected: selected.contains(option),
              onSelected: (_) => _toggle(option),
            )
          else
            ChoiceChip(
              label: Text(labelBuilder(option)),
              selected: selected.contains(option),
              onSelected: (_) => _toggle(option),
            ),
      ],
    );
  }
}
