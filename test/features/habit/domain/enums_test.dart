import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stored as int indexes / bits: the order is a storage contract
/// (data-model.md §2, §3.1).
void main() {
  test('HabitKind indexes are pinned', () {
    expect(HabitKind.yesNo.index, 0);
    expect(HabitKind.count.index, 1);
  });

  test('ScheduleType indexes are pinned', () {
    expect(ScheduleType.daily.index, 0);
    expect(ScheduleType.specificWeekdays.index, 1);
    expect(ScheduleType.timesPerWeek.index, 2);
  });

  test('Milestone values and bits are pinned', () {
    expect(
      [for (final m in Milestone.values) m.value],
      [7, 21, 30, 50, 100, 365],
    );
    expect([for (final m in Milestone.values) m.bit], [1, 2, 4, 8, 16, 32]);
    expect(Milestone.toMask({Milestone.d7, Milestone.d30}), 5);
    expect(Milestone.fromMask(5), {Milestone.d7, Milestone.d30});
    expect(Milestone.fromMask(63), Milestone.values.toSet());
    expect(Milestone.fromMask(0), isEmpty);
  });
}
