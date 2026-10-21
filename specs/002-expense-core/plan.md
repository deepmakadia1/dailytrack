# Implementation Plan: Expense Core (Phase 1, T1.1–T1.4)

**Branch**: `002-expense-core` | **Date**: 2026-10-14 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-expense-core/spec.md`

## Summary

This feature turns the Expense placeholder into a working module (`docs/spec.md` §14, T1.1–T1.4):

- **T1.1 Data**: Drift schema v1 → v2 adds `transactions` with 3 indexes and CHECK/FK constraints.
  It also adds domain entities, repository interfaces, and Drift implementations for
  transactions, categories, and accounts, all with soft delete. The existing exactly-once seed
  is kept, with a migration test proving the upgrade doesn't re-seed.
- **T1.2 EXP-02**: a full-screen add/edit form with the custom keypad and calculator, validation,
  remembered defaults derived from history, Undo after save, receipts (`image_picker` +
  `flutter_image_compress`), and no Repeat toggle.
- **T1.3 EXP-01 + EXP-03**: a period-scoped, paginated, live list with sticky day headers, an exact
  summary strip, search, session filters, swipe delete with Undo or duplicate, and the detail
  screen with share.
- **T1.4 EXP-04/05, EXP-06/07**: categories (tabs, reorder, hide, delete with replacement,
  duplicate-name check across en/hi/gu) and accounts (derived balances, archive, a last-active
  guard).
- **Module**: the real `ExpenseModule` routes, a live Home card (spent today and this month), and an
  "Add expense" quick action. `backupSection` stays a stub. No ads anywhere.

**Approach**:
- Pure-Dart domain, and Drift repositories bound only in `main.dart`.
- One `riverpod_generator` notifier per screen with a `freezed` state.
- Two reactive streams per list (a page stream and a ledger stream), so totals are exact by
  construction (research R4).
- Shared UI from `lib/core/widgets/`, with `PeriodSelector` generalized to Day, Week, Month, Year,
  and Custom.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged from feature 001)

**Primary Dependencies**:
- Existing: `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0,
  `drift` 2.35 + `drift_flutter` 0.3, `freezed` 4.0, `intl` 0.20, `uuid` 4.6.
- **New** (research R1): `image_picker` ^1.2.4, `flutter_image_compress` ^2.5.1, `path_provider`
  ^2.1.6 (already transitive), `share_plus` ^13.3.1 (listed in §2).

**Storage**:
- SQLite through Drift `AppDatabase`, **schema v2**: `settings`, `categories`, `accounts`, plus
  `transactions`. See [data-model.md](data-model.md).
- Receipt JPEGs in app-private `<documents>/receipts/`.

**Testing**:
- `flutter_test`: unit tests (real in-memory Drift through `makeRealContainer`), widget tests (fake
  repositories through `pumpTestApp`), and goldens (tag `golden`, Linux only).
- `mocktail`, and the Drift `SchemaVerifier` for v1→v2 with data.
- `integration_test` for the add-expense flow.

**Target Platform**: Android API 24+ (iOS-ready code, not tested)

**Project Type**: Mobile app (single Flutter project)

**Performance Goals** (Constitution V, spec SC-004/005):
- Save < 100 ms.
- EXP-01 first content < 300 ms at 10,000 rows.
- 60 fps scrolling with 10,000 transactions.
- Home card from local data with no visible delay.
- APK < 25 MB per ABI (baseline 21.0 MB arm64).

**Constraints**:
- Offline only. No ads (banner slot stays `null`).
- Money in `int` paise with `BigInt` math in the keypad.
- UTC ms storage, with local-day grouping in Dart.
- All strings from ARB in en/hi/gu.
- 200% font scale and 360 dp width.
- Receipts stay on the device with EXIF stripped.

**Scale/Scope**:
- 7 screens plus 1 Home card.
- 1 new table, 2 new enums, 3 repositories.
- About 9 new or changed shared core items.
- Roughly 120 new ARB keys × 3 languages.
- Designed for 10,000+ transactions.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs in files, tests, and commits; spec updated before code | ✅ with a **pre-implementation spec update** (Open item 1): `docs/spec.md` EXP-01/02/04/05/06 must record clarifications Q2–Q5 and the amount-search rule (R5) before the code that depends on them |
| II. Layered, feature-first | presentation → domain only; pure-Dart domain; no cross-feature imports; one notifier per screen; module registered | ✅ Repositories are bound in `expense_bindings.dart`, which only `main.dart` imports (R11). `DefaultNameCatalog`, `Clock`, and `TextSharer` are core interfaces, so core never imports the feature. Plugins (`image_picker`, `flutter_image_compress`, `path_provider`) are used only in `expense/data`, and `share_plus` only in `core/share`. The existing import-scan test is extended. The `app_database.dart` → feature-tables exception (feature 001 Complexity Tracking) now also covers `transactions_table.dart` |
| III. Data integrity & privacy | int paise; UTC ms; `deletedAt`; migration plus test; no egress | ✅ `transactions` is soft-delete only. v1→v2 `stepByStep` migration with a data-preserving test (R2). CHECK constraints for amount range, type shape, and note length. Receipts are app-private, relative paths, EXIF stripped (R8). Share is user-initiated text through the OS sheet. No analytics or ads |
| IV. Test-backed acceptance | ≥ 1 test per criterion; ≥ 80% coverage on `domain/` and `data/`; fakes + `NoAdsService`; EXP-01/02 goldens | ✅ Map in [quickstart §4](quickstart.md#4-acceptance-criteria--automated-tests). Goldens for EXP-01..07 × light/dark × en/gu. Real Drift only in unit tests |
| V. Offline, fast, accessible | tokens and shared widgets only; 4 states; ARB in 3 languages; 48 dp; 200%; perf budgets | ✅ The sliver layout with fixed extents (R6), the ledger fold (R4), and a perf unit test at 10,000 rows. Device fps is checked manually now and benchmarked in T5.1. §15.10 review per screen |
| VI. Isolated monetization | no ads on forms; banners per §11 | ✅ by exclusion. No ad code. `bannerSlot: null` on EXP-01/03/04/06 until T4.2 places banners. Tests assert no ad widgets and no `AdService` calls |
| VII. Locked stack, YAGNI | §2 packages only; additions justified | ✅ The 4 additions are justified in R1 (two were named by the user, one is in §2, one is already transitive). Sticky headers use SDK slivers instead of a package (R6). Remembered defaults are derived from history, not new settings (R7) |

**Result**: PASS. **After Phase 1 design**: PASS. The design added core interfaces
(`DefaultNameCatalog`, `TextSharer`, `Clock`, `rootNavigatorKey`/`rootMessengerKey`) specifically to
keep the layering rules intact. No new violations. Two existing deviations carry over (see
Complexity Tracking).

## Project Structure

### Documentation (this feature)

```text
specs/002-expense-core/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R15
├── data-model.md        # Phase 1: schema v2, entities, validation, state transitions
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── repositories.md        # domain interfaces, ports, errors
│   ├── routes_and_module.md   # routes, root keys, ExpenseModule, bindings
│   ├── screens.md             # per-screen controller, state, intents, layout
│   └── shared_widgets.md      # core additions and changes
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
  main.dart                                  # + ...expenseOverrides()
  app/
    app.dart                                 # scaffoldMessengerKey: rootMessengerKey
    router/routes.dart                       # + expense route constants and path helpers
    router/app_router.dart                   # navigatorKey: rootNavigatorKey
  core/
    database/app_database.dart               # + Transactions; schemaVersion 2; stepByStep from1To2
    database/app_database.steps.dart         # generated by make-migrations (stepByStep)
    module/root_navigator.dart               # NEW rootNavigatorKey, rootMessengerKey
    l10n/default_name_catalog.dart           # NEW interface (pure Dart)
    l10n/default_name_catalog_impl.dart      # NEW lookupAppLocalizations en/hi/gu
    share/text_sharer.dart                   # NEW TextSharer + SharePlusTextSharer + provider
    theme/app_icons.dart                     # NEW key → IconData, about 80 grouped
    utils/period.dart                        # NEW sealed Period
    utils/clock.dart                         # NEW Clock, SystemClock, clockProvider
    widgets/period_selector.dart             # CHANGED: takes Period
    widgets/period_picker_sheet.dart         # NEW
    widgets/icon_picker_grid.dart            # NEW
    widgets/color_picker_row.dart            # NEW
    widgets/undo_snack_bar.dart              # CHANGED: optional messenger
  features/expense/
    expense_module.dart                      # CHANGED: real routes, card, quick add
    expense_bindings.dart                    # NEW: expenseOverrides() (imported only by main.dart)
    domain/
      enums.dart                             # + TxnType, PaymentMode, AccountType.defaultPaymentMode
      entities/                              # transaction, transaction_draft, transaction_view, category,
                                             # account, txn_query, period_ledger, today_and_month_spend
      repositories/                          # transaction_repository, category_repository, account_repository
      receipts/                              # receipt_picker, receipt_store (interfaces)
      usecases/                              # validate_transaction, validate_category_name, validate_account,
                                             # fold_ledger, amount_entry
      errors.dart
    data/
      tables/transactions_table.dart         # NEW
      tables/{categories,accounts}_table.dart
      daos/                                  # transactions_dao, categories_dao, accounts_dao
      mappers/                               # row ↔ entity
      repositories/                          # drift_*_repository.dart
      receipts/                              # image_receipt_picker.dart, file_receipt_store.dart, resize_math.dart
      seed/expense_defaults_seeder.dart      # unchanged
    presentation/
      expense_providers.dart                 # repository/port providers (throw unless overridden)
      controllers/                           # one notifier + freezed state per screen (EXP-01's is keep-alive), + transaction_query_ops (pure), receipt_prune
      screens/                               # transactions_screen (EXP-01), transaction_form_screen (EXP-02),
                                             # transaction_detail_screen (EXP-03), categories_screen (EXP-04),
                                             # accounts_screen (EXP-06)
      widgets/                               # category_sheet (EXP-05), account_sheet (EXP-07), transaction_row,
                                             # day_header, summary_strip, filter_sheet, filter_chips,
                                             # category_grid, replacement_category_sheet, receipt_field,
                                             # receipt_viewer, expense_dashboard_card
      # expenses_placeholder_screen.dart     # DELETED
drift_schemas/app_database/drift_schema_v2.json  # NEW
tool/l10n/phase0_strings.py                  # + expense_* keys (en/hi/gu)
test/
  helpers/test_app.dart                      # default empty expense fakes
  features/expense/{fakes.dart, domain/, data/, presentation/}
  core/utils/period_test.dart, core/widgets/*  # new and changed shared code
  drift/app_database/migration_test.dart     # + v1→v2 with data
  goldens/expense_screens_golden_test.dart
  a11y/font_scale_test.dart                  # + EXP-01..07
integration_test/expense_flow_test.dart
```

**Structure Decision**: A single Flutter project following `docs/spec.md` §3, with all Expense code
under `lib/features/expense/{data,domain,presentation}` as requested. Two placements are not named
in §3:
- `expense_bindings.dart` at the feature root, next to `expense_module.dart`. It is the feature's
  half of the composition root (R11).
- Several small shared ports in `core/`, so core never imports the feature: `core/share/`,
  `core/utils/clock.dart`, `core/l10n/default_name_catalog*.dart`.

## Implementation order (input for /speckit-tasks)

1. **Pre-work**:
   - Update `docs/spec.md` with Q2–Q5 and R5 (Open item 1).
   - Add the 4 packages.
   - Add ARB keys (`tool/l10n/phase0_strings.py`, en/hi/gu), then `gen-l10n`.
2. **T1.1 Data**:
   - Enums and entities, then the `transactions` table, then schema v2 with `make-migrations`, then
     the migration test (v1→v2 with data, no re-seed).
   - DAOs and repositories for transactions, categories, and accounts, with real-Drift unit tests:
     ledger, search, balances, usage order, guards, soft delete and undo ordering, CHECK
     constraints, and indexes.
   - Use cases (validation, ledger fold, amount entry ≥ 1,000 values).
   - Receipt store and picker (with temp-dir tests).
   - Core ports: `Period`, `Clock`, `DefaultNameCatalog`, `TextSharer`, root keys.
   - `expense_bindings.dart`, `main.dart`, test fakes, and `pumpTestApp` defaults.
   - Perf unit test at 10,000 rows.
3. **Shared widgets**:
   - `PeriodSelector` → `Period`, plus `PeriodPickerSheet`.
   - `IconPickerGrid`, `ColorPickerRow`, `AppIcons`.
   - `UndoSnackBar` messenger parameter.
   - Widget tests and goldens.
4. **T1.2 EXP-02** with EXP-05 reachable from "+ New": controller tests first, then the screen,
   then both acceptance criteria, scenarios 1–15, and the edge cases.
5. **T1.3 EXP-01 + EXP-03**:
   - Routes and module routes, and delete the placeholder.
   - The pure query ops, the keep-alive controller (the screen's only notifier), slivers, and states.
   - EXP-03 with share and receipt viewer.
   - The 3 acceptance criteria and scenarios.
6. **T1.4**: EXP-04/05 (reorder, hide, delete with replacement, duplicate check in all 3
   languages), then EXP-06/07 (balances, archive, last-active guard).
7. **Module**: `ExpenseDashboardCard`, `quickAddAction`, and the integration test.
8. **Finish**:
   - Goldens (Linux) and the a11y sweep.
   - §15.10 review in `checklists/design-review.md`.
   - Quality gates, APK size, and `docs/spec.md` §14 checkboxes.
   - Task summary.

## Open items (resolve before or during implementation)

1. **Update `docs/spec.md` first** (Constitution I):
   - EXP-02: the category grid order is usage count, then the EXP-04 order (Q2). The Wallet
     account's default payment mode is Other (Q4).
   - EXP-05: names are unique per type across en/hi/gu translations of defaults (Q5).
   - EXP-06: the last active account cannot be archived or deleted (Q3).
   - EXP-01: amount search is exact, or a prefix of the whole-rupee digits (R5).
2. **Golden baselines**: Linux only (carried over from feature 001 open item 1). EXP-01..07 and the
   changed shared-widget goldens are generated together with feature 001's pending baselines.
3. **Native-speaker review** of the new Hindi and Gujarati strings (carried-over practice).
4. **Device checks**: the 60 fps scroll at 10,000 rows (SC-005) and the camera receipt flow on a
   physical device. Profile mode doesn't run on emulators.
5. **Backups**: `ExpenseModule.backupSection()` stays `null`. T3.2 must include `transactions` and
   the `receipts/` folder (relative paths, R8).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `core/database/app_database.dart` imports `features/expense/data/tables/transactions_table.dart` (core → feature) | Carried over from feature 001: Drift needs every table in one `@DriftDatabase` for a single file, cross-table transactions (category replacement, the last-account guard), and `SchemaVerifier` | Same as feature 001: moving tables to core breaks feature ownership, and separate databases break atomic multi-table writes and backup consistency. The import-scan test still allows only `app_database.dart` and only `data/tables/*` |
| EXP-01, EXP-03, EXP-04, and EXP-06 ship with `bannerSlot: null`, although spec §11 lists banners for them | The feature request puts all ads out of scope ("keep the AppScaffold banner slot empty"). Constitution VI's placement rule is satisfied by T4.2 | Adding banners now would pull `AdService` and consent work forward from T4.1. The slot already takes no space when empty, so adding banners later causes no layout change |
