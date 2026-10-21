# Contract: Shared code added or changed in `lib/core/`

All six §15.4 widgets named in the feature request already exist from feature 001:
`AmountText`, `CategoryAvatar`, `NumericKeypad`, `PeriodSelector`, `ChipSelector`, and
`UndoSnackBar`. This table lists only the **changes**. Each change keeps the widget's existing
tests green, adds tests for the new behavior, and regenerates goldens on Linux.

| Item | Change | Why |
| --- | --- | --- |
| `core/utils/period.dart` | **New** sealed `Period` (Day, Week, Month, Year, Custom), local-midnight boundaries → UTC ms, `previous/next/contains`, `label(locale, relative labels)` | EXP-01 period kinds (R13) |
| `PeriodSelector` | Takes `Period` instead of a month `DateTime`. Arrows are hidden for `CustomPeriod`. Arrow tooltips depend on the kind ("Previous week" etc.) | FR-019 |
| `PeriodPickerSheet` (`core/widgets/period_picker_sheet.dart`) | **New**: `AppBottomSheet` with Day, Week, Month, Year, and Custom range (`showDateRangePicker`). Returns a `Period` | EXP-01 "tapping the label opens a picker" |
| `UndoSnackBar.show` | Optional `ScaffoldMessengerState? messenger` parameter (defaults to `ScaffoldMessenger.of(context)`) | Undo after a route pop (R12) |
| `core/module/root_navigator.dart` | **New**: `rootNavigatorKey`, `rootMessengerKey` | R10, R12 |
| `core/theme/app_icons.dart` | **New**: `AppIcons.byKey(String) → IconData` (fallback `category`) and grouped `AppIcons.groups` (about 80) | R14 |
| `IconPickerGrid` (`core/widgets/icon_picker_grid.dart`) | **New**: grouped grid with 48 dp cells, selected state shown by a ring and a check, plus a semantic label per icon | EXP-05, EXP-07, later HAB-02 |
| `ColorPickerRow` (`core/widgets/color_picker_row.dart`) | **New**: the 16 `AppColors.palette` swatches. Selected state shown by a check icon, not color alone | EXP-05, EXP-07, later HAB-02 |
| `core/l10n/default_name_catalog.dart` + `default_name_catalog_impl.dart` | **New**: pure-Dart `DefaultNameCatalog` interface and `L10nDefaultNameCatalog` implementation | R9 |
| `core/share/text_sharer.dart` | **New**: `TextSharer`, `SharePlusTextSharer`, `textSharerProvider` | EXP-03 Share |
| `core/utils/clock.dart` | **New**: `Clock`, `SystemClock`, `clockProvider` (overridable) | Deterministic tests |
| `AppScaffold` | No change. The banner slot stays `null` | FR-038 |
| `NumericKeypad` | No API change. If the amount display needs a `+/−` toggle (EXP-07), it lives in the account sheet, not the keypad | data-model §5 |

`domain/` code may import pure-Dart files under `core/utils/` (`period.dart`, `clock.dart`, `date_keys.dart`,
`keypad_expression.dart`, `result.dart`) and `core/l10n/default_name_catalog.dart`. It must not import any
widget file, Flutter, Drift, or plugin (enforced by the T004 d import scan).