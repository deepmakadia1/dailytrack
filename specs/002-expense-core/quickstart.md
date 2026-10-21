# Quickstart & Validation: Expense Core (Phase 1, T1.1–T1.4)

**Feature**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Contracts**: [contracts/](contracts/)

This is a validation guide, not an implementation guide. It lists what to run and what "done"
looks like.

## 1. Quality gates (every task; Constitution, Development Workflow)

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/l10n/phase0_strings.py; flutter gen-l10n
flutter analyze                                   # zero issues
dart format --set-exit-if-changed .               # 0 changed
flutter test --exclude-tags golden                # Windows/macOS
flutter test --tags golden                        # Linux/CI only (baselines from Linux)
```

## 2. Schema change workflow (T1.1)

```powershell
dart run drift_dev make-migrations                # writes drift_schema_v2.json, app_database.steps.dart, test helpers
flutter test test/drift/app_database/migration_test.dart
```

Expected:
- `drift_schemas/app_database/drift_schema_v2.json` exists, and v1 is unchanged.
- The migration test runs v1→v2 with validation **and data**:
  - Every v1 `settings`, `categories`, and `accounts` row is identical after the upgrade.
  - The `seed.expense.defaults.v1` marker is kept.
  - Running `SeedRunner` again inserts 0 rows.
- A fresh v2 database matches the dump.

## 3. Run the app

```powershell
flutter run --flavor dev
```

Manual smoke test (about 3 minutes; the automated tests in §4 are the real proof):
1. Expenses tab → FAB → type `120+35.5` → `=` → tap Food → Save. The list shows ₹155.50 under
   "Today", the summary strip says Expense −₹155.50, and the snackbar says "Saved · Undo".
2. Swipe the row left, then tap Undo. It comes back in the same place.
3. Overflow → Accounts → + → "SBI Savings", Bank, 10,000 → Save. The total balance is ₹10,000 −
   ₹155.50.
4. Add a Transfer Cash → SBI of ₹100. The summary strip is unchanged, and both account balances
   move.
5. Overflow → Categories → + → "Food" (Expense). An inline duplicate error appears. Switch the app
   to Gujarati, then try "ખોરાક". It is also rejected (Q5).
6. Home → the Expense card shows today's and this month's spend. Tapping it opens EXP-01.
7. EXP-02 → Camera → take a photo → Save → open the detail. The thumbnail shows, and tapping it
   zooms.

## 4. Acceptance criteria → automated tests

Widget tests use `pumpTestApp` with fakes from `test/features/expense/fakes.dart`. Unit tests that
need real Drift use `makeRealContainer`.

| Spec criterion (verbatim) | Test file | Kind |
| --- | --- | --- |
| EXP-01: Totals in the summary strip always equal the sum of visible rows (transfers excluded). | `test/features/expense/presentation/transactions_screen_test.dart`, `test/features/expense/data/transaction_ledger_test.dart` | widget + unit (real Drift, randomized 500-row sets × filters) |
| EXP-01: Undo restores a deleted row in its original position. | `transactions_screen_test.dart`, `test/features/expense/data/transaction_repository_test.dart` | widget + unit |
| EXP-02: A new expense can be saved with amount + category only in 3 taps after typing the amount. | `test/features/expense/presentation/transaction_form_screen_test.dart` (counts `tester.tap` calls after keypad entry) | widget |
| EXP-02: Amount is stored in paise without rounding errors (e.g. 10.10 → 1010). | `transaction_form_screen_test.dart`, `test/features/expense/domain/amount_entry_test.dart` (≥ 1,000 values, SC-002) | widget + unit |
| EXP-03: Deleting returns to EXP-01 with Undo available. | `test/features/expense/presentation/transaction_detail_screen_test.dart` | widget |
| EXP-05: Duplicate names within the same type are rejected with an inline error. | `test/features/expense/presentation/category_sheet_test.dart`, `test/features/expense/domain/validate_category_name_test.dart` (all 3 languages, Q5) | widget + unit |
| SYS-01: First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once. | existing feature 001 tests + `migration_test.dart` (no re-seed after v1→v2) | unit |

**Derived scenarios and edge cases**: each user-story scenario and edge case in spec.md maps to a
`testWidgets`/`test` whose name starts with the Screen ID and the scenario number, for example
`EXP-04 US4-7 delete with transactions requires replacement`. `/speckit-tasks` lists them.

**Cross-cutting**:

| Requirement | Test |
| --- | --- |
| FR-003 soft delete everywhere | `transaction_repository_test.dart`, `category_repository_test.dart`, `account_repository_test.dart` |
| FR-008 live updates | `transactions_screen_test.dart` (fake stream emits), `expense_dashboard_card_test.dart` |
| CHECK constraints, FK, indexes exist | `test/features/expense/data/transactions_table_test.dart` (`PRAGMA index_list`) |
| Balances (US5-2), last-active guard (Q3) | `account_repository_test.dart` |
| Usage order (Q2) | `category_repository_test.dart` |
| Search rules (R5) | `transaction_search_test.dart` (real Drift: note, localized category, amount exact or prefix, wildcard escaping) |
| Receipts (R8) | `test/features/expense/data/receipt_store_test.dart` (temp dir: relative path, prune rules), `receipt_resize_test.dart` (dimension math) |
| Period boundaries (R13) | `test/core/utils/period_test.dart` (week start, month ends, DST zones) |
| Layering | `test/core/theme/no_hardcoded_style_test.dart` (existing import scan) extended: `presentation/` never imports `data/`, Drift, or plugins; only `main.dart` imports `expense_bindings.dart` |
| No ads (FR-038) | each screen test (with `NoAdsService`) asserts that no `AppBannerAd`/`AppNativeAd` is in the tree; the import scan (T004 e) proves `features/expense/` never imports `core/ads/` or `google_mobile_ads` |
| 200% font, 360 dp, en/hi/gu (SC-008) | `test/a11y/font_scale_test.dart` extended with EXP-01..07 |
| Goldens (FR-039) | `test/goldens/expense_screens_golden_test.dart`: EXP-01..07 × light/dark × en/gu (Linux) |

## 5. Performance checks

```powershell
flutter test test/features/expense/data/transaction_perf_test.dart
```

The test seeds 10,000 transactions in memory and asserts:
- `create` is under 100 ms (SC-004).
- The first `watchPage(limit: 50)` + `watchLedger` emission for a month is under 300 ms.
- The ledger for a full Year (about 10,000 rows) is under 300 ms.

Device check (manual, recorded in the task summary): `flutter run --flavor dev --profile` with the
dev-only "Seed 10,000 transactions" debug action (debug builds only, behind `kDebugMode`). Scroll
EXP-01 and confirm in DevTools that there are no frames over 16 ms (SC-005). The full benchmark is
T5.1.

## 6. Release-size check

```powershell
flutter build apk --flavor prod --release --split-per-abi
```

Each ABI must stay under 25 MB. Feature 001's baseline was 21.0 MB for arm64. Record the change
caused by `flutter_image_compress` and `image_picker` (R1).

## 7. Integration test

```powershell
flutter test integration_test --flavor dev
```

`integration_test/expense_flow_test.dart`: add an expense through EXP-02 → it appears in EXP-01 and
on the Home Expense card → restart → it is still there. The "appears in Reports" step of the §13
flow is added in T1.7.

## 8. Done checklist (per task)

- [ ] Gates in §1 are green. Goldens are generated on Linux or listed as an open item.
- [ ] Every criterion in §4 has a passing test.
- [ ] The §15.10 design review is recorded in `checklists/design-review.md` for EXP-01..07 and the
      Home card.
- [ ] `docs/spec.md` §14: T1.1–T1.4 checked. The task summary lists files, tests, checklist
      results, and open items.
