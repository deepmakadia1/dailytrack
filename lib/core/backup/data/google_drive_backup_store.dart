import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// [DriveBackupStore] over the Drive v3 API in `appDataFolder` (feature 008
/// research R10, data-model §5). Files carry the backup metadata as
/// `appProperties` (feature 010 research R8), so backups are listed and
/// compared on any device without a download.
final class GoogleDriveBackupStore implements DriveBackupStore {
  new({required this._api});

  final Future<drive.DriveApi> Function() _api;

  static const String folder = 'appDataFolder';
  static const String appKey = BackupMetaCodec.appKey;
  static const String appValue = BackupMetaCodec.appValue;
  static const String kindKey = BackupMetaCodec.kindKey;
  static const String _query =
      "appProperties has { key='$appKey' and value='$appValue' }";

  @override
  Future<List<DriveBackupEntry>> list() => _guard(() async {
    final files = (await _api()).files;
    final entries = <DriveBackupEntry>[];
    String? page;
    do {
      final result = await files.list(
        spaces: folder,
        q: _query,
        orderBy: 'createdTime desc',
        pageSize: 100,
        pageToken: page,
        $fields: 'nextPageToken,files(id,name,size,createdTime,appProperties)',
      );
      for (final f in result.files ?? const <drive.File>[]) {
        final id = f.id;
        if (id == null) continue;
        final props = f.appProperties ?? const {};
        entries.add(
          DriveBackupEntry(
            id: id,
            name: f.name ?? '',
            createdAt: f.createdTime?.toUtc().millisecondsSinceEpoch ?? 0,
            sizeBytes: int.tryParse(f.size ?? '') ?? 0,
            kind: props[kindKey] == BackupKind.auto.name
                ? BackupKind.auto
                : BackupKind.manual,
            device: props[BackupMetaCodec.deviceKey],
            meta: BackupMetaCodec.fromProperties(props),
          ),
        );
      }
      page = result.nextPageToken;
    } while (page != null);
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  });

  @override
  Future<void> upload(
    Uint8List bytes, {
    required String fileName,
    required BackupMeta meta,
  }) => _guard(() async {
    final file = drive.File()
      ..name = fileName
      ..parents = [folder]
      ..appProperties = BackupMetaCodec.toProperties(meta);
    // Drive creates the file only when the upload completes, so a broken
    // upload never shows up as a backup (spec Edge Cases).
    await (await _api()).files.create(
      file,
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
      uploadOptions: drive.ResumableUploadOptions(),
      $fields: 'id',
    );
  });

  @override
  Future<Uint8List> download(String fileId) => _guard(() async {
    final media = await (await _api()).files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final out = BytesBuilder(copy: false);
    await media.stream.forEach(out.add);
    return out.takeBytes();
  });

  @override
  Future<void> delete(String fileId) =>
      _guard(() async => await (await _api()).files.delete(fileId));

  @override
  Future<void> deleteAll() async {
    BackupFailure? first;
    for (final entry in await list()) {
      try {
        await delete(entry.id);
      } on BackupFailure catch (e) {
        first ??= e;
      }
    }
    if (first != null) throw first;
  }

  /// Maps Drive and network errors to plain backup failures.
  static Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on BackupFailure {
      rethrow;
    } on drive.DetailedApiRequestError catch (e) {
      final reasons = {for (final d in e.errors) d.reason};
      // Drive says "The user's Drive storage quota has been exceeded."
      if (reasons.contains('storageQuotaExceeded') ||
          reasons.contains('quotaExceeded') ||
          (e.message ?? '').toLowerCase().contains('storage quota')) {
        throw const DriveQuotaExceeded();
      }
      if (e.status == 401 || e.status == 403) throw const DriveAuthRequired();
      throw DriveUnavailable('${e.status}');
    } on drive.ApiRequestError catch (e) {
      throw DriveUnavailable(e.message);
    } on SocketException {
      throw const DriveOffline();
    } on TimeoutException {
      throw const DriveOffline();
    } on HttpException {
      throw const DriveOffline();
    } on Exception catch (e) {
      // http's ClientException wraps socket failures.
      if ('$e'.contains('ClientException')) throw const DriveOffline();
      throw DriveUnavailable('$e');
    }
  }
}
