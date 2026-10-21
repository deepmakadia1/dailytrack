import 'dart:ui';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/presentation/insights/habit_insight_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// HabitInsightSource (T040, research R4, R8). "Now" is Wednesday
/// 2026-10-21 10:00; the week starts Monday the 19th.
void main() {
  const source = HabitInsightSource();

  ({HabitFakes fakes, String read, String walk, String swim}) seeded() {
    final f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 10)));
    final read = f.addHabit('Read').id;
    final walk = f.addHabit('Walk').id;
    final swim = f.addHabit('Swim').id;
    f
      // 5 days through yesterday: 2 short of 7.
      ..doneRange(read, '2026-10-16', '2026-10-20')
      // 3 this week.
      ..doneRange(walk, '2026-10-19', '2026-10-21')
      // A broken 7-day streak.
      ..doneRange(swim, '2026-10-01', '2026-10-07');
    return (fakes: f, read: read, walk: walk, swim: swim);
  }

  Future<List<Insight>> evaluate(HabitFakes f, {String locale = 'en'}) async {
    final container = ProviderContainer(
      overrides: [
        ...f.overrides,
        clockProvider.overrideWithValue(f.world.clock),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(initial: AppSettings(locale: locale)),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingsProvider, (_, _) {});
    await container.read(appSettingsProvider.future);
    return await source.evaluate(container.read);
  }

  test('ruleIds are the documented order', () {
    expect(source.ruleIds, [
      'habit.nextMilestone',
      'habit.bestThisWeek',
      'habit.comeback',
    ]);
  });

  test('DSH-01 US4 localized English text and HAB-03 locations', () async {
    final s = seeded();
    final insights = await evaluate(s.fakes);
    expect(insights, [
      Insight(
        ruleId: 'habit.nextMilestone',
        text: "You're 2 days away from a 7-day streak with Read",
        location: Routes.habitDetailPath(s.read),
        semanticLabel:
            "Opens Read: You're 2 days away from a 7-day streak with Read",
      ),
      Insight(
        ruleId: 'habit.bestThisWeek',
        text: "You've done Walk 3 times this week",
        location: Routes.habitDetailPath(s.walk),
        semanticLabel: "Opens Walk: You've done Walk 3 times this week",
      ),
      Insight(
        ruleId: 'habit.comeback',
        text: 'Pick Swim up again today. Your best is 7 days.',
        location: Routes.habitDetailPath(s.swim),
        semanticLabel:
            'Opens Swim: Pick Swim up again today. Your best is 7 days.',
      ),
    ]);
  });

  test('DSH-01 US4 localized Gujarati text', () async {
    final gu = lookupAppLocalizations(const Locale('gu'));
    final insights = await evaluate(seeded().fakes, locale: 'gu');
    expect(insights.map((i) => i.text), [
      gu.habit_insightNextMilestoneDays(2, 7, 'Read'),
      gu.habit_insightBestThisWeek('Walk', 3),
      gu.habit_insightComebackDays('Swim', 7),
    ]);
  });

  test('no habits give no insights; at most one per rule id', () async {
    final empty = HabitFakes(MutableClock(DateTime(2026, 10, 21, 10)));
    expect(await evaluate(empty), isEmpty);
    final ids = [for (final i in await evaluate(seeded().fakes)) i.ruleId];
    expect(ids.toSet(), hasLength(ids.length));
  });
}
