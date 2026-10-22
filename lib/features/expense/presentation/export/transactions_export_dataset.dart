import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/utils/currencies.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:intl/intl.dart';

/// "Transactions" in SET-03 (FR-026 – FR-029, feature 008 research R14):
/// one row per transaction in the period and filters, oldest first; a
/// summary with totals and a donut of spending by category. Names are the
/// user's (seeded ones translated); amounts are positive and the Type
/// column gives the direction.
final class TransactionsExportDataset implements ExportDataset {
  const new();

  static const String datasetId = 'transactions';
  static const String accountsFilter = 'accounts';
  static const String categoriesFilter = 'categories';

  /// The donut shows at most this many slices; the rest are "Other".
  static const int maxSlices = 7;

  @override
  String get id => datasetId;

  @override
  String label(AppLocalizations l10n) => l10n.export_transactions;

  @override
  List<ExportFilterSpec> get filters => const [
    _AccountsFilter(),
    _CategoriesFilter(),
  ];

  @override
  Future<ExportDocument> build(
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  ) async {
    final l10n = context.l10n;
    final accounts = request.filters[accountsFilter] ?? const {};
    final categories = request.filters[categoriesFilter] ?? const {};
    final rows = await read(transactionRepositoryProvider).listForExport(
      TxnQuery(
        period: request.period,
        accountIds: accounts,
        categoryIds: categories,
      ),
    );

    final digits = currencyByCode(context.currencyCode)?.minorDigits ?? 2;
    MoneyCell money(int minor) => MoneyCell(
      minor,
      fractionDigits: digits,
      display: MoneyFormatter.format(minor, currencyCode: context.currencyCode),
    );
    final time = DateFormat('HH:mm', context.locale);

    var income = 0;
    var expense = 0;
    final byCategory = <String, (String, String, int)>{};
    for (final v in rows) {
      final t = v.transaction;
      if (t.type == TxnType.income) income += t.amountMinor;
      if (t.type == TxnType.expense) {
        expense += t.amountMinor;
        final c = v.category;
        if (c != null) {
          final (_, _, sum) = byCategory[c.id] ?? ('', '', 0);
          byCategory[c.id] = (
            l10n.categoryName(c),
            c.colorHex,
            sum + t.amountMinor,
          );
        }
      }
    }

    final filterLines = <String>[
      if (accounts.isNotEmpty)
        l10n.export_filterAccounts(
          _names(await const _AccountsFilter().options(read, l10n), accounts),
        ),
      if (categories.isNotEmpty)
        l10n.export_filterCategories(
          _names(
            await const _CategoriesFilter().options(read, l10n),
            categories,
          ),
        ),
    ];

    return ExportDocument(
      title: l10n.export_transactions,
      periodLabel: request.period.label(
        context.locale,
        RelativeDayLabels(
          today: l10n.common_today,
          yesterday: l10n.common_yesterday,
        ),
        now: context.clock.now(),
        fullDatePattern: context.dateFormat.pattern,
      ),
      summary: [
        (l10n.export_totalIncome, money(income).display),
        (l10n.export_totalExpense, money(expense).display),
        (
          l10n.export_net,
          MoneyFormatter.format(
            income - expense,
            currencyCode: context.currencyCode,
          ),
        ),
        (
          l10n.export_count,
          NumberFormat.decimalPattern(context.locale).format(rows.length),
        ),
      ],
      filterLines: filterLines,
      chart: _slices(byCategory.values, l10n),
      columns: [
        ExportColumn(l10n.export_colDate, flex: 1.4),
        ExportColumn(l10n.export_colTime, flex: 0.8),
        ExportColumn(l10n.export_colType),
        ExportColumn(l10n.export_colCategory, flex: 1.4),
        ExportColumn(l10n.export_colAccount, flex: 1.6),
        ExportColumn(l10n.export_colPaymentMode),
        ExportColumn(l10n.export_colAmount, align: ExportAlign.end, flex: 1.2),
        ExportColumn(l10n.export_colNote, flex: 2.4),
      ],
      rows: [for (final v in rows) _row(v, l10n, context, time, money)],
    );
  }

  static List<ExportCell> _row(
    TransactionView v,
    AppLocalizations l10n,
    ExportContext context,
    DateFormat time,
    MoneyCell Function(int) money,
  ) {
    final t = v.transaction;
    final local = Epoch.toLocal(t.occurredAt.millisecondsSinceEpoch);
    final to = v.toAccount;
    return [
      TextCell(formatFullDate(local, context.dateFormat, context.locale)),
      TextCell(time.format(local)),
      TextCell(l10n.txnType(t.type)),
      TextCell(v.category == null ? '' : l10n.categoryName(v.category!)),
      TextCell(
        to == null
            ? l10n.accountName(v.account)
            : l10n.export_transfer(
                l10n.accountName(v.account),
                l10n.accountName(to),
              ),
      ),
      TextCell(l10n.paymentMode(t.paymentMode)),
      money(t.amountMinor),
      TextCell(t.note ?? ''),
    ];
  }

  /// The biggest categories first; past [maxSlices], the rest are "Other".
  static List<ExportSlice>? _slices(
    Iterable<(String, String, int)> categories,
    AppLocalizations l10n,
  ) {
    final sorted = categories.toList()..sort((a, b) => b.$3.compareTo(a.$3));
    if (sorted.isEmpty) return null;
    final shown = sorted.length <= maxSlices
        ? sorted
        : sorted.take(maxSlices - 1).toList();
    final rest = sorted.skip(shown.length).fold(0, (sum, c) => sum + c.$3);
    return [
      for (final (label, color, value) in shown)
        ExportSlice(label: label, valueMinor: value, colorHex: color),
      if (rest > 0)
        ExportSlice(
          label: l10n.export_other,
          valueMinor: rest,
          colorHex: '#9CA3AF',
        ),
    ];
  }

  static String _names(List<ExportOption> options, Set<String> ids) => [
    for (final o in options)
      if (ids.contains(o.id)) o.label,
  ].join(', ');
}

final class _AccountsFilter implements ExportFilterSpec {
  const new();

  @override
  String get id => TransactionsExportDataset.accountsFilter;

  @override
  String label(AppLocalizations l10n) => l10n.export_accounts;

  @override
  Future<List<ExportOption>> options(
    ProviderReader read,
    AppLocalizations l10n,
  ) async => [
    for (final a in await read(
      accountRepositoryProvider,
    ).watchAllWithBalances().first)
      ExportOption(id: a.account.id, label: l10n.accountName(a.account)),
  ];
}

final class _CategoriesFilter implements ExportFilterSpec {
  const new();

  @override
  String get id => TransactionsExportDataset.categoriesFilter;

  @override
  String label(AppLocalizations l10n) => l10n.export_categories;

  @override
  Future<List<ExportOption>> options(
    ProviderReader read,
    AppLocalizations l10n,
  ) async => [
    for (final c in await read(categoryRepositoryProvider).watchAll().first)
      ExportOption(id: c.id, label: l10n.categoryName(c)),
  ];
}
