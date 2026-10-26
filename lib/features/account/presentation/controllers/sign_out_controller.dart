import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/change_counter.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_controller.freezed.dart';
part 'sign_out_controller.g.dart';

/// ACC-03 step 1: backing up the latest changes first.
enum SignOutBackup { checking, backingUp, backedUp, failed }

/// ACC-03 step 2.
enum SignOutChoice { keep, remove }

/// What ACC-03 shows (feature 010 contracts/screens.md "ACC-03").
@freezed
abstract class SignOutState with _$SignOutState {
  const factory({
    @Default(SignOutBackup.checking) SignOutBackup backup,
    @Default(SignOutChoice.keep) SignOutChoice choice,

    /// "Sign out anyway" after a failed backup.
    @Default(false) bool signedOutAnyway,

    /// A newer backup from another phone: the sheet asks, then calls
    /// [SignOutController.resolveConflict].
    ConflictCheck? conflict,

    /// Signing out (and erasing) is running.
    @Default(false) bool working,
  }) = _SignOutState;
  const new _();

  /// "Sign out" is enabled once the changes are backed up, or the user
  /// chose to go on without them (ACC-03 criterion 1).
  bool get canSignOut =>
      !working &&
      (backup == SignOutBackup.backedUp ||
          (backup == SignOutBackup.failed && signedOutAnyway));

  /// Removing data after a failed backup loses those changes: typed DELETE
  /// first (FR-023).
  bool get needsTypedConfirm =>
      choice == SignOutChoice.remove && backup == SignOutBackup.failed;
}

/// ACC-03 Sign out controller (spec §16).
@riverpod
class SignOutController extends _$SignOutController {
  @override
  SignOutState build() {
    unawaited(Future<void>(backUp));
    return const SignOutState();
  }

  /// Step 1, and "Try again": a manual backup with the conflict rule when
  /// data changed since the last backup. Offline or any failure goes to
  /// the failed state.
  Future<void> backUp({bool overwrite = false}) async {
    final s = await ref.read(settingsRepositoryProvider).load();
    final changed = ChangeCounter.changed(
      current: s.dataChangeCounter,
      backedUp: s.backedUpChangeCounter,
    );
    if (!changed && !overwrite) {
      _set(state.copyWith(backup: SignOutBackup.backedUp));
      return;
    }
    _set(state.copyWith(backup: SignOutBackup.backingUp, conflict: null));
    try {
      final result = await ref
          .read(accountServiceProvider)
          .guardAuth(
            () => ref
                .read(backupServiceProvider)
                .backupToDrive(
                  kind: BackupKind.manual,
                  conflict: overwrite
                      ? ConflictMode.overwrite
                      : ConflictMode.ask,
                ),
          );
      _set(switch (result) {
        NeedsConfirmation(:final conflict) => state.copyWith(
          conflict: conflict,
        ),
        _ => state.copyWith(backup: SignOutBackup.backedUp),
      });
    } on Object {
      _set(state.copyWith(backup: SignOutBackup.failed));
    }
  }

  /// The conflict warning's answer; declining counts as a failed backup.
  Future<void> resolveConflict({required bool backUpAnyway}) async {
    _set(state.copyWith(conflict: null));
    if (backUpAnyway) {
      await backUp(overwrite: true);
    } else {
      _set(state.copyWith(backup: SignOutBackup.failed));
    }
  }

  void signOutAnyway() => _set(state.copyWith(signedOutAnyway: true));

  void choose(SignOutChoice choice) => _set(state.copyWith(choice: choice));

  /// Signs out (FR-024); with "Remove data from this phone", then runs the
  /// same erase as Erase all data, which also removes the safety copy and
  /// leads to onboarding (FR-025). Drive backups are kept.
  Future<void> signOut() async {
    if (!state.canSignOut) return;
    _set(state.copyWith(working: true));
    try {
      await ref.read(accountServiceProvider).signOut();
      if (state.choice == SignOutChoice.remove) {
        await ref.read(appResetServiceProvider).eraseAll();
      }
    } finally {
      _set(state.copyWith(working: false));
    }
  }

  void _set(SignOutState next) {
    if (ref.mounted) state = next;
  }
}
