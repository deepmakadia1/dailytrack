# Contract: Screens, controllers, and states (feature 003)

The rules from feature 002 `contracts/screens.md` apply unchanged:
- One `riverpod_generator` notifier per screen, with a `freezed` state.
- Four states (skeleton after 300 ms, `EmptyState`, `ErrorState` with "Try again", content).
- `AppTokens` and `lib/core/widgets/` only. `bannerSlot: null` (FR-049).
- ARB keys `expense_*` in en, hi, and gu.
- The Screen ID starts each screen's doc comment and test names.

Additional rules for this feature:
- **Chart data is prepared in controllers** (research R12). Widgets under
  `presentation/widgets/charts/` only map view models to `fl_chart`. Controllers and states never
  import `fl_chart`.
- Every time read goes through `clockProvider`.

---

## EXP-08 Budgets: `BudgetsScreen` / `BudgetsController`

**Args**: `month` (`yyyy-MM`, optional; defaults to the current month).

**State** `BudgetsState`: `monthKey`, `overview: AsyncValue<BudgetsOverview>`.

**Intents**:
- `previousMonth()` and `nextMonth()`.
- `copyLastMonth() → Future<int>`: the snackbar shows "Copied {count, plural, …}" or "Nothing to
  copy".
- `deleteBudget(id) → Undo`.

**Layout** (US1 s1):
- `AppScaffold` with the title "Budgets" and an overflow menu with "Copy last month's budgets".
- `PeriodSelector` in month-only mode (`< October 2026 >`). The picker is disabled because this
  screen is month-only.
- `SummaryCard` for Overall: limit, spent, remaining, `ProgressBarStatus`, and one of:
  - "{amount} per day left for {days, plural}" (current month);
  - "No budget left this month" (remaining ≤ 0);
  - "Under budget by {amount}" or "Over budget by {amount}" (past month);
  - "{amount} per day for {days} days" (future month).

  With no Overall budget, the card says "Set an overall budget" and has a "Set budget" text
  button.
- Section "Category budgets": rows of `CategoryAvatar`, name (+ "Hidden" label),
  "{spent} of {limit}", and `ProgressBarStatus`. The level is also shown as a text or icon label,
  never by color alone.
- Section "Categories without budget": rows with a "Set budget" text button.
- No native ad (out of scope).

**States**:
- Empty (no budgets in the month): `EmptyState` with the explanation and a "Set monthly budget"
  button → EXP-09 with Overall preselected.
- Loading and error as standard.

**Navigation**: tapping a row, the overall card, or "Set budget" opens EXP-09
(`showAppBottomSheet`).

## EXP-09 Set budget: `BudgetSheet` / `BudgetFormController`

**Args**: `monthKey`, and either `budgetId?` (edit) or `categoryId?`/`overall` (new, preselected).

**State** `BudgetFormState`:
- `mode` (new/edit), `slot` (Overall or a category id), `availableSlots` (new mode: Overall plus
  expense categories without a budget that month).
- `expression` and `limitMinor` (shared `NumericKeypad` + `AmountEntry`), `rollover`.
- `showErrors`, `saving`, `saveFailed`.

**Intents**: `selectSlot`, `keypad*`, `toggleRollover`, `save() → bool`, `delete() → Undo?`.

**Layout**: `AppBottomSheet` titled "Set budget". It has 3 fields (category picker, amount,
"Repeat every month" switch), which fits the §15.3 bottom-sheet rule. The primary button is
"Set budget". In edit mode the category is read-only and a "Delete budget" text button is shown in
the error color.

**Validation**: `validateBudget` errors are shown inline. If the slot was taken meanwhile, the
error says so.

## EXP-10 Recurring transactions: `RecurringScreen` / `RecurringController`

**State**: `AsyncValue<({List<RecurringRuleView> active, List<RecurringRuleView> paused})>`
(paused includes ended rules).

**Intents**: `pause(id)`, `resume(id)` (disabled for ended rules), `delete(id) → Undo`.

**Layout**:
- Rows: `CategoryAvatar` (or the transfer icon), note or category name, signed `AmountText`,
  frequency text from `RecurrenceSchedule.describe()` + ARB, and "Next: {date}" (relative when
  close).
- Ended rows show "Ended {date}". Rows with a stale reference show a warning line ("Account
  archived") with an icon.
- Swipe left = Delete (red, trash icon). Swipe right = Pause or Resume. Both are also in the
  long-press menu.
- The FAB "Add recurring transaction" (one primary action) → `/expenses/recurring/add`.

**States**: empty → explanation and an "Add recurring transaction" button (the FAB is hidden while
the empty state shows its button, to keep one primary action).

**Navigation**: tapping a row → `/expenses/recurring/:ruleId/edit`.

## EXP-02 Add / edit transaction (changed): `TransactionFormController`

**New state**:
- `mode: FormMode` (new, edit, ruleEdit) and `ruleId?`.
- `repeat: RepeatState` (`enabled`, `frequency` (default monthly), `endDate?`, `describe`).
- `linkedToRule: bool` (edit of a linked entry → Repeat hidden, US3 s13).

**New intents**: `toggleRepeat`, `setFrequency`, `setEndDate`, `clearEndDate`.

**Repeat section** (item 9, above Save, inside the scroll area):
- A switch "Repeat". When on: `ChipSelector` with Daily, Weekly, Monthly, and Yearly, an
  "End date (optional)" chip, and the schedule in words.
- Error `repeatEndBeforeStart` is shown inline under the section.

**Save** (research R16):
- New + repeat: `createWithFirstOccurrence`, then `generateDue`. Undo → `undoRuleCreation`.
- Edit of an unlinked entry + repeat (Q3): `attachNewRule`, then generate. Undo →
  `undoRuleCreation(restoreSnapshot: original)`.
- Rule-edit, repeat on: `updateRule`. Undo restores the previous rule snapshot.
- Rule-edit, repeat off (Q5): `softDelete(rule)`, with the snackbar "Recurring transaction
  deleted · Undo".
- **After any successful save that creates or changes an expense**: `budgetAlertChecker.check(...)`
  runs `unawaited` and inside `try/catch` (FR-015, FR-018). The snackbar "Saved · Undo" is not
  affected.

**Rule-edit mode** (`/expenses/recurring/:ruleId/edit`):
- The title is "Edit recurring transaction". The date chip is labeled "Next date".
- There is no receipt field (rules have no receipts) and no delete icon (Repeat off or EXP-10
  delete is used instead).
- If the rule is missing or deleted, the screen shows the not-found state and pops (same as
  feature 002).

## EXP-01 (changed) and EXP-03 (changed)

- EXP-01 overflow: Categories, Accounts, **Budgets, Recurring, Reports**.
- `TransactionRow` shows `Icons.repeat` (16 dp, semantic label "Recurring") next to the
  category name when `isRecurring`. The row height is unchanged.
- EXP-03: when `recurringRuleId != null`, a "Created from recurring rule" link → rule-edit. If the
  rule is deleted, the text says "Recurring rule deleted" and is not a link.

## EXP-11 Reports: `ReportsScreen` / `ReportsController`

**State** `ReportsState`:
- `period: Period` (default current `MonthPeriod`), `tab: ReportTab`.
- `advancedUnlocked: bool` (from `FeatureGate.watch(advancedReports)`).
- `locked: bool` (derived with `ReportAccess`).
- `data: AsyncValue<ReportVm>`.

`ReportVm` is a union per tab: `OverviewVm`, `DonutVm`, `TrendVm`, `BarsVm` (research R12). Each
is computed in the controller from `watchLedger` and `watchBreakdown` (and, for Trends, the
previous-period ledger).

**Intents**: `setPeriod`, `setTab`, `selectSlice(categoryId?)`, `refresh()` (pull to refresh).

**Layout**:
- `PeriodSelector` with Week, Month, Year, and Custom. **Day is hidden**. Locked options show a
  lock icon (Q1 matrix).
- `TabBar` with Overview · Categories · Trends · Accounts. Locked tabs show a small lock icon and
  stay selectable, so the blurred preview can be seen.
- Overview: `SummaryCard`s for net savings, savings rate, and average daily spend, an
  income-vs-expense `BarChart`, and the top 3 categories as rows.
- Categories: a `PieChart` donut with a center label (total expense), a legend list (name, amount,
  %; tapping selects), and the selected category's transactions (`TransactionRow`, tap → EXP-03).
- Trends: a `LineChart`, with the current period solid and the previous one dashed, plus a legend
  with both labels (not color alone).
- Accounts: two horizontal `BarChart`s (by account, by payment mode), with value labels on each
  bar.
- Each chart has a `Semantics` summary ("Expense by category: Food 42%, …").
- When `locked`, the tab body is wrapped in `LockedFeatureOverlay(onWatchAd: null, onGetPro: null,
  message: …)`. The blurred child is rendered from **placeholder sample data**, not the user's
  numbers. This keeps the preview cheap and avoids loading advanced data while locked.
- No ad, and no "Export this report" action.

**States**:
- Empty period → `EmptyState` "No transactions in {period}" with "Add expense".
- Loading and error as standard. Pull to refresh calls `refresh()`.

## SET-01 placeholder (changed): `MorePlaceholderScreen`

When `debugToolsAvailableProvider` is true (dev flavor), a section "Developer" with a
`SwitchListTile` "Unlock all features (debug)" bound to `settings.debugUnlockAll`. In prod the
section is not built.
