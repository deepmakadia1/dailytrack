import 'dart:async';

import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/features/lock/presentation/pin_flow_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pin_controller.freezed.dart';
part 'pin_controller.g.dart';

/// SYS-04 steps (feature 007 data-model §5).
enum PinFlowStep { current, enterNew, confirmNew, offerBiometric, done }

/// Why the dots shook.
enum PinError { none, wrong, mismatch, saveFailed }

/// What SYS-04 achieved, for the snackbar on the way out.
enum PinOutcome { lockOn, pinChanged, lockOff }

/// SYS-04 state. Only the number of digits is kept here; the digits and
/// the first entry stay private in the controller (never in state or
/// semantics).
@freezed
abstract class PinState with _$PinState {
  const factory({
    required PinFlowStep step,
    @Default(0) int entered,
    @Default(PinError.none) PinError error,
    int? attemptsLeft,

    /// Shakes the dots each time it changes.
    @Default(0) int shakeCount,
    @Default(Duration.zero) Duration lockoutRemaining,
    @Default(false) bool busy,

    /// Offered after a first-time set when the phone supports it.
    @Default(false) bool biometricOn,

    /// Set once the flow is finished; the screen pops with it.
    PinOutcome? outcome,
  }) = _PinState;
}

/// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
/// "SYS-04").
@riverpod
class PinController extends _$PinController {
  String _entry = '';
  String? _current;
  String? _firstEntry;
  Timer? _ticker;

  static const int _length = 4;

  @override
  PinState build(PinFlowMode mode) {
    ref.onDispose(() {
      _ticker?.cancel();
      // Never keep a PIN once the screen is gone (FR-041).
      _entry = '';
      _current = null;
      _firstEntry = null;
    });
    if (mode != PinFlowMode.set) unawaited(_checkLockout());
    return PinState(
      step: mode == PinFlowMode.set
          ? PinFlowStep.enterNew
          : PinFlowStep.current,
    );
  }

  bool get _blocked => state.busy || state.lockoutRemaining > Duration.zero;

  void digit(String d) {
    if (_blocked || _entry.length >= _length) return;
    _entry += d;
    state = state.copyWith(entered: _entry.length, error: PinError.none);
    if (_entry.length == _length) unawaited(_submit());
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

  Future<void> _submit() async {
    final entry = _entry;
    _entry = '';
    switch (state.step) {
      case PinFlowStep.current:
        await _checkCurrent(entry);
      case PinFlowStep.enterNew:
        _firstEntry = entry;
        state = state.copyWith(step: PinFlowStep.confirmNew, entered: 0);
      case PinFlowStep.confirmNew:
        await _confirm(entry);
      case PinFlowStep.offerBiometric || PinFlowStep.done:
        break;
    }
  }

  Future<void> _checkCurrent(String entry) async {
    state = state.copyWith(busy: true);
    final lock = ref.read(lockServiceProvider);
    final result = mode == PinFlowMode.disable
        ? await lock.disable(entry)
        : await lock.verifyPin(entry);
    if (!ref.mounted) return;
    switch (result) {
      case UnlockSuccess():
        if (mode == PinFlowMode.disable) {
          ref.read(lockSessionProvider.notifier).unlocked();
          state = state.copyWith(
            busy: false,
            step: PinFlowStep.done,
            outcome: PinOutcome.lockOff,
          );
        } else {
          _current = entry;
          state = state.copyWith(
            busy: false,
            step: PinFlowStep.enterNew,
            entered: 0,
          );
        }
      case UnlockWrong(:final attemptsLeft):
        _shake(PinError.wrong, attemptsLeft: attemptsLeft);
      case UnlockLockedOut(:final remaining):
        _shake(PinError.wrong);
        _startLockout(remaining);
      case UnlockUnavailable():
        _shake(PinError.saveFailed);
    }
  }

  Future<void> _confirm(String entry) async {
    final first = _firstEntry;
    if (first == null || entry != first) {
      // Mismatch: shake and restart the confirm step (FR-038).
      _shake(PinError.mismatch);
      return;
    }
    state = state.copyWith(busy: true);
    final lock = ref.read(lockServiceProvider);
    try {
      if (mode == PinFlowMode.change) {
        final r = await lock.changePin(current: _current ?? '', newPin: first);
        if (r is! UnlockSuccess) throw StateError('current PIN rejected');
      } else {
        await lock.setPin(first);
      }
    } on Object {
      if (ref.mounted) _shake(PinError.saveFailed);
      return;
    }
    _firstEntry = null;
    _current = null;
    if (!ref.mounted) return;
    // A PIN the user just chose never asks for itself right away (FR-046).
    ref.read(lockSessionProvider.notifier).unlocked();
    if (mode == PinFlowMode.set &&
        await lock.biometricAvailability() == BiometricAvailability.available) {
      if (!ref.mounted) return;
      state = state.copyWith(
        busy: false,
        step: PinFlowStep.offerBiometric,
        entered: 0,
      );
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      busy: false,
      step: PinFlowStep.done,
      outcome: mode == PinFlowMode.change
          ? PinOutcome.pinChanged
          : PinOutcome.lockOn,
    );
  }

  /// The "Use fingerprint / face unlock" switch after a first-time set.
  Future<void> setBiometric({
    required bool enabled,
    required String reason,
  }) async {
    final ok = await ref
        .read(lockServiceProvider)
        .setBiometricEnabled(enabled: enabled, reason: reason);
    if (!ref.mounted) return;
    state = state.copyWith(biometricOn: ok ? enabled : state.biometricOn);
  }

  /// "Done" on the biometric offer.
  void finish() => state = state.copyWith(
    step: PinFlowStep.done,
    outcome: PinOutcome.lockOn,
  );

  void _shake(PinError error, {int? attemptsLeft}) {
    _entry = '';
    state = state.copyWith(
      busy: false,
      entered: 0,
      error: error,
      attemptsLeft: attemptsLeft,
      shakeCount: state.shakeCount + 1,
    );
  }

  Future<void> _checkLockout() async {
    final remaining = await ref.read(lockServiceProvider).lockoutRemaining();
    if (ref.mounted && remaining > Duration.zero) _startLockout(remaining);
  }

  /// Blocks input and counts down once a second (spec edge case: the same
  /// lockout as SYS-03).
  void _startLockout(Duration remaining) {
    state = state.copyWith(lockoutRemaining: remaining);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final left = await ref.read(lockServiceProvider).lockoutRemaining();
      if (!ref.mounted) return;
      state = state.copyWith(lockoutRemaining: left);
      if (left == Duration.zero) _ticker?.cancel();
    });
  }
}
