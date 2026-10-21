<!--
Sync Impact Report
- Version change: 1.0.0 → 1.0.1 (PATCH: two clarifying exceptions to existing rules; no principle
  added, removed, or redefined)
- Modified principles:
  - III. Data Integrity and Privacy (NON-NEGOTIABLE): soft delete applies to ordinary deletes; the
    user-confirmed "Erase all data" (SET-01, SYS-03) MUST remove every row permanently
  - V. Offline-First, Fast, and Accessible UX: screens whose content is a fixed set of controls
    (settings, keypads) MAY omit the empty state if the feature plan says so
- Added sections: none
- Removed sections: none
- Source: specs/007-settings-themes-app-lock analysis findings C1 and C3
- Templates: none need changes (plan-template's Constitution Check reads the principles at runtime)
- Follow-up TODOs: none
-->

# DailyTrack Constitution

## Core Principles

### I. Spec Is the Source of Truth

- `docs/spec.md` defines behavior for every feature. Each screen has a stable Screen ID
  (e.g. `EXP-02`) that MUST be used in feature specs, commit messages, and test names.
- When behavior changes, the spec MUST be updated first, then the code.
- If the spec is ambiguous or conflicts with the code, work MUST stop and the question MUST be
  resolved (and recorded in the spec) before implementation continues.
- Work proceeds one task at a time: plan → implement → test → summarize → stop for review.

**Rationale**: Traceability from Screen ID to code to test keeps an AI-assisted, spec-driven
codebase auditable and prevents silent drift.

### II. Layered, Feature-First Architecture

- Code is organized as `lib/features/<feature>/{data,domain,presentation}`; shared code lives in
  `lib/core/`.
- `presentation` MUST depend on `domain` only and MUST NOT import `data/`, Drift, or
  `google_mobile_ads`.
- `domain` MUST be pure Dart (no Flutter imports): entities, repository interfaces, use cases.
- `data` implements domain repositories via Drift DAOs, mappers, and services.
- A feature MUST NOT import another feature's internals; cross-feature needs go through `core/`
  domain interfaces or routes.
- Every tracker module MUST implement `TrackerModule` and be registered in
  `lib/app/module_registry.dart`, so new modules (Water, Period) are added without editing
  existing features.
- Each screen has exactly one Riverpod Notifier exposing an immutable state with loading, data,
  and error handled explicitly.

**Rationale**: Strict layering keeps modules independently testable and lets the app grow by
addition rather than modification.

### III. Data Integrity and Privacy (NON-NEGOTIABLE)

- Money MUST be stored as `int` minor units (paise). `double` MUST NOT be used for money.
- Timestamps MUST be stored as UTC epoch milliseconds; habit days MUST use local `yyyy-MM-dd`
  date keys.
- User data tables MUST soft-delete via `deletedAt` for ordinary deletes (so undo and backups stay
  consistent). The single exception is the user-confirmed "Erase all data" (SET-01, SYS-03), which
  MUST remove every row permanently.
- Every schema change MUST ship with a Drift migration and a migration test.
- User-entered data (transactions, habits, notes, settings) MUST NOT leave the device except
  through a user-initiated Google Drive backup. Financial or habit data MUST NOT be sent to ad,
  crash, or analytics SDKs, including as event parameters or targeting keywords.
- The PIN MUST be stored only as a salted hash (PBKDF2 or Argon2) in `flutter_secure_storage`;
  the plain PIN MUST never be stored.
- Secrets and release ad unit IDs MUST NOT be committed to the repository.

**Rationale**: This is a money and health-adjacent app; rounding errors, timezone bugs, data loss,
or leaks break user trust irreparably.

### IV. Test-Backed Acceptance (NON-NEGOTIABLE)

- Every acceptance criterion in the spec MUST have at least one automated test.
- Unit tests MUST cover money math, streaks, recurring rules, budget thresholds, ad frequency cap,
  backup round-trip, and migrations; `domain/` and `data/` target ≥ 80% coverage.
- Widget tests MUST use fake repositories and `NoAdsService`.
- Golden tests MUST cover DSH-01, EXP-01, EXP-02, HAB-01 in light/dark and English/Gujarati;
  integration tests MUST cover the end-to-end flows listed in spec §13.

**Rationale**: Tests are the executable form of the spec and the only reliable proof a task is
done.

### V. Offline-First, Fast, and Accessible UX

- All features MUST work offline except Drive backup, ads, and purchases.
- Performance budgets: cold start to Home < 1.5 s on a mid-range device; DB write for save or
  check-in < 100 ms; 60 fps scrolling with 10,000 transactions; APK < 25 MB per ABI.
- Screens MUST use only `AppTokens` and shared widgets from `lib/core/widgets/`; no hard-coded
  colors, sizes, spacing, or text styles.
- Every screen MUST implement loading, empty, error, and content states. A screen whose content is
  a fixed set of controls (settings, keypads) MAY omit the empty state, and the feature plan MUST
  say so.
- All user-facing strings MUST come from ARB files (en, hi, gu) with placeholders, never
  concatenation.
- Accessibility: 48×48 dp touch targets, semantic labels on icon buttons, WCAG AA contrast in
  both themes, status never conveyed by color alone, no clipping at 200% font scale.
- Each screen MUST pass the spec §15.10 design review checklist before it is marked done.

**Rationale**: The app's value is fast daily logging for Indian users across three languages and
a wide range of devices.

### VI. Respectful, Isolated Monetization

- All ad code MUST go through the `AdService` interface in `lib/core/ads/`; screens use only
  `AppBannerAd`, `AppNativeAd`, and `AdService` methods.
- Debug/dev builds MUST use Google's official test ad unit IDs only.
- Banner and native ads MUST NOT appear on add/edit forms, lock, onboarding, or premium (PRM)
  screens. Placements MUST match the spec §11 table.
- Rewarded ads MUST be started only by the user from the PRM-02 prompt.
- Interstitials MUST be shown only after a finished action, once the screen has closed, and only
  through the `AdConfig` frequency cap. Ads MUST NOT interrupt a task.
- No ad request is made before UMP consent is resolved. Rewards are granted only in
  `onUserEarnedReward`.
- With `NoAdsService` (Pro, ad-free day, tests), no ad widget occupies any space.

**Rationale**: Ads fund the app but must never cost user trust or violate Play policy.

### VII. Simplicity and Locked Stack

- The stack is fixed: Flutter + Riverpod (`riverpod_generator`) + `go_router` + Drift + `freezed`.
  Alternative state management, routing, or database packages MUST NOT be added.
- New dependencies MUST be justified in the feature plan and be compatible with the layer rules.
- Build only what the current spec task requires (YAGNI); out-of-scope items in spec §1 stay out.

**Rationale**: A small, consistent stack keeps the codebase predictable for both humans and AI
agents.

## Technology & Platform Constraints

- Platform: Android first (min API 24, target latest Play-required API); code stays iOS-ready but
  iOS is not tested in MVP.
- Package choices are those in spec §2; versions are locked in `pubspec.lock`.
- Build flavors: `dev` (test ad IDs, `.dev` application ID suffix) and `prod` (real IDs injected via
  `--dart-define` from CI secrets).
- Play Store compliance (spec §13) is a release requirement: data safety form, public privacy
  policy, 18+ audience, ads policy, IAP acknowledgement and restore, `app-ads.txt`.

## Development Workflow & Quality Gates

- Features follow Spec Kit: `/speckit-specify` → `/speckit-clarify` → `/speckit-plan` →
  `/speckit-tasks` → `/speckit-analyze` → `/speckit-implement`, in the phase order of spec §14.
- A task is done only when all of the following pass:
  - `dart run build_runner build --delete-conflicting-outputs`
  - `flutter analyze` with zero warnings
  - `dart format --set-exit-if-changed .`
  - `flutter test` all green
- Each task ends with a summary of files changed, tests added, checklist results, and open items.
- CI (GitHub Actions) runs analyze, format check, tests, and a release App Bundle build on every
  pull request.

## Governance

- This constitution supersedes other practices. `docs/spec.md` defines *what* to build; this
  document defines *how* it must be built. `docs/CLAUDE.md` is the runtime guidance file and MUST
  stay consistent with this constitution.
- Every plan's Constitution Check and every code review MUST verify compliance with the principles
  above. Any deviation MUST be documented with its justification in the plan's Complexity
  Tracking section.
- Amendments are made via `/speckit-constitution`, include a Sync Impact Report, and update any
  affected guidance files in the same change.
- Versioning follows semantic versioning: MAJOR for removing or redefining a principle, MINOR for
  adding a principle or materially expanding guidance, PATCH for clarifications and wording.

**Version**: 1.0.1 | **Ratified**: 2026-10-13 | **Last Amended**: 2026-10-21
