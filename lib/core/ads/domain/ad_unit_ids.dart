/// Ad unit IDs for one build (spec §11, feature 009 research R3). A null ID
/// turns that format off: it requests nothing and takes no space. Pure Dart.
final class AdUnitIds {
  const new({this.banner, this.native, this.interstitial, this.rewarded});

  /// Reads the release IDs passed with `--dart-define`; empty means missing.
  factory fromEnvironment() {
    String? read(String value) => value.isEmpty ? null : value;
    return AdUnitIds(
      banner: read(const String.fromEnvironment('ADMOB_BANNER_ID')),
      native: read(const String.fromEnvironment('ADMOB_NATIVE_ID')),
      interstitial: read(const String.fromEnvironment('ADMOB_INTERSTITIAL_ID')),
      rewarded: read(const String.fromEnvironment('ADMOB_REWARDED_ID')),
    );
  }

  /// Google's public Android test IDs. Safe to commit (Constitution VI).
  static const AdUnitIds test = AdUnitIds(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    native: 'ca-app-pub-3940256099942544/2247696110',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    rewarded: 'ca-app-pub-3940256099942544/5224354917',
  );

  /// No ads at all.
  static const AdUnitIds none = AdUnitIds();

  final String? banner;
  final String? native;
  final String? interstitial;
  final String? rewarded;

  /// The IDs this build uses (FR-004):
  ///  - dev flavor or any non-release build: always [test];
  ///  - prod release whose manifest fell back to the test App ID: [none];
  ///  - prod release otherwise: [fromEnv], format by format.
  static AdUnitIds resolve({
    required bool isProd,
    required bool isRelease,
    required bool manifestUsesTestAppId,
    required AdUnitIds fromEnv,
  }) {
    if (!isProd || !isRelease) return test;
    if (manifestUsesTestAppId) return none;
    return fromEnv;
  }
}
