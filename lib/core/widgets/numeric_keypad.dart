import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:flutter/material.dart';

/// Amount keypad with calculator operators (§15.4). It only emits key
/// presses; `KeypadExpression` evaluates the text.
class NumericKeypad extends StatelessWidget {
  const new({
    required this.onKey,
    required this.onBackspace,
    required this.onOperator,
    required this.onDone,
    super.key,
  });

  /// A digit `0`–`9` or the decimal point `.`.
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  /// One of the `KeypadExpression` operators, or `=`.
  final ValueChanged<String> onOperator;
  final VoidCallback onDone;

  static const String equals = '=';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final textStyle = Theme.of(context).textTheme.headlineSmall;

    Widget text(String label, ValueChanged<String> onTap) => TextButton(
      onPressed: () => onTap(label),
      child: Text(label, style: textStyle),
    );

    Widget key(Widget child, {int flex = 1}) => Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(tokens.s4),
        child: SizedBox(
          key: const ValueKey('keypad_key'),
          height: tokens.minTouchTarget + tokens.s8,
          child: child,
        ),
      ),
    );

    Widget row(List<Widget> keys) => Row(children: keys);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (digits, op) in const [
          (['7', '8', '9'], KeypadExpression.divide),
          (['4', '5', '6'], KeypadExpression.times),
          (['1', '2', '3'], KeypadExpression.minus),
        ])
          row([
            for (final d in digits) key(text(d, onKey)),
            key(text(op, onOperator)),
          ]),
        row([
          key(text('.', onKey)),
          key(text('0', onKey)),
          key(
            IconButton(
              onPressed: onBackspace,
              icon: Icon(
                Icons.backspace_outlined,
                semanticLabel: l10n.keypad_backspace,
              ),
            ),
          ),
          key(text(KeypadExpression.plus, onOperator)),
        ]),
        row([
          key(text(equals, onOperator)),
          key(
            // Tonal, not filled: the screen's own Save stays the single
            // primary action (§15.1).
            FilledButton.tonal(
              onPressed: onDone,
              child: Text(l10n.keypad_done),
            ),
            flex: 3,
          ),
        ]),
      ],
    );
  }
}
