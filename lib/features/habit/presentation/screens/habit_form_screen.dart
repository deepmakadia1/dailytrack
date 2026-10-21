import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/templates.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_form_controller.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:dailytrack/features/habit/presentation/widgets/reminders_section.dart';
import 'package:dailytrack/features/habit/presentation/widgets/schedule_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// HAB-02 Add / edit habit (spec US1-2, US1-12, US1-13, FR-024–FR-028,
/// US4): a full-screen single-scroll form above the shell with a sticky
/// "Save habit". [templateId] prefills a new habit (research R16).
class HabitFormScreen extends ConsumerStatefulWidget {
  const new({this.id, this.templateId, super.key});

  /// The habit to edit; null for a new one.
  final String? id;
  final String? templateId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _unit = TextEditingController();

  /// Set once a save, archive, or delete succeeded, so leaving skips the
  /// discard question.
  var _leaving = false;
  var _filled = false;

  HabitFormControllerProvider get _provider =>
      habitFormControllerProvider(widget.id);

  HabitFormController get _controller => ref.read(_provider.notifier);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final template = habitTemplateById(widget.templateId);
    if (widget.id == null && template != null && !_filled) {
      final l10n = AppLocalizations.of(context);
      // After the first frame: providers must not change during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyTemplate(template, l10n);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _applyTemplate(HabitTemplate t, AppLocalizations l10n) {
    final name = templateName(l10n, t);
    final unit = templateUnit(l10n, t);
    _controller.applyTemplate(t, name: name, unit: unit);
    _fill(ref.read(_provider));
  }

  /// Copies the loaded draft into the text fields once.
  void _fill(HabitFormState s) {
    _filled = true;
    _name.text = s.draft.name;
    _target.text = '${s.draft.schedule.target}';
    _unit.text = s.draft.unit ?? '';
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.habits);
    }
  }

  /// After archive or delete the habit's own pages are gone, so return to
  /// HAB-01 rather than to the page under this one.
  void _backToList() => context.go(Routes.habits);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = rootMessengerKey.currentState;
    final saved = await _controller.save();
    if (!mounted) return;
    if (saved == null) {
      if (ref.read(_provider).saveFailed) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      }
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    messenger?.showSnackBar(SnackBar(content: Text(l10n.habit_saved)));
    setState(() => _leaving = true);
    _close();
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final messenger = rootMessengerKey.currentState;
    final undo = await _controller.archive();
    if (!mounted) return;
    if (undo == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      return;
    }
    UndoSnackBar.show(
      context,
      message: l10n.habit_archived,
      onUndo: () => unawaited(undo()),
      messenger: messenger,
    );
    setState(() => _leaving = true);
    _backToList();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final name = ref.read(_provider).original?.name ?? '';
    final messenger = rootMessengerKey.currentState;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.habit_deleteTitle,
      consequence: l10n.habit_deleteBody(name),
      confirmLabel: l10n.habit_deleteConfirm,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await _controller.delete();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      return;
    }
    messenger?.showSnackBar(SnackBar(content: Text(l10n.habit_deleted)));
    setState(() => _leaving = true);
    _backToList();
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await ConfirmDialog.show(
      context,
      title: l10n.habit_discardTitle,
      consequence: l10n.habit_discardBody,
      confirmLabel: l10n.habit_discardConfirm,
      destructive: true,
    );
    if (!discard || !mounted) return;
    setState(() => _leaving = true);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(_provider);

    ref.listen(_provider, (previous, next) {
      if (next.status == HabitFormStatus.ready &&
          previous?.status != HabitFormStatus.ready &&
          !_filled) {
        _fill(next);
      }
      if (next.status == HabitFormStatus.notFound && !_leaving) {
        rootMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.habit_notFound)),
        );
        _leaving = true;
        context.go(Routes.habits);
      }
    });
    if (state.status == HabitFormStatus.ready && !_filled) _fill(state);

    return PopScope(
      canPop: !state.dirty || _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmDiscard());
      },
      child: AppScaffold(
        title: state.isEdit ? l10n.habit_editTitle : l10n.habit_addTitle,
        actions: [
          if (state.isEdit)
            PopupMenuButton<String>(
              key: const Key('habit_form_overflow'),
              tooltip: l10n.habit_moreOptions,
              onSelected: (v) =>
                  unawaited(v == 'archive' ? _archive() : _delete()),
              itemBuilder: (context) => [
                PopupMenuItem(
                  key: const Key('form_archive'),
                  value: 'archive',
                  child: Text(l10n.habit_menuArchive),
                ),
                PopupMenuItem(
                  key: const Key('form_delete'),
                  value: 'delete',
                  child: Text(l10n.habit_deleteAction),
                ),
              ],
            ),
        ],
        body: switch (state.status) {
          HabitFormStatus.loading => const DelayedSkeleton(
            child: SkeletonList(),
          ),
          HabitFormStatus.loadError => ErrorState(
            message: l10n.habit_loadError,
            onRetry: _controller.retry,
          ),
          HabitFormStatus.notFound => const SizedBox.shrink(),
          HabitFormStatus.ready => _Form(
            state: state,
            controller: _controller,
            name: _name,
            target: _target,
            unit: _unit,
            onSuggestion: (t) => _applyTemplate(t, l10n),
          ),
        },
        bottomBar: state.status == HabitFormStatus.ready
            ? Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppTokens.of(context).s8,
                ),
                child: FilledButton(
                  key: const Key('save_habit'),
                  onPressed: state.saving ? null : () => unawaited(_save()),
                  child: Text(l10n.habit_save),
                ),
              )
            : null,
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const new({
    required this.state,
    required this.controller,
    required this.name,
    required this.target,
    required this.unit,
    required this.onSuggestion,
  });

  final HabitFormState state;
  final HabitFormController controller;
  final TextEditingController name;
  final TextEditingController target;
  final TextEditingController unit;
  final ValueChanged<HabitTemplate> onSuggestion;

  String? _nameError(AppLocalizations l10n) =>
      state.hasError(HabitFieldError.nameRequired)
      ? l10n.habit_errNameRequired
      : state.hasError(HabitFieldError.nameTooLong)
      ? l10n.habit_errNameTooLong
      : null;

  Future<void> _pickIcon(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final key = await AppBottomSheet.show<String>(
      context,
      title: l10n.habit_iconLabel,
      child: Builder(
        builder: (context) => IconPickerGrid(
          selectedKey: state.draft.iconKey,
          onSelected: (k) => Navigator.of(context).pop(k),
        ),
      ),
    );
    if (key != null) controller.setIcon(key);
  }

  Future<void> _pickDate(BuildContext context, LocalDate today) async {
    final draft = state.draft.startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(draft.year, draft.month, draft.day),
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) controller.setStartDate(LocalDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final draft = state.draft;
    final count = draft.kind == HabitKind.count;
    final today = LocalDate.fromDateTime(ref.watch(clockProvider).now());
    final yesterday = today.addDays(-1);
    final typed = name.text.trim().toLowerCase();
    final suggestions = state.isEdit || typed.isEmpty
        ? const <HabitTemplate>[]
        : [
            for (final t in habitTemplates)
              if (templateName(l10n, t).toLowerCase().contains(typed) &&
                  templateName(l10n, t).toLowerCase() != typed)
                t,
          ];

    Widget label(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleSmall),
      ),
    );

    return ListView(
      key: const Key('habit_form'),
      padding: EdgeInsets.only(bottom: tokens.s24),
      children: [
        SizedBox(height: tokens.s8),
        TextField(
          key: const Key('habit_name'),
          controller: name,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.habit_nameLabel,
            errorText: _nameError(l10n),
          ),
          onChanged: controller.setName,
        ),
        if (suggestions.isNotEmpty) ...[
          SizedBox(height: tokens.s8),
          Semantics(
            label: l10n.habit_nameSuggestions,
            child: Wrap(
              spacing: tokens.s8,
              children: [
                for (final t in suggestions)
                  ActionChip(
                    key: ValueKey('suggestion_${t.id}'),
                    avatar: Icon(AppIcons.byKey(t.iconKey)),
                    label: Text(templateName(l10n, t)),
                    onPressed: () => onSuggestion(t),
                  ),
              ],
            ),
          ),
        ],
        label(l10n.habit_iconLabel),
        ListTile(
          key: const Key('habit_icon'),
          contentPadding: EdgeInsets.zero,
          leading: CategoryAvatar(
            icon: AppIcons.byKey(draft.iconKey),
            color: AppColors.fromHex(draft.colorHex),
            semanticLabel: l10n.habit_iconLabel,
          ),
          title: Text(l10n.habit_iconLabel),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => unawaited(_pickIcon(context)),
        ),
        label(l10n.habit_colorLabel),
        ColorPickerRow(
          selectedHex: draft.colorHex,
          onSelected: controller.setColor,
        ),
        label(l10n.habit_goalLabel),
        if (state.isEdit)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                key: const Key('goal_locked'),
                label: Text(
                  count ? l10n.habit_goalCount : l10n.habit_goalYesNo,
                ),
              ),
              Text(l10n.habit_goalLocked, style: theme.textTheme.bodySmall),
            ],
          )
        else
          ChipSelector<HabitKind>(
            key: const Key('goal_type'),
            options: HabitKind.values,
            selected: {draft.kind},
            labelBuilder: (k) => switch (k) {
              HabitKind.yesNo => l10n.habit_goalYesNo,
              HabitKind.count => l10n.habit_goalCount,
            },
            onChanged: (s) {
              controller.setKind(s.single);
              if (s.single == HabitKind.count && target.text == '0') {
                target.text = '1';
              }
            },
          ),
        if (count) ...[
          SizedBox(height: tokens.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('habit_target'),
                  controller: target,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.habit_targetLabel,
                    errorText: state.hasError(HabitFieldError.targetOutOfRange)
                        ? l10n.habit_errTargetRange
                        : null,
                    errorMaxLines: 2,
                  ),
                  onChanged: controller.setTarget,
                ),
              ),
              SizedBox(width: tokens.s12),
              Expanded(
                child: TextField(
                  key: const Key('habit_unit'),
                  controller: unit,
                  decoration: InputDecoration(
                    labelText: l10n.habit_unitLabel,
                    errorText: state.hasError(HabitFieldError.unitTooLong)
                        ? l10n.habit_errUnitTooLong
                        : null,
                    errorMaxLines: 2,
                  ),
                  onChanged: controller.setUnit,
                ),
              ),
            ],
          ),
        ],
        label(l10n.habit_scheduleLabel),
        ScheduleSection(
          schedule: draft.schedule,
          firstDayOfWeek: ref.watch(firstDayOfWeekProvider),
          onType: controller.setScheduleType,
          onWeekdays: controller.setWeekdays,
          onTimes: controller.setTimesPerWeek,
          weekdayError: state.hasError(HabitFieldError.weekdayRequired)
              ? l10n.habit_errWeekdayRequired
              : null,
          timesError: state.hasError(HabitFieldError.timesOutOfRange)
              ? l10n.habit_errTimesRange
              : null,
        ),
        label(l10n.habit_reminders),
        RemindersSection(
          times: draft.reminderTimes,
          onlyIfNotDone: draft.remindOnlyIfNotDone,
          notificationsAllowed: state.notificationsAllowed,
          exactAlarmsAllowed: state.exactAlarmsAllowed,
          error: state.reminderError,
          onAdd: controller.addReminder,
          onRemove: controller.removeReminder,
          onOnlyIfNotDone: (on) => controller.setRemindOnlyIfNotDone(on: on),
        ),
        label(l10n.habit_startDate),
        Wrap(
          spacing: tokens.s8,
          runSpacing: tokens.s8,
          children: [
            ChoiceChip(
              key: const Key('start_today'),
              label: Text(l10n.common_today),
              selected: draft.startDate == today,
              onSelected: (_) => controller.setStartDate(today),
            ),
            ChoiceChip(
              key: const Key('start_yesterday'),
              label: Text(l10n.common_yesterday),
              selected: draft.startDate == yesterday,
              onSelected: (_) => controller.setStartDate(yesterday),
            ),
            ChoiceChip(
              key: const Key('start_pick'),
              avatar: const Icon(Icons.calendar_today),
              label: Text(
                draft.startDate == today || draft.startDate == yesterday
                    ? l10n.habit_pickDate
                    : formatFullDate(
                        DateTime(
                          draft.startDate.year,
                          draft.startDate.month,
                          draft.startDate.day,
                        ),
                        FullDateFormatScope.of(context),
                        l10n.localeName,
                      ),
              ),
              selected:
                  draft.startDate != today && draft.startDate != yesterday,
              onSelected: (_) => unawaited(_pickDate(context, today)),
            ),
          ],
        ),
      ],
    );
  }
}
