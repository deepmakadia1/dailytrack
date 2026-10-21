# Contract: Screens in this feature (UI behavior contract)

Each screen has one Riverpod Notifier with a `freezed` state. Test names start with the Screen
ID, for example `SYS-02 user cannot turn off both modules`.

## SYS-01 Splash: `app/splash/` (route `/splash`)

§3 has no splash feature folder. SYS-01 is app bootstrap, so it lives next to
`app/bootstrap.dart`.

| State | UI |
| --- | --- |
| initializing | Logo centered on the theme background, app name below. No spinner for the first 300 ms. |
| failed | `ErrorState` with a plain-language message (`splash_errorMessage`) and "Retry" (`common_retry`). Retry runs bootstrap again. |
| ready | Router redirects to `initialLocation` (see [services.md](services.md#bootstrap)). |

No ads at any point.

## SYS-02 Onboarding: `features/onboarding/` (route `/onboarding`)

`OnboardingState { int step; String? languageCode; String currencyCode; List<String> enabled; String query; bool saving; }`

| Step | Content | Controls |
| --- | --- | --- |
| 1 Welcome | Illustration, headline `onboarding_welcomeTitle`, language chips (English, हिन्दी, ગુજરાતી, always shown in their own script) | Skip (top right), Next |
| 2 Currency | Search field and list from the currency table, INR preselected (device region IN, otherwise INR) | Skip, Next, Back |
| 3 Modules | Two toggle cards (Expense, Habit), both on. "Coming soon" row (Water, Period) disabled | Next, Back (no Skip) |
| 4 Privacy | "Your data stays on this device" text, "Allow notifications" button | "Get started" (primary), Back (no Skip) |

- A language chip writes the `locale` setting right away, so the UI switches instantly and the
  choice survives a restart even if onboarding is not finished.
- Turning off the last enabled module is rejected: the toggle stays on and an inline message
  (`onboarding_atLeastOneModule`) appears.
- "Allow notifications" calls `NotificationPermission.request()`. Every result (granted, denied,
  or an error) keeps the user on step 4. The button then shows the result as text.
- "Set app lock" is **not shown** in Phase 0 (spec Assumptions).
- "Get started" and "Skip" call `SettingsRepository.completeOnboarding`, and the router then goes
  to `/home`. Skip defaults: the device language if supported (otherwise en), INR, both modules on.
- A page indicator shows the current step out of 4. There are no ads.

## SET-06 Modules: `features/settings/` (route `/more/modules`)

`ModulesState { List<ModuleRow> rows; String? message; }` where `ModuleRow { id, enabled }`.

- `ReorderableListView` of registered modules in `moduleOrder`. Each row has a drag handle
  (semantic label `modules_reorderHandle`), a `CategoryAvatar` with the icon, the name, and a
  `Switch`.
- "Coming soon" section below: Water and Period, disabled switches, not reorderable.
- Toggle off: if the module is the last enabled one, the switch stays on and an inline message
  under the list shows `modules_atLeastOne`. This is the same pattern as SYS-02 step 3. A
  screen reader announces it through a `Semantics(liveRegion: true)` wrapper. Otherwise
  `setModules(...)` runs, then `module.onDisable()`. Toggle on works the same way with
  `onEnable()`.
- Reorder: `setModules(order: newOrder, ...)`. The nav bar and Home cards update right away
  because they watch the settings stream.
- States: loading (`DelayedSkeleton`), content. Error uses `ErrorState` with retry. There is no
  empty state, because the registry is never empty.
- No ads. SET-06 is not in the §11 placements.

## SYS-03 placeholder: `features/lock/` (route `/lock`)

`AppScaffold` with no back button (`PopScope(canPop: false)`), the title `lock_title`, and the
`EmptyState` message `lock_placeholderMessage`. No ads. T3.1 replaces it with the real screen.

## Placeholder tabs

See [routes.md](routes.md#placeholder-screens).
