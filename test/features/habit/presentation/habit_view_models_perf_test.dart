@Tags(['perf'])
library;

import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:dailytrack/features/habit/presentation/widgets/year_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_wrapper.dart';
import '../domain/history_builder.dart';

/// HAB-03 criterion "Heatmap renders 365 days in under 100 ms (precompute
/// in the controller)" (T077, FR-031). Host stand-ins for the device check.
void main() {
  final wed = engineAt('2026-10-21');

  int timeMs(void Function() body) {
    final watch = Stopwatch()..start();
    body();
    return watch.elapsedMilliseconds;
  }

  test('building the view model for 365 days is under 100 ms', () {
    final h = history(
      start: '2025-10-22',
      done: span('2025-10-22', '2026-10-21'),
    );
    late HabitDetailViewModel vm;
    expect(timeMs(() => vm = buildDetailViewModel(wed, h)), lessThan(100));
    expect(vm.heatmap.done, 365);
  });

  test('building it for 5 years is under 100 ms', () {
    final h = history(
      start: '2021-10-22',
      done: span('2021-10-22', '2026-10-21'),
    );
    expect(timeMs(() => buildDetailViewModel(wed, h)), lessThan(100));
  });

  testWidgets('pumping the heatmap with a prebuilt model is under 100 ms', (
    tester,
  ) async {
    final h = history(
      start: '2025-10-22',
      done: span('2025-10-22', '2026-10-21'),
    );
    final vm = buildDetailViewModel(wed, h);
    // Warm up the app shell, theme, localizations, and text layout first
    // (as in the running app), so only the heatmap's build, layout, and
    // paint are timed.
    await tester.pumpWidget(
      themed(
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ),
    );
    // Median of fresh builds (a new key each time), like the other perf
    // proxies, so a busy host does not decide the result.
    final times = <int>[];
    for (var i = 0; i < 9; i++) {
      final watch = Stopwatch()..start();
      await tester.pumpWidget(
        themed(
          YearHeatmap(
            key: ValueKey(i),
            model: vm.heatmap,
            color: const Color(0xFF1D8787),
            boundaryKey: GlobalKey(),
            onShare: () {},
          ),
        ),
      );
      times.add(watch.elapsedMilliseconds);
    }
    expect(find.byKey(const Key('heatmap_paint')), findsOneWidget);
    times.sort();
    expect(times[times.length ~/ 2], lessThan(100), reason: 'median $times');
  });
}
