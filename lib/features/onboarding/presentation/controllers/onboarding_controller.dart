import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Moved to core for SET-01 (feature 007 T052); re-exported for callers.
export 'package:dailytrack/core/utils/currencies.dart' show filterCurrencies;

part 'onboarding_controller.g.dart';

const String atLeastOneModuleKey = 'onboarding_atLeastOneModule';
const String saveErrorKey = 'onboarding_saveError';

/// SYS-02 Onboarding controller (T066). Depends only on domain interfaces
/// and providers.
@riverpod
class OnboardingController extends _$OnboardingController {
  /// Which save to repeat on "Retry": skip with defaults, or complete.
  bool _lastSaveWasSkip = false;

  @override
  OnboardingState build() {
    // Read once, never watch: choosing a language writes settings, and the
    // user's progress must survive that (spec edge case).
    final settings = ref.read(appSettingsProvider).value ?? const AppSettings();
    return OnboardingState(
      languageCode: settings.locale,
      currencyCode: settings.currencyCode,
      moduleOrder: settings.moduleOrder,
      enabledModules: settings.enabledModules,
    );
  }

  void next() {
    if (state.step < OnboardingState.stepCount) {
      state = state.copyWith(step: state.step + 1, moduleMessageKey: null);
    }
  }

  void back() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1, moduleMessageKey: null);
    }
  }

  /// Applies the new language right away so the UI switches instantly.
  Future<void> selectLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await ref.read(settingsRepositoryProvider).setLocale(code);
  }

  void selectCurrency(String code) =>
      state = state.copyWith(currencyCode: code);

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Turns a module on or off. Refuses to turn off the last enabled one.
  void toggleModule(String id) {
    final enabled = [...state.enabledModules];
    if (enabled.contains(id)) {
      if (enabled.length == 1) {
        state = state.copyWith(moduleMessageKey: atLeastOneModuleKey);
        return;
      }
      enabled.remove(id);
    } else {
      enabled.add(id);
    }
    state = state.copyWith(enabledModules: enabled, moduleMessageKey: null);
  }

  /// Asks for notification permission. Denial or a plugin failure is a
  /// normal result and never blocks onboarding.
  Future<void> requestNotifications() async {
    final permission = ref.read(notificationPermissionProvider);
    bool granted;
    try {
      granted = await permission.request();
    } on Object {
      granted = false;
    }
    state = state.copyWith(notificationsGranted: granted);
  }

  /// "Skip" on steps 1–2: device language, INR, every module on.
  Future<void> skip() async {
    if (!state.canSkip) return;
    _lastSaveWasSkip = true;
    final ids = ref.read(moduleRegistryProvider).ids;
    await _save(
      OnboardingChoices(
        locale: null,
        currencyCode: 'INR',
        moduleOrder: ids,
        enabledModules: ids,
      ),
    );
  }

  /// "Get started" on step 4.
  Future<void> complete() async {
    _lastSaveWasSkip = false;
    await _save(
      OnboardingChoices(
        locale: state.languageCode,
        currencyCode: state.currencyCode,
        moduleOrder: state.moduleOrder,
        enabledModules: state.enabledModules,
      ),
    );
  }

  /// Signed in during onboarding to an account without a backup: the new
  /// data is backed up once onboarding is done (spec US1 scenario 4). In
  /// pause mode, since there's no screen to ask on; a newer backup from
  /// another phone pauses auto backup and shows in ACC-01.
  void _backUpIfSignedIn() {
    final signedIn = ref.read(appSettingsProvider).value?.backupAccountEmail;
    if (signedIn == null) return;
    // Read now: the router leaves onboarding, and disposes this
    // controller, as soon as the save lands.
    final backups = ref.read(backupServiceProvider);
    unawaited(
      backups
          .backupToDrive(kind: BackupKind.manual, conflict: ConflictMode.pause)
          .then((_) {}, onError: (Object _) {}),
    );
  }

  /// SYS-02 "Restore with Google" (spec §2, §16): sign in; with a backup,
  /// restore the newest one without asking (the phone has no data yet),
  /// behind the full-screen progress view. [askPassword] asks for an
  /// encrypted backup's password (`wrong` after a failed one; null =
  /// cancelled). On success the restored settings mark onboarding done and
  /// the router leaves for Home; Restore purchase runs behind it and calls
  /// [onProRestored] when Pro is found (FR-029). Nothing is written when it
  /// fails or is cancelled.
  Future<void> restoreWithGoogle({
    required Future<String?> Function({required bool wrong}) askPassword,
    required void Function() onProRestored,
  }) async {
    if (state.saving ||
        state.googleRestore == GoogleRestoreStatus.signingIn ||
        state.googleRestore == GoogleRestoreStatus.restoring) {
      return;
    }
    final account = ref.read(accountServiceProvider);
    final drive = ref.read(driveBackupStoreProvider);
    final restore = ref.read(accountRestoreProvider);
    final pro = ref.read(proServiceProvider);
    void set(GoogleRestoreStatus status, [Object? error]) {
      if (ref.mounted) {
        state = state.copyWith(
          googleRestore: status,
          googleRestoreError: error,
        );
      }
    }

    set(GoogleRestoreStatus.signingIn);
    try {
      if (await account.signIn() == null) {
        set(GoogleRestoreStatus.idle);
        return;
      }
      final backups = await account.guardAuth(drive.list);
      if (backups.isEmpty) {
        set(GoogleRestoreStatus.noBackup);
        return;
      }
      final newest = backups.first;
      set(GoogleRestoreStatus.restoring);
      final bytes = await account.guardAuth(() => restore.download(newest));
      OpenedBackup? opened;
      String? password;
      var wrong = false;
      while (opened == null) {
        try {
          opened = await restore.open(bytes, password: password);
        } on BackupNeedsPassword {
          wrong = false;
        } on BackupWrongPassword {
          wrong = true;
        }
        if (opened != null) break;
        // Step 1 shows under the password sheet; nothing spins while the
        // user types.
        set(GoogleRestoreStatus.idle);
        password = await askPassword(wrong: wrong);
        if (password == null) return;
        set(GoogleRestoreStatus.restoring);
      }
      final result = await restore.apply(
        opened,
        entry: newest,
        fromEmptyPhone: true,
      );
      if (result is SafetyCopyFailed) throw const BackupStorageFull();
      unawaited(
        pro.restore().then((r) {
          if (r == RestoreResult.restored) onProRestored();
        }),
      );
    } on Object catch (e) {
      set(GoogleRestoreStatus.failed, e);
    }
  }

  /// Repeats the save that failed.
  Future<void> retrySave() => _lastSaveWasSkip ? skip() : complete();

  Future<void> _save(OnboardingChoices choices) async {
    if (state.saving) return;
    state = state.copyWith(saving: true, saveErrorKey: null);
    try {
      await ref.read(settingsRepositoryProvider).completeOnboarding(choices);
      _backUpIfSignedIn();
      // The router leaves /onboarding once settings report it done.
      if (ref.mounted) state = state.copyWith(saving: false);
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(saving: false, saveErrorKey: saveErrorKey);
      }
    }
  }
}
