# Contract: Developer "Seed 10,000 transactions"

## Core API (`lib/core/module/`)

```dart
// dev_action.dart: pure enough for core; IconData is the only Flutter type.
final class DevAction {
  const new({
    required this.id,          // 'expense.seed10k'
    required this.labelKey,    // 'more_seedTransactions'
    required this.confirmKey,  // 'more_seedConfirm'
    required this.icon,
    required this.run,
  });
  final String id;
  final String labelKey;
  final String confirmKey;
  final IconData icon;
  final Future<DevActionResult> Function(
    ProviderReader read,
    void Function(double fraction) onProgress,
  ) run;
}

sealed class DevActionResult {}
final class DevActionDone extends DevActionResult { DevActionDone(this.count); final int count; }
final class DevActionBusy extends DevActionResult {}

// tracker_module.dart, new optional member. The reader lets a module check
// debugToolsAvailableProvider, like contributeGlance and handleAction do.
List<DevAction> devActions(ProviderReader read) => const [];
```

## SET-01 Developer section (dev flavor only)

| Element | Key | Behavior |
|---|---|---|
| Row per action | `dev_<id>`, e.g. `dev_expense.seed10k` | title from `labelKey`; tap → confirm dialog |
| Confirm dialog | `dev_confirm`, buttons `dev_confirm_ok` / `dev_confirm_cancel` | body from `confirmKey`; Cancel does nothing |
| Progress | `dev_progress` (a `LinearProgressIndicator` in the row) | fraction from `onProgress`; the row is disabled while it runs |
| Result | SnackBar `dev_done` | `more_seedDone(count)`: "Added {count} transactions" |
| Busy | SnackBar `dev_busy` | `more_seedBusy`: "A backup or restore is running. Try again when it finishes." |

- The section isn't built in prod (`debugToolsAvailableProvider == false`).
- `ExpenseModule.devActions(read)` also returns `const []` when `read(debugToolsAvailableProvider)` is false, so the action
  isn't reachable in prod.

## Strings (`tool/l10n/phase0_strings.py`, en/hi/gu)

`more_seedTransactions`, `more_seedConfirm`, `more_seedDone` (`{count}` int, formatted with the
locale's number format), `more_seedBusy`.

## Seeder (`lib/features/expense/data/dev/large_data_seeder.dart`)

Rules are in [data-model.md](../data-model.md) §5. Tests:
- **Unit test over a real in-memory database**:
  - the count;
  - the type mix within ±2%;
  - every amount an `int` within bounds;
  - every `occurredAt` within the last 365 days;
  - transfers with two distinct accounts;
  - the same output for the same seed;
  - no budget alert or notification calls;
  - `dataChangeCounter` goes up (the database triggers raise it per row);
  - a second run adds another 10,000;
  - Erase all data removes them;
  - busy → `DevActionBusy` and no rows.
- **Widget test (fakes)**: the row shows in dev; confirm → progress → snackbar; Cancel → no run; the
  section and row are absent with `debugToolsAvailable = false`.
