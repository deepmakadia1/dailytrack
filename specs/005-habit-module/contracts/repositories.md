# Contract: Habit domain interfaces and use cases (feature 005)

All files are under `lib/features/habit/domain/` and are pure Dart (no Flutter, no Drift).
Time comes from an injected `Clock` (`package:clock`). Streams emit on every relevant change made
anywhere in the app (FR-007).

## HabitRepository (`repositories/habit_repository.dart`)

```dart
abstract interface class HabitRepository {
  /// Active (not archived, not deleted) habits in sort order.
  Stream<List<Habit>> watchActive();
  Stream<List<Habit>> watchArchived();          // newest archivedAt first
  Stream<Habit?> watchById(String id);          // null when deleted
  Future<Habit?> byId(String id);
  Future<List<Habit>> activeHabits();           // one-shot, for reminders

  /// Creates the habit and schedule version 1 (effective from startDate).
  Future<Habit> create(HabitDraft draft);

  /// Updates the habit. A changed schedule or target writes a version
  /// effective from today (same-day versions are replaced) (research R3).
  /// Throws HabitNotFound, KindLocked.
  Future<Habit> update(String id, HabitDraft draft);

  Future<void> archive(String id);              // sets archivedAt
  Future<void> restore(String id);              // clears archivedAt, sortOrder = max active + 1
  Future<void> undoArchive(String id);          // clears archivedAt, keeps sortOrder (Undo)
  Future<void> delete(String id);               // soft-deletes habit, schedules, entries
  Future<void> reorder(List<String> idsInOrder);

  /// Debug grant (research R9). Returns the new count; no-op at 2.
  Future<int> addFreeze(String id);
}
```

## HabitEntryRepository (`repositories/habit_entry_repository.dart`)

```dart
abstract interface class HabitEntryRepository {
  /// Histories of all active habits with live entries on or after [from]
  /// (HAB-01 and Home window, research R7). Only id/date/value/freeze.
  Stream<List<HabitHistory>> watchActiveHistories({required LocalDate from});

  /// Full history of one habit (HAB-03, and the R7 fallback).
  Stream<HabitHistory?> watchHistory(String habitId);
  Future<HabitHistory?> history(String habitId);

  /// Entries with notes, newest first (HAB-03 notes list).
  Stream<List<HabitEntry>> watchNotes(String habitId);

  /// Applies [op] in one transaction: entry upsert/soft delete, freeze
  /// count, milestone compare-and-set (research R8). Throws
  /// FreezeNotAllowed, NoFreezesLeft, DayNotEditable, HabitNotFound.
  Future<DayWriteResult> apply(String habitId, LocalDate date, DayOp op);
}

sealed class DayOp {}           // Toggle, Increment, SetValue(int), SetNote(String?),
                                // UseFreeze(allowToday: bool), Restore(EntrySnapshot)

final class DayWriteResult {
  final EntrySnapshot before;   // for Undo
  final StreakSummary summary;  // after the write
  final Milestone? milestone;   // highest newly celebrated, if any
}
```

The engine runs inside `apply` (the data layer calls the pure `StreakEngine` and
`selectNewMilestones`), so milestone bits are set atomically with the write.

## Ports (`ports/`)

```dart
/// Implemented in data/ over core NotificationService (research R10).
abstract interface class HabitReminderScheduler {
  Future<void> reconcile(String habitId);       // cancel all 24 ids, schedule plan
  Future<void> reconcileAll();                   // every active habit
  Future<void> cancel(String habitId);
  Future<void> cancelAll();                      // module disabled
  Future<bool> exactAlarmsAllowed();             // HAB-02 hint
}
```

## Use cases (`usecases/` and `streaks/`, `reminders/`)

| Name | Signature | Notes |
| --- | --- | --- |
| `StreakEngine` | `StreakEngine(Clock, {int firstDayOfWeek})`; `summarize(HabitHistory)`, `dayStatus(HabitHistory, LocalDate)`, `isScheduledOn(...)`, `weekProgress(...)`, `scheduleOn(HabitHistory, LocalDate)` | Research R6 |
| `selectNewMilestones` | `(int currentStreak, Set<Milestone> celebrated) → ({Set<Milestone> toSet, Milestone? show})` | Highest shown, all passed recorded |
| `FreezePolicy` | `check(HabitHistory, LocalDate day, {required bool allowToday, required int available}) → FreezeDecision` | Research R8, Edge Cases |
| `validateHabit` | `(HabitDraft, {Habit? existing}) → List<HabitFieldError>` | data-model §5.1 |
| `planReminders` | `(Habit, {required DateTime now, required bool doneToday, required bool weekTargetMet}) → List<PlannedReminder>` | Research R10 |
| `reminderIdsFor` | `(String habitId) → List<int>` (24 ids) | Uses core `stableNotificationId` |
| `HabitDayWriter` | `write(habitId, date, op) → DayWriteResult` | Calls `HabitEntryRepository.apply`, then `HabitReminderScheduler.reconcile` when the day is in the current week |
| `scheduleText` | `(HabitSchedule, {int doneThisWeek}) → ScheduleTextData` | Data for "Daily", "Mon, Wed, Fri", "3× per week · 1 left"; presentation formats with ARB |
| `habitTemplates` | `const List<HabitTemplate>` | Research R16 |

## Errors (`errors.dart`)

`HabitNotFound`, `KindLocked`, `DayNotEditable` (future or before start), `FreezeNotAllowed`
(today from the card, done day, outside 1–3 days), `NoFreezesLeft`, `HabitValidationFailed(errors)`.
