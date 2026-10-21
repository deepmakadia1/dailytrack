import 'dart:convert';

import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// Wrong-PIN state, persisted as `lock.lockout` so it survives restarts
/// (feature 007 data-model §2). Times are UTC epoch milliseconds.
@immutable
final class LockoutState {
  const new({
    this.failedAttempts = 0,
    this.level = 0,
    this.lockedAtUtcMs,
    this.lockedUntilUtcMs,
  });

  /// Thrown away JSON or a storage read error with a PIN set: lock for the
  /// maximum from [now], so a broken store never lets guesses through.
  factory failSafe(DateTime now) {
    final at = now.toUtc().millisecondsSinceEpoch;
    return LockoutState(
      failedAttempts: LockoutPolicy.attemptsBeforeFirstLockout,
      level: LockoutPolicy.maxLevel,
      lockedAtUtcMs: at,
      lockedUntilUtcMs: at + LockoutPolicy.max.inMilliseconds,
    );
  }

  /// Throws [FormatException] for wrongly typed fields.
  factory fromJson(Map<String, Object?> json) {
    final failed = json['failedAttempts'];
    final level = json['level'];
    final at = json['lockedAtUtcMs'];
    final until = json['lockedUntilUtcMs'];
    if (failed is! int ||
        level is! int ||
        (at != null && at is! int) ||
        (until != null && until is! int)) {
      throw const FormatException('malformed lockout state');
    }
    return LockoutState(
      failedAttempts: failed,
      level: level,
      lockedAtUtcMs: at as int?,
      lockedUntilUtcMs: until as int?,
    );
  }

  static const LockoutState initial = LockoutState();

  /// Consecutive wrong PINs since the last success.
  final int failedAttempts;

  /// 0 before any lockout; level k ≥ 1 lasts [LockoutPolicy.lengthFor].
  final int level;
  final int? lockedAtUtcMs;
  final int? lockedUntilUtcMs;

  /// The state stored as [encoded], or null when it is not valid.
  static LockoutState? tryParse(String encoded) {
    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, Object?>) return null;
      return LockoutState.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  Map<String, Object?> toJson() => {
    'failedAttempts': failedAttempts,
    'level': level,
    'lockedAtUtcMs': lockedAtUtcMs,
    'lockedUntilUtcMs': lockedUntilUtcMs,
  };

  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is LockoutState &&
      other.failedAttempts == failedAttempts &&
      other.level == level &&
      other.lockedAtUtcMs == lockedAtUtcMs &&
      other.lockedUntilUtcMs == lockedUntilUtcMs;

  @override
  int get hashCode =>
      Object.hash(failedAttempts, level, lockedAtUtcMs, lockedUntilUtcMs);

  @override
  String toString() =>
      'LockoutState(failed: $failedAttempts, level: $level, '
      'until: $lockedUntilUtcMs)';
}

/// SYS-03 lockout rules (FR-031, FR-032, research R4): 5 wrong PINs lock
/// for 30 s; once a lockout has ended, each further wrong PIN starts the
/// next one at double the length, up to 15 minutes (clarification Q1). A
/// success, by PIN or biometric, resets everything (Q3). Pure Dart; time is
/// always passed in.
abstract final class LockoutPolicy {
  static const int attemptsBeforeFirstLockout = 5;
  static const Duration base = Duration(seconds: 30);
  static const Duration max = Duration(minutes: 15);

  /// The first level whose length is capped at [max].
  static const int maxLevel = 6;

  /// Length of lockout [level] (≥ 1): 30 s, 60 s, 2, 4, 8, 15, 15 … min.
  static Duration lengthFor(int level) {
    final doubled = base * pow(2, min(level - 1, 10)).toInt();
    return doubled > max ? max : doubled;
  }

  /// One more wrong PIN at [now] (only while not locked out; callers check
  /// [remaining] first).
  static LockoutState registerFailure(LockoutState state, DateTime now) {
    final failed = state.failedAttempts + 1;
    if (state.level == 0 && failed < attemptsBeforeFirstLockout) {
      return LockoutState(failedAttempts: failed);
    }
    final level = state.level + 1;
    final at = now.toUtc().millisecondsSinceEpoch;
    return LockoutState(
      failedAttempts: failed,
      level: level,
      lockedAtUtcMs: at,
      lockedUntilUtcMs: at + lengthFor(level).inMilliseconds,
    );
  }

  static LockoutState registerSuccess() => LockoutState.initial;

  /// Time left in the current lockout at [now], or [Duration.zero]. If the
  /// clock has moved before the lockout began, the full length remains, so
  /// a lockout is never shortened or stretched past one period.
  static Duration remaining(LockoutState state, DateTime now) {
    final at = state.lockedAtUtcMs;
    final until = state.lockedUntilUtcMs;
    if (at == null || until == null || state.level == 0) return Duration.zero;
    final length = lengthFor(state.level);
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    if (nowMs < at) return length;
    final left = Duration(milliseconds: until - nowMs);
    if (left <= Duration.zero) return Duration.zero;
    return left > length ? length : left;
  }

  /// After the clock moved back before the lockout began, starts the
  /// lockout again from [now] with its full length; otherwise unchanged.
  static LockoutState reanchor(LockoutState state, DateTime now) {
    final at = state.lockedAtUtcMs;
    final nowMs = now.toUtc().millisecondsSinceEpoch;
    if (at == null || state.level == 0 || nowMs >= at) return state;
    return LockoutState(
      failedAttempts: state.failedAttempts,
      level: state.level,
      lockedAtUtcMs: nowMs,
      lockedUntilUtcMs: nowMs + lengthFor(state.level).inMilliseconds,
    );
  }

  /// Wrong PINs left before the first lockout; shown from the 3rd failure.
  /// Null otherwise.
  static int? attemptsLeftBeforeLockout(LockoutState state) =>
      state.level == 0 && state.failedAttempts >= 3
      ? attemptsBeforeFirstLockout - state.failedAttempts
      : null;

  /// Once a lockout has ended, the length the next wrong PIN would lock
  /// for (the post-lockout warning, US2-1). Null before the first lockout
  /// and while locked.
  static Duration? nextLockoutLength(LockoutState state, DateTime now) {
    if (state.level == 0 || remaining(state, now) > Duration.zero) return null;
    return lengthFor(state.level + 1);
  }
}
