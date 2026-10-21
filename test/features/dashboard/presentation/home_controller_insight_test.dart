import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/dashboard/domain/insight_rotation.dart';
import 'package:dailytrack/features/dashboard/presentation/controllers/home_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// The insight part of HomeController (T041, research R6, R7).
void main() {
  late MutableClock clock;
  late FakeInsightSource a;
  late FakeInsightSource b;
  late FakeSettingsRepository settings;
  late ProviderContainer container;

  Future<void> start(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true),
  }) async {
    settings = FakeSettingsRepository(
      initial: initial,
      knownModuleIds: const ['a', 'b'],
    );
    container =
        ProviderContainer(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(settings),
              clockProvider.overrideWithValue(clock),
              moduleRegistryProvider.overrideWithValue(
                ModuleRegistry([
                  FakeTrackerModule(id: 'a', insightSource: a),
                  FakeTrackerModule(id: 'b', insightSource: b),
                ]),
              ),
            ],
          )
          ..listen(appSettingsProvider, (_, _) {})
          ..listen(homeControllerProvider, (_, _) {});
    await tester.pump();
    await tester.pump();
  }

  HomeState state() => container.read(homeControllerProvider);

  String? pickedId() => switch (state().insight.value) {
    Picked(:final insight) => insight.ruleId,
    _ => null,
  };

  int calls() => a.calls + b.calls;

  /// Disposes the container inside the test, so its timers are cancelled
  /// before the pending-timer check.
  void homeTest(String name, Future<void> Function(WidgetTester) body) =>
      testWidgets(name, (tester) async {
        await body(tester);
        container.dispose();
        await tester.pump();
      });

  setUp(() {
    clock = MutableClock(DateTime(2026, 10, 20, 9));
    a = FakeInsightSource(
      const ['a.one', 'a.two'],
      insights: [insight('a.one'), insight('a.two')],
    );
    b = FakeInsightSource(const ['b.one'], insights: [insight('b.one')]);
  });

  const ab = AppSettings(
    onboardingDone: true,
    moduleOrder: ['a', 'b'],
    enabledModules: ['a', 'b'],
  );

  homeTest('DSH-01 US4-1 exactly one insight; the pick is stored', (
    tester,
  ) async {
    await start(tester, initial: ab);
    expect(pickedId(), 'a.one');
    expect(settings.calls['setDailyInsight'], 1);
    expect(settings.current.dailyInsightDate, '2026-10-20');
    expect(settings.current.dailyInsightId, 'a.one');
  });

  homeTest('DSH-01 US4-2 after midnight the insight changes and is '
      'stored', (tester) async {
    clock.value = DateTime(2026, 10, 20, 23, 59);
    await start(tester, initial: ab);
    expect(pickedId(), 'a.one');
    clock.value = DateTime(2026, 10, 21, 0, 1);
    await tester.pump(const Duration(minutes: 2));
    await tester.pump();
    expect(pickedId(), 'a.two');
    expect(settings.current.dailyInsightDate, '2026-10-21');
    expect(settings.current.dailyInsightId, 'a.two');
  });

  homeTest('DSH-01 US4-3 rebuilding on the same day keeps it, no write', (
    tester,
  ) async {
    await start(
      tester,
      initial: ab.copyWith(
        dailyInsightDate: '2026-10-20',
        dailyInsightId: 'b.one',
      ),
    );
    expect(pickedId(), 'b.one');
    container.invalidate(homeControllerProvider);
    await tester.pump();
    await tester.pump();
    expect(pickedId(), 'b.one');
    expect(settings.calls['setDailyInsight'], isNull);
  });

  homeTest('DSH-01 US4-4 refreshInsights re-evaluates and changes only '
      'the insight', (tester) async {
    await start(tester, initial: ab);
    final before = state();
    final callsBefore = calls();
    final refresh = container
        .read(homeControllerProvider.notifier)
        .refreshInsights();
    // The previous value stays while refreshing (no empty loading).
    expect(state().insight.hasValue, isTrue);
    await refresh;
    await tester.pump();
    expect(calls(), callsBefore + 2);
    final after = state();
    expect(after.greeting, before.greeting);
    expect(after.today, before.today);
    expect(after.modules, before.modules);
    expect(after.quickAdds, before.quickAdds);
    expect(after.comingSoon, before.comingSoon);
  });

  homeTest('storing the pick does not re-run evaluation', (tester) async {
    await start(tester, initial: ab);
    final callsAfterFirst = calls();
    expect(settings.calls['setDailyInsight'], 1);
    await tester.pump();
    await tester.pump();
    expect(calls(), callsAfterFirst);
  });

  homeTest('dismissing and undoing Coming soon never re-evaluates', (
    tester,
  ) async {
    await start(tester, initial: ab);
    final insight = state().insight;
    final callsBefore = calls();
    final notifier = container.read(homeControllerProvider.notifier);
    await notifier.dismissComingSoon();
    await tester.pump();
    expect(state().comingSoon, isEmpty);
    await notifier.undoDismissComingSoon();
    await tester.pump();
    expect(state().comingSoon, comingSoonModules);
    expect(calls(), callsBefore);
    expect(identical(state().insight, insight), isTrue);
  });

  homeTest('a module order change re-evaluates once and keeps the '
      'previous insight meanwhile', (tester) async {
    await start(tester, initial: ab);
    final callsBefore = calls();
    await settings.setModules(
      order: const ['b', 'a'],
      enabled: const ['a', 'b'],
    );
    await tester.pump();
    expect(state().insight.hasValue, isTrue);
    await tester.pump();
    await tester.pump();
    expect(calls(), callsBefore + 2);
    expect([for (final m in state().modules) m.id], ['b', 'a']);
  });

  homeTest("DSH-01 US4-6 a disabled module's source is not called", (
    tester,
  ) async {
    await start(tester, initial: ab.copyWith(enabledModules: const ['a']));
    expect(b.calls, 0);
    expect(a.calls, 1);
  });

  homeTest('DSH-01 US4-5 sources need nothing but local fakes', (tester) async {
    // No network override exists in this container; evaluation still works.
    await start(tester, initial: ab);
    expect(state().insight.value, isA<Picked>());
  });

  homeTest('FR-025 nothing applies: the starter, and no write', (tester) async {
    a.insights = const [];
    b.insights = const [];
    await start(tester, initial: ab);
    expect(state().insight.value, isA<Starter>());
    expect(settings.calls['setDailyInsight'], isNull);
  });

  homeTest('a source that throws is skipped', (tester) async {
    a.error = StateError('boom');
    await start(tester, initial: ab);
    expect(pickedId(), 'b.one');
  });
}
