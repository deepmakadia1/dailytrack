import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

enum ProgressStatus { onTrack, near, over }

/// Below 80% is on track, 80–100% is near the limit, above 100% is over.
ProgressStatus progressStatusOf(double ratio) => ratio > 1
    ? ProgressStatus.over
    : ratio >= 0.8
    ? ProgressStatus.near
    : ProgressStatus.onTrack;

Color _statusColor(AppTokens tokens, double ratio) =>
    switch (progressStatusOf(ratio)) {
      ProgressStatus.onTrack => tokens.success,
      ProgressStatus.near => tokens.warning,
      ProgressStatus.over => tokens.expense,
    };

/// Budget/goal progress bar (§15.4). Status is never shown by color alone:
/// it always has a text [label], plus an icon when over.
class ProgressBarStatus extends StatelessWidget {
  const new({required this.ratio, required this.label, super.key});

  final double ratio;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final color = _statusColor(tokens, ratio);
    final over = progressStatusOf(ratio) == ProgressStatus.over;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (over) ...[
              Icon(
                Icons.error_outline,
                color: color,
                size: tokens.chipIconSize,
              ),
              SizedBox(width: tokens.s4),
            ],
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          ],
        ),
        SizedBox(height: tokens.s4),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusChip),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1).toDouble(),
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            minHeight: tokens.s8,
          ),
        ),
      ],
    );
  }
}

/// Circular variant of [ProgressBarStatus], with the label underneath.
class ProgressRing extends StatelessWidget {
  const new({required this.ratio, required this.label, super.key});

  final double ratio;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final color = _statusColor(tokens, ratio);
    final over = progressStatusOf(ratio) == ProgressStatus.over;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: tokens.s48,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: ratio.clamp(0, 1).toDouble(),
                color: color,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                strokeWidth: tokens.s4,
              ),
              if (over)
                Icon(
                  Icons.error_outline,
                  color: color,
                  size: tokens.chipIconSize,
                ),
            ],
          ),
        ),
        SizedBox(height: tokens.s4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
