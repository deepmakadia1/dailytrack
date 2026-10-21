import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// An inline validation message under a form field: an icon AND text, never
/// color alone (§15.2), announced by screen readers when it appears.
class FieldError extends StatelessWidget {
  const new(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: EdgeInsets.only(top: tokens.s4),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: color, size: tokens.chipIconSize),
            SizedBox(width: tokens.s4),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
