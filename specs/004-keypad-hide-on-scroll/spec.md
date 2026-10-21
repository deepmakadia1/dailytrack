# Feature Specification: Hide the EXP-02 Keypad While Scrolling

**Feature Branch**: `004-keypad-hide-on-scroll`

**Created**: 2026-10-17

**Status**: Draft

**Input**: User description: "Create a user story in spec.md to hide the calculator number keyboard when scrolling, and show it only when the amount field is tapped."

**Source of truth**: `docs/spec.md` v1.0, section 8 (EXP-02 Add / edit transaction, Layout item 2 "Amount field" and Behavior) and section 15 (UI/UX guidelines). The keypad is the shared `NumericKeypad` delivered by feature 002 (`specs/002-expense-core/`).

> **Scope**: EXP-02 only (add, edit, and rule-edit modes). The keypads in the EXP-07 account sheet and
> the EXP-09 budget sheet are unchanged: those sheets are short, and in EXP-07 the keypad scrolls with
> the content instead of sitting above it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scrolling the form hides the keypad (Priority: P1)

While adding or editing a transaction, the user types the amount and then scrolls down to reach the account, payment mode, date, note, receipt, or Repeat fields. Today the calculator keypad stays pinned above the Save button and covers about half of the screen, so the user has to press Done first. With this story, starting to scroll the form hides the keypad, so the whole screen is available for the rest of the form.

**Why this priority**: It is the main request. On a 360 dp phone, and especially at large font sizes, the keypad leaves little room for the fields below the amount.

**Independent Test**: Open EXP-02 for a new expense, type an amount, drag the form upward, and check that the keypad is gone, the typed amount is unchanged, and the Save button is still visible.

**Acceptance Scenarios**:

1. **Given** EXP-02 is open for a new expense with the keypad showing, **When** the user drags the form to scroll it, **Then** the keypad hides and the Save button stays visible.
2. **Given** the user has typed "250" or a calculation such as "200+50", **When** scrolling hides the keypad, **Then** the amount display and the calculation are unchanged and no digit is lost.
3. **Given** the keypad was hidden by scrolling, **When** the user scrolls back to the top, **Then** the keypad stays hidden.
4. **Given** the keypad was hidden by scrolling, **When** the user taps Save with a valid amount and category, **Then** the transaction saves exactly as it would with the keypad open.
5. **Given** the form is scrolled by the app itself rather than by the user (for example, to bring a field into view), **When** that scroll happens, **Then** the keypad does not hide.

---

### User Story 2 - Only tapping the amount brings the keypad back (Priority: P1)

After the keypad is hidden (by scrolling, by Done, or by tapping the note field), the user brings it back by tapping the large amount at the top of the form. No other action shows it.

**Why this priority**: It is the second half of the request and makes the keypad predictable: one way to show it, several ways to hide it.

**Independent Test**: Hide the keypad by scrolling, tap a category, a payment mode chip, and the Repeat toggle and check the keypad stays hidden; then tap the amount and check the keypad shows with the previous amount ready to edit.

**Acceptance Scenarios**:

1. **Given** the keypad is hidden, **When** the user taps the amount display, **Then** the keypad shows and the next digit continues the existing amount or calculation.
2. **Given** the keypad is hidden, **When** the user taps a category, account, payment mode, date, receipt, or Repeat control, **Then** the keypad stays hidden.
3. **Given** the amount display is scrolled out of view, **When** the user scrolls back up and taps it, **Then** the keypad shows.
4. **Given** a screen reader is on, **When** the user focuses the amount display, **Then** it is announced as a button with the current amount, and activating it shows the keypad.

---

### Edge Cases

- A new entry still opens with the keypad showing (the amount field is auto-focused, `docs/spec.md` EXP-02 Layout item 2); edit and rule-edit modes still open with it hidden.
- A form whose content fits the screen does not scroll: a drag does nothing and the keypad stays as it is.
- A fling (fast swipe) hides the keypad the same way as a slow drag.
- The note field's system keyboard is unaffected; tapping the note field still hides the keypad as before.
- Hiding or showing the keypad is not an unsaved change: backing out of an untouched form shows no "Discard changes?" dialog.
- When the keypad hides, the form keeps the user's scroll position; the content does not jump back to the top.
- At 200% font scale the behavior is the same and nothing overflows (§15.10).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: EXP-02 MUST hide the numeric keypad as soon as the user starts scrolling the form by touch (drag or fling), in add, edit, and rule-edit modes.
- **FR-002**: Scrolls the app starts itself (not from the user's touch) MUST NOT hide the keypad.
- **FR-003**: Hiding the keypad MUST keep the typed amount and any calculation in progress exactly as they were.
- **FR-004**: Once hidden, the keypad MUST show again only when the user taps (or activates with a screen reader) the amount display; scrolling, including back to the top, and tapping any other control MUST NOT show it.
- **FR-005**: Showing or hiding the keypad MUST NOT mark the form as changed.
- **FR-006**: The existing ways to hide the keypad (its Done key and tapping the note field) and the initial state (shown for a new entry, hidden when editing) MUST keep working.
- **FR-007**: The Save button MUST stay visible and usable whether the keypad is shown or hidden.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After typing an amount, the user can reach any field below it with one scroll gesture and no extra tap to close the keypad.
- **SC-002**: The existing EXP-02 acceptance criterion still holds: a new expense saves with amount + category in 3 taps or fewer after typing the amount.
- **SC-003**: All EXP-02 widget and accessibility tests, including the 200% font scale checks in en, hi, and gu, pass with no overflow.

## Assumptions

- "Scrolling" means the user's own touch scroll of the EXP-02 form. Programmatic scrolls are excluded so that the app moving a field into view never takes the keypad away mid-entry.
- The keypad still opens automatically for a new entry, because speed is EXP-02's main design goal and the spec auto-focuses the amount field. "Show only when the amount field is tapped" applies once the keypad has been hidden.
- No new strings, settings, or stored data are needed.
