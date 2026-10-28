import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// A signed-in user past onboarding (feature 010).
const AppSettings signedIn = AppSettings(
  onboardingDone: true,
  locale: 'en',
  backupAccountEmail: 'me@example.com',
  accountDisplayName: 'Asha Patel',
  autoBackupFrequency: AutoBackupFrequency.daily,
  deviceId: 'this-phone',
  authMode: AuthMode.google,
);

/// The same phone as a guest: no account (feature 011).
final AppSettings guest = signedIn.copyWith(
  authMode: AuthMode.guest,
  backupAccountEmail: null,
  accountDisplayName: null,
);

/// Everything the account screens talk to, as fakes.
final class AccountWorld {
  new({
    required this.settings,
    required this.auth,
    required this.drive,
    required this.backup,
    required this.restore,
    required this.reset,
    required this.scheduler,
    required this.pro,
  });

  final FakeSettingsRepository settings;
  final FakeAccountAuth auth;
  final FakeDriveBackupStore drive;
  final FakeBackupService backup;
  final FakeAccountRestore restore;
  final FakeAppResetService reset;
  final FakeBackgroundScheduler scheduler;
  final FakeProStore pro;
}

/// A backup another phone made: 1,240 transactions and 8 habits.
BackupMeta otherPhoneMeta({
  bool encrypted = false,
  int at = 1792540800000,
  String deviceId = 'other-phone',
}) => BackupMeta(
  deviceId: deviceId,
  deviceName: 'Redmi Note 12',
  appVersion: '1.0.0+7',
  createdAt: at,
  kind: BackupKind.manual,
  counts: const {'expense.transactions': 1240, 'habit.habits': 8},
  schemaVersion: 5,
  encrypted: encrypted,
);

/// Pumps the app with fakes only and opens [location] (ACC-01 by default).
/// [arrange] sets up the fakes before the app starts. [authModeStored]
/// keeps a stored `authMode` of none (AUTH-01 tests); see
/// [FakeSettingsRepository.authModeStored]. [pin] turns on a real app lock
/// with that PIN stored.
Future<AccountWorld> pumpAccountApp(
  WidgetTester tester, {
  AppSettings initial = signedIn,
  String? location = Routes.account,
  bool hasData = true,
  int androidSdk = 34,
  FakeProStore? pro,
  FakeAdService? ads,
  FakeNetworkStateSource? network,
  FakeNotificationPermission? notif,
  bool? authModeStored,
  String? pin,
  void Function(AccountWorld world)? arrange,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = const Size(412, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final settings = FakeSettingsRepository(
    initial: initial,
    authModeStored: authModeStored,
  );
  final world = AccountWorld(
    settings: settings,
    auth: FakeAccountAuth(),
    drive: FakeDriveBackupStore(),
    backup: FakeBackupService(),
    restore: FakeAccountRestore(settings: settings)..hasData = hasData,
    reset: FakeAppResetService(),
    scheduler: FakeBackgroundScheduler(),
    pro: pro ?? FakeProStore(),
  );
  arrange?.call(world);
  // App lock with [pin] as the PIN; pair it with `lockEnabled: true`.
  final lock = pin == null ? null : TestLock(settings: settings);
  await lock?.seedPin(pin!);
  await pumpTestApp(
    tester,
    settings: settings,
    accountAuth: world.auth,
    drive: world.drive,
    accountRestore: world.restore,
    lock: lock,
    reset: world.reset,
    background: world.scheduler,
    proStore: world.pro,
    ads: ads,
    network: network,
    notif: notif,
    androidSdk: androidSdk,
    overrides: [
      driveAvailableProvider.overrideWithValue(true),
      backupServiceProvider.overrideWithValue(world.backup),
      restoreServiceProvider.overrideWithValue(FakeRestoreService()),
      ...overrides,
    ],
  );
  if (location != null) {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }
  return world;
}

/// Scrolls [key] into view and taps it.
Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
