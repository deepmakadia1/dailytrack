import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../account/account_test_app.dart';
import '../expense/expense_test_app.dart' show locationOf;
import '../expense/fakes.dart' show fakeNow;

/// SET-01 account card (feature 011 T040, spec §10 SET-01 item 1). "Changing
/// currency changes formatting only" is settings_screen_test.dart "SET-01
/// AC: changing currency changes formatting only"; "Ad privacy choices" is
/// settings_ad_privacy_test.dart; "Log out of guest" comes with ACC-04
/// (feature 011 US7).
void main() {
  /// A guest with some data and no account.
  final guest = signedIn.copyWith(
    authMode: AuthMode.guest,
    backupAccountEmail: null,
    accountDisplayName: null,
  );
  final fiveMinAgo = fakeNow
      .subtract(const Duration(minutes: 5))
      .toUtc()
      .millisecondsSinceEpoch;

  Future<AccountWorld> pumpMore(
    WidgetTester tester,
    AppSettings initial, {
    FakeNetworkStateSource? network,
  }) => pumpAccountApp(
    tester,
    initial: initial,
    location: Routes.more,
    network: network,
  );

  Text statusText(WidgetTester tester) => tester.widget<Text>(
    find.descendant(
      of: find.byKey(const Key('set01_accountStatus')),
      matching: find.byType(Text),
    ),
  );

  testWidgets('SET-01 The account card is the first item. As a guest it shows '
      '"Guest · Data saved only on this phone" and "Sign in with Google," '
      'which starts guest sign-in', (tester) async {
    final world = await pumpMore(tester, guest);
    final card = find.byKey(const Key('set01_accountCard'));
    expect(card, findsOneWidget);
    expect(
      tester.getTopLeft(card).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('premium_card'))).dy),
    );
    expect(find.byKey(const Key('set01_accountGuest')), findsOneWidget);
    expect(find.text('Guest · Data saved only on this phone'), findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.text('Sign in with Google')),
      findsOneWidget,
    );

    // The card itself is not tappable.
    await tester.tap(find.text('Guest · Data saved only on this phone'));
    await tester.pumpAndSettle();
    expect(locationOf(tester), Routes.more);
    expect(world.auth.calls, isEmpty);

    await tapKey(tester, 'set01_accountSignIn');
    expect(world.auth.signIns, 1, reason: 'guest sign-in started');
  });

  testWidgets('SET-01 signed in with Google, the card shows the name, email, '
      'initial, and "Backed up to Google" with the last backup\'s relative '
      'time, and opens ACC-01', (tester) async {
    await pumpMore(tester, signedIn.copyWith(lastBackupAt: fiveMinAgo));
    expect(find.byKey(const Key('set01_accountGoogle')), findsOneWidget);
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
    expect(find.byKey(const Key('set01_initial')), findsOneWidget);
    expect(statusText(tester).data, 'Backed up to Google · 5 min ago');
    expect(find.byKey(const Key('set01_accountGuest')), findsNothing);

    // Pushed above SET-01 (the router's location stays /more).
    await tapKey(tester, 'set01_accountGoogle');
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('SET-01 a photo shows in place of the initial', (tester) async {
    await pumpMore(
      tester,
      signedIn.copyWith(accountPhotoUrl: 'https://example.com/me.png'),
    );
    expect(find.byKey(const Key('set01_photo')), findsOneWidget);
  });

  testWidgets('SET-01 the Google card status lines', (tester) async {
    final nowMs = fakeNow.toUtc().millisecondsSinceEpoch;
    for (final (settings, text, warning) in [
      (signedIn, 'Not backed up yet', false),
      (
        signedIn.copyWith(backupLeaseUntil: nowMs + 60000),
        'Backing up…',
        false,
      ),
      (
        signedIn.copyWith(autoBackupPausedByConflict: true),
        'Backup paused',
        true,
      ),
      (signedIn.copyWith(autoBackupFailures: 3), 'Backup failed', true),
    ]) {
      await pumpMore(tester, settings);
      expect(statusText(tester).data, text);
      // Never color alone: paused and failed carry an icon.
      expect(
        find.descendant(
          of: find.byKey(const Key('set01_accountStatus')),
          matching: find.byIcon(Icons.error_outline),
        ),
        warning ? findsOneWidget : findsNothing,
        reason: text,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });

  testWidgets('SET-01 offline, the card keeps the last successful state '
      '(clarification Q3)', (tester) async {
    await pumpMore(
      tester,
      signedIn.copyWith(lastBackupAt: fiveMinAgo),
      network: FakeNetworkStateSource(online: false),
    );
    expect(statusText(tester).data, 'Backed up to Google · 5 min ago');
  });

  testWidgets('SET-01 offline as a guest, the card says "Connect to the '
      'internet to sign in with Google" and makes no request', (tester) async {
    final world = await pumpMore(
      tester,
      guest,
      network: FakeNetworkStateSource(online: false),
    );
    expect(find.byKey(const Key('set01_accountOffline')), findsOneWidget);
    await tapKey(tester, 'set01_accountSignIn');
    expect(world.auth.calls, isEmpty);
    expect(world.drive.calls, isEmpty);
    expect(world.settings.current.authMode, AuthMode.guest);
  });

  for (final (label, settings) in [('guest', guest), ('Google', signedIn)]) {
    testWidgets('SET-01 No text on this screen says "Synced" or "Sync." '
        '($label)', (tester) async {
      await pumpMore(tester, settings.copyWith(lastBackupAt: fiveMinAgo));
      final list = find.byKey(const Key('settings_list'));
      final seen = <String>{};
      for (var i = 0; i < 40; i++) {
        for (final e in find.byType(Text).evaluate()) {
          final w = e.widget as Text;
          final text = w.data ?? w.textSpan?.toPlainText() ?? '';
          seen.add(text);
        }
        final position = tester
            .state<ScrollableState>(
              find
                  .descendant(of: list, matching: find.byType(Scrollable))
                  .first,
            )
            .position;
        if (position.pixels >= position.maxScrollExtent) break;
        await tester.drag(list, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(seen, isNotEmpty);
      for (final text in seen) {
        expect(text.toLowerCase(), isNot(contains('sync')), reason: text);
      }
    });
  }
}
