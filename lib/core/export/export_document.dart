/// What an export holds, independent of CSV or PDF (SET-03, feature 008
/// research R14, data-model §8). Modules build it; the settings feature
/// renders it, so neither imports the other. Pure Dart.
final class ExportDocument {
  const new({
    required this.title,
    required this.periodLabel,
    required this.summary,
    required this.columns,
    required this.rows,
    this.filterLines = const [],
    this.chart,
  });

  /// "Transactions" or "Habits".
  final String title;

  /// The chosen period, as shown to the user.
  final String periodLabel;

  /// Label and value pairs for the PDF summary (totals, rates).
  final List<(String, String)> summary;

  /// The filters in use, e.g. "Accounts: Cash, SBI".
  final List<String> filterLines;

  /// Donut slices for the PDF, or null for no chart.
  final List<ExportSlice>? chart;

  final List<ExportColumn> columns;
  final List<List<ExportCell>> rows;

  bool get isEmpty => rows.isEmpty;
}

enum ExportAlign { start, end }

final class ExportColumn {
  const new(this.header, {this.align = ExportAlign.start, this.flex = 1});

  final String header;
  final ExportAlign align;

  /// Relative PDF column width.
  final double flex;
}

/// One table cell.
sealed class ExportCell {
  const new();
}

/// Text as shown to the user (already localized).
final class TextCell extends ExportCell {
  const new(this.text);

  final String text;
}

/// An amount: CSV writes a plain decimal in major units, PDF the formatted
/// [display] text (FR-029).
final class MoneyCell extends ExportCell {
  const new(this.minor, {required this.fractionDigits, required this.display});

  /// Always positive minor units; the Type column carries the direction.
  final int minor;

  /// The currency's decimals (2 for INR, 0 for JPY).
  final int fractionDigits;

  /// The user's currency formatting, e.g. "₹1,250.50".
  final String display;

  /// "1250.50": no symbol, no grouping, `.` decimal separator.
  String get plain {
    if (fractionDigits == 0) return '$minor';
    final divisor = _pow10(fractionDigits);
    final whole = minor ~/ divisor;
    final fraction = (minor % divisor).toString().padLeft(fractionDigits, '0');
    return '$whole.$fraction';
  }

  static int _pow10(int n) {
    var v = 1;
    for (var i = 0; i < n; i++) {
      v *= 10;
    }
    return v;
  }
}

/// One donut slice: a label (already localized), its value, and its color.
final class ExportSlice {
  const new({
    required this.label,
    required this.valueMinor,
    required this.colorHex,
  });

  final String label;
  final int valueMinor;

  /// `#RRGGBB`.
  final String colorHex;
}
