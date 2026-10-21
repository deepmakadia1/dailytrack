import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// SYS-02 step 4: privacy explanation, the optional notification request,
/// and the optional app lock (opens SYS-04; feature 007 US9).
class PrivacyStep extends StatelessWidget {
  const new({
    required this.notificationsGranted,
    required this.onAllowNotifications,
    required this.appLockOn,
    required this.onSetAppLock,
    super.key,
  });

  /// Null until the user has been asked.
  final bool? notificationsGranted;
  final VoidCallback onAllowNotifications;

  /// The lock is on: show "App lock is on" and offer "Change PIN".
  final bool appLockOn;

  /// Opens SYS-04; receives [appLockOn] to pick set or change.
  final ValueChanged<bool> onSetAppLock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final granted = notificationsGranted;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: tokens.s24),
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: tokens.s48 * 2,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: tokens.s24),
        Text(
          l10n.onboarding_privacyTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s12),
        Text(
          l10n.onboarding_privacyBody,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s32),
        OutlinedButton.icon(
          key: const Key('onboarding_allow_notifications'),
          onPressed: onAllowNotifications,
          icon: const Icon(Icons.notifications_active_outlined),
          label: Text(l10n.onboarding_allowNotifications),
        ),
        if (granted != null) ...[
          SizedBox(height: tokens.s12),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(
                  granted
                      ? Icons.check_circle_outline
                      : Icons.notifications_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: tokens.s8),
                Expanded(
                  child: Text(
                    granted
                        ? l10n.onboarding_notificationsGranted
                        : l10n.onboarding_notificationsDenied,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: tokens.s16),
        OutlinedButton.icon(
          key: const Key('onboarding_set_app_lock'),
          onPressed: () => onSetAppLock(appLockOn),
          icon: const Icon(Icons.lock_outline),
          label: Text(
            appLockOn ? l10n.onboarding_changePin : l10n.onboarding_setAppLock,
          ),
        ),
        if (appLockOn) ...[
          SizedBox(height: tokens.s12),
          Semantics(
            liveRegion: true,
            child: Row(
              key: const Key('onboarding_app_lock_on'),
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: tokens.s8),
                Expanded(
                  child: Text(
                    l10n.security_lockOn,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
