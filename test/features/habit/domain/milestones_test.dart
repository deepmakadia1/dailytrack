import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/streaks/milestones.dart';
import 'package:flutter_test/flutter_test.dart';

/// selectNewMilestones (FR-044, spec US3): every passed milestone is
/// recorded; only the highest new one is shown.
void main() {
  test('reaching 7 shows d7', () {
    final r = selectNewMilestones(7, {});
    expect(r.toSet, {Milestone.d7});
    expect(r.show, Milestone.d7);
  });

  test('below 7 shows nothing', () {
    final r = selectNewMilestones(6, {});
    expect(r.toSet, isEmpty);
    expect(r.show, isNull);
  });

  test('d7 already celebrated → nothing at 7 or 8', () {
    for (final streak in [7, 8, 20]) {
      final r = selectNewMilestones(streak, {Milestone.d7});
      expect(r.toSet, isEmpty, reason: '$streak');
      expect(r.show, isNull, reason: '$streak');
    }
  });

  test('a jump from 5 to 35 records d7, d21, d30 and shows d30', () {
    final r = selectNewMilestones(35, {});
    expect(r.toSet, {Milestone.d7, Milestone.d21, Milestone.d30});
    expect(r.show, Milestone.d30);
  });

  test('a broken and rebuilt streak with d7 celebrated shows nothing', () {
    // 7 → broken → 0 … 7 again.
    expect(selectNewMilestones(0, {Milestone.d7}).show, isNull);
    expect(selectNewMilestones(7, {Milestone.d7}).show, isNull);
  });

  test('a rebuilt streak that passes a new milestone shows only that one', () {
    final r = selectNewMilestones(21, {Milestone.d7});
    expect(r.toSet, {Milestone.d21});
    expect(r.show, Milestone.d21);
  });

  test('365 shows d365 and records every milestone', () {
    final r = selectNewMilestones(365, {});
    expect(r.toSet, Milestone.values.toSet());
    expect(r.show, Milestone.d365);
    final later = selectNewMilestones(400, Milestone.values.toSet());
    expect(later.show, isNull);
  });

  test('a gap in the celebrated set is filled without showing a lower one', () {
    final r = selectNewMilestones(60, {Milestone.d7, Milestone.d30});
    expect(r.toSet, {Milestone.d21, Milestone.d50});
    expect(r.show, Milestone.d50);
  });
}
