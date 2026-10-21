import 'dart:ui' show Locale;

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/device_info_source.dart';

/// The SET-01 "Send feedback" draft (feature 007 research R14): app version
/// and build, device model, Android version, and the device language.
/// It never contains app data or settings, not even the app language
/// (Constitution III).
({String subject, String body}) buildFeedbackEmail(
  AppLocalizations l10n, {
  required AppInfo app,
  required DeviceInfo device,
  required Locale deviceLocale,
}) {
  final model = '${device.manufacturer} ${device.model}'.trim();
  final android = device.sdkInt > 0
      ? '${device.release} (API ${device.sdkInt})'
      : device.release;
  return (
    subject: l10n.settings_feedbackSubject(app.version),
    body: l10n.settings_feedbackBody(
      app.version,
      app.buildNumber,
      model,
      android,
      deviceLocale.toLanguageTag(),
    ),
  );
}
