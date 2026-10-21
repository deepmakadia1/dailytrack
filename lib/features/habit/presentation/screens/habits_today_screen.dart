import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_controller.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_card.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_card_menu.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_dialogs.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:dailytrack/features/habit/presentation/widgets/milestone_sheet.dart';
import 'package:dailytrack/features/habit/presentation/widgets/progress_header.dart';
import 'package:dailytrack/features/habit/presentation/widgets/template_chips.dart';
import 'package:dailytrack/features/habit/presentation/widgets/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// HAB-01 Habits today (spec US1, FR-016–FR-023, contracts/screens.md):
/// week strip, progress header, scheduled habits, then a collapsed "Not
/// scheduled today" section. No ads (out of scope).
class HabitsTodayScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HabitsTodayScreen> createState() => _HabitsTodayScreenState();
}

/// What a write did to the day, for feedback.
enum _Change { checked, unchecked, other }

class _HabitsTodayScreenState extends ConsumerState<HabitsTodayScreen> {
  late final AppLifecycleListener _lifecycle;

  HabitsTodayController get _controller =>
      ref.read(habitsTodayControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // A new local day on resume resets the selection (research R14).
    _lifecycle = AppLifecycleListener(
      onResume: () => _controller.checkDayRollover(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Feedback after a day write: haptic on a new check-in (FR-019), Undo
  /// after an uncheck, the milestone sheet (FR-044), or an error.
  Future<void> _after(
    HabitCardData card,
    Future<DayWriteResult?> write,
    _Change change,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await write;
    if (!mounted) return;
    if (result == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      return;
    }
    switch (change) {
      case _Change.checked:
        unawaited(HapticFeedback.lightImpact());
      case _Change.unchecked:
        UndoSnackBar.show(
          context,
          message: l10n.habit_unchecked,
          onUndo: () => unawaited(_controller.undo(result.before)),
        );
      case _Change.other:
        break;
    }
    if (result.milestone case final milestone?) {
      await showMilestoneSheet(
        context,
        habit: card.habit,
        milestone: milestone,
        unit: result.summary.unit,
      );
    }
  }

  void _toggle(HabitCardData card) => unawaited(
    _after(
      card,
      _controller.toggle(card.id),
      card.isDone ? _Change.unchecked : _Change.checked,
    ),
  );

  void _increment(HabitCardData card) => unawaited(
    _after(
      card,
      _controller.increment(card.id),
      !card.isDone && card.value + 1 >= card.target
          ? _Change.checked
          : _Change.other,
    ),
  );

  Future<void> _enterValue(HabitCardData card) async {
    final value = await showValueEntryDialog(
      context,
      habitName: card.habit.name,
      value: card.value,
    );
    if (value == null || !mounted) return;
    await _after(
      card,
      _controller.setValue(card.id, value),
      !card.isDone && value >= card.target
          ? _Change.checked
          : card.isDone && value < card.target
          ? _Change.unchecked
          : _Change.other,
    );
  }

  Future<void> _menu(HabitCardData card, {required bool today}) async {
    final l10n = AppLocalizations.of(context);
    final action = await showHabitCardMenu(
      context,
      card: card,
      selectedIsToday: today,
    );
    if (action == null || !mounted) return;
    switch (action) {
      case HabitCardAction.edit:
        unawaited(context.push(Routes.habitEditPath(card.id)));
      case HabitCardAction.addNote:
        final note = await showNoteDialog(context, note: card.note);
        if (note == null || !mounted) return;
        final result = await _controller.setNote(card.id, note);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result == null ? l10n.habit_saveError : l10n.habit_noteSaved,
            ),
          ),
        );
      case HabitCardAction.skipToday:
        final result = await _controller.skipToday(card.id);
        if (!mounted) return;
        if (result == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
          return;
        }
        UndoSnackBar.show(
          context,
          message: l10n.habit_skipped,
          onUndo: () => unawaited(_controller.undo(result.before)),
        );
      case HabitCardAction.archive:
        final ok = await _controller.archive(card.id);
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
          return;
        }
        UndoSnackBar.show(
          context,
          message: l10n.habit_archived,
          onUndo: () => unawaited(_controller.undoArchive(card.id)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(habitsTodayControllerProvider);
    final data = state.data.value;
    final reorder = data?.reorderMode ?? false;

    return AppScaffold(
      title: l10n.habit_title,
      largeTitle: true,
      showBack: false,
      // The week strip spans the full width; the rest pads itself.
      padBody: false,
      actions: [
        if (reorder)
          TextButton(
            key: const Key('reorder_done'),
            onPressed: () => _controller.setReorderMode(on: false),
            child: Text(l10n.habit_reorderDone),
          )
        else
          PopupMenuButton<String>(
            key: const Key('habits_overflow'),
            tooltip: l10n.habit_moreOptions,
            onSelected: (value) => switch (value) {
              'archived' => unawaited(context.push(Routes.habitArchived)),
              _ => _controller.setReorderMode(on: true),
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                key: const Key('menu_archived'),
                value: 'archived',
                child: Text(l10n.habit_menuArchived),
              ),
              if (data != null && !data.isEmpty)
                PopupMenuItem(
                  key: const Key('menu_reorder'),
                  value: 'reorder',
                  child: Text(l10n.habit_menuReorder),
                ),
            ],
          ),
      ],
      fab: reorder
          ? null
          : FloatingActionButton(
              key: const Key('habit_fab'),
              tooltip: l10n.habit_addHabit,
              onPressed: () => unawaited(context.push(Routes.habitAddPath())),
              child: const Icon(Icons.add),
            ),
      body: switch (state.data) {
        AsyncData(:final value) when value.isEmpty => _Empty(
          onTemplate: (t) =>
              unawaited(context.push(Routes.habitAddPath(template: t.id))),
        ),
        AsyncData(:final value) when value.reorderMode => _ReorderList(
          data: value,
          onReorder: (ids) => unawaited(_controller.reorder(ids)),
        ),
        AsyncData(:final value) => _Content(
          data: value,
          onSelectDay: _controller.selectDay,
          onPageWeek: _controller.pageWeek,
          onToggle: _toggle,
          onIncrement: _increment,
          onEnterValue: (c) => unawaited(_enterValue(c)),
          onMenu: (c) => unawaited(_menu(c, today: value.selectedIsToday)),
          onOpen: (c) => unawaited(context.push(Routes.habitDetailPath(c.id))),
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

class _Empty extends StatelessWidget {
  const new({required this.onTemplate});

  final ValueChanged<HabitTemplate> onTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: tokens.s24,
        horizontal: tokens.screenPadding,
      ),
      child: Column(
        children: [
          EmptyState(
            title: l10n.habit_emptyTitle,
            message: l10n.habit_emptyBody,
            illustration: Icon(
              Icons.self_improvement,
              size: tokens.s48 * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: tokens.s16),
          TemplateChips(onSelected: onTemplate),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const new({
    required this.data,
    required this.onSelectDay,
    required this.onPageWeek,
    required this.onToggle,
    required this.onIncrement,
    required this.onEnterValue,
    required this.onMenu,
    required this.onOpen,
  });

  final HabitsTodayData data;
  final ValueChanged<LocalDate> onSelectDay;
  final ValueChanged<int> onPageWeek;
  final ValueChanged<HabitCardData> onToggle;
  final ValueChanged<HabitCardData> onIncrement;
  final ValueChanged<HabitCardData> onEnterValue;
  final ValueChanged<HabitCardData> onMenu;
  final ValueChanged<HabitCardData> onOpen;

  Widget _card(HabitCardData c) => HabitCard(
    card: c,
    onToggle: () => onToggle(c),
    onIncrement: () => onIncrement(c),
    onEnterValue: () => onEnterValue(c),
    onMenu: () => onMenu(c),
    onOpen: () => onOpen(c),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = EdgeInsets.symmetric(
          horizontal: tokens.sidePadding(constraints.maxWidth),
        );
        return ListView(
          key: const Key('habits_list'),
          padding: EdgeInsets.only(bottom: tokens.s48 * 2),
          children: [
            WeekStrip(
              week: data.week,
              selected: data.selected,
              weekOffset: data.weekOffset,
              onSelect: onSelectDay,
              onPage: onPageWeek,
            ),
            Padding(
              padding: side,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.s12),
                  ProgressHeader(
                    done: data.doneCount,
                    total: data.scheduledCount,
                  ),
                  SizedBox(height: tokens.s12),
                  if (data.allDoneToday) ...[
                    const AllDoneBanner(),
                    SizedBox(height: tokens.s12),
                  ],
                  if (data.scheduled.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: tokens.s16),
                      child: Text(
                        l10n.habit_noneScheduled,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final c in data.scheduled) _card(c),
                  if (data.notScheduled.isNotEmpty)
                    ExpansionTile(
                      key: const Key('not_scheduled_section'),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Text(
                        data.selectedIsToday
                            ? l10n.habit_notScheduledToday
                            : l10n.habit_notScheduledOnDay,
                        style: theme.textTheme.titleSmall,
                      ),
                      children: [for (final c in data.notScheduled) _card(c)],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Reorder mode (US1-11, FR-021): drag habits; the order is saved.
class _ReorderList extends StatefulWidget {
  const new({required this.data, required this.onReorder});

  final HabitsTodayData data;
  final ValueChanged<List<String>> onReorder;

  @override
  State<_ReorderList> createState() => _ReorderListState();
}

class _ReorderListState extends State<_ReorderList> {
  late List<String> _ids = [for (final h in widget.data.habits) h.id];

  @override
  void didUpdateWidget(_ReorderList old) {
    super.didUpdateWidget(old);
    _ids = [for (final h in widget.data.habits) h.id];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byId = {for (final h in widget.data.habits) h.id: h};
    return ReorderableListView(
      key: const Key('reorder_list'),
      buildDefaultDragHandles: false,
      onReorderItem: (from, to) {
        setState(() => _ids.insert(to, _ids.removeAt(from)));
        widget.onReorder([..._ids]);
      },
      children: [
        for (final (index, id) in _ids.indexed)
          ListTile(
            key: ValueKey('reorder_$id'),
            leading: CategoryAvatar(
              icon: habitIcon(byId[id]!),
              color: habitColor(byId[id]!),
              semanticLabel: byId[id]!.name,
            ),
            title: Text(byId[id]!.name),
            trailing: ReorderableDragStartListener(
              index: index,
              child: Semantics(
                label: l10n.habit_reorderHandle(byId[id]!.name),
                child: const Icon(Icons.drag_handle),
              ),
            ),
          ),
      ],
    );
  }
}
