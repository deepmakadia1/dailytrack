import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/usecases/habit_day_writer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// HabitDayWriter (T039, research R8, FR-039). Today is Wednesday
/// 2026-10-21; weeks start on Monday 19 (or Sunday 18).
void main() {
  late HabitFakes f;
  late String id;

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 10)));
    id = f.addHabit('Read').id;
  });

  HabitDayWriter writer({int firstDayOfWeek = 1}) => HabitDayWriter(
    f.entries,
    f.scheduler,
    f.clock,
    firstDayOfWeek: firstDayOfWeek,
  );

  test('a write in the current week reconciles that habit once', () async {
    final r = await writer().write(
      id,
      LocalDate.fromKey('2026-10-21'),
      const Toggle(),
    );
    expect(r.summary.current, 1);
    expect(f.scheduler.calls, ['reconcile:$id']);
    await writer().write(id, LocalDate.fromKey('2026-10-19'), const Toggle());
    expect(f.scheduler.calls, ['reconcile:$id', 'reconcile:$id']);
  });

  test('a back-fill in an earlier week does not reconcile', () async {
    await writer().write(id, LocalDate.fromKey('2026-10-18'), const Toggle());
    expect(f.scheduler.calls, isEmpty);
    expect(f.entry(id, '2026-10-18')?.value, 1);
  });

  test('the current week follows the first day of the week', () async {
    // Sunday 18 is in the current week when weeks start on Sunday.
    await writer(firstDayOfWeek: 7)
        .write(id, LocalDate.fromKey('2026-10-18'), const Toggle());
    expect(f.scheduler.calls, ['reconcile:$id']);
  });

  test('repository errors propagate without reconciling', () async {
    await expectLater(
      writer().write(id, LocalDate.fromKey('2026-10-22'), const Toggle()),
      throwsA(isA<DayNotEditable>()),
    );
    await expectLater(
      writer().write('nope', LocalDate.fromKey('2026-10-21'), const Toggle()),
      throwsA(isA<HabitNotFound>()),
    );
    expect(f.scheduler.calls, isEmpty);
  });

  test('a failing reconcile never fails the write', () async {
    final w = HabitDayWriter(f.entries, _ThrowingScheduler(), f.clock);
    final r = await w.write(
      id,
      LocalDate.fromKey('2026-10-21'),
      const Toggle(),
    );
    expect(r.summary.current, 1);
  });
}

final class _ThrowingScheduler extends FakeHabitReminderScheduler {
  @override
  Future<void> reconcile(String habitId) async => throw StateError('boom');
}
