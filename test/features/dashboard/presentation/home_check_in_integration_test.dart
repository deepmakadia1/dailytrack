import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_entry_repository.dart';
import 'package:dailytrack/features/habit/data/repositories/drift_habit_repository.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';
import '../../../helpers/real_app.dart';

/// DSH-01 acceptance criterion 1 (T030) on a real in-memory database with
/// the real Expense and Habit modules. "Now" is Wednesday 2026-10-21 10:00.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('DSH-01 AC1 marking a habit done from Home updates the ring, '
      'the habit list, and the streak icon without reload', (tester) async {
    final clock = MutableClock(DateTime(2026, 10, 21, 10));
    final db = AppDatabase(NativeDatabase.memory());
    late String readId;
    await tester.runAsync(() async {
      await SettingsRepositoryImpl(
        db,
        knownModuleIds: const ['expense', 'habit'],
      ).completeOnboarding(
        const OnboardingChoices(
          locale: 'en',
          currencyCode: 'INR',
          moduleOrder: ['expense', 'habit'],
          enabledModules: ['expense', 'habit'],
        ),
      );
      final habits = DriftHabitRepository(db, clock);
      final entries = DriftHabitEntryRepository(db, clock, StreakEngine(clock));
      final read = await habits.create(
        HabitDraft(
          name: 'Read',
          iconKey: 'menu_book',
          colorHex: '#2B7ACA',
          kind: HabitKind.yesNo,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
          startDate: LocalDate.fromKey('2026-10-01'),
        ),
      );
      readId = read.id;
      // A 6-day streak through yesterday.
      for (var d = 15; d <= 20; d++) {
        await entries.apply(read.id, LocalDate(2026, 10, d), const Toggle());
      }
    });

    await pumpRealDbApp(tester, db: db, clock: clock);
    await settleRealDb(tester);

    final flame = find.descendant(
      of: find.byKey(const Key('home_badge_habit')),
      matching: find.byKey(const Key('streak_flame_count')),
    );
    expect(find.text('0 of 1 done today'), findsOneWidget);
    expect(tester.widget<Text>(flame).data, '6');

    await tester.tap(find.byKey(ValueKey('home_check_$readId')));
    await settleRealDb(tester);

    // Same widget tree: no pumpWidget, no reload.
    expect(find.text('1 of 1 done today'), findsOneWidget);
    expect(tester.widget<Text>(flame).data, '7');

    await tester.tap(find.text('Habits'));
    await settleRealDb(tester);
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    expect(find.byKey(ValueKey('habit_card_$readId')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(ValueKey('streak_$readId'))).data,
      '7 days',
    );

    await tester.tap(find.text('Home'));
    await settleRealDb(tester);
    expect(find.text('1 of 1 done today'), findsOneWidget);

    // Unmount, let Drift finish its stream cleanup, then close the database
    // so no timer outlives the test.
    await tester.pumpWidget(const SizedBox());
    await settleRealDb(tester);
    await tester.runAsync(db.close);
    await tester.pump();
  });
}
