import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/dashboard_slot.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../fakes.dart';

/// DSH-01 shell (T013): one card per visible module, in SET-06 order.
void main() {
  ModuleRegistry registry() => ModuleRegistry([
    FakeTrackerModule(id: 'expense', rootPath: '/expenses'),
    FakeTrackerModule(id: 'habit', rootPath: '/habits'),
  ]);

  testWidgets('DSH-01 renders one home_card_<id> per visible module in '
      'moduleOrder, each inside a DashboardSlot', (tester) async {
    await pumpTestApp(
      tester,
      registry: registry(),
      settings: FakeSettingsRepository(
        initial: const AppSettings(
          onboardingDone: true,
          moduleOrder: ['habit', 'expense'],
        ),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    final habit = find.byKey(const Key('home_card_habit'));
    final expense = find.byKey(const Key('home_card_expense'));
    expect(habit, findsOneWidget);
    expect(expense, findsOneWidget);
    expect(
      tester.getTopLeft(habit).dy,
      lessThan(tester.getTopLeft(expense).dy),
    );
    for (final card in [habit, expense]) {
      expect(
        find.ancestor(of: card, matching: find.byType(DashboardSlot)),
        findsOneWidget,
      );
    }
    expect(find.text('Module habit card'), findsOneWidget);
  });

  testWidgets('a disabled module has no card; no ad widgets', (tester) async {
    await pumpTestApp(
      tester,
      registry: registry(),
      settings: FakeSettingsRepository(
        initial: const AppSettings(
          onboardingDone: true,
          enabledModules: ['expense'],
        ),
      ),
    );
    expect(find.byKey(const Key('home_card_expense')), findsOneWidget);
    expect(find.byKey(const Key('home_card_habit')), findsNothing);
    expect(anyAdWidget, findsNothing);
  });
}
