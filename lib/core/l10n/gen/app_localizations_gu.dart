// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'DailyTrack';

  @override
  String get common_next => 'આગળ';

  @override
  String get common_back => 'પાછળ';

  @override
  String get common_skip => 'છોડો';

  @override
  String get common_retry => 'ફરી પ્રયાસ કરો';

  @override
  String get common_tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get common_comingSoon => 'ટૂંક સમયમાં';

  @override
  String get common_placeholderMessage => 'આગામી અપડેટમાં આવશે';

  @override
  String get common_previousMonth => 'પાછલો મહિનો';

  @override
  String get common_nextMonth => 'આગલો મહિનો';

  @override
  String get common_undo => 'પૂર્વવત્ કરો';

  @override
  String get common_cancel => 'રદ કરો';

  @override
  String get keypad_backspace => 'ભૂંસો';

  @override
  String get keypad_done => 'થઈ ગયું';

  @override
  String get premium_lockedLabel => 'Pro સુવિધા, લૉક છે';

  @override
  String get nav_home => 'હોમ';

  @override
  String get nav_expenses => 'ખર્ચ';

  @override
  String get nav_habits => 'આદતો';

  @override
  String get nav_more => 'વધુ';

  @override
  String get splash_errorMessage =>
      'તમારો ડેટા ખોલી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get onboarding_welcomeTitle => 'પૈસા અને આદતો એક જ જગ્યાએ ટ્રૅક કરો';

  @override
  String get onboarding_languageLabel => 'તમારી ભાષા પસંદ કરો';

  @override
  String get onboarding_currencyTitle => 'તમારું ચલણ પસંદ કરો';

  @override
  String get onboarding_currencySearchHint => 'ચલણ શોધો';

  @override
  String get onboarding_noMatches => 'કોઈ મેળ મળ્યો નથી';

  @override
  String get onboarding_clearSearch => 'શોધ સાફ કરો';

  @override
  String get onboarding_modulesTitle => 'તમે શું ટ્રૅક કરવા માંગો છો?';

  @override
  String get onboarding_atLeastOneModule => 'ઓછામાં ઓછું એક ટ્રૅકર ચાલુ રાખો';

  @override
  String get onboarding_privacyTitle => 'તમારો ડેટા તમારી પાસે રહે છે';

  @override
  String get onboarding_privacyBody =>
      'તમે જે પણ નોંધો છો તે આ ફોન પર જ રહે છે. આગળના પગલામાં તમે Google થી તેનો બેકઅપ લઈ શકો છો અથવા મહેમાન તરીકે ચાલુ રાખી શકો છો.';

  @override
  String get onboarding_allowNotifications => 'સૂચનાઓની મંજૂરી આપો';

  @override
  String get onboarding_notificationsGranted => 'સૂચનાઓ ચાલુ છે';

  @override
  String get onboarding_notificationsDenied =>
      'સૂચનાઓ બંધ છે. તમે તેમને પછીથી સેટિંગ્સમાં ચાલુ કરી શકો છો.';

  @override
  String get onboarding_getStarted => 'શરૂ કરો';

  @override
  String get onboarding_saveError =>
      'તમારી પસંદગીઓ સાચવી શકાઈ નહીં. ફરી પ્રયાસ કરો.';

  @override
  String onboarding_stepLabel(int current, int total) {
    return 'પગલું $current / $total';
  }

  @override
  String get modules_title => 'મોડ્યુલ';

  @override
  String get modules_expense => 'ખર્ચ';

  @override
  String get modules_habit => 'આદત';

  @override
  String get modules_water => 'પાણી';

  @override
  String get modules_period => 'પીરિયડ';

  @override
  String get modules_atLeastOne => 'ઓછામાં ઓછું એક મોડ્યુલ ચાલુ રહેવું જોઈએ';

  @override
  String get modules_errorMessage =>
      'તમારા મોડ્યુલ લોડ કે સેવ થઈ શક્યા નહીં. ફરી પ્રયાસ કરો.';

  @override
  String modules_reorderHandle(String name) {
    return '$nameનો ક્રમ બદલો';
  }

  @override
  String get more_modulesEntry => 'મોડ્યુલ';

  @override
  String get lock_title => 'DailyTrack લૉક છે';

  @override
  String get lock_placeholderMessage => 'અનલૉક આગામી અપડેટમાં આવશે';

  @override
  String get premium_watchAd => 'જાહેરાત જુઓ';

  @override
  String get premium_getPro => 'Pro મેળવો';

  @override
  String get language_en => 'English';

  @override
  String get language_hi => 'हिन्दी';

  @override
  String get language_gu => 'ગુજરાતી';

  @override
  String get expense_cat_food => 'ખોરાક';

  @override
  String get expense_cat_groceries => 'કરિયાણું';

  @override
  String get expense_cat_transport => 'પરિવહન';

  @override
  String get expense_cat_fuel => 'ઇંધણ';

  @override
  String get expense_cat_shopping => 'ખરીદી';

  @override
  String get expense_cat_bills => 'બિલ';

  @override
  String get expense_cat_rent => 'ભાડું';

  @override
  String get expense_cat_health => 'આરોગ્ય';

  @override
  String get expense_cat_education => 'શિક્ષણ';

  @override
  String get expense_cat_entertainment => 'મનોરંજન';

  @override
  String get expense_cat_travel => 'મુસાફરી';

  @override
  String get expense_cat_other => 'અન્ય';

  @override
  String get income_cat_salary => 'પગાર';

  @override
  String get income_cat_business => 'વ્યવસાય';

  @override
  String get income_cat_gift => 'ભેટ';

  @override
  String get income_cat_interest => 'વ્યાજ';

  @override
  String get income_cat_other => 'અન્ય આવક';

  @override
  String get expense_account_cash => 'રોકડ';

  @override
  String get common_previousDay => 'પાછલો દિવસ';

  @override
  String get common_nextDay => 'આગલો દિવસ';

  @override
  String get common_previousWeek => 'પાછલું અઠવાડિયું';

  @override
  String get common_nextWeek => 'આગલું અઠવાડિયું';

  @override
  String get common_previousYear => 'પાછલું વર્ષ';

  @override
  String get common_nextYear => 'આગલું વર્ષ';

  @override
  String get common_today => 'આજે';

  @override
  String get common_yesterday => 'ગઈકાલે';

  @override
  String get common_periodTitle => 'સમયગાળો પસંદ કરો';

  @override
  String get common_periodDay => 'દિવસ';

  @override
  String get common_periodWeek => 'અઠવાડિયું';

  @override
  String get common_periodMonth => 'મહિનો';

  @override
  String get common_periodYear => 'વર્ષ';

  @override
  String get common_periodCustom => 'કસ્ટમ સમયગાળો';

  @override
  String get expense_typeExpense => 'ખર્ચ';

  @override
  String get expense_typeIncome => 'આવક';

  @override
  String get expense_typeTransfer => 'ટ્રાન્સફર';

  @override
  String get expense_payCash => 'રોકડ';

  @override
  String get expense_payUpi => 'UPI';

  @override
  String get expense_payCard => 'કાર્ડ';

  @override
  String get expense_payNetBanking => 'નેટ બેંકિંગ';

  @override
  String get expense_payOther => 'અન્ય';

  @override
  String get expense_accountTypeCash => 'રોકડ';

  @override
  String get expense_accountTypeBank => 'બેંક';

  @override
  String get expense_accountTypeUpi => 'UPI વૉલેટ';

  @override
  String get expense_accountTypeCard => 'કાર્ડ';

  @override
  String get expense_accountTypeWallet => 'વૉલેટ';

  @override
  String get expense_saved => 'સેવ થઈ ગયું';

  @override
  String get expense_deleted => 'વ્યવહાર કાઢી નાખ્યો';

  @override
  String get expense_loadError =>
      'તમારા વ્યવહારો લોડ થઈ શક્યા નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get expense_saveError =>
      'સેવ થઈ શક્યું નહીં. તમારા ફેરફારો અહીં જ છે. ફરી પ્રયાસ કરો.';

  @override
  String get expense_spentToday => 'આજનો ખર્ચ';

  @override
  String get expense_thisMonth => 'આ મહિને';

  @override
  String get expense_quickAdd => 'ખર્ચ ઉમેરો';

  @override
  String get expense_addTitle => 'વ્યવહાર ઉમેરો';

  @override
  String get expense_editTitle => 'વ્યવહાર બદલો';

  @override
  String get expense_saveExpense => 'ખર્ચ સેવ કરો';

  @override
  String get expense_saveIncome => 'આવક સેવ કરો';

  @override
  String get expense_saveTransfer => 'ટ્રાન્સફર સેવ કરો';

  @override
  String get expense_saveAndAddAnother => 'સેવ કરો અને બીજું ઉમેરો';

  @override
  String expense_fromAccount(String account) {
    return '$account માંથી';
  }

  @override
  String expense_toAccount(String account) {
    return '$account માં';
  }

  @override
  String get expense_chooseToAccount => 'ક્યાં મોકલવું છે તે પસંદ કરો';

  @override
  String get expense_account => 'ખાતું';

  @override
  String get expense_paymentMode => 'ચુકવણીની રીત';

  @override
  String get expense_category => 'શ્રેણી';

  @override
  String get expense_amount => 'રકમ';

  @override
  String get expense_pickDate => 'તારીખ પસંદ કરો';

  @override
  String get expense_pickTime => 'સમય પસંદ કરો';

  @override
  String get expense_noteLabel => 'નોંધ (વૈકલ્પિક)';

  @override
  String expense_noteLimit(int count) {
    return '$count/200';
  }

  @override
  String get expense_attachReceipt => 'રસીદ જોડો';

  @override
  String get expense_camera => 'કૅમેરા';

  @override
  String get expense_gallery => 'ગૅલેરી';

  @override
  String get expense_removeReceipt => 'રસીદ દૂર કરો';

  @override
  String get expense_receiptError => 'ફોટો જોડી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get expense_newCategory => 'નવી';

  @override
  String get expense_noCategories =>
      'હજી કોઈ શ્રેણી નથી. આગળ વધવા માટે એક ઉમેરો';

  @override
  String get expense_discardTitle => 'ફેરફારો રદ કરવા છે?';

  @override
  String get expense_discardBody =>
      'આ વ્યવહારમાં કરેલા તમારા ફેરફારો જતા રહેશે.';

  @override
  String get expense_discardConfirm => 'રદ કરો';

  @override
  String get expense_errAmountRequired => 'રકમ લખો';

  @override
  String expense_errAmountTooLarge(String max) {
    return 'રકમ વધુમાં વધુ $max હોઈ શકે';
  }

  @override
  String get expense_errAmountInvalid => 'ગણતરી તપાસો';

  @override
  String get expense_errCategoryRequired => 'શ્રેણી પસંદ કરો';

  @override
  String get expense_errToAccountRequired => 'પૈસા મોકલવા માટે ખાતું પસંદ કરો';

  @override
  String get expense_errSameAccount => 'બે અલગ ખાતાં પસંદ કરો';

  @override
  String get expense_errNoteTooLong => 'નોંધમાં વધુમાં વધુ 200 અક્ષર હોઈ શકે';

  @override
  String get expense_noLongerExists => 'આ વ્યવહાર હવે અસ્તિત્વમાં નથી';

  @override
  String get expense_deleteAction => 'વ્યવહાર કાઢી નાખો';

  @override
  String get expense_listTitle => 'ખર્ચ';

  @override
  String get expense_search => 'વ્યવહારો શોધો';

  @override
  String get expense_closeSearch => 'શોધ બંધ કરો';

  @override
  String get expense_filter => 'ફિલ્ટર';

  @override
  String get expense_menuCategories => 'શ્રેણીઓ';

  @override
  String get expense_menuAccounts => 'ખાતાં';

  @override
  String get expense_income => 'આવક';

  @override
  String get expense_expense => 'ખર્ચ';

  @override
  String get expense_net => 'ચોખ્ખું';

  @override
  String expense_emptyPeriod(String period) {
    return '$periodમાં કોઈ વ્યવહાર નથી';
  }

  @override
  String get expense_addExpense => 'ખર્ચ ઉમેરો';

  @override
  String get expense_noMatches => 'કંઈ મળ્યું નહીં';

  @override
  String get expense_clearFilters => 'ફિલ્ટર દૂર કરો';

  @override
  String get expense_duplicate => 'નકલ બનાવો';

  @override
  String get expense_delete => 'કાઢી નાખો';

  @override
  String expense_transferLabel(String from, String to) {
    return '$from → $to';
  }

  @override
  String get expense_detailTitle => 'વ્યવહાર';

  @override
  String get expense_edit => 'બદલો';

  @override
  String get expense_share => 'શેર કરો';

  @override
  String get expense_receipt => 'રસીદ';

  @override
  String get expense_receiptMissing => 'રસીદ ઉપલબ્ધ નથી';

  @override
  String get expense_close => 'બંધ કરો';

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
    return 'નોંધ: $note';
  }

  @override
  String get expense_filterTitle => 'વ્યવહારો ફિલ્ટર કરો';

  @override
  String get expense_filterType => 'પ્રકાર';

  @override
  String get expense_filterAmountMin => 'ઓછામાં ઓછી રકમ';

  @override
  String get expense_filterAmountMax => 'વધુમાં વધુ રકમ';

  @override
  String get expense_applyFilters => 'ફિલ્ટર લાગુ કરો';

  @override
  String expense_removeFilter(String name) {
    return 'ફિલ્ટર $name દૂર કરો';
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
    return 'રકમ: $amount';
  }

  @override
  String common_colorLabel(int index, int total) {
    return 'રંગ $index / $total';
  }

  @override
  String get common_iconPicker => 'આઇકન પસંદ કરો';

  @override
  String get common_colorPicker => 'રંગ પસંદ કરો';

  @override
  String get expense_categoriesTitle => 'શ્રેણીઓ';

  @override
  String get expense_newCategoryTitle => 'નવી શ્રેણી';

  @override
  String get expense_editCategoryTitle => 'શ્રેણી બદલો';

  @override
  String get expense_hiddenSection => 'છુપાવેલી';

  @override
  String get expense_hide => 'છુપાવો';

  @override
  String get expense_unhide => 'ફરી બતાવો';

  @override
  String get expense_rename => 'નામ બદલો';

  @override
  String get expense_deleteCategory => 'શ્રેણી કાઢી નાખો';

  @override
  String get expense_categoryDeleted => 'શ્રેણી કાઢી નાખી';

  @override
  String get expense_categoryHidden => 'શ્રેણી છુપાવી';

  @override
  String get expense_categoryShown => 'શ્રેણી ફરી દેખાય છે';

  @override
  String get expense_moveTitle => 'નવી શ્રેણી પસંદ કરો';

  @override
  String expense_moveBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count વ્યવહારો તમે પસંદ કરેલી શ્રેણીમાં જશે.',
      one: '1 વ્યવહાર તમે પસંદ કરેલી શ્રેણીમાં જશે.',
    );
    return '$_temp0';
  }

  @override
  String get expense_moveConfirm => 'ખસેડો અને કાઢી નાખો';

  @override
  String get expense_categoryName => 'નામ';

  @override
  String get expense_nameLimit => 'વધુમાં વધુ 30 અક્ષર';

  @override
  String get expense_errNameRequired => 'નામ લખો';

  @override
  String get expense_errNameTooLong => 'નામમાં વધુમાં વધુ 30 અક્ષર હોઈ શકે';

  @override
  String get expense_errNameDuplicate => 'આ નામની શ્રેણી પહેલેથી છે';

  @override
  String get expense_errNameReserved => 'બીજું નામ પસંદ કરો';

  @override
  String get expense_icon => 'આઇકન';

  @override
  String get expense_color => 'રંગ';

  @override
  String get expense_type => 'પ્રકાર';

  @override
  String get expense_saveCategory => 'શ્રેણી સેવ કરો';

  @override
  String expense_reorderHandle(String name) {
    return '$name ખેંચીને ક્રમ બદલો';
  }

  @override
  String get expense_reorderError =>
      'નવો ક્રમ સેવ થઈ શક્યો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get expense_noCategoriesHere => 'અહીં હજી કોઈ શ્રેણી નથી';

  @override
  String get expense_addCategory => 'શ્રેણી ઉમેરો';

  @override
  String get expense_loadDataError =>
      'આ સ્ક્રીન લોડ થઈ શકી નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get expense_accountsTitle => 'ખાતાં';

  @override
  String get expense_newAccountTitle => 'નવું ખાતું';

  @override
  String get expense_editAccountTitle => 'ખાતું બદલો';

  @override
  String get expense_totalBalance => 'કુલ બૅલેન્સ';

  @override
  String get expense_archivedSection => 'આર્કાઇવ કરેલાં';

  @override
  String get expense_archive => 'આર્કાઇવ કરો';

  @override
  String get expense_unarchive => 'પાછું લાવો';

  @override
  String get expense_accountArchived => 'ખાતું આર્કાઇવ કર્યું';

  @override
  String get expense_accountRestored => 'ખાતું પાછું લાવ્યા';

  @override
  String get expense_deleteAccount => 'ખાતું કાઢી નાખો';

  @override
  String get expense_accountDeleted => 'ખાતું કાઢી નાખ્યું';

  @override
  String get expense_lastAccountHelp => 'ઓછામાં ઓછું એક સક્રિય ખાતું જરૂરી છે';

  @override
  String get expense_accountHasTransactions =>
      'વ્યવહારોવાળાં ખાતાં કાઢી શકાતાં નથી, ફક્ત આર્કાઇવ કરી શકાય છે';

  @override
  String get expense_accountName => 'નામ';

  @override
  String get expense_accountType => 'પ્રકાર';

  @override
  String get expense_openingBalance => 'શરૂઆતનું બૅલેન્સ';

  @override
  String get expense_balancePositive => 'પૉઝિટિવ બૅલેન્સ';

  @override
  String get expense_balanceNegative => 'નેગેટિવ બૅલેન્સ, જેમ કે કાર્ડનું બાકી';

  @override
  String get expense_saveAccount => 'ખાતું સેવ કરો';

  @override
  String get expense_errAccountNameRequired => 'નામ લખો';

  @override
  String get expense_errAccountNameTooLong =>
      'નામમાં વધુમાં વધુ 40 અક્ષર હોઈ શકે';

  @override
  String expense_errBalanceRange(String min, String max) {
    return 'બૅલેન્સ $min અને $max ની વચ્ચે હોવું જોઈએ';
  }

  @override
  String get expense_addAccount => 'ખાતું ઉમેરો';

  @override
  String get expense_noAccounts => 'હજી કોઈ ખાતું નથી';

  @override
  String get expense_cardEmpty => 'તમારો પહેલો ખર્ચ ઉમેરો';

  @override
  String get common_iconGroup_food => 'ખોરાક';

  @override
  String get common_iconGroup_transport => 'પરિવહન';

  @override
  String get common_iconGroup_home => 'ઘર અને બિલ';

  @override
  String get common_iconGroup_shopping => 'ખરીદી';

  @override
  String get common_iconGroup_health => 'આરોગ્ય';

  @override
  String get common_iconGroup_education => 'શિક્ષણ';

  @override
  String get common_iconGroup_leisure => 'મનોરંજન';

  @override
  String get common_iconGroup_travel => 'મુસાફરી';

  @override
  String get common_iconGroup_money => 'પૈસા';

  @override
  String get common_iconGroup_other => 'અન્ય';

  @override
  String get icon_restaurant => 'રેસ્ટોરન્ટ';

  @override
  String get icon_local_grocery_store => 'કરિયાણું';

  @override
  String get icon_local_cafe => 'કૅફે';

  @override
  String get icon_fastfood => 'ફાસ્ટ ફૂડ';

  @override
  String get icon_bakery_dining => 'બેકરી';

  @override
  String get icon_local_bar => 'પીણાં';

  @override
  String get icon_icecream => 'આઇસક્રીમ';

  @override
  String get icon_lunch_dining => 'ભોજન';

  @override
  String get icon_directions_bus => 'બસ';

  @override
  String get icon_local_gas_station => 'ઇંધણ';

  @override
  String get icon_directions_car => 'કાર';

  @override
  String get icon_two_wheeler => 'ટુ-વ્હીલર';

  @override
  String get icon_local_taxi => 'ટેક્સી';

  @override
  String get icon_train => 'ટ્રેન';

  @override
  String get icon_electric_rickshaw => 'ઑટો રિક્ષા';

  @override
  String get icon_local_parking => 'પાર્કિંગ';

  @override
  String get icon_home => 'ઘર';

  @override
  String get icon_receipt => 'બિલ';

  @override
  String get icon_bolt => 'વીજળી';

  @override
  String get icon_water_drop => 'પાણી';

  @override
  String get icon_wifi => 'ઇન્ટરનેટ';

  @override
  String get icon_phone_android => 'મોબાઇલ';

  @override
  String get icon_build => 'સમારકામ';

  @override
  String get icon_cleaning_services => 'સફાઈ';

  @override
  String get icon_shopping_bag => 'ખરીદી';

  @override
  String get icon_shopping_cart => 'કાર્ટ';

  @override
  String get icon_checkroom => 'કપડાં';

  @override
  String get icon_devices => 'ઇલેક્ટ્રોનિક્સ';

  @override
  String get icon_chair => 'ફર્નિચર';

  @override
  String get icon_redeem => 'ભેટ';

  @override
  String get icon_local_florist => 'ફૂલ';

  @override
  String get icon_pets => 'પાળતુ પ્રાણી';

  @override
  String get icon_medical_services => 'તબીબી';

  @override
  String get icon_local_pharmacy => 'દવાની દુકાન';

  @override
  String get icon_fitness_center => 'ફિટનેસ';

  @override
  String get icon_spa => 'સ્વ-સંભાળ';

  @override
  String get icon_favorite => 'તંદુરસ્તી';

  @override
  String get icon_child_care => 'બાળ સંભાળ';

  @override
  String get icon_school => 'શાળા';

  @override
  String get icon_menu_book => 'પુસ્તકો';

  @override
  String get icon_computer => 'કમ્પ્યુટર';

  @override
  String get icon_science => 'વિજ્ઞાન';

  @override
  String get icon_edit => 'સ્ટેશનરી';

  @override
  String get icon_movie => 'ફિલ્મો';

  @override
  String get icon_sports_esports => 'ગેમ્સ';

  @override
  String get icon_music_note => 'સંગીત';

  @override
  String get icon_sports_cricket => 'ક્રિકેટ';

  @override
  String get icon_celebration => 'ઉજવણી';

  @override
  String get icon_theater_comedy => 'કાર્યક્રમ';

  @override
  String get icon_subscriptions => 'સબ્સ્ક્રિપ્શન';

  @override
  String get icon_flight => 'ફ્લાઇટ';

  @override
  String get icon_hotel => 'હોટેલ';

  @override
  String get icon_luggage => 'સામાન';

  @override
  String get icon_beach_access => 'રજા';

  @override
  String get icon_map => 'પ્રવાસ';

  @override
  String get icon_payments => 'પગાર';

  @override
  String get icon_storefront => 'વ્યવસાય';

  @override
  String get icon_savings => 'બચત';

  @override
  String get icon_attach_money => 'પૈસા';

  @override
  String get icon_account_balance => 'બેંક';

  @override
  String get icon_credit_card => 'ક્રેડિટ કાર્ડ';

  @override
  String get icon_wallet => 'વૉલેટ';

  @override
  String get icon_currency_rupee => 'રૂપિયો';

  @override
  String get icon_trending_up => 'રોકાણ';

  @override
  String get icon_request_quote => 'કર';

  @override
  String get icon_volunteer_activism => 'દાન';

  @override
  String get icon_work => 'કામ';

  @override
  String get icon_category => 'શ્રેણી';

  @override
  String get icon_star => 'તારો';

  @override
  String get icon_label => 'લેબલ';

  @override
  String get icon_more_horiz => 'અન્ય';

  @override
  String get expense_menuBudgets => 'બજેટ';

  @override
  String get expense_budgetsTitle => 'બજેટ';

  @override
  String get expense_budgetOverall => 'કુલ';

  @override
  String get expense_budgetCategoryBudgets => 'શ્રેણી બજેટ';

  @override
  String get expense_budgetWithoutBudget => 'બજેટ વગરની શ્રેણીઓ';

  @override
  String get expense_budgetSet => 'બજેટ નક્કી કરો';

  @override
  String get expense_budgetSetMonthly => 'માસિક બજેટ નક્કી કરો';

  @override
  String get expense_budgetCopyLastMonth => 'ગયા મહિનાના બજેટ કૉપિ કરો';

  @override
  String expense_budgetCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count બજેટ કૉપિ થયાં',
      one: '1 બજેટ કૉપિ થયું',
      zero: 'કૉપિ કરવા માટે કંઈ નથી',
    );
    return '$_temp0';
  }

  @override
  String expense_budgetPerDayLeft(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days દિવસ માટે રોજના $amount બાકી',
      one: '1 દિવસ માટે રોજના $amount બાકી',
    );
    return '$_temp0';
  }

  @override
  String get expense_budgetNoneLeft => 'આ મહિને કોઈ બજેટ બાકી નથી';

  @override
  String expense_budgetUnderBy(String amount) {
    return 'બજેટ કરતાં $amount ઓછો ખર્ચ';
  }

  @override
  String expense_budgetOverBy(String amount) {
    return 'બજેટ કરતાં $amount વધુ ખર્ચ';
  }

  @override
  String expense_budgetFuturePerDay(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days દિવસ માટે રોજના $amount',
      one: '1 દિવસ માટે રોજના $amount',
    );
    return '$_temp0';
  }

  @override
  String expense_budgetLeft(String amount) {
    return '$amount બાકી';
  }

  @override
  String expense_budgetSpentOfLimit(String spent, String limit) {
    return '$limit માંથી $spent';
  }

  @override
  String get expense_budgetLevelUnder => 'યોગ્ય માર્ગે';

  @override
  String get expense_budgetLevelWarning => 'લગભગ વપરાઈ ગયું';

  @override
  String get expense_budgetLevelOver => 'બજેટ કરતાં વધુ';

  @override
  String expense_budgetLevelLine(String level, int percent) {
    return '$level · $percent% વપરાયું';
  }

  @override
  String get expense_budgetEmptyTitle => 'તમારા મહિનાનું આયોજન કરો';

  @override
  String get expense_budgetEmptyBody =>
      'માસિક બજેટ નક્કી કરો અને જુઓ કે તમે દરરોજ હજુ કેટલો ખર્ચ કરી શકો છો.';

  @override
  String get expense_budgetRepeatMonthly => 'દર મહિને પુનરાવર્તન કરો';

  @override
  String get expense_budgetDelete => 'બજેટ કાઢી નાખો';

  @override
  String get expense_budgetDeleted => 'બજેટ કાઢી નાખ્યું';

  @override
  String get expense_budgetRestoreFailed =>
      'બજેટ પાછું લાવી શકાયું નહીં કારણ કે એક બજેટ પહેલેથી નક્કી છે.';

  @override
  String get expense_budgetSlotTaken => 'આ શ્રેણીનું આ મહિને પહેલેથી બજેટ છે.';

  @override
  String get expense_budgetHidden => 'છુપાયેલી';

  @override
  String get expense_budgetAmountMissing => 'રકમ દાખલ કરો';

  @override
  String get expense_budgetAmountTooLarge => 'રકમ ઘણી મોટી છે';

  @override
  String get expense_budgetSetOverallPrompt => 'કુલ બજેટ નક્કી કરો';

  @override
  String get notif_channelBudgetAlerts => 'બજેટ અલર્ટ';

  @override
  String get notif_channelBudgetAlertsDescription =>
      'જ્યારે કોઈ બજેટ 80% અથવા 100% સુધી પહોંચે';

  @override
  String notif_budget80Title(String category, int percent) {
    return '$category બજેટ $percent% પર';
  }

  @override
  String notif_budget80Body(String category, int percent) {
    return 'તમે આ મહિને તમારા $category બજેટનો $percent% ઉપયોગ કરી લીધો છે.';
  }

  @override
  String notif_budget100Title(String category) {
    return '$category બજેટ પૂરું થઈ ગયું';
  }

  @override
  String notif_budget100Body(String category, int percent) {
    return 'તમે આ મહિને તમારા $category બજેટનો $percent% ઉપયોગ કરી લીધો છે.';
  }

  @override
  String get notif_overallBudget => 'કુલ';

  @override
  String get expense_menuRecurring => 'આવર્તી';

  @override
  String get expense_repeat => 'પુનરાવર્તન';

  @override
  String get expense_freqDaily => 'દરરોજ';

  @override
  String get expense_freqWeekly => 'દર અઠવાડિયે';

  @override
  String get expense_freqMonthly => 'દર મહિને';

  @override
  String get expense_freqYearly => 'દર વર્ષે';

  @override
  String get expense_repeatEndDate => 'અંતિમ તારીખ (વૈકલ્પિક)';

  @override
  String expense_repeatEndsOn(String date) {
    return '$dateએ પૂરું';
  }

  @override
  String get expense_repeatClearEnd => 'અંતિમ તારીખ દૂર કરો';

  @override
  String get expense_repeatEndBeforeStart =>
      'અંતિમ તારીખ પહેલી તારીખ પહેલાંની ન હોઈ શકે';

  @override
  String get expense_everyDay => 'દરરોજ';

  @override
  String expense_everyWeekOn(String weekday) {
    return 'દર અઠવાડિયે $weekdayએ';
  }

  @override
  String expense_everyMonthOn(int day, String suffix) {
    return 'દર મહિનાની $day તારીખે';
  }

  @override
  String expense_everyYearOn(String date) {
    return 'દર વર્ષે $dateએ';
  }

  @override
  String get expense_recurringTitle => 'આવર્તી વ્યવહારો';

  @override
  String get expense_recurringPaused => 'થોભાવેલ';

  @override
  String expense_recurringNext(String date) {
    return 'આગળ: $date';
  }

  @override
  String expense_recurringEnded(String date) {
    return '$dateએ પૂરું થયું';
  }

  @override
  String get expense_recurringPause => 'થોભાવો';

  @override
  String get expense_recurringResume => 'ફરી શરૂ કરો';

  @override
  String get expense_recurringDelete => 'કાઢી નાખો';

  @override
  String get expense_recurringDeleted => 'આવર્તી વ્યવહાર કાઢી નાખ્યો';

  @override
  String get expense_recurringAdd => 'આવર્તી વ્યવહાર ઉમેરો';

  @override
  String get expense_recurringEmptyTitle => 'હજી કંઈ પુનરાવર્તિત થતું નથી';

  @override
  String get expense_recurringEmptyBody =>
      'ભાડું, પગાર અથવા બિલ એક વાર ઉમેરો, પછી તે આપમેળે નોંધાશે.';

  @override
  String get expense_recurringStaleAccount => 'ખાતું આર્કાઇવ કરેલું છે';

  @override
  String get expense_recurringStaleCategory => 'શ્રેણી છુપાયેલી છે';

  @override
  String get expense_ruleEditTitle => 'આવર્તી વ્યવહાર બદલો';

  @override
  String get expense_nextDate => 'આગલી તારીખ';

  @override
  String get expense_createdFromRule => 'આવર્તી નિયમથી બનાવેલ';

  @override
  String get expense_ruleDeleted => 'આવર્તી નિયમ કાઢી નાખ્યો';

  @override
  String get expense_recurringLabel => 'આવર્તી';

  @override
  String get expense_menuReports => 'રિપોર્ટ';

  @override
  String get premium_advancedReportsMessage => 'એડવાન્સ રિપોર્ટ Pro નો ભાગ છે.';

  @override
  String get premium_lockedPeriod => 'લૉક છે';

  @override
  String get more_developerSection => 'ડેવલપર';

  @override
  String get more_debugUnlockAll => 'બધી સુવિધાઓ અનલૉક કરો (ડીબગ)';

  @override
  String get expense_reportsTitle => 'રિપોર્ટ';

  @override
  String get expense_reportTabOverview => 'સારાંશ';

  @override
  String get expense_reportTabCategories => 'શ્રેણીઓ';

  @override
  String get expense_reportTabTrends => 'વલણો';

  @override
  String get expense_reportTabAccounts => 'ખાતાં';

  @override
  String expense_reportLockedTab(String tab) {
    return '$tab, લૉક છે';
  }

  @override
  String get expense_reportNetSavings => 'ચોખ્ખી બચત';

  @override
  String get expense_reportSavingsRate => 'બચત દર';

  @override
  String expense_reportSavingsRateValue(int percent) {
    return '$percent%';
  }

  @override
  String get expense_reportNoValue => '—';

  @override
  String get expense_reportAvgDaily => 'સરેરાશ દૈનિક ખર્ચ';

  @override
  String get expense_reportTopCategories => 'ટોચની શ્રેણીઓ';

  @override
  String get expense_reportIncomeVsExpense => 'આવક વિરુદ્ધ ખર્ચ';

  @override
  String expense_reportShare(int percent) {
    return 'ખર્ચનો $percent%';
  }

  @override
  String get expense_reportOther => 'અન્ય';

  @override
  String get expense_reportTotalSpent => 'કુલ ખર્ચ';

  @override
  String expense_reportChartSummaryDonut(String items) {
    return 'શ્રેણી મુજબ ખર્ચ: $items';
  }

  @override
  String expense_reportChartSummaryItem(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String expense_reportChartSummaryBar(String income, String expense) {
    return 'આવક $income, ખર્ચ $expense';
  }

  @override
  String expense_reportEmpty(String period) {
    return '$periodમાં કોઈ વ્યવહાર નથી';
  }

  @override
  String get expense_reportThisPeriod => 'આ સમયગાળો';

  @override
  String get expense_reportPreviousPeriod => 'પાછલો સમયગાળો';

  @override
  String get expense_reportByAccount => 'ખાતા મુજબ';

  @override
  String get expense_reportByPaymentMode => 'ચુકવણીની રીત મુજબ';

  @override
  String expense_reportChartSummaryTrend(String current, String previous) {
    return 'આ સમયગાળાનો ખર્ચ $current, પાછલો સમયગાળો $previous';
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
  String get notif_channelHabitReminders => 'આદત રિમાઇન્ડર';

  @override
  String get notif_channelHabitRemindersDescription =>
      'તમારી આદતો માટે રિમાઇન્ડર';

  @override
  String get habit_title => 'આદતો';

  @override
  String get habit_quickAddCheckIn => 'આદત ચેક-ઇન કરો';

  @override
  String habit_streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ',
      one: '1 દિવસ',
    );
    return '$_temp0';
  }

  @override
  String habit_streakWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count અઠવાડિયાં',
      one: '1 અઠવાડિયું',
    );
    return '$_temp0';
  }

  @override
  String habit_doneOfTotal(int done, int total) {
    return '$total માંથી $done પૂર્ણ';
  }

  @override
  String get habit_undo => 'પૂર્વવત્ કરો';

  @override
  String get habit_loadError => 'તમારી આદતો લોડ થઈ શકી નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get habit_saveError => 'સાચવી શકાયું નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get habit_menuArchived => 'આર્કાઇવ કરેલી આદતો';

  @override
  String get habit_menuReorder => 'ક્રમ બદલો';

  @override
  String get habit_reorderDone => 'થઈ ગયું';

  @override
  String habit_reorderHandle(String name) {
    return '$name નો ક્રમ બદલો';
  }

  @override
  String get habit_moreOptions => 'વધુ વિકલ્પો';

  @override
  String get habit_addHabit => 'આદત ઉમેરો';

  @override
  String get habit_emptyTitle => 'તમારી પહેલી આદત બનાવો';

  @override
  String get habit_emptyBody =>
      'કોઈ ટેમ્પલેટથી શરૂ કરો અથવા તમારી પોતાની આદત બનાવવા + દબાવો.';

  @override
  String get habit_notScheduledToday => 'આજે નિર્ધારિત નથી';

  @override
  String get habit_notScheduledOnDay => 'આ દિવસે નિર્ધારિત નથી';

  @override
  String get habit_allDone => 'આજનું બધું પૂર્ણ';

  @override
  String get habit_noneScheduled => 'આ દિવસે કંઈ નિર્ધારિત નથી';

  @override
  String get habit_menuEdit => 'ફેરફાર કરો';

  @override
  String get habit_menuAddNote => 'આજ માટે નોંધ ઉમેરો';

  @override
  String get habit_menuAddNoteDay => 'આ દિવસ માટે નોંધ ઉમેરો';

  @override
  String get habit_menuSkipToday => 'આજે છોડો';

  @override
  String habit_skipTodayHint(int count) {
    return 'તમારા $count ફ્રીઝમાંથી 1 વપરાશે';
  }

  @override
  String get habit_noFreezesLeft => 'કોઈ ફ્રીઝ બાકી નથી';

  @override
  String get habit_menuArchive => 'આર્કાઇવ કરો';

  @override
  String get habit_archived => 'આદત આર્કાઇવ થઈ';

  @override
  String get habit_unchecked => 'ચેક-ઇન દૂર કર્યું';

  @override
  String get habit_skipped => 'ફ્રીઝથી આજે છોડ્યું';

  @override
  String get habit_olderEditsHint => 'જૂના દિવસો આદતના પેજ પરથી બદલો';

  @override
  String get habit_futureDayHint => 'આવનારા દિવસોમાં હજી ચેક-ઇન થઈ શકે નહીં';

  @override
  String habit_dayRingLabel(String day, int done, int total) {
    return '$day, $total માંથી $done પૂર્ણ';
  }

  @override
  String habit_dayRingNone(String day) {
    return '$day, કંઈ નિર્ધારિત નથી';
  }

  @override
  String habit_valueEntryTitle(String name) {
    return '$name માટે મૂલ્ય લખો';
  }

  @override
  String get habit_valueEntryHint => '0 થી 9,999 સુધીની પૂર્ણ સંખ્યા';

  @override
  String get habit_valueEntryError => '0 થી 9,999 સુધીની પૂર્ણ સંખ્યા લખો';

  @override
  String get habit_set => 'સેટ કરો';

  @override
  String habit_markDoneLabel(String name) {
    return '$name પૂર્ણ કરો';
  }

  @override
  String habit_markNotDoneLabel(String name) {
    return '$name અધૂરું કરો';
  }

  @override
  String habit_addOneLabel(String name) {
    return '$name માં 1 ઉમેરો';
  }

  @override
  String habit_countLabel(String name, int value, int target, String unit) {
    return '$name, $target $unit માંથી $value';
  }

  @override
  String habit_countLabelNoUnit(String name, int value, int target) {
    return '$name, $target માંથી $value';
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
    return 'હાલની સળંગતા: $streak';
  }

  @override
  String get habit_statusDone => 'પૂર્ણ';

  @override
  String get habit_statusFreeze => 'ફ્રીઝ દિવસ';

  @override
  String get habit_scheduleDaily => 'દરરોજ';

  @override
  String habit_scheduleTimesPerWeek(int times, int left) {
    return 'અઠવાડિયામાં $times× · $left બાકી';
  }

  @override
  String habit_scheduleTimesPerWeekMet(int times) {
    return 'અઠવાડિયામાં $times× · પૂર્ણ';
  }

  @override
  String get habit_noteTitle => 'નોંધ';

  @override
  String get habit_noteHint => 'નોંધ ઉમેરો';

  @override
  String get habit_noteSave => 'નોંધ સાચવો';

  @override
  String get habit_noteSaved => 'નોંધ સચવાઈ';

  @override
  String get habit_detailTitle => 'આદત';

  @override
  String get habit_template_drinkWater => 'પાણી પીઓ';

  @override
  String get habit_template_read => 'વાંચો';

  @override
  String get habit_template_walk => 'ચાલો';

  @override
  String get habit_template_meditate => 'ધ્યાન કરો';

  @override
  String get habit_template_wakeUpEarly => 'વહેલા ઊઠો';

  @override
  String get habit_template_study => 'અભ્યાસ કરો';

  @override
  String get habit_unit_glasses => 'ગ્લાસ';

  @override
  String get habit_unit_pages => 'પાનાં';

  @override
  String get habit_unit_minutes => 'મિનિટ';

  @override
  String get habit_addTitle => 'નવી આદત';

  @override
  String get habit_editTitle => 'આદત બદલો';

  @override
  String get habit_nameLabel => 'નામ';

  @override
  String get habit_nameSuggestions => 'સૂચનો';

  @override
  String get habit_iconLabel => 'આઇકન';

  @override
  String get habit_colorLabel => 'રંગ';

  @override
  String get habit_goalLabel => 'લક્ષ્યનો પ્રકાર';

  @override
  String get habit_goalYesNo => 'હા / ના';

  @override
  String get habit_goalCount => 'ગણતરી';

  @override
  String get habit_goalLocked => 'આદત બન્યા પછી લક્ષ્યનો પ્રકાર બદલી શકાતો નથી';

  @override
  String get habit_targetLabel => 'લક્ષ્ય';

  @override
  String get habit_unitLabel => 'એકમ (વૈકલ્પિક)';

  @override
  String get habit_scheduleLabel => 'સમયપત્રક';

  @override
  String get habit_scheduleEveryDay => 'દરરોજ';

  @override
  String get habit_scheduleSpecificDays => 'પસંદ કરેલા દિવસો';

  @override
  String get habit_scheduleXTimes => 'અઠવાડિયામાં X વાર';

  @override
  String habit_timesPerWeekValue(int count) {
    return 'અઠવાડિયામાં $count×';
  }

  @override
  String get habit_decrease => 'ઘટાડો';

  @override
  String get habit_increase => 'વધારો';

  @override
  String get habit_startDate => 'શરૂઆતની તારીખ';

  @override
  String get habit_pickDate => 'તારીખ પસંદ કરો';

  @override
  String get habit_save => 'આદત સાચવો';

  @override
  String get habit_saved => 'આદત સચવાઈ';

  @override
  String get habit_errNameRequired => 'નામ લખો';

  @override
  String get habit_errNameTooLong => 'વધુમાં વધુ 40 અક્ષર લખો';

  @override
  String get habit_errTargetRange => '1 થી 9,999 સુધીનું લક્ષ્ય લખો';

  @override
  String get habit_errUnitTooLong => 'વધુમાં વધુ 20 અક્ષર લખો';

  @override
  String get habit_errWeekdayRequired => 'ઓછામાં ઓછો એક દિવસ પસંદ કરો';

  @override
  String get habit_errTimesRange => 'અઠવાડિયામાં 1 થી 6 વાર પસંદ કરો';

  @override
  String get habit_deleteAction => 'કાઢી નાખો';

  @override
  String get habit_deleteTitle => 'આદત કાઢી નાખીએ?';

  @override
  String habit_deleteBody(String name) {
    return 'આથી $name અને તેનો બધો ઇતિહાસ દૂર થશે.';
  }

  @override
  String get habit_deleteConfirm => 'આદત કાઢી નાખો';

  @override
  String get habit_deleted => 'આદત કાઢી નાખી';

  @override
  String get habit_discardTitle => 'ફેરફારો રદ કરીએ?';

  @override
  String get habit_discardBody => 'આ આદતમાં કરેલા ફેરફારો ખોવાઈ જશે.';

  @override
  String get habit_discardConfirm => 'રદ કરો';

  @override
  String get habit_notFound => 'આ આદત હવે અસ્તિત્વમાં નથી';

  @override
  String get habit_reminders => 'રિમાઇન્ડર';

  @override
  String get habit_addReminder => 'રિમાઇન્ડર ઉમેરો';

  @override
  String habit_removeReminder(String time) {
    return '$time નું રિમાઇન્ડર દૂર કરો';
  }

  @override
  String get habit_remindOnlyIfNotDone => 'કામ બાકી હોય ત્યારે જ યાદ અપાવો';

  @override
  String get habit_reminderLimit => 'તમે વધુમાં વધુ 3 રિમાઇન્ડર ઉમેરી શકો છો';

  @override
  String get habit_reminderDuplicate => 'આ સમય પહેલેથી ઉમેરેલો છે';

  @override
  String get habit_notificationsOffHint => 'રિમાઇન્ડર માટે સૂચનાની મંજૂરી જોઈએ';

  @override
  String get habit_inexactHint => 'રિમાઇન્ડર થોડી મિનિટ મોડા આવી શકે છે';

  @override
  String notif_habitReminderTitle(String name) {
    return '$name';
  }

  @override
  String notif_habitReminderBody(String name) {
    return '$name નો સમય થયો. તમે કરી શકો છો.';
  }

  @override
  String habit_milestoneTitleDays(int count) {
    return '$count દિવસની સળંગતા!';
  }

  @override
  String habit_milestoneTitleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count અઠવાડિયાંની સળંગતા!',
      one: '1 અઠવાડિયાની સળંગતા!',
    );
    return '$_temp0';
  }

  @override
  String get habit_milestoneBody =>
      'દરેક ચેક-ઇન મહત્ત્વનું છે. આમ જ ચાલુ રાખો!';

  @override
  String get habit_shareStreak => 'સળંગતા શેર કરો';

  @override
  String get habit_close => 'બંધ કરો';

  @override
  String get habit_shareCardFooter => 'DailyTrack સાથે ટ્રૅક કર્યું';

  @override
  String get habit_shareError => 'શેર થઈ શક્યું નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get common_iconGroup_habits => 'આદતો';

  @override
  String get icon_directions_walk => 'ચાલવું';

  @override
  String get icon_directions_run => 'દોડવું';

  @override
  String get icon_self_improvement => 'ધ્યાન';

  @override
  String get icon_alarm => 'અલાર્મ';

  @override
  String get icon_bedtime => 'ઊંઘ';

  @override
  String get habit_statCurrent => 'હાલની સળંગતા';

  @override
  String get habit_statBest => 'શ્રેષ્ઠ સળંગતા';

  @override
  String get habit_statRate => 'પૂર્ણતા દર (છેલ્લા 30 દિવસ)';

  @override
  String get habit_statTotal => 'કુલ પૂર્ણ';

  @override
  String habit_rateValue(int percent) {
    return '$percent%';
  }

  @override
  String get habit_rateNone => '—';

  @override
  String get habit_calendarTitle => 'કૅલેન્ડર';

  @override
  String habit_dayDone(String date) {
    return '$date, પૂર્ણ';
  }

  @override
  String habit_dayPartial(String date, int value, int target) {
    return '$date, $target માંથી $value';
  }

  @override
  String habit_dayMissed(String date) {
    return '$date, ચૂકી ગયા';
  }

  @override
  String habit_dayFreeze(String date) {
    return '$date, ફ્રીઝ દિવસ';
  }

  @override
  String habit_dayOther(String date) {
    return '$date';
  }

  @override
  String get habit_dayHasNote => 'નોંધ છે';

  @override
  String get habit_heatmapTitle => 'છેલ્લા 12 મહિના';

  @override
  String habit_heatmapSummary(int done, int total) {
    return 'છેલ્લા 12 મહિનામાં $total માંથી $done દિવસ પૂર્ણ';
  }

  @override
  String habit_heatmapMonth(String month, int done, int total) {
    return '$month: $total માંથી $done દિવસ પૂર્ણ';
  }

  @override
  String get habit_shareHeatmap => 'શેર કરો';

  @override
  String get habit_weeklyChartTitle => 'દર અઠવાડિયે પૂર્ણ';

  @override
  String habit_weeklyChartSummary(String items) {
    return 'છેલ્લા 12 અઠવાડિયામાં પૂર્ણ: $items';
  }

  @override
  String habit_weeklyChartItem(String date, int count) {
    return '$date નું અઠવાડિયું $count';
  }

  @override
  String get habit_notesTitle => 'નોંધો';

  @override
  String get habit_notesEmpty => 'હજી કોઈ નોંધ નથી';

  @override
  String get habit_freezeTitle => 'સળંગતા ફ્રીઝ';

  @override
  String habit_freezesAvailable(int count) {
    return 'ઉપલબ્ધ ફ્રીઝ: $count';
  }

  @override
  String get habit_freezeExplain =>
      'ફ્રીઝ કોઈ દિવસ ચૂકી જાઓ ત્યારે સળંગતા જાળવે છે. 3 દિવસ પહેલાં સુધીના ચૂકેલા દિવસે વાપરો.';

  @override
  String get habit_useFreeze => 'ફ્રીઝ વાપરો';

  @override
  String habit_useFreezeOn(String date) {
    return '$date પર ફ્રીઝ વાપરો';
  }

  @override
  String get habit_noFreezeableDay => 'છેલ્લા 3 દિવસમાં કોઈ દિવસ ચૂક્યા નથી';

  @override
  String get habit_freezeUsed => 'ફ્રીઝ વપરાયો';

  @override
  String get habit_addFreezeDebug => 'ફ્રીઝ ઉમેરો (ડીબગ)';

  @override
  String get habit_freezeCapReached => 'તમે વધુમાં વધુ 2 ફ્રીઝ રાખી શકો છો';

  @override
  String habit_editDayTitle(String date) {
    return '$date બદલો';
  }

  @override
  String get habit_dayDoneToggle => 'પૂર્ણ';

  @override
  String get habit_dayValueLabel => 'મૂલ્ય';

  @override
  String get habit_daySave => 'સાચવો';

  @override
  String get habit_daySaved => 'દિવસ સચવાયો';

  @override
  String get habit_edit => 'ફેરફાર કરો';

  @override
  String get habit_previousMonth => 'પાછલો મહિનો';

  @override
  String get habit_nextMonth => 'આગલો મહિનો';

  @override
  String get habit_archivedTitle => 'આર્કાઇવ કરેલી આદતો';

  @override
  String habit_archivedOn(String date) {
    return '$date એ આર્કાઇવ';
  }

  @override
  String habit_bestStreakLabel(String streak) {
    return 'શ્રેષ્ઠ સળંગતા: $streak';
  }

  @override
  String get habit_restore => 'પાછી લાવો';

  @override
  String get habit_restored => 'આદત પાછી આવી';

  @override
  String get habit_deletePermanently => 'કાયમ માટે કાઢી નાખો';

  @override
  String get habit_archivedEmpty => 'આર્કાઇવ કરેલી આદતો અહીં દેખાશે';

  @override
  String habit_doneTodayRing(int done, int total) {
    return 'આજે $total માંથી $done પૂર્ણ';
  }

  @override
  String get habit_cardEmpty => 'તમારી પહેલી આદત બનાવો';

  @override
  String get habit_cardNoneToday => 'આજે કંઈ નિર્ધારિત નથી';

  @override
  String get habit_addOne => '+1';

  @override
  String get habit_customValue => 'મૂલ્ય લખો';

  @override
  String get habit_loadDataError => 'આદતો લોડ થઈ શકી નહીં';

  @override
  String get home_greetingMorning => 'સુપ્રભાત';

  @override
  String get home_greetingAfternoon => 'શુભ બપોર';

  @override
  String get home_greetingEvening => 'શુભ સાંજ';

  @override
  String get home_quickAddTooltip => 'ઝડપથી ઉમેરો';

  @override
  String get home_insightTitle => 'આજની સલાહ';

  @override
  String get home_insightStarter => 'આજે કંઈક નોંધો, સલાહ અહીં દેખાશે';

  @override
  String get home_comingSoonTitle => 'ટૂંક સમયમાં';

  @override
  String home_comingSoonBody(String names) {
    return '$names ટ્રૅકર ટૂંક સમયમાં આવી રહ્યા છે';
  }

  @override
  String home_listPair(String first, String second) {
    return '$first અને $second';
  }

  @override
  String get home_comingSoonDismiss => 'દૂર કરો';

  @override
  String get home_comingSoonDismissed => 'કાર્ડ છુપાવ્યું';

  @override
  String get home_recentTitle => 'તાજેતરના વ્યવહારો';

  @override
  String get home_seeAll => 'બધા જુઓ';

  @override
  String get expense_quickAddIncome => 'આવક ઉમેરો';

  @override
  String get expense_cardAdd => 'ખર્ચ';

  @override
  String get expense_cardSetBudget => 'બજેટ સેટ કરો';

  @override
  String expense_cardMonthOfBudget(String spent, String limit) {
    return '$limit માંથી $spent';
  }

  @override
  String expense_insightCategoryHigher(String category, int percent) {
    return '$category પર ખર્ચ ગયા મહિના કરતાં $percent% વધુ છે';
  }

  @override
  String expense_insightCategoryLower(String category, int percent) {
    return '$category પર ખર્ચ ગયા મહિના કરતાં $percent% ઓછો છે. સરસ કામ.';
  }

  @override
  String expense_insightBudgetOnTrack(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days દિવસ માટે $amount બાકી',
      one: '1 દિવસ માટે $amount બાકી',
    );
    return 'તમે યોગ્ય માર્ગે છો: $_temp0';
  }

  @override
  String expense_insightBudgetNear(int percent) {
    return 'તમે આ મહિનાના બજેટનો $percent% ઉપયોગ કરી લીધો છે';
  }

  @override
  String expense_insightBudgetOver(String amount) {
    return 'તમે આ મહિનાના બજેટ કરતાં $amount વધુ છો. ખર્ચ વગરનો એક દિવસ મદદ કરશે.';
  }

  @override
  String expense_insightOpensReports(String text) {
    return 'રિપોર્ટ ખૂલશે: $text';
  }

  @override
  String expense_insightOpensBudgets(String text) {
    return 'બજેટ ખૂલશે: $text';
  }

  @override
  String habit_insightNextMilestoneDays(int count, int milestone, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ',
      one: '1 દિવસ',
    );
    return '$name સાથે $milestone દિવસની સળંગતાથી તમે $_temp0 દૂર છો';
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
      other: '$count અઠવાડિયાં',
      one: '1 અઠવાડિયું',
    );
    return '$name સાથે $milestone અઠવાડિયાની સળંગતાથી તમે $_temp0 દૂર છો';
  }

  @override
  String habit_insightBestThisWeek(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count વાર',
      one: '1 વાર',
    );
    return 'આ અઠવાડિયે તમે $name $_temp0 કર્યું';
  }

  @override
  String habit_insightComebackDays(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best દિવસ',
      one: '1 દિવસ',
    );
    return 'આજે ફરીથી $name શરૂ કરો. તમારી શ્રેષ્ઠ સળંગતા $_temp0 છે.';
  }

  @override
  String habit_insightComebackWeeks(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best અઠવાડિયાં',
      one: '1 અઠવાડિયું',
    );
    return 'આજે ફરીથી $name શરૂ કરો. તમારી શ્રેષ્ઠ સળંગતા $_temp0 છે.';
  }

  @override
  String habit_insightOpensHabit(String text, String name) {
    return '$name ખૂલશે: $text';
  }

  @override
  String habit_streakBadgeLabelDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ',
      one: '1 દિવસ',
    );
    return 'શ્રેષ્ઠ ચાલુ સળંગતા: $_temp0';
  }

  @override
  String habit_streakBadgeLabelWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count અઠવાડિયાં',
      one: '1 અઠવાડિયું',
    );
    return 'શ્રેષ્ઠ ચાલુ સળંગતા: $_temp0';
  }

  @override
  String habit_streakBadgeWeeksShort(int count) {
    return '$count અઠ.';
  }

  @override
  String habit_uncheckedSnack(String name) {
    return '$name પરથી નિશાન હટાવ્યું';
  }

  @override
  String get modules_moveUp => 'ઉપર ખસેડો';

  @override
  String get modules_moveDown => 'નીચે ખસેડો';

  @override
  String get settings_general => 'સામાન્ય';

  @override
  String get settings_appearance => 'દેખાવ';

  @override
  String get settings_modules => 'મોડ્યુલ';

  @override
  String get settings_notifications => 'સૂચનાઓ';

  @override
  String get settings_privacy => 'ગોપનીયતા';

  @override
  String get settings_about => 'એપ વિશે';

  @override
  String get settings_loadError => 'તમારી સેટિંગ્સ લોડ થઈ શકી નહીં.';

  @override
  String get settings_language => 'ભાષા';

  @override
  String get settings_languageSystem => 'સિસ્ટમ ડિફૉલ્ટ';

  @override
  String get settings_currency => 'ચલણ';

  @override
  String get settings_firstDayOfWeek => 'અઠવાડિયાનો પહેલો દિવસ';

  @override
  String get settings_monday => 'સોમવાર';

  @override
  String get settings_saturday => 'શનિવાર';

  @override
  String get settings_sunday => 'રવિવાર';

  @override
  String get settings_dateFormat => 'તારીખનું ફોર્મેટ';

  @override
  String get settings_themeEntry => 'થીમ અને રંગો';

  @override
  String get settings_modulesEntry => 'ટ્રૅકર ચાલુ કરો અથવા ક્રમ બદલો';

  @override
  String get settings_notificationsMaster => 'સૂચનાઓ';

  @override
  String get settings_dailySummaryTime => 'દૈનિક સારાંશનો સમય';

  @override
  String get settings_dailySummaryHelp => 'શું તમે આજના ખર્ચ નોંધ્યા?';

  @override
  String get settings_budgetAlerts => 'બજેટ એલર્ટ';

  @override
  String get settings_habitReminders => 'આદત રિમાઇન્ડર';

  @override
  String get settings_notificationsBlocked => 'DailyTrack માટે સૂચનાઓ બંધ છે';

  @override
  String get settings_openSystemSettings => 'સેટિંગ્સ ખોલો';

  @override
  String get settings_privacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get settings_terms => 'શરતો';

  @override
  String get settings_rateUs => 'અમને રેટિંગ આપો';

  @override
  String get settings_shareApp => 'એપ શેર કરો';

  @override
  String settings_shareAppText(String url) {
    return 'હું DailyTrack વડે મારા પૈસા અને આદતો ટ્રૅક કરું છું: $url';
  }

  @override
  String get settings_sendFeedback => 'પ્રતિસાદ મોકલો';

  @override
  String settings_feedbackSubject(String version) {
    return 'DailyTrack પ્રતિસાદ ($version)';
  }

  @override
  String settings_feedbackBody(
    String version,
    String build,
    String device,
    String android,
    String language,
  ) {
    return 'તમારો પ્રતિસાદ આ લાઇનની ઉપર લખો.\n\nએપ વર્ઝન: $version ($build)\nડિવાઇસ: $device\nAndroid: $android\nડિવાઇસની ભાષા: $language';
  }

  @override
  String settings_noEmailApp(String email) {
    return 'કોઈ ઇમેઇલ એપ મળી નહીં. અમને $email પર લખો';
  }

  @override
  String get settings_copyEmail => 'ઇમેઇલ કૉપિ કરો';

  @override
  String get settings_emailCopied => 'ઇમેઇલ કૉપિ થયો';

  @override
  String get settings_close => 'બંધ કરો';

  @override
  String get settings_appVersion => 'એપ વર્ઝન';

  @override
  String settings_appVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settings_licenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String get web_loadError =>
      'આ પેજ લોડ થઈ શક્યું નહીં. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get themes_title => 'થીમ અને રંગો';

  @override
  String get themes_mode => 'થીમ મોડ';

  @override
  String get themes_system => 'સિસ્ટમ';

  @override
  String get themes_light => 'આછું';

  @override
  String get themes_dark => 'ઘેરું';

  @override
  String get themes_colors => 'રંગો';

  @override
  String get themes_fontSize => 'ફૉન્ટનું કદ';

  @override
  String get themes_fontDefault => 'ડિફૉલ્ટ';

  @override
  String get themes_fontLarge => 'મોટું';

  @override
  String get themes_preview => 'પૂર્વાવલોકન';

  @override
  String get themes_previewSpent => 'આ મહિને ખર્ચ';

  @override
  String get themes_previewChip => 'કરિયાણું';

  @override
  String get themes_pro => 'Pro';

  @override
  String themes_tileSelected(String name) {
    return '$name, પસંદ કરેલ';
  }

  @override
  String themes_tileLocked(String name) {
    return '$name, Pro, લૉક છે';
  }

  @override
  String get themes_lockedMessage => 'આ થીમ વાપરવા Pro મેળવો';

  @override
  String get theme_default => 'ડિફૉલ્ટ ટીલ';

  @override
  String get theme_indigo => 'ઇન્ડિગો';

  @override
  String get theme_saffron => 'કેસરી';

  @override
  String get theme_forest => 'વન લીલો';

  @override
  String get theme_rose => 'ગુલાબી';

  @override
  String get theme_midnight => 'મધ્યરાત્રિ';

  @override
  String get theme_ocean => 'દરિયાઈ';

  @override
  String get theme_mono => 'મોનો';

  @override
  String get settings_security => 'સુરક્ષા';

  @override
  String get settings_appLockEntry => 'એપ લૉક';

  @override
  String get settings_on => 'ચાલુ';

  @override
  String get settings_off => 'બંધ';

  @override
  String get security_title => 'સુરક્ષા';

  @override
  String get security_appLock => 'એપ લૉક';

  @override
  String get security_changePin => 'PIN બદલો';

  @override
  String get security_biometric => 'ફિંગરપ્રિન્ટ / ફેસ અનલૉક વાપરો';

  @override
  String get security_needsLock => 'પહેલાં એપ લૉક ચાલુ કરો';

  @override
  String get security_biometricNotEnrolled =>
      'તમારા ફોનની સેટિંગ્સમાં ફિંગરપ્રિન્ટ અથવા ફેસ અનલૉક સેટ કરો';

  @override
  String get security_biometricNone =>
      'આ ફોન ફિંગરપ્રિન્ટ અથવા ફેસ અનલૉકને સપોર્ટ કરતો નથી';

  @override
  String get security_lockAfter => 'આ પછી લૉક કરો';

  @override
  String get security_immediately => 'તરત જ';

  @override
  String get security_after1Min => '1 મિનિટ પછી';

  @override
  String get security_after5Min => '5 મિનિટ પછી';

  @override
  String get security_hideInRecents => 'તાજેતરની એપ્સમાં સામગ્રી છુપાવો';

  @override
  String get security_hideInRecentsHelp => 'સ્ક્રીનશૉટ પણ બંધ થઈ જાય છે.';

  @override
  String get security_lockOn => 'એપ લૉક ચાલુ છે';

  @override
  String get security_lockOff => 'એપ લૉક બંધ છે';

  @override
  String get security_pinChanged => 'PIN બદલાઈ ગયો';

  @override
  String get lock_enterPin => 'PIN દાખલ કરો';

  @override
  String get lock_wrongPin => 'ખોટો PIN';

  @override
  String lock_attemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પ્રયાસ બાકી',
      one: '1 પ્રયાસ બાકી',
    );
    return 'ખોટો PIN. $_temp0';
  }

  @override
  String lock_tryAgainIn(String time) {
    return '$timeમાં ફરી પ્રયાસ કરો';
  }

  @override
  String lock_nextLockoutWarning(String time) {
    return 'આગલો ખોટો PIN એપને $time માટે લૉક કરશે';
  }

  @override
  String get lock_credentialUnavailable => 'આ ફોન પર એપ લૉક તપાસી શકાતું નથી.';

  @override
  String get lock_biometricReason => 'DailyTrack અનલૉક કરો';

  @override
  String get lock_useBiometric => 'ફિંગરપ્રિન્ટ વાપરો';

  @override
  String get lock_delete => 'ભૂંસો';

  @override
  String lock_dotsLabel(int count) {
    return '4માંથી $count અંક દાખલ કર્યા';
  }

  @override
  String get pin_enterCurrent => 'હાલનો PIN દાખલ કરો';

  @override
  String get pin_enterNew => 'નવો PIN દાખલ કરો';

  @override
  String get pin_confirmNew => 'નવા PIN ની પુષ્ટિ કરો';

  @override
  String get pin_mismatch => 'PIN મેળ ખાતા નથી. ફરી પ્રયાસ કરો.';

  @override
  String get pin_offerBiometric => 'ફિંગરપ્રિન્ટ / ફેસ અનલૉક વાપરો';

  @override
  String get pin_done => 'થઈ ગયું';

  @override
  String get pin_saveError => 'તમારો PIN સાચવી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get onboarding_setAppLock => 'એપ લૉક સેટ કરો';

  @override
  String get onboarding_changePin => 'PIN બદલો';

  @override
  String get settings_data => 'ડેટા';

  @override
  String get settings_eraseAll => 'બધો ડેટા ભૂંસો';

  @override
  String get erase_title => 'બધો ડેટા ભૂંસીએ?';

  @override
  String get erase_body =>
      'આનાથી તમારા વ્યવહારો, ખાતાં, શ્રેણીઓ, બજેટ, પુનરાવર્તિત એન્ટ્રી, આદતો અને ચેક-ઇન, સેટિંગ્સ અને એપ લૉક ભૂંસાઈ જશે. આને પૂર્વવત્ કરી શકાતું નથી.';

  @override
  String get erase_continue => 'આગળ વધો';

  @override
  String get erase_typeTitle => 'પુષ્ટિ માટે DELETE લખો';

  @override
  String get erase_typeHint => 'DELETE';

  @override
  String get erase_confirm => 'બધું ભૂંસો';

  @override
  String get erase_inProgress => 'ભૂંસાઈ રહ્યું છે…';

  @override
  String get erase_failed => 'તમારો ડેટા ભૂંસી શકાયો નહીં. કંઈ ભૂંસાયું નથી.';

  @override
  String get lock_forgotPin => 'PIN ભૂલી ગયા?';

  @override
  String get lock_forgotTitle => 'તમારો PIN ભૂલી ગયા?';

  @override
  String get lock_forgotBody =>
      'તમારો PIN પાછો મેળવી શકાતો નથી. તમે બધો ડેટા ભૂંસીને નવેસરથી શરૂ કરી શકો છો.';

  @override
  String get backup_title => 'બેકઅપ અને રિસ્ટોર';

  @override
  String get backup_lastBackupTitle => 'છેલ્લું બેકઅપ';

  @override
  String get backup_noBackupYet => 'હજી સુધી કોઈ બેકઅપ નથી';

  @override
  String backup_lastBackupDetail(String date, String location, String size) {
    return '$date · $location · $size';
  }

  @override
  String get backup_locationDevice => 'આ ડિવાઇસ';

  @override
  String get backup_locationDrive => 'Google Drive';

  @override
  String backup_lastBackupSubtitle(String date) {
    return 'છેલ્લું બેકઅપ: $date';
  }

  @override
  String get backup_notBackedUp => 'હજી સુધી બેકઅપ લેવાયું નથી';

  @override
  String get backup_localTitle => 'બેકઅપ ફાઇલ';

  @override
  String get backup_localBody =>
      'તમારો બધો ડેટા આ ફોન પર એક ફાઇલ તરીકે સેવ કરો, અથવા કોઈ ફાઇલમાંથી રિસ્ટોર કરો.';

  @override
  String get backup_saveFile => 'બેકઅપ ફાઇલ સેવ કરો';

  @override
  String get backup_restoreFile => 'ફાઇલમાંથી રિસ્ટોર કરો';

  @override
  String get backup_saved => 'બેકઅપ સેવ થઈ ગયું';

  @override
  String get backup_share => 'શેર કરો';

  @override
  String get backup_working => 'બેકઅપ બનાવી રહ્યા છીએ…';

  @override
  String get backup_optionsTitle => 'વિકલ્પો';

  @override
  String get backup_encrypt => 'બેકઅપ એન્ક્રિપ્ટ કરો';

  @override
  String get backup_encryptHelp => 'બેકઅપ ફાઇલોને પાસવર્ડથી સુરક્ષિત કરે છે';

  @override
  String get backup_changePassword => 'પાસવર્ડ બદલો';

  @override
  String get backup_includeReceipts => 'રસીદના ફોટા સામેલ કરો';

  @override
  String get backup_includeReceiptsHelp => 'આનાથી બેકઅપ ફાઇલ મોટી થાય છે';

  @override
  String backup_countTransactions(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString વ્યવહારો',
      one: '1 વ્યવહાર',
      zero: 'કોઈ વ્યવહાર નથી',
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
      other: '$countString આદતો',
      one: '1 આદત',
      zero: 'કોઈ આદત નથી',
    );
    return '$_temp0';
  }

  @override
  String get backup_passwordTitle => 'બેકઅપ પાસવર્ડ સેટ કરો';

  @override
  String get backup_passwordChangeTitle => 'બેકઅપ પાસવર્ડ બદલો';

  @override
  String get backup_passwordField => 'પાસવર્ડ';

  @override
  String get backup_passwordConfirm => 'પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get backup_passwordWarning =>
      'જો તમે આ પાસવર્ડ ભૂલી જશો, તો તેનાથી બનેલા બેકઅપ રિસ્ટોર થઈ શકશે નહીં. તેને પાછો મેળવી શકાતો નથી.';

  @override
  String get backup_passwordMismatch => 'પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get backup_passwordSave => 'પાસવર્ડ સેવ કરો';

  @override
  String get restore_passwordTitle => 'બેકઅપ પાસવર્ડ દાખલ કરો';

  @override
  String get restore_open => 'બેકઅપ ખોલો';

  @override
  String get restore_previewTitle => 'આ બેકઅપ રિસ્ટોર કરીએ?';

  @override
  String restore_previewCreated(String date) {
    return '$date એ બનાવેલ';
  }

  @override
  String restore_previewVersion(String version) {
    return 'એપ વર્ઝન $version';
  }

  @override
  String restore_previewReceipts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString રસીદના ફોટા સામેલ છે',
      one: '1 રસીદનો ફોટો સામેલ છે',
    );
    return '$_temp0';
  }

  @override
  String get restore_previewSkipped =>
      'આ બેકઅપનો થોડો ડેટા એવી સુવિધાનો છે જે આ વર્ઝનમાં નથી. તેને છોડી દેવામાં આવશે.';

  @override
  String get restore_continue => 'આગળ વધો';

  @override
  String get restore_confirmTitle => 'હાલનો ડેટા બદલીએ?';

  @override
  String get restore_confirmBody =>
      'તમારા હાલના બધા વ્યવહારો, ખાતાં, શ્રેણીઓ, બજેટ, પુનરાવર્તિત એન્ટ્રી, આદતો, ચેક-ઇન અને પસંદગીઓ આ બેકઅપથી બદલાઈ જશે. આને પૂર્વવત્ કરી શકાતું નથી.';

  @override
  String get restore_confirmAction => 'ડેટા બદલો';

  @override
  String get restore_inProgress => 'રિસ્ટોર થઈ રહ્યું છે…';

  @override
  String get restore_done => 'બેકઅપ રિસ્ટોર થઈ ગયું';

  @override
  String get restore_doneMissingReceipts =>
      'બેકઅપ રિસ્ટોર થઈ ગયું, પણ કેટલાક રસીદના ફોટા કૉપિ થઈ શક્યા નહીં.';

  @override
  String get restore_failedTitle => 'રિસ્ટોર થઈ શક્યું નહીં';

  @override
  String get backup_failedTitle => 'બેકઅપ થઈ શક્યું નહીં';

  @override
  String get backup_errNotRecognized =>
      'આ DailyTrack બેકઅપ નથી. કંઈ બદલાયું નથી.';

  @override
  String get backup_errDamaged =>
      'આ બેકઅપ ફાઇલ ખરાબ છે અને વાંચી શકાતી નથી. કંઈ બદલાયું નથી.';

  @override
  String get backup_errInvalid =>
      'આ બેકઅપમાં એવો ડેટા છે જે DailyTrack વાપરી શકતું નથી. કંઈ બદલાયું નથી.';

  @override
  String get backup_errTooNew => 'આ બેકઅપ રિસ્ટોર કરવા DailyTrack અપડેટ કરો.';

  @override
  String get backup_errWrongPassword => 'ખોટો પાસવર્ડ અથવા ખરાબ ફાઇલ.';

  @override
  String get backup_errNeedsPassword =>
      'એન્ક્રિપ્ટેડ બેકઅપ બનાવતા રહેવા માટે તમારો બેકઅપ પાસવર્ડ ફરીથી સેટ કરો.';

  @override
  String get backup_errTooLarge =>
      'આ બેકઅપ એન્ક્રિપ્ટ કરવા માટે ખૂબ મોટું છે. રસીદના ફોટા બંધ કરીને ફરી પ્રયાસ કરો.';

  @override
  String get backup_errBusy =>
      'એક બેકઅપ અથવા રિસ્ટોર પહેલેથી ચાલી રહ્યું છે. થોડી વાર પછી ફરી પ્રયાસ કરો.';

  @override
  String get backup_errStorage =>
      'આ ફોનમાં પૂરતી જગ્યા નથી. થોડી જગ્યા ખાલી કરીને ફરી પ્રયાસ કરો.';

  @override
  String get backup_errGeneric => 'કંઈક ખોટું થયું. કંઈ બદલાયું નથી.';

  @override
  String get backup_driveTitle => 'Google Drive';

  @override
  String get backup_driveBody =>
      'તમારી પોતાની Google Drive પર બેકઅપ લો. બેકઅપ એક ખાનગી એપ ફોલ્ડરમાં રાખવામાં આવે છે, જે તમને તમારી Drive ફાઇલોમાં દેખાશે નહીં.';

  @override
  String get backup_driveUnavailable => 'આ બિલ્ડમાં Google Drive ઉપલબ્ધ નથી.';

  @override
  String backup_connected(String email) {
    return '$email તરીકે જોડાયેલું છે';
  }

  @override
  String get backup_backUpNow => 'હમણાં બેકઅપ લો';

  @override
  String get backup_uploading => 'Google Drive પર બેકઅપ થઈ રહ્યું છે…';

  @override
  String get backup_driveSaved => 'Google Drive પર બેકઅપ થઈ ગયું';

  @override
  String get backup_autoTitle => 'ઑટો બેકઅપ';

  @override
  String get backup_autoOff => 'બંધ';

  @override
  String get backup_autoDaily => 'રોજ';

  @override
  String get backup_autoWeekly => 'દર અઠવાડિયે';

  @override
  String get backup_wifiOnly => 'ફક્ત Wi-Fi પર';

  @override
  String get backup_wifiOnlyHelp => 'બેકઅપ પહેલાં Wi-Fi ની રાહ જુએ છે';

  @override
  String get backup_driveListTitle => 'Google Drive માંથી રિસ્ટોર કરો';

  @override
  String get backup_driveListEmpty => 'Google Drive માં હજી સુધી કોઈ બેકઅપ નથી';

  @override
  String get backup_driveListError =>
      'તમારા Google Drive બેકઅપ લોડ થઈ શક્યા નહીં.';

  @override
  String backup_driveEntry(String date, String size) {
    return '$date · $size';
  }

  @override
  String get backup_kindManual => 'મેન્યુઅલ';

  @override
  String get backup_kindAuto => 'ઑટો';

  @override
  String get backup_delete => 'કાઢી નાખો';

  @override
  String get backup_deleteTitle => 'આ બેકઅપ કાઢી નાખીએ?';

  @override
  String get backup_deleteBody =>
      'તેને Google Drive માંથી દૂર કરવામાં આવશે. આને પૂર્વવત્ કરી શકાતું નથી.';

  @override
  String get backup_deleteAction => 'બેકઅપ કાઢી નાખો';

  @override
  String get backup_moreActions => 'આ બેકઅપ માટે વધુ વિકલ્પો';

  @override
  String get backup_listLoading => 'તમારા બેકઅપ લોડ થઈ રહ્યા છે…';

  @override
  String get backup_downloading => 'બેકઅપ ડાઉનલોડ થઈ રહ્યું છે…';

  @override
  String get backup_errAuth => 'તમારું Google ખાતું ફરીથી જોડવું પડશે.';

  @override
  String get backup_reconnect => 'Google ખાતું ફરીથી જોડો';

  @override
  String get backup_errQuota =>
      'તમારી Google Drive ભરાઈ ગઈ છે. Drive માં જગ્યા ખાલી કરીને ફરી પ્રયાસ કરો.';

  @override
  String get backup_errOffline =>
      'Google Drive સુધી પહોંચી શક્યા નહીં. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get backup_errDrive =>
      'Google Drive હાલમાં જવાબ આપતી નથી. પછીથી ફરી પ્રયાસ કરો.';

  @override
  String get notif_channelBackup => 'બેકઅપ';

  @override
  String get notif_channelBackupDescription =>
      'ઑટોમેટિક બેકઅપ વારંવાર નિષ્ફળ જાય ત્યારે જણાવે છે';

  @override
  String get notif_backupFailingTitle => 'ઑટોમેટિક બેકઅપ કામ કરતું નથી';

  @override
  String get notif_backupFailingBody =>
      'Google Drive પર તમારા છેલ્લા 3 બેકઅપ નિષ્ફળ ગયા. તપાસવા ટૅપ કરો.';

  @override
  String get lock_forgotBodyRestore =>
      'તમારો PIN પાછો મેળવી શકાતો નથી. તમે Google Drive બેકઅપમાંથી તમારો ડેટા રિસ્ટોર કરી શકો છો, અથવા બધો ડેટા ભૂંસીને નવેસરથી શરૂ કરી શકો છો.';

  @override
  String get lock_restoreFromDrive => 'Google Drive બેકઅપમાંથી રિસ્ટોર કરો';

  @override
  String get export_title => 'ડેટા એક્સપોર્ટ કરો';

  @override
  String get export_settingsHelp => 'CSV અથવા PDF';

  @override
  String get export_dataType => 'ડેટા';

  @override
  String get export_transactions => 'વ્યવહારો';

  @override
  String get export_habits => 'આદતો';

  @override
  String get export_period => 'સમયગાળો';

  @override
  String get export_format => 'ફોર્મેટ';

  @override
  String get export_csv => 'CSV';

  @override
  String get export_pdf => 'PDF';

  @override
  String get export_filtersTitle => 'ફિલ્ટર';

  @override
  String get export_accounts => 'ખાતાં';

  @override
  String get export_categories => 'શ્રેણીઓ';

  @override
  String get export_all => 'બધા';

  @override
  String export_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પસંદ કર્યા',
      one: '1 પસંદ કર્યું',
    );
    return '$_temp0';
  }

  @override
  String get export_filterDone => 'લાગુ કરો';

  @override
  String get export_button => 'એક્સપોર્ટ કરો';

  @override
  String get export_working => 'તમારી ફાઇલ બની રહી છે…';

  @override
  String get export_locked =>
      'એક્સપોર્ટ DailyTrack Pro નો ભાગ છે. એક એક્સપોર્ટ માટે જાહેરાત જુઓ, અથવા Pro મેળવો.';

  @override
  String get export_nothing => 'આ સમયગાળા માટે એક્સપોર્ટ કરવા જેવું કંઈ નથી';

  @override
  String get export_failedTitle => 'એક્સપોર્ટ થઈ શક્યું નહીં';

  @override
  String get export_failed =>
      'ફાઇલ બની શકી નહીં. કંઈ શેર કરાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get export_reportAction => 'આ રિપોર્ટ એક્સપોર્ટ કરો';

  @override
  String get export_colDate => 'તારીખ';

  @override
  String get export_colTime => 'સમય';

  @override
  String get export_colType => 'પ્રકાર';

  @override
  String get export_colCategory => 'શ્રેણી';

  @override
  String get export_colAccount => 'ખાતું';

  @override
  String get export_colPaymentMode => 'ચુકવણીની રીત';

  @override
  String get export_colAmount => 'રકમ';

  @override
  String get export_colNote => 'નોંધ';

  @override
  String get export_colHabit => 'આદત';

  @override
  String get export_colValue => 'મૂલ્ય';

  @override
  String get export_colTarget => 'લક્ષ્ય';

  @override
  String get export_colUnit => 'એકમ';

  @override
  String get export_colStatus => 'સ્થિતિ';

  @override
  String get export_statusDone => 'પૂર્ણ';

  @override
  String get export_statusPartial => 'આંશિક';

  @override
  String get export_statusFreeze => 'ફ્રીઝ';

  @override
  String get export_totalIncome => 'કુલ આવક';

  @override
  String get export_totalExpense => 'કુલ ખર્ચ';

  @override
  String get export_net => 'ચોખ્ખું';

  @override
  String get export_count => 'એન્ટ્રી';

  @override
  String export_percent(int percent) {
    return '$percent% પૂર્ણ';
  }

  @override
  String export_filterAccounts(String names) {
    return 'ખાતાં: $names';
  }

  @override
  String export_filterCategories(String names) {
    return 'શ્રેણીઓ: $names';
  }

  @override
  String export_transfer(String from, String to) {
    return '$from → $to';
  }

  @override
  String get export_chartTitle => 'શ્રેણી મુજબ ખર્ચ';

  @override
  String get export_other => 'અન્ય';

  @override
  String get export_summaryTitle => 'સારાંશ';

  @override
  String export_pdfHeader(String title, String period) {
    return 'DailyTrack · $title · $period';
  }

  @override
  String export_page(int page, int pages) {
    return 'પેજ $page / $pages';
  }

  @override
  String get notif_channelDailySummary => 'દૈનિક સારાંશ';

  @override
  String get notif_channelDailySummaryDescription =>
      'દિવસનો તમારો ખર્ચ અને આદતો';

  @override
  String get notif_dailySummaryTitle => 'આજે DailyTrack માં';

  @override
  String notif_dailySummaryBoth(String amount, int done, int total) {
    return 'આજે $amount ખર્ચ · $done/$total આદતો પૂર્ણ';
  }

  @override
  String notif_dailySummarySpend(String amount) {
    return 'આજે $amount ખર્ચ';
  }

  @override
  String notif_dailySummaryHabits(int done, int total) {
    return '$done/$total આદતો પૂર્ણ';
  }

  @override
  String get notif_actionMarkDone => 'પૂર્ણ કરો';

  @override
  String get notif_actionSnooze => '1 કલાક પછી';

  @override
  String get settings_exactNote => 'રિમાઇન્ડર થોડી મિનિટ મોડા આવી શકે છે';

  @override
  String get settings_exactAllow => 'ચોક્કસ સમયની મંજૂરી આપો';

  @override
  String get security_showWidgetData => 'વિજેટ પર ડેટા બતાવો';

  @override
  String get security_showWidgetDataHelp =>
      'તમારી હોમ સ્ક્રીન પર રકમ અને આદતોનાં નામ બતાવે છે';

  @override
  String get widget_label => 'DailyTrack આજે';

  @override
  String get widget_description => 'આજનો ખર્ચ, બજેટ અને આદતોની તપાસ';

  @override
  String get widget_open => 'DailyTrack ખોલો';

  @override
  String get widget_spentToday => 'આજનો ખર્ચ';

  @override
  String widget_spentTodayA11y(String amount) {
    return 'આજનો ખર્ચ, $amount';
  }

  @override
  String widget_monthBudget(String month) {
    return '$month નું બજેટ';
  }

  @override
  String widget_budgetText(int percent, String spent, String limit) {
    return '$percent% વપરાયું · $limit માંથી $spent';
  }

  @override
  String get widget_noBudget => 'કોઈ બજેટ સેટ નથી';

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
    return '$name, પૂર્ણ';
  }

  @override
  String widget_habitTodoA11y(String name) {
    return '$name, પૂર્ણ નથી. પૂર્ણ કરવા માટે બે વાર ટૅપ કરો';
  }

  @override
  String widget_habitCountA11y(String name, String progress) {
    return '$name, $progress. એક ઉમેરવા માટે બે વાર ટૅપ કરો';
  }

  @override
  String get ads_badge => 'જાહેરાત';

  @override
  String get ads_bannerLabel => 'જાહેરાત';

  @override
  String get privacy_adChoices => 'જાહેરાત ગોપનીયતા પસંદગીઓ';

  @override
  String get ads_resetCounters => 'જાહેરાત કાઉન્ટર રીસેટ કરો';

  @override
  String get ads_resetCountersDone => 'જાહેરાત કાઉન્ટર રીસેટ થયા';

  @override
  String get premium_title => 'DailyTrack Pro';

  @override
  String get premium_benefitNoAds => 'કોઈ જાહેરાત નહીં';

  @override
  String get premium_benefitThemes => 'બધી થીમ';

  @override
  String get premium_benefitReports => 'અદ્યતન રિપોર્ટ';

  @override
  String get premium_benefitExports => 'અમર્યાદિત એક્સપોર્ટ';

  @override
  String get premium_benefitFreezes => 'મર્યાદા સુધી અમર્યાદિત સ્ટ્રીક ફ્રીઝ';

  @override
  String get rewarded_titleReports => '24 કલાક માટે અદ્યતન રિપોર્ટ અનલૉક કરો';

  @override
  String get rewarded_titleCsv => 'એક CSV એક્સપોર્ટ અનલૉક કરો';

  @override
  String get rewarded_titlePdf => 'એક PDF એક્સપોર્ટ અનલૉક કરો';

  @override
  String rewarded_titleTheme(String theme) {
    return '$theme થીમ હંમેશ માટે અનલૉક કરો';
  }

  @override
  String rewarded_titleFreeze(String habit) {
    return '$habit માટે 1 સ્ટ્રીક ફ્રીઝ મેળવો';
  }

  @override
  String get rewarded_explainReports =>
      'આગામી 24 કલાક સુધી વલણો, ખાતાં અને દરેક સમયગાળો જોવા માટે એક ટૂંકી જાહેરાત જુઓ.';

  @override
  String get rewarded_explainExport =>
      'આ ફોર્મેટમાં એક એક્સપોર્ટ ફાઇલ બનાવવા માટે એક ટૂંકી જાહેરાત જુઓ.';

  @override
  String get rewarded_explainTheme =>
      'આ રંગ થીમ હંમેશ માટે મેળવવા માટે એક ટૂંકી જાહેરાત જુઓ.';

  @override
  String get rewarded_explainFreeze =>
      'આ આદતમાં એક સ્ટ્રીક ફ્રીઝ ઉમેરવા માટે એક ટૂંકી જાહેરાત જુઓ (વધુમાં વધુ 2).';

  @override
  String get rewarded_watch => 'એક ટૂંકી જાહેરાત જુઓ';

  @override
  String get rewarded_getPro => 'તેના બદલે Pro મેળવો';

  @override
  String get rewarded_notNow => 'હમણાં નહીં';

  @override
  String get rewarded_loadingAd => 'જાહેરાત લોડ થઈ રહી છે';

  @override
  String get rewarded_unavailable => 'જાહેરાત ઉપલબ્ધ નથી, પછીથી ફરી પ્રયાસ કરો';

  @override
  String get rewarded_tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get rewarded_closedEarly => 'અનલૉક કરવા માટે આખી જાહેરાત જુઓ';

  @override
  String get rewarded_limitReached =>
      'આજ માટે આ અનલૉકની મર્યાદા પૂરી થઈ ગઈ છે. કાલે ફરી પ્રયાસ કરો, અથવા Pro મેળવો.';

  @override
  String get locked_watchAdReports => '24 કલાક માટે અનલૉક કરવા જાહેરાત જુઓ';

  @override
  String get locked_watchAdExport => 'એક એક્સપોર્ટ અનલૉક કરવા જાહેરાત જુઓ';

  @override
  String get locked_watchAdTheme => 'આ થીમ અનલૉક કરવા જાહેરાત જુઓ';

  @override
  String get locked_watchAdFreeze => 'ફ્રીઝ મેળવવા જાહેરાત જુઓ';

  @override
  String premium_buyFor(String price) {
    return '$price માં Pro મેળવો';
  }

  @override
  String get premium_restore => 'ખરીદી પાછી મેળવો';

  @override
  String get premium_restored => 'Pro પાછું મળ્યું';

  @override
  String get premium_restoreNotFound =>
      'આ Google ખાતા માટે કોઈ Pro ખરીદી મળી નથી';

  @override
  String get premium_storeUnavailable =>
      'સ્ટોર હમણાં ઉપલબ્ધ નથી, પછીથી ફરી પ્રયાસ કરો';

  @override
  String get premium_accountNote =>
      'તમારી ખરીદી તમારા Google ખાતા સાથે જોડાયેલી છે.';

  @override
  String get premium_pending => 'ચુકવણી પૂરી થતાં જ Pro અનલૉક થશે';

  @override
  String get premium_purchaseError => 'ખરીદી પૂરી થઈ શકી નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get premium_owned => 'તમારી પાસે Pro છે. તમારા સાથ બદલ આભાર.';

  @override
  String get premium_cardTitle => 'જાહેરાતો દૂર કરો અને બધું અનલૉક કરો';

  @override
  String get premium_cardSubtitle => 'DailyTrack Pro: એક વાર ખરીદો, હંમેશ માટે';

  @override
  String get habit_addFreezePro => 'ફ્રીઝ ઉમેરો';

  @override
  String get account_title => 'ખાતું';

  @override
  String get account_signedOutTitle => 'તમારા Google ખાતાથી બેકઅપ લો';

  @override
  String get account_pointDrive =>
      'તમારો ડેટા તમારી પોતાની Google Drive માં સેવ થાય છે';

  @override
  String get account_pointRestore => 'નવા ફોન પર તેને રિસ્ટોર કરો';

  @override
  String get account_pointOptional =>
      'વૈકલ્પિક: એપ ખાતા વિના પણ પૂરેપૂરી કામ કરે છે';

  @override
  String get account_signIn => 'Google થી સાઇન ઇન કરો';

  @override
  String get account_pinFootnote =>
      'તમારા એપ લૉક PIN નું ક્યારેય બેકઅપ લેવાતું નથી.';

  @override
  String get account_signInFailed =>
      'સાઇન ઇન થઈ શક્યું નહીં. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get account_restoreOffline =>
      'રિસ્ટોર કરવા માટે ઇન્ટરનેટ સાથે કનેક્ટ કરો';

  @override
  String get account_signInOffline =>
      'Google વડે સાઇન ઇન કરવા માટે ઇન્ટરનેટ સાથે કનેક્ટ કરો';

  @override
  String get account_signedInBackedUp =>
      'સાઇન ઇન થઈ ગયું. તમારા ડેટાનું બેકઅપ થઈ ગયું છે.';

  @override
  String account_lastBackupFrom(String time, String device) {
    return 'છેલ્લું બેકઅપ: $time · $device';
  }

  @override
  String account_lastBackup(String time) {
    return 'છેલ્લું બેકઅપ: $time';
  }

  @override
  String get account_noBackupYet => 'આ ખાતામાં હજી સુધી કોઈ બેકઅપ નથી';

  @override
  String get account_statusBackedUp => 'Google પર બેકઅપ થઈ ગયું';

  @override
  String get account_statusOffline =>
      'તમે ઑફલાઇન છો. ઑનલાઇન થતાં બેકઅપ ફરી શરૂ થશે.';

  @override
  String get account_statusWaitingForWifi => 'Wi-Fi ની રાહ જોવાઈ રહી છે';

  @override
  String get account_statusFailedNoPassword =>
      'બેકઅપ નિષ્ફળ ગયું: બેકઅપ અને રિસ્ટોરમાં તમારો બેકઅપ પાસવર્ડ સેટ કરો';

  @override
  String get account_signOutBackedUp => 'બેકઅપ થઈ ગયું';

  @override
  String get account_statusBackingUp => 'બેકઅપ થઈ રહ્યું છે…';

  @override
  String get account_statusPaused =>
      'બેકઅપ અટક્યું છે: બીજા ફોનનું નવું બેકઅપ છે';

  @override
  String get account_statusFailed => 'બેકઅપ નિષ્ફળ ગયું';

  @override
  String get account_statusError => 'તમારા બેકઅપ વાંચી શકાયા નહીં.';

  @override
  String account_autoSummaryWifi(String frequency) {
    return '$frequency · ફક્ત Wi-Fi પર';
  }

  @override
  String get account_signOut => 'સાઇન આઉટ કરો';

  @override
  String get account_signedOut =>
      'સાઇન આઉટ થઈ ગયું. તમારો ડેટા હજી પણ આ ફોન પર છે.';

  @override
  String get account_deleteBackups => 'મારા બેકઅપ કાઢી નાખો';

  @override
  String get account_deleteTitle => 'તમારા બેકઅપ કાઢી નાખીએ?';

  @override
  String account_deleteBody(int count, String email) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$email માંથી DailyTrack ના બધા $countString બેકઅપ કાઢી નાખીએ? આ ફોનનો ડેટા રહેશે. આને પૂર્વવત્ કરી શકાતું નથી.',
      one:
          '$email માંથી DailyTrack નું 1 બેકઅપ કાઢી નાખીએ? આ ફોનનો ડેટા રહેશે. આને પૂર્વવત્ કરી શકાતું નથી.',
    );
    return '$_temp0';
  }

  @override
  String get account_deleteAction => 'બેકઅપ કાઢી નાખો';

  @override
  String get account_deleted => 'તમારા બેકઅપ કાઢી નાખવામાં આવ્યા';

  @override
  String account_photoOf(String name) {
    return '$name નો પ્રોફાઇલ ફોટો';
  }

  @override
  String get backup_manageAccount => 'તમારું ખાતું મેનેજ કરો';

  @override
  String get backup_conflictTitle => 'તો પણ બેકઅપ લઈએ?';

  @override
  String backup_conflictNewer(String device, String time) {
    return '$device નું એક નવું બેકઅપ ($time) છે. હમણાં બેકઅપ લેવાથી આ ફોનનો ડેટા સૌથી નવો બની જશે.';
  }

  @override
  String get backup_conflictEmpty =>
      'આ ફોન પર કોઈ ડેટા નથી. હમણાં બેકઅપ લેવાથી ખાલી બેકઅપ સૌથી નવું બની જશે.';

  @override
  String get backup_backUpAnyway => 'તો પણ બેકઅપ લો';

  @override
  String get backup_unknownDevice => 'અજાણ્યું ડિવાઇસ';

  @override
  String get account_androidPhone => 'Android ફોન';

  @override
  String get notif_backupPausedTitle => 'બેકઅપ અટક્યું છે';

  @override
  String get notif_backupPausedBody =>
      'બીજા ફોને નવું બેકઅપ લીધું છે. જોવા માટે ટૅપ કરો.';

  @override
  String account_choiceTitle(String email) {
    return '$email પર બેકઅપ મળ્યું';
  }

  @override
  String get account_fromThisPhone => 'આ ફોનમાંથી';

  @override
  String account_fromDevice(String device) {
    return '$device માંથી';
  }

  @override
  String get account_encrypted => 'એન્ક્રિપ્ટેડ';

  @override
  String account_thisPhone(String counts) {
    return 'આ ફોન: $counts';
  }

  @override
  String get account_thisPhoneEmpty => 'આ ફોન: હજી કોઈ ડેટા નથી';

  @override
  String get account_replaceNote => 'રિસ્ટોર કરવાથી આ ફોનનો ડેટા બદલાઈ જશે.';

  @override
  String get account_restoreFromAccount => 'ખાતામાંથી રિસ્ટોર કરો';

  @override
  String get account_keepThisPhone => 'આ ફોનનો ડેટા રાખો';

  @override
  String get account_seeAllBackups => 'બધા બેકઅપ જુઓ';

  @override
  String get account_close => 'બંધ કરો';

  @override
  String get account_wrongPassword => 'તે પાસવર્ડ કામ ન કર્યો';

  @override
  String get account_restoreFailed =>
      'રિસ્ટોર થઈ શક્યું નહીં. આ ફોન પરનો તમારો ડેટા બદલાયો નથી.';

  @override
  String get account_safetyCopyFailed =>
      'પહેલાં આ ફોનના ડેટાની કૉપિ સેવ કરવા માટે જગ્યા નથી, તેથી કંઈ રિસ્ટોર થયું નથી. જગ્યા ખાલી કરીને ફરી પ્રયાસ કરો.';

  @override
  String account_restoredCounts(String summary) {
    return 'રિસ્ટોર થઈ ગયું: $summary';
  }

  @override
  String get account_restoring => 'તમારો ડેટા રિસ્ટોર થઈ રહ્યો છે…';

  @override
  String get account_restore => 'રિસ્ટોર કરો';

  @override
  String get account_review => 'જુઓ';

  @override
  String get account_switch => 'ખાતું બદલો';

  @override
  String get account_switchFailedTitle => 'પહેલાં બેકઅપ થઈ શક્યું નહીં';

  @override
  String account_switchFailedBody(String email) {
    return 'તમારા નવા ફેરફારો હજી $email માં નથી. તો પણ ખાતું બદલીએ? તમારો ડેટા આ ફોન પર રહેશે.';
  }

  @override
  String get account_switchAnyway => 'તો પણ બદલો';

  @override
  String get account_sessionExpired =>
      'તમારું Google સાઇન-ઇન સમાપ્ત થયું. બેકઅપ ચાલુ રાખવા ફરીથી સાઇન ઇન કરો.';

  @override
  String account_signOutSheetTitle(String email) {
    return '$email માંથી સાઇન આઉટ કરીએ?';
  }

  @override
  String get account_signOutBackingUp =>
      'તમારા નવા ફેરફારોનું બેકઅપ થઈ રહ્યું છે…';

  @override
  String get account_signOutBackupFailed =>
      'તમારા નવા ફેરફારોનું બેકઅપ થઈ શક્યું નહીં';

  @override
  String get account_signOutAnyway => 'તો પણ સાઇન આઉટ કરો';

  @override
  String get account_keepData => 'આ ફોન પર ડેટા રાખો';

  @override
  String get account_keepDataHelp =>
      'તમે ખાતા વિના એપનો ઉપયોગ ચાલુ રાખી શકો છો.';

  @override
  String get account_removeData => 'આ ફોનમાંથી ડેટા કાઢી નાખો';

  @override
  String get account_removeDataHelp =>
      'તમારું બેકઅપ તમારા Google ખાતામાં રહેશે.';

  @override
  String get auth_title => 'તમારો ડેટા સુરક્ષિત રાખો';

  @override
  String get auth_body =>
      'તમારા ખર્ચ અને આદતોનો બેકઅપ લેવા અને નવા ફોન પર તેમને પાછા મેળવવા માટે Google થી સાઇન ઇન કરો.';

  @override
  String get auth_continueWithGoogle => 'Google સાથે ચાલુ રાખો';

  @override
  String get auth_continueAsGuest => 'મહેમાન તરીકે ચાલુ રાખો';

  @override
  String get auth_guestNote =>
      'મહેમાન તરીકે, તમારો ડેટા ફક્ત આ ફોન પર જ રહે છે.';

  @override
  String get auth_signInCancelled =>
      'સાઇન ઇન રદ થયું. ફરી પ્રયાસ કરો અથવા મહેમાન તરીકે ચાલુ રાખો.';

  @override
  String get auth_offline =>
      'તમે ઑફલાઇન છો. Google થી સાઇન ઇન કરવા માટે ઇન્ટરનેટ સાથે જોડાઓ, અથવા મહેમાન તરીકે ચાલુ રાખો.';

  @override
  String get auth_continueWithoutRestoring => 'રિસ્ટોર કર્યા વિના ચાલુ રાખો';

  @override
  String get accountCard_guestTitle => 'મહેમાન · ડેટા ફક્ત આ ફોન પર સેવ છે';

  @override
  String accountCard_backedUp(String time) {
    return 'Google પર બેકઅપ થઈ ગયું · $time';
  }

  @override
  String get accountCard_paused => 'બેકઅપ અટક્યું છે';

  @override
  String get accountCard_justNow => 'હમણાં જ';

  @override
  String accountCard_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count મિનિટ પહેલાં',
      one: '1 મિનિટ પહેલાં',
    );
    return '$_temp0';
  }

  @override
  String accountCard_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count કલાક પહેલાં',
      one: '1 કલાક પહેલાં',
    );
    return '$_temp0';
  }

  @override
  String accountCard_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ પહેલાં',
      one: 'ગઈકાલે',
    );
    return '$_temp0';
  }

  @override
  String get settings_logOutGuest => 'મહેમાન મોડમાંથી લૉગ આઉટ કરો';

  @override
  String get logOutGuest_title => 'લૉગ આઉટ કરીને તમારો ડેટા કાઢી નાખશો?';

  @override
  String get logOutGuest_body =>
      'મહેમાન તરીકે, તમારો ડેટા ફક્ત આ ફોન પર સેવ છે. લૉગ આઉટ કરવાથી તમારા બધા ખર્ચ, આદતો, બજેટ, રસીદો અને અનલૉક કાયમ માટે કાઢી નાખવામાં આવશે. આ પાછું કરી શકાતું નથી.';

  @override
  String get logOutGuest_signInInstead => 'તેના બદલે Google થી સાઇન ઇન કરો';

  @override
  String get logOutGuest_confirm => 'લૉગ આઉટ કરો અને કાઢી નાખો';

  @override
  String get logOutGuest_failed => 'તમારો ડેટા કાઢી શકાયો નથી. ફરી પ્રયાસ કરો.';

  @override
  String get finishSetup_title => 'સેટઅપ પૂરું કરો';

  @override
  String get finishSetup_body =>
      'તમારો ડેટા પાછો આવી ગયો. તમારા એપ લૉક PIN નું ક્યારેય બેકઅપ થતું નથી, તેથી તમારો ડેટા ખાનગી રાખવા નવો PIN સેટ કરો.';

  @override
  String get finishSetup_setLock => 'એપ લૉક સેટ કરો';

  @override
  String get finishSetup_allowNotifications => 'સૂચનાઓની મંજૂરી આપો';

  @override
  String get finishSetup_notNow => 'હમણાં નહીં';

  @override
  String get backup_previousTitle => 'ફોનનો પાછલો ડેટા રિસ્ટોર કરો';

  @override
  String backup_previousDetail(String date, String counts) {
    return '$date એ સેવ કર્યું · $counts';
  }

  @override
  String get currency_INR => 'ભારતીય રૂપિયો';

  @override
  String get currency_USD => 'યુએસ ડૉલર';

  @override
  String get currency_EUR => 'યુરો';

  @override
  String get currency_GBP => 'બ્રિટિશ પાઉન્ડ';

  @override
  String get currency_AED => 'યુએઈ દિરહામ';

  @override
  String get currency_SAR => 'સાઉદી રિયાલ';

  @override
  String get currency_QAR => 'કતારી રિયાલ';

  @override
  String get currency_KWD => 'કુવૈતી દીનાર';

  @override
  String get currency_OMR => 'ઓમાની રિયાલ';

  @override
  String get currency_BHD => 'બહેરીની દીનાર';

  @override
  String get currency_SGD => 'સિંગાપોર ડૉલર';

  @override
  String get currency_MYR => 'મલેશિયન રિંગિટ';

  @override
  String get currency_THB => 'થાઈ બાહ્ત';

  @override
  String get currency_IDR => 'ઇન્ડોનેશિયન રૂપિયા';

  @override
  String get currency_PHP => 'ફિલિપાઇન પેસો';

  @override
  String get currency_JPY => 'જાપાની યેન';

  @override
  String get currency_CNY => 'ચીની યુઆન';

  @override
  String get currency_HKD => 'હોંગકોંગ ડૉલર';

  @override
  String get currency_KRW => 'દક્ષિણ કોરિયન વૉન';

  @override
  String get currency_AUD => 'ઓસ્ટ્રેલિયન ડૉલર';

  @override
  String get currency_NZD => 'ન્યુઝીલેન્ડ ડૉલર';

  @override
  String get currency_CAD => 'કેનેડિયન ડૉલર';

  @override
  String get currency_CHF => 'સ્વિસ ફ્રેંક';

  @override
  String get currency_SEK => 'સ્વીડિશ ક્રોના';

  @override
  String get currency_NOK => 'નોર્વેજિયન ક્રોન';

  @override
  String get currency_DKK => 'ડેનિશ ક્રોન';

  @override
  String get currency_ZAR => 'દક્ષિણ આફ્રિકન રેન્ડ';

  @override
  String get currency_NPR => 'નેપાળી રૂપિયો';

  @override
  String get currency_BDT => 'બાંગ્લાદેશી ટાકા';

  @override
  String get currency_LKR => 'શ્રીલંકન રૂપિયો';
}
