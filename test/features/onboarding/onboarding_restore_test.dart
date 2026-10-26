import 'dart:async';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../account/account_test_app.dart';

/// SYS-02 "Restore with Google" (spec §2, §16; feature 010 US1, T043).
void main() {
  /// A fresh install on step 1.
  const fresh = AppSettings(locale: 'en');

  /// What the backup holds: its language, currency, and modules.
  void restoreWritesBackup(AccountWorld w) => w.restore.onApply = () =>
      w.settings.completeOnboarding(
        const OnboardingChoices(
          locale: 'hi',
          currencyCode: 'USD',
          moduleOrder: ['habit', 'expense'],
          enabledModules: ['habit'],
        ),
      );

  Future<AccountWorld> start(
    WidgetTester tester, {
    void Function(AccountWorld w)? arrange,
    FakeProStore? pro,
  }) async {
    final world = await pumpAccountApp(
      tester,
      initial: fresh,
      location: null,
      hasData: false,
      pro: pro,
      arrange: arrange,
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    return world;
  }

  testWidgets('SYS-02 "Restore with Google" on an account with a backup '
      'restores it without a choice sheet, skips steps 2–4, and lands on '
      "DSH-01 with the backup's language, currency, and modules", (
    tester,
  ) async {
    final world = await start(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        restoreWritesBackup(w);
      },
    );
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(world.restore.applied, [('f0', true)]);
    expect(find.byType(HomeScreen), findsOneWidget);
    final s = world.settings.current;
    expect(s.onboardingDone, isTrue);
    expect(s.locale, 'hi');
    expect(s.currencyCode, 'USD');
    expect(s.enabledModules, ['habit']);
  });

  testWidgets('SYS-02 after a restore from onboarding, the "Finish setting '
      'up" sheet appears once and Restore purchase runs', (tester) async {
    final pro = FakeProStore(ownership: OwnershipCheck.owned);
    final world = await start(
      tester,
      pro: pro,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        restoreWritesBackup(w);
      },
    );
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
    expect(find.byKey(const Key('finish_setup_lock')), findsOneWidget);
    expect(find.byKey(const Key('finish_setup_notifications')), findsOne);
    expect(pro.ownershipQueries, greaterThan(0));
    expect(world.settings.current.removeAdsPurchased, isTrue);
    expect(find.byKey(const Key('sys02_proRestored')), findsOneWidget);

    await tapKey(tester, 'finish_setup_later');
    expect(find.byKey(const Key('finish_setup')), findsNothing);
    expect(world.settings.current.finishSetupPending, isFalse);
    // Never again.
    world.settings.replace(world.settings.current.copyWith(fontSize: 'large'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finish_setup')), findsNothing);
  });

  testWidgets('SYS-02 the restore runs behind the full-screen "Restoring '
      'your data…" view, which back cannot close', (tester) async {
    final gate = Completer<void>();
    final world = await start(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.restore.downloadGate = gate;
        restoreWritesBackup(w);
      },
    );
    await tester.tap(find.byKey(const Key('sys02.restoreWithGoogle')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('sys02_restoring')), findsOneWidget);
    expect(find.text('Restoring your data…'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('sys02_restoring')), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(world.restore.applied, hasLength(1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('SYS-02 cancelling sign-in returns to onboarding with no data '
      'written', (tester) async {
    final world = await start(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.auth.signInResult = const DriveAuthRequired();
      },
    );
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(world.restore.applied, isEmpty);
    expect(world.restore.downloads, isEmpty);
    expect(world.settings.current.onboardingDone, isFalse);
    expect(world.settings.current.backupAccountEmail, isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byKey(const Key('sys02_restoreMessage')), findsNothing);
  });

  testWidgets('SYS-02 an account with no backup stays signed in, says so, '
      'continues onboarding, and backs up once onboarding is done', (
    tester,
  ) async {
    final world = await start(tester);
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(find.text('No backup found on this account'), findsOneWidget);
    expect(world.restore.applied, isEmpty);
    expect(world.settings.current.onboardingDone, isFalse);
    expect(world.settings.current.backupAccountEmail, 'me@example.com');

    await tapKey(tester, 'onboarding_skip');
    expect(world.settings.current.onboardingDone, isTrue);
    expect(world.backup.conflicts, [ConflictMode.pause]);
    expect(world.backup.driveBackups, 1);
  });

  testWidgets('SYS-02 an encrypted backup asks for its password first; a '
      'wrong one writes nothing; afterwards "Encrypt backup" is on', (
    tester,
  ) async {
    final world = await start(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta(encrypted: true));
        w.restore.encryptedWith = 'right';
        restoreWritesBackup(w);
      },
    );
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(find.byKey(const Key('restore_password_field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('restore_password_field')),
      'nope',
    );
    await tapKey(tester, 'restore_password_open');
    expect(find.text("That password didn't work"), findsOneWidget);
    expect(world.restore.applied, isEmpty);

    await tester.enterText(
      find.byKey(const Key('restore_password_field')),
      'right',
    );
    await tapKey(tester, 'restore_password_open');
    expect(world.restore.applied, hasLength(1));
    expect(world.settings.current.backupEncrypt, isTrue);
    expect(world.restore.remembered, 'right');
  });

  testWidgets('SYS-02 a failed restore writes nothing, shows the error, and '
      'offers "Try again"; onboarding continues', (tester) async {
    final world = await start(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.restore.failDownload = const DriveOffline();
      },
    );
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(world.restore.applied, isEmpty);
    expect(
      find.text("Couldn't restore. Your data on this phone wasn't changed."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    restoreWritesBackup(world);
    await tapKey(tester, 'sys02.restoreWithGoogle');
    expect(world.restore.applied, hasLength(1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
