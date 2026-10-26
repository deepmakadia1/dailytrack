import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-02 interstitial trigger (feature 009 T100, spec §11): after a
/// manual backup succeeds, once its success message has closed.
void main() {
  late FakeBackupService backup;
  late FakeAdService ads;

  setUp(() {
    backup = FakeBackupService();
    ads = FakeAdService();
  });

  Future<void> open(WidgetTester tester, {AppSettings? initial}) async {
    tester.view
      ..physicalSize = const Size(412, 1800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial:
            initial ?? const AppSettings(onboardingDone: true, locale: 'en'),
      ),
      ads: ads,
      overrides: [
        backupServiceProvider.overrideWithValue(backup),
        restoreServiceProvider.overrideWithValue(FakeRestoreService()),
        backupPasswordStoreProvider.overrideWithValue(
          FakeBackupPasswordStore(),
        ),
        fileSharerProvider.overrideWithValue(FakeFileSharer()),
        driveAvailableProvider.overrideWithValue(initial != null),
        driveBackupStoreProvider.overrideWithValue(FakeDriveBackupStore()),
      ],
    );
    routerOf(tester).go(Routes.backup);
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> closeSnackBar(WidgetTester tester) async {
    ScaffoldMessenger.of(tester.element(find.byType(SnackBar)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  testWidgets('US4-6 "Save backup file" triggers only after "Backup saved" '
      'has closed', (tester) async {
    await open(tester);
    await tapKey(tester, 'backup_save_file');
    expect(find.text('Backup saved'), findsOneWidget);
    expect(ads.triggers, isEmpty);
    await closeSnackBar(tester);
    expect(ads.triggers.single, isA<ManualBackupSucceeded>());
  });

  testWidgets('US4-6 Drive "Back up now" triggers after its success message '
      'closes', (tester) async {
    await open(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        backupAccountEmail: 'me@example.com',
      ),
    );
    await tapKey(tester, 'backup_now');
    expect(ads.triggers, isEmpty);
    await closeSnackBar(tester);
    expect(ads.triggers.single, isA<ManualBackupSucceeded>());
  });

  testWidgets('a failed or cancelled backup never triggers', (tester) async {
    backup.cancel = true;
    await open(tester);
    await tapKey(tester, 'backup_save_file');
    await tester.pumpAndSettle();
    backup
      ..cancel = false
      ..error = const DriveOffline();
    await tapKey(tester, 'backup_save_file');
    await tester.pumpAndSettle();
    expect(ads.triggers, isEmpty);
  });
}
