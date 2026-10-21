# Contract: Screens, controllers, and states (feature 005)

Every screen has one Riverpod Notifier with an immutable freezed state that handles loading, data,
and error explicitly (Constitution II). Screens import only `domain/` and `core/`. Skeletons appear
only after 300 ms; errors use `ErrorState` with "Try again"; empty states use `EmptyState`.
Banner and native ad slots are not built (all ads out of scope).

## HAB-01 Habits today: `HabitsTodayScreen` / `HabitsTodayController`

State:
```
HabitsTodayState {
  AsyncValue<HabitsTodayData> data;
}
HabitsTodayData {
  LocalDate today, selected;
  int weekOffset;                          // 0 = current week, -1 = previous (R14)
  List<WeekDayCell> week;                  // 7 cells: date, ratio done/scheduled, selectable
  int doneCount, scheduledCount;           // progress header for selected day
  List<HabitCardData> scheduled, notScheduled;
  bool allDoneToday;                       // banner (only when selected == today)
  bool reorderMode;
}
HabitCardData { Habit habit; DayStatus status; int value; int target; String? unit;
                ScheduleTextData schedule; int currentStreak; StreakUnit unit; bool canSkipToday; }
```
Methods: `selectDay(LocalDate)`, `pageWeek(int offset)`, `toggle(id)`, `increment(id)`,
`setValue(id, int)`, `setNote(id, String?)`, `skipToday(id)`, `archive(id)`, `undo(EntrySnapshot)`,
`undoArchive(id)`, `setReorderMode(bool)`, `reorder(List<String>)`.
Each write returns `DayWriteResult`; the screen shows the check animation + light haptic on a new
`done`, the `MilestoneSheet` when `milestone != null`, and an `UndoSnackBar` on uncheck, Skip today,
and archive.

Widgets: `WeekStrip`, `ProgressHeader`, `HabitCard` (yes/no check button or count `+` with
long-press `ValueEntryDialog`), `HabitCardMenu` (Edit, Add note for today, Skip today, Archive),
`AllDoneBanner`, `TemplateChips` (empty state), `ReorderableHabitList`. FAB `+` → `/habits/add`.

## HAB-02 Add / edit habit: `HabitFormScreen` / `HabitFormController`

State: `HabitFormState { HabitDraft draft; Habit? original; List<HabitFieldError> errors;
bool saving; bool dirty; bool notificationsAllowed; bool exactAlarmsAllowed; List<String> nameSuggestions; }`

Methods: `load({String? id, String? templateId})`, field setters, `addReminder(ReminderTime)`,
`removeReminder(int)`, `save() → SaveResult` (validate → create/update → reconcile reminders),
`archive()` (its Undo calls `HabitRepository.undoArchive`, keeping the sort position), `undoArchive()`,
`delete()`.

Layout per spec User Story 1 scenario 2; goal type read-only in edit mode; sticky "Save habit"
lifted above the keyboard; overflow Archive and Delete (`ConfirmDialog`) in edit mode; "Discard
changes?" on back when `dirty`. Hints: notifications denied (FR, User Story 4 scenario 7) and
inexact alarms ("may be a few minutes late").

## HAB-03 Habit detail: `HabitDetailScreen` / `HabitDetailController`

State:
```
HabitDetailData {
  Habit habit; StreakSummary summary; HabitDetailViewModel vm;   // research R13
  List<HabitEntry> notes;
  bool advancedReportsUnlocked; bool showDebugFreezeButton;
  List<LocalDate> freezeableDays;          // FreezePolicy, 1–3 days back
}
```
Methods: `editDay(LocalDate, {int? value, bool? toggle, String? note})`, `useFreeze(LocalDate)`,
`addDebugFreeze()`, `undo(EntrySnapshot)`, `shareHeatmap(Uint8List png)`.

Sections in order: header (CategoryAvatar, name, schedule text, Edit), `StatTiles` (2×2),
`HabitCalendar` (PageView by month back to start date; `DayEditSheet` for value and note),
`YearHeatmap` (CustomPaint + share), `WeeklyBarsChart` in `LockedFeatureOverlay` when locked,
`NotesList`, `FreezeCard` ("Freezes available: N", "Use a freeze" on a missed day picker,
debug button per R9).

## HAB-04 Archived habits: `ArchivedHabitsScreen` / `ArchivedHabitsController`

State: `AsyncValue<List<ArchivedHabitRow>>` with `Habit habit; DateTime archivedAt; int bestStreak`.
Methods: `restore(id)` (snackbar with Undo → archive again), `deletePermanently(id)` after
`ConfirmDialog`. Empty state text only.

## Milestone sheet: `MilestoneSheet` (shared within the habit feature)

`AppBottomSheet` with the milestone number, unit (days/weeks), encouragement text, "Share streak"
(filled) and "Close" (text). Share renders `StreakShareCard` off-screen in a `RepaintBoundary` →
`captureBoundaryPng` → `ImageSharer.sharePng(fileName: 'streak.png')`. Respects
`MediaQuery.disableAnimations`.

## Home card: `HabitDashboardCard` / `HabitDashboardController`

Data: `doneCount`, `scheduledCount`, `List<HabitCheckData>` for today's scheduled habits. `ProgressRing`
with "X of Y done today"; round check buttons; yes/no tap → `toggle`; count tap → `CountPopup` with
"+1" and custom value; long-press → `context.push('/habits/<id>')`; milestone sheet on milestone;
empty state "Create your first habit" → `/habits/add`.

## Accessibility and copy (all screens)

- 48 dp targets; semantic labels on check buttons ("Mark Read done", "Read, 12 of 20 pages").
- Status never by color only: done = check icon, freeze = snowflake icon, missed = outline + label.
- ARB plurals for days/weeks, "X of Y done", "N left"; no concatenation.
- 200% font scale and 360 dp width without overflow (week strip cells wrap labels to one letter
  when needed).
