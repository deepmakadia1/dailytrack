import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

int _ok(String input, {int minorDigits = 2}) {
  final r = KeypadExpression.evaluateToMinor(input, minorDigits: minorDigits);
  return switch (r) {
    Ok(:final value) => value,
    Err(:final error) => fail('expected Ok for "$input", got $error'),
  };
}

KeypadError _err(String input) {
  final r = KeypadExpression.evaluateToMinor(input);
  return switch (r) {
    Ok(:final value) => fail('expected Err for "$input", got $value'),
    Err(:final error) => error,
  };
}

void main() {
  test('addition of decimals', () => expect(_ok('12.5+7.5'), 2000));
  test('multiplication', () => expect(_ok('100×3'), 30000));
  test('division rounds half up', () {
    expect(_ok('10÷3'), 333);
    expect(_ok('2÷3'), 67);
  });
  test(
    'subtraction uses the true minus sign',
    () => expect(_ok('10−2.25'), 775),
  );
  test('× and ÷ bind tighter than + and −', () => expect(_ok('1+2×3'), 700));
  test('empty input is zero', () => expect(_ok(''), 0));
  test('single number', () => expect(_ok('0.05'), 5));
  test(
    'zero-decimal currencies',
    () => expect(_ok('1200', minorDigits: 0), 1200),
  );

  test('more than the allowed decimals is rejected', () {
    expect(_err('1.234'), KeypadError.tooManyDecimals);
  });
  test('division by zero is an error', () {
    expect(_err('5÷0'), KeypadError.divisionByZero);
  });
  test('malformed expressions are errors', () {
    expect(_err('5++3'), KeypadError.malformed);
    expect(_err('×5'), KeypadError.malformed);
    expect(_err('1.2.3'), KeypadError.malformed);
  });
  test('a trailing operator is ignored while typing', () {
    expect(_ok('12+'), 1200);
  });
  test('negative results are rejected (amounts are always positive)', () {
    expect(_err('2−5'), KeypadError.negative);
  });
}
