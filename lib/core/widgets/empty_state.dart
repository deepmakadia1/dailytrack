import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Explains what belongs on an empty screen and offers one action (§15.6).
class EmptyState extends StatelessWidget {
  const new({
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

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
            if (illustration != null) ...[
              illustration!,
              SizedBox(height: tokens.s16),
            ],
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: tokens.s8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: tokens.s24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
