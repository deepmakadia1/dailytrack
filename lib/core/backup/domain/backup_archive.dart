import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';

/// How a backup file is packed (research R2), recognized by its first bytes,
/// never by its extension.
enum ContainerForm { plain, zip, encrypted, unknown }

/// What an encrypted envelope wraps.
enum InnerForm { json, zip }

/// File extension per form.
String extensionFor(ContainerForm form) => switch (form) {
  ContainerForm.plain => 'json',
  ContainerForm.zip => 'zip',
  ContainerForm.encrypted => 'dtbk',
  ContainerForm.unknown => 'bin',
};

/// Name of the backup document inside a zip.
const String zipDocumentName = 'backup.json';

const List<int> _zipMagic = [0x50, 0x4B, 0x03, 0x04];

/// `DTBK`.
const List<int> envelopeMagic = [0x44, 0x54, 0x42, 0x4B];

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}

ContainerForm detectForm(Uint8List bytes) {
  if (_startsWith(bytes, envelopeMagic)) return ContainerForm.encrypted;
  if (_startsWith(bytes, _zipMagic)) return ContainerForm.zip;
  for (final b in bytes) {
    // Skip JSON whitespace (space, tab, LF, CR) and a UTF-8 BOM.
    if (b == 0x20 || b == 0x09 || b == 0x0A || b == 0x0D) continue;
    if (b == 0xEF || b == 0xBB || b == 0xBF) continue;
    return b == 0x7B ? ContainerForm.plain : ContainerForm.unknown;
  }
  return ContainerForm.unknown;
}

/// Packs the document and attachments (relative paths such as
/// `receipts/<uuid>.jpg`) into one zip.
Uint8List packZip(Uint8List json, Map<String, Uint8List> files) {
  final archive = Archive()..addFile(ArchiveFile.bytes(zipDocumentName, json));
  for (final MapEntry(:key, :value) in files.entries) {
    archive.addFile(ArchiveFile.bytes(key, value));
  }
  return ZipEncoder().encodeBytes(archive);
}

/// The document and every attachment of a zip. Throws [BackupDamaged] for a
/// bad zip or a missing document, and [BackupInvalid] for an unsafe path.
(Uint8List, Map<String, Uint8List>) unpackZip(Uint8List zip) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(zip, verify: true);
  } on Object catch (e) {
    throw BackupDamaged('zip: $e');
  }
  Uint8List? json;
  final files = <String, Uint8List>{};
  for (final entry in archive.files) {
    if (!entry.isFile) continue;
    final Uint8List bytes;
    try {
      bytes = entry.content;
    } on Object catch (e) {
      throw BackupDamaged('zip entry ${entry.name}: $e');
    }
    if (entry.name == zipDocumentName) {
      json = bytes;
    } else {
      if (!isSafeAttachmentPath(entry.name)) {
        throw BackupInvalid('unsafe file name in backup: ${entry.name}');
      }
      files[entry.name] = bytes;
    }
  }
  if (json == null) throw const BackupDamaged('zip has no backup.json');
  return (json, files);
}

/// Attachments live only under `receipts/` with a plain file name, so a file
/// can never escape the app folder on restore.
bool isSafeAttachmentPath(String path) =>
    RegExp(r'^receipts/[A-Za-z0-9._-]+$').hasMatch(path) &&
    !path.contains('..');
