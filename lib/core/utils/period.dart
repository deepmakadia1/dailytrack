import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
// `@immutable` via freezed_annotation's re-export of package:meta, so this
// file stays pure Dart without a new direct dependency.
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:intl/intl.dart';

/// A date range in the device's local calendar (research R13). Boundaries are
/// local midnights, so days stay correct across DST and time zone changes;
/// they are converted to UTC ms only for queries. Pure Dart.
@immutable
sealed class Period {
  const new();

  /// Local midnight that starts the period.
  DateTime get startLocal;

  /// Local midnight after the last day of the period.
  DateTime get endLocalExclusive;

  int get startUtcMs => startLocal.toUtc().millisecondsSinceEpoch;
  int get endUtcMsExclusive => endLocalExclusive.toUtc().millisecondsSinceEpoch;

  bool contains(int utcMs) => utcMs >= startUtcMs && utcMs < endUtcMsExclusive;

  /// The period before this one, or null for a custom range.
  Period? previous();

  /// The period after this one, or null for a custom range.
  Period? next();

  /// Display label. [fullDatePattern] (the SET-01 date format) is used by
  /// custom ranges only; other periods ignore it.
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  });

  @override
  bool operator ==(Object other) =>
      other is Period &&
      other.runtimeType == runtimeType &&
      other.startLocal == startLocal &&
      other.endLocalExclusive == endLocalExclusive;

  @override
  int get hashCode => Object.hash(runtimeType, startLocal, endLocalExclusive);
}

DateTime _midnight(DateTime local) =>
    DateTime(local.year, local.month, local.day);

final class SingleDayPeriod extends Period {
  new(DateTime anyLocal) : startLocal = _midnight(anyLocal);

  @override
  final DateTime startLocal;

  @override
  DateTime get endLocalExclusive =>
      DateTime(startLocal.year, startLocal.month, startLocal.day + 1);

  @override
  SingleDayPeriod previous() => SingleDayPeriod(
    DateTime(startLocal.year, startLocal.month, startLocal.day - 1),
  );

  @override
  SingleDayPeriod next() => SingleDayPeriod(endLocalExclusive);

  @override
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  }) => relativeDayLabel(startLocal, now: now, labels: labels, locale: locale);
}

final class WeekPeriod extends Period {
  /// [firstDayOfWeek] is 1 = Monday … 7 = Sunday (`AppSettings`).
  new(DateTime anyLocal, {required this.firstDayOfWeek})
    : startLocal = DateTime(
        anyLocal.year,
        anyLocal.month,
        anyLocal.day - (anyLocal.weekday - firstDayOfWeek + 7) % 7,
      );

  final int firstDayOfWeek;

  @override
  final DateTime startLocal;

  @override
  DateTime get endLocalExclusive =>
      DateTime(startLocal.year, startLocal.month, startLocal.day + 7);

  @override
  WeekPeriod previous() => WeekPeriod(
    DateTime(startLocal.year, startLocal.month, startLocal.day - 7),
    firstDayOfWeek: firstDayOfWeek,
  );

  @override
  WeekPeriod next() =>
      WeekPeriod(endLocalExclusive, firstDayOfWeek: firstDayOfWeek);

  @override
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  }) {
    final f = DateFormat('d MMM', locale);
    final last = DateTime(
      endLocalExclusive.year,
      endLocalExclusive.month,
      endLocalExclusive.day - 1,
    );
    return '${f.format(startLocal)} – ${f.format(last)}';
  }
}

final class MonthPeriod extends Period {
  new(DateTime anyLocal) : startLocal = DateTime(anyLocal.year, anyLocal.month);

  @override
  final DateTime startLocal;

  @override
  DateTime get endLocalExclusive =>
      DateTime(startLocal.year, startLocal.month + 1);

  @override
  MonthPeriod previous() =>
      MonthPeriod(DateTime(startLocal.year, startLocal.month - 1));

  @override
  MonthPeriod next() => MonthPeriod(endLocalExclusive);

  @override
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  }) => DateFormat.yMMMM(locale).format(startLocal);
}

final class YearPeriod extends Period {
  new(DateTime anyLocal) : startLocal = DateTime(anyLocal.year);

  @override
  final DateTime startLocal;

  @override
  DateTime get endLocalExclusive => DateTime(startLocal.year + 1);

  @override
  YearPeriod previous() => YearPeriod(DateTime(startLocal.year - 1));

  @override
  YearPeriod next() => YearPeriod(endLocalExclusive);

  @override
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  }) => DateFormat.y(locale).format(startLocal);
}

/// An inclusive range of whole local days. Has no previous or next.
final class CustomPeriod extends Period {
  new(DateTime fromLocal, DateTime toLocalInclusive)
    : startLocal = _midnight(fromLocal),
      endLocalExclusive = DateTime(
        toLocalInclusive.year,
        toLocalInclusive.month,
        toLocalInclusive.day + 1,
      ) {
    if (!endLocalExclusive.isAfter(startLocal)) {
      throw ArgumentError('Custom range ends before it starts');
    }
  }

  @override
  final DateTime startLocal;

  @override
  final DateTime endLocalExclusive;

  @override
  Period? previous() => null;

  @override
  Period? next() => null;

  @override
  String label(
    String locale,
    RelativeDayLabels labels, {
    required DateTime now,
    String fullDatePattern = defaultFullDatePattern,
  }) {
    // Full dates follow the SET-01 date format (feature 007 R13).
    final f = DateFormat(fullDatePattern, locale);
    final last = DateTime(
      endLocalExclusive.year,
      endLocalExclusive.month,
      endLocalExclusive.day - 1,
    );
    return '${f.format(startLocal)} – ${f.format(last)}';
  }
}
