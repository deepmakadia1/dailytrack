import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/backup/presentation/backup_failure_text.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// The ACC-01 state line: an icon and text, so the state never relies on
/// color alone; offline, paused, and failed use the `warning` color (spec
/// §16, data-model §7). A failure seen this session adds its message.
class BackupStatusLine extends StatelessWidget {
  const new({required this.status, super.key});

  final BackupStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final (icon, text, warn) = switch (status) {
      BackupStatusOffline() => (
        Icons.cloud_off_outlined,
        l10n.account_statusOffline,
        true,
      ),
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
      BackupStatusFailed(error: BackupNeedsPassword()) => (
        Icons.error_outline,
        l10n.account_statusFailedNoPassword,
        true,
      ),
      BackupStatusFailed() => (
        Icons.error_outline,
        l10n.account_statusFailed,
        true,
      ),
      BackupStatusWaitingForWifi() => (
        Icons.wifi_off_outlined,
        l10n.account_statusWaitingForWifi,
        false,
      ),
      BackupStatusBackedUp() => (
        Icons.cloud_done_outlined,
        l10n.account_statusBackedUp,
        false,
      ),
    };
    final detail = switch (status) {
      BackupStatusFailed(:final error?) when error is! BackupNeedsPassword =>
        backupFailureText(l10n, error),
      _ => null,
    };
    final color = warn ? tokens.warning : theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: tokens.iconSize, color: color),
        SizedBox(width: tokens.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
              if (detail != null)
                Text(
                  detail,
                  key: const Key('acc01_failureDetail'),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
