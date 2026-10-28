import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../expense/expense_test_app.dart';
import 'account_test_app.dart';

/// ACC-02 Restore choice (spec §16, feature 010 US3, T065). The data-level
/// criteria (one transaction, the safety copy, FR-019b) are also checked on
/// a real database in test/core/account/account_restore_test.dart.
void main() {
  Future<AccountWorld> openChoice(
    WidgetTester tester, {
    bool hasData = true,
    bool encrypted = false,
    String? device = 'Redmi Note 12',
    bool withMeta = true,
  }) async {
    final world = await pumpAccountApp(
      tester,
      hasData: hasData,
      arrange: (w) => w.drive.seed(
        meta: withMeta ? otherPhoneMeta(encrypted: encrypted) : null,
        createdAt: withMeta ? null : 1792540800000,
        device: device,
      ),
    );
    await tapKey(tester, 'acc01.restore');
    return world;
  }

  testWidgets("ACC-02 the summary shows the backup's date, device name, "
      'counts, and encryption from metadata without downloading the file', (
    tester,
  ) async {
    final world = await openChoice(tester, encrypted: true);
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(find.text('Backup found on me@example.com'), findsOneWidget);
    expect(find.text('From Redmi Note 12'), findsOneWidget);
    expect(find.text('1,240 transactions · 8 habits'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('Encrypted'), findsOneWidget);
    expect(find.text('This phone: 3 transactions'), findsOneWidget);
    expect(world.restore.downloads, isEmpty);
  });

  testWidgets('ACC-02 with no user data on the phone, the newest backup is '
      'restored without showing the choice', (tester) async {
    final world = await openChoice(tester, hasData: false);
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(world.restore.applied, [('f0', true)]);
    expect(find.text('Restored 1,240 transactions · 8 habits'), findsOneWidget);
  });

  testWidgets('ACC-02 "Restore from account" restores and closes; a failure '
      'leaves this phone\'s data unchanged and offers "Try again"', (
    tester,
  ) async {
    final world = await openChoice(tester);
    world.restore.failApply = const BackupDamaged('test');
    await tapKey(tester, 'acc02_restore');
    expect(world.restore.applied, isEmpty);
    expect(
      find.text("Couldn't restore. Your data on this phone wasn't changed."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);

    await tapKey(tester, 'acc02_restore');
    expect(world.restore.applied, [('f0', false)]);
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(find.text('Restored 1,240 transactions · 8 habits'), findsOneWidget);
  });

  testWidgets("ACC-02 when the safety copy can't be saved, nothing is "
      'restored and the sheet says why', (tester) async {
    final world = await openChoice(tester);
    world.restore.safetyFails = true;
    await tapKey(tester, 'acc02_restore');
    expect(world.restore.applied, isEmpty);
    expect(find.textContaining('Not enough free space'), findsOneWidget);
  });

  testWidgets('ACC-02 "Keep this phone\'s data" writes nothing locally, '
      'starts a backup, and the declined backup is known so it never '
      'warns', (tester) async {
    final world = await openChoice(tester);
    await world.settings.setAutoBackupPause(paused: true, notified: true);
    await tapKey(tester, 'acc02_keep');
    expect(world.restore.kept, ['f0']);
    expect(world.restore.applied, isEmpty);
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(
      world.settings.current.lastKnownDriveBackupAt,
      otherPhoneMeta().createdAt,
    );
    expect(world.settings.current.lastKnownDriveBackupDeviceId, 'other-phone');
  });

  group('encrypted backups', () {
    testWidgets('ACC-02 the saved password is used without asking', (
      tester,
    ) async {
      final world = await openChoice(tester, encrypted: true);
      world.restore
        ..encryptedWith = 'right'
        ..savedPassword = 'right';
      await tapKey(tester, 'acc02_restore');
      expect(find.byKey(const Key('acc02_password')), findsNothing);
      expect(world.restore.applied, hasLength(1));
    });

    testWidgets('ACC-02 the password is asked only when the saved one fails; '
        'a wrong password writes nothing; the right one turns "Encrypt '
        'backup" on', (tester) async {
      final world = await openChoice(tester, encrypted: true);
      world.restore
        ..encryptedWith = 'right'
        ..savedPassword = 'old';
      await tapKey(tester, 'acc02_restore');
      expect(find.byKey(const Key('acc02_password')), findsOneWidget);
      expect(world.restore.applied, isEmpty);

      await tester.enterText(find.byKey(const Key('acc02_password')), 'nope');
      await tapKey(tester, 'acc02_restore');
      expect(find.text("That password didn't work"), findsOneWidget);
      expect(world.restore.applied, isEmpty);
      expect(world.settings.current.backupEncrypt, isFalse);

      await tester.enterText(find.byKey(const Key('acc02_password')), 'right');
      await tapKey(tester, 'acc02_restore');
      expect(world.restore.applied, hasLength(1));
      expect(world.restore.remembered, 'right');
      expect(world.settings.current.backupEncrypt, isTrue);
    });
  });

  testWidgets('ACC-02 opened from ACC-01 it has a close button that changes '
      'nothing', (tester) async {
    final world = await openChoice(tester);
    await tapKey(tester, 'acc02_close');
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(world.restore.applied, isEmpty);
    expect(world.restore.kept, isEmpty);
  });

  testWidgets("ACC-02 after sign-in it can't be dismissed by tapping "
      'outside and has no close button', (tester) async {
    // Guest sign-in, here from the SET-02 Drive card.
    final world = await pumpAccountApp(
      tester,
      initial: guest,
      location: Routes.backup,
    );
    world.drive.seed(meta: otherPhoneMeta());
    await tapKey(tester, 'backup_signIn');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(find.byKey(const Key('acc02_close')), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    await tapKey(tester, 'acc02_keep');
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
  });

  testWidgets('ACC-02 offline: "Connect to the internet to restore", restore '
      "is disabled, and \"Keep this phone's data\" still works", (
    tester,
  ) async {
    // The connection drops after ACC-01 opened.
    final network = FakeNetworkStateSource();
    final world = await pumpAccountApp(
      tester,
      network: network,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    network.online = false;
    await tapKey(tester, 'acc01.restore');
    expect(find.text('Connect to the internet to restore'), findsOneWidget);
    final restore = tester.widget<FilledButton>(
      find.byKey(const Key('acc02_restore')),
    );
    expect(restore.onPressed, isNull);
    await tapKey(tester, 'acc02_keep');
    expect(world.restore.applied, isEmpty);
    expect(world.restore.kept, hasLength(1));
    expect(world.restore.downloads, isEmpty);
  });

  testWidgets('ACC-02 online there is no offline message', (tester) async {
    await openChoice(tester);
    expect(find.byKey(const Key('acc02_offline')), findsNothing);
  });

  testWidgets('ACC-02 a backup from this phone says "From this phone"', (
    tester,
  ) async {
    await pumpAccountApp(
      tester,
      arrange: (w) =>
          w.drive.seed(meta: otherPhoneMeta(deviceId: 'this-phone')),
    );
    await tapKey(tester, 'acc01.restore');
    expect(find.text('From this phone'), findsOneWidget);
  });

  testWidgets('FR-043 a backup without metadata shows the device feature 008 '
      'stored, or "Unknown device", and no counts', (tester) async {
    await openChoice(tester, withMeta: false);
    expect(find.text('From Redmi Note 12'), findsOneWidget);
    expect(find.byKey(const Key('acc02_counts')), findsNothing);
  });

  testWidgets('FR-043 without a stored device name it says "Unknown '
      'device"', (tester) async {
    await openChoice(tester, withMeta: false, device: null);
    expect(find.text('Unknown device'), findsOneWidget);
  });

  testWidgets('token expiry: a download refused for an expired sign-in signs '
      'the account out; ACC-01 closes to the More tab and says so', (
    tester,
  ) async {
    final world = await openChoice(tester);
    world.restore.failDownload = const DriveAuthRequired();
    await tapKey(tester, 'acc02_restore');
    expect(locationOf(tester), Routes.more);
    expect(find.byKey(const Key('acc01_sessionExpired')), findsOneWidget);
    expect(world.settings.current.backupAccountEmail, isNull);
    expect(world.restore.applied, isEmpty);
  });
}
