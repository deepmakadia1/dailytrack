// Typed failures of the Habit domain (contracts/repositories.md).

/// Any storage failure. Screens show their error state, or keep a form open.
final class HabitStorageFailure implements Exception {
  const new([this.cause]);

  final Object? cause;

  @override
  String toString() => 'HabitStorageFailure($cause)';
}

/// A missing or deleted habit.
final class HabitNotFound implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'HabitNotFound($id)';
}

/// An edit tried to change the goal type, which is fixed after create
/// (spec Edge Cases "Goal type").
final class KindLocked implements Exception {
  const new();

  @override
  String toString() => 'KindLocked';
}

/// A day that cannot be edited: after today or before the start date.
final class DayNotEditable implements Exception {
  const new(this.dateKey);

  final String dateKey;

  @override
  String toString() => 'DayNotEditable($dateKey)';
}

/// Why a freeze cannot go on a day (spec Edge Cases "Freeze window").
enum FreezeRejection {
  future,
  beforeStart,
  alreadyDone,
  alreadyFrozen,
  notScheduled,
  today,
  tooOld,
}

final class FreezeNotAllowed implements Exception {
  const new(this.reason);

  final FreezeRejection reason;

  @override
  String toString() => 'FreezeNotAllowed(${reason.name})';
}

/// The habit has no stored freeze left (FR-034).
final class NoFreezesLeft implements Exception {
  const new();

  @override
  String toString() => 'NoFreezesLeft';
}

/// A day value outside 0–9,999 or a note over 200 characters
/// (data-model §5.1).
final class InvalidDayInput implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'InvalidDayInput($message)';
}

/// HAB-02 field errors (data-model §5.1).
enum HabitFieldError {
  nameRequired,
  nameTooLong,
  targetOutOfRange,
  unitTooLong,
  weekdayRequired,
  timesOutOfRange,
  tooManyReminders,
  duplicateReminder,
  kindLocked,
}

final class HabitValidationFailed implements Exception {
  const new(this.errors);

  final List<HabitFieldError> errors;

  @override
  String toString() => 'HabitValidationFailed($errors)';
}
