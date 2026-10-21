import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// HAB-03 year heatmap (US5-4, FR-031): one `CustomPaint` over the
/// controller-built 53×7 model, intensity in the habit color, a semantics
/// summary, and a per-month text list for screen readers. [boundaryKey]
/// wraps the painted grid so it can be shared as an image.
class YearHeatmap extends StatelessWidget {
  const new({
    required this.model,
    required this.color,
    required this.boundaryKey,
    required this.onShare,
    super.key,
  });

  final HeatmapModel model;
  final Color color;
  final GlobalKey boundaryKey;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.habit_heatmapTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('share_heatmap'),
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: Text(l10n.habit_shareHeatmap),
            ),
          ],
        ),
        Semantics(
          label: l10n.habit_heatmapSummary(model.done, model.total),
          container: true,
          child: RepaintBoundary(
            key: boundaryKey,
            child: ColoredBox(
              color: scheme.surface,
              child: AspectRatio(
                aspectRatio: heatmapColumns / heatmapRows,
                child: CustomPaint(
                  key: const Key('heatmap_paint'),
                  painter: HeatmapPainter(
                    model: model,
                    color: color,
                    empty: scheme.surfaceContainerHighest,
                    freeze: scheme.primary,
                    gap: tokens.s4 / 4,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Screen readers get the months as text (research R13).
        Semantics(
          container: true,
          child: Column(
            children: [
              for (final m in model.months)
                Semantics(
                  label: l10n.habit_heatmapMonth(
                    DateFormat.yMMMM(l10n.localeName)
                        .format(DateTime(m.year, m.month)),
                    m.done,
                    m.total,
                  ),
                  child: const SizedBox(width: 1, height: 1),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Paints the heatmap cells. Freeze days use the primary color at low
/// intensity; days without progress use the empty color.
class HeatmapPainter extends CustomPainter {
  const new({
    required this.model,
    required this.color,
    required this.empty,
    required this.freeze,
    required this.gap,
  });

  final HeatmapModel model;
  final Color color;
  final Color empty;
  final Color freeze;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / heatmapColumns;
    final paint = Paint();
    for (var c = 0; c < model.columns.length; c++) {
      final column = model.columns[c];
      for (var r = 0; r < column.length; r++) {
        final day = column[r];
        if (day == null) continue;
        paint.color = day.status == DayStatus.freeze
            ? freeze.withValues(alpha: 0.4)
            : day.intensity == 0
            ? empty
            : color.withValues(alpha: day.intensity / 4);
        canvas.drawRect(
          Rect.fromLTWH(c * cell, r * cell, cell - gap, cell - gap),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(HeatmapPainter old) =>
      old.model != model || old.color != color || old.empty != empty;
}
