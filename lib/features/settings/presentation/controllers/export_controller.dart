import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:dailytrack/features/settings/export_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_controller.freezed.dart';
part 'export_controller.g.dart';

/// What SET-03 shows (feature 008 contracts/screens.md "SET-03").
@freezed
abstract class ExportState with _$ExportState {
  const factory({
    /// The enabled modules' datasets, in module order.
    required List<ExportDataset> datasets,
    required String datasetId,
    required Period period,
    required ExportFormat format,

    /// Filter id → chosen option ids; empty means all.
    required Map<String, Set<String>> filters,

    /// Whether each format is unlocked, live from the feature gate.
    required Map<ExportFormat, bool> unlocked,
    required int firstDayOfWeek,
    @Default(false) bool running,
  }) = _ExportState;

  const new _();

  ExportDataset get dataset => datasets.firstWhere(
    (d) => d.id == datasetId,
    orElse: () => datasets.first,
  );

  bool get canExport => unlocked[format] ?? false;
}

/// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
/// rewarded unlocks and Pro change it while SET-03 is open.
@riverpod
Stream<bool> exportUnlocked(Ref ref, ExportFormat format) =>
    ref.watch(featureGateProvider).watch(format.featureKey);

/// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
/// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".
@riverpod
class ExportController extends _$ExportController {
  @override
  Future<ExportState> build({String? datasetId, String? periodQuery}) async {
    final settings = await ref.read(settingsRepositoryProvider).load();
    final datasets = [
      for (final m in ref.read(moduleRegistryProvider).visible(settings))
        ...m.exportDatasets(),
    ];
    final now = ref.read(clockProvider).now();
    final fromQuery = periodQuery == null
        ? null
        : periodFromQuery(
            Uri.splitQueryString(periodQuery),
            firstDayOfWeek: settings.firstDayOfWeek,
          );
    final gate = ref.read(featureGateProvider);
    final unlocked = {
      for (final f in ExportFormat.values)
        f: await gate.isUnlocked(f.featureKey),
    };
    for (final f in ExportFormat.values) {
      ref.listen(exportUnlockedProvider(f), (_, next) {
        final value = next.value;
        final current = state.value;
        if (value != null && current != null) {
          state = AsyncData(
            current.copyWith(unlocked: {...current.unlocked, f: value}),
          );
        }
      });
    }
    return ExportState(
      datasets: datasets,
      datasetId: datasets.any((d) => d.id == datasetId)
          ? datasetId!
          : (datasets.isEmpty ? '' : datasets.first.id),
      period: fromQuery ?? MonthPeriod(now),
      format: ExportFormat.csv,
      filters: const {},
      unlocked: unlocked,
      firstDayOfWeek: settings.firstDayOfWeek,
    );
  }

  /// Error state "Try again".
  void retry() => ref.invalidateSelf();

  void _update(ExportState Function(ExportState) change) {
    final current = state.value;
    if (current != null) state = AsyncData(change(current));
  }

  /// Filters belong to a dataset, so they reset with it.
  void setDataset(String id) =>
      _update((s) => s.copyWith(datasetId: id, filters: const {}));

  void setPeriod(Period period) => _update((s) => s.copyWith(period: period));

  void setFormat(ExportFormat format) =>
      _update((s) => s.copyWith(format: format));

  void setFilter(String filterId, Set<String> ids) =>
      _update((s) => s.copyWith(filters: {...s.filters, filterId: ids}));

  /// The options of one filter of the current dataset.
  Future<List<ExportOption>> filterOptions(
    String filterId,
    AppLocalizations l10n,
  ) async {
    final dataset = state.value!.dataset;
    final spec = dataset.filters.firstWhere((f) => f.id == filterId);
    return await spec.options(ref.read, l10n);
  }

  /// Builds the file and, when ready, opens the share sheet (FR-030).
  /// Returns the outcome for the screen's message.
  Future<ExportOutcome> export(AppLocalizations l10n, String locale) async {
    final s = state.value!;
    _update((s) => s.copyWith(running: true));
    try {
      final settings = await ref.read(settingsRepositoryProvider).load();
      final outcome = await ref
          .read(exportUseCaseProvider)
          .run(
            s.dataset,
            ExportRequest(
              datasetId: s.datasetId,
              period: s.period,
              format: s.format,
              filters: s.filters,
            ),
            ExportContext(
              l10n: l10n,
              locale: locale,
              currencyCode: settings.currencyCode,
              dateFormat: FullDateFormat.fromStorage(settings.dateFormat),
              clock: ref.read(clockProvider),
            ),
            ref.read,
          );
      if (outcome case ExportReady(:final path, :final mimeType)) {
        await ref.read(fileSharerProvider).shareFile(path, mimeType: mimeType);
      }
      return outcome;
    } finally {
      _update((s) => s.copyWith(running: false));
    }
  }
}
