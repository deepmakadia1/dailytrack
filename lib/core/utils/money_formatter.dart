import 'package:dailytrack/core/utils/currencies.dart';

/// How to show the sign of an amount. Amounts are stored positive; the
/// caller knows from the transaction type whether to show + or −.
enum MoneySign {
  /// No sign for positive values, − for negative values.
  auto,
  plus,
  minus,
}

/// Formats integer minor units for display (spec §12, Constitution III).
///
/// Never converts to `double`: the whole and fractional parts are split with
/// integer math, so even very large values stay exact. Grouping is Indian
/// (12,34,567) for INR and Western (1,234,567) for every other currency, with
/// Latin digits in every UI language so an amount looks the same in en/hi/gu.
abstract final class MoneyFormatter {
  static const String minusSign = '−';

  static String format(
    int minor, {
    required String currencyCode,
    MoneySign sign = MoneySign.auto,
  }) {
    final info = currencyByCode(currencyCode);
    final digits = info?.minorDigits ?? 2;
    final symbol = info?.symbol ?? '$currencyCode ';

    final magnitude = BigInt.from(minor).abs();
    final divisor = BigInt.from(10).pow(digits);
    final whole = magnitude ~/ divisor;
    final fraction = magnitude % divisor;

    final grouped = currencyCode == 'INR'
        ? _groupIndian(whole.toString())
        : _groupWestern(whole.toString());
    final body = digits == 0
        ? grouped
        : '$grouped.${fraction.toString().padLeft(digits, '0')}';

    final prefix = switch (sign) {
      MoneySign.plus => '+',
      MoneySign.minus => minusSign,
      MoneySign.auto => minor < 0 ? minusSign : '',
    };
    return '$prefix$symbol$body';
  }

  static String _groupWestern(String digits) => _group(digits, 3, 3);

  static String _groupIndian(String digits) => _group(digits, 3, 2);

  /// Groups [digits] with [first] digits in the rightmost group and [rest]
  /// digits in every group to its left.
  static String _group(String digits, int first, int rest) {
    if (digits.length <= first) return digits;
    final head = digits.substring(0, digits.length - first);
    final tail = digits.substring(digits.length - first);
    final groups = <String>[];
    var end = head.length;
    while (end > 0) {
      final start = end - rest < 0 ? 0 : end - rest;
      groups.insert(0, head.substring(start, end));
      end = start;
    }
    return '${groups.join(',')},$tail';
  }
}
