# Contract: Screens

Every screen uses `AppTokens` and shared widgets from `lib/core/widgets/` only, strings from ARB files (research R15), 48 dp targets with semantic labels, and passes the §15.10 checklist in light/dark, English/Gujarati, 200% font scale, 360 dp width. No screen here shows or requests an ad.

## AUTH-01 Login — `lib/features/auth/presentation/screens/login_screen.dart`

Controller: `lib/features/auth/presentation/controllers/login_controller.dart` (`LoginController`, state in data-model §4).

| Element | Key | Behavior |
| --- | --- | --- |
| Logo + app name | `auth01_logo` | as SYS-01 |
| Title, body | `auth01_title`, `auth01_body` | "Keep your data safe", value line |
| "Continue with Google" (`FilledButton`, the one primary) | `auth01_google` | `LoginController.continueWithGoogle()`; shows progress while `signingIn`; disabled while busy |
| "Continue as guest" (`OutlinedButton`) | `auth01_guest` | `LoginController.continueAsGuest()`: `setFinishSetupPending(true)` then `setAuthMode(guest)`; no network read, no Google or Drive call |
| Guest note (`bodySmall`) | `auth01_guestNote` | static |
| Inline error + "Try again" | `auth01_error`, `auth01_tryAgain` | cancelled / failed / offline texts (spec FR-017, FR-018); "Try again" reruns `continueWithGoogle()` |
| Restoring view | `auth01_restoring` | full-screen progress "Restoring your data…" (no-data restore runs inside ACC-02's flow; this view covers the time before and after it) |
| Restore error view | `auth01_restoreFailed`, `auth01_restoreTryAgain`, `auth01_continueWithoutRestoring` | spec FR-019 |

- `PopScope`: back pops the route stack's root → `SystemNavigator.pop()` (app closes). No app bar.
- States: loading (signing-in progress and the restoring view), error (inline error, restore error), and content. Empty state omitted (fixed controls; this contract and the plan say so, constitution V).
- After ACC-03 "Keep data on this phone", the snackbar `auth01_signedOutKept` ("Signed out. Your data is still on this phone.") is shown through `rootMessengerKey` by the sign-out sheet after the redirect.

## SYS-02 Intro — `lib/features/onboarding/` (changes only)

- Remove "Restore with Google" (`sys02.restoreWithGoogle`, `_RestoreWithGoogle`, `LanguageStep.restore`) and the step 4 "Set app lock" button (`onboarding_set_app_lock`).
- Step 4 body: data is kept on this phone; the next step lets the user back it up with Google or continue as a guest. "Allow notifications" and "Get started" stay.
- "Get started"/Skip unchanged in code (`completeOnboarding`); the redirect now opens AUTH-01.

## SET-01 account card — `lib/features/account/presentation/widgets/account_card.dart`

State: the plain `accountCardViewProvider` in `lib/core/account/account_providers.dart` (data-model §5); no Notifier, so SET-01 keeps one. Placed first in SET-01's list (before the premium card) through `AccountUi.accountCard()`.

| State | Content | Keys |
| --- | --- | --- |
| Guest | `CategoryAvatar` with a person icon, "Guest · Data saved only on this phone", primary "Sign in with Google" (guest sign-in through `AccountUi.startGuestSignIn`, the same call SET-02 and ACC-04 make: snackbar, ACC-02 via `showRestoreChoice(afterSignIn: true)`, offline text). The card itself has no `onTap`. | `set01_accountCard`, `set01_accountGuest`, `set01_accountSignIn` |
| Google | Photo (cached, never awaited) or initial in `CategoryAvatar`, name, email, status line; tap → `context.push(Routes.account)` | `set01_accountGoogle`, `set01_accountStatus` |

Status line texts: "Backed up to Google · {time}" (relative), "Backing up…", "Not backed up yet", "Backup paused" / "Backup failed" in `warning` color with an icon (never color alone). Never "Synced"/"Sync".

## SET-01 Data group (changes only) — `lib/features/settings/presentation/screens/settings_screen.dart`

- "Log out of guest" row, `error` color text, key `set01_logOutGuest`, only while `authMode == guest`; taps `AccountUi.showLogOutGuest(context)`.
- Erase all data unchanged in UI; its erase now keeps onboarding and device preferences and lands on Home (clarification Q1).

## ACC-04 Log out of guest — `lib/features/account/presentation/widgets/log_out_guest_dialog.dart`

Controller: `controllers/log_out_guest_controller.dart` (`ready` → `deleting` → `error`).

| Element | Key | Behavior |
| --- | --- | --- |
| Title, body | `acc04_title`, `acc04_body` | spec texts |
| "Sign in with Google instead" (text) | `acc04_signInInstead` | closes, then `AccountUi.startGuestSignIn(context)` |
| "Cancel" | `acc04_cancel` | closes; back and tapping outside do the same |
| "Log out and delete" (`error` color) | `acc04_confirm` | progress on the button, all actions disabled, barrier not dismissible; `eraseAll(scope: guestLogOut)`; the redirect opens AUTH-01 |
| Error | `acc04_failed` | "Couldn't delete your data. Try again."; user stays a guest |

Built on `ConfirmDialog`'s layout (title, consequence, destructive action) with the extra text button; if `ConfirmDialog` can't take a third action, it gains an optional `secondaryAction` (one shared-widget change, with its widget test).

## ACC-01, ACC-03 (changes only)

- ACC-01: remove the `router.go(Routes.more)` branches (interim I4); Switch account calls `signOut(to: guest)` then `AccountSignIn.run()`; a cancelled chooser leaves `guest`, and rule 7 returns to SET-01 with the guest card. Status also reads the backup lease (research R11).
- ACC-03: `signOut(to: none)`; no navigation in the sheet; "Keep data" shows `auth01_signedOutKept` after the redirect; "Remove data" runs `eraseAll(scope: thisPhoneData)` after sign-out.

## SYS-03 "Forgot PIN?" (changes only)

The restore path (010 T064) for a guest uses `signIn()`, and `commitSignIn()` only after the restore succeeds (clarification Q2); a cancelled sign-in or failed restore clears the keys it saved and leaves `authMode = guest`. A user already signed in with Google keeps `google` either way (the restore uses the current account; `commitSignIn()` is a no-op for the mode). The erase path uses `eraseAll(scope: thisPhoneData)`.
