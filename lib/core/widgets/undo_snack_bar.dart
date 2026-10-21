import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// "Deleted · Undo" snackbar shown after a delete (§15.4, §15.6).
abstract final class UndoSnackBar {
  static const Duration duration = Duration(seconds: 5);

  /// Pass [messenger] (usually `rootMessengerKey.currentState`) when the
  /// calling screen is about to close, so the snackbar outlives it and
  /// shows on the screen underneath (research R12).
  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    ScaffoldMessengerState? messenger,
  }) {
    (messenger ?? ScaffoldMessenger.of(context))
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          // A snackbar with an action stays up by default; undo must expire.
          persist: false,
          action: SnackBarAction(
            label: AppLocalizations.of(context).common_undo,
            onPressed: onUndo,
          ),
        ),
      );
  }
}
