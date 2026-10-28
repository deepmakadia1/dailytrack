# Contract: CI workflows

## `release.yml` (new): signed App Bundle from a version tag

**Trigger**: `push` of a tag matching `v[0-9]+.[0-9]+.[0-9]+`. Concurrency is `release-${{ github.ref }}`,
and a running release is never cancelled.
**Permissions**: `contents: write`. Nothing else.

```text
verify ──┬──> checks ──────┐
         └──> integration ─┴──> build ──> (GitHub release)
```

| Job | Runs | Fails when |
|---|---|---|
| `verify` | secret presence; `PROD_ENV_JSON` shape (jq); tag = `v` + pubspec name | any secret is empty (named in an `::error::`); bad JSON or a test publisher ID; the tag and version differ (both printed) |
| `checks` | `flutter pub get`, build_runner, `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test` (goldens included once the baselines are committed) | any step fails |
| `integration` | KVM; `reactivecircus/android-emulator-runner@v2` (API 34, google_apis, x86_64, AVD cached); `flutter test integration_test --flavor dev` | any journey fails |
| `build` | decode the keystore → `$RUNNER_TEMP/upload.jks`; write `android/key.properties`; mask and write `config/prod.env.json`; `DAILYTRACK_STORE_BUILD=true flutter build appbundle --release --flavor prod --dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json`; `check_bundle.sh … prod`; `apk_sizes.sh`; upload artifacts; `gh release create` | any step fails; an APK is ≥ 25 MB |
| cleanup (`if: always()` in `build`) | `rm -f` the keystore, `android/key.properties`, `config/prod.env.json` | never fails the job |

**Outputs**
- Run artifact `dailytrack-<tag>`: `app-prod-release.aab` and `mapping.txt`, kept 90 days.
- GitHub release `<tag>` (`--verify-tag --generate-notes`) with the same two files.
- No Play upload (clarification Q1).

**Secrets**: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ANDROID_KEY_PASSWORD`, `PROD_ENV_JSON` (see [data-model.md](../data-model.md) §2).

**Re-running**: "Re-run failed jobs" on the same tag is the supported recovery for an emulator
flake. If a GitHub release for the tag already exists, the step uploads with `--clobber` instead of
failing.

## `goldens.yml` (new): regenerate golden baselines

**Trigger**: `workflow_dispatch`, with optional input `filter` (a test name pattern). Runs on
`ubuntu-latest` with the same Flutter version as `ci.yml`.

| Step | Command |
|---|---|
| Generate | `flutter test --tags golden --update-goldens ${filter:+--plain-name "$filter"}` |
| Upload | artifact `golden-baselines`: `test/goldens/*.png` |

It never commits, pushes, or opens a pull request (clarification Q5). The developer downloads the
artifact, reviews the images, and commits them.

## `ci.yml` (changed)

| Change | Why |
|---|---|
| Build the prod App Bundle (debug key, no secrets) on **every pull request** and push, not only on `main` | constitution: "a release App Bundle build on every pull request" |
| New step: run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, then `git diff --exit-code android/app/src/main/res` | the committed icons and splash match `assets/branding/` (research R6) |
| Drop `--exclude-tags golden` in the same change that commits the first baselines | pull requests compare goldens (clarification Q5) |
| No integration tests | clarification Q3 |

## `distribute.yml` (small change)

If the `PROD_ENV_JSON` secret is set, write it to `config/prod.env.json` and pass the second
`--dart-define-from-file`, so prod release testers see real ads. If it isn't, behavior is the same
as today.
