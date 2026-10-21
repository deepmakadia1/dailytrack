import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.freezed.dart';
part 'settings_controller.g.dart';

/// What SET-01 shows (feature 007 contracts/screens.md "SET-01").
@freezed
abstract class SettingsViewData with _$SettingsViewData {
  const factory({
    required AppSettings settings,

    /// Enabled module ids in the user's order; the Habit reminders row is
    /// shown only when `habit` is here (clarification Q2).
    required List<String> visibleModuleIds,

    /// Dev flavor only: shows the Developer section (FR-013).
    required bool devTools,
  }) = _SettingsViewData;
}

/// SET-01 controller. Follows the settings stream, so every row shows the
/// stored value right after a write.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsViewData> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    return SettingsViewData(
      settings: settings,
      visibleModuleIds: [
        for (final m in ref.read(moduleRegistryProvider).visible(settings))
          m.id,
      ],
      devTools: ref.watch(debugToolsAvailableProvider),
    );
  }

  /// Error state "Try again": reads settings again.
  void retry() => ref.invalidate(appSettingsProvider);

  // --- General ---

  /// Null follows the device language.
  Future<void> setLocale(String? code) =>
      ref.read(settingsRepositoryProvider).setLocale(code);

  /// Formatting only; stored amounts are never converted (FR-003).
  Future<void> setCurrency(String code) =>
      ref.read(settingsRepositoryProvider).setCurrency(code);

  Future<void> setFirstDayOfWeek(int day) =>
      ref.read(settingsRepositoryProvider).setFirstDayOfWeek(day);

  Future<void> setDateFormat(String format) =>
      ref.read(settingsRepositoryProvider).setDateFormat(format);

  // --- Notifications (research R17) ---

  Future<void> setNotificationsEnabled({required bool enabled}) => _notify(
    () => ref
        .read(settingsRepositoryProvider)
        .setNotificationsEnabled(enabled: enabled),
  );

  Future<void> setBudgetAlertsEnabled({required bool enabled}) => _notify(
    () => ref
        .read(settingsRepositoryProvider)
        .setBudgetAlertsEnabled(enabled: enabled),
  );

  Future<void> setHabitRemindersEnabled({required bool enabled}) => _notify(
    () => ref
        .read(settingsRepositoryProvider)
        .setHabitRemindersEnabled(enabled: enabled),
  );

  /// Stored only; the daily summary reminder itself arrives in T3.4.
  Future<void> setDailySummaryTime({required int hour, required int minute}) =>
      ref
          .read(settingsRepositoryProvider)
          .setDailySummaryTime(
            '${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')}',
          );

  /// Writes, then lets every enabled module reconcile its notifications
  /// with the new settings (cancel when off, reschedule when on).
  Future<void> _notify(Future<void> Function() write) async {
    await write();
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.load();
    for (final module in ref.read(moduleRegistryProvider).visible(settings)) {
      try {
        await module.onNotificationSettingsChanged(ref.read);
      } on Object {
        // Best effort; one module never blocks the others.
      }
    }
  }

  // --- Developer ---

  Future<void> setDebugUnlockAll({required bool enabled}) =>
      ref.read(settingsRepositoryProvider).setDebugUnlockAll(enabled: enabled);
}

/// The installed version for the About section. Kept for the session.
@Riverpod(keepAlive: true)
Future<AppInfo> appInfo(Ref ref) => ref.watch(appInfoSourceProvider).load();

/// Whether the OS lets the app notify (SET-01 "Notifications are blocked").
/// The screen refreshes it on resume, after a trip to system settings.
@riverpod
Future<bool> notificationsAllowed(Ref ref) =>
    ref.watch(notificationServiceProvider).canNotify();
