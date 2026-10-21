# Data Model: Habit Module (Phase 2, T2.1–T2.4)

**Feature**: [spec.md](spec.md) · **Research**: [research.md](research.md) · **Date**: 2026-10-18

Database: `AppDatabase` (Drift, single SQLite file), **schema v3 → v4**. Conventions are the same
as in features 002 and 003:
- `TEXT` UUID v4 primary key `id`.
- `createdAt` and `updatedAt` in UTC epoch ms, and nullable `deletedAt` (soft delete).
- Habit days as local `yyyy-MM-dd` TEXT keys (Constitution III).
- Enums stored with `intEnum`, and **append-only**.

`docs/spec.md` §4 was updated first (Changes 2026-10-18) with every column below that it did not
list.

## 1. Schema versions

| Version | Feature | Tables |
| --- | --- | --- |
| 1 | 001-foundation | `settings`, `categories`, `accounts` |
| 2 | 002-expense-core | + `transactions` |
| 3 | 003-budgets-recurring-reports | + `recurring_rules`, `budgets`, `unlocks` |
| **4** | **005-habit-module** | + `habits`, `habit_schedules`, `habit_entries` |

**Migration 3 → 4** (`stepByStep.from3To4`, research R2), in this order:
1. Create `habits` and index `habits_active_order`.
2. Create `habit_schedules` and indexes `habit_schedules_habit_from_unique` (partial, unique).
3. Create `habit_entries` and indexes `habit_entries_habit_date_unique` (full, unique) and
   `habit_entries_date`.

No existing table or row is touched. v1 and v2 databases run the earlier steps first. Settings rows,
including seed markers, are unchanged.

## 2. Enums (`features/habit/domain/enums.dart`)

| Enum | Values (index order, append-only) |
| --- | --- |
| `HabitKind` | yesNo, count |
| `ScheduleType` | daily, specificWeekdays, timesPerWeek |

## 3. Tables (`features/habit/data/tables/`)

### 3.1 `habits` (new, `habits_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| name | TEXT | no | 1–40 chars after trim (CHECK on length) |
| icon_key | TEXT | no | From the shared icon set |
| color_hex | TEXT | no | From the shared 16-color set |
| kind | INTEGER | no | `HabitKind`; fixed after create (domain rule) |
| target_value | INTEGER | no | CHECK `(kind = 0 AND target_value = 1) OR (kind = 1 AND target_value BETWEEN 1 AND 9999)`; mirrors newest schedule version |
| unit | TEXT | yes | ≤ 20 chars; count habits only |
| schedule_type | INTEGER | no | `ScheduleType`; mirrors newest version |
| weekdays_mask | INTEGER | no | Mon=1 … Sun=64; CHECK `BETWEEN 0 AND 127`; > 0 when specificWeekdays |
| times_per_week | INTEGER | yes | CHECK `BETWEEN 1 AND 6`; required when timesPerWeek |
| reminder_times | TEXT | no | JSON list of distinct `HH:mm`, 0–3 items, sorted; default `[]` |
| remind_only_if_not_done | INTEGER (bool) | no | Default 1 |
| start_date_key | TEXT | no | `yyyy-MM-dd` |
| is_archived | INTEGER (bool) | no | Default 0 |
| archived_at | INTEGER | yes | UTC ms; set with `is_archived = 1`, cleared on restore |
| sort_order | INTEGER | no | Active habits 0..n-1; archive leaves it unchanged (Undo keeps the position); restore from HAB-04 sets max active + 1 (end of list) |
| freezes_available | INTEGER | no | Default 0; CHECK `BETWEEN 0 AND 2` |
| celebrated_milestones | INTEGER | no | Default 0; bit i = milestone `[7,21,30,50,100,365][i]`; CHECK `BETWEEN 0 AND 63` |
| created_at, updated_at | INTEGER | no | UTC ms |
| deleted_at | INTEGER | yes | Soft delete |

Index `habits_active_order` on `(deleted_at, is_archived, sort_order)`.

### 3.2 `habit_schedules` (new, `habit_schedules_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| habit_id | TEXT | no | FK → `habits(id)` |
| effective_from_key | TEXT | no | `yyyy-MM-dd` |
| schedule_type | INTEGER | no | As `habits` |
| weekdays_mask | INTEGER | no | As `habits` |
| times_per_week | INTEGER | yes | As `habits` |
| target_value | INTEGER | no | As `habits` (kind comes from the habit) |
| created_at, updated_at | INTEGER | no | |
| deleted_at | INTEGER | yes | Set together with the habit's |

Index `habit_schedules_habit_from_unique` UNIQUE on `(habit_id, effective_from_key)` WHERE
`deleted_at IS NULL`.

### 3.3 `habit_entries` (new, `habit_entries_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| habit_id | TEXT | no | FK → `habits(id)` |
| date_key | TEXT | no | `yyyy-MM-dd` local |
| value | INTEGER | no | CHECK `BETWEEN 0 AND 9999` |
| is_freeze | INTEGER (bool) | no | Default 0 |
| note | TEXT | yes | ≤ 200 chars; empty string stored as NULL |
| created_at, updated_at | INTEGER | no | |
| deleted_at | INTEGER | yes | Soft delete (research R4) |

Indexes: `habit_entries_habit_date_unique` UNIQUE on `(habit_id, date_key)` (**full**, one physical
row per habit and day, research R4); `habit_entries_date` on `(date_key)` for the HAB-01 window.

Live-row invariant (enforced by the repository): a row is live (`deleted_at IS NULL`) only when
`value > 0 OR is_freeze = 1 OR note IS NOT NULL`. A freeze row has `value = 0`.

## 4. Settings (no schema change)

| Key | Type | Default | Note |
| --- | --- | --- | --- |
| `habitRemindersEnabled` | bool | true | "Habit reminders" setting; SET-01 toggle in T3.1 |

`firstDayOfWeek`, `notificationsEnabled`, and `debugUnlockAll` already exist and are read.

## 5. Domain entities (`features/habit/domain/entities/`, freezed, pure Dart)

| Entity | Fields | Notes |
| --- | --- | --- |
| `Habit` | id, name, iconKey, colorHex, kind, schedule (`HabitSchedule`), unit?, reminderTimes (`List<ReminderTime>`), remindOnlyIfNotDone, startDate (`LocalDate`), isArchived, archivedAt?, sortOrder, freezesAvailable, celebratedMilestones (`Set<Milestone>`), createdAt, updatedAt | `schedule` mirrors the newest version |
| `HabitSchedule` | type, weekdays (`Set<int>` 1–7), timesPerWeek?, target | Value object; `describe()` data for schedule text |
| `ScheduleVersion` | effectiveFrom (`LocalDate`), schedule | |
| `HabitEntry` | habitId, date, value, isFreeze, note? | Live entries only |
| `EntrySnapshot` | habitId, date, value, isFreeze, note?, wasLive, freezesAvailableBefore | For Undo (R8) |
| `HabitHistory` | habit kind, startDate, versions, `Map<LocalDate, HabitEntry>` | Engine input |
| `StreakSummary` | current, best, completionRate (`int?` percent), totalCompletions, unit (`days`/`weeks`) | Computed |
| `DayStatus` | enum: done, partial, missed, freeze, unscheduled, beforeStart, future, pending | Computed |
| `Milestone` | enum: d7, d21, d30, d50, d100, d365 (with `value` and bit index) | |
| `HabitDraft` | everything editable in HAB-02 | Validated by `validateHabit` |
| `HabitTemplate` | id, nameKey, iconKey, colorHex, kind, target, unitKey? | Const list (R16) |
| `PlannedReminder` | id, firstAt (local `DateTime`), repeat (daily/weekly) | Output of `planReminders` (R10) |
| `LocalDate` | year, month, day | `dates.dart` (R5) |
| `ReminderTime` | hour, minute | Parses/prints `HH:mm` |

## 5.1 Validation (`validateHabit`, FR-025)

| Field | Rule | Error |
| --- | --- | --- |
| name | trimmed length 1–40 | `nameRequired`, `nameTooLong` |
| target | yes/no → 1; count → 1–9,999 | `targetOutOfRange` |
| unit | ≤ 20 chars, count only | `unitTooLong` |
| schedule | specificWeekdays → ≥ 1 weekday; timesPerWeek → 1–6 | `weekdayRequired`, `timesOutOfRange` |
| reminders | ≤ 3, distinct | `tooManyReminders`, `duplicateReminder` |
| kind (edit) | unchanged from stored | `kindLocked` (UI shows it read-only) |
| startDate | any date (past or future) | — |

Day writes: `value` 0–9,999; note ≤ 200 chars; date ≤ today and ≥ startDate; HAB-01 only within 7
days back (presentation rule, R14); freeze rules in `FreezePolicy` (R8).

## 6. State transitions

**Habit**

```
            create
  (none) ──────────▶ Active ──archive──▶ Archived ──restore──▶ Active
                       │                    │
                       └──delete──┐  ┌──delete permanently
                                  ▼  ▼
                                Deleted (soft; habit + schedules + entries; reminders cancelled)
```
Undo of archive (within 5 s) returns to Active with the same `sort_order`; Restore from HAB-04 puts the habit at the end of the active list. Reorder only rewrites active habits. Archived and Deleted habits have no
reminders.

**Entry (one habit, one day)**

| From | Action | To | Side effects |
| --- | --- | --- | --- |
| none / deleted | toggle (yes/no), increment, setValue > 0 | live, value > 0 | milestone check |
| live done | toggle off / setValue 0, no note | deleted | — |
| live done | toggle off / setValue 0, with note | live, value 0 | — |
| none / deleted / live not done | useFreeze (allowed day, count > 0) | live, isFreeze, value 0 | freezes − 1; milestone check |
| live freeze | toggle / setValue reaching target | live, isFreeze = false | freezes + 1 (cap 2); milestone check |
| any | setNote | live if note or value or freeze | — |
| any | restore(snapshot) | snapshot state | freezes restored to `freezesAvailableBefore` |

**Milestones**: `celebrated_milestones` bits only ever turn on (compare-and-set, R8); they survive
archive, restore, and broken streaks (spec Assumptions: once ever).

## 7. Repository-level invariants (tested in `test/features/habit/data/`)

1. At most one physical `habit_entries` row per `(habit_id, date_key)`.
2. At most one live `habit_schedules` row per `(habit_id, effective_from_key)`; the `habits` row
   equals the newest live version.
3. Deleting a habit soft-deletes its schedules and entries in the same transaction.
4. `freezes_available` stays within 0–2 under concurrent writes.
5. A milestone bit is set by exactly one of two concurrent writers.
