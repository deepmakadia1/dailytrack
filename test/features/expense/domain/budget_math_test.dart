import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:flutter_test/flutter_test.dart';

/// Budget math (research R5), all in whole paise. EXP-08 criteria and US1
/// scenarios 2, 3 and 11, plus the "Over 100%" and "exactly at a
/// threshold" edge cases.
void main() {
  group('EXP-08 "Per day left" uses remaining days including today', () {
    // (year, month, days in month)
    const months = [
      (2027, 2, 28),
      (2028, 2, 29),
      (2026, 9, 30),
      (2026, 10, 31),
    ];
    for (final (y, m, days) in months) {
      final key = '$y-${m.toString().padLeft(2, '0')}';
      test('$key: first, middle and last day', () {
        expect(daysLeftInclusive(key, DateTime(y, m, 1, 8)), days);
        expect(daysLeftInclusive(key, DateTime(y, m, 15, 23)), days - 14);
        expect(daysLeftInclusive(key, DateTime(y, m, days, 23, 59)), 1);
      });
    }

    test('31 Oct with ₹310 left → ₹310 for 1 day; 1 Oct → 31 days', () {
      expect(perDayLeft(remainingMinor: 31000, daysLeft: 1), 31000);
      expect(daysLeftInclusive('2026-10', DateTime(2026, 10)), 31);
      expect(perDayLeft(remainingMinor: 31000, daysLeft: 31), 1000);
    });
  });

  test('per day left rounds down to whole paise', () {
    expect(perDayLeft(remainingMinor: 1000, daysLeft: 3), 333);
    expect(perDayLeft(remainingMinor: 2, daysLeft: 3), 0);
  });

  test('nothing left → no per-day amount', () {
    expect(perDayLeft(remainingMinor: 0, daysLeft: 5), isNull);
    expect(perDayLeft(remainingMinor: -500, daysLeft: 5), isNull);
    expect(perDayLeft(remainingMinor: 500, daysLeft: null), isNull);
  });

  test('past month → no days left; future month → all its days', () {
    final now = DateTime(2026, 10, 14);
    expect(daysLeftInclusive('2026-09', now), isNull);
    expect(daysLeftInclusive('2026-11', now), 30);
    expect(daysLeftInclusive('2027-02', now), 28);
    expect(monthPhase('2026-09', now), MonthPhase.past);
    expect(monthPhase('2026-10', now), MonthPhase.current);
    expect(monthPhase('2026-11', now), MonthPhase.future);
    expect(monthPhase('2025-12', now), MonthPhase.past);
  });

  group('levels (US1 s3, edge "exactly at a threshold")', () {
    BudgetLevel level(int spent) =>
        levelFor(spentMinor: spent, limitMinor: 100000);

    test('79.99% under, exactly 80% warning, exactly 100% warning, '
        '100.01% over', () {
      expect(level(79990), BudgetLevel.under);
      expect(level(80000), BudgetLevel.warning);
      expect(level(99999), BudgetLevel.warning);
      expect(level(100000), BudgetLevel.warning);
      expect(level(100010), BudgetLevel.over);
      expect(level(0), BudgetLevel.under);
    });

    test('thresholds count as reached exactly at 80% and 100%', () {
      bool hit(BudgetThreshold t, int spent) =>
          reaches(t, spentMinor: spent, limitMinor: 100000);
      expect(hit(BudgetThreshold.p80, 79999), isFalse);
      expect(hit(BudgetThreshold.p80, 80000), isTrue);
      expect(hit(BudgetThreshold.p100, 99999), isFalse);
      expect(hit(BudgetThreshold.p100, 100000), isTrue);
    });

    test('integer math has no rounding error at large limits', () {
      expect(
        levelFor(spentMinor: 79999999920, limitMinor: 99999999900),
        BudgetLevel.warning,
      );
      expect(
        levelFor(spentMinor: 79999999919, limitMinor: 99999999900),
        BudgetLevel.under,
      );
    });
  });

  test('percent is a whole number and may exceed 100 (edge "Over 100%")', () {
    expect(percentOf(spentMinor: 135000, limitMinor: 100000), 135);
    expect(percentOf(spentMinor: 4700, limitMinor: 6000), 78);
    expect(percentOf(spentMinor: 0, limitMinor: 6000), 0);
  });

  group('month keys', () {
    test('monthKeyOf pads year and month', () {
      expect(monthKeyOf(DateTime(2026, 10, 31, 23, 59)), '2026-10');
      expect(monthKeyOf(DateTime(2027)), '2027-01');
    });

    test('shiftMonthKey crosses year boundaries', () {
      expect(shiftMonthKey('2026-01', -1), '2025-12');
      expect(shiftMonthKey('2026-12', 1), '2027-01');
      expect(shiftMonthKey('2026-10', -13), '2025-09');
    });

    test('monthRangeUtc matches the local month period (local midnights)', () {
      final range = monthRangeUtc('2026-10');
      final period = MonthPeriod(DateTime(2026, 10));
      expect(range.startUtcMs, period.startUtcMs);
      expect(range.endUtcMsExclusive, period.endUtcMsExclusive);
      // 23:59 on 31 October local counts toward October (edge case).
      final late = DateTime(
        2026,
        10,
        31,
        23,
        59,
      ).toUtc().millisecondsSinceEpoch;
      expect(
        late >= range.startUtcMs && late < range.endUtcMsExclusive,
        isTrue,
      );
      final next = DateTime(2026, 11).toUtc().millisecondsSinceEpoch;
      expect(next, range.endUtcMsExclusive);
    });

    test('malformed keys are rejected', () {
      for (final bad in ['2026-1', '2026-13', '26-10', '2026/10']) {
        expect(() => monthStartLocal(bad), throwsFormatException, reason: bad);
      }
    });
  });

  group('buildBudgetStatus (US1 s2, s11)', () {
    Budget budget(int limit, {String month = '2026-10'}) => Budget(
      id: 'b',
      monthKey: month,
      limitMinor: limit,
      rollover: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    test('current month: remaining, percent, days and per day', () {
      final s = buildBudgetStatus(
        budget: budget(3000000),
        spentMinor: 1240000,
        nowLocal: DateTime(2026, 10, 14, 10),
      );
      expect(s.remainingMinor, 1760000);
      expect(s.percent, 41);
      expect(s.level, BudgetLevel.under);
      expect(s.monthPhase, MonthPhase.current);
      expect(s.daysLeft, 18);
      expect(s.perDayLeftMinor, 1760000 ~/ 18);
    });

    test('over budget: negative remaining and no per-day amount', () {
      final s = buildBudgetStatus(
        budget: budget(600000),
        spentMinor: 810000,
        nowLocal: DateTime(2026, 10, 14),
      );
      expect(s.remainingMinor, -210000);
      expect(s.percent, 135);
      expect(s.level, BudgetLevel.over);
      expect(s.perDayLeftMinor, isNull);
    });

    test('past month: no days left; future month: all days', () {
      final past = buildBudgetStatus(
        budget: budget(1000, month: '2026-09'),
        spentMinor: 500,
        nowLocal: DateTime(2026, 10, 14),
      );
      expect(past.monthPhase, MonthPhase.past);
      expect(past.daysLeft, isNull);
      expect(past.perDayLeftMinor, isNull);
      final future = buildBudgetStatus(
        budget: budget(3000, month: '2026-11'),
        spentMinor: 0,
        nowLocal: DateTime(2026, 10, 14),
      );
      expect(future.daysLeft, 30);
      expect(future.perDayLeftMinor, 100);
    });
  });
}
