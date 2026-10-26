// Single source of route paths and names (spec §5). Constants only and no
// imports, so it is the one lib/app/ file features may import.

abstract final class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String lock = '/lock';

  /// SYS-03 as a route, with where to go after unlocking (feature 007).
  static String lockPath({String? from}) =>
      from == null ? lock : '$lock?from=${Uri.encodeQueryComponent(from)}';

  /// SYS-04 Set / change PIN, above the shell. Query `mode`: [pinModeSet],
  /// [pinModeChange], or [pinModeDisable].
  static const String pin = '/settings/security/pin';

  static const String pinModeSet = 'set';
  static const String pinModeChange = 'change';
  static const String pinModeDisable = 'disable';

  /// [from] is where SYS-04 returns to when it closes (it leaves with `go`,
  /// not `pop`, so a router refresh can never bring it back).
  static String pinPath(String mode, {String? from}) =>
      '$pin?mode=${Uri.encodeQueryComponent(mode)}'
      '${from == null ? '' : '&from=${Uri.encodeQueryComponent(from)}'}';

  /// SET-05, pushed inside the More branch (feature 007).
  static const String security = '/more/security';

  /// Relative path of [security] under [more].
  static const String securitySegment = 'security';

  /// SET-02, pushed inside the More branch (feature 008).
  static const String backup = '/more/backup';

  /// Relative path of [backup] under [more].
  static const String backupSegment = 'backup';

  /// ACC-01 Account, pushed inside the More branch (feature 010).
  static const String account = '/more/account';

  /// Relative path of [account] under [more].
  static const String accountSegment = 'account';

  /// SET-03, above the shell so EXP-11 can open it (feature 008).
  static const String export = '/more/export';

  /// Relative path of [export] under [more].
  static const String exportSegment = 'export';

  /// SET-03 prefilled: [dataset] (e.g. `transactions`) and [period], the
  /// query from `periodToQuery` (EXP-11 "Export this report").
  static String exportPath({
    String? dataset,
    Map<String, String> period = const {},
  }) {
    final query = {'dataset': ?dataset, ...period};
    return query.isEmpty
        ? export
        : Uri(path: export, queryParameters: query).toString();
  }

  static const String home = '/home';
  static const String expenses = '/expenses';

  /// EXP-02 (new), above the shell. Query: `type`, `duplicateOf`.
  static const String expenseAdd = '/expenses/add';

  /// EXP-04, pushed inside the Expenses branch.
  static const String expenseCategories = '/expenses/categories';

  /// EXP-06, pushed inside the Expenses branch.
  static const String expenseAccounts = '/expenses/accounts';

  /// EXP-08, pushed inside the Expenses branch. Query: `month` (`yyyy-MM`).
  static const String expenseBudgets = '/expenses/budgets';

  /// EXP-10, pushed inside the Expenses branch.
  static const String expenseRecurring = '/expenses/recurring';

  /// EXP-02 new with Repeat on (EXP-10 empty state), above the shell.
  static const String expenseRecurringAdd = '/expenses/recurring/add';

  /// EXP-02 rule-edit mode, above the shell.
  static const String expenseRuleEdit = '/expenses/recurring/:ruleId/edit';

  /// EXP-11, pushed inside the Expenses branch.
  static const String expenseReports = '/expenses/reports';

  /// EXP-03, pushed inside the Expenses branch.
  static const String expenseDetail = '/expenses/:id';

  /// EXP-02 (edit), above the shell.
  static const String expenseEdit = '/expenses/:id/edit';

  // Segments under [expenses]. Static ones must be declared before `:id`.
  static const String expenseAddSegment = 'add';
  static const String expenseCategoriesSegment = 'categories';
  static const String expenseAccountsSegment = 'accounts';
  static const String expenseBudgetsSegment = 'budgets';
  static const String expenseRecurringSegment = 'recurring';
  static const String expenseReportsSegment = 'reports';

  /// Under [expenseRecurringSegment].
  static const String expenseRuleEditSegment = ':ruleId/edit';
  static const String expenseDetailSegment = ':id';
  static const String expenseEditSegment = 'edit';

  /// EXP-01, optionally filtered to one account (EXP-06 tap).
  static String expensesPath({String? accountId}) => accountId == null
      ? expenses
      : '$expenses?accountId=${Uri.encodeQueryComponent(accountId)}';

  /// EXP-02 new. [type] is `expense`, `income` or `transfer`.
  static String expenseAddPath({String? type, String? duplicateOf}) {
    final query = [
      if (type != null) 'type=${Uri.encodeQueryComponent(type)}',
      if (duplicateOf != null)
        'duplicateOf=${Uri.encodeQueryComponent(duplicateOf)}',
    ];
    return query.isEmpty ? expenseAdd : '$expenseAdd?${query.join('&')}';
  }

  /// EXP-08 for [month] (`yyyy-MM`), or this month. Also the budget alert
  /// notification payload (research R6).
  static String expenseBudgetsPath({String? month}) => month == null
      ? expenseBudgets
      : '$expenseBudgets?month=${Uri.encodeQueryComponent(month)}';

  static String expenseRuleEditPath(String ruleId) =>
      '$expenseRecurring/${Uri.encodeComponent(ruleId)}/edit';

  static String expenseDetailPath(String id) =>
      '$expenses/${Uri.encodeComponent(id)}';

  static String expenseEditPath(String id) =>
      '$expenses/${Uri.encodeComponent(id)}/edit';

  /// HAB-01, the Habits tab root (feature 005). Also the reminder payload.
  static const String habits = '/habits';

  /// HAB-02 (new), above the shell. Query: `template`.
  static const String habitAdd = '/habits/add';

  /// HAB-04, pushed inside the Habits branch.
  static const String habitArchived = '/habits/archived';

  /// HAB-03, pushed inside the Habits branch.
  static const String habitDetail = '/habits/:id';

  /// HAB-02 (edit), above the shell.
  static const String habitEdit = '/habits/:id/edit';

  // Segments under [habits]. Static ones must be declared before `:id`.
  static const String habitAddSegment = 'add';
  static const String habitArchivedSegment = 'archived';
  static const String habitDetailSegment = ':id';
  static const String habitEditSegment = 'edit';

  /// HAB-02 new, optionally prefilled from a template id (research R16).
  static String habitAddPath({String? template}) => template == null
      ? habitAdd
      : '$habitAdd?template=${Uri.encodeQueryComponent(template)}';

  static String habitDetailPath(String id) =>
      '$habits/${Uri.encodeComponent(id)}';

  static String habitEditPath(String id) =>
      '$habits/${Uri.encodeComponent(id)}/edit';

  static const String more = '/more';

  /// SET-06, pushed inside the More branch.
  static const String modules = '/more/modules';

  /// Relative path of [modules] under [more].
  static const String modulesSegment = 'modules';

  /// SET-04, pushed inside the More branch (feature 007).
  static const String themes = '/more/themes';

  /// Relative path of [themes] under [more].
  static const String themesSegment = 'themes';

  /// Privacy policy or Terms in the in-app web view, above the shell.
  /// `:page` is [webPagePrivacy] or [webPageTerms].
  static const String webPage = '/more/web/:page';

  /// Relative path of [webPage] under [more].
  static const String webPageSegment = 'web/:page';

  static const String webPagePrivacy = 'privacy';
  static const String webPageTerms = 'terms';

  static String webPagePath(String page) =>
      '/more/web/${Uri.encodeComponent(page)}';

  /// PRM-01 Premium / Remove Ads, a full-screen modal above everything
  /// (feature 009 contracts/routes.md).
  static const String premium = '/premium';
}

abstract final class RouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String lock = 'lock';
  static const String premium = 'premium';
  static const String home = 'home';
  static const String expenses = 'expenses';
  static const String expenseAdd = 'expenseAdd';
  static const String expenseCategories = 'expenseCategories';
  static const String expenseAccounts = 'expenseAccounts';
  static const String expenseBudgets = 'expenseBudgets';
  static const String expenseRecurring = 'expenseRecurring';
  static const String expenseRecurringAdd = 'expenseRecurringAdd';
  static const String expenseRuleEdit = 'expenseRuleEdit';
  static const String expenseReports = 'expenseReports';
  static const String expenseDetail = 'expenseDetail';
  static const String expenseEdit = 'expenseEdit';
  static const String habits = 'habits';
  static const String habitAdd = 'habitAdd';
  static const String habitArchived = 'habitArchived';
  static const String habitDetail = 'habitDetail';
  static const String habitEdit = 'habitEdit';
  static const String more = 'more';
  static const String modules = 'modules';
  static const String themes = 'themes';
  static const String webPage = 'webPage';
  static const String pin = 'pin';
  static const String security = 'security';
  static const String backup = 'backup';
  static const String account = 'account';
  static const String export = 'export';
}
