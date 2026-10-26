import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';
import '../features/expense/expense_test_app.dart' show routerOf;

/// §15.10 for feature 010 (T100): ACC-01 (signed out, signed in with a
/// paused backup), ACC-02, ACC-03 (failed backup, Remove chosen), SYS-02
/// step 1 with "Restore with Google", and "Finish setting up", at 200% font
/// scale on a 360×780 dp screen, in en, hi, and gu, light and dark: no
/// overflow (reported as a test failure), 48 dp labelled tap targets, and
/// text contrast.
void main() {
  const phone = Size(360, 780);

  Future<AccountWorld> pump(
    WidgetTester tester, {
    required AppSettings initial,
    String? location = Routes.account,
    bool hasData = true,
    void Function(AccountWorld w)? arrange,
  }) async {
    final world = await pumpAccountApp(
      tester,
      initial: initial,
      location: null,
      hasData: hasData,
      arrange: arrange,
    );
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    if (location != null) {
      routerOf(tester).go(location);
    }
    await tester.pumpAndSettle();
    return world;
  }

  Future<void> expectAccessible(
    WidgetTester tester, {
    bool contrast = true,
  }) async {
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    if (contrast) {
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
  }

  /// Every screenful of [scrollable]; contrast on the first only, as in
  /// backup_export_font_scale_test.dart (the guideline samples scrolled
  /// nodes against the app bar).
  Future<void> scrollAndCheck(WidgetTester tester, Finder scrollable) async {
    await expectAccessible(tester);
    for (var i = 0; i < 40; i++) {
      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await expectAccessible(tester, contrast: false);
    }
  }

  Finder screenList() => find
      .descendant(
        of: find.byType(AccountScreen),
        matching: find.byType(Scrollable),
      )
      .first;

  Finder sheetList(String key) => find
      .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
      .first;

  for (final lang in ['en', 'hi', 'gu']) {
    for (final theme in ['light', 'dark']) {
      final name = '$lang $theme';
      AppSettings settings({bool signedInUser = true}) => signedIn.copyWith(
        locale: lang,
        themeMode: theme,
        backupAccountEmail: signedInUser
            ? 'someone.long.name@example.com'
            : null,
        accountDisplayName: signedInUser ? 'Asha Patel' : null,
      );

      testWidgets('ACC-01 signed out, $name', (tester) async {
        await pump(tester, initial: settings(signedInUser: false));
        await scrollAndCheck(tester, screenList());
      });

      testWidgets('ACC-01 signed in, backup paused, $name', (tester) async {
        await pump(
          tester,
          initial: settings().copyWith(autoBackupPausedByConflict: true),
          arrange: (w) => w.drive.seed(meta: otherPhoneMeta(encrypted: true)),
        );
        expect(find.byKey(const Key('acc01_review')), findsOneWidget);
        await scrollAndCheck(tester, screenList());
      });

      testWidgets('ACC-02 restore choice, $name', (tester) async {
        await pump(
          tester,
          initial: settings(),
          arrange: (w) => w.drive.seed(meta: otherPhoneMeta(encrypted: true)),
        );
        await tapKey(tester, 'acc01.restore');
        expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
        await scrollAndCheck(tester, sheetList('acc02_sheet'));
      });

      testWidgets('ACC-03 failed backup with Remove chosen, $name', (
        tester,
      ) async {
        await pump(
          tester,
          initial: settings().copyWith(dataChangeCounter: 3),
          arrange: (w) => w.backup.error = const DriveOffline(),
        );
        await tapKey(tester, 'acc01.signOut');
        await tapKey(tester, 'acc03_remove');
        expect(find.byKey(const Key('acc03_failed')), findsOneWidget);
        await scrollAndCheck(tester, sheetList('acc03_sheet'));
      });

      testWidgets('SYS-02 step 1 with "Restore with Google", $name', (
        tester,
      ) async {
        await pump(
          tester,
          initial: AppSettings(locale: lang, themeMode: theme),
          location: null,
          hasData: false,
        );
        await tapKey(tester, 'sys02.restoreWithGoogle');
        expect(find.byKey(const Key('sys02_restoreMessage')), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Finish setting up, $name', (tester) async {
        await pump(
          tester,
          initial: settings().copyWith(finishSetupPending: true),
          location: Routes.home,
        );
        expect(find.byKey(const Key('finish_setup')), findsOneWidget);
        await expectAccessible(tester);
      });
    }
  }
}
