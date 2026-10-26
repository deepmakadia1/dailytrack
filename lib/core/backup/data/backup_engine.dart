import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_envelope.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/backup_migrator.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

/// Builds and restores backup files (SET-02, feature 008 research R2–R9).
/// It reads and writes module data only through each module's
/// [BackupSection]; settings only through [BackupSettingsPolicy].
final class BackupEngine {
  new({
    required this._db,
    required this._sections,
    required this._seederIds,
    required this._clock,
    required this._appVersion,
    required this._documentsDir,
    BackupEnvelope? envelope,
  }) : _envelope = envelope ?? BackupEnvelope();

  final AppDatabase _db;
  final List<BackupSection> _sections;
  final List<String> _seederIds;
  final Clock _clock;
  final Future<String> Function() _appVersion;
  final Future<Directory> Function() _documentsDir;
  final BackupEnvelope _envelope;

  /// Where receipts live, relative to the documents folder.
  static const String receiptsFolder = 'receipts';
  static const String _staging = 'receipts.restore';
  static const String _old = 'receipts.old';

  // ---- Backup ---------------------------------------------------------

  /// Every module's section and the restorable settings, from one
  /// consistent snapshot.
  Future<BackupDocument> exportDocument() async =>
      (await exportSnapshot()).document;

  /// [exportDocument] plus `dataChangeCounter` read in the same
  /// transaction, so a write made after the snapshot still counts as
  /// changed (feature 010 research R5, FR-031).
  Future<({BackupDocument document, int changeCounter})>
  exportSnapshot() async {
    final version = await _appVersion();
    return await _db.transaction(() async {
      final modules = <String, Map<String, Object?>>{};
      for (final s in _sections) {
        modules[s.moduleId] = await s.export(_db);
      }
      final rows = {
        for (final r in await _db.select(_db.settings).get()) r.key: r.value,
      };
      final counter = SettingsCodec.decode(
        rows,
        knownModuleIds: const [],
      ).dataChangeCounter;
      return (
        document: BackupDocument(
          schemaVersion: _db.schemaVersion,
          appVersion: version,
          createdAt: _clock.now().toUtc().millisecondsSinceEpoch,
          modules: modules,
          settings: BackupSettingsPolicy.exportable(rows),
        ),
        changeCounter: counter,
      );
    });
  }

  /// Non-deleted rows per module, keyed `"<moduleId>.<kind>"` like
  /// `BackupMeta.counts` (ACC-02 "This phone", the safety copy).
  Future<Map<String, int>> counts() async => _countsOf(await exportDocument());

  Map<String, int> _countsOf(BackupDocument doc) => {
    for (final s in _sections)
      for (final MapEntry(:key, :value)
          in s.counts(doc.modules[s.moduleId]!).entries)
        '${s.moduleId}.$key': value,
  };

  /// True when any module holds data the user made (feature 010 research
  /// R11).
  Future<bool> hasUserData() async {
    for (final s in _sections) {
      if (await s.hasUserData(_db)) return true;
    }
    return false;
  }

  /// Builds the backup file (FR-001, FR-003, FR-004). With [password] the
  /// file is encrypted; never pass null when encryption is on. With
  /// [device] the file carries `meta` (feature 010 research R8).
  Future<BackupFile> create({
    required bool includeReceipts,
    String? password,
    DeviceIdentity? device,
    BackupKind kind = BackupKind.manual,
  }) async {
    final snapshot = await exportSnapshot();
    var doc = snapshot.document;
    if (device != null) {
      doc = doc.withMeta(
        BackupMeta(
          deviceId: device.id,
          deviceName: device.name,
          appVersion: doc.appVersion,
          createdAt: doc.createdAt,
          kind: kind,
          counts: _countsOf(doc),
          schemaVersion: doc.schemaVersion,
          encrypted: password != null,
        ),
      );
    }
    final files = <String, Uint8List>{};
    if (includeReceipts) {
      final docs = await _documentsDir();
      for (final s in _sections) {
        for (final rel in s.attachments(doc.modules[s.moduleId]!)) {
          final file = File('${docs.path}/$rel');
          // A missing image is skipped; the backup still succeeds.
          if (file.existsSync()) files[rel] = await file.readAsBytes();
        }
      }
    } else {
      doc = doc.copyWith(
        modules: {
          for (final s in _sections)
            s.moduleId: s.withoutAttachments(doc.modules[s.moduleId]!),
        },
      );
    }

    final json = doc.toJson();
    final hasFiles = includeReceipts && files.isNotEmpty;
    final inner = await Isolate.run(() {
      final bytes = BackupDocument.fromJson(json).encode();
      return hasFiles ? packZip(bytes, files) : bytes;
    });
    final Uint8List bytes;
    final ContainerForm form;
    if (password != null) {
      bytes = await _envelope.seal(
        inner,
        password: password,
        form: hasFiles ? InnerForm.zip : InnerForm.json,
      );
      form = ContainerForm.encrypted;
    } else {
      bytes = inner;
      form = hasFiles ? ContainerForm.zip : ContainerForm.plain;
    }
    final stamp = DateFormat('yyyyMMdd_HHmm').format(_clock.now());
    return BackupFile(
      bytes: bytes,
      fileName: 'dailytrack_backup_$stamp.${extensionFor(form)}',
      meta: doc.meta,
      changeCounter: snapshot.changeCounter,
    );
  }

  // ---- Restore: read-only phases ---------------------------------------

  /// Reads, decrypts, unpacks, checks, and upgrades [bytes] without
  /// changing anything (FR-005, FR-006). Throws [BackupNeedsPassword] for
  /// an encrypted file without [password].
  Future<RestoreCandidate> open(Uint8List bytes, {String? password}) async {
    var form = detectForm(bytes);
    var body = bytes;
    final encrypted = form == ContainerForm.encrypted;
    if (encrypted) {
      if (password == null) throw const BackupNeedsPassword();
      final (plain, inner) = await _envelope.open(bytes, password: password);
      body = plain;
      form = inner == InnerForm.zip ? ContainerForm.zip : ContainerForm.plain;
      if (detectForm(body) != form) throw const BackupDamaged('inner form');
    }
    final Uint8List json;
    var attachments = <String, Uint8List>{};
    switch (form) {
      case ContainerForm.plain:
        json = body;
      case ContainerForm.zip:
        (json, attachments) = unpackZip(body);
      case ContainerForm.encrypted:
      case ContainerForm.unknown:
        throw const BackupNotRecognized();
    }

    final migrated = BackupMigrator(
      _sections,
      current: _db.schemaVersion,
    ).upgrade(BackupDocument.decode(json));
    final doc = migrated.document;
    for (final s in _sections) {
      s.validate(doc.modules[s.moduleId]!);
    }
    return RestoreCandidate(
      preview: RestorePreview(
        createdAt: doc.createdAt,
        appVersion: doc.appVersion,
        modules: [
          for (final s in _sections)
            ModuleSummary(
              moduleId: s.moduleId,
              counts: s.counts(doc.modules[s.moduleId]!),
            ),
        ],
        skippedModuleIds: migrated.skippedModuleIds,
        receiptCount: attachments.length,
        encrypted: encrypted,
      ),
      document: doc,
      attachments: attachments,
    );
  }

  // ---- Restore: writing phases ------------------------------------------

  /// Replaces all module data and restorable settings with [candidate]'s
  /// (FR-008). Receipts are staged first; the database is written in one
  /// transaction; the receipt folder is swapped only after commit. If
  /// anything fails before the commit, data and files are unchanged.
  Future<RestoreOutcome> apply(RestoreCandidate candidate) async {
    final docs = await _documentsDir();
    final staging = Directory('${docs.path}/$_staging');
    try {
      await _stage(staging, candidate.attachments);
      await _writeDatabase(candidate.document);
    } on Object {
      await _deleteQuietly(staging);
      rethrow;
    }
    return await _swapReceipts(docs, staging);
  }

  Future<void> _stage(Directory staging, Map<String, Uint8List> files) async {
    try {
      if (staging.existsSync()) await staging.delete(recursive: true);
      await staging.create(recursive: true);
      for (final MapEntry(:key, :value) in files.entries) {
        final name = key.substring(receiptsFolder.length + 1);
        await File('${staging.path}/$name').writeAsBytes(value, flush: true);
      }
    } on FileSystemException {
      throw const BackupStorageFull();
    }
  }

  Future<void> _writeDatabase(BackupDocument doc) => _db.transaction(() async {
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    for (final s in _sections) {
      await s.restore(_db, doc.modules[s.moduleId]!);
    }
    await _restoreSettings(doc.settings);
    final broken = await _db.customSelect('PRAGMA foreign_key_check').get();
    if (broken.isNotEmpty) {
      throw BackupInvalid('${broken.length} rows refer to missing rows');
    }
  });

  /// Replaces only restorable keys; device state is kept (FR-009). Marks
  /// onboarding done and every seeder as run, so seeds never re-run over
  /// restored data.
  Future<void> _restoreSettings(Map<String, String> settings) async {
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    final current = await _db.select(_db.settings).get();
    for (final row in current) {
      if (BackupSettingsPolicy.isRestorable(row.key)) {
        await (_db.delete(
          _db.settings,
        )..where((t) => t.key.equals(row.key))).go();
      }
    }
    Future<void> put(String key, String value) => _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value, updatedAt: now),
        );
    for (final MapEntry(:key, :value) in settings.entries) {
      if (BackupSettingsPolicy.isRestorable(key)) await put(key, value);
    }
    await put(SettingsCodec.onboardingDone, SettingsCodec.encode(true));
    for (final id in _seederIds) {
      await put(SettingsCodec.seedKey(id), SettingsCodec.encode(now));
    }
  }

  Future<RestoreOutcome> _swapReceipts(
    Directory docs,
    Directory staging,
  ) async {
    final current = Directory('${docs.path}/$receiptsFolder');
    final old = Directory('${docs.path}/$_old');
    try {
      await _deleteQuietly(old);
      if (current.existsSync()) await current.rename(old.path);
      await staging.rename(current.path);
      await _deleteQuietly(old);
      return RestoreOutcome.done;
    } on FileSystemException {
      return RestoreOutcome.doneWithMissingReceipts;
    }
  }

  static Future<void> _deleteQuietly(Directory dir) async {
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
    } on FileSystemException {
      // Left for the next run; never blocks a restore.
    }
  }
}
