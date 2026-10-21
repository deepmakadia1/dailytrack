import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// How a planned reminder repeats (research R10).
enum ReminderRepeat { daily, weekly }

/// One notification the reminder scheduler should register (research R10).
@immutable
final class PlannedReminder {
  const new({required this.id, required this.firstAt, required this.repeat});

  final int id;

  /// Local wall-clock time of the first fire.
  final DateTime firstAt;
  final ReminderRepeat repeat;
}
