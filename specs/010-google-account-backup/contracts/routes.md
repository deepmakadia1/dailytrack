# Contract: Routes

Added to `lib/app/router/routes.dart` (single source of paths), matching `docs/spec.md` §5:

| Screen | Name | Path | Segment | Opens as |
| --- | --- | --- | --- | --- |
| ACC-01 | `Routes.account` | `/more/account` | `accountSegment = 'account'` | Push under the More tab branch |
| ACC-02 | — | — | — | Bottom sheet (`showRestoreChoice`) |
| ACC-03 | — | — | — | Bottom sheet (`showSignOutSheet`) |

`docs/spec.md` §5 also lists AUTH-01 (`/login`) and ACC-04 (dialog) and adds the `authMode` redirect; feature 011 adds them, not this feature.

- ACC-01 is pushed from the SET-02 Drive card's account email (interim I3, **Replaced in 011**: also from the SET-01 account card). It is only reachable while signed in and pops when the account becomes signed out.
- The Backup notification for a conflict pause uses payload `Routes.account`; the failure notice keeps `Routes.backup`. A pause notice tapped after the account was signed out opens the More tab instead.
- Opening `/more/account` while locked waits for unlock like every other notification target (existing behavior in `app.dart`).
- After ACC-03 "Keep data on this phone", and after a cancelled Switch account chooser, the app goes to `Routes.more` (interim I4, **Replaced in 011**: `authMode = none` → `/login`).
- After ACC-03 "Remove data from this phone", Erase all data resets settings and invalidates bootstrap, and the onboarding redirect sends the user to `/onboarding` (existing behavior; interim I4, **Replaced in 011**: `/login`, with onboarding done kept).
- Ads: `isReadingLocation` (`router_ad_screen_probe.dart`) counts `/more/account` as a reading screen like the rest of More. No interstitial trigger starts there (ACC-01 "Back up now" fires none, FR-010), and ACC-02, ACC-03, and Finish setting up are sheets, so the probe needs no change. A test checks that "Back up now" on ACC-01 calls no `maybeShowInterstitial`.
