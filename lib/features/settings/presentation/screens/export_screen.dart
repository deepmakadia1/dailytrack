import 'dart:async';

import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/period_picker_sheet.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:dailytrack/features/settings/presentation/controllers/export_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-03 Export data (spec §10, feature 008 contracts/screens.md): data
/// type, period, format, filters (Transactions only), and one Export
/// button; the file opens in the share sheet. A fixed set of controls, so
/// it has no empty state (plan Complexity Tracking); "nothing to export" is
/// an outcome. Locked formats show the locked-feature overlay with no ad
/// action until rewarded ads exist (FR-031). No ads.
class ExportScreen extends ConsumerWidget {
  const new({super.key, this.datasetId, this.periodQuery});

  /// Prefill from the route, e.g. EXP-11 "Export this report".
  final String? datasetId;
  final String? periodQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = exportControllerProvider(
      datasetId: datasetId,
      periodQuery: periodQuery,
    );
    final async = ref.watch(provider);
    return AppScaffold(
      title: l10n.export_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) => _ExportForm(
          state: value,
          controller: ref.read(provider.notifier),
        ),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(provider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 4)),
      },
    );
  }
}

class _ExportForm extends ConsumerWidget {
  const new({required this.state, required this.controller});

  final ExportState state;
  final ExportController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final now = ref.watch(clockProvider).now();
    final dataset = state.datasets.isEmpty ? null : state.dataset;

    Future<void> pickPeriod() async {
      final picked = await PeriodPickerSheet.show(
        context,
        current: state.period,
        firstDayOfWeek: state.firstDayOfWeek,
        now: now,
        kinds: const {
          PeriodKind.week,
          PeriodKind.month,
          PeriodKind.year,
          PeriodKind.custom,
        },
      );
      if (picked != null) controller.setPeriod(picked);
    }

    Future<void> runExport() async {
      final messenger = ScaffoldMessenger.of(context);
      final outcome = await controller.export(
        l10n,
        Localizations.localeOf(context).toString(),
      );
      switch (outcome) {
        case ExportNothing():
          messenger.showSnackBar(
            SnackBar(
              key: const Key('export_nothing'),
              content: Text(l10n.export_nothing),
            ),
          );
        case ExportFailed():
          if (!context.mounted) return;
          await showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              key: const Key('export_error'),
              title: Text(l10n.export_failedTitle),
              content: Text(l10n.export_failed),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialog).pop(),
                  child: Text(l10n.common_cancel),
                ),
              ],
            ),
          );
        case ExportLocked() || ExportReady():
          break;
      }
    }

    final exportButton = FilledButton.icon(
      key: const Key('export_button'),
      onPressed: state.running || !state.canExport || dataset == null
          ? null
          : () => unawaited(runExport()),
      icon: state.running
          ? SizedBox.square(
              dimension: tokens.s16,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.ios_share),
      label: Text(state.running ? l10n.export_working : l10n.export_button),
    );

    return ListView(
      children: [
        SettingsSection(
          title: l10n.export_dataType,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.s16),
              child: ChipSelector<String>(
                key: const Key('export_dataset'),
                options: [for (final d in state.datasets) d.id],
                selected: {state.datasetId},
                labelBuilder: (id) =>
                    state.datasets.firstWhere((d) => d.id == id).label(l10n),
                onChanged: (ids) {
                  if (ids.isNotEmpty) controller.setDataset(ids.first);
                },
              ),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.export_period,
          children: [
            PeriodSelector(
              key: const Key('export_period'),
              period: state.period,
              now: now,
              onChanged: controller.setPeriod,
              onPick: () => unawaited(pickPeriod()),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.export_format,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.s16),
              child: ChipSelector<ExportFormat>(
                key: const Key('export_format'),
                options: ExportFormat.values,
                selected: {state.format},
                labelBuilder: (f) => switch (f) {
                  ExportFormat.csv => l10n.export_csv,
                  ExportFormat.pdf => l10n.export_pdf,
                },
                onChanged: (formats) {
                  if (formats.isNotEmpty) controller.setFormat(formats.first);
                },
              ),
            ),
          ],
        ),
        if (dataset != null && dataset.filters.isNotEmpty)
          SettingsSection(
            title: l10n.export_filtersTitle,
            children: [
              for (final spec in dataset.filters)
                _FilterRow(
                  spec: spec,
                  selected: state.filters[spec.id] ?? const {},
                  controller: controller,
                ),
            ],
          ),
        Padding(
          padding: EdgeInsets.all(tokens.s16),
          child: state.canExport
              ? exportButton
              : LockedFeatureOverlay(
                  key: const Key('export_locked'),
                  message: l10n.export_locked,
                  child: exportButton,
                ),
        ),
      ],
    );
  }
}

/// "Accounts: All" or "3 selected"; opens a multi-select sheet.
class _FilterRow extends StatelessWidget {
  const new({
    required this.spec,
    required this.selected,
    required this.controller,
  });

  final ExportFilterSpec spec;
  final Set<String> selected;
  final ExportController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Future<void> pick() async {
      final options = await controller.filterOptions(spec.id, l10n);
      if (!context.mounted) return;
      final picked = await AppBottomSheet.show<Set<String>>(
        context,
        title: spec.label(l10n),
        child: _FilterSheet(options: options, selected: selected),
      );
      if (picked != null) controller.setFilter(spec.id, picked);
    }

    return ListTile(
      key: Key('export_filter_${spec.id}'),
      title: Text(spec.label(l10n)),
      subtitle: Text(
        selected.isEmpty
            ? l10n.export_all
            : l10n.export_selected(selected.length),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => unawaited(pick()),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const new({required this.options, required this.selected});

  final List<ExportOption> options;
  final Set<String> selected;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<String> _chosen = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final o in widget.options)
                CheckboxListTile(
                  key: Key('export_option_${o.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(o.label),
                  value: _chosen.contains(o.id),
                  onChanged: (on) => setState(
                    () =>
                        on ?? false ? _chosen.add(o.id) : _chosen.remove(o.id),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: tokens.s16),
        FilledButton(
          key: const Key('export_filter_apply'),
          onPressed: () => Navigator.of(context).pop(_chosen),
          child: Text(l10n.export_filterDone),
        ),
      ],
    );
  }
}
