import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Wraps a single widget in the app theme and localizations, for shared
/// widget tests that don't need providers or routing.
Widget themed(
  Widget child, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  bool wrapInScaffold = true,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: wrapInScaffold ? Scaffold(body: child) : child,
  );
}
