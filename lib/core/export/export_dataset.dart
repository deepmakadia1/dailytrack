import 'package:clock/clock.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/period.dart';

/// SET-03 formats (FR-027, FR-028), each with its own unlock (FR-031).
enum ExportFormat {
  csv,
  pdf;

  FeatureKey get featureKey => switch (this) {
    ExportFormat.csv => FeatureKey.exportCsv,
    ExportFormat.pdf => FeatureKey.exportPdf,
  };

  String get extension => name;
}

/// What the user chose in SET-03.
final class ExportRequest {
  const new({
    required this.datasetId,
    required this.period,
    required this.format,
    this.filters = const {},
  });

  final String datasetId;
  final Period period;
  final ExportFormat format;

  /// Filter id → chosen option ids. An empty or missing set means all.
  final Map<String, Set<String>> filters;
}

/// What a dataset needs to localize and format its output (FR-029).
final class ExportContext {
  const new({
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.dateFormat,
    required this.clock,
  });

  final AppLocalizations l10n;
  final String locale;
  final String currencyCode;
  final FullDateFormat dateFormat;
  final Clock clock;
}

/// One choice in a filter (e.g. one account).
final class ExportOption {
  const new({required this.id, required this.label});

  final String id;
  final String label;
}

/// A dataset's filter, e.g. "Accounts" (SET-03 Transactions only).
abstract interface class ExportFilterSpec {
  String get id;
  String label(AppLocalizations l10n);
  Future<List<ExportOption>> options(
    ProviderReader read,
    AppLocalizations l10n,
  );
}

/// One kind of data a module can export (`TrackerModule.exportDatasets()`,
/// research R14): Expense offers transactions, Habit offers habits.
abstract interface class ExportDataset {
  /// Stable id, also used in file names and the route query.
  String get id;

  String label(AppLocalizations l10n);

  List<ExportFilterSpec> get filters;

  /// Reads local data only and never changes it.
  Future<ExportDocument> build(
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  );
}
