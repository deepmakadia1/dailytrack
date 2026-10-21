import 'package:dailytrack/core/utils/result.dart';

enum KeypadError { malformed, tooManyDecimals, divisionByZero, negative }

/// Evaluates the `NumericKeypad` calculator input (spec §15.4) into integer
/// minor units. Works in fixed-point `BigInt` arithmetic only; `double` is
/// never used for money (Constitution III).
abstract final class KeypadExpression {
  static const String plus = '+';
  static const String minus = '−';
  static const String times = '×';
  static const String divide = '÷';

  static Result<int, KeypadError> evaluateToMinor(
    String input, {
    int minorDigits = 2,
  }) {
    var text = input.trim();
    if (text.isEmpty) return const Ok(0);
    // A trailing operator is normal while the user is still typing.
    if (_isOperator(text[text.length - 1])) {
      text = text.substring(0, text.length - 1);
    }

    final numbers = <BigInt>[];
    final ops = <String>[];
    final buffer = StringBuffer();
    for (final ch in text.split('')) {
      if (_isOperator(ch)) {
        if (buffer.isEmpty) return const Err(KeypadError.malformed);
        final n = _parse(buffer.toString(), minorDigits);
        if (n case Err(:final error)) return Err(error);
        numbers.add((n as Ok<BigInt, KeypadError>).value);
        ops.add(ch);
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.isEmpty) return const Err(KeypadError.malformed);
    final last = _parse(buffer.toString(), minorDigits);
    if (last case Err(:final error)) return Err(error);
    numbers.add((last as Ok<BigInt, KeypadError>).value);

    final scale = BigInt.from(10).pow(minorDigits);

    // First pass: × and ÷, left to right.
    final terms = <BigInt>[numbers.first];
    final addOps = <String>[];
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      final rhs = numbers[i + 1];
      if (op == times) {
        terms[terms.length - 1] = _divRound(terms.last * rhs, scale);
      } else if (op == divide) {
        if (rhs == BigInt.zero) return const Err(KeypadError.divisionByZero);
        terms[terms.length - 1] = _divRound(terms.last * scale, rhs);
      } else {
        addOps.add(op);
        terms.add(rhs);
      }
    }

    // Second pass: + and −.
    var total = terms.first;
    for (var i = 0; i < addOps.length; i++) {
      total = addOps[i] == plus ? total + terms[i + 1] : total - terms[i + 1];
    }
    if (total.isNegative) return const Err(KeypadError.negative);
    return Ok(total.toInt());
  }

  static bool _isOperator(String ch) =>
      ch == plus || ch == minus || ch == times || ch == divide;

  /// Parses `12.5` into minor units (1250 for 2 digits).
  static Result<BigInt, KeypadError> _parse(String token, int minorDigits) {
    final parts = token.split('.');
    if (parts.length > 2) return const Err(KeypadError.malformed);
    final whole = parts[0].isEmpty ? '0' : parts[0];
    final frac = parts.length == 2 ? parts[1] : '';
    if (!RegExp(r'^\d+$').hasMatch(whole) ||
        (frac.isNotEmpty && !RegExp(r'^\d+$').hasMatch(frac))) {
      return const Err(KeypadError.malformed);
    }
    if (frac.length > minorDigits) {
      return const Err(KeypadError.tooManyDecimals);
    }
    final digits = whole + frac.padRight(minorDigits, '0');
    return Ok(BigInt.parse(digits));
  }

  /// Integer division rounding half up (inputs are non-negative).
  static BigInt _divRound(BigInt numerator, BigInt denominator) {
    final q = numerator ~/ denominator;
    final r = numerator.remainder(denominator);
    return r * BigInt.two >= denominator ? q + BigInt.one : q;
  }
}
