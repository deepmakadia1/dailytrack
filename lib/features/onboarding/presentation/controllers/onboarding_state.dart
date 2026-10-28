import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// SYS-02 screen state (T065, data-model.md §6).
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory({
    /// 1..4.
    @Default(1) int step,

    /// Chosen UI language, or null to follow the device.
    String? languageCode,
    @Default('INR') String currencyCode,
    @Default(<String>[]) List<String> moduleOrder,
    @Default(<String>[]) List<String> enabledModules,

    /// Currency search text (step 2).
    @Default('') String query,

    /// True while settings are being saved.
    @Default(false) bool saving,

    /// ARB key of the inline "keep one module on" message, if shown.
    String? moduleMessageKey,

    /// Result of the notification request, or null if not asked yet.
    bool? notificationsGranted,

    /// ARB key of the inline save error, if the last save failed.
    String? saveErrorKey,
  }) = _OnboardingState;

  const new _();

  static const int stepCount = 4;

  bool get canSkip => step <= 2;

  bool get isLastStep => step == stepCount;
}
