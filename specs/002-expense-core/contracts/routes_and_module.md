# Contract: Routes and ExpenseModule

Extends feature 001's `contracts/routes.md` and `contracts/tracker_module.md`. Feature 001's
redirect rules are unchanged. Rule 5 (disabled module) covers every path below, because all of
them start with `ExpenseModule.rootPath` (`/expenses`).

## Route constants (`lib/app/router/routes.dart`, constants only)

| Constant | Path | Name | Screen | Navigator |
| --- | --- | --- | --- | --- |
| `Routes.expenses` | `/expenses` | `expenses` | EXP-01 | Expenses branch (tab root) |
| `Routes.expenseAdd` | `/expenses/add` | `expenseAdd` | EXP-02 new | **root**, `fullscreenDialog` |
| `Routes.expenseCategories` | `/expenses/categories` | `expenseCategories` | EXP-04 | branch push |
| `Routes.expenseAccounts` | `/expenses/accounts` | `expenseAccounts` | EXP-06 | branch push |
| `Routes.expenseDetail` | `/expenses/:id` | `expenseDetail` | EXP-03 | branch push |
| `Routes.expenseEdit` | `/expenses/:id/edit` | `expenseEdit` | EXP-02 edit | **root**, `fullscreenDialog` |

Children of `/expenses` are declared in the order add, categories, accounts, `:id` (with child
`edit`), so static segments win.

**Query parameters**

| Route | Param | Values | Effect |
| --- | --- | --- | --- |
| `/expenses` | `accountId` | account id | Replaces the session filter's accounts with `{id}` once on arrival (EXP-06 tap). Unknown ids are ignored |
| `/expenses/add` | `type` | `expense` (default) · `income` · `transfer` | Initial segment |
| `/expenses/add` | `duplicateOf` | transaction id | Prefill from that row with `occurredAt = now` and no receipt. A missing id opens an empty form |

Path helpers (`Routes.expenseDetailPath(id)`, `expenseEditPath(id)`, `expenseAddPath({type, duplicateOf})`)
are pure string functions in `routes.dart`.

## Root navigator key

`lib/core/module/root_navigator.dart` exports `final rootNavigatorKey = GlobalKey<NavigatorState>()`.
`app_router.dart` passes it as `GoRouter(navigatorKey: …)`. Today the router lets go_router create
its own key. EXP-02 routes set `parentNavigatorKey: rootNavigatorKey` (research R10).

The same file exports `rootMessengerKey = GlobalKey<ScaffoldMessengerState>()`, passed to
`MaterialApp.router(scaffoldMessengerKey: …)`. `UndoSnackBar` gains an optional `messenger`
parameter. Controllers' callers use `rootMessengerKey.currentState`, so a snackbar raised while
EXP-02 or EXP-03 is closing never uses a disposed `BuildContext`, and Undo shows on EXP-01 (R12).

## ExpenseModule (`lib/features/expense/expense_module.dart`)

| Member | Value / behavior | Spec |
| --- | --- | --- |
| `id` | `'expense'` (unchanged) | |
| `rootPath` | `/expenses` | |
| `routes` | The six routes above, EXP-01 first | FR-029 |
| `dashboardCard(context)` | `ExpenseDashboardCard()`, a `ConsumerWidget` backed by `ExpenseDashboardController`. Shows "Spent today" and "This month" through `AmountText`, tap → `context.go('/expenses')`. Empty state: "Add your first expense" → `/expenses/add`. No budget bar | FR-030 |
| `quickAddAction()` | `QuickAddAction(labelKey: 'expense_quickAdd', icon: Icons.add, location: '/expenses/add?type=expense')` | FR-031 |
| `backupSection()` | `null` (stub until T3.2) | FR-032 |
| `seeders` | `[ExpenseDefaultsSeeder()]` (unchanged) | FR-006 |
| `onEnable` / `onDisable` | No-ops (no notifications yet) | |

`expenses_placeholder_screen.dart` is deleted (feature 001 Complexity Tracking: "the replacing task
MUST remove its placeholder").

## Bindings (`lib/features/expense/expense_bindings.dart`)

```dart
List<Override> expenseOverrides() => [
  transactionRepositoryProvider.overrideWith((ref) => DriftTransactionRepository(ref.watch(appDatabaseProvider), ref.watch(clockProvider))),
  categoryRepositoryProvider.overrideWith(...),
  accountRepositoryProvider.overrideWith(...),
  receiptPickerProvider.overrideWith(...),   // image_picker + flutter_image_compress + path_provider
  receiptStoreProvider.overrideWith(...),
  defaultNameCatalogProvider.overrideWithValue(const L10nDefaultNameCatalog()),
];
```

`textSharerProvider` and `clockProvider` are core providers with real defaults, so they don't need
overrides. `main.dart` `productionOverrides()` adds `...expenseOverrides()`. Only `main.dart`
imports this file, which the import-scan test enforces.
