import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// HAB-03 2×2 stat tiles (US5-1): current streak, best streak, completion
/// rate (last 30 days, scheduled days only), total completions.
class StatTiles extends StatelessWidget {
  const new({required this.summary, super.key});

  final StreakSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final rate = summary.completionRate;
    final tiles = [
      (
        const Key('stat_current'),
        l10n.habit_statCurrent,
        streakLength(l10n, summary.current, summary.unit),
      ),
      (
        const Key('stat_best'),
        l10n.habit_statBest,
        streakLength(l10n, summary.best, summary.unit),
      ),
      (
        const Key('stat_rate'),
        l10n.habit_statRate,
        rate == null ? l10n.habit_rateNone : l10n.habit_rateValue(rate),
      ),
      (
        const Key('stat_total'),
        l10n.habit_statTotal,
        '${summary.totalCompletions}',
      ),
    ];
    Widget row(int i) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _Tile(entry: tiles[i])),
          SizedBox(width: tokens.cardGap),
          Expanded(child: _Tile(entry: tiles[i + 1])),
        ],
      ),
    );
    return Column(
      children: [
        row(0),
        SizedBox(height: tokens.cardGap),
        row(2),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const new({required this.entry});

  final (Key, String, String) entry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final (key, label, value) = entry;
    return Card(
      margin: EdgeInsets.zero,
      child: Semantics(
        container: true,
        child: Padding(
          padding: EdgeInsets.all(tokens.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              SizedBox(height: tokens.s4),
              Text(value, key: key, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
