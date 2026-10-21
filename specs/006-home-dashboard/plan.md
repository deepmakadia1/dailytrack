# Implementation Plan: Home Dashboard (DSH-01, T2.5)

**Branch**: `006-home-dashboard` | **Date**: 2026-10-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-home-dashboard/spec.md`

## Summary

This feature replaces the Phase 0 Home placeholder with the full DSH-01 dashboard (`docs/spec.md` §7,
§14 T2.5):
- an app bar with a time-of-day greeting, today's date, and module badges (Habit: best active streak
  flame);
- module summary cards in SET-06 order;
- module sections (Expense: last 5 transactions);
- one daily rule-based insight;
- a dismissible Coming soon card;
- a + FAB whose menu comes from each enabled module's quick-add actions.

**Approach**:
- **Module contract** (R1–R5): `TrackerModule` becomes an abstract base class with optional
  `dashboardSections()`, `insights()`, and `appBarBadge()` defaults, as the user requested.
  `quickAddAction()` becomes `quickAddActions()` (a list), so Expense can offer "Add expense" and "Add
  income". Home (`lib/features/dashboard/`) depends only on `lib/core/` and the module registry. An
  import scan enforces this (R17).
- **Modules own their parts**: each module keeps its card, sections, badge, and insight rules in its
  own folder. Rules are pure Dart in `domain/insights/` with an injected `Clock` and unit tests. A thin
  adapter in each module loads inputs from its repositories and localizes the text (R4, R8).
- **Rotation** (R6, clarification Q1): a pure `pickDailyInsight` stores one pick (date + rule id) in
  settings and never repeats yesterday's insight when another applies.
- **Card upgrades** (R9–R11):
  - the expense card gains the overall-budget `ProgressBarStatus` and a "+ Expense" chip;
  - the habit card gets a horizontal check row and Undo on uncheck;
  - a new `watchRecent(limit: 5)` query feeds Recent transactions, transfers included (Q4).
- **Live data**: all cards and sections use Drift streams. Pull-to-refresh recomputes insights only
  (R7).
- **SET-06**: adds "Move up" / "Move down" semantics actions. The order already drives tabs and now
  provably drives Home and the FAB menu (R16).
- **No schema change**: three new settings keys (key-value table).

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: existing only (spec §2). These are `flutter_riverpod` 3.4 +
`riverpod_generator` 4.0, `go_router` 18.0, `drift` 2.35, `freezed` 4.0, `intl` 0.20, and `clock` 1.1.
**No new packages.**

**Storage**: SQLite through Drift `AppDatabase`, schema **v4 unchanged**. It gains 3 `settings` keys
(`dailyInsightDate`, `dailyInsightId`, `homeComingSoonDismissed`) and one new read query
(`watchRecent`). See [data-model.md](data-model.md).

**Testing**: `flutter_test`:
- **Unit tests** cover insight rules, rotation, greeting, and best streak. They are pure and use
  `Clock.fixed` / `MutableClock`.
- **Data tests** cover `watchRecent` and the settings codec. They run on a real in-memory Drift
  database.
- **Widget tests** use fake repositories, `FakeTrackerModule`, and `NoAdsService`.
- **Goldens**: DSH-01 in light/dark × en/gu (Constitution IV).
- **Integration**: the §13 flow "add expense → see on Home → appears in Reports" is extended to
  include the Home check.

**Target Platform**: Android API 24+ (iOS-ready code, not tested)

**Project Type**: Mobile app (single Flutter project)

**Performance Goals**:
- Home content from local data in < 300 ms with 10,000 transactions and 20 habits (SC-001; host perf
  test plus one manual mid-range device check).
- Check-in from Home updates the ring, flame, and HAB-01 within the same frame sequence.
- No full-screen spinner; skeletons only after 300 ms.

**Constraints**:
- Offline, with zero network calls (SC-008).
- No ads and no reserved ad slot (feature 008).
- Home must not import the Expense or Habit features.
- Money in paise. Local `yyyy-MM-dd` keys.
- ARB strings in en, hi, and gu with placeholders.
- 200% font scale and 360 dp width. Status never by color only.

**Scale/Scope**:
- 1 screen rebuilt (DSH-01), 2 cards upgraded, 2 new module widgets (Recent transactions, streak flame),
  and 1 screen finished (SET-06 a11y).
- 6 insight rules.
- 1 interface changed (`TrackerModule`), 2 repositories extended (settings, transactions).
- About 35 new ARB keys × 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs used; spec updated before code | ✅ `docs/spec.md` updated 2026-10-19: Changes line, §3 `TrackerModule` (optional `dashboardSections()`, `insights()`, `appBarBadge()`; `quickAddActions()` list), §4 settings keys, and the DSH-01 Behavior bullets for clarifications Q1–Q4. Tests and files use `DSH-01`, `SET-06` |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; registry; one notifier per screen | ✅ Home in `lib/features/dashboard/` imports only `lib/core/` and `Routes`, enforced by an extended import scan (R17). Insight rules and the rotation are pure Dart with an injected `Clock`. Each module's widgets and rules live in its own folder. DSH-01 has one screen notifier (`HomeController`); the insight is a separate field of its state, so refresh replaces only that field. Module-owned card, flame, and recent-transactions controllers follow the feature 005 precedent (R14) |
| III. Data integrity & privacy | int money; UTC ms; local keys; soft delete; migrations; no egress | ✅ No schema change and no migration needed (settings are key-value rows). `watchRecent` excludes soft-deleted rows. Insight math uses integer paise. Insights are computed on the device and contain no data that leaves it |
| IV. Test-backed acceptance | ≥ 1 test per criterion; fakes + NoAdsService; DSH-01 goldens | ✅ Mapped in [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests): all 3 copied DSH-01 criteria, every user story, and SC-001/005/006/008. Rules and rotation are unit tested at boundaries. DSH-01 goldens are light/dark × en/gu |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; ARB; 48 dp; 200%; never color only | ✅ Uses `AppScaffold`, `SummaryCard`, `ProgressBarStatus`, `AmountText`, `UndoSnackBar`, `EmptyState`, `DelayedSkeleton`, and the new shared `ScrollAwareFab` and `DashboardSlot`. Each slot has loading, empty, error, and content states. The budget level shows text and an icon. The 300 ms budget has a perf test. §15.10 is checked in the task summary |
| VI. Isolated monetization | ads only via AdService; placements per §11 | ✅ By exclusion: no ad code. The DSH-01 native slot is deferred to feature 008 with nothing in its place (§15.8, "no empty boxes") |
| VII. Locked stack, YAGNI | §2 packages only | ✅ No new dependencies. `MenuAnchor` and `RefreshIndicator` are Flutter SDK. The home widget (007), daily summary notification (T3.4), and ads (008) stay out |

**Result**: PASS. **After Phase 1 design**: PASS. The interface change from `implements` to
`extends` (R1) is a mechanical edit to 2 modules and 1 test fake. It is needed because Dart interfaces
cannot carry the default implementations the user asked for.

## Project Structure

### Documentation (this feature)

```text
specs/006-home-dashboard/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R18
├── data-model.md        # Phase 1: settings keys, core/module/domain types, state transitions
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── tracker_module.md    # TrackerModule changes and per-module implementations
│   ├── repositories.md      # SettingsRepository + TransactionRepository additions
│   └── screens.md           # DSH-01, expense/habit cards, recent section, flame, SET-06
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
  app/router/app_router.dart                  # Home branch → HomeScreen
  core/
    module/
      tracker_module.dart                     # abstract class; quickAddActions(); 3 optional members
      insight.dart                            # NEW Insight (pure Dart)
      insight_source.dart                     # NEW InsightSource (needs ProviderReader)
      dashboard_section.dart                  # NEW DashboardSection
    settings/
      domain/app_settings.dart                # + dailyInsightDate, dailyInsightId, homeComingSoonDismissed
      domain/settings_repository.dart         # + setDailyInsight, setHomeComingSoonDismissed
      data/settings_codec.dart                # + 3 keys
      data/settings_repository_impl.dart      # + 2 writes
    widgets/
      scroll_aware_fab.dart                   # NEW FAB that hides on scroll down
      dashboard_slot.dart                     # NEW 12 dp gap + AnimatedSize wrapper
    l10n/app_{en,hi,gu}.arb                   # + home_*, expense_quickAddIncome, insight, flame, modules_move*
    l10n/l10n_lookup.dart                     # + expense_quickAddIncome (FAB labels resolve by key)
  features/
    dashboard/
      domain/
        greeting.dart                         # NEW greetingFor, nextGreetingBoundary
        insight_rotation.dart                 # NEW pickDailyInsight
      presentation/
        controllers/home_controller.dart      # NEW HomeState incl. insight; refreshInsights(); persist pick
        screens/home_screen.dart              # NEW (replaces home_placeholder_screen.dart, deleted)
        widgets/home_app_bar.dart             # NEW
        widgets/insight_card.dart             # NEW
        widgets/coming_soon_card.dart         # NEW
        widgets/quick_add_menu.dart           # NEW
    expense/
      expense_module.dart                     # extends; quickAddActions (2); sections; insights
      domain/repositories/transaction_repository.dart   # + watchRecent
      domain/insights/expense_insight_rules.dart        # NEW pure rules + facts
      data/repositories/drift_transaction_repository.dart  # + watchRecent
      presentation/controllers/expense_dashboard_controller.dart  # + overall budget
      presentation/controllers/recent_transactions_controller.dart  # NEW
      presentation/insights/expense_insight_source.dart  # NEW adapter (load, run, localize)
      presentation/widgets/expense_dashboard_card.dart    # budget bar, + Expense chip, Set budget
      presentation/widgets/recent_transactions_section.dart  # NEW
    habit/
      habit_module.dart                       # extends; quickAddActions; insights; appBarBadge
      domain/insights/habit_insight_rules.dart  # NEW pure rules + facts
      domain/streaks/best_streak.dart         # NEW bestActiveStreak
      presentation/controllers/habit_dashboard_controller.dart  # + midnight rebuild, undo op
      presentation/controllers/streak_flame_controller.dart     # NEW
      presentation/insights/habit_insight_source.dart  # NEW adapter
      presentation/widgets/habit_dashboard_card.dart   # horizontal row, undo on uncheck
      presentation/widgets/streak_flame_badge.dart     # NEW
    settings/presentation/screens/modules_screen.dart  # + Move up/down semantics actions
test/
  helpers/fakes.dart                          # FakeTrackerModule extends; settings fake + 2 writes
  core/module/, core/settings/, core/widgets/ # contract, codec, ScrollAwareFab, DashboardSlot
  core/theme/no_hardcoded_style_test.dart     # + dashboard/insights layering scan
  features/dashboard/                         # home_screen, controllers, rotation, greeting, perf
  features/expense/{domain/insights,data,presentation}/   # rules, watchRecent, card, section
  features/habit/{domain/insights,domain/streaks,presentation}/  # rules, best streak, card, flame
  features/settings/                          # SET-06 reorder + semantics
  app/module_extensibility_test.dart          # third module contributes to Home
  a11y/home_font_scale_test.dart              # NEW
  goldens/home_golden_test.dart               # NEW light/dark × en/gu
integration_test/                             # extend "add expense → Home → Reports"
```

**Structure Decision**: Single Flutter project, following the existing feature-first layout. Home
lives in `lib/features/dashboard/` and reaches modules only through `TrackerModule` (user request,
Constitution II). Module-specific Home parts live in `lib/features/expense/` and
`lib/features/habit/`.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| `TrackerModule` changes from `interface` to `abstract class` (modules `extends`) | The user asked for optional members with defaults; Dart interfaces cannot provide inherited defaults | Keeping the interface would force every current and future module to implement all three members (R1) |
| SC-001 verified on a host stand-in plus one manual device check | CI has no mid-range Android device | The same practice was accepted in features 003 and 005 |
