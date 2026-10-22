# Contract: Android Host Changes

Package: `com.midexcode.daily.track.dailytrack`. Kotlin files live under
`android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/`.

## `AndroidManifest.xml`

Additions inside `<application>`:

```xml
<!-- flutter_local_notifications: action buttons without opening the app (R16) -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />

<!-- home_widget: background callback (widget clicks, system triggers) (R20, R21) -->
<receiver android:name="es.antonborri.home_widget.HomeWidgetBackgroundReceiver" android:exported="false">
  <intent-filter><action android:name="es.antonborri.home_widget.action.BACKGROUND" /></intent-filter>
</receiver>
<service android:name="es.antonborri.home_widget.HomeWidgetBackgroundService"
    android:permission="android.permission.BIND_JOB_SERVICE" android:exported="false" />

<!-- Widget provider -->
<receiver android:name=".widget.TodayWidgetProvider" android:exported="false"
    android:label="@string/widget_label">
  <intent-filter><action android:name="android.appwidget.action.APPWIDGET_UPDATE" /></intent-filter>
  <meta-data android:name="android.appwidget.provider" android:resource="@xml/today_widget_info" />
</receiver>

<!-- System triggers → Dart (R21) -->
<receiver android:name=".system.SystemEventsReceiver" android:exported="false">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED" />
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
    <action android:name="android.intent.action.TIMEZONE_CHANGED" />
  </intent-filter>
</receiver>
<receiver android:name=".system.MidnightAlarmReceiver" android:exported="false" />
```

Permissions: no new ones. `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, and
`POST_NOTIFICATIONS` are already declared. `INTERNET` is added for the release manifest if it is
missing (Drive). `<queries>` is unchanged.

The exact class and action names of `home_widget` 0.10.0 are verified against the plugin's README
when implemented. A manifest test asserts them.

## Kotlin

| File | Responsibility |
| --- | --- |
| `widget/TodayWidgetProvider.kt` | Extends `HomeWidgetProvider`. Reads `glance.v1`, picks `today` / `next` by local date, and binds `RemoteViews` (`widget_today.xml` or `widget_hidden.xml`). Habit slots use `HomeWidgetBackgroundIntent.getBroadcast(ctx, Uri("dailytrack://widget/check?habit=…&day=…"))`; the root uses `HomeWidgetLaunchIntent.getActivity(ctx, MainActivity::class.java, Uri("dailytrack://widget/open"))`. Sets content descriptions from the `a11y` strings. |
| `system/GlanceAlarmScheduler.kt` | `armMidnight(ctx)`: an `AlarmManager` alarm at the next local midnight + 1 min, `setExactAndAllowWhileIdle` when `canScheduleExactAlarms()`, otherwise `setWindow(…, 10 min)`. Its `PendingIntent` targets `MidnightAlarmReceiver`. |
| `system/MidnightAlarmReceiver.kt` | Sends `HomeWidgetBackgroundIntent` `dailytrack://system/midnight`, then calls `armMidnight` again. |
| `system/SystemEventsReceiver.kt` | On boot or package replace: `armMidnight` + `dailytrack://system/boot`. On time zone change: `armMidnight` + `dailytrack://system/timezone`. |
| `MainActivity.kt` | New channel `dailytrack/glance`, with method `armMidnight` → `GlanceAlarmScheduler.armMidnight`. Existing channels unchanged. |

## Resources

| File | Content |
| --- | --- |
| `res/xml/today_widget_info.xml` | `minWidth 250dp`, `minHeight 110dp`, `targetCellWidth 4`, `targetCellHeight 2`, `resizeMode horizontal|vertical`, `updatePeriodMillis 0`, `widgetCategory home_screen`, `previewLayout @layout/widget_today`, `description @string/widget_description` |
| `res/layout/widget_today.xml` | The data layout: spend, budget `ProgressBar` + text, and 4 habit slots, each at least 48 dp tall |
| `res/layout/widget_hidden.xml` | Icon + "Open DailyTrack" |
| `res/values/widget_colors.xml`, `res/values-night/widget_colors.xml` | **Generated** by `tool/android/widget_colors.dart` from the light and dark `AppColors` tokens (surface, onSurface, onSurfaceVariant, success, warning, expense); `test/android/widget_colors_sync_test.dart` keeps them in sync. Contrast ≥ 4.5:1 for text |
| `res/values/strings.xml` (+ `values-hi`, `values-gu`) | **Generated** by `tool/l10n/phase0_strings.py` from the `widget_label`, `widget_description`, and `widget_open` keys (fallback used before Dart writes a payload) |
| `res/drawable/ic_widget_check*.xml` | Vector check and plus icons |

## Build

- `android/app/build.gradle.kts`: no new SDK settings (minSdk 24 still works for every plugin
  resolved in R1).
- The R8 or ProGuard keep rules that `home_widget` and `flutter_local_notifications` need are
  verified with a release build of the dev flavor (quickstart §2).
