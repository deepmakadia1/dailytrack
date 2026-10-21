import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:flutter/material.dart';

/// HAB-02 reminders (US1-2, US4, T070): up to 3 times, "+ Add reminder"
/// opens a time picker, "Remind me only if not done yet" (default on), and
/// one-line hints when notifications are denied (US4-7) or exact alarms
/// are not allowed (FR-041).
class RemindersSection extends StatelessWidget {
  const new({
    required this.times,
    required this.onlyIfNotDone,
    required this.notificationsAllowed,
    required this.exactAlarmsAllowed,
    required this.onAdd,
    required this.onRemove,
    required this.onOnlyIfNotDone,
    this.error,
    super.key,
  });

  final List<ReminderTime> times;
  final bool onlyIfNotDone;
  final bool notificationsAllowed;
  final bool exactAlarmsAllowed;
  final ValueChanged<ReminderTime> onAdd;
  final ValueChanged<ReminderTime> onRemove;
  final ValueChanged<bool> onOnlyIfNotDone;
  final HabitFieldError? error;

  /// The picker opens on the first whole hour from 08:00 not yet used.
  TimeOfDay get _suggested {
    for (var i = 0; i < 24; i++) {
      final hour = (8 + i) % 24;
      if (!times.contains(ReminderTime(hour, 0))) {
        return TimeOfDay(hour: hour, minute: 0);
      }
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _suggested,
    );
    if (picked != null) onAdd(ReminderTime(picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    String label(ReminderTime t) => material.formatTimeOfDay(
      TimeOfDay(hour: t.hour, minute: t.minute),
      alwaysUse24HourFormat: use24h,
    );
    final errorText = switch (error) {
      HabitFieldError.duplicateReminder => l10n.habit_reminderDuplicate,
      HabitFieldError.tooManyReminders => l10n.habit_reminderLimit,
      _ => null,
    };

    Widget hint(String text, Key key) => Padding(
      padding: EdgeInsets.only(top: tokens.s4),
      child: Row(
        key: key,
        children: [
          Icon(
            Icons.info_outline,
            size: tokens.chipIconSize,
            color: theme.colorScheme.outline,
          ),
          SizedBox(width: tokens.s8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: tokens.s8,
          runSpacing: tokens.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final t in times)
              InputChip(
                key: ValueKey('reminder_${t.format()}'),
                avatar: const Icon(Icons.alarm),
                label: Text(label(t)),
                deleteButtonTooltipMessage: l10n.habit_removeReminder(label(t)),
                onDeleted: () => onRemove(t),
              ),
            if (times.length < maxReminders)
              TextButton.icon(
                key: const Key('add_reminder'),
                onPressed: () => _pick(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.habit_addReminder),
              ),
          ],
        ),
        if (times.length >= maxReminders)
          hint(l10n.habit_reminderLimit, const Key('reminder_limit')),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.s4),
            child: Text(
              errorText,
              key: const Key('reminder_error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        SwitchListTile(
          key: const Key('remind_only_if_not_done'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.habit_remindOnlyIfNotDone),
          value: onlyIfNotDone,
          onChanged: onOnlyIfNotDone,
        ),
        if (!notificationsAllowed)
          hint(
            l10n.habit_notificationsOffHint,
            const Key('notifications_hint'),
          ),
        if (notificationsAllowed && !exactAlarmsAllowed && times.isNotEmpty)
          hint(l10n.habit_inexactHint, const Key('inexact_hint')),
      ],
    );
  }
}
