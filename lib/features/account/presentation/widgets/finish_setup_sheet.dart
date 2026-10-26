import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// First Android version with a notification runtime permission (13).
const int notificationPermissionSdk = 33;

/// Shows "Finish setting up" once (research R13). Any action, or closing
/// it, clears `finishSetupPending`, so it never shows again.
Future<void> showFinishSetupSheet(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final sdk = (await container.read(deviceInfoSourceProvider).load()).sdkInt;
  if (!context.mounted) return;
  final settings = container.read(settingsRepositoryProvider);
  // Cleared before it shows, so a rebuild can never show it twice.
  await settings.setFinishSetupPending(pending: false);
  if (!context.mounted) return;
  await AppBottomSheet.show<void>(
    context,
    title: AppLocalizations.of(context).finishSetup_title,
    child: FinishSetupSheet(
      showNotifications: sdk >= notificationPermissionSdk,
    ),
  );
}

/// SYS-02 "Finish setting up" (spec §2, §16): the PIN is never backed up,
/// and a restore skipped the app lock step. No ads.
class FinishSetupSheet extends ConsumerWidget {
  const new({required this.showNotifications, super.key});

  /// "Allow notifications" only where Android asks for it (13+).
  final bool showNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Column(
      key: const Key('finish_setup'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.finishSetup_body),
        SizedBox(height: tokens.s16),
        FilledButton.icon(
          key: const Key('finish_setup_lock'),
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            unawaited(router.push(Routes.pinPath(Routes.pinModeSet)));
          },
          icon: const Icon(Icons.lock_outline),
          label: Text(l10n.finishSetup_setLock),
        ),
        if (showNotifications) ...[
          SizedBox(height: tokens.s8),
          OutlinedButton.icon(
            key: const Key('finish_setup_notifications'),
            onPressed: () {
              final permission = ref.read(notificationPermissionProvider);
              Navigator.of(context).pop();
              unawaited(permission.request().then((_) {}, onError: (_) {}));
            },
            icon: const Icon(Icons.notifications_outlined),
            label: Text(l10n.finishSetup_allowNotifications),
          ),
        ],
        SizedBox(height: tokens.s8),
        TextButton(
          key: const Key('finish_setup_later'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.finishSetup_notNow),
        ),
      ],
    );
  }
}
