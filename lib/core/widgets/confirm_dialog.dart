import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Confirmation for irreversible actions (§15.4): a title, the consequence
/// in plain words, Cancel, and the confirm action. Destructive confirms use
/// the error color.
class ConfirmDialog extends StatelessWidget {
  const new({
    required this.title,
    required this.consequence,
    required this.confirmLabel,
    super.key,
    this.destructive = false,
  });

  final String title;
  final String consequence;
  final String confirmLabel;
  final bool destructive;

  /// True when confirmed; false when cancelled or dismissed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String consequence,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        consequence: consequence,
        confirmLabel: confirmLabel,
        destructive: destructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      content: Text(consequence),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
