import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart' as habit_enums;
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_harness.dart';
import 'perf_support.dart';

/// §13 "Save transaction / check-in: < 100 ms DB write" on a device
/// (feature 012 T046, research R10). With 10,000 transactions on the
/// device database, times 50 transaction saves and 50 habit check-ins
/// through the real repositories. The p95 of each must be under 100 ms;
/// this target always blocks a release (clarification Q4).
///
/// flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart
///   --target integration_test/perf/write_perf_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  Map<String, double> stats(List<int> micros) => {
    'p50_ms': percentile(micros, 50) / 1000,
    'p95_ms': percentile(micros, 95) / 1000,
    'max_ms': percentile(micros, 100) / 1000,
  };

  testWidgets('saves and check-ins write in under 100 ms (p95) with 10,000 '
      'transactions', (tester) async {
    final world = HarnessWorld();
    await launch(tester, world);
    await startAsGuest(tester);
    await seed10k(tester);

    final container = containerOf(tester);
    final db = container.read(appDatabaseProvider);
    final account = await (db.select(db.accounts)..limit(1)).getSingle();
    final food =
        await (db.select(db.categories)
              ..where((c) => c.type.equalsValue(CategoryType.expense))
              ..limit(1))
            .getSingle();

    final saves = <int>[];
    final transactions = container.read(transactionRepositoryProvider);
    for (var i = 0; i < 50; i++) {
      final sw = Stopwatch()..start();
      await transactions.create(
        TransactionDraft(
          type: TxnType.expense,
          amountMinor: 1000 + i,
          accountId: account.id,
          categoryId: food.id,
          paymentMode: PaymentMode.upi,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
      saves.add(sw.elapsedMicroseconds);
    }

    final habit = await container
        .read(habitRepositoryProvider)
        .create(
          HabitDraft(
            name: 'Read',
            iconKey: 'menu_book',
            colorHex: '#2B7ACA',
            kind: habit_enums.HabitKind.yesNo,
            schedule: const HabitSchedule(
              type: habit_enums.ScheduleType.daily,
              target: 1,
            ),
            startDate: LocalDate.fromDateTime(
              DateTime.now().subtract(const Duration(days: 60)),
            ),
          ),
        );
    final entries = container.read(habitEntryRepositoryProvider);
    final today = LocalDate.fromDateTime(DateTime.now());
    final checkIns = <int>[];
    for (var i = 0; i < 50; i++) {
      final sw = Stopwatch()..start();
      await entries.apply(habit.id, today, const Toggle());
      checkIns.add(sw.elapsedMicroseconds);
    }

    final save = stats(saves);
    final checkIn = stats(checkIns);
    binding.reportData = {
      ...?binding.reportData,
      'writes': {'save': save, 'check_in': checkIn},
    };
    debugPrint('Save transaction: $save');
    debugPrint('Habit check-in: $checkIn');
    expect(save['p95_ms'], lessThan(100));
    expect(checkIn['p95_ms'], lessThan(100));
    await closeApp(tester);
  });
}
