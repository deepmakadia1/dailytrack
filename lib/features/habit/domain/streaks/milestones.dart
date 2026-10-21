import 'package:dailytrack/features/habit/domain/entities/milestone.dart';

/// Milestones a streak of [currentStreak] reaches that were never
/// celebrated for the habit (FR-044). All of them are recorded; only the
/// highest is shown, so one back-fill that passes several shows one sheet.
({Set<Milestone> toSet, Milestone? show}) selectNewMilestones(
  int currentStreak,
  Set<Milestone> celebrated,
) {
  final toSet = {
    for (final m in Milestone.values)
      if (m.value <= currentStreak && !celebrated.contains(m)) m,
  };
  Milestone? show;
  for (final m in toSet) {
    if (show == null || m.value > show.value) show = m;
  }
  return (toSet: toSet, show: show);
}
