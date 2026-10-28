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
      'Everything you log is kept on this phone. Next, you can back it up with Google or continue as a guest.';

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
  String get backup_title => 'Backup and restore';

  @override
  String get backup_lastBackupTitle => 'Last backup';

  @override
  String get backup_noBackupYet => 'No backup yet';

  @override
  String backup_lastBackupDetail(String date, String location, String size) {
    return '$date · $location · $size';
  }

  @override
  String get backup_locationDevice => 'This device';

  @override
  String get backup_locationDrive => 'Google Drive';

  @override
  String backup_lastBackupSubtitle(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backup_notBackedUp => 'Not backed up yet';

  @override
  String get backup_localTitle => 'Backup file';

  @override
  String get backup_localBody =>
      'Save all your data as one file on this phone, or restore from a file.';

  @override
  String get backup_saveFile => 'Save backup file';

  @override
  String get backup_restoreFile => 'Restore from file';

  @override
  String get backup_saved => 'Backup saved';

  @override
  String get backup_share => 'Share';

  @override
  String get backup_working => 'Creating backup…';

  @override
  String get backup_optionsTitle => 'Options';

  @override
  String get backup_encrypt => 'Encrypt backup';

  @override
  String get backup_encryptHelp => 'Protects backup files with a password';

  @override
  String get backup_changePassword => 'Change password';

  @override
  String get backup_includeReceipts => 'Include receipt images';

  @override
  String get backup_includeReceiptsHelp => 'Makes the backup file larger';

  @override
  String backup_countTransactions(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$_temp0';
  }

  @override
  String backup_countHabits(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString habits',
      one: '1 habit',
      zero: 'No habits',
    );
    return '$_temp0';
  }

  @override
  String get backup_passwordTitle => 'Set backup password';

  @override
  String get backup_passwordChangeTitle => 'Change backup password';

  @override
  String get backup_passwordField => 'Password';

  @override
  String get backup_passwordConfirm => 'Confirm password';

  @override
  String get backup_passwordWarning =>
      'If you lose this password, backups made with it can\'t be restored. It can\'t be recovered.';

  @override
  String get backup_passwordMismatch => 'Passwords don\'t match';

  @override
  String get backup_passwordSave => 'Save password';

  @override
  String get restore_passwordTitle => 'Enter backup password';

  @override
  String get restore_open => 'Open backup';

  @override
  String get restore_previewTitle => 'Restore this backup?';

  @override
  String restore_previewCreated(String date) {
    return 'Made on $date';
  }

  @override
  String restore_previewVersion(String version) {
    return 'App version $version';
  }

  @override
  String restore_previewReceipts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Includes $countString receipt images',
      one: 'Includes 1 receipt image',
    );
    return '$_temp0';
  }

  @override
  String get restore_previewSkipped =>
      'Some data in this backup is from a feature this version doesn\'t have. It will be skipped.';

  @override
  String get restore_continue => 'Continue';

  @override
  String get restore_confirmTitle => 'Replace current data?';

  @override
  String get restore_confirmBody =>
      'All your current transactions, accounts, categories, budgets, recurring entries, habits, check-ins, and preferences will be replaced by this backup. This can\'t be undone.';

  @override
  String get restore_confirmAction => 'Replace data';

  @override
  String get restore_inProgress => 'Restoring…';

  @override
  String get restore_done => 'Backup restored';

  @override
  String get restore_doneMissingReceipts =>
      'Backup restored, but some receipt images couldn\'t be copied.';

  @override
  String get restore_failedTitle => 'Couldn\'t restore';

  @override
  String get backup_failedTitle => 'Couldn\'t back up';

  @override
  String get backup_errNotRecognized =>
      'This isn\'t a DailyTrack backup. Nothing was changed.';

  @override
  String get backup_errDamaged =>
      'This backup file is damaged and can\'t be read. Nothing was changed.';

  @override
  String get backup_errInvalid =>
      'This backup has data DailyTrack can\'t use. Nothing was changed.';

  @override
  String get backup_errTooNew => 'Update DailyTrack to restore this backup.';

  @override
  String get backup_errWrongPassword => 'Wrong password or damaged file.';

  @override
  String get backup_errNeedsPassword =>
      'Set your backup password again to keep making encrypted backups.';

  @override
  String get backup_errTooLarge =>
      'This backup is too large to encrypt. Turn off receipt images and try again.';

  @override
  String get backup_errBusy =>
      'A backup or restore is already running. Try again in a moment.';

  @override
  String get backup_errStorage =>
      'There isn\'t enough storage on this phone. Free up some space and try again.';

  @override
  String get backup_errGeneric => 'Something went wrong. Nothing was changed.';

  @override
  String get backup_driveTitle => 'Google Drive';

  @override
  String get backup_driveBody =>
      'Back up to your own Google Drive. Backups are stored in a private app folder you won\'t see in your Drive files.';

  @override
  String get backup_driveUnavailable =>
      'Google Drive isn\'t available in this build.';

  @override
  String backup_connected(String email) {
    return 'Connected as $email';
  }

  @override
  String get backup_backUpNow => 'Back up now';

  @override
  String get backup_uploading => 'Backing up to Google Drive…';

  @override
  String get backup_driveSaved => 'Backed up to Google Drive';

  @override
  String get backup_autoTitle => 'Auto backup';

  @override
  String get backup_autoOff => 'Off';

  @override
  String get backup_autoDaily => 'Daily';

  @override
  String get backup_autoWeekly => 'Weekly';

  @override
  String get backup_wifiOnly => 'Wi-Fi only';

  @override
  String get backup_wifiOnlyHelp => 'Waits for Wi-Fi before backing up';

  @override
  String get backup_driveListTitle => 'Restore from Google Drive';

  @override
  String get backup_driveListEmpty => 'No backups in Google Drive yet';

  @override
  String get backup_driveListError =>
      'Couldn\'t load your Google Drive backups.';

  @override
  String backup_driveEntry(String date, String size) {
    return '$date · $size';
  }

  @override
  String get backup_kindManual => 'Manual';

  @override
  String get backup_kindAuto => 'Auto';

  @override
  String get backup_delete => 'Delete';

  @override
  String get backup_deleteTitle => 'Delete this backup?';

  @override
  String get backup_deleteBody =>
      'It will be removed from Google Drive. This can\'t be undone.';

  @override
  String get backup_deleteAction => 'Delete backup';

  @override
  String get backup_moreActions => 'More actions for this backup';

  @override
  String get backup_listLoading => 'Loading your backups…';

  @override
  String get backup_downloading => 'Downloading backup…';

  @override
  String get backup_errAuth =>
      'Your Google account needs to be connected again.';

  @override
  String get backup_reconnect => 'Reconnect Google account';

  @override
  String get backup_errQuota =>
      'Your Google Drive is full. Free up space in Drive and try again.';

  @override
  String get backup_errOffline =>
      'Couldn\'t reach Google Drive. Check your connection and try again.';

  @override
  String get backup_errDrive =>
      'Google Drive isn\'t responding right now. Try again later.';

  @override
  String get notif_channelBackup => 'Backup';

  @override
  String get notif_channelBackupDescription =>
      'Tells you when automatic backup keeps failing';

  @override
  String get notif_backupFailingTitle => 'Automatic backup isn\'t working';

  @override
  String get notif_backupFailingBody =>
      'Your last 3 backups to Google Drive failed. Tap to check.';

  @override
  String get lock_forgotBodyRestore =>
      'Your PIN can\'t be recovered. You can restore your data from a Google Drive backup, or erase all data and start fresh.';

  @override
  String get lock_restoreFromDrive => 'Restore from Google Drive backup';

  @override
  String get export_title => 'Export data';

  @override
  String get export_settingsHelp => 'CSV or PDF';

  @override
  String get export_dataType => 'Data';

  @override
  String get export_transactions => 'Transactions';

  @override
  String get export_habits => 'Habits';

  @override
  String get export_period => 'Period';

  @override
  String get export_format => 'Format';

  @override
  String get export_csv => 'CSV';

  @override
  String get export_pdf => 'PDF';

  @override
  String get export_filtersTitle => 'Filters';

  @override
  String get export_accounts => 'Accounts';

  @override
  String get export_categories => 'Categories';

  @override
  String get export_all => 'All';

  @override
  String export_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get export_filterDone => 'Apply';

  @override
  String get export_button => 'Export';

  @override
  String get export_working => 'Creating your file…';

  @override
  String get export_locked =>
      'Exports are part of DailyTrack Pro. Watch an ad for one export, or get Pro.';

  @override
  String get export_nothing => 'Nothing to export for this period';

  @override
  String get export_failedTitle => 'Couldn\'t export';

  @override
  String get export_failed =>
      'Couldn\'t create the file. Nothing was shared. Try again.';

  @override
  String get export_reportAction => 'Export this report';

  @override
  String get export_colDate => 'Date';

  @override
  String get export_colTime => 'Time';

  @override
  String get export_colType => 'Type';

  @override
  String get export_colCategory => 'Category';

  @override
  String get export_colAccount => 'Account';

  @override
  String get export_colPaymentMode => 'Payment mode';

  @override
  String get export_colAmount => 'Amount';

  @override
  String get export_colNote => 'Note';

  @override
  String get export_colHabit => 'Habit';

  @override
  String get export_colValue => 'Value';

  @override
  String get export_colTarget => 'Target';

  @override
  String get export_colUnit => 'Unit';

  @override
  String get export_colStatus => 'Status';

  @override
  String get export_statusDone => 'Done';

  @override
  String get export_statusPartial => 'Partial';

  @override
  String get export_statusFreeze => 'Freeze';

  @override
  String get export_totalIncome => 'Total income';

  @override
  String get export_totalExpense => 'Total expense';

  @override
  String get export_net => 'Net';

  @override
  String get export_count => 'Entries';

  @override
  String export_percent(int percent) {
    return '$percent% done';
  }

  @override
  String export_filterAccounts(String names) {
    return 'Accounts: $names';
  }

  @override
  String export_filterCategories(String names) {
    return 'Categories: $names';
  }

  @override
  String export_transfer(String from, String to) {
    return '$from → $to';
  }

  @override
  String get export_chartTitle => 'Spending by category';

  @override
  String get export_other => 'Other';

  @override
  String get export_summaryTitle => 'Summary';

  @override
  String export_pdfHeader(String title, String period) {
    return 'DailyTrack · $title · $period';
  }

  @override
  String export_page(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get notif_channelDailySummary => 'Daily summary';

  @override
  String get notif_channelDailySummaryDescription =>
      'Your spending and habits for the day';

  @override
  String get notif_dailySummaryTitle => 'Today in DailyTrack';

  @override
  String notif_dailySummaryBoth(String amount, int done, int total) {
    return 'Spent $amount today · $done/$total habits done';
  }

  @override
  String notif_dailySummarySpend(String amount) {
    return 'Spent $amount today';
  }

  @override
  String notif_dailySummaryHabits(int done, int total) {
    return '$done/$total habits done';
  }

  @override
  String get notif_actionMarkDone => 'Mark done';

  @override
  String get notif_actionSnooze => 'Snooze 1 h';

  @override
  String get settings_exactNote => 'Reminders may arrive a few minutes late';

  @override
  String get settings_exactAllow => 'Allow exact timing';

  @override
  String get security_showWidgetData => 'Show data on widget';

  @override
  String get security_showWidgetDataHelp =>
      'Shows amounts and habit names on your home screen';

  @override
  String get widget_label => 'DailyTrack today';

  @override
  String get widget_description =>
      'Today\'s spending, budget, and habit checks';

  @override
  String get widget_open => 'Open DailyTrack';

  @override
  String get widget_spentToday => 'Spent today';

  @override
  String widget_spentTodayA11y(String amount) {
    return 'Spent today, $amount';
  }

  @override
  String widget_monthBudget(String month) {
    return '$month budget';
  }

  @override
  String widget_budgetText(int percent, String spent, String limit) {
    return '$percent% used · $spent of $limit';
  }

  @override
  String get widget_noBudget => 'No budget set';

  @override
  String widget_progress(int value, int target) {
    return '$value / $target';
  }

  @override
  String widget_progressUnit(int value, int target, String unit) {
    return '$value / $target $unit';
  }

  @override
  String widget_habitDoneA11y(String name) {
    return '$name, done';
  }

  @override
  String widget_habitTodoA11y(String name) {
    return '$name, not done. Double tap to mark done';
  }

  @override
  String widget_habitCountA11y(String name, String progress) {
    return '$name, $progress. Double tap to add one';
  }

  @override
  String get ads_badge => 'Ad';

  @override
  String get ads_bannerLabel => 'Advertisement';

  @override
  String get privacy_adChoices => 'Ad privacy choices';

  @override
  String get ads_resetCounters => 'Reset ad counters';

  @override
  String get ads_resetCountersDone => 'Ad counters reset';

  @override
  String get premium_title => 'DailyTrack Pro';

  @override
  String get premium_benefitNoAds => 'No ads';

  @override
  String get premium_benefitThemes => 'All themes';

  @override
  String get premium_benefitReports => 'Advanced reports';

  @override
  String get premium_benefitExports => 'Unlimited exports';

  @override
  String get premium_benefitFreezes => 'Unlimited streak freezes up to the cap';

  @override
  String get rewarded_titleReports => 'Unlock advanced reports for 24 hours';

  @override
  String get rewarded_titleCsv => 'Unlock one CSV export';

  @override
  String get rewarded_titlePdf => 'Unlock one PDF export';

  @override
  String rewarded_titleTheme(String theme) {
    return 'Unlock the $theme theme for good';
  }

  @override
  String rewarded_titleFreeze(String habit) {
    return 'Get 1 streak freeze for $habit';
  }

  @override
  String get rewarded_explainReports =>
      'Watch a short ad to see Trends, Accounts, and every period for the next 24 hours.';

  @override
  String get rewarded_explainExport =>
      'Watch a short ad to create one export file in this format.';

  @override
  String get rewarded_explainTheme =>
      'Watch a short ad to keep this color theme for good.';

  @override
  String get rewarded_explainFreeze =>
      'Watch a short ad to add one streak freeze to this habit (up to 2).';

  @override
  String get rewarded_watch => 'Watch a short ad';

  @override
  String get rewarded_getPro => 'Get Pro instead';

  @override
  String get rewarded_notNow => 'Not now';

  @override
  String get rewarded_loadingAd => 'Loading ad';

  @override
  String get rewarded_unavailable => 'Ad not available, try again later';

  @override
  String get rewarded_tryAgain => 'Try again';

  @override
  String get rewarded_closedEarly => 'Watch the whole ad to unlock';

  @override
  String get rewarded_limitReached =>
      'You\'ve reached today\'s limit for this unlock. Try again tomorrow, or get Pro.';

  @override
  String get locked_watchAdReports => 'Watch an ad to unlock for 24 hours';

  @override
  String get locked_watchAdExport => 'Watch an ad to unlock one export';

  @override
  String get locked_watchAdTheme => 'Watch an ad to unlock this theme';

  @override
  String get locked_watchAdFreeze => 'Watch an ad to get a freeze';

  @override
  String premium_buyFor(String price) {
    return 'Get Pro for $price';
  }

  @override
  String get premium_restore => 'Restore purchase';

  @override
  String get premium_restored => 'Pro restored';

  @override
  String get premium_restoreNotFound =>
      'No Pro purchase found for this Google account';

  @override
  String get premium_storeUnavailable =>
      'Store not available right now, try again later';

  @override
  String get premium_accountNote =>
      'Your purchase is tied to your Google account.';

  @override
  String get premium_pending => 'Pro unlocks when the payment completes';

  @override
  String get premium_purchaseError =>
      'Couldn\'t complete the purchase. Try again.';

  @override
  String get premium_owned => 'You have Pro. Thanks for your support.';

  @override
  String get premium_cardTitle => 'Remove ads and unlock everything';

  @override
  String get premium_cardSubtitle =>
      'DailyTrack Pro: one purchase, yours for good';

  @override
  String get habit_addFreezePro => 'Add a freeze';

  @override
  String get more_seedTransactions => 'Seed 10,000 transactions';

  @override
  String get more_seedConfirm =>
      'Add 10,000 sample transactions to test performance? They are real entries and stay until you delete them or erase all data.';

  @override
  String get more_seedAdd => 'Add';

  @override
  String more_seedDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Added $countString transactions';
  }

  @override
  String get more_seedBusy =>
      'A backup or restore is running. Try again when it finishes.';

  @override
  String get account_title => 'Account';

  @override
  String get account_signedOutTitle => 'Back up with your Google account';

  @override
  String get account_pointDrive =>
      'Your data is saved to your own Google Drive';

  @override
  String get account_pointRestore => 'Restore it on a new phone';

  @override
  String get account_pointOptional =>
      'Optional: the app works fully without an account';

  @override
  String get account_signIn => 'Sign in with Google';

  @override
  String get account_pinFootnote => 'Your app lock PIN is never backed up.';

  @override
  String get account_signInFailed =>
      'Couldn\'t sign in. Check your connection and try again.';

  @override
  String get account_restoreOffline => 'Connect to the internet to restore';

  @override
  String get account_signInOffline =>
      'Connect to the internet to sign in with Google';

  @override
  String get account_signedInBackedUp => 'Signed in. Your data is backed up.';

  @override
  String account_lastBackupFrom(String time, String device) {
    return 'Last backup: $time · $device';
  }

  @override
  String account_lastBackup(String time) {
    return 'Last backup: $time';
  }

  @override
  String get account_noBackupYet => 'No backup in this account yet';

  @override
  String get account_statusBackedUp => 'Backed up to Google';

  @override
  String get account_statusOffline =>
      'You\'re offline. Backups resume when you\'re back online.';

  @override
  String get account_statusWaitingForWifi => 'Waiting for Wi-Fi';

  @override
  String get account_statusFailedNoPassword =>
      'Backup failed: set your backup password in Backup and restore';

  @override
  String get account_signOutBackedUp => 'Backed up';

  @override
  String get account_statusBackingUp => 'Backing up…';

  @override
  String get account_statusPaused =>
      'Backup paused: a newer backup from another phone exists';

  @override
  String get account_statusFailed => 'Backup failed';

  @override
  String get account_statusError => 'Couldn\'t read your backups.';

  @override
  String account_autoSummaryWifi(String frequency) {
    return '$frequency · Wi-Fi only';
  }

  @override
  String get account_signOut => 'Sign out';

  @override
  String get account_signedOut =>
      'Signed out. Your data is still on this phone.';

  @override
  String get account_deleteBackups => 'Delete my backups';

  @override
  String get account_deleteTitle => 'Delete your backups?';

  @override
  String account_deleteBody(int count, String email) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Delete all $countString DailyTrack backups from $email? Data on this phone stays. This can\'t be undone.',
      one:
          'Delete 1 DailyTrack backup from $email? Data on this phone stays. This can\'t be undone.',
    );
    return '$_temp0';
  }

  @override
  String get account_deleteAction => 'Delete backups';

  @override
  String get account_deleted => 'Your backups were deleted';

  @override
  String account_photoOf(String name) {
    return 'Profile photo of $name';
  }

  @override
  String get backup_manageAccount => 'Manage your account';

  @override
  String get backup_conflictTitle => 'Back up anyway?';

  @override
  String backup_conflictNewer(String device, String time) {
    return 'A newer backup from $device ($time) exists. Backing up now makes this phone\'s data the latest.';
  }

  @override
  String get backup_conflictEmpty =>
      'This phone has no data. Backing up now makes an empty backup the latest.';

  @override
  String get backup_backUpAnyway => 'Back up anyway';

  @override
  String get backup_unknownDevice => 'Unknown device';

  @override
  String get account_androidPhone => 'Android phone';

  @override
  String get notif_backupPausedTitle => 'Backup paused';

  @override
  String get notif_backupPausedBody =>
      'Another phone made a newer backup. Tap to review.';

  @override
  String account_choiceTitle(String email) {
    return 'Backup found on $email';
  }

  @override
  String get account_fromThisPhone => 'From this phone';

  @override
  String account_fromDevice(String device) {
    return 'From $device';
  }

  @override
  String get account_encrypted => 'Encrypted';

  @override
  String account_thisPhone(String counts) {
    return 'This phone: $counts';
  }

  @override
  String get account_thisPhoneEmpty => 'This phone: no data yet';

  @override
  String get account_replaceNote =>
      'Restoring replaces the data on this phone.';

  @override
  String get account_restoreFromAccount => 'Restore from account';

  @override
  String get account_keepThisPhone => 'Keep this phone\'s data';

  @override
  String get account_seeAllBackups => 'See all backups';

  @override
  String get account_close => 'Close';

  @override
  String get account_wrongPassword => 'That password didn\'t work';

  @override
  String get account_restoreFailed =>
      'Couldn\'t restore. Your data on this phone wasn\'t changed.';

  @override
  String get account_safetyCopyFailed =>
      'Not enough free space to save a copy of this phone\'s data first, so nothing was restored. Free up space and try again.';

  @override
  String account_restoredCounts(String summary) {
    return 'Restored $summary';
  }

  @override
  String get account_restoring => 'Restoring your data…';

  @override
  String get account_restore => 'Restore';

  @override
  String get account_review => 'Review';

  @override
  String get account_switch => 'Switch account';

  @override
  String get account_switchFailedTitle => 'Couldn\'t back up first';

  @override
  String account_switchFailedBody(String email) {
    return 'Your latest changes aren\'t in $email yet. Switch anyway? Your data stays on this phone.';
  }

  @override
  String get account_switchAnyway => 'Switch anyway';

  @override
  String get account_sessionExpired =>
      'Your Google sign-in expired. Sign in again to keep backing up.';

  @override
  String account_signOutSheetTitle(String email) {
    return 'Sign out of $email?';
  }

  @override
  String get account_signOutBackingUp => 'Backing up your latest changes…';

  @override
  String get account_signOutBackupFailed =>
      'Couldn\'t back up your latest changes';

  @override
  String get account_signOutAnyway => 'Sign out anyway';

  @override
  String get account_keepData => 'Keep data on this phone';

  @override
  String get account_keepDataHelp =>
      'You can keep using the app without an account.';

  @override
  String get account_removeData => 'Remove data from this phone';

  @override
  String get account_removeDataHelp =>
      'Your backup stays in your Google account.';

  @override
  String get auth_title => 'Keep your data safe';

  @override
  String get auth_body =>
      'Sign in with Google to back up your expenses and habits and get them back on a new phone.';

  @override
  String get auth_continueWithGoogle => 'Continue with Google';

  @override
  String get auth_continueAsGuest => 'Continue as guest';

  @override
  String get auth_guestNote =>
      'As a guest, your data stays only on this phone.';

  @override
  String get auth_signInCancelled =>
      'Sign-in was cancelled. Try again or continue as a guest.';

  @override
  String get auth_offline =>
      'You\'re offline. Connect to the internet to sign in with Google, or continue as a guest.';

  @override
  String get auth_continueWithoutRestoring => 'Continue without restoring';

  @override
  String get accountCard_guestTitle => 'Guest · Data saved only on this phone';

  @override
  String accountCard_backedUp(String time) {
    return 'Backed up to Google · $time';
  }

  @override
  String get accountCard_paused => 'Backup paused';

  @override
  String get accountCard_justNow => 'just now';

  @override
  String accountCard_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String accountCard_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String accountCard_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }

  @override
  String get settings_logOutGuest => 'Log out of guest';

  @override
  String get logOutGuest_title => 'Log out and delete your data?';

  @override
  String get logOutGuest_body =>
      'As a guest, your data is stored only on this phone. Logging out permanently deletes all your expenses, habits, budgets, receipts, and unlocks. This can\'t be undone.';

  @override
  String get logOutGuest_signInInstead => 'Sign in with Google instead';

  @override
  String get logOutGuest_confirm => 'Log out and delete';

  @override
  String get logOutGuest_failed => 'Couldn\'t delete your data. Try again.';

  @override
  String get finishSetup_title => 'Finish setting up';

  @override
  String get finishSetup_body =>
      'Your data is back. Your app lock PIN is never backed up, so set a new one to keep your data private.';

  @override
  String get finishSetup_setLock => 'Set app lock';

  @override
  String get finishSetup_allowNotifications => 'Allow notifications';

  @override
  String get finishSetup_notNow => 'Not now';

  @override
  String get backup_previousTitle => 'Restore previous phone data';

  @override
  String backup_previousDetail(String date, String counts) {
    return 'Saved $date · $counts';
  }

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
