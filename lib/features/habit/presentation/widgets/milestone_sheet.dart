import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/share_capture.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/widgets/streak_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// File name of the shared streak image.
const String streakShareFileName = 'streak.png';

/// The milestone celebration (US3, FR-044, FR-045). Shown once per
/// milestone per habit: callers show it only for a `DayWriteResult`
/// carrying a milestone, which the repository hands out once.
Future<void> showMilestoneSheet(
  BuildContext context, {
  required Habit habit,
  required Milestone milestone,
  required StreakUnit unit,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<void>(
    context,
    title: switch (unit) {
      StreakUnit.days => l10n.habit_milestoneTitleDays(milestone.value),
      StreakUnit.weeks => l10n.habit_milestoneTitleWeeks(milestone.value),
    },
    child: MilestoneSheet(habit: habit, milestone: milestone, unit: unit),
  );
}

/// Body of the milestone sheet: the streak card (also the image that is
/// shared), encouragement, "Share streak", and "Close".
class MilestoneSheet extends ConsumerStatefulWidget {
  const new({
    required this.habit,
    required this.milestone,
    required this.unit,
    super.key,
  });

  final Habit habit;
  final Milestone milestone;
  final StreakUnit unit;

  @override
  ConsumerState<MilestoneSheet> createState() => _MilestoneSheetState();
}

class _MilestoneSheetState extends ConsumerState<MilestoneSheet> {
  final GlobalKey _card = GlobalKey();
  var _sharing = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final sharer = ref.read(imageSharerProvider);
    setState(() => _sharing = true);
    try {
      final png = await captureBoundaryPng(_card);
      if (png == null) throw StateError('streak card not rendered');
      await sharer.sharePng(png, fileName: streakShareFileName);
    } on Object {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.habit_shareError)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RepaintBoundary(
              key: _card,
              child: StreakShareCard(
                habit: widget.habit,
                streak: widget.milestone.value,
                unit: widget.unit,
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.s16),
        Text(
          l10n.habit_milestoneBody,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s16),
        FilledButton.icon(
          key: const Key('share_streak'),
          onPressed: _sharing ? null : () => unawaited(_share()),
          icon: const Icon(Icons.share),
          label: Text(l10n.habit_shareStreak),
        ),
        SizedBox(height: tokens.s8),
        TextButton(
          key: const Key('milestone_close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.habit_close),
        ),
        SizedBox(height: tokens.s8),
      ],
    );
  }
}
