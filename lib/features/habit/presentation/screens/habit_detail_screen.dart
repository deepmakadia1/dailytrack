import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/share_capture.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_detail_controller.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:dailytrack/features/habit/presentation/widgets/charts/weekly_bars_chart.dart';
import 'package:dailytrack/features/habit/presentation/widgets/day_edit_sheet.dart';
import 'package:dailytrack/features/habit/presentation/widgets/freeze_card.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_calendar.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:dailytrack/features/habit/presentation/widgets/milestone_sheet.dart';
import 'package:dailytrack/features/habit/presentation/widgets/stat_tiles.dart';
import 'package:dailytrack/features/habit/presentation/widgets/year_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// HAB-03 Habit detail (spec US5, FR-029–FR-037, contracts/screens.md):
/// header, stat tiles, calendar, year heatmap, the gated weekly chart,
/// notes, and the streak freeze card, in that order. No ads.
class HabitDetailScreen extends ConsumerStatefulWidget {
  const new({required this.id, super.key});

  final String id;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  final GlobalKey _heatmap = GlobalKey();
  var _leaving = false;

  HabitDetailControllerProvider get _provider =>
      habitDetailControllerProvider(widget.id);

  HabitDetailController get _controller => ref.read(_provider.notifier);

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _afterWrite(HabitDetailData data, DayWriteResult result) async {
    if (result.milestone case final milestone?) {
      await showMilestoneSheet(
        context,
        habit: data.habit,
        milestone: milestone,
        unit: result.summary.unit,
      );
    }
  }

  Future<void> _editDay(HabitDetailData data, DayCell cell) async {
    final l10n = AppLocalizations.of(context);
    final edit = await showDayEditSheet(
      context,
      cell: cell,
      kind: data.habit.kind,
    );
    if (edit == null || !mounted) return;
    if (edit.done == null && edit.value == null && !edit.noteChanged) return;
    final result = await _controller.editDay(
      cell.date,
      done: edit.done,
      value: edit.value,
      note: edit.note,
      noteChanged: edit.noteChanged,
    );
    if (!mounted) return;
    if (result == null) {
      _snack(l10n.habit_saveError);
      return;
    }
    _snack(l10n.habit_daySaved);
    await _afterWrite(data, result);
  }

  Future<void> _useFreeze(HabitDetailData data, LocalDate day) async {
    final l10n = AppLocalizations.of(context);
    final result = await _controller.useFreeze(day);
    if (!mounted) return;
    if (result == null) {
      _snack(l10n.habit_saveError);
      return;
    }
    UndoSnackBar.show(
      context,
      message: l10n.habit_freezeUsed,
      onUndo: () => unawaited(_controller.undo(result.before)),
    );
    await _afterWrite(data, result);
  }

  Future<void> _addDebugFreeze() async {
    final l10n = AppLocalizations.of(context);
    final count = await _controller.addDebugFreeze();
    if (count == null && mounted) _snack(l10n.habit_saveError);
  }

  Future<void> _shareHeatmap() async {
    final l10n = AppLocalizations.of(context);
    final png = await captureBoundaryPng(_heatmap);
    final ok = png != null && await _controller.shareHeatmap(png);
    if (!ok && mounted) _snack(l10n.habit_shareError);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(_provider);

    ref.listen(_provider, (previous, next) {
      if (next.notFound && !_leaving) {
        _leaving = true;
        // HAB-02 (a full-screen page on the root navigator above the tabs)
        // explains its own delete or archive and navigates; only an
        // uncovered HAB-03 reports it.
        final covered = rootNavigatorKey.currentState?.canPop() ?? false;
        if (!covered) {
          rootMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(l10n.habit_notFound)),
          );
          context.go(Routes.habits);
        }
      }
    });

    final data = state.data.value;
    return AppScaffold(
      title: data?.habit.name ?? l10n.habit_detailTitle,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      padBody: false,
      actions: [
        if (data != null)
          IconButton(
            key: const Key('detail_edit'),
            tooltip: l10n.habit_edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                unawaited(context.push(Routes.habitEditPath(widget.id))),
          ),
      ],
      body: switch (state.data) {
        _ when state.notFound => const SizedBox.shrink(),
        AsyncData(:final value) => _Content(
          data: value,
          heatmapKey: _heatmap,
          onDay: (cell) => unawaited(_editDay(value, cell)),
          onUseFreeze: (day) => unawaited(_useFreeze(value, day)),
          onAddDebugFreeze: () => unawaited(_addDebugFreeze()),
          onShareHeatmap: () => unawaited(_shareHeatmap()),
          // PRM-02 (feature 009 FR-032): 24 hours of advanced reports, or
          // one more freeze for this habit, granted only by the reward.
          onWatchAdReports: () => unawaited(
            showRewardedUnlock(
              context,
              FeatureKey.advancedReports,
              duration: const Duration(hours: 24),
            ),
          ),
          onWatchAdFreeze: () => unawaited(
            showRewardedUnlock(
              context,
              FeatureKey.streakFreeze,
              grant: _controller.addRewardedFreeze,
              subjectName: value.habit.name,
            ),
          ),
          onGetPro: () => unawaited(context.push(Routes.premium)),
          isPro: ref.watch(proOwnedProvider),
          onAddProFreeze: () => unawaited(_controller.addProFreeze()),
        ),
        AsyncError() => ErrorState(
          message: l10n.habit_loadError,
          onRetry: _controller.retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList()),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const new({
    required this.data,
    required this.heatmapKey,
    required this.onDay,
    required this.onUseFreeze,
    required this.onAddDebugFreeze,
    required this.onShareHeatmap,
    required this.onWatchAdReports,
    required this.onWatchAdFreeze,
    required this.onGetPro,
    required this.isPro,
    required this.onAddProFreeze,
  });

  final HabitDetailData data;
  final GlobalKey heatmapKey;
  final ValueChanged<DayCell> onDay;
  final ValueChanged<LocalDate> onUseFreeze;
  final VoidCallback onAddDebugFreeze;
  final VoidCallback onShareHeatmap;
  final VoidCallback onWatchAdReports;
  final VoidCallback onWatchAdFreeze;
  final VoidCallback onGetPro;
  final bool isPro;
  final VoidCallback onAddProFreeze;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final habit = data.habit;
    final color = habitColor(habit);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = tokens.sidePadding(constraints.maxWidth);
        Widget padded(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: side),
          child: child,
        );
        Widget section(String title, Key key) => padded(
          Padding(
            padding: EdgeInsets.only(top: tokens.s24, bottom: tokens.s8),
            child: Semantics(
              header: true,
              child: Text(title, key: key, style: theme.textTheme.titleMedium),
            ),
          ),
        );

        return ListView(
          key: const Key('habit_detail'),
          padding: EdgeInsets.only(bottom: tokens.s48),
          children: [
            padded(
              Padding(
                key: const Key('detail_header'),
                padding: EdgeInsets.symmetric(vertical: tokens.s16),
                child: Row(
                  children: [
                    CategoryAvatar(
                      icon: habitIcon(habit),
                      color: color,
                      semanticLabel: habit.name,
                    ),
                    SizedBox(width: tokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name, style: theme.textTheme.titleLarge),
                          Text(
                            scheduleLabel(l10n, data.schedule),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            padded(
              StatTiles(key: const Key('stat_tiles'), summary: data.summary),
            ),
            section(l10n.habit_calendarTitle, const Key('section_calendar')),
            HabitCalendar(
              key: ValueKey('calendar_${habit.id}'),
              vm: data.vm,
              color: color,
              onDay: onDay,
            ),
            SizedBox(height: tokens.s16),
            padded(
              YearHeatmap(
                key: const Key('section_heatmap'),
                model: data.vm.heatmap,
                color: color,
                boundaryKey: heatmapKey,
                onShare: onShareHeatmap,
              ),
            ),
            section(l10n.habit_weeklyChartTitle, const Key('section_chart')),
            padded(
              data.advancedReportsUnlocked
                  ? WeeklyBarsChart(bars: data.vm.weeklyBars, color: color)
                  : LockedFeatureOverlay(
                      key: const Key('weekly_chart_locked'),
                      message: l10n.premium_advancedReportsMessage,
                      watchAdLabel: l10n.locked_watchAdReports,
                      onWatchAd: onWatchAdReports,
                      onGetPro: onGetPro,
                      child: WeeklyBarsChart(
                        bars: data.vm.weeklyBars,
                        color: color,
                      ),
                    ),
            ),
            section(l10n.habit_notesTitle, const Key('section_notes')),
            padded(
              NotesList(
                notes: [
                  for (final e in data.notes)
                    if (e.note case final note?) (date: e.date, note: note),
                ],
              ),
            ),
            SizedBox(height: tokens.s24),
            padded(
              FreezeCard(
                freezes: habit.freezesAvailable,
                freezeableDays: data.freezeableDays,
                showDebugButton: data.showDebugFreezeButton,
                onUse: onUseFreeze,
                onAddDebug: onAddDebugFreeze,
                onWatchAd: onWatchAdFreeze,
                isPro: isPro,
                onAddPro: onAddProFreeze,
              ),
            ),
          ],
        );
      },
    );
  }
}
