import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';

/// Default categories and accounts store their names as ARB keys so they
/// translate (spec §12). User-created names are returned unchanged.
String localizedSeedName(AppLocalizations l10n, String key) =>
    l10nByKey(l10n, key) ?? key;
