# Contract: Routes and redirect rules (T3.1)

## New routes (`lib/app/router/routes.dart`)

| Screen | Path | Name | Navigator | Notes |
| --- | --- | --- | --- | --- |
| SYS-03 | `/lock?from=<location>` | `lock` | root, top-level | Existing path. `from` is optional and URL-encoded. `Routes.lockPath({String? from})` builds it. |
| SYS-04 | `/settings/security/pin?mode=set\|change\|disable&from=<location>` | `pin` | root, top-level | `Routes.pinPath(String mode, {String? from})` with `'set'`, `'change'`, or `'disable'` (a String, so `routes.dart` stays import-free and onboarding needs no `features/lock` import; the screen parses it into `PinFlowMode`). It is pushed, and leaves with `go(from)` (default `/more`), never `pop` (research R10). |
| SET-01 | `/more` | `more` | More branch | Existing. Now builds `SettingsScreen`; `MorePlaceholderScreen` is deleted. |
| SET-04 | `/more/themes` | `themes` | More branch, pushed | `Routes.themesSegment = 'themes'` |
| SET-05 | `/more/security` | `security` | More branch, pushed | `Routes.securitySegment = 'security'` |
| SET-06 | `/more/modules` | `modules` | More branch, pushed | Existing |
| Web page | `/more/web/:page` (`privacy`, `terms`) | `webPage` | root, pushed | Full screen with a back button. An unknown `:page` redirects to `/more`. |

`/more/backup` (SET-02) and `/more/export` (SET-03) are not added (feature scope).

## `redirectFor` (pure, `lib/app/router/app_router.dart`)

It gains `uri`, `sessionLocked`, `sessionMode`, and `coveredLocation` arguments (with defaults),
read from `lockSessionProvider`. The router's `refreshListenable` also listens to the session's
`locked` and `mode`. The rules run in order:

| # | Rule | Change |
| --- | --- | --- |
| 1–2 | Stay on the splash until bootstrap is ready; then leave the splash for `initialLocation` | unchanged |
| 3 | If onboarding is not done → `/onboarding`, **except** `/settings/security/pin` with `mode=set` or `mode=change` | exception added (research R10) |
| 4 | If `onboardingDone && lockEnabled && sessionLocked` and the location is not `/lock` → `/lock?from=<location>`, **except** in overlay mode for the exact location the overlay covers (`coveredLocation`), which stays as it is (research R7). A different location (a deep link) goes through `/lock`; that navigation replaces the screen history anyway, so the session switches to `route` mode and the overlay is removed. Notification taps never get here, because they are deferred | was "lockEnabled" alone; now needs `sessionLocked`, carries `from`, and keeps the covered location |
| 4b | If on `/lock` and (`!lockEnabled` or `!sessionLocked`) → `from` or `/home` | new: leaves the lock once unlocked, or if the lock was turned off by erase |
| 5 | A disabled module's routes → `/home` | unchanged |
| 6 | `/onboarding` once onboarding is done → `/home` | unchanged |

**`initialLocationFor`** (`lib/app/bootstrap.dart`): when lock is on, it returns
`Routes.lockPath(from: launchPayload ?? Routes.home)`. A tapped notification's target is no longer
dropped (it was dropped in T0.5, FR-019).

**While the overlay is showing**, the router keeps its location. A notification tap calls
`lockSession.deferLocation(payload)` instead of `router.go`. After unlocking, the app calls
`router.go(pending)` only if a location was deferred. Any other navigation goes through rule 4, as
above.

## `MaterialApp.router` wiring (`lib/app/app.dart`)

- It uses the `routerDelegate`, `routeInformationParser`, and `routeInformationProvider` of the
  `GoRouter`, plus `backButtonDispatcher: LockAwareBackButtonDispatcher(ref)`. While the session is
  locked, back calls `SystemNavigator.pop()` and returns `true`.
- The `builder` wraps the child in this order:
  1. `MediaQuery` with `AppTextScaler` (font size);
  2. when `session.locked && mode == overlay`: `Stack([Offstage(offstage: true, child: child),
     const UnlockScreen(mode: overlay)])`.
- `theme` and `darkTheme` come from `effectiveColorThemeProvider`, and `themeMode` from settings.
- `AppLifecycleListener` keeps `onResume` (`AppOpenRunner`) and adds:
  - `onHide`/`onPause` → `markBackgrounded`;
  - `onResume` → `onResumed` **before** `AppOpenRunner`, so a locked app shows SYS-03 before the
    first resumed frame.
