# Contract: Routes

Added to `lib/app/router/routes.dart` (single source of paths):

| Screen | Name | Path | Segment | Opens as |
| --- | --- | --- | --- | --- |
| ACC-01 | `Routes.account` | `/more/account` | `accountSegment = 'account'` | Push under the More tab branch |
| ACC-02 | — | — | — | Bottom sheet (`showRestoreChoice`) |
| ACC-03 | — | — | — | Bottom sheet (`showSignOutSheet`) |

- The Backup notification for a conflict pause uses payload `Routes.account`; the failure notice keeps `Routes.backup`.
- Opening `/more/account` while locked waits for unlock like every other notification target (existing behavior in `app.dart`).
- After ACC-03 "Remove data from this phone", Erase all data invalidates bootstrap and the onboarding redirect sends the user to `/onboarding` (existing behavior).
- Ads: `isReadingLocation` (`router_ad_screen_probe.dart`) counts `/more/account` as a reading screen like the rest of More. No interstitial trigger starts there (ACC-01 "Back up now" fires none, FR-010), and ACC-02, ACC-03, and Finish setting up are sheets, so the probe needs no change. A test checks that "Back up now" on ACC-01 calls no `maybeShowInterstitial`.
