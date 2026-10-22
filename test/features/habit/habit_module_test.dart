import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/habit/data/backup/habit_backup_section.dart';
import 'package:dailytrack/features/habit/habit_module.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fakes.dart';
import 'habit_test_app.dart';

/// HabitModule (T090, FR-046, contracts/routes_and_module.md).
void main() {
  const module = HabitModule();

  test('SET-01 onNotificationSettingsChanged reconciles every reminder '
      '(feature 007 T020)', () async {
    final scheduler = FakeHabitReminderScheduler();
    final container = ProviderContainer(
      overrides: [habitReminderSchedulerProvider.overrideWithValue(scheduler)],
    );
    addTearDown(container.dispose);
    await module.onNotificationSettingsChanged(container.read);
    expect(scheduler.calls, ['reconcileAll']);
  });

  test('is registered once, as "habit"', () {
    expect([for (final m in registeredModules) m.id], contains('habit'));
    expect(registeredModules.whereType<HabitModule>(), hasLength(1));
    expect(module.rootPath, Routes.habits);
  });

  test('routes: HAB-01 root with add and archived before :id, edit under '
      ':id', () {
    final root = module.routes.single as GoRoute;
    expect(root.path, Routes.habits);
    final children = [for (final r in root.routes) (r as GoRoute).path];
    expect(children, [
      Routes.habitAddSegment,
      Routes.habitArchivedSegment,
      Routes.habitDetailSegment,
    ]);
    final detail = root.routes.last as GoRoute;
    expect((detail.routes.single as GoRoute).path, Routes.habitEditSegment);
    final paths = {
      root.path,
      for (final c in children) '${root.path}/$c',
      '${root.path}/${Routes.habitDetailSegment}/${Routes.habitEditSegment}',
    };
    expect(paths, {
      Routes.habits,
      Routes.habitAdd,
      Routes.habitArchived,
      Routes.habitDetail,
      Routes.habitEdit,
    });
  });

  test('US7-5 quick add "Check in habit" opens /habits', () {
    final action = module.quickAddActions().single;
    expect(action.labelKey, 'habit_quickAddCheckIn');
    expect(action.location, Routes.habits);
    expect(action.icon, Icons.check_circle);
  });

  test('backup is the habit section (feature 008); no seeders or '
      'background tasks', () {
    expect(module.backupSection(), isA<HabitBackupSection>());
    expect(module.seeders, isEmpty);
    expect(module.backgroundTasks, isEmpty);
  });

  testWidgets('DSH-01 US3 "Check in habit" opens HAB-01 for today', (
    tester,
  ) async {
    await pumpHabitApp(
      tester,
      habits: habitFakes()..addHabit('Read'),
      location: module.quickAddActions().single.location,
    );
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('day_2026-10-21')), findsOneWidget);
  });
}
