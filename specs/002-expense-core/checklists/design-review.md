# §15.10 Design Review: Expense Core (EXP-01 … EXP-07, Home Expense card)

**Feature**: [spec.md](../spec.md) · **Task**: T118 · **Reviewed**: 2026-10-14
**Gates at review time**: `flutter analyze` 0 issues · `dart format` 0 changed · `flutter test --exclude-tags golden` 533 passed · `flutter test integration_test --flavor dev` 3 passed (Android 16 emulator)

Legend: ✅ pass, with evidence · ⏳ not yet verifiable on this machine · N/A not applicable to this feature

## Summary

| # | §15.10 item | EXP-01 | EXP-02 | EXP-03 | EXP-04 | EXP-05 | EXP-06 | EXP-07 | Home card |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Only `AppTokens` and shared components; no hard-coded colors, sizes, or text styles | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 2 | Main task ≤ 3 taps; one primary action visible | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Loading, empty, error and content states implemented and tested | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 4 | 200% font scale and 360 dp wide, no clipping or overflow | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 5 | Light and dark goldens pass, English and Gujarati | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| 6 | Touch targets ≥ 48 dp; icons labelled; logical TalkBack order | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7 | Destructive actions follow undo-vs-confirm | ✅ | ✅ | ✅ | ✅ | N/A | ✅ | N/A | N/A |
| 8 | Ad placements match §11 and ad UX rules; no layout shift | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A |
| 9 | All strings from ARB with placeholders, no concatenation | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Result**: 8 of 9 items pass on every screen (item 8 is not applicable to this feature). Item 5 is open
until the golden baselines are generated on Linux (T113); every case is written and compiles.

## Evidence per item

**1. Tokens and shared components only.** The style guard
`test/core/theme/no_hardcoded_style_test.dart` scans every feature, core-widget and app file for color
literals and raw paddings (12 checks, all pass). Text styles come from `Theme.of(context).textTheme`,
sizes from `AppTokens`, amounts from `AmountText`, avatars from `CategoryAvatar`, sheets from
`AppBottomSheet`. The review found and fixed two literal sizes (the Home card skeleton height and the
icon-picker border width), which now use tokens.

**2. Speed and one primary action.**
- EXP-02: an expense saves in 2 taps after the amount. This is the verbatim acceptance criterion, tested.
- EXP-01, EXP-04 and EXP-06: the FAB is the only primary action.
- EXP-03: Edit is tonal and the other actions are outlined or text buttons.
- EXP-05 and EXP-07: Save is the only filled button.

The review found and fixed two violations:
- The shared keypad's Done key was a filled button next to Save on EXP-02 and EXP-07. It is now tonal.
- Empty states showed a filled action next to the FAB. The FAB now hides while an empty state is shown.

Both fixes are asserted: `EXP-02 US1-1`, `US2-9`, the EXP-04 empty test, and the EXP-06 empty test.

**3. Four states.** Every screen has a skeleton-only-after-300-ms test, an error-with-Try-again test, an
empty test and a content test:

| Screen | Tests |
|---|---|
| EXP-01 | `transactions_screen_test.dart` group "EXP-01 four states", plus `US2-9` (empty and "No matches") |
| EXP-02 | `transaction_form_screen_test.dart` group "EXP-02 four states" (empty: no visible categories) |
| EXP-03 | `transaction_detail_screen_test.dart` group "EXP-03 states", plus "deleted elsewhere" |
| EXP-04 | `categories_screen_test.dart` group "EXP-04 four states" |
| EXP-05 | `category_sheet_test.dart` "states: empty … and error with retry" (loading appears in edit mode while the list loads) |
| EXP-06 | `accounts_screen_test.dart` group "EXP-06 four states" |
| EXP-07 | `account_sheet_test.dart` "fields …" (empty new form) and "… a missing account is an error state" |
| Home card | `expense_dashboard_card_test.dart` (empty, error with Try again, content) |

**4. 200% and 360 dp.** `test/a11y/font_scale_test.dart` (T114) pumps each screen with realistic data
(long notes, ₹1,25,000.55, negative balances, a transfer, a hidden category, an archived account) at 2×
text on a 360×800 surface, in en, hi and gu. Any overflow fails the test. All 54 cases pass, covering:
- the Home card;
- EXP-01;
- EXP-02 in three modes: new, transfer and edit;
- EXP-03, EXP-04 and EXP-06;
- the EXP-05 and EXP-07 sheets.

**5. Goldens.** These cases are written in `test/goldens/expense_screens_golden_test.dart`, each in
light and dark × en and gu (64 cases):
- EXP-01: content, empty period, "No matches", search open.
- EXP-02: new with amount, transfer, validation errors.
- EXP-03: receipt placeholder.
- EXP-04: Hidden expanded, empty Income tab.
- EXP-05: new, duplicate error.
- EXP-06: negative balance with Archived expanded.
- EXP-07: negative opening balance.

The new `IconPickerGrid` and `ColorPickerRow` are added to the shared-widget goldens. **Open**: baselines
must be generated on Linux (`flutter test --tags golden --update-goldens`, T113). On Windows the tag is
excluded by project rule.

**6. Touch targets, labels, order.** The same 54 accessibility cases run Flutter's
`androidTapTargetGuideline` (≥ 48 dp) and `labeledTapTargetGuideline`, and all pass.

The review found and fixed three issues:
- The Home card was an unlabelled tappable area. It now announces "Expense" as a button.
- Icon-picker cells lost their tap action behind a tooltip, so screen readers couldn't select an icon.
  This is fixed and tested (`icon_picker_grid_test.dart`).
- EXP-02 category tiles and color swatches now carry an explicit tap action.

Amounts are spoken as formatted currency (`AmountText` semantics). Reading order follows the visual
top-to-bottom layout; no screen reorders semantics. A manual TalkBack pass on a device is still worth
doing before release.

**7. Undo vs confirm (§15.5).** These use an Undo snackbar with no dialog:
- deleting a transaction by swipe or menu (EXP-01), from edit (EXP-02) or from EXP-03;
- hiding or showing a category, and deleting an unused category (EXP-04);
- archiving, restoring or deleting an account (EXP-06).

These state what will happen before it happens:
- "Discard changes?" on EXP-02 (unsaved input is lost permanently).
- The EXP-04 replacement sheet, which states "Move N transactions …" before any change, uses a
  destructive button in the error color, and has no undo (FR-037).

Undo survives leaving the screen (tested: `edge case "Undo after leaving"`).

**8. Ads.** Not applicable. All ads are out of scope for this feature. Every banner slot is empty and
takes no space, and the T004(e) scan proves `features/expense/` never imports `core/ads/` or
`google_mobile_ads`. Placements are checked when T4.2 adds banners.

**9. Strings.**
- 243 new keys across this feature, in en, hi and gu, all generated from `tool/l10n/phase0_strings.py`.
- Placeholders and an ICU plural (`expense_moveBody`) are used where values vary.
- The review found and fixed one concatenation: the EXP-02 amount's spoken label now uses
  `expense_amountValue`.
- The EXP-03 share text joins two complete localized lines with a newline. That is not sentence
  concatenation.
- Open: the Hindi and Gujarati wording needs a native speaker's review.
