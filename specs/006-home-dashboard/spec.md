# Feature Specification: Home Dashboard (DSH-01)

**Feature Branch**: `006-home-dashboard`

**Created**: 2026-10-19

**Status**: Draft

**Input**: User description: "Feature: Home dashboard. Implement task T2.5, screen DSH-01, from docs/spec.md. Scope: DSH-01 Home as tab 1 (greeting, date, streak flame, module summary cards, recent transactions, daily insight card, dismissible Coming soon card); built from the module registry only, cards in SET-06 order; FAB menu from each enabled module's quickAddAction(); local rule-based insights, one per day, rotating daily; upgrade the expense and habit dashboard cards to the full DSH-01 design; empty states and single-module layout; finish SET-06 reordering; pull-to-refresh recomputes insights only. Out of scope: native ad slot (feature 008), home screen widget (feature 007). Copy the DSH-01 acceptance criteria exactly except the native ad criterion. Home must load from local data in under 300 ms. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §7 DSH-01, §3 (TrackerModule), §10 SET-06, §14 T2.5, §15 UI/UX guidelines.

## Clarifications

### Session 2026-10-19

- Q: How should Home pick the one insight shown each day, so it stays the same all day and changes the next day? → A: Store today's pick (local date + insight id) in settings. On a new day, pick the next applicable insight after yesterday's in a fixed rule order, cycling, and never yesterday's when another applies.
- Q: When the user taps the insight card, what should happen? → A: It opens the screen the insight relates to (e.g. a spending tip opens EXP-11 Reports, a streak tip opens HAB-03 for that habit); the starter tip is not tappable.
- Q: Once the user dismisses the "Coming soon" card, can they get it back? → A: Dismissing shows a 5-second undo snackbar; after that it is gone for good (no SET-06 control to restore it).
- Q: Should transfers between accounts appear in Home's recent transactions? → A: Yes, shown as in EXP-01: neutral color, no +/− sign, "From → To" accounts, transfer icon.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See today at a glance (Priority: P1)

A user opens the app and lands on Home (tab 1). At the top they see a greeting that matches the time of day ("Good morning"), today's date, and a streak flame showing their best active habit streak. Below it, one summary card per enabled module appears in the order they chose in SET-06: the expense card shows "Spent today," "This month" spent against the overall budget with a colored progress bar, and a "+ Expense" chip; the habit card shows a progress ring ("3 of 5 done today") and today's scheduled habits as round check buttons. Further down they see their last 5 transactions, one insight for the day, and a "Coming soon" card for Water and Period.

**Why this priority**: Home is the most-opened screen. Without the status overview there is no dashboard; every other story builds on it.

**Independent Test**: Seed transactions, an overall budget, and habits; open the app; confirm that every section shows the right values, in the right order, from local data in under 300 ms.

**Acceptance Scenarios**:

1. **Given** the time is 08:30, **When** the user opens Home, **Then** the app bar shows "Good morning" and today's date in `EEE, d MMM` form.
2. **Given** the user has habits with current streaks of 4 and 12 days, **When** Home loads, **Then** the streak flame shows 12; **When** the user taps it, **Then** HAB-01 opens.
3. **Given** the user spent ₹500 today and ₹6,000 this month against an overall budget of ₹10,000, **When** Home loads, **Then** the expense card shows ₹500 spent today, ₹6,000 of ₹10,000 this month, a green bar, and a text label for the level.
4. **Given** this month's spending reaches 80% of the overall budget, **Then** the bar turns amber; **Given** it goes over 100%, **Then** the bar turns red. Each level also shows a text or icon label, never color alone.
5. **Given** there are 8 transactions, **When** Home loads, **Then** "Recent transactions" lists the newest 5 (any type, transfers included) with category icon, note, account, and amount (signed for expense/income, neutral "From → To" for transfers); **When** the user taps "See all", **Then** EXP-01 opens.
6. **Given** the user tapped the expense card (outside its chip), **Then** EXP-01 opens; **Given** the user taps "+ Expense", **Then** the add-expense form (EXP-02) opens.
7. **Given** the user adds an expense on another screen, **When** they return to Home, **Then** spent today, this month, the bar, and recent transactions already show it without a manual refresh.
8. **Given** the user ordered modules Habit then Expense in SET-06, **When** Home loads, **Then** the habit card appears above the expense card.

---

### User Story 2 - Check in habits from Home (Priority: P1)

From the habit card on Home, the user taps a yes/no habit's check button to mark it done, or taps a count habit's button to pick "+1" or enter a custom value. Long-pressing any check button opens that habit's detail (HAB-03). The ring, the habit list, and the streak flame update at once.

**Why this priority**: One-tap logging is the screen's second purpose (spec §7 Purpose, §15.1 "Speed first").

**Independent Test**: Create a yes/no habit and a count habit; check them in from Home; confirm the ring, HAB-01 list, and streak flame update without reload.

**Acceptance Scenarios**:

1. **Given** a yes/no habit not done today, **When** the user taps its check button, **Then** it shows as done, the ring advances ("1 of 2 done today"), and the streak flame updates if this was the best streak, all without reload. A light haptic plays.
2. **Given** a yes/no habit done today, **When** the user taps it again, **Then** it is unchecked and an undo snackbar appears for 5 seconds; tapping "Undo" restores it.
3. **Given** a count habit with target 20 pages and 12 logged, **When** the user taps its button, **Then** a popup offers "+1" and a custom value; choosing "+1" records 13.
4. **Given** any habit button, **When** the user long-presses it, **Then** HAB-03 for that habit opens.
5. **Given** a check-in reaches a milestone streak (7, 21, 30, 50, 100, 365), **Then** the milestone celebration sheet appears once, as on HAB-01.

---

### User Story 3 - Quick add from the + button (Priority: P1)

The user taps the single + button on Home. A small menu opens with one entry per quick action offered by the enabled modules, in module order: "Add expense," "Add income," and "Check in habit." Picking an entry opens the matching screen.

**Why this priority**: The global + is the fastest way to log anything and must work in 2 taps.

**Independent Test**: With both modules enabled, tap + and confirm three entries in SET-06 order; disable Habit and confirm only the expense entries remain.

**Acceptance Scenarios**:

1. **Given** both modules are enabled in order Expense, Habit, **When** the user taps +, **Then** the menu shows "Add expense," "Add income," "Check in habit," in that order.
2. **Given** the menu is open, **When** the user picks "Add income," **Then** EXP-02 opens with type set to income; "Add expense" opens it with type expense; "Check in habit" opens HAB-01 for today.
3. **Given** the Habit module is disabled, **When** the user taps +, **Then** "Check in habit" is not listed.
4. **Given** the user scrolls down Home, **Then** the + button hides; scrolling up shows it again.

---

### User Story 4 - A daily insight (Priority: P2)

Home shows one short, rule-based tip each day, such as "Food spending is 20% higher than last month" or "You're 2 days away from a 30-day streak." Each enabled module provides its own candidate insights, computed on the device with no network. The shown insight changes from one day to the next. Pulling down on Home recomputes insights from the latest data.

**Why this priority**: Adds value and engagement but the dashboard works without it.

**Independent Test**: Seed data that triggers several rules; confirm one insight shows, that it stays the same all day, and that a different one shows the next day; pull to refresh after changing data and confirm the insight reflects the new data.

**Acceptance Scenarios**:

1. **Given** at least one rule applies, **When** Home loads, **Then** exactly one insight card is shown.
2. **Given** more than one insight applies on two consecutive days, **When** the day changes, **Then** a different insight is shown than the previous day.
3. **Given** the same day and unchanged data, **When** the user reopens Home, **Then** the same insight is shown.
4. **Given** the user pulls down to refresh, **Then** insights are recomputed and the card updates; module cards and recent transactions are not reloaded by the refresh (they already update live).
5. **Given** the device is offline, **Then** insights still appear; no network request is made.
6. **Given** a module is disabled, **Then** none of its insights are shown.
7. **Given** the insight "You're 2 days away from a 30-day streak" for habit Read, **When** the user taps the card, **Then** HAB-03 for Read opens; **Given** a category spending insight, **When** tapped, **Then** EXP-11 Reports opens.

---

### User Story 5 - First day and single-module users (Priority: P2)

A new user with no data sees a friendly empty state in each card, each with one action ("Add your first expense," "Create your first habit"). A user who enabled only one module sees a Home that only contains what applies to that module, with no gaps or broken sections.

**Why this priority**: Every user starts empty; a broken first impression loses users. Single-module setups are a supported configuration.

**Independent Test**: Fresh install with both modules; then with only Expense; then with only Habit; confirm the layout and actions in each case.

**Acceptance Scenarios**:

1. **Given** no transactions exist, **Then** the expense card shows "Add your first expense," which opens EXP-02, and the recent transactions section is hidden.
2. **Given** no habits exist, **Then** the habit card shows "Create your first habit," which opens HAB-02, and the streak flame shows 0.
3. **Given** only Expense is enabled, **Then** the habit card and the streak flame are hidden, and the rest of the screen lays out without empty gaps.
4. **Given** only Habit is enabled, **Then** the expense card and recent transactions are hidden, and the rest of the screen lays out without empty gaps.
5. **Given** no insight rule applies (for example, on the first day), **Then** the insight card shows a general starter tip instead of being empty.

---

### User Story 6 - Arrange modules in SET-06 (Priority: P2)

In SET-06 the user drags modules into a new order and toggles them on or off. Home cards, quick-add menu entries, and the bottom navigation tabs follow that order immediately.

**Why this priority**: The spec ties card order to SET-06; the basic SET-06 from feature 001 must fully drive Home.

**Independent Test**: Reorder modules in SET-06, go back to Home, and confirm the card order, FAB menu order, and tab order changed; restart the app and confirm the order persisted.

**Acceptance Scenarios**:

1. **Given** the order is Expense, Habit, **When** the user drags Habit above Expense, **Then** Home shows the habit card first, the FAB menu lists "Check in habit" first, and the Habits tab comes before the Expenses tab.
2. **Given** the user reordered modules, **When** the app restarts, **Then** the new order is kept.
3. **Given** only one module is enabled, **When** the user tries to turn it off, **Then** it stays on and a message explains that at least one module must stay enabled.
4. **Given** the user reorders with TalkBack, **Then** move up/down actions are available without dragging.

---

### User Story 7 - Coming soon card (Priority: P3)

Home shows a "Coming soon" card for the Water and Period trackers. The user can dismiss it and it does not return.

**Why this priority**: Informational only.

**Independent Test**: Dismiss the card, restart the app, and confirm it stays hidden.

**Acceptance Scenarios**:

1. **Given** the card has not been dismissed, **Then** it appears at the bottom of Home naming Water and Period.
2. **Given** the user dismisses it, **Then** it disappears without layout jumps under the finger and an undo snackbar shows for 5 seconds; **When** the user taps "Undo", **Then** the card returns in the same place.
3. **Given** the undo time has passed, **Then** the card stays hidden, including after restart, and no setting brings it back.

---

### Edge Cases

- **Day changes while Home is open** (past midnight or app resumed the next day): greeting, date, spent today, today's habits, and the daily insight switch to the new day.
- **Greeting boundaries**: 05:00–11:59 "Good morning," 12:00–16:59 "Good afternoon," 17:00–04:59 "Good evening."
- **No overall budget set**: the expense card shows this month's spending without a progress bar, plus a "Set budget" action that opens the overall budget sheet (EXP-09).
- **Budget exactly 80% or exactly 100%**: 80% is amber; 100% is amber; over 100% is red (matches the shared threshold rule: under 80% green, 80–100% amber, over 100% red).
- **No habits scheduled today but habits exist**: the habit card shows a calm "Nothing scheduled today" line instead of an empty button row, and the ring is hidden or shows no progress.
- **Many habits today**: the check button row scrolls horizontally; it never wraps or clips at 200% font scale.
- **No active streak** (all streaks 0): the flame shows 0.
- **Fewer than 5 transactions**: recent transactions shows only those that exist.
- **Deleted transactions**: soft-deleted rows never appear in recent transactions or totals.
- **A module's data fails to load**: only that card shows its error state with "Try again"; the rest of Home still works.
- **Insight rule fails**: that rule is skipped; it never breaks Home.
- **Module disabled while Home is open**: its card, FAB entries, insights, streak flame (Habit), and recent transactions (Expense) disappear at once.
- **Large text (200%) and 360 dp-wide screens**: no clipping or overflow; text in Hindi and Gujarati up to 30% longer still fits.
- **Back on Home** exits the app (§15.5).

## Requirements *(mandatory)*

### Functional Requirements

**Screen and layout**

- **FR-001**: Home MUST be the first tab and replace the current placeholder Home screen.
- **FR-002**: Home MUST be one scrollable screen in this order: app bar (greeting, date, streak flame), enabled module summary cards in SET-06 order, recent transactions, insight card, Coming soon card. Nothing is added in place of the native ad slot (feature 008).
- **FR-003**: The app bar MUST show a greeting by local time of day (see Edge Cases boundaries) and today's date formatted `EEE, d MMM` in the selected locale.
- **FR-004**: The app bar MUST show a streak flame with the best current streak across active habits; tapping it MUST open HAB-01. It MUST be hidden when the Habit module is disabled.
- **FR-005**: Home MUST build its cards, streak flame, recent transactions, insights, and quick-add menu only from what each enabled module provides through the module registry. Home MUST NOT depend directly on the Expense or Habit features.
- **FR-006**: A disabled module MUST contribute nothing to Home (no card, FAB entry, insight, streak flame, or recent transactions).

**Expense summary card**

- **FR-007**: The expense card MUST show "Spent today" (expenses only), "This month" spent against the overall budget with a progress bar, and a "+ Expense" chip. Tapping the card opens EXP-01; tapping the chip opens EXP-02 for an expense.
- **FR-008**: The budget bar MUST be green under 80%, amber from 80% to 100%, and red over 100%, and MUST also show the level as text or icon (never color alone).
- **FR-009**: With no overall budget, the card MUST show this month's spending without a bar and offer "Set budget."
- **FR-010**: With no transactions at all, the card MUST show the empty state "Add your first expense" with one action that opens EXP-02.

**Habit summary card**

- **FR-011**: The habit card MUST show a progress ring with "X of Y done today" and a horizontal row of round check buttons for habits scheduled today.
- **FR-012**: Tapping a yes/no habit's button MUST toggle today's entry; unchecking MUST offer a 5-second undo snackbar.
- **FR-013**: Tapping a count habit's button MUST open a popup with "+1" and a custom value entry.
- **FR-014**: Long-pressing any habit button MUST open HAB-03 for that habit.
- **FR-015**: Check-ins from Home MUST follow the same streak, milestone, and haptic rules as HAB-01.
- **FR-016**: With no habits, the card MUST show "Create your first habit" with one action that opens HAB-02.

**Recent transactions**

- **FR-017**: Home MUST list the 5 newest non-deleted transactions of every type (expense, income, transfer) with category icon, note, account, and amount, plus a "See all" action that opens EXP-01. Tapping a row opens its detail (EXP-03). Expense and income rows show a signed, colored amount; transfer rows match EXP-01: a transfer icon, "From → To" accounts, and a neutral amount with no +/− sign.
- **FR-018**: The section MUST be hidden when the Expense module is disabled or there are no transactions.

**Quick add**

- **FR-019**: Home MUST show a single + button that opens a menu of quick-add entries from every enabled module, in module order.
- **FR-020**: A module MUST be able to offer more than one quick-add entry (Expense offers "Add expense" and "Add income"; Habit offers "Check in habit").
- **FR-021**: "Add expense" and "Add income" MUST open EXP-02 preset to that type; "Check in habit" MUST open HAB-01 for today.
- **FR-022**: The + button MUST hide on scroll down and return on scroll up.

**Insights**

- **FR-023**: Each module MUST provide its own rule-based insight candidates, computed only from local data, with no network.
- **FR-024**: Home MUST show exactly one insight per day, chosen from the candidates of enabled modules. The day's pick (local date + insight id) MUST be stored in settings. On the first Home load of a new local date, Home MUST pick the next applicable insight after yesterday's in a fixed rule order (cycling back to the start), and MUST NOT pick yesterday's insight when any other applies. During the day the stored pick is kept while it still applies; if it stops applying (after refresh or a data change), the next applicable one in the same order replaces it and becomes the stored pick.
- **FR-025**: When no rule applies, Home MUST show a general starter tip. The starter tip is not tappable.
- **FR-025a**: Each insight MUST name a destination screen provided by its module; tapping the insight card MUST open it (e.g. a category spending tip opens EXP-11 Reports, a budget tip opens EXP-08 Budgets, a streak tip opens HAB-03 for that habit). The card MUST carry a semantic label that says where it leads.
- **FR-026**: Insight text MUST be localized with placeholders and follow the §15.7 tone (encouraging, never guilt).
- **FR-027**: The initial rule set MUST include at least: Expense — category spending this month vs last month (e.g. "Food spending is 20% higher than last month"), month budget on track or near limit; Habit — days left to the next milestone streak (e.g. "You're 2 days away from a 30-day streak"), best completion this week, and a comeback tip for a habit whose streak broke after a best of 7 or more.

**Refresh, live updates, states**

- **FR-028**: Pull-to-refresh MUST recompute insights only.
- **FR-029**: All cards and recent transactions MUST update live when data changes anywhere in the app, without reload.
- **FR-030**: Every card MUST have loading, empty, error, and content states. Loading placeholders appear only if loading takes longer than 300 ms; never a full-screen spinner. A card error shows plain language and "Try again" in that card only.

**Coming soon card**

- **FR-031**: Home MUST show a dismissible "Coming soon" card naming Water and Period. Dismissing MUST show a 5-second undo snackbar; once it expires, the dismissal is permanent and persists across restarts. No control restores the card.

**SET-06 Modules**

- **FR-032**: SET-06 reordering MUST change Home card order, quick-add menu order, and bottom navigation tab order immediately, and the order MUST persist.
- **FR-033**: SET-06 MUST keep at least one module enabled and explain why when the user tries to disable the last one.
- **FR-034**: SET-06 reordering MUST be possible without dragging for assistive technology users (move up / move down).

**UI/UX (§15)**

- **FR-035**: Home MUST use only shared design tokens and shared components; no screen-specific colors, sizes, or text styles.
- **FR-036**: Home MUST pass the §15.10 design review checklist (excluding ad items): 48 dp touch targets, semantic labels on all icons and check buttons, logical TalkBack order, works at 200% font scale and 360 dp width, light and dark themes, English, Hindi, and Gujarati strings from translation files.
- **FR-037**: Habit check-in from Home MUST be reachable without scrolling on a typical phone when the habit card is first or second.

### DSH-01 Acceptance Criteria (from docs/spec.md, native ad criterion excluded)

- [ ] Marking a habit done from Home updates the ring, the habit list, and the streak icon without reload.
- [ ] Budget bar color changes at 80% and 100% thresholds.
- [ ] Screen renders correctly with only one module enabled.

### Key Entities

- **Module contribution**: what an enabled module gives Home — its summary card, zero or more quick-add entries (label, icon, destination), insight candidates, and optional Home extras (Expense: recent transactions; Habit: best active streak).
- **Insight**: a short localized tip with a stable rule identity, the module it came from, the values it displays, and the screen it opens when tapped. Computed on demand; not stored as user data.
- **Daily insight choice**: a single stored setting holding the local date and the id of the insight picked for that date; only the latest pick is kept. Insight ids are stable across releases and unique across modules.
- **Module order and enabled set**: existing settings, edited in SET-06, that drive Home and navigation order.
- **Coming soon dismissed flag**: a setting that remembers the card was dismissed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Home shows all content from local data in under 300 ms after the tab is opened, on a mid-range device with 10,000 transactions and 20 habits.
- **SC-002**: A user can check in a habit from Home in 1 tap (yes/no) or 2 taps (count "+1"), and start logging an expense or income in 2 taps.
- **SC-003**: Changes made on any screen appear on Home within 1 second, with no manual refresh.
- **SC-004**: 100% of the copied DSH-01 acceptance criteria and every acceptance scenario above are covered by automated tests.
- **SC-005**: Home renders without clipping or overflow at 200% font scale on a 360 dp-wide screen, in light and dark themes, in English and Gujarati.
- **SC-006**: Over 7 consecutive days with at least 2 applicable insights each day, no two consecutive days show the same insight.
- **SC-007**: With any single module enabled, Home shows no empty gaps, hidden-but-spaced sections, or entries belonging to the disabled module.
- **SC-008**: Home makes zero network requests.

## Assumptions

- The user's "dashboard cards from features 002 and 004" refers to the expense card (feature 002, `specs/002-expense-core`) and the habit card (feature 005, `specs/005-habit-module`); feature 004 in this repo is the keypad/hide-on-scroll feature.
- The habit card from feature 005 already has the ring and check buttons; this feature aligns it with the full DSH-01 design and Home's contracts rather than rebuilding it. The expense card gains the budget bar now that budgets exist (feature 003).
- Supporting several quick-add entries per module requires extending the module contract from a single quick-add action to a list; Expense then offers both "Add expense" and "Add income."
- Greeting boundaries are 05:00 / 12:00 / 17:00 local time.
- "Check in habit" opens HAB-01 for today (current module behavior).
- The Coming soon card always sits last; its dismissal is a device setting and is included in backups once backup exists (T3.2).
- The native ad slot (feature 008), the home screen widget (feature 007), and the daily summary notification (T3.4) are out of scope; nothing is reserved in the layout for the ad.
- Insights are computed on Home open, on day change, and on pull-to-refresh; they are not pushed as notifications.
