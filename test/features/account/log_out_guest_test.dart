import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../auth/login_test_app.dart' show recordSystemCalls;
import '../expense/expense_test_app.dart' show locationOf;
import 'account_test_app.dart';

/// ACC-04 Log out of guest (feature 011 T054, spec §16). The data-level
/// criteria (module rows, receipts, the safety copy, unlocks, the PIN and
/// lockout state, the backup password, notifications, jobs, kept settings,
/// one transaction) are the `ACC-04 …` cases in
/// test/core/reset/drift_app_reset_service_test.dart, over a real database.
void main() {
  /// A guest with a theme and modules.
  final guestWithPrefs = guest.copyWith(
    locale: 'en',
    currencyCode: 'USD',
    themeMode: 'dark',
    enabledModules: const ['habit'],
    removeAdsPurchased: true,
  );

  /// What the real guest erase leaves (data-model §3).
  void eraseLikeGuestLogOut(AccountWorld w) => w.reset.onErase = () {
    final s = w.settings.current;
    w.settings.replace(
      AppSettings(
        onboardingDone: true,
        locale: s.locale,
        currencyCode: s.currencyCode,
        themeMode: s.themeMode,
        selectedTheme: s.selectedTheme,
        enabledModules: s.enabledModules,
        moduleOrder: s.moduleOrder,
        removeAdsPurchased: s.removeAdsPurchased,
        deviceId: s.deviceId,
      ),
    );
  };

  Future<AccountWorld> openAcc04(
    WidgetTester tester, {
    AppSettings? initial,
    FakeAdService? ads,
    String? pin,
    void Function(AccountWorld w)? arrange,
  }) async {
    final world = await pumpAccountApp(
      tester,
      initial: initial ?? guestWithPrefs,
      location: Routes.more,
      ads: ads,
      pin: pin,
      arrange: arrange,
    );
    if (pin != null) {
      // App lock is on: unlock first.
      for (final d in pin.split('')) {
        await tester.tap(find.byKey(Key('pin_key_$d')));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }
    final row = find.byKey(const Key('set01_logOutGuest'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapKey(tester, 'set01_logOutGuest');
    expect(find.byKey(const Key('acc04_dialog')), findsOneWidget);
    return world;
  }

  testWidgets('ACC-04 shows the title, the body, and the three actions', (
    tester,
  ) async {
    await openAcc04(tester);
    expect(find.text('Log out and delete your data?'), findsOneWidget);
    expect(
      find.text(
        'As a guest, your data is stored only on this phone. Logging out '
        'permanently deletes all your expenses, habits, budgets, receipts, '
        "and unlocks. This can't be undone.",
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('acc04_signInInstead')), findsOneWidget);
    expect(find.byKey(const Key('acc04_cancel')), findsOneWidget);
    expect(find.byKey(const Key('acc04_confirm')), findsOneWidget);
  });

  for (final how in ['Cancel', 'back', 'tapping outside']) {
    testWidgets('ACC-04 "Cancel," back, and tapping outside delete nothing: '
        'settings and authMode = guest are unchanged ($how)', (tester) async {
      final world = await openAcc04(tester);
      final before = world.settings.current;
      switch (how) {
        case 'Cancel':
          await tapKey(tester, 'acc04_cancel');
        case 'back':
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        default:
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('acc04_dialog')), findsNothing);
      expect(world.reset.calls, 0);
      expect(world.settings.current, before);
      expect(world.settings.current.authMode, AuthMode.guest);
    });
  }

  testWidgets('ACC-04 "Sign in with Google instead" deletes nothing and starts '
      'guest sign-in', (tester) async {
    final world = await openAcc04(tester);
    await tapKey(tester, 'acc04_signInInstead');
    expect(find.byKey(const Key('acc04_dialog')), findsNothing);
    expect(world.reset.calls, 0);
    expect(world.auth.calls, ['signIn']);
    // The account had no backup: signed in, and this phone backed up.
    expect(world.settings.current.authMode, AuthMode.google);
    expect(world.backup.driveBackups, 1);
  });

  testWidgets('ACC-04 "Log out and delete" runs the guest erase; afterwards '
      'language, currency, theme, enabled modules, onboarding done, and Pro '
      'are kept, authMode is none, and the app opens AUTH-01 with no way '
      'back; a restart opens AUTH-01, not Intro or SYS-03', (tester) async {
    final system = recordSystemCalls(tester);
    final ads = FakeAdService();
    final world = await openAcc04(
      tester,
      ads: ads,
      initial: guestWithPrefs.copyWith(lockEnabled: true),
      pin: '1234',
      arrange: eraseLikeGuestLogOut,
    );
    await tapKey(tester, 'acc04_confirm');

    expect(world.reset.scopes, [EraseScope.guestLogOut]);
    final s = world.settings.current;
    expect(s.authMode, AuthMode.none);
    expect(s.locale, 'en');
    expect(s.currencyCode, 'USD');
    expect(s.themeMode, 'dark');
    expect(s.enabledModules, ['habit']);
    expect(s.onboardingDone, isTrue);
    expect(s.removeAdsPurchased, isTrue);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(locationOf(tester), Routes.login);
    expect(find.byKey(const Key('acc04_dialog')), findsNothing);
    // No interstitial over the dialog or over AUTH-01 after it.
    expect(ads.triggers, isEmpty);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(system, contains('SystemNavigator.pop'));
    expect(find.byType(LoginScreen), findsOneWidget);

    await restartTestApp(tester, settings: world.settings);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(UnlockScreen), findsNothing);
  });

  testWidgets('ACC-04 while deleting, the confirm button shows progress and '
      'every action is disabled; back does nothing', (tester) async {
    final gate = Completer<void>();
    final world = await openAcc04(tester, arrange: (w) => w.reset.gate = gate);
    await tester.tap(find.byKey(const Key('acc04_confirm')));
    await tester.pump();
    for (final key in ['acc04_signInInstead', 'acc04_cancel']) {
      expect(
        tester.widget<TextButton>(find.byKey(Key(key))).onPressed,
        isNull,
        reason: key,
      );
    }
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('acc04_confirm')))
          .onPressed,
      isNull,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('acc04_confirm')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('acc04_dialog')), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(world.reset.calls, 1);
  });

  testWidgets('ACC-04 "Log out and delete" is shown in error color', (
    tester,
  ) async {
    await openAcc04(tester);
    final context = tester.element(find.byKey(const Key('acc04_confirm')));
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('acc04_confirm')),
    );
    expect(
      button.style?.backgroundColor?.resolve({}),
      Theme.of(context).colorScheme.error,
    );
  });

  testWidgets('ACC-04 A failed erase leaves all data and settings in place: '
      'the dialog says it could not delete, and the user stays a guest', (
    tester,
  ) async {
    final world = await openAcc04(
      tester,
      arrange: (w) => w.reset.failNext = Exception('disk full'),
    );
    final before = world.settings.current;
    await tapKey(tester, 'acc04_confirm');
    expect(find.byKey(const Key('acc04_failed')), findsOneWidget);
    expect(find.text("Couldn't delete your data. Try again."), findsOneWidget);
    expect(find.byKey(const Key('acc04_dialog')), findsOneWidget);
    expect(world.settings.current, before);
    expect(world.settings.current.authMode, AuthMode.guest);
  });

  testWidgets('SET-01 "Log out of guest" appears in the Data group only in the '
      'guest state, in error color, and opens ACC-04', (tester) async {
    await openAcc04(tester);
    await tapKey(tester, 'acc04_cancel');
    final row = find.byKey(const Key('set01_logOutGuest'));
    final context = tester.element(row);
    final title = tester.widget<Text>(
      find.descendant(of: row, matching: find.text('Log out of guest')),
    );
    expect(title.style?.color, Theme.of(context).colorScheme.error);
    // Below Erase all data, in the Data group.
    expect(
      tester.getTopLeft(row).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('settings_erase_all'))).dy,
      ),
    );
  });

  testWidgets('ACC-04 "Log out of guest" never appears in the Google state', (
    tester,
  ) async {
    await pumpAccountApp(tester, location: Routes.more);
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 30; i++) {
      expect(find.byKey(const Key('set01_logOutGuest')), findsNothing);
      final position = tester.state<ScrollableState>(list).position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('set01_logOutGuest')), findsNothing);
  });
}
