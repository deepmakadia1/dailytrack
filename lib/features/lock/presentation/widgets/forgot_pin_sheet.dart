import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/erase_all_data_flow.dart';
import 'package:flutter/material.dart';

/// SYS-03 "Forgot PIN?" (FR-035, US2-7, US2-8): the PIN can't be
/// recovered; the user can erase all data (typed DELETE) and start fresh.
/// Cancel leaves SYS-03, and any lockout, as it was. Restoring from a
/// Drive backup arrives with T3.2.
Future<void> showForgotPinSheet(
  BuildContext context,
  AppResetService service,
) async {
  final l10n = AppLocalizations.of(context);
  final erase = await AppBottomSheet.show<bool>(
    context,
    title: l10n.lock_forgotTitle,
    child: const _ForgotPin(),
  );
  if (erase == true && context.mounted) {
    await showEraseAllDataFlow(context, service);
  }
}

class _ForgotPin extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.lock_forgotBody,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('forgot_pin_erase'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.settings_eraseAll),
        ),
        SizedBox(height: tokens.s8),
        TextButton(
          key: const Key('forgot_pin_cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}
