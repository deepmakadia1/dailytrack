import 'dart:ui';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// Localizations for text built without a `BuildContext`, such as
/// notifications (feature 003 research R6, R15): the saved language, else
/// the device language when the app supports it, else English. Same rule as
/// `resolveLocale` in `app.dart`.
AppLocalizations l10nFor(String? savedLanguageCode, {Locale? device}) {
  final deviceCode =
      (device ?? PlatformDispatcher.instance.locale).languageCode;
  final code = savedLanguageCode ?? deviceCode;
  return lookupAppLocalizations(
    Locale(supportedLanguageCodes.contains(code) ? code : 'en'),
  );
}
