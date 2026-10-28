import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/core/backup/backup_test_support.dart';
import 'helpers/app_harness.dart';

/// Google journey on a device (feature 012 T020, spec FR-008, US2 scenario
/// 5), replacing feature 010's flow that ended on the removed SYS-02
/// "Restore with Google". Everything is real (database, backup engine,
/// account service, restore, erase) except Google: the account chooser and
/// Drive are in-memory fakes that keep their backups across the sign-out.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  Finder nav(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Future<Map<String, (int, String)>> checksums(WidgetTester tester) =>
      tableChecksums(containerOf(tester).read(appDatabaseProvider));

  AuthMode authMode(WidgetTester tester) =>
      containerOf(tester).read(appSettingsProvider).value!.authMode;

  /// Intro → AUTH-01 "Continue with Google". The fake account has no
  /// backup, so the first backup runs and Home opens, maybe after "Finish
  /// setting up".
  Future<void> signInFresh(WidgetTester tester, HarnessWorld world) async {
    await tapKey(tester, 'onboarding_skip');
    await tapKey(tester, 'auth01_google');
    await pumpUntil(
      tester,
      () =>
          shows(find.byType(HomeScreen)) ||
          shows(find.byKey(const Key('finish_setup'))),
    );
    if (shows(find.byKey(const Key('finish_setup')))) {
      await tapKey(tester, 'finish_setup_later');
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(authMode(tester), AuthMode.google);
  }

  Future<void> addExpense(WidgetTester tester, String amount) async {
    await tester.tap(nav('Home'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'home_fab');
    await tapKey(tester, 'home_quick_add_expense_quickAdd');
    for (final d in amount.split('')) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tapKey(tester, 'save_transaction');
  }

  /// More → the account card → ACC-01.
  Future<void> openAccount(WidgetTester tester) async {
    await tester.tap(nav('More'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'set01_accountGoogle');
    expect(find.byType(AccountScreen), findsOneWidget);
  }

  Future<void> backUpNow(WidgetTester tester, HarnessWorld world) async {
    final before = world.drive.files.length;
    await openAccount(tester);
    await tapKey(tester, 'acc01.backUpNow');
    await pumpUntil(tester, () => world.drive.files.length > before);
  }

  testWidgets('§16 sign in → back up → sign out removing data → sign in '
      'restores the newest backup at once (no data on this phone) and gives '
      'back the same rows', (tester) async {
    final world = HarnessWorld();
    await launch(tester, world);
    await signInFresh(tester, world);
    expect(world.drive.files, hasLength(1), reason: 'first backup');

    await addExpense(tester, '250');
    await addExpense(tester, '1200');
    await backUpNow(tester, world);
    final expected = await checksums(tester);
    expect(expected['transactions']!.$1, 2);

    // ACC-03: the backup is current; remove the data and sign out.
    await tapKey(tester, 'acc01.signOut');
    await pumpUntil(
      tester,
      () => shows(find.byKey(const Key('acc03_backedUp'))),
    );
    await tapKey(tester, 'acc03_remove');
    await tapKey(tester, 'acc03_signOut');
    await pumpUntil(tester, () => shows(find.byType(LoginScreen)));
    expect(authMode(tester), AuthMode.none);
    expect((await checksums(tester))['transactions']!.$1, 0);
    expect(world.drive.files, hasLength(2), reason: 'Drive backups are kept');

    // AUTH-01 again: no data on this phone, so ACC-02 is not shown and the
    // newest backup is restored at once (spec §16 ACC-02).
    await tapKey(tester, 'auth01_google');
    await pumpUntil(
      tester,
      () =>
          shows(find.byType(HomeScreen)) ||
          shows(find.byKey(const Key('finish_setup'))),
    );
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    if (shows(find.byKey(const Key('finish_setup')))) {
      await tapKey(tester, 'finish_setup_later');
    }
    expect(authMode(tester), AuthMode.google);
    expect(await checksums(tester), expected);
    await closeApp(tester);
  });

  testWidgets('§16 ACC-02: signing in again with data still on this phone '
      'shows the restore choice, and "Restore" gives back the backup', (
    tester,
  ) async {
    final world = HarnessWorld();
    await launch(tester, world);
    await signInFresh(tester, world);
    await addExpense(tester, '480');
    await backUpNow(tester, world);
    final expected = await checksums(tester);

    // ACC-03 with the default "Keep data on this phone".
    await tapKey(tester, 'acc01.signOut');
    await pumpUntil(
      tester,
      () => shows(find.byKey(const Key('acc03_backedUp'))),
    );
    await tapKey(tester, 'acc03_signOut');
    await pumpUntil(tester, () => shows(find.byType(LoginScreen)));
    expect((await checksums(tester))['transactions']!.$1, 1);

    await tapKey(tester, 'auth01_google');
    await pumpUntil(tester, () => shows(find.byKey(const Key('acc02_sheet'))));
    await tapKey(tester, 'acc02_restore');
    await pumpUntil(
      tester,
      () =>
          shows(find.byType(HomeScreen)) ||
          shows(find.byKey(const Key('finish_setup'))),
    );
    if (shows(find.byKey(const Key('finish_setup')))) {
      await tapKey(tester, 'finish_setup_later');
    }
    expect(authMode(tester), AuthMode.google);
    expect(await checksums(tester), expected);
    await closeApp(tester);
  });
}
