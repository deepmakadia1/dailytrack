# Data Model: Home Dashboard (DSH-01, T2.5)

**Feature**: `specs/006-home-dashboard` · **Date**: 2026-10-19

**Schema**: unchanged at **v4**. No new tables or columns. The new persisted values are rows in the
existing key-value `settings` table (`key` text PK, `value` JSON text), so no Drift migration is
needed. Insights are computed and never stored, except for the single daily pick.

---

## 1. Settings keys (new)

Added to `AppSettings` (`lib/core/settings/domain/app_settings.dart`) and `SettingsCodec`. Each key
decodes on its own and falls back to its default when missing or malformed (existing codec rule).

| Key | JSON type | Default | Field | Written by |
| --- | --- | --- | --- | --- |
| `dailyInsightDate` | string `yyyy-MM-dd` (local) | null | `String? dailyInsightDate` | `setDailyInsight` |
| `dailyInsightId` | string (rule id) | null | `String? dailyInsightId` | `setDailyInsight` |
| `homeComingSoonDismissed` | bool | false | `bool homeComingSoonDismissed` | `setHomeComingSoonDismissed` |

**Validation**:
- `dailyInsightDate` must parse as a `yyyy-MM-dd` date key. Otherwise it decodes to null, and the pair
  then counts as "no stored pick".
- `dailyInsightId` is any non-empty string. An id that no visible module declares counts as "not in
  order" (R6), so rotation restarts from the top.
- `setDailyInsight` writes both keys in one settings transaction, so they never disagree.

**Backup**: these keys belong to the settings section once T3.2 backup exists. Nothing is needed now.

## 2. Core module types (new, `lib/core/module/`)

`insight.dart` is pure Dart. `insight_source.dart` imports `ProviderReader` (`flutter_riverpod`),
so it is not pure Dart, and the layering scan exempts it (research R17).

### `Insight` (`insight.dart`)

| Field | Type | Rules |
| --- | --- | --- |
| `ruleId` | `String` | Stable across releases. Unique app-wide, prefixed with the module id (`expense.categoryVsLastMonth`). |
| `text` | `String` | Already localized, one sentence, no trailing period required. |
| `location` | `String?` | Route to open on tap (`Routes.*`). Null means not tappable. |
| `semanticLabel` | `String?` | Optional TalkBack text ("Open reports"). Home falls back to `text`. |

### `InsightSource` (`insight_source.dart`)

| Member | Type | Rules |
| --- | --- | --- |
| `ruleIds` | `List<String>` | Every rule the module may return, in its fixed rotation order. No duplicates. |
| `evaluate(ProviderReader read)` | `Future<List<Insight>>` | Applicable insights only, at most one per rule id, each id contained in `ruleIds`. Must not throw: a failing rule is skipped. |

### `DashboardSection` (`dashboard_section.dart`)

| Field | Type | Rules |
| --- | --- | --- |
| `id` | `String` | Unique app-wide (`expense.recentTransactions`). Used as the widget key. |
| `build` | `WidgetBuilder` | Returns the section, or `SizedBox.shrink()` when it has nothing to show. |

### `QuickAddAction` (existing, unchanged fields)

`labelKey` (ARB key), `icon`, `location`. It is now returned in a list (`quickAddActions()`).

## 3. Module domain types (new, pure Dart, injected `Clock`)

### Expense, `lib/features/expense/domain/insights/`

- `ExpenseInsightInputs`:
  - `thisMonthByCategory: Map<String, int>`: paise from day 1 through today;
  - `lastMonthSameDaysByCategory: Map<String, int>`: day 1 through the same day-of-month, capped at
    last month's length;
  - `overall: BudgetStatus?`;
  - `monthPhase` (elapsed days, total days).
- `ExpenseInsightFact` (sealed):
  - `CategoryChange(categoryId, percent, higher: bool)`;
  - `BudgetOnTrack(remainingMinor, daysLeft)`;
  - `BudgetNearLimit(percentUsed)`;
  - `BudgetOver(overMinor)`.
- `ExpenseInsightRules.evaluate(inputs) → List<ExpenseInsightFact>`, in rule order. Thresholds are
  in research R8.

### Habit, `lib/features/habit/domain/insights/`

- `HabitInsightInputs`: per active habit, `Habit`, `StreakSummary`, completions this week, and
  `scheduledToday`.
- `HabitInsightFact` (sealed):
  - `NextMilestone(habitId, name, daysLeft, milestone, unit)`;
  - `BestThisWeek(habitId, name, count)`;
  - `Comeback(habitId, name, best, unit)`.
- `HabitInsightRules.evaluate(inputs) → List<HabitInsightFact>`.

### Habit, best active streak (`lib/features/habit/domain/streaks/best_streak.dart`)

- `bestActiveStreak(List<(Habit, StreakSummary)>) → BestStreak?`, where
  `BestStreak(habitId, current, unit)`.
- Weekly units compare as `current × 7`. Ties go to the habit that sorts first. Returns null when
  there are no habits; the badge then shows 0.

## 4. Dashboard domain (`lib/features/dashboard/domain/`, pure Dart)

- `enum Greeting { morning, afternoon, evening }`. `greetingFor(DateTime local)`: 05:00–11:59
  morning, 12:00–16:59 afternoon, otherwise evening. `nextGreetingBoundary(DateTime local) →
  DateTime`.
- `StoredInsightPick(date, ruleId)`.
- `InsightPick` (sealed):
  - `Picked(insight, persist: bool)`;
  - `Starter()`.
- `pickDailyInsight({today, order, applicable, stored}) → InsightPick`. Rules are in research R6.

## 5. Presentation state (Riverpod, `freezed`)

- `HomeState`:
  - `greeting`, `today` (local date);
  - `modules: List<TrackerModule>` (visible, in order);
  - `quickAdds: List<QuickAddAction>`;
  - `comingSoon: List<ComingSoonModule>`, empty when dismissed;
  - `insight: AsyncValue<InsightPick>`, replaced alone by `refreshInsights()`, which keeps the
    previous value while refreshing.
- `ExpenseDashboardData` (replaces `TodayAndMonthSpend` as card state):
  - `todayMinor`, `monthMinor`, `hasAnyTransaction`;
  - `overall: BudgetStatus?` (limit, spent, ratio, level).
- `StreakFlameData`: `current`, `unit`.

## 6. State transitions

**Daily insight pick** (per local date):

```text
(no stored pick) ──first load, ≥1 applies──▶ Picked(first in order) ─persist─▶ stored(today, id)
stored(today, id) ──id still applies──▶ Picked(id)                          (no write)
stored(today, id) ──id stopped applying──▶ Picked(next after id) ─persist─▶ stored(today, next)
stored(d<today, id) ──new day──▶ Picked(next after id, ≠ id if any other) ─persist─▶ stored(today, x)
any ──nothing applies──▶ Starter                                            (no write)
```

**Coming soon card**: `visible` ─dismiss─▶ `hidden` (write true) ─Undo within 5 s─▶ `visible` (write
false). Once the snackbar closes, `hidden` is final, and no UI restores it.

**Habit check from Home**: same `DayOp` transitions as HAB-01 (feature 005 data-model §6). Unchecking
a yes/no habit offers Undo, which re-applies the previous op.
