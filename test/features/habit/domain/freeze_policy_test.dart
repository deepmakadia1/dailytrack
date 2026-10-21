import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/streaks/freeze_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_builder.dart';

/// FreezePolicy (spec Edge Cases "Freeze window", FR-035, FR-036, research
/// R8). Today is Wednesday 2026-10-21.
void main() {
  final policy = FreezePolicy(engineAt('2026-10-21'));

  FreezeDecision check(
    HabitHistory h,
    String day, {
    bool allowToday = false,
    int available = 1,
  }) => policy.check(h, d(day), allowToday: allowToday, available: available);

  Matcher rejected(FreezeRejection reason) =>
      isA<FreezeRejected>().having((r) => r.reason, 'reason', reason);

  group('HAB-03 criterion "A freeze cannot be applied to today or to a day '
      'older than 3 days"', () {
    final h = history(start: '2026-10-01');

    test('missed days 1–3 back are allowed', () {
      for (final k in ['2026-10-20', '2026-10-19', '2026-10-18']) {
        expect(check(h, k), isA<FreezeAllowed>(), reason: k);
      }
    });

    test('today from the card is rejected', () {
      expect(check(h, '2026-10-21'), rejected(FreezeRejection.today));
    });

    test('4 or more days back are rejected', () {
      expect(check(h, '2026-10-17'), rejected(FreezeRejection.tooOld));
      expect(check(h, '2026-10-01'), rejected(FreezeRejection.tooOld));
      expect(
        check(h, '2026-10-17', allowToday: true),
        rejected(FreezeRejection.tooOld),
      );
    });
  });

  test('future days are rejected', () {
    final h = history(start: '2026-10-01');
    expect(check(h, '2026-10-22'), rejected(FreezeRejection.future));
    expect(
      check(h, '2026-10-22', allowToday: true),
      rejected(FreezeRejection.future),
    );
  });

  test('days before the start are rejected', () {
    final h = history(start: '2026-10-20');
    expect(check(h, '2026-10-19'), rejected(FreezeRejection.beforeStart));
    expect(check(h, '2026-10-20'), isA<FreezeAllowed>());
  });

  test('done days are rejected; partial count days are allowed', () {
    final h = history(
      start: '2026-10-01',
      schedule: count(10),
      values: {'2026-10-20': 10, '2026-10-19': 4},
    );
    expect(check(h, '2026-10-20'), rejected(FreezeRejection.alreadyDone));
    expect(check(h, '2026-10-19'), isA<FreezeAllowed>());
  });

  test('a day that already has a freeze is rejected', () {
    final h = history(start: '2026-10-01', freezes: ['2026-10-20']);
    expect(check(h, '2026-10-20'), rejected(FreezeRejection.alreadyFrozen));
  });

  test('unscheduled "Specific days" days are rejected', () {
    final h = history(start: '2026-10-01', schedule: mwf);
    expect(check(h, '2026-10-20'), rejected(FreezeRejection.notScheduled));
    expect(check(h, '2026-10-19'), isA<FreezeAllowed>()); // Mon
    expect(
      check(h, '2026-10-21', allowToday: true),
      isA<FreezeAllowed>(),
    ); // Wed
  });

  test('no freezes left → none left, only for an otherwise allowed day', () {
    final h = history(start: '2026-10-01');
    expect(check(h, '2026-10-20', available: 0), isA<FreezeNoneLeft>());
    expect(
      check(h, '2026-10-21', available: 0),
      rejected(FreezeRejection.today),
    );
  });

  group('Skip today (allowToday)', () {
    test('allowed when today is scheduled and not done', () {
      final h = history(start: '2026-10-01');
      expect(check(h, '2026-10-21', allowToday: true), isA<FreezeAllowed>());
      expect(
        check(h, '2026-10-21', allowToday: true, available: 2),
        isA<FreezeAllowed>(),
      );
    });

    test('rejected when today is done or not scheduled', () {
      final done = history(start: '2026-10-01', done: ['2026-10-21']);
      expect(
        check(done, '2026-10-21', allowToday: true),
        rejected(FreezeRejection.alreadyDone),
      );
      final tueThu = history(start: '2026-10-01', schedule: weekdays({2, 4}));
      expect(
        check(tueThu, '2026-10-21', allowToday: true),
        rejected(FreezeRejection.notScheduled),
      );
    });

    test('a future start date is rejected', () {
      final h = history(start: '2026-10-25');
      expect(
        check(h, '2026-10-21', allowToday: true),
        rejected(FreezeRejection.beforeStart),
      );
    });
  });

  group('times per week (research R6)', () {
    test('any not-done day 1–3 back is freezable', () {
      final h = history(
        start: '2026-10-12',
        schedule: perWeek(2),
        done: ['2026-10-19'],
      );
      for (final k in ['2026-10-20', '2026-10-18']) {
        expect(check(h, k), isA<FreezeAllowed>(), reason: k);
      }
      expect(check(h, '2026-10-19'), rejected(FreezeRejection.alreadyDone));
    });

    test('also after the week target is met', () {
      final h = history(
        start: '2026-10-12',
        schedule: perWeek(1),
        done: ['2026-10-19'],
      );
      expect(check(h, '2026-10-20'), isA<FreezeAllowed>());
      expect(check(h, '2026-10-21', allowToday: true), isA<FreezeAllowed>());
    });
  });
}
