# Research: Expense Core (Phase 1, T1.1–T1.4)

**Feature**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Date**: 2026-10-14

Each decision follows the format Decision / Rationale / Alternatives considered. The Technical
Context has no remaining NEEDS CLARIFICATION items. Spec clarifications Q1–Q5 are treated as fixed
inputs.

## R1. New packages

**Decision**: Add these four direct dependencies. Versions were resolved with `flutter pub add --dry-run` on
2026-10-14 and are locked in `pubspec.lock`.

| Package | Version | Why | Layer |
| --- | --- | --- | --- |
| `image_picker` | ^1.2.4 | EXP-02 "Attach receipt: camera or gallery" (requested by the user, clarification Q1) | `expense/data` only |
| `flutter_image_compress` | ^2.5.1 | Max 1280 px, JPEG 80% (EXP-02). Uses native codecs, so no Dart image decoding on the UI isolate | `expense/data` only |
| `path_provider` | ^2.1.6 | App-private documents directory for `receipts/`. It is already a transitive dependency of `drift_flutter`, now made direct because we call it | `expense/data` only |
| `share_plus` | ^13.3.1 | EXP-03 "Share (as text)". Already listed in spec §2 | `core/share/` behind an interface |

**Rationale**: Constitution VII requires every addition to be justified. `image_picker` and
`flutter_image_compress` were named by the user. `path_provider` adds no new code to the APK.
`share_plus` is in the §2 stack. None of them sends data off the device. Sharing is started by
the user through the system sheet.

**Alternatives considered**:
- The `image` package (pure Dart resize): slow on large camera photos and blocks an isolate. Rejected.
- `image_picker`'s own `maxWidth`/`imageQuality`: it re-encodes inconsistently across Android
  versions and keeps the original format, such as HEIC or PNG. It is used only as a first, cheap
  downscale, and `flutter_image_compress` produces the final JPEG.
- An `Intent.ACTION_SEND` platform channel for sharing: reinvents `share_plus`. Rejected.
- A sticky-header package (`flutter_sticky_header`, `sliver_tools`): not needed, see R6.

**Android impact**: `image_picker` uses the system photo picker on API 33+ and `ACTION_GET_CONTENT`
below that. The camera flow uses `ACTION_IMAGE_CAPTURE`, so no `CAMERA` or storage permission is
declared. `share_plus` declares nothing. The expected APK growth is under 1 MB per ABI, mostly from
`flutter_image_compress`'s native library, and is checked against the 25 MB budget in quickstart
§6.

## R2. Schema change v1 → v2

**Decision**: Bump `AppDatabase.schemaVersion` to 2. Add the `transactions` table with three
indexes. `categories` and `accounts` are unchanged. Use Drift's `make-migrations` workflow:

1. Dump the v2 schema to `drift_schemas/app_database/drift_schema_v2.json`.
2. Generate `lib/core/database/app_database.steps.dart` (`stepByStep`) and the test helpers. `build.yaml` sets the database path, `schema_dir`, and `test_dir`.
3. Implement `from1To2: (m, schema) async { await m.createTable(schema.transactions); await m.createIndex(...) ×3; }`.

**Rationale**: Constitution III requires a migration and a migration test. The feature 001 harness
(`test/drift/app_database/migration_test.dart`) already contains a template for v1 → v2. A
`stepByStep` migration means the upgrade code uses the frozen v2 schema snapshot, not the live
table classes, so later changes cannot silently alter it.

**Alternatives considered**: A hand-written `onUpgrade` with `m.createTable(transactions)` uses the
live table, which drifts when T1.5 or T1.6 change it. Rejected.

## R3. Foreign keys and the recurring-rule reference

**Decision**:
- `transactions.accountId` references `accounts(id)`. `toAccountId` and `categoryId` are nullable
  references to `accounts(id)` and `categories(id)`. Foreign keys are already enforced with
  `PRAGMA foreign_keys = ON` (feature 001).
- `recurringRuleId` is a nullable `TEXT` with **no** foreign key constraint. T1.6 adds
  `recurring_rules`. Because SQLite cannot add a foreign key to an existing column, T1.6 either
  rebuilds `transactions` in its migration (Drift `TableMigration`) or keeps integrity in the
  repository. That decision belongs to T1.6.
- A table-level `CHECK` enforces the shape of each type: a transfer has `toAccountId`, no
  `categoryId`, and `toAccountId != accountId`. Expense and income have `categoryId` and no
  `toAccountId`. Also `amountMinor BETWEEN 1 AND 99999999900` and `length(note) <= 200`.

**Rationale**: The spec requires both the field (§4) and its emptiness in this feature. The `CHECK`
constraints are a last line of defense under the domain validation (FR-011), and they are tested
directly.

**Alternatives considered**: Leaving the column out until T1.6 adds a second migration for one
column, and the spec Assumption chose to include it now.

## R4. Querying: pages, totals, and day groups

**Decision**: EXP-01 uses two reactive Drift streams that share one filter object (`TxnQuery`):

1. **Page stream**: full rows joined with category and account, `ORDER BY occurredAt DESC, createdAt DESC, id DESC`,
   `LIMIT :pageCount*50`. Scrolling within 10 rows of the end increments `pageCount`. Drift
   re-emits on any write to the three tables, so other screens' changes appear live (FR-008).
2. **Ledger stream**: a slim projection `(occurredAt, type, amountMinor)` for **all** rows matching
   the query, with no limit. In Dart it is folded once into: period Income, Expense, and Net
   (transfers excluded), and a `Map<localDayKey, DayTotal>` for the sticky headers.

**Rationale**:
- One source for both the summary strip and the daily totals guarantees the acceptance criterion
  "Totals in the summary strip always equal the sum of visible rows".
- Local-day grouping in Dart uses `DateTime.fromMillisecondsSinceEpoch(...).toLocal()`. This is
  correct across DST and time zone changes, where an SQL `'localtime'` or fixed-offset expression is
  not.
- Cost at 10,000 rows (a Year period): 10,000 × 3 ints, about 5 ms to fold. This was measured in
  feature 001's harness for a similar fold and is re-checked by the perf test (quickstart §5).
- The `ORDER BY` is total and stable (the `id` tiebreak), so an undone soft delete lands back in
  exactly the same position. This satisfies the EXP-01 acceptance criterion.

**Alternatives considered**:
- SQL `GROUP BY date(occurredAt/1000,'unixepoch','localtime')`: SQLite's local time zone is the
  process time zone, which differs between tests and devices, and it breaks DST correctness. Rejected.
- Offset pagination with `OFFSET` per page: breaks when rows are inserted above the viewport while
  the stream re-emits. A growing `LIMIT` is simpler, and the cost is bounded at 50 × pages.
- Keyset pagination: better at very deep scrolls, but adds cursor state across re-emits. Not
  needed at 10,000 rows. Revisit in T5.1 if profiling shows it.

## R5. Search

**Decision**: `TxnQuery.search` is applied in SQL as an OR of three parts:
- `note LIKE '%q%'` with case-insensitive matching (SQLite `LIKE` is case-insensitive for ASCII.
  Devanagari and Gujarati have no case, so plain `LIKE` is correct for them.)
- `categoryId IN (:ids)`: the **controller** resolves `ids` by matching `q` against each category's
  **displayed** name (localized for defaults through `localizedSeedName`). There are at most a few
  hundred categories, so this runs in memory.
- An amount match: if `q` parses as a non-negative decimal (`KeypadExpression`'s parser,
  digits and `.` only), match `amountMinor = parsed` (exact) **or** `CAST(amountMinor / 100 AS TEXT) LIKE 'q%'`
  (prefix on the whole-rupee digits, only when `q` has no decimal point).

`%`, `_`, and `\` in `q` are escaped (`ESCAPE '\'`). The 300 ms debounce lives in the EXP-01
controller.

**Rationale**: Default category names are stored as l10n keys, so SQL cannot match them by
translated text. Resolving them in the controller keeps `domain/` free of Flutter l10n. The amount
rule settles the "exact or prefix" wording that was left open after clarification. Typing "12"
finds ₹12, ₹120 and ₹1,250. Typing "12.5" finds only ₹12.50.

**Alternatives considered**: An FTS5 virtual table is too much for a 200-character note field,
and it adds a table to migrate and back up. Rejected.

## R6. Sticky date headers and 60 fps at 10,000 rows

**Decision**: EXP-01 uses a `CustomScrollView`. Each day is one `SliverMainAxisGroup` holding a
`PinnedHeaderSliver` (date + day total) and a `SliverList.builder` of rows with a fixed
`itemExtent` of 72 dp. Native ads are not placed (FR-038).

**Rationale**: Both slivers are in the Flutter SDK (3.24+; the project is on 3.47). Pinned headers
inside a group stick until the group scrolls away, which is the §15.3 behavior with no package.
Fixed extents let the viewport skip layout for off-screen rows. At 200% font scale the extent is
scaled with `MediaQuery.textScalerOf(context).scale(72)`, so text never clips (FR-036).

**Alternatives considered**: `flutter_sticky_header`/`sliver_tools` are unnecessary dependencies
(Constitution VII). A flat `ListView` with header rows doesn't stick. Rejected.

## R7. Remembered defaults without new settings

**Decision**: These "remember the user" values (FR-013) are **derived from transaction history**,
not stored:
- **Last-used account**: the `accountId` of the most recently *created* non-deleted transaction
  whose account is still non-archived. Otherwise, the first non-archived account by `sortOrder`.
- **Payment mode**: the account type mapping (spec Assumption plus clarification Q4): cash→cash,
  bank→netBanking, upi→upi, card→card, wallet→other. It is applied when the account is chosen.
- **Category usage frequency**: `COUNT(*) GROUP BY categoryId` over non-deleted transactions of
  the selected type. Sort by count descending, then `sortOrder` ascending (clarification Q2).
  With no history, every count is 0, so the drag order applies.

**Rationale**: No new keys are needed in the shared `settings` table. That keeps `AppSettings`
(core) free of Expense-specific fields, which would be a cross-feature leak. Values also stay
correct after Undo, delete, and restore from backup. The queries use the existing indexes:
`(categoryId, occurredAt)` covers the count. "Most recently created" uses the primary-key lookup
over `createdAt`, which runs once per EXP-02 open and costs under 5 ms at 10,000 rows.

**Alternatives considered**: Storing `expense.lastAccountId` in `settings` goes stale on archive,
delete, or restore, and needs extra invalidation logic. Rejected.

## R8. Receipt storage lifecycle

**Decision**:
- Pick: `ImagePicker.pickImage(source, maxWidth: 2560)` is a cheap first pass. Then
  `FlutterImageCompress.compressAndGetFile` with target dimensions computed so the **longest
  side ≤ 1280** while keeping the aspect ratio, `quality: 80`, `format: CompressFormat.jpeg`, and
  `keepExif: false`, which strips GPS location for privacy.
- Store at `<appDocuments>/receipts/<uuid>.jpg`. The **relative** path `receipts/<uuid>.jpg` is
  saved in `receiptPath`, so restoring a backup on a new install (T3.2) resolves against that
  install's directory.
- A file is written as soon as it is picked (a "pending" receipt). Replacing or removing a receipt
  in EXP-02 never deletes a file immediately, because Undo after an edit may restore the old path.
- **Pruning**: `ReceiptStore.pruneOrphans()` runs once per app process, without blocking UI. A
  keep-alive `receiptPruneProvider` starts it the first time EXP-01 or EXP-02 builds. `TrackerModule`
  has no startup hook, and adding one for this isn't worth a contract change. It deletes files in `receipts/` that no
  transaction row references (deleted or not) **and** whose modified time is more than 24 hours
  old. This removes picks from discarded forms and replaced receipts. Soft-deleted transactions
  keep their files, so a later backup restore stays consistent.

**Rationale**: This meets FR-015 (on-device, app-private, 1280 px, JPEG 80). It is safe with
Undo, and stripping EXIF prevents a location leak if the user later shares the image. The 24-hour
grace period means a file picked in a form that is still open is never pruned.

**Alternatives considered**: Deleting the old file on save breaks Undo after an edit. Storing
absolute paths breaks after backup restore and reinstall. Storing blobs in SQLite makes the
database and backups too large. All rejected.

## R9. Duplicate category names across languages (clarification Q5)

**Decision**: `core/l10n/default_name_catalog.dart` declares `abstract interface class DefaultNameCatalog { Set<String> namesFor(String key); }`
(pure Dart, in core because core may not import features). The expense domain imports it.
`core/l10n/default_name_catalog_impl.dart` implements it with
`lookupAppLocalizations(Locale(code))` for `en`, `hi`, and `gu`, plus the existing `l10nByKey`.
The `ValidateCategoryName` use case normalizes names (trim, collapse inner whitespace, Unicode-aware
`toLowerCase`) and rejects a name equal to:
- any non-deleted custom or **renamed** category name of the same type, or
- any of the three translations of any **non-renamed** default of the same type (`isDefault && name == key`).

It also rejects names matching the ARB key pattern `^(expense|income)_(cat|account)_` so a user
cannot type a key and have it displayed as a translation.

**Rationale**: Keeps the domain Flutter-free (Constitution II) and uses the generated localizations
as the single source of translations.

**Alternatives considered**: A copied table of translations in Dart would drift from the ARB files.
Rejected.

## R10. Navigation shape

**Decision**: All Expense routes are children of the Expenses tab branch, so the disabled-module
redirect (feature 001 rule 5) covers them:

| Route | Screen | Navigator |
| --- | --- | --- |
| `/expenses` | EXP-01 | branch |
| `/expenses/add` (`?type=&duplicateOf=`) | EXP-02 new | **root** (full-screen modal, `fullscreenDialog: true`) |
| `/expenses/categories` | EXP-04 | branch (push) |
| `/expenses/accounts` | EXP-06 | branch (push) |
| `/expenses/:id` | EXP-03 | branch (push) |
| `/expenses/:id/edit` | EXP-02 edit | **root** |

Static segments are declared before `:id`. EXP-02 needs `parentNavigatorKey: rootNavigatorKey`,
so the key moves from `app/router/app_router.dart` into a new `core/module/root_navigator.dart`.
That is core, which features may import. The router then reuses it. Account tap in EXP-06 calls
`context.go('/expenses?accountId=<id>')`, and EXP-01 applies query parameters to its session filter
once.

**Rationale**: Spec §5 says add/edit opens full screen above the shell. The feature may not import
`app/` beyond `routes.dart`, so the key must live in core.

**Alternatives considered**: Pushing EXP-02 with `Navigator.of(context, rootNavigator: true)`
bypasses go_router, breaking deep links and redirects. Rejected.

## R11. Wiring repositories without breaking layering

**Decision**: Mirror feature 001's settings pattern:
- Providers are a presentation concern, so they don't go in `domain/`.
  `features/expense/presentation/expense_providers.dart` declares
  `transactionRepositoryProvider`, `categoryRepositoryProvider`, `accountRepositoryProvider`,
  `receiptStoreProvider`, `receiptPickerProvider`, `defaultNameCatalogProvider`, and `clockProvider`.
  Each throws `UnimplementedError` unless overridden.
- `features/expense/expense_bindings.dart` (feature root, next to `expense_module.dart`) exports
  `List<Override> expenseOverrides()`, which binds the Drift implementations.
- `main.dart`'s `productionOverrides()` spreads `...expenseOverrides()`. It is the only file
  importing the bindings.
- `test/helpers/test_app.dart` `pumpTestApp` overrides the same providers with empty fakes by default,
  because Home's placeholder now renders the live Expense card. Tests can pass their own fakes.

**Rationale**: `presentation/` never imports `data/` (Constitution II, checked by the existing
import-scan test). There is a single composition root, and widget tests stay database-free.

**Alternatives considered**: Adding `List<Override> get overrides` to `TrackerModule` changes a
shared contract for one feature's convenience. It can be revisited when Habit needs the same.
Rejected for now.

## R12. Undo semantics

**Decision**:

| Action | Undo does |
| --- | --- |
| Save new transaction (EXP-02) | `softDelete(id)` |
| Save edit (EXP-02) | `restore(previousSnapshot)`, rewriting all fields including `updatedAt` from the snapshot |
| Delete transaction (EXP-01 swipe or menu, EXP-02 edit, EXP-03) | `undelete(id)` (clears `deletedAt`) |
| Delete custom category without transactions | `undelete(id)` |
| Archive account | `setArchived(id, false)` |
| Delete account without transactions | `undelete(id)` |
| Hide or unhide default category | `setHidden(id, !hidden)` |
| Delete category **with** replacement | No undo. The replacement sheet states the count ("Move 12 transactions to Food") before confirming (FR-037) |

The snackbar is shown on the **root** `ScaffoldMessenger`, so it survives closing EXP-02 and EXP-03
and is visible on EXP-01. Undo calls go through the repository, never through screen state.

**Rationale**: Spec Assumptions plus §15.5. Using the root messenger is what makes "Deleting
returns to EXP-01 with Undo available" (EXP-03) work.

## R13. Period model and `PeriodSelector`

**Decision**: Add `core/utils/period.dart`: a sealed `Period` (`SingleDayPeriod`, `WeekPeriod(firstDayOfWeek)`,
`MonthPeriod`, `YearPeriod`, `CustomPeriod`) with `startUtcMs`, `endUtcMsExclusive` (computed
from **local** midnight boundaries), `previous()`, `next()`, and `contains(utcMs)`. A custom range
has no previous/next, so the arrows are hidden. Change the shared `PeriodSelector` to take a
`Period` and a localized label (month: `yMMMM`; day: relative or `EEE, d MMM`; week: `d MMM – d MMM`;
year: `y`; custom: `d MMM y – d MMM y`). Add a `PeriodPickerSheet` (core/widgets) with the 5
kinds. The existing month behavior and tests are kept through `MonthPeriod`. Its golden baselines
are regenerated on Linux.

**Rationale**: EXP-01 needs Day, Week, Month, Year, and Custom. T1.5 and T1.7 reuse the same widget
(§15.4: one shared component). The week start comes from `AppSettings.firstDayOfWeek`.

**Alternatives considered**: An Expense-local period widget would duplicate a §15.4 component. Rejected.

## R14. Icons and colors for categories and accounts

**Decision**: Add `core/theme/app_icons.dart`: an ordered `Map<String, IconData>` of about 80
Material Symbols Rounded-style icons in groups (Food, Transport, Home & bills, Shopping, Health,
Education, Leisure, Travel, Money, Other). It includes every key the feature 001 seeder already
uses (`restaurant`, `wallet`, …), and unknown keys fall back to `category`. Colors come from the
existing 16-color `AppColors.palette`, stored as `#RRGGBB`. Both pickers are shared widgets
(`IconPickerGrid`, `ColorPickerRow` in `core/widgets/`), because HAB-02 reuses them ("same
components as EXP-05").

**Rationale**: `iconKey` is persisted, so the key→icon table must be stable and shared. Constant
`IconData` keeps icon-font tree-shaking working.

## R15. Testing strategy specifics

**Decision**:
- **Unit (real Drift, in-memory, `makeRealContainer`)**: DAO queries, CHECK constraints, balance
  math, category totals, usage ordering, search rules, soft delete and undelete ordering, category
  replacement move, the last-account guard, and v1→v2 migration with data (rows preserved and the seed marker kept).
- **Unit (pure)**: `Period` boundaries (DST via a `TZ` test zone list, week start), paise parsing
  for 1,000+ amounts (SC-002, property-style loop), `ValidateCategoryName`, and the receipt
  dimension calculator.
- **Widget**: every copied acceptance criterion, scenario, and edge case (quickstart §4), with fake
  repositories (`FakeTransactionRepository` etc. in `test/features/expense/fakes.dart`). No
  database, `NoAdsService`.
- **Golden (Linux only, tag `golden`)**: EXP-01..EXP-07 × light/dark × en/gu, plus the extended
  `PeriodSelector` and the new pickers.
- **Performance**: a unit test seeds 10,000 rows in memory and asserts that a save is under 100 ms
  and that the first page plus ledger for a month is under 300 ms. Measured 60 fps scrolling is
  verified on a device in T5.1 (spec §14). This feature records a `flutter run --profile` timeline
  check in quickstart §6 as a manual item.
- **Integration**: add an expense → it appears in EXP-01 and in the Home Expense card. The Reports
  part of the §13 flow is completed in T1.7.
