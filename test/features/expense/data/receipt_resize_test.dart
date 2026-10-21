import 'package:dailytrack/features/expense/data/receipts/resize_math.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-02: receipts are reduced to at most 1280 px on the longest side,
/// keeping the aspect ratio and never upscaling (research R8).
void main() {
  test('landscape and portrait shrink to 1280 on the longest side', () {
    expect(receiptTargetSize(4000, 3000), (1280, 960));
    expect(receiptTargetSize(3000, 4000), (960, 1280));
    expect(receiptTargetSize(4032, 1960), (1280, 622));
  });

  test('small images are unchanged', () {
    expect(receiptTargetSize(800, 600), (800, 600));
    expect(receiptTargetSize(1280, 1280), (1280, 1280));
  });

  test('extreme ratios keep at least 1 px', () {
    expect(receiptTargetSize(20000, 3), (1280, 1));
  });
}
