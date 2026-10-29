# Feature Specification: Release Readiness (§14 T5.1, code side of T5.2, §13 targets)

**Feature Branch**: `012-release-readiness`

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: "Feature: Release readiness. Implement §14 T5.1 and the code side of T5.2 from docs/spec.md, and the §13 targets. Scope: golden tests from §13 (DSH-01, EXP-01, EXP-02, HAB-01, plus AUTH-01 and SET-01) in light and dark, English and Gujarati; integration tests from §13 plus a guest flow (Intro → Login → Continue as guest → add expense → Log out of guest), a Google flow with fake sign-in and Drive clients (sign in → backup → sign out → sign in → restore), and app lock; a dev-only "Seed 10,000 transactions" action in the Developer section and a performance pass against §13 targets (cold start, 60 fps scrolling in EXP-01, writes under 100 ms, APK size per ABI); release build setup (signing from android/key.properties, never committed; R8 with any keep rules the plugins need; versionName and versionCode from pubspec.yaml; the production AdMob App ID and ad unit IDs from config/prod.env.json, git-ignored, or CI secrets); app icon and adaptive icon, and the splash, from assets/branding/; privacy policy and terms URLs in lib/core/config/app_links.dart pointing to the final website; a GitHub Actions workflow that builds a signed release App Bundle from secrets when a version tag is pushed; a final audit (every acceptance criterion in docs/spec.md has a test, no TODO or "Replaced in" markers, no "Sync" in UI strings, no test ad IDs in prod builds, and the §13 Play Store compliance items that the code controls). Out of scope: Play Console, AdMob, and Google Cloud console setup, store listing text and images, and hosting the website (done manually)."

**Source**: `docs/spec.md` §11 (ad unit IDs, test IDs in dev and debug, App ID placeholder), §12 (localization), §13 (targets table, testing strategy, build flavors, Play Store compliance checklist), §14 T5.1 and T5.2, §15.10 (design review checklist), §16 (Android Auto Backup rules, guest data never leaves the device).

**Builds on**: every earlier feature (001–011). The golden harness (`test/goldens/`, tag `golden`, Linux only), the integration harness (`integration_test/`), the dev-flavor Developer section in SET-01, `AdUnitIds` and the Gradle AdMob App ID placeholder (feature 009), `AppLinks` (feature 007), the existing CI and "Distribute APK" workflows, and the branding images already in `assets/branding/`. This feature adds no new user-facing screen in the prod flavor.

## Clarifications

### Session 2026-10-28

- Q: When a version tag is pushed, where should the signed App Bundle end up? → A: Attached, with its mapping file, to the workflow run and to a GitHub release for the tag; no automatic Play upload (the internal testing track upload stays manual).
- Q: Are `https://daily-track-c5736.web.app/privacy` and `/terms` the final privacy policy and terms addresses? → A: Yes at first; later changed to `https://daily-track-c5736.web.app/privacy` and `/terms` on Firebase Hosting (published from `site/`), so no custom domain is needed.
- Q: When should CI run the integration tests on an Android emulator? → A: Only on version tags, before the bundle is built; a failure stops the release. Pull requests don't run them.
- Q: If the performance pass misses a §13 target, does that block the first release? → A: Writes under 100 ms and APK size per ABI always block; a cold start or scrolling miss of up to 20% may ship if recorded as an open item for the next version.
- Q: How are new or changed golden images created and committed from a Windows machine? → A: A manually run CI workflow renders them on Linux and offers them as a download; the developer reviews and commits them; pull request CI compares goldens.

**Actors**: the **release maintainer** (builds, signs, and ships the app), the **developer** (runs tests and the performance pass), and the **end user** (receives a fast, correctly branded, policy-compliant app).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visual regressions are caught before release (Priority: P1)

A developer changes a shared widget or token. The golden test run compares DSH-01, EXP-01, EXP-02, HAB-01, AUTH-01, and SET-01 in light and dark themes and in English and Gujarati against approved reference images, and fails on any visual difference, so the change is reviewed before it ships.

**Why this priority**: §13 names golden tests as part of the release test strategy, and they are the only automatic check of layout, theming, and Gujarati text rendering across the six highest-traffic screens.

**Independent Test**: Run the golden suite on Linux. Every one of the 28 required combinations (7 screen states × 2 themes × 2 languages) has a reference image and passes; changing a token makes the affected images fail.

**Acceptance Scenarios**:

1. **Given** the approved reference images, **When** the golden suite runs on Linux with no code change, **Then** all 28 required combinations pass.
2. **Given** a change to a color token, **When** the golden suite runs, **Then** every affected screen fails and names the image that differs.
3. **Given** AUTH-01 and SET-01, **When** their goldens render, **Then** AUTH-01 shows both login paths and SET-01 shows the account card, in both the guest and the Google state.
4. **Given** a golden test for a screen or state that no longer exists (for example the removed SYS-02 "Restore with Google"), **When** the audit runs, **Then** it is removed.
5. **Given** a developer on Windows or macOS, **When** they run the normal test command, **Then** golden tests are skipped and no reference image is written.

---

### User Story 2 - The main journeys work end to end (Priority: P1)

Before each release, the integration suite drives the real app (real database, fake Google sign-in and Drive clients, test ads) through the §13 journeys and the three journeys this feature adds, so a release never ships with a broken core flow.

**Why this priority**: Widget tests cover screens one at a time; only integration tests prove that screens, storage, routing, and startup work together.

**Independent Test**: Run the integration suite on an emulator. Each journey below runs from a fresh install and passes without network access.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the user adds an expense, **Then** it appears on Home and in Reports.
2. **Given** a fresh install, **When** the user creates a habit and checks in, **Then** the streak shows 1.
3. **Given** data on the phone, **When** the user backs up, erases all data, and restores, **Then** every row comes back.
4. **Guest flow**: **Given** a fresh install, **When** the user goes through Intro → Login → "Continue as guest" → adds an expense → "Log out of guest" → "Log out and delete", **Then** the expense is gone, the app is on Login, a restart opens Login, and at no point was a Google sign-in or Drive request made.
5. **Google flow**: **Given** a fresh install with fake sign-in and Drive clients, **When** the user signs in with Google → backs up → signs out → signs in again → restores, **Then** the restored data matches what was backed up, and each step shows the screen the spec names.
6. **App lock**: **Given** app lock is on, **When** the app cold-starts or returns from the background past the lock timeout, **Then** the unlock screen is shown, a wrong PIN is refused, and the right PIN opens the screen the user left.

---

### User Story 3 - Signed release builds come from a tag (Priority: P1)

The release maintainer pushes a version tag. An automated workflow builds a signed, shrunk release App Bundle with the production ad IDs, the version from the project's version field, and the production icon and splash, and makes it available to download. No signing key, keystore password, or production ad ID is ever stored in the repository.

**Why this priority**: The app cannot be published without a signed bundle, and building it by hand risks shipping test ad IDs, wrong versions, or a leaked key.

**Independent Test**: Push a test tag to a fork with the secrets set. The workflow produces a signed App Bundle whose version name and code match the project version, whose signature matches the upload key, and which contains no test ad ID. With a secret missing, the workflow stops before building and names the missing secret.

**Acceptance Scenarios**:

1. **Given** the signing details in a local, git-ignored signing file, **When** the maintainer builds the prod release locally, **Then** the bundle is signed with the upload key; **Given** no signing file, **Then** a store build fails with a message naming the missing file instead of silently signing with the debug key.
2. **Given** the project version `1.2.3+45`, **When** a release is built, **Then** the version name is `1.2.3` and the version code is `45`.
3. **Given** a release build, **When** it runs on a device, **Then** code shrinking is on, and every plugin feature still works (Drive backup and restore, sign-in, notifications, background jobs, home widget, ads, purchases, secure storage, PDF export).
4. **Given** the production ad IDs in the local, git-ignored production settings file or in CI secrets, **When** a prod release is built, **Then** the app and every ad placement use the production IDs; **Given** any dev-flavor or debug build, **Then** only Google's test IDs are used.
5. **Given** a pushed tag `vX.Y.Z` whose version does not match the project version, **When** the workflow runs, **Then** it fails before building and says the two differ.
6. **Given** a pushed version tag and all secrets set, **When** the workflow finishes, **Then** the signed App Bundle and its mapping file are attached to the workflow run and to a GitHub release named after the tag; nothing is uploaded to Play (the maintainer uploads to the internal testing track by hand).
7. **Given** any build log, **When** it is read, **Then** no signing password, key, or production ad ID is printed.

---

### User Story 4 - The app meets the §13 performance targets with heavy data (Priority: P2)

A developer opens the Developer section in a dev build, taps "Seed 10,000 transactions", and then measures cold start, scrolling, and save time against the §13 targets. The results, with the APK size per ABI, are recorded in a performance report, and any target that is missed is fixed or reported with its measured value.

**Why this priority**: §13 sets hard targets, and 10,000 transactions is the stated load; without a quick way to load that data, the targets cannot be checked.

**Independent Test**: In a dev build, seed 10,000 transactions, then run the performance checks on the reference device. The report lists every §13 target with its measured value and a pass or fail.

**Acceptance Scenarios**:

1. **Given** a dev-flavor build, **When** the developer taps "Seed 10,000 transactions" and confirms, **Then** 10,000 transactions spread over existing accounts and categories and the past 12 months are added, progress is shown, the app stays responsive, and a message says how many were added.
2. **Given** a prod-flavor build, **When** SET-01 is opened, **Then** neither the Developer section nor the seed action exists, and the seeding code is not reachable.
3. **Given** 10,000 transactions, **When** the app cold-starts to Home on a mid-range device, **Then** Home is shown in under 1.5 s.
4. **Given** 10,000 transactions, **When** the user scrolls EXP-01 top to bottom, **Then** it renders at 60 fps (no more than 1% of frames over the 16.7 ms budget; FR-018 allows up to 1.2% as an open item).
5. **Given** 10,000 transactions, **When** a transaction is saved or a habit checked in, **Then** the database write finishes in under 100 ms and the screen never freezes.
6. **Given** a release build split per ABI, **When** its size is measured, **Then** each ABI's APK is under 25 MB.
7. **Given** seeding runs a second time, **When** it completes, **Then** another 10,000 are added (it never deletes data) and Erase all data removes them like any other data.

---

### User Story 5 - The installed app looks finished (Priority: P2)

An end user installs the app and sees the DailyTrack icon (an adaptive icon with a monochrome layer for themed icons) on the home screen and launcher, and the branded splash on launch, in light and dark mode, on Android 7 through the latest version. Links to the privacy policy and terms open the live website.

**Why this priority**: The default Flutter icon or a broken policy link blocks store review and undermines trust, but it does not affect app behavior.

**Independent Test**: Install the prod release build on Android 7, Android 12+, and a device with themed icons on. Check the icon, the splash, and both links.

**Acceptance Scenarios**:

1. **Given** the prod or dev build, **When** it is installed, **Then** the launcher shows the DailyTrack icon generated from `assets/branding/`, adaptive on Android 8+ and with a monochrome layer for themed icons on Android 13+.
2. **Given** a cold start, **When** the app launches, **Then** the branded splash is shown on Android 7–11 and the Android 12+ splash API, in light and dark mode, with no white flash before SYS-01.
3. **Given** SET-01 Privacy and About, **When** the user taps the privacy policy or terms link, **Then** the final website page opens: `https://daily-track-c5736.web.app/privacy` or `https://daily-track-c5736.web.app/terms`.
4. **Given** a prod build, **When** the privacy or terms URL is checked, **Then** it uses HTTPS and is not a placeholder.

---

### User Story 6 - A final audit proves release readiness (Priority: P2)

Before tagging the first release, the maintainer runs the release audit. It reports, for every acceptance criterion in `docs/spec.md`, the test that covers it, and checks the code for leftover markers, banned wording, test ad IDs in prod builds, and the Play Store compliance items the code controls. Anything that fails is fixed or listed as open.

**Why this priority**: The constitution requires a test for every acceptance criterion; the audit is the single place that proves it for the whole app before the first public release.

**Independent Test**: Run the audit. It produces a criteria-to-test table with no gaps, and each automated check passes; deliberately adding a `TODO` or a test ad ID to prod makes it fail.

**Acceptance Scenarios**:

1. **Given** `docs/spec.md`, **When** the audit runs, **Then** every acceptance criterion (every `- [ ]` item in a section's acceptance criteria) is listed with at least one test that covers it, and a criterion with no test fails the audit.
2. **Given** the source code, **When** the audit runs, **Then** it finds no `TODO`, `FIXME`, "Replaced in", or "Interim" markers in app code, build files, or tests.
3. **Given** the UI strings in English, Hindi, and Gujarati, **When** the audit runs, **Then** none contains "Sync" or "Synced" in any form.
4. **Given** a prod release build, **When** its compiled output is inspected, **Then** it contains none of Google's test ad unit IDs or test App ID; **Given** a dev or debug build, **Then** it contains no production ad ID.
5. **Given** the §13 Play Store compliance items the code controls, **When** the audit runs, **Then** each is checked and passes: the Android backup rules include only the database and exclude secure storage and the no-backup folder; the privacy policy is linked in SET-01; no ad shows on lock, forms, onboarding, login, account dialogs, or premium screens; ads keep an 8 dp gap from tappable controls; interstitials only follow the frequency cap; exact-alarm permissions are either not requested or justified; purchases are acknowledged and "Restore purchase" exists; no financial or habit data reaches the ad SDK; the child-directed tag stays unspecified; the requested Google scopes are only `email`, `profile`, and Drive `appDataFolder`; target API level is the latest Play requires and min API is 24.
6. **Given** the items that need a console (data safety form, OAuth verification, target audience, `app-ads.txt`), **When** the audit report is written, **Then** they are listed as manual steps with what the code already provides for each.
7. **Given** a finished audit, **When** §14 is updated, **Then** T5.1 is checked, and T5.2 is checked only when its manual steps are also done.

---

### Edge Cases

- **Goldens rendered on Windows or macOS**: they are never committed; reference images are generated only on Linux (CI or WSL), and a run on another platform skips the golden tag.
- **Gujarati glyphs in goldens**: the golden harness loads the app's bundled fonts so Gujarati text renders as real glyphs, not boxes.
- **Integration tests and the network**: every journey uses fake sign-in and Drive clients and test ads; none needs internet, and a real Google account is never used.
- **Integration test order**: each journey starts from a fresh install state, so a failing journey cannot break the next.
- **Seeding while app lock or a backup runs**: seeding waits for or refuses an in-progress backup or restore and says why; it never runs during a restore.
- **Seeding and the guest or Google state**: seeded rows count as user data (ACC-02 treats the phone as having data); seeding does not trigger an immediate Drive backup beyond the normal auto backup rules.
- **Seeding and budgets or recurring rules**: seeded transactions never create budget alert notifications in bulk.
- **Seeding interrupted** (app killed): rows already written stay valid; no half-written transaction exists.
- **Missing signing file locally**: debug and dev builds still build; only a store build of the prod release fails, with a clear message.
- **Missing production ad IDs**: a prod release that is not a store build falls back to test IDs and requests no ads (feature 009 behavior); a store build fails.
- **Shrinking removes code a plugin needs**: covered by keep rules; the release-build smoke check exercises each plugin feature.
- **Version code reused**: Play rejects it; the workflow checks that the tag matches the project version so the maintainer bumps both.
- **Tag pushed without secrets**: the workflow fails before building and names each missing secret.
- **Tag on a commit that fails CI checks**: the workflow runs analyze, format, tests, and the integration suite first, and builds nothing if any fails.
- **Emulator flake on a tag run**: the maintainer re-runs the failed workflow for the same tag; the tag is not moved or re-pushed.
- **Icons on old Android**: Android 7.0–7.1 get the legacy square/round icon; adaptive and monochrome layers appear only where supported.
- **Dark splash**: the splash background follows the system theme; there is no light flash in dark mode.
- **Cold start or scrolling target missed with 10,000 rows**: the report shows the measured value; a miss within 20% is recorded as an open item and does not block; a larger miss blocks T5.1 until fixed (FR-018).
- **Write or APK size target missed**: always blocks T5.1 and the release tag until fixed.
- **Perf test flakiness on slow machines**: timing targets are measured on the reference device in profile mode, not in widget tests on developer machines.

## Requirements *(mandatory)*

### Functional Requirements

**Golden tests**

- **FR-001**: The golden suite MUST cover DSH-01, EXP-01, EXP-02, HAB-01, AUTH-01, and SET-01, each in light and dark themes and in English and Gujarati (at least 28 reference images: 7 screen states, counting SET-01 guest and Google separately), at a phone size of 360 × 800 dp.
- **FR-002**: SET-01 goldens MUST include the account card in both the guest and the Google states; AUTH-01 goldens MUST show the default state with both login paths.
- **FR-003**: Golden tests MUST render with the app's bundled fonts and fixed data and time, so results are deterministic.
- **FR-004**: Reference images MUST be generated and compared only on Linux; on other platforms the golden tests MUST be skipped by the normal test command. A manually run CI workflow MUST render the reference images on Linux and offer them as a downloadable artifact, which the developer reviews and commits by hand; that workflow never commits or opens pull requests itself. Pull request CI MUST compare goldens and fail on any difference.
- **FR-005**: Golden tests for screens or states removed by earlier features (for example SYS-02 "Restore with Google") MUST be deleted.

**Integration tests**

- **FR-006**: The integration suite MUST include the three §13 journeys: add expense → shown on Home → shown in Reports; create habit → check in → streak; backup → erase → restore.
- **FR-007**: The integration suite MUST include a guest journey: Intro → Login → "Continue as guest" → add expense → "Log out of guest" → "Log out and delete" → Login, and MUST assert that no Google sign-in or Drive request was made.
- **FR-008**: The integration suite MUST include a Google journey with fake sign-in and Drive clients: sign in → back up → sign out → sign in → restore, and MUST assert the restored data equals the backed-up data.
- **FR-009**: The integration suite MUST include an app lock journey: lock on → cold start shows unlock → wrong PIN refused → right PIN opens; and return from background past the timeout re-locks.
- **FR-010**: Every integration journey MUST run offline against a real on-device database, start from a fresh install state, and use test ads.
- **FR-011**: The tag workflow MUST run the integration suite on an Android emulator before building the bundle; if any journey fails, no bundle is built and no release is created. Pull request CI does not run the integration suite.

**Developer seeding and performance**

- **FR-012**: The dev-flavor Developer section in SET-01 MUST offer "Seed 10,000 transactions", which asks for confirmation, then adds 10,000 transactions (a realistic mix of expenses, income, and transfers across existing accounts and categories, dated over the past 12 months), shows progress, keeps the app responsive, and reports the number added.
- **FR-013**: The seed action and its code path MUST NOT exist or be reachable in the prod flavor.
- **FR-014**: Seeded transactions MUST be ordinary user data: they obey every data rule (money in minor units, UTC dates, soft delete), appear everywhere real data appears, are included in backups and exports, and are removed by Erase all data.
- **FR-015**: Seeding MUST NOT post bulk notifications (budget alerts, daily summary) and MUST NOT run while a backup or restore is in progress.
- **FR-016**: A performance pass MUST measure, with 10,000 seeded transactions on a mid-range reference device (about 4 GB RAM) in a profile or release build: cold start to Home (target under 1.5 s), EXP-01 scrolling (target 60 fps, at most 1% of frames over budget), save transaction and habit check-in database writes (target under 100 ms), and per-ABI APK size of the release build (target under 25 MB each).
- **FR-017**: The scroll and write measurements MUST be repeatable from an automated performance test that a developer can run on a device; cold start and APK size MUST have a documented, repeatable measuring procedure.
- **FR-018**: The performance results MUST be recorded in a performance report in the feature folder with the device, build, measured value, target, and pass or fail. The write target (under 100 ms) and the APK size target (under 25 MB per ABI) MUST pass before T5.1 is checked or a release is tagged. A cold start or scrolling miss of up to 20% (cold start up to 1.8 s; up to 1.2% slow frames) MAY ship only if the report records it as an open item for the next version; a larger miss blocks like the hard targets.

**Release build**

- **FR-019**: The prod release MUST be signed with the upload key read from a git-ignored signing file (`android/key.properties` and the keystore it names) or, in CI, from secrets; neither the file, the keystore, nor any password MAY be committed.
- **FR-020**: A store build without signing details MUST fail with a message naming the missing file; debug and dev builds MUST still build without it.
- **FR-021**: The prod release MUST enable code shrinking and resource shrinking, with keep rules for every plugin that needs them, and MUST pass a release smoke check of each plugin feature (Google sign-in, Drive backup and restore, notifications and their action buttons, background jobs, home widget, ads and consent, purchases, secure storage, file sharing, PDF export, local auth if used).
- **FR-022**: The version name and version code MUST come only from the project's version field (`name+code`), with no other place to edit.
- **FR-023**: The production AdMob App ID and ad unit IDs MUST be read at build time from a git-ignored production settings file (`config/prod.env.json`) locally or from CI secrets; an example file with placeholder values MUST be committed and documented.
- **FR-024**: Dev-flavor and debug builds MUST always use Google's official test App ID and test ad unit IDs, whatever values are supplied.
- **FR-025**: The release build output and logs MUST NOT print signing passwords, keys, or production ad IDs.

**Branding**

- **FR-026**: The launcher icon, adaptive icon (foreground and background), and monochrome layer for themed icons MUST be generated from `assets/branding/` for every flavor, and the generated files MUST be committed so builds don't depend on running the generator.
- **FR-027**: The native splash MUST be generated from `assets/branding/` for the pre-Android 12 splash and the Android 12+ splash API, with light and dark backgrounds that match the app's tokens, and MUST hand over to SYS-01 without a visible flash.

**Links**

- **FR-028**: The privacy policy and terms URLs MUST default to the final pages `https://daily-track-c5736.web.app/privacy` and `https://daily-track-c5736.web.app/terms` (Firebase Hosting, published from `site/` with `firebase deploy --only hosting`), and MUST still be overridable at build time; the audit checks that both use HTTPS and are on that host.

**Release workflow**

- **FR-029**: A CI workflow MUST run when a version tag (`v<major>.<minor>.<patch>`) is pushed, check that the tag matches the project version, run analyze, format, unit and widget tests, and the integration suite (FR-011), and then build a signed prod release App Bundle from secrets.
- **FR-030**: The workflow MUST fail before building, naming each missing secret, when a required secret (keystore, keystore password, key alias, key password, AdMob App ID, ad unit IDs) is absent.
- **FR-031**: The workflow MUST attach the signed App Bundle and its mapping file (for crash deobfuscation) to the run and to a GitHub release for the tag. It MUST NOT upload to Play and needs no Play credentials; the internal testing track upload is a manual step in the audit report.
- **FR-032**: The workflow MUST never write secrets to logs or to the repository, and MUST remove the decoded keystore after the build.

**Audit**

- **FR-033**: A release audit MUST produce a criteria-to-test table listing every acceptance criterion in `docs/spec.md` with at least one covering test; a criterion without a test MUST be added a test or reported as a gap.
- **FR-034**: An automated check MUST fail when app code, build files, or tests contain `TODO`, `FIXME`, "Replaced in", or "Interim" markers.
- **FR-035**: An automated check MUST fail when any English, Hindi, or Gujarati UI string contains "sync" in any case or form.
- **FR-036**: An automated check MUST fail when a prod release build contains any Google test ad ID or test App ID, or when a dev or debug build contains a production ad ID.
- **FR-037**: The audit MUST check each code-controlled §13 Play Store compliance item listed in User Story 6 scenario 5, and MUST list the console-only items as manual steps.
- **FR-038**: When the audit and the performance pass are complete, `docs/spec.md` §14 T5.1 MUST be checked; T5.2 MUST stay unchecked until its manual steps are done, and the §13 checklist items the code satisfies MUST be checked.

### Key Entities *(include if feature involves data)*

- **Golden reference image**: an approved picture of one screen in one theme and one language, generated on Linux; compared on every golden run.
- **Integration journey**: one scripted end-to-end flow on a real device database with fake external clients.
- **Seeded transaction**: an ordinary transaction created by the dev-only seed action; indistinguishable from user-entered data.
- **Performance report**: per target — device, build type, data size, measured value, target, pass or fail.
- **Signing details**: upload keystore, its passwords, and key alias; local in a git-ignored file or in CI secrets only.
- **Production build settings**: AdMob App ID, ad unit IDs, and other prod-only build values; local in a git-ignored file or in CI secrets only.
- **Criteria-to-test table**: each acceptance criterion in `docs/spec.md` mapped to the test or tests that cover it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the 28 required golden combinations (7 screen states × 2 themes × 2 languages; SET-01 has a guest and a Google state) have an approved reference image and pass on Linux.
- **SC-002**: All 7 integration journeys (the six in User Story 2 plus the smoke test) pass on an emulator, offline, with zero real Google or Drive requests.
- **SC-003**: With 10,000 transactions on the reference device, saves complete in under 100 ms (blocking); Home appears in under 1.5 s from a cold start and the transactions list scrolls with no more than 1% slow frames, or any miss is within 20% and recorded as an open item.
- **SC-004**: Every per-ABI release APK is under 25 MB.
- **SC-005**: Pushing a version tag produces a signed release bundle with no manual steps, and the bundle's version matches the project version every time.
- **SC-006**: 0 signing secrets or production ad IDs exist in the repository history added by this feature, and 0 test ad IDs exist in the prod release build.
- **SC-007**: 100% of acceptance criteria in `docs/spec.md` map to at least one test in the criteria-to-test table.
- **SC-008**: 0 `TODO`, "Replaced in", or "Interim" markers in app code and tests, and 0 UI strings containing "Sync" in any of the three languages.
- **SC-009**: Every code-controlled Play Store compliance item in §13 passes the audit, and every console-only item is listed as a manual step.
- **SC-010**: The release build passes the plugin smoke check with no crash on Android 7 and on the latest Android version.

## Assumptions

- **Platform for goldens**: reference images are generated on Linux only (project rule), through the manual CI workflow in FR-004, so a Windows developer can update them without WSL.
- **Reference device**: "mid-range device" in §13 is a phone with about 4 GB RAM on a recent Android version; cold start and fps are measured on it in profile or release mode, not in widget tests, because timing in widget tests on developer machines is unreliable (the DSH-01 300 ms widget test is already flaky).
- **Existing tracked config**: `config/dart_defines.json` holds Firebase client values and the Google web client ID, which are not secrets and stay as they are; the new `config/prod.env.json` holds only prod-only values (AdMob IDs and any other secret build values) and is git-ignored.
- **Existing ad ID handling**: the feature 009 rules stay: ad unit IDs come in through build defines, the App ID through a Gradle placeholder, and dev and debug builds force test IDs. This feature adds the production settings file and CI secrets as the sources.
- **Existing workflows**: the current CI workflow and the manual "Distribute APK" workflow stay; the tag workflow is new and separate.
- **Branding images**: the files already in `assets/branding/` (app icon, adaptive foreground and background, monochrome, logo, Android 12 splash) are final; the dev flavor may add a "Dev" marker to tell it apart.
- **Tag format**: `v<major>.<minor>.<patch>` (for example `v1.0.0`); the version code is bumped by hand in the project version.
- **Audit scope**: "acceptance criteria" means the checkbox items under each section's acceptance criteria in `docs/spec.md`; criteria that can only be checked on a device or in a console are mapped to a device check or a manual step rather than an automated test.
- **Seed action placement**: it sits in the existing dev-only Developer section next to "Unlock all" and "Reset ad counters", so no new prod UI or prod strings are needed beyond the Developer section's own strings.
- **Out of scope**: Play Console, AdMob, and Google Cloud console setup; the data safety form; OAuth consent verification; store listing text and images; hosting the website and `app-ads.txt`. These are listed as manual steps in the audit report.
