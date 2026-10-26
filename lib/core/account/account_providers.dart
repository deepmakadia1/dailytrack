import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/account/account_service.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/account_ui.dart';
import 'package:dailytrack/core/account/data/no_backup_device_id_store.dart';
import 'package:dailytrack/core/account/device_identity_service.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/account_auth.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'account_providers.g.dart';

/// Google sign-in (feature 010 research R1). `production_overrides.dart`
/// binds `GoogleAuth`; tests bind `FakeAccountAuth`.
@Riverpod(keepAlive: true)
AccountAuth accountAuth(Ref ref) =>
    throw UnimplementedError('accountAuthProvider must be overridden');

@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) => AccountService(
  auth: ref.watch(accountAuthProvider),
  settings: ref.watch(settingsRepositoryProvider),
  scheduler: ref.watch(backgroundSchedulerProvider),
);

/// The signed-in account, for ACC-01 and SET-02.
@Riverpod(keepAlive: true)
Stream<AccountState> accountState(Ref ref) =>
    ref.watch(accountServiceProvider).watch();

/// The no-backup device ID file. Tests override it with a fake.
@Riverpod(keepAlive: true)
DeviceIdFile deviceIdFile(Ref ref) => const ChannelDeviceIdFile();

@Riverpod(keepAlive: true)
DeviceIdentityService deviceIdentityService(Ref ref) => DeviceIdentityService(
  file: ref.watch(deviceIdFileProvider),
  settings: ref.watch(settingsRepositoryProvider),
  info: ref.watch(deviceInfoSourceProvider),
  newId: const Uuid().v4,
);

/// The one Drive restore path (research R12). Widget tests override it
/// with a fake.
@Riverpod(keepAlive: true)
AccountRestore accountRestore(Ref ref) => AccountRestore(
  drive: ref.watch(driveBackupStoreProvider),
  restore: ref.watch(restoreServiceProvider),
  engine: ref.watch(backupEngineProvider),
  backup: ref.watch(backupServiceProvider),
  safety: ref.watch(safetyCopyStoreProvider),
  passwords: ref.watch(backupPasswordStoreProvider),
  settings: ref.watch(settingsRepositoryProvider),
  clock: ref.watch(clockProvider),
);

/// ACC-02 for other features (research R18). Bound in
/// `production_overrides.dart` to the account feature.
@Riverpod(keepAlive: true)
AccountUi accountUi(Ref ref) =>
    throw UnimplementedError('accountUiProvider must be overridden');

/// The shared "Sign in with Google" for ACC-01 and SET-02.
@Riverpod(keepAlive: true)
AccountSignIn accountSignIn(Ref ref) => AccountSignIn(
  account: ref.watch(accountServiceProvider),
  drive: ref.watch(driveBackupStoreProvider),
  backup: ref.watch(backupServiceProvider),
);
