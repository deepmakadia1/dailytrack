/// Whether the app lock is on and usable (feature 007 data-model §5).
enum LockStatus {
  /// No app lock.
  disabled,

  /// App lock on, PIN readable.
  enabled,

  /// App lock on, but the stored PIN is missing or unreadable (e.g. secure
  /// storage was wiped). Only "Forgot PIN?" can help (research R6).
  credentialUnavailable,
}

/// The outcome of a PIN check (SYS-03, SYS-04).
sealed class UnlockResult {
  const new();
}

final class UnlockSuccess extends UnlockResult {
  const new();
}

/// A wrong PIN that did not start a lockout.
final class UnlockWrong extends UnlockResult {
  const new({this.attemptsLeft, this.nextLockout});

  /// Wrong PINs left before the first lockout, from the 3rd failure.
  final int? attemptsLeft;

  /// After a lockout has ended: how long the next wrong PIN locks for.
  final Duration? nextLockout;
}

/// Input is blocked; nothing was checked.
final class UnlockLockedOut extends UnlockResult {
  const new(this.remaining);

  final Duration remaining;
}

/// The stored PIN cannot be read ([LockStatus.credentialUnavailable]).
final class UnlockUnavailable extends UnlockResult {
  const new();
}

/// Whether fingerprint or face unlock can be used (research R18).
enum BiometricAvailability {
  /// No biometric hardware.
  none,

  /// Hardware present, nothing enrolled.
  notEnrolled,
  available,
}

/// SET-05 "Lock after" (data-model §5).
enum LockAfter {
  immediately(0),
  oneMinute(60),
  fiveMinutes(300);

  new(this.seconds);

  final int seconds;

  static LockAfter fromSeconds(int seconds) =>
      values.firstWhere((v) => v.seconds == seconds, orElse: () => oneMinute);
}
