# Contract: Routes, HabitModule, bindings, and app wiring (feature 005)

## Routes (`lib/app/router/routes.dart`)

| Constant | Path | Name | Notes |
| --- | --- | --- | --- |
| `habits` | `/habits` | `habits` | HAB-01 (existing tab root) |
| `habitAdd` | `/habits/add` | `habitAdd` | HAB-02 new; query `template`; root navigator |
| `habitArchived` | `/habits/archived` | `habitArchived` | HAB-04; pushed in branch |
| `habitDetail` | `/habits/:id` | `habitDetail` | HAB-03; pushed in branch |
| `habitEdit` | `/habits/:id/edit` | `habitEdit` | HAB-02 edit; root navigator |

Helpers: `habitAddPath({String? template})`, `habitDetailPath(id)`, `habitEditPath(id)`. Segments
`add` and `archived` are declared before `:id`.

## HabitModule (`lib/features/habit/habit_module.dart`)

| Member | Behavior |
| --- | --- |
| `routes` | The 5 routes above (HAB-01 root first) |
| `dashboardCard` | `HabitDashboardCard()` |
| `quickAddAction` | `QuickAddAction(labelKey: 'habit_quickAddCheckIn', icon: Icons.check_circle, location: Routes.habits)` |
| `backupSection` | `null` (stub until T3.2) |
| `seeders` | `[]` |
| `onEnable` | `refreshTimeZone()` then `HabitReminderScheduler.reconcileAll()` |
| `onDisable` | `HabitReminderScheduler.cancelAll()` |
| `onAppOpen` | same as `onEnable` (time-zone changes, day rollover, reboot catch-up) |
| `backgroundTasks` | `{}` |

## Bindings (`lib/features/habit/habit_bindings.dart`)

`habitOverrides()` binds `habitRepositoryProvider`, `habitEntryRepositoryProvider`,
`habitReminderSchedulerProvider` to Drift and local implementations (the scheduler is
`NoopHabitReminderScheduler` from `data/reminders/` until T069 binds `LocalHabitReminderScheduler`);
included in
`productionOverrides()` after `expenseOverrides()`. `features/habit/presentation/habit_providers.dart`
declares the providers typed to domain interfaces (throwing until overridden), plus
`streakEngineProvider` (built from `clockProvider` and `appSettings.firstDayOfWeek`) and
`habitDayWriterProvider`.

## App wiring

- `production_overrides.dart`: channel labels for `habitReminders`; `imageSharerProvider` default
  is the real one.
- `lib/app/module_registry.dart`: `HabitModule` already registered; no change.
- Notification taps with payload `/habits` use the existing tap routing.

## Layering scan (extended: `test/core/theme/no_hardcoded_style_test.dart`)

- `features/habit/domain/**` imports no `package:flutter`, `package:drift`, or `data/`.
- `features/habit/presentation/**` imports no `data/`, `package:drift`, `package:share_plus`,
  `package:flutter_local_notifications`, or `package:timezone`.
- `package:fl_chart` only in `features/*/presentation/widgets/charts/`.
- `package:share_plus` and `package:path_provider` (share use) only in `core/share/` (and the
  existing `expense_bindings.dart` composition for receipts).
- `package:timezone` and `package:flutter_local_notifications` only in `core/notifications/`.
- `app_database.dart` may import `features/habit/data/tables/*` and `features/habit/domain/enums.dart`
  (extending the existing exception).
- No `DateTime.now()` in `lib/` (existing rule).
