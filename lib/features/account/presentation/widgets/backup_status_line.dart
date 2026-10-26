import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// The ACC-01 state line: an icon and text, so the state never relies on
/// color alone; paused and failed use the `warning` color (spec §16).
class BackupStatusLine extends StatelessWidget {
  const new({required this.status, super.key});

  final BackupStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final (icon, text, warn) = switch (status) {
      BackupStatusBackingUp() => (
        Icons.cloud_sync_outlined,
        l10n.account_statusBackingUp,
        false,
      ),
      BackupStatusPaused() => (
        Icons.pause_circle_outline,
        l10n.account_statusPaused,
        true,
      ),
      BackupStatusFailed() => (
        Icons.error_outline,
        l10n.account_statusFailed,
        true,
      ),
      BackupStatusBackedUp() => (
        Icons.cloud_done_outlined,
        l10n.account_statusBackedUp,
        false,
      ),
    };
    final color = warn ? tokens.warning : theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: tokens.iconSize, color: color),
        SizedBox(width: tokens.s8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
