@Tags(['golden'])
library;

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';
import '../features/expense/expense_test_app.dart' show routerOf;
import '../helpers/fakes.dart' show FakeNetworkStateSource;

/// §15.10 / Constitution IV goldens for feature 010 (T100): ACC-01 offline
/// and signed in, ACC-02, and ACC-03 after a failed backup, in light/dark ×
/// English/Gujarati on a
/// 360×800 surface with fakes only. Baselines are made and compared on
/// Linux: `flutter test --tags golden --update-goldens`.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required AppSettings initial,
    String? location = Routes.account,
    bool hasData = true,
    FakeNetworkStateSource? network,
    void Function(AccountWorld w)? arrange,
  }) async {
    await pumpAccountApp(
      tester,
      initial: initial,
      location: null,
      hasData: hasData,
      network: network,
      arrange: arrange,
    );
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    if (location != null) routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  AppSettings user(String theme, String lang) => signedIn.copyWith(
    locale: lang,
    themeMode: theme,
    backupAccountEmail: 'me@example.com',
    accountDisplayName: 'Asha Patel',
  );

  final scenarios =
      <String, Future<void> Function(WidgetTester, String theme, String lang)>{
        'ACC-01 offline': (tester, theme, lang) => pump(
          tester,
          initial: user(theme, lang).copyWith(lastBackupAt: 1792540800000),
          network: FakeNetworkStateSource(online: false),
        ),
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
