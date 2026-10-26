import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// PRM-01 Premium (feature 009 T083; spec US3, PRM-01 ACs, FR-037 – FR-046).
void main() {
  late FakeProStore store;

  setUp(() => store = FakeProStore());

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true),
    Size size = const Size(412, 915),
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final settings = await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(initial: initial),
      proStore: store,
    );
    unawaited(routerOf(tester).push<void>(Routes.premium));
    await tester.pumpAndSettle();
    expect(find.byType(PremiumScreen), findsOneWidget);
    return settings;
  }

  Finder buy() => find.byKey(const Key('premium_buy'));
  bool enabled(WidgetTester tester, Finder f) =>
      tester.widget<ButtonStyleButton>(f).onPressed != null;

  testWidgets('US3-1 headline, the five benefits, the price from Google '
      'Play, Restore purchase, and the Google account note', (tester) async {
    await open(tester);
    expect(find.text('DailyTrack Pro'), findsWidgets);
    for (final b in [
      'No ads',
      'All themes',
      'Advanced reports',
      'Unlimited exports',
      'Unlimited streak freezes up to the cap',
    ]) {
      expect(find.text(b), findsOneWidget, reason: b);
    }
    expect(find.text('Get Pro for ₹299.00'), findsOneWidget);
    expect(enabled(tester, buy()), isTrue);
    expect(find.text('Restore purchase'), findsOneWidget);
    expect(
      find.text('Your purchase is tied to your Google account.'),
      findsOneWidget,
    );
  });

  testWidgets('US3-1 store unavailable: the button is disabled and says so; '
      'Restore stays available', (tester) async {
    store.available = false;
    await open(tester);
    expect(
      find.descendant(
        of: buy(),
        matching: find.text('Store not available right now, try again later'),
      ),
      findsOneWidget,
    );
    expect(enabled(tester, buy()), isFalse);
    expect(enabled(tester, find.byKey(const Key('premium_restore'))), isTrue);
  });

  testWidgets('US3-2 a completed purchase: "You have Pro", no buy button, '
      'Pro saved', (tester) async {
    final settings = await open(tester);
    await tester.tap(buy());
    await tester.pump();
    expect(store.bought, hasLength(1));
    store.emit(StorePurchaseStatus.purchased, needsCompletion: true);
    await tester.pumpAndSettle();
    expect(settings.current.removeAdsPurchased, isTrue);
    expect(store.completed, hasLength(1), reason: 'acknowledged');
    expect(find.byKey(const Key('premium_owned')), findsOneWidget);
    expect(buy(), findsNothing);
    expect(find.byKey(const Key('premium_restore')), findsNothing);
  });

  testWidgets('US3-3 a cancelled purchase goes back to the price, with no '
      'message', (tester) async {
    await open(tester);
    await tester.tap(buy());
    await tester.pump();
    store.emit(StorePurchaseStatus.canceled);
    await tester.pumpAndSettle();
    expect(enabled(tester, buy()), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('US3-4 a failed purchase explains it and offers Try again', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(buy());
    await tester.pump();
    store.emit(StorePurchaseStatus.error);
    await tester.pumpAndSettle();
    expect(
      find.text("Couldn't complete the purchase. Try again."),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(enabled(tester, buy()), isTrue);
  });

  testWidgets('US3-5 a pending payment says Pro unlocks when it completes', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(buy());
    await tester.pump();
    store.emit(StorePurchaseStatus.pending);
    await tester.pumpAndSettle();
    expect(find.text('Pro unlocks when the payment completes'), findsOneWidget);
    store.emit(StorePurchaseStatus.purchased);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('premium_owned')), findsOneWidget);
  });

  testWidgets('PRM-01 AC reinstalling and tapping "Restore purchase" '
      'restores Pro', (tester) async {
    // A fresh install: nothing saved, but Play says the account owns Pro.
    store.ownership = OwnershipCheck.owned;
    final settings = await open(tester);
    await tester.tap(find.byKey(const Key('premium_restore')));
    await tester.pumpAndSettle();
    expect(find.text('Pro restored'), findsOneWidget);
    expect(settings.current.removeAdsPurchased, isTrue);
    expect(find.byKey(const Key('premium_owned')), findsOneWidget);
  });

  testWidgets('"Restore purchase" with nothing to restore says so', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('premium_restore')));
    await tester.pumpAndSettle();
    expect(
      find.text('No Pro purchase found for this Google account'),
      findsOneWidget,
    );
  });

  testWidgets('FR-046 a double tap starts one purchase', (tester) async {
    await open(tester);
    await tester.tap(buy());
    await tester.tap(buy(), warnIfMissed: false);
    await tester.pump();
    expect(store.bought, hasLength(1));
  });

  testWidgets('already Pro: "You have Pro" at once', (tester) async {
    await open(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        removeAdsPurchased: true,
      ),
    );
    expect(find.byKey(const Key('premium_owned')), findsOneWidget);
    expect(buy(), findsNothing);
  });

  testWidgets('FR-009 no ad of any kind on PRM-01', (tester) async {
    await open(tester);
    expect(find.byType(AppBannerAd), findsNothing);
    expect(find.byType(AppNativeAd), findsNothing);
  });

  testWidgets('FR-050 200% font on a 360 dp screen: nothing overflows', (
    tester,
  ) async {
    await open(tester, size: const Size(360, 780), textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('premium_account_note')),
      100,
    );
    expect(tester.takeException(), isNull);
  });
}
