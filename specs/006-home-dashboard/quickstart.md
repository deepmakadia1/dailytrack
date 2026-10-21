# Quickstart: Home Dashboard (DSH-01, T2.5)

How to check that the feature works. Contracts: [tracker_module.md](contracts/tracker_module.md),
[screens.md](contracts/screens.md), [repositories.md](contracts/repositories.md). Data:
[data-model.md](data-model.md).

## 1. Prerequisites

- Flutter 3.47.7 / Dart 3.13.5 (unchanged), Android emulator or device API 24+.
- Branch `006-home-dashboard`. Run `flutter pub get`.

## 2. Quality gates (constitution)

```sh
dart run build_runner build --delete-conflicting-outputs
flutter analyze                      # zero warnings
dart format --set-exit-if-changed .
flutter test                         # all green, including goldens (Linux host)
```

## 3. Focused test runs

```sh
flutter test test/features/dashboard/                 # Home screen, controllers, rotation, greeting, perf
flutter test test/features/expense/domain/insights/   # expense insight rules (Clock.fixed)
flutter test test/features/habit/domain/insights/     # habit insight rules + best streak
flutter test test/features/expense/presentation/expense_dashboard_card_test.dart
flutter test test/features/habit/presentation/habit_dashboard_card_test.dart
flutter test test/features/settings/                  # SET-06 reorder + semantics actions
flutter test test/core/theme/no_hardcoded_style_test.dart   # layering scan (R17)
flutter test test/goldens/home_golden_test.dart       # light/dark × en/gu
```

## 4. Manual walkthrough (dev flavor)

1. **Fresh install**: complete onboarding with both modules on. Home shows the greeting for the
   current time, today's date, flame 0, "Add your first expense", "Create your first habit", the
   starter tip, and the Coming soon card. Recent transactions is not shown.
2. **Add expense** via + → "Add expense" and save ₹500. Back on Home, "Spent today" is ₹500 and
   Recent transactions shows 1 row, with no refresh.
3. **Budget**: set an overall budget of ₹600 from the card's "Set budget". The bar is amber (83%,
   "Almost used"). Add ₹200 more and the bar turns red with an icon.
4. **Habit**: create "Read" (yes/no, daily). Tap its check on Home: the ring shows 1 of 1 and the
   flame shows 1. Tap again: it unchecks, and Undo restores it. Long-press opens HAB-03.
5. **Count habit**: create "Water" (count 8). Tap → "+1" records 1/8.
6. **Insight**: after seeding (`dev` seed or data from earlier days), Home shows one insight. Tapping
   it opens Reports or HAB-03. Pull down to refresh and only the insight updates. Change the device
   date +1 day, reopen the app, and a different insight shows when more than one applies.
7. **SET-06**: drag Habit above Expense. Home cards, the + menu, and the tabs all follow. Restart and
   the order is kept. With TalkBack, use the "Move up" / "Move down" actions.
8. **Single module**: disable Habit. Home shows no habit card, no flame, and no "Check in habit".
   Re-enable it, disable Expense, and confirm there's no expense card, no Recent transactions, and no
   gaps.
9. **Coming soon**: dismiss the card and tap Undo, and it returns. Dismiss again and wait 5 s, then
   restart, and it stays hidden.
10. **Accessibility**: at 200% font scale on a 360 dp-wide screen, nothing clips. Check dark theme.
    Switch to Gujarati.
11. **Performance**: with the 10,000-transaction perf seed, Home content appears in under 300 ms
    (record it in the task summary).

## 5. Acceptance criteria → automated tests

| Criterion / scenario | Test |
| --- | --- |
| DSH-01: Marking a habit done from Home updates the ring, the habit list, and the streak icon without reload | `test/features/dashboard/home_screen_test.dart` "check-in updates ring, HAB-01 list and flame" (real in-memory DB, same container, navigates to HAB-01) |
| DSH-01: Budget bar color changes at 80% and 100% thresholds | `expense_dashboard_card_test.dart` "bar is success <80%, warning at 80% and 100%, expense >100%" (79/80/100/101%) |
| DSH-01: Screen renders correctly with only one module enabled | `home_screen_test.dart` "only expense" / "only habit" (no foreign card, badge, section, FAB entry; no empty `DashboardSlot` gap) + goldens |
| US1 greeting/date, flame tap, order | `home_screen_test.dart`, `greeting_test.dart` (boundaries 04:59/05:00/11:59/12:00/16:59/17:00) |
| US1 recent 5, transfers, See all | `recent_transactions_section_test.dart`, `drift_transaction_repository_test.dart` (`watchRecent`) |
| US2 toggle/undo/count/long-press/milestone | `habit_dashboard_card_test.dart` |
| US3 FAB menu order, routes, hide on scroll | `home_screen_test.dart` "quick add", `scroll_aware_fab_test.dart` |
| US4 one insight, rotation, refresh only insights, offline, disabled module, tap | `insight_rotation_test.dart` (7-day sequences, SC-006), `home_controller_insight_test.dart`, rule tests |
| US5 empty states, starter tip | `home_screen_test.dart` "first day" |
| US6 reorder drives Home/FAB/tabs, persists, last-module guard, semantics actions | `modules_screen_test.dart`, `home_screen_test.dart` "reorder" |
| US7 coming soon dismiss + undo + persistence | `coming_soon_card_test.dart` |
| SC-001 < 300 ms | `home_perf_test.dart` |
| SC-005 200% / 360 dp | `test/a11y/home_font_scale_test.dart` |
| SC-008 no network | Layering scan: no `http`/`dart:io` socket imports under dashboard or insights |
| FR-005 registry-only | Layering scan (R17) + `module_extensibility_test.dart` extended: a fake third module's card, section, badge, insight, and quick-add show on Home |
