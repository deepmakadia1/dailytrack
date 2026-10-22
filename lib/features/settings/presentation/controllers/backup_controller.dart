import 'dart:async';

import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_summaries.dart';
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

    /// The connected Google account, or null.
    String? accountEmail,

    /// The Drive backups; null while no account is connected.
    AsyncValue<List<DriveBackupEntry>>? drive,

    /// True while a backup file is being saved.
    @Default(false) bool busy,

    /// True while backing up to Drive.
    @Default(false) bool uploading,
  }) = _BackupState;
}

/// SET-02 Backup and restore controller (FR-012 – FR-021).
@riverpod
class BackupController extends _$BackupController {
  @override
  Future<BackupState> build() async {
    final s = await ref.watch(appSettingsProvider.future);
    final available = ref.watch(driveAvailableProvider);
    final connected = available && s.backupAccountEmail != null;
    // After build returns, so the list lands on the new state.
    if (connected) unawaited(Future<void>(refreshDrive));
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
      drive: connected ? const AsyncLoading() : null,
    );
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

  /// Interactive sign-in with the `drive.appdata` scope only (FR-014).
  /// Throws `DriveAuthRequired` when the user cancels.
  Future<void> connect() async {
    final email = await ref.read(driveBackupStoreProvider).connect();
    await ref.read(settingsRepositoryProvider).setBackupAccountEmail(email);
    await _syncSchedule();
  }

  /// Signs out, turns auto backup off, and keeps the Drive backups
  /// (FR-015).
  Future<void> disconnect() async {
    try {
      await ref.read(driveBackupStoreProvider).disconnect();
    } on Object {
      // Forgetting the account locally is enough to stop backups.
    }
    final settings = ref.read(settingsRepositoryProvider);
    final s = await settings.load();
    await settings.setAutoBackup(
      frequency: AutoBackupFrequency.off,
      wifiOnly: s.autoBackupWifiOnly,
    );
    await settings.setBackupAccountEmail(null);
    await _syncSchedule();
  }

  /// "Back up now" (manual; never pruned). Throws a `BackupFailure`.
  Future<void> backUpNow() async {
    _update((s) => s.copyWith(uploading: true));
    try {
      await ref
          .read(backupServiceProvider)
          .backupToDrive(kind: BackupKind.manual);
    } finally {
      _update((s) => s.copyWith(uploading: false));
    }
    await refreshDrive();
  }

  /// Reloads the Drive list (FR-016).
  Future<void> refreshDrive() async {
    if (state.value?.accountEmail == null) return;
    _update((s) => s.copyWith(drive: const AsyncLoading()));
    final result = await AsyncValue.guard(
      ref.read(driveBackupStoreProvider).list,
    );
    _update((s) => s.copyWith(drive: result));
  }

  /// Deletes one Drive backup after the screen's confirmation (FR-016).
  Future<void> deleteBackup(String fileId) async {
    await ref.read(driveBackupStoreProvider).delete(fileId);
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
