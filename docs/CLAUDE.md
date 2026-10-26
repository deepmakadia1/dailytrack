# DailyTrack — rules for Claude Code

This project uses Spec Kit for spec-driven development. Feature specs live in `specs/`.
The master spec is `docs/spec.md` and is the source of truth for every feature.

## How to work
- Before coding, read the relevant Screen ID sections (e.g. `EXP-02`) in `docs/spec.md`
  and the current feature's files in `specs/<feature>/`.
- One task per session: plan → implement → test → summarize changes → stop for review.
- If the spec is unclear or conflicts with the code, ask before guessing. Update the spec
  first, then the code.
- Golden tests (tag `golden`) are generated and compared on Linux only (CI or WSL):
  `flutter test --tags golden --update-goldens`. On Windows/macOS run
  `flutter test --exclude-tags golden`, and never commit goldens rendered there.
- Widget tests use `pumpTestApp` / `restartTestApp` (`test/helpers/test_app.dart`) with
  fakes from `test/helpers/fakes.dart`. They never open a database. Unit tests that need
  real Drift use `makeRealContainer` (`test/helpers/real_container.dart`).
- A module's default data is added only as `Seeder`s returned by
  `TrackerModule.seeders`. `SeedRunner` runs each one exactly once at startup.
- UI strings are added in `tool/l10n/phase0_strings.py` (en/hi/gu together), then run
  `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Don't edit the ARB files
  by hand.

## Architecture (spec §2, §3) — hard rules
- Flutter + Riverpod (riverpod_generator) + go_router + Drift + freezed. Do not add other
  state management, routing, or database packages.
- Feature-first clean architecture: `lib/features/<feature>/{data,domain,presentation}`.
- `presentation` depends on `domain` only. Never import `data/`, Drift, or
  `google_mobile_ads` from `presentation/`.
- `domain` is pure Dart (no Flutter imports).
- Features never import each other's internals; shared code goes in `lib/core/`.
- Every tracker module extends `TrackerModule` and is registered in
  `lib/app/module_registry.dart`.
- Home reaches modules only through `TrackerModule` (`dashboardCard`,
  `dashboardSections`, `insights`, `appBarBadge`, `quickAddActions`).
- Backups: each module owns a `BackupSection` (codecs + validation + upgrade steps); every Drift
  migration that changes a backed-up table adds an upgrade step.
- Export data comes from `TrackerModule.exportDatasets()`; settings never imports modules.
- Notification buttons and widget checks reach modules as an `AppAction` through
  `TrackerModule.handleAction`; the widget and daily summary data come from
  `TrackerModule.contributeGlance`.
- Widget and daily summary refresh from `GlanceRefresher` (Drift `tableUpdates`); don't add
  manual refresh calls in repositories.
- Background entry points are top-level in `lib/app/background_entry_points.dart` (plus the
  WorkManager dispatcher) and open their own container. `home_widget` is imported only there
  and in `lib/core/widget/data/`.

## Data rules
- Money = `int` minor units (paise). Never use `double` for money.
- Dates = UTC epoch milliseconds. Habit days = local `yyyy-MM-dd` date keys.
- Soft delete with `deletedAt` on user data tables for ordinary deletes. There are two
  user-confirmed exceptions (constitution III): "Erase all data" (SET-01, SYS-03) removes every
  row permanently, and restoring a backup (SET-02, SYS-03, SYS-01) replaces all module rows with
  the backup's rows in one transaction. Every schema change needs a Drift migration and a
  migration test.
- User data leaves the device only through actions the user starts or schedules: Google Drive
  backups (manual, or auto while signed in) to their own account, and backup or export files
  they save or share. It may also leave through Android's own device backup and device transfer,
  which the user controls in system settings. Those backup rules use an include list that covers
  only the database file; secure storage, receipts, and everything else stay out (constitution
  III). The PIN hash, lockout state, and backup password never leave the device. Never send
  financial or habit data to ad, crash, or analytics SDKs.

## UI rules (spec §15)
- Use only `AppTokens` and shared widgets from `lib/core/widgets/`. No hard-coded colors,
  sizes, spacing, or text styles in screens.
- Every screen implements loading, empty, error, and content states. A screen made of a fixed
  set of controls (settings, keypads) may omit the empty state if the feature plan says so
  (constitution V).
- All user-facing strings via ARB files (en, hi, gu) with placeholders, never concatenation.
- Run through the §15.10 design review checklist before marking a screen done.

## Ads (spec §11)
- All ad code goes through `AdService` in `lib/core/ads/`. Screens use `AppBannerAd`,
  `AppNativeAd`, and `AdService` methods only.
- Debug/dev builds use Google's official test ad unit IDs only. Never commit real ad IDs.
- No ads on forms, lock, onboarding, or premium screens. Interstitials only via the
  frequency cap in `AdConfig`.

## Quality gates (must pass before a task is done)
- Every acceptance criterion in the spec has at least one test.
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze` with zero warnings
- `dart format --set-exit-if-changed .`
- `flutter test` all green
- Summarize: files changed, tests added, checklist results, anything left open.
