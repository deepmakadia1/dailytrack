import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:flutter_test/flutter_test.dart';

/// The glance model (feature 008 T009, data-model §6).
void main() {
  GlanceHabit habit(String id, {int value = 0, int target = 1}) => GlanceHabit(
    id: id,
    name: id,
    kind: GlanceHabitKind.yesNo,
    value: value,
    target: target,
    colorHex: '#2B7ACA',
  );

  test('budget percent and level: under < 80 ≤ warning ≤ 100 < over', () {
    GlanceBudget b(int spent) =>
        GlanceBudget(limitMinor: 1000000, spentMinor: spent);
    expect((b(620000).percent, b(620000).level), (62, GlanceLevel.under));
    expect(b(799999).level, GlanceLevel.under);
    expect(b(800000).level, GlanceLevel.warning);
    expect((b(1000000).percent, b(1000000).level), (100, GlanceLevel.warning));
    expect((b(1000001).percent, b(1000001).level), (100, GlanceLevel.over));
    expect(b(1500000).percent, 150);
  });

  test('a habit is done when its value reaches the target', () {
    expect(habit('a', value: 1).done, isTrue);
    expect(habit('a').done, isFalse);
    expect(habit('a', value: 12, target: 20).done, isFalse);
    expect(habit('a', value: 20, target: 20).done, isTrue);
  });

  test('the builder keeps at most 4 habits, in order', () {
    final b = GlanceBuilder(DateTime(2026, 10, 21))
      ..setHabits(
        GlanceHabits(
          scheduled: 6,
          done: 1,
          items: [for (final id in 'abcdef'.split('')) habit(id)],
        ),
      );
    final g = b.build();
    expect([for (final h in g.habits!.items) h.id], ['a', 'b', 'c', 'd']);
    expect((g.habits!.scheduled, g.habits!.done), (6, 1));
  });

  test('with no contributions, spend and habits are null', () {
    final g = GlanceBuilder(DateTime(2026, 10, 21)).build();
    expect(g.spend, isNull);
    expect(g.habits, isNull);
    expect(g.date, DateTime(2026, 10, 21));
  });
}
