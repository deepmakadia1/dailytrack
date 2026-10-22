import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'security_controller.freezed.dart';
part 'security_controller.g.dart';

/// What SET-05 shows (feature 007 contracts/screens.md "SET-05").
@freezed
abstract class SecurityState with _$SecurityState {
  const factory({
    required bool lockOn,
    required BiometricAvailability biometric,
    required bool biometricEnabled,
    required int lockAfterSeconds,
    required bool hideInRecents,

    /// "Show data on widget" (feature 008 FR-047).
    @Default(false) bool showDataOnWidget,
  }) = _SecurityState;
}

/// SET-05 Security controller (FR-022 – FR-027). The lock itself is turned
/// on and off through SYS-04, which owns the PIN.
@riverpod
class SecurityController extends _$SecurityController {
  @override
  Future<SecurityState> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    final lock = ref.read(lockServiceProvider);
    return SecurityState(
      lockOn: settings.lockEnabled,
      biometric: await lock.biometricAvailability(),
      biometricEnabled: settings.biometricEnabled,
      lockAfterSeconds: settings.lockAfterSeconds,
      hideInRecents: settings.hideInRecents,
      showDataOnWidget: settings.showDataOnWidget,
    );
  }

  /// Error state "Try again".
  void retry() => ref.invalidateSelf();

  /// Turning on needs a successful prompt (FR-026); a cancel leaves it off.
  Future<void> setBiometric({required bool enabled, required String reason}) =>
      ref
          .read(lockServiceProvider)
          .setBiometricEnabled(enabled: enabled, reason: reason);

  Future<void> setLockAfter(int seconds) =>
      ref.read(settingsRepositoryProvider).setLockAfterSeconds(seconds);

  Future<void> setHideInRecents({required bool enabled}) =>
      ref.read(settingsRepositoryProvider).setHideInRecents(enabled: enabled);

  /// The widget follows within a second through the glance refresher
  /// (feature 008 R19).
  Future<void> setShowDataOnWidget({required bool enabled}) => ref
      .read(settingsRepositoryProvider)
      .setShowDataOnWidget(enabled: enabled);
}
