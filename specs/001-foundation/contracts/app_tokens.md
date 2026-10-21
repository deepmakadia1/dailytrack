# Contract: AppTokens and shared widgets

**Location**: `lib/core/theme/`, `lib/core/widgets/` · **Spec**: §15.2, §15.4, FR-005 to FR-009

## AppTokens (`ThemeExtension<AppTokens>`)

```dart
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  // Semantic colors (§15.2): light/dark values come from app_colors.dart only.
  final Color income, expense, warning, success, adBadge;
  final double habitDoneDarkOpacity;            // 0.85 in dark, 1.0 in light
  // Spacing scale (4-pt grid)
  final double s4, s8, s12, s16, s24, s32, s48;
  final double screenPadding, screenPaddingWide, cardGap;   // 16, 24, 12
  final double wideBreakpoint, maxContentWidth;             // 600, 600
  // Shapes
  final double radiusChip, radiusCard, radiusSheet;         // 8, 16, 28
  // Sizes
  final double iconSize, chipIconSize, avatarSize, minTouchTarget, navBarHeight; // 24, 20, 40, 48, 80
  // Motion
  final Duration motionShort, motionMedium;                  // 150 ms, 250 ms
  static AppTokens of(BuildContext context);                 // Theme.of(context).extension<AppTokens>()!
  // copyWith + lerp
}
```

- `app_colors.dart` is the **only** file that contains hex literals: the seed `#0F766E`, the
  semantic light and dark colors, and the fixed palette of 16 category and habit colors (each
  with ≥ 3:1 contrast on both themes' surfaces, checked by a unit test).
- `app_theme.dart` builds light and dark `ThemeData`. It uses Material 3, `ColorScheme.fromSeed`,
  the Noto Sans type scale with fallbacks (§15.2 sizes and weights), flat elevation with tonal
  surfaces, and attaches `AppTokens`.
- A lint-like test scans `lib/features/**` and `lib/core/widgets/**` for `Color(0x`, `Colors.`,
  and `#` hex literals and fails if it finds any.

## Shared widgets (all in `lib/core/widgets/`; each has widget tests and light/dark goldens)

| Widget | Key parameters | Notes |
| --- | --- | --- |
| `AppScaffold` | `title`, `body`, `actions`, `fab`, `bannerSlot`, `largeTitle` | Safe areas, edge-to-edge, max width 600, FAB above banner slot; banner slot collapses to 0 height when empty |
| `AmountText` | `amountMinor`, `currencyCode`, `kind` (income/expense/neutral), `showSign`, `style` | Uses `MoneyFormatter`; Indian grouping for INR; `+`/`−` sign plus color; tabular figures; semantics label reads the full currency amount |
| `CategoryAvatar` | `iconKey`, `color`, `semanticLabel` | 40 dp circle, 24 dp icon |
| `SummaryCard` | `title`, `value` (Widget), `progress?`, `actionChip?` | 16 dp radius, tonal surface |
| `ProgressBarStatus` / `ProgressRing` | `ratio`, `label` | <0.8 success, 0.8–1.0 warning, >1.0 expense color, **plus** text label/icon |
| `PeriodSelector` | `period`, `onChanged`, `onPick` | `< Month Year >`, 48 dp arrows with semantic labels |
| `ChipSelector<T>` | `options`, `selected`, `multi`, `labelBuilder` | Single and multi-select |
| `NumericKeypad` | `onKey`, `onBackspace`, `onOperator`, `onDone` | Digits, `.`, `+ − × ÷`, `=`; keys ≥ 48 dp. Calculator evaluation lives in `core/utils/keypad_expression.dart` (unit tested) |
| `AppBottomSheet` | `show(context, title:, child:)` | Drag handle, 28 dp top corners, keyboard insets |
| `EmptyState` | `title`, `message`, `actionLabel?`, `onAction?`, `illustration?` | |
| `ErrorState` | `message`, `onRetry`, `secondaryAction?` | "Try again" default label from ARB |
| `SkeletonList` / `SkeletonCard` | `itemCount` | Shown only after 300 ms (`DelayedSkeleton` wrapper); respects disable-animations |
| `UndoSnackBar` | `show(context, message:, onUndo:)` | 5 s duration |
| `ConfirmDialog` | `show(context, title:, consequence:, confirmLabel:, destructive:)` → `Future<bool>` | Destructive action uses `colorScheme.error` |
| `LockedFeatureOverlay` | `child`, `onWatchAd`, `onGetPro` | Blur + lock badge + two actions (wired in T4.4) |

## Utilities (`lib/core/utils/`, pure Dart, unit tested)

- `MoneyFormatter.format(int minor, {required String currencyCode, MoneySign sign = MoneySign.auto})`:
  Indian grouping for INR (`12,34,567.00`), Western for other currencies, Latin digits in every
  UI language. Minor digits come from the currency table. It uses `BigInt` integer math and never
  `double`. *(Changed during T025: the planned `locale` parameter was dropped, because grouping
  depends only on the currency, so an amount looks the same in en/hi/gu.)* Parsing keypad input
  into minor units is integer-only (`KeypadExpression`).
- `DateKeys.fromLocal(DateTime)` → `yyyy-MM-dd`, `DateKeys.parse`, `Epoch.nowUtcMs()`,
  `Epoch.toLocal(int)`, plus relative labels ("Today", "Yesterday", `EEE, d MMM`).
- `currencies.dart`: the curated 30-currency table (research R5).
