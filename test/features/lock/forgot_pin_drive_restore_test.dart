import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import 'lock_test_app.dart';

/// SYS-03 "Forgot PIN?" → "Restore from Google Drive backup" (feature 008
/// T139, T140, T143; US8-1 – US8-4; FR-024).
void main() {
  late FakeDriveBackupStore drive;
  late FakeRestoreService restore;
  late FakeAppResetService reset;

  setUp(() {
    drive = FakeDriveBackupStore();
    restore = FakeRestoreService();
    reset = FakeAppResetService();
  });

  Future<LockWorld> open(WidgetTester tester, {bool available = true}) =>
      pumpLockApp(
        tester,
        pin: '1234',
        initial: const AppSettings(
          onboardingDone: true,
          locale: 'en',
          lockEnabled: true,
          biometricEnabled: true,
        ),
        reset: reset,
        overrides: [
          driveAvailableProvider.overrideWithValue(available),
          driveBackupStoreProvider.overrideWithValue(drive),
          restoreServiceProvider.overrideWithValue(restore),
        ],
      );

  Future<void> tapForgot(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await tester.pumpAndSettle();
  }

  void addBackup() {
    drive
      ..files.add(
        DriveBackupEntry(
          id: 'b1',
          name: 'b1.json',
          createdAt: DateTime.utc(2026, 10, 20).millisecondsSinceEpoch,
          sizeBytes: 4096,
          kind: BackupKind.auto,
        ),
      )
      ..contents['b1'] = Uint8List.fromList(utf8.encode('{}'));
  }

  testWidgets('US8-1 the sheet offers Drive restore above Erase all data', (
    tester,
  ) async {
    await open(tester);
    await tapForgot(tester);
    expect(find.text('Restore from Google Drive backup'), findsOneWidget);
    expect(
      find.textContaining('restore your data from a Google Drive'),
      findsOneWidget,
    );
    final restoreTop = tester.getTopLeft(
      find.byKey(const Key('forgot_pin_restore')),
    );
    final eraseTop = tester.getTopLeft(
      find.byKey(const Key('forgot_pin_erase')),
    );
    expect(restoreTop.dy, lessThan(eraseTop.dy));
  });

  testWidgets('without Drive in this build only erasing is offered', (
    tester,
  ) async {
    await open(tester, available: false);
    await tapForgot(tester);
    expect(find.byKey(const Key('forgot_pin_restore')), findsNothing);
    expect(find.byKey(const Key('forgot_pin_erase')), findsOneWidget);
  });

  testWidgets('US8-3 sign in, pick a backup, confirm: data restored, PIN and '
      'biometric cleared, lock off, Home opens', (tester) async {
    addBackup();
    final w = await open(tester);
    await tapForgot(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_restore')));
    await tester.pumpAndSettle();
    expect(drive.connects, 1);
    expect(w.settings.current.backupAccountEmail, 'me@example.com');
    expect(find.byKey(const Key('drive_restore_picker')), findsOneWidget);

    await tester.tap(find.byKey(const Key('drive_backup_b1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('restore_preview')), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace data'));
    await tester.pumpAndSettle();

    expect(restore.applies, 1);
    expect(w.settings.current.lockEnabled, isFalse);
    expect(w.settings.current.biometricEnabled, isFalse);
    expect(w.lock.store.values.containsKey(SecureLockService.pinKey), isFalse);
    expect(find.byType(UnlockScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(reset.calls, 0);
  });

  testWidgets('US8-4 cancelling at the backup picker changes nothing', (
    tester,
  ) async {
    addBackup();
    final w = await open(tester);
    await tapForgot(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_restore')));
    await tester.pumpAndSettle();
    // Dismiss the picker sheet.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(restore.applies, 0);
    expect(w.settings.current.lockEnabled, isTrue);
    expect(w.lock.store.values.containsKey(SecureLockService.pinKey), isTrue);
    expect(find.byType(UnlockScreen), findsOneWidget);
  });

  testWidgets('US8-4 cancelling Google sign-in changes nothing and shows no '
      'error', (tester) async {
    drive.connectResult = const DriveAuthRequired();
    final w = await open(tester);
    await tapForgot(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_restore')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup_error')), findsNothing);
    expect(find.byKey(const Key('drive_restore_picker')), findsNothing);
    expect(w.settings.current.lockEnabled, isTrue);
    expect(find.byType(UnlockScreen), findsOneWidget);
  });

  testWidgets('US8-2 no backups in Drive: says so and offers Erase all data', (
    tester,
  ) async {
    await open(tester);
    await tapForgot(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_restore')));
    await tester.pumpAndSettle();
    expect(find.text('No backups in Google Drive yet'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    // The usual two-step erase follows.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('typed_confirm_field')),
      'DELETE',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await tester.pumpAndSettle();
    expect(reset.calls, 1);
  });

  testWidgets('a Drive error while listing is explained; nothing changes', (
    tester,
  ) async {
    addBackup();
    drive.failNext = const DriveOffline();
    final w = await open(tester);
    await tapForgot(tester);
    await tester.tap(find.byKey(const Key('forgot_pin_restore')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup_error')), findsOneWidget);
    expect(w.settings.current.lockEnabled, isTrue);
  });
}
