@Tags(['golden'])
library;

import 'dart:async';

import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// §15.10 screen goldens (T110): SYS-01, SYS-02 and SET-06 in light and
/// dark × English and Gujarati, on a 360×800 surface, with fakes only.
/// Baselines are made and compared on Linux (research R11):
/// `flutter test --tags golden --update-goldens`.
void main() {
  const primary = Key('onboarding_primary');

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  final scenarios = <String, Future<void> Function(WidgetTester, AppSettings)>{
    'SYS-01 initializing': (tester, s) async {
      await pumpTestApp(
        tester,
        settings: FakeSettingsRepository(initial: s),
        bootstrap: _PendingBootstrap(),
      );
      await _loadLogo(tester);
    },
    'SYS-01 error': (tester, s) async {
      await pumpTestApp(
        tester,
        settings: FakeSettingsRepository(initial: s),
        bootstrap: FakeBootstrap(results: [BootstrapFailed(StateError('db'))]),
      );
      await _loadLogo(tester);
    },
    for (var step = 1; step <= 4; step++)
      'SYS-02 step $step': (tester, s) async {
        await pumpTestApp(tester, settings: FakeSettingsRepository(initial: s));
        for (var i = 1; i < step; i++) {
          await tapAndSettle(tester, find.byKey(primary));
        }
      },
    'SYS-02 step 3 at least one module': (tester, s) async {
      await pumpTestApp(tester, settings: FakeSettingsRepository(initial: s));
      await tapAndSettle(tester, find.byKey(primary));
      await tapAndSettle(tester, find.byKey(primary));
      await tapAndSettle(tester, find.byKey(const Key('module_toggle_habit')));
      await tapAndSettle(
        tester,
        find.byKey(const Key('module_toggle_expense')),
      );
    },
    'SET-06 default': (tester, s) async {
      await _openModules(tester, s.copyWith(onboardingDone: true));
    },
    'SET-06 habit disabled': (tester, s) async {
      await _openModules(
        tester,
        s.copyWith(onboardingDone: true, enabledModules: ['expense']),
      );
    },
  };

  for (final MapEntry(key: name, value: build) in scenarios.entries) {
    for (final theme in const ['light', 'dark']) {
      for (final lang in const ['en', 'gu']) {
        testWidgets('$name golden $theme $lang', (tester) async {
          tester.view
            ..physicalSize = const Size(360, 800)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await build(tester, AppSettings(locale: lang, themeMode: theme));

          final file =
              '${name.toLowerCase().replaceAll(' ', '_')}'
              '_${theme}_$lang.png';
          await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        });
      }
    }
  }
}

Future<void> _openModules(WidgetTester tester, AppSettings settings) async {
  await pumpTestApp(
    tester,
    settings: FakeSettingsRepository(initial: settings),
  );
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(appRouterProvider)
      .go(Routes.modules);
  await tester.pumpAndSettle();
}

/// Asset images decode outside fake async; decode the splash logo for real
/// so it appears in the image.
Future<void> _loadLogo(WidgetTester tester) async {
  final context = tester.element(find.byType(SplashScreen));
  await tester.runAsync(
    () => precacheImage(const AssetImage(SplashScreen.logoAsset), context),
  );
  await tester.pumpAndSettle();
}

/// Startup that never finishes, to capture the splash's initializing state.
class _PendingBootstrap extends FakeBootstrap {
  @override
  Future<BootstrapResult> build() => Completer<BootstrapResult>().future;

  @override
  Future<void> retry() async {}
}
