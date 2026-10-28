import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

const _primary = Key('onboarding_primary');
const _skip = Key('onboarding_skip');
const _back = Key('onboarding_back');
const _retry = Key('onboarding_retry');
const _allow = Key('onboarding_allow_notifications');

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Moves forward from step 1 to [step] with the primary button.
Future<void> _goToStep(WidgetTester tester, int step) async {
  for (var i = 1; i < step; i++) {
    await _tap(tester, find.byKey(_primary));
  }
}

bool _switchValue(WidgetTester tester, String key) =>
    tester.widget<SwitchListTile>(find.byKey(Key(key))).value;

/// Records `SystemNavigator.pop` (Android back closing the app).
List<String> _recordSystemCalls(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      calls.add(call.method);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  testWidgets('SYS-02 selected language persists and applies after app '
      'restart', (tester) async {
    final repo = await pumpTestApp(tester);
    expect(find.text('Track money and habits in one place'), findsOneWidget);

    await _tap(tester, find.text('ગુજરાતી'));
    expect(
      find.text('પૈસા અને આદતો એક જ જગ્યાએ ટ્રૅક કરો'),
      findsOneWidget,
      reason: 'the UI switches language immediately',
    );

    await _goToStep(tester, 4);
    await _tap(tester, find.byKey(_primary));
    expect(find.byType(LoginScreen), findsOneWidget);
    await _tap(tester, find.byKey(const Key('auth01_guest')));
    expect(find.byType(HomeScreen), findsOneWidget);

    await restartTestApp(tester, settings: repo);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('હોમ'), findsWidgets, reason: 'Home is in Gujarati');
    expect(repo.current.locale, 'gu');
  });

  for (final (label, permission) in [
    ('denied', FakeNotificationPermission(result: false)),
    ('plugin error', FakeNotificationPermission(throws: true)),
  ]) {
    testWidgets('SYS-02 denying the notification permission does not block '
        'onboarding ($label)', (tester) async {
      final repo = await pumpTestApp(tester, notif: permission);
      await _goToStep(tester, 4);
      await _tap(tester, find.byKey(_allow));
      expect(
        find.text(
          'Notifications are off. You can turn them on later in Settings.',
        ),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(_primary));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(repo.current.onboardingDone, isTrue);
    });
  }

  testWidgets('SYS-02 user cannot turn off both modules', (tester) async {
    final repo = await pumpTestApp(tester);
    await _goToStep(tester, 3);

    await _tap(tester, find.byKey(const Key('module_toggle_habit')));
    expect(_switchValue(tester, 'module_toggle_habit'), isFalse);

    await _tap(tester, find.byKey(const Key('module_toggle_expense')));
    expect(_switchValue(tester, 'module_toggle_expense'), isTrue);
    expect(find.text('Keep at least one tracker on'), findsOneWidget);

    await _tap(tester, find.byKey(_primary)); // step 3 → 4
    await _tap(tester, find.byKey(_primary)); // Get started
    expect(repo.current.onboardingDone, isTrue);
    expect(repo.current.enabledModules, ['expense']);
  });

  group('SYS-02 scenarios', () {
    testWidgets('Skip on step 1 saves the defaults and opens AUTH-01', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr')];
      tester.platformDispatcher.localeTestValue = const Locale('fr');
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      final repo = await pumpTestApp(tester);
      expect(
        find.text('Track money and habits in one place'),
        findsOneWidget,
        reason: 'an unsupported device language falls back to English',
      );
      await _tap(tester, find.byKey(_skip));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(repo.current.locale, isNull);
      expect(repo.current.currencyCode, 'INR');
      expect(repo.current.enabledModules, ['expense', 'habit']);
      expect(repo.current.onboardingDone, isTrue);
    });

    testWidgets('Skip shows on steps 1–2 only', (tester) async {
      await pumpTestApp(tester);
      expect(find.byKey(_skip), findsOneWidget);
      await _goToStep(tester, 2);
      expect(find.byKey(_skip), findsOneWidget);
      await _goToStep(tester, 2); // to step 3
      expect(find.byKey(_skip), findsNothing);
      await _goToStep(tester, 2); // to step 4
      expect(find.byKey(_skip), findsNothing);
    });

    testWidgets('currency search filters by name and shows no matches', (
      tester,
    ) async {
      await pumpTestApp(tester);
      await _goToStep(tester, 2);
      final search = find.byKey(const Key('onboarding_currency_search'));

      await tester.enterText(search, 'dol');
      await tester.pumpAndSettle();
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.byKey(const Key('currency_INR')), findsNothing);

      await tester.enterText(search, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No matches'), findsOneWidget);
      await _tap(tester, find.text('Clear search'));
      expect(find.byKey(const Key('currency_INR')), findsOneWidget);
    });

    testWidgets('INR is preselected for an en_IN device', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('en', 'IN')];
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pumpTestApp(tester);
      await _goToStep(tester, 2);
      final inr = tester.widget<ListTile>(
        find.byKey(const Key('currency_INR')),
      );
      expect(inr.selected, isTrue);
    });

    testWidgets('Water and Period are disabled "Coming soon" rows', (
      tester,
    ) async {
      await pumpTestApp(tester);
      await _goToStep(tester, 3);
      for (final id in ['water', 'period']) {
        final finder = find.byKey(Key('module_soon_$id'));
        await tester.ensureVisible(finder);
        final tile = tester.widget<SwitchListTile>(finder);
        expect(tile.onChanged, isNull);
        expect(tile.value, isFalse);
      }
      expect(find.text('Coming soon'), findsNWidgets(2));
    });

    testWidgets('changing language keeps the other choices', (tester) async {
      await pumpTestApp(tester);
      await _goToStep(tester, 2);
      await _tap(tester, find.byKey(const Key('currency_USD')));
      await _tap(tester, find.byKey(_back));
      await _tap(tester, find.text('हिन्दी'));
      await _goToStep(tester, 2);
      final usd = tester.widget<ListTile>(
        find.byKey(const Key('currency_USD')),
      );
      expect(usd.selected, isTrue);
    });

    testWidgets('a failed save keeps the choices and offers retry', (
      tester,
    ) async {
      final repo = FakeSettingsRepository(failNextCompleteOnboarding: true);
      await pumpTestApp(tester, settings: repo);
      await _goToStep(tester, 2);
      await _tap(tester, find.byKey(const Key('currency_USD')));
      await _goToStep(tester, 3); // to step 4
      await _tap(tester, find.byKey(_primary));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(
        find.text("Couldn't save your choices. Try again."),
        findsOneWidget,
      );
      expect(find.text('Your data stays with you'), findsOneWidget);
      expect(repo.current.onboardingDone, isFalse);

      await _tap(tester, find.byKey(_retry));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(repo.current.currencyCode, 'USD');
    });

    testWidgets('a failed Skip also offers retry', (tester) async {
      final repo = FakeSettingsRepository(failNextCompleteOnboarding: true);
      await pumpTestApp(tester, settings: repo);
      await _tap(tester, find.byKey(_skip));
      expect(
        find.text("Couldn't save your choices. Try again."),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(_retry));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(repo.current.onboardingDone, isTrue);
    });

    testWidgets('a returning user never sees onboarding', (tester) async {
      await pumpTestApp(
        tester,
        settings: FakeSettingsRepository(
          initial: const AppSettings(onboardingDone: true),
        ),
      );
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  for (final (label, key) in [('"Get started"', _primary), ('Skip', _skip)]) {
    testWidgets('SYS-02 $label marks onboarding done and opens AUTH-01; back '
        'on AUTH-01 never returns to Intro', (tester) async {
      final system = _recordSystemCalls(tester);
      final repo = await pumpTestApp(tester);
      if (key == _primary) await _goToStep(tester, 4);
      await _tap(tester, find.byKey(key));
      expect(repo.current.onboardingDone, isTrue);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(system, contains('SystemNavigator.pop'));
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  }

  testWidgets('SYS-02 Intro shows no "Restore with Google" or "Set app lock" '
      'option', (tester) async {
    await pumpTestApp(tester);
    for (var step = 1; step <= 4; step++) {
      expect(find.byKey(const Key('sys02.restoreWithGoogle')), findsNothing);
      expect(find.byKey(const Key('onboarding_set_app_lock')), findsNothing);
      expect(find.text('Restore with Google'), findsNothing);
      expect(find.text('Set app lock'), findsNothing);
      if (step < 4) await _tap(tester, find.byKey(_primary));
    }
    expect(
      find.text(
        'Everything you log is kept on this phone. Next, you can back it up '
        'with Google or continue as a guest.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(_allow), findsOneWidget);
  });

  testWidgets('SYS-02 closing the app during Intro shows Intro again on the '
      'next start; closing it on AUTH-01 shows AUTH-01, not Intro', (
    tester,
  ) async {
    final repo = await pumpTestApp(tester);
    await _goToStep(tester, 3);
    await restartTestApp(tester, settings: repo);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(repo.current.onboardingDone, isFalse);

    await _tap(tester, find.byKey(_skip));
    expect(find.byType(LoginScreen), findsOneWidget);
    await restartTestApp(tester, settings: repo);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(repo.current.authMode, AuthMode.none);
  });
}
