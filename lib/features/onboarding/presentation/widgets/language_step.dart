import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:flutter/material.dart';

/// SYS-02 step 1: welcome headline and language chips. Choosing a language
/// switches the UI immediately.
class LanguageStep extends StatelessWidget {
  const new({
    required this.languageCode,
    required this.onLanguageSelected,
    this.restore,
    super.key,
  });

  /// "Restore with Google" and its messages, when Drive is available.
  final Widget? restore;

  /// Chosen language, or null when following the device.
  final String? languageCode;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final current =
        languageCode ?? Localizations.localeOf(context).languageCode;
    return ListView(
      padding: EdgeInsets.symmetric(vertical: tokens.s24),
      children: [
        Icon(
          Icons.insights_rounded,
          size: tokens.s48 * 2,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: tokens.s24),
        Text(
          l10n.onboarding_welcomeTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s32),
        Text(l10n.onboarding_languageLabel, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.s12),
        ChipSelector<String>(
          key: const Key('onboarding_language'),
          options: supportedLanguageCodes,
          selected: {current},
          labelBuilder: (code) => l10nByKey(l10n, 'language_$code') ?? code,
          onChanged: (selected) => onLanguageSelected(selected.first),
        ),
        if (restore case final restore?) ...[
          SizedBox(height: tokens.s24),
          restore,
        ],
      ],
    );
  }
}
