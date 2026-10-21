# Data Model: Expense Core (Phase 1, T1.1–T1.4)

**Feature**: [spec.md](spec.md) · **Research**: [research.md](research.md) · **Date**: 2026-10-14

Database: `AppDatabase` (Drift, single SQLite file), **schema v1 → v2**. Conventions (Constitution
III, spec §4):
- `TEXT` UUID v4 primary key `id`.
- `createdAt` and `updatedAt` in UTC epoch ms.
- Nullable `deletedAt` on every user table.
- Money as `INTEGER` minor units (paise).
- Enums stored as their `int` index through Drift `intEnum`. Enums are **append-only**: never
  reorder or remove values.

## 1. Schema versions

| Version | Feature | Tables |
| --- | --- | --- |
| 1 | 001-foundation | `settings`, `categories`, `accounts` |
| **2** | **002-expense-core** | + `transactions` (and 3 indexes) |

**Migration 1 → 2** (`stepByStep.from1To2`, research R2):

1. `CREATE TABLE transactions …` from the frozen v2 snapshot.
2. `CREATE INDEX transactions_occurred ON transactions(occurredAt)`.
3. `CREATE INDEX transactions_category_occurred ON transactions(categoryId, occurredAt)`.
4. `CREATE INDEX transactions_account_occurred ON transactions(accountId, occurredAt)`.

No existing row is read or written. `settings` (including `seed.expense.defaults.v1`),
`categories`, and `accounts` are untouched, so the seeder never runs again (FR-006, SC-006).

## 2. Enums (`features/expense/domain/enums.dart`)

| Enum | Values (index order, append-only) | Status |
| --- | --- | --- |
| `CategoryType` | expense, income | existing |
| `AccountType` | cash, bank, upi, card, wallet | existing. Displayed as Cash, Bank, UPI wallet, Card, Wallet |
| `TxnType` | expense, income, transfer | **new** |
| `PaymentMode` | cash, upi, card, netBanking, other | **new** |

`AccountType → default PaymentMode` (research R7, clarification Q4): cash→cash, bank→netBanking,
upi→upi, card→card, wallet→other.

## 3. Tables

### 3.1 `transactions` (new, `features/expense/data/tables/transactions_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK, UUID v4 |
| type | INTEGER (`TxnType`) | no | |
| amountMinor | INTEGER | no | `CHECK (amountMinor BETWEEN 1 AND 99999999900)`. ₹0.01 … ₹99,99,99,999.00. Always positive; the sign comes from `type` |
| accountId | TEXT | no | FK → `accounts(id)`. Source account |
| toAccountId | TEXT | yes | FK → `accounts(id)`. Transfer only |
| categoryId | TEXT | yes | FK → `categories(id)`. Null for transfer |
| paymentMode | INTEGER (`PaymentMode`) | no | |
| note | TEXT | yes | `CHECK (note IS NULL OR length(note) <= 200)`. Blank input is stored as NULL |
| occurredAt | INTEGER | no | UTC ms, chosen by the user |
| receiptPath | TEXT | yes | **Relative** path `receipts/<uuid>.jpg` (R8) |
| recurringRuleId | TEXT | yes | Always NULL in this feature. No FK until T1.6 (R3) |
| createdAt | INTEGER | no | UTC ms |
| updatedAt | INTEGER | no | UTC ms |
| deletedAt | INTEGER | yes | Soft delete |

Table-level check (R3):

```text
CHECK (
  (type = 2 AND toAccountId IS NOT NULL AND categoryId IS NULL AND toAccountId <> accountId)
  OR (type IN (0, 1) AND categoryId IS NOT NULL AND toAccountId IS NULL)
)
```

Indexes: `(occurredAt)`, `(categoryId, occurredAt)`, `(accountId, occurredAt)` (spec §4). The
default list order is `occurredAt DESC, createdAt DESC, id DESC`. The order is total, so Undo
restores a row to the same position (R4).

### 3.2 `categories` (existing, unchanged schema)

`id, name (1–40), type (CategoryType), iconKey, colorHex (#RRGGBB), isDefault, isArchived, sortOrder, createdAt, updatedAt, deletedAt`.
Index `categories_type_sort (type, sortOrder)`.

| Rule | Where enforced |
| --- | --- |
| `isArchived` means **hidden**. Excluded from EXP-02 for new entries, shown in EXP-04's "Hidden" section, still displayed on existing transactions | repository queries |
| Names entered in EXP-05: 1–30 chars after trim (storage allows 40) | `ValidateCategoryName` |
| Unique per type: normalized, case-insensitive, across custom names, renamed defaults, and **all 3 translations** of non-renamed defaults (clarification Q5, R9) | `ValidateCategoryName` |
| Names must not look like an ARB key (`^(expense\|income)_(cat\|account)_`) | `ValidateCategoryName` |
| A default is "renamed" when `isDefault && name != <its original key>`. The original key is recoverable because a default's untouched name **is** its key | derived |
| `isDefault` rows are never soft-deleted | repository (`deleteCategory` throws `CategoryDeleteNotAllowed`) |
| Deleting a custom category with transactions requires `replacementId` (same type, not deleted, ≠ id). Moving the transactions and soft-deleting the category happen in **one** DB transaction | `CategoryRepository.deleteCategory` |
| New categories get `sortOrder = max(sortOrder of type) + 1` | repository |
| Reorder rewrites `sortOrder` for the whole type in one transaction | repository |

### 3.3 `accounts` (existing, unchanged schema)

`id, name (1–40), type (AccountType), openingBalanceMinor (may be negative), iconKey, colorHex, isArchived, sortOrder, createdAt, updatedAt, deletedAt`.

| Rule | Where enforced |
| --- | --- |
| Name required, 1–40 chars after trim (no uniqueness rule in the spec) | `ValidateAccount` |
| `openingBalanceMinor` within ±99,99,99,999.00 | `ValidateAccount` |
| An account referenced by any non-deleted transaction (as `accountId` or `toAccountId`) cannot be deleted, only archived | repository (`AccountDeleteNotAllowed.hasTransactions`) |
| At least one non-deleted, non-archived account must remain: archive or delete of the last one is refused (clarification Q3) | repository (`AccountDeleteNotAllowed.lastActive` / `AccountArchiveNotAllowed`) in a DB transaction |
| Archived accounts are excluded from EXP-02 pickers for new entries. In edit mode the entry's current (archived) account stays selectable so editing never silently changes it | repository and EXP-02 controller |

**Derived balance** (never stored, FR-009):

```text
balance(a) = a.openingBalanceMinor
           + Σ amount  where type=income   and accountId=a
           − Σ amount  where type=expense  and accountId=a
           − Σ amount  where type=transfer and accountId=a
           + Σ amount  where type=transfer and toAccountId=a
           (all over transactions with deletedAt IS NULL)
total = Σ balance(a) over non-deleted, non-archived accounts
```

Computed by one aggregate SQL query per stream emission, using `(accountId, occurredAt)`. The
`toAccountId` side scans only transfers.

## 4. Domain entities (`features/expense/domain/entities/`, pure Dart, `freezed`)

| Entity | Fields | Notes |
| --- | --- | --- |
| `Transaction` | id, type, amountMinor, accountId, toAccountId?, categoryId?, paymentMode, note?, occurredAt (DateTime UTC), receiptPath?, recurringRuleId?, createdAt, updatedAt, deletedAt? | `isTransfer`, `signedAmountMinor` (income +, expense −, transfer 0 for totals) |
| `TransactionDraft` | type, amountMinor?, accountId?, toAccountId?, categoryId?, paymentMode, note, occurredAt, receiptPath? | Form input. Becomes a `Transaction` on save |
| `TransactionView` | transaction + category (id, name, isDefault, iconKey, colorHex)? + account + toAccount? | Read model for rows and detail. The name is still raw (key or text), and the UI localizes it |
| `Category` | id, name, type, iconKey, colorHex, isDefault, isHidden, sortOrder | `isHidden` maps to the `isArchived` column |
| `CategoryWithStats` | category, monthTotalMinor, usageCount | EXP-04 rows, EXP-02 ordering |
| `Account` | id, name, type, openingBalanceMinor, iconKey, colorHex, isArchived, sortOrder | |
| `AccountWithBalance` | account, balanceMinor, hasTransactions | EXP-06 |
| `TxnQuery` | period (`Period`), search?, matchingCategoryIds, categoryIds, accountIds, paymentModes, types, minAmountMinor?, maxAmountMinor? | Session filter (FR-020). `isFiltered` |
| `PeriodLedger` | incomeMinor, expenseMinor, netMinor, dayTotals: Map<String dateKey, DayTotal> | Folded from the ledger stream (R4) |
| `DayTotal` | incomeMinor, expenseMinor, netMinor | Header shows `netMinor` with sign |
| `TodayAndMonthSpend` | todayMinor, monthMinor, hasAnyTransaction | Home card (FR-030) |

`Period` (`core/utils/period.dart`, R13) is shared and pure Dart.

## 5. Validation (`features/expense/domain/usecases/`)

| Use case | Rules → error enum | Spec |
| --- | --- | --- |
| `ValidateTransaction` | amount missing or 0 → `amountRequired`; > 99,99,99,999.00 → `amountTooLarge`; keypad error (malformed, too many decimals, ÷0, negative) → `amountInvalid`; expense/income without category → `categoryRequired`; transfer without `toAccountId` → `toAccountRequired`; from == to → `sameAccount`; note > 200 → `noteTooLong` | FR-011, edge cases |
| `ValidateCategoryName` | empty → `required`; > 30 → `tooLong`; key-like → `reserved`; duplicate (R9) → `duplicate` | FR-025, Q5 |
| `ValidateAccount` | empty name → `nameRequired`; > 40 → `nameTooLong`; balance out of range → `balanceOutOfRange` | FR-028 |

Calculator results are rounded half-up to whole paise by the existing `KeypadExpression.evaluateToMinor`
(spec Assumption). A negative result is an error for transactions. For opening balances, the sign
comes from a separate +/− toggle in EXP-07, and the keypad value stays non-negative.

## 6. State transitions

**Transaction**

```text
(draft) --save--> active --softDelete--> deleted --undelete--> active
active --edit(save)--> active'   (undo: restore(snapshot) → active)
```

**Category**

```text
active ⇄ hidden                            (setHidden; defaults and customs)
custom active|hidden --delete (no txns)--> deleted --undelete--> previous state
custom active|hidden --delete(replacement)--> deleted   (txns.categoryId := replacement; no undo)
default: delete not allowed
```

**Account**

```text
active ⇄ archived        (archive refused if it is the last active account)
active|archived --delete (no txns, not last active)--> deleted --undelete--> previous state
with transactions: delete not allowed
```

## 7. Seed data (existing, unchanged)

`ExpenseDefaultsSeeder` (`expense.defaults.v1`), run exactly once by `SeedRunner`:
- 12 expense categories (`expense_cat_<slug>`: food, groceries, transport, fuel, shopping, bills,
  rent, health, education, entertainment, travel, other).
- 5 income categories (`income_cat_<slug>`: salary, business, gift, interest, other).
- One Cash account (`expense_account_cash`, type cash, opening 0).

This feature adds only a regression test that seeding after the v1→v2 upgrade inserts nothing.

## 8. Files on disk

| Path | Content | Lifecycle |
| --- | --- | --- |
| `<appDocuments>/receipts/<uuid>.jpg` | JPEG, longest side ≤ 1280 px, quality 80, no EXIF | Written on pick. Referenced by `receiptPath`. Pruned when unreferenced by any row (including soft-deleted) and older than 24 h (R8) |
