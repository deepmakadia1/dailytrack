# Quickstart: Google Account and Cloud Backup (§16)

How to check that the feature works.
- Contracts: [services.md](contracts/services.md), [screens.md](contracts/screens.md),
  [routes.md](contracts/routes.md), [android.md](contracts/android.md).
- State and formats: [data-model.md](data-model.md). Decisions: [research.md](research.md).

## 1. Prerequisites

- The feature 008 Google setup (its quickstart §1): Drive API enabled, Android OAuth clients for
  both flavors, and `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>`. The OAuth consent screen now also
  lists the `email` and `profile` scopes (research R2).
- No new packages (research R3, R17). Run `flutter pub get` anyway after pulling.
- Two Android devices or emulators with Google Play services, signed in to the same test Google
  account, for the conflict checks. One at API 31 or later and one at API 30 or lower for the two
  Android backup rule files.

## 2. Quality gates (constitution)

```sh
dart run build_runner build --delete-conflicting-outputs
python tool/l10n/phase0_strings.py && flutter gen-l10n
flutter analyze                      # zero warnings
dart format --set-exit-if-changed .
flutter test --exclude-tags golden   # on Windows/macOS; full `flutter test` on Linux CI
```

## 3. Focused test runs

```sh
flutter test test/core/backup/domain/       # trigger, change counter, conflict, rotation, meta codec, status, safety policy (fake clock)
flutter test test/core/account/             # AccountService transitions, device identity table, AccountRestore paths
flutter test test/core/database/            # migration 4 → 5, trigger coverage test (data-model §2)
flutter test test/features/account/         # ACC-01, ACC-02, ACC-03, Finish setting up: every copied criterion
flutter test test/features/onboarding/      # SYS-02 Restore with Google criteria
flutter test test/features/settings/        # SET-01 Account row, SET-02 Drive card and safety copy tile
flutter test test/android/                  # backup rules XML parse test
```

Expected: every acceptance criterion copied into `spec.md` maps to at least one named test
(`ACC-01 …`, `ACC-02 …`, `ACC-03 …`, `SYS-02 …`, `SET-01 …`, `§16 …` in the test names).

## 4. Device checks

Run `flutter run --flavor dev --dart-define=GOOGLE_SERVER_CLIENT_ID=<id>` on device A.

1. **Sign in, first backup (ACC-01)**: fresh test account with no backups. More → Account → Sign in with Google.
   Expect "Signed in. Your data is backed up.", Auto backup now Daily, and ACC-01 showing the name, photo,
   email, and "Last backup: Today, … · <device A model>".
2. **Background backup**: add an expense, press Home. Within a minute (on Wi-Fi), the last backup time
   updates. Add another and press Home again at once: no new backup until 15 minutes have passed
   (`adb shell dumpsys jobscheduler | grep backgroundBackup` shows one pending job at most).
3. **Wi-Fi only**: turn Wi-Fi off with mobile data on, add data, press Home. ACC-01 shows "Waiting for Wi-Fi".
   Turn Wi-Fi on; the backup runs.
4. **Metadata**: SET-02 → Restore from Google Drive. Each row shows device name, counts, Manual/Auto.
5. **New phone (SYS-02)**: install on device B (fresh). On step 1 tap "Restore with Google", pick the account.
   Expect "Restoring your data…", then Home with the same language, currency, modules, and data; then the
   Finish setting up sheet; "Pro restored" if the account owns Pro.
6. **Conflict**: on device B add data and press Home (B backs up). On device A add data and press Home.
   Expect no upload from A, one "Backup paused" notification, and ACC-01 "Backup paused …" with Review.
   Tap Back up now: the warning dialog names device B; Cancel uploads nothing.
7. **Restore choice + safety copy (ACC-02)**: on A tap Review → Restore from account. Data now matches B.
   SET-02 shows "Restore previous phone data"; restoring it brings A's data back.
8. **Sign out (ACC-03)**: airplane mode, add data, Account → Sign out. Expect the failed state with
   "Sign out anyway"; choose Remove → typed DELETE dialog appears. Cancel. Back online, sign out with
   Keep: data stays, ACC-01 signed out.
9. **Delete my backups**: sign in again on A, Delete my backups, confirm. SET-02 Drive list is empty; local
   data and the sign-in stay.
10. **Android Auto Backup**: with app lock on, run
    `adb shell bmgr backupnow <applicationId>`, uninstall, reinstall (`adb install`), then
    `adb shell bmgr restore <token> <applicationId>` (or use the restore that happens on install).
    Start the app: no onboarding, no lock screen (no PIN), Finish setting up sheet on Home, data present.
    `adb shell run-as <applicationId> ls app_flutter` before backup confirms the `dailytrack.sqlite` path
    used in the rules (research R14).
11. **Secrets stay home**: after step 10, Security shows app lock off, and SET-02 "Encrypt backup", if it
    was on, reports that the password must be set again (research R13).
