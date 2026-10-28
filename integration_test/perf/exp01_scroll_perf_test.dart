import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_harness.dart';
import 'perf_support.dart';

/// §13 "List scrolling: 60 fps with 10,000 transactions" on a device
/// (feature 012 T045, research R10). Seeds 10,000 transactions, opens
/// EXP-01, and flings it top to bottom while Flutter records frame timings.
/// Fails above 1.2% slow frames; prints Pass at 1% or below and Open
/// between (clarification Q4). Numbers are only meaningful in profile mode:
///
/// flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart
///   --target integration_test/perf/exp01_scroll_perf_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  testWidgets('EXP-01 scrolls at 60 fps with 10,000 transactions', (
    tester,
  ) async {
    final world = HarnessWorld();
    await launch(tester, world);
    await startAsGuest(tester);
    await seed10k(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Expenses'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
    final list = find.byKey(const Key('transactions_list'));
    expect(list, findsOneWidget);

    await binding.watchPerformance(() async {
      for (var i = 0; i < 15; i++) {
        await tester.fling(list, const Offset(0, -1500), 8000);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 5; i++) {
        await tester.fling(list, const Offset(0, 1500), 8000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'exp01_scroll');

    final summary = Map<String, dynamic>.from(
      binding.reportData!['exp01_scroll'] as Map,
    );
    final frames = summary['frame_count'] as int;
    final slow =
        (summary['missed_frame_build_budget_count'] as int) +
        (summary['missed_frame_rasterizer_budget_count'] as int);
    final share = frames == 0 ? 0.0 : slow / frames * 100;
    final result = share <= 1.0
        ? 'Pass'
        : share <= 1.2
        ? 'Open'
        : 'Fail';
    binding.reportData!['exp01_scroll_result'] = {
      'frames': frames,
      'slow_frames': slow,
      'slow_percent': share,
      'result': result,
    };
    debugPrint(
      'EXP-01 scroll: $slow of $frames frames over budget '
      '(${share.toStringAsFixed(2)}%) → $result',
    );
    expect(frames, greaterThan(0));
    expect(share, lessThanOrEqualTo(1.2), reason: 'slow frames: $result');
    await closeApp(tester);
  });
}
