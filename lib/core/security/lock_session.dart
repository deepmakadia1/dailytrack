import 'package:dailytrack/core/security/domain/lock_rules.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lock_session.freezed.dart';
part 'lock_session.g.dart';

/// How SYS-03 is shown (feature 007 research R7).
enum LockMode {
  /// The `/lock` route: cold start, or a new navigation while locked.
  route,

  /// Covering the app after a resume, so open screens and unsaved input
  /// survive (clarification Q4).
  overlay,
}

/// In-memory lock session (feature 007 data-model §3).
@freezed
abstract class LockSessionState with _$LockSessionState {
  const factory({
    @Default(false) bool locked,
    @Default(LockMode.route) LockMode mode,

    /// Set when the app leaves the screen; cleared on resume.
    DateTime? backgroundedAt,

    /// The next trip out of the app was started by the app itself.
    @Default(false) bool externalActivity,

    /// A notification target that arrived while locked.
    String? pendingLocation,

    /// The router location the resume overlay covers; the router keeps it
    /// as it is while locked (redirect rule 4).
    String? coveredLocation,
  }) = _LockSessionState;
}

/// Whether the app is locked right now (research R7). Bootstrap starts it
/// from `settings.lockEnabled`; the app's lifecycle listener locks it again
/// after the "Lock after" time.
@Riverpod(keepAlive: true)
class LockSession extends _$LockSession {
  @override
  LockSessionState build() => const LockSessionState();

  /// Cold start, once settings are loaded: locked when the lock is on.
  void start({required bool lockEnabled}) =>
      state = LockSessionState(locked: lockEnabled);

  /// The app left the screen at [now], showing the router [location]. With
  /// "Immediately" the lock comes on right away, so the first frame drawn on
  /// the way back is already SYS-03, never the app's content. (No frames
  /// are drawn while hidden, so the recents preview keeps the last screen;
  /// "Hide app content in recents" blanks it.)
  void markBackgrounded(DateTime now, {String? location}) {
    if (state.backgroundedAt != null) return;
    final settings = ref.read(appSettingsProvider).value;
    final lockNow =
        settings != null &&
        settings.lockEnabled &&
        settings.authMode != AuthMode.none &&
        settings.lockAfterSeconds == 0 &&
        !state.externalActivity &&
        !state.locked;
    state = state.copyWith(
      backgroundedAt: now,
      locked: state.locked || lockNow,
      mode: lockNow ? LockMode.overlay : state.mode,
      coveredLocation: lockNow ? location : state.coveredLocation,
    );
  }

  /// The app is back at [now], on the router [location]: locks when
  /// [shouldLockOnResume] says so.
  void onResumed(DateTime now, {String? location}) {
    final settings = ref.read(appSettingsProvider).value;
    final lock =
        !state.locked &&
        settings != null &&
        shouldLockOnResume(
          // Never on AUTH-01: the lock follows login (feature 011 R7).
          lockEnabled:
              settings.lockEnabled && settings.authMode != AuthMode.none,
          backgroundedAt: state.backgroundedAt,
          now: now,
          lockAfterSeconds: settings.lockAfterSeconds,
          externalActivity: state.externalActivity,
        );
    state = state.copyWith(
      backgroundedAt: null,
      externalActivity: false,
      locked: state.locked || lock,
      mode: lock ? LockMode.overlay : state.mode,
      coveredLocation: lock ? location : state.coveredLocation,
    );
  }

  /// The next trip out of the app is the app's own (camera, share, email)
  /// and does not lock for up to 5 minutes (research R15).
  void expectExternalActivity() =>
      state = state.copyWith(externalActivity: true);

  /// A notification tapped while locked opens after unlocking.
  void deferLocation(String location) =>
      state = state.copyWith(pendingLocation: location);

  /// SYS-03 is showing as the `/lock` route (a navigation while locked).
  void showAsRoute() {
    if (state.mode != LockMode.route) {
      state = state.copyWith(mode: LockMode.route);
    }
  }

  /// Unlocked (correct PIN, biometrics, or a PIN just set). Returns and
  /// clears the deferred location, if any.
  String? unlocked() {
    final pending = state.pendingLocation;
    state = state.copyWith(
      locked: false,
      mode: LockMode.route,
      pendingLocation: null,
      coveredLocation: null,
    );
    return pending;
  }

  /// Erase all data: back to a fresh, unlocked session.
  void reset() => state = const LockSessionState();
}
