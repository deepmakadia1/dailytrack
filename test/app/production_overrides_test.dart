import 'dart:io';

import 'package:dailytrack/app/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-041, SC-010: developer tools exist exactly when the flavor is not
/// prod (`production_overrides.dart` binds `debugToolsAvailableProvider`
/// to `!FlavorConfig.current.isProd`).
void main() {
  test('prod has no developer tools; dev and unknown flavors do', () {
    expect(!FlavorConfig.fromName('prod').isProd, isFalse);
    expect(!FlavorConfig.fromName('dev').isProd, isTrue);
    expect(!FlavorConfig.fromName(null).isProd, isTrue);
  });

  test('production_overrides.dart binds the provider from the flavor', () {
    final src = File('lib/app/production_overrides.dart').readAsStringSync();
    expect(
      src,
      contains(
        'debugToolsAvailableProvider.overrideWithValue('
        '!FlavorConfig.current.isProd)',
      ),
    );
  });
}
