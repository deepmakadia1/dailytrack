import 'dart:async';

import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// [ConsentService] over Google's UMP SDK, bundled with `google_mobile_ads`
/// (spec §11, feature 009 research R4). The only UMP caller.
// Device bindings; exercised on a device (quickstart §4.1), not unit tests.
// coverage:ignore-start
final class UmpConsentService implements ConsentService {
  new({this.debugSettings});

  /// Dev builds only: `--dart-define=UMP_DEBUG_GEOGRAPHY=eea` (or `other`)
  /// and `UMP_TEST_DEVICE_ID=<hashed id>` force the consent region, so the
  /// form can be tested anywhere. Prod passes null.
  factory fromEnvironment({required bool isProd}) {
    if (isProd) return UmpConsentService();
    const geography = String.fromEnvironment('UMP_DEBUG_GEOGRAPHY');
    const device = String.fromEnvironment('UMP_TEST_DEVICE_ID');
    final debugGeography = switch (geography) {
      'eea' => DebugGeography.debugGeographyEea,
      'other' => DebugGeography.debugGeographyOther,
      _ => null,
    };
    if (debugGeography == null && device.isEmpty) return UmpConsentService();
    return UmpConsentService(
      debugSettings: ConsentDebugSettings(
        debugGeography: debugGeography,
        testIdentifiers: device.isEmpty ? null : [device],
      ),
    );
  }

  final ConsentDebugSettings? debugSettings;

  final _privacyChanges = StreamController<bool>.broadcast();
  bool? _privacyRequired;

  @override
  Future<ConsentResult> gather({
    required Future<void> Function() beforeForm,
    required Duration timeout,
  }) async {
    try {
      await _requestUpdate().timeout(timeout);
    } on Object {
      // Offline or failing: keep whatever the SDK stored last time.
      return await _current();
    }
    try {
      final info = ConsentInformation.instance;
      if (await info.getConsentStatus() == ConsentStatus.required &&
          await info.isConsentFormAvailable()) {
        await beforeForm();
      }
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
    } on Object {
      // A form that fails to load leaves consent as it was.
    }
    return await _current();
  }

  Future<void> _requestUpdate() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(consentDebugSettings: debugSettings),
      done.complete,
      (error) => done.completeError(
        StateError('consent update failed: ${error.errorCode}'),
      ),
    );
    return done.future;
  }

  Future<ConsentResult> _current() async {
    final result = ConsentResult(
      canRequestAds: await canRequestAds(),
      privacyOptionsRequired: await _readPrivacyRequired(),
    );
    _emitPrivacy(result.privacyOptionsRequired);
    return result;
  }

  Future<bool> _readPrivacyRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } on Object {
      return false;
    }
  }

  void _emitPrivacy(bool required) {
    if (_privacyRequired == required) return;
    _privacyRequired = required;
    _privacyChanges.add(required);
  }

  @override
  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } on Object {
      return false;
    }
  }

  @override
  Stream<bool> get privacyOptionsRequired async* {
    yield _privacyRequired ?? await _readPrivacyRequired();
    yield* _privacyChanges.stream;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } on Object {
      // The form is optional UI; the stored consent stays as it was.
    }
    _emitPrivacy(await _readPrivacyRequired());
  }

  @override
  Future<void> resetForDebug() async {
    try {
      await ConsentInformation.instance.reset();
    } on Object {
      // Dev tool only.
    }
  }
}
// coverage:ignore-end
