/// Whether a full-screen ad may appear right now: the app is in the
/// foreground, not locked, and on a reading screen, never a form, lock,
/// onboarding, or premium screen (FR-023, feature 009 research R10). The
/// composition root binds it over the router and the lock session.
abstract interface class AdScreenProbe {
  bool get canShowFullScreenAd;
}

/// Never allows a full-screen ad: the default, and for tests.
final class NeverShowProbe implements AdScreenProbe {
  const new();

  @override
  bool get canShowFullScreenAd => false;
}
