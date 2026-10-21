import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/security/domain/biometric_authenticator.dart';
import 'package:dailytrack/core/security/domain/lock_service.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/domain/lockout_policy.dart';
import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:dailytrack/core/security/domain/secure_key_value_store.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';

/// [LockService] over secure storage, PBKDF2 hashing, the biometric
/// prompt, and [LockoutPolicy] (feature 007 research R3 – R6, R18).
final class SecureLockService implements LockService {
  new({
    required this._store,
    required this._biometrics,
    required this._settings,
    required this._clock,
    PinHasher? hasher,
  }) : _hasher = hasher ?? PinHasher();

  static const String keyPrefix = 'lock.';
  static const String pinKey = 'lock.pin';
  static const String lockoutKey = 'lock.lockout';

  static final RegExp _pinFormat = RegExp(r'^[0-9]{4}$');

  final SecureKeyValueStore _store;
  final BiometricAuthenticator _biometrics;
  final SettingsRepository _settings;
  final Clock _clock;
  final PinHasher _hasher;

  DateTime get _now => _clock.now().toUtc();

  /// The stored credential, or null when missing or unreadable.
  Future<PinRecord?> _record() async {
    try {
      final raw = await _store.read(pinKey);
      if (raw == null) return null;
      final json = jsonDecode(raw);
      if (json is! Map<String, Object?>) return null;
      return PinRecord.fromJson(json);
    } on Object {
      return null;
    }
  }

  /// The lockout state; a read error with a PIN set fails safe (locked for
  /// the maximum), corrupt data counts as no failures.
  Future<LockoutState> _lockout() async {
    try {
      final raw = await _store.read(lockoutKey);
      if (raw == null) return LockoutState.initial;
      final state = LockoutState.tryParse(raw) ?? LockoutState.initial;
      final anchored = LockoutPolicy.reanchor(state, _now);
      if (anchored != state) await _saveLockout(anchored);
      return anchored;
    } on Object {
      return LockoutState.failSafe(_now);
    }
  }

  Future<void> _saveLockout(LockoutState state) async {
    try {
      if (state == LockoutState.initial) {
        await _store.delete(lockoutKey);
      } else {
        await _store.write(lockoutKey, state.encode());
      }
    } on Object {
      // Best effort: an unwritable store fails safe on the next read.
    }
  }

  @override
  Future<LockStatus> status() async {
    final settings = await _settings.load();
    if (!settings.lockEnabled) return LockStatus.disabled;
    return await _record() == null
        ? LockStatus.credentialUnavailable
        : LockStatus.enabled;
  }

  @override
  Future<void> setPin(String pin) async {
    if (!_pinFormat.hasMatch(pin)) {
      throw ArgumentError.value('****', 'pin', 'must be 4 digits');
    }
    final record = await _hasher.hash(pin);
    // Credential first, then the switch (research R6).
    await _store.write(pinKey, jsonEncode(record.toJson()));
    await _saveLockout(LockoutState.initial);
    await _settings.setLockEnabled(enabled: true);
  }

  @override
  Future<UnlockResult> verifyPin(String pin) async {
    final state = await _lockout();
    final remaining = LockoutPolicy.remaining(state, _now);
    if (remaining > Duration.zero) return UnlockLockedOut(remaining);

    final record = await _record();
    if (record == null) return const UnlockUnavailable();

    if (await _hasher.verify(pin, record)) {
      await _saveLockout(LockoutPolicy.registerSuccess());
      return const UnlockSuccess();
    }
    final next = LockoutPolicy.registerFailure(state, _now);
    // Stored before returning, so killing the app still counts the guess.
    await _saveLockout(next);
    final locked = LockoutPolicy.remaining(next, _now);
    if (locked > Duration.zero) return UnlockLockedOut(locked);
    return UnlockWrong(
      attemptsLeft: LockoutPolicy.attemptsLeftBeforeLockout(next),
      nextLockout: LockoutPolicy.nextLockoutLength(next, _now),
    );
  }

  @override
  Future<UnlockResult> changePin({
    required String current,
    required String newPin,
  }) async {
    final result = await verifyPin(current);
    if (result is UnlockSuccess) await setPin(newPin);
    return result;
  }

  @override
  Future<UnlockResult> disable(String current) async {
    final result = await verifyPin(current);
    if (result is UnlockSuccess) {
      // The switch first, then the credential (research R6).
      await _settings.setLockEnabled(enabled: false);
      await _settings.setBiometricEnabled(enabled: false);
      await reset();
    }
    return result;
  }

  @override
  Future<bool> unlockWithBiometrics({required String reason}) async {
    if (await status() != LockStatus.enabled) return false;
    if (await _biometrics.availability() != BiometricAvailability.available) {
      return false;
    }
    if (!await _biometrics.authenticate(reason)) return false;
    await _saveLockout(LockoutPolicy.registerSuccess());
    return true;
  }

  @override
  Future<bool> setBiometricEnabled({
    required bool enabled,
    required String reason,
  }) async {
    if (!enabled) {
      await _settings.setBiometricEnabled(enabled: false);
      return true;
    }
    if (await _biometrics.availability() != BiometricAvailability.available ||
        !await _biometrics.authenticate(reason)) {
      return false;
    }
    await _settings.setBiometricEnabled(enabled: true);
    return true;
  }

  @override
  Future<BiometricAvailability> biometricAvailability() =>
      _biometrics.availability();

  @override
  Future<Duration> lockoutRemaining() async =>
      LockoutPolicy.remaining(await _lockout(), _now);

  @override
  Future<Duration?> nextLockoutLength() async =>
      LockoutPolicy.nextLockoutLength(await _lockout(), _now);

  @override
  Future<void> reset() => _store.deleteWhere((k) => k.startsWith(keyPrefix));
}
