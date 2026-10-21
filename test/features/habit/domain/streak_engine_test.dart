import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_builder.dart';

/// Streak engine (research R6, spec §4 "Business rules for streaks").
/// Unless a test says otherwise, today is Wednesday 2026-10-21 at noon and
/// weeks start on Monday (2026-10-19). Every expectation is hand-computed.
void main() {
  void expectSummary(
    StreakSummary s, {
    required int current,
    required int best,
    required int? rate,
    required int total,
    StreakUnit unit = StreakUnit.days,
  }) {
    expect(
      (s.current, s.best, s.completionRate, s.totalCompletions, s.unit),
      (current, best, rate, total, unit),
      reason: '(current, best, rate, total, unit)',
    );
  }

  final wed = engineAt('2026-10-21');

  group('US2 acceptance scenarios', () {
    test('STREAK US2-1 daily habit done the last 5 days including today '
        'has streak 5', () {
      final h = history(
        start: '2026-10-17',
        done: span('2026-10-17', '2026-10-21'),
      );
      expectSummary(wed.summarize(h), current: 5, best: 5, rate: 100, total: 5);
    });

    test('STREAK US2-2 done the last 5 days but not yet today keeps 5', () {
      final h = history(
        start: '2026-10-16',
        done: span('2026-10-16', '2026-10-20'),
      );
      expectSummary(wed.summarize(h), current: 5, best: 5, rate: 100, total: 5);
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.pending);
    });

    test('STREAK US2-3 done 3 days ago and today, not in between, is 1', () {
      final h = history(
        start: '2026-10-18',
        done: ['2026-10-18', '2026-10-21'],
      );
      // 2 hits of 4 days.
      expectSummary(wed.summarize(h), current: 1, best: 1, rate: 50, total: 2);
    });

    test('STREAK US2-4 Mon/Wed/Fri done on the last three scheduled days is '
        '3; days between do not break it', () {
      final h = history(
        start: '2026-10-12',
        schedule: mwf,
        done: ['2026-10-16', '2026-10-19', '2026-10-21'],
      );
      // Scheduled: Mon 12 and Wed 14 missed, Fri 16, Mon 19, Wed 21 done.
      expectSummary(wed.summarize(h), current: 3, best: 3, rate: 60, total: 3);
      for (final k in ['2026-10-17', '2026-10-18', '2026-10-20']) {
        expect(wed.dayStatus(h, d(k)), DayStatus.unscheduled, reason: k);
      }
    });

    test('STREAK US2-5 a past count day of 12 of 20 breaks the streak', () {
      final h = history(
        start: '2026-10-15',
        schedule: count(20),
        values: {
          for (final k in span('2026-10-15', '2026-10-21')) k: 20,
          '2026-10-18': 12,
        },
      );
      expectSummary(wed.summarize(h), current: 3, best: 3, rate: 86, total: 6);
      expect(wed.dayStatus(h, d('2026-10-18')), DayStatus.partial);
    });

    test('STREAK US2-6 a freeze on a missed day between done days keeps the '
        'streak without adding to it', () {
      final h = history(
        start: '2026-10-15',
        done: [
          ...span('2026-10-15', '2026-10-17'),
          ...span('2026-10-19', '2026-10-21'),
        ],
        freezes: ['2026-10-18'],
      );
      // The freeze day is left out of the rate: 6 of 6.
      expectSummary(wed.summarize(h), current: 6, best: 6, rate: 100, total: 6);
      expect(wed.dayStatus(h, d('2026-10-18')), DayStatus.freeze);
    });

    group('STREAK US2-7 3× per week met in each of the last 4 complete '
        'weeks', () {
      // Weeks: Sep 21, Sep 28, Oct 5, Oct 12 (Mondays); 3 days each.
      final met = [
        '2026-09-21',
        '2026-09-23',
        '2026-09-25',
        '2026-09-28',
        '2026-09-30',
        '2026-10-02',
        '2026-10-05',
        '2026-10-06',
        '2026-10-11',
        '2026-10-13',
        '2026-10-15',
        '2026-10-18',
      ];

      test('is 4 weeks while the current week has 0 done', () {
        final h = history(start: '2026-09-21', schedule: perWeek(3), done: met);
        // Weeks overlapping Sep 22–Oct 21: Sep 21, Sep 28, Oct 5, Oct 12 →
        // 4 of 4; the open current week is left out.
        expectSummary(
          wed.summarize(h),
          current: 4,
          best: 4,
          rate: 100,
          total: 12,
          unit: StreakUnit.weeks,
        );
      });

      test('is still 4 with 1 of 3 done this week; 5 once the week is met', () {
        final partial = history(
          start: '2026-09-21',
          schedule: perWeek(3),
          done: [...met, '2026-10-20'],
        );
        expect(wed.summarize(partial).current, 4);
        final full = history(
          start: '2026-09-21',
          schedule: perWeek(3),
          done: [...met, ...span('2026-10-19', '2026-10-21')],
        );
        expect(wed.summarize(full).current, 5);
        expect(wed.summarize(full).best, 5);
      });

      test('an unmet current week breaks it only once the week is over', () {
        final h = history(
          start: '2026-09-21',
          schedule: perWeek(3),
          done: [...met, '2026-10-20'],
        );
        expect(engineAt('2026-10-25', hour: 23).summarize(h).current, 4);
        expect(engineAt('2026-10-26', hour: 0).summarize(h).current, 0);
        expect(engineAt('2026-10-26', hour: 0).summarize(h).best, 4);
      });
    });

    test('STREAK US2-8 back-filling a missed day recomputes current, best, '
        'and rate', () {
      final before = history(
        start: '2026-10-10',
        done: [...span('2026-10-10', '2026-10-19'), '2026-10-21'],
      );
      // 12 scheduled days, 11 done: 91.67 % → 92.
      expectSummary(
        wed.summarize(before),
        current: 1,
        best: 10,
        rate: 92,
        total: 11,
      );
      final after = history(
        start: '2026-10-10',
        done: span('2026-10-10', '2026-10-21'),
      );
      expectSummary(
        wed.summarize(after),
        current: 12,
        best: 12,
        rate: 100,
        total: 12,
      );
    });

    test('STREAK US2-9 best is the longest run and never below current', () {
      final h = history(
        start: '2026-10-01',
        done: [
          ...span('2026-10-01', '2026-10-07'),
          ...span('2026-10-09', '2026-10-11'),
          '2026-10-20',
          '2026-10-21',
        ],
      );
      final s = wed.summarize(h);
      expect((s.current, s.best), (2, 7));
      final all = history(
        start: '2026-10-01',
        done: span('2026-10-01', '2026-10-21'),
      );
      final t = wed.summarize(all);
      expect((t.current, t.best), (21, 21));
    });
  });

  group('daily', () {
    test('today pending does not break the streak', () {
      final h = history(
        start: '2026-10-19',
        done: ['2026-10-19', '2026-10-20'],
      );
      expectSummary(wed.summarize(h), current: 2, best: 2, rate: 100, total: 2);
    });

    test('a missed past day breaks the streak', () {
      final h = history(
        start: '2026-10-15',
        done: ['2026-10-15', '2026-10-16', ...span('2026-10-18', '2026-10-20')],
      );
      // 17 missed; 5 of 6 past days done (83.3 %), today pending.
      expectSummary(wed.summarize(h), current: 3, best: 3, rate: 83, total: 5);
      expect(wed.dayStatus(h, d('2026-10-17')), DayStatus.missed);
    });

    test('a partial count today is pending, not partial', () {
      final h = history(
        start: '2026-10-20',
        schedule: count(5),
        values: {'2026-10-20': 5, '2026-10-21': 3},
      );
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.pending);
      expectSummary(wed.summarize(h), current: 1, best: 1, rate: 100, total: 1);
    });

    test('values above the target count as done', () {
      final h = history(
        start: '2026-10-20',
        schedule: count(5),
        values: {'2026-10-20': 9, '2026-10-21': 5},
      );
      expectSummary(wed.summarize(h), current: 2, best: 2, rate: 100, total: 2);
    });

    test('a freeze day that was also done counts as done', () {
      final h = history(
        start: '2026-10-20',
        done: ['2026-10-20', '2026-10-21'],
        freezes: ['2026-10-20'],
      );
      expect(wed.dayStatus(h, d('2026-10-20')), DayStatus.done);
      expect(wed.summarize(h).current, 2);
    });

    test('a note-only day is not done', () {
      final h = history(start: '2026-10-20', notes: {'2026-10-20': 'Tired'});
      expect(wed.dayStatus(h, d('2026-10-20')), DayStatus.missed);
      expectSummary(wed.summarize(h), current: 0, best: 0, rate: 0, total: 0);
    });

    test('an empty history', () {
      final h = history(start: '2026-10-01');
      // 20 missed past days, today pending.
      expectSummary(wed.summarize(h), current: 0, best: 0, rate: 0, total: 0);
    });

    test('only freezes: no countable day', () {
      final h = history(
        start: '2026-10-19',
        freezes: ['2026-10-19', '2026-10-20'],
      );
      expectSummary(
        wed.summarize(h),
        current: 0,
        best: 0,
        rate: null,
        total: 0,
      );
    });
  });

  group('specific weekdays', () {
    final weekdaysOnly = weekdays({1, 2, 3, 4, 5});
    final monToFri = span('2026-10-12', '2026-10-16');

    test('a Mon–Fri run is kept over the weekend (Monday morning: 5)', () {
      final h = history(
        start: '2026-10-12',
        schedule: weekdaysOnly,
        done: monToFri,
      );
      final mon = engineAt('2026-10-19', hour: 7);
      expectSummary(mon.summarize(h), current: 5, best: 5, rate: 100, total: 5);
    });

    test(
      'a forgotten Monday breaks it on Tuesday; back-filling it gives 6',
      () {
        final tue = engineAt('2026-10-20', hour: 8);
        final gap = history(
          start: '2026-10-12',
          schedule: weekdaysOnly,
          done: monToFri,
        );
        expect(tue.summarize(gap).current, 0);
        expect(tue.summarize(gap).best, 5);
        final filled = history(
          start: '2026-10-12',
          schedule: weekdaysOnly,
          done: [...monToFri, '2026-10-19'],
        );
        expect(tue.summarize(filled).current, 6);
        expect(tue.summarize(filled).best, 6);
      },
    );

    test('done on an unscheduled day: total yes, streak and rate no', () {
      final h = history(
        start: '2026-10-12',
        schedule: mwf,
        done: [
          '2026-10-12', '2026-10-14', '2026-10-16', '2026-10-19',
          '2026-10-13', '2026-10-17', // Tue, Sat
        ],
      );
      expectSummary(wed.summarize(h), current: 4, best: 4, rate: 100, total: 6);
      expect(wed.dayStatus(h, d('2026-10-13')), DayStatus.done);
    });

    test('rate counts only scheduled days', () {
      final h = history(
        start: '2026-10-12',
        schedule: mwf,
        done: ['2026-10-12', '2026-10-16', '2026-10-13'],
      );
      // Mon 12 ✓, Wed 14 ✗, Fri 16 ✓, Mon 19 ✗; Wed 21 pending → 2 of 4.
      expectSummary(wed.summarize(h), current: 0, best: 1, rate: 50, total: 3);
    });
  });

  group('times per week', () {
    test('a past unmet week with a freeze keeps the streak without adding', () {
      final h = history(
        start: '2026-09-28',
        schedule: perWeek(3),
        done: [
          '2026-09-28', '2026-09-29', '2026-09-30', // met
          '2026-10-06', // 1 of 3
          '2026-10-12', '2026-10-14', '2026-10-16', // met
        ],
        freezes: ['2026-10-08'],
      );
      // Rate: Sep 28 ✓, Oct 5 frozen (left out), Oct 12 ✓ → 100.
      expectSummary(
        wed.summarize(h),
        current: 2,
        best: 2,
        rate: 100,
        total: 7,
        unit: StreakUnit.weeks,
      );
    });

    test('a past unmet week without a freeze breaks the streak', () {
      final h = history(
        start: '2026-09-28',
        schedule: perWeek(3),
        done: [
          '2026-09-28',
          '2026-09-29',
          '2026-09-30',
          '2026-10-06',
          '2026-10-12',
          '2026-10-14',
          '2026-10-16',
        ],
      );
      expectSummary(
        wed.summarize(h),
        current: 1,
        best: 1,
        rate: 67,
        total: 7,
        unit: StreakUnit.weeks,
      );
    });

    test('a current week that is met counts at once', () {
      final h = history(
        start: '2026-10-12',
        schedule: perWeek(2),
        done: ['2026-10-12', '2026-10-13', '2026-10-19', '2026-10-21'],
      );
      expectSummary(
        wed.summarize(h),
        current: 2,
        best: 2,
        rate: 100,
        total: 4,
        unit: StreakUnit.weeks,
      );
    });

    group('week start', () {
      // Starts Saturday 2026-10-03; 2× per week.
      final h = history(
        start: '2026-10-03',
        schedule: perWeek(2),
        done: [
          '2026-10-04', '2026-10-05', // Sun, Mon
          '2026-10-11', '2026-10-12', // Sun, Mon
          '2026-10-17', '2026-10-18', // Sat, Sun
        ],
      );

      test('Monday', () {
        // Sep 28 (Oct 3–4: 1) ✗, Oct 5 (5, 11) ✓, Oct 12 (12, 17, 18) ✓,
        // Oct 19 (0) open.
        final e = engineAt('2026-10-21');
        expectSummary(
          e.summarize(h),
          current: 2,
          best: 2,
          rate: 67,
          total: 6,
          unit: StreakUnit.weeks,
        );
        expect(e.weekProgress(h, d('2026-10-21')), (done: 0, target: 2));
        expect(e.weekProgress(h, d('2026-10-04')), (done: 1, target: 2));
      });

      test('Sunday', () {
        // Sep 27 (Oct 3: 0) ✗, Oct 4 (4, 5) ✓, Oct 11 (11, 12, 17) ✓,
        // Oct 18 (18) open.
        final e = engineAt('2026-10-21', firstDayOfWeek: 7);
        expectSummary(
          e.summarize(h),
          current: 2,
          best: 2,
          rate: 67,
          total: 6,
          unit: StreakUnit.weeks,
        );
        expect(e.weekProgress(h, d('2026-10-21')), (done: 1, target: 2));
      });

      test('Saturday', () {
        // Oct 3 (4, 5) ✓, Oct 10 (11, 12) ✓, Oct 17 (17, 18) ✓ met.
        final e = engineAt('2026-10-21', firstDayOfWeek: 6);
        expectSummary(
          e.summarize(h),
          current: 3,
          best: 3,
          rate: 100,
          total: 6,
          unit: StreakUnit.weeks,
        );
        expect(e.weekProgress(h, d('2026-10-21')), (done: 2, target: 2));
      });
    });

    test('every day on or after the start is scheduled, also once the week '
        'is met (research R6)', () {
      final h = history(
        start: '2026-10-19',
        schedule: perWeek(2),
        done: ['2026-10-19', '2026-10-20'],
      );
      expect(wed.isScheduledOn(h, d('2026-10-21')), isTrue);
      expect(wed.isScheduledOn(h, d('2026-10-25')), isTrue);
      expect(wed.isScheduledOn(h, d('2026-10-18')), isFalse);
      // The met week lists the other days as not due.
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.unscheduled);
      expect(wed.dayStatus(h, d('2026-10-22')), DayStatus.future);
    });

    test('an unmet past day is missed; today is pending', () {
      final h = history(start: '2026-10-19', schedule: perWeek(3));
      expect(wed.dayStatus(h, d('2026-10-19')), DayStatus.missed);
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.pending);
    });

    test('a partial first week must still meet the target', () {
      // Starts Saturday: the first week has 2 days for a 3× target.
      final h = history(
        start: '2026-10-17',
        schedule: perWeek(3),
        done: ['2026-10-17', '2026-10-18'],
      );
      final s = engineAt('2026-10-21').summarize(h);
      expect((s.current, s.best, s.completionRate), (0, 0, 0));
    });

    test('a count habit needs the target on each counted day', () {
      final h = history(
        start: '2026-10-12',
        schedule: perWeek(2, target: 10),
        values: {'2026-10-12': 10, '2026-10-13': 9, '2026-10-14': 12},
      );
      expect(wed.summarize(h).current, 1);
      expect(wed.summarize(h).totalCompletions, 2);
    });
  });

  group('completion rate', () {
    test('looks back 30 days including today', () {
      final h = history(
        start: '2026-09-01',
        done: [...span('2026-09-01', '2026-09-30'), '2026-10-21'],
      );
      // Window Sep 22–Oct 21: Sep 22–30 (9) + today (1) of 30 → 33.
      expect(wed.summarize(h).completionRate, 33);
      expect(wed.summarize(h).totalCompletions, 31);
    });

    test('leaves out freeze days and an undone today', () {
      final h = history(
        start: '2026-10-12',
        done: [...span('2026-10-12', '2026-10-15'), '2026-10-19', '2026-10-20'],
        freezes: ['2026-10-16'],
      );
      // Oct 12–20 without the freeze: 8 days, 6 done.
      expect(wed.summarize(h).completionRate, 75);
    });

    test('counts today only once it is done', () {
      int? rate(List<String> done) => wed
          .summarize(history(start: '2026-10-20', done: done))
          .completionRate;
      expect(rate(['2026-10-20']), 100);
      expect(rate(['2026-10-20', '2026-10-21']), 100);
      expect(rate(['2026-10-21']), 50);
      expect(rate([]), 0);
    });

    test('rounds half up to a whole percent', () {
      // 8 past days (Oct 13–20), today pending.
      int? rate(int doneDays) => wed
          .summarize(
            history(
              start: '2026-10-13',
              done: span('2026-10-13', '2026-10-20').take(doneDays),
            ),
          )
          .completionRate;
      expect(rate(1), 13); // 12.5
      expect(rate(3), 38); // 37.5
      expect(rate(7), 88); // 87.5
    });

    test('is null with no countable day', () {
      expect(
        wed.summarize(history(start: '2026-10-21')).completionRate,
        isNull,
      );
      expect(
        wed.summarize(history(start: '2026-10-25')).completionRate,
        isNull,
      );
      // Mondays only, started Thursday, today Saturday: no due day yet.
      expect(
        engineAt('2026-10-17')
            .summarize(history(start: '2026-10-15', schedule: weekdays({1})))
            .completionRate,
        isNull,
      );
    });
  });

  group('total completions', () {
    test('counts done days on or after the start, scheduled or not', () {
      final h = history(
        start: '2026-10-12',
        schedule: weekdays({1}, target: 5),
        values: {
          '2026-10-11': 5, // before start
          '2026-10-12': 5,
          '2026-10-13': 7, // unscheduled
          '2026-10-14': 4, // partial
          '2026-10-19': 5,
          '2026-10-23': 5, // future
        },
        freezes: ['2026-10-20'],
      );
      expect(wed.summarize(h).totalCompletions, 3);
    });
  });

  group('start date', () {
    test('days before the start are beforeStart and never missed', () {
      final h = history(
        start: '2026-10-19',
        done: span('2026-10-19', '2026-10-21'),
      );
      expect(wed.dayStatus(h, d('2026-10-18')), DayStatus.beforeStart);
      expect(wed.isScheduledOn(h, d('2026-10-18')), isFalse);
      expectSummary(wed.summarize(h), current: 3, best: 3, rate: 100, total: 3);
    });

    test('a future start has no scheduled day yet', () {
      final h = history(start: '2026-10-25', done: ['2026-10-21']);
      expect(wed.isScheduledOn(h, d('2026-10-21')), isFalse);
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.beforeStart);
      expect(wed.dayStatus(h, d('2026-10-26')), DayStatus.future);
      expectSummary(
        wed.summarize(h),
        current: 0,
        best: 0,
        rate: null,
        total: 0,
      );
    });

    test('a start of today with nothing done is pending', () {
      final h = history(start: '2026-10-21');
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.pending);
      expectSummary(
        wed.summarize(h),
        current: 0,
        best: 0,
        rate: null,
        total: 0,
      );
    });
  });

  group('schedule and target history (research R3)', () {
    test('daily → Mon/Wed/Fri mid-run keeps the run and judges each day with '
        'its own schedule', () {
      final h = history(
        start: '2026-10-10',
        versions: [('2026-10-10', daily), ('2026-10-15', mwf)],
        done: [
          ...span('2026-10-10', '2026-10-14'),
          '2026-10-16',
          '2026-10-19',
          '2026-10-21',
        ],
      );
      // 5 daily days + Fri 16, Mon 19, Wed 21.
      expectSummary(wed.summarize(h), current: 8, best: 8, rate: 100, total: 8);
      expect(wed.isScheduledOn(h, d('2026-10-13')), isTrue); // Tue, daily
      expect(wed.isScheduledOn(h, d('2026-10-20')), isFalse); // Tue, MWF
      expect(wed.scheduleOn(h, d('2026-10-14')), daily);
      expect(wed.scheduleOn(h, d('2026-10-15')), mwf);
    });

    test(
      'a schedule change can end a run that the old schedule would keep',
      () {
        // Mon/Wed/Fri → daily from Monday 19: Tue 20 is now due and missed.
        final h = history(
          start: '2026-10-12',
          versions: [('2026-10-12', mwf), ('2026-10-19', daily)],
          done: [
            '2026-10-12',
            '2026-10-14',
            '2026-10-16',
            '2026-10-19',
            '2026-10-21',
          ],
        );
        final s = wed.summarize(h);
        expect((s.current, s.best), (1, 4));
      },
    );

    test('a raised target: an earlier day with 15 stays done at target 10', () {
      final h = history(
        start: '2026-10-15',
        versions: [('2026-10-15', count(10)), ('2026-10-18', count(20))],
        values: {
          '2026-10-15': 15,
          '2026-10-16': 15,
          '2026-10-17': 15,
          '2026-10-18': 15,
          '2026-10-19': 20,
          '2026-10-20': 25,
        },
      );
      expect(wed.dayStatus(h, d('2026-10-17')), DayStatus.done);
      expect(wed.dayStatus(h, d('2026-10-18')), DayStatus.partial);
      // 15, 16, 17 done; 18 partial breaks; 19, 20 done; today pending.
      expectSummary(wed.summarize(h), current: 2, best: 3, rate: 83, total: 5);
    });

    test('a lowered target makes later days easier, not earlier ones', () {
      final h = history(
        start: '2026-10-19',
        versions: [('2026-10-19', count(8)), ('2026-10-20', count(4))],
        values: {'2026-10-19': 5, '2026-10-20': 5, '2026-10-21': 4},
      );
      expect(wed.dayStatus(h, d('2026-10-19')), DayStatus.partial);
      expect(wed.dayStatus(h, d('2026-10-20')), DayStatus.done);
      expect(wed.summarize(h).current, 2);
    });

    test('same-day versions: the last one wins', () {
      final h = history(
        start: '2026-10-01',
        versions: [
          ('2026-10-01', daily),
          ('2026-10-12', mwf),
          ('2026-10-12', weekdays({2, 4})),
        ],
      );
      expect(wed.scheduleOn(h, d('2026-10-13')), weekdays({2, 4}));
      expect(wed.isScheduledOn(h, d('2026-10-13')), isTrue); // Tue
      expect(wed.isScheduledOn(h, d('2026-10-12')), isFalse); // Mon
    });

    test('a start date moved before the first version uses the oldest '
        'version for the earlier days', () {
      final h = history(
        start: '2026-10-01',
        versions: [('2026-10-10', mwf), ('2026-10-15', daily)],
        done: ['2026-10-02', '2026-10-05', '2026-10-07', '2026-10-09'],
      );
      expect(wed.scheduleOn(h, d('2026-10-05')), mwf);
      expect(wed.isScheduledOn(h, d('2026-10-05')), isTrue); // Mon
      expect(wed.isScheduledOn(h, d('2026-10-06')), isFalse); // Tue
      // Fri 2, Mon 5, Wed 7, Fri 9 done; Mon 12 missed.
      expect(wed.summarize(h).best, 4);
    });

    test('daily → 2× per week mid-week: day units, then a week unit', () {
      final h = history(
        start: '2026-10-05',
        versions: [('2026-10-05', daily), ('2026-10-14', perWeek(2))],
        done: [
          ...span('2026-10-05', '2026-10-13'),
          '2026-10-15',
          '2026-10-17',
          '2026-10-20',
        ],
      );
      // 9 daily days + the week of Oct 12 (Wed–Sun part: 15, 17) met; the
      // current week (1 of 2) is open.
      final s = wed.summarize(h);
      expect((s.current, s.best, s.unit), (10, 10, StreakUnit.weeks));
    });

    test('2× per week → daily: the unit follows today', () {
      final h = history(
        start: '2026-10-05',
        versions: [('2026-10-05', perWeek(2)), ('2026-10-19', daily)],
        done: [
          '2026-10-05',
          '2026-10-06',
          '2026-10-12',
          '2026-10-13',
          '2026-10-19',
          '2026-10-20',
        ],
      );
      final s = wed.summarize(h);
      expect((s.current, s.best, s.unit), (4, 4, StreakUnit.days));
    });

    test('a target change inside a week uses the latest weekly target', () {
      final h = history(
        start: '2026-10-19',
        versions: [('2026-10-19', perWeek(2)), ('2026-10-21', perWeek(3))],
        done: ['2026-10-19', '2026-10-20'],
      );
      expect(wed.weekProgress(h, d('2026-10-19')), (done: 2, target: 3));
      expect(wed.weekProgress(h, d('2026-10-21')), (done: 2, target: 3));
      expect(wed.dayStatus(h, d('2026-10-21')), DayStatus.pending);
      expect(wed.summarize(h).current, 0);
    });
  });

  group('boundaries', () {
    test('month end', () {
      final h = history(
        start: '2026-10-28',
        done: span('2026-10-28', '2026-11-02'),
      );
      final s = engineAt('2026-11-02').summarize(h);
      expect((s.current, s.best), (6, 6));
    });

    test('year end, daily', () {
      final h = history(
        start: '2026-12-29',
        done: span('2026-12-29', '2027-01-02'),
      );
      final s = engineAt('2027-01-02').summarize(h);
      expect((s.current, s.best, s.completionRate), (5, 5, 100));
    });

    test('year end, a week spanning two years', () {
      // Monday weeks: Dec 14, Dec 21, Dec 28 (to Jan 3) all met.
      final h = history(
        start: '2026-12-14',
        schedule: perWeek(2),
        done: [
          '2026-12-15',
          '2026-12-17',
          '2026-12-22',
          '2026-12-23',
          '2026-12-31',
          '2027-01-01',
        ],
      );
      final e = engineAt('2027-01-05');
      expect(e.summarize(h).current, 3);
      expect(e.weekProgress(h, d('2027-01-03')), (done: 2, target: 2));
      expect(e.weekProgress(h, d('2026-12-28')), (done: 2, target: 2));
    });

    test('29 February (2028, leap year)', () {
      final dailyRun = history(
        start: '2028-02-27',
        done: span('2028-02-27', '2028-03-01'),
      );
      expect(engineAt('2028-03-01').summarize(dailyRun).current, 4);
      // Mon/Wed/Fri: Fri 25, Mon 28, Wed 1 Mar; Tue 29 Feb is not due.
      final h = history(
        start: '2028-02-25',
        schedule: mwf,
        done: ['2028-02-25', '2028-02-28', '2028-03-01'],
      );
      final e = engineAt('2028-03-01');
      expect(e.summarize(h).current, 3);
      expect(e.dayStatus(h, d('2028-02-29')), DayStatus.unscheduled);
      final tuesdays = history(
        start: '2028-02-22',
        schedule: weekdays({2}),
        done: ['2028-02-22', '2028-02-29'],
      );
      expect(e.summarize(tuesdays).current, 2);
    });

    test('28 February → 1 March in a common year', () {
      final h = history(
        start: '2027-02-27',
        done: span('2027-02-27', '2027-03-01'),
      );
      expect(span('2027-02-27', '2027-03-01'), hasLength(3));
      expect(engineAt('2027-03-01').summarize(h).current, 3);
    });

    test('clock at 23:59:59: today is still pending', () {
      final h = history(
        start: '2026-10-19',
        done: ['2026-10-19', '2026-10-20'],
      );
      final late = engineAt('2026-10-21', hour: 23, minute: 59, second: 59);
      expect(late.today, d('2026-10-21'));
      expect(late.summarize(h).current, 2);
      expect(late.dayStatus(h, d('2026-10-21')), DayStatus.pending);
    });

    test('clock at 00:00:00: yesterday is over and breaks the streak', () {
      final undone = history(
        start: '2026-10-19',
        done: ['2026-10-19', '2026-10-20'],
      );
      final midnight = engineAt('2026-10-22', hour: 0);
      expect(midnight.today, d('2026-10-22'));
      expect(midnight.summarize(undone).current, 0);
      expect(midnight.dayStatus(undone, d('2026-10-21')), DayStatus.missed);
      final done = history(
        start: '2026-10-19',
        done: span('2026-10-19', '2026-10-21'),
      );
      expect(midnight.summarize(done).current, 3);
    });
  });

  group('time zone', () {
    test('today is the local calendar day of the clock, also for a UTC '
        'clock value', () {
      final instant = DateTime.utc(2026, 10, 21, 23, 30);
      final local = instant.toLocal();
      final e = StreakEngine(Clock.fixed(instant));
      expect(e.today, LocalDate(local.year, local.month, local.day));
      expect(e.today, StreakEngine(Clock.fixed(local)).today);
    });

    test('entries keep their day key: moving the clock never splits or '
        'duplicates a day', () {
      final h = history(
        start: '2026-10-19',
        done: span('2026-10-19', '2026-10-21'),
      );
      // Any wall-clock time on the 21st, as after travelling between zones.
      for (final hour in [0, 5, 12, 18, 23]) {
        final s = engineAt('2026-10-21', hour: hour).summarize(h);
        expect((s.current, s.totalCompletions), (3, 3), reason: '$hour:00');
      }
    });
  });

  test('clock moved back: an entry after today is future and counts toward '
      'nothing', () {
    final h = history(
      start: '2026-10-19',
      done: ['2026-10-19', '2026-10-20', '2026-10-23'],
    );
    expect(wed.dayStatus(h, d('2026-10-23')), DayStatus.future);
    expectSummary(wed.summarize(h), current: 2, best: 2, rate: 100, total: 2);
  });

  test('dayStatus covers every value', () {
    // Mon–Fri, count 5, from Tuesday Oct 13.
    final h = history(
      start: '2026-10-13',
      schedule: weekdays({1, 2, 3, 4, 5}, target: 5),
      values: {'2026-10-13': 5, '2026-10-14': 2, '2026-10-18': 5},
      freezes: ['2026-10-16'],
    );
    final expected = {
      '2026-10-12': DayStatus.beforeStart,
      '2026-10-13': DayStatus.done,
      '2026-10-14': DayStatus.partial,
      '2026-10-15': DayStatus.missed,
      '2026-10-16': DayStatus.freeze,
      '2026-10-17': DayStatus.unscheduled,
      '2026-10-18': DayStatus.done, // unscheduled but done
      '2026-10-21': DayStatus.pending,
      '2026-10-22': DayStatus.future,
    };
    for (final MapEntry(key: k, value: status) in expected.entries) {
      expect(wed.dayStatus(h, d(k)), status, reason: k);
    }
    expect(
      {for (final s in expected.values) s},
      DayStatus.values.toSet(),
      reason: 'every DayStatus is covered',
    );
  });

  test('isDone uses the target in effect that day', () {
    final h = history(
      start: '2026-10-19',
      versions: [('2026-10-19', count(3)), ('2026-10-20', count(6))],
      values: {'2026-10-19': 3, '2026-10-20': 3},
    );
    expect(wed.isDone(h, d('2026-10-19')), isTrue);
    expect(wed.isDone(h, d('2026-10-20')), isFalse);
    expect(wed.isDone(h, d('2026-10-21')), isFalse);
  });

  test('weekProgress counts only days from the start through today', () {
    final h = history(
      start: '2026-10-20',
      schedule: perWeek(4),
      done: ['2026-10-19', '2026-10-20', '2026-10-21', '2026-10-22'],
    );
    expect(wed.weekProgress(h, d('2026-10-21')), (done: 2, target: 4));
    // Other schedules report a target of 1.
    final other = history(start: '2026-10-19', done: ['2026-10-19']);
    expect(wed.weekProgress(other, d('2026-10-21')), (done: 1, target: 1));
  });

  test('a long history (5 years) summarizes quickly', () {
    final h = history(
      start: '2021-10-22',
      done: span('2021-10-22', '2026-10-21'),
    );
    final watch = Stopwatch()..start();
    final s = wed.summarize(h);
    watch.stop();
    expect(s.current, 1826);
    expect(s.best, 1826);
    expect(watch.elapsedMilliseconds, lessThan(100));
  });

  test(
    'currentRunReaches tells whether the run passes a day (research R7)',
    () {
      final unbroken = history(
        start: '2026-10-01',
        done: span('2026-10-01', '2026-10-20'),
      );
      expect(wed.currentRunReaches(unbroken, d('2026-10-05')), isTrue);
      final broken = history(
        start: '2026-10-01',
        done: [
          ...span('2026-10-01', '2026-10-09'),
          ...span('2026-10-11', '2026-10-20'),
        ],
      );
      expect(wed.currentRunReaches(broken, d('2026-10-05')), isFalse);
      expect(wed.currentRunReaches(broken, d('2026-10-12')), isTrue);
      // No units at all (future start) reaches trivially.
      expect(
        wed.currentRunReaches(history(start: '2026-10-25'), d('2026-10-01')),
        isTrue,
      );
    },
  );

  test('HabitHistory loadedFrom does not change the rules', () {
    final h = history(
      start: '2026-10-19',
      done: span('2026-10-19', '2026-10-21'),
    );
    final windowed = h.copyWith(loadedFrom: d('2026-10-20'));
    expect(wed.summarize(windowed), wed.summarize(h));
    expect(windowed, isA<HabitHistory>());
  });
}
