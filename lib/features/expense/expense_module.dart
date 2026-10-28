import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/backup/expense_backup_section.dart';
import 'package:dailytrack/features/expense/data/dev/large_data_seeder.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/export/transactions_export_dataset.dart';
import 'package:dailytrack/features/expense/presentation/insights/expense_insight_source.dart';
import 'package:dailytrack/features/expense/presentation/screens/accounts_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/budgets_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/categories_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/recurring_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/reports_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_dashboard_card.dart';
import 'package:dailytrack/features/expense/presentation/widgets/recent_transactions_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Expense tracker module (spec §3, contracts/routes_and_module.md): the
/// Expenses tab (EXP-01..11), the Home card and the quick-add action.
/// Backup arrives in T3.2.
final class ExpenseModule extends TrackerModule {
  const new();

  @override
  String get id => 'expense';

  @override
  String displayName(BuildContext context) =>
      AppLocalizations.of(context).modules_expense;

  @override
  String tabLabel(BuildContext context) =>
      AppLocalizations.of(context).nav_expenses;

  @override
  IconData get icon => Icons.receipt_long_outlined;

  @override
  IconData get selectedIcon => Icons.receipt_long;

  @override
  String get rootPath => Routes.expenses;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: Routes.expenses,
      name: RouteNames.expenses,
      builder: (context, state) =>
          TransactionsScreen(accountId: state.uri.queryParameters['accountId']),
      // Static segments before `:id` (research R10).
      routes: [
        GoRoute(
          path: Routes.expenseAddSegment,
          name: RouteNames.expenseAdd,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: TransactionFormScreen(
              args: TransactionFormArgs(
                mode: FormMode.add,
                initialType: _typeFrom(state.uri.queryParameters['type']),
                duplicateOf: state.uri.queryParameters['duplicateOf'],
              ),
            ),
          ),
        ),
        GoRoute(
          path: Routes.expenseCategoriesSegment,
          name: RouteNames.expenseCategories,
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: Routes.expenseAccountsSegment,
          name: RouteNames.expenseAccounts,
          builder: (context, state) => const AccountsScreen(),
        ),
        GoRoute(
          path: Routes.expenseBudgetsSegment,
          name: RouteNames.expenseBudgets,
          builder: (context, state) =>
              BudgetsScreen(month: state.uri.queryParameters['month']),
        ),
        GoRoute(
          path: Routes.expenseRecurringSegment,
          name: RouteNames.expenseRecurring,
          builder: (context, state) => const RecurringScreen(),
          routes: [
            GoRoute(
              path: Routes.expenseAddSegment,
              name: RouteNames.expenseRecurringAdd,
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: const TransactionFormScreen(
                  args: TransactionFormArgs(mode: FormMode.add, repeat: true),
                ),
              ),
            ),
            GoRoute(
              path: Routes.expenseRuleEditSegment,
              name: RouteNames.expenseRuleEdit,
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: TransactionFormScreen(
                  args: TransactionFormArgs(
                    mode: FormMode.ruleEdit,
                    ruleId: state.pathParameters['ruleId'],
                  ),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: Routes.expenseReportsSegment,
          name: RouteNames.expenseReports,
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: Routes.expenseDetailSegment,
          name: RouteNames.expenseDetail,
          builder: (context, state) =>
              TransactionDetailScreen(id: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: Routes.expenseEditSegment,
              name: RouteNames.expenseEdit,
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: TransactionFormScreen(
                  args: TransactionFormArgs(
                    mode: FormMode.edit,
                    id: state.pathParameters['id'],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  /// `?type=` → transaction type; anything unknown means Expense.
  static TxnType _typeFrom(String? name) => TxnType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => TxnType.expense,
  );

  /// Spent today and this month, live (FR-030).
  @override
  Widget dashboardCard(BuildContext context) => const ExpenseDashboardCard();

  /// The global "+" opens EXP-02 as an expense (FR-031) or as income
  /// (DSH-01).
  @override
  List<QuickAddAction> quickAddActions() => [
    QuickAddAction(
      labelKey: 'expense_quickAdd',
      icon: Icons.add,
      location: Routes.expenseAddPath(type: TxnType.expense.name),
    ),
    QuickAddAction(
      labelKey: 'expense_quickAddIncome',
      icon: Icons.add_card,
      location: Routes.expenseAddPath(type: TxnType.income.name),
    ),
  ];

  /// DSH-01 Recent transactions, below all module cards.
  @override
  List<DashboardSection> dashboardSections() => [
    DashboardSection(
      id: 'expense.recentTransactions',
      build: (_) => const RecentTransactionsSection(),
    ),
  ];

  /// DSH-01 rule-based insights, evaluated on the device.
  @override
  InsightSource? insights() => const ExpenseInsightSource();

  /// SET-03 export (feature 008 research R14).
  @override
  List<ExportDataset> exportDatasets() => const [TransactionsExportDataset()];

  /// Dev flavor only: "Seed 10,000 transactions" for the §13 performance
  /// pass (feature 012 T041). Empty in prod.
  @override
  List<DevAction> devActions(ProviderReader read) => [
    if (read(debugToolsAvailableProvider))
      DevAction(
        id: 'expense.seed10k',
        labelKey: 'more_seedTransactions',
        confirmKey: 'more_seedConfirm',
        icon: Icons.dataset_outlined,
        run: (read, onProgress) => LargeDataSeeder(
          read(appDatabaseProvider),
          read(clockProvider),
          read(backupCoordinatorProvider),
        ).seed(onProgress: onProgress),
      ),
  ];

  @override
  BackupSection? backupSection() => const ExpenseBackupSection();

  /// Spent today and the month's Overall budget for the home screen widget
  /// and the daily summary (feature 008 research R19). For a later day
  /// (tomorrow's precomputed block) today's spend is 0.
  @override
  Future<void> contributeGlance(
    GlanceBuilder b,
    ProviderReader read,
    DateTime nowLocal,
  ) async {
    final settings = await read(settingsRepositoryProvider).load();
    final spend = await read(transactionRepositoryProvider)
        .watchTodayAndMonthSpend(nowLocal)
        .first;
    final overview = await read(budgetRepositoryProvider)
        .watchOverview(monthKeyOf(nowLocal))
        .first;
    final overall = overview.overall;
    b.spend = GlanceSpend(
      todayMinor: spend.todayMinor,
      currencyCode: settings.currencyCode,
      monthStart: DateTime(nowLocal.year, nowLocal.month),
      budget: overall == null
          ? null
          : GlanceBudget(
              limitMinor: overall.spentMinor + overall.remainingMinor,
              spentMinor: overall.spentMinor,
            ),
    );
  }

  @override
  List<Seeder> get seeders => const [ExpenseDefaultsSeeder()];

  /// The daily background job's unique name (research R10).
  static const String recurringTaskName = 'expense.recurring';

  /// FR-043: schedules the daily job and catches up at once.
  @override
  Future<void> onEnable(ProviderReader read) async {
    await _ensureDaily(read);
    await onAppOpen(read);
  }

  /// SET-01 notification switches (feature 007 R17): removes shown budget
  /// alerts once they are no longer allowed. New alerts are already blocked
  /// by the notification gate.
  @override
  Future<void> onNotificationSettingsChanged(ProviderReader read) async {
    try {
      if (!await read(notificationGateProvider).budgetAlertsAllowed()) {
        await read(budgetAlertNotifierProvider).cancelAll();
      }
    } on Object {
      // Best effort.
    }
  }

  /// Erase all data (feature 007 R16): receipt photos are files, not rows,
  /// so they go here; shown budget alerts go too.
  @override
  Future<void> onEraseAll(ProviderReader read) async {
    try {
      await read(receiptStoreProvider).deleteAll();
    } on Object {
      // Best effort; the rows that pointed at them are already gone.
    }
    try {
      await read(budgetAlertNotifierProvider).cancelAll();
    } on Object {
      // Best effort.
    }
  }

  /// FR-043: stops the daily job and removes shown budget alerts. Expense
  /// data is kept.
  @override
  Future<void> onDisable(ProviderReader read) async {
    try {
      await read(backgroundSchedulerProvider).cancel(recurringTaskName);
    } on Object {
      // Best effort.
    }
    try {
      await read(budgetAlertNotifierProvider).cancelAll();
    } on Object {
      // Best effort; nothing else to undo.
    }
  }

  /// Cold start and every resume (research R10), each step isolated:
  /// budget rollover (FR-013), due recurring entries (FR-025), then the
  /// daily job (keep policy, so usually a no-op).
  @override
  Future<void> onAppOpen(ProviderReader read) async {
    await _rollover(read);
    await _generate(read);
    await _ensureDaily(read);
  }

  /// Runs in the background isolate even when the app is closed (FR-025).
  /// Rollover also runs, so a month change while closed is handled.
  @override
  Map<String, BackgroundTask> get backgroundTasks => {
    recurringTaskName: (read) async {
      await _rollover(read);
      await _generate(read);
      return true;
    },
  };

  static Future<void> _rollover(ProviderReader read) async {
    try {
      final now = read(clockProvider).now();
      await read(budgetRepositoryProvider).rolloverIfNeeded(monthKeyOf(now));
    } on Object {
      // Best effort (research R10); the next open retries.
    }
  }

  static Future<void> _generate(ProviderReader read) async {
    try {
      await read(recurringGeneratorProvider).runDue();
    } on Object {
      // runDue never throws; reading an unbound provider might.
    }
  }

  static Future<void> _ensureDaily(ProviderReader read) async {
    try {
      await read(backgroundSchedulerProvider).ensureDaily(recurringTaskName);
    } on Object {
      // The OS may refuse; app open still generates (spec edge case).
    }
  }
}
