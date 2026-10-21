import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/ports/habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_entry_repository.dart';
import 'package:dailytrack/features/habit/domain/repositories/habit_repository.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/domain/usecases/habit_day_writer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_providers.g.dart';

// Typed to domain interfaces and free of data/, Drift and plugin imports, so
// presentation code can depend on them (Constitution II). `habit_bindings.dart`
// binds the real implementations (only production_overrides.dart imports
// it); widget tests bind fakes through `pumpTestApp`.

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) =>
    throw UnimplementedError('habitRepositoryProvider must be overridden');

@Riverpod(keepAlive: true)
HabitEntryRepository habitEntryRepository(Ref ref) =>
    throw UnimplementedError('habitEntryRepositoryProvider must be overridden');

@Riverpod(keepAlive: true)
HabitReminderScheduler habitReminderScheduler(Ref ref) =>
    throw UnimplementedError(
      'habitReminderSchedulerProvider must be overridden',
    );

/// The user's first day of the week (settings, default Monday).
@Riverpod(keepAlive: true)
int firstDayOfWeek(Ref ref) =>
    ref.watch(appSettingsProvider).value?.firstDayOfWeek ?? 1;

/// Streak rules with the app clock (research R6); rebuilt when the first
/// day of the week changes.
@Riverpod(keepAlive: true)
StreakEngine streakEngine(Ref ref) => StreakEngine(
  ref.watch(clockProvider),
  firstDayOfWeek: ref.watch(firstDayOfWeekProvider),
);

/// Every day write goes through this (research R8). Composed from bound
/// providers; needs no binding.
@Riverpod(keepAlive: true)
HabitDayWriter habitDayWriter(Ref ref) => HabitDayWriter(
  ref.watch(habitEntryRepositoryProvider),
  ref.watch(habitReminderSchedulerProvider),
  ref.watch(clockProvider),
  firstDayOfWeek: ref.watch(firstDayOfWeekProvider),
);
