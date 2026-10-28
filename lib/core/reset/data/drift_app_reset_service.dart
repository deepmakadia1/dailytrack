import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/utils/date_keys.dart';

/// [AppResetService] over the Drift database (feature 007 data-model §6).
///
/// Step 1 is all-or-nothing: one transaction deletes every row of every
/// table, settings and unlocks included. Rows are deleted rather than the
/// file, so live Drift streams keep working. Steps 2–4 cannot bring any data
/// back, so a failure there is ignored: with the settings rows gone the lock
/// is already off, and the next PIN set overwrites a leftover credential.
final class DriftAppResetService implements AppResetService {
  new({
    required this._db,
    required this._modules,
    required this._read,
    required this._notifications,
    required this._resetLock,
    required this._afterErase,
    this._refreshGlance,
  });

  /// The device preferences every erase keeps (feature 011 clarification
  /// Q1): the restarted app opens Home (or AUTH-01), never Intro.
  static const Set<String> devicePreferenceKeys = {
    SettingsCodec.locale,
    SettingsCodec.currencyCode,
    SettingsCodec.themeMode,
    SettingsCodec.selectedTheme,
    SettingsCodec.enabledModules,
    SettingsCodec.moduleOrder,
    SettingsCodec.onboardingDone,
  };

  /// The settings rows [EraseScope.thisPhoneData] keeps (SET-01, SYS-03 "Forgot
  /// PIN?", ACC-03 "Remove data"; feature 010 FR-006a, feature 011
  /// data-model §3): [devicePreferenceKeys]; the sign-in mode and the
  /// sign-in with its Auto backup settings and the newest known Drive
  /// backup, since erasing removes data from this phone only and never
  /// signs out (SET-01); the install time, so erasing can't reset the 2-day
  /// interstitial rule (feature 009 research R9); the settings copy of the
  /// device ID, which belongs to this install (feature 010 research R4);
  /// and ad consent and the Pro state, so erasing never costs a Pro user
  /// their ad-free state (feature 011 analysis I2).
  static const Set<String> keptByErase = {
    ...devicePreferenceKeys,
    SettingsCodec.authMode,
    SettingsCodec.backupAccountEmail,
    SettingsCodec.accountDisplayName,
    SettingsCodec.accountPhotoUrl,
    SettingsCodec.deviceId,
    SettingsCodec.adsInstallAt,
    SettingsCodec.lastKnownDriveBackupAt,
    SettingsCodec.lastKnownDriveBackupDeviceId,
    SettingsCodec.autoBackupFrequency,
    SettingsCodec.autoBackupWifiOnly,
    SettingsCodec.adConsentStatus,
    SettingsCodec.removeAdsPurchased,
    SettingsCodec.proNotOwnedStreak,
    SettingsCodec.proPurchasePending,
    SettingsCodec.proRemovalPending,
  };

  /// The settings rows [EraseScope.guestLogOut] keeps (ACC-04, feature 011
  /// data-model §3): [devicePreferenceKeys], the device ID, the install
  /// time, ad consent, and the Pro state. The account keys, Auto backup
  /// settings, and the known Drive backup go; `authMode` is written `none`.
  static const Set<String> keptByGuestLogOut = {
    ...devicePreferenceKeys,
    SettingsCodec.deviceId,
    SettingsCodec.adsInstallAt,
    SettingsCodec.adConsentStatus,
    SettingsCodec.removeAdsPurchased,
    SettingsCodec.proNotOwnedStreak,
    SettingsCodec.proPurchasePending,
    SettingsCodec.proRemovalPending,
  };

  /// The settings rows [scope] keeps.
  static Set<String> keptBy(EraseScope scope) => switch (scope) {
    EraseScope.thisPhoneData => keptByErase,
    EraseScope.guestLogOut => keptByGuestLogOut,
  };

  /// The change counters always start again at 0, whatever a scope keeps:
  /// the erased phone counts as unchanged until the user adds data.
  static const Set<String> _alwaysReset = {
    SettingsCodec.dataChangeCounter,
    SettingsCodec.backedUpChangeCounter,
  };

  final AppDatabase _db;

  /// Every registered module, enabled or not.
  final List<TrackerModule> _modules;
  final ProviderReader _read;
  final NotificationService _notifications;

  /// Deletes every `lock.*` secure entry.
  final Future<void> Function() _resetLock;

  /// Resets the lock session and runs startup again (it reseeds the
  /// defaults and lands on Home, or AUTH-01 after a sign-out).
  final void Function() _afterErase;

  /// Redraws the home screen widget, now hidden (feature 008 R19).
  final Future<void> Function()? _refreshGlance;

  @override
  Future<void> eraseAll({EraseScope scope = EraseScope.thisPhoneData}) async {
    final keep = keptBy(scope).difference(_alwaysReset);
    await _db.transaction(() async {
      final kept = await (_db.select(
        _db.settings,
      )..where((t) => t.key.isIn(keep))).get();
      // Foreign keys are checked at commit, when every table is empty.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
      await _db.delete(_db.settings).go();
      for (final row in kept) {
        await _db.into(_db.settings).insert(row);
      }
      if (scope == EraseScope.guestLogOut) {
        // In the same transaction, so a failure leaves the user a guest
        // with everything in place.
        await _db
            .into(_db.settings)
            .insert(
              SettingsCompanion.insert(
                key: SettingsCodec.authMode,
                value: SettingsCodec.encode(AuthMode.none.name),
                updatedAt: Epoch.nowUtcMs(),
              ),
            );
      }
      // The change-counter triggers (feature 010) count the deletes above,
      // and the kept rows when they are restorable settings; with both
      // counters gone they read 0.
      await (_db.delete(
        _db.settings,
      )..where((t) => t.key.isIn(_alwaysReset))).go();
    });

    for (final module in _modules) {
      try {
        await module.onEraseAll(_read);
      } on Object {
        // One module never blocks the others.
      }
    }
    try {
      await _notifications.cancelAll();
    } on Object {
      // Best effort.
    }
    try {
      await _resetLock();
    } on Object {
      // Best effort; see the class comment.
    }
    try {
      await _refreshGlance?.call();
    } on Object {
      // Best effort.
    }
    _afterErase();
  }
}
