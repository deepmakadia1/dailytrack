# Contract: Routes, ExpenseModule, bindings, and app wiring (feature 003)

## Routes (`lib/app/router/routes.dart`)

Static segments are declared before `:id` (feature 002 R10).

| Constant | Path | Name | Screen |
| --- | --- | --- | --- |
| `expenseBudgets` | `/expenses/budgets` | `expenseBudgets` | EXP-08 (query `month=yyyy-MM`, optional) |
| `expenseRecurring` | `/expenses/recurring` | `expenseRecurring` | EXP-10 |
| `expenseRecurringAdd` | `/expenses/recurring/add` | `expenseRecurringAdd` | EXP-02, new with Repeat on |
| `expenseRuleEdit` | `/expenses/recurring/:ruleId/edit` | `expenseRuleEdit` | EXP-02 rule-edit |
| `expenseReports` | `/expenses/reports` | `expenseReports` | EXP-11 |

Helpers: `expenseBudgetsPath({String? month})` and `expenseRuleEditPath(String ruleId)`. EXP-09 is a
bottom sheet with no route. EXP-02 routes open on the root navigator as full-screen modals (same as
feature 002). EXP-08, EXP-10, and EXP-11 push within the Expenses branch.

## ExpenseModule (`lib/features/expense/expense_module.dart`)

- `routes`: the existing ones plus the five above.
- `onAppOpen(read)`, in order, each step in its own `try/catch`:
  1. `read(budgetRepositoryProvider).rolloverIfNeeded(monthKeyOf(read(clockProvider).now()))`
  2. `read(recurringGeneratorProvider).runDue()`
  3. `read(backgroundSchedulerProvider).ensureDaily(ExpenseModule.recurringTaskName)` where
     `recurringTaskName = 'expense.recurring'`
- `backgroundTasks`: `{ 'expense.recurring': (read) async { rollover; runDue; return true; } }`.
  Rollover also runs here, so a month change while the app is closed is handled.
- `onDisable(read)`: cancels `expense.recurring` and calls `budgetAlertNotifier.cancelAll()`.
- `onEnable(read)`: `ensureDaily` then `onAppOpen(read)`.
- `dashboardCard`, `quickAddAction`, `backupSection` (still `null`), and `seeders`: unchanged.

## Bindings (`lib/features/expense/expense_bindings.dart`)

Adds overrides for `budgetRepositoryProvider`, `recurringRuleRepositoryProvider`,
`budgetAlertNotifierProvider` (`LocalBudgetAlertNotifier(notificationService, settings,
categoryNames)`), and `notificationGateProvider`. `budgetAlertCheckerProvider` and
`recurringGeneratorProvider` are plain providers in `expense_providers.dart` that compose those
ports and need no override.

## App wiring

| File | Change |
| --- | --- |
| `lib/app/production_overrides.dart` | **new**; `productionOverrides()` moved from `main.dart`. Adds `featureGateProvider`, `unlockRepositoryProvider`, `notificationServiceProvider`, `backgroundSchedulerProvider`, `debugToolsAvailableProvider` |
| `lib/main.dart` | `Workmanager().initialize(backgroundDispatcher)` through `initializeBackground()` from `core/background`, then `runApp` |
| `lib/app/background_dispatcher.dart` | **new**; `@pragma('vm:entry-point')` callback (research R10) |
| `lib/app/bootstrap.dart` | after settings: `notificationService.initialize()` (non-blocking); `launchPayload()` → initial location when allowed; `unawaited(onAppOpen)` for enabled modules |
| `lib/app/app.dart` | `AppLifecycleListener(onResume: …onAppOpen…)` and the `notificationService.taps` → `router.go` subscription |
| `lib/core/database/app_database.dart` | v3, new tables, `from2To3`, shared isolate, busy timeout |
| `android/app/src/main/AndroidManifest.xml` | nothing for `workmanager` (it merges its own manifest). `POST_NOTIFICATIONS` already present (feature 001) |

## Layering scan (extended: `test/core/theme/no_hardcoded_style_test.dart`)

- `app_database.dart` may import `features/expense/data/tables/{budgets,recurring_rules}_table.dart`
  (an extension of the Complexity Tracking exception).
- `package:workmanager` only in `core/background/workmanager_background_scheduler.dart` and
  `app/background_dispatcher.dart`.
- `package:fl_chart` only in `features/expense/presentation/widgets/charts/`.
- `package:flutter_local_notifications` only in `core/notifications/local_*.dart`.
- No `DateTime.now(` in `lib/`. Today it appears in `core/utils/date_keys.dart` (`nowUtcMs`) and `core/widgets/period_selector.dart`; both move to an injected `Clock` or `clock.now()`.
- `features/settings` does not import `app/flavor.dart`; it uses `debugToolsAvailableProvider`.
