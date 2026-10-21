enum ReceiptSource { camera, gallery }

/// Picks and stores a receipt photo (research R8).
abstract interface class ReceiptPicker {
  /// Picks, downsizes (longest side ≤ 1280), re-encodes JPEG quality 80
  /// without EXIF, stores it under `receipts/`, and returns the RELATIVE
  /// path, or null if the user cancelled. Throws `ReceiptFailure`.
  Future<String?> pick(ReceiptSource source);
}
