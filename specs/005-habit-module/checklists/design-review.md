# Design review: Habit module screens (§15.10)

**Feature**: 005-habit-module · **Task**: T097 · **Date**: 2026-10-19 (clock in tests: 2026-10-21)

Each screen was checked against the nine items of `docs/spec.md` §15.10. Results are evidence-based:
an item is **Pass** only when an automated test or a code scan covers it. **Not verified** means the
check cannot run on the Windows development host. **Partial** means part of the item is covered.

Legend: ✅ Pass · ⚠️ Partial · ⏳ Not verified here · ➖ Not applicable

## Results

| # | §15.10 item | HAB-01 | HAB-02 | HAB-03 | HAB-04 | Milestone sheet | Home card |
|---|---|---|---|---|---|---|---|
| 1 | Only `AppTokens` and shared components; no hard-coded colors, sizes, or text styles | ✅ | ✅ | ⚠️ ¹ | ✅ | ⚠️ ² | ✅ |
| 2 | Main task ≤ 3 taps; one primary action visible | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Loading, empty, error, and content states implemented and tested | ✅ | ⚠️ ³ | ⚠️ ⁴ | ⚠️ ⁴ | ➖ | ✅ |
| 4 | 200% font scale and 360 dp wide, no clipping or overflow | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 5 | Light and dark goldens pass, English and Gujarati | ⏳ ⁵ | ⏳ ⁵ | ⏳ ⁵ | ⏳ ⁵ | ⏳ ⁵ | ⏳ ⁵ |
| 6 | Touch targets ≥ 48 dp; icons labelled; logical TalkBack order | ⚠️ ⁶ | ⚠️ ⁶ | ⚠️ ⁶ | ⚠️ ⁶ | ⚠️ ⁶ | ⚠️ ⁶ |
| 7 | Destructive actions follow undo-vs-confirm | ✅ | ✅ | ✅ | ✅ | ➖ | ➖ |
| 8 | Ad placements match §11 and the ad UX rules; no layout shift | ✅ ⁷ | ✅ ⁷ | ✅ ⁷ | ✅ ⁷ | ✅ ⁷ | ✅ ⁷ |
| 9 | All strings from ARB with placeholders, no concatenation | ✅ ⁸ | ✅ | ✅ ⁸ | ✅ | ✅ | ✅ |

## Evidence

- **Item 1**: `test/core/theme/no_hardcoded_style_test.dart` scans all of `lib/features/` for color
  literals and raw paddings (green). Text styles come from `Theme.of(context).textTheme`. The
  layering scan (T004) confirms presentation imports no data, Drift, or plugin code.
- **Item 2**: SC-001 test "the Read chip then Save habit creates the habit in 2 taps"
  (`habits_today_screen_test.dart`). A check-in is one tap on HAB-01 and on the Home card. HAB-02
  has one filled button ("Save habit"); HAB-03's primary action is Edit in the app bar; HAB-04 has
  one filled (tonal) Restore per row.
- **Item 3**: HAB-01: skeleton only after 300 ms, empty state with templates, error with
  Try again, content (`habits_today_screen_test.dart`, FR-023). Home card: empty, nothing today,
  error, content (`habit_dashboard_card_test.dart`). HAB-04: empty, error, content
  (`archived_habits_screen_test.dart`). HAB-03: error and content
  (`habit_detail_screen_test.dart`).
- **Item 4**: `test/a11y/habit_font_scale_test.dart` (T094): every screen at 200% on 360×800 in
  en, hi, and gu, scrolled top to bottom where long. Any overflow fails the test. 27/27 green.
  This check found the week-strip days at 39 dp wide. HAB-01 now gives the strip the full width
  (51 dp per day) and moves the week-page button to its own row.
- **Item 5**: `test/goldens/habit_screens_golden_test.dart` (T093): HAB-01 with 5 habits in
  light/dark × en/gu, and HAB-01 empty, HAB-02, HAB-03 (locked chart), HAB-04, and the milestone
  sheet in light/dark en. All 14 scenarios build. The baselines must be generated and compared on
  Linux (`flutter test --tags golden --update-goldens`), as for every existing golden in the repo;
  none exist yet.
- **Item 6**: the same a11y test checks `androidTapTargetGuideline` (48 dp) and
  `labeledTapTargetGuideline` on every screen, and both pass. Building the Home-card test found that
  four custom buttons (week-strip day, calendar day, count `+`, Home check) excluded their own tap
  action from semantics, so TalkBack could not activate them. Each now has its own semantics node
  with `onTap`/`onLongPress`. Status is never shown by color alone: check icon plus "Done",
  snowflake plus "Freeze day", "missed" in calendar semantics.
- **Item 7**: Confirm: delete a habit with history (HAB-02 overflow, HAB-04 Delete permanently)
  uses `ConfirmDialog` naming the history. Undo (5 s): uncheck, Skip today, archive (HAB-01 and
  HAB-02), restore (HAB-04), use a freeze (HAB-03). All covered by widget tests.
- **Item 8**: no ad is requested or built (FR-049); `bannerSlot` is null on HAB-01, HAB-03, and
  HAB-04 (tests). Ads are out of scope in this feature, so the only check is that layout stays
  stable without them.
- **Item 9**: every visible string is an ARB key in en/hi/gu (`tool/l10n/phase0_strings.py`) with
  ICU placeholders and plurals ("3 of 5 done", "1 week", "21-day streak!"). The status text no
  longer joins a "·" separator to a localized string; it is its own text widget.

## Notes and open items

1. **HAB-03 heatmap**: the per-month screen-reader lines use 1×1 dp invisible semantics nodes (a
   layout size, not a style). The heatmap's cell size comes from the available width, not a token.
2. **Milestone sheet**: the share card has a fixed logical size (320×200, rendered at 3×) so the
   shared PNG looks the same on every device (research R12). This is deliberate and kept.
3. **HAB-02**: the edit-mode load error (`loadError`) and the delayed skeleton have no widget test
   (the fake repository cannot fail `byId`). The not-found path is tested.
4. **HAB-03 / HAB-04**: the 300 ms delayed skeleton is shared (`DelayedSkeleton`) and tested on
   HAB-01, but not separately on these screens.
5. **Golden baselines**: generate on Linux CI (T093 stays open until they are committed).
6. **TalkBack order**: reading order follows the visual top-to-bottom layout, but "logical order"
   needs a manual TalkBack pass on a device (quickstart §4, with T098).
7. **Weekday lists** ("Mon, Wed, Fri") join localized day names with ", ". This is list formatting,
   not sentence concatenation; a locale-aware list format can replace it if a reviewer prefers.
8. **Deferred by scope** (spec Out of scope, T4.2–T4.4): HAB-01 native and banner ads, HAB-03 and
   HAB-04 banners, the HAB-02 interstitial after saving a new habit, and "Watch an ad to get a
   freeze". The `LockedFeatureOverlay` on the weekly chart shows no "Watch an ad" and a disabled
   "Get Pro" (tested).
