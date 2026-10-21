---

description: "Task list for Home Dashboard (DSH-01, T2.5)"
---

# Tasks: Home Dashboard (DSH-01, T2.5)

**Input**: Design documents from `specs/006-home-dashboard/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and the request ("insight rules are pure domain logic with unit
tests and an injected clock") require:
- At least one automated test per copied DSH-01 acceptance criterion and per user-story scenario (map
  in quickstart §5).
- Pure unit tests for every insight rule, the rotation, the greeting, and the best streak, using
  `Clock.fixed` / `MutableClock`.
- Widget tests with fakes and `NoAdsService`.
- DSH-01 goldens in light/dark × en/gu.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US7). Test names start with the
Screen ID and the scenario, e.g. `DSH-01 US2-1 yes/no check updates ring and flame` (Constitution I).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US7 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`.
- **Strings**:
  - Add keys to `tool/l10n/phase0_strings.py`, with en, hi, and gu together. Use the prefixes `home_`,
    `expense_`, `habit_`, `modules_`. Use sentence case, start buttons with a verb, and use ICU
    placeholders and plurals, never concatenation.
  - Then run `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit ARB files by hand.
  - Keys that are looked up by name (quick-add labels) must also be added to
    `lib/core/l10n/l10n_lookup.dart`.
- **Codegen**: after changing any `@riverpod`, `@freezed`, or Drift file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: read time only from `clockProvider` or an injected `Clock`. Never call `DateTime.now()`
  (scan-enforced). Habit day logic uses `LocalDate`.
- **Layering**: nothing under `lib/features/dashboard/` imports `package:dailytrack/features/` (other
  than itself), `package:drift`, or any `/data/` path. Insight rule files under
  `lib/features/*/domain/insights/` and `lib/core/module/insight.dart` import nothing matching
  `package:flutter/` (with the slash) or `package:flutter_riverpod` (scan-enforced from T006).
  `lib/core/module/insight_source.dart` is exempt because it needs `ProviderReader`.
- **Screens and widgets**:
  - Use only `AppTokens` and `lib/core/widgets/`.
  - Every slot has 4 states: `DelayedSkeleton` (shown only after 300 ms), empty, error with "Try
    again", and content.
  - Never show status by color alone.
  - Respect `MediaQuery.disableAnimations`.
  - Light haptic on habit check only.
  - No ad widgets and no reserved ad slot.
- **Widget tests**:
  - Use `pumpTestApp` (`test/helpers/test_app.dart`) with fakes from `test/helpers/fakes.dart`,
    `test/features/expense/fakes.dart`, and `test/features/habit/fakes.dart`, plus `MutableClock` and
    `NoAdsService`.
  - Assert that no `AppNativeAd`/`AppBannerAd` is in the tree.
- **Real-DB tests**: `makeRealContainer` (`test/helpers/real_container.dart`) or the
  expense/habit db fixtures.
- **Goldens**: tag `golden`, Linux only (`flutter test --tags golden --update-goldens`). On Windows
  run `flutter test --exclude-tags golden`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Folder skeletons and the strings every story needs

- [X] T001 Create the folders `lib/features/dashboard/domain/`, `lib/features/dashboard/presentation/{controllers,screens,widgets}/`, `lib/features/expense/domain/insights/`, `lib/features/expense/presentation/insights/`, `lib/features/habit/domain/insights/`, `lib/features/habit/presentation/insights/`, and `test/features/dashboard/`. Add `test/features/dashboard/fakes.dart` (header comment only, for later fake insight sources).
- [X] T002 Add all new strings to `tool/l10n/phase0_strings.py` in en, hi, and gu, then regenerate. Keys (contracts/screens.md, research R8):
  - Home: `home_greetingMorning`, `home_greetingAfternoon`, `home_greetingEvening`, `home_quickAddTooltip` ("Quick add"), `home_insightTitle` ("Tip for today"), `home_insightStarter` ("Log something today and tips will show up here"), `home_comingSoonTitle` ("Coming soon"), `home_comingSoonBody` (placeholder `{names}`), `home_comingSoonDismiss` ("Dismiss"), `home_comingSoonDismissed` ("Card hidden"), `home_recentTitle` ("Recent transactions"), `home_seeAll` ("See all").
  - Expense: `expense_quickAddIncome` ("Add income"), `expense_cardAdd` ("Expense"), `expense_cardSetBudget` ("Set budget"), `expense_cardMonthOfBudget` (placeholders `{spent}`, `{limit}`).
  - Expense insights: `expense_insightCategoryHigher` (`{category}`, `{percent}`), `expense_insightCategoryLower`, `expense_insightBudgetOnTrack` (`{amount}`, plural `{days}`), `expense_insightBudgetNear` (`{percent}`), `expense_insightBudgetOver` (`{amount}`).
  - Habit: `habit_insightNextMilestone` (`{count}`, `{milestone}`, `{name}`, day/week plural variants), `habit_insightBestThisWeek` (`{name}`, plural `{count}`), `habit_insightComeback` (`{name}`, `{best}` with unit plural), `habit_streakBadgeLabel` (plural `{count}`, day/week variants), `habit_streakBadgeWeeksShort` ("{count} wk"), `habit_uncheckedSnack` ("{name} unchecked").
  - Modules: `modules_moveUp` ("Move up"), `modules_moveDown` ("Move down").
  - Also add `expense_quickAddIncome` to `lib/core/l10n/l10n_lookup.dart`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Module contract, core types, settings keys, shared widgets, layering scan, and a Home screen shell that renders cards from the registry

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Write `test/core/module/tracker_module_contract_test.dart`:
  - a minimal `extends TrackerModule` subclass with only the required members returns `const []` from `quickAddActions()` and `dashboardSections()`, and `null` from `insights()` and `appBarBadge(context)`;
  - `ModuleRegistry.visible` still orders by `moduleOrder`.
  It must fail until T004.
- [X] T004 Change `lib/core/module/tracker_module.dart` per contracts/tracker_module.md:
  - `abstract interface class TrackerModule` → `abstract class TrackerModule` with `const TrackerModule();`;
  - replace `QuickAddAction? quickAddAction()` with `List<QuickAddAction> quickAddActions() => const [];`;
  - add `List<DashboardSection> dashboardSections() => const [];`, `InsightSource? insights() => null;`, and `Widget? appBarBadge(BuildContext context) => null;`, each with a doc comment stating its rule from the contract;
  - update the class doc comment to reference `specs/006-home-dashboard/contracts/tracker_module.md`.
- [X] T005 [P] Create two files:
  - `lib/core/module/insight.dart` (pure Dart, no imports outside the Dart SDK): `final class Insight { ruleId, text, location?, semanticLabel? }` plus `==`/`hashCode`;
  - `lib/core/module/insight_source.dart` (imports `provider_reader.dart` and `insight.dart`): `abstract interface class InsightSource { List<String> get ruleIds; Future<List<Insight>> evaluate(ProviderReader read); }`.
  Doc comments must state: "`ruleIds`: every rule the module may return, in its fixed rotation order. No duplicates"; "`evaluate`: applicable insights only, at most one per rule id, each id contained in `ruleIds`. Must not throw: a failing rule is skipped"; and that `ruleId` is "Stable across releases. Unique app-wide, prefixed with the module id". Create `lib/core/module/dashboard_section.dart` with `final class DashboardSection { const new({required this.id, required this.build}); final String id; final WidgetBuilder build; }`. Export all three files from `tracker_module.dart`.
- [X] T006 [P] Extend `test/core/theme/no_hardcoded_style_test.dart` (research R17) with these scans:
  - (a) `lib/features/dashboard/**` imports nothing from `package:dailytrack/features/` outside `features/dashboard/`, nothing from `package:drift`, and no `/data/` path;
  - (b) `lib/features/*/domain/insights/**` and `lib/core/module/insight.dart` import nothing matching `package:flutter/` (with the slash) or `package:flutter_riverpod`; `lib/core/module/insight_source.dart` is exempt;
  - (c) `lib/features/dashboard/**` and `lib/features/*/{domain,presentation}/insights/**` import no `package:http`, `dart:io`, or `package:dio` (SC-008).
- [X] T007 Change `ExpenseModule` (`lib/features/expense/expense_module.dart`), `HabitModule` (`lib/features/habit/habit_module.dart`), and `FakeTrackerModule` (`test/helpers/fakes.dart`) from `implements TrackerModule` to `extends TrackerModule`. Rename `quickAddAction()` to `quickAddActions()`:
  - Expense returns `[QuickAddAction(labelKey: 'expense_quickAdd', icon: Icons.add, location: Routes.expenseAddPath(type: TxnType.expense.name)), QuickAddAction(labelKey: 'expense_quickAddIncome', icon: Icons.add_card, location: Routes.expenseAddPath(type: TxnType.income.name))]`;
  - Habit returns `[QuickAddAction(labelKey: 'habit_quickAddCheckIn', icon: Icons.check_circle, location: Routes.habits)]`;
  - `FakeTrackerModule` takes optional constructor params `quickAdds`, `sections`, `insightSource`, and `badge` (all defaulting to empty/null).
  Update `test/features/expense/expense_module_test.dart` and `test/features/habit/habit_module_test.dart` to the list API, adding a check that Expense's second entry opens EXP-02 with type income.
- [X] T008 [P] Write `test/core/settings/settings_codec_home_test.dart`:
  - `dailyInsightDate`/`dailyInsightId`/`homeComingSoonDismissed` decode their defaults (`null`, `null`, `false`) when missing;
  - a malformed date (`"2026-13-40"`, `"x"`, `42`) decodes to null;
  - a non-string id decodes to null;
  - round-trips through `SettingsRepositoryImpl` on a real in-memory DB, and `setDailyInsight` writes both keys in one transaction (both visible in the same `watch()` emission).
- [X] T009 Add the 3 keys per data-model.md §1:
  - fields `String? dailyInsightDate`, `String? dailyInsightId`, `@Default(false) bool homeComingSoonDismissed` in `lib/core/settings/domain/app_settings.dart`;
  - constants and decoding in `lib/core/settings/data/settings_codec.dart`, where `dailyInsightDate` "must parse as a `yyyy-MM-dd` date key", otherwise null, using `lib/core/utils/date_keys.dart`;
  - `setDailyInsight({required String dateKey, required String ruleId})` (one transaction) and `setHomeComingSoonDismissed({required bool dismissed})` in `lib/core/settings/domain/settings_repository.dart` and `lib/core/settings/data/settings_repository_impl.dart`;
  - both writes in `FakeSettingsRepository` (`test/helpers/fakes.dart`).
- [X] T010 [P] Write `test/core/widgets/dashboard_slot_test.dart`:
  - `DashboardSlot` adds a top gap of `tokens.cardGap` around a visible child;
  - it adds no height when the child is `SizedBox.shrink()`;
  - it animates height over 200 ms, or instantly with `disableAnimations`;
  - a tap just below the gap hits the child, and a tap inside the gap does not (hit-test offset).
  Then create `lib/core/widgets/dashboard_slot.dart` (research R3): `AnimatedSize(duration: disableAnimations ? Duration.zero : 200 ms)` around `_GapIfNonEmpty(gap: tokens.cardGap)`, a `SingleChildRenderObjectWidget` whose `RenderProxyBox` subclass overrides `performLayout`, `paint`, `hitTestChildren`, and `applyPaintTransform` to offset the child by `gap` only when `child.size.height > 0` (size = child height + gap), and reports height 0 otherwise. Do not use a `LayoutBuilder`; it cannot know the child's size before layout.
- [X] T011 [P] Write `test/core/widgets/scroll_aware_fab_test.dart`: the FAB hides after a reverse `UserScrollNotification`, shows after a forward one, has a 48 dp+ target and a tooltip/semantic label, and uses no animation when `disableAnimations` is set. Then create `lib/core/widgets/scroll_aware_fab.dart` (research R12): a `NotificationListener<UserScrollNotification>` wrapper given the scroll subtree and the FAB, with `AnimatedSlide` + `AnimatedOpacity` over 200 ms and standard easing.
- [X] T012 [P] Write `test/features/dashboard/domain/greeting_test.dart`: 04:59 is evening, 05:00 morning, 11:59 morning, 12:00 afternoon, 16:59 afternoon, 17:00 evening, and 23:59 evening. `nextGreetingBoundary` returns 05:00/12:00/17:00 or the next 05:00 correctly, including across month end and DST-free local midnight. Then create `lib/features/dashboard/domain/greeting.dart` (`enum Greeting`, `greetingFor`, `nextGreetingBoundary`), which is pure Dart.
- [X] T013 Write `test/features/dashboard/presentation/home_screen_shell_test.dart`:
  - with the two real modules faked through `FakeTrackerModule`s, Home renders one `home_card_<id>` per visible module in `moduleOrder` order inside `DashboardSlot`s;
  - a disabled module's card is absent;
  - no `AppNativeAd`/`AppBannerAd` is present.
  Then create:
  - `lib/features/dashboard/presentation/controllers/home_controller.dart`: `@riverpod HomeController` with `freezed HomeState { greeting, today (DateTime local date), modules, quickAdds, comingSoon }`. It is built from `moduleRegistryProvider`, `clockProvider`, and settings watched only through `appSettingsProvider.select((s) => (s.enabledModules, s.moduleOrder))` (T048 adds `locale` to the select, and T056 follows `homeComingSoonDismissed` with `ref.listen`, never with `watch`). It reschedules a `Timer` to `min(nextGreetingBoundary, next midnight)` and re-evaluates on `AppLifecycleListener.onResume` (research R18). `comingSoon` stays empty until US7.
  - `lib/features/dashboard/presentation/screens/home_screen.dart`: `AppScaffold`, `showBack: false`, a `CustomScrollView` with a `SliverList` of slots, 16/24 dp padding, and 600 dp max width.
  Swap `HomePlaceholderScreen` for `HomeScreen` in `lib/app/router/app_router.dart`. Delete `lib/features/dashboard/presentation/screens/home_placeholder_screen.dart` and update any tests that referenced it (`grep -rn HomePlaceholderScreen test lib`).

**Checkpoint**: Foundation ready. The app runs with the new Home listing module cards, and all existing tests are green.

---

## Phase 3: User Story 1 - See today at a glance (Priority: P1) 🎯 MVP

**Goal**: Greeting, date, streak flame, expense card with the budget bar and "+ Expense", Recent transactions, all in SET-06 order and live.

**Independent Test**: Seed transactions, an overall budget, and habits, then open Home. Every section shows the right values in the right order, and adding an expense elsewhere updates Home without refresh.

### Tests for User Story 1 ⚠️

- [X] T014 [P] [US1] Write `test/features/habit/domain/streaks/best_streak_test.dart` for `bestActiveStreak`:
  - an empty list gives null;
  - picks the max current;
  - weekly unit compares as `current × 7` (a 2-week streak beats a 13-day one, 1 week loses to 8 days);
  - a tie goes to the first habit in sort order;
  - all zeros give `BestStreak(current: 0)` for the first habit.
- [X] T015 [P] [US1] Write `test/features/expense/data/watch_recent_test.dart` (real in-memory DB, expense db fixture), covering `TransactionRepository.watchRecent`:
  - orders by `occurredAt DESC, createdAt DESC`;
  - limit 5 out of 8;
  - excludes soft-deleted rows;
  - includes transfers with `toAccount` resolved;
  - re-emits after a create, a soft delete, and a category rename.
- [X] T016 [P] [US1] Extend `test/features/expense/presentation/expense_dashboard_card_test.dart` with:
  - `DSH-01 AC2 budget bar color changes at 80% and 100% thresholds`: at 79% the bar is `tokens.success`; at 80% and 100% it is `tokens.warning` with the "Almost used" level text; at 101% it is `tokens.expense` with the error icon. Use a fake `BudgetRepository` overview.
  - `US1-3` "₹6,000 of ₹10,000" text.
  - The no-budget case shows the month total and a `expense_card_set_budget` button that opens `BudgetSheet` for the Overall budget.
  - `expense_card_add` pushes `/expenses/add?type=expense`.
  - The card body tap goes to `/expenses`.
- [X] T017 [P] [US1] Write `test/features/expense/presentation/recent_transactions_section_test.dart`:
  - shows 5 rows of 8, newest first;
  - a transfer row shows "From → To" and an unsigned amount;
  - "See all" (`recent_see_all`) goes to EXP-01;
  - a row tap pushes EXP-03;
  - the section renders `SizedBox.shrink()` with zero transactions;
  - it updates live when the fake stream emits.
- [X] T018 [P] [US1] Write `test/features/habit/presentation/streak_flame_badge_test.dart`:
  - shows 12 for streaks 4 and 12;
  - shows "2 wk" when a weekly habit wins;
  - shows 0 with no habits;
  - the semantic label is "Best active streak: 12 days";
  - the target is ≥ 48 dp;
  - a tap navigates to `/habits`.
- [X] T019 [US1] Write `test/features/dashboard/presentation/home_screen_test.dart` group `US1`:
  - (1) at 08:30 (`MutableClock`), `home_greeting` reads "Good morning" and `home_date` reads `EEE, d MMM` in the locale; at 11:59 → 12:00 the greeting changes without a restart;
  - (2) a `FakeTrackerModule` badge renders in the app bar as `home_badge_<id>` in module order;
  - (3) a module section renders after all cards and before the insight slot;
  - (8) with `moduleOrder: [habit, expense]` the habit card comes first.
  Use `FakeTrackerModule`s with keyed card, section, and badge widgets, so this test needs no feature imports.

### Implementation for User Story 1

- [X] T020 [P] [US1] Create `lib/features/habit/domain/streaks/best_streak.dart`, pure Dart, with `BestStreak(habitId, current, unit)` and `bestActiveStreak(List<(Habit, StreakSummary)>)` per data-model.md §3: "Weekly units compare as `current × 7`. Ties go to the habit that sorts first. Returns null when there are no habits."
- [X] T021 [P] [US1] Add `Stream<List<TransactionView>> watchRecent({int limit = 5})` to `lib/features/expense/domain/repositories/transaction_repository.dart` and implement it in `lib/features/expense/data/repositories/drift_transaction_repository.dart`. Use `deletedAt IS NULL ORDER BY occurred_at DESC, created_at DESC LIMIT ?`, joined to categories and accounts the same way `watchPage` builds `TransactionView`, and watch the transactions, categories, and accounts tables. Add it to the fake in `test/features/expense/fakes.dart`.
- [X] T022 [US1] Upgrade `lib/features/expense/presentation/controllers/expense_dashboard_controller.dart` to emit `freezed ExpenseDashboardData { todayMinor, monthMinor, hasAnyTransaction, BudgetStatus? overall }`. It combines `watchTodayAndMonthSpend(now)` with `budgetRepositoryProvider.watchOverview(monthKey).map((o) => o.overall)`, following the `HabitDashboardController` two-subscription pattern, and keeps the midnight `Timer` (research R9).
- [X] T023 [US1] Upgrade `lib/features/expense/presentation/widgets/expense_dashboard_card.dart` per contracts/screens.md "Expense card":
  - **"This month" with a budget**: `expense_cardMonthOfBudget` with `AmountText`-formatted values, plus `ProgressBarStatus(ratio: overall.ratio, label: <EXP-08 level text>)` keyed `expense_card_budget_bar`. Reuse the label helper from `lib/features/expense/presentation/widgets/overall_budget_card.dart`; extract it to `expense_labels.dart` if it is private.
  - **Without a budget**: the month total plus a `TextButton` `expense_card_set_budget` that calls `BudgetSheet.show` for the Overall budget.
  - **Chip**: `ActionChip` `expense_card_add` with `Icons.add` and the `expense_cardAdd` label, which pushes `Routes.expenseAddPath(type: TxnType.expense.name)`.
  - **Card tap**: still goes to EXP-01.
  - **States**: the empty and error states are unchanged.
  Update the class doc comment, which currently says "No budget bar (T1.5)".
- [X] T024 [US1] Create `lib/features/expense/presentation/controllers/recent_transactions_controller.dart` (`@riverpod` stream of `watchRecent(limit: 5)`) and `lib/features/expense/presentation/widgets/recent_transactions_section.dart`. It is a `SummaryCard`-styled card with the title `home_recentTitle` and a `home_seeAll` `TextButton` (`recent_see_all`, `context.go(Routes.expenses)`), followed by up to 5 existing `TransactionRow`s (`recent_row_<id>`) that tap to `Routes.expenseDetailPath(id)`. It shows `DelayedSkeleton` while loading, inline error text with "Try again", and `SizedBox.shrink()` when the list is empty.
- [X] T025 [US1] In `lib/features/expense/expense_module.dart`, override `dashboardSections()` to return `[DashboardSection(id: 'expense.recentTransactions', build: (_) => const RecentTransactionsSection())]`.
- [X] T026 [US1] Create `lib/features/habit/presentation/controllers/streak_flame_controller.dart`. It is `@riverpod`, watches `habitRepositoryProvider.watchActive()` and `habitEntryRepositoryProvider.watchActiveHistories(from: today.addDays(-HabitsTodayController.windowDays))`, summarizes with `streakEngineProvider`, and emits `StreakFlameData(current, unit)` through `bestActiveStreak`. It rebuilds at local midnight, and it emits 0 when there are no habits. Create `lib/features/habit/presentation/widgets/streak_flame_badge.dart` (contracts/screens.md "Streak flame badge"): `Icons.local_fire_department` plus the count, using `habit_streakBadgeWeeksShort` for weekly units, a 48 dp `InkResponse` with `context.go(Routes.habits)`, and `Semantics(label: habit_streakBadgeLabel)`. Override `appBarBadge` in `lib/features/habit/habit_module.dart` to return `const StreakFlameBadge(key: Key('home_badge_habit'))`.
- [X] T027 [US1] Create `lib/features/dashboard/presentation/widgets/home_app_bar.dart`, a large app bar with:
  - the greeting (`titleMedium`, from `HomeState.greeting` → `home_greeting*` keys);
  - the date `DateFormat('EEE, d MMM', locale)` (`bodySmall`);
  - actions = `[for m in modules: m.appBarBadge(context)]`, non-null only, each wrapped in `KeyedSubtree(key: Key('home_badge_${m.id}'))`.
  Wire it into `home_screen.dart`.
- [X] T028 [US1] In `lib/features/dashboard/presentation/screens/home_screen.dart`, render the slots in DSH-01 order: the cards (`home_card_<id>`), then every visible module's `dashboardSections()` in module order (`home_section_<sectionId>`), then an insight placeholder slot (filled in US4) and a coming soon slot (filled in US7). Each slot sits in a `DashboardSlot`. Make T019 pass.

**Checkpoint**: US1 is fully functional. Home shows the header, flame, upgraded expense card, recent transactions, and the existing habit card, live and in order.

---

## Phase 4: User Story 2 - Check in habits from Home (Priority: P1)

**Goal**: The full DSH-01 habit card: horizontal check row, toggle with Undo, count popup, long-press to HAB-03, milestones. Ring, HAB-01, and the flame update without reload.

**Independent Test**: Create a yes/no habit and a count habit, then check them in from Home. The ring, the HAB-01 list, and the streak flame update without reload.

### Tests for User Story 2 ⚠️

- [X] T029 [P] [US2] Extend `test/features/habit/presentation/habit_dashboard_card_test.dart`:
  - `US2-1` a yes/no tap shows done, the ring goes "0 of 2" → "1 of 2", and a light haptic plays (`SystemChannels.platform` log);
  - `US2-2` unchecking shows `UndoSnackBar` with `habit_uncheckedSnack`, and Undo restores done;
  - `US2-3` count 12/20 → popup → `count_add_one` records 13, and `count_custom` sets the entered value;
  - `US2-4` long-press pushes `/habits/<id>`;
  - `US2-5` a milestone result opens the milestone sheet once;
  - the check row is a horizontal `ListView` that scrolls with 12 habits and does not overflow at 200% text scale on a 360 dp width;
  - `SC-002` taps: a yes/no check-in takes exactly 1 tap, and a count "+1" takes exactly 2 taps (button, then `count_add_one`).
- [X] T030 [US2] Write `test/features/dashboard/presentation/home_check_in_integration_test.dart` (real in-memory DB via `makeRealContainer`, real `ExpenseModule`/`HabitModule` registry), titled `DSH-01 AC1 marking a habit done from Home updates the ring, the habit list, and the streak icon without reload`:
  - seed habit "Read" with a 6-day streak, then tap `home_check_<id>`;
  - expect the ring to read "1 of 1" and `home_badge_habit` to show 7 with no `pumpWidget` rebuild;
  - switch to the Habits tab, where HAB-01 shows Read done with streak 7;
  - switch back to Home.

### Implementation for User Story 2

- [X] T031 [US2] In `lib/features/habit/presentation/controllers/habit_dashboard_controller.dart`, add a midnight `Timer` rebuild (as `ExpenseDashboardController` has) and expose `undo(String habitId, DayWriteResult previous)`, which re-applies the prior day state through `habitEntryRepositoryProvider.apply`, mirroring the HAB-01 undo path in `habits_today_controller.dart`.
- [X] T032 [US2] Upgrade `lib/features/habit/presentation/widgets/habit_dashboard_card.dart` (research R11):
  - Replace the `Wrap` with a horizontal `ListView.separated` (gap `tokens.s4`). Compute the row height as the 48 dp button plus the label's line height under the current `MediaQuery.textScaler`, measured with a `TextPainter` using the label's text style (no fixed constant, no `IntrinsicHeight`).
  - After a yes/no toggle that unchecks, show `UndoSnackBar` (`habit_uncheckedSnack`) whose action calls `controller.undo`.
  - Keep `_Ring`, the count popup, long-press, milestones, and haptics.
  - Update the doc comment to reference DSH-01.
  Make T029 and T030 pass.

**Checkpoint**: US1 and US2 work. The DSH-01 AC1 test is green.

---

## Phase 5: User Story 3 - Quick add from the + button (Priority: P1)

**Goal**: A single + FAB that opens a menu built from enabled modules' `quickAddActions()` in module order, and hides on scroll.

**Independent Test**: With both modules on, + shows 3 entries in SET-06 order. Disable Habit and only the expense entries remain.

### Tests for User Story 3 ⚠️

- [X] T033 [US3] Add group `US3` to `test/features/dashboard/presentation/home_screen_test.dart`:
  - (1) `FakeTrackerModule`s with quick-adds `[a1, a2]` and `[b1]` in order `[a, b]` → tapping `home_fab` shows `home_quick_add_a1`, `a2`, `b1` in that order;
  - (2) picking an entry pushes its `location`;
  - (3) a disabled module's entries are absent;
  - (4) scrolling down hides `home_fab` and scrolling up shows it;
  - every menu item is ≥ 48 dp tall and has its localized label (`l10nByKey`);
  - there is exactly one FAB;
  - `SC-002` taps: reaching EXP-02 takes exactly 2 taps (`home_fab`, then the entry).
- [X] T034 [P] [US3] Extend `test/features/expense/expense_module_test.dart` and `test/features/habit/habit_module_test.dart` (real routers) with:
  - `US3-2` "Add income" opens EXP-02 with the type segment on income;
  - "Add expense" opens it on expense;
  - "Check in habit" opens HAB-01 for today.

### Implementation for User Story 3

- [X] T035 [US3] Create `lib/features/dashboard/presentation/widgets/quick_add_menu.dart`. It is a `MenuAnchor` with one `MenuItemButton` per `QuickAddAction`: leading `Icon(action.icon)`, label `l10nByKey(l10n, action.labelKey)`, key `home_quick_add_<labelKey>`, min height 48 dp, and `onPressed: context.push(action.location)`. The anchor is a `FloatingActionButton` (`home_fab`, `Icons.add`, tooltip `home_quickAddTooltip`). Fill `HomeState.quickAdds` in `home_controller.dart` as `[for m in modules ...m.quickAddActions()]`.
- [X] T036 [US3] In `lib/features/dashboard/presentation/screens/home_screen.dart`, pass the menu through `AppScaffold.fab`, wrapped in `ScrollAwareFab` listening to the Home `CustomScrollView`. Hide the FAB entirely when `quickAdds` is empty. Make T033 pass.

**Checkpoint**: All P1 stories work. This is the MVP.

---

## Phase 6: User Story 4 - A daily insight (Priority: P2)

**Goal**: One local rule-based insight per day, provided by each module, rotated per clarification Q1, tappable to its screen (Q2), and recomputed by pull-to-refresh only.

**Independent Test**: Seed data that triggers several rules. One insight shows and stays the same all day, a different one shows the next day, and pull-to-refresh after a data change updates only the insight.

### Tests for User Story 4 ⚠️

- [X] T037 [P] [US4] Write `test/features/dashboard/domain/insight_rotation_test.dart` for `pickDailyInsight` (research R6), with fixed date keys:
  - no stored pick picks the first applicable in order and persists;
  - same day with the stored rule still applicable keeps it with `persist: false`;
  - same day with the stored rule no longer applicable picks the next applicable after it (cycling) and persists;
  - a new day picks the first applicable after the stored rule, skips the stored one, and persists;
  - a new day where only the stored rule applies returns it;
  - a stored rule not in `order` starts from the top;
  - nothing applicable returns `Starter` with no persist;
  - the order is the module order then each module's `ruleIds`;
  - `SC-006`: simulate 7 consecutive days with a randomly varying applicable set of ≥ 2 rules each day (seeded `Random`, 200 runs) and assert no two consecutive days repeat.
- [X] T038 [P] [US4] Write `test/features/expense/domain/insights/expense_insight_rules_test.dart` (`Clock.fixed`, research R8 thresholds):
  - **`categoryVsLastMonth`**:
    - +20% applies and +19% does not;
    - −20% gives a "lower" fact;
    - it needs both periods > 0 and the larger ≥ 20000 paise;
    - the comparison uses the same days last month, capped at last month's length (31 Mar vs 28/29 Feb);
    - it picks the largest absolute change.
  - **`budgetOnTrack`**: needs an overall budget, spent < 80%, and spent ratio ≤ elapsed ratio. It reports `daysLeft` including today.
  - **`budgetNearLimit`**: at 80% and 100% it gives `BudgetNearLimit`, and above 100% it gives `BudgetOver(overMinor)`.
  - **No budget**: no budget facts.
  - **Money**: all integer paise, no `double` (assert inputs and outputs are `int`).
- [X] T039 [P] [US4] Write `test/features/habit/domain/insights/habit_insight_rules_test.dart` (`Clock.fixed`):
  - `nextMilestone` gaps 1–3 apply and 4 does not, for each milestone 7/21/30/50/100/365; it picks the smallest gap, with ties going to the longer streak; it handles the week unit;
  - `bestThisWeek` needs ≥ 3 completions this week and respects `firstDayOfWeek` (Mon vs Sun);
  - `comeback` needs current 0, best ≥ 7, and the habit scheduled today; it does not apply if the habit is not scheduled today.
- [X] T040 [P] [US4] Write `test/features/expense/presentation/expense_insight_source_test.dart` and `test/features/habit/presentation/habit_insight_source_test.dart` (fakes):
  - `ruleIds` equal the documented order;
  - `evaluate` returns localized en and gu text with formatted amounts and names;
  - `location`s are `Routes.expenseReports`, `Routes.expenseBudgets`, and `Routes.habitDetailPath(id)`;
  - a rule that throws (fake input throws) is skipped while the others still return;
  - at most one insight per rule id.
- [X] T041 [US4] Write `test/features/dashboard/presentation/home_controller_insight_test.dart` for the insight part of `HomeController` (fake `InsightSource`s via `FakeTrackerModule`, `FakeSettingsRepository`, `MutableClock`):
  - `US4-1` exactly one insight;
  - `US4-2` advancing the clock past midnight changes the insight and writes `setDailyInsight`;
  - `US4-3` rebuilding on the same day keeps it with no write;
  - `US4-4` `refreshInsights()` re-evaluates the sources (call count +1); every `HomeState` field other than `insight` is identical (`==`) before and after, and the module card providers' listen counts don't change;
  - persisting the pick via `setDailyInsight` does not re-run evaluation (source call count unchanged after the write);
  - dismissing and undoing the Coming soon card (`setHomeComingSoonDismissed(true/false)`) does not re-evaluate sources (call count unchanged), and `state.insight` stays the identical value;
  - changing `moduleOrder` re-evaluates once, and `state.insight` keeps its previous value (`hasValue`) while loading;
  - `US4-5` sources are called without network (no overrides needed beyond fakes);
  - `US4-6` a disabled module's source is not called;
  - `FR-025` nothing applies → starter with no write;
  - while refreshing, the previous value stays (no `AsyncLoading` without a value).
- [X] T042 [US4] Write `test/features/dashboard/presentation/insight_card_test.dart`:
  - renders `home_insight` with the title and text;
  - `US4-7` a tap pushes `insight.location`;
  - the semantic label includes the destination;
  - the starter (`home_insight_starter`) is not tappable (no `onTap` in semantics);
  - pull-to-refresh on Home (`RefreshIndicator` fling) calls `refreshInsights()` once.

### Implementation for User Story 4

- [X] T043 [P] [US4] Create `lib/features/dashboard/domain/insight_rotation.dart` (pure Dart) with `StoredInsightPick(date, ruleId)`, sealed `InsightPick { Picked(insight, persist), Starter() }`, and `pickDailyInsight({required String today, required List<String> order, required Map<String, Insight> applicable, StoredInsightPick? stored})`, exactly per research R6 and the data-model.md §6 transitions. Make T037 pass.
- [X] T044 [P] [US4] Create `lib/features/expense/domain/insights/expense_insight_rules.dart` (pure Dart, injected `Clock`) with `ExpenseInsightInputs`, sealed `ExpenseInsightFact` (`CategoryChange`, `BudgetOnTrack`, `BudgetNearLimit`, `BudgetOver`), `ExpenseInsightRules.ruleIds = ['expense.categoryVsLastMonth', 'expense.budgetOnTrack', 'expense.budgetNearLimit']`, and `evaluate(inputs)` returning facts in rule order. Use integer percent math (`(a - b) * 100 ~/ b`). Make T038 pass.
- [X] T045 [P] [US4] Create `lib/features/habit/domain/insights/habit_insight_rules.dart` (pure Dart, injected `Clock`) with `HabitInsightInputs`, sealed `HabitInsightFact` (`NextMilestone`, `BestThisWeek`, `Comeback`), `HabitInsightRules.ruleIds = ['habit.nextMilestone', 'habit.bestThisWeek', 'habit.comeback']`, and `evaluate`. Reuse `milestones` from `lib/features/habit/domain/streaks/milestones.dart`. Make T039 pass.
- [X] T046 [US4] Create `lib/features/expense/presentation/insights/expense_insight_source.dart` (`final class ExpenseInsightSource implements InsightSource`). `evaluate(read)`:
  - read settings (locale, currency) once;
  - build two `CustomPeriod`s (this month 1st→today, last month 1st→same day capped);
  - take `watchBreakdown(...).first` for each and `budgetRepository.watchOverview(monthKey).first`;
  - run `ExpenseInsightRules` with `read(clockProvider)`, each fact mapped in its own `try`/`catch`;
  - localize with `l10nFor(settings.locale)`, using category names from the default-name catalog or as stored, and amounts from `MoneyFormatter.format`.
  Override `insights()` in `expense_module.dart` to return `const ExpenseInsightSource()`.
- [X] T047 [US4] Create `lib/features/habit/presentation/insights/habit_insight_source.dart`. `evaluate(read)`:
  - take `watchActive().first` and `watchActiveHistories(from: today − 400).first`;
  - summarize with `streakEngineProvider`, and compute this-week completions with `engine.weekProgress` and `scheduledToday`;
  - run the rules, guarding each one;
  - localize, with `location: Routes.habitDetailPath(habitId)`.
  Override `insights()` in `habit_module.dart`. Make T040 pass.
- [X] T048 [US4] In `lib/features/dashboard/presentation/controllers/home_controller.dart` (the one DSH-01 notifier, Constitution II, research R7), add `HomeState.insight` (`AsyncValue<InsightPick>`) and `refreshInsights()`:
  - `build()` watches settings only through `appSettingsProvider.select((s) => (s.locale, s.enabledModules, s.moduleOrder))` and the registry, never the insight keys or `homeComingSoonDismissed`. It starts an evaluation without awaiting it. On the first build `insight` starts as `AsyncLoading`; on a later re-run (module or language change) it starts as `AsyncLoading<InsightPick>().copyWithPrevious(<previous insight>)`, read from `stateOrNull` before rebuilding, so the card keeps its content and height (§15.6).
  - Gather `insights()` from `visible(settings)`. The order is `[for m in visible ...m.insights()!.ruleIds]`.
  - Evaluate all sources in parallel (`Future.wait`, each wrapped in `catchError → []`), then call `pickDailyInsight` with the stored pick from settings.
  - On `persist`, call `settingsRepository.setDailyInsight`. The write must not retrigger `build` or evaluation, which is why the `select` above excludes the insight keys.
  - Set a midnight `Timer` and handle `AppLifecycleListener.onResume`, both re-evaluating when the date changes.
  - `refreshInsights()` re-evaluates and replaces only `state.insight`, keeping the previous value while loading (`AsyncLoading<InsightPick>().copyWithPrevious(previousInsight)`).
  Make T041 pass.
- [X] T049 [US4] Create `lib/features/dashboard/presentation/widgets/insight_card.dart`: a `SummaryCard` titled `home_insightTitle` with `Icons.lightbulb_outline`, the text, and `InkWell` → `context.push(location)` when a location is set. It has `Semantics(button: location != null, label: semanticLabel ?? text)` and the starter key `home_insight_starter`. `DelayedSkeleton` covers loading, and if the whole evaluation fails it shows the starter. In `home_screen.dart`, fill the insight slot and wrap the scroll view in `RefreshIndicator(onRefresh: () => ref.read(homeControllerProvider.notifier).refreshInsights())`. Make T042 pass.

**Checkpoint**: Insights work for both modules, rotate daily, and refresh on pull.

---

## Phase 7: User Story 5 - First day and single-module users (Priority: P2)

**Goal**: Friendly empty states with one action each, and a gap-free layout with only one module enabled.

**Independent Test**: Fresh install with both modules, then with only Expense, then with only Habit. Layout and actions are correct in each case.

### Tests for User Story 5 ⚠️

- [X] T050 [US5] Write `test/features/dashboard/presentation/home_single_module_test.dart` using the real modules with fake repositories (`expense_test_app.dart`/`habit_test_app.dart` helpers):
  - `DSH-01 AC3 screen renders correctly with only one module enabled`, as two cases:
    - **only expense**: no `home_card_habit`, `home_badge_habit`, "Check in habit", or habit insight; expense card, recent transactions, and insight present;
    - **only habit**: no `home_card_expense`, `home_section_expense.recentTransactions`, "Add expense", or "Add income".
    For both, assert that the vertical distance between consecutive visible slots equals `tokens.cardGap` (no empty `DashboardSlot` gap).
  - `US5-1`–`US5-5` first day:
    - "Add your first expense" opens EXP-02;
    - recent transactions is hidden;
    - "Create your first habit" opens HAB-02;
    - the flame shows 0;
    - the insight card shows the starter tip.
  - Each card's error state shows only in that card while the others render.
  - `FR-037`: on a 360×780 dp surface, with order `[habit, expense]` and with `[expense, habit]`, every `home_check_*` button is fully visible without scrolling (its rect lies inside the viewport above the FAB).

### Implementation for User Story 5

- [X] T051 [US5] Fix whatever T050 exposes:
  - in `lib/core/widgets/dashboard_slot.dart`, a zero-height child must add no gap;
  - in `lib/features/expense/presentation/widgets/recent_transactions_section.dart`, the empty case must be shrink;
  - in `lib/features/dashboard/presentation/screens/home_screen.dart`, a disabled module must contribute nothing.
  Confirm the empty-state copy in both cards matches DSH-01 ("Add your first expense", "Create your first habit"). Make T050 pass.

**Checkpoint**: First-day and single-module layouts are correct.

---

## Phase 8: User Story 6 - Arrange modules in SET-06 (Priority: P2)

**Goal**: SET-06 reordering drives Home cards, the FAB menu, and tabs at once, persists, and is accessible without dragging.

**Independent Test**: Reorder in SET-06, go back to Home, and the cards, FAB order, and tab order change. Restart and the order is kept.

### Tests for User Story 6 ⚠️

- [X] T052 [P] [US6] Extend `test/features/settings/modules_screen_test.dart`, which is the canonical SET-06 test file. Leave `test/features/habit/presentation/modules_screen_test.dart` unchanged and add nothing to it:
  - `US6-4` each row exposes the `CustomSemanticsAction`s "Move up"/"Move down" (the first row has no Move up, the last has no Move down);
  - invoking "Move down" on Expense (via `tester.semantics.performAction` / `SemanticsOwner.performAction`) calls `reorder` and the rows swap;
  - `US6-3` turning off the last enabled module shows `modules_atLeastOne` (existing behavior, keep the test).
- [X] T053 [US6] Add group `US6` to `test/features/dashboard/presentation/home_screen_test.dart`, plus `test/app/router/app_shell_test.dart` with the real `ModulesScreen`:
  - `US6-1` reorder in SET-06 → back to Home → the habit card comes first, the FAB menu lists the habit entry first, and the Habits destination comes before Expenses;
  - `US6-2` the order survives re-pumping with the same `FakeSettingsRepository` (persistence through the repository).

### Implementation for User Story 6

- [X] T054 [US6] In `lib/features/settings/presentation/screens/modules_screen.dart`, wrap each module row in `Semantics(customSemanticsActions: {CustomSemanticsAction(label: l10n.modules_moveUp): () => onReorder(i, i - 1), CustomSemanticsAction(label: l10n.modules_moveDown): () => onReorder(i, i + 1)})`, omitting actions at the ends. Check the index semantics of `onReorderItem` (index after removal) in `ModulesController.reorder`. Make T052 and T053 pass.

**Checkpoint**: SET-06 fully drives Home and navigation.

---

## Phase 9: User Story 7 - Coming soon card (Priority: P3)

**Goal**: A dismissible Water/Period card with a 5 s Undo. After that it is hidden for good (clarification Q3).

**Independent Test**: Dismiss, Undo, dismiss again, wait 5 s, restart. The card stays hidden.

### Tests for User Story 7 ⚠️

- [X] T055 [US7] Write `test/features/dashboard/presentation/coming_soon_card_test.dart`:
  - `US7-1` the card shows last, naming Water and Period from `comingSoonModules`;
  - `US7-2` dismiss (`home_coming_soon_dismiss`, 48 dp, semantic label) calls `setHomeComingSoonDismissed(dismissed: true)`, the card leaves via `AnimatedSize`, and an `UndoSnackBar` shows; Undo calls `dismissed: false` and the card returns in place;
  - `US7-3` with `homeComingSoonDismissed: true` at start, there is no card and no SET-06 control restores it.

### Implementation for User Story 7

- [X] T056 [US7] Create `lib/features/dashboard/presentation/widgets/coming_soon_card.dart`. It is a `SummaryCard` titled `home_comingSoonTitle` with body `home_comingSoonBody(names)`, where the names are localized via `l10nByKey(nameKey)` and joined with the locale's list format (an ARB placeholder, no concatenation), and a dismiss `IconButton` (`Icons.close`, tooltip `home_comingSoonDismiss`). In `home_controller.dart`, follow `appSettingsProvider.select((s) => s.homeComingSoonDismissed)` with `ref.listen(..., fireImmediately: true)` and set `state = state.copyWith(comingSoon: dismissed ? [] : comingSoonModules)`. Do not add it to the `build()` select (research R7) and add `dismissComingSoon()` / `undoDismissComingSoon()`, which call the repository. In `home_screen.dart`, fill the last slot and show `UndoSnackBar(home_comingSoonDismissed)` on dismiss. Make T055 pass.

**Checkpoint**: All user stories are complete.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Goldens, accessibility, performance, extensibility proof, integration flow, docs, and quality gates

- [X] T057 [P] Extend `test/app/module_extensibility_test.dart` (SC-008 of feature 001, FR-005 here). A fake third module `notes` with a card, a section, a badge, one quick-add, and an `InsightSource` returning one insight contributes all five to Home with no other code change. Disabling it removes all five.
- [X] T058 [P] Write `test/a11y/home_font_scale_test.dart` (SC-005), at 200% text scale on a 360×780 dp surface with both modules and seeded content, in en and gu:
  - no `RenderFlex` overflow and no clipped text in the app bar, cards, check row, recent rows, insight, coming soon, or FAB menu;
  - every tappable element is ≥ 48 dp (`meetsGuideline(androidTapTargetGuideline)`) and labeled (`labeledTapTargetGuideline`);
  - text contrast passes (`textContrastGuideline`) in light and dark.
- [ ] T059 [P] Write `test/goldens/home_golden_test.dart` (tag `golden`): DSH-01 with seeded content and in its first-day state, in light/dark × en/gu, plus only-expense and only-habit variants in light/en. Generate the baselines on Linux (`--update-goldens`).
- [ ] T060 Write `test/features/dashboard/home_perf_test.dart` (SC-001, research R15). Use a real in-memory DB seeded with 10,000 transactions over 24 months, an overall budget, and 20 habits × 400 days of entries. Use `tester.runAsync` for the real database work. Start a `Stopwatch` immediately before `pumpWidget(HomeScreen …)`, then call `pump()` in 16 ms steps until `spent_today`, `habit_card_ring`, five `recent_row_*`, and `home_badge_habit` all show content; fail as soon as 300 ms pass. Assert < 300 ms (host stand-in, same as `test/app/bootstrap_perf_test.dart`). If it fails, profile the queries before changing UI.
- [ ] T061 [P] Extend `integration_test/expense_flow_test.dart` (§13 "add expense → see on Home → appears in Reports"):
  - after saving an expense via + → "Add expense", assert that Home's `spent_today` and the first `recent_row_*` show it;
  - check in a habit from Home and assert that the flame increments.
- [ ] T062 [P] Update docs:
  - check that `docs/spec.md` §3, §4, and §7 match the final code (the member names, and the settings keys `dailyInsightDate`, `dailyInsightId`, `homeComingSoonDismissed`);
  - tick `T2.5` in `docs/spec.md` §14 only after T064 passes, and leave the DSH-01 native-ad criterion unticked for feature 008;
  - add a `docs/CLAUDE.md` note under the module rules: "Home reaches modules only through `TrackerModule` (`dashboardCard`, `dashboardSections`, `insights`, `appBarBadge`, `quickAddActions`)".
- [X] T063 Run the §15.10 design review checklist on DSH-01, the expense card, the habit card, recent transactions, the flame, and SET-06, excluding the ad items. Fix any findings and record the results for the task summary.
- [ ] T064 Run the quality gates and fix all findings:
  - `dart run build_runner build --delete-conflicting-outputs`;
  - `flutter analyze` (zero warnings);
  - `dart format --set-exit-if-changed .`;
  - `flutter test --exclude-tags golden` on Windows, plus `flutter test` with goldens on Linux/CI.
  Then walk through quickstart.md §4 on the dev flavor, including the manual mid-range device timing for SC-001, and write the task summary: files changed, tests added, the §15.10 results, and open items (DSH-01 native ad → feature 008, home widget → feature 007).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends on Setup and blocks all stories. T004 must land before T007. T005 before T007. T009 before any controller that reads the new settings. T013 before every Home test.
- **User stories (Phases 3–9)**: all depend on Phase 2.
  - **US1**: no story dependency.
  - **US2**: uses the US1 flame (T026) for its AC1 integration test (T030).
  - **US3**: independent of US1/US2 (it tests with `FakeTrackerModule`).
  - **US4**: independent. It fills the insight slot reserved in T028; if US1 is not done, add the slot in T049.
  - **US5**: verifies US1–US4 together, so run it after them.
  - **US6**: independent; T053 benefits from US3's FAB.
  - **US7**: independent.
- **Polish (Phase 10)**: after the desired stories. T059 goldens and T060 perf need US1–US4 and US7 done.

### Within Each User Story

- Tests are written first and fail, then implementation follows.
- Pure domain code (rules, rotation, best streak) comes before adapters and controllers, which come before widgets, which come before the Home wiring.
- Run codegen after each `@riverpod`/`@freezed` change.

### Parallel Opportunities

- **Phase 2**: T005, T006, T008, T010, T011, and T012 touch different files.
- **US1**: tests T014–T018 are parallel; T020 and T021 are parallel.
- **US4**: tests T037–T040 are parallel; T043, T044, and T045 (three pure files) are parallel.
- **Polish**: T057, T058, T059, T061, and T062 are parallel.
- **Stories**: after Phase 2, US3, US6, and US7 can run in parallel with US1, since they touch different files except `home_screen.dart`. Serialize edits to `home_screen.dart` and `home_controller.dart`.

---

## Parallel Example: User Story 4

```text
# Tests together:
Task: "T037 insight_rotation_test.dart"
Task: "T038 expense_insight_rules_test.dart"
Task: "T039 habit_insight_rules_test.dart"
Task: "T040 expense/habit insight source tests"

# Pure domain together:
Task: "T043 lib/features/dashboard/domain/insight_rotation.dart"
Task: "T044 lib/features/expense/domain/insights/expense_insight_rules.dart"
Task: "T045 lib/features/habit/domain/insights/habit_insight_rules.dart"
```

---

## Implementation Strategy

### MVP First (P1 stories)

1. Phase 1 Setup, then Phase 2 Foundational (the contract change, settings keys, and Home shell).
2. US1: at-a-glance overview. **Validate** with the US1 tests and quickstart §4 steps 1–3.
3. US2: check-in from Home. **Validate** DSH-01 AC1.
4. US3: + menu. **The MVP is done**: Home is useful daily.

### Incremental Delivery

5. US4 insights → US5 empty/single-module (DSH-01 AC3) → US6 SET-06 → US7 Coming soon.
6. Polish: goldens, a11y, perf (SC-001), integration, docs, gates.

---

## Notes

- [P] means different files and no dependency on an incomplete task.
- The DSH-01 acceptance criteria map to: AC1 → T030, AC2 → T016, AC3 → T050. The native-ad criterion is out of scope (feature 008).
- Never add a placeholder where the native ad will go (§15.8).
- Commit after each task or logical group, with the Screen ID in the message (e.g. `DSH-01: add insight rotation`).
