import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';

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

  final AppDatabase _db;

  /// Every registered module, enabled or not.
  final List<TrackerModule> _modules;
  final ProviderReader _read;
  final NotificationService _notifications;

  /// Deletes every `lock.*` secure entry.
  final Future<void> Function() _resetLock;

  /// Resets the lock session and runs startup again (it reseeds the
  /// defaults and lands on onboarding).
  final void Function() _afterErase;

  /// Redraws the home screen widget, now hidden (feature 008 R19).
  final Future<void> Function()? _refreshGlance;

  @override
  Future<void> eraseAll() async {
    await _db.transaction(() async {
      // The install time survives, so erasing can't reset the 2-day
      // interstitial rule (feature 009 research R9); so does the settings
      // copy of the device ID, which belongs to this install (feature 010
      // research R4).
      final kept =
          await (_db.select(_db.settings)..where(
                (t) => t.key.isIn([
                  SettingsCodec.adsInstallAt,
                  SettingsCodec.deviceId,
                ]),
              ))
              .get();
      // Foreign keys are checked at commit, when every table is empty.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
      // The change-counter triggers (feature 010) count the deletes above
      // into a new settings row; the erased phone starts at 0.
      await _db.delete(_db.settings).go();
      for (final row in kept) {
        await _db.into(_db.settings).insert(row);
      }
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
