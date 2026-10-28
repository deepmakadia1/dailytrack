import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/typed_confirm_dialog.dart';
import 'package:flutter/material.dart';

/// The word typed to confirm; the same in every language (spec
/// Assumptions).
const String eraseConfirmWord = 'DELETE';

/// "Erase all data", shared by SET-01 and SYS-03 "Forgot PIN?" (FR-047,
/// FR-048, feature 007 research R16):
///  1. a dialog saying exactly what goes and that it can't be undone,
///  2. typing DELETE,
///  3. a progress dialog while [service] erases,
///  4. on failure, "Nothing was deleted" with "Try again".
/// On success the app restarts at Home by itself (AUTH-01 after a
/// sign-out), never at onboarding.
Future<void> showEraseAllDataFlow(
  BuildContext context,
  AppResetService service,
) async {
  final l10n = AppLocalizations.of(context);
  final first = await ConfirmDialog.show(
    context,
    title: l10n.erase_title,
    consequence: l10n.erase_body,
    confirmLabel: l10n.erase_continue,
    destructive: true,
  );
  if (!first || !context.mounted) return;
  final typed = await TypedConfirmDialog.show(
    context,
    title: l10n.erase_typeTitle,
    word: eraseConfirmWord,
    hint: l10n.erase_typeHint,
    confirmLabel: l10n.erase_confirm,
  );
  if (!typed || !context.mounted) return;

  final navigator = Navigator.of(context);
  while (true) {
    // The app may rebuild its screens while erasing, so the progress dialog
    // is removed by its route, never by popping whatever is on top.
    final progress = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ErasingDialog(),
    );
    navigator.push(progress);
    Object? error;
    try {
      await service.eraseAll();
    } on Object catch (e) {
      error = e;
    }
    if (progress.isActive) navigator.removeRoute(progress);
    if (error == null || !context.mounted) return;
    final retry = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('erase_failed'),
        content: Text(l10n.erase_failed),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.common_tryAgain),
          ),
        ],
      ),
    );
    if (retry != true || !context.mounted) return;
  }
}

class _ErasingDialog extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        key: const Key('erase_progress'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: tokens.s16),
            Expanded(child: Text(l10n.erase_inProgress)),
          ],
        ),
      ),
    );
  }
}
