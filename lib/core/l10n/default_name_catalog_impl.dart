import 'package:dailytrack/core/l10n/default_name_catalog.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:flutter/widgets.dart';

/// [DefaultNameCatalog] over the generated localizations for every
/// supported language (en, hi, gu), so translations are never copied.
final class L10nDefaultNameCatalog implements DefaultNameCatalog {
  const new();

  @override
  Set<String> namesFor(String key) => {
    for (final locale in AppLocalizations.supportedLocales)
      ?l10nByKey(lookupAppLocalizations(Locale(locale.languageCode)), key),
  };
}
