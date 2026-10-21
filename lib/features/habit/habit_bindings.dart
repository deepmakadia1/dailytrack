import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/data/reminders/local_habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_entry_repository.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// The Habit half of the composition root (contracts/routes_and_module.md):
/// binds the Drift repositories and the local reminder scheduler. Only
/// `app/production_overrides.dart` imports this file (layering scan).
// coverage:ignore-start
List<Override> habitOverrides() => [
  habitRepositoryProvider.overrideWith(
    (ref) => DriftHabitRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  habitEntryRepositoryProvider.overrideWith(
    (ref) => DriftHabitEntryRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
      ref.watch(streakEngineProvider),
    ),
  ),
  habitReminderSchedulerProvider.overrideWith(
    (ref) => LocalHabitReminderScheduler(
      service: ref.watch(notificationServiceProvider),
      habits: ref.watch(habitRepositoryProvider),
      entries: ref.watch(habitEntryRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
      clock: ref.watch(clockProvider),
      l10n: () => l10nFor(ref.read(appSettingsProvider).value?.locale),
    ),
  ),
];
// coverage:ignore-end
