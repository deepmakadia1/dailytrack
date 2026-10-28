import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'account_test_app.dart';

/// The manual backup warning (spec §16 "Conflict rule", feature 010 T085,
/// US5, FR-038, FR-038a): ACC-01 and SET-02 "Back up now" share one dialog
/// that names the other phone and the time of its backup; "Cancel" uploads
/// nothing and "Back up anyway" uploads. An empty phone over a backup with
/// data gets its own text. A paused auto backup shows "Backup paused" on
/// ACC-01, and Review opens ACC-02 for that backup.
void main() {
  /// The newer backup's time as the dialog shows it (the user's full date
  /// format, default `dMMMy`, plus the time).
  String shownTime(int createdAt) =>
      formatFullDateTime(Epoch.toLocal(createdAt), FullDateFormat.dMMMy, 'en');

  /// Where each screen's "Back up now" lives.
  const screens = {
    Routes.account: 'acc01.backUpNow',
    Routes.backup: 'backup_now',
  };

  for (final MapEntry(key: location, value: button) in screens.entries) {
    final id = location == Routes.account ? 'ACC-01' : 'SET-02';

    testWidgets('$id Back up now over a newer backup from another phone: the '
        'dialog names the device and time; Cancel uploads nothing, Back up '
        'anyway uploads', (tester) async {
      final newer = otherPhoneMeta();
      final world = await pumpAccountApp(
        tester,
        location: location,
        arrange: (w) => w.backup.conflict = NewerFromOtherDevice(newer),
      );
      await tapKey(tester, button);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Back up anyway?'), findsOneWidget);
      expect(
        find.text(
          'A newer backup from Redmi Note 12 '
          '(${shownTime(newer.createdAt)}) exists. Backing up now makes '
          "this phone's data the latest.",
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(world.backup.driveBackups, 0);
      expect(world.backup.conflicts, [ConflictMode.ask]);

      await tapKey(tester, button);
      await tester.tap(find.text('Back up anyway'));
      await tester.pumpAndSettle();
      expect(world.backup.driveBackups, 1);
      expect(world.backup.conflicts.last, ConflictMode.overwrite);
    });

    testWidgets('$id Back up now from an empty phone over a backup with data '
        'shows the empty-phone warning', (tester) async {
      final world = await pumpAccountApp(
        tester,
        location: location,
        hasData: false,
        arrange: (w) => w.backup.conflict = EmptyOverData(otherPhoneMeta()),
      );
      await tapKey(tester, button);
      expect(
        find.text(
          'This phone has no data. Backing up now makes an empty backup the '
          'latest.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(world.backup.driveBackups, 0);

      await tapKey(tester, button);
      await tester.tap(find.text('Back up anyway'));
      await tester.pumpAndSettle();
      expect(world.backup.driveBackups, 1);
    });
  }

  testWidgets('ACC-01 a paused auto backup shows "Backup paused"; Review '
      'opens ACC-02 for the newer backup from the other phone', (tester) async {
    await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(autoBackupPausedByConflict: true),
      arrange: (w) {
        // An older backup from this phone, then the newer one that paused
        // auto backup.
        w.drive
          ..seed(
            meta: otherPhoneMeta(at: 1792450800000, deviceId: 'this-phone'),
            device: 'Google Pixel 7',
          )
          ..seed(meta: otherPhoneMeta());
      },
    );
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(
      find.text('Backup paused: a newer backup from another phone exists'),
      findsOneWidget,
    );
    await tapKey(tester, 'acc01_review');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('acc02_device'))).data,
      'From Redmi Note 12',
    );
  });
}
