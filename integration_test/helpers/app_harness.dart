import 'dart:io';

import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/data/safety_copy_store.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/support/network_state_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/receipts/file_receipt_store.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import '../../test/helpers/backup_fakes.dart';
import '../../test/helpers/fakes.dart';
import '../../test/helpers/mutable_clock.dart';

/// Shared setup for the device journeys (feature 012 T014, research R8).
/// Everything is real (database, settings, bootstrap, router, backup engine,
/// erase, lock) except Google, ads, notifications, WorkManager, purchases,
/// and the share sheet, which are in-memory fakes. The fakes live in the
/// [HarnessWorld], so they keep their state (Drive backups, recorded calls)
/// across [restart].
final class HarnessWorld {
  new({this.clock});

  final auth = FakeAccountAuth();
  final drive = FakeDriveBackupStore();
  final scheduler = FakeBackgroundScheduler();
  final notifications = FakeNotificationService();
  final network = FakeNetworkStateSource();
  final pro = FakeProStore();

  /// Replaces the real clock when set (app lock timeout).
  final MutableClock? clock;
}

/// Simulates a fresh install: every table (settings too) is emptied, secure
/// storage (PIN, lockout, backup password) is cleared, and the receipt and
/// safety copy files are deleted. The device ID file is kept, as the erase
/// keeps it. Call before each journey (spec FR-010).
Future<void> freshInstall() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase.open();
  await db.transaction(() async {
    // Reverse order: transactions reference categories and accounts.
    for (final table in db.allTables.toList().reversed) {
      await db.delete(table).go();
    }
  });
  await db.close();
  await const FlutterSecureStorage().deleteAll();
  final receipts = Directory(
    '${(await getApplicationDocumentsDirectory()).path}/'
    '${FileReceiptStore.folder}',
  );
  if (receipts.existsSync()) await receipts.delete(recursive: true);
  await FileSafetyCopyStore(getApplicationSupportDirectory).delete();
}

/// Starts the app the way `main()` does, with the [world]'s fakes, and waits
/// for the splash to hand over.
Future<void> launch(
  WidgetTester tester,
  HarnessWorld world, {
  List<Override> extra = const [],
}) async {
  final clock = world.clock;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...productionOverrides(),
        accountAuthProvider.overrideWithValue(world.auth),
        driveAvailableProvider.overrideWithValue(true),
        driveBackupStoreProvider.overrideWithValue(world.drive),
        backgroundSchedulerProvider.overrideWithValue(world.scheduler),
        notificationServiceProvider.overrideWithValue(world.notifications),
        networkStateSourceProvider.overrideWithValue(world.network),
        proStoreProvider.overrideWithValue(world.pro),
        fileSharerProvider.overrideWithValue(FakeFileSharer()),
        adServiceProvider.overrideWithValue(const NoAdsService()),
        if (clock != null) clockProvider.overrideWithValue(clock),
        ...extra,
      ],
      child: const DailyTrackApp(),
    ),
  );
  // Bootstrap does real disk I/O off the frame loop, so pumpAndSettle can
  // return while the splash is still up.
  await pumpUntil(tester, () => !shows(find.byType(SplashScreen)));
}

/// Disposes the app (closing the database), as on exit, then starts it again
/// with the same fakes.
Future<void> restart(WidgetTester tester, HarnessWorld world) async {
  await closeApp(tester);
  await launch(tester, world);
}

/// Disposes the provider scope, closing the database.
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// Pumps until [done] or [timeout]; fails on timeout.
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

/// Scrolls the key into view, then taps it.
Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (!shows(finder)) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

/// From a fresh install: SYS-02 Skip, then AUTH-01 "Continue as guest".
Future<void> startAsGuest(WidgetTester tester) async {
  await tapKey(tester, 'onboarding_skip');
  await tapKey(tester, 'auth01_guest');
}
