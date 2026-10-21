# Contract: Screens (feature 006)

## DSH-01 Home: `lib/features/dashboard/presentation/screens/home_screen.dart`

Route `/home` (`Routes.home`), branch 0 of the shell. Replaces `HomePlaceholderScreen` in
`app_router.dart`, and the placeholder file is deleted.

**Layout** (one `CustomScrollView` inside `RefreshIndicator`, side padding 16/24 dp, max width 600 dp):

| # | Slot | Source | Key |
| --- | --- | --- | --- |
| 1 | App bar: greeting (`titleMedium`), date `EEE, d MMM` (`bodySmall`), badges | `HomeState` + `module.appBarBadge()` | `home_greeting`, `home_date`, `home_badge_<moduleId>` |
| 2 | Module cards, in SET-06 order | `module.dashboardCard()` | `home_card_<moduleId>` |
| 3 | Module sections | `module.dashboardSections()` | `home_section_<sectionId>` |
| 4 | Insight card | `HomeState.insight` (`HomeController`) | `home_insight` (`home_insight_starter` for the starter tip) |
| 5 | Coming soon card | `comingSoonModules` | `home_coming_soon` |
| — | FAB `ScrollAwareFab` → `MenuAnchor` | `quickAddActions()` of visible modules | `home_fab`, `home_quick_add_<labelKey>` |

Slots 2–5 are each wrapped in `DashboardSlot` (12 dp top gap + `AnimatedSize` 200 ms).

**States**:
- **Loading**: each slot loads on its own. `DelayedSkeleton` appears only after 300 ms. There is no
  full-screen spinner.
- **Empty**: each card shows its own empty state; see the module cards below.
- **Error**: only the failing card shows `ErrorState`-style text with "Try again". If insight
  evaluation fails as a whole, Home shows the starter tip.
- **Content**: as in the layout table above.

**Behavior**:
- Pull-to-refresh calls `HomeController.refreshInsights()`, which replaces only `HomeState.insight`.
- The FAB hides on scroll down and shows on scroll up.
- Back on Home exits the app (existing `AppShell` `PopScope`).
- Insight tap: `context.push(insight.location)` when non-null.
- Coming soon dismiss: an `IconButton` "Dismiss" (48 dp, semantic label), then `UndoSnackBar` (5 s).

**Ads**: none. No slot is reserved (feature 008).

**ARB keys** (prefix `home_`): `home_greetingMorning`, `home_greetingAfternoon`,
`home_greetingEvening`, `home_quickAddTooltip`, `home_insightTitle`, `home_insightStarter`,
`home_comingSoonTitle`, `home_comingSoonBody` (placeholder: names), `home_comingSoonDismiss`,
`home_comingSoonDismissed`, `home_recentTitle`, `home_seeAll`. All exist in en, hi, and gu.

## Expense card (upgrade): `lib/features/expense/presentation/widgets/expense_dashboard_card.dart`

| Element | Behavior | Key |
| --- | --- | --- |
| "Spent today" | `AmountText` expense | `spent_today` (existing) |
| "This month" | With an overall budget: "₹6,000 of ₹10,000", plus `ProgressBarStatus` with the level text. Without one: the month total plus a "Set budget" `TextButton` that opens `BudgetSheet` (Overall). | `spent_month`, `expense_card_budget_bar`, `expense_card_set_budget` |
| "+ Expense" chip | Opens EXP-02 with type expense | `expense_card_add` |
| Card tap | Opens EXP-01 | `home_card_expense` |
| Empty | "Add your first expense" (existing) | `expense_card_empty` |

## Recent transactions section (new): `lib/features/expense/presentation/widgets/recent_transactions_section.dart`

- Shows the title "Recent transactions" and a "See all" `TextButton` (opens EXP-01), then up to 5
  `TransactionRow`s (tap opens EXP-03).
- Hidden (`SizedBox.shrink()`) when there are no transactions.
- Controller: `RecentTransactionsController` (stream of `watchRecent(limit: 5)`).
- Keys: `recent_transactions`, `recent_see_all`, `recent_row_<id>`.

## Habit card (upgrade): `lib/features/habit/presentation/widgets/habit_dashboard_card.dart`

| Element | Behavior | Key |
| --- | --- | --- |
| Ring | "X of Y done today" (existing `_Ring`) | `habit_card_ring` |
| Check row | Horizontal `ListView`, one 48 dp button per habit scheduled today | `home_check_<habitId>` (existing) |
| Yes/no tap | Toggle. Unchecking shows `UndoSnackBar`. | — |
| Count tap | Popup "+1" / custom value (existing) | `count_add_one`, `count_custom` |
| Long-press | Opens HAB-03 | — |
| Empty | "Create your first habit" opens HAB-02 (existing) | `habit_card_empty` |
| None today | "Nothing scheduled today" (existing) | `habit_card_none` |

## Streak flame badge (new): `lib/features/habit/presentation/widgets/streak_flame_badge.dart`

- A flame icon plus the number (unit suffix for weekly habits) inside a 48 dp `InkResponse`. Tap
  opens `Routes.habits`.
- Semantic label `habit_streakBadgeLabel(count, unit)`: "Best active streak: 12 days".
- Controller: `StreakFlameController` (research R5). Key: `home_badge_habit`.

## SET-06 Modules (finish): `lib/features/settings/presentation/screens/modules_screen.dart`

- Adds `CustomSemanticsAction` "Move up" / "Move down" on each module row. The first row has no
  "Move up" and the last row has no "Move down". New ARB keys: `modules_moveUp`, `modules_moveDown`.
- Reorder already persists and drives tabs. New tests show that it also drives Home cards and the FAB
  menu.
