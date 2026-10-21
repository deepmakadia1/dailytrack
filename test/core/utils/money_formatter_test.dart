import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter', () {
    test('INR uses Indian grouping', () {
      expect(
        MoneyFormatter.format(123456700, currencyCode: 'INR'),
        '₹12,34,567.00',
      );
    });

    test('formats minor units exactly', () {
      expect(MoneyFormatter.format(1050, currencyCode: 'INR'), '₹10.50');
      expect(MoneyFormatter.format(5, currencyCode: 'INR'), '₹0.05');
      expect(MoneyFormatter.format(0, currencyCode: 'INR'), '₹0.00');
    });

    test('explicit sign uses + and the true minus sign (U+2212)', () {
      expect(
        MoneyFormatter.format(1050, currencyCode: 'INR', sign: MoneySign.plus),
        '+₹10.50',
      );
      expect(
        MoneyFormatter.format(1050, currencyCode: 'INR', sign: MoneySign.minus),
        '−₹10.50',
      );
    });

    test('negative values get a minus sign automatically', () {
      expect(MoneyFormatter.format(-1050, currencyCode: 'INR'), '−₹10.50');
    });

    test('other currencies use Western grouping', () {
      expect(
        MoneyFormatter.format(123456700, currencyCode: 'USD'),
        r'$1,234,567.00',
      );
    });

    test('minor digits come from the currency table', () {
      expect(MoneyFormatter.format(1234, currencyCode: 'JPY'), '¥1,234');
      expect(MoneyFormatter.format(1234, currencyCode: 'KWD'), 'KD1.234');
    });

    test('very large values keep exact precision (no double rounding)', () {
      // 2^53 + 1 minor units would be rounded if converted to double.
      expect(
        // The app never compiles to JavaScript, so JS precision is irrelevant.
        // ignore: avoid_js_rounded_ints
        MoneyFormatter.format(9007199254740993, currencyCode: 'USD'),
        r'$90,071,992,547,409.93',
      );
    });

    test('unknown currency codes fall back to the code as the symbol', () {
      expect(MoneyFormatter.format(100, currencyCode: 'XYZ'), 'XYZ 1.00');
    });
  });
}
