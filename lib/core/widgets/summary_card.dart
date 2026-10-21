import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Card with a title, a main value, an optional progress indicator and an
/// optional action chip (§15.4). Flat, on a tonal surface.
class SummaryCard extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    super.key,
    this.leading,
    this.progress,
    this.actionChip,
  });

  final String title;
  final Widget value;
  final Widget? leading;
  final Widget? progress;
  final Widget? actionChip;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leading != null) ...[leading!, SizedBox(width: tokens.s12)],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                ?actionChip,
              ],
            ),
            SizedBox(height: tokens.s8),
            DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium,
              child: value,
            ),
            if (progress != null) ...[SizedBox(height: tokens.s12), progress!],
          ],
        ),
      ),
    );
  }
}
