# Feature Specification: Expense Core (Phase 1, T1.1–T1.4)

**Feature Branch**: `002-expense-core`

**Created**: 2026-10-14

**Status**: Draft

**Input**: User description: "Feature: Expense core. Implement tasks T1.1 to T1.4 from docs/spec.md. Scope: data layer for the Expense module (spec §4): accounts, categories, and transactions tables with Drift DAOs, domain entities, repository interfaces and implementations, soft delete, indexes, and a Drift migration from the feature 001 schema. First-run seeding: 12 expense categories, 5 income categories (names as l10n keys), and one "Cash" account, exactly once. Screens: EXP-01 Transactions list, EXP-02 Add/edit transaction, EXP-03 Transaction detail, EXP-04 Categories, EXP-05 Add/edit category sheet, EXP-06 Accounts, EXP-07 Add/edit account sheet. ExpenseModule implementing TrackerModule: routes, a simple dashboardCard (spent today + this month), quickAddAction opening EXP-02, and backupSection stubbed. Shared widgets this feature needs from §15.4 if not already built (AmountText, CategoryAvatar, NumericKeypad, PeriodSelector, ChipSelector, UndoSnackBar). Out of scope (later features): the Repeat toggle in EXP-02 and recurring rules, budgets and budget alerts, reports, all ads (keep the AppScaffold banner slot empty), and the Home dashboard layout. Copy the acceptance criteria for EXP-01 to EXP-07 exactly from the spec, except criteria about budgets, recurring rules, or ads. Follow the UI/UX rules in §15."

**Source of truth**: `docs/spec.md` v1.0, sections 3 (TrackerModule), 4 (accounts, categories, transactions, default seed), 5 (routes for EXP-01 to EXP-07), 8 (EXP-01 to EXP-07), 12 (Localization, Accessibility), 13 (performance targets, testing), 14 (Phase 1: T1.1–T1.4), and 15 (UI/UX guidelines).

> **Note on scope and wording**: The master spec and the project constitution (Principle VII, "Locked
> Stack") already fix the technology. Some requirements below name project building blocks
> (`TrackerModule`, `AppScaffold`, the shared widgets of §15.4, soft delete, schema versions) because
> the master spec mandates them, not as new design decisions. Everything else is described by
> observable behavior.

> **What feature 001 already delivered** (see `specs/001-foundation/summary.md`): the `categories`
> and `accounts` tables (local schema version 1), the exactly-once first-launch seed of 12 expense
> categories, 5 income categories, and one Cash account, and all §15.4 shared widgets, including
> `AmountText`, `CategoryAvatar`, `NumericKeypad`, `PeriodSelector`, `ChipSelector`, and
> `UndoSnackBar`. This feature reuses them. It adds the transactions store, the upgrade from the
> feature 001 schema, the read/write layer for all three record types, the seven Expense screens, and
> the real `ExpenseModule`. It extends a shared widget only where a screen here needs behavior the
> widget lacks.

## Clarifications

### Session 2026-10-14

- Q: Should attaching a receipt photo be built in this feature, or deferred? → A: Option A. Build it now: attach from camera or gallery, compress, store on the device, show the thumbnail and full-screen view, and accept the needed photo-picking dependency, justified in the plan.
- Q: Should the EXP-02 category grid follow usage frequency or the EXP-04 drag order? → A: Option A. EXP-02 orders by how often each category is used, with the EXP-04 drag order as the tiebreak (and as the whole order when there is no history). EXP-04 always shows the drag order.
- Q: Should the app stop the user from archiving or deleting their last active account? → A: Option A. Yes. The last non-archived account cannot be archived or deleted, and the user is told why.
- Q: Which payment mode should EXP-02 pre-select for a Wallet account? → A: Option A. Other.
- Q: Should duplicate category names be checked against default names in the current language only, or in all languages? → A: Option A. In all three languages (en, hi, gu), plus custom names as typed, case-insensitive and trimmed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log a transaction in seconds (EXP-02) (Priority: P1)

A user has just paid for lunch. They tap + on the Expenses tab (or the quick-add action), type the amount on the custom keypad, tap the Food category, and tap Save. The screen closes, a "Saved · Undo" snackbar appears, and the entry is stored. The same screen records income (Expense · Income · Transfer segmented control) and transfers between two of the user's accounts, and it edits an existing entry.

**Why this priority**: Logging is the core of the Expense module. Every other screen in this feature reads what this screen writes. On its own it already gives a user a working spending log.

**Independent Test**: On a freshly seeded install, open EXP-02, type 10.10, pick a category, and save. Confirm that exactly one transaction exists with an amount of 1010 paise, the default account, the current date and time, and the chosen category.

**Acceptance Scenarios** (EXP-02 acceptance criteria, copied verbatim from `docs/spec.md`; the budget-alert and interstitial criteria are excluded as out of scope):

- [ ] A new expense can be saved with amount + category only in 3 taps after typing the amount.
- [ ] Amount is stored in paise without rounding errors (e.g. 10.10 → 1010).

**Additional scenarios** (derived from the EXP-02 Layout, Validation, and Behavior):

1. **Given** EXP-02 opens for a new entry, **Then** the amount field is focused with the custom keypad (digits, decimal, backspace, + − × ÷) showing, the system keyboard is not shown, and the amount is displayed with the currency symbol and Indian grouping (₹1,25,000).
2. **Given** the user types `120+35.50`, **When** they finish the calculation, **Then** the amount shows ₹155.50 and is saved as 15550 paise.
3. **Given** the Expense or Income type, **Then** a 4-column category grid for that type shows the user's non-hidden categories ordered by how often the user has picked each one, with the EXP-04 drag order as the tiebreak and as the whole order when there is no history, ending with "+ New", which opens EXP-05. A category created there is selected when the sheet closes.
4. **Given** the Transfer type, **Then** the category grid is hidden and "From" and "To" account chips are shown. **When** From and To are the same account, **Then** saving is blocked with an inline error under the account chips.
5. **Given** the amount is 0, empty, or above ₹99,99,99,999, **When** the user taps Save, **Then** the entry is not saved and an inline error appears under the amount.
6. **Given** the Expense or Income type with no category selected, **When** the user taps Save, **Then** the entry is not saved and an inline error appears under the category grid.
7. **Given** a new entry, **Then** the account chip defaults to the last-used non-archived account (the seeded Cash account on first use), and the payment mode defaults from that account's type. Changing the account updates the payment mode default.
8. **Given** the date and time chip, **Then** it defaults to now and offers "Today" and "Yesterday" shortcuts before the full date and time pickers.
9. **Given** the note field, **Then** it accepts up to 200 characters, shows the limit before it is reached, and offers suggestions from the user's recent notes.
10. **Given** the user attaches a receipt from the camera or gallery, **Then** the image is reduced to at most 1280 px on its longest side, re-encoded as JPEG at 80% quality, and stored in the app's private storage, and the transaction keeps a reference to it.
11. **Given** a successful save, **Then** the screen closes and a "Saved · Undo" snackbar shows for 5 seconds. Undo removes a new entry, or restores an edited entry to its previous values.
12. **Given** a long-press on Save, **Then** the user can choose "Save and add another", which saves and resets the form for a new entry of the same type, keeping the account.
13. **Given** the form has unsaved changes, **When** the user goes back, **Then** a "Discard changes?" dialog appears. With no changes, back closes the screen without a dialog.
14. **Given** EXP-02 opened in edit mode (`/expenses/:id/edit`), **Then** the fields are prefilled, a delete icon shows in the app bar, and deleting closes the screen and offers Undo.
15. **Given** EXP-02, **Then** no Repeat toggle and no ad of any kind is shown.

---

### User Story 2 - Browse, search, and review transactions (EXP-01, EXP-03) (Priority: P1)

A user opens the Expenses tab to see where their money went this month. They see income, expense, and net totals for the period, then a list grouped by day with daily totals. They switch to last month with the period arrows, search for "chai", filter by the UPI payment mode, tap a row to see its full detail, and swipe a mistaken entry away, with a few seconds to undo.

**Why this priority**: Logged data is only useful if the user can find and check it. Together with User Story 1, this is the minimum useful expense tracker.

**Independent Test**: Seed a fixed set of transactions across two months and several categories, accounts, and payment modes. Confirm that the list, daily totals, and summary strip match the seed for each period, that search and filters narrow the rows correctly, and that delete with Undo restores the row in place.

**Acceptance Scenarios** (copied verbatim from `docs/spec.md`; the EXP-01 criterion "Changing period updates the list, totals, and ads without leaving the screen" mentions ads and is therefore not copied, see derived scenario 2):

EXP-01:

- [ ] Totals in the summary strip always equal the sum of visible rows (transfers excluded).
- [ ] Undo restores a deleted row in its original position.

EXP-03:

- [ ] Deleting returns to EXP-01 with Undo available.

**Additional scenarios** (derived from the EXP-01 and EXP-03 Layout, Behavior, and States):

1. **Given** the Expenses tab opens, **Then** the screen shows, in order: an app bar titled "Expenses" with search, filter, and overflow (Categories, Accounts) actions; a period selector set to the current month; a summary strip with Income, Expense, and Net for the period; any active filter chips; and the grouped list.
2. **Given** the user changes the period (arrows, or the picker with Day, Week, Month, Year, or Custom range), **Then** the list and totals update without leaving the screen.
3. **Given** a list of entries, **Then** rows are grouped under sticky date headers ("Today", "Yesterday", or `EEE, d MMM`) showing that day's total, and each row shows the category icon in a colored circle, the category name, a one-line note, the account and payment mode in small text, and the right-aligned signed amount.
4. **Given** a transfer in the period, **Then** it is listed (shown as a transfer between the two accounts) but excluded from the Income, Expense, Net, and daily totals.
5. **Given** a search query, **Then** after a 300 ms pause rows are shown whose note or displayed category name contains the query, or whose amount matches it exactly or as a prefix. Default categories are matched by their name in the current language.
6. **Given** filters for category, account, payment mode, type, or amount range, **Then** each active filter shows as a chip with an ×, and removing a chip widens the list immediately. Filters persist while the app is open and are cleared after a restart.
7. **Given** more than 50 entries in the period, **Then** the list loads in pages of 50 as the user scrolls, and entries added or changed elsewhere appear without a manual refresh.
8. **Given** a swipe left on a row, **Then** the entry is removed immediately with a 5-second Undo snackbar (no confirmation dialog). **Given** a swipe right, **Then** EXP-02 opens prefilled as a copy with today's date. Both actions are also available from the row's long-press menu.
9. **Given** an empty period with no filters, **Then** the screen shows an illustration, "No transactions in October" (with the period's name), and an "Add expense" button. **Given** a search or filter with no results, **Then** it shows "No matches" with a "Clear filters" button and no illustration.
10. **Given** a tap on a row, **Then** EXP-03 opens showing a large amount, a type badge, the category with its icon, the account (both accounts for a transfer), payment mode, date and time, note, and a receipt thumbnail that opens a full-screen zoomable view. Actions: Edit (opens EXP-02 in edit mode), Duplicate, Delete, and Share (as text).
11. **Given** the Expenses tab, **Then** the FAB opens EXP-02 with type Expense, and no ad of any kind is shown; the banner slot stays empty and takes no space.

---

### User Story 3 - Upgrade safely and start with useful defaults (Priority: P1)

A person who installed the feature 001 build updates the app. Their settings, categories, and Cash account are still there, nothing is seeded twice, and they can start logging right away. A new user who installs this build gets the same 12 expense categories, 5 income categories, and Cash account, in their own language, exactly once.

**Why this priority**: Losing or duplicating user data on an update breaks trust immediately (Constitution III). Every story above depends on the stored data being correct.

**Independent Test**: Create a database at the feature 001 schema containing settings, the seeded categories and account, plus one custom category. Upgrade it, then confirm that every row is unchanged, the transactions store exists and is empty, and the seed did not run again.

**Acceptance Scenarios** (SYS-01 seed criterion, copied verbatim from `docs/spec.md`; it is already covered by feature 001 and must keep passing):

- [ ] First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once.

**Additional scenarios**:

1. **Given** a device with feature 001 data, **When** the app is updated and opened, **Then** all settings, categories, and accounts are preserved exactly, and the defaults are not seeded again.
2. **Given** a fresh install, **When** the app is opened in Gujarati, **Then** the default category and account names appear in Gujarati, and switching to English shows them in English without changing stored data.
3. **Given** the transactions store, **Then** lookups by date, by category and date, and by account and date stay fast at 10,000 entries (see SC-004).
4. **Given** any transaction, category, or account removed by the user, **Then** it is marked as deleted rather than erased, so Undo can restore it and later backups stay consistent.

---

### User Story 4 - Organize categories (EXP-04, EXP-05) (Priority: P2)

A user wants a "Chai & snacks" category and doesn't use "Fuel". They open Categories from the Expenses overflow menu, add the new category with an icon and color, hide Fuel, and drag Groceries to the top. They also see how much they spent in each category this month.

**Why this priority**: The seeded categories cover most users. Customizing them makes logging faster but is not needed for a first entry.

**Independent Test**: On a seeded install, create a custom category, rename and hide a default one, reorder the list, and delete a custom category that has transactions by moving them to a replacement. Confirm that EXP-02's grid and EXP-01's rows reflect each change.

**Acceptance Scenarios** (EXP-05 acceptance criteria, copied verbatim from `docs/spec.md`; EXP-04 has no acceptance criteria in the master spec):

- [ ] Duplicate names within the same type are rejected with an inline error.

**Additional scenarios** (derived from the EXP-04 and EXP-05 Layout and Behavior):

1. **Given** EXP-04, **Then** it shows Expense and Income tabs, each with a reorderable list (drag handle) showing icon, name, and this month's total. Hidden categories appear in a collapsed "Hidden" section. The FAB opens EXP-05 for the selected tab's type.
2. **Given** a tap on a category, **Then** EXP-05 opens as a bottom sheet in edit mode with its type fixed.
3. **Given** EXP-05, **Then** it offers a name (required, at most 30 characters), an icon picker (a grid of about 80 icons grouped by theme), a color picker (16 preset colors), and the type (fixed when editing).
4. **Given** a name that matches another category of the same type, compared case-insensitively, ignoring surrounding spaces, and treating repeated inner spaces as one, and including each non-renamed default category by its name in every supported language (English, Hindi, Gujarati), **Then** saving is blocked with an inline error. The same name in the other type is allowed.
5. **Given** a default category, **Then** it can be renamed and hidden, but no delete action is offered.
6. **Given** a custom category with no transactions, **When** the user deletes it, **Then** it is removed with a 5-second Undo.
7. **Given** a custom category that has transactions, **When** the user deletes it, **Then** they must choose a replacement category of the same type, and all of its transactions are moved to the replacement before it is removed.
8. **Given** a hidden category, **Then** it is not offered in EXP-02 for new entries, but existing transactions still show it with its name and icon.
9. **Given** a reorder, **Then** the new order is saved immediately, kept after a restart, and always shown in EXP-04. In EXP-02 it breaks ties between categories used equally often.

---

### User Story 5 - Track money across accounts (EXP-06, EXP-07) (Priority: P2)

A user pays with cash, their SBI savings account, and Paytm. They open Accounts, add "SBI Savings" (Bank) with its current balance and "Paytm" (Wallet), and see a total balance across all active accounts. They tap SBI Savings to see only its transactions, and later archive an old card they no longer use.

**Why this priority**: The seeded Cash account is enough to start logging. Multiple accounts and balances add value once the user logs regularly.

**Independent Test**: Create two accounts with opening balances, then log an expense, an income, and a transfer between them. Confirm that each account's balance equals opening + income − expense ± transfers, and that the total equals the sum of non-archived accounts.

**Acceptance Scenarios**: EXP-06 and EXP-07 have no acceptance criteria in the master spec. These are derived from their Layout and Behavior:

1. **Given** EXP-06, **Then** it shows a total balance card at the top (sum of non-archived accounts), then a list of accounts with icon, name, type, and current balance (negative balances in red with a minus sign), then a collapsed "Archived" section. The FAB opens EXP-07.
2. **Given** an account, **Then** its balance equals its opening balance + income − expense − transfers out + transfers in, counting only entries that are not deleted.
3. **Given** a tap on an account, **Then** EXP-01 opens filtered to that account, with the account filter chip shown.
4. **Given** a long-press on an account, **Then** the user can edit or archive it. An archived account can be restored from the Archived section.
5. **Given** an account that has transactions, **Then** it can be archived but not deleted. An account with no transactions can be deleted, with a 5-second Undo.
6. **Given** an archived account, **Then** it is not offered in EXP-02 pickers for new entries, but existing transactions still show it.
7. **Given** EXP-07, **Then** it offers a name (required), type (Cash, Bank, UPI wallet, Card, Wallet), opening balance (may be negative, entered with the custom keypad), icon, and color.
8. **Given** only one non-archived account remains, **Then** it cannot be archived or deleted, and the user is told why.

---

### User Story 6 - Expense on Home and quick add (Priority: P3)

From the Home tab the user sees how much they have spent today and this month, and the global quick-add action takes them straight into a new expense.

**Why this priority**: Home already loops over modules (feature 001). Replacing the placeholder card makes the module visible outside its tab, but the full Home layout is a later feature (T2.5).

**Independent Test**: Log two expenses today and one earlier this month, plus one income. Confirm the Expense card shows today's and this month's expense totals (income and transfers excluded), and that the module's quick-add action opens EXP-02 with type Expense.

**Acceptance Scenarios**:

1. **Given** expenses today and earlier this month, **Then** the Expense card shows "Spent today" and "This month" as expense totals in the user's currency. Income and transfers are not counted.
2. **Given** no transactions yet, **Then** the card shows a friendly empty state with one action, "Add your first expense", which opens EXP-02.
3. **Given** a tap on the card, **Then** EXP-01 opens.
4. **Given** a transaction is added, edited, or deleted anywhere, **Then** the card updates without a reload.
5. **Given** the module's quick-add action, **Then** it is labeled "Add expense" and opens EXP-02 with type Expense.
6. **Given** the Expense module is disabled in SET-06, **Then** its card and tab are hidden as before, and its data is kept.

---

### Edge Cases

- **Amount precision**: Typed amounts allow at most 2 decimal places. Calculator results with more decimals are rounded half-up to 2 places before saving, and the displayed value equals the stored value. Division by zero shows an inline error and is not saved.
- **Amount limits**: ₹99,99,99,999.00 is accepted; one paisa more is rejected. Negative calculator results are rejected for transactions (the sign comes from the type).
- **Date boundaries**: An entry at 23:59 local time belongs to that local day in headers, daily totals, "Spent today", and period totals, even though it is stored in UTC. Week periods start on the user's first-day-of-week setting.
- **Time zone change**: Entries keep their original moment in time; their day grouping follows the device's current time zone.
- **Future dates**: An entry dated in the future is allowed and appears under its own date. It counts in a period only when the period contains that date.
- **Deleted references**: A transaction whose category is hidden or whose account is archived still shows them with their name and icon. Categories and accounts are never hard-deleted while transactions refer to them.
- **Undo after leaving**: The Undo snackbar stays available for its full 5 seconds even if the user navigates to another screen or tab, and tapping it restores the entry. After 5 seconds the deletion is final in the UI. The entry is still recoverable in data (soft delete), but not from the UI.
- **Edit an entry deleted elsewhere**: If an entry open in EXP-02 or EXP-03 is deleted elsewhere, the screen shows a plain message and returns to EXP-01 instead of saving a deleted entry.
- **Duplicate of a transfer**: Swipe-right on a transfer opens EXP-02 as a transfer with the same From and To accounts.
- **Archived default account**: If the last-used account is archived, the default falls back to the first non-archived account in sort order.
- **Receipt file missing**: If a receipt file was removed from storage, EXP-03 shows a "Receipt not available" placeholder instead of failing.
- **Renamed default category**: Once a default category is renamed, it shows the user's text in every language. Hiding a default category doesn't change its name.
- **Search in other scripts**: Search works for notes and category names in Hindi and Gujarati, as well as English.
- **Load failure**: If stored data cannot be read, each screen shows its error state with "Try again", not a crash or blank screen. If a save fails, the form stays open with the user's input intact and an error message.
- **Large data**: With 10,000 transactions, the list, summary strip, and account balances stay responsive (SC-004, SC-005).

## Requirements *(mandatory)*

### Functional Requirements

**Data and storage (T1.1)**

- **FR-001**: System MUST store transactions with: type (expense, income, transfer), a positive amount in minor units (paise), source account, destination account (transfers only), category (expense and income only), payment mode (cash, UPI, card, net banking, other), optional note (at most 200 characters), the user-chosen moment (stored in UTC), optional receipt reference, and an optional recurring-rule reference that stays empty in this feature.
- **FR-002**: System MUST keep the existing category and account records and add read, create, update, reorder, hide/archive, and soft-delete operations for categories, accounts, and transactions through domain interfaces that screens use without knowing how data is stored.
- **FR-003**: All three record types MUST be removed by soft delete (marked deleted, excluded from every list, total, balance, search, and picker) so Undo can restore them.
- **FR-004**: System MUST support fast lookups of transactions by date, by category and date, and by account and date, as listed in spec §4.
- **FR-005**: System MUST upgrade an existing feature 001 database to the new schema without losing or changing any existing record, and the upgrade MUST be covered by an automated migration test from every earlier schema version.
- **FR-006**: First launch MUST seed 12 expense categories, 5 income categories, and one Cash account (type cash, opening balance 0), exactly once, with names stored as translation keys (`expense_cat_<slug>`, `income_cat_<slug>`, `expense_account_cash`). Upgrading MUST NOT seed again.
- **FR-007**: Default category and account names MUST be displayed in the current app language. User-entered names MUST be shown exactly as typed.
- **FR-008**: Changes to transactions, categories, or accounts MUST appear on every open screen that shows them (EXP-01, EXP-03, EXP-04, EXP-06, the Expense Home card) without a manual refresh.
- **FR-009**: Money MUST be held and computed as whole minor units at every step. Totals and balances MUST be exact sums with no rounding drift.

**EXP-02 Add / edit transaction (T1.2)**

- **FR-010**: EXP-02 MUST open full screen at `/expenses/add` (new) and `/expenses/:id/edit` (edit), with an Expense · Income · Transfer control, a large amount field using the shared custom keypad with calculator keys, a category grid (Expense and Income only), account chip(s), payment-mode chips, a date and time chip, a note field, receipt attachment, and a sticky Save button.
- **FR-011**: Validation MUST require an amount greater than 0 and at most ₹99,99,99,999; a category for Expense and Income; and different From and To accounts for Transfer. Errors MUST appear inline under the relevant field.
- **FR-012**: A new expense MUST be saveable with amount + category in 3 taps after typing the amount, using the default account, payment mode, and date and time.
- **FR-013**: Defaults MUST remember the user: last-used account, payment mode derived from the account type, and categories in the EXP-02 grid ordered by how often the user picks them, with the EXP-04 drag order as the tiebreak (and as the whole order when there is no history).
- **FR-014**: Save MUST close the screen and show "Saved · Undo" for 5 seconds. Long-press on Save MUST offer "Save and add another". Back with unsaved changes MUST ask "Discard changes?".
- **FR-015**: Receipts MUST be stored only on the device, in app-private storage, reduced to at most 1280 px on the longest side and JPEG quality 80%. Removing a receipt or deleting a transaction MUST NOT break other entries.
- **FR-016**: EXP-02 MUST NOT show the Repeat toggle, budget checks, or any ad.

**EXP-01 Transactions list and EXP-03 detail (T1.3)**

- **FR-017**: EXP-01 MUST replace the Expenses tab placeholder and follow the spec §15.3 screen anatomy: app bar → period selector → summary strip → filter chips → grouped list. The overflow menu MUST show Categories and Accounts only; Budgets, Recurring, and Reports are added by later features.
- **FR-018**: The summary strip MUST show Income, Expense, and Net for the selected period and active filters and search, excluding transfers, and MUST always equal the sum of the matching rows. Amounts MUST carry a sign and the income/expense color.
- **FR-019**: The period selector MUST default to the current month and support Day, Week, Month, Year, and Custom range.
- **FR-020**: Search MUST match note, displayed category name, and amount (exact or prefix), debounced by 300 ms. Filters MUST cover category, account, payment mode, type, and amount range, and MUST last for the app session only.
- **FR-021**: The list MUST load in pages of 50 and stay scrollable at 60 fps with 10,000 transactions.
- **FR-022**: Swipe left MUST soft-delete with a 5-second Undo that restores the row in its original position. Swipe right MUST open EXP-02 as a copy dated today. Both MUST also be available from a long-press menu.
- **FR-023**: EXP-03 MUST open at `/expenses/:id` and show the fields listed in User Story 2, scenario 10, with Edit, Duplicate, Delete, and Share (plain-text summary through the system share sheet). Delete MUST return to EXP-01 with Undo available. The "Created from recurring rule" link MUST NOT be shown in this feature.

**EXP-04/05 Categories and EXP-06/07 Accounts (T1.4)**

- **FR-024**: EXP-04 MUST open at `/expenses/categories` with Expense and Income tabs, a drag-reorderable list showing this month's total per category, a collapsed Hidden section, and a FAB to EXP-05.
- **FR-025**: EXP-05 MUST be a bottom sheet with name (required, at most 30 characters, unique per type, case-insensitive, ignoring surrounding spaces and treating repeated inner spaces as one, and not equal to any non-renamed default category name of that type in English, Hindi, or Gujarati), about 80 icons grouped by theme, 16 preset colors, and a type that is fixed when editing.
- **FR-026**: Default categories MUST be renamable and hideable but never deletable. Deleting a custom category that has transactions MUST require choosing a same-type replacement and moving the transactions to it.
- **FR-027**: EXP-06 MUST open at `/expenses/accounts` and show a total-balance card (non-archived accounts), the account list with current balances, and a collapsed Archived section. Tapping an account MUST open EXP-01 filtered to it. Long-press MUST offer edit and archive.
- **FR-028**: EXP-07 MUST be a bottom sheet with name (required), type (Cash, Bank, UPI wallet, Card, Wallet), opening balance (may be negative), icon, and color. An account with transactions MUST NOT be deletable, and at least one non-archived account MUST always remain.

**Module integration**

- **FR-029**: `ExpenseModule` MUST implement `TrackerModule` and own the routes for EXP-01, EXP-02, EXP-03, EXP-04, and EXP-06 under `/expenses`. EXP-05 and EXP-07 open as bottom sheets without routes.
- **FR-030**: `ExpenseModule.dashboardCard` MUST show "Spent today" and "This month" expense totals, update live, open EXP-01 on tap, and show an "Add your first expense" empty state. It MUST NOT show a budget bar.
- **FR-031**: `ExpenseModule.quickAddAction` MUST return an "Add expense" action that opens EXP-02 with type Expense.
- **FR-032**: `ExpenseModule.backupSection` MUST remain a stub with no export or import until T3.2, and the module's seeders MUST remain the existing exactly-once defaults seeder.

**UI/UX, localization, accessibility (spec §12, §15)**

- **FR-033**: Every screen in this feature MUST implement loading (skeletons only after 300 ms), empty, error (plain language with "Try again"), and content states.
- **FR-034**: Screens MUST use only the theme tokens and shared components from `lib/core/widgets/`; amounts MUST always be shown through the shared amount component with the user's currency, Indian grouping for INR, a sign, and tabular figures.
- **FR-035**: All user-facing text MUST be available in English, Hindi, and Gujarati, using placeholders and plurals instead of concatenation, in sentence case, with buttons that start with a verb.
- **FR-036**: All screens MUST work at 200% font scale and on 360 dp-wide screens without clipping, have touch targets of at least 48 × 48 dp, label every icon button for screen readers, read amounts as currency, and never convey meaning by color alone.
- **FR-037**: Reversible actions (delete transaction, delete custom category without transactions, archive account) MUST use an Undo snackbar without a dialog. Moving transactions to a replacement category MUST state what will change before it happens.
- **FR-038**: No ad of any kind MUST be requested or shown by this feature. The `AppScaffold` banner slot MUST stay empty and take no space.
- **FR-039**: Each screen in this feature MUST pass the spec §15.10 design review checklist, with EXP-01 and EXP-02 golden tests in light and dark themes, in English and Gujarati.
- **FR-040**: Every acceptance criterion copied above MUST have at least one automated test, and widget tests MUST use fake repositories.

### Key Entities

- **Transaction**: One money movement. Type (expense, income, transfer); positive amount in paise; source account; destination account (transfer only); category (expense and income only); payment mode; optional note (≤ 200 chars); occurred-at moment; optional receipt reference; optional recurring-rule reference (unused in this feature); created, updated, and deleted timestamps.
- **Category**: A label for expenses or income (fixed type). Name (a translation key for defaults, user text otherwise; ≤ 30 chars for user names, unique per type); icon; color from the 16-color set; default flag (defaults can be hidden, never deleted); hidden/archived flag; sort order; created, updated, and deleted timestamps. One category has many transactions.
- **Account**: Where money is held. Name; type (cash, bank, UPI wallet, card, wallet); opening balance in paise (may be negative); icon; color; archived flag; sort order; created, updated, and deleted timestamps. Current balance is derived, never stored: opening + income − expense − transfers out + transfers in.
- **Period**: A date range chosen in the period selector (day, week, month, year, or custom), evaluated in the device's local time zone. Not stored.
- **Transaction filter**: The session-only set of search text, categories, accounts, payment modes, types, and amount range applied to EXP-01. Not stored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can log a new expense with only amount and category in 3 taps after typing the amount, and in under 5 seconds from opening the add screen.
- **SC-002**: For every amount with up to 2 decimals between ₹0.01 and ₹99,99,99,999.00, the stored value equals the typed value exactly (100% of a test set of at least 1,000 values, including 10.10, 0.29, and 1,25,000.55).
- **SC-003**: In every tested period, filter, and search combination, the summary strip, daily totals, account balances, and the Home card equal the sum of the matching entries with 0 paise difference.
- **SC-004**: With 10,000 transactions stored, saving an entry completes in under 100 ms, and opening EXP-01 for any month shows content in under 300 ms on a mid-range device.
- **SC-005**: With 10,000 transactions stored, scrolling EXP-01 stays at 60 frames per second on a mid-range device.
- **SC-006**: Upgrading from the feature 001 build preserves 100% of existing settings, categories, and accounts, and creates 0 duplicate default records.
- **SC-007**: A deleted transaction, category, or account restored with Undo within 5 seconds reappears with all of its data and in the same position in 100% of tests.
- **SC-008**: All seven screens render without clipping or overflow at 200% font scale on a 360 dp-wide screen, in English, Hindi, and Gujarati, in light and dark themes.
- **SC-009**: Every acceptance criterion copied into this spec has at least one passing automated test, and no ad request is made from any screen in this feature.

## Assumptions

- **Reuse of feature 001**: The categories and accounts tables, the exactly-once seeding mechanism, and the six shared widgets named in the request already exist and are reused. This feature only extends a shared widget where a screen needs behavior it lacks, with tests updated to match.
- **Category name length**: User-entered category names are limited to 30 characters by EXP-05. The storage limit of 40 from feature 001 stays, so renamed defaults and future imports fit.
- **Recurring-rule reference**: The transactions store includes the empty, optional recurring-rule reference from spec §4 now, so T1.6 does not need another schema change for it. Its link to recurring rules is enforced once T1.6 adds them.
- **Payment mode defaults by account type** (Wallet → Other confirmed in Clarifications): Cash → Cash, Bank → Net banking, UPI wallet → UPI, Card → Card, Wallet → Other. The user can always change it per entry.
- **Last active account** (confirmed in Clarifications): At least one non-archived account must always exist, so EXP-02 always has a default account.
- **Duplicate-name check** (confirmed in Clarifications): Category names are compared case-insensitively, ignoring surrounding spaces and treating repeated inner spaces as one ("Chai  snacks" equals "Chai snacks"), against other non-deleted categories of the same type. Defaults that have not been renamed are compared by their names in all three languages. Renamed defaults are compared by their stored text, like custom categories.
- **Undo after save**: Undo after saving a new entry removes it (soft delete). Undo after an edit restores the previous values.
- **Calculator rounding**: Results with more than 2 decimals are rounded half-up to 2 decimals, in whole-paise arithmetic.
- **Overflow menu**: EXP-01 shows only Categories and Accounts until the Budgets, Recurring, and Reports screens exist.
- **Quick add**: The module provides one quick-add action, "Add expense". Income and transfers are reached through the EXP-02 type control. The Home FAB menu that combines module actions is part of T2.5.
- **Receipts** (confirmed in Clarifications): Receipts are in scope. The photo-picking and compression dependency is justified in the plan, as Constitution VII requires. Receipts are not included in backups until T3.2.
- **Share**: Share in EXP-03 sends a plain-text summary (type, amount, category, account, date, note) through the system share sheet. It never includes the receipt image.
- **Out of scope**: The Repeat toggle and recurring rules (T1.6), budgets and budget alerts (T1.5), reports (T1.7), all ads (T4.x; the banner slot stays empty), the Home dashboard layout and FAB menu (T2.5), backup of expense data (T3.2), and CSV/PDF export (T3.3).
- **Golden baselines**: Golden images are generated on Linux only, as in feature 001; the Windows test run excludes them.
