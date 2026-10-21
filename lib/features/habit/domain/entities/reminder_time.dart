import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A reminder time of day, stored as `HH:mm` (spec §4 `reminderTimes`).
@immutable
final class ReminderTime implements Comparable<ReminderTime> {
  const new(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour'),
      assert(minute >= 0 && minute < 60, 'minute');

  /// Parses `HH:mm`. Throws [FormatException] if malformed.
  factory parse(String value) {
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    if (match == null) throw FormatException('Invalid reminder time', value);
    return ReminderTime(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  final int hour;
  final int minute;

  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(ReminderTime other) =>
      (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => format();
}
