import 'package:dailytrack/core/security/domain/lockout_policy.dart';
import 'package:flutter_test/flutter_test.dart';

/// SYS-03 lockout (T036, research R4, FR-031, FR-032, clarifications Q1, Q3).
void main() {
  final t0 = DateTime.utc(2026, 10, 21, 10);
  const s = Duration(seconds: 1);

  LockoutState fail(LockoutState state, DateTime at, [int times = 1]) {
    var next = state;
    for (var i = 0; i < times; i++) {
      next = LockoutPolicy.registerFailure(next, at);
    }
    return next;
  }

  test('lockout lengths: 30 s, 60 s, 2, 4, 8, then 15 minutes', () {
    expect(
      [for (var level = 1; level <= 8; level++) LockoutPolicy.lengthFor(level)],
      [
        const Duration(seconds: 30),
        const Duration(seconds: 60),
        const Duration(minutes: 2),
        const Duration(minutes: 4),
        const Duration(minutes: 8),
        const Duration(minutes: 15),
        const Duration(minutes: 15),
        const Duration(minutes: 15),
      ],
    );
  });

  test('failures 1 to 4 do not lock; the hint starts at the 3rd', () {
    var state = LockoutState.initial;
    final left = <int?>[];
    for (var i = 1; i <= 4; i++) {
      state = fail(state, t0);
      expect(state.level, 0);
      expect(LockoutPolicy.remaining(state, t0), Duration.zero);
      left.add(LockoutPolicy.attemptsLeftBeforeLockout(state));
    }
    expect(left, [null, null, 2, 1]);
  });

  test('the 5th failure locks for 30 s; it ends exactly at 30 s', () {
    final state = fail(LockoutState.initial, t0, 5);
    expect(state.level, 1);
    expect(LockoutPolicy.remaining(state, t0), const Duration(seconds: 30));
    expect(
      LockoutPolicy.remaining(
        state,
        t0.add(const Duration(milliseconds: 29999)),
      ),
      greaterThan(Duration.zero),
    );
    expect(LockoutPolicy.remaining(state, t0.add(s * 30)), Duration.zero);
    expect(LockoutPolicy.attemptsLeftBeforeLockout(state), isNull);
  });

  test('Q1: after a lockout ends, each wrong PIN starts the next, doubled '
      'lockout, up to 15 minutes', () {
    var state = fail(LockoutState.initial, t0, 5);
    var now = t0;
    final lengths = <Duration>[LockoutPolicy.remaining(state, now)];
    for (var i = 0; i < 6; i++) {
      now = now.add(LockoutPolicy.remaining(state, now));
      // The warning before the next wrong PIN names the next length.
      final warned = LockoutPolicy.nextLockoutLength(state, now);
      state = fail(state, now);
      final remaining = LockoutPolicy.remaining(state, now);
      expect(warned, remaining);
      lengths.add(remaining);
    }
    expect(lengths, [
      const Duration(seconds: 30),
      const Duration(seconds: 60),
      const Duration(minutes: 2),
      const Duration(minutes: 4),
      const Duration(minutes: 8),
      const Duration(minutes: 15),
      const Duration(minutes: 15),
    ]);
  });

  test('nextLockoutLength is null before the first lockout and while '
      'locked', () {
    expect(LockoutPolicy.nextLockoutLength(LockoutState.initial, t0), isNull);
    final locked = fail(LockoutState.initial, t0, 5);
    expect(LockoutPolicy.nextLockoutLength(locked, t0), isNull);
    expect(
      LockoutPolicy.nextLockoutLength(locked, t0.add(s * 30)),
      const Duration(seconds: 60),
    );
  });

  test('a success resets the count and the level (PIN or biometric)', () {
    final reset = LockoutPolicy.registerSuccess();
    expect(reset.failedAttempts, 0);
    expect(reset.level, 0);
    expect(reset.lockedUntilUtcMs, isNull);
    expect(reset, LockoutState.initial);
  });

  test('moving the clock back never extends a lockout past its length', () {
    final state = fail(LockoutState.initial, t0, 5);
    final back = t0.subtract(const Duration(hours: 1));
    expect(LockoutPolicy.remaining(state, back), const Duration(seconds: 30));
    final anchored = LockoutPolicy.reanchor(state, back);
    expect(anchored.lockedAtUtcMs, back.millisecondsSinceEpoch);
    expect(LockoutPolicy.remaining(anchored, back.add(s * 30)), Duration.zero);
  });

  test('moving the clock forward past the end ends the lockout (a known, '
      'documented limit)', () {
    final state = fail(LockoutState.initial, t0, 5);
    expect(
      LockoutPolicy.remaining(state, t0.add(const Duration(days: 1))),
      Duration.zero,
    );
  });

  test('JSON round-trips; corrupt JSON gives the initial state', () {
    final state = fail(LockoutState.initial, t0, 5);
    expect(LockoutState.fromJson(state.toJson()), state);
    expect(LockoutState.tryParse('{"failedAttempts":"x"}'), isNull);
    expect(LockoutState.tryParse('not json'), isNull);
    expect(LockoutState.tryParse(state.encode()), state);
  });

  test('a fail-safe state locks for the maximum from now', () {
    final state = LockoutState.failSafe(t0);
    expect(LockoutPolicy.remaining(state, t0), const Duration(minutes: 15));
  });
}
