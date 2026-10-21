# Contract: Routes and navigation shell

**Location**: `lib/app/router/routes.dart` (single source of paths and names; constants only and import-free, so it is the one `lib/app/` file features may import), `lib/app/router/app_router.dart` · **Spec**: §5, FR-016 to FR-020, FR-026

## Route table (Phase 0)

| Name | Path | Screen | Opens as | Owner |
| --- | --- | --- | --- | --- |
| `splash` | `/splash` | SYS-01 Splash | Full screen | app |
| `onboarding` | `/onboarding` | SYS-02 Onboarding | Full screen | `features/onboarding` |
| `lock` | `/lock` | SYS-03 placeholder | Full screen, back blocked | `features/lock` |
| `home` | `/home` | DSH-01 placeholder | Shell branch 0 | `features/dashboard` |
| `expenses` | `/expenses` | EXP-01 placeholder | Shell branch (module) | `ExpenseModule.routes` |
| `habits` | `/habits` | HAB-01 placeholder | Shell branch (module) | `HabitModule.routes` |
| `more` | `/more` | SET-01 placeholder | Shell branch (last) | `features/settings` |
| `modules` | `/more/modules` | SET-06 Modules | Push inside More branch | `features/settings` |

## Redirect rules (evaluated in order)

1. If bootstrap is not ready, go to `/splash`.
2. If bootstrap failed, stay on `/splash`, which renders the error state.
3. If `!onboardingDone` and the location is not `/onboarding`, go to `/onboarding`.
4. If `onboardingDone`, `lockEnabled`, and the location is not `/lock`, go to `/lock`. In Phase
   0 this only applies at startup. Locking again after the app returns from background is T3.1.
5. If the location belongs to a module that is not enabled, go to `/home`.
6. If the location is `/splash` or `/onboarding` after they are complete, go to `/home`.

`refreshListenable` fires when the bootstrap state or the settings change.

## Shell (`AppShell`)

- `StatefulShellRoute.indexedStack` has branches `[home, ...registry.all (registry order), more]`.
  They are built once.
- `NavigationBar` destinations are `[Home, ...registry.visible(settings), More]`. Labels are
  always shown, the selected tab uses the filled icon, and the bar is 80 dp tall.
- Tapping a destination calls `goBranch(branchIndexOf(destination))`. Tapping the active tab pops
  it to its root.
- Back button: on a non-Home tab root, go to the Home branch. On Home, the app exits.

## Placeholder screens

Each placeholder uses `AppScaffold` with a localized title and an `EmptyState` ("Coming in a
later update"). The More placeholder adds a list tile "Modules" that opens `/more/modules`.
Home lists `dashboardCard()` for each visible module, in order.
