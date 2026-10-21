/// One supported currency (research R5). Display names live in the ARB files
/// as `currency_<code>`, so they translate.
final class CurrencyInfo {
  const new(this.code, this.symbol, this.minorDigits);

  final String code;
  final String symbol;

  /// Digits after the decimal point (ISO 4217 minor unit).
  final int minorDigits;
}

/// The curated list of 30 currencies offered in SYS-02 step 2. INR is first.
const List<CurrencyInfo> currencies = [
  CurrencyInfo('INR', '₹', 2),
  CurrencyInfo('USD', r'$', 2),
  CurrencyInfo('EUR', '€', 2),
  CurrencyInfo('GBP', '£', 2),
  CurrencyInfo('AED', 'AED', 2),
  CurrencyInfo('SAR', 'SAR', 2),
  CurrencyInfo('QAR', 'QAR', 2),
  CurrencyInfo('KWD', 'KD', 3),
  CurrencyInfo('OMR', 'OMR', 3),
  CurrencyInfo('BHD', 'BD', 3),
  CurrencyInfo('SGD', r'S$', 2),
  CurrencyInfo('MYR', 'RM', 2),
  CurrencyInfo('THB', '฿', 2),
  CurrencyInfo('IDR', 'Rp', 2),
  CurrencyInfo('PHP', '₱', 2),
  CurrencyInfo('JPY', '¥', 0),
  CurrencyInfo('CNY', 'CN¥', 2),
  CurrencyInfo('HKD', r'HK$', 2),
  CurrencyInfo('KRW', '₩', 0),
  CurrencyInfo('AUD', r'A$', 2),
  CurrencyInfo('NZD', r'NZ$', 2),
  CurrencyInfo('CAD', r'CA$', 2),
  CurrencyInfo('CHF', 'CHF', 2),
  CurrencyInfo('SEK', 'kr', 2),
  CurrencyInfo('NOK', 'kr', 2),
  CurrencyInfo('DKK', 'kr', 2),
  CurrencyInfo('ZAR', 'R', 2),
  CurrencyInfo('NPR', 'Rs', 2),
  CurrencyInfo('BDT', '৳', 2),
  CurrencyInfo('LKR', 'Rs', 2),
];

CurrencyInfo? currencyByCode(String code) {
  for (final c in currencies) {
    if (c.code == code) return c;
  }
  return null;
}

/// Currencies whose code or localized name contains [query]
/// (case-insensitive). [nameOf] resolves a code to its display name.
List<CurrencyInfo> filterCurrencies(
  String query,
  String Function(String code) nameOf,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return currencies;
  return [
    for (final c in currencies)
      if (c.code.toLowerCase().contains(q) ||
          nameOf(c.code).toLowerCase().contains(q))
        c,
  ];
}
