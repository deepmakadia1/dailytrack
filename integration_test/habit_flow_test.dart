import 'package:dailytrack/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';

/// Spec §13 flow, Habit part (feature 012 T018, spec US2 scenario 2): create
/// a habit in HAB-02, check it in on HAB-01, and see a streak of 1 on HAB-01
/// and HAB-03, on the real database.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  /// The id of the only habit card on HAB-01.
  String onlyHabitId() {
    final keys = find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('habit_card_'),
        )
        .evaluate()
        .map((e) => (e.widget.key! as ValueKey<String>).value)
        .toSet();
    expect(keys, hasLength(1));
    return keys.single.substring('habit_card_'.length);
  }

  testWidgets('HAB-02 create → HAB-01 check in → streak 1 on HAB-01 and '
      'HAB-03', (tester) async {
    final world = HarnessWorld();
    await launch(tester, world);
    await startAsGuest(tester);

    await tester.tap(navLabel('Habits'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'habit_fab');
    await tester.enterText(find.byKey(const Key('habit_name')), 'Read');
    await tester.pumpAndSettle();
    await tapKey(tester, 'save_habit');
    await pumpUntil(tester, () => shows(find.text('Read')));

    final id = onlyHabitId();
    await tester.tap(find.byKey(ValueKey('check_$id')));
    await tester.pumpAndSettle();
    if (shows(find.byKey(const Key('milestone_close')))) {
      await tapKey(tester, 'milestone_close');
    }
    final streak = tester.widget<Text>(find.byKey(ValueKey('streak_$id')));
    expect(streak.data, contains('1'));

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('stat_current')),
        matching: find.textContaining('1'),
      ),
      findsWidgets,
    );
    expect(world.auth.calls, isEmpty);
    await closeApp(tester);
  });
}
