# Data Model: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Feature**: [spec.md](spec.md) · **Research**: [research.md](research.md) · **Date**: 2026-10-15

Database: `AppDatabase` (Drift, single SQLite file), **schema v2 → v3**. Conventions are the same
as in feature 002:
- `TEXT` UUID v4 primary key `id`.
- `createdAt` and `updatedAt` in UTC epoch ms, and nullable `deletedAt` (soft delete).
- Money as `INTEGER` paise.
- Enums stored with `intEnum`, and **append-only**.

## 1. Schema versions

| Version | Feature | Tables |
| --- | --- | --- |
| 1 | 001-foundation | `settings`, `categories`, `accounts` |
| 2 | 002-expense-core | + `transactions` |
| **3** | **003-budgets-recurring-reports** | + `recurring_rules`, `budgets`, `unlocks`; `transactions` rebuilt with a foreign key on `recurring_rule_id` |

**Migration 2 → 3** (`stepByStep.from2To3`, research R3), in this order:
1. Create `recurring_rules` and index `recurring_rules_due`.
2. Create `budgets` and indexes `budgets_month` and `budgets_month_category_unique` (partial,
   unique).
3. Create `unlocks` and index `unlocks_feature`.
4. With `foreign_keys = OFF`: `alterTable(TableMigration(transactions))`, which copies all rows
   unchanged. Then make sure `transactions_occurred`, `transactions_category_occurred`, and
   `transactions_account_occurred` exist, create `transactions_rule`, run `PRAGMA
   foreign_key_check` (it must return nothing), and set `foreign_keys = ON`.

v1 databases run `from1To2` and then `from2To3`. The settings rows (including seed markers) are not
touched.

## 2. Enums

| Enum | File | Values (index order, append-only) | Status |
| --- | --- | --- | --- |
| `Frequency` | `features/expense/domain/enums.dart` | daily, weekly, monthly, yearly | **new** |
| `UnlockSource` | `core/feature_gate/domain/unlock.dart` | rewardedAd, purchase | **new** |
| `TxnType`, `PaymentMode` | expense enums | unchanged | existing |

`FeatureKey` is **not** an `intEnum`. It is a value class stored as TEXT (research R13):
`exportCsv`, `exportPdf`, `advancedReports`, `adFreeDay`, `streakFreeze`, `premiumTheme_<name>`.

## 3. Tables

### 3.1 `recurring_rules` (new, `features/expense/data/tables/recurring_rules_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| template_type | INTEGER (`TxnType`) | no | |
| amount_minor | INTEGER | no | `BETWEEN 1 AND 99999999900` |
| account_id | TEXT | no | FK `accounts(id)` |
| to_account_id | TEXT | yes | FK `accounts(id)`, transfers only |
| category_id | TEXT | yes | FK `categories(id)`, null for transfers |
| payment_mode | INTEGER (`PaymentMode`) | no | |
| note | TEXT | yes | `length ≤ 200` |
| frequency | INTEGER (`Frequency`) | no | |
| interval | INTEGER | no | default 1, `CHECK (interval >= 1)` |
| anchor_at | INTEGER | no | UTC ms of the first occurrence (research R8). Not in spec §4, added for month-end correctness |
| next_run_at | INTEGER | no | UTC ms. Only moves forward (R9) |
| end_at | INTEGER | yes | UTC ms, inclusive. `CHECK (end_at IS NULL OR end_at >= anchor_at)` |
| is_active | INTEGER (bool) | no | false = paused or ended |
| created_at, updated_at | INTEGER | no | |
| deleted_at | INTEGER | yes | soft delete |

- Table CHECK (the same type shape as `transactions`): a transfer has `to_account_id`, no category,
  and different accounts. Expense and income have a category and no `to_account_id`.
- Index `recurring_rules_due (is_active, next_run_at)`.

### 3.2 `budgets` (new, `features/expense/data/tables/budgets_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| category_id | TEXT | yes | FK `categories(id)`. NULL = Overall |
| month_key | TEXT | no | `yyyy-MM`, `GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]'` |
| limit_minor | INTEGER | no | `BETWEEN 1 AND 99999999900` |
| rollover | INTEGER (bool) | no | "Repeat every month" |
| alert80_sent_at | INTEGER | yes | UTC ms |
| alert100_sent_at | INTEGER | yes | UTC ms. `CHECK (alert100_sent_at IS NULL OR alert80_sent_at IS NOT NULL)` |
| created_at, updated_at | INTEGER | no | |
| deleted_at | INTEGER | yes | soft delete |

- `budgets_month (month_key)`.
- `budgets_month_category_unique` on `(month_key, IFNULL(category_id, '')) WHERE deleted_at IS
  NULL` (R4): one live budget per category per month, and one Overall budget per month.

### 3.3 `unlocks` (new, `core/database/tables/unlocks_table.dart`)

| Column | Type | Null | Constraint / note |
| --- | --- | --- | --- |
| id | TEXT | no | PK |
| feature_key | TEXT | no | `FeatureKey.storageKey` |
| expires_at | INTEGER | yes | UTC ms. NULL = permanent |
| source | INTEGER (`UnlockSource`) | no | |
| created_at, updated_at | INTEGER | no | |
| deleted_at | INTEGER | yes | `revoke` soft-deletes (for example a refunded purchase in T4.5) |

Index `unlocks_feature (feature_key)`.

### 3.4 `transactions` (changed)

The only change is that `recurring_rule_id` now has `REFERENCES recurring_rules(id)`, plus the new
index `transactions_rule (recurring_rule_id)`. All other columns, CHECKs, and indexes are unchanged.

A transaction is **linked** when `recurring_rule_id IS NOT NULL`. That covers a rule's first
occurrence and every generated row.

### 3.5 `settings` keys (key-value, no schema change)

| Key | Type | Default | Use |
| --- | --- | --- | --- |
| `notificationsEnabled` | bool | true | master switch (SET-01 toggle in T3.1) |
| `budgetAlertsEnabled` | bool | true | Budget alerts setting (SET-01 toggle in T3.1) |
| `debugUnlockAll` | bool | false | dev-flavor switch. Ignored in prod (R13) |
| `latestSeenAt` | int (UTC ms) | null | FeatureGate clock-rollback guard. Only increases |
| `module.expense.budgetRolloverMonth` | string `yyyy-MM` | null | rollover done marker (R7) |

The first four are added to `AppSettings` and `SettingsCodec`. The last one is written through the
new `readModuleState/writeModuleState`.

## 4. Domain entities (pure Dart, `freezed`)

| Entity | Location | Fields |
| --- | --- | --- |
| `Budget` | `expense/domain/entities/budget.dart` | `id`, `categoryId?`, `monthKey`, `limitMinor`, `rollover`, `alert80SentAt?`, `alert100SentAt?`, `createdAt`, `updatedAt` |
| `BudgetDraft` | same | `categoryId?`, `monthKey`, `limitMinor`, `rollover` |
| `BudgetStatus` (derived) | `expense/domain/entities/budget_status.dart` | `budget`, `category?` (view: name, icon, color, hidden), `spentMinor`, `remainingMinor`, `percent`, `level` (under/warning/over), `daysLeft?`, `perDayLeftMinor?`, `monthPhase` (past/current/future) |
| `BudgetsOverview` | same | `monthKey`, `overall: BudgetStatus?`, `categories: List<BudgetStatus>` (sorted by percent desc, then name), `withoutBudget: List<CategoryView>` (non-hidden expense categories with no budget) |
| `RecurringRule` | `expense/domain/entities/recurring_rule.dart` | `id`, template (`type`, `amountMinor`, `accountId`, `toAccountId?`, `categoryId?`, `paymentMode`, `note?`), `frequency`, `interval`, `anchorAt`, `nextRunAt`, `endAt?`, `isActive`; derived `isEnded` |
| `RecurringRuleView` | same | rule plus category/account display fields and a `staleReference` flag (archived account or hidden category → warning line) |
| `RepeatSettings` | `expense/domain/entities/repeat_settings.dart` | `frequency`, `endAt?` (from EXP-02's Repeat section) |
| `ExpenseBreakdown` | `expense/domain/entities/expense_breakdown.dart` | `byCategory: Map<String, int>`, `byAccount: Map<String, int>`, `byPaymentMode: Map<PaymentMode, int>`, `totalExpenseMinor` |
| `BudgetAlert` | `expense/domain/entities/budget_alert.dart` | `budgetId`, `monthKey`, `categoryId?`, `threshold` (80/100), `percent` |
| `Unlock` | `core/feature_gate/domain/unlock.dart` | `id`, `featureKey`, `expiresAt?`, `source`, `createdAt` |

`Transaction` and `TransactionView` (feature 002) already carry `recurringRuleId`. `TransactionView`
gains `isRecurring` (derived) for the EXP-01 icon.

## 5. Validation rules

| Rule | Where | Spec |
| --- | --- | --- |
| Budget limit 1 … 99,99,99,999.00 paise | `validateBudget` use case + CHECK | US1 s5, FR-011 |
| One live budget per slot (category or Overall, month) | unique index → `BudgetSlotTaken` | US1 s6 |
| EXP-09 hides categories that already have a budget for the month (new mode) | controller | US1 s6 |
| Repeat end date ≥ the entry's date | `validateTransaction` (extended) | US3 s3 |
| Repeat allowed only when the entry is not linked to a rule | controller + repository guard | FR-021 |
| Rule template obeys the same type-shape and amount rules as a transaction | shared validator + CHECK | FR-002 |
| `interval ≥ 1` (always 1 from the UI) | CHECK | spec Assumptions |

## 6. State transitions

**Budget alert markers** (per budget, per month):

```text
none ──spent ≥ 80%──▶ 80 sent ──spent ≥ 100%──▶ 80+100 sent
none ──spent ≥ 100% (one save)──▶ 80+100 sent   (only the 100% notification)
limit saved: clear 100 if spent < limit; clear 80 if spent·100 < limit·80
```

**Recurring rule**:

```text
            create (Repeat on)
                  │
                  ▼
   ┌────────── active ◀──────── resume (next = first occurrence after now)
   │   pause │    │ generator: next > endAt
   │         ▼    ▼
   │      paused  ended (is_active=false, next > endAt) ──edit end date──▶ active
   │         │
   └─delete──┴──▶ deleted (soft; Undo → previous state)
```

- Generated transactions are independent. Editing or deleting the rule never changes them.
- Rule-edit save: template and schedule change, `anchorAt` = the chosen date,
  `nextRunAt` = first occurrence ≥ max(chosen, now).

**Unlock**: `granted` → (`expiresAt ≤ effectiveNow`) → `expired` (row kept). `revoke` → deleted.
`effectiveNow` never goes backwards.

## 7. Derived values (never stored)

- Budget spent, remaining, percent, level, days left, per-day left (research R5).
- Account balances (feature 002), unchanged. Generated rows count like any other row.
- Report figures: ledger (feature 002) and breakdown (R11) → view models (R12).
- `RecurringRule.isEnded = !isActive && endAt != null && nextRunAt > endAt`.
