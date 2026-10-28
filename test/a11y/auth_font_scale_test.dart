import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';

/// §15.10 for feature 011 (T061): AUTH-01 Login (default and inline
/// error), the SET-01 account card (guest and Google), and ACC-04 Log out
/// of guest, at 200% font scale on a
/// 360×780 dp screen, in en, hi, and gu, light and dark: no overflow
/// (reported as a test failure), 48 dp labelled tap targets, and text
/// contrast.
void main() {
  const phone = Size(360, 780);

  Future<AccountWorld> pump(
    WidgetTester tester, {
    required String lang,
    required String theme,
    void Function(AccountWorld w)? arrange,
  }) async {
    final world = await pumpAccountApp(
      tester,
      initial: AppSettings(
        onboardingDone: true,
        locale: lang,
        themeMode: theme,
      ),
      authModeStored: true,
      location: null,
      arrange: arrange,
    );
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    return world;
  }

  Future<void> expectAccessible(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final lang in ['en', 'hi', 'gu']) {
    for (final theme in ['light', 'dark']) {
      final name = '$lang $theme';

      testWidgets('AUTH-01 default, $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, theme: theme);
        expect(find.byKey(const Key('auth01_google')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('AUTH-01 inline error, $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(
          tester,
          lang: lang,
          theme: theme,
          arrange: (w) => w.auth.signInResult = const DriveAuthRequired(),
        );
        final google = find.byKey(const Key('auth01_google'));
        await tester.ensureVisible(google);
        await tester.pumpAndSettle();
        await tester.tap(google);
        await tester.pumpAndSettle();
        final tryAgain = find.byKey(const Key('auth01_tryAgain'));
        await tester.ensureVisible(tryAgain);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth01_error')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });
    }
  }

  Future<void> pumpMore(
    WidgetTester tester, {
    required AppSettings initial,
  }) async {
    await pumpAccountApp(tester, initial: initial, location: Routes.more);
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
  }

  for (final lang in ['en', 'hi', 'gu']) {
    for (final theme in ['light', 'dark']) {
      final name = '$lang $theme';
      final asGuest = guest.copyWith(locale: lang, themeMode: theme);
      final asGoogle = signedIn.copyWith(
        locale: lang,
        themeMode: theme,
        autoBackupPausedByConflict: true,
      );

      testWidgets('SET-01 account card, guest, $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpMore(tester, initial: asGuest);
        expect(find.byKey(const Key('set01_accountGuest')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('SET-01 account card, Google with a warning, $name', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpMore(tester, initial: asGoogle);
        expect(find.byKey(const Key('set01_accountGoogle')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('ACC-04 Log out of guest, $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpMore(tester, initial: asGuest);
        final row = find.byKey(const Key('set01_logOutGuest'));
        await tester.scrollUntilVisible(
          row,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tapKey(tester, 'set01_logOutGuest');
        expect(find.byKey(const Key('acc04_dialog')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });
    }
  }
}
