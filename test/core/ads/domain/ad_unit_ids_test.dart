import 'package:dailytrack/core/ads/ad_providers.dart';
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
      final ids = AdUnitIds.resolveFor(
        isProd: false,
        isRelease: true,
        manifestUsesTestAppId: false,
        fromEnv: real,
      );
      expect(identical(ids, AdUnitIds.test), isTrue);
    });

    test('prod flavor, debug build', () {
      final ids = AdUnitIds.resolveFor(
        isProd: true,
        isRelease: false,
        manifestUsesTestAppId: false,
        fromEnv: real,
      );
      expect(identical(ids, AdUnitIds.test), isTrue);
    });
  });

  test('US5-3 prod release on the test App ID requests no ads', () {
    final ids = AdUnitIds.resolveFor(
      isProd: true,
      isRelease: true,
      manifestUsesTestAppId: true,
      fromEnv: real,
    );
    expect(ids.banner, isNull);
    expect(ids.native, isNull);
  });

  test('prod release with a real App ID uses the release IDs', () {
    final ids = AdUnitIds.resolveFor(
      isProd: true,
      isRelease: true,
      manifestUsesTestAppId: false,
      fromEnv: real,
    );
    expect(identical(ids, real), isTrue);
  });

  test('prod release with a real App ID turns off a format with no ID', () {
    final ids = AdUnitIds.resolveFor(
      isProd: true,
      isRelease: true,
      manifestUsesTestAppId: false,
      fromEnv: const AdUnitIds(banner: 'release-unit-1'),
    );
    expect(ids.banner, 'release-unit-1');
    expect(ids.native, isNull);
    expect(ids.interstitial, isNull);
    expect(ids.rewarded, isNull);
  });

  // Feature 012 T004: the compile-time branch. Tests run as a debug, non-prod
  // build, so it must give the test IDs even with real-looking ones.
  test('resolveAdUnitIds gives the test IDs in a debug, non-prod build', () {
    for (final manifestUsesTestAppId in [true, false]) {
      final ids = resolveAdUnitIds(
        manifestUsesTestAppId: manifestUsesTestAppId,
        fromEnv: real,
      );
      expect(identical(ids, AdUnitIds.test), isTrue);
    }
  });
}
