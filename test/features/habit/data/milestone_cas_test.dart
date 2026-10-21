import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_db_fixture.dart';

/// HAB-01 criterion "Milestone sheet appears once per milestone per habit"
/// (data level, research R8, data-model §7 invariant 5).
void main() {
  test(
    'two concurrent writes that both reach 7: exactly one celebrates d7',
    () async {
      final t = await HabitDb.open();
      final h = await t.habit(start: '2026-10-15');
      for (var day = 15; day <= 20; day++) {
        await t.entries.apply(h.id, LocalDate(2026, 10, day), const Toggle());
      }

      // Two screens (HAB-01 and the Home card) write today at the same time.
      final results = await Future.wait([
        t.entries.apply(h.id, t.today, const SetValue(1)),
        t.entries.apply(h.id, t.today, const SetValue(1)),
      ]);

      expect([for (final r in results) r.summary.current], [7, 7]);
      expect([for (final r in results) r.milestone].where((m) => m != null), [
        Milestone.d7,
      ]);
      final row = await (t.db.select(
        t.db.habits,
      )..where((x) => x.id.equals(h.id))).getSingle();
      expect(row.celebratedMilestones, Milestone.d7.bit);
    },
  );

  test('concurrent writes on two habits each celebrate their own', () async {
    final t = await HabitDb.open();
    final a = await t.habit(name: 'A', start: '2026-10-15');
    final b = await t.habit(name: 'B', start: '2026-10-15');
    for (var day = 15; day <= 20; day++) {
      await t.entries.apply(a.id, LocalDate(2026, 10, day), const Toggle());
      await t.entries.apply(b.id, LocalDate(2026, 10, day), const Toggle());
    }
    final results = await Future.wait([
      t.entries.apply(a.id, t.today, const Toggle()),
      t.entries.apply(b.id, t.today, const Toggle()),
    ]);
    expect(
      [for (final r in results) r.milestone],
      [Milestone.d7, Milestone.d7],
    );
  });
}
