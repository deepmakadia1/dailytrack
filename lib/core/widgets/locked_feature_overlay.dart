import 'dart:ui';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Blurs a Pro feature and offers "Watch an ad" (PRM-02) and "Get Pro"
/// (PRM-01) (§15.4, feature 003 research R14, feature 009 FR-032).
class LockedFeatureOverlay extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onWatchAd,
    this.onGetPro,
    this.message,
    this.watchAdLabel,
  });

  final Widget child;

  /// Opens PRM-02. Null: the "Watch an ad" button is not built.
  final VoidCallback? onWatchAd;

  /// Opens PRM-01. Null: "Get Pro" is shown disabled.
  final VoidCallback? onGetPro;

  /// Says what the ad unlocks, e.g. "Watch an ad to unlock for 24 hours".
  /// Defaults to "Watch an ad".
  final String? watchAdLabel;

  /// An optional explanation line under the lock badge.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Blur strength reuses the 8 dp spacing step; enough to hide numbers.
    final sigma = tokens.s8;

    // Both children are unpositioned, so the overlay is at least as large as
    // the card even when the locked content is small.
    return Stack(
      alignment: Alignment.center,
      children: [
        // The locked content is shown blurred but can't be used or read out.
        ExcludeSemantics(
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(tokens.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: tokens.avatarSize / 2,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    Icons.lock,
                    color: scheme.onPrimaryContainer,
                    semanticLabel: l10n.premium_lockedLabel,
                  ),
                ),
                if (message case final text?) ...[
                  SizedBox(height: tokens.s12),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                SizedBox(height: tokens.s16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: tokens.s8,
                  runSpacing: tokens.s8,
                  children: [
                    if (onWatchAd case final watch?)
                      OutlinedButton.icon(
                        key: const Key('locked_watch_ad'),
                        onPressed: watch,
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(watchAdLabel ?? l10n.premium_watchAd),
                      ),
                    FilledButton(
                      key: const Key('locked_get_pro'),
                      onPressed: onGetPro,
                      child: Text(l10n.premium_getPro),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
