# Route Contracts

| Screen | Path | Navigator | Notes |
| --- | --- | --- | --- |
| PRM-01 Premium | `/premium` | root (`parentNavigatorKey: rootNavigatorKey`) | Full-screen modal (`fullscreenDialog: true`). `Routes.premium` constant. Reached from the SET-01 premium card, every "Get Pro", and PRM-02 "Get Pro instead" |
| PRM-02 Rewarded unlock | — | — | Bottom sheet through `showRewardedUnlock` (no route, spec §5) |

**Rules**:
- `Routes.premium` is added to `lib/app/router/routes.dart`, which stays import-free.
- `AdScreenProbe.nonReadingRoutes` (composition root) contains:
  - `Routes.splash`, `Routes.onboarding`, `Routes.lock`, `Routes.premium`, `Routes.pin`
  - every path ending in `/add` or `/edit`
  - `Routes.expenseRecurringAdd` and `Routes.expenseRuleEdit`

  Everything else, including `/home`, counts as a reading screen (research R10).
- **Deep links**: none. A notification or widget launch never opens `/premium`.
- **Lock interplay**: `/premium` behaves like any root route under the lock redirect. Opening the
  Play purchase dialog calls `expectExternalActivity()` first.
