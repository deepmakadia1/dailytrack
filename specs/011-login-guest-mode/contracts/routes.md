# Contract: Routes and redirects

Changes to `lib/app/router/routes.dart` and `lib/app/router/app_router.dart`, matching `docs/spec.md` §5.

| Screen | Name | Path | Opens as |
| --- | --- | --- | --- |
| AUTH-01 | `Routes.login` / `RouteNames.login` | `/login` | Top-level `GoRoute`, full screen, no back arrow; Android back closes the app |
| ACC-04 | — | — | Dialog (`AccountUi.showLogOutGuest`) |

## `redirectFor` (pure; `authMode` passed in, read from `authModeProvider`)

Evaluated in this order; the first rule that returns a location wins.

| # | Condition | Result |
| --- | --- | --- |
| 1–2 | Startup not ready / on splash | unchanged (splash, then `initialLocation`) |
| 3 | `!onboardingDone` and location ≠ `/onboarding` | `/onboarding` (the SYS-04 `settingPin` exception is removed) |
| 3b **new** | `onboardingDone`, `authMode == none`, location ∉ {`/splash`, `/login`} | `/login` |
| 3c **new** | location == `/login`, `authMode != none` | `/home` (rule 4 then adds SYS-03 when locked) |
| 4 / 4b | lock rules | apply only when `authMode != none` |
| 5 | disabled module route | unchanged |
| 6 | onboarding done, on `/onboarding` | `/login` when `authMode == none`, else `/home` |
| 7 **new** | location starts with `/more/account`, `authMode != google` | `/more` |

`initialLocationFor(settings, launchPayload)`: `/onboarding` → else `/login` when `authMode == none` (payload dropped) → else `Routes.lockPath(from: target)` when locked → else target.

Refresh: `appRouter` adds `ref.listen(authModeProvider, …)` to the refresh notifier.

## Navigation effects

- Intro "Get started"/Skip: `completeOnboarding` → rule 6 → `/login` (replaces Intro).
- AUTH-01 → Home: setting `authMode` triggers rule 3c; no `context.go` in the screen.
- ACC-03 (either choice), ACC-04: setting `authMode = none` triggers rule 3b from wherever the user is; the stack is replaced.
- ACC-01 open when the account stops being `google` (revoked, Switch account cancelled): rule 7 sends the user to SET-01. The `router.go(Routes.more)` calls in `account_screen.dart` and `sign_out_sheet.dart` are removed (interim I4).
- Pause notification payload `Routes.account` while not `google`: rule 7.

## Ads

`router_ad_screen_probe.dart`: `/login` is not a reading screen, so no banner or interstitial trigger counts it; a test asserts `maybeShowInterstitial` is never called while `/login` is the current location (AUTH-01 AC, §11), including right after ACC-04.

## Tests

`test/app/router/redirect_test.dart`: one case per row above, plus the SYS-01 AC combinations (onboarding × `authMode` × lock) and the restart cases from ACC-03/ACC-04 ACs.
