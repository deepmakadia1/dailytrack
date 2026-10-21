# Data Model: Foundation (Phase 0)

**Feature**: `001-foundation` · **Schema version**: 1 · **Source**: `docs/spec.md` §4, spec FR-011, FR-025

General rules from §4 and Constitution III:
- Every table has a `TEXT` UUID primary key `id` (except `settings`, which uses `key`), plus
  `createdAt` and `updatedAt`. All timestamps are UTC epoch milliseconds stored as `int`.
- User data tables have a nullable `deletedAt` for soft delete.
- Money is stored as `int` minor units. `double` is never used.

## 1. `settings` (core): key-value store

| Column | Type | Constraints | Notes |
| --- | --- | --- | --- |
| key | text | PK | One of the keys below |
| value | text | not null | JSON-encoded value |
| updatedAt | int | not null | UTC ms |

`settings` is not user content in the soft-delete sense. Rows are overwritten, never soft-deleted.

**Keys used or defined in Phase 0** (defaults are applied when a key is missing or unreadable;
see the spec edge case "Settings value unreadable or corrupted"):

| Key | JSON type | Default | Written by |
| --- | --- | --- | --- |
| `locale` | string \| null (`en`/`hi`/`gu`) | null → device locale if supported, else `en` | SYS-02 |
| `currencyCode` | string (ISO 4217) | `INR` | SYS-02 |
| `themeMode` | string (`system`/`light`/`dark`) | `system` | (T3.1) |
| `selectedTheme` | string | `default` | (T3.1/T4.4) |
| `firstDayOfWeek` | int (1=Mon … 7=Sun) | 1 | (T3.1) |
| `lockEnabled` | bool | false | (T3.1); fakes in tests |
| `biometricEnabled` | bool | false | (T3.1) |
| `enabledModules` | list<string>, ordered | `["expense","habit"]` | SYS-02, SET-06 |
| `moduleOrder` | list<string> | registry order | SET-06 |
| `onboardingDone` | bool | false | SYS-02 |
| `adConsentStatus` | string \| null | null | (T4.1) |
| `lastBackupAt` | int \| null | null | (T3.2) |
| `removeAdsPurchased` | bool | false | (T4.5); fakes in tests |
| `seed.<seederId>` | int (UTC ms when seeded) | absent | SeedRunner (FR-025) |

`moduleOrder` holds every registered module in the user's order. `enabledModules` is the enabled
subset. Tabs and dashboard cards use `moduleOrder` filtered by `enabledModules`. Keeping them
separate means a disabled module keeps its place when it is re-enabled.

**Validation**:
- `enabledModules` must never be empty. The repository rejects an empty write with
  `LastModuleError`, and both SYS-02 and SET-06 show the "at least one module" message.
- Unknown module ids in either list are dropped when read, for example a module removed in a
  future version.
- `locale` must be one of the supported locales, or it is ignored.

**Domain entity** `AppSettings` (freezed, pure Dart, in `core/settings/domain/`) holds typed
fields for all keys above, with defaults. `SettingsRepository` maps between it and the rows.

## 2. `categories` (owned by the expense feature; moved forward from T1.1)

| Column | Type | Constraints | Notes |
| --- | --- | --- | --- |
| id | text | PK (UUID v4) | |
| name | text | not null, 1–40 chars | l10n key when `isDefault` (e.g. `expense_cat_food`), otherwise user text |
| type | int enum `CategoryType` | not null | `expense`, `income` |
| iconKey | text | not null | From the fixed icon set |
| colorHex | text | not null, `#RRGGBB` | From the fixed 16-color set |
| isDefault | bool | not null, default false | Seeded rows only; can be hidden, never deleted |
| isArchived | bool | not null, default false | |
| sortOrder | int | not null | |
| createdAt / updatedAt | int | not null | UTC ms |
| deletedAt | int | nullable | Soft delete |

Index: `(type, sortOrder)`.

## 3. `accounts` (owned by the expense feature; moved forward from T1.1)

| Column | Type | Constraints | Notes |
| --- | --- | --- | --- |
| id | text | PK (UUID v4) | |
| name | text | not null, 1–40 chars | l10n key for the seeded Cash account (`expense_account_cash`) |
| type | int enum `AccountType` | not null | `cash`, `bank`, `upi`, `card`, `wallet` |
| openingBalanceMinor | int | not null, default 0 | Minor units |
| iconKey / colorHex | text | not null | |
| isArchived | bool | not null, default false | |
| sortOrder | int | not null | |
| createdAt / updatedAt | int | not null | UTC ms |
| deletedAt | int | nullable | Soft delete |

Enums are stored as ints through Drift `intEnum`. **Enum values are append-only.** Never reorder
or remove them, because the stored index must stay stable across versions and backups.

## 4. Seed data (FR-025, research R7)

Run once by `SeedRunner` under the key `seed.expense.defaults.v1`, inside a single transaction.

- **Expense categories (12)**, in this `sortOrder`: food, groceries, transport, fuel, shopping,
  bills, rent, health, education, entertainment, travel, other.
- **Income categories (5)**: salary, business, gift, interest, other.
- **Account (1)**: Cash, `type = cash`, `openingBalanceMinor = 0`, `sortOrder = 0`.

All seeded categories have `isDefault = true`. Names are the keys
`expense_cat_<slug>` / `income_cat_<slug>` / `expense_account_cash`, with translations in all
three ARB files.

**Invariant tested**: after any number of bootstraps there are exactly 12 + 5 default categories
and 1 seeded Cash account.

## 5. Non-persisted domain concepts

- **TrackerModule**: id (`expense`, `habit`), name l10n key, icon, routes, dashboard card,
  quick-add action, backup section, `onEnable`/`onDisable`, and seeders. See
  [contracts/tracker_module.md](contracts/tracker_module.md).
- **ModuleRegistry**: the ordered list of registered `TrackerModule`s, plus the static "Coming
  soon" entries (water, period), which are display-only.
- **AppTokens**: a theme extension. See [contracts/app_tokens.md](contracts/app_tokens.md).

## 6. State transitions

**Startup (SYS-01)**: `initializing` → `ready(route)` or `failed(error)`. From `failed`, "Retry"
goes back to `initializing`.
`ready` picks the first route in this order: `/onboarding` if `!onboardingDone`, then `/lock` if
`lockEnabled`, otherwise `/home`.

**Onboarding (SYS-02)**: `step1` ↔ `step2` ↔ `step3` ↔ `step4` → `completing` → `done`.
"Skip" on step 1 or 2 goes straight to `completing` with defaults. `onboardingDone` is written
last, in the same transaction as the other onboarding settings. If the app is killed before
that, onboarding starts again.

**Module (SET-06)**: `enabled` ↔ `disabled`. Disabling a module removes it from
`enabledModules` and calls `onDisable()`. Enabling it adds it back at its `moduleOrder` position
and calls `onEnable()`. Disabling is rejected when only one module is enabled.

## 7. Migrations

- v1: `createAll()` for `settings`, `categories`, `accounts`.
- The schema dump is committed at `drift_schemas/app_database/drift_schema_v1.json`. The
  generated verifier test asserts that v1 is created and matches the dump.
- Future changes bump `schemaVersion`, add a `from1To2` step in `stepByStep`, and add a
  migration test in the same file.
