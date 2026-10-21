// Stored as their int index (Drift intEnum).
// Append-only: never reorder or remove values, or stored data and backups
// will decode to the wrong value (data-model.md §2).

/// What a check-in records (spec §4 `habits.kind`).
enum HabitKind { yesNo, count }

/// When a habit is due (spec §4 `habits.scheduleType`).
enum ScheduleType { daily, specificWeekdays, timesPerWeek }
