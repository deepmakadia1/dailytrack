import 'dart:async';

import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/network_state_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/account/presentation/controllers/sign_out_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'account_test_app.dart';

/// ACC-03 Sign out controller (spec §16, feature 010 US6, T090): the step 1
/// backup state machine, when "Sign out" is enabled, "Remove data from this
/// phone", and no Drive request after sign-out.
void main() {
  late FakeSettingsRepository settings;
  late FakeAccountAuth auth;
  late FakeBackupService backup;
  late FakeDriveBackupStore drive;
  late FakeAppResetService reset;
  late FakeNetworkStateSource network;
  late FakeBackgroundScheduler scheduler;
  late ProviderContainer container;
  late List<SignOutBackup> steps;

  /// Signed in with changes not yet backed up.
  final changed = signedIn.copyWith(dataChangeCounter: 5);

  void start({bool changes = true}) {
    settings = FakeSettingsRepository(initial: changes ? changed : signedIn);
    auth = FakeAccountAuth();
    backup = FakeBackupService();
    drive = FakeDriveBackupStore();
    reset = FakeAppResetService();
    network = FakeNetworkStateSource();
    scheduler = FakeBackgroundScheduler();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        accountAuthProvider.overrideWithValue(auth),
        backupServiceProvider.overrideWithValue(backup),
        driveBackupStoreProvider.overrideWithValue(drive),
        appResetServiceProvider.overrideWithValue(reset),
        networkStateSourceProvider.overrideWithValue(network),
        backgroundSchedulerProvider.overrideWithValue(scheduler),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(),
        ),
        moduleRegistryProvider.overrideWithValue(ModuleRegistry(const [])),
        clockProvider.overrideWithValue(
          MutableClock(DateTime.utc(2026, 10, 28, 9)),
        ),
      ],
    );
    addTearDown(container.dispose);
    steps = [];
    container.listen(signOutControllerProvider, (_, next) {
      if (steps.isEmpty || steps.last != next.backup) steps.add(next.backup);
    }, fireImmediately: true);
  }

  SignOutState state() => container.read(signOutControllerProvider);
  SignOutController controller() =>
      container.read(signOutControllerProvider.notifier);

  group('ACC-03 step 1', () {
    test('ACC-03 with changes: checking → backingUp → backedUp, a manual '
        'backup that asks on conflict', () async {
      final gate = Completer<void>();
      start();
      backup.gate = gate;
      await pumpEventQueue();
      expect(state().backup, SignOutBackup.backingUp);
      expect(state().canSignOut, isFalse);

      gate.complete();
      await pumpEventQueue();
      expect(steps, [
        SignOutBackup.checking,
        SignOutBackup.backingUp,
        SignOutBackup.backedUp,
      ]);
      expect(backup.driveBackups, 1);
      expect(backup.conflicts, [ConflictMode.ask]);
      expect(state().canSignOut, isTrue);
    });

    test(
      'ACC-03 with nothing to back up: checking → backedUp, no upload',
      () async {
        start(changes: false);
        await pumpEventQueue();
        expect(steps, [SignOutBackup.checking, SignOutBackup.backedUp]);
        expect(backup.conflicts, isEmpty);
        expect(state().canSignOut, isTrue);
      },
    );

    test('ACC-03 a failed backup: checking → backingUp → failed; "Try '
        'again" can still succeed', () async {
      start();
      backup.error = const DriveOffline();
      await pumpEventQueue();
      expect(steps, [
        SignOutBackup.checking,
        SignOutBackup.backingUp,
        SignOutBackup.failed,
      ]);
      expect(state().canSignOut, isFalse);

      backup.error = null;
      await controller().backUp();
      expect(state().backup, SignOutBackup.backedUp);
      expect(state().canSignOut, isTrue);
    });

    test('ACC-03 offline: failed at once, with no Drive request', () async {
      start();
      network.online = false;
      await pumpEventQueue();
      expect(steps, [SignOutBackup.checking, SignOutBackup.failed]);
      expect(backup.conflicts, isEmpty);
      expect(drive.calls, isEmpty);
    });

    test('ACC-03 a newer backup from another phone asks; declining is a '
        'failed backup, "Back up anyway" overwrites', () async {
      start();
      backup.conflict = NewerFromOtherDevice(otherPhoneMeta());
      await pumpEventQueue();
      expect(state().conflict, isA<NewerFromOtherDevice>());
      expect(state().canSignOut, isFalse);

      await controller().resolveConflict(backUpAnyway: false);
      expect(state().conflict, isNull);
      expect(state().backup, SignOutBackup.failed);

      await controller().resolveConflict(backUpAnyway: true);
      expect(backup.conflicts.last, ConflictMode.overwrite);
      expect(state().backup, SignOutBackup.backedUp);
    });
  });

  group('ACC-03 "Sign out" enabled', () {
    test('ACC-03 only when backedUp, or failed after "Sign out anyway"', () {
      const checking = SignOutState();
      const backingUp = SignOutState(backup: SignOutBackup.backingUp);
      const backedUp = SignOutState(backup: SignOutBackup.backedUp);
      const failed = SignOutState(backup: SignOutBackup.failed);
      expect(checking.canSignOut, isFalse);
      expect(backingUp.canSignOut, isFalse);
      expect(backedUp.canSignOut, isTrue);
      expect(failed.canSignOut, isFalse);
      expect(failed.copyWith(signedOutAnyway: true).canSignOut, isTrue);
      // Never while signing out.
      expect(backedUp.copyWith(working: true).canSignOut, isFalse);
    });

    test('ACC-03 signOut does nothing until it is enabled', () async {
      start();
      backup.error = const DriveOffline();
      await pumpEventQueue();
      await controller().signOut();
      expect(auth.signOuts, 0);
      expect(settings.current.backupAccountEmail, 'me@example.com');

      controller().signOutAnyway();
      expect(state().canSignOut, isTrue);
      await controller().signOut();
      expect(auth.signOuts, 1);
      expect(settings.current.backupAccountEmail, isNull);
    });

    test('ACC-03 "Remove data" after a failed backup needs the typed DELETE; '
        'after a backup it does not', () {
      const failed = SignOutState(
        backup: SignOutBackup.failed,
        choice: SignOutChoice.remove,
      );
      expect(failed.needsTypedConfirm, isTrue);
      expect(
        failed.copyWith(backup: SignOutBackup.backedUp).needsTypedConfirm,
        isFalse,
      );
      expect(
        failed.copyWith(choice: SignOutChoice.keep).needsTypedConfirm,
        isFalse,
      );
    });
  });

  group('ACC-03 step 2', () {
    test(
      'ACC-03 "Keep data on this phone" signs out without erasing',
      () async {
        start(changes: false);
        await pumpEventQueue();
        await controller().signOut();
        expect(auth.signOuts, 1);
        expect(reset.calls, 0);
        expect(settings.current.backupAccountEmail, isNull);
      },
    );

    test(
      'ACC-03 "Remove data from this phone" signs out, then erases',
      () async {
        start(changes: false);
        await pumpEventQueue();
        int? signOutsAtErase;
        reset.onErase = () => signOutsAtErase = auth.signOuts;
        controller().choose(SignOutChoice.remove);
        await controller().signOut();
        expect(auth.signOuts, 1);
        expect(reset.calls, 1);
        // The erase ran after Google sign-out.
        expect(signOutsAtErase, 1);
        expect(settings.current.backupAccountEmail, isNull);
        expect(state().working, isFalse);
      },
    );

    test('ACC-03 after sign-out, no Drive request is made until the user '
        'signs in again', () async {
      start();
      await pumpEventQueue();
      await controller().signOut();
      drive.calls.clear();
      final uploads = backup.conflicts.length;

      // Every way a backup could start on its own: the scheduled and the
      // app-open jobs, and leaving the app.
      await runAutoBackup(container.read);
      await runAutoBackup(container.read, foreground: true);
      await container.read(backgroundBackupSchedulerProvider).onAppHidden();

      expect(drive.calls, isEmpty);
      expect(backup.changedChecks, 0);
      expect(backup.conflicts, hasLength(uploads));
      expect(scheduler.oneOff, isEmpty);
      expect(
        scheduler.cancelled,
        containsAll(['core.autoBackup', 'core.backgroundBackup']),
      );
    });
  });
}
