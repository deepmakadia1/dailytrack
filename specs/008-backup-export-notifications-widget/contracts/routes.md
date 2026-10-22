# Contract: Routes

## New routes (`lib/app/router/routes.dart`)

| Screen | Path | Name | Placement |
| --- | --- | --- | --- |
| SET-02 Backup and restore | `/more/backup` (segment `backup`) | `backup` | Child of the More branch (push) |
| SET-03 Export data | `/more/export` (segment `export`) | `export` | Child of More with `parentNavigatorKey: rootNavigatorKey`, so EXP-11 can push it above the shell and back returns to Reports |

```dart
static String exportPath({Period? period, String? dataset}) // '/more/export?dataset=transactions&kind=month&start=2026-10-01&end=2026-10-31'
```

## Period query codec (`lib/core/utils/period.dart`, pure)

| Parameter | Values |
| --- | --- |
| `kind` | `day`, `week`, `month`, `year`, `custom` |
| `start` | `yyyy-MM-dd`, the first local day |
| `end` | `yyyy-MM-dd`, the last local day (inclusive) |

```dart
Map<String, String> periodToQuery(Period p);
Period? periodFromQuery(Map<String, String> q, {required int firstDayOfWeek}); // null on invalid → default month
```

Week periods are rebuilt from `start` with the current first day of week. If the result does not
match `end`, it falls back to a custom range with the same days.

## Notification and widget locations

| Source | Location | Lock behavior |
| --- | --- | --- |
| Habit reminder tap | `/habits?habit=…&at=…&wd=…` (extra query ignored by HAB-01) | Deferred until unlock (existing `LockSession.deferLocation`) |
| Daily summary tap | `/home` | same |
| Backup failing tap | `/more/backup` | same |
| Widget launch (cold) | `/home` via `HomeWidgetBridge.launchLocation()` (checked after `launchPayload()` in bootstrap) | `initialLocationFor` wraps it in `/lock?from=` |
| Widget launch (warm) | `/home` via `HomeWidgetBridge.launches` | same as a notification tap |

## Redirect

No new redirect rules. `/more/backup` and `/more/export` are ordinary authenticated routes, covered
by the existing lock rules 3, 4, and 4b.
