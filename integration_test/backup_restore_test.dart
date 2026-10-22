import 'dart:io';

import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/backup_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/core/backup/backup_test_support.dart';
import '../test/features/expense/expense_test_app.dart' show routerOf;
import '../test/helpers/fakes.dart';

/// SET-02 AC 1 on a device (spec §13 integration test, feature 008 T037):
/// backup → erase → restore with the real database, the real backup engine,
/// and the real erase, driven through SET-02. Only the system file dialogs
/// are replaced (they need a person to tap them). Row counts and SHA-256
/// checksums of every module table, and the receipt image, must be equal.
///
/// Run with `flutter test integration_test/backup_restore_test.dart
/// --flavor dev` on an emulator or device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() done, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!done() && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(done(), isTrue, reason: 'timed out');
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  testWidgets('SET-02 AC1 backup → erase → restore gives identical rows, '
      'checksums, and receipts', (tester) async {
    // A device with real data: every module table, soft-deleted rows,
    // Hindi and Gujarati notes, and a receipt image.
    final docs = await getApplicationDocumentsDirectory();
    final seedDb = AppDatabase.open();
    await eraseEverything(seedDb);
    await seedRichData(seedDb, docs);
    // No app lock: this test drives the screens directly.
    await (seedDb.delete(
      seedDb.settings,
    )..where((s) => s.key.equals('lockEnabled'))).go();
    await seedDb.close();

    final files = FakeLocalBackupFiles();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...productionOverrides(),
          localBackupFilesProvider.overrideWithValue(files),
          fileSharerProvider.overrideWithValue(FakeFileSharer()),
        ],
        child: const DailyTrackApp(),
      ),
    );
    await pumpUntil(tester, () => find.byType(SplashScreen).evaluate().isEmpty);
    expect(find.byType(HomeScreen), findsOneWidget);

    final db = container(tester).read(appDatabaseProvider);
    final before = await tableChecksums(db);
    expect(before['transactions']!.$1, 4);
    expect(before['habit_entries']!.$1, 4);

    // 1. Back up from SET-02, with receipt images.
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    await tapKey(tester, 'settings_backup');
    expect(find.byType(BackupScreen), findsOneWidget);
    await tapKey(tester, 'backup_include_receipts');
    await tapKey(tester, 'backup_save_file');
    await pumpUntil(tester, () => files.saved.isNotEmpty);
    final (name, bytes) = files.saved.single;
    expect(name, startsWith('dailytrack_backup_'));
    expect(name, endsWith('.zip'));

    // 2. Erase all data, exactly as SET-01 does; the app restarts at
    // onboarding.
    await container(tester).read(appResetServiceProvider).eraseAll();
    await pumpUntil(
      tester,
      () => find.byType(OnboardingScreen).evaluate().isNotEmpty,
    );
    expect(File('${docs.path}/receipts/r1.jpg').existsSync(), isFalse);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await pumpUntil(
      tester,
      () => find.byType(HomeScreen).evaluate().isNotEmpty,
    );
    final erased = await tableChecksums(
      container(tester).read(appDatabaseProvider),
    );
    expect(erased['transactions']!.$1, 0);
    expect(erased['habits']!.$1, 0);

    // 3. Restore the file from SET-02.
    files.picked = bytes;
    routerOf(tester).go(Routes.backup);
    await tester.pumpAndSettle();
    await tapKey(tester, 'backup_restore_file');
    await pumpUntil(
      tester,
      () => find.byKey(const Key('restore_preview')).evaluate().isNotEmpty,
    );
    await tester.tap(find.byKey(const Key('restore_continue')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await pumpUntil(
      tester,
      () => find.byKey(const Key('restore_done')).evaluate().isNotEmpty,
    );

    // 4. Identical data: per-table row counts and checksums, and the image.
    final after = await tableChecksums(
      container(tester).read(appDatabaseProvider),
    );
    expect(after, before);
    expect(
      File('${docs.path}/receipts/r1.jpg').readAsBytesSync(),
      receiptBytes,
    );
  });
}
