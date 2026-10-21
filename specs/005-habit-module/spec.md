# Feature Specification: Habit Module (Phase 2, T2.1–T2.4)

**Feature Branch**: `005-habit-module`

**Created**: 2026-10-18

**Status**: Draft

**Input**: User description: "Feature: Habit module. Implement tasks T2.1 to T2.4 from docs/spec.md. Scope: Data layer (spec §4): habits and habit_entries tables with Drift DAOs, domain entities, repository interfaces and implementations, soft delete, and a migration from the feature 003 schema. Streak engine as pure domain logic following the "Business rules for streaks" in §4: current streak, best streak, completion rate over scheduled days, timesPerWeek weekly streaks, freeze days, and back-filling. Exhaustive unit tests with an injected clock. Screens: HAB-01 Habits (today) with week strip and templates, HAB-02 Add/edit habit, HAB-03 Habit detail (stat tiles, calendar, year heatmap, notes, freeze card), HAB-04 Archived habits. Reminders: schedule, reschedule, and cancel habit reminders through NotificationService with stable IDs per habit + reminder index, "Remind me only if not done yet", and rescheduling after device reboot (RECEIVE_BOOT_COMPLETED). Milestone celebration sheet (7, 21, 30, 50, 100, 365) with a "Share streak" image card via share_plus. HabitModule implementing TrackerModule: routes, a simple dashboardCard (progress ring + today's habit checks), quickAddAction, and backupSection stubbed. Gating: the HAB-03 weekly bar chart uses FeatureGate advancedReports with LockedFeatureOverlay. Out of scope (later features): notification action buttons Mark done / Snooze (feature 007), the "Watch an ad to get a freeze" action and all ads (feature 008), and the Home dashboard layout (feature 005). Freezes can be granted only through the dev-only unlock switch for now. Copy the acceptance criteria for HAB-01 to HAB-04 exactly from the spec, except criteria about ads. Follow the UI/UX rules in §15."

**Source of truth**: `docs/spec.md` v1.0, sections 3 (TrackerModule), 4 (habits, habit_entries, unlocks, settings, "Business rules for streaks"), 5 (routes for HAB-01 to HAB-04), 7 (DSH-01 habit summary card and FAB), 9 (HAB-01 to HAB-04), 12 (Habit reminders channel, rescheduling, localization, accessibility), 13 (performance targets, testing), 14 (Phase 2: T2.1–T2.4), and 15 (UI/UX guidelines).

> **Note on scope and wording**: The master spec and the project constitution (Principle VII, "Locked
> Stack") already fix the technology, and the request names project parts the master spec mandates:
> `NotificationService`, `TrackerModule`, `FeatureGate`, `LockedFeatureOverlay`, the reboot
> permission, and the image-sharing library. Requirements below name these and the shared widgets of
> §15.4 only because the master spec or the request fixes them. Everything else is described by
> observable behavior.

> **Feature numbering**: The request calls the Home dashboard layout "feature 005". Because
> `specs/004-keypad-hide-on-scroll` took number 004, this habit feature is `005`. Later work is
> referred to below by its §14 task ID: Home dashboard = T2.5, notification action buttons = T3.4
> ("feature 007" in the request), ads and rewarded freezes = T4.x ("feature 008" in the request).

> **What earlier features already delivered** (see `specs/001-foundation/` to `specs/003-budgets-recurring-reports/`):
> the local database at schema version 3 (settings, accounts, categories, transactions, budgets,
> recurring rules, unlocks); a placeholder `HabitModule` and Habits tab; the `TrackerModule` interface
> and module registry; `NotificationService` with a Budget alerts channel (show, cancel, tap routing;
> no scheduled notifications yet); the notification permission request; the `FeatureGate` with the
> `streakFreeze` and `advancedReports` keys and the dev-only "Unlock all features (debug)" switch on
> the More placeholder screen; and the shared widgets, including `CategoryAvatar`, `ChipSelector`,
> icon and color pickers, `ProgressBarStatus`, `SummaryCard`, `EmptyState`, `ErrorState`,
> `UndoSnackBar`, `ConfirmDialog`, `AppBottomSheet`, and `LockedFeatureOverlay` (which can already
> hide "Watch an ad" and disable "Get Pro"). This feature adds the habits and habit entries stores and
> the upgrade from schema version 3, the streak engine, HAB-01 to HAB-04, habit reminders, the
> milestone sheet, and the real `HabitModule`.

## Clarifications

### Session 2026-10-18

- Q: When the user picks "Skip today" on a habit and a freeze is available, should a freeze be used on today? → A: Option A. Yes. "Skip today" uses a freeze on today when one is available; with no freezes left the menu item is disabled with "No freezes left". The HAB-03 rule "A freeze cannot be applied to today" covers only the HAB-03 freeze card (repairing missed past days).
- Q: With the dev-only "Unlock all features (debug)" switch on, how should a habit get streak freezes? → A: Option A. The HAB-03 freeze card shows a dev-only "Add a freeze (debug)" button that adds 1 freeze per tap, up to 2; it is hidden when the switch is off and never exists in prod builds.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a habit and check it in every day (HAB-01, HAB-02) (Priority: P1)

A user wants to read every day. On the empty Habits tab they tap the "Read" template chip; HAB-02 opens prefilled with the name "Read", a book icon, goal type Count, target 20, unit "pages", and schedule "Every day". They tap "Save habit" and land back on HAB-01, where the habit card shows "0 / 20 pages" with a + button. Each evening they tap + while reading, or long-press + to type "20". When the count reaches 20 the card shows done with a short check animation and a light haptic, the progress header reads "1 of 1 done", the flame shows the streak, and an "All done for today" banner appears.

**Why this priority**: Creating a habit and checking it in daily is the core loop of the module. On its own this story is a working habit tracker.

**Independent Test**: With an injected clock, create one yes/no habit and one count habit, check them in on several days, and confirm entries are stored for the right local dates, the progress header and week strip rings update, and the empty state with template chips appears when there are no habits.

**Acceptance Scenarios** (HAB-01 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] Toggling a yes/no habit creates or deletes the `habit_entries` row for that date key.
- [ ] Streak updates immediately after check-in and matches the rules in section 4.
- [ ] Back-filling yesterday restores a broken streak.
- [ ] Milestone sheet appears once per milestone per habit.

**Acceptance Scenarios** (HAB-02 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] "Specific days" requires at least one weekday.
- [ ] Reminders fire at the set local time, including after a device reboot (`RECEIVE_BOOT_COMPLETED` reschedule).
- [ ] "Remind only if not done" suppresses the notification when today's entry already meets the target.

The milestone and reminder criteria are covered in User Stories 3 and 4.

**Additional scenarios** (derived from the HAB-01 and HAB-02 Layout, Behavior, and States):

1. **Given** no active habits, **When** the user opens the Habits tab (`/habits`), **Then** HAB-01 shows an illustration, "Build your first habit", and template chips Drink water, Read, Walk, Meditate, Wake up early, Study; tapping a chip opens HAB-02 prefilled from that template, and the + FAB opens an empty HAB-02.
2. **Given** HAB-02 is open, **Then** it is a full-screen single-scroll form with, in order: Name (required, at most 40 characters, with suggestions from the templates as the user types), Icon and color pickers, Goal type ("Yes / No" or "Count"; Count shows target number and unit), Schedule (Every day · Specific days with weekday chips · X times per week with a 1–6 stepper), Reminders (up to 3 times, "+ Add reminder" opens a time picker, toggle "Remind me only if not done yet", default on), Start date (default today), and a sticky "Save habit" button.
3. **Given** the user chooses "Specific days" with no weekday selected, **When** they tap Save, **Then** the habit is not saved and the form explains that at least one weekday is needed.
4. **Given** a yes/no habit scheduled today, **When** the user taps its check button, **Then** an entry with value 1 is stored for today's local date and the card shows done; **When** they tap it again, **Then** that entry is removed and a 5-second "Undo" snackbar is shown.
5. **Given** a count habit with target 20 at "12 / 20 pages", **When** the user taps +, **Then** the value becomes 13; **When** they long-press +, **Then** a number entry dialog lets them set any whole value from 0 to 9,999; the day counts as done once the value reaches the target, and values above the target are kept.
6. **Given** habits on the selected day, **Then** HAB-01 lists scheduled habits first, then a collapsed "Not scheduled today" section; each card shows the icon in a colored circle, the name, the schedule text ("Daily", "Mon, Wed, Fri", "3× per week · 1 left"), the current streak with a flame, and the check control on the right.
7. **Given** the week strip, **Then** it shows the 7 days of the current week, starting on the user's first day of the week, each with a mini completion ring; future days are disabled; tapping a past day switches the list and progress header to that date.
8. **Given** today is the first day of the week, **When** the user pages the week strip back, **Then** the previous week is shown and its days that are at most 7 days before today can be selected for back-filling; older days are disabled with a hint that older edits are made from the habit's detail screen.
9. **Given** all habits scheduled today are done, **Then** a one-line "All done for today" banner is shown; it disappears when any of them is unchecked.
10. **Given** the user long-presses a habit card, **Then** a menu offers Edit, Add note for today, Skip today, and Archive. Skip today uses one of the habit's freezes on today (disabled with "No freezes left" when it has none). Archive moves the habit to HAB-04, cancels its reminders, and shows a 5-second Undo.
11. **Given** the user chooses "Reorder" from the overflow menu, **Then** they can drag habits into a new order, which is kept after restart.
12. **Given** an existing habit, **When** the user opens HAB-02 in edit mode (`/habits/:id/edit`) and changes its schedule or target, **Then** past entries are kept, and streaks and completion rate use the old settings for days before the change and the new settings from the change date onward. The overflow menu offers Archive and Delete; Delete asks for confirmation, stating the history that will be removed, then removes the habit and its entries.
13. **Given** the user leaves HAB-02 with unsaved changes, **Then** they are asked "Discard changes?".

---

### User Story 2 - Trustworthy streaks and back-filling (streak engine) (Priority: P1)

A user meditates on weekdays only (Specific days: Mon–Fri). They check in Monday to Friday, and on the next Monday morning the streak still shows 5, not broken by Saturday or Sunday. On Tuesday they realize they forgot to check in on Monday, so the streak shows 0; they select Monday on the week strip, check it, and the streak returns to 6 immediately. Another user runs "3× per week" and sees a weekly streak of 4 weeks.

**Why this priority**: Streaks are the motivation behind the whole module. Wrong or flickering streaks destroy trust, so the rules must be exact and exhaustively tested.

**Independent Test**: Pure domain tests with an injected "today" covering every schedule type, count and yes/no goals, schedule and target changes, freeze days, back-filling, start dates, week boundaries, and month and year boundaries, comparing current streak, best streak, completion rate, and total completions with hand-computed values.

**Acceptance Scenarios** (derived from `docs/spec.md` §4 "Business rules for streaks"):

1. **Given** a daily habit done on each of the last 5 days including today, **Then** the current streak is 5.
2. **Given** a daily habit done on each of the last 5 days but not yet today, **Then** the current streak is 5 (today never breaks the streak until the day is over).
3. **Given** a daily habit done 3 days ago and today but not yesterday or 2 days ago, **Then** the current streak is 1.
4. **Given** a Mon/Wed/Fri habit done on the last three scheduled days, **Then** unscheduled days between them do not break the streak, and the current streak is 3.
5. **Given** a count habit with target 20, **When** a scheduled past day has value 12, **Then** that day breaks the streak.
6. **Given** a habit with a freeze day on a missed scheduled day between done days, **Then** the streak is not broken by that day.
7. **Given** a "3× per week" habit that met its target in each of the last 4 complete weeks, **Then** the current streak is 4 weeks, and the current week does not break it until the week is over.
8. **Given** the user back-fills a missed scheduled day, **Then** current streak, best streak, and completion rate are recomputed and shown immediately on HAB-01, HAB-03, and the Home habit card.
9. **Given** any history, **Then** the best streak is the longest run ever achieved under the same rules, and is never less than the current streak.

---

### User Story 3 - Celebrate milestones and share the streak (Priority: P2)

On the 21st day in a row, the user checks in "Read" and a celebration bottom sheet appears: "21-day streak!" with encouragement and a "Share streak" button. Tapping it renders an image card with the habit's icon, color, name, and "21 days" and opens the system share sheet. Tomorrow's check-in shows no sheet; the next sheet appears at 30.

**Why this priority**: Milestones reward consistency and spread the app by word of mouth, but the tracker works without them.

**Independent Test**: With an injected clock, build a streak to each milestone (7, 21, 30, 50, 100, 365) and confirm the sheet appears exactly once per milestone per habit, including after a streak is broken and rebuilt, and that "Share streak" produces an image and opens the share sheet.

**Acceptance Scenarios**:

1. **Given** a habit whose current streak becomes 7, 21, 30, 50, 100, or 365 through a check-in or back-fill, **And** that milestone was never celebrated for that habit, **Then** the milestone sheet appears once and that milestone is recorded as celebrated for that habit.
2. **Given** a milestone already celebrated for a habit, **When** the streak breaks and later reaches the same number again, **Then** no sheet appears.
3. **Given** one back-fill that joins two runs and passes several uncelebrated milestones at once, **Then** one sheet appears for the highest milestone reached, and all passed milestones are recorded as celebrated.
4. **Given** the milestone sheet, **When** the user taps "Share streak", **Then** an image card with the habit icon, color, name, streak length, and app name is created and the system share sheet opens; no other personal data is in the image.
5. **Given** a "times per week" habit, **Then** its milestones count weeks, and the sheet says weeks.

---

### User Story 4 - Get reminded only when it matters (reminders) (Priority: P2)

The user adds reminders at 7:00 AM and 9:00 PM to "Drink water" with "Remind me only if not done yet" on. At 7:00 AM they get a "Habit reminders" notification; tapping it opens HAB-01 for today. They reach the target by noon, so no 9:00 PM reminder appears. After a phone restart, tomorrow's reminders still fire.

**Why this priority**: Reminders turn intent into habit, but check-in works without them.

**Independent Test**: With a fake notification service and injected clock, save habits with reminders and confirm scheduled times and stable IDs per habit and reminder index; reschedule on edit; cancel on archive, delete, and module disable; suppress after the target is met; reschedule on app start and after reboot.

**Acceptance Scenarios**:

1. **Given** a habit saved with reminder times, **Then** one reminder per time is scheduled on the "Habit reminders" channel at that local time on the habit's scheduled days, each with a stable ID derived from the habit and the reminder's index, so saving again replaces rather than duplicates it.
2. **Given** the user edits a habit's reminder times, schedule, or name, **When** they save, **Then** its reminders are rescheduled, and removed reminder slots are cancelled.
3. **Given** "Remind me only if not done yet" is on, **When** today's entry meets the target (or a "times per week" habit has already met this week's target), **Then** the rest of today's reminders for that habit are not shown; unchecking today makes later reminders for today show again.
4. **Given** "Remind me only if not done yet" is off, **Then** reminders are shown even when the habit is done.
5. **Given** a habit is archived, deleted, or the Habit module is turned off, **Then** all its reminders are cancelled; restoring the habit or turning the module back on reschedules them.
6. **Given** the device restarts, or the app starts, **Then** every active habit's reminders are rescheduled.
7. **Given** the user has denied notifications, **Then** HAB-02 shows a one-line hint that reminders need notification permission, and saving still works.
8. **Given** the user taps a habit reminder with app lock off, **Then** the app opens HAB-01 for today; with app lock on, the user lands on the unlock screen (forwarding after unlock comes in T3.1).

---

### User Story 5 - Review a habit's history and repair a missed day (HAB-03) (Priority: P2)

The user taps their "Walk" card and sees HAB-03: a header with icon, name, schedule, and Edit; four stat tiles (Current streak, Best streak, Completion rate (last 30 days), Total completions); a month calendar with done days filled in the habit color, freeze days with a snowflake, and missed scheduled days outlined; a year heatmap; a notes list; and a streak freeze card. They tap last Tuesday in the calendar to add a note "Rainy, walked indoors". They see they missed yesterday, use a freeze on it, and the streak is restored.

**Why this priority**: The detail view explains progress and allows repairs, but daily check-in works without it.

**Independent Test**: With seeded entries and an injected clock, open HAB-03 and confirm stat tile values, calendar markings, heatmap intensities, notes ordering, freeze rules, and the locked weekly chart.

**Acceptance Scenarios** (HAB-03 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] Completion rate counts only scheduled days.
- [ ] A freeze cannot be applied to today or to a day older than 3 days.
- [ ] Heatmap renders 365 days in under 100 ms (precompute in the controller).

**Additional scenarios** (derived from the HAB-03 Layout and Behavior):

1. **Given** the user opens a habit (`/habits/:id`), **Then** HAB-03 shows, in order: header (icon, name, schedule text, Edit button), 2×2 stat tiles, calendar, year heatmap, weekly bar chart, notes list, and streak freeze card.
2. **Given** the calendar, **Then** done days are filled in the habit color, freeze days show a snowflake, missed scheduled days have a faint outline, and every marking also has a text or icon equivalent for screen readers; the user can swipe to previous months back to the habit's start date.
3. **Given** the user taps a past or current day on or after the start date, **Then** they can toggle it (yes/no) or edit its value (count) and its note (at most 200 characters); future days are disabled.
4. **Given** the year heatmap, **Then** it shows a 53×7 grid for the last 12 months with color intensity from value ÷ target (capped at 100%), and a share button renders the heatmap as an image and opens the system share sheet.
5. **Given** advanced reports are locked, **Then** the weekly bar chart of completions for the last 12 weeks shows the shared locked overlay with a blurred preview, no "Watch an ad" action, and a disabled "Get Pro"; **Given** they are unlocked (including by the dev-only switch), **Then** the chart is shown.
6. **Given** entries with notes, **Then** the notes list shows them newest first with their dates; with none, it shows a one-line empty message.
7. **Given** the streak freeze card, **Then** it shows "Freezes available: N" (0–2); **When** the user uses a freeze on a missed scheduled day 1 to 3 days before today, **Then** that day becomes a freeze day, the count decreases by 1, the streak is restored, and a 5-second Undo returns the freeze.
8. **Given** a habit already holds 2 freezes, **Then** it cannot hold more.
9. **Given** a dev build with "Unlock all features (debug)" on, **When** the user taps "Add a freeze (debug)" on the freeze card, **Then** the count increases by 1, up to 2, after which the button is disabled; **Given** the switch is off or a prod build, **Then** the button is not shown.

---

### User Story 6 - Archive, restore, and delete habits (HAB-04) (Priority: P3)

The user stops a habit for the season and archives it. Later they open "Archived habits" from the HAB-01 overflow menu, see the habit with its archive date and best streak, and tap Restore; it returns to HAB-01 with its history and reminders. Another old habit they delete permanently after confirming.

**Why this priority**: Keeps the active list focused without losing history; useful but not essential for daily use.

**Independent Test**: Archive and restore habits and confirm list content, reminder cancel and reschedule, and that delete removes the habit everywhere after confirmation.

HAB-04 has no acceptance criteria in `docs/spec.md`; its behavior is covered by the derived scenarios below.

**Additional scenarios** (derived from the HAB-04 Layout):

1. **Given** archived habits, **When** the user opens HAB-04 (`/habits/archived`), **Then** each row shows the name, archive date, and best streak, with Restore and Delete permanently actions.
2. **Given** the user taps Restore, **Then** the habit returns to HAB-01 at the end of the list, its history is intact, and its reminders are rescheduled.
3. **Given** the user taps Delete permanently, **Then** a confirmation states that the habit and all its history will be removed; confirming removes it from every screen.
4. **Given** no archived habits, **Then** HAB-04 shows an empty state explaining that archived habits appear here.

---

### User Story 7 - Habits on Home and quick add (HabitModule) (Priority: P3)

On the Home tab the habit card shows a progress ring "3 of 5 done today" and a row of round check buttons for today's scheduled habits. Tapping a yes/no check marks it done; tapping a count check offers +1 or a custom value; long-pressing opens HAB-03. The global + menu offers "Check in habit".

**Why this priority**: Brings the habit loop to the most-opened screen, but the full Home layout comes later (T2.5); this feature supplies only the module's card and quick-add action.

**Independent Test**: Render the module's dashboard card and quick-add action with a fake repository and confirm the ring, check buttons, navigation, and empty state.

**Acceptance Scenarios**:

1. **Given** habits scheduled today, **Then** the card shows a progress ring with "X of Y done today" and one round check button per scheduled habit, in sort order.
2. **Given** the user taps a yes/no check on the card, **Then** it is marked done and the ring, HAB-01, and streaks update without reload; a count check opens a small popup with "+1" and a custom value entry.
3. **Given** the user long-presses a check on the card, **Then** HAB-03 opens for that habit.
4. **Given** no habits, **Then** the card shows an empty state with "Create your first habit", which opens HAB-02.
5. **Given** the quick-add action "Check in habit", **Then** it opens HAB-01 for today; with no active habits, HAB-01's empty state offers the templates and the + button to create one.

---

### Edge Cases

- **Today vs. day over**: A scheduled day that is not yet done never breaks the streak while it is still today in local time; it breaks once the local day has passed. For "times per week", the current week never breaks the streak until it is over.
- **Unscheduled days**: Days not scheduled for the habit never break the streak. Completions on unscheduled days count toward total completions but do not add to the streak.
- **Freeze days in streaks and rates**: A freeze day keeps the streak unbroken but does not add to its length. Freeze days are left out of completion rate (neither done nor missed). For "times per week", a week that missed its target but contains a freeze day keeps the weekly streak unbroken without adding to it.
- **Freeze window**: From the HAB-03 freeze card, a freeze can be used only on a missed day 1 to 3 days before today that is on or after the start date (for "Specific days", only a scheduled day; for "times per week", any day that is not done, because every day on or after the start date counts as scheduled for streaks, freezes, and Skip today). Today, future days, done days, and older days are rejected there. Today can be frozen only through "Skip today" on HAB-01 (FR-036).
- **Skipped today, then done**: Checking in a habit after "Skip today" turns today into a normal done day and returns the freeze (same rule as checking any freeze day).
- **Checking a freeze day**: Marking a freeze day as done turns it into a normal done day and returns the freeze to the habit (up to the cap of 2).
- **Start date**: Days before the habit's start date are not scheduled, cannot be edited, and never count as missed. A habit with a future start date appears under "Not scheduled today" until it starts.
- **Schedule and target changes**: Each change applies from its change date onward; days before it keep the settings that were in effect then. Several changes on the same day keep only the last one.
- **Goal type**: The goal type (Yes / No or Count) is fixed after the habit is created; HAB-02 in edit mode shows it read-only.
- **"Times per week" listing**: A "times per week" habit is listed as scheduled on a day if it is done that day or its weekly target was not yet met before that day; otherwise it is listed under "Not scheduled today". Its schedule text shows how many are left this week.
- **Completion rate for "times per week"**: Measured over weeks instead of days: the share of weeks overlapping the last 30 days that met the target; the current week counts only once its target is met or it is over.
- **Notes without completion**: Adding a note on a day that is not done stores the note without marking the day done. Unchecking a yes/no day that has a note keeps the note (value 0) instead of removing it; Undo restores the previous state.
- **Count value 0**: Setting a count habit's value to 0 on a day without a note removes that day's entry.
- **Week start**: The week strip and "times per week" weeks start on the first day of the week from settings (default Monday).
- **Time zone change or travel**: Entries keep their local date key; streaks are computed in the device's current local date, so moving time zones never splits or duplicates a day.
- **Clock moved backwards**: Today is always the device's current local date; entries dated after today are kept but cannot be edited until that date, and they do not count toward streaks until then.
- **Duplicate reminder times**: The same time cannot be added twice for one habit; at most 3 reminders.
- **Exact alarms not granted**: Reminders fall back to inexact scheduling, and HAB-02 notes they may be a few minutes late.
- **Deleted habits**: Deleted habits and their entries disappear from every screen, the Home card, and reminders; they are soft-deleted so a future backup feature can restore them.
- **Archived habits**: Archived habits are hidden from HAB-01 and the Home card, keep their entries and celebrated milestones, and have no reminders.
- **Module turned off**: Its tab and card are hidden and its reminders are cancelled; data is kept and reminders return when it is turned on again.
- **Many habits**: HAB-01, the week strip rings, and the Home card stay responsive with at least 50 active habits and 5 years of entries each.

## Requirements *(mandatory)*

### Functional Requirements

**Data and storage (T2.1)**

- **FR-001**: System MUST store habits with: name (at most 40 characters), icon, color, goal type (yes/no or count), target value (1 for yes/no; 1–9,999 for count), optional unit (at most 20 characters), schedule type (daily, specific weekdays, times per week), weekdays set, times per week (1–6), 0–3 reminder times (`HH:mm`), the "remind only if not done yet" flag, start date (`yyyy-MM-dd`), archived flag and archive moment, and sort order.
- **FR-002**: System MUST keep the history of each habit's schedule and target, each with the local date it takes effect, so days are evaluated with the settings in effect on that date.
- **FR-003**: System MUST store habit entries with: habit, local date key (`yyyy-MM-dd`), value (1 for done yes/no, or count achieved), freeze flag, and optional note (at most 200 characters). Each habit MUST have at most one non-deleted entry per date key.
- **FR-004**: System MUST store, per habit, the number of available streak freezes (0–2) and which milestones have been celebrated.
- **FR-005**: Habits and habit entries MUST be removed by soft delete; deleting a habit soft-deletes its entries.
- **FR-006**: System MUST upgrade an existing schema-version-3 database (and every earlier version) to the new schema without losing or changing any existing record, covered by automated migration tests.
- **FR-007**: All habit data MUST be read and written through repository interfaces in the habit domain layer, and screens MUST update live when habit data changes anywhere in the app.

**Streak engine (T2.1)**

- **FR-008**: The streak engine MUST be pure domain logic that takes "today" from an injected clock and computes, for any habit: current streak, best streak, completion rate over the last 30 days, total completions, whether a day is scheduled, whether a day is done, and the done status for any date range.
- **FR-009**: A day MUST count as done when its entry's value reaches the target in effect on that day.
- **FR-010**: Current streak MUST count back from today over scheduled days only; a scheduled day breaks it when it has no entry reaching the target and no freeze; today MUST never break it until the local day is over.
- **FR-011**: For "times per week", the streak MUST count consecutive weeks where the target was met, and the current week MUST NOT break it until the week is over.
- **FR-012**: Freeze days, unscheduled-day completions, start dates, and schedule or target changes MUST follow the rules in Edge Cases.
- **FR-013**: Completion rate MUST count only scheduled days (weeks, for "times per week") on or after the start date within the last 30 days including today, MUST leave out freeze days, MUST count today only if it is already done, and MUST be shown as a whole percent; with no countable days it MUST show "—".
- **FR-014**: Total completions MUST count every done day since the habit started.
- **FR-015**: Unit tests MUST cover every schedule type, both goal types, freeze days, back-filling, start dates, schedule and target changes, week starts, month and year boundaries, leap years, and empty histories.

**HAB-01 Habits today (T2.3)**

- **FR-016**: HAB-01 MUST replace the Habits tab placeholder at `/habits` and show the app bar (title "Habits", overflow: Archived habits, Reorder), week strip, progress header ("X of Y done" with a linear bar for the selected day), and habit list described in User Story 1.
- **FR-017**: The week strip MUST allow selecting today and past days up to 7 days back for check-in and back-fill, including days in the previous week; future days and older days MUST be disabled.
- **FR-018**: Tapping a yes/no check MUST create the entry for the selected date key or remove it; tapping + on a count habit MUST add 1; long-press on + MUST open number entry (0–9,999).
- **FR-019**: Completing a habit MUST play a short check animation and a light haptic, respecting the system "Remove animations" setting.
- **FR-020**: The long-press menu MUST offer Edit, Add note for today, Skip today, and Archive; Skip today MUST follow the rule in FR-036.
- **FR-021**: Reorder mode MUST let the user drag habits and MUST persist the new order.
- **FR-022**: With no active habits, HAB-01 MUST show the empty state with template chips Drink water, Read, Walk, Meditate, Wake up early, and Study, each prefilling HAB-02 (see Assumptions for template values).
- **FR-023**: HAB-01 MUST show skeletons only if loading takes over 300 ms, and an error state with "Try again" if habits cannot be loaded.

**HAB-02 Add / edit habit (T2.2)**

- **FR-024**: HAB-02 MUST open full screen at `/habits/add` and `/habits/:id/edit` with the fields in User Story 1, scenario 2, a sticky save button, and, in edit mode, Archive and Delete in the overflow menu.
- **FR-025**: HAB-02 MUST block saving while the name is empty or longer than 40 characters, while "Specific days" has no weekday, or while a count target is outside 1–9,999, and MUST say why next to the field.
- **FR-026**: Saving MUST schedule or reschedule the habit's reminders (FR-038) and MUST return to the previous screen with a "Habit saved" snackbar.
- **FR-027**: Changing schedule or target MUST NOT delete or change past entries (FR-002).
- **FR-028**: Delete MUST ask for confirmation in a `ConfirmDialog` that states the habit and its history will be removed; Archive MUST keep history, stop reminders, and offer Undo.

**HAB-03 Habit detail and HAB-04 Archived habits (T2.4)**

- **FR-029**: HAB-03 MUST open at `/habits/:id` from a HAB-01 card tap or a Home card long-press and show the sections in User Story 5, scenario 1.
- **FR-030**: The calendar MUST let the user edit any day from the start date through today: toggle or set the value, and add, change, or remove the note.
- **FR-031**: The heatmap MUST be precomputed by the screen's controller and MUST render 365 days in under 100 ms; its share button MUST render the heatmap as an image and open the system share sheet.
- **FR-032**: The weekly bar chart MUST show completions per week for the last 12 weeks and MUST be gated by the `advancedReports` feature key, showing `LockedFeatureOverlay` without "Watch an ad" and with "Get Pro" disabled while locked.
- **FR-033**: HAB-04 MUST open at `/habits/archived` from the HAB-01 overflow menu, list archived habits with name, archive date, and best streak, and offer Restore (which reschedules reminders) and Delete permanently (with `ConfirmDialog`).

**Streak freezes**

- **FR-034**: Each habit MUST hold 0–2 available freezes, shown on the HAB-03 freeze card as "Freezes available: N".
- **FR-035**: Using a freeze MUST be allowed only on a missed day 1 to 3 days before today (Edge Cases), MUST mark that day as a freeze day, decrease the count by 1, and offer a 5-second Undo that reverses both.
- **FR-036**: "Skip today" on HAB-01 MUST, when the habit has at least one freeze and today is a scheduled, not-done day, mark today as a freeze day, decrease the count by 1, and offer a 5-second Undo that reverses both. With no freezes available, the menu item MUST be shown disabled with "No freezes left". This is the only way to put a freeze on today; the HAB-03 freeze card follows FR-035.
- **FR-037**: In this feature, freezes MUST be grantable only through the dev-only "Unlock all features (debug)" switch: while it is on, the HAB-03 freeze card MUST show an "Add a freeze (debug)" button that adds 1 freeze per tap and is disabled at 2. The button MUST be hidden when the switch is off and MUST NOT exist in prod builds. Turning the switch off MUST NOT remove freezes already granted. In prod builds no freeze can be gained until the rewarded "Watch an ad" action arrives (T4.4).

**Reminders (T2.2)**

- **FR-038**: Saving a habit MUST schedule one local notification per reminder time on the "Habit reminders" channel (default on) for the habit's scheduled days ("times per week": every day), each with a stable ID derived from the habit and reminder index; saving again MUST replace them and cancel removed slots.
- **FR-039**: With "Remind me only if not done yet" on, reminders MUST NOT be shown on a day whose entry already meets the target, or, for "times per week", once the week's target is met; unchecking MUST restore that day's remaining reminders.
- **FR-040**: Reminders MUST be cancelled when a habit is archived or deleted and when the Habit module is turned off, and rescheduled when a habit is restored, when the module is turned on, on every app start, and after device reboot.
- **FR-041**: Reminders MUST fire at the set local time; when exact alarms are not allowed they MUST fall back to inexact scheduling.
- **FR-042**: Tapping a habit reminder MUST open HAB-01 for today when app lock is off. When app lock is on, the tap MUST land on the unlock screen and never bypass it; forwarding to HAB-01 after unlock comes with the real SYS-03 in T3.1 (plan Complexity Tracking).
- **FR-043**: Reminder notification text MUST contain only the habit name and a short encouragement from the ARB files, never notes or counts.

**Milestones**

- **FR-044**: When a check-in, value change, back-fill, or freeze makes a habit's current streak reach 7, 21, 30, 50, 100, or 365 for a milestone not yet celebrated for that habit, the system MUST show the milestone bottom sheet once and record the milestone (User Story 3).
- **FR-045**: The milestone sheet's "Share streak" MUST render an image card (habit icon, color, name, streak length with unit, app name) and open the system share sheet.

**HabitModule (TrackerModule)**

- **FR-046**: `HabitModule` MUST provide the routes for HAB-01 to HAB-04, the dashboard card in User Story 7, the "Check in habit" quick-add action, reminder cancel on disable and reschedule on enable and app open, and a stubbed backup section (no habit data in backups until T3.2).

**Cross-cutting**

- **FR-047**: All new strings MUST be in English, Hindi, and Gujarati ARB files, using placeholders and plurals (for example "3 of 5 done", "1 left", "21-day streak").
- **FR-048**: All new screens MUST follow §15: shared tokens and components only; one primary action per screen; loading, empty, error, and content states; 48 dp touch targets with semantic labels; status never by color alone; no clipping at 200% font scale; undo for reversible actions and confirmation for deleting a habit with history; the §15.10 checklist passes.
- **FR-049**: No habit data MUST be sent to ad, crash, or analytics services, and no ad MUST be requested or shown by this feature; HAB-01, HAB-03, and HAB-04 banner and native slots stay empty until T4.2.

### Key Entities

- **Habit**: Something the user wants to do regularly. Name, icon, color, goal type, target and unit, schedule (daily, specific weekdays, or times per week), 0–3 reminder times with the "only if not done" flag, start date, archived flag and moment, sort order, available freezes (0–2), celebrated milestones; created, updated, and deleted timestamps.
- **Habit schedule version**: The schedule and target of a habit from a given local date onward. A new version is recorded each time the user changes them; the first starts at the start date.
- **Habit entry**: One habit on one local date. Value, freeze flag, optional note; created, updated, and deleted timestamps. At most one per habit per date.
- **Streak summary**: Computed, not stored: current streak, best streak, completion rate (last 30 days), total completions, and per-day status (done, partial, missed, freeze, unscheduled, future).
- **Habit reminder**: A scheduled local notification for one habit and one reminder index; its ID is stable for that pair.
- **Habit template**: A predefined starter habit (name as a translatable key, icon, color, goal type, target, unit, schedule). Not stored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a habit from a template in 2 taps and check it in from HAB-01 in 1 tap.
- **SC-002**: Across the streak test suite (at least 100 scenarios), current streak, best streak, completion rate, and total completions match hand-computed values in 100% of cases.
- **SC-003**: Saving a check-in completes in under 100 ms, and the streak, progress header, and week strip update within the same frame sequence (under 200 ms) with no reload.
- **SC-004**: HAB-03's heatmap for 365 days renders in under 100 ms, and HAB-01 and HAB-03 show content in under 500 ms with 50 habits holding 5 years of entries each on a mid-range device.
- **SC-005**: In tests, 100% of reminders are scheduled at the set local time with one ID per habit and reminder index (0 duplicates after repeated saves), 100% are cancelled on archive, delete, and module disable, and 100% are rescheduled on app open; the boot reschedule is declared for the operating system, and a manual device check confirms a pending reminder still fires after a restart.
- **SC-006**: With "Remind me only if not done yet" on, 0 reminders are shown on days already done.
- **SC-007**: Each milestone sheet appears exactly once per milestone per habit across simulated histories of 400 days, including broken and rebuilt streaks.
- **SC-008**: Upgrading from the feature 003 build preserves 100% of existing records and settings.
- **SC-009**: All new screens render without clipping or overflow at 200% font scale on a 360 dp-wide screen, in English, Hindi, and Gujarati, in light and dark themes.
- **SC-010**: No ad request is made and no habit data leaves the device from any part of this feature, and the freeze-granting debug control is absent from 100% of prod builds.

## Assumptions

- **Reuse of earlier features**: The database, settings (including first day of week), `NotificationService`, notification permission request, `FeatureGate` with its dev-only unlock switch, module registry, and the shared widgets listed above already exist and are reused. `NotificationService` is extended with a "Habit reminders" channel and scheduled notifications; a `ProgressRing` shared widget is added if not yet present (§15.4).
- **Schedule history**: §4 has no table for schedule history, but HAB-02 requires that schedule changes apply "from the change date onward". This feature adds the schedule version store (and the per-habit freeze count, celebrated milestones, archive moment, and "only if not done" flag); the plan updates `docs/spec.md` §4 accordingly (Constitution I).
- **Templates**: Drink water (Count, 8 glasses, daily), Read (Count, 20 pages, daily), Walk (Count, 30 minutes, daily), Meditate (Count, 10 minutes, daily), Wake up early (Yes / No, daily), Study (Count, 60 minutes, daily); no reminders. Template names and units are ARB keys shown in the user's language; the saved habit keeps the text as shown, like any user-typed name.
- **Week strip paging**: The week strip shows the current week and can page back one week only, so "back-filling up to 7 days back" works on any weekday.
- **Milestones once ever**: "once per milestone per habit" is read literally: a celebrated milestone never shows again for that habit, even after a broken streak.
- **Times per week milestones** count weeks, matching the weekly streak.
- **Notes**: A note can exist on a day that is not done (see Edge Cases), so a yes/no uncheck removes the entry only when it has no note.
- **Undo on uncheck**: Following §15.5 ("uncheck habit" is reversible), unchecking a habit shows a 5-second Undo.
- **Deleted data retention**: Deleted habits stay soft-deleted; purging after 30 days and restoring from backup come with T3.2.
- **Reminder channel setting**: A "Habit reminders" setting is stored with default on and honored now; its toggle in SET-01 comes with T3.1.
- **Out of scope**: Notification action buttons "Mark done" and "Snooze 1 h" (T3.4, "feature 007" in the request); the "Watch an ad to get a freeze" action, PRM-02, and all ads including HAB-01, HAB-03, and HAB-04 banners, the HAB-01 native ad, and the interstitial after saving a new habit (T4.x, "feature 008"); the Home dashboard layout, greeting, streak flame icon, insights, and FAB menu (T2.5, "feature 005" in the request); the home screen widget (T3.4); and habit backup and restore (T3.2).
- **Golden baselines**: Golden images are generated on Linux only, as in earlier features; HAB-01 goldens in light/dark and English/Gujarati are part of this feature (§13).
