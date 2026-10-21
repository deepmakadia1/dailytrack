// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DailyTrack';

  @override
  String get common_next => 'Next';

  @override
  String get common_back => 'Back';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_tryAgain => 'Try again';

  @override
  String get common_comingSoon => 'Coming soon';

  @override
  String get common_placeholderMessage => 'Coming in a later update';

  @override
  String get common_previousMonth => 'Previous month';

  @override
  String get common_nextMonth => 'Next month';

  @override
  String get common_undo => 'Undo';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get keypad_backspace => 'Delete';

  @override
  String get keypad_done => 'Done';

  @override
  String get premium_lockedLabel => 'Pro feature, locked';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_expenses => 'Expenses';

  @override
  String get nav_habits => 'Habits';

  @override
  String get nav_more => 'More';

  @override
  String get splash_errorMessage => 'Couldn\'t open your data. Try again.';

  @override
  String get onboarding_welcomeTitle => 'Track money and habits in one place';

  @override
  String get onboarding_languageLabel => 'Choose your language';

  @override
  String get onboarding_currencyTitle => 'Choose your currency';

  @override
  String get onboarding_currencySearchHint => 'Search currency';

  @override
  String get onboarding_noMatches => 'No matches';

  @override
  String get onboarding_clearSearch => 'Clear search';

  @override
  String get onboarding_modulesTitle => 'What do you want to track?';

  @override
  String get onboarding_atLeastOneModule => 'Keep at least one tracker on';

  @override
  String get onboarding_privacyTitle => 'Your data stays with you';

  @override
  String get onboarding_privacyBody =>
      'Everything you log is stored only on this device. Nothing is uploaded unless you choose to back it up.';

  @override
  String get onboarding_allowNotifications => 'Allow notifications';

  @override
  String get onboarding_notificationsGranted => 'Notifications are on';

  @override
  String get onboarding_notificationsDenied =>
      'Notifications are off. You can turn them on later in Settings.';

  @override
  String get onboarding_getStarted => 'Get started';

  @override
  String get onboarding_saveError => 'Couldn\'t save your choices. Try again.';

  @override
  String onboarding_stepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get modules_title => 'Modules';

  @override
  String get modules_expense => 'Expense';

  @override
  String get modules_habit => 'Habit';

  @override
  String get modules_water => 'Water';

  @override
  String get modules_period => 'Period';

  @override
  String get modules_atLeastOne => 'At least one module must stay on';

  @override
  String get modules_errorMessage =>
      'Couldn\'t load or save your modules. Try again.';

  @override
  String modules_reorderHandle(String name) {
    return 'Reorder $name';
  }

  @override
  String get more_modulesEntry => 'Modules';

  @override
  String get lock_title => 'DailyTrack is locked';

  @override
  String get lock_placeholderMessage => 'Unlock is coming in a later update';

  @override
  String get premium_watchAd => 'Watch an ad';

  @override
  String get premium_getPro => 'Get Pro';

  @override
  String get language_en => 'English';

  @override
  String get language_hi => 'हिन्दी';

  @override
  String get language_gu => 'ગુજરાતી';

  @override
  String get expense_cat_food => 'Food';

  @override
  String get expense_cat_groceries => 'Groceries';

  @override
  String get expense_cat_transport => 'Transport';

  @override
  String get expense_cat_fuel => 'Fuel';

  @override
  String get expense_cat_shopping => 'Shopping';

  @override
  String get expense_cat_bills => 'Bills';

  @override
  String get expense_cat_rent => 'Rent';

  @override
  String get expense_cat_health => 'Health';

  @override
  String get expense_cat_education => 'Education';

  @override
  String get expense_cat_entertainment => 'Entertainment';

  @override
  String get expense_cat_travel => 'Travel';

  @override
  String get expense_cat_other => 'Other';

  @override
  String get income_cat_salary => 'Salary';

  @override
  String get income_cat_business => 'Business';

  @override
  String get income_cat_gift => 'Gift';

  @override
  String get income_cat_interest => 'Interest';

  @override
  String get income_cat_other => 'Other income';

  @override
  String get expense_account_cash => 'Cash';

  @override
  String get common_previousDay => 'Previous day';

  @override
  String get common_nextDay => 'Next day';

  @override
  String get common_previousWeek => 'Previous week';

  @override
  String get common_nextWeek => 'Next week';

  @override
  String get common_previousYear => 'Previous year';

  @override
  String get common_nextYear => 'Next year';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String get common_periodTitle => 'Choose a period';

  @override
  String get common_periodDay => 'Day';

  @override
  String get common_periodWeek => 'Week';

  @override
  String get common_periodMonth => 'Month';

  @override
  String get common_periodYear => 'Year';

  @override
  String get common_periodCustom => 'Custom range';

  @override
  String get expense_typeExpense => 'Expense';

  @override
  String get expense_typeIncome => 'Income';

  @override
  String get expense_typeTransfer => 'Transfer';

  @override
  String get expense_payCash => 'Cash';

  @override
  String get expense_payUpi => 'UPI';

  @override
  String get expense_payCard => 'Card';

  @override
  String get expense_payNetBanking => 'Net banking';

  @override
  String get expense_payOther => 'Other';

  @override
  String get expense_accountTypeCash => 'Cash';

  @override
  String get expense_accountTypeBank => 'Bank';

  @override
  String get expense_accountTypeUpi => 'UPI wallet';

  @override
  String get expense_accountTypeCard => 'Card';

  @override
  String get expense_accountTypeWallet => 'Wallet';

  @override
  String get expense_saved => 'Saved';

  @override
  String get expense_deleted => 'Transaction deleted';

  @override
  String get expense_loadError =>
      'Couldn\'t load your transactions. Try again.';

  @override
  String get expense_saveError =>
      'Couldn\'t save. Your changes are still here. Try again.';

  @override
  String get expense_spentToday => 'Spent today';

  @override
  String get expense_thisMonth => 'This month';

  @override
  String get expense_quickAdd => 'Add expense';

  @override
  String get expense_addTitle => 'Add transaction';

  @override
  String get expense_editTitle => 'Edit transaction';

  @override
  String get expense_saveExpense => 'Save expense';

  @override
  String get expense_saveIncome => 'Save income';

  @override
  String get expense_saveTransfer => 'Save transfer';

  @override
  String get expense_saveAndAddAnother => 'Save and add another';

  @override
  String expense_fromAccount(String account) {
    return 'From $account';
  }

  @override
  String expense_toAccount(String account) {
    return 'To $account';
  }

  @override
  String get expense_chooseToAccount => 'Choose where to move it';

  @override
  String get expense_account => 'Account';

  @override
  String get expense_paymentMode => 'Payment mode';

  @override
  String get expense_category => 'Category';

  @override
  String get expense_amount => 'Amount';

  @override
  String get expense_pickDate => 'Pick date';

  @override
  String get expense_pickTime => 'Pick time';

  @override
  String get expense_noteLabel => 'Note (optional)';

  @override
  String expense_noteLimit(int count) {
    return '$count/200';
  }

  @override
  String get expense_attachReceipt => 'Attach receipt';

  @override
  String get expense_camera => 'Camera';

  @override
  String get expense_gallery => 'Gallery';

  @override
  String get expense_removeReceipt => 'Remove receipt';

  @override
  String get expense_receiptError => 'Couldn\'t attach the photo. Try again.';

  @override
  String get expense_newCategory => 'New';

  @override
  String get expense_noCategories => 'No categories yet. Add one to continue';

  @override
  String get expense_discardTitle => 'Discard changes?';

  @override
  String get expense_discardBody =>
      'Your changes to this transaction will be lost.';

  @override
  String get expense_discardConfirm => 'Discard';

  @override
  String get expense_errAmountRequired => 'Enter an amount';

  @override
  String expense_errAmountTooLarge(String max) {
    return 'Amount can be at most $max';
  }

  @override
  String get expense_errAmountInvalid => 'Check the calculation';

  @override
  String get expense_errCategoryRequired => 'Choose a category';

  @override
  String get expense_errToAccountRequired =>
      'Choose an account to move money to';

  @override
  String get expense_errSameAccount => 'Choose two different accounts';

  @override
  String get expense_errNoteTooLong => 'Notes can be up to 200 characters';

  @override
  String get expense_noLongerExists => 'This transaction no longer exists';

  @override
  String get expense_deleteAction => 'Delete transaction';

  @override
  String get expense_listTitle => 'Expenses';

  @override
  String get expense_search => 'Search transactions';

  @override
  String get expense_closeSearch => 'Close search';

  @override
  String get expense_filter => 'Filter';

  @override
  String get expense_menuCategories => 'Categories';

  @override
  String get expense_menuAccounts => 'Accounts';

  @override
  String get expense_income => 'Income';

  @override
  String get expense_expense => 'Expense';

  @override
  String get expense_net => 'Net';

  @override
  String expense_emptyPeriod(String period) {
    return 'No transactions in $period';
  }

  @override
  String get expense_addExpense => 'Add expense';

  @override
  String get expense_noMatches => 'No matches';

  @override
  String get expense_clearFilters => 'Clear filters';

  @override
  String get expense_duplicate => 'Duplicate';

  @override
  String get expense_delete => 'Delete';

  @override
  String expense_transferLabel(String from, String to) {
    return '$from → $to';
  }

  @override
  String get expense_detailTitle => 'Transaction';

  @override
  String get expense_edit => 'Edit';

  @override
  String get expense_share => 'Share';

  @override
  String get expense_receipt => 'Receipt';

  @override
  String get expense_receiptMissing => 'Receipt not available';

  @override
  String get expense_close => 'Close';

  @override
  String expense_shareText(
    String type,
    String amount,
    String category,
    String account,
    String date,
  ) {
    return '$type: $amount\n$category · $account\n$date';
  }

  @override
  String expense_shareNote(String note) {
    return 'Note: $note';
  }

  @override
  String get expense_filterTitle => 'Filter transactions';

  @override
  String get expense_filterType => 'Type';

  @override
  String get expense_filterAmountMin => 'Min amount';

  @override
  String get expense_filterAmountMax => 'Max amount';

  @override
  String get expense_applyFilters => 'Apply filters';

  @override
  String expense_removeFilter(String name) {
    return 'Remove filter $name';
  }

  @override
  String expense_amountAtLeast(String amount) {
    return '≥ $amount';
  }

  @override
  String expense_amountAtMost(String amount) {
    return '≤ $amount';
  }

  @override
  String expense_amountBetween(String min, String max) {
    return '$min – $max';
  }

  @override
  String expense_accountAndMode(String account, String mode) {
    return '$account · $mode';
  }

  @override
  String expense_amountValue(String amount) {
    return 'Amount: $amount';
  }

  @override
  String common_colorLabel(int index, int total) {
    return 'Color $index of $total';
  }

  @override
  String get common_iconPicker => 'Choose an icon';

  @override
  String get common_colorPicker => 'Choose a color';

  @override
  String get expense_categoriesTitle => 'Categories';

  @override
  String get expense_newCategoryTitle => 'New category';

  @override
  String get expense_editCategoryTitle => 'Edit category';

  @override
  String get expense_hiddenSection => 'Hidden';

  @override
  String get expense_hide => 'Hide';

  @override
  String get expense_unhide => 'Show again';

  @override
  String get expense_rename => 'Rename';

  @override
  String get expense_deleteCategory => 'Delete category';

  @override
  String get expense_categoryDeleted => 'Category deleted';

  @override
  String get expense_categoryHidden => 'Category hidden';

  @override
  String get expense_categoryShown => 'Category shown again';

  @override
  String get expense_moveTitle => 'Choose a new category';

  @override
  String expense_moveBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count transactions to the category you choose.',
      one: 'Move 1 transaction to the category you choose.',
    );
    return '$_temp0';
  }

  @override
  String get expense_moveConfirm => 'Move and delete';

  @override
  String get expense_categoryName => 'Name';

  @override
  String get expense_nameLimit => 'Up to 30 characters';

  @override
  String get expense_errNameRequired => 'Enter a name';

  @override
  String get expense_errNameTooLong => 'Names can be up to 30 characters';

  @override
  String get expense_errNameDuplicate =>
      'A category with this name already exists';

  @override
  String get expense_errNameReserved => 'Choose a different name';

  @override
  String get expense_icon => 'Icon';

  @override
  String get expense_color => 'Color';

  @override
  String get expense_type => 'Type';

  @override
  String get expense_saveCategory => 'Save category';

  @override
  String expense_reorderHandle(String name) {
    return 'Drag to reorder $name';
  }

  @override
  String get expense_reorderError => 'Couldn\'t save the new order. Try again.';

  @override
  String get expense_noCategoriesHere => 'No categories here yet';

  @override
  String get expense_addCategory => 'Add category';

  @override
  String get expense_loadDataError => 'Couldn\'t load this screen. Try again.';

  @override
  String get expense_accountsTitle => 'Accounts';

  @override
  String get expense_newAccountTitle => 'New account';

  @override
  String get expense_editAccountTitle => 'Edit account';

  @override
  String get expense_totalBalance => 'Total balance';

  @override
  String get expense_archivedSection => 'Archived';

  @override
  String get expense_archive => 'Archive';

  @override
  String get expense_unarchive => 'Restore';

  @override
  String get expense_accountArchived => 'Account archived';

  @override
  String get expense_accountRestored => 'Account restored';

  @override
  String get expense_deleteAccount => 'Delete account';

  @override
  String get expense_accountDeleted => 'Account deleted';

  @override
  String get expense_lastAccountHelp => 'You need at least one active account';

  @override
  String get expense_accountHasTransactions =>
      'Accounts with transactions can be archived, not deleted';

  @override
  String get expense_accountName => 'Name';

  @override
  String get expense_accountType => 'Type';

  @override
  String get expense_openingBalance => 'Opening balance';

  @override
  String get expense_balancePositive => 'Positive balance';

  @override
  String get expense_balanceNegative =>
      'Negative balance, for example a card you owe on';

  @override
  String get expense_saveAccount => 'Save account';

  @override
  String get expense_errAccountNameRequired => 'Enter a name';

  @override
  String get expense_errAccountNameTooLong =>
      'Names can be up to 40 characters';

  @override
  String expense_errBalanceRange(String min, String max) {
    return 'Balance must be between $min and $max';
  }

  @override
  String get expense_addAccount => 'Add account';

  @override
  String get expense_noAccounts => 'No accounts yet';

  @override
  String get expense_cardEmpty => 'Add your first expense';

  @override
  String get common_iconGroup_food => 'Food';

  @override
  String get common_iconGroup_transport => 'Transport';

  @override
  String get common_iconGroup_home => 'Home and bills';

  @override
  String get common_iconGroup_shopping => 'Shopping';

  @override
  String get common_iconGroup_health => 'Health';

  @override
  String get common_iconGroup_education => 'Education';

  @override
  String get common_iconGroup_leisure => 'Leisure';

  @override
  String get common_iconGroup_travel => 'Travel';

  @override
  String get common_iconGroup_money => 'Money';

  @override
  String get common_iconGroup_other => 'Other';

  @override
  String get icon_restaurant => 'Restaurant';

  @override
  String get icon_local_grocery_store => 'Groceries';

  @override
  String get icon_local_cafe => 'Cafe';

  @override
  String get icon_fastfood => 'Fast food';

  @override
  String get icon_bakery_dining => 'Bakery';

  @override
  String get icon_local_bar => 'Drinks';

  @override
  String get icon_icecream => 'Ice cream';

  @override
  String get icon_lunch_dining => 'Meal';

  @override
  String get icon_directions_bus => 'Bus';

  @override
  String get icon_local_gas_station => 'Fuel';

  @override
  String get icon_directions_car => 'Car';

  @override
  String get icon_two_wheeler => 'Two-wheeler';

  @override
  String get icon_local_taxi => 'Taxi';

  @override
  String get icon_train => 'Train';

  @override
  String get icon_electric_rickshaw => 'Auto rickshaw';

  @override
  String get icon_local_parking => 'Parking';

  @override
  String get icon_home => 'Home';

  @override
  String get icon_receipt => 'Bills';

  @override
  String get icon_bolt => 'Electricity';

  @override
  String get icon_water_drop => 'Water';

  @override
  String get icon_wifi => 'Internet';

  @override
  String get icon_phone_android => 'Mobile';

  @override
  String get icon_build => 'Repairs';

  @override
  String get icon_cleaning_services => 'Cleaning';

  @override
  String get icon_shopping_bag => 'Shopping';

  @override
  String get icon_shopping_cart => 'Cart';

  @override
  String get icon_checkroom => 'Clothes';

  @override
  String get icon_devices => 'Electronics';

  @override
  String get icon_chair => 'Furniture';

  @override
  String get icon_redeem => 'Gift';

  @override
  String get icon_local_florist => 'Flowers';

  @override
  String get icon_pets => 'Pets';

  @override
  String get icon_medical_services => 'Medical';

  @override
  String get icon_local_pharmacy => 'Pharmacy';

  @override
  String get icon_fitness_center => 'Fitness';

  @override
  String get icon_spa => 'Self-care';

  @override
  String get icon_favorite => 'Wellbeing';

  @override
  String get icon_child_care => 'Child care';

  @override
  String get icon_school => 'School';

  @override
  String get icon_menu_book => 'Books';

  @override
  String get icon_computer => 'Computer';

  @override
  String get icon_science => 'Science';

  @override
  String get icon_edit => 'Stationery';

  @override
  String get icon_movie => 'Movies';

  @override
  String get icon_sports_esports => 'Games';

  @override
  String get icon_music_note => 'Music';

  @override
  String get icon_sports_cricket => 'Cricket';

  @override
  String get icon_celebration => 'Celebration';

  @override
  String get icon_theater_comedy => 'Events';

  @override
  String get icon_subscriptions => 'Subscriptions';

  @override
  String get icon_flight => 'Flight';

  @override
  String get icon_hotel => 'Hotel';

  @override
  String get icon_luggage => 'Luggage';

  @override
  String get icon_beach_access => 'Holiday';

  @override
  String get icon_map => 'Trip';

  @override
  String get icon_payments => 'Salary';

  @override
  String get icon_storefront => 'Business';

  @override
  String get icon_savings => 'Savings';

  @override
  String get icon_attach_money => 'Money';

  @override
  String get icon_account_balance => 'Bank';

  @override
  String get icon_credit_card => 'Credit card';

  @override
  String get icon_wallet => 'Wallet';

  @override
  String get icon_currency_rupee => 'Rupee';

  @override
  String get icon_trending_up => 'Investment';

  @override
  String get icon_request_quote => 'Tax';

  @override
  String get icon_volunteer_activism => 'Donation';

  @override
  String get icon_work => 'Work';

  @override
  String get icon_category => 'Category';

  @override
  String get icon_star => 'Star';

  @override
  String get icon_label => 'Label';

  @override
  String get icon_more_horiz => 'Other';

  @override
  String get expense_menuBudgets => 'Budgets';

  @override
  String get expense_budgetsTitle => 'Budgets';

  @override
  String get expense_budgetOverall => 'Overall';

  @override
  String get expense_budgetCategoryBudgets => 'Category budgets';

  @override
  String get expense_budgetWithoutBudget => 'Categories without budget';

  @override
  String get expense_budgetSet => 'Set budget';

  @override
  String get expense_budgetSetMonthly => 'Set monthly budget';

  @override
  String get expense_budgetCopyLastMonth => 'Copy last month\'s budgets';

  @override
  String expense_budgetCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count budgets',
      one: 'Copied 1 budget',
      zero: 'Nothing to copy',
    );
    return '$_temp0';
  }

  @override
  String expense_budgetPerDayLeft(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$amount per day left for $_temp0';
  }

  @override
  String get expense_budgetNoneLeft => 'No budget left this month';

  @override
  String expense_budgetUnderBy(String amount) {
    return 'Under budget by $amount';
  }

  @override
  String expense_budgetOverBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String expense_budgetFuturePerDay(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$amount per day for $_temp0';
  }

  @override
  String expense_budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String expense_budgetSpentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get expense_budgetLevelUnder => 'On track';

  @override
  String get expense_budgetLevelWarning => 'Almost used';

  @override
  String get expense_budgetLevelOver => 'Over budget';

  @override
  String expense_budgetLevelLine(String level, int percent) {
    return '$level · $percent% used';
  }

  @override
  String get expense_budgetEmptyTitle => 'Plan your month';

  @override
  String get expense_budgetEmptyBody =>
      'Set a monthly budget to see how much you can still spend each day.';

  @override
  String get expense_budgetRepeatMonthly => 'Repeat every month';

  @override
  String get expense_budgetDelete => 'Delete budget';

  @override
  String get expense_budgetDeleted => 'Budget deleted';

  @override
  String get expense_budgetRestoreFailed =>
      'Couldn\'t restore the budget because one is already set.';

  @override
  String get expense_budgetSlotTaken =>
      'This category already has a budget this month.';

  @override
  String get expense_budgetHidden => 'Hidden';

  @override
  String get expense_budgetAmountMissing => 'Enter an amount';

  @override
  String get expense_budgetAmountTooLarge => 'Amount is too large';

  @override
  String get expense_budgetSetOverallPrompt => 'Set an overall budget';

  @override
  String get notif_channelBudgetAlerts => 'Budget alerts';

  @override
  String get notif_channelBudgetAlertsDescription =>
      'When a budget reaches 80% or 100%';

  @override
  String notif_budget80Title(String category, int percent) {
    return '$category budget at $percent%';
  }

  @override
  String notif_budget80Body(String category, int percent) {
    return 'You\'ve used $percent% of your $category budget this month.';
  }

  @override
  String notif_budget100Title(String category) {
    return '$category budget used up';
  }

  @override
  String notif_budget100Body(String category, int percent) {
    return 'You\'ve used $percent% of your $category budget this month.';
  }

  @override
  String get notif_overallBudget => 'Overall';

  @override
  String get expense_menuRecurring => 'Recurring';

  @override
  String get expense_repeat => 'Repeat';

  @override
  String get expense_freqDaily => 'Daily';

  @override
  String get expense_freqWeekly => 'Weekly';

  @override
  String get expense_freqMonthly => 'Monthly';

  @override
  String get expense_freqYearly => 'Yearly';

  @override
  String get expense_repeatEndDate => 'End date (optional)';

  @override
  String expense_repeatEndsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get expense_repeatClearEnd => 'Remove end date';

  @override
  String get expense_repeatEndBeforeStart =>
      'End date can\'t be before the first date';

  @override
  String get expense_everyDay => 'Every day';

  @override
  String expense_everyWeekOn(String weekday) {
    return 'Every week on $weekday';
  }

  @override
  String expense_everyMonthOn(int day, String suffix) {
    String _temp0 = intl.Intl.selectLogic(suffix, {
      'st': '${day}st',
      'nd': '${day}nd',
      'rd': '${day}rd',
      'other': '${day}th',
    });
    return 'Every month on $_temp0';
  }

  @override
  String expense_everyYearOn(String date) {
    return 'Every year on $date';
  }

  @override
  String get expense_recurringTitle => 'Recurring transactions';

  @override
  String get expense_recurringPaused => 'Paused';

  @override
  String expense_recurringNext(String date) {
    return 'Next: $date';
  }

  @override
  String expense_recurringEnded(String date) {
    return 'Ended $date';
  }

  @override
  String get expense_recurringPause => 'Pause';

  @override
  String get expense_recurringResume => 'Resume';

  @override
  String get expense_recurringDelete => 'Delete';

  @override
  String get expense_recurringDeleted => 'Recurring transaction deleted';

  @override
  String get expense_recurringAdd => 'Add recurring transaction';

  @override
  String get expense_recurringEmptyTitle => 'Nothing repeats yet';

  @override
  String get expense_recurringEmptyBody =>
      'Add rent, salary, or bills once and they\'ll be logged for you.';

  @override
  String get expense_recurringStaleAccount => 'Account archived';

  @override
  String get expense_recurringStaleCategory => 'Category hidden';

  @override
  String get expense_ruleEditTitle => 'Edit recurring transaction';

  @override
  String get expense_nextDate => 'Next date';

  @override
  String get expense_createdFromRule => 'Created from recurring rule';

  @override
  String get expense_ruleDeleted => 'Recurring rule deleted';

  @override
  String get expense_recurringLabel => 'Recurring';

  @override
  String get expense_menuReports => 'Reports';

  @override
  String get premium_advancedReportsMessage =>
      'Advanced reports are part of Pro.';

  @override
  String get premium_lockedPeriod => 'Locked';

  @override
  String get more_developerSection => 'Developer';

  @override
  String get more_debugUnlockAll => 'Unlock all features (debug)';

  @override
  String get expense_reportsTitle => 'Reports';

  @override
  String get expense_reportTabOverview => 'Overview';

  @override
  String get expense_reportTabCategories => 'Categories';

  @override
  String get expense_reportTabTrends => 'Trends';

  @override
  String get expense_reportTabAccounts => 'Accounts';

  @override
  String expense_reportLockedTab(String tab) {
    return '$tab, locked';
  }

  @override
  String get expense_reportNetSavings => 'Net savings';

  @override
  String get expense_reportSavingsRate => 'Savings rate';

  @override
  String expense_reportSavingsRateValue(int percent) {
    return '$percent%';
  }

  @override
  String get expense_reportNoValue => '—';

  @override
  String get expense_reportAvgDaily => 'Average daily spend';

  @override
  String get expense_reportTopCategories => 'Top categories';

  @override
  String get expense_reportIncomeVsExpense => 'Income vs expense';

  @override
  String expense_reportShare(int percent) {
    return '$percent% of spending';
  }

  @override
  String get expense_reportOther => 'Other';

  @override
  String get expense_reportTotalSpent => 'Total spent';

  @override
  String expense_reportChartSummaryDonut(String items) {
    return 'Expense by category: $items';
  }

  @override
  String expense_reportChartSummaryItem(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String expense_reportChartSummaryBar(String income, String expense) {
    return 'Income $income, expense $expense';
  }

  @override
  String expense_reportEmpty(String period) {
    return 'No transactions in $period';
  }

  @override
  String get expense_reportThisPeriod => 'This period';

  @override
  String get expense_reportPreviousPeriod => 'Previous period';

  @override
  String get expense_reportByAccount => 'By account';

  @override
  String get expense_reportByPaymentMode => 'By payment mode';

  @override
  String expense_reportChartSummaryTrend(String current, String previous) {
    return 'Spending this period $current, previous period $previous';
  }

  @override
  String expense_reportChartSummaryBars(String title, String items) {
    return '$title: $items';
  }

  @override
  String expense_reportChartSummaryBarItem(String name, String amount) {
    return '$name $amount';
  }

  @override
  String get notif_channelHabitReminders => 'Habit reminders';

  @override
  String get notif_channelHabitRemindersDescription =>
      'Reminders for your habits';

  @override
  String get habit_title => 'Habits';

  @override
  String get habit_quickAddCheckIn => 'Check in habit';

  @override
  String habit_streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String habit_streakWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String habit_doneOfTotal(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get habit_undo => 'Undo';

  @override
  String get habit_loadError => 'Couldn\'t load your habits. Try again.';

  @override
  String get habit_saveError => 'Couldn\'t save. Try again.';

  @override
  String get habit_menuArchived => 'Archived habits';

  @override
  String get habit_menuReorder => 'Reorder';

  @override
  String get habit_reorderDone => 'Done';

  @override
  String habit_reorderHandle(String name) {
    return 'Reorder $name';
  }

  @override
  String get habit_moreOptions => 'More options';

  @override
  String get habit_addHabit => 'Add habit';

  @override
  String get habit_emptyTitle => 'Build your first habit';

  @override
  String get habit_emptyBody =>
      'Start with a template or tap + to create your own.';

  @override
  String get habit_notScheduledToday => 'Not scheduled today';

  @override
  String get habit_notScheduledOnDay => 'Not scheduled on this day';

  @override
  String get habit_allDone => 'All done for today';

  @override
  String get habit_noneScheduled => 'Nothing scheduled on this day';

  @override
  String get habit_menuEdit => 'Edit';

  @override
  String get habit_menuAddNote => 'Add note for today';

  @override
  String get habit_menuAddNoteDay => 'Add note for this day';

  @override
  String get habit_menuSkipToday => 'Skip today';

  @override
  String habit_skipTodayHint(int count) {
    return 'Uses 1 of your $count freezes';
  }

  @override
  String get habit_noFreezesLeft => 'No freezes left';

  @override
  String get habit_menuArchive => 'Archive';

  @override
  String get habit_archived => 'Habit archived';

  @override
  String get habit_unchecked => 'Check-in removed';

  @override
  String get habit_skipped => 'Today skipped with a freeze';

  @override
  String get habit_olderEditsHint => 'Edit older days from the habit\'s page';

  @override
  String get habit_futureDayHint => 'Future days can\'t be checked in yet';

  @override
  String habit_dayRingLabel(String day, int done, int total) {
    return '$day, $done of $total done';
  }

  @override
  String habit_dayRingNone(String day) {
    return '$day, nothing scheduled';
  }

  @override
  String habit_valueEntryTitle(String name) {
    return 'Set value for $name';
  }

  @override
  String get habit_valueEntryHint => 'A whole number from 0 to 9,999';

  @override
  String get habit_valueEntryError => 'Enter a whole number from 0 to 9,999';

  @override
  String get habit_set => 'Set';

  @override
  String habit_markDoneLabel(String name) {
    return 'Mark $name done';
  }

  @override
  String habit_markNotDoneLabel(String name) {
    return 'Mark $name not done';
  }

  @override
  String habit_addOneLabel(String name) {
    return 'Add 1 to $name';
  }

  @override
  String habit_countLabel(String name, int value, int target, String unit) {
    return '$name, $value of $target $unit';
  }

  @override
  String habit_countLabelNoUnit(String name, int value, int target) {
    return '$name, $value of $target';
  }

  @override
  String habit_countValue(int value, int target, String unit) {
    return '$value / $target $unit';
  }

  @override
  String habit_countValueNoUnit(int value, int target) {
    return '$value / $target';
  }

  @override
  String habit_streakLabel(String streak) {
    return 'Current streak: $streak';
  }

  @override
  String get habit_statusDone => 'Done';

  @override
  String get habit_statusFreeze => 'Freeze day';

  @override
  String get habit_scheduleDaily => 'Daily';

  @override
  String habit_scheduleTimesPerWeek(int times, int left) {
    return '$times× per week · $left left';
  }

  @override
  String habit_scheduleTimesPerWeekMet(int times) {
    return '$times× per week · done';
  }

  @override
  String get habit_noteTitle => 'Note';

  @override
  String get habit_noteHint => 'Add a note';

  @override
  String get habit_noteSave => 'Save note';

  @override
  String get habit_noteSaved => 'Note saved';

  @override
  String get habit_detailTitle => 'Habit';

  @override
  String get habit_template_drinkWater => 'Drink water';

  @override
  String get habit_template_read => 'Read';

  @override
  String get habit_template_walk => 'Walk';

  @override
  String get habit_template_meditate => 'Meditate';

  @override
  String get habit_template_wakeUpEarly => 'Wake up early';

  @override
  String get habit_template_study => 'Study';

  @override
  String get habit_unit_glasses => 'glasses';

  @override
  String get habit_unit_pages => 'pages';

  @override
  String get habit_unit_minutes => 'minutes';

  @override
  String get habit_addTitle => 'New habit';

  @override
  String get habit_editTitle => 'Edit habit';

  @override
  String get habit_nameLabel => 'Name';

  @override
  String get habit_nameSuggestions => 'Suggestions';

  @override
  String get habit_iconLabel => 'Icon';

  @override
  String get habit_colorLabel => 'Color';

  @override
  String get habit_goalLabel => 'Goal type';

  @override
  String get habit_goalYesNo => 'Yes / No';

  @override
  String get habit_goalCount => 'Count';

  @override
  String get habit_goalLocked =>
      'The goal type can\'t be changed after the habit is created';

  @override
  String get habit_targetLabel => 'Target';

  @override
  String get habit_unitLabel => 'Unit (optional)';

  @override
  String get habit_scheduleLabel => 'Schedule';

  @override
  String get habit_scheduleEveryDay => 'Every day';

  @override
  String get habit_scheduleSpecificDays => 'Specific days';

  @override
  String get habit_scheduleXTimes => 'X times per week';

  @override
  String habit_timesPerWeekValue(int count) {
    return '$count× per week';
  }

  @override
  String get habit_decrease => 'Decrease';

  @override
  String get habit_increase => 'Increase';

  @override
  String get habit_startDate => 'Start date';

  @override
  String get habit_pickDate => 'Pick a date';

  @override
  String get habit_save => 'Save habit';

  @override
  String get habit_saved => 'Habit saved';

  @override
  String get habit_errNameRequired => 'Enter a name';

  @override
  String get habit_errNameTooLong => 'Use at most 40 characters';

  @override
  String get habit_errTargetRange => 'Enter a target from 1 to 9,999';

  @override
  String get habit_errUnitTooLong => 'Use at most 20 characters';

  @override
  String get habit_errWeekdayRequired => 'Choose at least one weekday';

  @override
  String get habit_errTimesRange => 'Choose 1 to 6 times per week';

  @override
  String get habit_deleteAction => 'Delete';

  @override
  String get habit_deleteTitle => 'Delete habit?';

  @override
  String habit_deleteBody(String name) {
    return 'This removes $name and all its history.';
  }

  @override
  String get habit_deleteConfirm => 'Delete habit';

  @override
  String get habit_deleted => 'Habit deleted';

  @override
  String get habit_discardTitle => 'Discard changes?';

  @override
  String get habit_discardBody => 'Your changes to this habit will be lost.';

  @override
  String get habit_discardConfirm => 'Discard';

  @override
  String get habit_notFound => 'This habit no longer exists';

  @override
  String get habit_reminders => 'Reminders';

  @override
  String get habit_addReminder => 'Add reminder';

  @override
  String habit_removeReminder(String time) {
    return 'Remove reminder at $time';
  }

  @override
  String get habit_remindOnlyIfNotDone => 'Remind me only if not done yet';

  @override
  String get habit_reminderLimit => 'You can add up to 3 reminders';

  @override
  String get habit_reminderDuplicate => 'This time is already added';

  @override
  String get habit_notificationsOffHint =>
      'Reminders need notification permission';

  @override
  String get habit_inexactHint => 'Reminders may be a few minutes late';

  @override
  String notif_habitReminderTitle(String name) {
    return '$name';
  }

  @override
  String notif_habitReminderBody(String name) {
    return 'Time for $name. You\'ve got this.';
  }

  @override
  String habit_milestoneTitleDays(int count) {
    return '$count-day streak!';
  }

  @override
  String habit_milestoneTitleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-week streak!',
      one: '1-week streak!',
    );
    return '$_temp0';
  }

  @override
  String get habit_milestoneBody => 'Every check-in adds up. Keep it going!';

  @override
  String get habit_shareStreak => 'Share streak';

  @override
  String get habit_close => 'Close';

  @override
  String get habit_shareCardFooter => 'Tracked with DailyTrack';

  @override
  String get habit_shareError => 'Couldn\'t share. Try again.';

  @override
  String get common_iconGroup_habits => 'Habits';

  @override
  String get icon_directions_walk => 'Walk';

  @override
  String get icon_directions_run => 'Run';

  @override
  String get icon_self_improvement => 'Meditation';

  @override
  String get icon_alarm => 'Alarm';

  @override
  String get icon_bedtime => 'Sleep';

  @override
  String get habit_statCurrent => 'Current streak';

  @override
  String get habit_statBest => 'Best streak';

  @override
  String get habit_statRate => 'Completion rate (last 30 days)';

  @override
  String get habit_statTotal => 'Total completions';

  @override
  String habit_rateValue(int percent) {
    return '$percent%';
  }

  @override
  String get habit_rateNone => '—';

  @override
  String get habit_calendarTitle => 'Calendar';

  @override
  String habit_dayDone(String date) {
    return '$date, done';
  }

  @override
  String habit_dayPartial(String date, int value, int target) {
    return '$date, $value of $target';
  }

  @override
  String habit_dayMissed(String date) {
    return '$date, missed';
  }

  @override
  String habit_dayFreeze(String date) {
    return '$date, freeze day';
  }

  @override
  String habit_dayOther(String date) {
    return '$date';
  }

  @override
  String get habit_dayHasNote => 'has a note';

  @override
  String get habit_heatmapTitle => 'Last 12 months';

  @override
  String habit_heatmapSummary(int done, int total) {
    return '$done of $total days done in the last 12 months';
  }

  @override
  String habit_heatmapMonth(String month, int done, int total) {
    return '$month: $done of $total days done';
  }

  @override
  String get habit_shareHeatmap => 'Share';

  @override
  String get habit_weeklyChartTitle => 'Completions per week';

  @override
  String habit_weeklyChartSummary(String items) {
    return 'Completions in the last 12 weeks: $items';
  }

  @override
  String habit_weeklyChartItem(String date, int count) {
    return 'week of $date $count';
  }

  @override
  String get habit_notesTitle => 'Notes';

  @override
  String get habit_notesEmpty => 'No notes yet';

  @override
  String get habit_freezeTitle => 'Streak freeze';

  @override
  String habit_freezesAvailable(int count) {
    return 'Freezes available: $count';
  }

  @override
  String get habit_freezeExplain =>
      'A freeze keeps your streak when you miss a day. Use it on a missed day up to 3 days back.';

  @override
  String get habit_useFreeze => 'Use a freeze';

  @override
  String habit_useFreezeOn(String date) {
    return 'Use a freeze on $date';
  }

  @override
  String get habit_noFreezeableDay => 'No missed day in the last 3 days';

  @override
  String get habit_freezeUsed => 'Freeze used';

  @override
  String get habit_addFreezeDebug => 'Add a freeze (debug)';

  @override
  String get habit_freezeCapReached => 'You can keep up to 2 freezes';

  @override
  String habit_editDayTitle(String date) {
    return 'Edit $date';
  }

  @override
  String get habit_dayDoneToggle => 'Done';

  @override
  String get habit_dayValueLabel => 'Value';

  @override
  String get habit_daySave => 'Save';

  @override
  String get habit_daySaved => 'Day saved';

  @override
  String get habit_edit => 'Edit';

  @override
  String get habit_previousMonth => 'Previous month';

  @override
  String get habit_nextMonth => 'Next month';

  @override
  String get habit_archivedTitle => 'Archived habits';

  @override
  String habit_archivedOn(String date) {
    return 'Archived $date';
  }

  @override
  String habit_bestStreakLabel(String streak) {
    return 'Best streak: $streak';
  }

  @override
  String get habit_restore => 'Restore';

  @override
  String get habit_restored => 'Habit restored';

  @override
  String get habit_deletePermanently => 'Delete permanently';

  @override
  String get habit_archivedEmpty => 'Archived habits appear here';

  @override
  String habit_doneTodayRing(int done, int total) {
    return '$done of $total done today';
  }

  @override
  String get habit_cardEmpty => 'Create your first habit';

  @override
  String get habit_cardNoneToday => 'Nothing scheduled today';

  @override
  String get habit_addOne => '+1';

  @override
  String get habit_customValue => 'Enter value';

  @override
  String get habit_loadDataError => 'Couldn\'t load habits';

  @override
  String get home_greetingMorning => 'Good morning';

  @override
  String get home_greetingAfternoon => 'Good afternoon';

  @override
  String get home_greetingEvening => 'Good evening';

  @override
  String get home_quickAddTooltip => 'Quick add';

  @override
  String get home_insightTitle => 'Tip for today';

  @override
  String get home_insightStarter =>
      'Log something today and tips will show up here';

  @override
  String get home_comingSoonTitle => 'Coming soon';

  @override
  String home_comingSoonBody(String names) {
    return '$names trackers are on the way';
  }

  @override
  String home_listPair(String first, String second) {
    return '$first and $second';
  }

  @override
  String get home_comingSoonDismiss => 'Dismiss';

  @override
  String get home_comingSoonDismissed => 'Card hidden';

  @override
  String get home_recentTitle => 'Recent transactions';

  @override
  String get home_seeAll => 'See all';

  @override
  String get expense_quickAddIncome => 'Add income';

  @override
  String get expense_cardAdd => 'Expense';

  @override
  String get expense_cardSetBudget => 'Set budget';

  @override
  String expense_cardMonthOfBudget(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String expense_insightCategoryHigher(String category, int percent) {
    return '$category spending is $percent% higher than last month';
  }

  @override
  String expense_insightCategoryLower(String category, int percent) {
    return '$category spending is $percent% lower than last month. Nice work.';
  }

  @override
  String expense_insightBudgetOnTrack(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'You\'re on track: $amount left for $_temp0';
  }

  @override
  String expense_insightBudgetNear(int percent) {
    return 'You\'ve used $percent% of this month\'s budget';
  }

  @override
  String expense_insightBudgetOver(String amount) {
    return 'You\'re $amount over this month\'s budget. A no-spend day helps.';
  }

  @override
  String expense_insightOpensReports(String text) {
    return 'Opens reports: $text';
  }

  @override
  String expense_insightOpensBudgets(String text) {
    return 'Opens budgets: $text';
  }

  @override
  String habit_insightNextMilestoneDays(int count, int milestone, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'You\'re $_temp0 away from a $milestone-day streak with $name';
  }

  @override
  String habit_insightNextMilestoneWeeks(
    int count,
    int milestone,
    String name,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return 'You\'re $_temp0 away from a $milestone-week streak with $name';
  }

  @override
  String habit_insightBestThisWeek(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return 'You\'ve done $name $_temp0 this week';
  }

  @override
  String habit_insightComebackDays(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best days',
      one: '1 day',
    );
    return 'Pick $name up again today. Your best is $_temp0.';
  }

  @override
  String habit_insightComebackWeeks(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best weeks',
      one: '1 week',
    );
    return 'Pick $name up again today. Your best is $_temp0.';
  }

  @override
  String habit_insightOpensHabit(String text, String name) {
    return 'Opens $name: $text';
  }

  @override
  String habit_streakBadgeLabelDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Best active streak: $_temp0';
  }

  @override
  String habit_streakBadgeLabelWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return 'Best active streak: $_temp0';
  }

  @override
  String habit_streakBadgeWeeksShort(int count) {
    return '$count wk';
  }

  @override
  String habit_uncheckedSnack(String name) {
    return '$name unchecked';
  }

  @override
  String get modules_moveUp => 'Move up';

  @override
  String get modules_moveDown => 'Move down';

  @override
  String get settings_general => 'General';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_modules => 'Modules';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_about => 'About';

  @override
  String get settings_loadError => 'Couldn\'t load your settings.';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_languageSystem => 'System default';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_firstDayOfWeek => 'First day of week';

  @override
  String get settings_monday => 'Monday';

  @override
  String get settings_saturday => 'Saturday';

  @override
  String get settings_sunday => 'Sunday';

  @override
  String get settings_dateFormat => 'Date format';

  @override
  String get settings_themeEntry => 'Theme and colors';

  @override
  String get settings_modulesEntry => 'Enable or reorder trackers';

  @override
  String get settings_notificationsMaster => 'Notifications';

  @override
  String get settings_dailySummaryTime => 'Daily summary time';

  @override
  String get settings_dailySummaryHelp => 'Did you log today\'s expenses?';

  @override
  String get settings_budgetAlerts => 'Budget alerts';

  @override
  String get settings_habitReminders => 'Habit reminders';

  @override
  String get settings_notificationsBlocked =>
      'Notifications are blocked for DailyTrack';

  @override
  String get settings_openSystemSettings => 'Open settings';

  @override
  String get settings_privacyPolicy => 'Privacy policy';

  @override
  String get settings_terms => 'Terms';

  @override
  String get settings_rateUs => 'Rate us';

  @override
  String get settings_shareApp => 'Share app';

  @override
  String settings_shareAppText(String url) {
    return 'I track my money and habits with DailyTrack: $url';
  }

  @override
  String get settings_sendFeedback => 'Send feedback';

  @override
  String settings_feedbackSubject(String version) {
    return 'DailyTrack feedback ($version)';
  }

  @override
  String settings_feedbackBody(
    String version,
    String build,
    String device,
    String android,
    String language,
  ) {
    return 'Write your feedback above this line.\n\nApp version: $version ($build)\nDevice: $device\nAndroid: $android\nDevice language: $language';
  }

  @override
  String settings_noEmailApp(String email) {
    return 'No email app found. Write to us at $email';
  }

  @override
  String get settings_copyEmail => 'Copy email';

  @override
  String get settings_emailCopied => 'Email copied';

  @override
  String get settings_close => 'Close';

  @override
  String get settings_appVersion => 'App version';

  @override
  String settings_appVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settings_licenses => 'Open-source licenses';

  @override
  String get web_loadError =>
      'Couldn\'t load this page. Check your connection and try again.';

  @override
  String get themes_title => 'Theme and colors';

  @override
  String get themes_mode => 'Theme mode';

  @override
  String get themes_system => 'System';

  @override
  String get themes_light => 'Light';

  @override
  String get themes_dark => 'Dark';

  @override
  String get themes_colors => 'Colors';

  @override
  String get themes_fontSize => 'Font size';

  @override
  String get themes_fontDefault => 'Default';

  @override
  String get themes_fontLarge => 'Large';

  @override
  String get themes_preview => 'Preview';

  @override
  String get themes_previewSpent => 'Spent this month';

  @override
  String get themes_previewChip => 'Groceries';

  @override
  String get themes_pro => 'Pro';

  @override
  String themes_tileSelected(String name) {
    return '$name, selected';
  }

  @override
  String themes_tileLocked(String name) {
    return '$name, Pro, locked';
  }

  @override
  String get themes_lockedMessage => 'Get Pro to use this theme';

  @override
  String get theme_default => 'Default teal';

  @override
  String get theme_indigo => 'Indigo';

  @override
  String get theme_saffron => 'Saffron';

  @override
  String get theme_forest => 'Forest';

  @override
  String get theme_rose => 'Rose';

  @override
  String get theme_midnight => 'Midnight';

  @override
  String get theme_ocean => 'Ocean';

  @override
  String get theme_mono => 'Mono';

  @override
  String get settings_security => 'Security';

  @override
  String get settings_appLockEntry => 'App lock';

  @override
  String get settings_on => 'On';

  @override
  String get settings_off => 'Off';

  @override
  String get security_title => 'Security';

  @override
  String get security_appLock => 'App lock';

  @override
  String get security_changePin => 'Change PIN';

  @override
  String get security_biometric => 'Use fingerprint / face unlock';

  @override
  String get security_needsLock => 'Turn on app lock first';

  @override
  String get security_biometricNotEnrolled =>
      'Set up fingerprint or face unlock in your phone\'s settings';

  @override
  String get security_biometricNone =>
      'This phone doesn\'t support fingerprint or face unlock';

  @override
  String get security_lockAfter => 'Lock after';

  @override
  String get security_immediately => 'Immediately';

  @override
  String get security_after1Min => 'After 1 minute';

  @override
  String get security_after5Min => 'After 5 minutes';

  @override
  String get security_hideInRecents => 'Hide app content in recents';

  @override
  String get security_hideInRecentsHelp => 'Also blocks screenshots.';

  @override
  String get security_lockOn => 'App lock is on';

  @override
  String get security_lockOff => 'App lock is off';

  @override
  String get security_pinChanged => 'PIN changed';

  @override
  String get lock_enterPin => 'Enter PIN';

  @override
  String get lock_wrongPin => 'Wrong PIN';

  @override
  String lock_attemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left',
      one: '1 attempt left',
    );
    return 'Wrong PIN. $_temp0';
  }

  @override
  String lock_tryAgainIn(String time) {
    return 'Try again in $time';
  }

  @override
  String lock_nextLockoutWarning(String time) {
    return 'Next wrong PIN locks the app for $time';
  }

  @override
  String get lock_credentialUnavailable =>
      'App lock can\'t be checked on this phone.';

  @override
  String get lock_biometricReason => 'Unlock DailyTrack';

  @override
  String get lock_useBiometric => 'Use fingerprint';

  @override
  String get lock_delete => 'Delete';

  @override
  String lock_dotsLabel(int count) {
    return '$count of 4 digits entered';
  }

  @override
  String get pin_enterCurrent => 'Enter current PIN';

  @override
  String get pin_enterNew => 'Enter new PIN';

  @override
  String get pin_confirmNew => 'Confirm new PIN';

  @override
  String get pin_mismatch => 'PINs don\'t match. Try again.';

  @override
  String get pin_offerBiometric => 'Use fingerprint / face unlock';

  @override
  String get pin_done => 'Done';

  @override
  String get pin_saveError => 'Couldn\'t save your PIN. Try again.';

  @override
  String get onboarding_setAppLock => 'Set app lock';

  @override
  String get onboarding_changePin => 'Change PIN';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_eraseAll => 'Erase all data';

  @override
  String get erase_title => 'Erase all data?';

  @override
  String get erase_body =>
      'This deletes your transactions, accounts, categories, budgets, recurring entries, habits and check-ins, settings, and app lock. This can\'t be undone.';

  @override
  String get erase_continue => 'Continue';

  @override
  String get erase_typeTitle => 'Type DELETE to confirm';

  @override
  String get erase_typeHint => 'DELETE';

  @override
  String get erase_confirm => 'Erase everything';

  @override
  String get erase_inProgress => 'Erasing…';

  @override
  String get erase_failed => 'Couldn\'t erase your data. Nothing was deleted.';

  @override
  String get lock_forgotPin => 'Forgot PIN?';

  @override
  String get lock_forgotTitle => 'Forgot your PIN?';

  @override
  String get lock_forgotBody =>
      'Your PIN can\'t be recovered. You can erase all data and start fresh.';

  @override
  String get currency_INR => 'Indian Rupee';

  @override
  String get currency_USD => 'US Dollar';

  @override
  String get currency_EUR => 'Euro';

  @override
  String get currency_GBP => 'British Pound';

  @override
  String get currency_AED => 'UAE Dirham';

  @override
  String get currency_SAR => 'Saudi Riyal';

  @override
  String get currency_QAR => 'Qatari Riyal';

  @override
  String get currency_KWD => 'Kuwaiti Dinar';

  @override
  String get currency_OMR => 'Omani Rial';

  @override
  String get currency_BHD => 'Bahraini Dinar';

  @override
  String get currency_SGD => 'Singapore Dollar';

  @override
  String get currency_MYR => 'Malaysian Ringgit';

  @override
  String get currency_THB => 'Thai Baht';

  @override
  String get currency_IDR => 'Indonesian Rupiah';

  @override
  String get currency_PHP => 'Philippine Peso';

  @override
  String get currency_JPY => 'Japanese Yen';

  @override
  String get currency_CNY => 'Chinese Yuan';

  @override
  String get currency_HKD => 'Hong Kong Dollar';

  @override
  String get currency_KRW => 'South Korean Won';

  @override
  String get currency_AUD => 'Australian Dollar';

  @override
  String get currency_NZD => 'New Zealand Dollar';

  @override
  String get currency_CAD => 'Canadian Dollar';

  @override
  String get currency_CHF => 'Swiss Franc';

  @override
  String get currency_SEK => 'Swedish Krona';

  @override
  String get currency_NOK => 'Norwegian Krone';

  @override
  String get currency_DKK => 'Danish Krone';

  @override
  String get currency_ZAR => 'South African Rand';

  @override
  String get currency_NPR => 'Nepalese Rupee';

  @override
  String get currency_BDT => 'Bangladeshi Taka';

  @override
  String get currency_LKR => 'Sri Lankan Rupee';
}
