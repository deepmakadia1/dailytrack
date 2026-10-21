import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Plain-language error with a next step (§15.6). No codes or stack traces.
class ErrorState extends StatelessWidget {
  const new({
    required this.message,
    required this.onRetry,
    super.key,
    this.retryLabel,
    this.secondaryAction,
  });

  final String message;
  final VoidCallback onRetry;

  /// Defaults to "Try again" from the ARB files.
  final String? retryLabel;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: tokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: tokens.s48,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: tokens.s16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.s24),
            FilledButton(
              onPressed: onRetry,
              child: Text(
                retryLabel ?? AppLocalizations.of(context).common_tryAgain,
              ),
            ),
            if (secondaryAction != null) ...[
              SizedBox(height: tokens.s8),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
