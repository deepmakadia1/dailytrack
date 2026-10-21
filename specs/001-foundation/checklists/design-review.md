# Design review: Foundation (Phase 0) screens (T106)

**Checklist**: `docs/spec.md` §15.10, applied per screen · **Reviewed**: 2026-10-14

**Evidence used for every screen**:
- Tokens: `test/core/theme/no_hardcoded_style_test.dart` scans `lib/features/`, `lib/core/widgets/` and `lib/app/` for color literals, `Colors.*` and raw `EdgeInsets.all(<n>)`. It passes.
- 200% font scale and 360 dp width: `test/a11y/font_scale_test.dart` (T104). Every screen below is pumped at 2× text in en, hi and gu on a 360×800 surface. No overflow, and `androidTapTargetGuideline` and `labeledTapTargetGuideline` pass.
- Strings: every user-facing string comes from the ARB files (generated from `tool/l10n/phase0_strings.py`). A scan of `lib/` for string literals in `Text`, `label`, `tooltip`, `semanticLabel`, `hintText`, `title` and `message` finds none.
- TalkBack order: all screens are single-column layouts with no custom `sortKey`s, so the reading order follows the visual order top to bottom. This was checked by reading the widget trees, not by an automated test.
- Ads: no Phase 0 screen has an ad slot. SYS-01, SYS-02, SET-06 and `/lock` are ad-free by §11. `NoAdsService` is the only `AdService`.

## SYS-01 Splash (`lib/app/splash/splash_screen.dart`)

- [x] Uses only `AppTokens` and shared components (`ErrorState`); no hard-coded colors, sizes, or text styles.
- [x] Main task takes three taps or fewer; one primary action visible. No taps on the happy path, and one (Retry) on the error path.
- [x] Loading, empty, error, and content states implemented and tested. Initializing and error are covered by `test/app/splash/splash_screen_test.dart`, ready by `test/app/app_smoke_test.dart`. Empty doesn't apply: there is no data to list.
- [x] Works at 200% font scale and on a 360 dp-wide screen without clipping or overflow (T104, error state).
- [ ] Light and dark golden tests pass, in English and Gujarati. `test/goldens/screens_golden_test.dart` (T110) covers initializing and error × light/dark × en/gu. **The baselines aren't generated yet** (Linux only, T102/T110). Check this item after they are committed and pass.
- [x] All touch targets ≥ 48 dp; all icons have semantic labels; TalkBack order is logical (T104 guidelines).
- [x] Destructive actions follow the undo-vs-confirm rule. There are no destructive actions.
- [x] Ad placements match section 11; no layout shift. There are no ads.
- [x] All strings come from ARB files and use placeholders, not concatenation.

## SYS-02 Onboarding (`lib/features/onboarding/`)

- [x] Uses only `AppTokens` and shared components (`ChipSelector`, `CategoryAvatar`, `ErrorState` pattern).
- [x] Main task takes three taps or fewer; one primary action visible. Skip finishes onboarding in 1 tap. The full path is the 4 steps that `docs/spec.md` SYS-02 specifies. Each step has a single primary `FilledButton` (Next / Get started).
- [x] Loading, empty, error, and content states implemented and tested. The content is the 4 steps. Saving disables the primary button and shows progress. The save error has Retry (T063). The empty state is the currency search with no matches, with a clear action (T063). There is no full-screen loading, because settings are local (FR-024).
- [x] Works at 200% font scale and on a 360 dp-wide screen without clipping or overflow (T104, all 4 steps, en/hi/gu).
- [ ] Light and dark golden tests pass, in English and Gujarati. T110 covers steps 1–4 and the step 3 "at least one module" message. **Baselines are pending** (Linux, T102/T110).
- [x] All touch targets ≥ 48 dp; all icons have semantic labels; TalkBack order is logical (T104). The step 3 message is announced through `Semantics(liveRegion: true)`.
- [x] Destructive actions follow the undo-vs-confirm rule. There are none: every choice can be changed later in settings.
- [x] Ad placements match section 11; no layout shift. There are no ads on onboarding (§11).
- [x] All strings come from ARB files and use placeholders, not concatenation (`onboarding_stepLabel` uses `{current}`/`{total}`).

## SET-06 Modules (`lib/features/settings/presentation/screens/modules_screen.dart`)

- [x] Uses only `AppTokens` and shared components (`AppScaffold`, `CategoryAvatar`, `ErrorState`, `DelayedSkeleton`/`SkeletonList`).
- [x] Main task takes three taps or fewer; one primary action visible. Toggling or reordering a module is 1 tap or 1 drag from the screen, 2 taps from More. The screen has no primary button; each row's switch is its action.
- [x] Loading, empty, error, and content states implemented and tested. Loading shows the skeleton only after 300 ms, and the error state has Retry (`test/features/settings/modules_screen_test.dart`). The content is covered by the T086 tests. Empty doesn't apply, because the registry is never empty (contracts/screens.md).
- [x] Works at 200% font scale and on a 360 dp-wide screen without clipping or overflow (T104).
- [ ] Light and dark golden tests pass, in English and Gujarati. T110 covers the default and Habit-disabled states. **Baselines are pending** (Linux, T102/T110).
- [x] All touch targets ≥ 48 dp; all icons have semantic labels; TalkBack order is logical. The drag handles are 48 dp and labelled "Reorder {name}" (T086). The switches are labelled by their row title. The "at least one" message is a live region.
- [x] Destructive actions follow the undo-vs-confirm rule. Disabling a module is not destructive: it keeps all data (T087) and is undone by toggling again.
- [x] Ad placements match section 11; no layout shift. SET-06 is not a §11 placement.
- [x] All strings come from ARB files and use placeholders, not concatenation (`modules_reorderHandle` uses `{name}`).

## Placeholders: Home (DSH-01), Expenses (EXP-01), Habits (HAB-01), More (SET-01), `/lock` (SYS-03)

These follow the justified deviation in [plan.md Complexity Tracking](../plan.md#complexity-tracking), row "Placeholder screens". Each one is replaced by its owning task: EXP-01 in T1.3, HAB-01 in T2.3, DSH-01 in T2.5, and SET-01 and SYS-03 in T3.1. Those tasks bring the notifier, all four states and the goldens.

- [x] Uses only `AppTokens` and shared components (`AppScaffold`, `EmptyState`, `SummaryCard` cards on Home).
- [x] Main task takes three taps or fewer; one primary action visible. The only actions are tab switches and More → Modules (1 tap).
- Loading, empty, error, and content states: **not passing, by justified deviation** (plan.md Complexity Tracking). Placeholders implement content and empty states only. They load no data, so there is no loading or error condition.
- [x] Works at 200% font scale and on a 360 dp-wide screen without clipping or overflow (T104 covers all four tabs and `/lock` in en/hi/gu).
- Light and dark golden tests: **not passing, by justified deviation** (plan.md Complexity Tracking). Golden baselines come with each replacing screen.
- [x] All touch targets ≥ 48 dp; all icons have semantic labels; TalkBack order is logical (T104 guidelines; the nav bar is 80 dp tall).
- [x] Destructive actions follow the undo-vs-confirm rule. There are none.
- [x] Ad placements match section 11; no layout shift. There are no ads in Phase 0, and `/lock` must never show ads (§11).
- [x] All strings come from ARB files and use placeholders, not concatenation.

The third deviation in that plan.md row, having no Riverpod notifier (Principle II), isn't a §15.10 item. It is recorded here for completeness and ends with the same replacing tasks.

## Open

- The golden item for SYS-01, SYS-02 and SET-06 is checked once T102 and the T110 baselines are generated on Linux and pass.
