import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/widgets/privacy_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/lock/lock_test_app.dart';
import '../helpers/fake_webview.dart';

/// SC-010 / §15.10 (feature 007 T073): SET-01, SET-04, SET-05, SYS-03, and
/// SYS-04 at 200% font scale on a 360×780 dp screen, in en, hi, and gu,
/// light and dark: no overflow (reported as a test failure), 48 dp labelled
/// tap targets, and text contrast. Also the erase dialogs, the Forgot PIN
/// sheet, and onboarding step 4.
void main() {
  const phone = Size(360, 780);

  setUp(FakeWebViewPlatform.install);

  Future<LockWorld> pump(
    WidgetTester tester, {
    required String lang,
    required String themeMode,
    String? pin,
    String fontSize = 'default',
    bool onboardingDone = true,
  }) async {
    final w = await pumpLockApp(
      tester,
      pin: pin,
      initial: AppSettings(
        onboardingDone: onboardingDone,
        locale: lang,
        themeMode: themeMode,
        lockEnabled: pin != null,
        fontSize: fontSize,
      ),
    );
    // After pumpLockApp, which sets a phone size of its own.
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    return w;
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

  /// Checks every screenful of the main list.
  Future<void> scrollAndCheck(WidgetTester tester, Key list) async {
    await expectAccessible(tester);
    final scroll = find.byKey(list);
    for (var i = 0; i < 30; i++) {
      final position = tester
          .state<ScrollableState>(
            find
                .descendant(of: scroll, matching: find.byType(Scrollable))
                .first,
          )
          .position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(scroll, const Offset(0, -300));
      await tester.pumpAndSettle();
      await expectAccessible(tester);
    }
  }

  /// SET-01 is long: brings each section header to the top, then checks
  /// targets and labels. Text contrast is proven in color_themes_test.dart
  /// instead: under SET-01's large-title app bar the guideline samples each
  /// node at its local rectangle (without the app bar offset), i.e. empty
  /// background (checked against a screenshot during feature 007).
  Future<void> checkEachSection(
    WidgetTester tester,
    List<String> headers,
  ) async {
    await expectAccessible(tester, contrast: false);
    final scrollable = find
        .descendant(
          of: find.byKey(const Key('settings_list')),
          matching: find.byType(Scrollable),
        )
        .first;
    for (final header in headers) {
      final finder = find.text(header).first;
      await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
      await tester.pumpAndSettle();
      await Scrollable.ensureVisible(tester.element(finder));
      await tester.pumpAndSettle();
      await expectAccessible(tester, contrast: false);
    }
  }

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  for (final lang in const ['en', 'hi', 'gu']) {
    for (final theme in const ['light', 'dark']) {
      final tag = '$lang, $theme';

      testWidgets('SET-01 at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme);
        await go(tester, Routes.more);
        final l10n = AppLocalizations.of(
          tester.element(find.byKey(const Key('settings_list'))),
        );
        await checkEachSection(tester, [
          l10n.settings_general,
          l10n.settings_appearance,
          l10n.settings_modules,
          l10n.settings_notifications,
          l10n.settings_security,
          l10n.settings_data,
          l10n.settings_privacy,
          l10n.settings_about,
        ]);
        semantics.dispose();
      });

      testWidgets('SET-04 at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme);
        await go(tester, Routes.themes);
        await scrollAndCheck(tester, const Key('themes_list'));
        semantics.dispose();
      });

      testWidgets('SET-05 at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme);
        await go(tester, Routes.security);
        await scrollAndCheck(tester, const Key('security_list'));
        semantics.dispose();
      });

      testWidgets('SYS-03 at 200%, also locked out ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        final w = await pump(tester, lang: lang, themeMode: theme, pin: '1234');
        expect(find.byType(UnlockScreen), findsOneWidget);
        await expectAccessible(tester);
        for (var i = 0; i < 5; i++) {
          await enterPin(tester, '0000');
        }
        await expectAccessible(tester);
        w.expense.clock.advance(const Duration(seconds: 30));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        semantics.dispose();
      });

      testWidgets('SYS-04 at 200%, every step ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme);
        await go(tester, Routes.more);
        await go(tester, Routes.pinPath(Routes.pinModeSet));
        expect(find.byType(PinScreen), findsOneWidget);
        await expectAccessible(tester);
        await enterPin(tester, '1234');
        await expectAccessible(tester);
        await enterPin(tester, '9999');
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('erase dialogs at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme);
        await go(tester, Routes.more);
        final row = find.byKey(const Key('settings_erase_all'));
        final l10n = AppLocalizations.of(
          tester.element(find.byKey(const Key('settings_list'))),
        );
        await tester.scrollUntilVisible(
          row,
          200,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('settings_list')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await Scrollable.ensureVisible(tester.element(row));
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();
        expect(find.text(l10n.erase_title), findsOneWidget);
        await expectAccessible(tester);
        await tester.tap(find.text(l10n.erase_continue));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        await tester.enterText(
          find.byKey(const Key('typed_confirm_field')),
          'DELETE',
        );
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('Forgot PIN sheet at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme, pin: '1234');
        await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('forgot_pin_erase')), findsOneWidget);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('onboarding step 4 at 200% ($tag)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, lang: lang, themeMode: theme, onboardingDone: false);
        for (var i = 1; i < 4; i++) {
          final next = find.byKey(const Key('onboarding_primary'));
          await tester.ensureVisible(next);
          await tester.pumpAndSettle();
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        await expectAccessible(tester);
        // Step 4 is a lazy list; at 200% the button may start below the
        // fold.
        final allow = find.byKey(const Key('onboarding_allow_notifications'));
        await tester.scrollUntilVisible(
          allow,
          200,
          scrollable: find
              .descendant(
                of: find.byType(PrivacyStep),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });
    }
  }

  testWidgets('SET-04 Large font on top of 200%: capped at 200%, no overflow', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, lang: 'gu', themeMode: 'light', fontSize: 'large');
    await go(tester, Routes.themes);
    final scale =
        MediaQuery.textScalerOf(
          tester.element(find.byKey(const Key('themes_list'))),
        ).scale(10) /
        10;
    expect(scale, 2);
    await scrollAndCheck(tester, const Key('themes_list'));
    semantics.dispose();
  });
}
