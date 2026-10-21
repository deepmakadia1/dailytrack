---

description: "Task list for Expense Core (Phase 1, T1.1–T1.4)"
---

# Tasks: Expense Core (Phase 1, T1.1–T1.4)

**Input**: Design documents from `specs/002-expense-core/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV says every acceptance criterion needs at least one automated
test, `domain/` and `data/` need ≥ 80% coverage, widget tests use fakes and `NoAdsService`, and
EXP-01/EXP-02 need goldens. Write each test task first and confirm it fails before its
implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US6). Test names start with the
Screen ID and scenario, e.g. `EXP-02 US1-5 amount above limit shows inline error` (Constitution I).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US6 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`.
- **Strings**: add keys to `tool/l10n/phase0_strings.py` (en, hi, gu together; prefix `expense_`;
  sentence case; buttons start with a verb; placeholders and plurals, never concatenation). Then
  run `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit the ARB files by hand.
- **Codegen**: after changing any `@riverpod`, `@freezed`, or Drift file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Screens**:
  - Use only `AppTokens` and `lib/core/widgets/`. Build on `AppScaffold` with `bannerSlot: null`.
  - Every screen has 4 states: `DelayedSkeleton`, `EmptyState`, `ErrorState` (with "Try again" →
    `ref.invalidate`), and content.
  - One `@riverpod` notifier per screen, with a `freezed` state (contracts/screens.md).
- **Widget tests**: `pumpTestApp` (`test/helpers/test_app.dart`) with fakes from
  `test/features/expense/fakes.dart`. They never open a database. Each one also asserts that no
  `AppBannerAd`/`AppNativeAd` is in the tree (FR-038). Widget tests always use `pumpTestApp`'s
  default `NoAdsService` (Constitution IV) and never inject a mock ad service. That no ad is
  requested is proved statically by T004(e).
- **Unit tests with real Drift**: `makeRealContainer` (`test/helpers/real_container.dart`) or
  `AppDatabase(NativeDatabase.memory())`.
- **Goldens**: tag `golden`, generated on Linux only (`flutter test --tags golden --update-goldens`).
  On Windows, run `flutter test --exclude-tags golden`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Spec update, dependencies, shared strings, and layering guards

- [X] T001 Update `docs/spec.md` before any code (Constitution I, plan Open item 1):
  - **EXP-02 category grid**: "ordered by how often the user picks each category, with the EXP-04 order as the tiebreak and as the whole order when there is no history".
  - **EXP-02 payment mode defaults**: Cash → Cash, Bank → Net banking, UPI wallet → UPI, Card → Card, Wallet → Other.
  - **EXP-05**: "unique per type, compared case-insensitively, ignoring surrounding spaces and treating repeated inner spaces as one, including the English, Hindi, and Gujarati names of default categories that have not been renamed".
  - **EXP-06**: "The last non-archived account cannot be archived or deleted, and the user is told why".
  - **EXP-01 search**: "amount matches exactly, or as a prefix of the whole-rupee digits when the query has no decimal point".
  - Also add a dated line to the spec's change history (if there is none, add a short "Changes" note under the version line).
- [X] T002 Add dependencies to `pubspec.yaml`: `image_picker: ^1.2.4`, `flutter_image_compress: ^2.5.1`, `path_provider: ^2.1.6`, `share_plus: ^13.3.1` (research R1). Then:
  - Run `flutter pub get`.
  - Run `flutter build apk --flavor dev --debug` and inspect `build/app/intermediates/merged_manifests/devDebug/AndroidManifest.xml`. Confirm no `CAMERA`, `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, or location permission was added. If any was added, remove it with `tools:node="remove"` in `android/app/src/main/AndroidManifest.xml`.
- [X] T003 [P] Add the shared Expense strings (en/hi/gu) to `tool/l10n/phase0_strings.py` and regenerate:
  - Type labels: `expense_typeExpense` "Expense", `expense_typeIncome` "Income", `expense_typeTransfer` "Transfer".
  - Payment modes: `expense_payCash` "Cash", `expense_payUpi` "UPI", `expense_payCard` "Card", `expense_payNetBanking` "Net banking", `expense_payOther` "Other".
  - Account types: `expense_accountTypeCash` "Cash", `…Bank` "Bank", `…Upi` "UPI wallet", `…Card` "Card", `…Wallet` "Wallet".
  - Snackbars and errors: `expense_saved` "Saved", `expense_deleted` "Transaction deleted", `expense_loadError` "Couldn't load your transactions. Try again.", `expense_saveError` "Couldn't save. Your changes are still here. Try again.".
  - Spend labels: `expense_spentToday` "Spent today", `expense_thisMonth` "This month".
  - Quick add: `expense_quickAdd` "Add expense".
  - For the shared pickers (T012–T014): icon group names `common_iconGroup<Group>` (Food, Transport, Home & bills, Shopping, Health, Education, Leisure, Travel, Money, Other), one semantic label per icon key `icon_<key>` for every key planned in research R14, and `common_colorLabel` "Color {index} of {total}".
- [X] T004 [P] Extend the layering scan in `test/core/theme/no_hardcoded_style_test.dart` with five new tests:
  - (a) Files under `lib/**/presentation/` never import `package:image_picker`, `package:flutter_image_compress`, `package:path_provider`, or `package:share_plus`.
  - (b) Only `lib/main.dart` imports `features/expense/expense_bindings.dart`.
  - (c) `package:share_plus` is imported only under `lib/core/share/`.
  - (d) Files under `lib/features/expense/domain/` import no `package:flutter`, `package:drift`, or any plugin.
  - (e) No file under `lib/features/expense/` imports `lib/core/ads/` or `package:google_mobile_ads` (FR-038: this feature cannot request an ad).

**Checkpoint**: Dependencies resolve, strings generate, the scan passes on the current tree.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schema v2, domain model, Drift repositories, core ports, and test fakes. Every story
depends on these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Core ports and shared widgets

- [X] T005 [P] Write `test/core/utils/period_test.dart` for the sealed `Period` (research R13). Cover:
  - `SingleDayPeriod`, `WeekPeriod(firstDayOfWeek)` (1 = Monday … 7 = Sunday, from `AppSettings.firstDayOfWeek`), `MonthPeriod`, `YearPeriod`, `CustomPeriod`.
  - `startUtcMs`/`endUtcMsExclusive` computed from **local** midnights.
  - `previous()`/`next()` (Custom returns null), and `contains(utcMs)`.
  - Month ends (31 → 30 → 28/29) and week starts on Monday and on Sunday.
  - A DST zone: run the boundary assertions with `TZ=America/New_York` noted in a comment, and skip on Windows if `TZ` cannot be set.
- [X] T006 [P] Implement `lib/core/utils/period.dart` (pure Dart, no Flutter imports) to pass T005. Include `label(String locale, RelativeDayLabels labels)`:
  - Month: `yMMMM`.
  - Day: relative "Today"/"Yesterday", otherwise `EEE, d MMM`.
  - Week: `d MMM – d MMM`.
  - Year: `y`.
  - Custom: `d MMM y – d MMM y`.
- [X] T007 [P] Create `lib/core/utils/clock.dart`: `abstract interface class Clock { DateTime now(); }`, `SystemClock`, and a `FixedClock` (test-visible). Create `lib/core/utils/clock_provider.dart` with a keep-alive `clockProvider` (defaults to `SystemClock`).
- [X] T008 [P] Create `lib/core/module/root_navigator.dart` exporting `rootNavigatorKey = GlobalKey<NavigatorState>()` and `rootMessengerKey = GlobalKey<ScaffoldMessengerState>()` (contracts/routes_and_module.md). Then:
  - Pass `navigatorKey: rootNavigatorKey` in `lib/app/router/app_router.dart`.
  - Pass `scaffoldMessengerKey: rootMessengerKey` in `lib/app/app.dart`.
  - Keep all existing router tests green.
- [X] T009 [P] Add an optional `ScaffoldMessengerState? messenger` parameter to `UndoSnackBar.show` in `lib/core/widgets/undo_snack_bar.dart` (default `ScaffoldMessenger.of(context)`). Add a test to `test/core/widgets/undo_snack_bar_test.dart`: the snackbar stays visible and Undo still fires after the route that raised it is popped.
- [X] T010 [P] Create `lib/core/l10n/default_name_catalog.dart` (pure-Dart interface `DefaultNameCatalog { Set<String> namesFor(String key); }`) and `lib/core/l10n/default_name_catalog_impl.dart` (`L10nDefaultNameCatalog` uses `lookupAppLocalizations(Locale(code))` for `en`, `hi`, `gu` and `l10nByKey`). Test in `test/core/l10n/default_name_catalog_test.dart`: `namesFor('expense_cat_food')` == {"Food", "खाना", "ખોરાક"}, and unknown keys return an empty set.
- [X] T011 [P] Create `lib/core/share/text_sharer.dart`: `TextSharer { Future<void> shareText(String text, {String? subject}); }`, `SharePlusTextSharer` (uses `share_plus`), and a keep-alive `textSharerProvider`. Add `FakeTextSharer` (records calls) to `test/helpers/fakes.dart`.
- [X] T012 [P] Create `lib/core/theme/app_icons.dart` (research R14):
  - `AppIcons.byKey(String key) → IconData`, falling back to `Icons.category`.
  - `AppIcons.groups`: an ordered `Map<String groupL10nKey, List<String iconKey>>` with about 80 const Material icons in groups Food, Transport, Home & bills, Shopping, Health, Education, Leisure, Travel, Money, Other.
  - It must include every key used by `lib/features/expense/data/seed/expense_defaults_seeder.dart` (`restaurant`, `local_grocery_store`, `directions_bus`, `local_gas_station`, `shopping_bag`, `receipt`, `home`, `medical_services`, `school`, `movie`, `flight`, `category`, `payments`, `storefront`, `redeem`, `savings`, `attach_money`, `wallet`).
  - Use the group-name and icon-label strings added in T003 (this task does not edit the strings file).
  - Test in `test/core/theme/app_icons_test.dart`: every seeder key resolves to a non-fallback icon, keys are unique, and every key has a label.
- [X] T013 [P] Create `lib/core/widgets/icon_picker_grid.dart` (`IconPickerGrid({required String selectedKey, required ValueChanged<String> onSelected})`):
  - Group headers, 48 dp cells, and a 40 dp `CategoryAvatar`-style preview.
  - The selected state is shown by a ring **and** a check icon, never color alone.
  - `Semantics(selected:, label: icon_<key>)`.
  - Test in `test/core/widgets/icon_picker_grid_test.dart` (selection, labels, 48 dp) and add golden cases to the shared-widget goldens.
- [X] T014 [P] Create `lib/core/widgets/color_picker_row.dart` (`ColorPickerRow({required String selectedHex, required ValueChanged<String> onSelected})`):
  - The 16 `AppColors.palette` swatches as `AppColors.toHex` values, in a wrapping layout.
  - Selected state shown by a check icon, and a semantic label from `common_colorLabel` (added in T003).
  - Test in `test/core/widgets/color_picker_row_test.dart` and add golden cases.

### Domain (pure Dart, `lib/features/expense/domain/`)

- [X] T015 [P] Extend `lib/features/expense/domain/enums.dart` with:
  - `enum TxnType { expense, income, transfer }`
  - `enum PaymentMode { cash, upi, card, netBanking, other }`
  - The extension `AccountTypeX.defaultPaymentMode`: cash→cash, bank→netBanking, upi→upi, card→card, wallet→other.

  Keep the "append-only: never reorder or remove values" comment. Test in `test/features/expense/domain/enums_test.dart`:
  - The index order is fixed.
  - The mapping covers every `AccountType`.
- [X] T016 [P] Create the freezed entities in `lib/features/expense/domain/entities/`, one file each, with the exact fields from data-model.md §4:
  - `transaction.dart` (`Transaction`, with `isTransfer` and `signedAmountMinor`: income +, expense −, transfer 0)
  - `transaction_draft.dart`, `transaction_view.dart`, `category.dart` (`isHidden` maps to the `isArchived` column), `account.dart`
  - `category_with_stats.dart`, `account_with_balance.dart`
  - `txn_query.dart` (`period`, `search`, `matchingCategoryIds`, `categoryIds`, `accountIds`, `paymentModes`, `types`, `minAmountMinor`, `maxAmountMinor`, `isFiltered`)
  - `period_ledger.dart` (`PeriodLedger`, `DayTotal`), `today_and_month_spend.dart`

  Domain imports only `package:freezed_annotation`, `package:meta`, pure-Dart files under `lib/core/utils/` (for example `period.dart`, `date_keys.dart`, `keypad_expression.dart`, `result.dart`), and `lib/core/l10n/default_name_catalog.dart`. Never Flutter, Drift, or plugins (checked by T004 d).
- [X] T017 [P] Create `lib/features/expense/domain/errors.dart` with:
  - `ExpenseStorageFailure`, `TransactionNotFound`
  - `CategoryDeleteNotAllowed` (reasons `isDefault`, `replacementRequired`, `invalidReplacement`)
  - `AccountDeleteNotAllowed` (`hasTransactions`, `lastActive`), `AccountArchiveNotAllowed` (`lastActive`)
  - `ReceiptFailure`
- [X] T018 [P] Create the repository and port interfaces exactly as in contracts/repositories.md:
  - `lib/features/expense/domain/repositories/transaction_repository.dart`
  - `…/category_repository.dart`
  - `…/account_repository.dart`
  - `lib/features/expense/domain/receipts/receipt_picker.dart` (with `enum ReceiptSource { camera, gallery }`)
  - `lib/features/expense/domain/receipts/receipt_store.dart`
- [X] T019 [P] Write `test/features/expense/domain/amount_entry_test.dart` (SC-002) for a loop over ≥ 1,000 decimal strings. Include `10.10 → 1010`, `0.29 → 29`, `0.01 → 1`, `125000.55 → 12500055`, `99999999.99`, and generated `i/100` values. Assert:
  - `AmountEntry.parse(expression)` equals `int.parse(digitsWithoutPoint)` exactly.
  - Calculator results with more than 2 decimals are rounded half-up (`10 ÷ 3 → 333`, `2 ÷ 3 → 67`).
  - `÷0`, negative results, and 3+ decimals typed are errors.
- [X] T020 [P] Write `test/features/expense/domain/validate_transaction_test.dart` for `ValidateTransaction` → error enum (data-model §5):
  - Amount null or 0 → `amountRequired`; `amountMinor > 99999999900` → `amountTooLarge`; `99999999900` accepted; keypad error → `amountInvalid`.
  - Expense/income without `categoryId` → `categoryRequired`.
  - Transfer without `toAccountId` → `toAccountRequired`; `toAccountId == accountId` → `sameAccount`.
  - Note longer than 200 characters → `noteTooLong`.
- [X] T021 Implement `lib/features/expense/domain/usecases/amount_entry.dart` (wraps `KeypadExpression.evaluateToMinor`, rejects negatives and > 2 typed decimals) and `lib/features/expense/domain/usecases/validate_transaction.dart` to pass T019–T020.
- [X] T022 [P] Write `test/features/expense/domain/fold_ledger_test.dart`, then implement `lib/features/expense/domain/usecases/fold_ledger.dart`: `PeriodLedger foldLedger(Iterable<(int occurredAtUtcMs, TxnType type, int amountMinor)> rows, {DateTime Function(int utcMs) toLocal = Epoch.toLocal})`. Rules:
  - Income and expense are summed separately, `net = income − expense`, transfers are excluded from every total.
  - Day keys are `DateKeys.fromLocal(toLocal(ms))`, using the injected converter (default `Epoch.toLocal`, the device time zone).
  - An entry at 23:59 local time falls on that local day.
  - Edge case "Time zone change": fold the same rows with two injected `toLocal` converters (UTC+05:30 and UTC−04:00). An entry at 2026-10-13T20:00Z falls on 2026-10-14 in the first and 2026-10-13 in the second. Every row lands in exactly one day under both. Income, expense, and net are identical. Only the day grouping changes, never the stored moment.

### Data (Drift, `lib/features/expense/data/`)

- [X] T023 Create `lib/features/expense/data/tables/transactions_table.dart` (`@DataClassName('TransactionRow')`), exactly per data-model.md §3.1:
  - Columns:
    - `id` TEXT PK
    - `type` `intEnum<TxnType>`
    - `amountMinor` INTEGER with `CHECK (amountMinor BETWEEN 1 AND 99999999900)`
    - `accountId` TEXT `references(Accounts, #id)`
    - `toAccountId` TEXT nullable `references(Accounts, #id)`
    - `categoryId` TEXT nullable `references(Categories, #id)`
    - `paymentMode` `intEnum<PaymentMode>`
    - `note` TEXT nullable with `CHECK (note IS NULL OR length(note) <= 200)`
    - `occurredAt` INTEGER (UTC ms)
    - `receiptPath` TEXT nullable ("Relative path `receipts/<uuid>.jpg`")
    - `recurringRuleId` TEXT nullable ("Always NULL in this feature. No FK until T1.6")
    - `createdAt`, `updatedAt` INTEGER, and `deletedAt` INTEGER nullable
  - The table-level check `(type = 2 AND toAccountId IS NOT NULL AND categoryId IS NULL AND toAccountId <> accountId) OR (type IN (0, 1) AND categoryId IS NOT NULL AND toAccountId IS NULL)`.
  - `@TableIndex`es: `transactions_occurred (occurredAt)`, `transactions_category_occurred (categoryId, occurredAt)`, `transactions_account_occurred (accountId, occurredAt)`.
  - The same header comments as `accounts_table.dart` (`coverage:ignore-file`).
- [X] T024 Register `Transactions` in `@DriftDatabase(tables: [Settings, Categories, Accounts, Transactions])` in `lib/core/database/app_database.dart` and set `schemaVersion => 2`. Then:
  - Run `dart run drift_dev make-migrations`, which produces `drift_schemas/app_database/drift_schema_v2.json`, `lib/core/database/app_database.steps.dart`, and the test helpers under `test/drift/app_database/generated/`.
  - Implement `onUpgrade: stepByStep(from1To2: (m, schema) async { await m.createTable(schema.transactions); await m.createIndex(...) for the 3 indexes; })`.
  - Leave `drift_schema_v1.json` untouched.
  - Extend the comment allowing the core → feature import to name `transactions_table.dart` (plan Complexity Tracking).
- [X] T025 Extend `test/drift/app_database/migration_test.dart`: replace the commented template with `upgrade from v1 to v2` (`verifier.startAt(1)` → `migrateAndValidate(db, 2)`), and update the fresh-database test to expect v2.
- [X] T026 [P] Write `test/features/expense/data/transactions_table_test.dart` (real in-memory Drift). Assert:
  - Inserts are rejected for `amountMinor` 0 and 99999999901.
  - Transfers are rejected with a category or with the same from/to accounts. Expenses are rejected without a category.
  - A 201-character note is rejected.
  - A non-existent `accountId` is rejected (FK).
  - `PRAGMA index_list('transactions')` lists the 3 named indexes.
- [X] T027 [P] Create `lib/features/expense/data/daos/transactions_dao.dart` (`@DriftAccessor(tables: [Transactions, Categories, Accounts])`) with these queries (research R4, R5, R7):
  - `watchPage(TxnQuery, limit)`: a join returning rows with category, account, and toAccount, ordered `occurredAt DESC, createdAt DESC, id DESC`, with `deletedAt IS NULL`.
  - `watchLedgerRows(TxnQuery)`: the `(occurredAt, type, amountMinor)` projection, no limit.
  - The search predicate: note `LIKE '%q%' ESCAPE '\'` with `%`, `_`, and `\` escaped; OR `categoryId IN matchingCategoryIds`; OR `amountMinor = parsed`; OR, when q has no decimal point, `CAST(amountMinor / 100 AS TEXT) LIKE 'q%'`.
  - Filters: category, account (matches `accountId` or `toAccountId`), payment mode, type, and amount range.
  - `watchById`, `lastUsedAccountId` (most recent `createdAt` whose account is not archived), `recentNotes(prefix, limit)`, and the `todayAndMonthSpend` sums.
- [X] T028 [P] Create `lib/features/expense/data/daos/categories_dao.dart`:
  - `watchByTypeWithStats(type, monthStartUtc, monthEndUtc)`: the month total and all-time usage count for non-deleted transactions.
  - `watchPickable(type)`: non-hidden, `ORDER BY usageCount DESC, sortOrder ASC`.
  - `watchAll`, `insert`, `update`, `setHidden`, `reorder` (rewrites `sortOrder` for the whole type in one transaction), `transactionCount`, `moveTransactions(from, to)`, `softDelete`, and `undelete`.
- [X] T029 [P] Create `lib/features/expense/data/daos/accounts_dao.dart`:
  - `watchAllWithBalances()`: one aggregate per data-model §3.3, `balance = opening + income − expense − transfers out + transfers in`, over `deletedAt IS NULL`, plus `hasTransactions`.
  - `watchTotalBalance()` (non-archived), `watchPickable()`, `insert`, `update`, `setArchived`, `softDelete`, `undelete`, and `countActive()`.
- [X] T030 [P] Create the row ↔ entity mappers in `lib/features/expense/data/mappers/` (`transaction_mapper.dart`, `category_mapper.dart`, `account_mapper.dart`): UTC ms ↔ `DateTime.utc`, and blank note → NULL.
- [X] T031 Write `test/features/expense/data/transaction_repository_test.dart` (real Drift). Cover:
  - `create` assigns a UUID and timestamps.
  - `update` of a deleted or missing id throws `TransactionNotFound`.
  - `restore(snapshot)` rewrites every field.
  - `softDelete` hides the row from page, ledger, and `watchById` (null).
  - `undelete` returns it **at the same index** in `watchPage` with ties on `occurredAt` (EXP-01 acceptance criterion: "Undo restores a deleted row in its original position.").
  - The page `limit` is respected.
  - `lastUsedAccountId` skips archived accounts.
  - `recentNotes` returns distinct entries, most recent first, matching the prefix.
  - `watchTodayAndMonthSpend` counts only expenses and excludes income and transfers.
  - Streams re-emit after writes to another table (FR-008).
- [X] T032 [P] Write `test/features/expense/data/transaction_search_test.dart` (real Drift):
  - Note substring, case-insensitive for English, and Hindi/Gujarati text.
  - `matchingCategoryIds`.
  - Amount: "12" matches ₹12, ₹120, and ₹1,250 but not ₹2.12. "12.5" matches only ₹12.50.
  - `%`, `_`, and `\` are literal.
  - Combined with filters.
- [X] T033 [P] Write `test/features/expense/data/transaction_ledger_test.dart` (real Drift, the EXP-01 criterion "Totals in the summary strip always equal the sum of visible rows (transfers excluded).") using a seeded `Random(42)` loop. For 500 rows across 3 accounts, all types, and 2 months, and for each period kind × a set of filters, assert:
  - `ledger.income/expense/net` equal the sums over `watchPage(limit: 100000)` rows (transfers excluded).
  - The `dayTotals` keys and values equal a per-local-day regrouping of those rows.
- [X] T034 Implement `lib/features/expense/data/repositories/drift_transaction_repository.dart` (uses `TransactionsDao`, `foldLedger`, `Clock`, and `Uuid`; maps `SqliteException` → `ExpenseStorageFailure`) to pass T031–T033.
- [X] T035 [P] Write `test/features/expense/data/category_repository_test.dart` (real Drift with the seeded defaults). Cover:
  - The pickable order: usage count descending, then `sortOrder` (clarification Q2). With no history, it is pure `sortOrder`.
  - Hidden categories are excluded from `watchPickable` but kept in `watchAll`.
  - `create` sets `sortOrder = max + 1`, and `reorder` persists.
  - Deleting a default throws `CategoryDeleteNotAllowed.isDefault`.
  - Deleting a custom category with transactions and no replacement throws `replacementRequired`. With a replacement of the other type or itself it throws `invalidReplacement`. With a valid replacement, the transactions are moved and the category is soft-deleted atomically (force a failure mid-way and assert nothing changed).
  - `undelete` restores the category.
  - The month total uses local month boundaries.
- [X] T036 Implement `lib/features/expense/data/repositories/drift_category_repository.dart` to pass T035.
- [X] T037 [P] Write `test/features/expense/data/account_repository_test.dart` (real Drift). Cover:
  - Balances for opening + income − expense − transfer out + transfer in, with a negative opening balance and deleted transactions ignored.
  - The total covers non-archived accounts only.
  - Deleting an account with transactions (as source or destination) throws `AccountDeleteNotAllowed.hasTransactions`.
  - Archiving or deleting the last non-archived account throws `…lastActive` (clarification Q3).
  - `undelete` and unarchive work.
  - `watchPickable` excludes archived accounts.
- [X] T038 Implement `lib/features/expense/data/repositories/drift_account_repository.dart` to pass T037. Run the last-active checks inside a DB transaction.

### Receipts (`lib/features/expense/data/receipts/`)

- [X] T039 [P] Write `test/features/expense/data/receipt_resize_test.dart`, then implement `lib/features/expense/data/receipts/resize_math.dart`: `(int w, int h) targetSize(int w, int h, {int maxSide = 1280})` keeps the aspect ratio, never upscales, and makes the longest side ≤ 1280 (4000×3000 → 1280×960; 800×600 → unchanged; 3000×4000 → 960×1280).
- [X] T040 [P] Write `test/features/expense/data/receipt_store_test.dart` (temp directory), then implement `lib/features/expense/data/receipts/file_receipt_store.dart` (`ReceiptStore`, root directory injected; production root is `getApplicationDocumentsDirectory()`):
  - `resolve('receipts/x.jpg')` returns an absolute path, or null if the file is missing.
  - `pruneOrphans(referenced)` deletes only unreferenced files with an mtime older than 24 h and returns the count.
  - Referenced files and files from the last 24 hours are kept (research R8).
- [X] T041 Implement `lib/features/expense/data/receipts/image_receipt_picker.dart` (`ReceiptPicker`):
  1. `ImagePicker().pickImage(source, maxWidth: 2560)`. Null → return null.
  2. Read the dimensions and compute `targetSize`.
  3. `FlutterImageCompress.compressAndGetFile(..., minWidth/minHeight = target, quality: 80, format: CompressFormat.jpeg, keepExif: false)` to `<root>/receipts/<uuid>.jpg`.
  4. Return `receipts/<uuid>.jpg`.

  Any exception becomes `ReceiptFailure`. Add `// coverage:ignore` around the plugin calls with a reason (device-only; covered by the T112 manual check).

### Wiring and fakes

- [X] T042 Create `lib/features/expense/presentation/expense_providers.dart`. Declare keep-alive providers that throw `UnimplementedError` unless overridden (mirroring `core/settings/settings_providers.dart`): `transactionRepositoryProvider`, `categoryRepositoryProvider`, `accountRepositoryProvider`, `receiptPickerProvider`, `receiptStoreProvider`, `defaultNameCatalogProvider`. It must not import `data/` or Drift.
- [X] T043 Create `lib/features/expense/expense_bindings.dart` with `List<Override> expenseOverrides()`, binding the Drift repositories (`ref.watch(appDatabaseProvider)`, `ref.watch(clockProvider)`), `ImageReceiptPicker`, `FileReceiptStore`, and `L10nDefaultNameCatalog` (contracts/routes_and_module.md). Then spread `...expenseOverrides()` in `productionOverrides()` in `lib/main.dart`.
- [X] T044 Create `test/features/expense/fakes.dart`:
  - In-memory `FakeTransactionRepository`, `FakeCategoryRepository`, and `FakeAccountRepository` backed by `StreamController.broadcast`, with seed helpers `withDefaults()` (17 categories, Cash) and `add(...)`, plus switches `failNextWrite` / `failWatch` for error states.
  - `FakeReceiptPicker` (returns a configured path, null, or throws), `FakeReceiptStore`, and `FakeDefaultNameCatalog`.
  - Implement the same ordering and ledger rules as the contracts.
- [X] T045 Update `pumpTestApp`/`restartTestApp` in `test/helpers/test_app.dart` so that, by default, they override the six expense providers with empty-default fakes, `clockProvider` with a `FixedClock(2026-10-14 10:00 local)`, and `textSharerProvider` with `FakeTextSharer`. Add an optional `expense:` parameter (a record of the fakes) so tests can pass their own. All existing tests stay green.
- [X] T046 Add the route constants and pure path helpers to `lib/app/router/routes.dart`:
  - `expenseAdd = '/expenses/add'`, `expenseCategories = '/expenses/categories'`, `expenseAccounts = '/expenses/accounts'`, `expenseDetail = '/expenses/:id'`, `expenseEdit = '/expenses/:id/edit'`, plus their segments and names.
  - `expenseDetailPath(id)`, `expenseEditPath(id)`, `expenseAddPath({String? type, String? duplicateOf})`, `expensesPath({String? accountId})`.

  The file stays import-free. Test in `test/app/router/routes_test.dart`.
- [X] T047 Write `test/features/expense/data/transaction_perf_test.dart` (real in-memory Drift, 10,000 rows; SC-004, research R15). Assert:
  - `create` is under 100 ms (median of 20).
  - The first emission of `watchPage(month, limit: 50)` + `watchLedger(month)` is under 300 ms.
  - The `watchLedger(year)` emission is under 300 ms.

  Tag it `perf`, so CI runs it but it can be excluded locally.

**Checkpoint**: `flutter test --exclude-tags golden` is green. Schema v2 migrates. Repositories are
tested against real Drift. The app still runs, with the Expenses tab still showing the placeholder.

---

## Phase 3: User Story 1 - Log a transaction in seconds (EXP-02) (Priority: P1) 🎯 MVP

**Goal**: A full-screen add/edit form saves expenses, income, and transfers with the custom keypad,
validation, remembered defaults, receipts, and Undo.

**Independent Test**: On a freshly seeded install, open EXP-02, type 10.10, pick a category, and
save. Exactly one transaction exists with 1010 paise, the default account, the current date and
time, and the chosen category.

### Tests for User Story 1 ⚠️ (write first, must fail)

- [X] T048 [P] [US1] Write the acceptance tests in `test/features/expense/presentation/transaction_form_screen_test.dart`:
  - (a) **"A new expense can be saved with amount + category only in 3 taps after typing the amount."** After entering `250` with keypad taps, count only the subsequent `tester.tap` calls: category Food, then Save. The repository has 1 expense (≤ 3 taps).
  - (b) **"Amount is stored in paise without rounding errors (e.g. 10.10 → 1010)."** For `10.10`, `0.29`, and `1,25,000.55` entered through the keypad, the stored `amountMinor` is 1010, 29, and 12500055.
- [X] T049 [US1] Add scenario tests to the same file, named `EXP-02 US1-<n>` with the spec's numbering (US1-3, "+ New", is tested in T088):
  1. The amount is focused and the keypad is shown with no system keyboard (`tester.testTextInput.isVisible == false`). Indian grouping shows ₹1,25,000.
  2. `120+35.50` then `=` shows ₹155.50 and stores 15550.
  4. Transfer hides the category grid and shows From/To chips, and from == to shows the inline `sameAccount` error.
  5. Amounts 0, empty, and ₹99,99,99,999.01 show an inline amount error and nothing is saved.
  6. Expense with no category shows an inline category error.
  7. The default account is the last used (fake), and changing it to a Wallet account sets payment mode Other (clarification Q4).
  8. The Today/Yesterday chips set the date.
  9. The note shows a counter, is limited to 200, and shows suggestions from `recentNotes`.
  10. A receipt picked with `FakeReceiptPicker` shows a thumbnail placeholder, and `ReceiptFailure` shows an inline error with the form kept.
  11. After save, the screen pops, the "Saved · Undo" snackbar is shown on `rootMessengerKey`, and Undo soft-deletes the new entry. After an edit, Undo restores the previous values.
  12. Long-press Save → "Save and add another" saves and resets the amount, keeping type and account.
  13. Back with changes shows "Discard changes?", and back without changes pops with no dialog.
  14. Edit mode is prefilled, and the app bar delete pops and shows Undo.
  15. No Repeat toggle (`find.text` for the repeat label finds nothing) and no ad widgets.

  Also add the four-state tests (Constitution V; contracts/screens.md EXP-02): loading with a delayed fake shows a skeleton only after 300 ms; a load failure (`failWatch`) shows `ErrorState`, and "Try again" recovers; **empty**: with every Expense category hidden in the fake, the grid shows only "+ New" and the `expense_noCategories` helper; content.
- [X] T050 [US1] Add edge-case tests to the same file, named `EXP-02 edge`:
  - `10÷3` stores 333, and `5÷0` shows an inline error.
  - A negative result is rejected.
  - An entry dated in the future is accepted.
  - The edited entry was deleted elsewhere (the fake emits null): a message is shown, the form pops, and nothing is saved.
  - A save failure (`failNextWrite`) keeps the form open with the input intact and shows the `expense_saveError` text.
  - The last-used account is archived, so the default falls back to the first pickable account.
- [X] T051 [P] [US1] Write `test/features/expense/presentation/transaction_form_controller_test.dart` (ProviderContainer + fakes). Cover:
  - Each intent in contracts/screens.md EXP-02.
  - `isDirty` transitions.
  - `setType` clears the category.
  - In edit mode an archived account stays selectable (data-model §3.3).
  - `duplicateOf` prefills with `occurredAt = clock.now()` and no receipt.

### Implementation for User Story 1

- [X] T052 [US1] Add the EXP-02 strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Titles: `expense_addTitle` "Add transaction", `expense_editTitle` "Edit transaction".
  - Save buttons: `expense_saveExpense` "Save expense", `expense_saveIncome` "Save income", `expense_saveTransfer` "Save transfer", `expense_saveAndAddAnother` "Save and add another".
  - Account chips: `expense_from` "From", `expense_to` "To".
  - Date chips: `expense_today` "Today", `expense_yesterday` "Yesterday".
  - Note: `expense_noteLabel` "Note (optional)", `expense_noteLimit` "{count}/200".
  - Receipt: `expense_attachReceipt` "Attach receipt", `expense_camera` "Camera", `expense_gallery` "Gallery", `expense_removeReceipt` "Remove receipt", `expense_receiptError` "Couldn't attach the photo. Try again.".
  - New category tile: `expense_newCategory` "New".
  - Discard dialog: `expense_discardTitle` "Discard changes?", `expense_discardBody` "Your changes to this transaction will be lost.", `expense_discardConfirm` "Discard".
  - Validation errors, one per error enum: `expense_errAmountRequired` "Enter an amount", `expense_errAmountTooLarge` "Amount can be at most ₹99,99,99,999", `expense_errAmountInvalid` "Check the calculation", `expense_errCategoryRequired` "Choose a category", `expense_errToAccountRequired` "Choose an account to move money to", `expense_errSameAccount` "Choose two different accounts", `expense_errNoteTooLong` "Notes can be up to 200 characters".
  - Deleted elsewhere: `expense_noLongerExists` "This transaction no longer exists".
  - Empty state: `expense_noCategories` "No categories yet. Add one to continue".
  - Delete action: `expense_deleteAction` "Delete transaction".

  The amount limit text uses a placeholder formatted by `MoneyFormatter`.
- [X] T053 [US1] Create `lib/features/expense/presentation/controllers/transaction_form_state.dart` (freezed `TransactionFormState` per contracts/screens.md EXP-02, including `TransactionFormArgs(mode, id?, initialType, duplicateOf?)`) and `lib/features/expense/presentation/controllers/transaction_form_controller.dart` (`@riverpod class TransactionFormController`, family on args). Behavior:
  - Defaults: `lastUsedAccountId()`, otherwise the first pickable account. Payment mode from `defaultPaymentMode`. `occurredAt = clock.now()`.
  - Validates with `ValidateTransaction` and `AmountEntry`.
  - `save({addAnother})` returns `SaveResult(id, Future<void> Function() undo)`.
- [X] T054 [P] [US1] Create `lib/features/expense/presentation/widgets/category_grid.dart`: a 4-column grid of `CategoryAvatar` + localized name (`localizedSeedName`). The "+ New" tile at the end calls a provided `onNew` callback (wired to EXP-05 in T091). Cells are 48 dp or larger, the selected cell shows a ring and a check, and the grid is hidden for Transfer.
- [X] T055 [P] [US1] Create `lib/features/expense/presentation/widgets/receipt_field.dart`: Camera and Gallery buttons, the thumbnail (`Image.file` of `ReceiptStore.resolve`, or the "Receipt not available" placeholder when null), and remove, with semantic labels on every icon button.
- [X] T056 [P] [US1] Create `lib/features/expense/presentation/widgets/account_chips.dart` (single account, or From/To) with an account picker bottom sheet (`AppBottomSheet`, pickable accounts plus the current archived one in edit mode), and `lib/features/expense/presentation/widgets/occurred_at_chips.dart` (Today, Yesterday, date picker, time picker).
- [X] T057 [US1] Create `lib/features/expense/presentation/screens/transaction_form_screen.dart` (EXP-02). Layout in order:
  1. Segmented Expense · Income · Transfer.
  2. Amount display in `displaySmall` with tabular figures and the `MoneyFormatter` preview.
  3. `NumericKeypad`.
  4. `CategoryGrid`.
  5. `AccountChips`.
  6. Payment mode `ChipSelector`.
  7. `OccurredAtChips`.
  8. Note `TextField` with suggestions.
  9. `ReceiptField`.
  10. A sticky save button lifted above the keyboard, with long-press for "Save and add another".

  In edit mode, the app bar has a delete icon. Use `PopScope` for "Discard changes?" with `ConfirmDialog`. After saving: pop, then `UndoSnackBar.show(messenger: rootMessengerKey.currentState)`. Implement all four states from contracts/screens.md EXP-02: loading, error ("Try again"), empty (only "+ New" plus the `expense_noCategories` helper when the type has no pickable categories), and content. No ads.
- [X] T058 [US1] Register the EXP-02 routes in `lib/features/expense/expense_module.dart`: `/expenses/add` (query parameters `type`, `duplicateOf`) and `/expenses/:id/edit`, both with `parentNavigatorKey: rootNavigatorKey` and `MaterialPage(fullscreenDialog: true)`. Declare them before `:id` (contracts/routes_and_module.md).
- [X] T059 [US1] Create `lib/features/expense/presentation/controllers/receipt_prune_controller.dart` (keep-alive `receiptPruneProvider`). On first read it calls `ReceiptStore.pruneOrphans(referenced)` once per process, without awaiting in the UI and ignoring failures. The referenced paths come from `TransactionRepository.allReceiptPaths()` (in contracts/repositories.md; includes deleted rows). Implement it in the DAO, the Drift repository, and the fake, with a unit test. The provider is read in `TransactionFormScreen.initState`.
- [X] T060 [US1] Add EXP-02 golden cases to `test/goldens/expense_screens_golden_test.dart`: new Expense with an amount typed, Transfer, and validation errors, each × light/dark × en/gu (tag `golden`).

**Checkpoint**: EXP-02 works on its own (reachable at `/expenses/add`), and T048–T051 pass.

---

## Phase 4: User Story 2 - Browse, search, and review transactions (EXP-01, EXP-03) (Priority: P1)

**Goal**: The Expenses tab lists transactions per period with exact totals, sticky day headers,
search, filters, swipe delete with Undo or duplicate, and the detail screen with share.

**Independent Test**: Seed a fixed set across two months and several categories, accounts, and
payment modes. Then check:
- The list, daily totals, and summary strip match the seed for each period.
- Search and filters narrow the rows correctly.
- Delete with Undo restores the row in place.

### Tests for User Story 2 ⚠️ (write first, must fail)

- [X] T061 [P] [US2] Update `test/core/widgets/period_selector_test.dart` for the `Period` API. Cover:
  - The month arrows (existing behavior through `MonthPeriod`).
  - Day, Week, and Year labels and arrows.
  - Arrows hidden for `CustomPeriod`.
  - Kind-specific tooltips.

  Also add `test/core/widgets/period_picker_sheet_test.dart`: choosing each of the 5 kinds returns the matching `Period` (Custom through `showDateRangePicker`).
- [X] T062 [P] [US2] Write the acceptance tests in `test/features/expense/presentation/transactions_screen_test.dart`:
  - (a) **"Totals in the summary strip always equal the sum of visible rows (transfers excluded)."** Over a fake data set including transfers, and for no filter, a search, and an account filter, sum the `AmountText` values of the rendered rows (excluding transfers) and compare them with the strip.
  - (b) **"Undo restores a deleted row in its original position."** Swipe left on the 3rd of 5 rows, tap Undo, and the same id is at index 2 again.
  - (c) Edge case "Undo after leaving": swipe-delete a row, switch to the Home tab within 2 s, tap Undo on the still-visible snackbar, return to Expenses, and the row is back at its index. After 5 s the snackbar is gone and the row stays deleted.
- [X] T063 [P] [US2] Write the acceptance test in `test/features/expense/presentation/transaction_detail_screen_test.dart`: **"Deleting returns to EXP-01 with Undo available."** Open `/expenses/:id`, tap Delete, and check that the location is `/expenses` and that a snackbar with Undo is visible. Undo restores the row.
- [X] T064 [US2] Add scenario tests to `transactions_screen_test.dart`, named `EXP-01 US2-<n>`:
  1. The order is app bar (title "Expenses", search, filter, overflow with Categories and Accounts only), period selector on the current month, summary strip, chips, list.
  2. Changing the period updates the list and totals without navigation.
  3. Day headers read "Today", "Yesterday", or `EEE, d MMM`, with the day total, and the rows show avatar, name, a 1-line note, account · mode, and the amount.
  4. A transfer row is shown but excluded from totals.
  5. Search waits 300 ms (`tester.pump(299 ms)` → unchanged; `+1 ms` → filtered) and matches a localized default category name in Gujarati.
  6. A filter chip × removes the filter. Filters survive leaving and returning to the tab and are reset by `restartTestApp`.
  7. Scrolling near the end loads page 2 (51+ rows), and a fake emission adds a row live.
  8. Swipe right opens `/expenses/add?duplicateOf=` with today's date, and the long-press menu offers Delete and Duplicate. Edge case "Duplicate of a transfer": swiping right on a transfer row opens EXP-02 as a Transfer with the same From and To accounts and the same amount, today's date, and no receipt.
  9. An empty period shows "No transactions in October 2026" and "Add expense", and a filtered empty state shows "No matches" and "Clear filters" with no illustration.
  10. The FAB opens EXP-02 with type Expense, and there are no ad widgets.
  11. `/expenses?accountId=x` applies the account filter chip once.
  12. §15.3 FAB behavior: after `tester.drag` scrolling the list down, the FAB is hidden (absent or fully transparent, so it can't be tapped). After scrolling up it is visible and tappable again. With `MediaQuery.disableAnimations` it switches without animating.

  Also add the four-state tests (Constitution V, §15.10 "implemented and tested"; contracts/screens.md EXP-01):
  - **Loading**: with a fake whose streams emit after a delay, nothing shows before 300 ms (`tester.pump(299 ms)`) and `SkeletonList` shows after (`+1 ms`). No full-screen spinner at any time.
  - **Error**: `failWatch` shows `ErrorState` with plain-language text and "Try again". After clearing the failure, tapping it shows the content.
  - **Empty** (scenario 9) and **content** (scenarios 1–3) are covered above.
- [X] T065 [US2] Add scenario and edge-case tests to `transaction_detail_screen_test.dart`, named `EXP-03 US2-10 / edge`:
  - All fields are shown, and a transfer shows both accounts.
  - Edit → `/expenses/:id/edit`.
  - Duplicate → `/expenses/add?duplicateOf=id`.
  - Share calls `FakeTextSharer` with a localized summary (type, amount, category, account, date, note) and no image.
  - Tapping the receipt opens the full-screen `InteractiveViewer`.
  - A missing receipt file shows "Receipt not available".
  - A row deleted elsewhere shows "This transaction no longer exists" and pops.
  - No recurring link.
  - Loading, error, and retry states.
- [X] T066 [P] [US2] Write `test/features/expense/presentation/transactions_controller_test.dart`. Cover:
  - The intents in contracts/screens.md EXP-01: `setPeriod` resets `pageCount`, `loadMore` guard, `setSearch` debounce, `matchingCategoryIds` from localized names, `applyRouteAccount`, and `resetPaging`.
  - `TransactionsController` keeps `query` across screen dispose (keep-alive), and no second notifier exists for EXP-01.
  - `resetPaging()` sets `pageCount` to 1 and keeps `query`, including after `loadMore` and a filter change.

### Implementation for User Story 2

- [X] T067 [US2] Change `lib/core/widgets/period_selector.dart` to `PeriodSelector({required Period period, required ValueChanged<Period> onChanged, VoidCallback? onPick})`:
  - The label comes from `Period.label`, and the arrows call `previous()`/`next()` and are hidden for Custom.
  - Add the tooltip strings `common_previousDay/Week/Year` and `common_nextDay/Week/Year`.
  - Update the existing `PeriodSelector` call sites and golden cases. The baselines are regenerated on Linux in T113.
- [X] T068 [US2] Create `lib/core/widgets/period_picker_sheet.dart` (`PeriodPickerSheet.show(context, {required Period current, required int firstDayOfWeek}) → Future<Period?>`), using `AppBottomSheet` with Day, Week, Month, Year, and Custom range options. Add strings `common_periodDay` "Day", `…Week` "Week", `…Month` "Month", `…Year` "Year", `…Custom` "Custom range".
- [X] T069 [US2] Add the EXP-01/EXP-03 strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Screen and actions: `expense_listTitle` "Expenses", `expense_search` "Search transactions", `expense_filter` "Filter", `expense_menuCategories` "Categories", `expense_menuAccounts` "Accounts".
  - Summary strip: `expense_income` "Income", `expense_expense` "Expense", `expense_net` "Net".
  - Empty states: `expense_emptyPeriod` "No transactions in {period}", `expense_addExpense` "Add expense", `expense_noMatches` "No matches", `expense_clearFilters` "Clear filters".
  - Row actions: `expense_duplicate` "Duplicate".
  - Transfer label: `expense_transferLabel` "{from} → {to}".
  - Detail screen: `expense_detailTitle` "Transaction", `expense_edit` "Edit", `expense_share` "Share", `expense_receiptMissing` "Receipt not available".
  - Share text: `expense_shareText` (multi-line with placeholders type, amount, category, account, date, note).
  - Filter sheet labels: `expense_filterAmountMin/Max`, `expense_applyFilters` "Apply filters".
- [X] T070 [US2] Create `lib/features/expense/presentation/controllers/transaction_query_ops.dart`: pure functions on `TxnQuery`, with no Riverpod and no notifier (Constitution II allows exactly one notifier per screen). They are `withPeriod`, `withSearch`, `applyFilters`, `removeChip(FilterChipId)`, `cleared()` (keeps the period), and `withRouteAccount(accountId)`. Unit-test them in `test/features/expense/presentation/transaction_query_ops_test.dart`.
- [X] T071 [US2] Create `lib/features/expense/presentation/controllers/transactions_state.dart` and `transactions_controller.dart` (EXP-01, contracts/screens.md). It is the screen's **only** notifier, declared `@Riverpod(keepAlive: true)`, so `query` (default `MonthPeriod(clock.now())`) survives navigation and resets on process restart (FR-020). Its intents are `setPeriod`, `setSearch`, `applyFilters`, `removeFilter`, `clearFilters`, `applyRouteAccount`, and `resetPaging` (sets `pageCount` to 1 and leaves `query` alone), all built on T070's ops. Behavior:
  - Combines `watchPage(query, limit: pageCount*50)`, `watchLedger(query)`, and `categoryRepository.watchAll()`.
  - Resolves `matchingCategoryIds` from `localizedSeedName` (the l10n is passed in from the screen) after a 300 ms debounce.
  - Exposes `delete(id) → Future<void> Function() undo` and `loadMore()`.
- [X] T072 [P] [US2] Create the EXP-01 widgets in `lib/features/expense/presentation/widgets/`:
  - `summary_strip.dart`: 3× `AmountText`, income green +, expense red −, net signed.
  - `day_header.dart`: a `PinnedHeaderSliver` child with the relative label and day net `AmountText`.
  - `transaction_row.dart`: 72 dp scaled by `MediaQuery.textScalerOf`; `CategoryAvatar` (`AppIcons.byKey`, `colorHex`), name, 1-line ellipsized note, account · mode in `bodySmall`, and a right-aligned `AmountText`; a transfer variant with a transfer icon, `expense_transferLabel`, and a neutral amount.
  - `filter_chips.dart`: `InputChip` with × and semantic labels.
  - `transaction_filter_sheet.dart`: `AppBottomSheet` with `ChipSelector`s for type, payment mode, categories, and accounts, plus min/max amount through `NumericKeypad`.
- [X] T073 [US2] Create `lib/features/expense/presentation/screens/transactions_screen.dart` (EXP-01) per contracts/screens.md and research R6:
  - `AppScaffold` (`bannerSlot: null`) with a search field toggle, filter, overflow (Categories → `/expenses/categories`, Accounts → `/expenses/accounts`), and FAB → `Routes.expenseAddPath(type: 'expense')`. The FAB hides on scroll down and shows on scroll up (§15.3).
  - A `CustomScrollView` with `PeriodSelector` (`onPick` → `PeriodPickerSheet`), `SummaryStrip`, `FilterChips`, and per day a `SliverMainAxisGroup` containing `PinnedHeaderSliver(DayHeader)` + `SliverList.builder(itemExtent)` of `Dismissible(TransactionRow)`. endToStart deletes (red, trash icon, `UndoSnackBar`). startToEnd duplicates. The long-press menu has the same actions.
  - `loadMore` fires within 10 rows of the end.
  - States: `DelayedSkeleton(SkeletonList)`, `EmptyState` with illustration for an empty period, `EmptyState` with no illustration ("No matches" / "Clear filters") when filtered, and `ErrorState`.
  - In `initState`, call `resetPaging()` (contracts/screens.md EXP-01), then read `accountId` from `GoRouterState` once and call `applyRouteAccount`.
- [X] T074 [US2] Create `lib/features/expense/presentation/controllers/transaction_detail_controller.dart` (EXP-03): it streams `watchById(id)`, resolves the receipt through `ReceiptStore.resolve`, and exposes `delete() → undo` and `shareText(AppLocalizations)`.
- [X] T075 [P] [US2] Create `lib/features/expense/presentation/widgets/receipt_viewer.dart` (a full-screen route with `InteractiveViewer`, a close button with a semantic label, and the missing-file placeholder).
- [X] T076 [US2] Create `lib/features/expense/presentation/screens/transaction_detail_screen.dart` (EXP-03):
  - Large `AmountText`, type badge (text + icon, not color alone), category with avatar, account(s), payment mode, date and time, note, and receipt thumbnail → `ReceiptViewer`.
  - Actions: Edit, Duplicate, Delete (→ `context.go('/expenses')`, then Undo on `rootMessengerKey`), and Share (`textSharerProvider`).
  - A null row shows `expense_noLongerExists` and pops. No recurring link. `bannerSlot: null`. Loading, error, and content states.
- [X] T077 [US2] In `lib/features/expense/expense_module.dart`, make `/expenses` build `TransactionsScreen`, and add the `:id` → `TransactionDetailScreen` child route after the static segments (`add`, `categories`, `accounts`). Delete `lib/features/expense/presentation/screens/expenses_placeholder_screen.dart` and update any tests that referenced it (`test/app/router/*`, `test/goldens/screens_golden_test.dart`).
- [X] T078 [US2] Add EXP-01 and EXP-03 golden cases to `test/goldens/expense_screens_golden_test.dart`: EXP-01 with content (including a transfer), the empty period, "No matches", and the search open; EXP-03 for an expense with a receipt placeholder. Each × light/dark × en/gu.

**Checkpoint**: The Expenses tab is real. US1 and US2 together form a usable expense tracker.

---

## Phase 5: User Story 3 - Upgrade safely and start with useful defaults (Priority: P1)

**Goal**: An existing feature 001 install upgrades with no data loss and no re-seeding. New
installs get the localized defaults exactly once.

**Independent Test**: Create a database at the feature 001 schema containing settings, the seeded
categories and account, plus one custom category. Upgrade it, then confirm every row is unchanged,
`transactions` exists and is empty, and the seed did not run again.

### Tests for User Story 3 ⚠️

- [X] T079 [P] [US3] Add `upgrade from v1 to v2 preserves data and does not re-seed` to `test/drift/app_database/migration_test.dart`:
  1. Use `verifier.schemaAt(1)` and insert, through the generated v1 helper classes, a `settings` row set (including `seed.expense.defaults.v1`), the 17 default categories, a custom category, the Cash account, and a second account.
  2. Migrate to v2 with `migrateAndValidate`.
  3. Assert every v1 row is byte-identical (compare full row maps).
  4. Assert `SELECT COUNT(*) FROM transactions` = 0.
  5. Run `SeedRunner(db).runAll([ExpenseDefaultsSeeder()])` and assert the category and account counts are unchanged (SC-006).
- [X] T080 [P] [US3] Add a regression test to `test/core/database/seed_runner_test.dart`: the existing criterion **"First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once."** runs against schema v2, and running it twice inserts nothing new.
- [X] T081 [P] [US3] Write `test/features/expense/presentation/default_names_localized_test.dart` (US3-2):
  - With the default fakes, EXP-04 and the EXP-02 grid show "ખોરાક" under `gu` and "Food" under `en` for `expense_cat_food`, and the Cash account shows "રોકડ" / "Cash".
  - Switching the locale through `FakeSettingsRepository.setLocale` updates the screens without changing the fake's stored names.

  This test depends on T057 (EXP-02) and T094 (EXP-04). Before those exist, mark it `skip:` with a reason and remove the skip in T097.
- [X] T082 [P] [US3] Add `soft delete leaves rows recoverable` to `test/features/expense/data/transaction_repository_test.dart` (US3-4): after `softDelete` of a transaction, a custom category, and an account without transactions, the raw `SELECT` still finds each row with `deletedAt` set, and `undelete` clears it.

### Implementation for User Story 3

- [X] T083 [US3] Fix any failures from T079–T082 in `lib/core/database/app_database.dart`, `app_database.steps.dart`, or the repositories. If nothing fails, record in the task summary that T024's migration already satisfied US3. Then run `dart run drift_dev make-migrations` again and confirm the generated files are unchanged.

**Checkpoint**: Upgrading is proven safe. The first-launch seed criterion is still green.

---

## Phase 6: User Story 4 - Organize categories (EXP-04, EXP-05) (Priority: P2)

**Goal**: Users add, rename, hide, reorder, and delete categories (with replacement), with a
duplicate-name check across English, Hindi, and Gujarati.

**Independent Test**: On a seeded install, create a custom category, rename and hide a default,
reorder, and delete a custom category that has transactions using a replacement. EXP-02's grid and
EXP-01's rows reflect each change.

### Tests for User Story 4 ⚠️ (write first, must fail)

- [X] T084 [P] [US4] Write `test/features/expense/domain/validate_category_name_test.dart` for `ValidateCategoryName` (research R9, clarification Q5):
  - Empty or whitespace → `required`. Longer than 30 after trim → `tooLong`. `expense_cat_x` / `income_account_y` → `reserved`.
  - Duplicates are case-insensitive after trimming and collapsing whitespace: "food" for an expense duplicates the non-renamed default "Food", "खाना", and "ખોરાક"; "  FOOD " duplicates "Food".
  - The same name in the other type is allowed.
  - A renamed default ("Meals") is compared by "Meals" and no longer by its translations.
  - Deleted categories are ignored.
  - Editing a category to its own current name is allowed.
- [X] T085 [P] [US4] Write `test/features/expense/presentation/category_sheet_test.dart`. The acceptance test: **"Duplicate names within the same type are rejected with an inline error."** Typing "Food" for type expense, then Save, shows the inline error under the name field, and the repository is unchanged. Scenario tests named `EXP-05 US4-<n>`:
  - The fields: name (max 30 with counter), `IconPickerGrid`, `ColorPickerRow`, and type (read-only when editing).
  - A Gujarati duplicate is rejected.
  - Save returns the created `Category`.
  - All four states (contracts/screens.md EXP-05): loading (edit mode), error with retry, empty (a new blank form with the name focused and the first icon and color preselected), and content (edit, prefilled).
- [X] T086 [P] [US4] Write `test/features/expense/presentation/categories_screen_test.dart`, with scenario tests named `EXP-04 US4-<n>`:
  1. Expense/Income tabs, rows showing avatar, localized name, and this month's total, and a collapsed "Hidden" section.
  2. Tap opens EXP-05 in edit mode.
  5. A default category offers Rename and Hide but not Delete.
  6. Deleting a custom category with no transactions takes effect immediately with a 5-second Undo, and Undo restores it.
  7. Deleting a custom category with transactions opens the replacement sheet (same type only, self excluded, showing "Move {count} transactions to …"). Confirming moves the transactions and removes the category, with no undo.
  8. A hidden category is absent from the EXP-02 grid, but existing rows still show it.
  9. Drag reorder persists after a restart (`restartTestApp`). A reorder failure reverts and shows an error.

  Edge case "Renamed default category": rename `expense_cat_food` to "Meals". Then EXP-04, the EXP-02 grid, and an EXP-01 row show "Meals" under `en`, `hi`, and `gu`, and the stored name is the plain text "Meals". A hidden-but-not-renamed default keeps showing its translated name.

  Also cover the empty, error, and loading states, and that the FAB opens EXP-05 for the current tab's type.
- [X] T087 [P] [US4] Write `test/features/expense/presentation/categories_controller_test.dart` (the reorder optimistic update and revert, `toggleHidden` with undo, and the `delete` branching on `transactionCount`), plus `category_form_controller_test.dart`.
- [X] T088 [P] [US4] Add to `test/features/expense/presentation/transaction_form_screen_test.dart`: `EXP-02 US1-3 "+ New" opens EXP-05, and the created category is selected when the sheet closes`. It depends on T091.

### Implementation for User Story 4

- [X] T089 [US4] Add the EXP-04/05 strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Titles: `expense_categoriesTitle` "Categories", `expense_newCategoryTitle` "New category", `expense_editCategoryTitle` "Edit category".
  - Hidden section and actions: `expense_hiddenSection` "Hidden", `expense_hide` "Hide", `expense_unhide` "Show again", `expense_rename` "Rename".
  - Delete: `expense_deleteCategory` "Delete category", `expense_categoryDeleted` "Category deleted".
  - Replacement sheet: `expense_moveTitle` "Choose a new category", `expense_moveBody` "{count, plural, one{Move 1 transaction to the category you choose.} other{Move {count} transactions to the category you choose.}}", `expense_moveConfirm` "Move and delete".
  - Name field: `expense_categoryName` "Name", `expense_nameLimit` "Up to 30 characters".
  - Name errors: `expense_errNameRequired` "Enter a name", `expense_errNameTooLong` "Names can be up to 30 characters", `expense_errNameDuplicate` "A category with this name already exists", `expense_errNameReserved` "Choose a different name".
  - Pickers and type: `expense_icon` "Icon", `expense_color` "Color", `expense_type` "Type", `expense_saveCategory` "Save category".
  - Reorder: `expense_reorderHandle` "Drag to reorder", `expense_reorderError` "Couldn't save the new order. Try again.".
- [X] T090 [US4] Implement `lib/features/expense/domain/usecases/validate_category_name.dart` (`ValidateCategoryName(DefaultNameCatalog)`, `call(name, type, existing: List<Category>, editingId?)`) to pass T084. Normalize with trim, collapse internal whitespace, and `toLowerCase()`.
- [X] T091 [US4] Create `lib/features/expense/presentation/controllers/category_form_state.dart` + `category_form_controller.dart` (family `CategoryFormArgs(type, id?)`), and `lib/features/expense/presentation/widgets/category_sheet.dart` (EXP-05, `AppBottomSheet`):
  - Name `TextField` (max 30 with counter, inline error).
  - `IconPickerGrid`, `ColorPickerRow`.
  - Type shown read-only when editing.
  - Sticky "Save category" button.
  - All four states from contracts/screens.md EXP-05.
  - `CategorySheet.show(context, {type, id}) → Future<Category?>`.

  Then wire `CategoryGrid.onNew` in `transaction_form_screen.dart` to open it and call `controller.onCategoryCreated` (T088).
- [X] T092 [P] [US4] Create `lib/features/expense/presentation/widgets/replacement_category_sheet.dart`: `AppBottomSheet` listing same-type, non-deleted categories except the one being deleted, with the `expense_moveBody` count, a destructive "Move and delete" button in the error color, and a cancel action.
- [X] T093 [US4] Create `lib/features/expense/presentation/controllers/categories_state.dart` + `categories_controller.dart` (EXP-04: `tab`, `items` from `watchByType(type, month: MonthPeriod(clock.now()))`, `hiddenExpanded`, `reorder`, `toggleHidden → undo`, `delete`).
- [X] T094 [US4] Create `lib/features/expense/presentation/screens/categories_screen.dart` (EXP-04):
  - `AppScaffold` (`bannerSlot: null`), a `TabBar` for Expense/Income, and a `ReorderableListView` with 48 dp drag handles labelled `expense_reorderHandle`.
  - Rows show avatar, localized name, and `AmountText` month total.
  - A collapsed "Hidden" `ExpansionTile`, and the FAB → `CategorySheet` for the current type.
  - Tap → edit. The long-press menu has Rename, Hide/Show again, and Delete (custom categories only).
  - All 4 states.
- [X] T095 [US4] Register `/expenses/categories` → `CategoriesScreen` in `lib/features/expense/expense_module.dart`, before `:id`.
- [X] T096 [US4] Add EXP-04 (content with a Hidden section expanded, empty Income tab) and EXP-05 (new, duplicate error) golden cases to `test/goldens/expense_screens_golden_test.dart`, each × light/dark × en/gu.
- [X] T097 [US4] Remove the `skip:` from T081 in `test/features/expense/presentation/default_names_localized_test.dart` and make it pass.

**Checkpoint**: Categories are fully manageable, and EXP-02's "+ New" works.

---

## Phase 7: User Story 5 - Track money across accounts (EXP-06, EXP-07) (Priority: P2)

**Goal**: Users manage multiple accounts with derived balances and a total, can archive accounts,
and can jump to a filtered list.

**Independent Test**: Create two accounts with opening balances. Log an expense, an income, and a
transfer between them. Each balance equals opening + income − expense ± transfers, and the total
equals the sum of the non-archived accounts.

### Tests for User Story 5 ⚠️ (write first, must fail)

- [X] T098 [P] [US5] Write `test/features/expense/domain/validate_account_test.dart` for `ValidateAccount`: an empty name after trim → `nameRequired`; longer than 40 → `nameTooLong`; `|openingBalanceMinor| > 99999999900` → `balanceOutOfRange`; negative values within range are accepted.
- [X] T099 [P] [US5] Write `test/features/expense/presentation/accounts_screen_test.dart`, with scenario tests named `EXP-06 US5-<n>`:
  1. Total balance card, then the list (avatar, name, localized type, balance; a negative balance in red **with** a "−" sign), then a collapsed "Archived" section. The FAB opens EXP-07.
  2. A balance shown matches the fake's derived value.
  3. Tap goes to `/expenses?accountId=<id>`, where EXP-01 shows the account filter chip.
  4. The long-press menu has Edit and Archive. Archive shows Undo, and an archived account can be restored from the Archived section.
  5. Delete is offered only when the account has no transactions, with Undo.
  6. An archived account is not offered in EXP-02 pickers.
  8. With only one active account, Archive and Delete are disabled with the helper text "You need at least one active account".

  Also cover the loading, error, and empty states.
- [X] T100 [P] [US5] Write `test/features/expense/presentation/account_sheet_test.dart`, with scenario tests named `EXP-07 US5-7`:
  - The fields: name (required), type `ChipSelector` (Cash, Bank, UPI wallet, Card, Wallet), opening balance through `NumericKeypad` with a +/− toggle (−500 stores −50000), icon, and color.
  - Validation errors are shown inline.
  - Edit is prefilled.
  - A save failure keeps the sheet open.
  - All four states (contracts/screens.md EXP-07): loading (edit mode), error with retry, empty (a new blank form: name focused, type Cash, ₹0 placeholder), and content (edit, prefilled).
- [X] T101 [P] [US5] Write `test/features/expense/presentation/accounts_controller_test.dart` and `account_form_controller_test.dart` (the intents in contracts/screens.md EXP-06/07, and the last-active guard surfaced as a disabled state).

### Implementation for User Story 5

- [X] T102 [US5] Add the EXP-06/07 strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Titles: `expense_accountsTitle` "Accounts", `expense_newAccountTitle` "New account", `expense_editAccountTitle` "Edit account".
  - Total and archived section: `expense_totalBalance` "Total balance", `expense_archivedSection` "Archived".
  - Archive and delete actions: `expense_archive` "Archive", `expense_unarchive` "Restore", `expense_accountArchived` "Account archived", `expense_deleteAccount` "Delete account", `expense_accountDeleted` "Account deleted".
  - Last-active guard: `expense_lastAccountHelp` "You need at least one active account".
  - Fields: `expense_accountName` "Name", `expense_accountType` "Type", `expense_openingBalance` "Opening balance", `expense_negativeToggle` "Balance is negative (for example, a card you owe on)".
  - Save button: `expense_saveAccount` "Save account".
  - Errors: `expense_errAccountNameRequired` "Enter a name", `expense_errAccountNameTooLong` "Names can be up to 40 characters", `expense_errBalanceRange` "Balance must be between −₹99,99,99,999 and ₹99,99,99,999".
- [X] T103 [US5] Implement `lib/features/expense/domain/usecases/validate_account.dart` to pass T098.
- [X] T104 [US5] Create `lib/features/expense/presentation/controllers/account_form_state.dart` + `account_form_controller.dart`, and `lib/features/expense/presentation/widgets/account_sheet.dart` (EXP-07, `AppBottomSheet`):
  - Name `TextField`, type `ChipSelector`.
  - Opening balance through `NumericKeypad`, with a `+/−` `SegmentedButton` that has semantic labels.
  - `IconPickerGrid`, `ColorPickerRow`, and a sticky "Save account" button.
  - All four states from contracts/screens.md EXP-07.
  - `AccountSheet.show(context, {id}) → Future<Account?>`.
- [X] T105 [US5] Create `lib/features/expense/presentation/controllers/accounts_state.dart` + `accounts_controller.dart` (EXP-06: `AccountsData(total, active, archived, canArchiveOrDelete)`, `archive → undo`, `unarchive`, `delete → undo`).
- [X] T106 [US5] Create `lib/features/expense/presentation/screens/accounts_screen.dart` (EXP-06):
  - `AppScaffold` (`bannerSlot: null`), a `SummaryCard` "Total balance" with `AmountText` (kind by sign), and the list of rows (avatar, name, localized type, balance `AmountText`).
  - A collapsed "Archived" `ExpansionTile` and the FAB → `AccountSheet`.
  - Tap → `context.go(Routes.expensesPath(accountId: id))`. The long-press menu has Edit, Archive/Restore, and Delete (only without transactions). The last-active guard disables Archive and Delete with helper text.
  - All 4 states.
- [X] T107 [US5] Register `/expenses/accounts` → `AccountsScreen` in `lib/features/expense/expense_module.dart`, before `:id`.
- [X] T108 [US5] Add EXP-06 (content with a negative balance and the Archived section expanded) and EXP-07 (new account, negative opening balance) golden cases to `test/goldens/expense_screens_golden_test.dart`, each × light/dark × en/gu.

**Checkpoint**: Accounts and balances work. EXP-06 → filtered EXP-01 works.

---

## Phase 8: User Story 6 - Expense on Home and quick add (Priority: P3)

**Goal**: The Home tab shows a live Expense card (spent today and this month), and the module's
quick-add action opens EXP-02.

**Independent Test**: Log two expenses today and one earlier this month, plus one income. The card
shows the expense-only totals, and `quickAddAction` opens EXP-02 with type Expense.

### Tests for User Story 6 ⚠️ (write first, must fail)

- [X] T109 [P] [US6] Write `test/features/expense/presentation/expense_dashboard_card_test.dart`, with scenario tests named `DSH-01 Expense card US6-<n>`:
  1. "Spent today" and "This month" are expense-only (income and transfers excluded).
  2. With no transactions, the card shows "Add your first expense", which opens `/expenses/add`.
  3. Tapping the card goes to `/expenses`.
  4. A fake emission updates the values live.
  6. With the Expense module disabled in settings, the card is hidden (Home placeholder loop) and the fake data still exists.

  Also check that the values switch to a new day after `FixedClock` passes midnight and the timer fires, and cover the error state.
- [X] T110 [P] [US6] Add `ExpenseModule quickAddAction` and `routes` tests to `test/features/expense/expense_module_test.dart`:
  - `quickAddAction()` has `labelKey == 'expense_quickAdd'`, its location opens EXP-02 with type Expense (US6-5), and `backupSection() == null`.
  - `seeders` is `[ExpenseDefaultsSeeder]`.
  - Every route path starts with `/expenses`, and the static segments come before `:id`.
  - Rule 5 redirects every expense route to `/home` when the module is disabled (extends `test/app/router/disabled_module_redirect_test.dart`).

### Implementation for User Story 6

- [X] T111 [US6] Add the strings `expense_cardEmpty` "Add your first expense" and `expense_cardTitle` "Expense" (if `modules_expense` doesn't fit), then:
  - Create `lib/features/expense/presentation/controllers/expense_dashboard_controller.dart`. It uses `watchTodayAndMonthSpend(clock.now())` and recomputes at the next local midnight through a `Timer` that is cancelled on dispose.
  - Create `lib/features/expense/presentation/widgets/expense_dashboard_card.dart`, a `ConsumerWidget`:
    - `SummaryCard` with `CategoryAvatar`, title, and two `AmountText` rows. Tap → `context.go('/expenses')`.
    - Empty: an action chip "Add your first expense" → `/expenses/add`.
    - Error: a compact `ErrorState`.
    - No budget bar.
  - Update `lib/features/expense/expense_module.dart`: `dashboardCard` returns `const ExpenseDashboardCard()`, and `quickAddAction()` returns `QuickAddAction(labelKey: 'expense_quickAdd', icon: Icons.add, location: Routes.expenseAddPath(type: 'expense'))`. Keep `backupSection() => null` with a comment "Stub until T3.2". Update the module's doc comment.
- [X] T112 [US6] Create `integration_test/expense_flow_test.dart` (dev flavor, real app via `productionOverrides()`):
  1. Fresh launch, then complete onboarding with Skip.
  2. Expenses tab → FAB → type 250 → Food → Save.
  3. Check EXP-01 shows ₹250 under "Today".
  4. Check the Home card shows ₹250 for today and for the month.
  5. Restart the app and check the entry is still there.

  Add a step to `quickstart.md` §7 noting that the Reports part arrives in T1.7.

**Checkpoint**: All six stories are complete.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [ ] T113 Generate the golden baselines on Linux (WSL or CI) for `test/goldens/expense_screens_golden_test.dart`, the changed `PeriodSelector`, and the new `IconPickerGrid`/`ColorPickerRow`/`PeriodPickerSheet` goldens using `flutter test --tags golden --update-goldens`, and commit the PNGs. If Linux is still unavailable, record this as an open item next to feature 001 open item 1, and never commit goldens rendered on Windows.
- [X] T114 [P] Extend `test/a11y/font_scale_test.dart` with EXP-01..EXP-07 and the Home Expense card. For each: 200% font scale, 360 dp width, en/hi/gu, no overflow exceptions, every tappable control ≥ 48×48 dp, every `IconButton` with a tooltip or semantic label, and amounts read as currency (the `AmountText` semantics label) (FR-036, SC-008).
- [ ] T115 [P] Add a debug-only "Seed 10,000 transactions" action to `lib/features/expense/presentation/screens/transactions_screen.dart`, behind `kDebugMode` in the overflow menu. It calls `TransactionRepository.debugSeed(int count)` (in contracts/repositories.md), implemented in `drift_transaction_repository.dart` with batched inserts and a no-op in the fake, and is excluded from release by `kDebugMode`. Test that it's absent when `kDebugMode` is false, using an injectable flag.
- [ ] T116 Run the coverage check: `flutter test --exclude-tags golden --coverage`, then confirm with `lcov` or a summary script that `lib/features/expense/domain/` and `lib/features/expense/data/` are each ≥ 80% (Constitution IV). Add tests for any gaps.
- [ ] T117 Run quickstart.md §5–§6. Then:
  - Record the perf test timings.
  - Build `flutter build apk --flavor prod --release --split-per-abi` and record each ABI's size against the 25 MB budget and the 21.0 MB arm64 baseline.
  - On a physical device, record the profile-mode 60 fps scroll at 10,000 rows (SC-005) and the camera receipt flow, or list them as open items.
- [X] T118 Run the §15.10 design review checklist for EXP-01..EXP-07 and the Home Expense card, and record the results in `specs/002-expense-core/checklists/design-review.md` (one table per screen, every item with evidence: a test name or a file). The "light and dark goldens" item passes only after T113.
- [X] T119 Run all quality gates from quickstart.md §1 and fix everything:
  - `dart run build_runner build --delete-conflicting-outputs`
  - `flutter analyze` (zero issues)
  - `dart format --set-exit-if-changed .`
  - `flutter test --exclude-tags golden`
  - `flutter test integration_test --flavor dev` on an emulator
- [ ] T120 Close out the docs:
  - Mark T1.1–T1.4 done in the `docs/spec.md` §14 checklist.
  - Add Expense conventions to `docs/CLAUDE.md` "How to work": expense fakes in `test/features/expense/fakes.dart`, bindings only in `main.dart`, and `rootMessengerKey` for Undo after a pop.
  - Write `specs/002-expense-core/summary.md` covering: files changed, tests added, gate and checklist results, decisions made during implementation, and open items. The open items include: goldens on Linux, Hindi/Gujarati native-speaker review, device fps and camera checks, and backup of `transactions` + `receipts/` in T3.2.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none. T001 (the spec update) must be done before any code that implements
  Q2–Q5 or R5.
- **Foundational (Phase 2)**: depends on Setup and **blocks all stories**. Inside it:
  - T005→T006.
  - T015–T018 → T019–T022.
  - T023→T024→T025.
  - T027–T030 → T031–T038.
  - T039–T041.
  - T042→T043, and T044→T045.
- **US1 (Phase 3)** and **US2 (Phase 4)**: both start after Foundational. They share
  `expense_module.dart` and `tool/l10n/phase0_strings.py`, so the tasks that edit those files
  (T052, T058, T069, T077) run one at a time.
- **US3 (Phase 5)**: starts after Foundational. It is test-heavy and independent of US1/US2,
  except T081, which is un-skipped in T097.
- **US4 (Phase 6)**: after Foundational. T088 and T091's EXP-02 wiring need T057 (US1).
- **US5 (Phase 7)**: after Foundational. US5-3 (the filtered EXP-01) needs T073 (US2).
- **US6 (Phase 8)**: after Foundational. T112 (integration) needs US1 + US2.
- **Polish (Phase 9)**: after all stories.

### User Story Dependencies

| Story | Hard dependency | Soft (integration only) |
| --- | --- | --- |
| US1 EXP-02 | Foundational | "+ New" → EXP-05 is completed by US4 (T088, T091) |
| US2 EXP-01/03 | Foundational | Duplicate and Edit open EXP-02 (US1). Their tests assert the route location only |
| US3 Upgrade | Foundational (T024) | T081 needs the US1/US4 screens |
| US4 Categories | Foundational | EXP-02 wiring (US1) |
| US5 Accounts | Foundational | Account tap → EXP-01 filter (US2) |
| US6 Home card | Foundational | Integration test needs US1 + US2 |

### Within Each User Story

Tests come first and must fail. Then strings, then controller and state, then widgets, then the
screen, then routes, then goldens.

---

## Parallel Examples

**Foundational**, after T015–T018:

```text
T019 amount_entry_test.dart   T020 validate_transaction_test.dart   T022 fold_ledger
T026 transactions_table_test  T027 transactions_dao   T028 categories_dao   T029 accounts_dao   T030 mappers
T005/T006 period   T007 clock   T008 root keys   T009 UndoSnackBar   T010 name catalog   T011 sharer   T012–T014 icons/pickers
```

**User Story 1**:

```text
T048 (then T049, T050 in the same file) | T051 controller test
T054 category_grid   T055 receipt_field   T056 account/occurred chips
```

**User Story 2**:

```text
T061 period selector tests | T062 (then T064) list tests | T063 (then T065) detail tests | T066 controller test
T072 list widgets   T075 receipt_viewer
```

**User Story 3**: T079, T080, T081, and T082 are all [P] (different files).

**User Story 4**: T084, T085, T086, and T087 are in parallel, then T092 alongside T090.

**User Story 5**: T098, T099, T100, and T101 are in parallel.

---

## Implementation Strategy

### MVP first

1. Phase 1, then Phase 2. The data is safe and tested.
2. Phase 3 (US1, EXP-02). **Stop and validate**: transactions can be logged.
3. Phase 4 (US2, EXP-01/03). **Stop and validate**: this is the first user-visible usable tracker,
   and it replaces the Expenses placeholder.
4. Phase 5 (US3): the upgrade-safety proof. Run it before any build goes to a device with feature 001 data.

### Incremental delivery

After the MVP comes US4 (categories), then US5 (accounts), then US6 (Home card + integration),
then Polish. Each phase ends at a checkpoint with all gates green.

Following Constitution I ("one task at a time: plan → implement → test → summarize → stop for review"),
it's natural to stop for review after Phase 2, Phase 4 (T1.2 + T1.3), Phase 7 (T1.4), and Phase 9.

---

## Notes

- [P] means a different file with no dependency on an incomplete task. Tasks that edit
  `tool/l10n/phase0_strings.py`, `expense_module.dart`, `routes.dart`, `test_app.dart`, or a test
  file shared with another task are never [P] with each other.
- Every task ID maps to a Screen ID or a data-model section in its description, for traceability.
- Commit after each task or logical group, with the Screen ID in the commit message.
