import 'dart:async';
import 'dart:typed_data';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/backup/presentation/backup_summaries.dart';
import 'package:dailytrack/core/backup/presentation/restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_controller.freezed.dart';
part 'backup_controller.g.dart';

/// What SET-02 shows (feature 008 contracts/screens.md "SET-02").
@freezed
abstract class BackupState with _$BackupState {
  const factory({
    required bool encrypt,
    required bool includeReceipts,

    /// Google Drive is configured in this build.
    required bool driveAvailable,
    required AutoBackupFrequency autoFrequency,
    required bool wifiOnly,

    /// UTC epoch milliseconds of the last backup, or null.
    int? lastBackupAt,
    BackupLocation? lastBackupLocation,
    int? lastBackupSizeBytes,

    /// The signed-in Google account, or null (also when this run's silent
    /// sign-in failed; feature 010 research R2).
    String? accountEmail,

    /// Signed out because the Google sign-in expired (research R2).
    @Default(false) bool sessionExpired,

    /// The 7-day copy of the data a restore replaced (FR-019a).
    SafetyCopyInfo? safetyCopy,

    /// The Drive backups; null while signed out.
    AsyncValue<List<DriveBackupEntry>>? drive,

    /// True while a backup file is being saved.
    @Default(false) bool busy,

    /// True while backing up to Drive.
    @Default(false) bool uploading,
  }) = _BackupState;
}

/// SET-02 Backup and restore controller (FR-012 â€“ FR-021).
@riverpod
class BackupController extends _$BackupController {
  @override
  Future<BackupState> build() async {
    final settings = ref.watch(appSettingsProvider.future);
    // Rebuilds when this run's silent sign-in result changes.
    ref.watch(accountStateProvider);
    final available = ref.watch(driveAvailableProvider);
    final s = await settings;
    final account = ref.read(accountServiceProvider).stateOf(s);
    final connected = available && account is SignedIn && account.verified;
    SafetyCopyInfo? safetyCopy;
    try {
      safetyCopy = await ref.read(accountRestoreProvider).safetyCopy();
    } on Object {
      safetyCopy = null;
    }
    // Settings change often (every backup writes several keys); the Drive
    // list is read again only for a different account.
    final previous = state.value;
    final kept = connected && previous?.accountEmail == s.backupAccountEmail
        ? previous?.drive
        : null;
    // After build returns, so the list lands on the new state.
    if (connected && kept == null) unawaited(Future<void>(refreshDrive));
    return BackupState(
      lastBackupAt: s.lastBackupAt,
      lastBackupLocation: s.lastBackupLocation,
      lastBackupSizeBytes: s.lastBackupSizeBytes,
      encrypt: s.backupEncrypt,
      includeReceipts: s.backupIncludeReceipts,
      driveAvailable: available,
      accountEmail: connected ? s.backupAccountEmail : null,
      autoFrequency: s.autoBackupFrequency,
      wifiOnly: s.autoBackupWifiOnly,
      drive: connected ? kept ?? const AsyncLoading() : null,
      sessionExpired: account is SignedOut && account.expired,
      safetyCopy: safetyCopy,
    );
  }

  /// Drive calls made on this screen: an expired sign-in signs the account
  /// out (research R2).
  Future<T> _drive<T>(Future<T> Function() body) =>
      ref.read(accountServiceProvider).guardAuth(body);

  /// A Drive backup through the account restore: the safety copy first,
  /// then the account's bookkeeping and FR-019b (US4 scenario 7).
  RestoreApply applyFromDrive(DriveBackupEntry entry) =>
      (candidate, password) async {
        final result = await ref
            .read(accountRestoreProvider)
            .apply(
              OpenedBackup(candidate, password: password),
              entry: entry,
              fromEmptyPhone: false,
            );
        ref.invalidateSelf();
        return switch (result) {
          Restored(:final outcome) => outcome,
          SafetyCopyFailed() => throw const BackupStorageFull(),
        };
      };

  /// A local file: keeps "Encrypt backup" on with the password that opened
  /// an encrypted one (FR-019b).
  RestoreApply applyFromFile() => (candidate, password) async {
    final outcome = await ref.read(restoreServiceProvider).apply(candidate);
    if (candidate.preview.encrypted && password != null) {
      await ref.read(accountRestoreProvider).rememberEncryption(password);
    }
    return outcome;
  };

  /// "Restore previous phone data": the safety copy's bytes.
  Future<Uint8List?> readSafetyCopy() =>
      ref.read(accountRestoreProvider).readSafetyCopy();

  /// After the safety copy was restored, it is gone.
  Future<void> safetyCopyRestored() async {
    await ref.read(accountRestoreProvider).deleteSafetyCopy();
    ref.invalidateSelf();
  }

  /// Error state "Try again".
  void retry() => ref.invalidateSelf();

  void _update(BackupState Function(BackupState) change) {
    final current = state.value;
    if (current != null) state = AsyncData(change(current));
  }

  /// Makes a backup and lets the user save it. Null when cancelled; throws a
  /// `BackupFailure` the screen shows in plain language.
  Future<SavedBackup?> saveBackup() async {
    _update((s) => s.copyWith(busy: true));
    try {
      return await ref.read(backupServiceProvider).backupToDevice();
    } finally {
      _update((s) => s.copyWith(busy: false));
    }
  }

  Future<void> shareLastBackup() =>
      ref.read(backupServiceProvider).shareLastFile();

  Future<void> setIncludeReceipts({required bool enabled}) => ref
      .read(settingsRepositoryProvider)
      .setBackupIncludeReceipts(enabled: enabled);

  /// The password is stored before encryption turns on, so a backup never
  /// sees "encrypt on" without a password (research R4).
  Future<void> turnOnEncryption(String password) async {
    await ref.read(backupPasswordStoreProvider).write(password);
    await ref.read(settingsRepositoryProvider).setBackupEncrypt(enabled: true);
  }

  /// Future backups only; existing encrypted files keep their password.
  Future<void> turnOffEncryption() async {
    await ref.read(settingsRepositoryProvider).setBackupEncrypt(enabled: false);
    await ref.read(backupPasswordStoreProvider).delete();
  }

  Future<void> changePassword(String password) =>
      ref.read(backupPasswordStoreProvider).write(password);

  // ---- Google Drive (US2, US3) ------------------------------------------

  /// "Back up now" (manual; never rotated) with the conflict rule;
  /// [overwrite] is "Back up anyway" after the warning. Throws a
  /// `BackupFailure`.
  Future<DriveBackupResult> backUpNow({bool overwrite = false}) async {
    _update((s) => s.copyWith(uploading: true));
    final DriveBackupResult result;
    try {
      result = await _drive(
        () => ref
            .read(backupServiceProvider)
            .backupToDrive(
              kind: BackupKind.manual,
              conflict: overwrite ? ConflictMode.overwrite : ConflictMode.ask,
            ),
      );
    } finally {
      _update((s) => s.copyWith(uploading: false));
    }
    if (result is Uploaded) await refreshDrive();
    return result;
  }

  /// Reloads the Drive list (FR-016).
  Future<void> refreshDrive() async {
    if (state.value?.accountEmail == null) return;
    _update((s) => s.copyWith(drive: const AsyncLoading()));
    final result = await AsyncValue.guard(
      () => _drive(ref.read(driveBackupStoreProvider).list),
    );
    _update((s) => s.copyWith(drive: result));
  }

  /// Deletes one Drive backup after the screen's confirmation (FR-016).
  Future<void> deleteBackup(String fileId) async {
    await _drive(() => ref.read(driveBackupStoreProvider).delete(fileId));
    await refreshDrive();
  }

  Future<void> setAutoFrequency(AutoBackupFrequency frequency) async {
    final settings = ref.read(settingsRepositoryProvider);
    final s = await settings.load();
    await settings.setAutoBackup(
      frequency: frequency,
      wifiOnly: s.autoBackupWifiOnly,
    );
    await _syncSchedule();
  }

  Future<void> setWifiOnly({required bool wifiOnly}) async {
    final settings = ref.read(settingsRepositoryProvider);
    final s = await settings.load();
    await settings.setAutoBackup(
      frequency: s.autoBackupFrequency,
      wifiOnly: wifiOnly,
    );
    await _syncSchedule();
  }

  Future<void> _syncSchedule() async => await syncAutoBackupSchedule(
    await ref.read(settingsRepositoryProvider).load(),
    ref.read(backgroundSchedulerProvider),
  );

  /// Each module's summary line for the restore preview, by module id.
  Map<String, String Function(Map<String, int>)> summaries(
    AppLocalizations l10n,
  ) => backupSummaries(ref.read(moduleRegistryProvider), l10n);
}
