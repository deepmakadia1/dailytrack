@Tags(['golden'])
library;

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';
import '../features/auth/login_test_app.dart' show onLogin;
import '../features/expense/expense_test_app.dart' show routerOf;
import '../features/expense/fakes.dart' show fakeNow;

/// §13 / Constitution IV goldens added by feature 012 (T007, data-model §8):
/// AUTH-01 with both login paths, and the SET-01 account card as a guest
/// and signed in with Google, in light/dark × English/Gujarati on a 360×800
/// surface with fakes only. Baselines are made and compared on Linux only,
/// through the "Regenerate goldens" workflow.
void main() {
  final fiveMinAgo = fakeNow
      .subtract(const Duration(minutes: 5))
      .toUtc()
      .millisecondsSinceEpoch;

  Future<void> pump(
    WidgetTester tester, {
    required AppSettings initial,
    String? location,
  }) async {
    await pumpAccountApp(
      tester,
      initial: initial,
      authModeStored: true,
      location: null,
      hasData: false,
    );
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    if (location != null) routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  final scenarios =
      <String, Future<void> Function(WidgetTester, String theme, String lang)>{
        'AUTH-01 default': (tester, theme, lang) => pump(
          tester,
          initial: onLogin.copyWith(locale: lang, themeMode: theme),
        ),
        'SET-01 guest card': (tester, theme, lang) => pump(
          tester,
          initial: guest.copyWith(locale: lang, themeMode: theme),
          location: Routes.more,
        ),
        'SET-01 Google card': (tester, theme, lang) => pump(
          tester,
          initial: signedIn.copyWith(
            locale: lang,
            themeMode: theme,
            lastBackupAt: fiveMinAgo,
          ),
          location: Routes.more,
        ),
      };

  for (final MapEntry(key: name, value: build) in scenarios.entries) {
    for (final theme in ['light', 'dark']) {
      for (final lang in ['en', 'gu']) {
        testWidgets('$name golden $theme $lang', (tester) async {
          await build(tester, theme, lang);
          final file =
              '${name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '')}'
              '_${theme}_$lang.png';
          await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        });
      }
    }
  }
}
