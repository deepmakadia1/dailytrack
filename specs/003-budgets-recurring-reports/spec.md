# Feature Specification: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Feature Branch**: `003-budgets-recurring-reports`

**Created**: 2026-10-15

**Status**: Draft

**Input**: User description: "Feature: Budgets, recurring rules, and reports. Implement tasks T1.5 to T1.7 from docs/spec.md, building on the Expense module from feature 002. Scope: Budgets (spec §4 budgets table): EXP-08 Budgets screen and EXP-09 Set budget sheet, overall and per-category monthly budgets, "Copy last month's budgets", automatic rollover on the first app open of a new month, and "per day left". Budget alerts: after saving a transaction in EXP-02, check budgets and send a local notification at 80% and 100%, once each per budget per month (Budget alerts channel in §12). Respect the Budget alerts setting. Recurring rules (spec §4 recurring_rules table): the Repeat toggle in EXP-02, EXP-10 Recurring transactions screen, and a generator that creates due transactions up to now and advances nextRunAt. Run it on every app open and from a daily workmanager job. Generated rows link to their rule and show a repeat icon in EXP-01. Reports: EXP-11 with Overview, Categories, Trends, and Accounts tabs, using fl_chart. Feature gating (spec §4 unlocks table): add the unlocks table and a FeatureGate service in core. Overview and Categories for the current and previous month are free. Trends, Accounts, Year, and Custom range require the advancedReports unlock and show LockedFeatureOverlay when locked. In the dev flavor only, add a debug switch in SET-01 to unlock all features. Out of scope (later features): rewarded ads and the "Watch an ad" action (show the overlay with only the "Get Pro" button, disabled, until feature 008), the "Export this report" action (feature 007), the daily summary notification (feature 007), and all ads. Copy the acceptance criteria for EXP-08, EXP-09, EXP-10, and EXP-11 exactly from the spec, plus the EXP-02 budget alert criterion. Follow the UI/UX rules in §15."

**Source of truth**: `docs/spec.md` v1.0, sections 4 (budgets, recurring_rules, unlocks, transactions.recurringRuleId), 5 (routes for EXP-08 to EXP-11), 8 (EXP-01, EXP-02, EXP-03, EXP-08 to EXP-11), 10 (SET-01 Notifications, PRM-02 unlock expiry rule), 12 (Budget alerts channel, Accessibility), 13 (performance targets, testing), 14 (Phase 1: T1.5–T1.7), and 15 (UI/UX guidelines).

> **Note on scope and wording**: The master spec and the project constitution (Principle VII, "Locked
> Stack") already fix the technology, and the request names three building blocks the master spec
> mandates: a background daily job for recurring rules, a charting library for reports, and the shared
> `LockedFeatureOverlay`. Requirements below name these and other mandated project parts (`FeatureGate`,
> `TrackerModule`, shared widgets of §15.4, schema versions) only because the master spec or the request
> fixes them. Everything else is described by observable behavior.

> **What feature 002 already delivered** (see `specs/002-expense-core/`): the transactions,
> categories, and accounts stores (local schema version 2), including the empty optional
> recurring-rule reference on each transaction; EXP-01 to EXP-07; `ExpenseModule` with routes, Home
> card, and quick-add; and the shared widgets, including `PeriodSelector`, `ProgressBarStatus`,
> `SummaryCard`, `AppBottomSheet`, and `LockedFeatureOverlay`. Feature 001 delivered the notification
> permission request. SET-01 is still a placeholder screen ("More" tab) until T3.1. This feature adds
> the budgets, recurring rules, and unlocks stores; the upgrade from schema version 2; EXP-08 to
> EXP-11; the Repeat toggle and budget alert check in EXP-02; the repeat icon in EXP-01; the
> "Created from recurring rule" link in EXP-03; and the core feature gate.

## Clarifications

### Session 2026-10-15

- Q: Should Week periods and Month periods older than last month be free or locked in Reports? → A: Option A. Overview and Categories are free for any week that overlaps the current or previous month. Months older than the previous month (and weeks entirely before it) require `advancedReports`.
- Q: Should saving an expense dated in an earlier month send budget alerts for that earlier month? → A: Option A. No. Only expenses dated in the current month alert, whether saved in EXP-02 or created by a recurring rule; past-month budgets still update on screen without a notification.
- Q: When editing a hand-entered transaction, should EXP-02 let the user turn Repeat on? → A: Option A. Yes. The entry becomes the first occurrence of a new rule, due occurrences after its date are generated immediately, and Undo removes the rule and generated entries and reverts the edit.
- Q: If a budget's limit is raised after an alert was sent, can that alert fire again? → A: Option A. Yes. Saving a new limit clears each alert marker whose threshold is no longer reached under it; markers still reached stay set.
- Q: In rule-edit mode, what happens when the user turns Repeat off and saves? → A: Option A. The rule ends: it is soft-deleted, generated entries are kept, and a 5-second Undo is offered.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Set monthly budgets and see how much is left (EXP-08, EXP-09) (Priority: P1)

A user wants to keep October's spending under ₹30,000 and food under ₹6,000. From the Expenses overflow menu they open Budgets, tap "Set monthly budget", enter ₹30,000 as the overall budget with "Repeat every month" on, then tap "Set budget" next to Food in the "Categories without budget" section and enter ₹6,000. The Budgets screen now shows the overall card with limit, spent, remaining, a progress bar, and "₹X per day left for N days", plus a Food row with spent / limit and a progress bar. On 1 November, the first time they open the app, the budgets marked to repeat are already in place for November.

**Why this priority**: Budgets turn a spending log into spending control, which is the main reason users keep logging. On its own this story is a complete, useful budget tracker.

**Independent Test**: With fixed transactions in October, set an overall budget and two category budgets. Confirm that spent, remaining, progress, and per-day-left values match the seeded data on a fixed "today", that the empty state appears with no budgets, that "Copy last month's budgets" fills only missing budgets, and that moving the clock into November and starting the app creates the repeating budgets once.

**Acceptance Scenarios** (EXP-08 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] "Per day left" uses remaining days including today.
- [ ] Copy last month does not overwrite budgets already set for this month.

EXP-09 has no acceptance criteria in `docs/spec.md`; its behavior is covered by the derived scenarios below.

**Additional scenarios** (derived from the EXP-08 and EXP-09 Layout, Behavior, and States):

1. **Given** the user opens Budgets (from the EXP-01 overflow menu, at `/expenses/budgets`), **Then** the screen shows, in order: a month selector `< October 2026 >` set to the current month; the overall budget card; the category budgets list; and a "Categories without budget" section listing each non-hidden expense category that has no budget for that month, each with a "Set budget" button.
2. **Given** an overall budget for the month, **Then** the overall card shows the limit, spent (all expense transactions in that month, any category), remaining (limit − spent, shown as a negative "over budget" amount when spent exceeds the limit), a progress bar, and "₹X per day left for N days", where N is the number of days from today to the last day of the month, both included, and ₹X is remaining ÷ N rounded down to whole paise.
3. **Given** category budgets, **Then** each row shows the category icon and name, spent / limit, and a progress bar with threshold styling: under 80%, 80–100%, and over 100%, each with a text or icon label as well as color.
4. **Given** a tap on a budget row, on the overall card, or on "Set budget", **Then** EXP-09 opens as a bottom sheet with: Category (or "Overall"), amount, and a "Repeat every month" toggle. When editing an existing budget, the category is fixed and a Delete button is shown.
5. **Given** EXP-09, **When** the user saves an amount greater than 0 and at most ₹99,99,99,999, **Then** the budget is saved for the month shown in the month selector and the screen updates immediately. An empty or zero amount is rejected with an inline error.
6. **Given** a category (or Overall) that already has a budget for that month, **Then** it cannot be chosen again in a new budget; the user edits the existing one instead (one budget per category per month, and one overall budget per month).
7. **Given** a budget is deleted from EXP-09, **Then** the sheet closes, the budget disappears, and an Undo snackbar is shown for 5 seconds; Undo restores it with its limit and repeat setting.
8. **Given** the overflow menu action "Copy last month's budgets", **Then** every budget from the previous month whose category (or Overall) has no budget in the selected month is copied with the same limit and repeat setting, and a snackbar states how many budgets were copied (or that there was nothing to copy).
9. **Given** budgets with "Repeat every month" on in the most recent earlier month that has budgets, **When** the app is opened for the first time in a new month, **Then** each of those budgets is created for the new month with the same limit and repeat setting, unless that category (or Overall) already has a budget in the new month. This happens once; opening the app again in the same month creates nothing more.
10. **Given** no budgets for the selected month, **Then** the screen shows an explanation of what budgets do and a "Set monthly budget" button that opens EXP-09 with "Overall" selected.
11. **Given** the month selector is moved to a past or future month, **Then** the screen shows that month's budgets and spending. For a past month, the per-day-left line is replaced by the final result (under or over budget by ₹X); for a future month, N counts all days of that month.
12. **Given** the Budgets screen, **Then** no ad of any kind is shown; the native ad slot after the category list is left out until the ads feature.

---

### User Story 2 - Get warned before going over budget (EXP-02 budget alerts) (Priority: P1)

A user has a ₹6,000 Food budget for October and has spent ₹4,700. They log a ₹200 lunch. When they tap Save, a local notification says Food has reached 80% of its budget. Later they log more food and cross ₹6,000; a second notification says the budget is used up. Logging more food that month sends no further Food alerts. Tapping a notification opens Budgets.

**Why this priority**: Alerts are what make budgets work without the user checking the screen. They depend on User Story 1's budgets and on the existing EXP-02 save.

**Independent Test**: With a fake notification sender and fixed budgets, save expenses that cross 80% and then 100% of a category budget and of the overall budget. Confirm exactly one notification per threshold per budget per month, none when the Budget alerts setting or notifications are off, none for an expense dated in a past month, and that the sent markers survive an app restart.

**Acceptance Scenarios** (EXP-02 budget alert criterion, copied verbatim from `docs/spec.md`):

- [ ] Budget alert fires once at 80% and once at 100% per category per month.

**Additional scenarios** (derived from EXP-02 Behavior, the §4 budgets table, and the §12 Budget alerts channel):

1. **Given** a saved expense (new or edited) dated in the current month, which has a budget for its category, **When** that category's spending in that month reaches at least 80% of the limit for the first time, **Then** one "Budget alerts" notification is sent naming the category and the percentage used, and the budget records that its 80% alert was sent.
2. **Given** the same budget, **When** spending reaches at least 100% for the first time, **Then** one notification is sent saying the budget is used up (or exceeded), and the budget records that its 100% alert was sent. If a single save crosses both thresholds at once, only the 100% notification is sent and both are marked as sent.
3. **Given** an overall budget for the month, **Then** the same rules apply to total expense spending in that month, with a notification naming the overall budget.
4. **Given** an alert has already been sent for a threshold, **When** spending drops below it (a delete or an edit) and rises above it again in the same month, **Then** no second notification is sent for that threshold.
5. **Given** the Budget alerts setting is off, or the app's notification master switch is off, or the operating system's notification permission is denied, **Then** no budget notification is shown and the save still succeeds normally.
6. **Given** a budget alert notification, **When** the user taps it, **Then** the app opens Budgets (EXP-08) for that month. If app lock is on, the app opens the unlock screen instead; opening EXP-08 after unlock is deferred to T3.1 (real SYS-03).
7. **Given** an income or transfer is saved, **Then** no budget check runs and no budget notification is sent.
8. **Given** the notification check fails for any reason, **Then** the saved transaction is unaffected and the user sees the usual "Saved · Undo" snackbar.

---

### User Story 3 - Automate repeating transactions (EXP-02 Repeat, EXP-10) (Priority: P2)

A user pays ₹15,000 rent on the 5th of every month. When logging it in EXP-02 they turn on Repeat, choose Monthly, and save. From then on, a rent expense appears automatically on the 5th of each month, marked with a small repeat icon in the Expenses list, even if the app was not opened that day. In Recurring transactions they see the rule with "Every month on 5th" and the next date, and they can pause, resume, edit, or delete it.

**Why this priority**: Recurring entries save effort for fixed costs and income, and make budgets accurate without manual logging. It is valuable but not required for budgets or reports to work.

**Independent Test**: With a controllable clock, create daily, weekly, monthly (including on the 31st), and yearly rules, advance the clock by various amounts (including 3 months with no app open), run the generator from app open and from the daily background job, and confirm the exact set and dates of generated entries, no duplicates, each linked to its rule, and the advanced next run date.

**Acceptance Scenarios** (EXP-10 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] A monthly rule on the 31st runs on the last day of shorter months.
- [ ] If the app was not opened for 3 months, all missed entries are created once, with correct dates, and no duplicates.

**Additional scenarios** (derived from EXP-02 item 9, EXP-10 Layout and Behavior, EXP-01, EXP-03, and the §4 recurring_rules table):

1. **Given** EXP-02 for a new entry, or for editing an entry that was not created from a rule, **Then** a Repeat toggle is shown, off by default. **When** it is turned on, **Then** the user chooses Daily, Weekly, Monthly, or Yearly (Monthly preselected) and an optional end date, and the form shows the resulting schedule in words ("Every month on 5th").
2. **Given** the user saves with Repeat on, **Then** the transaction is saved as the first occurrence and linked to a new active rule that copies its type, amount, account(s), category, payment mode, and note, and whose next run date is the next occurrence after the saved entry's date and time. Undo on the "Saved · Undo" snackbar removes both the entry and the new rule.
3. **Given** the end date is before the entry's date, **Then** saving is blocked with an inline error under the Repeat section.
4. **Given** active rules whose next run date is in the past or now, **When** the app is opened or the daily background job runs, **Then** one transaction is created for every occurrence from the next run date up to now, each dated at its own occurrence, linked to its rule, and the rule's next run date moves to the first occurrence after now. Occurrences after the end date are never created, and a rule whose end date has passed is no longer due.
5. **Given** the app open check and the daily background job (or two app opens) run at the same time or one after another, **Then** each occurrence is created exactly once.
6. **Given** a monthly rule anchored on the 29th, 30th, or 31st, **Then** in shorter months it runs on the last day of the month, and it returns to its anchor day in months that have it. A yearly rule on 29 February runs on 28 February in non-leap years.
7. **Given** EXP-01 lists a transaction created from a rule, **Then** its row shows a small repeat icon with a screen-reader label. **Given** EXP-03 for such a transaction, **Then** it shows a "Created from recurring rule" link that opens the rule for editing.
8. **Given** the user opens Recurring transactions (from the EXP-01 overflow menu, at `/expenses/recurring`), **Then** active rules are listed with the category icon, the note (or the category name when there is no note), the signed amount, the frequency text ("Every day", "Every week on Monday", "Every month on 5th", "Every year on 5 Oct"), and the next date. Paused rules are listed in a separate "Paused" section.
9. **Given** a swipe on a rule (or its long-press menu), **Then** the user can Pause or Resume it, or Delete it. Delete is soft and offers a 5-second Undo; already generated transactions are kept and keep their link.
10. **Given** a paused rule is resumed, **Then** occurrences that fell during the pause are not created; the next run date moves to the first occurrence after now.
11. **Given** a tap on a rule, **Then** EXP-02 opens in rule-edit mode, prefilled from the rule, with the Repeat section shown. Saving changes the rule for future occurrences only; transactions already generated are not changed. Saving with Repeat turned off ends the rule: it is soft-deleted, its generated transactions are kept with their link, and a 5-second Undo restores it.
12. **Given** no rules, **Then** EXP-10 shows an explanation and an "Add recurring transaction" button that opens EXP-02 with Repeat on.
13. **Given** a transaction that was created from a rule (or is a rule's first occurrence) is edited in EXP-02, **Then** the Repeat toggle is not shown, and the edit affects only that one transaction.
14. **Given** the user edits a hand-entered transaction and turns Repeat on, **When** they save, **Then** that entry becomes the first occurrence of a new active rule built from its saved values, every due occurrence after its date up to now is generated immediately, and Undo removes the rule and those generated entries and restores the entry's previous values.

---

### User Story 4 - Understand spending with free reports (EXP-11 Overview and Categories) (Priority: P2)

At the end of the month the user opens Reports. The Overview tab shows income against expense for October, net savings, savings rate, average daily spend, and the top 3 categories. The Categories tab shows a donut chart of expenses by category; tapping the Food slice highlights it and lists the Food transactions below. They switch to September with the period selector and see the same views for last month, at no cost.

**Why this priority**: Reports give the insight that makes logging feel worthwhile. The free tabs work for every user and are the base for the advanced tabs.

**Independent Test**: With fixed transactions across several months, categories, accounts, and payment modes, open Reports for the current and previous month and confirm every figure and chart total equals the EXP-01 summary strip for the same period, and that the slice selection lists exactly that category's transactions.

**Acceptance Scenarios** (EXP-11 acceptance criteria, copied verbatim from `docs/spec.md`; the first one is partly deferred, see the note):

- [ ] Locked tabs show a blurred preview and a "Watch an ad to unlock for 24 hours" button.
- [ ] Chart totals match the EXP-01 summary strip for the same period.

> **Scope note on the first criterion**: as requested, rewarded ads and the "Watch an ad" action are
> out of scope until feature 008. In this feature, locked content shows the blurred preview with the
> lock badge and only a disabled "Get Pro" button. The "Watch an ad to unlock for 24 hours" part of
> the criterion is tested and marked done in feature 008. The blurred-preview part is tested here.

**Additional scenarios** (derived from the EXP-11 Layout and Free vs unlocked rules):

1. **Given** the user opens Reports (from the EXP-01 overflow menu, at `/expenses/reports`), **Then** the screen shows a period selector (Month by default, set to the current month; Week, Year, and Custom range also offered) and the tabs Overview · Categories · Trends · Accounts.
2. **Given** the Overview tab, **Then** it shows: an income vs expense bar for the period; net savings (income − expense); savings rate (net ÷ income, as a whole-number percentage, or "—" when income is 0); average daily spend (expense ÷ number of days in the period, counting only days up to today for the current period); and the top 3 expense categories with their amounts and share of expense.
3. **Given** the Categories tab, **Then** it shows a donut chart of expense by category, with a legend that lists each category name, amount, and percentage, so the data is readable without color. When there are more than 8 categories, those under 2% of expense are merged into one "Other" slice; its legend row lists the merged categories, and tapping "Other" lists the transactions of all merged categories. **When** the user taps a slice or a legend row, **Then** it is highlighted and that category's transactions in the period are listed below, newest first; tapping one opens EXP-03.
4. **Given** a period with no transactions, **Then** each tab shows an empty state ("No transactions in October") with an "Add expense" button, not an empty chart.
5. **Given** the Reports screen, **Then** pull to refresh recomputes the figures, and charts also update when transactions change.
6. **Given** charts and figures, **Then** transfers are always excluded, and all amounts use the user's currency formatting with signs and tabular figures.
7. **Given** the Reports screen, **Then** no "Export this report" action and no ad of any kind is shown; the banner slot stays empty and takes no space.

---

### User Story 5 - Advanced reports behind a feature gate (EXP-11 Trends, Accounts, Year, Custom; FeatureGate) (Priority: P3)

A user taps the Trends tab. Without the advanced reports unlock, they see a blurred preview of the chart with a lock badge and a disabled "Get Pro" button, and a short line explaining that advanced reports are part of Pro. A developer testing the dev build turns on "Unlock all features" in More, and the Trends tab shows a line chart of daily spending for October with September as a dashed comparison line; the Accounts tab shows spending by account and by payment mode; and Year and Custom range periods become available.

**Why this priority**: The advanced tabs add depth for engaged users and set up the monetization of later features, but the free reports already deliver the core value.

**Independent Test**: With a fake feature gate (locked, unlocked, and expired unlock), confirm which tabs and periods are locked, that the overlay shows only a disabled "Get Pro" button, that unlocking shows the real charts with totals matching EXP-01, that an expired unlock stays expired even after the device clock is set back, and that the dev-only switch exists in the dev flavor and never in prod.

**Acceptance Scenarios**: covered by the EXP-11 criteria in User Story 4 (blurred preview of locked tabs; chart totals match EXP-01).

**Additional scenarios** (derived from EXP-11 and the §4 unlocks table):

1. **Given** the advanced reports feature is locked, **Then** the Trends and Accounts tabs show their content blurred under the shared locked-feature overlay with the lock badge and a single, disabled "Get Pro" button (no "Watch an ad" button), plus a one-line explanation that this is an advanced report.
2. **Given** the advanced reports feature is locked, **Then** Year and Custom range in the period selector show a lock icon, and so do Month periods older than the previous month and future months. Selecting a locked period shows its content blurred under the same overlay, on every tab. Week periods that overlap the current or previous month are free on Overview and Categories; weeks that lie entirely before the previous month or entirely after the current month are locked.
3. **Given** the advanced reports feature is unlocked, **Then** the Trends tab shows a line chart of spending per day for Week, Month, and Custom periods and per month for Year, with the previous period of the same length as a dashed comparison line, and a legend that names both lines.
4. **Given** the advanced reports feature is unlocked, **Then** the Accounts tab shows a bar chart of expense by account and a bar chart of expense by payment mode for the period, each bar labeled with its amount.
5. **Given** an unlock with an expiry time, **Then** the feature is unlocked only until that time. If the device clock is moved backwards, an expired unlock stays expired (the latest time ever seen is used when it is later than the current time).
6. **Given** a permanent unlock (no expiry), **Then** the feature stays unlocked across restarts.
7. **Given** the dev flavor, **Then** the More tab shows a "Unlock all features (debug)" switch. When it is on, every gated feature reports as unlocked; when it is off, the real unlock records decide. **Given** the prod flavor, **Then** the switch does not exist and the setting has no effect even if present in stored data.
8. **Given** the unlock status changes while Reports is open, **Then** the overlay appears or disappears without leaving the screen.

---

### Edge Cases

- **Month boundaries and time zones**: A transaction at 23:59 local time on 31 October counts toward October's budgets and reports. Months, days, and the "first app open of a new month" are determined in the device's current local time zone.
- **Budget for a hidden or deleted category**: A budget whose category is later hidden or deleted still shows in EXP-08 for months where it exists, labeled with the category name and a "hidden" marker; it is not copied or rolled over into new months.
- **Over 100%**: Progress bars cap visually at full width and show "over budget" text with the over amount; the percentage text shows the real value (for example 135%).
- **Zero or negative remaining days in the past**: Per-day-left never divides by zero; past months show the final under/over result instead.
- **Spending exactly at a threshold**: Exactly 80% (or 100%) of the limit counts as reached.
- **Editing a budget limit after alerts** (confirmed in Clarifications): Saving a new limit clears each alert marker whose threshold is no longer reached under the new limit, so that threshold can alert once more when crossed again. Markers whose threshold is still reached stay set, so lowering a limit never repeats an alert already sent; a threshold newly reached because of a lower limit alerts on the next save of an expense in that budget.
- **Backdated expense** (confirmed in Clarifications): An expense saved for a past month updates that month's spent and progress in EXP-08 but sends no notification and records no alert marker. An expense dated in a future month also sends no notification until that month is current.
- **Rollover after several skipped months**: If the app is not opened for two or more months, rollover creates budgets for the current month only, copied from the most recent earlier month that has budgets.
- **Rollover and Copy together**: Neither ever overwrites a budget that already exists for the target month.
- **Generator with many missed occurrences**: A daily rule not run for a year creates 365 entries in one batch without blocking the UI, all or nothing, and without duplicates if interrupted and restarted.
- **Rule referencing an archived account or hidden category**: Generation still creates the entry with that account and category, as EXP-02 would show them for history; EXP-10 marks the rule with a warning line so the user can update it.
- **Rule deleted while entries exist**: Generated entries keep their rule link; EXP-03's "Created from recurring rule" link then says the rule was deleted instead of opening it.
- **Recurring transfer**: Repeat works for transfers; generated transfers use the same From and To accounts and show the repeat icon.
- **Device clock changes**: If the clock moves backwards, no occurrence is generated twice. If it jumps forward, all occurrences up to the new now are created.
- **Background job not allowed**: If the operating system delays or blocks the daily background job, the app-open check still creates all due entries.
- **Notification permission revoked later**: Budget alerts silently stop; the alert markers are still recorded so turning permission back on does not cause a burst of old alerts.
- **Reports with only income or only transfers**: Overview shows 0 expense, no top categories, and the donut shows its empty state.
- **Large data**: With 10,000 transactions, budgets, alert checks, and every report tab stay responsive (SC-004).
- **Load failure**: Each new screen shows its error state with "Try again". A failed budget or rule save keeps the sheet or form open with the user's input and shows an error.

## Requirements *(mandatory)*

### Functional Requirements

**Data and storage**

- **FR-001**: System MUST store budgets with: optional category (none = overall), month (`yyyy-MM`), limit in minor units, repeat-every-month flag, and the moments the 80% and 100% alerts were sent (each optional). Each category (or Overall) MUST have at most one non-deleted budget per month.
- **FR-002**: System MUST store recurring rules with: template type, amount in minor units, account, destination account (transfers), category, payment mode, note, frequency (daily, weekly, monthly, yearly), interval (every N periods), the anchor occurrence, next run moment, optional end moment, and an active flag.
- **FR-003**: System MUST store unlocks with: feature key (exportCsv, exportPdf, premiumTheme_{name}, advancedReports, adFreeDay, streakFreeze), optional expiry moment (none = permanent), and source (rewardedAd, purchase).
- **FR-004**: Budgets and recurring rules MUST be removed by soft delete. The transaction's recurring-rule reference added by feature 002 MUST now point to a recurring rule.
- **FR-005**: System MUST upgrade an existing schema-version-2 database (and every earlier version) to the new schema without losing or changing any existing record, covered by automated migration tests.
- **FR-006**: Money in budgets, rules, alerts, and reports MUST be held and computed as whole minor units at every step.

**EXP-08 Budgets and EXP-09 Set budget (T1.5)**

- **FR-007**: EXP-08 MUST open at `/expenses/budgets` from the EXP-01 overflow menu and show the month selector, overall budget card, category budgets list, and "Categories without budget" section described in User Story 1.
- **FR-008**: "Spent" for a budget MUST be the sum of non-deleted expense transactions in that local calendar month, for that category (or all categories for Overall), excluding income and transfers.
- **FR-009**: "Per day left" MUST equal remaining ÷ N rounded down to whole paise, where N counts the days from today to the last day of the month, both included, and MUST be shown only for the current month (all days of the month for future months; replaced by the final result for past months). When remaining is 0 or negative, it MUST say no budget is left instead of a per-day amount.
- **FR-010**: Progress MUST use the shared progress component with the threshold styles under 80%, 80–100%, and over 100%, each paired with text or an icon.
- **FR-011**: EXP-09 MUST be a bottom sheet with Category (or Overall), amount (via the shared custom keypad, greater than 0 and at most ₹99,99,99,999), "Repeat every month" toggle, a "Set budget" button, and a Delete button when editing. Deleting MUST offer a 5-second Undo.
- **FR-012**: "Copy last month's budgets" MUST copy each previous-month budget whose category (or Overall) has no budget in the selected month, and MUST NOT change any existing budget.
- **FR-013**: On the first app open in a new local month, the system MUST create the current month's budgets from every repeating budget of the most recent earlier month that has budgets, skipping categories (and Overall) that already have one, and MUST do this at most once per month.
- **FR-014**: EXP-08 MUST show an empty state with an explanation and a "Set monthly budget" button when the selected month has no budgets.

**Budget alerts (T1.5)**

- **FR-015**: After every successful save in EXP-02 (new or edited) of an expense dated in the current local month, the system MUST check that expense's category budget and the overall budget for the current month. Expenses dated in any other month MUST NOT trigger a budget notification.
- **FR-016**: For each checked budget, when spent reaches at least 80% of the limit and the 80% alert was not yet sent, the system MUST send one notification on the "Budget alerts" channel and record that it was sent; the same MUST apply at 100%. A save that crosses both thresholds MUST send only the 100% notification and record both.
- **FR-017**: Each threshold MUST alert at most once per budget per month, including across app restarts and after spending drops and rises again, except that saving a new limit MUST clear each marker whose threshold is no longer reached under the new limit (markers still reached stay set).
- **FR-018**: No budget notification MUST be shown when the Budget alerts setting (default on) is off, when the notification master setting is off, or when the operating system permission is denied. The alert check MUST never block, delay, or fail the save.
- **FR-019**: Tapping a budget notification MUST open EXP-08 for that budget's month when app lock is off. When app lock is on, it MUST open the unlock screen and MUST NOT bypass it; forwarding to EXP-08 after unlock is deferred to T3.1.
- **FR-020**: Budget notifications MUST NOT include any data beyond the category name and percentage, and MUST be created only on the device.

**Recurring rules and EXP-10 (T1.6)**

- **FR-021**: EXP-02 MUST show a Repeat toggle (off by default) for new entries, when editing a transaction that is not linked to a rule, and in rule-edit mode, with Daily, Weekly, Monthly (default), and Yearly choices, an optional end date, and the schedule in words. It MUST be hidden when editing a transaction that is linked to a rule.
- **FR-022**: Saving a new entry, or an edited entry not linked to a rule, with Repeat on MUST save the entry as the first occurrence linked to a new active rule (interval 1) whose next run is the occurrence after the entry's moment, and MUST then run the generator for that rule so occurrences already due are created at once. Undo MUST remove the rule and any entries generated by it, and remove a new entry or restore an edited entry's previous values.
- **FR-023**: The generator MUST, for every active, non-deleted rule with a next run moment at or before now, create one transaction per due occurrence up to now (and not after the end moment), each dated at its occurrence and linked to the rule, then set the next run moment to the first occurrence after now. Each rule's generation and advance MUST happen together, so an interrupted run never creates duplicates or skips occurrences.
- **FR-024**: Monthly rules MUST run on the anchor day, or on the last day of the month when the month is shorter; yearly rules on 29 February MUST run on 28 February in non-leap years. Weekly rules MUST keep the anchor weekday, and all rules MUST keep the anchor local time of day.
- **FR-025**: The generator MUST run on every app open (without delaying the first screen) and from a daily background job that works when the app is closed, and concurrent or repeated runs MUST NOT create duplicates.
- **FR-026**: EXP-10 MUST open at `/expenses/recurring` from the EXP-01 overflow menu and list active and paused rules as described in User Story 3, with Pause/Resume and Delete as swipe actions and in a long-press menu, an empty state, and tap-to-edit opening EXP-02 in rule-edit mode.
- **FR-027**: Editing a rule MUST affect only future occurrences. Saving a rule in rule-edit mode with Repeat turned off MUST soft-delete the rule, keep its generated transactions, and offer a 5-second Undo. Resuming a paused rule MUST NOT create occurrences missed during the pause. Deleting a rule MUST keep its generated transactions.
- **FR-028**: EXP-01 rows for generated transactions MUST show a small repeat icon with a screen-reader label. EXP-03 MUST show a "Created from recurring rule" link for them that opens the rule in EXP-02 rule-edit mode, or states that the rule was deleted.
- **FR-029**: Budget checks (FR-015 to FR-018) MUST also run for expenses created by the generator, under the same current-month-only rule.

**EXP-11 Reports (T1.7)**

- **FR-030**: EXP-11 MUST open at `/expenses/reports` from the EXP-01 overflow menu, with a period selector (Month default; Week, Year, Custom range) and the tabs Overview, Categories, Trends, and Accounts, with charts drawn by the charting library named in the request.
- **FR-031**: Overview MUST show the income vs expense bar, net savings, savings rate, average daily spend, and top 3 expense categories, as defined in User Story 4.
- **FR-032**: Categories MUST show a donut chart of expense by category with a text legend, and tapping a slice or legend row MUST highlight it and list that category's transactions for the period.
- **FR-033**: Trends MUST show a line chart of spending per day (per month for Year) with the previous period of the same length as a dashed comparison line.
- **FR-034**: Accounts MUST show bar charts of expense by account and by payment mode.
- **FR-035**: Every total shown in Reports MUST equal the EXP-01 summary strip for the same period (transfers excluded), with 0 paise difference.
- **FR-036**: EXP-11 MUST support pull to refresh and update when transactions change.

**Feature gating**

- **FR-037**: A core `FeatureGate` service MUST answer, for any feature key, whether it is currently unlocked, and MUST notify listeners when that changes. Features in other modules MUST use it through a core interface only.
- **FR-038**: A feature MUST count as unlocked when a non-deleted unlock for its key is permanent or expires after the effective now, where the effective now is the later of the current time and the latest time the app has ever seen.
- **FR-039**: Overview and Categories MUST always be free for the current month, the previous month, and any week that overlaps either of them. Trends, Accounts, Year, Custom range, Month periods older than the previous month, future Month periods, weeks entirely before the previous month, and weeks entirely after the current month MUST require the `advancedReports` unlock.
- **FR-040**: When locked, gated content MUST be shown blurred under the shared locked-feature overlay with the lock badge, a short explanation, and only a disabled "Get Pro" button. The "Watch an ad" action MUST NOT be shown in this feature.
- **FR-041**: In the dev flavor only, the More tab (SET-01) MUST show an "Unlock all features (debug)" switch that makes every feature report as unlocked. The prod flavor MUST NOT include the switch or honor its stored value.

**Module integration**

- **FR-042**: `ExpenseModule` MUST own the routes for EXP-08, EXP-10, and EXP-11 under `/expenses`. EXP-09 opens as a bottom sheet without a route. The EXP-01 overflow menu MUST now show Categories, Accounts, Budgets, Recurring, and Reports.
- **FR-043**: `ExpenseModule`'s disable hook MUST cancel pending budget notifications and stop the recurring background job; enabling the module MUST restart the job. Expense data MUST be kept.

**UI/UX, localization, accessibility (spec §12, §15)**

- **FR-044**: Every new screen and sheet MUST implement loading (skeletons only after 300 ms), empty, error (plain language with "Try again"), and content states.
- **FR-045**: Screens MUST use only theme tokens and shared components; amounts MUST always use the shared amount component with currency, Indian grouping for INR, a sign, and tabular figures. Chart colors MUST come from the theme and category colors.
- **FR-046**: All user-facing text, including notification text and frequency descriptions, MUST be available in English, Hindi, and Gujarati using placeholders and plurals (for example ordinal days and "N days"), in sentence case, with buttons that start with a verb.
- **FR-047**: All new screens MUST work at 200% font scale and on 360 dp-wide screens without clipping, have touch targets of at least 48 × 48 dp, label every icon button for screen readers, read amounts as currency, and never convey budget status or chart meaning by color alone (each chart has a text legend or labels).
- **FR-048**: Reversible actions (delete budget, delete rule, pause rule) MUST use an Undo snackbar or be directly reversible without a dialog.
- **FR-049**: No ad of any kind MUST be requested or shown by this feature, and the "Export this report" action and the daily summary notification MUST NOT be added.
- **FR-050**: Each new screen MUST pass the spec §15.10 design review checklist (golden tests are required by the constitution only for DSH-01, EXP-01, EXP-02, HAB-01; the EXP-01 and EXP-02 goldens MUST be updated for the repeat icon and Repeat toggle).
- **FR-051**: Every acceptance criterion copied above MUST have at least one automated test (the "Watch an ad" part as noted in User Story 4 excepted), and widget tests MUST use fake repositories, a fake feature gate, and a fake notification sender. Unit tests MUST cover budget thresholds, per-day-left, rollover, copy, and recurring rule generation.

### Key Entities

- **Budget**: A monthly spending limit. Optional category (none = overall); month (`yyyy-MM`); limit in paise; repeat-every-month flag; 80% and 100% alert-sent moments; created, updated, and deleted timestamps. At most one per category (or Overall) per month. "Spent", "remaining", "progress", and "per day left" are derived, never stored.
- **Recurring rule**: A template that creates transactions on a schedule. Template type, amount, account(s), category, payment mode, note; frequency (daily, weekly, monthly, yearly); interval; anchor occurrence; next run moment; optional end moment; active flag; created, updated, and deleted timestamps. One rule has many generated transactions.
- **Transaction** (from feature 002): gains a meaningful recurring-rule reference, set only on entries created from or as the first occurrence of a rule.
- **Unlock**: A record that a gated feature is available. Feature key; optional expiry (none = permanent); source (rewarded ad or purchase). Read through the feature gate.
- **Feature gate**: The core service that decides whether a feature key is unlocked, using unlock records, the latest-seen time, and (dev flavor only) the debug unlock-all setting. Not stored itself.
- **Report period**: A week, month, year, or custom date range in local time, plus its previous period of the same length for comparison. Not stored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can set an overall monthly budget from an empty Budgets screen in 3 taps after typing the amount.
- **SC-002**: In every tested month, budget spent, remaining, progress, and per-day-left values equal the values computed by hand from the seeded transactions, with 0 paise difference.
- **SC-003**: Across a test set of at least 50 save sequences, each budget threshold produces exactly one notification per budget per month (0 duplicates, 0 missed), and 0 notifications when alerts are turned off.
- **SC-004**: With 10,000 transactions stored, saving an expense including the budget check completes in under 100 ms, and opening Budgets or any Reports tab shows content in under 500 ms on a mid-range device.
- **SC-005**: For rules of every frequency, after any simulated gap of up to 1 year without opening the app, 100% of due occurrences exist exactly once with the correct dates, including month-end and leap-year cases.
- **SC-006**: Recurring entries appear without the user opening the app on the due day in at least 95% of days when the operating system allows the daily background job, and in 100% of cases by the next app open.
- **SC-007**: In every tested period, every total shown in Reports equals the EXP-01 summary strip for the same period, with 0 paise difference.
- **SC-008**: Upgrading from the feature 002 build preserves 100% of existing records and settings.
- **SC-009**: All new screens render without clipping or overflow at 200% font scale on a 360 dp-wide screen, in English, Hindi, and Gujarati, in light and dark themes.
- **SC-010**: The dev-only unlock switch is absent from 100% of prod builds, and no ad request is made from any screen in this feature.

## Assumptions

- **Reuse of features 001 and 002**: The transactions, categories, and accounts stores, EXP-01 to EXP-07, the notification permission request, and the shared widgets (including `LockedFeatureOverlay`, `PeriodSelector`, `ProgressBarStatus`, `SummaryCard`, `AppBottomSheet`, `NumericKeypad`) already exist and are reused. `LockedFeatureOverlay` is extended so its "Watch an ad" action can be left out and "Get Pro" can be disabled.
- **Settings without SET-01**: SET-01 is still a placeholder until T3.1. The Budget alerts setting and the notification master setting are stored now with a default of on and are honored by the alert check; their toggles are added to SET-01 in T3.1. The dev-only debug switch is added to the current More placeholder screen.
- **Overall vs category alerts**: Both the overall budget and each category budget alert independently, as the §12 Budget alerts channel says ("Category or overall budget").
- **Alerts only for the current month** (confirmed in Clarifications): Expenses saved in EXP-02 and expenses created by the recurring generator are checked against budgets only when dated in the current month, so backdating or catching up on missed months never sends alerts about past months.
- **Interval**: EXP-02 offers only Daily, Weekly, Monthly, and Yearly, so new rules use an interval of 1. The stored interval supports "every N periods" later without a schema change.
- **First occurrence** (confirmed in Clarifications for edits): The entry saved with Repeat on, whether new or an edited hand-entered entry, is the rule's first occurrence; the generator starts from the next one and backfills any occurrences already due.
- **Rule edits**: Rule-edit mode in EXP-02 changes the template and schedule for future occurrences only; generated entries are independent transactions after creation.
- **Rollover source month**: Rollover uses the most recent earlier month that has budgets, so a skipped month does not stop budgets from repeating.
- **Budget alert channel**: A new "Budget alerts" notification channel is created, on by default, as listed in §12. Rescheduling on reboot and the daily summary channel come with T3.4 and feature 007.
- **Locked overlay content**: "Get Pro" is shown disabled because PRM-01 does not exist yet; it is enabled in the premium feature. The rewarded-ad "Watch an ad" action and the PRM-02 sheet come in feature 008.
- **Free reports period scope** (confirmed in Clarifications): "Current and previous month" is measured from today's local month. A week counts as free when any of its days falls in either month.
- **New dependencies**: The background job library and the charting library named in the request are new dependencies that the plan must justify (Constitution VII). The local notifications library is already present.
- **Out of scope**: Rewarded ads and the "Watch an ad" action (feature 008), the "Export this report" action (feature 007), the daily summary notification (feature 007), all ads including the EXP-08 native ad and EXP-11 banner (the banner slot stays empty), the Home card budget bar and home screen widget (T2.5, T3.4), and backup of budgets, rules, and unlocks (T3.2).
- **Golden baselines**: Golden images are generated on Linux only, as in features 001 and 002.
