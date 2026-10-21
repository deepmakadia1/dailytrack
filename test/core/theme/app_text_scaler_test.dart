import 'package:dailytrack/core/theme/app_text_scaler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// SET-04 Large font size (T056, feature 007 research R11).
void main() {
  double scale(double system, {required bool large}) =>
      appTextScaler(TextScaler.linear(system), large: large).scale(10) / 10;

  test('Large adds 15% on top of the system scale', () {
    expect(scale(1, large: true), closeTo(1.15, 1e-9));
    expect(scale(1.5, large: true), closeTo(1.725, 1e-9));
  });

  test('the combined scale is capped at 200%', () {
    expect(scale(2, large: true), closeTo(2, 1e-9));
    expect(scale(1.8, large: true), closeTo(2, 1e-9));
  });

  test('Default leaves the system scale unchanged, even above 200%', () {
    expect(scale(1, large: false), 1);
    expect(scale(1.3, large: false), closeTo(1.3, 1e-9));
    expect(scale(2.4, large: false), closeTo(2.4, 1e-9));
  });
}
