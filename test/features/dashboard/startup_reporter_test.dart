import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/startup/startup_providers.dart';
import 'package:dailytrack/core/startup/startup_reporter.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// DSH-01 reports "fully drawn" once per app run, for the §13 cold start
/// measurement (feature 012 T037, research R10).
void main() {
  testWidgets('DSH-01 calls StartupReporter.homeShown exactly once, after its '
      'first frame, and not again after rebuilds or leaving and coming back', (
    tester,
  ) async {
    final reporter = _RecordingReporter();
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true, locale: 'en'),
      ),
      overrides: [startupReporterProvider.overrideWithValue(reporter)],
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(reporter.calls, 1);

    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    routerOf(tester).go(Routes.home);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(reporter.calls, 1);
  });
}

final class _RecordingReporter implements StartupReporter {
  int calls = 0;

  @override
  void homeShown() => calls++;
}
