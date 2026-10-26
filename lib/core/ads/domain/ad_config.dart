/// Every tunable ad number in one place (spec §11), so the values can later
/// come from Remote Config without code changes elsewhere (feature 009
/// data-model §3). Pure Dart.
final class AdConfig {
  const new({
    this.installAgeDays = 2,
    this.minGap = const Duration(minutes: 3),
    this.maxPerDay = 4,
    this.savesPerInterstitial = 4,
    this.sessionGap = const Duration(minutes: 30),
    this.rewardedTimeout = const Duration(seconds: 8),
    this.retryBackoff = const [
      Duration(seconds: 30),
      Duration(seconds: 60),
      Duration(seconds: 120),
    ],
    this.afterCloseDelay = const Duration(milliseconds: 400),
    this.consentUpdateTimeout = const Duration(seconds: 5),
    this.nativeFirstRow = 8,
    this.nativeEvery = 15,
    this.nativeMaxPerLoad = 3,
    this.habitsNativeMinCards = 5,
    this.habitsNativeAfter = 4,
    this.rewardedPerKeyPerDay = 10,
  });

  static const AdConfig defaults = AdConfig();

  /// No interstitial in the first days after install.
  final int installAgeDays;

  /// Minimum time between two interstitials.
  final Duration minGap;

  /// Most interstitials per local day.
  final int maxPerDay;

  /// New EXP-02 entries per interstitial (clarification Q4).
  final int savesPerInterstitial;

  /// Background time after which a return starts a new session
  /// (clarification Q3).
  final Duration sessionGap;

  /// PRM-02 waits this long for a rewarded ad.
  final Duration rewardedTimeout;

  /// Waits between banner/native load retries; then the slot gives up.
  final List<Duration> retryBackoff;

  /// Wait after a screen closes before an interstitial may show.
  final Duration afterCloseDelay;

  /// Limit for the UMP consent info update in SYS-01.
  final Duration consentUpdateTimeout;

  final int nativeFirstRow;
  final int nativeEvery;
  final int nativeMaxPerLoad;
  final int habitsNativeMinCards;
  final int habitsNativeAfter;

  /// Earned rewards per feature key per local day (FR-053).
  final int rewardedPerKeyPerDay;
}
