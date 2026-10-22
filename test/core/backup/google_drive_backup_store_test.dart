import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/data/google_drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
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
    store = GoogleDriveBackupStore(
      api: () async => api,
      connect: () async => 'me@example.com',
      disconnect: () async {},
      deviceName: () async => 'Pixel 8a',
    );
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

  test('SET-02 US2-4 upload goes to appDataFolder with app, kind, schema, '
      'and device, as a resumable upload', () async {
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
      kind: BackupKind.manual,
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
      'schemaVersion': '4',
      'device': 'Pixel 8a',
    });
    expect(captured.whereType<drive.Media>().single.length, 3);
    expect(captured.whereType<drive.ResumableUploadOptions>(), hasLength(1));
  });

  test('SET-02 US2-9 Q1 pruneAuto keeps the 5 newest auto backups and never '
      'deletes a manual one', () async {
    stubList([
      for (var d = 1; d <= 7; d++) _file('auto$d', kind: 'auto', day: d),
      _file('manual-old', kind: 'manual', day: 0 + 1),
      _file('manual-new', kind: 'manual', day: 20),
    ]);
    when(() => files.delete(any())).thenAnswer((_) async {});
    await store.pruneAuto();
    final deleted = verify(() => files.delete(captureAny())).captured;
    expect(deleted, ['auto2', 'auto1']);
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
