# Contract: Expense screens, controllers, and states

Rules for every screen (Constitution II and V, spec §15):
- **One Riverpod notifier per screen** (`riverpod_generator`). The state is an immutable `freezed`
  class. The async status is explicit: `AsyncValue<…>` from an `AsyncNotifier`/`StreamNotifier`,
  or a sealed `Loading | Data | Error` union where a screen also holds synchronous form state.
- **Four states**:
  - Loading: `DelayedSkeleton` (shown only after 300 ms) wrapping `SkeletonList`/`SkeletonCard`.
  - Empty: `EmptyState`.
  - Error: `ErrorState` with "Try again", which calls `ref.invalidate`.
  - Content.
- **Layout and tokens**: only `AppTokens`, `AppScaffold`, and `lib/core/widgets/`. The
  `bannerSlot` is always `null` (FR-038).
- **Text**: all strings come from ARB (keys `expense_*`), in sentence case, and buttons start with a verb.
- **Screen IDs**: files follow the feature 001 naming (`transactions_screen.dart`, no ID prefix).
  Each screen's doc comment and every test `group`/`testWidgets` name starts with its Screen ID
  (`EXP-01 …`), as Constitution I requires.

File layout: `lib/features/expense/presentation/{screens,widgets,controllers}/`.

---

## EXP-01 Transactions list: `TransactionsScreen` / `TransactionsController`

**State** `TransactionsState`:
- `query: TxnQuery` (session; held by this keep-alive controller, see "Session filter" below)
- `searchText: String`
- `searchOpen: bool`
- `pageCount: int`
- `rows: AsyncValue<List<TransactionView>>`
- `ledger: AsyncValue<PeriodLedger>`
- `categories: Map<String, Category>` (display and search)
- `hasMore: bool`

**Session filter**: `TransactionsController` is the screen's only notifier, declared
`@Riverpod(keepAlive: true)`, and `query` lives in its state. So the filter survives tab switches
and navigation, and it resets on process restart (FR-020). The default is the current
`MonthPeriod`. Pure query edits (apply, remove a chip, clear) are plain functions in
`transaction_query_ops.dart`, not a second notifier (Constitution II: exactly one notifier per
screen). Because a kept-alive notifier can't tell when its screen is rebuilt, the screen calls the
`resetPaging()` intent from `initState`. That sets `pageCount` to 1 and keeps `query` unchanged.

| Intent | Effect |
| --- | --- |
| `setPeriod(Period)` | Updates the query and resets `pageCount` to 1 |
| `setSearch(String)` | 300 ms debounce, then resolves `matchingCategoryIds` from the localized names (R5) |
| `applyFilters(...)` / `removeFilter(chip)` / `clearFilters()` | Update the query |
| `loadMore()` | `pageCount++` when `rows.length == pageCount*50` |
| `resetPaging()` | `pageCount = 1`; `query` unchanged. Called by the screen's `initState` |
| `delete(id)` | `softDelete`, then shows `UndoSnackBar` → `undelete` |
| `duplicate(id)` | Navigates to `/expenses/add?duplicateOf=id` (swipe right or menu) |
| `applyRouteAccount(accountId)` | Called once from the route's query parameters |

**Layout** (§15.3 anatomy):
- `AppScaffold`:
  - title "Expenses"
  - actions: search, filter (opens `TransactionFilterSheet`), overflow (Categories, Accounts)
  - FAB "+" → `/expenses/add`
- Body:
  - `PeriodSelector(period)`
  - Summary strip: 3× `AmountText` (Income +, Expense −, Net ±)
  - Filter chips (`InputChip` with ×, via `ChipSelector`-style tokens)
  - `CustomScrollView` with `SliverMainAxisGroup` + `PinnedHeaderSliver` per day (R6)
- Row: `CategoryAvatar` 40 dp, category name (`titleMedium`), note (1 line, ellipsis), account ·
  payment mode (`bodySmall`), right-aligned `AmountText`. Transfer rows show "From → To" with a
  transfer icon and a neutral amount.
- Swipes: `Dismissible`. endToStart = delete (red, trash icon). startToEnd = duplicate. The
  long-press menu has Delete and Duplicate.
- **Empty states**:
  - Period empty and no filter or search: illustration plus "No transactions in {period}" and
    "Add expense".
  - Filtered empty: "No matches" plus "Clear filters", with no illustration.

## EXP-02 Add / edit transaction: `TransactionFormScreen` / `TransactionFormController`

`family` arguments: `TransactionFormArgs(mode: add|edit, id?, initialType, duplicateOf?)`.

**Four states (Constitution V)**:
- Loading: `DelayedSkeleton` while categories, accounts, and (in edit mode) the entry load.
- Error: `ErrorState` "Try again" if any of them fails to load.
- Empty: the selected Expense or Income type has **no pickable (non-hidden) categories**. The
  grid shows only "+ New" with the helper text "No categories yet. Add one to continue"
  (`expense_noCategories`). Transfer cannot be empty, because at least one active account always
  exists (Q3).
- Content: the form.

**State** `TransactionFormState`:
- `status: Loading | Ready | LoadError`
- `draft: TransactionDraft`
- `expression: String` (raw keypad input)
- `amountMinor: int?`
- `errors: Map<Field, ValidationError>`
- `pickableCategories`
- `pickableAccounts`
- `noteSuggestions`
- `isDirty: bool`
- `saving: bool`
- `original: Transaction?` (edit snapshot for Undo)

| Intent | Effect |
| --- | --- |
| `key(String)` / `operator(String)` / `backspace()` / `equals()` | Updates `expression`, then `amountMinor = KeypadExpression.evaluateToMinor` |
| `setType(TxnType)` | Clears the category when the type changes, and swaps the grid for From/To on Transfer |
| `selectCategory(id)` | |
| `selectAccount(id)` / `selectToAccount(id)` | Selecting the source account sets `paymentMode` from the account type (data-model §2) |
| `setPaymentMode` | |
| `setOccurredAt(DateTime)` | Chips: Today, Yesterday, pick date, pick time |
| `setNote(String)` | Max 200 with a live counter. Suggestions from `recentNotes(prefix)` |
| `pickReceipt(source)` / `removeReceipt()` | Shows an inline error on `ReceiptFailure` and keeps the form |
| `save({addAnother = false})` | Validates. Creates or updates. Returns `SaveResult(id, undo)`. With `addAnother`, the form resets but keeps type and account |
| `delete()` | Edit mode only. Soft delete, then the caller pops and shows Undo |
| `onCategoryCreated(Category)` | From EXP-05 "+ New": select it |

**Defaults (new)**:
- Type from the route.
- Account: `lastUsedAccountId()`, otherwise the first pickable account (R7).
- Payment mode from the account type.
- `occurredAt` = `clock.now()`.

**Layout**:
- Full-screen modal. Top: the Expense · Income · Transfer segmented control.
- Amount (`displaySmall`, tabular figures, `AmountText`-formatted preview with Indian grouping),
  then `NumericKeypad` (custom keypad; the system keyboard never opens for the amount).
- 4-column category grid with "+ New" last (`AppBottomSheet` → EXP-05). Hidden for Transfer.
- Account chip(s), then the payment mode `ChipSelector`, then the date and time chip with Today
  and Yesterday shortcuts.
- Note field ("(optional)", counter), receipt row (Camera, Gallery, thumbnail, remove).
- Sticky "Save expense", "Save income", or "Save transfer" button, lifted above the keyboard.
  Long-press → "Save and add another".
- **Edit mode**: delete icon in the app bar.
- **Back**: if `isDirty` → `ConfirmDialog` "Discard changes?".
- **Three-tap path** (acceptance criterion): after typing the amount, tap a category, then tap
  Save. The keypad's Done key only collapses the keypad, and it is not counted.
- No Repeat toggle. No ads.

## EXP-03 Transaction detail: `TransactionDetailScreen` / `TransactionDetailController`

**State**: `AsyncValue<TransactionView?>` from `watchById(id)`, plus `receiptAbsolutePath: String?`.
A `null` row (deleted elsewhere) shows the message "This transaction no longer exists" and pops to
EXP-01.

**Layout**: large `AmountText`, type badge, category with avatar, account(s), payment mode, date
and time, note, receipt thumbnail (tap → full-screen `InteractiveViewer`; a missing file shows the
"Receipt not available" placeholder). Actions:
- **Edit** → `/expenses/:id/edit`.
- **Duplicate** → `/expenses/add?duplicateOf=id`.
- **Delete**: soft delete, then `context.go('/expenses')`, then Undo on the root messenger.
- **Share**: `TextSharer.shareText`, a localized multi-line summary built with ARB placeholders.

No recurring link. Banner slot empty.

## EXP-04 Categories: `CategoriesScreen` / `CategoriesController`

**State**:
- `tab: CategoryType`
- `items: AsyncValue<List<CategoryWithStats>>` for the current local month
- `hiddenExpanded: bool`

| Intent | Effect |
| --- | --- |
| `reorder(oldIndex, newIndex)` | Optimistic, then `repo.reorder`. A failure reverts and shows an error snackbar |
| `toggleHidden(id)` | Shows Undo |
| `delete(id)` | `transactionCount == 0` → delete with Undo. Otherwise opens `ReplacementCategorySheet` (same type, excluding self, showing the count) → `delete(id, replacementId)` with no undo (R12). Defaults: there's no delete action in the UI |

**Layout**: Tabs Expense / Income, a `ReorderableListView` (drag handle, 48 dp) of rows (avatar,
localized name, `AmountText` month total), a collapsed "Hidden" `ExpansionTile`, and a FAB "+" →
EXP-05 for the current tab type. Tap → EXP-05 edit. The long-press menu has Hide/Unhide and Delete
(custom only).

## EXP-05 Add / edit category: `CategorySheet` / `CategoryFormController` (bottom sheet)

`family(CategoryFormArgs(type, id?))`. **State**: `name`, `iconKey`, `colorHex`, `type`,
`nameError?`, `saving`, `status`.

**Four states (Constitution V)**:
- Loading: edit mode while the category and the list of existing names load. New mode loads only
  the existing names for the duplicate check.
- Error: `ErrorState` "Try again".
- Empty: new mode. The blank form shows the name field focused, the first icon and the first
  palette color preselected, and the hint "Up to 30 characters".
- Content: edit mode, prefilled.

- Fields: name (max 30, counter), `IconPickerGrid` (about 80, grouped), `ColorPickerRow` (16), and
  type, which is shown read-only when editing.
- Save validates with `ValidateCategoryName` (R9). A duplicate shows the inline error "A category
  with this name already exists" under the field (acceptance criterion).
- It returns the saved `Category` to the caller (EXP-02 "+ New" selects it).

## EXP-06 Accounts: `AccountsScreen` / `AccountsController`

**State**: `AsyncValue<AccountsData(total, active, archived)>`, `archivedExpanded`.

**Layout**:
- `SummaryCard` "Total balance" (`AmountText`, red with − when negative).
- List rows: avatar, name, localized type, balance (`AmountText`, kind by sign).
- Collapsed "Archived" section. FAB "+" → EXP-07.

**Interactions**:
- Tap → `context.go('/expenses?accountId=<id>')`.
- Long-press menu:
  - Edit → EXP-07.
  - Archive → Undo snackbar. Unarchive also shows Undo.
  - Delete, only when `!hasTransactions`, with Undo.
- If the account is the last active one, Archive and Delete are disabled, with the helper text
  "You need at least one active account" (Q3).

## EXP-07 Add / edit account: `AccountSheet` / `AccountFormController` (bottom sheet)

**State**: `name`, `type`, `openingExpression`, `openingNegative: bool`, `iconKey`, `colorHex`,
`errors`, `saving`, `status`.

**Four states (Constitution V)**:
- Loading: edit mode only, while the account loads.
- Error: `ErrorState` "Try again".
- Empty: new mode. The blank form has the name focused, type Cash, opening balance ₹0 shown as a
  placeholder, and the first icon and color.
- Content: edit mode, prefilled.

Fields:
- Name.
- Type (`ChipSelector`: Cash, Bank, UPI wallet, Card, Wallet).
- Opening balance: `NumericKeypad` plus a +/− toggle (data-model §5).
- Icon and color (shared pickers).

Save validates with `ValidateAccount`.

## Home card: `ExpenseDashboardCard` / `ExpenseDashboardController`

**State**: `AsyncValue<TodayAndMonthSpend>` from `watchTodayAndMonthSpend(clock.now())`. It is
recomputed when the local date changes, using a timer to the next local midnight.
- Content: `SummaryCard` with "Spent today" and "This month".
- Empty (`!hasAnyTransaction`): `EmptyState`-style "Add your first expense" action.
- Error: compact `ErrorState`.
