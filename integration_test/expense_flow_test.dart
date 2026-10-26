import 'dart:async';

import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/screens/reports_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_dashboard_card.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart' as habit_enums;
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Spec §13 flow, Expense part (T112, feature 003 T104): add an expense →
/// it appears in EXP-01, on the Home card and in Reports with matching
/// totals → it survives a restart. Plus budget alerts and a recurring rule.
/// Real database, as `main()` wires it; notifications and the background
/// scheduler are recording fakes so the flow is deterministic.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wipeData() async {
    final db = AppDatabase.open();
    await db.transaction(() async {
      // Reverse order: transactions reference categories and accounts.
      for (final table in db.allTables.toList().reversed) {
        await db.delete(table).go();
      }
    });
    await db.close();
  }

  late _RecordingNotifications notifications;

  Future<void> launchApp(WidgetTester tester) async {
    notifications = _RecordingNotifications();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...productionOverrides(),
          notificationServiceProvider.overrideWithValue(notifications),
          backgroundSchedulerProvider.overrideWithValue(_NoBackground()),
        ],
        child: const DailyTrackApp(),
      ),
    );
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (find.byType(SplashScreen).evaluate().isNotEmpty &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('add an expense → EXP-01 and the Home card show it → it '
      'survives a restart', (tester) async {
    await wipeData();
    await launchApp(tester);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();

    await tester.tap(navLabel('Expenses'));
    await tester.pumpAndSettle();
    // A fresh install shows the empty state; its button is the one primary
    // action (the FAB steps aside, §15.1).
    await tester.tap(find.widgetWithText(FilledButton, 'Add expense'));
    await tester.pumpAndSettle();
    for (final d in ['2', '5', '0']) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tester.tap(find.byKey(const Key('save_transaction')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('−₹250.00'), findsWidgets);

    // §13: it appears in Reports with the same totals as the strip.
    await tester.tap(find.byKey(const Key('expenses_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_reports')));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('report_net')),
        matching: find.text('−₹250.00'),
      ),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(navLabel('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseDashboardCard), findsOneWidget);
    expect(find.text('₹250.00'), findsNWidgets(2), reason: 'today and month');

    await closeApp(tester);
    await launchApp(tester);
    expect(find.text('₹250.00'), findsNWidgets(2));
    await closeApp(tester);
  });

  ProviderContainer homeContainerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  // Feature 006 (T061): the same flow through DSH-01's + menu, then a habit
  // check-in from Home.
  testWidgets('DSH-01 + → "Add expense" → Home shows it in Spent today and '
      'Recent transactions; a Home check-in raises the streak flame', (
    tester,
  ) async {
    await wipeData();
    await launchApp(tester);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home_quick_add_expense_quickAdd')));
    await tester.pumpAndSettle();
    for (final d in ['2', '5', '0']) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tester.tap(find.byKey(const Key('save_transaction')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('spent_today')),
        matching: find.text('₹250.00'),
      ),
      findsOneWidget,
    );
    final recentRow = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('recent_row_'),
    );
    expect(recentRow, findsOneWidget);
    expect(
      find.descendant(of: recentRow, matching: find.text('−₹250.00')),
      findsOneWidget,
    );

    final habit = await homeContainerOf(tester)
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
            startDate: LocalDate.fromDateTime(DateTime.now()),
          ),
        );
    await tester.pumpAndSettle();
    final flame = find.descendant(
      of: find.byKey(const Key('home_badge_habit')),
      matching: find.byKey(const Key('streak_flame_count')),
    );
    expect(tester.widget<Text>(flame).data, '0');
    await tester.tap(find.byKey(ValueKey('home_check_${habit.id}')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(flame).data, '1');
    await closeApp(tester);
  });

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  Future<void> addExpense(WidgetTester tester, String amount) async {
    await tester.tap(find.byKey(const Key('add_transaction')));
    await tester.pumpAndSettle();
    for (final d in amount.split('')) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tester.tap(find.byKey(const Key('save_transaction')));
    await tester.pumpAndSettle();
    // Let the background budget check finish.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets('a ₹1,000 Food budget alerts once at 80% and once at 100%', (
    tester,
  ) async {
    await wipeData();
    await launchApp(tester);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();
    await tester.tap(navLabel('Expenses'));
    await tester.pumpAndSettle();

    // Set the budget through EXP-08 / EXP-09.
    await tester.tap(find.byKey(const Key('expenses_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_budgets')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Food'));
    for (final d in ['1', '0', '0', '0']) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('save_budget')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // EXP-01 shows the empty state first, so add through EXP-02 directly.
    await tester.tap(find.widgetWithText(FilledButton, 'Add expense'));
    await tester.pumpAndSettle();
    for (final d in ['8', '5', '0']) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tester.tap(find.byKey(const Key('save_transaction')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(notifications.shown, hasLength(1));
    expect(notifications.shown.single.title, 'Food budget at 85%');

    await addExpense(tester, '200');
    expect(notifications.shown, hasLength(2));
    expect(notifications.shown.last.title, 'Food budget used up');
    await addExpense(tester, '50');
    expect(notifications.shown, hasLength(2), reason: 'once per threshold');
    await closeApp(tester);
  });

  testWidgets('a monthly rule dated 3 months ago creates 4 linked rows on app '
      'open, shown with the repeat icon', (tester) async {
    await wipeData();
    await launchApp(tester);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();

    final c = containerOf(tester);
    final accounts = await c
        .read(accountRepositoryProvider)
        .watchPickable()
        .first;
    final food =
        (await c
                .read(categoryRepositoryProvider)
                .watchPickable(CategoryType.expense)
                .first)
            .first;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month - 3, now.day, 8);
    await c
        .read(recurringRuleRepositoryProvider)
        .createWithFirstOccurrence(
          TransactionDraft(
            type: TxnType.expense,
            amountMinor: 150000,
            accountId: accounts.first.id,
            categoryId: food.id,
            paymentMode: PaymentMode.upi,
            note: 'Rent',
            occurredAt: first.toUtc(),
          ),
          const RepeatSettings(),
        );

    // A restart is an app open: the generator catches up.
    await closeApp(tester);
    await launchApp(tester);
    final db = AppDatabase.open();
    final rows = await (db.select(
      db.transactions,
    )..where((t) => t.recurringRuleId.isNotNull())).get();
    await db.close();
    expect(rows, hasLength(4));

    await tester.tap(navLabel('Expenses'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.repeat), findsWidgets);
    await closeApp(tester);
  });
}

/// Records notifications instead of showing them.
final class _RecordingNotifications implements NotificationService {
  final List<AppNotification> shown = [];
  final _taps = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> canNotify() async => true;

  @override
  Future<void> show(AppNotification notification) async =>
      shown.add(notification);

  @override
  Future<void> cancelByTag(String tag) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<String?> launchPayload() async => null;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> schedule(ScheduledNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<bool> requestExactAlarms() async => true;

  @override
  Stream<NotificationActionEvent> get actions => const Stream.empty();

  @override
  Future<bool> refreshTimeZone() async => true;
}

/// No WorkManager in the integration run.
final class _NoBackground implements BackgroundScheduler {
  @override
  Future<void> ensureDaily(String uniqueName) async {}

  @override
  Future<void> enqueueOnce(
    String uniqueName, {
    NetworkRequirement network = NetworkRequirement.none,
  }) async {}

  @override
  Future<void> ensurePeriodic(
    String uniqueName, {
    required Duration every,
    NetworkRequirement network = NetworkRequirement.none,
  }) async {}

  @override
  Future<void> cancel(String uniqueName) async {}
}
