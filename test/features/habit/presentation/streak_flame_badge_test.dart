import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/controllers/streak_flame_controller.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:dailytrack/features/habit/presentation/widgets/streak_flame_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../habit_test_app.dart';

/// DSH-01 streak flame (T018, contracts/screens.md "Streak flame badge").
/// "Now" is 2026-10-21 10:00.
void main() {
  String count(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('streak_flame_count'))).data!;

  testWidgets('DSH-01 shows the best active streak (12 of 4 and 12)', (
    tester,
  ) async {
    final h = habitFakes();
    final read = h.addHabit('Read');
    final walk = h.addHabit('Walk');
    h
      ..doneRange(read.id, '2026-10-10', '2026-10-21')
      ..doneRange(walk.id, '2026-10-18', '2026-10-21');
    await pumpHabitApp(tester, habits: h, location: Routes.home);
    expect(find.byKey(const Key('home_badge_habit')), findsOneWidget);
    expect(count(tester), '12');
  });

  testWidgets('DSH-01 shows 0 with no habits', (tester) async {
    await pumpHabitApp(tester, habits: habitFakes(), location: Routes.home);
    expect(count(tester), '0');
  });

  testWidgets('DSH-01 shows "2 wk" when a weekly habit wins', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      ),
      overrides: [
        streakFlameControllerProvider.overrideWith(
          () => _FixedFlame(
            const StreakFlameData(current: 2, unit: StreakUnit.weeks),
          ),
        ),
      ],
    );
    expect(count(tester), '2 wk');
    expect(
      find.bySemanticsLabel('Best active streak: 2 weeks'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('DSH-01 has a labelled 48 dp target that opens HAB-01', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = habitFakes();
    final read = h.addHabit('Read');
    h.doneRange(read.id, '2026-10-10', '2026-10-21');
    await pumpHabitApp(tester, habits: h, location: Routes.home);
    expect(
      find.bySemanticsLabel('Best active streak: 12 days'),
      findsOneWidget,
    );
    final size = tester.getSize(find.byType(StreakFlameBadge));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await tester.tap(find.byType(StreakFlameBadge));
    await tester.pumpAndSettle();
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('DSH-01 updates live after a check-in', (tester) async {
    final h = habitFakes();
    final read = h.addHabit('Read');
    h.doneRange(read.id, '2026-10-15', '2026-10-20');
    await pumpHabitApp(tester, habits: h, location: Routes.home);
    expect(count(tester), '6');
    h.doneRange(read.id, '2026-10-21', '2026-10-21');
    await tester.pumpAndSettle();
    expect(count(tester), '7');
  });
}

class _FixedFlame extends StreakFlameController {
  new(this._data);

  final StreakFlameData _data;

  @override
  AsyncValue<StreakFlameData> build() => AsyncData(_data);
}
