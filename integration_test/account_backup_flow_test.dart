import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/background_dispatcher.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/core/backup/backup_test_support.dart';
import '../test/features/expense/expense_test_app.dart' show routerOf;
import '../test/helpers/backup_fakes.dart';
import '../test/helpers/fakes.dart';

/// Feature 010 end to end on a device (spec §13 integration tests, §16,
/// task T103): sign in → auto backup when the app goes to the background →
/// ACC-03 sign out with "Remove data from this phone" → SYS-02 "Restore
/// with Google" → the same data. Everything is real (database, triggers,
/// backup engine, account service, restore, erase, device ID file) except
/// Google: the account chooser and Drive are in-memory fakes that keep the
/// backups across the sign-out, and WorkManager is replaced by running the
/// queued task the way its dispatcher would.
///
/// Run with `flutter test integration_test/account_backup_flow_test.dart
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

  bool shows(Finder finder) => finder.evaluate().isNotEmpty;

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  testWidgets('§16 sign in → auto backup → sign out removing data → Restore '
      'with Google gives back the same rows', (tester) async {
    // A phone with real data in every module table and a receipt image.
    final docs = await getApplicationDocumentsDirectory();
    final seedDb = AppDatabase.open();
    await eraseEverything(seedDb);
    await seedRichData(seedDb, docs);
    // No app lock: this test drives the screens directly.
    await (seedDb.delete(
      seedDb.settings,
    )..where((s) => s.key.equals('lockEnabled'))).go();
    await seedDb.close();

    final auth = FakeAccountAuth();
    final drive = FakeDriveBackupStore();
    final scheduler = FakeBackgroundScheduler();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...productionOverrides(),
          accountAuthProvider.overrideWithValue(auth),
          driveAvailableProvider.overrideWithValue(true),
          driveBackupStoreProvider.overrideWithValue(drive),
          backgroundSchedulerProvider.overrideWithValue(scheduler),
          proStoreProvider.overrideWithValue(FakeProStore()),
          fileSharerProvider.overrideWithValue(FakeFileSharer()),
        ],
        child: const DailyTrackApp(),
      ),
    );
    await pumpUntil(tester, () => !shows(find.byType(SplashScreen)));
    expect(find.byType(HomeScreen), findsOneWidget);
    final db = container(tester).read(appDatabaseProvider);
    // Receipts travel with the backups, so restored rows keep their paths.
    await container(tester)
        .read(settingsRepositoryProvider)
        .setBackupIncludeReceipts(enabled: true);

    // 1. Sign in from ACC-01: the account is empty, so the first backup
    // runs at once.
    routerOf(tester).go(Routes.account);
    await tester.pumpAndSettle();
    await tapKey(tester, 'acc01.signIn');
    await pumpUntil(tester, () => drive.files.isNotEmpty);
    expect(drive.files.single.kind, BackupKind.manual);
    final s = await container(tester).read(settingsRepositoryProvider).load();
    expect(s.backupAccountEmail, 'me@example.com');
    expect(s.autoBackupFrequency.name, 'daily');

    // 2. New data, then the app goes to the background: one background
    // backup is queued (Wi-Fi only), and runs like WorkManager would.
    await db.customStatement(
      'INSERT INTO habits (id, name, icon_key, color_hex, kind, target_value, '
      'schedule_type, weekdays_mask, start_date_key, sort_order, created_at, '
      "updated_at) VALUES ('flow', 'Stretch', 'yoga', '#00897B', 0, 1, 0, "
      "127, '2026-10-26', 9, 0, 0)",
    );
    final expected = await tableChecksums(db);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await pumpUntil(
      tester,
      () => scheduler.oneOff.containsKey(backgroundBackupTaskName),
    );
    expect(
      scheduler.oneOff[backgroundBackupTaskName],
      NetworkRequirement.unmetered,
    );
    expect(
      await runBackgroundTask(backgroundBackupTaskName, container(tester)),
      isTrue,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(drive.files.where((f) => f.kind == BackupKind.auto), hasLength(1));
    final auto = drive.files.firstWhere((f) => f.kind == BackupKind.auto);
    expect(auto.meta!.counts['habit.habits'], greaterThan(0));

    // 3. ACC-03: nothing left to back up; remove the data and sign out.
    // The real erase runs and the app restarts at onboarding.
    routerOf(tester).go(Routes.account);
    await tester.pumpAndSettle();
    await tapKey(tester, 'acc01.signOut');
    await pumpUntil(
      tester,
      () => shows(find.byKey(const Key('acc03_backedUp'))),
    );
    await tapKey(tester, 'acc03_remove');
    await tapKey(tester, 'acc03_signOut');
    await pumpUntil(tester, () => shows(find.byType(OnboardingScreen)));
    expect(auth.signOuts, greaterThan(0));
    expect(drive.files, hasLength(2), reason: 'Drive backups are kept');
    final erased = await tableChecksums(
      container(tester).read(appDatabaseProvider),
    );
    expect(erased['transactions']!.$1, 0);
    expect(erased['habits']!.$1, 0);

    // 4. SYS-02 "Restore with Google": the newest backup (the auto one) is
    // restored without a choice, and Home opens.
    await tapKey(tester, 'sys02.restoreWithGoogle');
    await pumpUntil(tester, () => shows(find.byType(HomeScreen)));
    final restored = await tableChecksums(
      container(tester).read(appDatabaseProvider),
    );
    expect(restored, expected);
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
    await tapKey(tester, 'finish_setup_later');
  });
}
