# Implementation Plan: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Branch**: `003-budgets-recurring-reports` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-budgets-recurring-reports/spec.md`

## Summary

This feature completes Phase 1 of the Expense module (`docs/spec.md` §14, T1.5–T1.7) on top of
feature 002:

- **T1.5 Budgets**:
  - EXP-08 and the EXP-09 sheet: overall and per-category monthly budgets, a live spent/remaining
    view, "per day left", "Copy last month's budgets", and rollover on the first app open of a
    month.
  - Budget alerts after each EXP-02 save, at 80% and 100%, once each per budget per month, for the
    current month only (Q2). A raised limit re-arms an alert (Q4).
- **T1.6 Recurring**:
  - The EXP-02 Repeat section, including turning Repeat on while editing an unlinked entry (Q3),
    and rule-edit mode, where Repeat off deletes the rule (Q5).
  - The EXP-10 list with pause, resume, and delete.
  - An exactly-once generator, run on app open and from a daily `workmanager` job.
  - A repeat icon in EXP-01 and a rule link in EXP-03.
- **T1.7 Reports**: EXP-11 with Overview, Categories, Trends, and Accounts, drawn with `fl_chart`
  from controller-built view models. The totals reuse the EXP-01 ledger.
- **Gating**: a core `FeatureGate` with the `unlocks` table. Free and advanced follow the Q1
  matrix. The `LockedFeatureOverlay` has a disabled "Get Pro" and no "Watch an ad". There is a
  dev-only "Unlock all features" switch.

**Approach**:
- Schema v2 → v3 adds 3 tables and rebuilds `transactions` to add the rule foreign key (R3).
- Time comes only from `package:clock` (R2).
- Money math is in pure-Dart use cases (R5, R8).
- Writes that must happen exactly once use compare-and-set inside Drift transactions on a shared
  isolate (R6, R9).
- `TrackerModule` gains `onAppOpen` and `backgroundTasks` hooks driven by a `ProviderReader`, so
  modules stay `const` and core never imports a feature (R10).

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Existing: `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0,
  `drift` 2.35 + `drift_flutter` 0.3, `freezed` 4.0, `intl` 0.20, `uuid` 4.6,
  `flutter_local_notifications` 22.3.
- **New** (research R1): `clock` ^1.1.3 (was transitive), `workmanager` ^0.10.10, `fl_chart`
  ^1.2.0.

**Storage**: SQLite through Drift `AppDatabase`, **schema v3**: + `recurring_rules`, `budgets`,
`unlocks`; `transactions` gains a foreign key. The database is shared across isolates. New settings
keys, with no schema change. See [data-model.md](data-model.md).

**Testing**:
- `flutter_test`: unit tests (real in-memory Drift), widget tests (fakes, `NoAdsService`, fake
  gate, fake notifier), and Linux goldens.
- `mocktail`, and `SchemaVerifier` for v1/v2 → v3 with data.
- `integration_test` (the §13 Reports flow).

**Target Platform**: Android API 24+ (iOS-ready code, not tested)

**Project Type**: Mobile app (single Flutter project)

**Performance Goals** (spec SC-004, Constitution V):
- Save + budget check < 100 ms.
- EXP-08 and each EXP-11 tab first content < 500 ms at 10,000 transactions. CI measures these on
  the host as a stand-in (data-layer first emit, same thresholds); the mid-range reference device
  is a Snapdragon 6-series or equivalent with 4 GB RAM, checked once by hand in T106.
- Generator: 365 catch-up rows < 200 ms.
- First screen never waits for app-open work.
- APK < 25 MB per ABI.

**Constraints**:
- Offline, with no data leaving the device. Notifications are local and carry only the category
  name and a percentage.
- No ads, and no Export action.
- `int` paise everywhere. UTC ms storage, local-calendar months.
- ARB text in en, hi, and gu, including notification text produced without a `BuildContext`.
- 200% font scale and 360 dp width. Charts have text legends and semantic summaries.

**Scale/Scope**:
- 4 new screens/sheets (EXP-08, EXP-09, EXP-10, EXP-11) and 4 changed (EXP-01, EXP-02, EXP-03, the
  More placeholder).
- 3 new tables and 1 rebuilt table.
- 3 new core services (gate, notifications, background) and 1 changed interface (`TrackerModule`).
- About 110 new ARB keys × 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs in files, tests, and commits; spec updated before code | ✅ Clarifications Q1–Q5 and the design-level §4 additions (`recurring_rules.anchorAt` and `toAccountId`, one live budget per slot, alert reset, `featureKey` as text) are recorded in `docs/spec.md` (Changes 2026-10-15, Open item 1 done) |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; one notifier per screen; registry | ✅ FeatureGate, unlocks, notifications, and background are in `core/` (user request). Expense uses them through core interfaces. Charts are only in `presentation/widgets/charts/`. The `TrackerModule` hooks take a `ProviderReader`, so core never imports a feature. `features/settings` reads `debugToolsAvailableProvider`, not `app/flavor.dart`. One notifier each for EXP-08, 09, 10, 11 |
| III. Data integrity & privacy | int paise; UTC ms; soft delete; migration + test; no egress | ✅ All new tables have `deletedAt` and CHECKs. The v2→v3 migration (with a table rebuild) is tested with data from v1 and v2. Notifications are local and contain no amounts or notes. No new network use |
| IV. Test-backed acceptance | ≥ 1 test per criterion; ≥ 80% domain/data; fakes + NoAdsService; goldens for EXP-01/02 | ✅ The map is in [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests). Recurring-rule and budget-threshold unit tests are explicitly required by the constitution and planned exhaustively. The EXP-01 and EXP-02 goldens are updated. ⚠️ One criterion is only partly testable now (EXP-11 "Watch an ad" button), see Complexity Tracking |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; 3 languages; 48 dp; 200%; never color only | ✅ Every screen uses the 4 states. Charts get legends, value labels, and `Semantics` summaries. Budget levels get text or icons. Perf tests at 10,000 rows. §15.10 review per screen |
| VI. Isolated monetization | ads only via AdService; none on forms; rewarded only from PRM-02 | ✅ by exclusion. No ad code and no rewarded flow. The overlay's "Watch an ad" is not built. EXP-08's native ad and EXP-11's banner are deferred (Complexity Tracking) |
| VII. Locked stack, YAGNI | §2 packages only; additions justified | ✅ All 3 additions are in §2 and named by the user (R1). `timezone` is not added (no scheduled notifications yet). Interval UI and per-week budgets are not built. Ad-related gate sources are deferred to T4.4 |

**Result**: PASS. **After Phase 1 design**: PASS. The design added a core `TrackerModule` hook
change and `debugToolsAvailableProvider` specifically to keep Principle II intact. Deviations are
listed below.

## Project Structure

### Documentation (this feature)

```text
specs/003-budgets-recurring-reports/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R17
├── data-model.md        # Phase 1: schema v3, entities, validation, state transitions
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── repositories.md        # Expense domain interfaces, ports, use cases, Q1 matrix
│   ├── core_services.md       # Clock, FeatureGate, notifications, background, TrackerModule, settings
│   ├── screens.md             # EXP-08/09/10/11 + changed EXP-01/02/03 and More
│   └── routes_and_module.md   # routes, ExpenseModule hooks, bindings, app wiring, scan rules
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
  main.dart                                   # Workmanager init; uses production_overrides.dart
  app/
    production_overrides.dart                 # NEW (moved from main.dart) + gate, notifications, scheduler, debug flag
    background_dispatcher.dart                # NEW @pragma('vm:entry-point')
    bootstrap.dart                            # + notifications init, launch payload, onAppOpen
    app.dart                                  # + AppLifecycleListener resume → onAppOpen; taps → router
    router/routes.dart                        # + budgets, recurring, recurring/add, rule edit, reports
  core/
    background/                               # NEW background_scheduler.dart, workmanager_background_scheduler.dart, providers
    database/
      app_database.dart                       # v3, + 3 tables, from2To3, shared isolate, busy_timeout
      app_database.steps.dart                 # regenerated
      tables/unlocks_table.dart               # NEW
    feature_gate/                             # NEW
      domain/{feature_key,unlock,unlock_repository,feature_gate}.dart
      data/{drift_unlock_repository,drift_feature_gate}.dart
      feature_gate_providers.dart             # + debugToolsAvailableProvider
    module/tracker_module.dart                # onEnable/onDisable(read), + onAppOpen, backgroundTasks, ProviderReader
    notifications/                            # + notification_service.dart, app_notification.dart, local_notification_service.dart
    settings/                                 # + 4 AppSettings fields, module-state read/write
    utils/clock.dart                          # DELETED (package:clock)
    utils/clock_provider.dart                 # returns package:clock Clock
    utils/date_keys.dart, widgets/period_selector.dart   # DateTime.now() → clock
    widgets/locked_feature_overlay.dart       # optional onWatchAd, nullable onGetPro, message
  features/expense/
    expense_module.dart                       # + routes, onAppOpen, backgroundTasks, onEnable/onDisable
    expense_bindings.dart                     # + budget/rule repositories, notifier, gate
    domain/
      enums.dart                              # + Frequency
      entities/                               # + budget, budget_status, recurring_rule, repeat_settings,
                                              #   expense_breakdown, budget_alert
      repositories/                           # + budget_repository, recurring_rule_repository; transaction_repository + watchBreakdown
      ports/                                  # NEW budget_alert_notifier, notification_gate
      usecases/                               # + budget_math, validate_budget, check_budget_alerts, recurrence,
                                              #   generate_recurring, report_access; validate_transaction (repeat)
      errors.dart                             # + BudgetSlotTaken, BudgetNotFound, RuleNotFound, TransactionAlreadyLinked
    data/
      tables/{budgets,recurring_rules}_table.dart   # NEW; transactions_table.dart + FK, index
      daos/{budgets,recurring_rules}_dao.dart       # NEW; transactions_dao + breakdown
      mappers/{budget,recurring_rule}_mapper.dart   # NEW
      repositories/drift_{budget,recurring_rule}_repository.dart  # NEW
      notifications/{local_budget_alert_notifier,settings_notification_gate}.dart  # NEW
    presentation/
      expense_providers.dart                  # + providers for new repositories/ports/use cases
      controllers/                            # + budgets_, budget_form_, recurring_, reports_ controllers/states;
                                              #   report_view_models.dart (pure builders); transaction_form_* (repeat, modes)
      screens/                                # + budgets_screen (EXP-08), recurring_screen (EXP-10), reports_screen (EXP-11)
      widgets/                                # + budget_sheet (EXP-09), budget_row, overall_budget_card, repeat_section,
                                              #   recurring_row; transaction_row (repeat icon)
      widgets/charts/                         # NEW: income_expense_bar, category_donut, trend_line, breakdown_bars (only fl_chart importers)
  features/settings/presentation/screens/more_placeholder_screen.dart  # + dev switch
  features/habit/habit_module.dart            # hook signature updates (no-ops)
drift_schemas/app_database/drift_schema_v3.json  # NEW
tool/l10n/phase0_strings.py                   # + expense_budget*, expense_recurring*, expense_report*, notif_*, premium_*
test/
  helpers/{mutable_clock.dart, fakes.dart, test_app.dart}   # clock helper, fake gate/notifier/scheduler/notification service
  core/feature_gate/, core/notifications/, core/background/  # NEW
  core/theme/no_hardcoded_style_test.dart     # + import and DateTime.now rules
  features/expense/{domain,data,presentation}/   # see quickstart §5
  drift/app_database/migration_test.dart       # + v1/v2 → v3 with data
  app/{bootstrap_test, background_dispatcher_test}.dart
  goldens/                                    # EXP-01/02 updated; EXP-08, EXP-11 overview, overlay
integration_test/expense_flow_test.dart       # + Reports and budget-alert flow
```

**Structure Decision**: a single Flutter project following `docs/spec.md` §3. Budgets, recurring
rules, and reports live under `lib/features/expense/` and FeatureGate plus `unlocks` under
`lib/core/`, as requested. Additions not named in §3:
- `core/feature_gate/` and `core/background/`: shared services, in the same style as `core/ads`.
- `features/expense/domain/ports/`: interfaces for side effects (notifications, settings) that the
  domain needs.
- `lib/app/production_overrides.dart` and `lib/app/background_dispatcher.dart`: the composition
  root, split so the workmanager isolate can build the same container.

## Implementation order (input for /speckit-tasks)

1. **Pre-work**:
   - `flutter pub add` the 3 packages.
   - Move to `package:clock` (R2): delete `core/utils/clock.dart`, update the 15 importers and 3
     tests, fix the 2 `DateTime.now()` calls, and add the scan rule.
   - Add ARB keys, then `gen-l10n`.
2. **Foundation (blocks all stories)**:
   - Schema v3: tables, `make-migrations`, `from2To3`, the migration test with data, the shared
     isolate.
   - Settings additions.
   - `TrackerModule` hook changes (Expense and Habit), `Bootstrap` and lifecycle `onAppOpen`,
     `production_overrides.dart`.
   - Core notifications service, core background scheduler and dispatcher.
   - Core FeatureGate + unlocks repository.
   - `LockedFeatureOverlay` change.
   - Test fakes and helpers.
3. **US1 Budgets (P1)**: `budget_math` → `BudgetRepository` (slot uniqueness, copy, rollover,
   limit-change clearing) + `watchBreakdown` → EXP-08 controller and screen → EXP-09 sheet →
   overflow entry → the 2 EXP-08 criteria plus scenarios. **Checkpoint**.
4. **US2 Alerts (P1)**: `BudgetAlertChecker` + compare-and-set markers → `LocalBudgetAlertNotifier`
   + `SettingsNotificationGate` → EXP-02 save hook → tap routing → the EXP-02 alert criterion
   (≥ 50 sequences). **Checkpoint**.
5. **US3 Recurring (P2)**: `RecurrenceSchedule` (exhaustive) → `RecurringRuleRepository` +
   `generateDue` (compare-and-set) → `RecurringGenerator` → `ExpenseModule.onAppOpen` and
   `backgroundTasks` → EXP-02 Repeat section and modes → EXP-10 → EXP-01 icon and EXP-03 link → the
   2 EXP-10 criteria. **Checkpoint**.
6. **US4 Reports free (P2)**: `ReportAccess` → view-model builders → `ReportsController` → Overview
   and Categories tabs and charts → the "totals match" criterion. **Checkpoint**.
7. **US5 Advanced + gate (P3)**: Trends and Accounts tabs, the locked overlay wiring, the period
   lock icons, and the dev switch on More → the locked-preview criterion (partial, see Complexity
   Tracking).
8. **Finish**:
   - Goldens (Linux), the a11y sweep at 200%.
   - §15.10 review in `checklists/design-review.md`.
   - Perf tests, APK size, the integration test.
   - `docs/spec.md` §14 checkboxes T1.5–T1.7.
   - Task summary.

## Open items (resolve before or during implementation)

1. ✅ **Done 2026-10-15: `docs/spec.md` §4 updated** (Constitution I):
   - `recurring_rules`: add `toAccountId` (transfers) and `anchorAt` (first occurrence; month-end
     correctness, R8).
   - `budgets`: "one live budget per category (or Overall) per month"; alert markers reset on a
     limit change, already in EXP-09.
   - `unlocks`: `featureKey` is stored as text because of `premiumTheme_{name}`.
2. **EXP-11 "Watch an ad" criterion**: tested and checked off in feature 008. Keep it unchecked in
   `docs/spec.md` until then.
3. **Notification deep link with app lock on**: Bootstrap sends a locked user to `/lock`, and the
   payload is dropped. T3.1 (real SYS-03) must forward a pending location after unlock.
4. **SET-01 toggles**: the Budget alerts and notifications master settings exist with default on,
   but have no UI until T3.1.
5. **Golden baselines**: Linux only (carried over). EXP-01/02 baselines are regenerated, and EXP-08,
   EXP-11, and the overlay are new.
6. **Native-speaker review** of new hi/gu strings, especially ordinal day phrases ("Every month on
   5th"), which use ICU `selectordinal` where the language supports it, and a "day {n}" form
   otherwise.
7. **Device checks**:
   - Workmanager actually runs daily on a physical device with battery optimization on (SC-006 is
     best effort, and the operating system controls timing).
   - Notification appearance on Android 13+ and 8–12.
8. **Backups**: T3.2 must include `budgets`, `recurring_rules`, and `unlocks` (the purchase-sourced
   rows) and the new settings keys, excluding `latestSeenAt` and `debugUnlockAll`.
9. **Play data-safety form**: record the Android permissions `workmanager` adds (T001) and confirm
   that none of them needs a data-safety declaration change.
   - Recorded 2026-10-17 from `build/app/intermediates/merged_manifest/devDebug/.../AndroidManifest.xml`
     (`workmanager` 0.10.10, `workmanager_android` 0.10.9): `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`,
     `ACCESS_NETWORK_STATE` (WorkManager itself), `FOREGROUND_SERVICE`, and
     `FOREGROUND_SERVICE_SHORT_SERVICE` (the plugin, for expedited work).
   - None is removed with `tools:node="remove"`: WorkManager reads network state internally, and
     `shortService` needs no Play declaration. The `dataSync` FGS type is opt-in and not enabled.
   - None of these collects or shares user data, so the data-safety answers are unchanged.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `core/database/app_database.dart` imports `features/expense/data/tables/{budgets,recurring_rules}_table.dart` (core → feature) | Carried over from features 001 and 002: Drift needs every table in one `@DriftDatabase` for atomic cross-table writes (generator + rule compare-and-set, rule creation + first occurrence) and `SchemaVerifier` | Same as before: moving Expense tables to core breaks feature ownership, and separate databases break atomicity. `unlocks` lives in core, so it adds no new exception. The scan still allows only `app_database.dart` → `data/tables/*` |
| EXP-11 criterion "Locked tabs show … a 'Watch an ad to unlock for 24 hours' button" is only partly satisfied (Constitution IV: every criterion tested) | The user put rewarded ads and the "Watch an ad" action out of scope until feature 008 | Building the button without a working rewarded flow would show a dead control (§15.1 "Forgiving") and pull `AdService`/PRM-02 forward. The blurred-preview half is tested now, and the button half is an explicit feature 008 obligation (Open item 2) |
| EXP-08 ships without its native ad and EXP-11 without its banner, though §11 lists them | All ads are out of scope ("and all ads") | Adding ads now needs T4.1 consent and `AdService`. The slots take no space when empty, so adding them later causes no layout change |
| `recurring_rules.anchor_at` and `to_account_id` are columns not in spec §4 | Month-end rules (EXP-10 criterion 1) need the original day, and recurring transfers need a destination account | Deriving the anchor from `nextRunAt` loses the day after a clamped month (31 → 30). Disallowing recurring transfers would contradict EXP-02, where Repeat is available for every type. Spec §4 was updated first (Open item 1, done) |
| FR-019 deep link with app lock on opens `/lock` only; EXP-08 is not opened after unlock | The real SYS-03 lock flow, which owns post-unlock navigation, is built in T3.1 | Building a pending-location hand-off against the placeholder lock screen would be rewritten in T3.1. Never bypassing the lock is the safe behavior now. T3.1 is obligated to add forwarding (Open item 3) |
