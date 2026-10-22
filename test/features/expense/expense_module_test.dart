import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/expense/data/backup/expense_backup_section.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import 'expense_test_app.dart';
import 'fakes.dart';

/// ExpenseModule registration (US6, T110, FR-029–FR-032).
void main() {
  const module = ExpenseModule();

  group('SET-01 onNotificationSettingsChanged (feature 007 T020)', () {
    Future<FakeBudgetAlertNotifier> run({required bool allowed}) async {
      final notifier = FakeBudgetAlertNotifier();
      final gate = FakeNotificationGate()..allowed = allowed;
      final container = ProviderContainer(
        overrides: [
          budgetAlertNotifierProvider.overrideWithValue(notifier),
          notificationGateProvider.overrideWithValue(gate),
        ],
      );
      addTearDown(container.dispose);
      await module.onNotificationSettingsChanged(container.read);
      return notifier;
    }

    test(
      'removes shown budget alerts once they are no longer allowed',
      () async {
        expect((await run(allowed: false)).cancelAllCalls, 1);
      },
    );

    test('keeps them while budget alerts are allowed', () async {
      expect((await run(allowed: true)).cancelAllCalls, 0);
    });
  });

  test(
    'quick adds open EXP-02 as an expense, then as income; backup is the '
    'expense section (feature 008); seeders are the first-launch defaults',
    () {
      final [expense, income] = module.quickAddActions();
      expect(expense.labelKey, 'expense_quickAdd');
      expect(expense.location, '/expenses/add?type=expense');
      expect(income.labelKey, 'expense_quickAddIncome');
      expect(income.location, '/expenses/add?type=income');
      expect(module.backupSection(), isA<ExpenseBackupSection>());
      expect(module.seeders.single, isA<ExpenseDefaultsSeeder>());
    },
  );

  test(
    'every route lives under /expenses; static segments come before :id',
    () {
      final root = module.routes.single as GoRoute;
      expect(root.path, module.rootPath);
      final children = [for (final r in root.routes) (r as GoRoute).path];
      expect(children, [
        'add',
        'categories',
        'accounts',
        'budgets',
        'recurring',
        'reports',
        ':id',
      ]);
      expect(children.indexOf(':id'), children.length - 1);
    },
  );

  testWidgets('US6-5 the quick-add location opens EXP-02 as an expense', (
    tester,
  ) async {
    await pumpExpenseApp(tester, location: Routes.home);
    routerOf(tester).go(module.quickAddActions().first.location);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
  });

  testWidgets('DSH-01 US3-2 "Add income" opens EXP-02 as income', (
    tester,
  ) async {
    await pumpExpenseApp(tester, location: Routes.home);
    routerOf(tester).go(module.quickAddActions()[1].location);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.text('Save income'), findsOneWidget);
  });

  testWidgets('rule 5: with Expense disabled every expense route goes Home', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(
          onboardingDone: true,
          enabledModules: ['habit'],
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    for (final location in [
      Routes.expenses,
      Routes.expenseAdd,
      Routes.expenseCategories,
      Routes.expenseAccounts,
      Routes.expenseDetailPath('x'),
      Routes.expenseEditPath('x'),
    ]) {
      container.read(appRouterProvider).go(location);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget, reason: location);
      expect(find.byType(TransactionFormScreen), findsNothing);
    }
  });
}
