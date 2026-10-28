import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/data/google_drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

class _MockDriveApi extends Mock implements drive.DriveApi;

class _MockFiles extends Mock implements drive.FilesResource;

/// Backup metadata from the real engine through `BackupService` to the
/// Drive store's `appProperties` and the file's `meta` (feature 010 T102,
/// §16 "Each Drive backup has `deviceId`, `deviceName`, `appVersion`,
/// `createdAt`, `kind`, and `counts` in both `appProperties` and the file's
/// `meta`.", FR-041, FR-043).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUpAll(() {
    registerFallbackValue(drive.File());
    registerFallbackValue(drive.Media(const Stream.empty(), 0));
    registerFallbackValue(drive.UploadOptions.defaultOptions);
  });

  late AppDatabase db;
  late Directory docs;
  late Directory cache;
  late MutableClock clock;
  late SettingsRepositoryImpl settings;
  late FakeLocalBackupFiles files;
  late _MockFiles driveFiles;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('meta_docs');
    cache = await Directory.systemTemp.createTemp('meta_cache');
    clock = MutableClock(DateTime(2026, 10, 27, 21, 30));
    await seedRichData(db, docs);
    settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    files = FakeLocalBackupFiles();
    driveFiles = _MockFiles();
    when(
      () => driveFiles.list(
        spaces: any(named: 'spaces'),
        q: any(named: 'q'),
        orderBy: any(named: 'orderBy'),
        pageSize: any(named: 'pageSize'),
        pageToken: any(named: 'pageToken'),
        $fields: any(named: r'$fields'),
      ),
    ).thenAnswer((_) async => drive.FileList(files: const []));
    when(
      () => driveFiles.create(
        any(),
        uploadMedia: any(named: 'uploadMedia'),
        uploadOptions: any(named: 'uploadOptions'),
        $fields: any(named: r'$fields'),
      ),
    ).thenAnswer((_) async => drive.File()..id = 'new');
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
    await cache.delete(recursive: true);
  });

  BackupService service() {
    final api = _MockDriveApi();
    when(() => api.files).thenReturn(driveFiles);
    return BackupService(
      engine: engineFor(db, clock, docs),
      coordinator: BackupCoordinator(db, clock),
      settings: settings,
      files: files,
      passwords: FakeBackupPasswordStore(),
      sharer: FakeFileSharer(),
      cacheDir: () async => cache,
      nowUtcMs: () => clock.now().toUtc().millisecondsSinceEpoch,
      drive: GoogleDriveBackupStore(api: () async => api),
      device: () async =>
          const DeviceIdentity(id: 'dev-a', name: 'Xiaomi Redmi Note 12'),
    );
  }

  test('§16 each Drive backup has deviceId, deviceName, appVersion, '
      "createdAt, kind, and counts in both appProperties and the file's "
      'meta', () async {
    final result = await service().backupToDrive(
      kind: BackupKind.auto,
      conflict: ConflictMode.overwrite,
    );
    expect(result, isA<Uploaded>());

    final captured = verify(
      () => driveFiles.create(
        captureAny(),
        uploadMedia: captureAny(named: 'uploadMedia'),
        uploadOptions: any(named: 'uploadOptions'),
        $fields: any(named: r'$fields'),
      ),
    ).captured;
    final props = (captured[0] as drive.File).appProperties!;
    final media = captured[1] as drive.Media;
    final bytes = BytesBuilder();
    await media.stream.forEach(bytes.add);

    final listed = BackupMetaCodec.fromProperties(props)!;
    final inFile = BackupDocument.decode(bytes.takeBytes()).meta!;

    for (final m in [listed, inFile]) {
      expect(m.deviceId, 'dev-a');
      expect(m.deviceName, 'Xiaomi Redmi Note 12');
      expect(m.appVersion, '1.0.0+7');
      expect(m.createdAt, clock.now().toUtc().millisecondsSinceEpoch);
      expect(m.kind, BackupKind.auto);
      expect(m.schemaVersion, db.schemaVersion);
      expect(m.encrypted, isFalse);
      expect(m.counts['expense.transactions'], greaterThan(0));
      expect(m.counts['habit.habits'], greaterThan(0));
    }
    expect(listed.toJson(), inFile.toJson());
  });

  test('§16 counts leave out soft-deleted rows', () async {
    final file = await engineFor(db, clock, docs).create(
      includeReceipts: false,
      device: const DeviceIdentity(id: 'dev-a', name: 'Pixel'),
    );
    final live = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM transactions WHERE deleted_at IS NULL',
        )
        .getSingle();
    expect(file.meta!.counts['expense.transactions'], live.read<int>('n'));
  });

  test(
    'SET-02 local backup files carry the same meta inside the file',
    () async {
      final saved = await service().backupToDevice();
      expect(saved, isNotNull);
      final (_, bytes) = files.saved.single;
      final meta = BackupDocument.decode(bytes).meta;
      expect(meta, isNotNull);
      expect(meta!.deviceId, 'dev-a');
      expect(meta.kind, BackupKind.manual);
    },
  );

  test('FR-043 a backup made before this feature (no meta) is still '
      'restorable and gives the same data', () async {
    final engine = engineFor(db, clock, docs);
    final oldFile = (await engine.exportDocument()).encode();
    expect(BackupDocument.decode(oldFile).meta, isNull);
    final before = await tableChecksums(db);

    await eraseEverything(db);
    final restore = RestoreService(
      engine: engine,
      coordinator: BackupCoordinator(db, clock),
      files: files,
      aftermath: () async {},
    );
    final candidate = await restore.open(Uint8List.fromList(oldFile));
    expect(candidate.document.meta, isNull);
    expect(await restore.apply(candidate), RestoreOutcome.done);

    expect(await tableChecksums(db), before);
  });
}
