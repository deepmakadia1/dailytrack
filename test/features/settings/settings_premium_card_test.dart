import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_webview.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-01 premium banner card (feature 009 T085, FR-045).
void main() {
  setUp(FakeWebViewPlatform.install);
  const card = Key('premium_card');

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    bool pro = false,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 2600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: AppSettings(onboardingDone: true, removeAdsPurchased: pro),
      ),
    );
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    return settings;
  }

  testWidgets('the card leads SET-01 and opens PRM-01', (tester) async {
    await open(tester);
    expect(find.text('Remove ads and unlock everything'), findsOneWidget);
    final cardTop = tester.getTopLeft(find.byKey(card)).dy;
    final general = tester.getTopLeft(find.text('General')).dy;
    expect(cardTop, lessThan(general));
    await tester.tap(find.byKey(card));
    await tester.pumpAndSettle();
    expect(find.byType(PremiumScreen), findsOneWidget);
  });

  testWidgets('hidden after purchase, live', (tester) async {
    final settings = await open(tester);
    settings.replace(settings.current.copyWith(removeAdsPurchased: true));
    await tester.pumpAndSettle();
    expect(find.byKey(card), findsNothing);
  });

  testWidgets('hidden for Pro', (tester) async {
    await open(tester, pro: true);
    expect(find.byKey(card), findsNothing);
  });
}
