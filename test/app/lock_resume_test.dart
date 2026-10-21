import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/expense/fakes.dart';
import '../features/lock/lock_test_app.dart';

/// SYS-03 on resume (T027, T028; SYS-03 AC1, US1-5 – US1-7, FR-043,
/// FR-044, clarification Q4, research R7).
void main() {
  ExpenseFakes withLunch() => ExpenseFakes.withDefaults()
    ..addTransaction(
      id: 'lunch',
      amount: 15550,
      category: 'food',
      note: 'Lunch with team',
    );

  Future<LockWorld> start(WidgetTester tester, {int lockAfter = 60}) async {
    final w = await pumpLockApp(
      tester,
      pin: '1234',
      expense: withLunch(),
      initial: AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: true,
        lockAfterSeconds: lockAfter,
      ),
    );
    // Cold start: SYS-03 first.
    expect(find.byType(UnlockScreen), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.byType(UnlockScreen), findsNothing);
    return w;
  }

  void setState(WidgetTester tester, List<AppLifecycleState> states) =>
      states.forEach(tester.binding.handleAppLifecycleStateChanged);

  void leave(WidgetTester tester) => setState(tester, const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]);

  void back(WidgetTester tester) => setState(tester, const [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]);

  testWidgets('SYS-03 AC1 "Correct PIN unlocks and returns the user to the '
      'screen they were on before backgrounding." (US1-5, US1-6)', (
    tester,
  ) async {
    final w = await start(tester);
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('txn_lunch')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    final detail = tester.state(find.byType(TransactionDetailScreen));

    // 30 s away with "Lock after: 1 min": no lock.
    leave(tester);
    w.expense.clock.advance(const Duration(seconds: 30));
    back(tester);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsNothing);

    // 61 s away: SYS-03 covers the detail, which stays mounted but hidden.
    leave(tester);
    w.expense.clock.advance(const Duration(seconds: 61));
    back(tester);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(TransactionDetailScreen), findsNothing);
    expect(
      find.byType(TransactionDetailScreen, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Lunch with team'), findsNothing);

    await enterPin(tester, '1234');
    expect(find.byType(UnlockScreen), findsNothing);
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    // The very same screen, not a rebuilt one.
    expect(tester.state(find.byType(TransactionDetailScreen)), same(detail));

    // Back still goes to the screen before it.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets('Q4 an unsaved EXP-02 form survives the lock with its input', (
    tester,
  ) async {
    final w = await start(tester);
    routerOf(tester).go(Routes.expenseAddPath(type: 'expense'));
    await tester.pumpAndSettle();
    final form = tester.state(find.byType(TransactionFormScreen));
    await tester.enterText(find.byType(EditableText).last, 'Taxi home');
    await tester.pump();

    leave(tester);
    w.expense.clock.advance(const Duration(minutes: 2));
    back(tester);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsOneWidget);

    await enterPin(tester, '1234');
    expect(tester.state(find.byType(TransactionFormScreen)), same(form));
    expect(find.text('Taxi home'), findsOneWidget);
  });

  testWidgets('US1-5 "Immediately" locks already when the app is hidden, so '
      'the first frame back shows SYS-03, never the content', (tester) async {
    await start(tester, lockAfter: 0);
    setState(tester, const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
    ]);
    expect(containerOf(tester).read(lockSessionProvider).locked, isTrue);
    setState(tester, const [
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    await tester.pump();
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(TransactionsScreen), findsNothing);
  });

  testWidgets('the notification shade (inactive only) never locks', (
    tester,
  ) async {
    final w = await start(tester, lockAfter: 0);
    setState(tester, const [AppLifecycleState.inactive]);
    w.expense.clock.advance(const Duration(minutes: 10));
    setState(tester, const [AppLifecycleState.resumed]);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsNothing);
  });

  testWidgets('FR-034 back while SYS-03 covers the app closes the app and '
      'pops nothing underneath (T028)', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final w = await start(tester);
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('txn_lunch')));
    await tester.pumpAndSettle();
    leave(tester);
    w.expense.clock.advance(const Duration(minutes: 2));
    back(tester);
    await tester.pumpAndSettle();

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(calls, contains('SystemNavigator.pop'));
    expect(find.byType(UnlockScreen), findsOneWidget);

    await enterPin(tester, '1234');
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    // Unlocked, back pops normally again.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets('a deep link while SYS-03 covers the app goes through SYS-03 '
      'as a route, then opens', (tester) async {
    final w = await start(tester);
    leave(tester);
    w.expense.clock.advance(const Duration(minutes: 2));
    back(tester);
    await tester.pumpAndSettle();
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(TransactionsScreen, skipOffstage: false), findsNothing);
    await enterPin(tester, '1234');
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });
}
