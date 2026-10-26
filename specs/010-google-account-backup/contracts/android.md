# Contract: Android

## AndroidManifest.xml

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules"
    ...>
```

The comment above `<application>` is rewritten: Android Auto Backup is on for the database only (spec §16, research R14), and secure storage is never included.

## res/xml/data_extraction_rules.xml (Android 12+)

```xml
<data-extraction-rules>
  <cloud-backup>
    <include domain="root" path="app_flutter/dailytrack.sqlite"/>
    <include domain="root" path="app_flutter/dailytrack.sqlite-wal"/>
    <include domain="root" path="app_flutter/dailytrack.sqlite-shm"/>
    <exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>
  </cloud-backup>
  <device-transfer>
    <!-- same includes and exclude -->
  </device-transfer>
</data-extraction-rules>
```

## res/xml/backup_rules.xml (Android 11 and lower)

```xml
<full-backup-content>
  <include domain="root" path="app_flutter/dailytrack.sqlite"/>
  <include domain="root" path="app_flutter/dailytrack.sqlite-wal"/>
  <include domain="root" path="app_flutter/dailytrack.sqlite-shm"/>
  <exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>
</full-backup-content>
```

Because both files list includes, nothing else is backed up: receipts (`app_flutter/receipts/`), the safety copy (`files/restore_safety/`), WorkManager's database, other shared preferences, and caches stay on the device. The no-backup folder is never backed up by Android. A unit test parses both files and checks exactly these includes and the secure-storage exclude (§16 criterion 2). The device check (quickstart §4) confirms the database path with `adb shell run-as`.

## MainActivity.kt — `dailytrack/window` channel

Two new methods next to `getDeviceInfo`:

| Method | Returns |
| --- | --- |
| `getNoBackupDir` | `context.noBackupFilesDir.absolutePath` |
| `getNetworkState` | `{ "online": Boolean, "metered": Boolean }` from `ConnectivityManager.getNetworkCapabilities(activeNetwork)` (`NET_CAPABILITY_INTERNET` + `VALIDATED`; `connectivityManager.isActiveNetworkMetered`) |

`ACCESS_NETWORK_STATE` permission is added to the manifest (normal permission, no prompt; WorkManager already merges it).

## WorkManager

- Existing periodic `core.autoBackup` unchanged.
- New one-off `core.backgroundBackup`: `ExistingWorkPolicy.REPLACE`, `NetworkType.UNMETERED` when Wi-Fi only, else `CONNECTED`; no backoff retry (the task always returns true, like `core.autoBackup`).
