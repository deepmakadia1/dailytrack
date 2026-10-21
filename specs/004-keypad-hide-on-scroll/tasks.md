# Tasks: Hide the EXP-02 Keypad While Scrolling

**Input**: Design documents from `specs/004-keypad-hide-on-scroll/`

**Prerequisites**: plan.md, spec.md

**Tests**: Required (constitution Principle IV): every acceptance scenario has a widget test.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Spec

- [X] T001 Update `docs/spec.md` EXP-02 Behavior with the keypad visibility user story and add the acceptance criterion; add the 2026-10-17 change note

## Phase 2: Foundational

- [X] T002 Make `setKeypadOpen` a no-op when the value is unchanged in `lib/features/expense/presentation/controllers/transaction_form_controller.dart` (plan R2)

## Phase 3: User Story 1 - Scrolling the form hides the keypad (P1) 🎯 MVP

### Tests for User Story 1 (write first, expect them to fail)

- [X] T003 [P] [US1] Widget test: dragging the form hides the keypad and Save stays visible (US1 s1, FR-001, FR-007) in `test/features/expense/presentation/transaction_form_keypad_test.dart`
- [X] T004 [P] [US1] Widget test: a typed amount and a calculation in progress are unchanged after hiding (US1 s2, FR-003) in the same file
- [X] T005 [P] [US1] Widget test: scrolling back to the top keeps the keypad hidden (US1 s3, FR-004) in the same file
- [X] T006 [P] [US1] Widget test: Save after hiding by scroll saves the same transaction (US1 s4) in the same file
- [X] T007 [P] [US1] Widget test: `Scrollable.ensureVisible` on the note field does not hide the keypad; a horizontal drag on a chip row does not hide it (US1 s5, FR-002) in the same file
- [X] T008 [P] [US1] Widget test: hiding by scroll is not an unsaved change; back shows no "Discard changes?" dialog (FR-005) in the same file

### Implementation for User Story 1

- [X] T009 [US1] Wrap the form's scroll view in `_Form` with a `NotificationListener<UserScrollNotification>` that hides the keypad on a depth-0, non-idle user scroll in `lib/features/expense/presentation/screens/transaction_form_screen.dart`

## Phase 4: User Story 2 - Only tapping the amount brings the keypad back (P1)

### Tests for User Story 2

- [X] T010 [P] [US2] Widget tests: after hiding, tapping a category, payment mode chip, or the Repeat toggle keeps it hidden; tapping the amount shows it and the next digit continues the amount; scrolled out of view, scrolling back up and tapping the amount shows it; edit and rule-edit modes open hidden and hide on scroll after tapping the amount (US2 s1–s3, FR-004, FR-006) in `test/features/expense/presentation/transaction_form_keypad_test.dart`
- [X] T011 [P] [US2] Widget test: the amount display is a labelled button and its tap action shows the keypad (US2 s4) in the same file

## Phase 5: Polish

- [X] T012 [P] Add "EXP-02 keypad hidden by scroll at 200%" to `test/a11y/font_scale_test.dart` (SC-003, §15.10)
- [X] T013 Quality gates: `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test --exclude-tags golden` for the expense and a11y suites, and the existing EXP-02 tests (SC-002)

## Dependencies & Execution Order

- T001 first (spec before code).
- T002 before T009.
- T003–T008 before T009 (TDD); T010–T011 run after T009 (they rely on hiding by scroll).
- T012 after T009; T013 last.

## Notes

- No strings, schema, or settings change, so no `build_runner`, l10n, or migration step.
