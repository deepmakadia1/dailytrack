import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/expense/fakes.dart';
import '../helpers/fake_webview.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// §15.10 design review for feature 009 (T121, FR-050): PRM-01, PRM-02,
/// the SET-01 premium card, and every screen that now shows ads (with ads
/// loaded), at 200% font on a 360 dp screen, in en, hi, and gu, light and
/// dark: no overflow, 48 dp tap targets, labelled controls.
void main() {
  setUp(FakeWebViewPlatform.install);
  const languages = ['en', 'hi', 'gu'];

  Future<void> setUpSurface(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> expectAccessible(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  Future<void> pump(
    WidgetTester tester, {
    required String lang,
    required String themeMode,
    bool pro = false,
    FakeAdService? ads,
    FakeProStore? store,
  }) async {
    await setUpSurface(tester);
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          locale: lang,
          themeMode: themeMode,
          removeAdsPurchased: pro,
        ),
      ),
      expense: ExpenseFakes.withDefaults(),
      ads: ads,
      proStore: store,
    );
  }

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  for (final lang in languages) {
    for (final mode in ['light', 'dark']) {
      group('$lang $mode', () {
        testWidgets('PRM-01 ready at 200%', (tester) async {
          final semantics = tester.ensureSemantics();
          await pump(tester, lang: lang, themeMode: mode);
          unawaited(routerOf(tester).push<void>(Routes.premium));
          await tester.pumpAndSettle();
          expect(find.byType(PremiumScreen), findsOneWidget);
          await expectAccessible(tester);
          await tester.scrollUntilVisible(
            find.byKey(const Key('premium_account_note')),
            100,
          );
          await expectAccessible(tester);
          semantics.dispose();
        });

        testWidgets('PRM-01 owned at 200%', (tester) async {
          final semantics = tester.ensureSemantics();
          await pump(tester, lang: lang, themeMode: mode, pro: true);
          unawaited(routerOf(tester).push<void>(Routes.premium));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('premium_owned')), findsOneWidget);
          await expectAccessible(tester);
          semantics.dispose();
        });

        testWidgets('PRM-02 sheet (from EXP-11) at 200%', (tester) async {
          final semantics = tester.ensureSemantics();
          await pump(tester, lang: lang, themeMode: mode, ads: FakeAdService());
          await go(tester, Routes.expenseReports);
          // At 200% the tab bar scrolls; bring Trends into view first.
          await tester.ensureVisible(find.byKey(const ValueKey('tab_trends')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('tab_trends')));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byKey(const Key('locked_watch_ad')));
          await tester.pumpAndSettle();
          await expectAccessible(tester);
          await tester.tap(find.byKey(const Key('locked_watch_ad')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('rewarded_watch')), findsOneWidget);
          await expectAccessible(tester);
          semantics.dispose();
        });

        testWidgets('SET-01 with the premium card and a loaded banner at '
            '200%', (tester) async {
          final semantics = tester.ensureSemantics();
          await pump(
            tester,
            lang: lang,
            themeMode: mode,
            ads: FakeAdService(view: FakeAdView()),
          );
          await go(tester, Routes.more);
          expect(find.byKey(const Key('premium_card')), findsOneWidget);
          expect(find.byKey(const Key('fake_ad_view')), findsOneWidget);
          await expectAccessible(tester);
          semantics.dispose();
        });

        for (final location in [
          Routes.home,
          Routes.expenses,
          Routes.expenseBudgets,
          Routes.habits,
          Routes.expenseCategories,
          Routes.expenseAccounts,
          Routes.backup,
        ]) {
          testWidgets('$location with ads loaded at 200%', (tester) async {
            final semantics = tester.ensureSemantics();
            await pump(
              tester,
              lang: lang,
              themeMode: mode,
              // Worst-case sizes: a native template is 320 dp; a large
              // adaptive banner is at most 15% of the 800 dp screen.
              ads: FakeAdService(
                view: FakeAdView(height: 320),
                bannerView: FakeAdView(height: 120),
              ),
            );
            await go(tester, location);
            await expectAccessible(tester);
            semantics.dispose();
          });
        }
      });
    }
  }
}
