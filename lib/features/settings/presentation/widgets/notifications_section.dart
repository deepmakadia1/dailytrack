import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-01 Notifications (FR-007 – FR-009, clarification Q2): the master
/// switch, daily summary time, budget alerts, and habit reminders while the
/// Habit module is on. With the master switch off the other rows are
/// disabled but keep their values. Without exact alarms a note says
/// reminders may be late and offers "Allow exact timing" (feature 008
/// FR-042).
class NotificationsSection extends ConsumerWidget {
  const new({required this.settings, required this.habitEnabled, super.key});

  final AppSettings settings;

  /// Shows the Habit reminders row.
  final bool habitEnabled;

  static TimeOfDay parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    final master = settings.notificationsEnabled;
    // Unknown while loading: assume allowed, so the note never flashes.
    final allowed = ref.watch(notificationsAllowedProvider).value ?? true;
    final exact = ref.watch(exactAlarmsAllowedProvider).value ?? true;
    final time = parseTime(settings.dailySummaryTime);
    final timeText = MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    Future<void> pickTime() async {
      final picked = await showTimePicker(context: context, initialTime: time);
      if (picked != null) {
        await controller.setDailySummaryTime(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }

    Future<void> openSystemSettings() async {
      await ref.read(externalLauncherProvider).openNotificationSettings();
      ref.invalidate(notificationsAllowedProvider);
    }

    return SettingsSection(
      title: l10n.settings_notifications,
      children: [
        SwitchListTile(
          key: const Key('settings_notifications_master'),
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(l10n.settings_notificationsMaster),
          value: master,
          onChanged: (on) =>
              unawaited(controller.setNotificationsEnabled(enabled: on)),
        ),
        if (master && !allowed)
          ListTile(
            key: const Key('settings_notifications_blocked'),
            leading: Icon(
              Icons.notifications_off_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(l10n.settings_notificationsBlocked),
            trailing: TextButton(
              key: const Key('settings_open_system_settings'),
              onPressed: () => unawaited(openSystemSettings()),
              child: Text(l10n.settings_openSystemSettings),
            ),
          ),
        if (master && allowed && !exact)
          ListTile(
            key: const Key('settings_exact_note'),
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.settings_exactNote),
            trailing: TextButton(
              key: const Key('settings_exact_allow'),
              onPressed: () => unawaited(controller.requestExactAlarms()),
              child: Text(l10n.settings_exactAllow),
            ),
          ),
        ListTile(
          key: const Key('settings_daily_summary_time'),
          enabled: master,
          leading: const Icon(Icons.schedule),
          title: Text(l10n.settings_dailySummaryTime),
          subtitle: Text(l10n.settings_dailySummaryHelp),
          trailing: Text(timeText),
          onTap: () => unawaited(pickTime()),
        ),
        SwitchListTile(
          key: const Key('settings_budget_alerts'),
          secondary: const Icon(Icons.savings_outlined),
          title: Text(l10n.settings_budgetAlerts),
          value: settings.budgetAlertsEnabled,
          onChanged: master
              ? (on) =>
                    unawaited(controller.setBudgetAlertsEnabled(enabled: on))
              : null,
        ),
        if (habitEnabled)
          SwitchListTile(
            key: const Key('settings_habit_reminders'),
            secondary: const Icon(Icons.alarm_outlined),
            title: Text(l10n.settings_habitReminders),
            value: settings.habitRemindersEnabled,
            onChanged: master
                ? (on) => unawaited(
                    controller.setHabitRemindersEnabled(enabled: on),
                  )
                : null,
          ),
      ],
    );
  }
}
