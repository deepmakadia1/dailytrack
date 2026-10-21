import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/utils/result.dart';

enum AmountError { required, tooLarge, invalid }

/// Turns `NumericKeypad` input into a transaction amount in paise (EXP-02,
/// FR-011, SC-002). Exact fixed-point math; calculator results round half up
/// to whole paise (spec Assumption "Calculator rounding").
abstract final class AmountEntry {
  /// ₹99,99,99,999.00 in paise (FR-011).
  static const int maxMinor = 99999999900;

  static Result<int, AmountError> parse(String expression) =>
      switch (KeypadExpression.evaluateToMinor(expression)) {
        Err() => const Err(AmountError.invalid),
        Ok(:final value) when value <= 0 => const Err(AmountError.required),
        Ok(:final value) when value > maxMinor => const Err(
          AmountError.tooLarge,
        ),
        Ok(:final value) => Ok(value),
      };
}
