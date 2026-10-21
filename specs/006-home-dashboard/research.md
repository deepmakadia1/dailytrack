# Research: Home Dashboard (DSH-01, T2.5)

**Feature**: `specs/006-home-dashboard` · **Date**: 2026-10-19

Technical Context had no open NEEDS CLARIFICATION items; the stack is fixed by spec §2 and the
constitution (VII). The decisions below settle how the feature fits the existing code. Each was
checked against the code as of 2026-10-19 (files cited).

---

## R1. Optional `TrackerModule` members need an abstract class, not an interface

- **Decision**: Change `abstract interface class TrackerModule` (`lib/core/module/tracker_module.dart`)
  to `abstract class TrackerModule` with a `const` constructor. `ExpenseModule`, `HabitModule`, and the
  test `FakeTrackerModule` (`test/helpers/fakes.dart`) change from `implements` to `extends`. The new
  members `dashboardSections()`, `insights()`, and `appBarBadge()` get empty defaults in the base
  class, as the user asked.
- **Rationale**: Dart `implements` never inherits bodies, so defaults on an interface would force
  every module to implement them anyway. An abstract base with a `const` constructor keeps both
  modules `const` (they are used in `const List<TrackerModule> registeredModules`).
- **Alternatives considered**: (a) a separate `HomeContributor` mixin that modules opt into with
  `with`: Home would then need `is` checks per module, which is a hidden contract. (b) Extension
  methods: cannot be overridden per module. (c) Keep the interface and make the new members
  nullable getters: still requires every module to declare them.

## R2. Several quick-add entries per module

- **Decision**: Replace `QuickAddAction? quickAddAction()` with `List<QuickAddAction>
  quickAddActions()`, default `const []`. Expense returns "Add expense" (`type=expense`) and "Add
  income" (`type=income`); Habit returns "Check in habit" (`Routes.habits`). The FAB menu concatenates
  the lists of `registry.visible(settings)`, so it follows SET-06 order.
- **Rationale**: FR-020 needs two Expense entries; the old contract allows one. A list with an empty
  default also serves future modules. `docs/spec.md` §3 is updated to match (Constitution I).
- **Alternatives considered**: Keep `quickAddAction()` and add `quickAddExtras()`: two members for
  one concept. Put "Add income" in Home: breaks the registry-only rule (FR-005).

## R3. `dashboardSections()`: Home extras below the cards

- **Decision**: `List<DashboardSection> dashboardSections()`, default `const []`. A
  `DashboardSection` has a stable `id` and a `WidgetBuilder build`. Home renders all sections of
  visible modules, in module order, after all module cards and before the insight card. Expense
  returns one section, "Recent transactions". Each section widget decides its own visibility and
  returns `SizedBox.shrink()` when empty (FR-018). Home wraps every slot in a shared `DashboardSlot`:
  `AnimatedSize` (200 ms) around a custom `SingleChildRenderObjectWidget` (`_GapIfNonEmpty`). Its render
  box lays out the child first. When the child's height is greater than 0, it reports
  `childHeight + cardGap` and paints the child offset by the gap. Otherwise it reports 0. A hidden
  section therefore leaves no gap (SC-007), and appearing content animates its height (§15.6 no layout
  shift). A `LayoutBuilder` cannot do this, because it cannot know the child's size before layout.
- **Rationale**: Matches the DSH-01 layout order (cards → recent transactions → insight → coming
  soon) and keeps Home free of expense imports.
- **Alternatives considered**: Sections returning slivers: more flexible, but every module would need
  sliver knowledge for a plain card list. A per-section `isVisible` stream: duplicates the data each
  section already watches.

## R4. `insights()`: a module-owned source of rule-based insights

- **Decision**: `InsightSource? insights()`, default `null`. `InsightSource` (core,
  `lib/core/module/insight_source.dart`; it imports `ProviderReader`, so it is not pure Dart) has:
  - `List<String> ruleIds`: every rule the module can produce, in its fixed order (used for rotation,
    R6);
  - `Future<List<Insight>> evaluate(ProviderReader read)`: runs the rules on a fresh read of local
    data and returns the applicable ones, at most one per rule.
  `Insight` (core, `lib/core/module/insight.dart`, pure Dart) holds `ruleId`, localized `text`, and an optional `location` (route) to
  open on tap (FR-025a).
  Rules are pure Dart in each module's `domain/insights/` with an injected `Clock`; they take plain
  inputs (breakdowns, budget status, streak summaries) and return typed facts. The module's
  `presentation/insights/` adapter loads the inputs through its repositories, runs the rules, and maps
  facts to `Insight` text with `l10nFor(locale)` (`lib/core/l10n/l10n_for.dart`, no `BuildContext`).
  The adapter runs each rule in its own `try`/`catch`; a failing rule is skipped (edge case "Insight
  rule fails").
- **Rationale**: Satisfies "each module provides its own insights" and "pure domain logic with unit
  tests and an injected clock". Localizing in the module keeps Home ignorant of rule semantics.
- **Alternatives considered**: Return keys + args and let Home localize: Home would need every
  module's ARB keys through `l10nByKey`, and placeholders are typed per key. A `Stream<List<Insight>>`:
  conflicts with FR-028 (insights change only on open, day change, and pull-to-refresh).

## R5. `appBarBadge()`: the streak flame

- **Decision**: `Widget? appBarBadge(BuildContext context)`, default `null`. Home shows the non-null
  badges of visible modules, in module order, in the app bar's actions. Habit returns
  `StreakFlameBadge`: a 48 dp tappable flame + number that opens HAB-01 (`context.go(Routes.habits)`)
  with the semantic label "Best active streak: 12 days".
- **Best active streak**: the highest `StreakSummary.current` across active habits, computed by
  `StreakFlameController` from `watchActiveHistories(from: today − 400 days)`. That is the same window
  HAB-01 uses (`HabitsTodayController.windowDays`, feature 005 R7), so the flame and HAB-01 always agree.
  Weekly-unit habits compare as `current × 7` days, and the badge shows the winner's own unit ("5 wk").
  Ties go to the habit that sorts first. With no habits or no active streak it shows 0 (spec Edge
  Cases).
- **Rationale**: Live (Drift stream) so a check-in on Home or HAB-01 updates it without reload (DSH-01
  criterion 1).
- **Alternatives considered**: Cache streaks in the `habits` table: a schema change and a second
  source of truth, rejected (feature 005 kept streaks computed).

## R6. Daily insight rotation (clarification Q1)

- **Decision**: Pure function `pickDailyInsight` in `lib/features/dashboard/domain/insight_rotation.dart`:
  - Inputs: `today` (local date key), `order` (the concatenated `ruleIds` of visible modules in
    module order), `applicable` (rule id → `Insight`), and `stored` (`date`, `ruleId`) or null.
  - **Same day** (`stored.date == today`): keep the stored rule if it applies. Otherwise take the next
    applicable rule after it in `order`, cycling.
  - **New day**: take the first applicable rule after `stored.ruleId` in `order`, cycling, skipping
    `stored.ruleId`. Fall back to `stored.ruleId` only if nothing else applies.
  - If `stored.ruleId` is not in `order` (its module is disabled, or the rule was removed), start
    from the top of `order`.
  - If nothing applies, return the starter tip and **do not** write, so rotation resumes from the
    last real pick.
  - The result says whether the stored pick must change. `HomeController` then writes
    `dailyInsightDate` + `dailyInsightId` through `SettingsRepository.setDailyInsight`.
- **Rationale**: Deterministic, testable with fixed dates, and it guarantees "never yesterday's when
  another applies" (SC-006) even when the applicable set changes daily.
- **Alternatives considered**: See the clarification options (date modulo, 7-day history).

## R7. When insights are computed

- **Decision**: `HomeController`, the one DSH-01 notifier (R14), holds the insight as its own field,
  `HomeState.insight: AsyncValue<InsightPick>`. It evaluates sources:
  - in `build()`, i.e. when Home opens;
  - at the next local midnight (`Timer`, the same pattern as `ExpenseDashboardController`);
  - when the app resumes on a new local date;
  - on `refreshInsights()` from pull-to-refresh.
  `refreshInsights()` replaces only `state.insight` and keeps the previous value while loading (no
  flicker). `build()` watches settings through `select` on `locale`, `enabledModules`, and
  `moduleOrder` only, the inputs that really change which insights apply. It never watches the
  insight keys, so persisting the pick does not re-run it. `homeComingSoonDismissed` is followed with
  `ref.listen`, which only does `state = state.copyWith(comingSoon: …)`, so dismissing or undoing the
  Coming soon card never re-evaluates insights or touches `state.insight`. When `build()` does re-run
  (module or language change), it seeds the new state with the previous insight value
  (`AsyncLoading().copyWithPrevious(old)`), so the card keeps its content and height until the new pick
  is ready (§15.6 no layout shift). It never watches data streams (FR-028). Module cards and sections watch their own module
  providers, so updating `HomeState` never rebuilds them.
- **Rationale**: FR-028 says pull-to-refresh recomputes insights only. Everything else on Home is
  already live.

## R8. Initial rule set and thresholds (FR-027)

Every rule is a pure function of plain inputs and a `Clock`. Money is in paise (`int`), and
percentages use integer math.

| Rule id (stable) | Module | Applies when | Text (en) | Opens |
| --- | --- | --- | --- | --- |
| `expense.categoryVsLastMonth` | Expense | A category's spend from the 1st to today is ≥ 20% above or below the same days last month. Both periods are > 0 and the larger is ≥ ₹200. Picks the largest absolute change. | "Food spending is 20% higher than last month" / "…20% lower than last month. Nice work." | EXP-11 Reports |
| `expense.budgetOnTrack` | Expense | An overall budget exists, spent < 80%, and spent ratio ≤ elapsed-days ratio | "You're on track: ₹4,000 left for 12 days" | EXP-08 |
| `expense.budgetNearLimit` | Expense | An overall budget exists and spent ≥ 80% | "You've used 85% of this month's budget" / over: "You're ₹500 over this month's budget. A no-spend day helps." | EXP-08 |
| `habit.nextMilestone` | Habit | Some habit's current streak is 1–3 units short of the next milestone (7, 21, 30, 50, 100, 365). Picks the smallest gap; ties go to the longer streak. | "You're 2 days away from a 30-day streak with Read" | HAB-03 for that habit |
| `habit.bestThisWeek` | Habit | Some habit was completed ≥ 3 times this week (week start from settings) | "You've done Read 5 times this week" | HAB-03 |
| `habit.comeback` | Habit | Some habit has current = 0, best ≥ 7, and is scheduled today | "Pick Read up again today. Your best is 21 days." | HAB-03 |

- Tone follows §15.7 (encouraging, no guilt). Category names come from the localized default-name
  catalog or are shown as the user typed them. Amounts are formatted with `MoneyFormatter.format`
  (`lib/core/utils/money_formatter.dart`) and the locale.
- Starter tip (no rule applies): "Log something today and tips will show up here" (dashboard ARB key).
  It is not tappable.

## R9. Expense card: budget bar

- **Decision**: `ExpenseDashboardController` combines `watchTodayAndMonthSpend(now)` with
  `BudgetRepository.watchOverview(monthKey)` (`overall` status). It reuses the existing
  `ProgressBarStatus` (`lib/core/widgets/progress_status.dart`, threshold logic `progressStatusOf`:
  under 80% / 80–100% / over 100%) and the EXP-08 level text ("85% used · Almost used"). The month
  figure on the bar comes from the budget status (same number as EXP-08). With no overall budget the
  card shows the month total plus a "Set budget" text button that opens the existing `BudgetSheet`
  (EXP-09) for the Overall budget. The "+ Expense" chip pushes `Routes.expenseAddPath(type: 'expense')`.
  Tapping the card body goes to EXP-01.
- **Rationale**: One threshold rule app-wide (§15.1 Consistent). The bar color changes at exactly 80%
  (amber) and above 100% (red), as `progressStatusOf` already does and tests cover.

## R10. Recent transactions query

- **Decision**: Add `Stream<List<TransactionView>> watchRecent({int limit = 5})` to
  `TransactionRepository`, implemented in Drift as `deletedAt IS NULL ORDER BY occurredAt DESC,
  createdAt DESC LIMIT ?`. It uses the existing `transactions_occurred` index. The section reuses the
  EXP-01 `TransactionRow`, which already renders transfers as "From → To" with a neutral amount
  (`transaction_row.dart`, clarification Q4). Tapping a row pushes EXP-03.
- **Rationale**: `watchPage` needs a `Period`, and there is no all-time period; a dedicated
  5-row query is the cheapest read for the 300 ms budget.

## R11. Habit card upgrade

- **Decision**: Keep the feature 005 card logic (toggle, count popup "+1" / custom value via
  `setValue`, long-press → HAB-03, milestone sheet, haptic). Changes:
  - The check buttons move from a `Wrap` into a horizontal `ListView`, as DSH-01 describes ("horizontal
    list"). Its height comes from the 48 dp button plus the text-scaled label, so 200% scale doesn't
    clip.
  - Unchecking a yes/no habit shows the shared `UndoSnackBar`; Undo re-applies the toggle (§15.5,
    FR-012).
  - The ring keeps habit-success coloring. It does not use the budget-threshold `ProgressRing`,
    because habits have no "over" state.
  - The card title row gets the "Today" date context.
- **Rationale**: Feature 005 already meets most of the DSH-01 design; rebuilding it adds risk.

## R12. FAB that hides on scroll

- **Decision**: Add a shared `ScrollAwareFab` to `lib/core/widgets/`. It listens to
  `UserScrollNotification` from the Home scroll view: hide on reverse, show on forward, and animate
  with `AnimatedSlide`/`AnimatedScale` over 200 ms (respecting `MediaQuery.disableAnimations`). It is
  placed through `AppScaffold.fab` (16 dp from edges, §15.3). The FAB opens a `MenuAnchor` menu with
  one `MenuItemButton` per `QuickAddAction`: icon, localized label via `l10nByKey`, and a 48 dp
  minimum height. Picking an entry calls `context.push(location)`.
- **Rationale**: No existing FAB hides on scroll (`app_scaffold.dart` only passes `fab`). A shared
  widget lets EXP-01 and HAB-01 adopt it later.
- **Alternatives considered**: A bottom sheet menu: heavier than "small menu". Speed-dial FABs: they
  add more filled buttons, which breaks §15.1 rule 2 (one primary action per screen).

## R13. Coming soon card (clarification Q3)

- **Decision**: New settings key `homeComingSoonDismissed` (bool, default false). Dismiss writes
  `true` at once, and the card leaves through `AnimatedSize` 200 ms. A 5 s `UndoSnackBar` "Undo" writes
  `false`. The card lists `comingSoonModules` from `core/module/module_registry.dart` (Water, Period),
  so it needs no new data.
- **Rationale**: Write-then-undo matches existing undo flows (archive habit, delete transaction).

## R14. Home structure and controllers

- **Decision**: `lib/features/dashboard/`:
  - `domain/`: `greeting.dart` (`greetingFor(DateTime)`: 05:00–11:59 morning, 12:00–16:59 afternoon,
    17:00–04:59 evening) and `insight_rotation.dart`. Pure Dart.
  - `presentation/controllers/home_controller.dart`: the one screen notifier (Constitution II). It
    exposes `HomeState`: greeting, date label inputs, visible modules, quick-add entries,
    `comingSoonDismissed`, and `insight` (R7). It reschedules itself at the next greeting boundary or midnight and on
    resume.
  - `presentation/screens/home_screen.dart`, replacing `home_placeholder_screen.dart` in
    `app_router.dart`.
  - `presentation/widgets/`: `home_app_bar.dart`, `insight_card.dart`, `coming_soon_card.dart`,
    `quick_add_menu.dart`.
  Module cards keep their own controllers inside their modules.
- **Rationale**: One notifier for DSH-01 (Constitution II). The insight is a separate field of
  `HomeState` so pull-to-refresh changes only that part of the state. The card, flame, and
  recent-transactions controllers belong to their modules' widgets (feature 005 precedent: "one
  notifier … for the Home card").

## R15. 300 ms load budget (SC-001)

- **Decision**:
  - Every Home read is a local Drift stream or a single settings read. No work happens before the
    first frame.
  - Insights are evaluated after the first frame (the insight card shows `DelayedSkeleton` only if
    evaluation takes > 300 ms).
  - Queries used: today/month spend (existing), the budget overview for one month (existing), recent
    5 (indexed), and active histories over a 400-day window (existing, same as HAB-01).
  - A host perf test (`test/features/dashboard/home_perf_test.dart`, same approach as
    `test/app/bootstrap_perf_test.dart`) seeds 10,000 transactions and 20 habits × 400 days in an
    in-memory database. It asserts that all module cards, recent transactions, and the streak flame
    show content within 300 ms of pumping Home. One manual check on a mid-range device is recorded
    in the task summary.
- **Rationale**: The host stand-in is the project's existing practice (feature 005 SC-003/004).

## R16. SET-06 "fully working" reordering

- **Decision**: Verified that the order already drives the tab bar (`AppShell._branchesFor` uses
  `registry.visible(settings)`) and persists through `SettingsRepository.setModules`. Home and the FAB
  use the same `visible(settings)`. Missing pieces to add:
  - `CustomSemanticsAction`s "Move up" / "Move down" on each SET-06 row (FR-034), calling the same
    `ModulesController.reorder`;
  - widget tests showing that a reorder changes Home card order, FAB menu order, and tab order at
    once (US6).
  The last-module guard already exists (`atLeastOneModuleKey`).

## R17. Layering enforcement

- **Decision**: Extend the import scan in `test/core/theme/no_hardcoded_style_test.dart` (it already
  enforces layer rules, see feature 005 contracts):
  - `lib/features/dashboard/**` must not import `package:dailytrack/features/` (anything outside
    dashboard) or `package:drift`;
  - `lib/features/*/domain/insights/**` and `lib/core/module/insight.dart` import nothing matching
    `package:flutter/` (with the slash) or `package:flutter_riverpod`. `insight_source.dart` is
    exempt because it needs `ProviderReader`.
- **Rationale**: Makes FR-005 a failing test, not a convention.

## R18. Day and time changes while Home is open

- **Decision**: `HomeController` reads `clockProvider`. It sets a `Timer`
  to the next boundary (greeting boundary or local midnight) and also re-check on
  `AppLifecycleState.resumed` through `AppLifecycleListener`. The module cards already rebuild at
  midnight (`ExpenseDashboardController`). The habit card and the streak flame get the same midnight
  rebuild.
- **Rationale**: Timers can fire late after the device sleeps, and resume re-checks cover that.
