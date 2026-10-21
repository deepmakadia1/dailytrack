# Contract: TrackerModule and ModuleRegistry

**Location**: `lib/core/module/tracker_module.dart`, `lib/core/module/module_registry.dart`, `lib/app/module_registry.dart` · **Spec**: §3, FR-014, FR-015, FR-025

```dart
/// Implemented by every tracker (Expense, Habit; later Water, Period).
abstract interface class TrackerModule {
  /// Stable id persisted in settings (`enabledModules`, `moduleOrder`). Never change it.
  String get id;                                   // 'expense', 'habit'

  /// Localized display name (resolved from ARB via the passed context).
  String displayName(BuildContext context);

  /// Localized bottom-navigation label ("Expenses"), from the "Tab label key" column below.
  /// Separate from displayName ("Expense"), which SYS-02 and SET-06 show. Added in T084.
  String tabLabel(BuildContext context);

  IconData get icon;                               // outlined (inactive tab)
  IconData get selectedIcon;                       // filled (active tab)

  /// Root path of the module's tab branch, e.g. '/expenses'. Every route the module owns
  /// MUST live under this prefix so the router can redirect it when the module is disabled.
  String get rootPath;

  /// go_router routes for the module's tab branch (root route first).
  List<RouteBase> get routes;

  /// Card shown on Home (DSH-01). Placeholder card in Phase 0.
  Widget dashboardCard(BuildContext context);

  /// Global "+" action for this module. Null when the module has none yet (Phase 0).
  QuickAddAction? quickAddAction();

  /// Backup section: JSON export/import of the module's own tables. Phase 0: returns null.
  BackupSection? backupSection();

  /// One-time data seeders (run once each by SeedRunner, regardless of enabled state).
  List<Seeder> get seeders;

  /// Called when the user enables/disables the module (schedules/cancels notifications).
  /// MUST NOT delete data. Phase 0 implementations are no-ops.
  Future<void> onEnable();
  Future<void> onDisable();
}

final class QuickAddAction {           // label + icon + route to push
  const QuickAddAction({required this.labelKey, required this.icon, required this.location});
  final String labelKey; final IconData icon; final String location;
}

abstract interface class BackupSection { /* defined in T3.2; declared empty in Phase 0 */ }
```

`TrackerModule` is a UI-composition contract, so it lives in `core/module/` and may import
Flutter. Pure-domain pieces such as `Seeder` and `BackupSection` stay Flutter-free.

```dart
// lib/core/database/seeding.dart
abstract interface class Seeder {
  String get id;                                   // e.g. 'expense.defaults.v1'; bump suffix to reseed new data
  Future<void> seed(AppDatabase db);               // runs inside SeedRunner's transaction
}
```

## ModuleRegistry

```dart
// lib/app/module_registry.dart. This is the only file that imports concrete modules. It holds nothing else.
final registeredModules = <TrackerModule>[ExpenseModule(), HabitModule()];
// main.dart: ProviderScope(overrides: [moduleRegistryProvider.overrideWithValue(ModuleRegistry(registeredModules))])

// lib/core/module/module_registry.dart. Features import this file, never lib/app/module_registry.dart,
// so there is no app <-> features import cycle.
/// Display-only rows shown as "Coming soon" in SYS-02 step 3 and SET-06.
const comingSoonModules = <ComingSoonModule>[
  ComingSoonModule(id: 'water', nameKey: 'modules_water'),
  ComingSoonModule(id: 'period', nameKey: 'modules_period'),
];

@Riverpod(keepAlive: true)
ModuleRegistry moduleRegistry(Ref ref) =>
    throw UnimplementedError('moduleRegistryProvider must be overridden in main() / tests');

class ModuleRegistry {
  List<TrackerModule> get all;                                          // registry order
  TrackerModule? byId(String id);
  /// Enabled modules in the user's order (moduleOrder ∩ enabledModules).
  List<TrackerModule> visible(AppSettings settings);
  /// Module owning [location], if any (prefix match on rootPath).
  TrackerModule? owning(String location);
}
```

## Phase 0 implementations

| Module | id | rootPath | Tab label key | Dashboard card | Seeders |
| --- | --- | --- | --- | --- | --- |
| `ExpenseModule` (`features/expense/expense_module.dart`) | `expense` | `/expenses` | `nav_expenses` | Placeholder `SummaryCard` | `ExpenseDefaultsSeeder` |
| `HabitModule` (`features/habit/habit_module.dart`) | `habit` | `/habits` | `nav_habits` | Placeholder `SummaryCard` | none |

## Guarantees (tested)

1. Adding a module means one new folder plus one entry in `registeredModules`. The router, Home,
   SET-06, and SYS-02 need no edits (SC-008).
2. Disabling a module calls `onDisable()` exactly once and never deletes rows.
3. `onEnable()` / `onDisable()` are not called during SYS-02. Onboarding only writes the initial
   setting, and nothing is scheduled yet.
