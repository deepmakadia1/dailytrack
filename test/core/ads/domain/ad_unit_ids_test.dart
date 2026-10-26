import 'package:dailytrack/core/ads/domain/ad_unit_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const real = AdUnitIds(
    banner: 'release-unit-1',
    native: 'release-unit-2',
    interstitial: 'release-unit-3',
    rewarded: 'release-unit-4',
  );

  test('the test IDs are Google public Android test IDs', () {
    for (final id in [
      AdUnitIds.test.banner,
      AdUnitIds.test.native,
      AdUnitIds.test.interstitial,
      AdUnitIds.test.rewarded,
    ]) {
      expect(id, startsWith('ca-app-pub-3940256099942544/'));
    }
  });

  group('FR-004 dev and debug builds always use the test IDs', () {
    test('dev flavor, release build', () {
      final ids = AdUnitIds.resolve(
        isProd: false,
        isRelease: true,
        manifestUsesTestAppId: false,
        fromEnv: real,
      );
      expect(identical(ids, AdUnitIds.test), isTrue);
    });

    test('prod flavor, debug build', () {
      final ids = AdUnitIds.resolve(
        isProd: true,
        isRelease: false,
        manifestUsesTestAppId: false,
        fromEnv: real,
      );
      expect(identical(ids, AdUnitIds.test), isTrue);
    });
  });

  test('US5-3 prod release on the test App ID requests no ads', () {
    final ids = AdUnitIds.resolve(
      isProd: true,
      isRelease: true,
      manifestUsesTestAppId: true,
      fromEnv: real,
    );
    expect(ids.banner, isNull);
    expect(ids.native, isNull);
  });

  test('prod release with a real App ID uses the release IDs', () {
    final ids = AdUnitIds.resolve(
      isProd: true,
      isRelease: true,
      manifestUsesTestAppId: false,
      fromEnv: real,
    );
    expect(identical(ids, real), isTrue);
  });
}
