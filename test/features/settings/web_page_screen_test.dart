import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/config/app_links.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/settings/presentation/screens/settings_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/web_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/fake_webview.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-01 Privacy: policy and terms in the in-app web view (T067, FR-011,
/// US8-1).
/// The loading bar animates forever, so pump fixed frames, never settle.
Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeWebViewPlatform web;

  setUp(() => web = FakeWebViewPlatform.install());

  Future<FakeExternalLauncher> open(WidgetTester tester, String page) async {
    final launcher = FakeExternalLauncher();
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true, locale: 'en'),
      ),
      launcher: launcher,
    );
    routerOf(tester).go(Routes.webPagePath(page));
    await frames(tester);
    return launcher;
  }

  testWidgets('privacy loads the policy URL with JavaScript off and shows '
      'progress until the page finishes', (tester) async {
    await open(tester, Routes.webPagePrivacy);
    expect(find.byType(WebPageScreen), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(web.controller!.loaded, [Uri.parse(AppLinks.privacyPolicyUrl)]);
    expect(web.controller!.javaScriptMode, JavaScriptMode.disabled);
    expect(find.byKey(const Key('web_loading')), findsOneWidget);

    web.delegate!.onPageFinished!(AppLinks.privacyPolicyUrl);
    await frames(tester);
    expect(find.byKey(const Key('web_loading')), findsNothing);
    expect(find.byKey(const Key('fake_webview')), findsOneWidget);
  });

  testWidgets('terms loads the terms URL', (tester) async {
    await open(tester, Routes.webPageTerms);
    expect(find.text('Terms'), findsOneWidget);
    expect(web.controller!.loaded, [Uri.parse(AppLinks.termsUrl)]);
  });

  testWidgets('a failed load shows the error; Try again loads again', (
    tester,
  ) async {
    await open(tester, Routes.webPagePrivacy);
    web.delegate!.onWebResourceError!(
      const WebResourceError(
        errorCode: -2,
        description: 'net::ERR_INTERNET_DISCONNECTED',
        isForMainFrame: true,
      ),
    );
    web.delegate!.onPageFinished!(AppLinks.privacyPolicyUrl);
    await frames(tester);
    expect(
      find.text(
        "Couldn't load this page. Check your connection and try again.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await frames(tester);
    expect(web.controller!.loaded, hasLength(2));
    expect(find.byKey(const Key('web_loading')), findsOneWidget);
  });

  testWidgets('a failed image does not count as a failed page', (tester) async {
    await open(tester, Routes.webPagePrivacy);
    web.delegate!.onWebResourceError!(
      const WebResourceError(
        errorCode: -1,
        description: 'image',
        isForMainFrame: false,
      ),
    );
    await frames(tester);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('links to another host open in the browser, not in the view', (
    tester,
  ) async {
    final launcher = await open(tester, Routes.webPagePrivacy);
    final other = await web.delegate!.onNavigationRequest!(
      const NavigationRequest(
        url: 'https://example.org/page',
        isMainFrame: true,
      ),
    );
    expect(other, NavigationDecision.prevent);
    expect(launcher.urls, [Uri.parse('https://example.org/page')]);

    final same = await web.delegate!.onNavigationRequest!(
      const NavigationRequest(url: AppLinks.termsUrl, isMainFrame: true),
    );
    expect(same, NavigationDecision.navigate);
  });

  testWidgets('an unknown page goes back to SET-01', (tester) async {
    await open(tester, 'cookies');
    expect(find.byType(WebPageScreen), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
