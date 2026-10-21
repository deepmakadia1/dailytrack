# Implementation Plan: Hide the EXP-02 Keypad While Scrolling

**Branch**: `004-keypad-hide-on-scroll` | **Date**: 2026-10-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-keypad-hide-on-scroll/spec.md`

## Summary

EXP-02 already keeps a `keypadOpen` flag in `TransactionFormState`, shown by tapping the amount display and hidden by the keypad's Done key or by tapping the note field. This feature adds one more way to hide it: a user-initiated scroll of the form. The form's `SingleChildScrollView` is wrapped in a `NotificationListener<UserScrollNotification>` that calls `controller.setKeypadOpen(open: false)` when the user starts scrolling the outer form (depth 0, direction not idle) and the keypad is open. Nothing else changes: the amount display stays the only way to show the keypad, and `keypadOpen` already sits outside the `isDirty` comparison.

## Technical Context

**Language/Version**: Dart 3.13, Flutter 3.47.7

**Primary Dependencies**: flutter_riverpod 3 (existing `TransactionFormController`), no new packages

**Storage**: N/A (UI state only)

**Testing**: flutter_test widget tests with `pumpExpenseApp` and the expense fakes; the §15.10 200% font scale test in `test/a11y/font_scale_test.dart`

**Target Platform**: Android (primary), iOS later

**Project Type**: Mobile app, feature-first clean architecture

**Performance Goals**: Hiding the keypad is a single state change; no measurable cost

**Constraints**: Programmatic scrolls (`Scrollable.ensureVisible`, `animateTo`) must not hide the keypad; nested horizontal scrollables (chip rows) must not hide it

**Scale/Scope**: One screen (EXP-02), one widget, one controller guard, one new test file

## Constitution Check

| Principle | Status |
|-----------|--------|
| I. Spec is the source of truth | Pass: `docs/spec.md` EXP-02 Behavior and acceptance criteria updated first (2026-10-17 change note). |
| II. Layered, feature-first architecture | Pass: change is in `presentation/` only; no domain or data change. |
| III. Data integrity and privacy | Pass: no stored data; amount and calculation are untouched. |
| IV. Test-backed acceptance | Pass: every acceptance scenario gets a widget test (T003–T011). |
| V. Offline-first, fast, accessible UX | Pass: Save stays visible; the amount display keeps its button semantics; 200% check added (T012). |
| VI. Monetization | N/A |
| VII. Simplicity and locked stack | Pass: uses the framework's scroll notifications; no new package. |

## Research

### R1: Which scroll signal

- **Decision**: `UserScrollNotification` with `direction != ScrollDirection.idle` and `depth == 0`.
- **Rationale**: The framework sends it only for scrolls driven by the user's drag or fling, so `Scrollable.ensureVisible` and `animateTo` (FR-002) never trigger it. `depth == 0` ignores nested scrollables such as horizontal chip rows. If the content fits the viewport, the scroll physics reject the drag and no notification is sent (spec edge case).
- **Alternatives considered**: `ScrollStartNotification.dragDetails != null` works too but also fires on a touch that ends up not moving the form. A `GestureDetector` on vertical drag would compete with the scroll view's own recognizer.

### R2: Where the state lives

- **Decision**: Keep `keypadOpen` in `TransactionFormState`; `setKeypadOpen` returns early when the value is unchanged.
- **Rationale**: The notification arrives many times during a drag (direction changes); the guard avoids extra state emissions. `_update` already computes `isDirty` from the draft, expression and repeat only, so FR-005 holds without changes.

## Project Structure

### Documentation (this feature)

```text
specs/004-keypad-hide-on-scroll/
├── spec.md
├── plan.md
├── tasks.md
└── checklists/requirements.md
```

### Source Code

```text
lib/features/expense/presentation/
├── controllers/transaction_form_controller.dart   # setKeypadOpen: no-op when unchanged
└── screens/transaction_form_screen.dart           # _Form: NotificationListener around the scroll view

test/features/expense/presentation/
└── transaction_form_keypad_test.dart              # new: US1 and US2 scenarios
test/a11y/font_scale_test.dart                     # + EXP-02 keypad hidden by scroll at 200%
```

**Structure Decision**: Existing feature-first layout; no new files in `lib/`.

## Complexity Tracking

None.
