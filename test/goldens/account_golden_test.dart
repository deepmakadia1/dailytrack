@Tags(['golden'])
library;

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';
import '../features/expense/expense_test_app.dart' show routerOf;

/// §15.10 / Constitution IV goldens for feature 010 (T100): ACC-01 signed
/// out and signed in, ACC-02, ACC-03 after a failed backup, and SYS-02 step
/// 1 with "Restore with Google", in light/dark × English/Gujarati on a
/// 360×800 surface with fakes only. Baselines are made and compared on
/// Linux: `flutter test --tags golden --update-goldens`.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required AppSettings initial,
    String? location = Routes.account,
    bool hasData = true,
    void Function(AccountWorld w)? arrange,
  }) async {
    await pumpAccountApp(
      tester,
      initial: initial,
      location: null,
      hasData: hasData,
      arrange: arrange,
    );
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    if (location != null) routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  AppSettings user(String theme, String lang, {bool signedInUser = true}) =>
      signedIn.copyWith(
        locale: lang,
        themeMode: theme,
        backupAccountEmail: signedInUser ? 'me@example.com' : null,
        accountDisplayName: signedInUser ? 'Asha Patel' : null,
      );

  final scenarios =
      <String, Future<void> Function(WidgetTester, String theme, String lang)>{
        'ACC-01 signed out': (tester, theme, lang) =>
            pump(tester, initial: user(theme, lang, signedInUser: false)),
        'ACC-01 signed in': (tester, theme, lang) => pump(
          tester,
          initial: user(theme, lang),
          arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
        ),
        'ACC-02': (tester, theme, lang) async {
          await pump(
            tester,
            initial: user(theme, lang),
            arrange: (w) => w.drive.seed(meta: otherPhoneMeta(encrypted: true)),
          );
          await tapKey(tester, 'acc01.restore');
        },
        'ACC-03 failed backup': (tester, theme, lang) async {
          await pump(
            tester,
            initial: user(theme, lang).copyWith(dataChangeCounter: 3),
            arrange: (w) => w.backup.error = const DriveOffline(),
          );
          await tapKey(tester, 'acc01.signOut');
        },
        'SYS-02 restore with Google': (tester, theme, lang) => pump(
          tester,
          initial: AppSettings(locale: lang, themeMode: theme),
          location: null,
          hasData: false,
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
