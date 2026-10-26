import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/data/google_drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:mocktail/mocktail.dart';

class _MockDriveApi extends Mock implements drive.DriveApi;

class _MockFiles extends Mock implements drive.FilesResource;

drive.File _file(String id, {required String kind, required int day}) =>
    drive.File()
      ..id = id
      ..name = 'dailytrack_backup_$id.json'
      ..size = '${1000 + day}'
      ..createdTime = DateTime.utc(2026, 10, day)
      ..appProperties = {'app': 'dailytrack', 'kind': kind, 'device': 'Pixel'};

/// Google Drive in `appDataFolder` (feature 008 T051, research R10,
/// data-model §5): the query, appProperties, rotation of auto backups only
/// (Q1), and error mapping.
void main() {
  setUpAll(() {
    registerFallbackValue(drive.File());
    registerFallbackValue(drive.Media(const Stream.empty(), 0));
    registerFallbackValue(drive.UploadOptions.defaultOptions);
    registerFallbackValue(drive.DownloadOptions.metadata);
  });

  late _MockFiles files;
  late GoogleDriveBackupStore store;

  setUp(() {
    files = _MockFiles();
    final api = _MockDriveApi();
    when(() => api.files).thenReturn(files);
    store = GoogleDriveBackupStore(api: () async => api);
  });

  void stubList(List<drive.File> result) => when(
    () => files.list(
      spaces: any(named: 'spaces'),
      q: any(named: 'q'),
      orderBy: any(named: 'orderBy'),
      pageSize: any(named: 'pageSize'),
      pageToken: any(named: 'pageToken'),
      $fields: any(named: r'$fields'),
    ),
  ).thenAnswer((_) async => drive.FileList(files: result));

  test('SET-02 US2-6 list asks only for DailyTrack files in appDataFolder, '
      'newest first, with Manual/Auto and device', () async {
    stubList([
      _file('old', kind: 'manual', day: 1),
      _file('new', kind: 'auto', day: 9),
    ]);
    final entries = await store.list();
    expect([for (final e in entries) e.id], ['new', 'old']);
    expect(entries.first.kind, BackupKind.auto);
    expect(entries.last.kind, BackupKind.manual);
    expect(entries.first.sizeBytes, 1009);
    expect(entries.first.device, 'Pixel');
    // Backups made before feature 010 have no metadata (FR-043).
    expect(entries.first.meta, isNull);
    expect(
      entries.first.createdAt,
      DateTime.utc(2026, 10, 9).millisecondsSinceEpoch,
    );
    final call = verify(
      () => files.list(
        spaces: captureAny(named: 'spaces'),
        q: captureAny(named: 'q'),
        orderBy: any(named: 'orderBy'),
        pageSize: any(named: 'pageSize'),
        pageToken: any(named: 'pageToken'),
        $fields: any(named: r'$fields'),
      ),
    )..called(1);
    expect(call.captured[0], 'appDataFolder');
    expect(
      call.captured[1],
      "appProperties has { key='app' and value='dailytrack' }",
    );
  });

  test('SET-02 US2-4 upload goes to appDataFolder with the backup metadata '
      'as appProperties, as a resumable upload', () async {
    when(
      () => files.create(
        any(),
        uploadMedia: any(named: 'uploadMedia'),
        uploadOptions: any(named: 'uploadOptions'),
        $fields: any(named: r'$fields'),
      ),
    ).thenAnswer((_) async => drive.File()..id = 'x');
    await store.upload(
      Uint8List.fromList([1, 2, 3]),
      fileName: 'dailytrack_backup_20261021_2130.json',
      meta: const BackupMeta(
        deviceId: 'dev-1',
        deviceName: 'Pixel 8a',
        appVersion: '1.0.0+7',
        createdAt: 1792540800000,
        kind: BackupKind.manual,
        counts: {'expense.transactions': 12, 'habit.habits': 2},
        schemaVersion: 5,
        encrypted: true,
      ),
    );
    final captured = verify(
      () => files.create(
        captureAny(),
        uploadMedia: captureAny(named: 'uploadMedia'),
        uploadOptions: captureAny(named: 'uploadOptions'),
        $fields: any(named: r'$fields'),
      ),
    ).captured;
    final file = captured[0] as drive.File;
    expect(file.name, 'dailytrack_backup_20261021_2130.json');
    expect(file.parents, ['appDataFolder']);
    expect(file.appProperties, {
      'app': 'dailytrack',
      'kind': 'manual',
      'schemaVersion': '5',
      'deviceId': 'dev-1',
      'createdAt': '1792540800000',
      'encrypted': '1',
      'appVersion': '1.0.0+7',
      'device': 'Pixel 8a',
      'c.expense.transactions': '12',
      'c.habit.habits': '2',
    });
    expect(captured.whereType<drive.Media>().single.length, 3);
    expect(captured.whereType<drive.ResumableUploadOptions>(), hasLength(1));
  });

  test('§16 list reads the metadata back from appProperties', () async {
    stubList([
      _file('a', kind: 'auto', day: 3)
        ..appProperties = {
          'app': 'dailytrack',
          'kind': 'auto',
          'device': 'Pixel 8a',
          'deviceId': 'dev-1',
          'createdAt': '1792540800000',
          'c.expense.transactions': '12',
        },
    ]);
    final meta = (await store.list()).single.meta!;
    expect(meta.deviceId, 'dev-1');
    expect(meta.deviceName, 'Pixel 8a');
    expect(meta.kind, BackupKind.auto);
    expect(meta.counts, {'expense.transactions': 12});
  });

  test('ACC-01 deleteAll removes every DailyTrack file and keeps going '
      'after one failure', () async {
    stubList([
      _file('m', kind: 'manual', day: 1),
      _file('bad', kind: 'auto', day: 2),
      _file('a', kind: 'auto', day: 3),
    ]);
    when(() => files.delete(any())).thenAnswer((_) async {});
    when(() => files.delete('bad')).thenThrow(const SocketException('x'));
    await expectLater(store.deleteAll(), throwsA(isA<DriveOffline>()));
    final deleted = verify(() => files.delete(captureAny())).captured;
    expect(deleted, unorderedEquals(['m', 'bad', 'a']));
  });

  test('download returns the file bytes', () async {
    when(() => files.get(any(), downloadOptions: any(named: 'downloadOptions')))
        .thenAnswer(
          (_) async => drive.Media(
            Stream.fromIterable([
              [1, 2],
              [3],
            ]),
            3,
          ),
        );
    expect(await store.download('id'), [1, 2, 3]);
  });

  test('SET-02 US2-5 errors become plain backup failures', () async {
    Future<void> expectFailure(Object error, Matcher matcher) async {
      when(() => files.delete(any())).thenThrow(error);
      await expectLater(store.delete('x'), throwsA(matcher));
    }

    await expectFailure(
      drive.DetailedApiRequestError(401, 'expired'),
      isA<DriveAuthRequired>(),
    );
    await expectFailure(
      drive.DetailedApiRequestError(
        403,
        "The user's Drive storage quota has been exceeded.",
      ),
      isA<DriveQuotaExceeded>(),
    );
    await expectFailure(
      drive.DetailedApiRequestError(500, 'oops'),
      isA<DriveUnavailable>(),
    );
    await expectFailure(const SocketException('no route'), isA<DriveOffline>());
    await expectFailure(const DriveAuthRequired(), isA<DriveAuthRequired>());
  });
}
