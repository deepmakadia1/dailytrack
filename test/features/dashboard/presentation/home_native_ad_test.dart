import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../../expense/fakes.dart';
import '../../habit/fakes.dart';

/// DSH-01 native ad position (feature 009 T033, spec §7 and §11): one
/// native ad after the second module card, never above the first.
void main() {
  const native = Key('home_native');
  Finder card(String id) => find.byKey(Key('home_card_$id'));

  Future<void> pumpHome(
    WidgetTester tester, {
    List<String> enabled = const ['expense', 'habit'],
    List<String> order = const ['expense', 'habit'],
    AdService? ads,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final expense = ExpenseFakes.withDefaults();
    await pumpTestApp(
      tester,
      expense: expense,
      habit: HabitFakes(expense.clock),
      ads: ads ?? FakeAdService(view: FakeAdView(height: 320)),
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          enabledModules: enabled,
          moduleOrder: order,
        ),
      ),
    );
  }

  double top(WidgetTester tester, Finder f) => tester.getTopLeft(f).dy;
  double bottom(WidgetTester tester, Finder f) => tester.getBottomLeft(f).dy;

  group('DSH-01 AC native ad never appears above the first module card', () {
    testWidgets('two modules: the ad sits after the second card', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.byKey(native), findsOneWidget);
      expect(
        top(tester, find.byKey(native)),
        greaterThanOrEqualTo(bottom(tester, card('habit'))),
      );
      expect(
        top(tester, card('habit')),
        greaterThan(top(tester, card('expense'))),
      );
    });

    testWidgets('reordered modules: still after both cards', (tester) async {
      await pumpHome(tester, order: const ['habit', 'expense']);
      expect(
        top(tester, find.byKey(native)),
        greaterThanOrEqualTo(bottom(tester, card('expense'))),
      );
      expect(
        top(tester, find.byKey(native)),
        greaterThanOrEqualTo(bottom(tester, card('habit'))),
      );
    });

    for (final only in ['expense', 'habit']) {
      testWidgets('only $only enabled: the ad sits after the only card', (
        tester,
      ) async {
        await pumpHome(tester, enabled: [only]);
        expect(find.byKey(native), findsOneWidget);
        expect(
          top(tester, find.byKey(native)),
          greaterThanOrEqualTo(bottom(tester, card(only))),
        );
      });
    }

    testWidgets('the ad is shown (loaded) and labeled "Ad"', (tester) async {
      await pumpHome(tester);
      expect(tester.getSize(find.byKey(native)).height, greaterThan(300));
      expect(
        find.descendant(of: find.byKey(native), matching: find.text('Ad')),
        findsOneWidget,
      );
    });
  });

  testWidgets('§11 with NoAdsService the Home slot takes no space', (
    tester,
  ) async {
    await pumpHome(tester, ads: const NoAdsService());
    expect(tester.getSize(find.byType(AppNativeAd)).height, 0);
  });
}
