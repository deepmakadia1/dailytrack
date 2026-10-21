import 'dart:math' as math;

import 'package:dailytrack/features/expense/domain/enums.dart';
// `@immutable` via freezed_annotation's re-export of package:meta.
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// What a schedule says in words, for presentation to turn into ARB text
/// ("Every month on 5th").
@immutable
final class ScheduleDescription {
  const new({
    required this.frequency,
    required this.interval,
    required this.weekday,
    required this.day,
    required this.month,
  });

  final Frequency frequency;
  final int interval;

  /// 1 = Monday … 7 = Sunday.
  final int weekday;

  /// Day of the month of the anchor (1–31).
  final int day;

  /// Month of the anchor (1–12).
  final int month;

  @override
  bool operator ==(Object other) =>
      other is ScheduleDescription &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.weekday == weekday &&
      other.day == day &&
      other.month == month;

  @override
  int get hashCode => Object.hash(frequency, interval, weekday, day, month);
}

int _daysIn(int year, int month) => DateTime(year, month + 1, 0).day;

/// A recurring rule's schedule (research R8). Pure Dart.
///
/// Every occurrence is computed from the anchor, never from the previous
/// one, with the local `DateTime` constructor: wall-clock time survives DST
/// and time zone changes, and a rule on the 31st runs on the last day of
/// shorter months and returns to the 31st when the month has it (EXP-10
/// criterion 1). A yearly rule on 29 February runs on 28 February in other
/// years.
final class RecurrenceSchedule {
  new({required this.anchorLocal, required this.frequency, this.interval = 1}) {
    if (interval < 1) throw ArgumentError.value(interval, 'interval');
  }

  /// Local date and time of the first occurrence (n = 0).
  final DateTime anchorLocal;
  final Frequency frequency;
  final int interval;

  /// The [n]th occurrence (n ≥ 0), local time.
  DateTime occurrence(int n) {
    if (n < 0) throw RangeError.value(n, 'n');
    final a = anchorLocal;
    final step = n * interval;
    DateTime at(int y, int m, int d) =>
        DateTime(y, m, d, a.hour, a.minute, a.second, a.millisecond);
    switch (frequency) {
      case Frequency.daily:
        return at(a.year, a.month, a.day + step);
      case Frequency.weekly:
        return at(a.year, a.month, a.day + 7 * step);
      case Frequency.monthly:
        final months = a.month - 1 + step;
        final y = a.year + months ~/ 12;
        final m = months % 12 + 1;
        return at(y, m, math.min(a.day, _daysIn(y, m)));
      case Frequency.yearly:
        final y = a.year + step;
        return at(y, a.month, math.min(a.day, _daysIn(y, a.month)));
    }
  }

  /// A lower bound for the first index at or after [t], from calendar
  /// arithmetic; [indexAtOrAfter] corrects it by a few steps at most.
  int _estimate(DateTime t) {
    final a = anchorLocal;
    final raw = switch (frequency) {
      Frequency.daily => _wholeDays(a, t) ~/ interval,
      Frequency.weekly => _wholeDays(a, t) ~/ (7 * interval),
      Frequency.monthly =>
        ((t.year - a.year) * 12 + t.month - a.month) ~/ interval,
      Frequency.yearly => (t.year - a.year) ~/ interval,
    };
    return math.max(0, raw - 2);
  }

  /// Calendar days from [a]'s date to [b]'s date (DST-safe: compares UTC
  /// midnights of the local dates).
  static int _wholeDays(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  /// The smallest n ≥ 0 with `occurrence(n) >= t`. O(1): an arithmetic
  /// estimate plus a bounded correction, even years behind.
  int indexAtOrAfter(DateTime t) {
    final local = t.toLocal();
    var n = _estimate(local);
    while (occurrence(n).isBefore(local)) {
      n++;
    }
    while (n > 0 && !occurrence(n - 1).isBefore(local)) {
      n--;
    }
    return n;
  }

  /// The smallest n ≥ 0 with `occurrence(n) > t`.
  int indexAfter(DateTime t) {
    final n = indexAtOrAfter(t);
    return occurrence(n).isAtSameMomentAs(t) ? n + 1 : n;
  }

  /// The first occurrence strictly after [t] (the next run after now).
  DateTime firstAfter(DateTime t) => occurrence(indexAfter(t));

  ScheduleDescription describe() => ScheduleDescription(
    frequency: frequency,
    interval: interval,
    weekday: anchorLocal.weekday,
    day: anchorLocal.day,
    month: anchorLocal.month,
  );
}
