import 'package:dailytrack/core/security/domain/lock_types.dart';

/// The app lock (SYS-03, SYS-04, SET-05; feature 007 contracts/services.md).
/// The PIN lives only as a salted hash in secure storage; `lockEnabled` and
/// `biometricEnabled` in settings say whether the lock is on. Every failure
/// comes back as a result value; nothing throws into widgets except
/// [setPin]'s precondition.
abstract interface class LockService {
  /// Combines `settings.lockEnabled` with the stored credential.
  Future<LockStatus> status();

  /// Hashes [pin] (exactly 4 digits, else [ArgumentError]) off the UI
  /// thread, stores it, clears the lockout, then turns the lock on. The
  /// credential is written first, so a crash never leaves the lock on
  /// without a PIN.
  Future<void> setPin(String pin);

  /// Checks the lockout first and never hashes while locked out. The new
  /// lockout state is stored before this returns, so killing the app right
  /// after a wrong guess still counts it.
  Future<UnlockResult> verifyPin(String pin);

  /// Verifies [current] (counting toward the same lockout), then stores
  /// [newPin]. Returns the verification result.
  Future<UnlockResult> changePin({
    required String current,
    required String newPin,
  });

  /// Verifies [current], then turns the lock and biometrics off and deletes
  /// every `lock.*` entry. Returns the verification result.
  Future<UnlockResult> disable(String current);

  /// The system biometric prompt. A success clears the lockout (allowed
  /// during one, clarification Q3). Never offered without a readable PIN.
  Future<bool> unlockWithBiometrics({required String reason});

  /// Turning on needs a successful prompt first (FR-026); turning off
  /// always succeeds. Returns whether the setting now matches [enabled].
  Future<bool> setBiometricEnabled({
    required bool enabled,
    required String reason,
  });

  Future<BiometricAvailability> biometricAvailability();

  /// Time left in the current lockout, or [Duration.zero].
  Future<Duration> lockoutRemaining();

  /// After a lockout has ended, how long the next wrong PIN locks for;
  /// null otherwise.
  Future<Duration?> nextLockoutLength();

  /// Deletes every `lock.*` entry (erase all data).
  Future<void> reset();
}
