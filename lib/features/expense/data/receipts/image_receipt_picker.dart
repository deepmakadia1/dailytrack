import 'dart:io';
import 'dart:ui' as ui;

import 'package:dailytrack/features/expense/data/receipts/file_receipt_store.dart';
import 'package:dailytrack/features/expense/data/receipts/resize_math.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Picks a receipt photo and stores it as a small JPEG (EXP-02, research R8):
/// longest side ≤ 1280 px, quality 80, EXIF (including GPS) stripped.
///
/// Camera, gallery and the native codec only run on a device, so this class
/// is covered by the manual receipt check (T117); the size math and file
/// handling it relies on are unit-tested.
// coverage:ignore-start
final class ImageReceiptPicker implements ReceiptPicker {
  new(this._store, {ImagePicker? picker, this.beforeLeaving})
    : _picker = picker ?? ImagePicker();

  final FileReceiptStore _store;
  final ImagePicker _picker;

  /// Called before the camera or gallery opens, so the trip out does not
  /// lock the app (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<String?> pick(ReceiptSource source) async {
    try {
      beforeLeaving?.call();
      final picked = await _picker.pickImage(
        source: switch (source) {
          ReceiptSource.camera => ImageSource.camera,
          ReceiptSource.gallery => ImageSource.gallery,
        },
        // A cheap first pass; the final size is set below.
        maxWidth: 2560,
        maxHeight: 2560,
      );
      if (picked == null) return null;

      final (width, height) = await _dimensions(picked.path);
      final (targetW, targetH) = receiptTargetSize(width, height);
      final relative = _store.newRelativePath();
      final target = File(await _store.absolute(relative));
      await target.parent.create(recursive: true);

      final result = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target.path,
        minWidth: targetW,
        minHeight: targetH,
        quality: 80,
      );
      if (result == null) throw const ReceiptFailure('compression failed');
      return relative;
    } on ReceiptFailure {
      rethrow;
    } on Exception catch (e) {
      throw ReceiptFailure(e);
    }
  }

  /// Reads the pixel size without decoding the whole image.
  static Future<(int, int)> _dimensions(String path) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await File(path).readAsBytes(),
    );
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = (descriptor.width, descriptor.height);
    descriptor.dispose();
    buffer.dispose();
    return size;
  }
}
// coverage:ignore-end
