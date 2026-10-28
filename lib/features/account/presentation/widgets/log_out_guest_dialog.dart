import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/account/presentation/controllers/log_out_guest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens ACC-04 Log out of guest (spec §16). "Sign in with Google instead"
/// closes it and starts guest sign-in; "Cancel", back, and tapping outside
/// change nothing.
Future<void> showLogOutGuestDialog(BuildContext context) async {
  final signInInstead = await showDialog<bool>(
    context: context,
    builder: (_) => const LogOutGuestDialog(),
  );
  if (signInInstead == true && context.mounted) {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(accountUiProvider).startGuestSignIn(context);
  }
}

/// ACC-04 (feature 011 contracts/screens.md): `ConfirmDialog`'s layout
/// (title, consequence, Cancel, a destructive action in `error` color)
/// with a third, text action and the deleting and error states, which the
/// stateless `ConfirmDialog` can't show. No ads.
class LogOutGuestDialog extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(logOutGuestControllerProvider);
    final deleting = state == LogOutGuestState.deleting;
    final navigator = Navigator.of(context);

    Future<void> confirm() async {
      final done = await ref
          .read(logOutGuestControllerProvider.notifier)
          .confirm();
      // The router opens AUTH-01; the dialog goes with the old screens.
      if (done && navigator.mounted && navigator.canPop()) navigator.pop();
    }

    return PopScope(
      // Back and tapping outside do nothing while deleting.
      canPop: !deleting,
      child: AlertDialog(
        key: const Key('acc04_dialog'),
        // Long text at 200% font scale on a 360 dp screen scrolls (§15.10).
        scrollable: true,
        title: Text(l10n.logOutGuest_title, key: const Key('acc04_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.logOutGuest_body, key: const Key('acc04_body')),
            if (state == LogOutGuestState.error) ...[
              SizedBox(height: tokens.s16),
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: scheme.error),
                    SizedBox(width: tokens.s8),
                    Expanded(
                      child: Text(
                        l10n.logOutGuest_failed,
                        key: const Key('acc04_failed'),
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsOverflowButtonSpacing: tokens.s8,
        actions: [
          TextButton(
            key: const Key('acc04_signInInstead'),
            onPressed: deleting ? null : () => navigator.pop(true),
            child: Text(l10n.logOutGuest_signInInstead),
          ),
          TextButton(
            key: const Key('acc04_cancel'),
            onPressed: deleting ? null : () => navigator.pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            key: const Key('acc04_confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: deleting ? null : () => unawaited(confirm()),
            child: deleting
                ? SizedBox.square(
                    dimension: tokens.s16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onError,
                    ),
                  )
                : Text(l10n.logOutGuest_confirm),
          ),
        ],
      ),
    );
  }
}
