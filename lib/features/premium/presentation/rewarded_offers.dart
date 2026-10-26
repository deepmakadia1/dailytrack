import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// What PRM-02 says for one feature key: what the user gets and for how
/// long, before any ad plays (§15.8, FR-028).
final class RewardedOffer {
  const new({
    required this.icon,
    required this.title,
    required this.explanation,
  });

  final IconData icon;
  final String title;
  final String explanation;
}

/// The offer for [key]. [subjectName] is the theme or habit name.
RewardedOffer rewardedOfferFor(
  AppLocalizations l10n,
  FeatureKey key, {
  String? subjectName,
}) {
  if (key == FeatureKey.advancedReports) {
    return RewardedOffer(
      icon: Icons.insights_outlined,
      title: l10n.rewarded_titleReports,
      explanation: l10n.rewarded_explainReports,
    );
  }
  if (key == FeatureKey.exportCsv || key == FeatureKey.exportPdf) {
    return RewardedOffer(
      icon: Icons.ios_share,
      title: key == FeatureKey.exportCsv
          ? l10n.rewarded_titleCsv
          : l10n.rewarded_titlePdf,
      explanation: l10n.rewarded_explainExport,
    );
  }
  if (key == FeatureKey.streakFreeze) {
    return RewardedOffer(
      icon: Icons.ac_unit,
      title: l10n.rewarded_titleFreeze(subjectName ?? ''),
      explanation: l10n.rewarded_explainFreeze,
    );
  }
  // premiumTheme_{name}.
  return RewardedOffer(
    icon: Icons.palette_outlined,
    title: l10n.rewarded_titleTheme(subjectName ?? ''),
    explanation: l10n.rewarded_explainTheme,
  );
}
