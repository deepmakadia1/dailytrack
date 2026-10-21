import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// HAB-01 progress header (FR-016): "X of Y done" with a linear bar for
/// the selected day. Status is text, the bar only repeats it.
class ProgressHeader extends StatelessWidget {
  const new({required this.done, required this.total, super.key});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.habit_doneOfTotal(done, total),
          key: const Key('progress_header'),
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: tokens.s8),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusChip),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: tokens.s8,
              color: tokens.success,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

/// "All done for today" (US1-9).
class AllDoneBanner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Container(
      key: const Key('all_done_banner'),
      padding: EdgeInsets.all(tokens.s12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Row(
        children: [
          Icon(
            Icons.celebration,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: tokens.s8),
          Expanded(
            child: Text(
              l10n.habit_allDone,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
