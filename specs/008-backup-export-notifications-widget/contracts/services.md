# Contract: Services and Module Hooks

Dart signatures are shown in outline (primary-constructor style as in the codebase). Pure Dart means
no Flutter imports (Constitution II). Research decisions are cited as R#.

## `lib/core/backup/`

### `backup_section.dart` (replaces the placeholder in `tracker_module.dart`)

```dart
abstract interface class BackupSection {
  String get moduleId;                 // key under "modules"
  int get sinceSchemaVersion;          // first schemaVersion that has this section
  Future<Map<String, Object?>> export(AppDatabase db);                 // inside engine read txn
  void validate(Map<String, Object?> section);                         // throws BackupInvalid
  Map<String, Object?> upgrade(Map<String, Object?> section, {required int from}); // to current
  Future<void> restore(AppDatabase db, Map<String, Object?> section);  // inside engine write txn
  Map<String, int> counts(Map<String, Object?> section);               // e.g. {'transactions': 1240}
  String summary(AppLocalizations l10n, Map<String, int> counts);      // "1,240 transactions"
  Iterable<String> attachments(Map<String, Object?> section) => const [];       // relative paths
  Map<String, Object?> withoutAttachments(Map<String, Object?> section) => section;
}
```

### Domain (pure Dart)

```dart
// backup_errors.dart
sealed class BackupFailure implements Exception;   // each maps to one localized message (§15.6)
final class BackupNotRecognized, BackupDamaged, BackupInvalid(String detail), BackupTooNew(int v),
  BackupWrongPassword, BackupNeedsPassword, BackupTooLargeToEncrypt, BackupBusy, BackupStorageFull,
  DriveAuthRequired, DriveQuotaExceeded, DriveOffline, DriveUnavailable(String? code);

// backup_envelope.dart (R3)
final class BackupEnvelope {
  const new({int iterations = 600000});
  static bool isEncrypted(Uint8List bytes);
  Future<Uint8List> seal(Uint8List inner, {required String password, required InnerForm form});
  Future<(Uint8List, InnerForm)> open(Uint8List file, {required String password}); // BackupWrongPassword
}

// backup_archive.dart (R2)
enum InnerForm { json, zip }
ContainerForm detectForm(Uint8List bytes);                 // plain | zip | encrypted | unknown
Uint8List packZip(Uint8List json, Map<String, Uint8List> files);
(Uint8List json, Map<String, Uint8List> files) unpackZip(Uint8List zip);

// backup_document.dart
final class BackupDocument { int schemaVersion; String appVersion; int createdAt;
  Map<String, Map<String, Object?>> modules; Map<String, String> settings;
  factory fromJson(Map<String, Object?>); Map<String, Object?> toJson(); }

// backup_migrator.dart (R7)
const minRestorableSchema = 4;
final class BackupMigrator { const new(this.sections, {required this.current});
  BackupDocument upgrade(BackupDocument doc); }      // BackupTooNew if doc.schemaVersion > current

// backup_settings_policy.dart (R6)
abstract final class BackupSettingsPolicy {
  static bool isRestorable(String key);
  static Map<String, String> exportable(Map<String, String> all);
}

// restore_preview.dart
final class RestorePreview { DateTime createdAt; String appVersion;
  List<(String moduleId, String summary)> modules; List<String> skippedModuleIds; bool hasReceipts; }

// ports
abstract interface class DriveBackupStore {
  Future<String?> connectedEmail();
  Future<String> connect();                                      // interactive; returns email
  Future<void> disconnect();
  Future<List<DriveBackupEntry>> list();
  Future<void> upload(File file, {required BackupKind kind, void Function(int, int)? progress});
  Future<File> download(String fileId, {void Function(int, int)? progress});
  Future<void> delete(String fileId);
  Future<void> pruneAuto({int keep = 5});
}
abstract interface class LocalBackupFiles {
  Future<bool> saveAs(File file, {required String suggestedName}); // false = user cancelled
  Future<File?> pick();
}
abstract interface class BackupPasswordStore {
  Future<String?> read(); Future<void> write(String password); Future<void> delete();
}
```

### Services (in `core/backup/`, wired in `backup_providers.dart`)

```dart
final class BackupService {
  // Builds the file, then saves, shares, or uploads it. Single flight + cross-isolate lease (R8).
  Stream<BackupProgress> backupToDevice();               // ends with BackupDone(file, sizeBytes)
  Stream<BackupProgress> backupToDrive({required BackupKind kind});
  Future<void> shareLastFile();                           // through FileSharer
}

/// Bound in lib/app/production_overrides.dart (core never imports lib/app/): cancelAll →
/// AppOpenRunner.run → DailySummaryScheduler.reschedule → GlanceRefresher.refreshNow, each best effort.
final restoreAftermathProvider = Provider<Future<void> Function()>((ref) => throw UnimplementedError());

final class RestoreService {
  Future<RestoreCandidate> open(RestoreSource source, {String? password}); // read-only phases 1–3
  Stream<RestoreProgress> apply(RestoreCandidate candidate);              // phases 4–7
}
sealed class RestoreSource { FileSource(File); DriveSource(String fileId); }
final class RestoreCandidate { RestorePreview preview; /* opaque: upgraded document + staged attachments */ }

final class BackupCoordinator {                           // shared by both services
  Future<T> run<T>(Future<T> Function() body);            // BackupBusy if the lease is held
}

Future<bool> runAutoBackup(ProviderReader read);          // core background task 'core.autoBackup' (R11)
```

### Presentation (shared, `core/backup/presentation/`)

```dart
enum RestoreEntry { settings, forgotPin, databaseFailure }
Future<bool> showRestoreFlow(BuildContext context, {required RestoreEntry entry}); // true = restored
Future<bool> showBackupPasswordSheet(BuildContext context, {required bool changing});
```

## `lib/core/database/database_recovery.dart` (R22)

```dart
final class DatabaseRecovery {
  /// Closes the shared connection, renames dailytrack.sqlite(-wal,-shm) to
  /// dailytrack.broken-<ts>.*, then invalidates appDatabaseProvider so a fresh v4 database opens.
  Future<void> moveBrokenDatabaseAside();
}
```

## `lib/core/export/` (pure Dart, R14)

```dart
abstract interface class ExportDataset {
  String get id;                                   // 'transactions' | 'habits'
  String get labelKey;
  List<ExportFilterSpec> get filters;
  Future<ExportDocument> build(ExportRequest request, ExportContext context, ProviderReader read);
}
```

## `lib/features/settings/domain/export/` (pure Dart)

```dart
final class CsvBuilder { const new(); Uint8List build(ExportDocument doc); }   // BOM + CRLF (R13)
abstract interface class ShapedTextRenderer {                                // R12
  Future<ShapedImage> render(String text, {required double fontSize, required bool bold});
}
final class ShapedImage { Uint8List png; double widthPt; double heightPt; }
final class PdfReportBuilder {
  const new({required this.fonts});                 // NotoSans + Devanagari + Gujarati bytes
  Future<Uint8List> build(ExportDocument doc, Map<String, ShapedImage> shaped); // run in Isolate.run
  static Set<String> needsShaping(ExportDocument doc);    // strings with U+0900–U+0DFF
}
final class ExportUseCase {
  /// gate check → build → write file → consumeOne → returns the file to share (FR-031, Q2).
  Future<ExportOutcome> run(ExportRequest request);
}
sealed class ExportOutcome { ExportLocked; ExportNothing; ExportFailed(Object); ExportReady(File file); }
```

## `lib/core/feature_gate/` (addition, R15)

```dart
// UnlockRepository
Future<bool> consumeOne(FeatureKey key);  // revoke oldest live, unexpired rewardedAd unlock; no-op otherwise
```

## `lib/core/notifications/` (changes, R16, R18)

```dart
enum NotificationChannelId { budgetAlerts, habitReminders, dailySummary, backup } // appended
final class NotificationActionSpec { const new({required this.id, required this.label}); }
// AppNotification: + List<NotificationActionSpec> actions = const []
// ScheduledNotification: repeat becomes RepeatInterval? (null = one-shot)
abstract interface class NotificationService {
  // existing members unchanged, plus:
  Stream<NotificationActionEvent> get actions;     // responses while the app runs
  Future<bool> requestExactAlarms();
}

final class DailySummaryScheduler {
  Future<void> reschedule({HomeGlance? today, HomeGlance? next});  // cancels when not allowed
  static String textFor(AppLocalizations l10n, HomeGlance glance);  // pure; ARB variants
}
```

## `lib/core/widget/` (R19, R20)

```dart
// domain (pure)
final class HomeGlance { ... }                       // data-model §6
final class GlanceBuilder { void setSpend(GlanceSpend); void setHabits(GlanceHabits); HomeGlance build(); }
String encodeWidgetPayload(HomeGlance? today, HomeGlance? next,
    {required bool hidden, required AppLocalizations l10n, required String locale}); // glance.v1 JSON
abstract interface class HomeWidgetBridge {          // data/home_widget_bridge.dart implements
  Future<void> save(String payloadJson);
  Future<void> armMidnight();                        // method channel dailytrack/glance
  Future<String?> launchLocation();                  // initiallyLaunchedFromHomeWidget → '/home'
  Stream<String> get launches;                       // warm widget launches → '/home'
  Future<void> registerBackgroundCallback(Future<void> Function(Uri?) callback); // bootstrap passes widgetBackgroundEntryPoint
}

// glance_refresher.dart (keep-alive provider)
final class GlanceRefresher {
  void start();                 // listens to db.tableUpdates on 6 tables, debounce 750 ms
  Future<void> refreshNow();    // build today + next, save widget payload, reschedule daily summary
}
```

## `lib/core/module/` (additions)

```dart
// app_action.dart
enum AppActionSource { notification, widget, system }
final class AppAction { const new({required this.source, required this.name, this.params = const {}}); }
final class AppActionDispatcher { Future<bool> dispatch(AppAction action, ProviderReader read); }

// tracker_module.dart (TrackerModule)
BackupSection? backupSection();                                                       // now real
List<ExportDataset> exportDatasets() => const [];
Future<void> contributeGlance(GlanceBuilder b, ProviderReader read, DateTime nowLocal) async {}
Future<bool> handleAction(AppAction action, ProviderReader read) async => false;
```

## `lib/core/background/` (R11)

```dart
enum NetworkRequirement { none, connected, unmetered }
abstract interface class BackgroundScheduler {
  Future<void> ensureDaily(String uniqueName);                                         // unchanged
  Future<void> ensurePeriodic(String uniqueName, {required Duration every,
      NetworkRequirement network = NetworkRequirement.none});                         // policy: replace
  Future<void> cancel(String uniqueName);
}
```

`lib/app/background_dispatcher.dart`: `runBackgroundTask` checks
`coreBackgroundTasks = {'core.autoBackup': runAutoBackup}` before module tasks, then calls
`GlanceRefresher.refreshNow()` (best effort).

## `lib/app/background_entry_points.dart` (new, top-level, `@pragma('vm:entry-point')`)

Core receives these functions by injection only: `LocalNotificationService(..., backgroundHandler:
notificationActionEntryPoint)` in `production_overrides.dart`, and
`HomeWidgetBridge.registerBackgroundCallback(widgetBackgroundEntryPoint)` in `bootstrap.dart`.

```dart
/// flutter_local_notifications background action handler. Opens its own container and Drift
/// connection (productionOverrides → AppDatabase.open with shareAcrossIsolates).
void notificationActionEntryPoint(NotificationResponse response);

/// home_widget interactivity callback: dailytrack://widget/check, dailytrack://system/{midnight,boot,timezone}.
Future<void> widgetBackgroundEntryPoint(Uri? uri);
```

Both run `WidgetsFlutterBinding.ensureInitialized()`, `DartPluginRegistrant.ensureInitialized()`,
intl date-symbol initialization, `notificationService.initialize()`, then the dispatch, then
`GlanceRefresher.refreshNow()`, then `container.dispose()` in `finally`. They never throw.

## Module implementations

| File | Implements |
| --- | --- |
| `features/expense/data/backup/expense_backup_section.dart` (+ `*_codec.dart` per table) | `BackupSection` for 5 tables |
| `features/habit/data/backup/habit_backup_section.dart` (+ codecs) | `BackupSection` for 3 tables |
| `features/expense/data/export/transactions_export_dataset.dart` | `ExportDataset` (`listForExport`, slices) |
| `features/habit/data/export/habits_export_dataset.dart` | `ExportDataset` (`entriesBetween`) |
| `features/expense/expense_module.dart` | `backupSection`, `exportDatasets`, `contributeGlance` |
| `features/habit/habit_module.dart` | `backupSection`, `exportDatasets`, `contributeGlance`, `handleAction` |
| `features/habit/domain/reminders/resolve_reminder_day.dart` | pure day rule (R17) |
| `features/habit/data/reminders/local_habit_reminder_scheduler.dart` | actions on reminders, query payload, cancel snooze when done |

New repository methods: `TransactionRepository.listForExport(TxnQuery)` and
`HabitEntryRepository.entriesBetween(LocalDate from, LocalDate to)`.

## Reset (`DriftAppResetService`, change)

After the existing steps, it also runs, best effort:
- delete secure keys with the `backup.` prefix
- `DriveBackupStore.disconnect()`
- `BackgroundScheduler.cancel('core.autoBackup')`
- `GlanceRefresher.refreshNow()`, so the widget shows "Open DailyTrack"

## Settings (`SettingsRepository`, additions)

```dart
Future<void> setLastBackup({required int at, required BackupLocation location, required int sizeBytes});
Future<void> setLastAutoBackupAt(int at);
Future<void> setBackupAccountEmail(String? email);
Future<void> setAutoBackup({required AutoBackupFrequency frequency, required bool wifiOnly});
Future<void> setBackupEncrypt({required bool enabled});
Future<void> setBackupIncludeReceipts({required bool enabled});
Future<void> recordAutoBackupResult({required bool success}); // updates failures + notified (data-model §9)
Future<void> setShowDataOnWidget({required bool enabled});
Future<void> setDeviceTimeZoneId(String id);
Future<void> restoreSettings(Map<String, String> restorable, {required Iterable<String> seederIds}); // inside caller txn
```
