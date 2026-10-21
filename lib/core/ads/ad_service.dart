/// All ad code goes through this interface (Constitution VI). Phase 0 only
/// needs [initialize]; banner, native, interstitial and rewarded methods
/// arrive in T4.x.
abstract interface class AdService {
  Future<void> initialize();
}

/// Used in Phase 0, for Pro users, during ad-free days, and in tests.
/// Ad widgets backed by this service take no space at all.
final class NoAdsService implements AdService {
  const new();

  @override
  Future<void> initialize() async {}
}
