import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';

/// Localized display name of a currency (`currency_<CODE>` in the ARB files),
/// falling back to the code itself.
String currencyName(AppLocalizations l10n, String code) =>
    l10nByKey(l10n, 'currency_$code') ?? code;
