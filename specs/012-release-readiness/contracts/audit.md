# Contract: Release audit

## Outputs (in `specs/012-release-readiness/`)

| File | What it holds | Checked by |
|---|---|---|
| `criteria-coverage.md` | every `docs/spec.md` acceptance criterion → test (format in [data-model.md](../data-model.md) §7) | `test/audit/criteria_coverage_test.dart` |
| `compliance.md` | each §13 Play Store item: code-controlled (check, result) or console-only (manual step, what the code provides); the R14 device smoke results | people, at release |
| `performance-report.md` | §13 targets (format in data-model §6) | people, at release; the device perf tests enforce the limits |

## Automated checks

| Test or script | Scope | Fails on |
|---|---|---|
| `test/audit/criteria_coverage_test.dart` | `docs/spec.md` "Acceptance criteria" checkbox items vs `criteria-coverage.md` | a missing, extra, or stale row; a missing test file; a test name substring not found |
| `test/audit/markers_test.dart` | `lib/`, `test/`, `integration_test/`, `tool/`, `android/app/**/*.kts`, `android/app/src/main/**/*.{kt,xml}`, `.github/workflows/`; skips generated files and this test's own pattern list | `\bTODO\b`, `\bFIXME\b`, `Replaced in`, `\bInterim\b` (case-insensitive) |
| `test/core/l10n/no_sync_wording_test.dart` (existing) | en/hi/gu ARB values and Android `strings.xml` | `sync` in any case |
| `test/core/ads/domain/ad_unit_ids_test.dart` (extended) | `AdUnitIds.resolveFor` | a dev or debug build returning non-test IDs; prod release without an App ID returning anything but `none` |
| `test/android/manifest_test.dart` (extended) | `AndroidManifest.xml` | `USE_EXACT_ALARM`; a permission outside the allow-list |
| `test/android/backup_rules_test.dart` (existing) | backup rules XML | an include other than the database; secure storage or the no-backup folder not excluded |
| `test/audit/google_scopes_test.dart` (new) | `GoogleAuth.scopes` and the sign-in scopes | anything but `email`, `profile`, `drive.appdata` |
| `test/core/theme/splash_colors_test.dart` (new) | `pubspec.yaml` `flutter_native_splash` vs `app_colors.dart` | the light or dark surface differs |
| `tool/release/check_bundle.sh` | the built `.aab` | see [build.md](build.md) |

## Spec updates when the audit passes

- `docs/spec.md` §14: check `T5.1`. `T5.2` stays unchecked until the manual steps in
  `compliance.md` are done.
- `docs/spec.md` §13 Play Store checklist: tick only the items marked code-controlled and passing in
  `compliance.md`. The Android Auto Backup rules item is one; so is the code half of the ads policy
  item.
- `docs/CLAUDE.md`: add the release commands, the `goldens.yml` baseline routine, and the rule that
  `config/prod.env.json` and `key.properties` are never committed.
