import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// App name; not translated.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack'**
  String get appName;

  /// Button: go to next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// Button: go to previous step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// Button: skip onboarding with defaults.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// Button: retry a failed action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Default ErrorState button label.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_tryAgain;

  /// Label for modules not yet available.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get common_comingSoon;

  /// Placeholder screen message.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later update'**
  String get common_placeholderMessage;

  /// PeriodSelector back arrow label.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get common_previousMonth;

  /// PeriodSelector forward arrow label.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get common_nextMonth;

  /// Snackbar undo action.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get common_undo;

  /// ConfirmDialog cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// NumericKeypad backspace key label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keypad_backspace;

  /// NumericKeypad done key.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get keypad_done;

  /// LockedFeatureOverlay lock badge semantic label.
  ///
  /// In en, this message translates to:
  /// **'Pro feature, locked'**
  String get premium_lockedLabel;

  /// Bottom nav: Home tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// Bottom nav: Expenses tab.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get nav_expenses;

  /// Bottom nav: Habits tab.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get nav_habits;

  /// Bottom nav: More tab.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get nav_more;

  /// SYS-01 error when local storage fails to open.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your data. Try again.'**
  String get splash_errorMessage;

  /// SYS-02 step 1 headline.
  ///
  /// In en, this message translates to:
  /// **'Track money and habits in one place'**
  String get onboarding_welcomeTitle;

  /// SYS-02 step 1 language chips label.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboarding_languageLabel;

  /// SYS-02 step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Choose your currency'**
  String get onboarding_currencyTitle;

  /// SYS-02 step 2 search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get onboarding_currencySearchHint;

  /// SYS-02 currency search empty result.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get onboarding_noMatches;

  /// SYS-02 button to clear the currency search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get onboarding_clearSearch;

  /// SYS-02 step 3 title.
  ///
  /// In en, this message translates to:
  /// **'What do you want to track?'**
  String get onboarding_modulesTitle;

  /// SYS-02 message when the user tries to turn off the last module.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one tracker on'**
  String get onboarding_atLeastOneModule;

  /// SYS-02 step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Your data stays with you'**
  String get onboarding_privacyTitle;

  /// SYS-02 step 4 body: data stays on this phone; AUTH-01 comes next.
  ///
  /// In en, this message translates to:
  /// **'Everything you log is kept on this phone. Next, you can back it up with Google or continue as a guest.'**
  String get onboarding_privacyBody;

  /// SYS-02 step 4 button.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboarding_allowNotifications;

  /// Shown after permission is granted.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get onboarding_notificationsGranted;

  /// Shown after permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. You can turn them on later in Settings.'**
  String get onboarding_notificationsDenied;

  /// SYS-02 primary button on the last step.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_getStarted;

  /// SYS-02 error when saving onboarding settings fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your choices. Try again.'**
  String get onboarding_saveError;

  /// SYS-02 progress label.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboarding_stepLabel(int current, int total);

  /// SET-06 screen title.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules_title;

  /// Expense module name.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get modules_expense;

  /// Habit module name.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get modules_habit;

  /// Water module name (coming soon).
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get modules_water;

  /// Period module name (coming soon).
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get modules_period;

  /// SET-06 message when the user tries to turn off the last module.
  ///
  /// In en, this message translates to:
  /// **'At least one module must stay on'**
  String get modules_atLeastOne;

  /// SET-06 error state when settings cannot be read or written.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load or save your modules. Try again.'**
  String get modules_errorMessage;

  /// Semantic label for a module drag handle.
  ///
  /// In en, this message translates to:
  /// **'Reorder {name}'**
  String modules_reorderHandle(String name);

  /// More tab entry that opens SET-06.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get more_modulesEntry;

  /// SYS-03 placeholder title.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack is locked'**
  String get lock_title;

  /// SYS-03 placeholder message.
  ///
  /// In en, this message translates to:
  /// **'Unlock is coming in a later update'**
  String get lock_placeholderMessage;

  /// LockedFeatureOverlay action.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad'**
  String get premium_watchAd;

  /// LockedFeatureOverlay action.
  ///
  /// In en, this message translates to:
  /// **'Get Pro'**
  String get premium_getPro;

  /// Language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// Language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get language_hi;

  /// Language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get language_gu;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get expense_cat_food;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get expense_cat_groceries;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expense_cat_transport;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get expense_cat_fuel;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get expense_cat_shopping;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get expense_cat_bills;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expense_cat_rent;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get expense_cat_health;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get expense_cat_education;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get expense_cat_entertainment;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get expense_cat_travel;

  /// Default expense category.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expense_cat_other;

  /// Default income category.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get income_cat_salary;

  /// Default income category.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get income_cat_business;

  /// Default income category.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get income_cat_gift;

  /// Default income category.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get income_cat_interest;

  /// Default income category.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get income_cat_other;

  /// Default account.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get expense_account_cash;

  /// PeriodSelector back arrow (day).
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get common_previousDay;

  /// PeriodSelector forward arrow (day).
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get common_nextDay;

  /// PeriodSelector back arrow (week).
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get common_previousWeek;

  /// PeriodSelector forward arrow (week).
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get common_nextWeek;

  /// PeriodSelector back arrow (year).
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get common_previousYear;

  /// PeriodSelector forward arrow (year).
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get common_nextYear;

  /// Relative day label.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// Relative day label.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// PeriodPickerSheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose a period'**
  String get common_periodTitle;

  /// Period kind.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get common_periodDay;

  /// Period kind.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get common_periodWeek;

  /// Period kind.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get common_periodMonth;

  /// Period kind.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get common_periodYear;

  /// Period kind.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get common_periodCustom;

  /// Transaction type.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense_typeExpense;

  /// Transaction type.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get expense_typeIncome;

  /// Transaction type.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get expense_typeTransfer;

  /// Payment mode.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get expense_payCash;

  /// Payment mode.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get expense_payUpi;

  /// Payment mode.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get expense_payCard;

  /// Payment mode.
  ///
  /// In en, this message translates to:
  /// **'Net banking'**
  String get expense_payNetBanking;

  /// Payment mode.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expense_payOther;

  /// Account type.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get expense_accountTypeCash;

  /// Account type.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get expense_accountTypeBank;

  /// Account type.
  ///
  /// In en, this message translates to:
  /// **'UPI wallet'**
  String get expense_accountTypeUpi;

  /// Account type.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get expense_accountTypeCard;

  /// Account type.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get expense_accountTypeWallet;

  /// Snackbar after saving a transaction.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get expense_saved;

  /// Snackbar after deleting a transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get expense_deleted;

  /// Error state of expense screens.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your transactions. Try again.'**
  String get expense_loadError;

  /// EXP-02 save failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Your changes are still here. Try again.'**
  String get expense_saveError;

  /// Home Expense card.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get expense_spentToday;

  /// Home Expense card.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get expense_thisMonth;

  /// Global quick-add action.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expense_quickAdd;

  /// EXP-02 title (new).
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get expense_addTitle;

  /// EXP-02 title (edit).
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get expense_editTitle;

  /// EXP-02 save button.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get expense_saveExpense;

  /// EXP-02 save button.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get expense_saveIncome;

  /// EXP-02 save button.
  ///
  /// In en, this message translates to:
  /// **'Save transfer'**
  String get expense_saveTransfer;

  /// EXP-02 long-press save option.
  ///
  /// In en, this message translates to:
  /// **'Save and add another'**
  String get expense_saveAndAddAnother;

  /// EXP-02 transfer source chip.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String expense_fromAccount(String account);

  /// EXP-02 transfer destination chip.
  ///
  /// In en, this message translates to:
  /// **'To {account}'**
  String expense_toAccount(String account);

  /// EXP-02 empty transfer destination chip.
  ///
  /// In en, this message translates to:
  /// **'Choose where to move it'**
  String get expense_chooseToAccount;

  /// Account picker title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get expense_account;

  /// EXP-02 section label.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get expense_paymentMode;

  /// EXP-02 section label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expense_category;

  /// EXP-02 amount field label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expense_amount;

  /// EXP-02 date chip.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get expense_pickDate;

  /// EXP-02 time chip.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get expense_pickTime;

  /// EXP-02 note field.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get expense_noteLabel;

  /// EXP-02 note counter.
  ///
  /// In en, this message translates to:
  /// **'{count}/200'**
  String expense_noteLimit(int count);

  /// EXP-02 receipt section.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt'**
  String get expense_attachReceipt;

  /// EXP-02 receipt source.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get expense_camera;

  /// EXP-02 receipt source.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get expense_gallery;

  /// EXP-02 remove receipt.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt'**
  String get expense_removeReceipt;

  /// EXP-02 receipt failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t attach the photo. Try again.'**
  String get expense_receiptError;

  /// EXP-02 category grid '+ New' tile.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get expense_newCategory;

  /// EXP-02 empty state.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Add one to continue'**
  String get expense_noCategories;

  /// EXP-02 back with changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get expense_discardTitle;

  /// EXP-02 discard dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this transaction will be lost.'**
  String get expense_discardBody;

  /// EXP-02 discard dialog button.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get expense_discardConfirm;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get expense_errAmountRequired;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Amount can be at most {max}'**
  String expense_errAmountTooLarge(String max);

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Check the calculation'**
  String get expense_errAmountInvalid;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get expense_errCategoryRequired;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Choose an account to move money to'**
  String get expense_errToAccountRequired;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get expense_errSameAccount;

  /// EXP-02 validation.
  ///
  /// In en, this message translates to:
  /// **'Notes can be up to 200 characters'**
  String get expense_errNoteTooLong;

  /// Entry deleted elsewhere.
  ///
  /// In en, this message translates to:
  /// **'This transaction no longer exists'**
  String get expense_noLongerExists;

  /// Delete icon label.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get expense_deleteAction;

  /// EXP-01 title.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expense_listTitle;

  /// EXP-01 search.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get expense_search;

  /// EXP-01 close search.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get expense_closeSearch;

  /// EXP-01 filter action.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get expense_filter;

  /// EXP-01 overflow item.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get expense_menuCategories;

  /// EXP-01 overflow item.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get expense_menuAccounts;

  /// Summary strip.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get expense_income;

  /// Summary strip.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense_expense;

  /// Summary strip.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get expense_net;

  /// EXP-01 empty period.
  ///
  /// In en, this message translates to:
  /// **'No transactions in {period}'**
  String expense_emptyPeriod(String period);

  /// EXP-01 empty action and FAB.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expense_addExpense;

  /// EXP-01 filtered empty.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get expense_noMatches;

  /// EXP-01 filtered empty action.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get expense_clearFilters;

  /// Row and detail action.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get expense_duplicate;

  /// Row action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expense_delete;

  /// Transfer row title.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String expense_transferLabel(String from, String to);

  /// EXP-03 title.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get expense_detailTitle;

  /// EXP-03 action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get expense_edit;

  /// EXP-03 action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get expense_share;

  /// EXP-03 receipt label.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get expense_receipt;

  /// Missing receipt file.
  ///
  /// In en, this message translates to:
  /// **'Receipt not available'**
  String get expense_receiptMissing;

  /// Close the receipt viewer.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get expense_close;

  /// EXP-03 share text.
  ///
  /// In en, this message translates to:
  /// **'{type}: {amount}\n{category} · {account}\n{date}'**
  String expense_shareText(
    String type,
    String amount,
    String category,
    String account,
    String date,
  );

  /// EXP-03 share text note line.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String expense_shareNote(String note);

  /// Filter sheet title.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get expense_filterTitle;

  /// Filter sheet section.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get expense_filterType;

  /// Filter sheet field.
  ///
  /// In en, this message translates to:
  /// **'Min amount'**
  String get expense_filterAmountMin;

  /// Filter sheet field.
  ///
  /// In en, this message translates to:
  /// **'Max amount'**
  String get expense_filterAmountMax;

  /// Filter sheet button.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get expense_applyFilters;

  /// Filter chip delete label.
  ///
  /// In en, this message translates to:
  /// **'Remove filter {name}'**
  String expense_removeFilter(String name);

  /// Amount filter chip.
  ///
  /// In en, this message translates to:
  /// **'≥ {amount}'**
  String expense_amountAtLeast(String amount);

  /// Amount filter chip.
  ///
  /// In en, this message translates to:
  /// **'≤ {amount}'**
  String expense_amountAtMost(String amount);

  /// Amount filter chip.
  ///
  /// In en, this message translates to:
  /// **'{min} – {max}'**
  String expense_amountBetween(String min, String max);

  /// EXP-01 row subtitle: account and payment mode.
  ///
  /// In en, this message translates to:
  /// **'{account} · {mode}'**
  String expense_accountAndMode(String account, String mode);

  /// EXP-02 amount spoken label.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String expense_amountValue(String amount);

  /// ColorPickerRow swatch label.
  ///
  /// In en, this message translates to:
  /// **'Color {index} of {total}'**
  String common_colorLabel(int index, int total);

  /// IconPickerGrid label.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get common_iconPicker;

  /// ColorPickerRow label.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get common_colorPicker;

  /// EXP-04 title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get expense_categoriesTitle;

  /// EXP-05 title (new).
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get expense_newCategoryTitle;

  /// EXP-05 title (edit).
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get expense_editCategoryTitle;

  /// EXP-04 hidden section.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get expense_hiddenSection;

  /// EXP-04 action.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get expense_hide;

  /// EXP-04 action.
  ///
  /// In en, this message translates to:
  /// **'Show again'**
  String get expense_unhide;

  /// EXP-04 action.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get expense_rename;

  /// EXP-04 action.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get expense_deleteCategory;

  /// EXP-04 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get expense_categoryDeleted;

  /// EXP-04 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Category hidden'**
  String get expense_categoryHidden;

  /// EXP-04 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Category shown again'**
  String get expense_categoryShown;

  /// Replacement sheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose a new category'**
  String get expense_moveTitle;

  /// Replacement sheet body.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Move 1 transaction to the category you choose.} other{Move {count} transactions to the category you choose.}}'**
  String expense_moveBody(int count);

  /// Replacement sheet button.
  ///
  /// In en, this message translates to:
  /// **'Move and delete'**
  String get expense_moveConfirm;

  /// EXP-05 name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get expense_categoryName;

  /// EXP-05 name hint.
  ///
  /// In en, this message translates to:
  /// **'Up to 30 characters'**
  String get expense_nameLimit;

  /// EXP-05 validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get expense_errNameRequired;

  /// EXP-05 validation.
  ///
  /// In en, this message translates to:
  /// **'Names can be up to 30 characters'**
  String get expense_errNameTooLong;

  /// EXP-05 validation.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get expense_errNameDuplicate;

  /// EXP-05 validation.
  ///
  /// In en, this message translates to:
  /// **'Choose a different name'**
  String get expense_errNameReserved;

  /// EXP-05/07 section.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get expense_icon;

  /// EXP-05/07 section.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get expense_color;

  /// EXP-05/07 section.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get expense_type;

  /// EXP-05 button.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get expense_saveCategory;

  /// EXP-04 drag handle label.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder {name}'**
  String expense_reorderHandle(String name);

  /// EXP-04 reorder failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the new order. Try again.'**
  String get expense_reorderError;

  /// EXP-04 empty tab.
  ///
  /// In en, this message translates to:
  /// **'No categories here yet'**
  String get expense_noCategoriesHere;

  /// EXP-04 FAB and empty action.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get expense_addCategory;

  /// Generic load error (categories, accounts, Home card).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this screen. Try again.'**
  String get expense_loadDataError;

  /// EXP-06 title.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get expense_accountsTitle;

  /// EXP-07 title (new).
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get expense_newAccountTitle;

  /// EXP-07 title (edit).
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get expense_editAccountTitle;

  /// EXP-06 total card.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get expense_totalBalance;

  /// EXP-06 archived section.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get expense_archivedSection;

  /// EXP-06 action.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get expense_archive;

  /// EXP-06 action.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get expense_unarchive;

  /// EXP-06 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Account archived'**
  String get expense_accountArchived;

  /// EXP-06 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Account restored'**
  String get expense_accountRestored;

  /// EXP-06 action.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get expense_deleteAccount;

  /// EXP-06 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get expense_accountDeleted;

  /// EXP-06 last-active guard (Q3).
  ///
  /// In en, this message translates to:
  /// **'You need at least one active account'**
  String get expense_lastAccountHelp;

  /// EXP-06 delete explanation.
  ///
  /// In en, this message translates to:
  /// **'Accounts with transactions can be archived, not deleted'**
  String get expense_accountHasTransactions;

  /// EXP-07 name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get expense_accountName;

  /// EXP-07 type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get expense_accountType;

  /// EXP-07 opening balance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get expense_openingBalance;

  /// EXP-07 sign toggle (+).
  ///
  /// In en, this message translates to:
  /// **'Positive balance'**
  String get expense_balancePositive;

  /// EXP-07 sign toggle (−).
  ///
  /// In en, this message translates to:
  /// **'Negative balance, for example a card you owe on'**
  String get expense_balanceNegative;

  /// EXP-07 button.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get expense_saveAccount;

  /// EXP-07 validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get expense_errAccountNameRequired;

  /// EXP-07 validation.
  ///
  /// In en, this message translates to:
  /// **'Names can be up to 40 characters'**
  String get expense_errAccountNameTooLong;

  /// EXP-07 validation.
  ///
  /// In en, this message translates to:
  /// **'Balance must be between {min} and {max}'**
  String expense_errBalanceRange(String min, String max);

  /// EXP-06 FAB and empty action.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get expense_addAccount;

  /// EXP-06 empty state.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get expense_noAccounts;

  /// Home Expense card empty action.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense'**
  String get expense_cardEmpty;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get common_iconGroup_food;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get common_iconGroup_transport;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Home and bills'**
  String get common_iconGroup_home;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get common_iconGroup_shopping;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get common_iconGroup_health;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get common_iconGroup_education;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get common_iconGroup_leisure;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get common_iconGroup_travel;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get common_iconGroup_money;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get common_iconGroup_other;

  /// Semantic label of the 'restaurant' icon.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get icon_restaurant;

  /// Semantic label of the 'local_grocery_store' icon.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get icon_local_grocery_store;

  /// Semantic label of the 'local_cafe' icon.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get icon_local_cafe;

  /// Semantic label of the 'fastfood' icon.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get icon_fastfood;

  /// Semantic label of the 'bakery_dining' icon.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get icon_bakery_dining;

  /// Semantic label of the 'local_bar' icon.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get icon_local_bar;

  /// Semantic label of the 'icecream' icon.
  ///
  /// In en, this message translates to:
  /// **'Ice cream'**
  String get icon_icecream;

  /// Semantic label of the 'lunch_dining' icon.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get icon_lunch_dining;

  /// Semantic label of the 'directions_bus' icon.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get icon_directions_bus;

  /// Semantic label of the 'local_gas_station' icon.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get icon_local_gas_station;

  /// Semantic label of the 'directions_car' icon.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get icon_directions_car;

  /// Semantic label of the 'two_wheeler' icon.
  ///
  /// In en, this message translates to:
  /// **'Two-wheeler'**
  String get icon_two_wheeler;

  /// Semantic label of the 'local_taxi' icon.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get icon_local_taxi;

  /// Semantic label of the 'train' icon.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get icon_train;

  /// Semantic label of the 'electric_rickshaw' icon.
  ///
  /// In en, this message translates to:
  /// **'Auto rickshaw'**
  String get icon_electric_rickshaw;

  /// Semantic label of the 'local_parking' icon.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get icon_local_parking;

  /// Semantic label of the 'home' icon.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get icon_home;

  /// Semantic label of the 'receipt' icon.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get icon_receipt;

  /// Semantic label of the 'bolt' icon.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get icon_bolt;

  /// Semantic label of the 'water_drop' icon.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get icon_water_drop;

  /// Semantic label of the 'wifi' icon.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get icon_wifi;

  /// Semantic label of the 'phone_android' icon.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get icon_phone_android;

  /// Semantic label of the 'build' icon.
  ///
  /// In en, this message translates to:
  /// **'Repairs'**
  String get icon_build;

  /// Semantic label of the 'cleaning_services' icon.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get icon_cleaning_services;

  /// Semantic label of the 'shopping_bag' icon.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get icon_shopping_bag;

  /// Semantic label of the 'shopping_cart' icon.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get icon_shopping_cart;

  /// Semantic label of the 'checkroom' icon.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get icon_checkroom;

  /// Semantic label of the 'devices' icon.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get icon_devices;

  /// Semantic label of the 'chair' icon.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get icon_chair;

  /// Semantic label of the 'redeem' icon.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get icon_redeem;

  /// Semantic label of the 'local_florist' icon.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get icon_local_florist;

  /// Semantic label of the 'pets' icon.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get icon_pets;

  /// Semantic label of the 'medical_services' icon.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get icon_medical_services;

  /// Semantic label of the 'local_pharmacy' icon.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get icon_local_pharmacy;

  /// Semantic label of the 'fitness_center' icon.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get icon_fitness_center;

  /// Semantic label of the 'spa' icon.
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get icon_spa;

  /// Semantic label of the 'favorite' icon.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing'**
  String get icon_favorite;

  /// Semantic label of the 'child_care' icon.
  ///
  /// In en, this message translates to:
  /// **'Child care'**
  String get icon_child_care;

  /// Semantic label of the 'school' icon.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get icon_school;

  /// Semantic label of the 'menu_book' icon.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get icon_menu_book;

  /// Semantic label of the 'computer' icon.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get icon_computer;

  /// Semantic label of the 'science' icon.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get icon_science;

  /// Semantic label of the 'edit' icon.
  ///
  /// In en, this message translates to:
  /// **'Stationery'**
  String get icon_edit;

  /// Semantic label of the 'movie' icon.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get icon_movie;

  /// Semantic label of the 'sports_esports' icon.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get icon_sports_esports;

  /// Semantic label of the 'music_note' icon.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get icon_music_note;

  /// Semantic label of the 'sports_cricket' icon.
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get icon_sports_cricket;

  /// Semantic label of the 'celebration' icon.
  ///
  /// In en, this message translates to:
  /// **'Celebration'**
  String get icon_celebration;

  /// Semantic label of the 'theater_comedy' icon.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get icon_theater_comedy;

  /// Semantic label of the 'subscriptions' icon.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get icon_subscriptions;

  /// Semantic label of the 'flight' icon.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get icon_flight;

  /// Semantic label of the 'hotel' icon.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get icon_hotel;

  /// Semantic label of the 'luggage' icon.
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get icon_luggage;

  /// Semantic label of the 'beach_access' icon.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get icon_beach_access;

  /// Semantic label of the 'map' icon.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get icon_map;

  /// Semantic label of the 'payments' icon.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get icon_payments;

  /// Semantic label of the 'storefront' icon.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get icon_storefront;

  /// Semantic label of the 'savings' icon.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get icon_savings;

  /// Semantic label of the 'attach_money' icon.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get icon_attach_money;

  /// Semantic label of the 'account_balance' icon.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get icon_account_balance;

  /// Semantic label of the 'credit_card' icon.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get icon_credit_card;

  /// Semantic label of the 'wallet' icon.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get icon_wallet;

  /// Semantic label of the 'currency_rupee' icon.
  ///
  /// In en, this message translates to:
  /// **'Rupee'**
  String get icon_currency_rupee;

  /// Semantic label of the 'trending_up' icon.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get icon_trending_up;

  /// Semantic label of the 'request_quote' icon.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get icon_request_quote;

  /// Semantic label of the 'volunteer_activism' icon.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get icon_volunteer_activism;

  /// Semantic label of the 'work' icon.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get icon_work;

  /// Semantic label of the 'category' icon.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get icon_category;

  /// Semantic label of the 'star' icon.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get icon_star;

  /// Semantic label of the 'label' icon.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get icon_label;

  /// Semantic label of the 'more_horiz' icon.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get icon_more_horiz;

  /// EXP-01 overflow item that opens EXP-08.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get expense_menuBudgets;

  /// EXP-08 screen title.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get expense_budgetsTitle;

  /// EXP-08/09: the budget that covers all expense categories.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get expense_budgetOverall;

  /// EXP-08 section heading.
  ///
  /// In en, this message translates to:
  /// **'Category budgets'**
  String get expense_budgetCategoryBudgets;

  /// EXP-08 section heading.
  ///
  /// In en, this message translates to:
  /// **'Categories without budget'**
  String get expense_budgetWithoutBudget;

  /// EXP-08 row button and EXP-09 title and primary button.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get expense_budgetSet;

  /// EXP-08 empty state button.
  ///
  /// In en, this message translates to:
  /// **'Set monthly budget'**
  String get expense_budgetSetMonthly;

  /// EXP-08 overflow action.
  ///
  /// In en, this message translates to:
  /// **'Copy last month\'s budgets'**
  String get expense_budgetCopyLastMonth;

  /// EXP-08 snackbar after Copy last month's budgets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to copy} =1{Copied 1 budget} other{Copied {count} budgets}}'**
  String expense_budgetCopied(int count);

  /// EXP-08 overall card, current month. days counts today.
  ///
  /// In en, this message translates to:
  /// **'{amount} per day left for {days, plural, =1{1 day} other{{days} days}}'**
  String expense_budgetPerDayLeft(String amount, int days);

  /// EXP-08 overall card when remaining is 0 or less.
  ///
  /// In en, this message translates to:
  /// **'No budget left this month'**
  String get expense_budgetNoneLeft;

  /// EXP-08 overall card, past month result.
  ///
  /// In en, this message translates to:
  /// **'Under budget by {amount}'**
  String expense_budgetUnderBy(String amount);

  /// EXP-08 over-budget amount.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String expense_budgetOverBy(String amount);

  /// EXP-08 overall card, future month.
  ///
  /// In en, this message translates to:
  /// **'{amount} per day for {days, plural, =1{1 day} other{{days} days}}'**
  String expense_budgetFuturePerDay(String amount, int days);

  /// EXP-08 remaining amount when under the limit.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String expense_budgetLeft(String amount);

  /// EXP-08 spent / limit.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String expense_budgetSpentOfLimit(String spent, String limit);

  /// EXP-08 level label under 80%.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get expense_budgetLevelUnder;

  /// EXP-08 level label 80–100%.
  ///
  /// In en, this message translates to:
  /// **'Almost used'**
  String get expense_budgetLevelWarning;

  /// EXP-08 level label over 100%.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get expense_budgetLevelOver;

  /// EXP-08 progress label: level text and percentage used.
  ///
  /// In en, this message translates to:
  /// **'{level} · {percent}% used'**
  String expense_budgetLevelLine(String level, int percent);

  /// EXP-08 empty state title.
  ///
  /// In en, this message translates to:
  /// **'Plan your month'**
  String get expense_budgetEmptyTitle;

  /// EXP-08 empty state explanation.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget to see how much you can still spend each day.'**
  String get expense_budgetEmptyBody;

  /// EXP-09 toggle.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month'**
  String get expense_budgetRepeatMonthly;

  /// EXP-09 delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get expense_budgetDelete;

  /// EXP-08 snackbar after delete.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get expense_budgetDeleted;

  /// EXP-08 snackbar when Undo finds the slot taken.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore the budget because one is already set.'**
  String get expense_budgetRestoreFailed;

  /// EXP-09 inline error.
  ///
  /// In en, this message translates to:
  /// **'This category already has a budget this month.'**
  String get expense_budgetSlotTaken;

  /// EXP-08 marker for a budget whose category is hidden or deleted.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get expense_budgetHidden;

  /// EXP-09 inline error.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get expense_budgetAmountMissing;

  /// EXP-09 inline error.
  ///
  /// In en, this message translates to:
  /// **'Amount is too large'**
  String get expense_budgetAmountTooLarge;

  /// EXP-08 overall card with no Overall budget.
  ///
  /// In en, this message translates to:
  /// **'Set an overall budget'**
  String get expense_budgetSetOverallPrompt;

  /// Android notification channel name (spec §12).
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notif_channelBudgetAlerts;

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'When a budget reaches 80% or 100%'**
  String get notif_channelBudgetAlertsDescription;

  /// Budget alert title at 80%. No amounts (FR-020).
  ///
  /// In en, this message translates to:
  /// **'{category} budget at {percent}%'**
  String notif_budget80Title(String category, int percent);

  /// Budget alert body at 80%. No amounts (FR-020).
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your {category} budget this month.'**
  String notif_budget80Body(String category, int percent);

  /// Budget alert title at 100%. No amounts (FR-020).
  ///
  /// In en, this message translates to:
  /// **'{category} budget used up'**
  String notif_budget100Title(String category);

  /// Budget alert body at 100%. No amounts (FR-020).
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your {category} budget this month.'**
  String notif_budget100Body(String category, int percent);

  /// Name of the overall budget in budget alerts.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get notif_overallBudget;

  /// EXP-01 overflow item that opens EXP-10.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get expense_menuRecurring;

  /// EXP-02 Repeat switch.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get expense_repeat;

  /// Repeat frequency chip.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get expense_freqDaily;

  /// Repeat frequency chip.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get expense_freqWeekly;

  /// Repeat frequency chip.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get expense_freqMonthly;

  /// Repeat frequency chip.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get expense_freqYearly;

  /// EXP-02 Repeat end-date chip.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get expense_repeatEndDate;

  /// EXP-02 Repeat end-date chip with a date.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String expense_repeatEndsOn(String date);

  /// EXP-02 button that clears the end date.
  ///
  /// In en, this message translates to:
  /// **'Remove end date'**
  String get expense_repeatClearEnd;

  /// EXP-02 inline error under the Repeat section.
  ///
  /// In en, this message translates to:
  /// **'End date can\'t be before the first date'**
  String get expense_repeatEndBeforeStart;

  /// Schedule in words.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get expense_everyDay;

  /// Schedule in words; weekday is a localized day name.
  ///
  /// In en, this message translates to:
  /// **'Every week on {weekday}'**
  String expense_everyWeekOn(String weekday);

  /// Schedule in words. suffix is the English ordinal category (st, nd, rd, th), from ordinalSuffix(); hi/gu use a 'day N' form and ignore it (plan Open item 6).
  ///
  /// In en, this message translates to:
  /// **'Every month on {suffix, select, st{{day}st} nd{{day}nd} rd{{day}rd} other{{day}th}}'**
  String expense_everyMonthOn(int day, String suffix);

  /// Schedule in words; date is e.g. 5 Oct.
  ///
  /// In en, this message translates to:
  /// **'Every year on {date}'**
  String expense_everyYearOn(String date);

  /// EXP-10 screen title.
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions'**
  String get expense_recurringTitle;

  /// EXP-10 section heading.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get expense_recurringPaused;

  /// EXP-10 row: next date.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String expense_recurringNext(String date);

  /// EXP-10 row of an ended rule.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String expense_recurringEnded(String date);

  /// EXP-10 swipe and menu action.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get expense_recurringPause;

  /// EXP-10 swipe and menu action.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get expense_recurringResume;

  /// EXP-10 swipe and menu action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expense_recurringDelete;

  /// EXP-10 / EXP-02 snackbar.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction deleted'**
  String get expense_recurringDeleted;

  /// EXP-10 FAB and empty-state button.
  ///
  /// In en, this message translates to:
  /// **'Add recurring transaction'**
  String get expense_recurringAdd;

  /// EXP-10 empty state title.
  ///
  /// In en, this message translates to:
  /// **'Nothing repeats yet'**
  String get expense_recurringEmptyTitle;

  /// EXP-10 empty state explanation.
  ///
  /// In en, this message translates to:
  /// **'Add rent, salary, or bills once and they\'ll be logged for you.'**
  String get expense_recurringEmptyBody;

  /// EXP-10 warning line.
  ///
  /// In en, this message translates to:
  /// **'Account archived'**
  String get expense_recurringStaleAccount;

  /// EXP-10 warning line.
  ///
  /// In en, this message translates to:
  /// **'Category hidden'**
  String get expense_recurringStaleCategory;

  /// EXP-02 title in rule-edit mode.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring transaction'**
  String get expense_ruleEditTitle;

  /// EXP-02 date label in rule-edit mode.
  ///
  /// In en, this message translates to:
  /// **'Next date'**
  String get expense_nextDate;

  /// EXP-03 link.
  ///
  /// In en, this message translates to:
  /// **'Created from recurring rule'**
  String get expense_createdFromRule;

  /// EXP-03 text when the rule is deleted.
  ///
  /// In en, this message translates to:
  /// **'Recurring rule deleted'**
  String get expense_ruleDeleted;

  /// Semantic label of the EXP-01 repeat icon.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get expense_recurringLabel;

  /// EXP-01 overflow item that opens EXP-11.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get expense_menuReports;

  /// LockedFeatureOverlay explanation on EXP-11.
  ///
  /// In en, this message translates to:
  /// **'Advanced reports are part of Pro.'**
  String get premium_advancedReportsMessage;

  /// Semantic label of a locked period option.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get premium_lockedPeriod;

  /// More tab section, dev flavor only.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get more_developerSection;

  /// Dev-only switch (FR-041).
  ///
  /// In en, this message translates to:
  /// **'Unlock all features (debug)'**
  String get more_debugUnlockAll;

  /// EXP-11 screen title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get expense_reportsTitle;

  /// EXP-11 tab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get expense_reportTabOverview;

  /// EXP-11 tab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get expense_reportTabCategories;

  /// EXP-11 tab.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get expense_reportTabTrends;

  /// EXP-11 tab.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get expense_reportTabAccounts;

  /// Semantic label of a locked EXP-11 tab.
  ///
  /// In en, this message translates to:
  /// **'{tab}, locked'**
  String expense_reportLockedTab(String tab);

  /// EXP-11 Overview card.
  ///
  /// In en, this message translates to:
  /// **'Net savings'**
  String get expense_reportNetSavings;

  /// EXP-11 Overview card.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get expense_reportSavingsRate;

  /// EXP-11 savings rate value.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String expense_reportSavingsRateValue(int percent);

  /// EXP-11 value shown when it can't be computed (no income).
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get expense_reportNoValue;

  /// EXP-11 Overview card.
  ///
  /// In en, this message translates to:
  /// **'Average daily spend'**
  String get expense_reportAvgDaily;

  /// EXP-11 Overview section.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get expense_reportTopCategories;

  /// EXP-11 Overview chart title.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense'**
  String get expense_reportIncomeVsExpense;

  /// EXP-11 share of expense.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of spending'**
  String expense_reportShare(int percent);

  /// EXP-11 donut slice for small categories.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expense_reportOther;

  /// EXP-11 donut center label.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get expense_reportTotalSpent;

  /// Semantic summary of the donut chart.
  ///
  /// In en, this message translates to:
  /// **'Expense by category: {items}'**
  String expense_reportChartSummaryDonut(String items);

  /// One item in a chart summary.
  ///
  /// In en, this message translates to:
  /// **'{name} {percent}%'**
  String expense_reportChartSummaryItem(String name, int percent);

  /// Semantic summary of the income vs expense chart.
  ///
  /// In en, this message translates to:
  /// **'Income {income}, expense {expense}'**
  String expense_reportChartSummaryBar(String income, String expense);

  /// EXP-11 empty state.
  ///
  /// In en, this message translates to:
  /// **'No transactions in {period}'**
  String expense_reportEmpty(String period);

  /// EXP-11 Trends legend: solid line.
  ///
  /// In en, this message translates to:
  /// **'This period'**
  String get expense_reportThisPeriod;

  /// EXP-11 Trends legend: dashed line.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get expense_reportPreviousPeriod;

  /// EXP-11 Accounts chart title.
  ///
  /// In en, this message translates to:
  /// **'By account'**
  String get expense_reportByAccount;

  /// EXP-11 Accounts chart title.
  ///
  /// In en, this message translates to:
  /// **'By payment mode'**
  String get expense_reportByPaymentMode;

  /// Semantic summary of the trend chart.
  ///
  /// In en, this message translates to:
  /// **'Spending this period {current}, previous period {previous}'**
  String expense_reportChartSummaryTrend(String current, String previous);

  /// Semantic summary of a bar chart.
  ///
  /// In en, this message translates to:
  /// **'{title}: {items}'**
  String expense_reportChartSummaryBars(String title, String items);

  /// One bar in a chart summary.
  ///
  /// In en, this message translates to:
  /// **'{name} {amount}'**
  String expense_reportChartSummaryBarItem(String name, String amount);

  /// Android notification channel name (spec §12).
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get notif_channelHabitReminders;

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'Reminders for your habits'**
  String get notif_channelHabitRemindersDescription;

  /// HAB-01 app bar title.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habit_title;

  /// Quick-add action label.
  ///
  /// In en, this message translates to:
  /// **'Check in habit'**
  String get habit_quickAddCheckIn;

  /// Streak length in days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String habit_streakDays(int count);

  /// Streak length in weeks (times per week habits).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String habit_streakWeeks(int count);

  /// HAB-01 progress header.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String habit_doneOfTotal(int done, int total);

  /// Undo action.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get habit_undo;

  /// HAB-01/HAB-02 error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your habits. Try again.'**
  String get habit_loadError;

  /// Snackbar when a habit write fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get habit_saveError;

  /// HAB-01 overflow item.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get habit_menuArchived;

  /// HAB-01 overflow item.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get habit_menuReorder;

  /// HAB-01 button that ends reorder mode.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habit_reorderDone;

  /// Drag handle semantic label.
  ///
  /// In en, this message translates to:
  /// **'Reorder {name}'**
  String habit_reorderHandle(String name);

  /// Overflow menu tooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get habit_moreOptions;

  /// HAB-01 FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get habit_addHabit;

  /// HAB-01 empty state title.
  ///
  /// In en, this message translates to:
  /// **'Build your first habit'**
  String get habit_emptyTitle;

  /// HAB-01 empty state body.
  ///
  /// In en, this message translates to:
  /// **'Start with a template or tap + to create your own.'**
  String get habit_emptyBody;

  /// HAB-01 collapsed section for today.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled today'**
  String get habit_notScheduledToday;

  /// HAB-01 collapsed section for a past day.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled on this day'**
  String get habit_notScheduledOnDay;

  /// HAB-01 banner.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get habit_allDone;

  /// HAB-01 when no habit is due on the selected day.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled on this day'**
  String get habit_noneScheduled;

  /// HAB-01 card menu item.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habit_menuEdit;

  /// HAB-01 card menu item.
  ///
  /// In en, this message translates to:
  /// **'Add note for today'**
  String get habit_menuAddNote;

  /// HAB-01 card menu item on a past day.
  ///
  /// In en, this message translates to:
  /// **'Add note for this day'**
  String get habit_menuAddNoteDay;

  /// HAB-01 card menu item; uses a freeze.
  ///
  /// In en, this message translates to:
  /// **'Skip today'**
  String get habit_menuSkipToday;

  /// Subtitle of Skip today.
  ///
  /// In en, this message translates to:
  /// **'Uses 1 of your {count} freezes'**
  String habit_skipTodayHint(int count);

  /// Disabled Skip today subtitle.
  ///
  /// In en, this message translates to:
  /// **'No freezes left'**
  String get habit_noFreezesLeft;

  /// Menu item.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habit_menuArchive;

  /// Snackbar with Undo.
  ///
  /// In en, this message translates to:
  /// **'Habit archived'**
  String get habit_archived;

  /// Snackbar with Undo.
  ///
  /// In en, this message translates to:
  /// **'Check-in removed'**
  String get habit_unchecked;

  /// Snackbar with Undo.
  ///
  /// In en, this message translates to:
  /// **'Today skipped with a freeze'**
  String get habit_skipped;

  /// Hint on disabled older days in the week strip.
  ///
  /// In en, this message translates to:
  /// **'Edit older days from the habit\'s page'**
  String get habit_olderEditsHint;

  /// Hint on disabled future days.
  ///
  /// In en, this message translates to:
  /// **'Future days can\'t be checked in yet'**
  String get habit_futureDayHint;

  /// Week strip day semantic label.
  ///
  /// In en, this message translates to:
  /// **'{day}, {done} of {total} done'**
  String habit_dayRingLabel(String day, int done, int total);

  /// Week strip day with no due habit.
  ///
  /// In en, this message translates to:
  /// **'{day}, nothing scheduled'**
  String habit_dayRingNone(String day);

  /// HAB-01 number entry dialog title.
  ///
  /// In en, this message translates to:
  /// **'Set value for {name}'**
  String habit_valueEntryTitle(String name);

  /// Number entry helper text.
  ///
  /// In en, this message translates to:
  /// **'A whole number from 0 to 9,999'**
  String get habit_valueEntryHint;

  /// Number entry error.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 0 to 9,999'**
  String get habit_valueEntryError;

  /// Dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get habit_set;

  /// Check button semantic label.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} done'**
  String habit_markDoneLabel(String name);

  /// Check button semantic label when done.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} not done'**
  String habit_markNotDoneLabel(String name);

  /// Count + button semantic label.
  ///
  /// In en, this message translates to:
  /// **'Add 1 to {name}'**
  String habit_addOneLabel(String name);

  /// Count habit semantic label.
  ///
  /// In en, this message translates to:
  /// **'{name}, {value} of {target} {unit}'**
  String habit_countLabel(String name, int value, int target, String unit);

  /// Count habit semantic label without a unit.
  ///
  /// In en, this message translates to:
  /// **'{name}, {value} of {target}'**
  String habit_countLabelNoUnit(String name, int value, int target);

  /// Count habit progress on the card.
  ///
  /// In en, this message translates to:
  /// **'{value} / {target} {unit}'**
  String habit_countValue(int value, int target, String unit);

  /// Count habit progress without a unit.
  ///
  /// In en, this message translates to:
  /// **'{value} / {target}'**
  String habit_countValueNoUnit(int value, int target);

  /// Flame semantic label.
  ///
  /// In en, this message translates to:
  /// **'Current streak: {streak}'**
  String habit_streakLabel(String streak);

  /// Card status text.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habit_statusDone;

  /// Card status text.
  ///
  /// In en, this message translates to:
  /// **'Freeze day'**
  String get habit_statusFreeze;

  /// Schedule text.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habit_scheduleDaily;

  /// Schedule text for times per week.
  ///
  /// In en, this message translates to:
  /// **'{times}× per week · {left} left'**
  String habit_scheduleTimesPerWeek(int times, int left);

  /// Schedule text when the week is met.
  ///
  /// In en, this message translates to:
  /// **'{times}× per week · done'**
  String habit_scheduleTimesPerWeekMet(int times);

  /// Note dialog title.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get habit_noteTitle;

  /// Note field hint.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get habit_noteHint;

  /// Note dialog button.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get habit_noteSave;

  /// Snackbar after saving a note.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get habit_noteSaved;

  /// HAB-03 placeholder title.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habit_detailTitle;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get habit_template_drinkWater;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get habit_template_read;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get habit_template_walk;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get habit_template_meditate;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Wake up early'**
  String get habit_template_wakeUpEarly;

  /// Template name.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get habit_template_study;

  /// Template unit.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get habit_unit_glasses;

  /// Template unit.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get habit_unit_pages;

  /// Template unit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get habit_unit_minutes;

  /// HAB-02 title (new).
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get habit_addTitle;

  /// HAB-02 title (edit).
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habit_editTitle;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get habit_nameLabel;

  /// HAB-02 template name suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get habit_nameSuggestions;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get habit_iconLabel;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habit_colorLabel;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Goal type'**
  String get habit_goalLabel;

  /// Goal type option.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get habit_goalYesNo;

  /// Goal type option.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get habit_goalCount;

  /// HAB-02 edit-mode hint.
  ///
  /// In en, this message translates to:
  /// **'The goal type can\'t be changed after the habit is created'**
  String get habit_goalLocked;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get habit_targetLabel;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Unit (optional)'**
  String get habit_unitLabel;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get habit_scheduleLabel;

  /// Schedule option.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get habit_scheduleEveryDay;

  /// Schedule option.
  ///
  /// In en, this message translates to:
  /// **'Specific days'**
  String get habit_scheduleSpecificDays;

  /// Schedule option.
  ///
  /// In en, this message translates to:
  /// **'X times per week'**
  String get habit_scheduleXTimes;

  /// Times per week stepper value.
  ///
  /// In en, this message translates to:
  /// **'{count}× per week'**
  String habit_timesPerWeekValue(int count);

  /// Stepper button.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get habit_decrease;

  /// Stepper button.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get habit_increase;

  /// HAB-02 field label.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get habit_startDate;

  /// Date chip.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get habit_pickDate;

  /// HAB-02 sticky button.
  ///
  /// In en, this message translates to:
  /// **'Save habit'**
  String get habit_save;

  /// Snackbar after save.
  ///
  /// In en, this message translates to:
  /// **'Habit saved'**
  String get habit_saved;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get habit_errNameRequired;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'Use at most 40 characters'**
  String get habit_errNameTooLong;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'Enter a target from 1 to 9,999'**
  String get habit_errTargetRange;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'Use at most 20 characters'**
  String get habit_errUnitTooLong;

  /// HAB-02 error (Specific days).
  ///
  /// In en, this message translates to:
  /// **'Choose at least one weekday'**
  String get habit_errWeekdayRequired;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'Choose 1 to 6 times per week'**
  String get habit_errTimesRange;

  /// HAB-02 overflow item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habit_deleteAction;

  /// Delete dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habit_deleteTitle;

  /// Delete dialog consequence.
  ///
  /// In en, this message translates to:
  /// **'This removes {name} and all its history.'**
  String habit_deleteBody(String name);

  /// Delete dialog confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get habit_deleteConfirm;

  /// Snackbar after delete.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get habit_deleted;

  /// Discard dialog title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get habit_discardTitle;

  /// Discard dialog consequence.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this habit will be lost.'**
  String get habit_discardBody;

  /// Discard dialog confirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get habit_discardConfirm;

  /// Snackbar when an edited habit was deleted.
  ///
  /// In en, this message translates to:
  /// **'This habit no longer exists'**
  String get habit_notFound;

  /// HAB-02 section label.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get habit_reminders;

  /// HAB-02 button.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get habit_addReminder;

  /// Reminder chip delete label.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder at {time}'**
  String habit_removeReminder(String time);

  /// HAB-02 switch.
  ///
  /// In en, this message translates to:
  /// **'Remind me only if not done yet'**
  String get habit_remindOnlyIfNotDone;

  /// HAB-02 hint and error.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 3 reminders'**
  String get habit_reminderLimit;

  /// HAB-02 error.
  ///
  /// In en, this message translates to:
  /// **'This time is already added'**
  String get habit_reminderDuplicate;

  /// HAB-02 hint when notifications are denied.
  ///
  /// In en, this message translates to:
  /// **'Reminders need notification permission'**
  String get habit_notificationsOffHint;

  /// HAB-02 hint without exact alarms.
  ///
  /// In en, this message translates to:
  /// **'Reminders may be a few minutes late'**
  String get habit_inexactHint;

  /// Habit reminder title: only the habit name (FR-043).
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String notif_habitReminderTitle(String name);

  /// Habit reminder body: name and encouragement only (FR-043).
  ///
  /// In en, this message translates to:
  /// **'Time for {name}. You\'ve got this.'**
  String notif_habitReminderBody(String name);

  /// Milestone sheet title.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak!'**
  String habit_milestoneTitleDays(int count);

  /// Milestone sheet title (weekly habits).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-week streak!} other{{count}-week streak!}}'**
  String habit_milestoneTitleWeeks(int count);

  /// Milestone encouragement, no guilt (§15.7).
  ///
  /// In en, this message translates to:
  /// **'Every check-in adds up. Keep it going!'**
  String get habit_milestoneBody;

  /// Milestone sheet button.
  ///
  /// In en, this message translates to:
  /// **'Share streak'**
  String get habit_shareStreak;

  /// Milestone sheet button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get habit_close;

  /// Share card footer.
  ///
  /// In en, this message translates to:
  /// **'Tracked with DailyTrack'**
  String get habit_shareCardFooter;

  /// Snackbar when sharing fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share. Try again.'**
  String get habit_shareError;

  /// IconPickerGrid group heading.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get common_iconGroup_habits;

  /// Semantic label of the 'directions_walk' icon.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get icon_directions_walk;

  /// Semantic label of the 'directions_run' icon.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get icon_directions_run;

  /// Semantic label of the 'self_improvement' icon.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get icon_self_improvement;

  /// Semantic label of the 'alarm' icon.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get icon_alarm;

  /// Semantic label of the 'bedtime' icon.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get icon_bedtime;

  /// HAB-03 stat tile.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get habit_statCurrent;

  /// HAB-03 stat tile.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get habit_statBest;

  /// HAB-03 stat tile.
  ///
  /// In en, this message translates to:
  /// **'Completion rate (last 30 days)'**
  String get habit_statRate;

  /// HAB-03 stat tile.
  ///
  /// In en, this message translates to:
  /// **'Total completions'**
  String get habit_statTotal;

  /// Completion rate value.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String habit_rateValue(int percent);

  /// Completion rate with no countable day.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get habit_rateNone;

  /// HAB-03 section title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get habit_calendarTitle;

  /// Calendar day semantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, done'**
  String habit_dayDone(String date);

  /// Calendar day semantics (count, not done).
  ///
  /// In en, this message translates to:
  /// **'{date}, {value} of {target}'**
  String habit_dayPartial(String date, int value, int target);

  /// Calendar day semantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, missed'**
  String habit_dayMissed(String date);

  /// Calendar day semantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, freeze day'**
  String habit_dayFreeze(String date);

  /// Calendar day semantics (nothing to report).
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String habit_dayOther(String date);

  /// Calendar day semantics hint.
  ///
  /// In en, this message translates to:
  /// **'has a note'**
  String get habit_dayHasNote;

  /// HAB-03 heatmap title.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get habit_heatmapTitle;

  /// Heatmap semantic summary.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} days done in the last 12 months'**
  String habit_heatmapSummary(int done, int total);

  /// Heatmap per-month line for screen readers.
  ///
  /// In en, this message translates to:
  /// **'{month}: {done} of {total} days done'**
  String habit_heatmapMonth(String month, int done, int total);

  /// Heatmap share button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get habit_shareHeatmap;

  /// HAB-03 chart title.
  ///
  /// In en, this message translates to:
  /// **'Completions per week'**
  String get habit_weeklyChartTitle;

  /// Chart semantic summary.
  ///
  /// In en, this message translates to:
  /// **'Completions in the last 12 weeks: {items}'**
  String habit_weeklyChartSummary(String items);

  /// One bar in the chart summary.
  ///
  /// In en, this message translates to:
  /// **'week of {date} {count}'**
  String habit_weeklyChartItem(String date, int count);

  /// HAB-03 section title.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get habit_notesTitle;

  /// HAB-03 notes empty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get habit_notesEmpty;

  /// HAB-03 freeze card title.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze'**
  String get habit_freezeTitle;

  /// Freeze card count.
  ///
  /// In en, this message translates to:
  /// **'Freezes available: {count}'**
  String habit_freezesAvailable(int count);

  /// Freeze card explanation.
  ///
  /// In en, this message translates to:
  /// **'A freeze keeps your streak when you miss a day. Use it on a missed day up to 3 days back.'**
  String get habit_freezeExplain;

  /// Freeze card button.
  ///
  /// In en, this message translates to:
  /// **'Use a freeze'**
  String get habit_useFreeze;

  /// Freeze day picker item.
  ///
  /// In en, this message translates to:
  /// **'Use a freeze on {date}'**
  String habit_useFreezeOn(String date);

  /// Freeze card when nothing can be frozen.
  ///
  /// In en, this message translates to:
  /// **'No missed day in the last 3 days'**
  String get habit_noFreezeableDay;

  /// Snackbar with Undo.
  ///
  /// In en, this message translates to:
  /// **'Freeze used'**
  String get habit_freezeUsed;

  /// Dev-only button (FR-037).
  ///
  /// In en, this message translates to:
  /// **'Add a freeze (debug)'**
  String get habit_addFreezeDebug;

  /// Freeze cap hint.
  ///
  /// In en, this message translates to:
  /// **'You can keep up to 2 freezes'**
  String get habit_freezeCapReached;

  /// Day edit sheet title.
  ///
  /// In en, this message translates to:
  /// **'Edit {date}'**
  String habit_editDayTitle(String date);

  /// Day edit switch for yes/no habits.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habit_dayDoneToggle;

  /// Day edit value field.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get habit_dayValueLabel;

  /// Day edit save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get habit_daySave;

  /// Snackbar after a day edit.
  ///
  /// In en, this message translates to:
  /// **'Day saved'**
  String get habit_daySaved;

  /// HAB-03 header button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habit_edit;

  /// Calendar paging.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get habit_previousMonth;

  /// Calendar paging.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get habit_nextMonth;

  /// HAB-04 title.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get habit_archivedTitle;

  /// HAB-04 row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived {date}'**
  String habit_archivedOn(String date);

  /// HAB-04 row line.
  ///
  /// In en, this message translates to:
  /// **'Best streak: {streak}'**
  String habit_bestStreakLabel(String streak);

  /// HAB-04 action.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get habit_restore;

  /// Snackbar with Undo.
  ///
  /// In en, this message translates to:
  /// **'Habit restored'**
  String get habit_restored;

  /// HAB-04 action.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get habit_deletePermanently;

  /// HAB-04 empty state.
  ///
  /// In en, this message translates to:
  /// **'Archived habits appear here'**
  String get habit_archivedEmpty;

  /// Home card ring label.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done today'**
  String habit_doneTodayRing(int done, int total);

  /// Home card empty action.
  ///
  /// In en, this message translates to:
  /// **'Create your first habit'**
  String get habit_cardEmpty;

  /// Home card when no habit is due.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today'**
  String get habit_cardNoneToday;

  /// Count popup button.
  ///
  /// In en, this message translates to:
  /// **'+1'**
  String get habit_addOne;

  /// Count popup button.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get habit_customValue;

  /// Home card error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load habits'**
  String get habit_loadDataError;

  /// DSH-01 greeting, 05:00–11:59.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get home_greetingMorning;

  /// DSH-01 greeting, 12:00–16:59.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get home_greetingAfternoon;

  /// DSH-01 greeting, 17:00–04:59.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get home_greetingEvening;

  /// DSH-01 + button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get home_quickAddTooltip;

  /// DSH-01 insight card title.
  ///
  /// In en, this message translates to:
  /// **'Tip for today'**
  String get home_insightTitle;

  /// DSH-01 starter tip when no insight rule applies.
  ///
  /// In en, this message translates to:
  /// **'Log something today and tips will show up here'**
  String get home_insightStarter;

  /// DSH-01 Coming soon card title.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get home_comingSoonTitle;

  /// DSH-01 Coming soon card body; names is a localized list.
  ///
  /// In en, this message translates to:
  /// **'{names} trackers are on the way'**
  String home_comingSoonBody(String names);

  /// Joins two names in a list.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second}'**
  String home_listPair(String first, String second);

  /// DSH-01 Coming soon dismiss button.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get home_comingSoonDismiss;

  /// Snackbar after dismissing the Coming soon card.
  ///
  /// In en, this message translates to:
  /// **'Card hidden'**
  String get home_comingSoonDismissed;

  /// DSH-01 recent transactions title.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get home_recentTitle;

  /// DSH-01 recent transactions link to EXP-01.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get home_seeAll;

  /// Quick-add action label.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get expense_quickAddIncome;

  /// Home Expense card chip that adds an expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense_cardAdd;

  /// Home Expense card button when no overall budget exists.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get expense_cardSetBudget;

  /// Home Expense card month spent of the overall budget.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String expense_cardMonthOfBudget(String spent, String limit);

  /// Insight: a category is up versus the same days last month.
  ///
  /// In en, this message translates to:
  /// **'{category} spending is {percent}% higher than last month'**
  String expense_insightCategoryHigher(String category, int percent);

  /// Insight: a category is down versus the same days last month.
  ///
  /// In en, this message translates to:
  /// **'{category} spending is {percent}% lower than last month. Nice work.'**
  String expense_insightCategoryLower(String category, int percent);

  /// Insight: the overall budget is on pace.
  ///
  /// In en, this message translates to:
  /// **'You\'re on track: {amount} left for {days, plural, =1{1 day} other{{days} days}}'**
  String expense_insightBudgetOnTrack(String amount, int days);

  /// Insight: the overall budget is 80–100% used.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of this month\'s budget'**
  String expense_insightBudgetNear(int percent);

  /// Insight: the overall budget is exceeded.
  ///
  /// In en, this message translates to:
  /// **'You\'re {amount} over this month\'s budget. A no-spend day helps.'**
  String expense_insightBudgetOver(String amount);

  /// Insight card semantic label, spending tip.
  ///
  /// In en, this message translates to:
  /// **'Opens reports: {text}'**
  String expense_insightOpensReports(String text);

  /// Insight card semantic label, budget tip.
  ///
  /// In en, this message translates to:
  /// **'Opens budgets: {text}'**
  String expense_insightOpensBudgets(String text);

  /// Insight: a daily streak is close to a milestone.
  ///
  /// In en, this message translates to:
  /// **'You\'re {count, plural, =1{1 day} other{{count} days}} away from a {milestone}-day streak with {name}'**
  String habit_insightNextMilestoneDays(int count, int milestone, String name);

  /// Insight: a weekly streak is close to a milestone.
  ///
  /// In en, this message translates to:
  /// **'You\'re {count, plural, =1{1 week} other{{count} weeks}} away from a {milestone}-week streak with {name}'**
  String habit_insightNextMilestoneWeeks(int count, int milestone, String name);

  /// Insight: most completions this week.
  ///
  /// In en, this message translates to:
  /// **'You\'ve done {name} {count, plural, =1{1 time} other{{count} times}} this week'**
  String habit_insightBestThisWeek(String name, int count);

  /// Insight: encourage restarting a broken daily streak.
  ///
  /// In en, this message translates to:
  /// **'Pick {name} up again today. Your best is {best, plural, =1{1 day} other{{best} days}}.'**
  String habit_insightComebackDays(String name, int best);

  /// Insight: encourage restarting a broken weekly streak.
  ///
  /// In en, this message translates to:
  /// **'Pick {name} up again today. Your best is {best, plural, =1{1 week} other{{best} weeks}}.'**
  String habit_insightComebackWeeks(String name, int best);

  /// Insight card semantic label, habit tip.
  ///
  /// In en, this message translates to:
  /// **'Opens {name}: {text}'**
  String habit_insightOpensHabit(String text, String name);

  /// Home streak flame semantic label.
  ///
  /// In en, this message translates to:
  /// **'Best active streak: {count, plural, =1{1 day} other{{count} days}}'**
  String habit_streakBadgeLabelDays(int count);

  /// Home streak flame semantic label, weekly habit.
  ///
  /// In en, this message translates to:
  /// **'Best active streak: {count, plural, =1{1 week} other{{count} weeks}}'**
  String habit_streakBadgeLabelWeeks(int count);

  /// Home streak flame count for a weekly streak.
  ///
  /// In en, this message translates to:
  /// **'{count} wk'**
  String habit_streakBadgeWeeksShort(int count);

  /// Snackbar after unchecking a habit on Home.
  ///
  /// In en, this message translates to:
  /// **'{name} unchecked'**
  String habit_uncheckedSnack(String name);

  /// SET-06 accessibility action.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get modules_moveUp;

  /// SET-06 accessibility action.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get modules_moveDown;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get settings_modules;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// SET-01 error state message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your settings.'**
  String get settings_loadError;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// SET-01 language option that follows the device.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settings_languageSystem;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get settings_firstDayOfWeek;

  /// First day of week option.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settings_monday;

  /// First day of week option.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get settings_saturday;

  /// First day of week option.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settings_sunday;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settings_dateFormat;

  /// SET-01 row that opens SET-04.
  ///
  /// In en, this message translates to:
  /// **'Theme and colors'**
  String get settings_themeEntry;

  /// SET-01 row that opens SET-06.
  ///
  /// In en, this message translates to:
  /// **'Enable or reorder trackers'**
  String get settings_modulesEntry;

  /// SET-01 master notifications switch.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notificationsMaster;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Daily summary time'**
  String get settings_dailySummaryTime;

  /// SET-01 daily summary row helper text (the reminder's message).
  ///
  /// In en, this message translates to:
  /// **'Did you log today\'s expenses?'**
  String get settings_dailySummaryHelp;

  /// SET-01 switch.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get settings_budgetAlerts;

  /// SET-01 switch, shown when the Habit module is on.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get settings_habitReminders;

  /// SET-01 note when the OS blocks notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for DailyTrack'**
  String get settings_notificationsBlocked;

  /// SET-01 button that opens the system notification settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settings_openSystemSettings;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settings_privacyPolicy;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get settings_terms;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get settings_rateUs;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get settings_shareApp;

  /// Text shared by Share app.
  ///
  /// In en, this message translates to:
  /// **'I track my money and habits with DailyTrack: {url}'**
  String settings_shareAppText(String url);

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settings_sendFeedback;

  /// Feedback email subject.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack feedback ({version})'**
  String settings_feedbackSubject(String version);

  /// Feedback email body with device facts only (no app data, Constitution III).
  ///
  /// In en, this message translates to:
  /// **'Write your feedback above this line.\n\nApp version: {version} ({build})\nDevice: {device}\nAndroid: {android}\nDevice language: {language}'**
  String settings_feedbackBody(
    String version,
    String build,
    String device,
    String android,
    String language,
  );

  /// Dialog when no email app exists.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to us at {email}'**
  String settings_noEmailApp(String email);

  /// Button in the no-email-app dialog.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get settings_copyEmail;

  /// Snackbar after copying the support email.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get settings_emailCopied;

  /// Dialog close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settings_close;

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_appVersion;

  /// App version and build number.
  ///
  /// In en, this message translates to:
  /// **'{version} ({build})'**
  String settings_appVersionValue(String version, String build);

  /// SET-01 row.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settings_licenses;

  /// Web page load error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this page. Check your connection and try again.'**
  String get web_loadError;

  /// SET-04 title.
  ///
  /// In en, this message translates to:
  /// **'Theme and colors'**
  String get themes_title;

  /// SET-04 section.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themes_mode;

  /// Theme mode option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themes_system;

  /// Theme mode option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themes_light;

  /// Theme mode option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themes_dark;

  /// SET-04 section.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themes_colors;

  /// SET-04 section.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get themes_fontSize;

  /// Font size option.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themes_fontDefault;

  /// Font size option.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get themes_fontLarge;

  /// SET-04 preview card label.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get themes_preview;

  /// SET-04 preview sample card title.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get themes_previewSpent;

  /// SET-04 preview sample chip.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get themes_previewChip;

  /// Badge on premium themes.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get themes_pro;

  /// Theme tile semantic label when selected.
  ///
  /// In en, this message translates to:
  /// **'{name}, selected'**
  String themes_tileSelected(String name);

  /// Theme tile semantic label when locked.
  ///
  /// In en, this message translates to:
  /// **'{name}, Pro, locked'**
  String themes_tileLocked(String name);

  /// SET-04 locked theme overlay message.
  ///
  /// In en, this message translates to:
  /// **'Get Pro to use this theme'**
  String get themes_lockedMessage;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Default teal'**
  String get theme_default;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get theme_indigo;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Saffron'**
  String get theme_saffron;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get theme_forest;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get theme_rose;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get theme_midnight;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get theme_ocean;

  /// Color theme name.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get theme_mono;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_security;

  /// SET-01 row that opens SET-05.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settings_appLockEntry;

  /// Setting state.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settings_on;

  /// Setting state.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settings_off;

  /// SET-05 title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security_title;

  /// SET-05 switch.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get security_appLock;

  /// SET-05 row.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get security_changePin;

  /// SET-05 switch.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint / face unlock'**
  String get security_biometric;

  /// SET-05 note on rows that need app lock.
  ///
  /// In en, this message translates to:
  /// **'Turn on app lock first'**
  String get security_needsLock;

  /// SET-05 biometric unavailable: nothing enrolled.
  ///
  /// In en, this message translates to:
  /// **'Set up fingerprint or face unlock in your phone\'s settings'**
  String get security_biometricNotEnrolled;

  /// SET-05 biometric unavailable: no hardware.
  ///
  /// In en, this message translates to:
  /// **'This phone doesn\'t support fingerprint or face unlock'**
  String get security_biometricNone;

  /// SET-05 row.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get security_lockAfter;

  /// Lock after option.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get security_immediately;

  /// Lock after option.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get security_after1Min;

  /// Lock after option.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get security_after5Min;

  /// SET-05 switch.
  ///
  /// In en, this message translates to:
  /// **'Hide app content in recents'**
  String get security_hideInRecents;

  /// SET-05 switch helper text.
  ///
  /// In en, this message translates to:
  /// **'Also blocks screenshots.'**
  String get security_hideInRecentsHelp;

  /// Snackbar and onboarding status.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get security_lockOn;

  /// Snackbar after turning the lock off.
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get security_lockOff;

  /// Snackbar after changing the PIN.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get security_pinChanged;

  /// SYS-03 title.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get lock_enterPin;

  /// SYS-03/SYS-04 error.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get lock_wrongPin;

  /// SYS-03 error from the 3rd wrong PIN.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {count, plural, =1{1 attempt left} other{{count} attempts left}}'**
  String lock_attemptsLeft(int count);

  /// SYS-03 lockout countdown; time is m:ss.
  ///
  /// In en, this message translates to:
  /// **'Try again in {time}'**
  String lock_tryAgainIn(String time);

  /// SYS-03 warning after a lockout; time is m:ss.
  ///
  /// In en, this message translates to:
  /// **'Next wrong PIN locks the app for {time}'**
  String lock_nextLockoutWarning(String time);

  /// SYS-03 when the stored PIN cannot be read.
  ///
  /// In en, this message translates to:
  /// **'App lock can\'t be checked on this phone.'**
  String get lock_credentialUnavailable;

  /// System biometric prompt reason.
  ///
  /// In en, this message translates to:
  /// **'Unlock DailyTrack'**
  String get lock_biometricReason;

  /// Keypad biometric key label.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get lock_useBiometric;

  /// Keypad backspace key label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get lock_delete;

  /// PIN dots semantic label.
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 digits entered'**
  String lock_dotsLabel(int count);

  /// SYS-04 step title.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get pin_enterCurrent;

  /// SYS-04 step title.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get pin_enterNew;

  /// SYS-04 step title.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get pin_confirmNew;

  /// SYS-04 confirm mismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pin_mismatch;

  /// SYS-04 biometric offer after first setup.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint / face unlock'**
  String get pin_offerBiometric;

  /// SYS-04 finish button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pin_done;

  /// SYS-04 save failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your PIN. Try again.'**
  String get pin_saveError;

  /// SYS-02 step 4 button.
  ///
  /// In en, this message translates to:
  /// **'Set app lock'**
  String get onboarding_setAppLock;

  /// SYS-02 step 4 button once the lock is on.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get onboarding_changePin;

  /// SET-01 section header.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settings_data;

  /// SET-01 Data row.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get settings_eraseAll;

  /// Erase step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Erase all data?'**
  String get erase_title;

  /// Erase step 1 consequence text.
  ///
  /// In en, this message translates to:
  /// **'This deletes your transactions, accounts, categories, budgets, recurring entries, habits and check-ins, settings, and app lock. This can\'t be undone.'**
  String get erase_body;

  /// Erase step 1 confirm button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get erase_continue;

  /// Erase step 2 title; DELETE is not translated.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get erase_typeTitle;

  /// Erase step 2 field hint; not translated.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get erase_typeHint;

  /// Erase step 2 destructive button.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get erase_confirm;

  /// Erase progress.
  ///
  /// In en, this message translates to:
  /// **'Erasing…'**
  String get erase_inProgress;

  /// Erase failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t erase your data. Nothing was deleted.'**
  String get erase_failed;

  /// SYS-03 link.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get lock_forgotPin;

  /// Forgot PIN sheet title.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get lock_forgotTitle;

  /// Forgot PIN sheet body.
  ///
  /// In en, this message translates to:
  /// **'Your PIN can\'t be recovered. You can erase all data and start fresh.'**
  String get lock_forgotBody;

  /// SET-02 title and SET-01 Data row.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backup_title;

  /// SET-02 card title.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backup_lastBackupTitle;

  /// SET-02 Last backup when none exists.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get backup_noBackupYet;

  /// SET-02 Last backup line: date and time, location, file size.
  ///
  /// In en, this message translates to:
  /// **'{date} · {location} · {size}'**
  String backup_lastBackupDetail(String date, String location, String size);

  /// Backup location.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get backup_locationDevice;

  /// Backup location; product name, not translated.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get backup_locationDrive;

  /// SET-01 Data row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String backup_lastBackupSubtitle(String date);

  /// SET-01 Data row subtitle when no backup exists.
  ///
  /// In en, this message translates to:
  /// **'Not backed up yet'**
  String get backup_notBackedUp;

  /// SET-02 Local backup card title.
  ///
  /// In en, this message translates to:
  /// **'Backup file'**
  String get backup_localTitle;

  /// SET-02 Local backup card body.
  ///
  /// In en, this message translates to:
  /// **'Save all your data as one file on this phone, or restore from a file.'**
  String get backup_localBody;

  /// SET-02 primary button.
  ///
  /// In en, this message translates to:
  /// **'Save backup file'**
  String get backup_saveFile;

  /// SET-02 button.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backup_restoreFile;

  /// Snackbar after a successful save.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backup_saved;

  /// Snackbar action: share the saved backup file.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get backup_share;

  /// SET-02 progress while backing up.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get backup_working;

  /// SET-02 section title.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get backup_optionsTitle;

  /// SET-02 switch.
  ///
  /// In en, this message translates to:
  /// **'Encrypt backup'**
  String get backup_encrypt;

  /// SET-02 switch helper text.
  ///
  /// In en, this message translates to:
  /// **'Protects backup files with a password'**
  String get backup_encryptHelp;

  /// SET-02 row shown while encryption is on.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get backup_changePassword;

  /// SET-02 switch.
  ///
  /// In en, this message translates to:
  /// **'Include receipt images'**
  String get backup_includeReceipts;

  /// SET-02 switch helper text.
  ///
  /// In en, this message translates to:
  /// **'Makes the backup file larger'**
  String get backup_includeReceiptsHelp;

  /// Restore summary for the Expense module.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String backup_countTransactions(int count);

  /// Restore summary for the Habit module.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No habits} =1{1 habit} other{{count} habits}}'**
  String backup_countHabits(int count);

  /// Password sheet title when turning encryption on.
  ///
  /// In en, this message translates to:
  /// **'Set backup password'**
  String get backup_passwordTitle;

  /// Password sheet title when changing it.
  ///
  /// In en, this message translates to:
  /// **'Change backup password'**
  String get backup_passwordChangeTitle;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backup_passwordField;

  /// Password confirmation field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backup_passwordConfirm;

  /// Password sheet warning.
  ///
  /// In en, this message translates to:
  /// **'If you lose this password, backups made with it can\'t be restored. It can\'t be recovered.'**
  String get backup_passwordWarning;

  /// Password sheet error.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get backup_passwordMismatch;

  /// Password sheet primary button.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get backup_passwordSave;

  /// Restore: password prompt title.
  ///
  /// In en, this message translates to:
  /// **'Enter backup password'**
  String get restore_passwordTitle;

  /// Restore: password prompt button.
  ///
  /// In en, this message translates to:
  /// **'Open backup'**
  String get restore_open;

  /// Restore summary title.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restore_previewTitle;

  /// Restore summary: when the backup was made.
  ///
  /// In en, this message translates to:
  /// **'Made on {date}'**
  String restore_previewCreated(String date);

  /// Restore summary: app version that made it.
  ///
  /// In en, this message translates to:
  /// **'App version {version}'**
  String restore_previewVersion(String version);

  /// Restore summary: receipts in the file.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Includes 1 receipt image} other{Includes {count} receipt images}}'**
  String restore_previewReceipts(int count);

  /// Restore summary: unknown module sections.
  ///
  /// In en, this message translates to:
  /// **'Some data in this backup is from a feature this version doesn\'t have. It will be skipped.'**
  String get restore_previewSkipped;

  /// Restore summary button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get restore_continue;

  /// Restore confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Replace current data?'**
  String get restore_confirmTitle;

  /// Restore confirmation consequence text.
  ///
  /// In en, this message translates to:
  /// **'All your current transactions, accounts, categories, budgets, recurring entries, habits, check-ins, and preferences will be replaced by this backup. This can\'t be undone.'**
  String get restore_confirmBody;

  /// Restore confirmation destructive button.
  ///
  /// In en, this message translates to:
  /// **'Replace data'**
  String get restore_confirmAction;

  /// Restore progress.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get restore_inProgress;

  /// Snackbar after a successful restore.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restore_done;

  /// Snackbar after a restore whose receipt folder swap failed.
  ///
  /// In en, this message translates to:
  /// **'Backup restored, but some receipt images couldn\'t be copied.'**
  String get restore_doneMissingReceipts;

  /// Restore error dialog title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore'**
  String get restore_failedTitle;

  /// Backup error dialog title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t back up'**
  String get backup_failedTitle;

  /// BackupNotRecognized message.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a DailyTrack backup. Nothing was changed.'**
  String get backup_errNotRecognized;

  /// BackupDamaged message.
  ///
  /// In en, this message translates to:
  /// **'This backup file is damaged and can\'t be read. Nothing was changed.'**
  String get backup_errDamaged;

  /// BackupInvalid message.
  ///
  /// In en, this message translates to:
  /// **'This backup has data DailyTrack can\'t use. Nothing was changed.'**
  String get backup_errInvalid;

  /// BackupTooNew message.
  ///
  /// In en, this message translates to:
  /// **'Update DailyTrack to restore this backup.'**
  String get backup_errTooNew;

  /// BackupWrongPassword message; no hint about which.
  ///
  /// In en, this message translates to:
  /// **'Wrong password or damaged file.'**
  String get backup_errWrongPassword;

  /// BackupNeedsPassword message.
  ///
  /// In en, this message translates to:
  /// **'Set your backup password again to keep making encrypted backups.'**
  String get backup_errNeedsPassword;

  /// BackupTooLargeToEncrypt message.
  ///
  /// In en, this message translates to:
  /// **'This backup is too large to encrypt. Turn off receipt images and try again.'**
  String get backup_errTooLarge;

  /// BackupBusy message.
  ///
  /// In en, this message translates to:
  /// **'A backup or restore is already running. Try again in a moment.'**
  String get backup_errBusy;

  /// BackupStorageFull message.
  ///
  /// In en, this message translates to:
  /// **'There isn\'t enough storage on this phone. Free up some space and try again.'**
  String get backup_errStorage;

  /// Unexpected backup or restore error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Nothing was changed.'**
  String get backup_errGeneric;

  /// SET-02 card title; product name, not translated.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get backup_driveTitle;

  /// SET-02 Drive card explanation.
  ///
  /// In en, this message translates to:
  /// **'Back up to your own Google Drive. Backups are stored in a private app folder you won\'t see in your Drive files.'**
  String get backup_driveBody;

  /// SET-02 Drive card when no client ID is configured.
  ///
  /// In en, this message translates to:
  /// **'Google Drive isn\'t available in this build.'**
  String get backup_driveUnavailable;

  /// SET-02 connected account line.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email}'**
  String backup_connected(String email);

  /// SET-02 primary button when connected.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backup_backUpNow;

  /// SET-02 progress.
  ///
  /// In en, this message translates to:
  /// **'Backing up to Google Drive…'**
  String get backup_uploading;

  /// Snackbar after a Drive backup.
  ///
  /// In en, this message translates to:
  /// **'Backed up to Google Drive'**
  String get backup_driveSaved;

  /// SET-02 row and choice sheet title.
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get backup_autoTitle;

  /// Auto backup option.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get backup_autoOff;

  /// Auto backup option.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backup_autoDaily;

  /// Auto backup option.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backup_autoWeekly;

  /// SET-02 switch.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get backup_wifiOnly;

  /// SET-02 switch helper.
  ///
  /// In en, this message translates to:
  /// **'Waits for Wi-Fi before backing up'**
  String get backup_wifiOnlyHelp;

  /// SET-02 section title and Drive picker title.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get backup_driveListTitle;

  /// Drive list empty state.
  ///
  /// In en, this message translates to:
  /// **'No backups in Google Drive yet'**
  String get backup_driveListEmpty;

  /// Drive list error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your Google Drive backups.'**
  String get backup_driveListError;

  /// Drive list row: date and time, file size.
  ///
  /// In en, this message translates to:
  /// **'{date} · {size}'**
  String backup_driveEntry(String date, String size);

  /// Drive list label for a backup made with Back up now.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get backup_kindManual;

  /// Drive list label for an automatic backup.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get backup_kindAuto;

  /// Drive list row action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get backup_delete;

  /// Delete confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete this backup?'**
  String get backup_deleteTitle;

  /// Delete confirmation consequence.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from Google Drive. This can\'t be undone.'**
  String get backup_deleteBody;

  /// Delete confirmation destructive button.
  ///
  /// In en, this message translates to:
  /// **'Delete backup'**
  String get backup_deleteAction;

  /// Drive list overflow button label.
  ///
  /// In en, this message translates to:
  /// **'More actions for this backup'**
  String get backup_moreActions;

  /// Progress while listing Drive backups.
  ///
  /// In en, this message translates to:
  /// **'Loading your backups…'**
  String get backup_listLoading;

  /// Progress while downloading a Drive backup.
  ///
  /// In en, this message translates to:
  /// **'Downloading backup…'**
  String get backup_downloading;

  /// DriveAuthRequired message.
  ///
  /// In en, this message translates to:
  /// **'Your Google account needs to be connected again.'**
  String get backup_errAuth;

  /// Action for an auth error.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Google account'**
  String get backup_reconnect;

  /// DriveQuotaExceeded message.
  ///
  /// In en, this message translates to:
  /// **'Your Google Drive is full. Free up space in Drive and try again.'**
  String get backup_errQuota;

  /// DriveOffline message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Google Drive. Check your connection and try again.'**
  String get backup_errOffline;

  /// DriveUnavailable message.
  ///
  /// In en, this message translates to:
  /// **'Google Drive isn\'t responding right now. Try again later.'**
  String get backup_errDrive;

  /// Android notification channel name.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get notif_channelBackup;

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'Tells you when automatic backup keeps failing'**
  String get notif_channelBackupDescription;

  /// Backup failure notification title.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup isn\'t working'**
  String get notif_backupFailingTitle;

  /// Backup failure notification body.
  ///
  /// In en, this message translates to:
  /// **'Your last 3 backups to Google Drive failed. Tap to check.'**
  String get notif_backupFailingBody;

  /// Forgot PIN sheet body when Drive restore is available.
  ///
  /// In en, this message translates to:
  /// **'Your PIN can\'t be recovered. You can restore your data from a Google Drive backup, or erase all data and start fresh.'**
  String get lock_forgotBodyRestore;

  /// Forgot PIN primary button.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive backup'**
  String get lock_restoreFromDrive;

  /// SET-03 title and SET-01 Data row.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get export_title;

  /// SET-01 Export data row subtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV or PDF'**
  String get export_settingsHelp;

  /// SET-03 data type label.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get export_dataType;

  /// SET-03 data type and PDF title.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get export_transactions;

  /// SET-03 data type and PDF title.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get export_habits;

  /// SET-03 period label.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get export_period;

  /// SET-03 format label.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get export_format;

  /// Format name; not translated.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get export_csv;

  /// Format name; not translated.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get export_pdf;

  /// SET-03 filters label.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get export_filtersTitle;

  /// SET-03 filter.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get export_accounts;

  /// SET-03 filter.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get export_categories;

  /// SET-03 filter value when nothing is narrowed.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get export_all;

  /// SET-03 filter value.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String export_selected(int count);

  /// Filter sheet button.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get export_filterDone;

  /// SET-03 primary button.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_button;

  /// SET-03 progress.
  ///
  /// In en, this message translates to:
  /// **'Creating your file…'**
  String get export_working;

  /// SET-03 locked overlay message (feature 009).
  ///
  /// In en, this message translates to:
  /// **'Exports are part of DailyTrack Pro. Watch an ad for one export, or get Pro.'**
  String get export_locked;

  /// Snackbar when the export would be empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export for this period'**
  String get export_nothing;

  /// Export error dialog title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export'**
  String get export_failedTitle;

  /// Export error message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the file. Nothing was shared. Try again.'**
  String get export_failed;

  /// EXP-11 app bar action label.
  ///
  /// In en, this message translates to:
  /// **'Export this report'**
  String get export_reportAction;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get export_colDate;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get export_colTime;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get export_colType;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get export_colCategory;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get export_colAccount;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get export_colPaymentMode;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get export_colAmount;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get export_colNote;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get export_colHabit;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get export_colValue;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get export_colTarget;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get export_colUnit;

  /// Export column.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get export_colStatus;

  /// Habit export status.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get export_statusDone;

  /// Habit export status.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get export_statusPartial;

  /// Habit export status: a streak freeze day.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get export_statusFreeze;

  /// PDF summary label.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get export_totalIncome;

  /// PDF summary label.
  ///
  /// In en, this message translates to:
  /// **'Total expense'**
  String get export_totalExpense;

  /// PDF summary label.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get export_net;

  /// PDF summary label: number of rows.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get export_count;

  /// PDF summary: a habit's completion rate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String export_percent(int percent);

  /// PDF filter line.
  ///
  /// In en, this message translates to:
  /// **'Accounts: {names}'**
  String export_filterAccounts(String names);

  /// PDF filter line.
  ///
  /// In en, this message translates to:
  /// **'Categories: {names}'**
  String export_filterCategories(String names);

  /// Export account cell of a transfer.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String export_transfer(String from, String to);

  /// PDF chart title.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get export_chartTitle;

  /// PDF chart slice for small categories.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get export_other;

  /// PDF section title.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get export_summaryTitle;

  /// PDF page header.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack · {title} · {period}'**
  String export_pdfHeader(String title, String period);

  /// PDF page footer.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String export_page(int page, int pages);

  /// Android notification channel name.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get notif_channelDailySummary;

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'Your spending and habits for the day'**
  String get notif_channelDailySummaryDescription;

  /// Daily summary notification title.
  ///
  /// In en, this message translates to:
  /// **'Today in DailyTrack'**
  String get notif_dailySummaryTitle;

  /// Daily summary body with both modules.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount} today · {done}/{total} habits done'**
  String notif_dailySummaryBoth(String amount, int done, int total);

  /// Daily summary body, Expense only.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount} today'**
  String notif_dailySummarySpend(String amount);

  /// Daily summary body, Habit only.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} habits done'**
  String notif_dailySummaryHabits(int done, int total);

  /// Habit reminder button (yes/no habits).
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get notif_actionMarkDone;

  /// Habit reminder button: remind again in one hour.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 h'**
  String get notif_actionSnooze;

  /// SET-01 note when exact alarms are not allowed.
  ///
  /// In en, this message translates to:
  /// **'Reminders may arrive a few minutes late'**
  String get settings_exactNote;

  /// SET-01 note action: opens the system alarms page.
  ///
  /// In en, this message translates to:
  /// **'Allow exact timing'**
  String get settings_exactAllow;

  /// SET-05 switch.
  ///
  /// In en, this message translates to:
  /// **'Show data on widget'**
  String get security_showWidgetData;

  /// SET-05 switch helper text.
  ///
  /// In en, this message translates to:
  /// **'Shows amounts and habit names on your home screen'**
  String get security_showWidgetDataHelp;

  /// Home screen widget name in the widget picker.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack today'**
  String get widget_label;

  /// Widget picker description.
  ///
  /// In en, this message translates to:
  /// **'Today\'s spending, budget, and habit checks'**
  String get widget_description;

  /// Widget text when data is hidden.
  ///
  /// In en, this message translates to:
  /// **'Open DailyTrack'**
  String get widget_open;

  /// Widget spend label.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get widget_spentToday;

  /// Widget spend content description.
  ///
  /// In en, this message translates to:
  /// **'Spent today, {amount}'**
  String widget_spentTodayA11y(String amount);

  /// Widget budget label.
  ///
  /// In en, this message translates to:
  /// **'{month} budget'**
  String widget_monthBudget(String month);

  /// Widget budget text.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used · {spent} of {limit}'**
  String widget_budgetText(int percent, String spent, String limit);

  /// Widget when there is no Overall budget.
  ///
  /// In en, this message translates to:
  /// **'No budget set'**
  String get widget_noBudget;

  /// Widget count habit progress without a unit.
  ///
  /// In en, this message translates to:
  /// **'{value} / {target}'**
  String widget_progress(int value, int target);

  /// Widget count habit progress with its unit.
  ///
  /// In en, this message translates to:
  /// **'{value} / {target} {unit}'**
  String widget_progressUnit(int value, int target, String unit);

  /// Widget content description of a done habit.
  ///
  /// In en, this message translates to:
  /// **'{name}, done'**
  String widget_habitDoneA11y(String name);

  /// Widget content description of a yes/no habit to check.
  ///
  /// In en, this message translates to:
  /// **'{name}, not done. Double tap to mark done'**
  String widget_habitTodoA11y(String name);

  /// Widget content description of a count habit.
  ///
  /// In en, this message translates to:
  /// **'{name}, {progress}. Double tap to add one'**
  String widget_habitCountA11y(String name, String progress);

  /// Label on every native ad (spec §15.8).
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get ads_badge;

  /// Semantic label of a banner or native ad.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get ads_bannerLabel;

  /// SET-01 Privacy row; reopens the consent form (FR-014).
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get privacy_adChoices;

  /// Dev-only SET-01 action (FR-048).
  ///
  /// In en, this message translates to:
  /// **'Reset ad counters'**
  String get ads_resetCounters;

  /// Snackbar after Reset ad counters.
  ///
  /// In en, this message translates to:
  /// **'Ad counters reset'**
  String get ads_resetCountersDone;

  /// PRM-01 headline.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack Pro'**
  String get premium_title;

  /// PRM-01 benefit.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get premium_benefitNoAds;

  /// PRM-01 benefit.
  ///
  /// In en, this message translates to:
  /// **'All themes'**
  String get premium_benefitThemes;

  /// PRM-01 benefit.
  ///
  /// In en, this message translates to:
  /// **'Advanced reports'**
  String get premium_benefitReports;

  /// PRM-01 benefit.
  ///
  /// In en, this message translates to:
  /// **'Unlimited exports'**
  String get premium_benefitExports;

  /// PRM-01 benefit.
  ///
  /// In en, this message translates to:
  /// **'Unlimited streak freezes up to the cap'**
  String get premium_benefitFreezes;

  /// PRM-02 title.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced reports for 24 hours'**
  String get rewarded_titleReports;

  /// PRM-02 title.
  ///
  /// In en, this message translates to:
  /// **'Unlock one CSV export'**
  String get rewarded_titleCsv;

  /// PRM-02 title.
  ///
  /// In en, this message translates to:
  /// **'Unlock one PDF export'**
  String get rewarded_titlePdf;

  /// PRM-02 title; theme name.
  ///
  /// In en, this message translates to:
  /// **'Unlock the {theme} theme for good'**
  String rewarded_titleTheme(String theme);

  /// PRM-02 title; habit name.
  ///
  /// In en, this message translates to:
  /// **'Get 1 streak freeze for {habit}'**
  String rewarded_titleFreeze(String habit);

  /// PRM-02 explanation.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to see Trends, Accounts, and every period for the next 24 hours.'**
  String get rewarded_explainReports;

  /// PRM-02 explanation.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to create one export file in this format.'**
  String get rewarded_explainExport;

  /// PRM-02 explanation.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to keep this color theme for good.'**
  String get rewarded_explainTheme;

  /// PRM-02 explanation.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to add one streak freeze to this habit (up to 2).'**
  String get rewarded_explainFreeze;

  /// PRM-02 primary button.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad'**
  String get rewarded_watch;

  /// PRM-02 secondary button.
  ///
  /// In en, this message translates to:
  /// **'Get Pro instead'**
  String get rewarded_getPro;

  /// PRM-02 text button.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get rewarded_notNow;

  /// Semantic label of the PRM-02 spinner.
  ///
  /// In en, this message translates to:
  /// **'Loading ad'**
  String get rewarded_loadingAd;

  /// PRM-02 when no ad loads in 8 s.
  ///
  /// In en, this message translates to:
  /// **'Ad not available, try again later'**
  String get rewarded_unavailable;

  /// PRM-02 button after a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get rewarded_tryAgain;

  /// PRM-02 after the ad was closed early.
  ///
  /// In en, this message translates to:
  /// **'Watch the whole ad to unlock'**
  String get rewarded_closedEarly;

  /// PRM-02 at 10 rewards per feature per day (FR-053).
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit for this unlock. Try again tomorrow, or get Pro.'**
  String get rewarded_limitReached;

  /// EXP-11 and HAB-03 locked overlay.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to unlock for 24 hours'**
  String get locked_watchAdReports;

  /// SET-03 locked overlay.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to unlock one export'**
  String get locked_watchAdExport;

  /// SET-04 locked overlay.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to unlock this theme'**
  String get locked_watchAdTheme;

  /// HAB-03 freeze card button.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to get a freeze'**
  String get locked_watchAdFreeze;

  /// PRM-01 primary button; price from Google Play.
  ///
  /// In en, this message translates to:
  /// **'Get Pro for {price}'**
  String premium_buyFor(String price);

  /// PRM-01 text button.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get premium_restore;

  /// Snackbar after Restore purchase found Pro.
  ///
  /// In en, this message translates to:
  /// **'Pro restored'**
  String get premium_restored;

  /// Snackbar after Restore purchase found nothing.
  ///
  /// In en, this message translates to:
  /// **'No Pro purchase found for this Google account'**
  String get premium_restoreNotFound;

  /// PRM-01 when Google Play can't sell Pro.
  ///
  /// In en, this message translates to:
  /// **'Store not available right now, try again later'**
  String get premium_storeUnavailable;

  /// PRM-01 note.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is tied to your Google account.'**
  String get premium_accountNote;

  /// PRM-01 pending payment.
  ///
  /// In en, this message translates to:
  /// **'Pro unlocks when the payment completes'**
  String get premium_pending;

  /// PRM-01 purchase error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the purchase. Try again.'**
  String get premium_purchaseError;

  /// PRM-01 when Pro is owned.
  ///
  /// In en, this message translates to:
  /// **'You have Pro. Thanks for your support.'**
  String get premium_owned;

  /// SET-01 premium card title.
  ///
  /// In en, this message translates to:
  /// **'Remove ads and unlock everything'**
  String get premium_cardTitle;

  /// SET-01 premium card subtitle.
  ///
  /// In en, this message translates to:
  /// **'DailyTrack Pro: one purchase, yours for good'**
  String get premium_cardSubtitle;

  /// HAB-03 freeze card button for Pro users.
  ///
  /// In en, this message translates to:
  /// **'Add a freeze'**
  String get habit_addFreezePro;

  /// ACC-01 title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_title;

  /// ACC-01 signed-out title.
  ///
  /// In en, this message translates to:
  /// **'Back up with your Google account'**
  String get account_signedOutTitle;

  /// ACC-01 signed-out point 1.
  ///
  /// In en, this message translates to:
  /// **'Your data is saved to your own Google Drive'**
  String get account_pointDrive;

  /// ACC-01 signed-out point 2.
  ///
  /// In en, this message translates to:
  /// **'Restore it on a new phone'**
  String get account_pointRestore;

  /// ACC-01 signed-out point 3.
  ///
  /// In en, this message translates to:
  /// **'Optional: the app works fully without an account'**
  String get account_pointOptional;

  /// ACC-01 and SET-02 sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get account_signIn;

  /// ACC-01 signed-out footnote.
  ///
  /// In en, this message translates to:
  /// **'Your app lock PIN is never backed up.'**
  String get account_pinFootnote;

  /// Sign-in failure message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Check your connection and try again.'**
  String get account_signInFailed;

  /// ACC-02 offline state; restore is disabled (spec §16).
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to restore'**
  String get account_restoreOffline;

  /// Shown instead of signing in while the phone is offline (spec §16).
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to sign in with Google'**
  String get account_signInOffline;

  /// Snackbar after signing in to an account without backups.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Your data is backed up.'**
  String get account_signedInBackedUp;

  /// ACC-01 last backup line with the device that made it.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time} · {device}'**
  String account_lastBackupFrom(String time, String device);

  /// ACC-01 last backup line.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time}'**
  String account_lastBackup(String time);

  /// ACC-01 status when the account has no backups.
  ///
  /// In en, this message translates to:
  /// **'No backup in this account yet'**
  String get account_noBackupYet;

  /// ACC-01 state line (spec §16).
  ///
  /// In en, this message translates to:
  /// **'Backed up to Google'**
  String get account_statusBackedUp;

  /// ACC-01 offline state line; also why the network actions are disabled.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Backups resume when you\'re back online.'**
  String get account_statusOffline;

  /// ACC-01 state line: a background backup waits for Wi-Fi (Wi-Fi only is on).
  ///
  /// In en, this message translates to:
  /// **'Waiting for Wi-Fi'**
  String get account_statusWaitingForWifi;

  /// ACC-01 state line: Encrypt backup is on but the password is missing.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: set your backup password in Backup and restore'**
  String get account_statusFailedNoPassword;

  /// ACC-03 step 1 when nothing changed since the last backup.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get account_signOutBackedUp;

  /// ACC-01 state line.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get account_statusBackingUp;

  /// ACC-01 state line.
  ///
  /// In en, this message translates to:
  /// **'Backup paused: a newer backup from another phone exists'**
  String get account_statusPaused;

  /// ACC-01 state line.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get account_statusFailed;

  /// ACC-01 status area error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your backups.'**
  String get account_statusError;

  /// ACC-01 Auto backup row.
  ///
  /// In en, this message translates to:
  /// **'{frequency} · Wi-Fi only'**
  String account_autoSummaryWifi(String frequency);

  /// ACC-01 text button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get account_signOut;

  /// Snackbar after signing out.
  ///
  /// In en, this message translates to:
  /// **'Signed out. Your data is still on this phone.'**
  String get account_signedOut;

  /// ACC-01 destructive text button.
  ///
  /// In en, this message translates to:
  /// **'Delete my backups'**
  String get account_deleteBackups;

  /// Delete my backups confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete your backups?'**
  String get account_deleteTitle;

  /// Delete my backups confirmation consequence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 DailyTrack backup from {email}? Data on this phone stays. This can\'t be undone.} other{Delete all {count} DailyTrack backups from {email}? Data on this phone stays. This can\'t be undone.}}'**
  String account_deleteBody(int count, String email);

  /// Delete my backups destructive button.
  ///
  /// In en, this message translates to:
  /// **'Delete backups'**
  String get account_deleteAction;

  /// Snackbar after Delete my backups.
  ///
  /// In en, this message translates to:
  /// **'Your backups were deleted'**
  String get account_deleted;

  /// ACC-01 account photo semantic label.
  ///
  /// In en, this message translates to:
  /// **'Profile photo of {name}'**
  String account_photoOf(String name);

  /// SET-02 account row subtitle; opens ACC-01.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get backup_manageAccount;

  /// Conflict dialog title.
  ///
  /// In en, this message translates to:
  /// **'Back up anyway?'**
  String get backup_conflictTitle;

  /// Conflict dialog: another phone backed up newer data.
  ///
  /// In en, this message translates to:
  /// **'A newer backup from {device} ({time}) exists. Backing up now makes this phone\'s data the latest.'**
  String backup_conflictNewer(String device, String time);

  /// Conflict dialog: empty phone over a backup with data.
  ///
  /// In en, this message translates to:
  /// **'This phone has no data. Backing up now makes an empty backup the latest.'**
  String get backup_conflictEmpty;

  /// Conflict dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Back up anyway'**
  String get backup_backUpAnyway;

  /// Device name when a backup doesn't say.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get backup_unknownDevice;

  /// Device name when the phone reports neither manufacturer nor model.
  ///
  /// In en, this message translates to:
  /// **'Android phone'**
  String get account_androidPhone;

  /// Pause notification title.
  ///
  /// In en, this message translates to:
  /// **'Backup paused'**
  String get notif_backupPausedTitle;

  /// Pause notification body.
  ///
  /// In en, this message translates to:
  /// **'Another phone made a newer backup. Tap to review.'**
  String get notif_backupPausedBody;

  /// ACC-02 title.
  ///
  /// In en, this message translates to:
  /// **'Backup found on {email}'**
  String account_choiceTitle(String email);

  /// ACC-02 device line when the backup came from this phone.
  ///
  /// In en, this message translates to:
  /// **'From this phone'**
  String get account_fromThisPhone;

  /// ACC-02 device line.
  ///
  /// In en, this message translates to:
  /// **'From {device}'**
  String account_fromDevice(String device);

  /// ACC-02 label next to a lock icon.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get account_encrypted;

  /// ACC-02 line with this phone's data counts.
  ///
  /// In en, this message translates to:
  /// **'This phone: {counts}'**
  String account_thisPhone(String counts);

  /// ACC-02 line when this phone has no counts.
  ///
  /// In en, this message translates to:
  /// **'This phone: no data yet'**
  String get account_thisPhoneEmpty;

  /// ACC-02 note above the buttons.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces the data on this phone.'**
  String get account_replaceNote;

  /// ACC-02 primary button.
  ///
  /// In en, this message translates to:
  /// **'Restore from account'**
  String get account_restoreFromAccount;

  /// ACC-02 secondary button.
  ///
  /// In en, this message translates to:
  /// **'Keep this phone\'s data'**
  String get account_keepThisPhone;

  /// ACC-02 link to the SET-02 Drive list.
  ///
  /// In en, this message translates to:
  /// **'See all backups'**
  String get account_seeAllBackups;

  /// ACC-02 close button when opened from ACC-01.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get account_close;

  /// Inline error for a wrong backup password.
  ///
  /// In en, this message translates to:
  /// **'That password didn\'t work'**
  String get account_wrongPassword;

  /// Restore from the account failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore. Your data on this phone wasn\'t changed.'**
  String get account_restoreFailed;

  /// The safety copy couldn't be saved; nothing was restored.
  ///
  /// In en, this message translates to:
  /// **'Not enough free space to save a copy of this phone\'s data first, so nothing was restored. Free up space and try again.'**
  String get account_safetyCopyFailed;

  /// Snackbar after a restore, e.g. 'Restored 1,240 transactions · 8 habits'.
  ///
  /// In en, this message translates to:
  /// **'Restored {summary}'**
  String account_restoredCounts(String summary);

  /// Progress while restoring from the account.
  ///
  /// In en, this message translates to:
  /// **'Restoring your data…'**
  String get account_restoring;

  /// ACC-01 secondary button.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get account_restore;

  /// ACC-01 link next to Backup paused.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get account_review;

  /// ACC-01 text button.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get account_switch;

  /// Switch account: the backup to the current account failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t back up first'**
  String get account_switchFailedTitle;

  /// Switch account failure dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your latest changes aren\'t in {email} yet. Switch anyway? Your data stays on this phone.'**
  String account_switchFailedBody(String email);

  /// Switch account failure dialog button.
  ///
  /// In en, this message translates to:
  /// **'Switch anyway'**
  String get account_switchAnyway;

  /// Shown when Drive says the sign-in expired or access was removed.
  ///
  /// In en, this message translates to:
  /// **'Your Google sign-in expired. Sign in again to keep backing up.'**
  String get account_sessionExpired;

  /// ACC-03 title.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {email}?'**
  String account_signOutSheetTitle(String email);

  /// ACC-03 step 1 progress.
  ///
  /// In en, this message translates to:
  /// **'Backing up your latest changes…'**
  String get account_signOutBackingUp;

  /// ACC-03 step 1 failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t back up your latest changes'**
  String get account_signOutBackupFailed;

  /// ACC-03 button after a failed backup.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get account_signOutAnyway;

  /// ACC-03 option.
  ///
  /// In en, this message translates to:
  /// **'Keep data on this phone'**
  String get account_keepData;

  /// ACC-03 option helper.
  ///
  /// In en, this message translates to:
  /// **'You can keep using the app without an account.'**
  String get account_keepDataHelp;

  /// ACC-03 option.
  ///
  /// In en, this message translates to:
  /// **'Remove data from this phone'**
  String get account_removeData;

  /// ACC-03 option helper.
  ///
  /// In en, this message translates to:
  /// **'Your backup stays in your Google account.'**
  String get account_removeDataHelp;

  /// AUTH-01 title.
  ///
  /// In en, this message translates to:
  /// **'Keep your data safe'**
  String get auth_title;

  /// AUTH-01 value line.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to back up your expenses and habits and get them back on a new phone.'**
  String get auth_body;

  /// AUTH-01 primary button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continueWithGoogle;

  /// AUTH-01 secondary button.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get auth_continueAsGuest;

  /// AUTH-01 note under the buttons.
  ///
  /// In en, this message translates to:
  /// **'As a guest, your data stays only on this phone.'**
  String get auth_guestNote;

  /// AUTH-01 inline error after the account chooser was closed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled. Try again or continue as a guest.'**
  String get auth_signInCancelled;

  /// AUTH-01 inline error when offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet to sign in with Google, or continue as a guest.'**
  String get auth_offline;

  /// AUTH-01 restore error view secondary button.
  ///
  /// In en, this message translates to:
  /// **'Continue without restoring'**
  String get auth_continueWithoutRestoring;

  /// SET-01 account card, guest state.
  ///
  /// In en, this message translates to:
  /// **'Guest · Data saved only on this phone'**
  String get accountCard_guestTitle;

  /// SET-01 account card status; {time} is relative, e.g. 5 min ago. Never 'Synced'.
  ///
  /// In en, this message translates to:
  /// **'Backed up to Google · {time}'**
  String accountCard_backedUp(String time);

  /// SET-01 account card status, warning color.
  ///
  /// In en, this message translates to:
  /// **'Backup paused'**
  String get accountCard_paused;

  /// Relative time under a minute, in the account card status.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get accountCard_justNow;

  /// Relative time in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 min ago} other{{count} min ago}}'**
  String accountCard_minutesAgo(int count);

  /// Relative time in hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String accountCard_hoursAgo(int count);

  /// Relative time in days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{yesterday} other{{count} days ago}}'**
  String accountCard_daysAgo(int count);

  /// SET-01 Data row, guest only, error color.
  ///
  /// In en, this message translates to:
  /// **'Log out of guest'**
  String get settings_logOutGuest;

  /// ACC-04 title.
  ///
  /// In en, this message translates to:
  /// **'Log out and delete your data?'**
  String get logOutGuest_title;

  /// ACC-04 body.
  ///
  /// In en, this message translates to:
  /// **'As a guest, your data is stored only on this phone. Logging out permanently deletes all your expenses, habits, budgets, receipts, and unlocks. This can\'t be undone.'**
  String get logOutGuest_body;

  /// ACC-04 text button.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google instead'**
  String get logOutGuest_signInInstead;

  /// ACC-04 destructive button.
  ///
  /// In en, this message translates to:
  /// **'Log out and delete'**
  String get logOutGuest_confirm;

  /// ACC-04 error; nothing was deleted.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your data. Try again.'**
  String get logOutGuest_failed;

  /// Finish setting up sheet title.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up'**
  String get finishSetup_title;

  /// Finish setting up sheet body.
  ///
  /// In en, this message translates to:
  /// **'Your data is back. Your app lock PIN is never backed up, so set a new one to keep your data private.'**
  String get finishSetup_body;

  /// Finish setting up primary button.
  ///
  /// In en, this message translates to:
  /// **'Set app lock'**
  String get finishSetup_setLock;

  /// Finish setting up button (Android 13+).
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get finishSetup_allowNotifications;

  /// Finish setting up dismiss button.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get finishSetup_notNow;

  /// SET-02 safety copy tile.
  ///
  /// In en, this message translates to:
  /// **'Restore previous phone data'**
  String get backup_previousTitle;

  /// SET-02 safety copy tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved {date} · {counts}'**
  String backup_previousDetail(String date, String counts);

  /// Display name of INR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get currency_INR;

  /// Display name of USD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currency_USD;

  /// Display name of EUR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currency_EUR;

  /// Display name of GBP (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currency_GBP;

  /// Display name of AED (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham'**
  String get currency_AED;

  /// Display name of SAR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get currency_SAR;

  /// Display name of QAR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal'**
  String get currency_QAR;

  /// Display name of KWD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get currency_KWD;

  /// Display name of OMR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Omani Rial'**
  String get currency_OMR;

  /// Display name of BHD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar'**
  String get currency_BHD;

  /// Display name of SGD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currency_SGD;

  /// Display name of MYR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currency_MYR;

  /// Display name of THB (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get currency_THB;

  /// Display name of IDR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currency_IDR;

  /// Display name of PHP (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Philippine Peso'**
  String get currency_PHP;

  /// Display name of JPY (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currency_JPY;

  /// Display name of CNY (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currency_CNY;

  /// Display name of HKD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currency_HKD;

  /// Display name of KRW (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get currency_KRW;

  /// Display name of AUD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currency_AUD;

  /// Display name of NZD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'New Zealand Dollar'**
  String get currency_NZD;

  /// Display name of CAD (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currency_CAD;

  /// Display name of CHF (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currency_CHF;

  /// Display name of SEK (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Swedish Krona'**
  String get currency_SEK;

  /// Display name of NOK (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Norwegian Krone'**
  String get currency_NOK;

  /// Display name of DKK (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Danish Krone'**
  String get currency_DKK;

  /// Display name of ZAR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currency_ZAR;

  /// Display name of NPR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Nepalese Rupee'**
  String get currency_NPR;

  /// Display name of BDT (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi Taka'**
  String get currency_BDT;

  /// Display name of LKR (SYS-02 step 2).
  ///
  /// In en, this message translates to:
  /// **'Sri Lankan Rupee'**
  String get currency_LKR;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
