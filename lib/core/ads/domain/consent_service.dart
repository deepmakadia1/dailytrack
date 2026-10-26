/// What a consent check found (feature 009 research R4).
final class ConsentResult {
  const new({
    required this.canRequestAds,
    required this.privacyOptionsRequired,
  });

  static const ConsentResult none = ConsentResult(
    canRequestAds: false,
    privacyOptionsRequired: false,
  );

  final bool canRequestAds;
  final bool privacyOptionsRequired;
}

/// Ad consent (UMP, spec §11). The ads SDK starts, and ads are requested,
/// only after [canRequestAds] says so (FR-011, FR-012). Pure Dart; the UMP
/// adapter lives in `data/`.
abstract interface class ConsentService {
  /// Updates consent info and shows the consent form if one is required.
  /// [beforeForm] runs right before a form appears (SYS-01 removes the
  /// native splash). Only the info update is limited to [timeout]; the
  /// form waits for the user. Never throws: on any failure the answer comes
  /// from the SDK's stored state.
  Future<ConsentResult> gather({
    required Future<void> Function() beforeForm,
    required Duration timeout,
  });

  /// From the SDK's stored state, so it works offline. Never throws.
  Future<bool> canRequestAds();

  /// Whether SET-01 must offer "Ad privacy choices" (FR-014). Emits the
  /// current answer, then after every [gather] and privacy form.
  Stream<bool> get privacyOptionsRequired;

  /// Reopens the consent form from "Ad privacy choices".
  Future<void> showPrivacyOptionsForm();

  /// Dev-only "Reset ad counters": forgets stored consent, so the form
  /// shows again on the next cold start (feature 009 research R15).
  Future<void> resetForDebug();
}

/// No consent SDK: tests, and Pro users who never load it. Ads are never
/// allowed and no privacy row is shown.
final class NoConsentService implements ConsentService {
  const new();

  @override
  Future<ConsentResult> gather({
    required Future<void> Function() beforeForm,
    required Duration timeout,
  }) async => ConsentResult.none;

  @override
  Future<bool> canRequestAds() async => false;

  @override
  Stream<bool> get privacyOptionsRequired => Stream.value(false);

  @override
  Future<void> showPrivacyOptionsForm() async {}

  @override
  Future<void> resetForDebug() async {}
}
