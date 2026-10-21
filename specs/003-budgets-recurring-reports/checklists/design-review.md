# Design review (spec §15.10): EXP-08, EXP-09, EXP-10, EXP-11

Date: 2026-10-17. Evidence: automated tests on Windows (`flutter test --exclude-tags golden`, 859 passing) and code reading. No device run.

| Check | EXP-08 Budgets | EXP-09 Set budget | EXP-10 Recurring | EXP-11 Reports |
| --- | --- | --- | --- | --- |
| Tokens and shared components only | Pass | Pass | Pass | Pass (chart colors from theme and category colors) |
| ≤ 3 taps, one primary action | Pass | Pass ("Set budget") | Pass (FAB hidden in empty state) | Pass (view only) |
| Loading, empty, error, content implemented and tested | Pass | Partial: states built; load error tested at controller level only | Pass | Pass |
| 200% font, 360 dp | Not verified (T102) | Not verified (T102) | Not verified (T102) | Pass (widget test, all tabs) |
| Light/dark goldens, en/gu | Not run (Linux only, T101) | Not run | Not run | Not run |
| Touch targets ≥ 48 dp, labelled icons, TalkBack order | Partial: sizes and labels in code; TalkBack order not checked on device | Partial | Partial | Partial (charts have semantic summaries; locked tabs announced) |
| Destructive actions: undo vs confirm | Pass (delete → Undo) | Pass | Pass (delete → Undo; pause directly reversible) | n/a |
| Ad placements, no layout shift | Pass: native ad deferred to T4.2, slot takes no space | Pass (no ads on forms) | Pass | Pass: banner deferred to T4.2; "Watch an ad" deferred to feature 008 |
| ARB strings with placeholders | Pass | Pass | Pass | Pass (chart summaries join localized items with ", ") |
