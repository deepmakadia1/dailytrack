import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dailytrack/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// Spec §11 and FR-009: banner and native ads never appear on add/edit
/// forms, lock, onboarding, or premium screens (feature 009 T036). The ad
/// service here would fill every slot it is asked for, so any placed slot
/// would show a visible fake ad.
void main() {
  late FakeAdService ads;

  setUp(() => ads = FakeAdService(view: FakeAdView()));

  Future<void> pump(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true),
    TestLock? lock,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTestApp(
      tester,
      ads: ads,
      lock: lock,
      settings: FakeSettingsRepository(initial: initial),
    );
  }

  Future<void> push(WidgetTester tester, String location) async {
    unawaited(routerOf(tester).push<void>(location));
    await tester.pumpAndSettle();
  }

  /// No ad slot inside [screen], and no fake ad visible anywhere on stage.
  void expectNoAds(Finder screen) {
    expect(screen, findsOneWidget);
    for (final type in [AppBannerAd, AppNativeAd]) {
      expect(
        find.descendant(of: screen, matching: find.byType(type)),
        findsNothing,
        reason: '$type inside the screen',
      );
    }
    expect(find.byKey(const Key('fake_ad_view')), findsNothing);
  }

  testWidgets('control: the same fake service does fill EXP-01 slots', (
    tester,
  ) async {
    await pump(tester);
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fake_ad_view')), findsWidgets);
  });

  testWidgets('EXP-02 add form has no ads', (tester) async {
    await pump(tester);
    await push(tester, Routes.expenseAdd);
    expectNoAds(find.byType(TransactionFormScreen));
  });

  testWidgets('HAB-02 add form has no ads', (tester) async {
    await pump(tester);
    await push(tester, Routes.habitAdd);
    expectNoAds(find.byType(HabitFormScreen));
  });

  testWidgets('SYS-02 onboarding has no ads', (tester) async {
    await pump(tester, initial: const AppSettings());
    expectNoAds(find.byType(OnboardingScreen));
  });

  testWidgets('SYS-03 lock screen has no ads', (tester) async {
    const settings = AppSettings(onboardingDone: true, lockEnabled: true);
    final repo = FakeSettingsRepository(initial: settings);
    final lock = TestLock(settings: repo);
    await lock.seedPin('1234');
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTestApp(tester, ads: ads, lock: lock, settings: repo);
    expectNoAds(find.byType(UnlockScreen));
  });

  testWidgets('SYS-04 PIN screen has no ads', (tester) async {
    await pump(tester);
    await push(tester, Routes.pinPath(Routes.pinModeSet));
    expectNoAds(find.byType(PinScreen));
  });

  testWidgets('PRM-01 premium screen has no ads', (tester) async {
    await pump(tester);
    await push(tester, Routes.premium);
    expectNoAds(find.byType(PremiumScreen));
  });
}
