import 'dart:io';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/data/backup_engine.dart';
import 'package:dailytrack/core/backup/data/file_picker_local_backup_files.dart';
import 'package:dailytrack/core/backup/data/google_auth.dart';
import 'package:dailytrack/core/backup/data/google_drive_backup_store.dart';
import 'package:dailytrack/core/backup/data/safety_copy_store.dart';
import 'package:dailytrack/core/backup/data/secure_backup_password_store.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/config/google_config.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/security/data/flutter_secure_key_value_store.dart';
import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

/// System save and open dialogs. Widget tests override this with a fake.
@Riverpod(keepAlive: true)
LocalBackupFiles localBackupFiles(Ref ref) => FilePickerLocalBackupFiles(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);

/// Whether Google Drive backup is configured in this build (research R10).
/// Widget tests override it.
@Riverpod(keepAlive: true)
bool driveAvailable(Ref ref) => GoogleConfig.driveAvailable;

/// Google sign-in, shared so initialization happens once.
@Riverpod(keepAlive: true)
GoogleAuth googleAuth(Ref ref) => GoogleAuth(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);

/// The user's Drive app folder (feature 008 research R10). Widget tests
/// override this with a fake.
@Riverpod(keepAlive: true)
DriveBackupStore driveBackupStore(Ref ref) =>
    GoogleDriveBackupStore(api: ref.watch(googleAuthProvider).driveApi);

/// The backup password in secure storage (feature 008 research R4).
@Riverpod(keepAlive: true)
BackupPasswordStore backupPasswordStore(Ref ref) =>
    const SecureBackupPasswordStore(FlutterSecureKeyValueStore());

/// Where receipts live; tests point this at a temporary folder.
@Riverpod(keepAlive: true)
Future<Directory> Function() backupDocumentsDir(Ref ref) =>
    getApplicationDocumentsDirectory;

/// Where backup copies are kept for sharing.
@Riverpod(keepAlive: true)
Future<Directory> Function() backupCacheDir(Ref ref) => getTemporaryDirectory;

/// The 7-day safety copy in app support (feature 010 data-model §5).
/// Widget tests override it with a fake.
@Riverpod(keepAlive: true)
SafetyCopyStore safetyCopyStore(Ref ref) =>
    FileSafetyCopyStore(getApplicationSupportDirectory);

/// Runs after a restore: reschedule notifications and run app-open work
/// (FR-010). Bound in `lib/app/production_overrides.dart`, because core never
/// imports `lib/app/` (feature 008 research R8).
@Riverpod(keepAlive: true)
Future<void> Function() restoreAftermath(Ref ref) =>
    throw UnimplementedError('restoreAftermathProvider must be overridden');

@Riverpod(keepAlive: true)
BackupCoordinator backupCoordinator(Ref ref) =>
    BackupCoordinator(ref.watch(appDatabaseProvider), ref.watch(clockProvider));

@Riverpod(keepAlive: true)
BackupEngine backupEngine(Ref ref) {
  final registry = ref.watch(moduleRegistryProvider);
  return BackupEngine(
    db: ref.watch(appDatabaseProvider),
    sections: [for (final m in registry.all) ?m.backupSection()],
    seederIds: [
      for (final m in registry.all)
        for (final s in m.seeders) s.id,
    ],
    clock: ref.watch(clockProvider),
    appVersion: () async {
      final info = await ref.read(appInfoSourceProvider).load();
      return '${info.version}+${info.buildNumber}';
    },
    documentsDir: ref.watch(backupDocumentsDirProvider),
  );
}

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) => BackupService(
  engine: ref.watch(backupEngineProvider),
  coordinator: ref.watch(backupCoordinatorProvider),
  settings: ref.watch(settingsRepositoryProvider),
  files: ref.watch(localBackupFilesProvider),
  passwords: ref.watch(backupPasswordStoreProvider),
  sharer: ref.watch(fileSharerProvider),
  cacheDir: ref.watch(backupCacheDirProvider),
  nowUtcMs: () => ref.read(clockProvider).now().toUtc().millisecondsSinceEpoch,
  drive: ref.watch(driveBackupStoreProvider),
  device: () => ref.read(deviceIdentityServiceProvider).current(),
);

@Riverpod(keepAlive: true)
RestoreService restoreService(Ref ref) => RestoreService(
  engine: ref.watch(backupEngineProvider),
  coordinator: ref.watch(backupCoordinatorProvider),
  files: ref.watch(localBackupFilesProvider),
  aftermath: ref.watch(restoreAftermathProvider),
);

/// Starts a background backup when the app is hidden (feature 010 R6).
@Riverpod(keepAlive: true)
BackgroundBackupScheduler backgroundBackupScheduler(Ref ref) =>
    BackgroundBackupScheduler(
      settings: ref.watch(settingsRepositoryProvider),
      scheduler: ref.watch(backgroundSchedulerProvider),
      clock: ref.watch(clockProvider),
    );
