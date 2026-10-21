import 'dart:async';

import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unlock_controller.freezed.dart';
part 'unlock_controller.g.dart';

/// Why the SYS-03 dots shook.
enum UnlockError { none, wrong }

/// SYS-03 state (feature 007 contracts/screens.md "SYS-03"). Only the
/// number of digits entered is kept, never the digits.
@freezed
abstract class UnlockState with _$UnlockState {
  const factory({
    /// Null while loading.
    LockStatus? status,
    @Default(0) int entered,
    @Default(UnlockError.none) UnlockError error,
    int? attemptsLeft,

    /// After a lockout has ended: what the next wrong PIN locks for.
    Duration? nextLockout,
    @Default(Duration.zero) Duration lockoutRemaining,
    @Default(0) int shakeCount,
    @Default(false) bool busy,

    /// Biometric unlock is on and usable: the key shows and the prompt
    /// opens on its own once.
    @Default(false) bool biometricReady,

    /// Set on success; the screen leaves with it.
    @Default(false) bool unlocked,
  }) = _UnlockState;
}

/// SYS-03 Unlock controller (FR-028 – FR-034, clarifications Q1, Q3).
@riverpod
class UnlockController extends _$UnlockController {
  String _entry = '';
  Timer? _ticker;

  static const int _length = 4;

  @override
  UnlockState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _entry = '';
    });
    unawaited(_load());
    return const UnlockState();
  }

  Future<void> _load() async {
    final lock = ref.read(lockServiceProvider);
    final status = await lock.status();
    final settings = await ref.read(settingsRepositoryProvider).load();
    final biometricReady =
        status == LockStatus.enabled &&
        settings.biometricEnabled &&
        await lock.biometricAvailability() == BiometricAvailability.available;
    final remaining = await lock.lockoutRemaining();
    final next = await lock.nextLockoutLength();
    if (!ref.mounted) return;
    state = state.copyWith(
      status: status,
      biometricReady: biometricReady,
      nextLockout: next,
    );
    if (remaining > Duration.zero) _startLockout(remaining);
  }

  bool get _blocked =>
      state.busy ||
      state.status != LockStatus.enabled ||
      state.lockoutRemaining > Duration.zero;

  void digit(String d) {
    if (_blocked || _entry.length >= _length) return;
    _entry += d;
    state = state.copyWith(entered: _entry.length);
    if (_entry.length == _length) unawaited(_verify());
  }

  void backspace() {
    if (_blocked || _entry.isEmpty) return;
    _entry = _entry.substring(0, _entry.length - 1);
    state = state.copyWith(entered: _entry.length);
  }

  /// Backgrounding or rotating clears a half-typed PIN.
  void clearEntry() {
    _entry = '';
    if (ref.mounted) state = state.copyWith(entered: 0);
  }

  Future<void> _verify() async {
    final entry = _entry;
    _entry = '';
    state = state.copyWith(busy: true);
    final result = await ref.read(lockServiceProvider).verifyPin(entry);
    if (!ref.mounted) return;
    switch (result) {
      case UnlockSuccess():
        state = state.copyWith(busy: false, unlocked: true);
      case UnlockWrong(:final attemptsLeft, :final nextLockout):
        _shake(attemptsLeft: attemptsLeft, nextLockout: nextLockout);
      case UnlockLockedOut(:final remaining):
        _shake();
        _startLockout(remaining);
      case UnlockUnavailable():
        state = state.copyWith(
          busy: false,
          entered: 0,
          status: LockStatus.credentialUnavailable,
        );
    }
  }

  /// The system prompt; works during a lockout too (Q3).
  Future<void> biometric(String reason) async {
    if (!state.biometricReady || state.busy) return;
    final ok = await ref
        .read(lockServiceProvider)
        .unlockWithBiometrics(reason: reason);
    if (!ref.mounted || !ok) return;
    _ticker?.cancel();
    state = state.copyWith(unlocked: true, lockoutRemaining: Duration.zero);
  }

  void _shake({int? attemptsLeft, Duration? nextLockout}) {
    state = state.copyWith(
      busy: false,
      entered: 0,
      error: UnlockError.wrong,
      attemptsLeft: attemptsLeft,
      nextLockout: nextLockout,
      shakeCount: state.shakeCount + 1,
    );
  }

  /// Blocks the keypad with a countdown (FR-031); when it ends, shows how
  /// long the next wrong PIN would lock for (US2-1).
  void _startLockout(Duration remaining) {
    state = state.copyWith(lockoutRemaining: remaining, nextLockout: null);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final lock = ref.read(lockServiceProvider);
      final left = await lock.lockoutRemaining();
      if (!ref.mounted) return;
      if (left > Duration.zero) {
        state = state.copyWith(lockoutRemaining: left);
        return;
      }
      _ticker?.cancel();
      final next = await lock.nextLockoutLength();
      if (!ref.mounted) return;
      state = state.copyWith(
        lockoutRemaining: Duration.zero,
        error: UnlockError.none,
        nextLockout: next,
      );
    });
  }
}
