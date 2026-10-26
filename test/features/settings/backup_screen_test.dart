import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-02 Backup and restore, local file (feature 008 T034, T035, T036,
/// T075, T077; US1, US4; FR-007, FR-012, FR-013, FR-021, FR-034).
void main() {
  late FakeBackupService backup;
  late FakeRestoreService restore;
  late FakeBackupPasswordStore passwords;
  late FakeFileSharer sharer;
  late FakeDriveBackupStore drive;
  late FakeBackgroundScheduler scheduler;
  late FakeAccountAuth auth;
  late FakeAccountRestore accountRestore;

  setUp(() {
    backup = FakeBackupService();
    restore = FakeRestoreService();
    passwords = FakeBackupPasswordStore();
    sharer = FakeFileSharer();
    drive = FakeDriveBackupStore();
    scheduler = FakeBackgroundScheduler();
    auth = FakeAccountAuth();
  });

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true, locale: 'en'),
    String location = Routes.backup,
    bool driveAvailable = false,
    bool phoneHasData = false,
    void Function()? arrange,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 1800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeSettingsRepository(initial: initial);
    accountRestore = FakeAccountRestore(settings: repo)..hasData = phoneHasData;
    arrange?.call();
    final settings = await pumpTestApp(
      tester,
      settings: repo,
      accountRestore: accountRestore,
      overrides: [
        backupServiceProvider.overrideWithValue(backup),
        restoreServiceProvider.overrideWithValue(restore),
        backupPasswordStoreProvider.overrideWithValue(passwords),
        fileSharerProvider.overrideWithValue(sharer),
        driveAvailableProvider.overrideWithValue(driveAvailable),
        driveBackupStoreProvider.overrideWithValue(drive),
      ],
      background: scheduler,
      accountAuth: auth,
    );
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
    return settings;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('SET-01 FR-034 the Data section opens SET-02 and says "Not '
      'backed up yet"', (tester) async {
    await open(tester, location: Routes.more);
    final row = find.byKey(const Key('settings_backup'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: row, matching: find.text('Not backed up yet')),
      findsOneWidget,
    );
    // Backup comes before Erase all data.
    expect(
      tester.getTopLeft(row).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('settings_erase_all'))).dy,
      ),
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(BackupScreen), findsOneWidget);
  });

  testWidgets('SET-02 US1-8 Last backup shows "No backup yet", then the date, '
      'location, and size', (tester) async {
    await open(tester);
    expect(find.text('No backup yet'), findsOneWidget);

    await open(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        lastBackupAt: 1792540800000,
        lastBackupLocation: BackupLocation.device,
        lastBackupSizeBytes: 1258291,
      ),
    );
    final line = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('backup_last')),
        matching: find.byType(Text),
      ),
    );
    expect(line.data, contains('This device'));
    expect(line.data, contains('1.2 MB'));
    expect(line.data, contains('2026'));
  });

  testWidgets('SET-02 US1-1 Save backup file → "Backup saved" with Share', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'backup_save_file');
    expect(backup.saves, 1);
    expect(find.text('Backup saved'), findsOneWidget);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(backup.shares, 1);
  });

  testWidgets('SET-02 US1-1 a cancelled save shows nothing', (tester) async {
    backup.cancel = true;
    await open(tester);
    await tapKey(tester, 'backup_save_file');
    expect(find.text('Backup saved'), findsNothing);
    expect(find.byKey(const Key('backup_error')), findsNothing);
  });

  testWidgets('SET-02 a failed backup explains it in plain language', (
    tester,
  ) async {
    backup.error = const BackupNeedsPassword();
    await open(tester);
    await tapKey(tester, 'backup_save_file');
    expect(find.byKey(const Key('backup_error')), findsOneWidget);
    expect(
      find.text(
        'Set your backup password again to keep making encrypted backups.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('SET-02 US1-2 "Include receipt images" persists', (tester) async {
    final settings = await open(tester);
    await tapKey(tester, 'backup_include_receipts');
    expect(settings.current.backupIncludeReceipts, isTrue);
  });

  testWidgets('SET-02 US4-1 Encrypt backup needs matching passwords and shows '
      'the warning; cancel leaves it off', (tester) async {
    final settings = await open(tester);
    await tapKey(tester, 'backup_encrypt');
    expect(find.byKey(const Key('backup_password_warning')), findsOneWidget);
    expect(
      find.textContaining("backups made with it can't be restored"),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('backup_password_field')),
      'one',
    );
    await tester.enterText(
      find.byKey(const Key('backup_password_confirm')),
      'two',
    );
    await tester.pumpAndSettle();
    expect(find.text("Passwords don't match"), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('backup_password_save')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.current.backupEncrypt, isFalse);
    expect(passwords.value, isNull);

    await tapKey(tester, 'backup_encrypt');
    await tester.enterText(
      find.byKey(const Key('backup_password_field')),
      'secret',
    );
    await tester.enterText(
      find.byKey(const Key('backup_password_confirm')),
      'secret',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('backup_password_save')));
    await tester.pumpAndSettle();
    expect(passwords.value, 'secret');
    expect(settings.current.backupEncrypt, isTrue);
    expect(find.byKey(const Key('backup_change_password')), findsOneWidget);
  });

  testWidgets('SET-02 US4-4 turning encryption off deletes the password', (
    tester,
  ) async {
    passwords.value = 'secret';
    final settings = await open(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        backupEncrypt: true,
      ),
    );
    await tapKey(tester, 'backup_encrypt');
    expect(settings.current.backupEncrypt, isFalse);
    expect(passwords.value, isNull);
  });

  testWidgets('SET-02 US1-3/4 restore: summary, "Replace current data?", then '
      'restored', (tester) async {
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    expect(find.byKey(const Key('restore_preview')), findsOneWidget);
    expect(find.text('1,240 transactions'), findsOneWidget);
    expect(find.text('8 habits'), findsOneWidget);
    expect(find.text('Includes 3 receipt images'), findsOneWidget);
    expect(find.text('App version 1.0.0+7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restore_continue')));
    await tester.pumpAndSettle();
    expect(find.text('Replace current data?'), findsOneWidget);
    await tester.tap(find.text('Replace data'));
    await tester.pumpAndSettle();
    expect(restore.applies, 1);
    expect(find.text('Backup restored'), findsOneWidget);
  });

  testWidgets('SET-02 US1-4 cancelling at the summary or the confirmation '
      'changes nothing', (tester) async {
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(restore.applies, 0);

    await tapKey(tester, 'backup_restore_file');
    await tester.tap(find.byKey(const Key('restore_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(restore.applies, 0);
    expect(find.text('Backup restored'), findsNothing);
  });

  testWidgets('SET-02 US4-3 an encrypted file asks for its password; a wrong '
      'one asks again', (tester) async {
    restore.onOpen = (password) => switch (password) {
      null => const BackupNeedsPassword(),
      'right' => FakeRestoreService.candidate(),
      _ => const BackupWrongPassword(),
    };
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    expect(find.text('Enter backup password'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('restore_password_field')),
      'wrong',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('restore_password_open')));
    await tester.pumpAndSettle();
    expect(find.text('Wrong password or damaged file.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('restore_password_field')),
      'right',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('restore_password_open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('restore_preview')), findsOneWidget);
    expect(restore.passwords, [null, 'wrong', 'right']);
    expect(restore.applies, 0);
  });

  testWidgets('SET-02 US1-5 a file that is not a backup: plain error, nothing '
      'restored', (tester) async {
    restore.onOpen = (_) => const BackupNotRecognized();
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    expect(
      find.text("This isn't a DailyTrack backup. Nothing was changed."),
      findsOneWidget,
    );
    expect(restore.applies, 0);
  });

  testWidgets('SET-02 US1-5 a newer backup asks to update the app', (
    tester,
  ) async {
    restore.onOpen = (_) => const BackupTooNew(9);
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    expect(
      find.text('Update DailyTrack to restore this backup.'),
      findsOneWidget,
    );
  });

  testWidgets('SET-02 US1-7 a failed restore says nothing changed', (
    tester,
  ) async {
    restore.applyError = const BackupInvalid('fk');
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    await tester.tap(find.byKey(const Key('restore_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace data'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('restore_progress')), findsNothing);
    expect(
      find.text(
        "This backup has data DailyTrack can't use. Nothing was "
        'changed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Backup restored'), findsNothing);
  });

  testWidgets('SET-02 picking no file does nothing', (tester) async {
    restore.picked = null;
    await open(tester);
    await tapKey(tester, 'backup_restore_file');
    expect(restore.passwords, isEmpty);
    expect(find.byKey(const Key('restore_preview')), findsNothing);
  });

  group('Google Drive (US2, US3)', () {
    const connected = AppSettings(
      onboardingDone: true,
      locale: 'en',
      backupAccountEmail: 'me@example.com',
    );

    DriveBackupEntry entry(String id, BackupKind kind, int day) =>
        DriveBackupEntry(
          id: id,
          name: '$id.json',
          createdAt: DateTime.utc(2026, 10, day, 12).millisecondsSinceEpoch,
          sizeBytes: 2048,
          kind: kind,
          device: 'Pixel 8a',
        );

    testWidgets('SET-02 without a configured client the card says Drive is '
        'unavailable', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('backup_drive_unavailable')), findsOneWidget);
      expect(find.byKey(const Key('backup_signIn')), findsNothing);
    });

    testWidgets('SET-02 "Sign in with Google" is the shared sign-in: it '
        'shows the account, Back up now, and Auto backup, turns Auto backup '
        'to Daily, and makes the first backup', (tester) async {
      final settings = await open(tester, driveAvailable: true);
      expect(find.byKey(const Key('backup_now')), findsNothing);
      await tapKey(tester, 'backup_signIn');
      expect(auth.signIns, 1);
      expect(settings.current.backupAccountEmail, 'me@example.com');
      expect(settings.current.accountDisplayName, 'Asha Patel');
      expect(settings.current.autoBackupFrequency, AutoBackupFrequency.daily);
      expect(backup.driveBackups, 1);
      expect(find.text('Signed in. Your data is backed up.'), findsOneWidget);
      expect(find.text('me@example.com'), findsOneWidget);
      for (final key in [
        'backup_account',
        'backup_now',
        'backup_auto',
        'backup_wifi_only',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
      expect(find.byKey(const Key('backup_disconnect')), findsNothing);
      // One primary action: Back up now; saving a file is secondary.
      expect(
        tester.widget(find.byKey(const Key('backup_save_file'))),
        isA<OutlinedButton>(),
      );
    });

    testWidgets('SET-02 US2-2 cancelling sign-in changes nothing and shows '
        'no error', (tester) async {
      auth.signInResult = const DriveAuthRequired();
      final settings = await open(tester, driveAvailable: true);
      await tapKey(tester, 'backup_signIn');
      expect(settings.current.backupAccountEmail, isNull);
      expect(settings.current.autoBackupFrequency, AutoBackupFrequency.off);
      expect(backup.driveBackups, 0);
      expect(find.byKey(const Key('backup_error')), findsNothing);
      expect(find.byKey(const Key('backup_signIn')), findsOneWidget);
    });

    testWidgets('SET-02 signing in to an account with a backup opens ACC-02 '
        'when this phone has data, and uploads nothing', (tester) async {
      drive.files.add(entry('theirs', BackupKind.manual, 2));
      final settings = await open(
        tester,
        driveAvailable: true,
        phoneHasData: true,
      );
      await tapKey(tester, 'backup_signIn');
      expect(settings.current.backupAccountEmail, 'me@example.com');
      expect(backup.driveBackups, 0);
      expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
      expect(find.byKey(const Key('acc02_close')), findsNothing);
    });

    testWidgets('SET-02 signing in to an account with a backup on a phone '
        'with no data restores it without the choice', (tester) async {
      drive.files.add(entry('theirs', BackupKind.manual, 2));
      await open(tester, driveAvailable: true);
      await tapKey(tester, 'backup_signIn');
      expect(find.byKey(const Key('acc02_sheet')), findsNothing);
      expect(accountRestore.applied, [('theirs', true)]);
      expect(backup.driveBackups, 0);
    });

    testWidgets('SET-02 a failed sign-in says so', (tester) async {
      auth.signInResult = const DriveOffline();
      final settings = await open(tester, driveAvailable: true);
      await tapKey(tester, 'backup_signIn');
      expect(settings.current.backupAccountEmail, isNull);
      expect(
        find.text("Couldn't sign in. Check your connection and try again."),
        findsOneWidget,
      );
    });

    testWidgets('SET-02 US2-4 Back up now shows "Backed up to Google Drive"', (
      tester,
    ) async {
      await open(tester, initial: connected, driveAvailable: true);
      await tapKey(tester, 'backup_now');
      expect(backup.driveBackups, 1);
      expect(find.text('Backed up to Google Drive'), findsOneWidget);
    });

    testWidgets('§16 Back up now over a newer backup from another phone '
        'warns first; Cancel uploads nothing', (tester) async {
      backup.conflict = const NewerFromOtherDevice(
        BackupMeta(
          deviceId: 'other-phone',
          deviceName: 'Redmi Note 12',
          appVersion: '1.0.0+7',
          createdAt: 1792540800000,
          kind: BackupKind.manual,
          counts: {'expense.transactions': 4},
          schemaVersion: 5,
          encrypted: false,
        ),
      );
      await open(tester, initial: connected, driveAvailable: true);
      await tapKey(tester, 'backup_now');
      expect(find.text('Back up anyway?'), findsOneWidget);
      expect(
        find.textContaining('A newer backup from Redmi Note 12'),
        findsOne,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(backup.driveBackups, 0);

      await tapKey(tester, 'backup_now');
      await tester.tap(find.text('Back up anyway'));
      await tester.pumpAndSettle();
      expect(backup.driveBackups, 1);
      expect(backup.conflicts.last, ConflictMode.overwrite);
      expect(find.text('Backed up to Google Drive'), findsOneWidget);
    });

    testWidgets('SET-02 US2-5 offline: a plain error', (tester) async {
      backup.error = const DriveOffline();
      await open(tester, initial: connected, driveAvailable: true);
      await tapKey(tester, 'backup_now');
      expect(
        find.text(
          "Couldn't reach Google Drive. Check your connection and try again.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('SET-02 US2-6 an empty Drive list says so', (tester) async {
      await open(tester, initial: connected, driveAvailable: true);
      expect(find.byKey(const Key('backup_drive_empty')), findsOneWidget);
      expect(find.text('No backups in Google Drive yet'), findsOneWidget);
    });

    testWidgets('SET-02 US2-6/10 the Drive list is newest first with '
        'Manual/Auto labels', (tester) async {
      drive.files.addAll([
        entry('old', BackupKind.manual, 1),
        entry('new', BackupKind.auto, 9),
      ]);
      await open(tester, initial: connected, driveAvailable: true);
      final newer = tester.getTopLeft(
        find.byKey(const Key('drive_backup_new')),
      );
      final older = tester.getTopLeft(
        find.byKey(const Key('drive_backup_old')),
      );
      expect(newer.dy, lessThan(older.dy));
      expect(find.text('Auto · Pixel 8a'), findsOneWidget);
      expect(find.text('Manual · Pixel 8a'), findsOneWidget);
    });

    testWidgets('token expiry: when Drive refuses the sign-in, SET-02 shows '
        'the account signed out and says to sign in again', (tester) async {
      drive.failNext = const DriveAuthRequired();
      final settings = await open(
        tester,
        initial: connected,
        driveAvailable: true,
      );
      expect(settings.current.backupAccountEmail, isNull);
      expect(find.byKey(const Key('backup_sessionExpired')), findsOneWidget);
      await tapKey(tester, 'backup_signIn');
      expect(auth.signIns, 1);
      expect(find.byKey(const Key('backup_sessionExpired')), findsNothing);
      expect(find.byKey(const Key('backup_account')), findsOneWidget);
    });

    testWidgets('SET-02 US2-10 Delete asks first, then removes the backup', (
      tester,
    ) async {
      drive.files.add(entry('a', BackupKind.manual, 3));
      await open(tester, initial: connected, driveAvailable: true);
      await tapKey(tester, 'drive_backup_menu_a');
      await tester.tap(find.byKey(const Key('drive_backup_delete_a')));
      await tester.pumpAndSettle();
      expect(find.text('Delete this backup?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(drive.deleted, isEmpty);

      await tapKey(tester, 'drive_backup_menu_a');
      await tester.tap(find.byKey(const Key('drive_backup_delete_a')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete backup'));
      await tester.pumpAndSettle();
      expect(drive.deleted, ['a']);
      expect(find.byKey(const Key('drive_backup_a')), findsNothing);
    });

    testWidgets('SET-02 US2-7 tapping a Drive backup downloads it, then the '
        'usual summary and confirmation restore it', (tester) async {
      drive
        ..files.add(entry('a', BackupKind.auto, 3))
        ..contents['a'] = Uint8List.fromList(utf8.encode('{}'));
      await open(tester, initial: connected, driveAvailable: true);
      await tapKey(tester, 'drive_backup_a');
      expect(find.byKey(const Key('restore_preview')), findsOneWidget);
      await tester.tap(find.byKey(const Key('restore_continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replace data'));
      await tester.pumpAndSettle();
      // Through the account restore: the safety copy and FR-019b.
      expect(accountRestore.applied, [('a', false)]);
      expect(find.text('Backup restored'), findsOneWidget);
    });

    testWidgets('ACC-02 US3-5 "Restore previous phone data" shows the copy\'s '
        'date and counts, restores it after the usual steps, and is gone '
        'afterwards', (tester) async {
      await open(
        tester,
        initial: connected,
        driveAvailable: true,
        arrange: () => accountRestore.copy = SafetyCopyInfo(
          createdAt: DateTime(2026, 10, 25, 21).toUtc().millisecondsSinceEpoch,
          counts: const {'expense.transactions': 12},
          fileName: 'dailytrack_backup_20261025_2100.json',
        ),
      );
      expect(find.text('Restore previous phone data'), findsWidgets);
      expect(find.textContaining('12 transactions'), findsOneWidget);
      await tapKey(tester, 'backup_previous');
      expect(find.byKey(const Key('restore_preview')), findsOneWidget);
      await tester.tap(find.byKey(const Key('restore_continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replace data'));
      await tester.pumpAndSettle();
      expect(restore.applies, 1);
      expect(accountRestore.copyDeletes, 1);
      expect(find.byKey(const Key('backup_previous')), findsNothing);
    });

    testWidgets('SET-02 without a safety copy there is no "Restore previous '
        'phone data"', (tester) async {
      await open(tester, initial: connected, driveAvailable: true);
      expect(find.byKey(const Key('backup_previous')), findsNothing);
    });

    testWidgets('FR-019b restoring an encrypted file turns "Encrypt backup" on '
        'with that password; a failed restore saves nothing', (tester) async {
      restore.onOpen = (password) => switch (password) {
        null => const BackupNeedsPassword(),
        'pw' => FakeAccountRestore.candidate(encrypted: true),
        _ => const BackupWrongPassword(),
      };
      final settings = await open(tester);
      Future<void> restoreFile() async {
        await tapKey(tester, 'backup_restore_file');
        await tester.enterText(
          find.byKey(const Key('restore_password_field')),
          'pw',
        );
        await tapKey(tester, 'restore_password_open');
        await tester.tap(find.byKey(const Key('restore_continue')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Replace data'));
        await tester.pumpAndSettle();
      }

      restore.applyError = const BackupStorageFull();
      await restoreFile();
      expect(accountRestore.remembered, isNull);
      expect(settings.current.backupEncrypt, isFalse);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      restore.applyError = null;
      await restoreFile();
      expect(accountRestore.remembered, 'pw');
      expect(settings.current.backupEncrypt, isTrue);
    });

    testWidgets('SET-02 US3-1 Daily with Wi-Fi only schedules an unmetered '
        'job; Wi-Fi only off needs any network', (tester) async {
      final settings = await open(
        tester,
        initial: connected,
        driveAvailable: true,
      );
      // Off by default: Wi-Fi only is disabled.
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('backup_wifi_only')))
            .onChanged,
        isNull,
      );
      await tapKey(tester, 'backup_auto');
      await tester.tap(find.byKey(const Key('backup_auto_daily')));
      await tester.pumpAndSettle();
      expect(settings.current.autoBackupFrequency, AutoBackupFrequency.daily);
      expect(scheduler.periodic[autoBackupTaskName], (
        const Duration(hours: 24),
        NetworkRequirement.unmetered,
      ));
      await tapKey(tester, 'backup_wifi_only');
      expect(settings.current.autoBackupWifiOnly, isFalse);
      expect(
        scheduler.periodic[autoBackupTaskName]?.$2,
        NetworkRequirement.connected,
      );
    });

    testWidgets('SET-02 signed in, the account row opens ACC-01; sign-out '
        'lives there', (tester) async {
      await open(tester, initial: connected, driveAvailable: true);
      expect(find.byKey(const Key('backup_disconnect')), findsNothing);
      await tapKey(tester, 'backup_account');
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.byKey(const Key('acc01.signOut')), findsOneWidget);
    });
  });
}
