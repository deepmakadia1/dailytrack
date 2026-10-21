/// How one day of one habit looks (research R6). Computed, never stored.
enum DayStatus {
  /// The entry reaches the target in effect that day.
  done,

  /// Some progress on a due day, below the target.
  partial,

  /// A due day that is over with no progress and no freeze.
  missed,

  /// A streak freeze day.
  freeze,

  /// Not due (or, for "times per week", the week's target is already met).
  unscheduled,

  /// Before the habit's start date.
  beforeStart,

  /// After today.
  future,

  /// Today, due and not yet done. Never breaks a streak.
  pending,
}
