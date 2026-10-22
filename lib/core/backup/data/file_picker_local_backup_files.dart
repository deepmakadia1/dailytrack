import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:file_picker/file_picker.dart';

/// [LocalBackupFiles] over `file_picker` (system save and open dialogs).
/// Platform channel only, so it is covered by the device check (quickstart
/// §4 step 1).
// coverage:ignore-start
final class FilePickerLocalBackupFiles implements LocalBackupFiles {
  const new({this.beforeLeaving});

  /// Called before the system picker opens, so the trip out does not lock
  /// the app (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<bool> saveAs(Uint8List bytes, {required String suggestedName}) async {
    beforeLeaving?.call();
    final uri = await FilePicker.saveFile(
      fileName: suggestedName,
      bytes: bytes,
    );
    return uri != null;
  }

  @override
  Future<Uint8List?> pick() async {
    beforeLeaving?.call();
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return null;
    return await files.first.xFile.readAsBytes();
  }
}
// coverage:ignore-end
