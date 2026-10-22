import 'package:dailytrack/core/export/export_document.dart';

/// A Gujarati note with a conjunct (ક્ષ) and an emoji.
const String gujaratiNote = 'આજે ચા ☕ ક્ષમા';

/// A Hindi note with a conjunct (क्ष), a comma, and quotes.
const String hindiNote = 'दूध, ब्रेड "और" क्षमा';

MoneyCell inr(int minor, String display) =>
    MoneyCell(minor, fractionDigits: 2, display: display);

/// A transactions-shaped document with Hindi and Gujarati notes.
ExportDocument sampleDocument({int extraRows = 0}) => ExportDocument(
  title: 'Transactions',
  periodLabel: 'October 2026',
  summary: [('Total expense', '₹1,250.50'), ('Net', '−₹1,250.50')],
  filterLines: const ['Accounts: Cash'],
  chart: const [
    ExportSlice(label: 'Food', valueMinor: 100000, colorHex: '#F97316'),
    ExportSlice(label: 'ચા', valueMinor: 25050, colorHex: '#7C3AED'),
  ],
  columns: const [
    ExportColumn('Date'),
    ExportColumn('Type'),
    ExportColumn('Amount', align: ExportAlign.end),
    ExportColumn('Note'),
  ],
  rows: [
    [
      const TextCell('21 Oct 2026'),
      const TextCell('Expense'),
      inr(125050, '₹1,250.50'),
      const TextCell(gujaratiNote),
    ],
    [
      const TextCell('21 Oct 2026'),
      const TextCell('Income'),
      inr(99999999900, '₹99,99,99,999.00'),
      const TextCell(hindiNote),
    ],
    [
      const TextCell('22 Oct 2026'),
      const TextCell('Expense'),
      inr(5, '₹0.05'),
      const TextCell('line one\nline two'),
    ],
    for (var i = 0; i < extraRows; i++)
      [
        const TextCell('23 Oct 2026'),
        const TextCell('Expense'),
        inr(100 + i, '₹1.00'),
        TextCell('Row $i'),
      ],
  ],
);
