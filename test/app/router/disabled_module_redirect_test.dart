import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// Redirect rule 5 (contracts/routes.md): a disabled module's routes are
/// unreachable.
void main() {
  testWidgets('DSH-01 a disabled module route redirects to Home', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(
          onboardingDone: true,
          enabledModules: ['expense'],
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );

    container.read(appRouterProvider).go(Routes.habits);
    await tester.pumpAndSettle();

    expect(find.byType(HabitsTodayScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      container
          .read(appRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path,
      Routes.home,
    );
  });

  testWidgets('DSH-01 disabling the open module leaves its tab for Home', (
    tester,
  ) async {
    final settings = await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    container.read(appRouterProvider).go(Routes.habits);
    await tester.pumpAndSettle();
    expect(find.byType(HabitsTodayScreen), findsOneWidget);

    await settings.setModules(
      order: const ['expense', 'habit'],
      enabled: const ['expense'],
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Habits'), findsNothing);
  });
}
