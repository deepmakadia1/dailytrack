# Contract: `TrackerModule` (changes in feature 006)

File: `lib/core/module/tracker_module.dart` (+ new `insight.dart`, `insight_source.dart`, `dashboard_section.dart`).
Supersedes the feature 001 contract for the members listed here; all other members are unchanged.

## Declaration

```dart
abstract class TrackerModule {
  const TrackerModule();

  // ── unchanged (required) ──
  String get id;
  String displayName(BuildContext context);
  String tabLabel(BuildContext context);
  IconData get icon;
  IconData get selectedIcon;
  String get rootPath;
  List<RouteBase> get routes;
  Widget dashboardCard(BuildContext context);
  BackupSection? backupSection();
  List<Seeder> get seeders;
  Future<void> onEnable(ProviderReader read);
  Future<void> onDisable(ProviderReader read);
  Future<void> onAppOpen(ProviderReader read);
  Map<String, BackgroundTask> get backgroundTasks;

  // ── changed: was `QuickAddAction? quickAddAction()` ──
  List<QuickAddAction> quickAddActions() => const [];

  // ── new, optional (feature 006) ──
  List<DashboardSection> dashboardSections() => const [];
  InsightSource? insights() => null;
  Widget? appBarBadge(BuildContext context) => null;
}
```

Modules use `extends TrackerModule` (was `implements`) and keep `const` constructors.

## Rules

- `quickAddActions()`: entries in the order they should appear within this module's part of the menu.
  Each `location` must be a route that the module owns or that lives above the shell.
- `dashboardSections()`: rendered after **all** module cards, grouped by module in the user's order.
  A section must hide itself (`SizedBox.shrink()`) when it has nothing to show. It must not add outer
  spacing, because Home's `DashboardSlot` adds the 12 dp gap only around non-empty content.
- `insights()`:
  - `ruleIds` is constant for a given app version.
  - `evaluate` reads only local data through `read`, makes no network calls, never throws, and
    returns at most one `Insight` per rule id.
  - Insight text is localized with `l10nFor(settings.locale)`.
- `appBarBadge()`: a widget at most 48 dp tall with its own semantic label and tap target. Home shows
  the badges in module order in the app bar actions.
- A disabled module contributes nothing: Home calls these members only on `registry.visible(settings)`.
- Home and every file under `lib/features/dashboard/` interact with modules **only** through these
  members (enforced by the import scan, research R17).

## Implementations in this feature

| Module | `quickAddActions()` | `dashboardSections()` | `insights()` | `appBarBadge()` |
| --- | --- | --- | --- | --- |
| Expense | Add expense (`/expenses/add?type=expense`), Add income (`?type=income`) | `expense.recentTransactions` | `ExpenseInsightSource` (3 rules) | null |
| Habit | Check in habit (`/habits`) | none | `HabitInsightSource` (3 rules) | `StreakFlameBadge` |
| `FakeTrackerModule` (tests) | configurable, default `[]` | configurable | configurable | configurable |

## ARB keys moved or added for quick add

- `expense_quickAdd` stays "Add expense".
- New: `expense_quickAddIncome` "Add income".
- `habit_quickAddCheckIn` is unchanged.
