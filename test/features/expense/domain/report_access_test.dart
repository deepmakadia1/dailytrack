import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/usecases/report_access.dart';
import 'package:flutter_test/flutter_test.dart';

/// ReportAccess: the clarification Q1 matrix (FR-039,
/// contracts/repositories.md). True = needs the advancedReports unlock.
void main() {
  const free = [ReportTab.overview, ReportTab.categories];
  const advanced = [ReportTab.trends, ReportTab.accounts];

  void expectFreeOnBasicTabs(Period p, DateTime now, {required bool isFree}) {
    for (final tab in free) {
      expect(requiresAdvanced(tab, p, now), !isFree, reason: '$tab $p');
    }
    for (final tab in advanced) {
      expect(requiresAdvanced(tab, p, now), isTrue, reason: '$tab $p');
    }
  }

  for (final now in [DateTime(2026, 10, 15, 12), DateTime(2027, 1, 1, 9)]) {
    group('today = $now', () {
      final current = MonthPeriod(now);
      final previous = current.previous();

      test('current and previous month: free on Overview and Categories, '
          'advanced on Trends and Accounts', () {
        expectFreeOnBasicTabs(current, now, isFree: true);
        expectFreeOnBasicTabs(previous, now, isFree: true);
      });

      test('two months back and any future month are advanced', () {
        expectFreeOnBasicTabs(previous.previous(), now, isFree: false);
        expectFreeOnBasicTabs(current.next(), now, isFree: false);
      });

      test(
        'a week containing today is free; a week spanning the previous '
        "month's first day is free; a week entirely before it is advanced",
        () {
          expectFreeOnBasicTabs(
            WeekPeriod(now, firstDayOfWeek: 1),
            now,
            isFree: true,
          );
          final spanning = WeekPeriod(previous.startLocal, firstDayOfWeek: 1);
          expect(
            spanning.startLocal.isBefore(previous.startLocal) ||
                spanning.startLocal == previous.startLocal,
            isTrue,
          );
          expectFreeOnBasicTabs(spanning, now, isFree: true);
          final before = WeekPeriod(
            previous.startLocal.subtract(const Duration(days: 8)),
            firstDayOfWeek: 1,
          );
          expect(
            before.endLocalExclusive.isAfter(previous.startLocal),
            isFalse,
          );
          expectFreeOnBasicTabs(before, now, isFree: false);
        },
      );

      test('a week spanning the end of the current month is free; a week '
          'entirely in next month is advanced', () {
        final lastDay = current.endLocalExclusive.subtract(
          const Duration(days: 1),
        );
        expectFreeOnBasicTabs(
          WeekPeriod(lastDay, firstDayOfWeek: 1),
          now,
          isFree: true,
        );
        final next = WeekPeriod(
          current.endLocalExclusive.add(const Duration(days: 7)),
          firstDayOfWeek: 1,
        );
        expect(next.startLocal.isBefore(current.endLocalExclusive), isFalse);
        expectFreeOnBasicTabs(next, now, isFree: false);
      });

      test('Year and Custom are advanced on every tab', () {
        for (final p in [
          YearPeriod(now),
          CustomPeriod(current.startLocal, current.startLocal),
        ]) {
          for (final tab in ReportTab.values) {
            expect(requiresAdvanced(tab, p, now), isTrue, reason: '$tab $p');
          }
        }
      });
    });
  }

  test('1 Jan 2027: the previous month is December 2026', () {
    final now = DateTime(2027, 1, 1, 9);
    expect(
      requiresAdvanced(
        ReportTab.overview,
        MonthPeriod(DateTime(2026, 12)),
        now,
      ),
      isFalse,
    );
    expect(
      requiresAdvanced(
        ReportTab.overview,
        MonthPeriod(DateTime(2026, 11)),
        now,
      ),
      isTrue,
    );
  });
}
