import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A local calendar day, the unit of every habit rule (research R5,
/// Constitution III). Arithmetic runs on UTC midnights, so a daylight-saving
/// change in the device's zone never makes a day 23 or 25 hours long.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  const new(this.year, this.month, this.day);

  /// The calendar day [dateTime] falls on in the device's zone. A UTC value
  /// is converted to local time first.
  factory fromDateTime(DateTime dateTime) {
    final local = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return LocalDate(local.year, local.month, local.day);
  }

  /// Parses a `yyyy-MM-dd` key. Throws [FormatException] if malformed.
  ///
  /// Pure calendar arithmetic: building a local `DateTime` needs a time-zone
  /// lookup, which made loading a 400-day history slow (DSH-01 SC-001).
  /// Same result as parsing with `DateKeys`.
  factory fromKey(String key) {
    final match = _keyPattern.firstMatch(key);
    if (match == null) throw FormatException('Invalid date key', key);
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    final utc = DateTime.utc(y, m, d);
    if (utc.month != m || utc.day != d) {
      throw FormatException('Invalid date key', key);
    }
    return LocalDate(y, m, d);
  }

  static final RegExp _keyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// The `yyyy-MM-dd` key stored in `habit_entries.date_key`. Same format
  /// as `DateKeys.fromLocal`, without building a local `DateTime`.
  String get key =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  LocalDate addDays(int days) {
    final d = _utc.add(Duration(days: days));
    return LocalDate(d.year, d.month, d.day);
  }

  /// Whole days from [other] to this day (positive when this is later).
  int difference(LocalDate other) => _utc.difference(other._utc).inDays;

  /// The first day of this day's week, where weeks start on
  /// [firstDayOfWeek] (1 = Monday … 7 = Sunday, settings `firstDayOfWeek`).
  LocalDate startOfWeek(int firstDayOfWeek) =>
      addDays(-((weekday - firstDayOfWeek) % 7));

  bool isBefore(LocalDate other) => compareTo(other) < 0;

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}
