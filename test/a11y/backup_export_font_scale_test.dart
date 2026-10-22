import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/features/settings/export_providers.dart';
import 'package:dailytrack/features/settings/presentation/screens/backup_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/expense/fakes.dart';
import '../helpers/backup_fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// SC-012 / §15.10 (feature 008 T146): SET-02 (Drive unavailable, not
/// connected, connected with backups) and SET-03 (unlocked and locked) at
/// 200% font scale on a 360×780 dp screen, in en, hi, and gu, light and
/// dark: no overflow (reported as a test failure), 48 dp labelled tap
/// targets, and text contrast.
void main() {
  const phone = Size(360, 780);

  Future<void> pump(
    WidgetTester tester, {
    required String lang,
    required String themeMode,
    required String location,
    String? account,
    bool driveAvailable = false,
    bool exportLocked = false,
  }) async {
    final drive = FakeDriveBackupStore();
    drive.files.addAll([
      for (final (i, kind) in [BackupKind.manual, BackupKind.auto].indexed)
        DriveBackupEntry(
          id: 'b$i',
          name: 'b$i.json',
          createdAt: DateTime.utc(2026, 10, 20 - i, 12).millisecondsSinceEpoch,
          sizeBytes: 2048,
          kind: kind,
          device: 'Pixel 8a',
        ),
    ]);
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          locale: lang,
          themeMode: themeMode,
          backupAccountEmail: account,
          lastBackupAt: 1792540800000,
          lastBackupLocation: BackupLocation.drive,
          lastBackupSizeBytes: 48213,
        ),
      ),
      expense: ExpenseFakes.withDefaults(now: DateTime(2026, 10, 21, 12)),
      gate: FakeFeatureGate(
        unlocked: {
          FeatureKey.exportCsv: !exportLocked,
          FeatureKey.exportPdf: !exportLocked,
        },
      ),
      overrides: [
        backupServiceProvider.overrideWithValue(FakeBackupService()),
        restoreServiceProvider.overrideWithValue(FakeRestoreService()),
        backupPasswordStoreProvider.overrideWithValue(
          FakeBackupPasswordStore(),
        ),
        fileSharerProvider.overrideWithValue(FakeFileSharer()),
        driveAvailableProvider.overrideWithValue(driveAvailable),
        driveBackupStoreProvider.overrideWithValue(drive),
        exportUseCaseProvider.overrideWithValue(FakeExportUseCase()),
      ],
    );
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> expectAccessible(
    WidgetTester tester, {
    bool contrast = true,
  }) async {
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    if (contrast) {
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
  }

  /// Checks every screenful of the screen's list. Text contrast is checked
  /// on the first screenful only: once the list scrolls under the app bar,
  /// the guideline samples each node at its local rectangle (without the
  /// app bar offset), i.e. the app bar background, and reports about 1.1:1
  /// for section headers. Their real colors (primary and onSurface on
  /// surface) are proven in color_themes_test.dart, as for SET-01 (feature
  /// 007 T073).
  Future<void> scrollAndCheck(WidgetTester tester, Type screen) async {
    await expectAccessible(tester);
    final scrollable = find
        .descendant(of: find.byType(screen), matching: find.byType(Scrollable))
        .first;
    for (var i = 0; i < 40; i++) {
      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      await expectAccessible(tester, contrast: false);
    }
  }

  for (final lang in ['en', 'hi', 'gu']) {
    for (final theme in ['light', 'dark']) {
      final name = '$lang $theme';

      testWidgets('SET-02 Drive unavailable, $name', (tester) async {
        await pump(
          tester,
          lang: lang,
          themeMode: theme,
          location: Routes.backup,
        );
        await scrollAndCheck(tester, BackupScreen);
      });

      testWidgets('SET-02 not connected, $name', (tester) async {
        await pump(
          tester,
          lang: lang,
          themeMode: theme,
          location: Routes.backup,
          driveAvailable: true,
        );
        expect(find.byKey(const Key('backup_connect')), findsOneWidget);
        await scrollAndCheck(tester, BackupScreen);
      });

      testWidgets('SET-02 connected with Drive backups, $name', (tester) async {
        await pump(
          tester,
          lang: lang,
          themeMode: theme,
          location: Routes.backup,
          driveAvailable: true,
          account: 'someone.with.a.long.name@example.com',
        );
        expect(find.byKey(const Key('backup_now')), findsOneWidget);
        await scrollAndCheck(tester, BackupScreen);
      });

      testWidgets('SET-03 unlocked, $name', (tester) async {
        await pump(
          tester,
          lang: lang,
          themeMode: theme,
          location: Routes.export,
        );
        await scrollAndCheck(tester, ExportScreen);
      });

      testWidgets('SET-03 locked, $name', (tester) async {
        await pump(
          tester,
          lang: lang,
          themeMode: theme,
          location: Routes.export,
          exportLocked: true,
        );
        expect(find.byType(LockedFeatureOverlay), findsOneWidget);
        await scrollAndCheck(tester, ExportScreen);
      });
    }
  }
}
