import 'package:dailytrack/core/utils/result.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// SC-002 / EXP-02: "Amount is stored in paise without rounding errors
/// (e.g. 10.10 → 1010)."
void main() {
  int ok(String input) => switch (AmountEntry.parse(input)) {
    Ok(:final value) => value,
    Err(:final error) => fail('$input → $error'),
  };
  AmountError err(String input) => switch (AmountEntry.parse(input)) {
    Ok(:final value) => fail('$input → $value, expected an error'),
    Err(:final error) => error,
  };

  test('named examples are exact', () {
    expect(ok('10.10'), 1010);
    expect(ok('0.29'), 29);
    expect(ok('0.01'), 1);
    expect(ok('125000.55'), 12500055);
    expect(ok('99999999.99'), 9999999999);
    expect(ok('99999999'), 9999999900);
    expect(ok('12.5'), 1250);
    expect(ok('.5'), 50);
  });

  test('1,000+ generated amounts round-trip with no error', () {
    var checked = 0;
    // Every paise value 1..1000 plus a spread of large ones.
    final values = [
      for (var i = 1; i <= 1000; i++) i,
      for (var i = 1; i <= 200; i++) i * 499999937 % 9999999999 + 1,
    ];
    for (final minor in values) {
      final rupees = minor ~/ 100;
      final paise = (minor % 100).toString().padLeft(2, '0');
      final text = '$rupees.$paise';
      expect(ok(text), int.parse('$rupees$paise'), reason: text);
      checked++;
    }
    expect(checked, greaterThanOrEqualTo(1000));
  });

  test('calculator results with more than 2 decimals round half up', () {
    expect(ok('10÷3'), 333);
    expect(ok('2÷3'), 67);
    expect(ok('120+35.50'), 15550);
    expect(ok('3×1.11'), 333);
    expect(ok('100−0.01'), 9999);
  });

  test('a trailing operator is ignored while typing', () {
    expect(ok('250+'), 25000);
  });

  test('empty or zero is "required"', () {
    expect(err(''), AmountError.required);
    expect(err('0'), AmountError.required);
    expect(err('0.00'), AmountError.required);
    expect(err('5−5'), AmountError.required);
  });

  test('above ₹99,99,99,999.00 is "tooLarge"; the maximum is accepted', () {
    expect(ok('999999999'), AmountEntry.maxMinor);
    expect(err('999999999.01'), AmountError.tooLarge);
    expect(err('9999999999999999999999'), AmountError.tooLarge);
  });

  test('÷0, negative results and 3+ typed decimals are "invalid"', () {
    expect(err('5÷0'), AmountError.invalid);
    expect(err('5−6'), AmountError.invalid);
    expect(err('1.234'), AmountError.invalid);
    expect(err('1..2'), AmountError.invalid);
  });
}
