import 'dart:ui';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Blurs a Pro feature and offers "Watch an ad" or "Get Pro" (§15.4,
/// feature 003 research R14). Wired to rewarded ads and billing in T4.4;
/// until then callers leave [onWatchAd] out and pass no [onGetPro].
class LockedFeatureOverlay extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onWatchAd,
    this.onGetPro,
    this.message,
  });

  final Widget child;

  /// Null: the "Watch an ad" button is not built (feature 008 adds it).
  final VoidCallback? onWatchAd;

  /// Null: "Get Pro" is shown disabled (PRM-01 does not exist yet).
  final VoidCallback? onGetPro;

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
                        onPressed: watch,
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(l10n.premium_watchAd),
                      ),
                    FilledButton(
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
