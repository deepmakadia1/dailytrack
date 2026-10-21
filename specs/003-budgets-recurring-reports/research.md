# Research: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Feature**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Date**: 2026-10-15

Each decision is written as Decision / Rationale / Alternatives considered. The Technical Context of
the plan had no open `NEEDS CLARIFICATION` items. Product questions were settled in the spec's
Clarifications (Q1–Q5). The items below settle how to build it.

---

## R1. New packages

**Decision**: add three direct dependencies, all listed in `docs/spec.md` §2 or named by the user.
Versions come from `flutter pub add --dry-run` on 2026-10-15:

| Package | Version | Why | Layer |
| --- | --- | --- | --- |
| `clock` | ^1.1.3 | All time logic (user request). Already in `pubspec.lock` as a transitive dependency, so it adds no code size | domain, data, presentation (pure Dart) |
| `workmanager` | ^0.10.10 | Daily recurring job (spec §2 "Background jobs", user request) | `core/background/` only |
| `fl_chart` | ^1.2.0 | Reports charts (spec §2 "Charts", user request). Brings `equatable` 2.1.0 transitively | `features/expense/presentation/widgets/charts/` only |

`timezone` is **not** added. Budget alerts are shown at once (`show`), never scheduled, so no
zoned scheduling is needed (YAGNI, Constitution VII). It arrives with habit reminders in T2.2.

**Rationale**: every package is on the locked stack list in §2. None is a state, routing, or database
alternative. `workmanager` and `fl_chart` stay behind one folder each, so the layering scan can
enforce where they are imported.

**Alternatives considered**: `android_alarm_manager_plus` (less reliable across reboots and Doze,
and not in §2); `syncfusion_flutter_charts` and hand-drawn `CustomPaint` charts (licence, size, and
effort; `fl_chart` is the §2 choice).

---

## R2. Moving to `package:clock`

**Decision**: replace the feature 002 home-grown `Clock` interface (`core/utils/clock.dart`:
`Clock`, `SystemClock`, `FixedClock`) with `package:clock`'s `Clock`.

- `clockProvider` (keep-alive, same name and file) now returns `package:clock`'s `Clock`. The
  production value is `const Clock()`, which reads the zone-aware `clock` global, so `withClock`
  works too.
- Tests override it with `Clock.fixed(...)` or a new `test/helpers/mutable_clock.dart`
  (`Clock(() => value)` with `advance`), replacing `FixedClock`.
- `core/utils/clock.dart` is deleted. Its 15 importers switch to `package:clock/clock.dart`. The 3
  test files that use `FixedClock` move to the helper.
- **Every** time read in `lib/` goes through an injected `Clock`. That includes repositories,
  use cases, controllers, the recurring generator, rollover, the feature gate, and the background
  task. A new scan test fails on `DateTime.now()` anywhere in `lib/`.
- Pure domain functions take `DateTime now` (or a `Clock`) as a parameter and never read the
  global.

**Rationale**: the user asked for the `clock` package for all time logic. Its `Clock` has the same
`now()` shape, so the switch is mechanical. It also works in the workmanager isolate, which has no
widget tree. Testing month boundaries, rollover, a 3-month gap, and unlock expiry all depends on
time being injected everywhere.

**Alternatives considered**: keeping the custom interface and only adding `package:clock` for new
code (two clock abstractions in one app). Calling the `clock` global directly everywhere (hidden
dependency, and Riverpod tests can't override it without zones).

---

## R3. Schema v2 → v3

**Decision**: one `stepByStep.from2To3` step, generated with `dart run drift_dev make-migrations`
(new snapshot `drift_schemas/app_database/drift_schema_v3.json`):

1. `createTable(recurring_rules)` plus index `recurring_rules_due (is_active, next_run_at)`.
2. `createTable(budgets)` plus index `budgets_month (month_key)` and the partial unique index
   `budgets_month_category_unique` (R4).
3. `createTable(unlocks)` plus index `unlocks_feature (feature_key)`.
4. `alterTable(TableMigration(schema.transactions))`. This rebuilds `transactions` from the frozen
   v3 snapshot so `recurring_rule_id` gains `REFERENCES recurring_rules(id)`. SQLite cannot add a
   foreign key to an existing column; this settles feature 002 research R3. Every row is copied
   unchanged (all `recurring_rule_id` values are NULL in v2).
5. Re-create the 3 existing transaction indexes if the rebuild dropped them, and add
   `transactions_rule (recurring_rule_id)`, used for EXP-03's link and for Undo of a new rule.

Foreign keys are switched off for the rebuild (`PRAGMA foreign_keys = OFF` before, then
`PRAGMA foreign_key_check` and `ON` after, all inside the migration), as Drift's docs recommend
for `alterTable`.

**Migration test** (`test/drift/app_database/migration_test.dart`):
- v1→v3 and v2→v3 with data. Settings, categories, accounts, and about 50 transactions of all 3
  types (with receipts and notes) come out byte-identical.
- The 4 transaction indexes exist, the foreign key is present (`PRAGMA foreign_key_list`), and the
  seed markers are untouched (no re-seed).
- `SchemaVerifier` validates against the v3 snapshot.

**Rationale**: a real foreign key matches the rest of the schema. Rules are soft-deleted, never
removed, so the key can never block a write. Rebuilding up to about 10,000 rows takes well under a
second, once.

**Alternatives considered**: integrity checked only in the repository (feature 002 R3 option b).
Rejected because the database is the cheapest place to guarantee it, and backups (T3.2) restore
rows without going through repositories.

---

## R4. Budget uniqueness and "Overall"

**Decision**: `budgets.category_id` NULL means Overall. Uniqueness among live rows is enforced by a
partial expression index declared with `@TableIndex.sql`:

```sql
CREATE UNIQUE INDEX budgets_month_category_unique
  ON budgets (month_key, IFNULL(category_id, ''))
  WHERE deleted_at IS NULL;
```

`month_key` has `CHECK (month_key GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]')`. `limit_minor` has
`CHECK (limit_minor BETWEEN 1 AND 99999999900)`.

Undo of a delete calls `undelete`. If the user created another budget for the same slot within the
5 seconds, the unique index rejects the undelete and the repository reports `BudgetSlotTaken`. The
snackbar then says the budget could not be restored (edge case, tested).

**Rationale**: a plain `UNIQUE(category_id, month_key)` treats NULLs as distinct, so it would allow
two Overall budgets, and it would block re-creating a budget after a soft delete.

**Alternatives considered**: a sentinel category id `'overall'` (would break the foreign key to
categories); checking only in the repository (racy across isolates, R9).

---

## R5. Budget math (pure domain)

**Decision**: `features/expense/domain/usecases/budget_math.dart`, all `int` paise:

- `spent`: sum of non-deleted **expense** rows in `[monthStart, nextMonthStart)` local, converted to
  UTC ms. Filtered by category, or all categories for Overall. Computed by one SQL `GROUP BY
  category_id` per month (R11), so EXP-08 makes one query, not one per budget.
- `remaining = limit − spent` (may be negative).
- `progress` levels: `under` (< 80%), `warning` (80–100%), `over` (> 100%), using integer
  comparisons: `spent * 100 >= limit * 80` and `spent >= limit`. Exactly 80% and exactly 100% count
  as reached (spec Edge Cases). `ProgressBarStatus` already takes these three levels.
- `daysLeftInclusive(today, month)`: from today to the last day, both included, for the current
  month. All days for a future month. Null for a past month (EXP-08 then shows the final result).
- `perDayLeft = remaining ~/ daysLeft` (rounded down, whole paise) when remaining > 0. Otherwise
  "no budget left".
- Percent text: `(spent * 100) ~/ limit` (whole percent, may exceed 100).

**Rationale**: whole paise and integer comparisons avoid all floating-point edge cases
(Constitution III). Keeping it pure makes the per-day-left criterion a plain unit test.

---

## R6. Budget alerts

**Decision**: `BudgetAlertChecker` (domain use case, `usecases/check_budget_alerts.dart`) with
ports `BudgetRepository`, `BudgetAlertNotifier` (domain interface), `NotificationGate` (reads the
two settings and the OS permission), and `Clock`.

`check({required int occurredAtUtcMs, required String? categoryId, required TxnType type})`:

1. Return if the type is not expense, or the entry is not in the **current** local month
   (clarification Q2).
2. Load the month's category budget (if `categoryId` has one) and the Overall budget. Compute
   spent for each (R5).
3. For each budget, decide the target: 100% if reached and `alert100SentAt` is null; else 80% if
   reached and `alert80SentAt` is null; else nothing.
4. Record the marker with a compare-and-set write in the repository:
   `UPDATE budgets SET alert100_sent_at = :now, alert80_sent_at = IFNULL(alert80_sent_at, :now)
   WHERE id = :id AND alert100_sent_at IS NULL` (and the same for 80%). **Only when exactly one row
   changed** does the checker go on to step 5. This stops the UI isolate and the background
   isolate from both alerting.
5. If `NotificationGate.allowed()` (notifications master on, budget alerts on, OS permission
   granted), call `notifier.notify(BudgetAlert(budgetId, monthKey, categoryId, threshold,
   percent))`.

Markers are recorded even when notifications are off (spec Edge Cases), so turning them back on
never sends old alerts.

- **Callers**: `TransactionFormController.save()` after a successful create or update. It runs
  `unawaited`, inside `try/catch`, so it never blocks or fails the save (FR-018). Also
  `RecurringGenerator`, for generated expenses dated in the current month (FR-029).
- **Limit change** (clarification Q4): `BudgetRepository.save` for an existing budget recomputes
  spent in the same transaction. It clears `alert80SentAt` if 80% is no longer reached and
  `alert100SentAt` if 100% is no longer reached.
- **Notification text**: built by the data-side `LocalBudgetAlertNotifier` from ARB through
  `lookupAppLocalizations`, using the saved locale (or the device locale). It works in the
  background isolate without a `BuildContext`. The body has only the category name (default names
  translated) and the percentage. It never contains amounts or notes (FR-020).
- **Notification id**: a stable 31-bit hash of `budgetId:threshold`, with tag `budget`, so
  `ExpenseModule.onDisable` can cancel all shown budget alerts. Payload:
  `/expenses/budgets?month=yyyy-MM`.

**Alternatives considered**: checking in a database trigger (cannot send notifications); checking
on the EXP-08 stream (misses saves while EXP-08 is closed); one alert per save without markers
(breaks "once per month").

---

## R7. Budget rollover and Copy last month

**Decision**:
- **Rollover** runs from `ExpenseModule.onAppOpen` (R10): on cold start and on every resume.
  1. `currentMonth = monthKey(clock.now())`. If the stored marker `expense.budgetRolloverMonth`
     equals it, stop.
  2. In one transaction: find the latest `month_key < currentMonth` that has live budgets. Copy its
     `rollover = true` budgets whose slot is empty in `currentMonth` (same limit, `rollover = true`,
     markers cleared). Write the marker.
- **Copy last month** (EXP-08 overflow): copies **all** live budgets of the month just before the
  selected month into empty slots, in one transaction. Returns the count for the snackbar.
- Both skip budgets whose category is hidden or deleted (spec Edge Cases).
- The marker is stored in the settings table under a module-state key through a new
  `SettingsRepository.readModuleState/writeModuleState` pair. It is namespaced
  `module.expense.budgetRolloverMonth`, next to the existing `seed.<id>` markers, with no schema
  change.

**Rationale**: the marker stops a deleted rolled-over budget from coming back on the next open in
the same month. Using the latest earlier month with budgets covers skipped months (spec
Assumptions).

**Alternatives considered**: creating next month's budgets ahead of time at month end (needs the
app open on the last day); no marker (deleted budgets come back).

---

## R8. Recurrence math

**Decision**: a pure `RecurrenceSchedule` (`usecases/recurrence.dart`) built from `anchorLocal`
(the first occurrence's local date and time), `frequency`, and `interval`:

- `occurrence(n)` for n ≥ 0, built with the local `DateTime(...)` constructor so wall-clock time
  survives DST and time zone changes:
  - daily: `(y, m, d + n·i, h, min)`
  - weekly: `(y, m, d + 7·n·i, h, min)`
  - monthly: month `m + n·i`, day `min(anchorDay, daysIn(month))`
  - yearly: year `y + n·i`, day `min(anchorDay, daysIn(Feb))` for 29 Feb
- Always computed **from the anchor**, never from the previous occurrence. So a rule on the 31st
  runs on 30 Apr and is back on 31 May (EXP-10 criterion 1).
- `indexAtOrAfter(DateTime t)`: an arithmetic estimate (days ÷ period length), corrected by at most
  ±2 steps. O(1) even for a daily rule 10 years behind.
- `describe()` returns a frequency enum plus weekday, day, or month numbers. Presentation turns it
  into ARB text with plural and ordinal placeholders ("Every month on 5th").

`recurring_rules.anchor_at` (UTC ms) is stored alongside the spec §4 fields, because the stored
`nextRunAt` alone loses the original day after a clamped month (31 → 30).

**Rationale**: month-end and leap-year rules are only correct when computed from the anchor. Exhaustive
unit tests cover every frequency over 4 years, plus DST dates (for a non-IST test zone) and 29 Feb.

---

## R9. Recurring generator: exactly once, across isolates

**Decision**: `RecurringGenerator.runDue()` (domain use case) using
`RecurringRuleRepository.generateDue(ruleId, now)`. The Drift implementation does, **per rule, in
one transaction**:

1. Re-read the rule. Skip it if it is deleted, inactive, or `next_run_at > now`.
2. From `n = indexAtOrAfter(nextRunAt)`, insert one transaction per occurrence while
   `occ(n) <= now` and `occ(n) <= endAt` (if set). Each row copies the template, gets a new UUID,
   `occurred_at = occ(n)`, and `recurring_rule_id`.
3. `UPDATE recurring_rules SET next_run_at = :newNext, is_active = :stillActive WHERE id = :id AND
   next_run_at = :oldNext` (compare-and-set). If 0 rows changed, throw `RuleChangedConcurrently`
   to roll back. Another run already handled it, so the generator skips the rule.
4. Return the created rows. After the transaction commits, the generator calls
   `BudgetAlertChecker` for created **expenses** dated in the current month (Q2).

- A rule whose next occurrence is after `endAt` becomes `is_active = false` with `ended = true`
  (derived: `!isActive && nextRunAt > endAt`). EXP-10 shows it in "Paused" as "Ended", and Resume
  is offered only after the end date is changed (edge case).
- Large catch-up (365 rows): one batch insert per rule, about 20 ms on a mid-range device. It runs
  off the UI frame because Drift runs queries on its background isolate.
- **Clock moved back**: `next_run_at` only ever moves forward, so nothing repeats. **Clock moved
  forward**: everything due is created.
- **Two isolates**: `AppDatabase.open()` switches to
  `driftDatabase(name: 'dailytrack', native: DriftNativeOptions(shareAcrossIsolates: true))`.
  Workmanager's Android engine runs in the same process, so both isolates share one Drift server,
  and transactions are serialized. When the app process is not running, the background isolate
  owns the database alone. The compare-and-set in step 3 covers any remaining case, such as a
  second process or an old engine. A `busy_timeout` of 5 s is set in `beforeOpen`.

**Alternatives considered**: a unique index on `(recurring_rule_id, occurred_at)` (rejected:
editing a generated entry's date onto another occurrence's date would fail); deterministic ids
`rule:n` (leaks a format into ids, and an edit then delete then regenerate cycle gets confusing).

---

## R10. App open, background job, and the module hooks

**Decision**: extend `TrackerModule` (core) with a host-agnostic reader, so modules stay `const`
and core never imports a feature:

```dart
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

Future<void> onEnable(ProviderReader read);   // was onEnable()
Future<void> onDisable(ProviderReader read);  // was onDisable()
Future<void> onAppOpen(ProviderReader read);  // NEW: cold start + every resume
Map<String, BackgroundTask> get backgroundTasks; // NEW: unique name → task
```

`ref.read` and `ProviderContainer.read` both fit `ProviderReader`. `HabitModule` gets no-op
implementations.

- **App open**: `Bootstrap._start()` (after seeding and loading settings) and an
  `AppLifecycleListener` in `app.dart` (on `resumed`) call `onAppOpen` for **enabled** modules.
  These calls are `unawaited`, and errors are caught and ignored, so they never delay the first
  screen (FR-025). A simple in-flight guard skips the call if the previous one is still running.
- `ExpenseModule.onAppOpen` runs, in order: budget rollover (R7), `RecurringGenerator.runDue()`
  (R9), and `BackgroundScheduler.ensureDaily('expense.recurring')` (keep policy, so it is a no-op
  if already registered).
- `onDisable` cancels the daily job and the shown budget notifications (tag `budget`).
  `onEnable` registers the job and runs `onAppOpen` (FR-043).
- **Background**: `core/background/background_scheduler.dart` (port) and
  `workmanager_background_scheduler.dart` (the only importer of `workmanager`). The periodic task
  runs every 24 h with no network constraint and `ExistingPeriodicWorkPolicy.keep`.
  `lib/app/background_dispatcher.dart` holds the `@pragma('vm:entry-point')` callback. It ensures
  the binding, builds a `ProviderContainer(overrides: productionOverrides())`, finds the task by
  name across enabled modules, runs it, disposes the container, and returns `true`. A failure
  returns `false` so the operating system retries with backoff. `productionOverrides()` moves from
  `main.dart` to `lib/app/production_overrides.dart` so both entry points share it.
- `Workmanager().initialize(backgroundDispatcher)` is called in `main()` before `runApp`.

**Rationale**: "every app open" plus the daily job are both in the spec. Resume counts as an open,
because a phone can keep the app in memory for days. A reader-based hook keeps modules declarative
and testable with a `ProviderContainer`.

**Alternatives considered**: a core `appOpenTasksProvider` list overridden by each feature's
bindings. This works for app open, but splits one module's lifecycle across two places, and
`onDisable` would still need dependencies.

---

## R11. Aggregation queries and "totals match EXP-01"

**Decision**: reuse the feature 002 ledger and add one breakdown stream to `TransactionRepository`:

- `watchLedger(TxnQuery)` (existing) gives income, expense, net, and per-local-day totals. Reports
  Overview and Trends use it with `TxnQuery(period: …)` and no filters. This is **exactly** what
  EXP-01's summary strip uses, so the totals match by construction (EXP-11 criterion 2).
- **New** `watchBreakdown(TxnQuery)` gives expense totals grouped by category, account, and payment
  mode. It runs three `GROUP BY` queries in one read transaction, all built from the **same**
  private `_whereFor(TxnQuery)` predicate builder as the ledger. A unit test asserts that the sum of
  each grouping equals the ledger's expense at 10,000 rows.
- EXP-08 uses `watchBreakdown` for the month (category totals plus the overall expense).
- Year trends: `PeriodLedger.dayTotals` folded into 12 monthly sums in the controller.

**Rationale**: one predicate builder means one definition of "in the period". Grouping in SQL keeps
each report under 500 ms at 10,000 rows (SC-004) using the `(category_id, occurred_at)` and
`(account_id, occurred_at)` indexes.

---

## R12. Chart data lives in controllers

**Decision** (user request): controllers produce **plain, ready-to-draw view models**. Widgets only
map them 1:1 to `fl_chart` objects and do no arithmetic, sorting, or grouping:

- `OverviewVm`: income, expense, net, `savingsRatePercent?`, `avgDailySpend?`, `topCategories`
  (≤ 3, with share percent).
- `DonutVm`: `slices` (categoryId, label input, colorKey, amount, percent, sorted desc). Slices under
  2% are merged into "Other" only when there are more than 8 slices. `selectedId`, plus the
  selected category's transactions.
- `TrendVm`: `current` and `previous` as `List<TrendPoint(x: int, yMinor: int)>`, `xLabels`,
  `maxY` (rounded up to a nice step), `granularity` (day or month).
- `BarsVm` (Accounts tab): `byAccount` and `byPaymentMode` as `List<BarItem(label input, amount)>`.

`fl_chart` types (`FlSpot`, `PieChartSectionData`, …) never appear in controller or state files; a
scan test enforces this. Amount axis labels come from the shared money formatter. Colors are
resolved in widgets from `AppTokens` and the category color key.

**Rationale**: data preparation is unit-testable without pumping charts, and the "totals match"
test runs against view models. Swapping or upgrading `fl_chart` touches widgets only.

---

## R13. FeatureGate and unlocks (core)

**Decision**: new `lib/core/feature_gate/`:

- `domain/feature_key.dart`: `FeatureKey` value class. Its `storageKey` is `exportCsv`,
  `exportPdf`, `advancedReports`, `adFreeDay`, `streakFreeze`, or `premiumTheme_<name>` (the
  `premiumTheme(name)` factory). The spec's enum has a parameterized member, so it is stored as
  `TEXT`.
- `domain/unlock.dart`: `Unlock` entity. `domain/unlock_repository.dart`: `watchActive`, `grant`
  (used from T4.4 on, and in tests), and `revoke`.
- `domain/feature_gate.dart`: the interface `Stream<bool> watch(FeatureKey)` and
  `Future<bool> isUnlocked(FeatureKey)`.
- `data/drift_feature_gate.dart`: a feature is unlocked if **(a)** `debugUnlockAll` is on and
  `debugToolsAvailable` is true, or **(b)** a live unlock row has no expiry or
  `expiresAt > effectiveNow`. `effectiveNow = max(clock.now(), latestSeenAt)`. `latestSeenAt` is a
  settings value raised (never lowered) on every evaluation and on app open (PRM-02 rule). `watch`
  combines the unlock stream and the settings stream, and also arms a `Timer` for the nearest
  expiry so the UI re-locks on time.
- Table `core/database/tables/unlocks_table.dart` (`unlocks`): this is in core, so no new
  core → feature import.
- `debugToolsAvailableProvider` (core, default `false`) is overridden in `productionOverrides()`
  with `!FlavorConfig.current.isProd`. The dev switch on the More placeholder writes
  `AppSettings.debugUnlockAll`. In prod the provider is false, so the switch is not built and the
  stored value is ignored (FR-041). A test runs both flavors.

**Rationale**: Habit (streak freeze), Themes, and Export reuse the gate later without touching
Expense (user request). Clock-rollback protection belongs in the gate, because every caller needs
it.

**Alternatives considered**: storing `FeatureKey` as `intEnum` (cannot carry theme names); storing
the debug override only in memory (lost on restart, annoying for QA).

---

## R14. `LockedFeatureOverlay` without ads

**Decision**: change the shared widget so `onWatchAd` is **optional**. When it is null, the button
is not built. Also make `onGetPro` nullable (null = disabled) and add an optional `message` line.
EXP-11 passes `onWatchAd: null, onGetPro: null`, with the message "Advanced reports are part of
Pro." Feature 008 passes real callbacks without another API change. Existing goldens for the overlay are
regenerated, and a new widget test asserts that no "Watch an ad" text exists and that "Get Pro" is
disabled and still announced by TalkBack.

---

## R15. Notifications in core

**Decision**: grow `lib/core/notifications/` from permission only into a small service:

- `notification_service.dart` (pure interface): `initialize()`, `canNotify()` (OS-level enabled
  check), `show(AppNotification)`, `cancelByTag(String)`, `Future<String?> launchPayload()`,
  `Stream<String> taps`.
- `AppNotification`: `id`, `channel` (enum `NotificationChannelId.budgetAlerts`; other §12 channels
  are added by their features), `title`, `body`, `payload`, `tag`.
- `local_notification_service.dart`: the only importer of `flutter_local_notifications` besides
  the existing permission class. It creates the "Budget alerts" Android channel (default
  importance) on `initialize()`.
- Tap routing (app layer): `app.dart` listens to `taps` and calls `router.go(payload)`. `Bootstrap`
  checks `launchPayload()`: if onboarding is done and lock is off, the payload becomes the initial
  location. If lock is on, the start is `/lock` as today. Forwarding the payload after unlock is
  recorded for T3.1 (plan Open item 3).
- `NotificationGate` (Expense domain port, R6) is implemented in Expense data by combining
  `SettingsRepository` and `NotificationService.canNotify()`.
- `AppSettings` gains `notificationsEnabled` (default true) and `budgetAlertsEnabled` (default
  true). They are stored now; their toggles arrive in SET-01 (T3.1).

---

## R16. Routes and EXP-02 modes

**Decision**: add under `/expenses`, with the static segments declared before `:id` (feature 002
R10):

| Route | Screen | Notes |
| --- | --- | --- |
| `/expenses/budgets?month=yyyy-MM` | EXP-08 | `month` optional (notification deep link) |
| `/expenses/recurring` | EXP-10 | |
| `/expenses/recurring/add` | EXP-02 | new entry with Repeat on (EXP-10 empty state) |
| `/expenses/recurring/:ruleId/edit` | EXP-02 rule-edit mode | |
| `/expenses/reports` | EXP-11 | |

`TransactionFormController` gains a `FormMode` (new, edit, ruleEdit) and a `repeat` sub-state
(`enabled`, `frequency`, `endDate`, `describe`). Rule-edit loads a `RecurringRule` and maps it to the
same draft shape. The date chip there means "next date". Saving sets a new anchor = the chosen date
and time, and `nextRunAt` = the first occurrence ≥ max(chosen, now) (spec: future occurrences
only).

Saving with Repeat:
- New entry: `RecurringRuleRepository.createWithFirstOccurrence(draft, schedule)` inserts the
  transaction and the rule in one transaction, then `generateDue(rule)`. The returned undo
  soft-deletes the rule and every row linked to it (the first occurrence included).
- Edit of an unlinked entry (Q3): `attachNewRule(txnId, draft, schedule)` updates the entry, creates
  the rule, and links it, then generates. The undo soft-deletes the rule and the generated rows,
  restores the entry snapshot, and clears its link.
- Rule-edit with Repeat off (Q5): soft-delete the rule, with Undo calling `undelete`.

---

## R17. Testing strategy specifics

- **Unit (real in-memory Drift, `makeRealContainer`)**: budgets CRUD, the unique slot, marker
  compare-and-set, limit-change clearing, rollover (marker, skipped months, hidden categories),
  copy (no overwrite); generator (every frequency, 31st, 29 Feb, 3-month and 1-year gaps,
  `endAt`, pause and resume, two concurrent `runDue` calls → no duplicates, clock moved back);
  breakdown sums = ledger at 10,000 rows (perf < 500 ms); `DriftFeatureGate` (permanent, expiry,
  clock moved back, debug switch on dev and prod).
- **Domain (pure)**: `budget_math`, `RecurrenceSchedule` (exhaustive), `BudgetAlertChecker` with
  fakes (≥ 50 save sequences, SC-003), report access rules (Q1 matrix), and view-model builders.
- **Widget (fake repositories, fake gate, fake notifier, `NoAdsService`)**: EXP-08, EXP-09, EXP-10,
  EXP-11 (each tab, locked and unlocked), EXP-02 Repeat (new, edit, rule-edit), EXP-01 repeat icon,
  EXP-03 rule link, and the More dev switch.
- **Migration**: R3.
- **Integration** (`integration_test/expense_flow_test.dart`, extended): add an expense → it shows in
  Reports with matching totals (spec §13 flow). Set a budget → an expense over 80% → the fake
  notifier is called.
- **Goldens (Linux)**: the EXP-01 and EXP-02 baselines are updated (repeat icon, Repeat toggle); new
  goldens are added for EXP-08 and EXP-11 Overview (not required by the constitution, but cheap
  regression cover) and for `LockedFeatureOverlay`.
- **Scans**: no `DateTime.now(` in `lib/`; `workmanager` imported only from `core/background/`;
  `fl_chart` only from `presentation/widgets/charts/`; `flutter_local_notifications` only from
  `core/notifications/`.
