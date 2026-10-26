import 'dart:async';
import 'dart:typed_data';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restore_choice_controller.freezed.dart';
part 'restore_choice_controller.g.dart';

/// What ACC-02 shows (feature 010 contracts/screens.md "ACC-02"). The
/// summary comes from the backup's metadata only; nothing is downloaded
/// until "Restore from account".
@freezed
abstract class RestoreChoiceState with _$RestoreChoiceState {
  const factory({
    /// This phone's counts, keyed like `BackupMeta.counts`.
    required AsyncValue<Map<String, int>> phoneCounts,

    /// This install's ID, for "From this phone"; null while loading.
    String? thisDeviceId,

    /// The saved backup password didn't open it: the field shows.
    @Default(false) bool passwordNeeded,

    /// The typed password didn't work.
    @Default(false) bool passwordError,

    /// Restoring or keeping is running.
    @Default(false) bool working,

    /// The last restore failed; this phone's data is unchanged.
    Object? failure,
  }) = _RestoreChoiceState;
}

/// ACC-02 Restore choice controller for [newest].
@riverpod
class RestoreChoiceController extends _$RestoreChoiceController {
  /// Downloaded once; "Try again" after a wrong password reuses it.
  Uint8List? _bytes;

  @override
  RestoreChoiceState build(DriveBackupEntry newest) {
    unawaited(Future<void>(_load));
    return const RestoreChoiceState(phoneCounts: AsyncLoading());
  }

  Future<void> _load() async {
    final counts = await AsyncValue.guard(
      ref.read(accountRestoreProvider).phoneCounts,
    );
    String? id;
    try {
      id = (await ref.read(deviceIdentityServiceProvider).current()).id;
    } on Object {
      id = null;
    }
    if (!ref.mounted) return;
    state = state.copyWith(phoneCounts: counts, thisDeviceId: id);
  }

  /// "Restore from account": downloads, opens with the saved password (or
  /// [password] once the field shows), saves the safety copy, and replaces
  /// this phone's data. Null when it needs a password or failed (shown in
  /// the state).
  Future<AccountRestoreResult?> restore({String? password}) async {
    final restore = ref.read(accountRestoreProvider);
    final account = ref.read(accountServiceProvider);
    state = state.copyWith(working: true, failure: null, passwordError: false);
    try {
      final bytes =
          _bytes ??
          await account.guardAuth<Uint8List>(() => restore.download(newest));
      _bytes = bytes;
      final OpenedBackup opened;
      try {
        opened = await restore.open(bytes, password: password);
      } on BackupNeedsPassword {
        if (ref.mounted) {
          state = state.copyWith(working: false, passwordNeeded: true);
        }
        return null;
      } on BackupWrongPassword {
        if (ref.mounted) {
          state = state.copyWith(working: false, passwordError: true);
        }
        return null;
      }
      final result = await restore.apply(
        opened,
        entry: newest,
        fromEmptyPhone: false,
      );
      if (ref.mounted) state = state.copyWith(working: false);
      return result;
    } on Object catch (e) {
      if (ref.mounted) state = state.copyWith(working: false, failure: e);
      return null;
    }
  }

  /// "Keep this phone's data" (FR-020). Writes nothing locally.
  Future<void> keep() async {
    state = state.copyWith(working: true);
    try {
      await ref.read(accountRestoreProvider).keepThisPhone(newest);
    } finally {
      if (ref.mounted) state = state.copyWith(working: false);
    }
  }
}
