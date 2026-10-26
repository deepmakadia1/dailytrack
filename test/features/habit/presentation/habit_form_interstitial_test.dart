import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../habit_test_app.dart';

/// HAB-02 interstitial trigger (feature 009 T100, spec §11): a new habit
/// only, after the form has closed.
void main() {
  Finder field(String key) => find.byKey(Key(key));
  const tall = Size(412, 2400);

  testWidgets('US4-5 saving a new habit triggers once, after the form '
      'has closed', (tester) async {
    final ads = FakeAdService();
    await pumpHabitApp(tester, habits: habitFakes(), size: tall, ads: ads);
    final formOpenAtTrigger = <bool>[];
    ads.onTrigger = (_) =>
        formOpenAtTrigger.add(locationOf(tester).startsWith(Routes.habitAdd));
    unawaited(routerOf(tester).push<void>(Routes.habitAdd));
    await tester.pumpAndSettle();
    await tester.enterText(field('habit_name'), 'Walk');
    await tester.tap(field('save_habit'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitFormScreen), findsNothing);
    expect(ads.triggers.single, isA<HabitCreated>());
    expect(formOpenAtTrigger.single, isFalse);
    await flushTimers(tester);
  });

  testWidgets('editing a habit never triggers', (tester) async {
    final ads = FakeAdService();
    final habits = habitFakes();
    final habit = habits.addHabit('Read');
    await pumpHabitApp(
      tester,
      habits: habits,
      size: tall,
      ads: ads,
      location: Routes.habitEditPath(habit.id),
    );
    await tester.enterText(field('habit_name'), 'Read more');
    await tester.tap(field('save_habit'));
    await tester.pumpAndSettle();
    expect(ads.triggers, isEmpty);
    await flushTimers(tester);
  });
}
