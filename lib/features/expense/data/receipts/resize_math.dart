import 'dart:math' as math;

/// Longest side of a stored receipt, in pixels (EXP-02).
const int receiptMaxSide = 1280;

/// The size to re-encode a [width] × [height] photo at: the longest side at
/// most [maxSide], aspect ratio kept, never upscaled (research R8).
(int, int) receiptTargetSize(
  int width,
  int height, {
  int maxSide = receiptMaxSide,
}) {
  final longest = math.max(width, height);
  if (longest <= maxSide) return (width, height);
  int scale(int side) => math.max(1, (side * maxSide / longest).round());
  return (scale(width), scale(height));
}
