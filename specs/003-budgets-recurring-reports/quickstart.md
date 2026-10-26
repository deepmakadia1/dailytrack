# Quickstart & Validation: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Feature**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Data model**: [data-model.md](data-model.md) · **Contracts**: [contracts/](contracts/)

This is a validation guide, not an implementation guide. It lists what to run and what "done" looks
like.

## 1. Quality gates (every task)

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/l10n/phase0_strings.py; flutter gen-l10n
flutter analyze                                   # zero issues
dart format --set-exit-if-changed .               # 0 changed
flutter test --exclude-tags golden                # Windows/macOS
flutter test --tags golden                        # Linux/CI only
```

## 2. Dependencies

```powershell
flutter pub add clock:^1.1.3 workmanager:^0.10.10 fl_chart:^1.2.0
```

Expected: `clock` moves from transitive to direct. `fl_chart` 1.2.0 (+ `equatable`) and the
`workmanager` 0.10.10 family are added. Nothing else changes major version (research R1).

## 3. Schema change workflow (v2 → v3)

```powershell
dart run drift_dev make-migrations
flutter test test/drift/app_database/migration_test.dart
```

Expected (data-model §1, research R3):
- `drift_schema_v3.json` exists, and v1 and v2 are unchanged.
- v1→v3 and v2→v3 **with data**: every settings, category, account, and transaction row is
  identical, and the seed markers are kept, so re-seeding inserts 0 rows.
- `PRAGMA foreign_key_list(transactions)` shows `recurring_rule_id → recurring_rules(id)`.
- The 4 transaction indexes exist, along with `budgets_month_category_unique`,
  `recurring_rules_due`, and `unlocks_feature`.
- `PRAGMA foreign_key_check` returns nothing.

## 4. Run the app

```powershell
flutter run --flavor dev
```

Manual smoke test (about 5 minutes; the automated tests in §5 are the real proof):

1. **Budgets**: Expenses → overflow → Budgets. You see the empty state → "Set monthly budget" →
   ₹30,000 with "Repeat every month" on → Set budget. The overall card shows "₹X per day left for N
   days", where N counts today to the end of the month, both included. In "Categories without
   budget", tap Food → Set budget → ₹1,000.
2. **Alert**: + → ₹850 → Food → Save. A "Budget alerts" notification says Food reached 85%. Save
   ₹200 Food: it says the budget is used up. Save ₹50 Food: no notification. Tapping a
   notification opens Budgets.
3. **Past month**: + → ₹5,000 → Food, dated last month → Save. No notification (Q2).
4. **Recurring**: + → ₹15,000 → Rent → date: the 5th, three months ago → Repeat on, Monthly →
   Save. The list shows 4 rent rows with the repeat icon (the original + 3 backfilled). Overflow →
   Recurring shows "Every month on 5th" and next date the 5th of next month. Swipe → Pause; the rule
   moves to Paused.
5. **Reports**: Overflow → Reports. Overview and Categories show this month, and their totals equal
   the Expenses summary strip. Tap a donut slice to see the list below it. Trends shows the blurred
   preview, a lock, and a disabled "Get Pro"; there is no "Watch an ad". Choose a month 3 months back
   → locked (Q1).
6. **Dev unlock**: More → Developer → "Unlock all features (debug)" on. Reports Trends shows a
   solid and a dashed line, and Accounts shows two bar charts.
7. **Background**: in Android Studio, App Inspection → Background Task Inspector → find
   `expense.recurring` for `com.midexcode.dailytrack` and run it. Due entries
   appear, and no duplicates appear on the next app open.

Prod check: `flutter run --flavor prod` → the More tab has no Developer section.

## 5. Acceptance criteria → automated tests

Test names start with the Screen ID (Constitution I).

| Criterion (verbatim) | Test |
| --- | --- |
| EXP-08 "Per day left" uses remaining days including today. | `test/features/expense/domain/budget_math_test.dart` (`EXP-08 per day left …`: first, middle, and last day of 28-, 30-, and 31-day months) + `presentation/budgets_screen_test.dart` (rendered text) |
| EXP-08 Copy last month does not overwrite budgets already set for this month. | `data/budget_repository_test.dart` (`EXP-08 copy last month keeps existing`) + `presentation/budgets_screen_test.dart` (snackbar count) |
| EXP-02 Budget alert fires once at 80% and once at 100% per category per month. | `domain/check_budget_alerts_test.dart` (≥ 50 sequences, overall + category, both thresholds in one save, drop and rise, restart, settings off, past month) + `data/budget_repository_test.dart` (concurrent marker compare-and-set) + `presentation/transaction_form_budget_alert_test.dart` |
| EXP-10 A monthly rule on the 31st runs on the last day of shorter months. | `domain/recurrence_test.dart` (31 Jan → 28/29 Feb → 31 Mar → 30 Apr …, 4 years) + `data/recurring_generator_test.dart` |
| EXP-10 If the app was not opened for 3 months, all missed entries are created once, with correct dates, and no duplicates. | `data/recurring_generator_test.dart` (`EXP-10 three-month gap`: every frequency; two concurrent `runDue`; app open + background task; rerun → 0 created) |
| EXP-11 Locked tabs show a blurred preview and a "Watch an ad to unlock for 24 hours" button. | `presentation/reports_screen_test.dart` (`EXP-11 locked tabs blurred preview`: overlay present, child excluded from semantics, "Get Pro" disabled, **no** "Watch an ad"). The button part is **deferred to feature 008** (spec US4 note) and tracked in `checklists/design-review.md` |
| EXP-11 Chart totals match the EXP-01 summary strip for the same period. | `presentation/reports_controller_test.dart` (view models vs ledger for month, week, year, custom) + `data/breakdown_test.dart` (sums = ledger at 10,000 rows) + `integration_test/expense_flow_test.dart` |

Derived scenarios (US1–US5) and edge cases each get at least one test in the matching
`*_screen_test.dart`, `*_controller_test.dart`, or domain test. `/speckit-tasks` lists them one by
one.

Other required tests:
- `core/feature_gate/drift_feature_gate_test.dart`: permanent, expiring (timer re-lock), clock moved
  back, revoke, debug switch on dev and ignored on prod.
- `domain/report_access_test.dart`: the full Q1 matrix.
- `app/bootstrap_test.dart`: `onAppOpen` runs without delaying the first route, the launch payload
  routing works, and a failure in `onAppOpen` is ignored.
- `app/background_dispatcher_test.dart`: the task is resolved by name, and a disabled module →
  `true`.
- `test/core/theme/no_hardcoded_style_test.dart`: the new import rules and `DateTime.now(`.
- Migration test (§3).

## 6. Performance checks (SC-004)

```powershell
flutter test test/features/expense/data/transaction_perf_test.dart
```

Extended with 10,000 rows:
- Save + budget check < 100 ms.
- `watchOverview` first emit < 500 ms.
- `watchBreakdown` for a year < 500 ms.
- Generator: 365 occurrences < 200 ms.

Device fps is checked manually.

## 7. Release-size check

```powershell
flutter build apk --flavor prod --release --split-per-abi
```

Expected: arm64 APK < 25 MB. The baseline after feature 002 is noted in its task summary.
`fl_chart` and `workmanager` are expected to add < 1 MB.

## 8. Integration test

```powershell
flutter test integration_test/expense_flow_test.dart --flavor dev
```

Spec §13 flow: add an expense → it appears on Home → it appears in Reports with matching totals.
Plus: set a budget → save over 80% → the fake notifier was called once.

## 9. Done checklist (per task)

- [ ] Quality gates (§1) green.
- [ ] Every criterion in §5 has a passing test.
- [ ] `checklists/design-review.md`: §15.10 per screen (EXP-08, EXP-09, EXP-10, EXP-11, and the
      changed EXP-01, EXP-02, EXP-03).
- [ ] `docs/spec.md` §14: T1.5, T1.6, and T1.7 checked.
- [ ] Task summary: files changed, tests added, checklist results, open items.
