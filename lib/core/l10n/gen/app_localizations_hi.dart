// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'DailyTrack';

  @override
  String get common_next => 'आगे';

  @override
  String get common_back => 'पीछे';

  @override
  String get common_skip => 'छोड़ें';

  @override
  String get common_retry => 'फिर से कोशिश करें';

  @override
  String get common_tryAgain => 'फिर से कोशिश करें';

  @override
  String get common_comingSoon => 'जल्द आ रहा है';

  @override
  String get common_placeholderMessage => 'आगे के अपडेट में आएगा';

  @override
  String get common_previousMonth => 'पिछला महीना';

  @override
  String get common_nextMonth => 'अगला महीना';

  @override
  String get common_undo => 'पहले जैसा करें';

  @override
  String get common_cancel => 'रद्द करें';

  @override
  String get keypad_backspace => 'मिटाएँ';

  @override
  String get keypad_done => 'हो गया';

  @override
  String get premium_lockedLabel => 'Pro फ़ीचर, लॉक है';

  @override
  String get nav_home => 'होम';

  @override
  String get nav_expenses => 'खर्च';

  @override
  String get nav_habits => 'आदतें';

  @override
  String get nav_more => 'और';

  @override
  String get splash_errorMessage =>
      'आपका डेटा नहीं खुल सका। फिर से कोशिश करें।';

  @override
  String get onboarding_welcomeTitle => 'पैसे और आदतों को एक ही जगह ट्रैक करें';

  @override
  String get onboarding_languageLabel => 'अपनी भाषा चुनें';

  @override
  String get onboarding_currencyTitle => 'अपनी मुद्रा चुनें';

  @override
  String get onboarding_currencySearchHint => 'मुद्रा खोजें';

  @override
  String get onboarding_noMatches => 'कोई मेल नहीं मिला';

  @override
  String get onboarding_clearSearch => 'खोज साफ़ करें';

  @override
  String get onboarding_modulesTitle => 'आप क्या ट्रैक करना चाहते हैं?';

  @override
  String get onboarding_atLeastOneModule => 'कम से कम एक ट्रैकर चालू रखें';

  @override
  String get onboarding_privacyTitle => 'आपका डेटा आपके पास रहता है';

  @override
  String get onboarding_privacyBody =>
      'आप जो भी दर्ज करते हैं, वह इसी फ़ोन पर रहता है। अगले कदम में आप Google से इसका बैकअप ले सकते हैं या मेहमान के रूप में जारी रख सकते हैं।';

  @override
  String get onboarding_allowNotifications => 'सूचनाएँ चालू करें';

  @override
  String get onboarding_notificationsGranted => 'सूचनाएँ चालू हैं';

  @override
  String get onboarding_notificationsDenied =>
      'सूचनाएँ बंद हैं। आप इन्हें बाद में सेटिंग्स में चालू कर सकते हैं।';

  @override
  String get onboarding_getStarted => 'शुरू करें';

  @override
  String get onboarding_saveError =>
      'आपकी पसंद सेव नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String onboarding_stepLabel(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get modules_title => 'मॉड्यूल';

  @override
  String get modules_expense => 'खर्च';

  @override
  String get modules_habit => 'आदत';

  @override
  String get modules_water => 'पानी';

  @override
  String get modules_period => 'पीरियड';

  @override
  String get modules_atLeastOne => 'कम से कम एक मॉड्यूल चालू रहना चाहिए';

  @override
  String get modules_errorMessage =>
      'आपके मॉड्यूल लोड या सेव नहीं हो सके। फिर से कोशिश करें।';

  @override
  String modules_reorderHandle(String name) {
    return '$name का क्रम बदलें';
  }

  @override
  String get more_modulesEntry => 'मॉड्यूल';

  @override
  String get lock_title => 'DailyTrack लॉक है';

  @override
  String get lock_placeholderMessage => 'अनलॉक आगे के अपडेट में आएगा';

  @override
  String get premium_watchAd => 'विज्ञापन देखें';

  @override
  String get premium_getPro => 'Pro लें';

  @override
  String get language_en => 'English';

  @override
  String get language_hi => 'हिन्दी';

  @override
  String get language_gu => 'ગુજરાતી';

  @override
  String get expense_cat_food => 'खाना';

  @override
  String get expense_cat_groceries => 'किराना';

  @override
  String get expense_cat_transport => 'यातायात';

  @override
  String get expense_cat_fuel => 'ईंधन';

  @override
  String get expense_cat_shopping => 'खरीदारी';

  @override
  String get expense_cat_bills => 'बिल';

  @override
  String get expense_cat_rent => 'किराया';

  @override
  String get expense_cat_health => 'स्वास्थ्य';

  @override
  String get expense_cat_education => 'शिक्षा';

  @override
  String get expense_cat_entertainment => 'मनोरंजन';

  @override
  String get expense_cat_travel => 'यात्रा';

  @override
  String get expense_cat_other => 'अन्य';

  @override
  String get income_cat_salary => 'वेतन';

  @override
  String get income_cat_business => 'व्यवसाय';

  @override
  String get income_cat_gift => 'उपहार';

  @override
  String get income_cat_interest => 'ब्याज';

  @override
  String get income_cat_other => 'अन्य आय';

  @override
  String get expense_account_cash => 'नकद';

  @override
  String get common_previousDay => 'पिछला दिन';

  @override
  String get common_nextDay => 'अगला दिन';

  @override
  String get common_previousWeek => 'पिछला हफ़्ता';

  @override
  String get common_nextWeek => 'अगला हफ़्ता';

  @override
  String get common_previousYear => 'पिछला साल';

  @override
  String get common_nextYear => 'अगला साल';

  @override
  String get common_today => 'आज';

  @override
  String get common_yesterday => 'कल';

  @override
  String get common_periodTitle => 'अवधि चुनें';

  @override
  String get common_periodDay => 'दिन';

  @override
  String get common_periodWeek => 'हफ़्ता';

  @override
  String get common_periodMonth => 'महीना';

  @override
  String get common_periodYear => 'साल';

  @override
  String get common_periodCustom => 'कस्टम अवधि';

  @override
  String get expense_typeExpense => 'खर्च';

  @override
  String get expense_typeIncome => 'आय';

  @override
  String get expense_typeTransfer => 'ट्रांसफ़र';

  @override
  String get expense_payCash => 'नकद';

  @override
  String get expense_payUpi => 'UPI';

  @override
  String get expense_payCard => 'कार्ड';

  @override
  String get expense_payNetBanking => 'नेट बैंकिंग';

  @override
  String get expense_payOther => 'अन्य';

  @override
  String get expense_accountTypeCash => 'नकद';

  @override
  String get expense_accountTypeBank => 'बैंक';

  @override
  String get expense_accountTypeUpi => 'UPI वॉलेट';

  @override
  String get expense_accountTypeCard => 'कार्ड';

  @override
  String get expense_accountTypeWallet => 'वॉलेट';

  @override
  String get expense_saved => 'सेव हो गया';

  @override
  String get expense_deleted => 'लेन-देन हटाया गया';

  @override
  String get expense_loadError =>
      'आपके लेन-देन लोड नहीं हो सके। फिर से कोशिश करें।';

  @override
  String get expense_saveError =>
      'सेव नहीं हो सका। आपके बदलाव यहीं हैं। फिर से कोशिश करें।';

  @override
  String get expense_spentToday => 'आज का खर्च';

  @override
  String get expense_thisMonth => 'इस महीने';

  @override
  String get expense_quickAdd => 'खर्च जोड़ें';

  @override
  String get expense_addTitle => 'लेन-देन जोड़ें';

  @override
  String get expense_editTitle => 'लेन-देन बदलें';

  @override
  String get expense_saveExpense => 'खर्च सेव करें';

  @override
  String get expense_saveIncome => 'आय सेव करें';

  @override
  String get expense_saveTransfer => 'ट्रांसफ़र सेव करें';

  @override
  String get expense_saveAndAddAnother => 'सेव करें और एक और जोड़ें';

  @override
  String expense_fromAccount(String account) {
    return '$account से';
  }

  @override
  String expense_toAccount(String account) {
    return '$account में';
  }

  @override
  String get expense_chooseToAccount => 'कहाँ भेजना है, चुनें';

  @override
  String get expense_account => 'खाता';

  @override
  String get expense_paymentMode => 'भुगतान का तरीका';

  @override
  String get expense_category => 'श्रेणी';

  @override
  String get expense_amount => 'राशि';

  @override
  String get expense_pickDate => 'तारीख चुनें';

  @override
  String get expense_pickTime => 'समय चुनें';

  @override
  String get expense_noteLabel => 'नोट (वैकल्पिक)';

  @override
  String expense_noteLimit(int count) {
    return '$count/200';
  }

  @override
  String get expense_attachReceipt => 'रसीद जोड़ें';

  @override
  String get expense_camera => 'कैमरा';

  @override
  String get expense_gallery => 'गैलरी';

  @override
  String get expense_removeReceipt => 'रसीद हटाएँ';

  @override
  String get expense_receiptError => 'फ़ोटो नहीं जुड़ सकी। फिर से कोशिश करें।';

  @override
  String get expense_newCategory => 'नई';

  @override
  String get expense_noCategories =>
      'अभी कोई श्रेणी नहीं है। जारी रखने के लिए एक जोड़ें';

  @override
  String get expense_discardTitle => 'बदलाव छोड़ दें?';

  @override
  String get expense_discardBody =>
      'इस लेन-देन में किए गए आपके बदलाव मिट जाएँगे।';

  @override
  String get expense_discardConfirm => 'छोड़ दें';

  @override
  String get expense_errAmountRequired => 'राशि डालें';

  @override
  String expense_errAmountTooLarge(String max) {
    return 'राशि ज़्यादा से ज़्यादा $max हो सकती है';
  }

  @override
  String get expense_errAmountInvalid => 'हिसाब जाँचें';

  @override
  String get expense_errCategoryRequired => 'श्रेणी चुनें';

  @override
  String get expense_errToAccountRequired => 'पैसे भेजने के लिए खाता चुनें';

  @override
  String get expense_errSameAccount => 'दो अलग-अलग खाते चुनें';

  @override
  String get expense_errNoteTooLong =>
      'नोट में ज़्यादा से ज़्यादा 200 अक्षर हो सकते हैं';

  @override
  String get expense_noLongerExists => 'यह लेन-देन अब मौजूद नहीं है';

  @override
  String get expense_deleteAction => 'लेन-देन हटाएँ';

  @override
  String get expense_listTitle => 'खर्च';

  @override
  String get expense_search => 'लेन-देन खोजें';

  @override
  String get expense_closeSearch => 'खोज बंद करें';

  @override
  String get expense_filter => 'फ़िल्टर';

  @override
  String get expense_menuCategories => 'श्रेणियाँ';

  @override
  String get expense_menuAccounts => 'खाते';

  @override
  String get expense_income => 'आय';

  @override
  String get expense_expense => 'खर्च';

  @override
  String get expense_net => 'शुद्ध';

  @override
  String expense_emptyPeriod(String period) {
    return '$period में कोई लेन-देन नहीं';
  }

  @override
  String get expense_addExpense => 'खर्च जोड़ें';

  @override
  String get expense_noMatches => 'कुछ नहीं मिला';

  @override
  String get expense_clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get expense_duplicate => 'कॉपी बनाएँ';

  @override
  String get expense_delete => 'हटाएँ';

  @override
  String expense_transferLabel(String from, String to) {
    return '$from → $to';
  }

  @override
  String get expense_detailTitle => 'लेन-देन';

  @override
  String get expense_edit => 'बदलें';

  @override
  String get expense_share => 'शेयर करें';

  @override
  String get expense_receipt => 'रसीद';

  @override
  String get expense_receiptMissing => 'रसीद उपलब्ध नहीं है';

  @override
  String get expense_close => 'बंद करें';

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
    return 'नोट: $note';
  }

  @override
  String get expense_filterTitle => 'लेन-देन फ़िल्टर करें';

  @override
  String get expense_filterType => 'प्रकार';

  @override
  String get expense_filterAmountMin => 'न्यूनतम राशि';

  @override
  String get expense_filterAmountMax => 'अधिकतम राशि';

  @override
  String get expense_applyFilters => 'फ़िल्टर लागू करें';

  @override
  String expense_removeFilter(String name) {
    return 'फ़िल्टर $name हटाएँ';
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
    return 'राशि: $amount';
  }

  @override
  String common_colorLabel(int index, int total) {
    return 'रंग $index / $total';
  }

  @override
  String get common_iconPicker => 'आइकन चुनें';

  @override
  String get common_colorPicker => 'रंग चुनें';

  @override
  String get expense_categoriesTitle => 'श्रेणियाँ';

  @override
  String get expense_newCategoryTitle => 'नई श्रेणी';

  @override
  String get expense_editCategoryTitle => 'श्रेणी बदलें';

  @override
  String get expense_hiddenSection => 'छिपी हुई';

  @override
  String get expense_hide => 'छिपाएँ';

  @override
  String get expense_unhide => 'फिर से दिखाएँ';

  @override
  String get expense_rename => 'नाम बदलें';

  @override
  String get expense_deleteCategory => 'श्रेणी हटाएँ';

  @override
  String get expense_categoryDeleted => 'श्रेणी हटाई गई';

  @override
  String get expense_categoryHidden => 'श्रेणी छिपाई गई';

  @override
  String get expense_categoryShown => 'श्रेणी फिर से दिख रही है';

  @override
  String get expense_moveTitle => 'नई श्रेणी चुनें';

  @override
  String expense_moveBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लेन-देन आपकी चुनी हुई श्रेणी में चले जाएँगे।',
      one: '1 लेन-देन आपकी चुनी हुई श्रेणी में चला जाएगा।',
    );
    return '$_temp0';
  }

  @override
  String get expense_moveConfirm => 'ले जाएँ और हटाएँ';

  @override
  String get expense_categoryName => 'नाम';

  @override
  String get expense_nameLimit => 'ज़्यादा से ज़्यादा 30 अक्षर';

  @override
  String get expense_errNameRequired => 'नाम डालें';

  @override
  String get expense_errNameTooLong =>
      'नाम में ज़्यादा से ज़्यादा 30 अक्षर हो सकते हैं';

  @override
  String get expense_errNameDuplicate => 'इस नाम की श्रेणी पहले से है';

  @override
  String get expense_errNameReserved => 'कोई दूसरा नाम चुनें';

  @override
  String get expense_icon => 'आइकन';

  @override
  String get expense_color => 'रंग';

  @override
  String get expense_type => 'प्रकार';

  @override
  String get expense_saveCategory => 'श्रेणी सेव करें';

  @override
  String expense_reorderHandle(String name) {
    return '$name को खींचकर क्रम बदलें';
  }

  @override
  String get expense_reorderError =>
      'नया क्रम सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get expense_noCategoriesHere => 'यहाँ अभी कोई श्रेणी नहीं है';

  @override
  String get expense_addCategory => 'श्रेणी जोड़ें';

  @override
  String get expense_loadDataError =>
      'यह स्क्रीन लोड नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get expense_accountsTitle => 'खाते';

  @override
  String get expense_newAccountTitle => 'नया खाता';

  @override
  String get expense_editAccountTitle => 'खाता बदलें';

  @override
  String get expense_totalBalance => 'कुल बैलेंस';

  @override
  String get expense_archivedSection => 'संग्रहीत';

  @override
  String get expense_archive => 'संग्रहीत करें';

  @override
  String get expense_unarchive => 'वापस लाएँ';

  @override
  String get expense_accountArchived => 'खाता संग्रहीत किया गया';

  @override
  String get expense_accountRestored => 'खाता वापस लाया गया';

  @override
  String get expense_deleteAccount => 'खाता हटाएँ';

  @override
  String get expense_accountDeleted => 'खाता हटाया गया';

  @override
  String get expense_lastAccountHelp => 'कम से कम एक सक्रिय खाता ज़रूरी है';

  @override
  String get expense_accountHasTransactions =>
      'जिन खातों में लेन-देन हैं, उन्हें हटाया नहीं, सिर्फ़ संग्रहीत किया जा सकता है';

  @override
  String get expense_accountName => 'नाम';

  @override
  String get expense_accountType => 'प्रकार';

  @override
  String get expense_openingBalance => 'शुरुआती बैलेंस';

  @override
  String get expense_balancePositive => 'पॉज़िटिव बैलेंस';

  @override
  String get expense_balanceNegative => 'नेगेटिव बैलेंस, जैसे कार्ड का बकाया';

  @override
  String get expense_saveAccount => 'खाता सेव करें';

  @override
  String get expense_errAccountNameRequired => 'नाम डालें';

  @override
  String get expense_errAccountNameTooLong =>
      'नाम में ज़्यादा से ज़्यादा 40 अक्षर हो सकते हैं';

  @override
  String expense_errBalanceRange(String min, String max) {
    return 'बैलेंस $min और $max के बीच होना चाहिए';
  }

  @override
  String get expense_addAccount => 'खाता जोड़ें';

  @override
  String get expense_noAccounts => 'अभी कोई खाता नहीं';

  @override
  String get expense_cardEmpty => 'अपना पहला खर्च जोड़ें';

  @override
  String get common_iconGroup_food => 'खाना';

  @override
  String get common_iconGroup_transport => 'यातायात';

  @override
  String get common_iconGroup_home => 'घर और बिल';

  @override
  String get common_iconGroup_shopping => 'खरीदारी';

  @override
  String get common_iconGroup_health => 'स्वास्थ्य';

  @override
  String get common_iconGroup_education => 'शिक्षा';

  @override
  String get common_iconGroup_leisure => 'मनोरंजन';

  @override
  String get common_iconGroup_travel => 'यात्रा';

  @override
  String get common_iconGroup_money => 'पैसा';

  @override
  String get common_iconGroup_other => 'अन्य';

  @override
  String get icon_restaurant => 'रेस्टोरेंट';

  @override
  String get icon_local_grocery_store => 'किराना';

  @override
  String get icon_local_cafe => 'कैफ़े';

  @override
  String get icon_fastfood => 'फ़ास्ट फ़ूड';

  @override
  String get icon_bakery_dining => 'बेकरी';

  @override
  String get icon_local_bar => 'पेय';

  @override
  String get icon_icecream => 'आइसक्रीम';

  @override
  String get icon_lunch_dining => 'भोजन';

  @override
  String get icon_directions_bus => 'बस';

  @override
  String get icon_local_gas_station => 'ईंधन';

  @override
  String get icon_directions_car => 'कार';

  @override
  String get icon_two_wheeler => 'दोपहिया';

  @override
  String get icon_local_taxi => 'टैक्सी';

  @override
  String get icon_train => 'ट्रेन';

  @override
  String get icon_electric_rickshaw => 'ऑटो रिक्शा';

  @override
  String get icon_local_parking => 'पार्किंग';

  @override
  String get icon_home => 'घर';

  @override
  String get icon_receipt => 'बिल';

  @override
  String get icon_bolt => 'बिजली';

  @override
  String get icon_water_drop => 'पानी';

  @override
  String get icon_wifi => 'इंटरनेट';

  @override
  String get icon_phone_android => 'मोबाइल';

  @override
  String get icon_build => 'मरम्मत';

  @override
  String get icon_cleaning_services => 'सफ़ाई';

  @override
  String get icon_shopping_bag => 'खरीदारी';

  @override
  String get icon_shopping_cart => 'कार्ट';

  @override
  String get icon_checkroom => 'कपड़े';

  @override
  String get icon_devices => 'इलेक्ट्रॉनिक्स';

  @override
  String get icon_chair => 'फ़र्नीचर';

  @override
  String get icon_redeem => 'उपहार';

  @override
  String get icon_local_florist => 'फूल';

  @override
  String get icon_pets => 'पालतू जानवर';

  @override
  String get icon_medical_services => 'चिकित्सा';

  @override
  String get icon_local_pharmacy => 'दवा की दुकान';

  @override
  String get icon_fitness_center => 'फ़िटनेस';

  @override
  String get icon_spa => 'सेल्फ़-केयर';

  @override
  String get icon_favorite => 'सेहत';

  @override
  String get icon_child_care => 'बच्चों की देखभाल';

  @override
  String get icon_school => 'स्कूल';

  @override
  String get icon_menu_book => 'किताबें';

  @override
  String get icon_computer => 'कंप्यूटर';

  @override
  String get icon_science => 'विज्ञान';

  @override
  String get icon_edit => 'स्टेशनरी';

  @override
  String get icon_movie => 'फ़िल्में';

  @override
  String get icon_sports_esports => 'गेम्स';

  @override
  String get icon_music_note => 'संगीत';

  @override
  String get icon_sports_cricket => 'क्रिकेट';

  @override
  String get icon_celebration => 'उत्सव';

  @override
  String get icon_theater_comedy => 'कार्यक्रम';

  @override
  String get icon_subscriptions => 'सदस्यता';

  @override
  String get icon_flight => 'उड़ान';

  @override
  String get icon_hotel => 'होटल';

  @override
  String get icon_luggage => 'सामान';

  @override
  String get icon_beach_access => 'छुट्टी';

  @override
  String get icon_map => 'यात्रा';

  @override
  String get icon_payments => 'वेतन';

  @override
  String get icon_storefront => 'व्यवसाय';

  @override
  String get icon_savings => 'बचत';

  @override
  String get icon_attach_money => 'पैसा';

  @override
  String get icon_account_balance => 'बैंक';

  @override
  String get icon_credit_card => 'क्रेडिट कार्ड';

  @override
  String get icon_wallet => 'वॉलेट';

  @override
  String get icon_currency_rupee => 'रुपया';

  @override
  String get icon_trending_up => 'निवेश';

  @override
  String get icon_request_quote => 'कर';

  @override
  String get icon_volunteer_activism => 'दान';

  @override
  String get icon_work => 'काम';

  @override
  String get icon_category => 'श्रेणी';

  @override
  String get icon_star => 'तारा';

  @override
  String get icon_label => 'लेबल';

  @override
  String get icon_more_horiz => 'अन्य';

  @override
  String get expense_menuBudgets => 'बजट';

  @override
  String get expense_budgetsTitle => 'बजट';

  @override
  String get expense_budgetOverall => 'कुल';

  @override
  String get expense_budgetCategoryBudgets => 'श्रेणी बजट';

  @override
  String get expense_budgetWithoutBudget => 'बिना बजट वाली श्रेणियाँ';

  @override
  String get expense_budgetSet => 'बजट तय करें';

  @override
  String get expense_budgetSetMonthly => 'मासिक बजट तय करें';

  @override
  String get expense_budgetCopyLastMonth => 'पिछले महीने के बजट कॉपी करें';

  @override
  String expense_budgetCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बजट कॉपी किए गए',
      one: '1 बजट कॉपी किया गया',
      zero: 'कॉपी करने को कुछ नहीं है',
    );
    return '$_temp0';
  }

  @override
  String expense_budgetPerDayLeft(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों के लिए रोज़ $amount बाकी',
      one: '1 दिन के लिए रोज़ $amount बाकी',
    );
    return '$_temp0';
  }

  @override
  String get expense_budgetNoneLeft => 'इस महीने कोई बजट नहीं बचा';

  @override
  String expense_budgetUnderBy(String amount) {
    return 'बजट से $amount कम खर्च';
  }

  @override
  String expense_budgetOverBy(String amount) {
    return 'बजट से $amount ज़्यादा खर्च';
  }

  @override
  String expense_budgetFuturePerDay(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों के लिए रोज़ $amount',
      one: '1 दिन के लिए रोज़ $amount',
    );
    return '$_temp0';
  }

  @override
  String expense_budgetLeft(String amount) {
    return '$amount बाकी';
  }

  @override
  String expense_budgetSpentOfLimit(String spent, String limit) {
    return '$limit में से $spent';
  }

  @override
  String get expense_budgetLevelUnder => 'सही राह पर';

  @override
  String get expense_budgetLevelWarning => 'लगभग खत्म';

  @override
  String get expense_budgetLevelOver => 'बजट से ज़्यादा';

  @override
  String expense_budgetLevelLine(String level, int percent) {
    return '$level · $percent% इस्तेमाल हुआ';
  }

  @override
  String get expense_budgetEmptyTitle => 'अपने महीने की योजना बनाएँ';

  @override
  String get expense_budgetEmptyBody =>
      'मासिक बजट तय करें और देखें कि आप हर दिन और कितना खर्च कर सकते हैं।';

  @override
  String get expense_budgetRepeatMonthly => 'हर महीने दोहराएँ';

  @override
  String get expense_budgetDelete => 'बजट हटाएँ';

  @override
  String get expense_budgetDeleted => 'बजट हटाया गया';

  @override
  String get expense_budgetRestoreFailed =>
      'बजट वापस नहीं लाया जा सका क्योंकि एक बजट पहले से तय है।';

  @override
  String get expense_budgetSlotTaken => 'इस श्रेणी का इस महीने पहले से बजट है।';

  @override
  String get expense_budgetHidden => 'छिपी हुई';

  @override
  String get expense_budgetAmountMissing => 'राशि दर्ज करें';

  @override
  String get expense_budgetAmountTooLarge => 'राशि बहुत ज़्यादा है';

  @override
  String get expense_budgetSetOverallPrompt => 'कुल बजट तय करें';

  @override
  String get notif_channelBudgetAlerts => 'बजट अलर्ट';

  @override
  String get notif_channelBudgetAlertsDescription =>
      'जब कोई बजट 80% या 100% तक पहुँचे';

  @override
  String notif_budget80Title(String category, int percent) {
    return '$category बजट $percent% पर';
  }

  @override
  String notif_budget80Body(String category, int percent) {
    return 'आपने इस महीने अपने $category बजट का $percent% इस्तेमाल कर लिया है।';
  }

  @override
  String notif_budget100Title(String category) {
    return '$category बजट खत्म हो गया';
  }

  @override
  String notif_budget100Body(String category, int percent) {
    return 'आपने इस महीने अपने $category बजट का $percent% इस्तेमाल कर लिया है।';
  }

  @override
  String get notif_overallBudget => 'कुल';

  @override
  String get expense_menuRecurring => 'आवर्ती';

  @override
  String get expense_repeat => 'दोहराएँ';

  @override
  String get expense_freqDaily => 'रोज़';

  @override
  String get expense_freqWeekly => 'हर हफ़्ते';

  @override
  String get expense_freqMonthly => 'हर महीने';

  @override
  String get expense_freqYearly => 'हर साल';

  @override
  String get expense_repeatEndDate => 'समाप्ति तिथि (वैकल्पिक)';

  @override
  String expense_repeatEndsOn(String date) {
    return '$date को समाप्त';
  }

  @override
  String get expense_repeatClearEnd => 'समाप्ति तिथि हटाएँ';

  @override
  String get expense_repeatEndBeforeStart =>
      'समाप्ति तिथि पहली तिथि से पहले नहीं हो सकती';

  @override
  String get expense_everyDay => 'हर दिन';

  @override
  String expense_everyWeekOn(String weekday) {
    return 'हर हफ़्ते $weekday को';
  }

  @override
  String expense_everyMonthOn(int day, String suffix) {
    return 'हर महीने की $day तारीख को';
  }

  @override
  String expense_everyYearOn(String date) {
    return 'हर साल $date को';
  }

  @override
  String get expense_recurringTitle => 'आवर्ती लेन-देन';

  @override
  String get expense_recurringPaused => 'रुका हुआ';

  @override
  String expense_recurringNext(String date) {
    return 'अगला: $date';
  }

  @override
  String expense_recurringEnded(String date) {
    return '$date को समाप्त';
  }

  @override
  String get expense_recurringPause => 'रोकें';

  @override
  String get expense_recurringResume => 'फिर शुरू करें';

  @override
  String get expense_recurringDelete => 'हटाएँ';

  @override
  String get expense_recurringDeleted => 'आवर्ती लेन-देन हटाया गया';

  @override
  String get expense_recurringAdd => 'आवर्ती लेन-देन जोड़ें';

  @override
  String get expense_recurringEmptyTitle => 'अभी कुछ भी दोहराया नहीं जाता';

  @override
  String get expense_recurringEmptyBody =>
      'किराया, वेतन या बिल एक बार जोड़ें, फिर वे अपने-आप दर्ज होंगे।';

  @override
  String get expense_recurringStaleAccount => 'खाता संग्रहित है';

  @override
  String get expense_recurringStaleCategory => 'श्रेणी छिपी हुई है';

  @override
  String get expense_ruleEditTitle => 'आवर्ती लेन-देन बदलें';

  @override
  String get expense_nextDate => 'अगली तिथि';

  @override
  String get expense_createdFromRule => 'आवर्ती नियम से बनाया गया';

  @override
  String get expense_ruleDeleted => 'आवर्ती नियम हटाया गया';

  @override
  String get expense_recurringLabel => 'आवर्ती';

  @override
  String get expense_menuReports => 'रिपोर्ट';

  @override
  String get premium_advancedReportsMessage =>
      'एडवांस रिपोर्ट Pro का हिस्सा हैं।';

  @override
  String get premium_lockedPeriod => 'लॉक है';

  @override
  String get more_developerSection => 'डेवलपर';

  @override
  String get more_debugUnlockAll => 'सभी फ़ीचर अनलॉक करें (डीबग)';

  @override
  String get expense_reportsTitle => 'रिपोर्ट';

  @override
  String get expense_reportTabOverview => 'सारांश';

  @override
  String get expense_reportTabCategories => 'श्रेणियाँ';

  @override
  String get expense_reportTabTrends => 'रुझान';

  @override
  String get expense_reportTabAccounts => 'खाते';

  @override
  String expense_reportLockedTab(String tab) {
    return '$tab, लॉक है';
  }

  @override
  String get expense_reportNetSavings => 'शुद्ध बचत';

  @override
  String get expense_reportSavingsRate => 'बचत दर';

  @override
  String expense_reportSavingsRateValue(int percent) {
    return '$percent%';
  }

  @override
  String get expense_reportNoValue => '—';

  @override
  String get expense_reportAvgDaily => 'औसत दैनिक खर्च';

  @override
  String get expense_reportTopCategories => 'शीर्ष श्रेणियाँ';

  @override
  String get expense_reportIncomeVsExpense => 'आय बनाम खर्च';

  @override
  String expense_reportShare(int percent) {
    return 'खर्च का $percent%';
  }

  @override
  String get expense_reportOther => 'अन्य';

  @override
  String get expense_reportTotalSpent => 'कुल खर्च';

  @override
  String expense_reportChartSummaryDonut(String items) {
    return 'श्रेणी के अनुसार खर्च: $items';
  }

  @override
  String expense_reportChartSummaryItem(String name, int percent) {
    return '$name $percent%';
  }

  @override
  String expense_reportChartSummaryBar(String income, String expense) {
    return 'आय $income, खर्च $expense';
  }

  @override
  String expense_reportEmpty(String period) {
    return '$period में कोई लेन-देन नहीं';
  }

  @override
  String get expense_reportThisPeriod => 'यह अवधि';

  @override
  String get expense_reportPreviousPeriod => 'पिछली अवधि';

  @override
  String get expense_reportByAccount => 'खाते के अनुसार';

  @override
  String get expense_reportByPaymentMode => 'भुगतान के तरीके के अनुसार';

  @override
  String expense_reportChartSummaryTrend(String current, String previous) {
    return 'इस अवधि का खर्च $current, पिछली अवधि $previous';
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
  String get notif_channelHabitReminders => 'आदत रिमाइंडर';

  @override
  String get notif_channelHabitRemindersDescription => 'आपकी आदतों के रिमाइंडर';

  @override
  String get habit_title => 'आदतें';

  @override
  String get habit_quickAddCheckIn => 'आदत चेक-इन करें';

  @override
  String habit_streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String habit_streakWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हफ़्ते',
      one: '1 हफ़्ता',
    );
    return '$_temp0';
  }

  @override
  String habit_doneOfTotal(int done, int total) {
    return '$total में से $done पूरी';
  }

  @override
  String get habit_undo => 'पहले जैसा करें';

  @override
  String get habit_loadError =>
      'आपकी आदतें लोड नहीं हो सकीं। फिर से कोशिश करें।';

  @override
  String get habit_saveError => 'सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get habit_menuArchived => 'संग्रहित आदतें';

  @override
  String get habit_menuReorder => 'क्रम बदलें';

  @override
  String get habit_reorderDone => 'हो गया';

  @override
  String habit_reorderHandle(String name) {
    return '$name का क्रम बदलें';
  }

  @override
  String get habit_moreOptions => 'और विकल्प';

  @override
  String get habit_addHabit => 'आदत जोड़ें';

  @override
  String get habit_emptyTitle => 'अपनी पहली आदत बनाएँ';

  @override
  String get habit_emptyBody =>
      'किसी टेम्पलेट से शुरू करें या अपनी आदत बनाने के लिए + दबाएँ।';

  @override
  String get habit_notScheduledToday => 'आज के लिए नहीं';

  @override
  String get habit_notScheduledOnDay => 'इस दिन के लिए नहीं';

  @override
  String get habit_allDone => 'आज के सारे काम पूरे';

  @override
  String get habit_noneScheduled => 'इस दिन कुछ तय नहीं है';

  @override
  String get habit_menuEdit => 'बदलें';

  @override
  String get habit_menuAddNote => 'आज के लिए नोट जोड़ें';

  @override
  String get habit_menuAddNoteDay => 'इस दिन के लिए नोट जोड़ें';

  @override
  String get habit_menuSkipToday => 'आज छोड़ें';

  @override
  String habit_skipTodayHint(int count) {
    return 'आपके $count फ़्रीज़ में से 1 इस्तेमाल होगा';
  }

  @override
  String get habit_noFreezesLeft => 'कोई फ़्रीज़ बाकी नहीं';

  @override
  String get habit_menuArchive => 'संग्रहित करें';

  @override
  String get habit_archived => 'आदत संग्रहित की गई';

  @override
  String get habit_unchecked => 'चेक-इन हटाया गया';

  @override
  String get habit_skipped => 'फ़्रीज़ से आज छोड़ा गया';

  @override
  String get habit_olderEditsHint => 'पुराने दिन आदत के पेज से बदलें';

  @override
  String get habit_futureDayHint =>
      'आने वाले दिनों में अभी चेक-इन नहीं हो सकता';

  @override
  String habit_dayRingLabel(String day, int done, int total) {
    return '$day, $total में से $done पूरी';
  }

  @override
  String habit_dayRingNone(String day) {
    return '$day, कुछ तय नहीं';
  }

  @override
  String habit_valueEntryTitle(String name) {
    return '$name के लिए मान लिखें';
  }

  @override
  String get habit_valueEntryHint => '0 से 9,999 तक की पूरी संख्या';

  @override
  String get habit_valueEntryError => '0 से 9,999 तक की पूरी संख्या लिखें';

  @override
  String get habit_set => 'सेट करें';

  @override
  String habit_markDoneLabel(String name) {
    return '$name को पूरा करें';
  }

  @override
  String habit_markNotDoneLabel(String name) {
    return '$name को अधूरा करें';
  }

  @override
  String habit_addOneLabel(String name) {
    return '$name में 1 जोड़ें';
  }

  @override
  String habit_countLabel(String name, int value, int target, String unit) {
    return '$name, $target $unit में से $value';
  }

  @override
  String habit_countLabelNoUnit(String name, int value, int target) {
    return '$name, $target में से $value';
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
    return 'मौजूदा सिलसिला: $streak';
  }

  @override
  String get habit_statusDone => 'पूरी';

  @override
  String get habit_statusFreeze => 'फ़्रीज़ दिन';

  @override
  String get habit_scheduleDaily => 'रोज़';

  @override
  String habit_scheduleTimesPerWeek(int times, int left) {
    return 'हफ़्ते में $times× · $left बाकी';
  }

  @override
  String habit_scheduleTimesPerWeekMet(int times) {
    return 'हफ़्ते में $times× · पूरा';
  }

  @override
  String get habit_noteTitle => 'नोट';

  @override
  String get habit_noteHint => 'नोट जोड़ें';

  @override
  String get habit_noteSave => 'नोट सेव करें';

  @override
  String get habit_noteSaved => 'नोट सेव हुआ';

  @override
  String get habit_detailTitle => 'आदत';

  @override
  String get habit_template_drinkWater => 'पानी पिएँ';

  @override
  String get habit_template_read => 'पढ़ें';

  @override
  String get habit_template_walk => 'टहलें';

  @override
  String get habit_template_meditate => 'ध्यान करें';

  @override
  String get habit_template_wakeUpEarly => 'जल्दी उठें';

  @override
  String get habit_template_study => 'पढ़ाई करें';

  @override
  String get habit_unit_glasses => 'गिलास';

  @override
  String get habit_unit_pages => 'पेज';

  @override
  String get habit_unit_minutes => 'मिनट';

  @override
  String get habit_addTitle => 'नई आदत';

  @override
  String get habit_editTitle => 'आदत बदलें';

  @override
  String get habit_nameLabel => 'नाम';

  @override
  String get habit_nameSuggestions => 'सुझाव';

  @override
  String get habit_iconLabel => 'आइकन';

  @override
  String get habit_colorLabel => 'रंग';

  @override
  String get habit_goalLabel => 'लक्ष्य का प्रकार';

  @override
  String get habit_goalYesNo => 'हाँ / नहीं';

  @override
  String get habit_goalCount => 'गिनती';

  @override
  String get habit_goalLocked =>
      'आदत बनने के बाद लक्ष्य का प्रकार नहीं बदला जा सकता';

  @override
  String get habit_targetLabel => 'लक्ष्य';

  @override
  String get habit_unitLabel => 'इकाई (वैकल्पिक)';

  @override
  String get habit_scheduleLabel => 'समय-सारणी';

  @override
  String get habit_scheduleEveryDay => 'हर दिन';

  @override
  String get habit_scheduleSpecificDays => 'चुने हुए दिन';

  @override
  String get habit_scheduleXTimes => 'हफ़्ते में X बार';

  @override
  String habit_timesPerWeekValue(int count) {
    return 'हफ़्ते में $count×';
  }

  @override
  String get habit_decrease => 'घटाएँ';

  @override
  String get habit_increase => 'बढ़ाएँ';

  @override
  String get habit_startDate => 'शुरू होने की तारीख';

  @override
  String get habit_pickDate => 'तारीख चुनें';

  @override
  String get habit_save => 'आदत सेव करें';

  @override
  String get habit_saved => 'आदत सेव हुई';

  @override
  String get habit_errNameRequired => 'नाम लिखें';

  @override
  String get habit_errNameTooLong => 'ज़्यादा से ज़्यादा 40 अक्षर लिखें';

  @override
  String get habit_errTargetRange => '1 से 9,999 तक का लक्ष्य लिखें';

  @override
  String get habit_errUnitTooLong => 'ज़्यादा से ज़्यादा 20 अक्षर लिखें';

  @override
  String get habit_errWeekdayRequired => 'कम से कम एक दिन चुनें';

  @override
  String get habit_errTimesRange => 'हफ़्ते में 1 से 6 बार चुनें';

  @override
  String get habit_deleteAction => 'हटाएँ';

  @override
  String get habit_deleteTitle => 'आदत हटाएँ?';

  @override
  String habit_deleteBody(String name) {
    return 'इससे $name और उसका पूरा इतिहास हट जाएगा।';
  }

  @override
  String get habit_deleteConfirm => 'आदत हटाएँ';

  @override
  String get habit_deleted => 'आदत हटाई गई';

  @override
  String get habit_discardTitle => 'बदलाव छोड़ दें?';

  @override
  String get habit_discardBody => 'इस आदत में किए बदलाव खो जाएँगे।';

  @override
  String get habit_discardConfirm => 'छोड़ दें';

  @override
  String get habit_notFound => 'यह आदत अब मौजूद नहीं है';

  @override
  String get habit_reminders => 'रिमाइंडर';

  @override
  String get habit_addReminder => 'रिमाइंडर जोड़ें';

  @override
  String habit_removeReminder(String time) {
    return '$time का रिमाइंडर हटाएँ';
  }

  @override
  String get habit_remindOnlyIfNotDone => 'तभी याद दिलाएँ जब काम बाकी हो';

  @override
  String get habit_reminderLimit =>
      'आप ज़्यादा से ज़्यादा 3 रिमाइंडर जोड़ सकते हैं';

  @override
  String get habit_reminderDuplicate => 'यह समय पहले से जोड़ा गया है';

  @override
  String get habit_notificationsOffHint =>
      'रिमाइंडर के लिए सूचना की अनुमति चाहिए';

  @override
  String get habit_inexactHint => 'रिमाइंडर कुछ मिनट देर से आ सकते हैं';

  @override
  String notif_habitReminderTitle(String name) {
    return '$name';
  }

  @override
  String notif_habitReminderBody(String name) {
    return '$name का समय हो गया। आप कर सकते हैं।';
  }

  @override
  String habit_milestoneTitleDays(int count) {
    return '$count दिन का सिलसिला!';
  }

  @override
  String habit_milestoneTitleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हफ़्तों का सिलसिला!',
      one: '1 हफ़्ते का सिलसिला!',
    );
    return '$_temp0';
  }

  @override
  String get habit_milestoneBody =>
      'हर चेक-इन मायने रखता है। ऐसे ही जारी रखें!';

  @override
  String get habit_shareStreak => 'सिलसिला शेयर करें';

  @override
  String get habit_close => 'बंद करें';

  @override
  String get habit_shareCardFooter => 'DailyTrack के साथ ट्रैक किया';

  @override
  String get habit_shareError => 'शेयर नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get common_iconGroup_habits => 'आदतें';

  @override
  String get icon_directions_walk => 'टहलना';

  @override
  String get icon_directions_run => 'दौड़ना';

  @override
  String get icon_self_improvement => 'ध्यान';

  @override
  String get icon_alarm => 'अलार्म';

  @override
  String get icon_bedtime => 'नींद';

  @override
  String get habit_statCurrent => 'मौजूदा सिलसिला';

  @override
  String get habit_statBest => 'सबसे लंबा सिलसिला';

  @override
  String get habit_statRate => 'पूरा होने की दर (पिछले 30 दिन)';

  @override
  String get habit_statTotal => 'कुल पूरे किए';

  @override
  String habit_rateValue(int percent) {
    return '$percent%';
  }

  @override
  String get habit_rateNone => '—';

  @override
  String get habit_calendarTitle => 'कैलेंडर';

  @override
  String habit_dayDone(String date) {
    return '$date, पूरा';
  }

  @override
  String habit_dayPartial(String date, int value, int target) {
    return '$date, $target में से $value';
  }

  @override
  String habit_dayMissed(String date) {
    return '$date, छूट गया';
  }

  @override
  String habit_dayFreeze(String date) {
    return '$date, फ़्रीज़ दिन';
  }

  @override
  String habit_dayOther(String date) {
    return '$date';
  }

  @override
  String get habit_dayHasNote => 'नोट है';

  @override
  String get habit_heatmapTitle => 'पिछले 12 महीने';

  @override
  String habit_heatmapSummary(int done, int total) {
    return 'पिछले 12 महीनों में $total में से $done दिन पूरे';
  }

  @override
  String habit_heatmapMonth(String month, int done, int total) {
    return '$month: $total में से $done दिन पूरे';
  }

  @override
  String get habit_shareHeatmap => 'शेयर करें';

  @override
  String get habit_weeklyChartTitle => 'हर हफ़्ते पूरे किए';

  @override
  String habit_weeklyChartSummary(String items) {
    return 'पिछले 12 हफ़्तों में पूरे किए: $items';
  }

  @override
  String habit_weeklyChartItem(String date, int count) {
    return '$date वाला हफ़्ता $count';
  }

  @override
  String get habit_notesTitle => 'नोट';

  @override
  String get habit_notesEmpty => 'अभी कोई नोट नहीं';

  @override
  String get habit_freezeTitle => 'सिलसिला फ़्रीज़';

  @override
  String habit_freezesAvailable(int count) {
    return 'उपलब्ध फ़्रीज़: $count';
  }

  @override
  String get habit_freezeExplain =>
      'फ़्रीज़ किसी दिन चूकने पर भी सिलसिला बनाए रखता है। इसे 3 दिन पहले तक के छूटे दिन पर इस्तेमाल करें।';

  @override
  String get habit_useFreeze => 'फ़्रीज़ इस्तेमाल करें';

  @override
  String habit_useFreezeOn(String date) {
    return '$date पर फ़्रीज़ इस्तेमाल करें';
  }

  @override
  String get habit_noFreezeableDay => 'पिछले 3 दिनों में कोई दिन नहीं छूटा';

  @override
  String get habit_freezeUsed => 'फ़्रीज़ इस्तेमाल हुआ';

  @override
  String get habit_addFreezeDebug => 'फ़्रीज़ जोड़ें (डीबग)';

  @override
  String get habit_freezeCapReached =>
      'आप ज़्यादा से ज़्यादा 2 फ़्रीज़ रख सकते हैं';

  @override
  String habit_editDayTitle(String date) {
    return '$date बदलें';
  }

  @override
  String get habit_dayDoneToggle => 'पूरा';

  @override
  String get habit_dayValueLabel => 'मान';

  @override
  String get habit_daySave => 'सेव करें';

  @override
  String get habit_daySaved => 'दिन सेव हुआ';

  @override
  String get habit_edit => 'बदलें';

  @override
  String get habit_previousMonth => 'पिछला महीना';

  @override
  String get habit_nextMonth => 'अगला महीना';

  @override
  String get habit_archivedTitle => 'संग्रहित आदतें';

  @override
  String habit_archivedOn(String date) {
    return '$date को संग्रहित';
  }

  @override
  String habit_bestStreakLabel(String streak) {
    return 'सबसे लंबा सिलसिला: $streak';
  }

  @override
  String get habit_restore => 'वापस लाएँ';

  @override
  String get habit_restored => 'आदत वापस आई';

  @override
  String get habit_deletePermanently => 'हमेशा के लिए हटाएँ';

  @override
  String get habit_archivedEmpty => 'संग्रहित आदतें यहाँ दिखेंगी';

  @override
  String habit_doneTodayRing(int done, int total) {
    return 'आज $total में से $done पूरी';
  }

  @override
  String get habit_cardEmpty => 'अपनी पहली आदत बनाएँ';

  @override
  String get habit_cardNoneToday => 'आज कुछ तय नहीं';

  @override
  String get habit_addOne => '+1';

  @override
  String get habit_customValue => 'मान लिखें';

  @override
  String get habit_loadDataError => 'आदतें लोड नहीं हो सकीं';

  @override
  String get home_greetingMorning => 'सुप्रभात';

  @override
  String get home_greetingAfternoon => 'शुभ दोपहर';

  @override
  String get home_greetingEvening => 'शुभ संध्या';

  @override
  String get home_quickAddTooltip => 'जल्दी जोड़ें';

  @override
  String get home_insightTitle => 'आज की सलाह';

  @override
  String get home_insightStarter => 'आज कुछ दर्ज करें, सलाह यहाँ दिखेगी';

  @override
  String get home_comingSoonTitle => 'जल्द आ रहा है';

  @override
  String home_comingSoonBody(String names) {
    return '$names ट्रैकर जल्द आ रहे हैं';
  }

  @override
  String home_listPair(String first, String second) {
    return '$first और $second';
  }

  @override
  String get home_comingSoonDismiss => 'हटाएँ';

  @override
  String get home_comingSoonDismissed => 'कार्ड छिपाया गया';

  @override
  String get home_recentTitle => 'हाल के लेन-देन';

  @override
  String get home_seeAll => 'सभी देखें';

  @override
  String get expense_quickAddIncome => 'आय जोड़ें';

  @override
  String get expense_cardAdd => 'खर्च';

  @override
  String get expense_cardSetBudget => 'बजट सेट करें';

  @override
  String expense_cardMonthOfBudget(String spent, String limit) {
    return '$limit में से $spent';
  }

  @override
  String expense_insightCategoryHigher(String category, int percent) {
    return '$category पर खर्च पिछले महीने से $percent% ज़्यादा है';
  }

  @override
  String expense_insightCategoryLower(String category, int percent) {
    return '$category पर खर्च पिछले महीने से $percent% कम है। बहुत बढ़िया।';
  }

  @override
  String expense_insightBudgetOnTrack(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों के लिए $amount बाकी',
      one: '1 दिन के लिए $amount बाकी',
    );
    return 'आप सही राह पर हैं: $_temp0';
  }

  @override
  String expense_insightBudgetNear(int percent) {
    return 'आपने इस महीने के बजट का $percent% इस्तेमाल कर लिया है';
  }

  @override
  String expense_insightBudgetOver(String amount) {
    return 'आप इस महीने के बजट से $amount ऊपर हैं। एक बिना खर्च वाला दिन मदद करेगा।';
  }

  @override
  String expense_insightOpensReports(String text) {
    return 'रिपोर्ट खुलेगी: $text';
  }

  @override
  String expense_insightOpensBudgets(String text) {
    return 'बजट खुलेगा: $text';
  }

  @override
  String habit_insightNextMilestoneDays(int count, int milestone, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$name के साथ $milestone दिन के सिलसिले से आप $_temp0 दूर हैं';
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
      other: '$count हफ़्ते',
      one: '1 हफ़्ता',
    );
    return '$name के साथ $milestone हफ़्ते के सिलसिले से आप $_temp0 दूर हैं';
  }

  @override
  String habit_insightBestThisWeek(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार',
      one: '1 बार',
    );
    return 'इस हफ़्ते आपने $name $_temp0 किया';
  }

  @override
  String habit_insightComebackDays(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best दिन',
      one: '1 दिन',
    );
    return 'आज फिर से $name शुरू करें। आपका सबसे अच्छा सिलसिला $_temp0 है।';
  }

  @override
  String habit_insightComebackWeeks(String name, int best) {
    String _temp0 = intl.Intl.pluralLogic(
      best,
      locale: localeName,
      other: '$best हफ़्ते',
      one: '1 हफ़्ता',
    );
    return 'आज फिर से $name शुरू करें। आपका सबसे अच्छा सिलसिला $_temp0 है।';
  }

  @override
  String habit_insightOpensHabit(String text, String name) {
    return '$name खुलेगा: $text';
  }

  @override
  String habit_streakBadgeLabelDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return 'सबसे अच्छा चालू सिलसिला: $_temp0';
  }

  @override
  String habit_streakBadgeLabelWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हफ़्ते',
      one: '1 हफ़्ता',
    );
    return 'सबसे अच्छा चालू सिलसिला: $_temp0';
  }

  @override
  String habit_streakBadgeWeeksShort(int count) {
    return '$count हफ़्ते';
  }

  @override
  String habit_uncheckedSnack(String name) {
    return '$name से निशान हटाया गया';
  }

  @override
  String get modules_moveUp => 'ऊपर ले जाएँ';

  @override
  String get modules_moveDown => 'नीचे ले जाएँ';

  @override
  String get settings_general => 'सामान्य';

  @override
  String get settings_appearance => 'रूप-रंग';

  @override
  String get settings_modules => 'मॉड्यूल';

  @override
  String get settings_notifications => 'सूचनाएँ';

  @override
  String get settings_privacy => 'निजता';

  @override
  String get settings_about => 'ऐप के बारे में';

  @override
  String get settings_loadError => 'आपकी सेटिंग्स लोड नहीं हो सकीं।';

  @override
  String get settings_language => 'भाषा';

  @override
  String get settings_languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get settings_currency => 'मुद्रा';

  @override
  String get settings_firstDayOfWeek => 'हफ़्ते का पहला दिन';

  @override
  String get settings_monday => 'सोमवार';

  @override
  String get settings_saturday => 'शनिवार';

  @override
  String get settings_sunday => 'रविवार';

  @override
  String get settings_dateFormat => 'तारीख का फ़ॉर्मैट';

  @override
  String get settings_themeEntry => 'थीम और रंग';

  @override
  String get settings_modulesEntry => 'ट्रैकर चालू करें या क्रम बदलें';

  @override
  String get settings_notificationsMaster => 'सूचनाएँ';

  @override
  String get settings_dailySummaryTime => 'रोज़ के सारांश का समय';

  @override
  String get settings_dailySummaryHelp => 'क्या आपने आज के खर्च दर्ज किए?';

  @override
  String get settings_budgetAlerts => 'बजट अलर्ट';

  @override
  String get settings_habitReminders => 'आदत रिमाइंडर';

  @override
  String get settings_notificationsBlocked =>
      'DailyTrack के लिए सूचनाएँ बंद हैं';

  @override
  String get settings_openSystemSettings => 'सेटिंग्स खोलें';

  @override
  String get settings_privacyPolicy => 'निजता नीति';

  @override
  String get settings_terms => 'शर्तें';

  @override
  String get settings_rateUs => 'हमें रेटिंग दें';

  @override
  String get settings_shareApp => 'ऐप शेयर करें';

  @override
  String settings_shareAppText(String url) {
    return 'मैं DailyTrack से अपने पैसे और आदतें ट्रैक करता/करती हूँ: $url';
  }

  @override
  String get settings_sendFeedback => 'सुझाव भेजें';

  @override
  String settings_feedbackSubject(String version) {
    return 'DailyTrack सुझाव ($version)';
  }

  @override
  String settings_feedbackBody(
    String version,
    String build,
    String device,
    String android,
    String language,
  ) {
    return 'अपना सुझाव इस लाइन के ऊपर लिखें।\n\nऐप वर्शन: $version ($build)\nडिवाइस: $device\nAndroid: $android\nडिवाइस की भाषा: $language';
  }

  @override
  String settings_noEmailApp(String email) {
    return 'कोई ईमेल ऐप नहीं मिला। हमें $email पर लिखें';
  }

  @override
  String get settings_copyEmail => 'ईमेल कॉपी करें';

  @override
  String get settings_emailCopied => 'ईमेल कॉपी हो गया';

  @override
  String get settings_close => 'बंद करें';

  @override
  String get settings_appVersion => 'ऐप वर्शन';

  @override
  String settings_appVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settings_licenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String get web_loadError =>
      'यह पेज लोड नहीं हो सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get themes_title => 'थीम और रंग';

  @override
  String get themes_mode => 'थीम मोड';

  @override
  String get themes_system => 'सिस्टम';

  @override
  String get themes_light => 'हल्का';

  @override
  String get themes_dark => 'गहरा';

  @override
  String get themes_colors => 'रंग';

  @override
  String get themes_fontSize => 'फ़ॉन्ट का आकार';

  @override
  String get themes_fontDefault => 'डिफ़ॉल्ट';

  @override
  String get themes_fontLarge => 'बड़ा';

  @override
  String get themes_preview => 'झलक';

  @override
  String get themes_previewSpent => 'इस महीने खर्च';

  @override
  String get themes_previewChip => 'किराना';

  @override
  String get themes_pro => 'Pro';

  @override
  String themes_tileSelected(String name) {
    return '$name, चुना गया';
  }

  @override
  String themes_tileLocked(String name) {
    return '$name, Pro, लॉक है';
  }

  @override
  String get themes_lockedMessage => 'यह थीम इस्तेमाल करने के लिए Pro लें';

  @override
  String get theme_default => 'डिफ़ॉल्ट टील';

  @override
  String get theme_indigo => 'इंडिगो';

  @override
  String get theme_saffron => 'केसरिया';

  @override
  String get theme_forest => 'हरा-भरा';

  @override
  String get theme_rose => 'गुलाबी';

  @override
  String get theme_midnight => 'आधी रात';

  @override
  String get theme_ocean => 'समुद्री';

  @override
  String get theme_mono => 'मोनो';

  @override
  String get settings_security => 'सुरक्षा';

  @override
  String get settings_appLockEntry => 'ऐप लॉक';

  @override
  String get settings_on => 'चालू';

  @override
  String get settings_off => 'बंद';

  @override
  String get security_title => 'सुरक्षा';

  @override
  String get security_appLock => 'ऐप लॉक';

  @override
  String get security_changePin => 'PIN बदलें';

  @override
  String get security_biometric => 'फ़िंगरप्रिंट / फ़ेस अनलॉक इस्तेमाल करें';

  @override
  String get security_needsLock => 'पहले ऐप लॉक चालू करें';

  @override
  String get security_biometricNotEnrolled =>
      'अपने फ़ोन की सेटिंग में फ़िंगरप्रिंट या फ़ेस अनलॉक सेट करें';

  @override
  String get security_biometricNone =>
      'यह फ़ोन फ़िंगरप्रिंट या फ़ेस अनलॉक सपोर्ट नहीं करता';

  @override
  String get security_lockAfter => 'इसके बाद लॉक करें';

  @override
  String get security_immediately => 'तुरंत';

  @override
  String get security_after1Min => '1 मिनट बाद';

  @override
  String get security_after5Min => '5 मिनट बाद';

  @override
  String get security_hideInRecents => 'हाल के ऐप्स में सामग्री छिपाएँ';

  @override
  String get security_hideInRecentsHelp => 'स्क्रीनशॉट भी बंद हो जाते हैं।';

  @override
  String get security_lockOn => 'ऐप लॉक चालू है';

  @override
  String get security_lockOff => 'ऐप लॉक बंद है';

  @override
  String get security_pinChanged => 'PIN बदल दिया गया';

  @override
  String get lock_enterPin => 'PIN डालें';

  @override
  String get lock_wrongPin => 'गलत PIN';

  @override
  String lock_attemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कोशिशें बाकी',
      one: '1 कोशिश बाकी',
    );
    return 'गलत PIN। $_temp0';
  }

  @override
  String lock_tryAgainIn(String time) {
    return '$time में फिर से कोशिश करें';
  }

  @override
  String lock_nextLockoutWarning(String time) {
    return 'अगला गलत PIN ऐप को $time के लिए लॉक कर देगा';
  }

  @override
  String get lock_credentialUnavailable =>
      'इस फ़ोन पर ऐप लॉक जाँचा नहीं जा सकता।';

  @override
  String get lock_biometricReason => 'DailyTrack अनलॉक करें';

  @override
  String get lock_useBiometric => 'फ़िंगरप्रिंट इस्तेमाल करें';

  @override
  String get lock_delete => 'मिटाएँ';

  @override
  String lock_dotsLabel(int count) {
    return '4 में से $count अंक डाले गए';
  }

  @override
  String get pin_enterCurrent => 'मौजूदा PIN डालें';

  @override
  String get pin_enterNew => 'नया PIN डालें';

  @override
  String get pin_confirmNew => 'नए PIN की पुष्टि करें';

  @override
  String get pin_mismatch => 'PIN मेल नहीं खाते। फिर से कोशिश करें।';

  @override
  String get pin_offerBiometric => 'फ़िंगरप्रिंट / फ़ेस अनलॉक इस्तेमाल करें';

  @override
  String get pin_done => 'हो गया';

  @override
  String get pin_saveError => 'आपका PIN सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get onboarding_setAppLock => 'ऐप लॉक सेट करें';

  @override
  String get onboarding_changePin => 'PIN बदलें';

  @override
  String get settings_data => 'डेटा';

  @override
  String get settings_eraseAll => 'सारा डेटा मिटाएँ';

  @override
  String get erase_title => 'सारा डेटा मिटाएँ?';

  @override
  String get erase_body =>
      'इससे आपके लेन-देन, खाते, श्रेणियाँ, बजट, दोहराई जाने वाली एंट्री, आदतें और चेक-इन, सेटिंग्स और ऐप लॉक मिट जाएँगे। इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get erase_continue => 'आगे बढ़ें';

  @override
  String get erase_typeTitle => 'पुष्टि के लिए DELETE लिखें';

  @override
  String get erase_typeHint => 'DELETE';

  @override
  String get erase_confirm => 'सब कुछ मिटाएँ';

  @override
  String get erase_inProgress => 'मिटाया जा रहा है…';

  @override
  String get erase_failed =>
      'आपका डेटा मिटाया नहीं जा सका। कुछ भी नहीं मिटाया गया।';

  @override
  String get lock_forgotPin => 'PIN भूल गए?';

  @override
  String get lock_forgotTitle => 'अपना PIN भूल गए?';

  @override
  String get lock_forgotBody =>
      'आपका PIN वापस नहीं मिल सकता। आप सारा डेटा मिटाकर नए सिरे से शुरू कर सकते हैं।';

  @override
  String get backup_title => 'बैकअप और रीस्टोर';

  @override
  String get backup_lastBackupTitle => 'पिछला बैकअप';

  @override
  String get backup_noBackupYet => 'अभी तक कोई बैकअप नहीं';

  @override
  String backup_lastBackupDetail(String date, String location, String size) {
    return '$date · $location · $size';
  }

  @override
  String get backup_locationDevice => 'यह डिवाइस';

  @override
  String get backup_locationDrive => 'Google Drive';

  @override
  String backup_lastBackupSubtitle(String date) {
    return 'पिछला बैकअप: $date';
  }

  @override
  String get backup_notBackedUp => 'अभी तक बैकअप नहीं लिया गया';

  @override
  String get backup_localTitle => 'बैकअप फ़ाइल';

  @override
  String get backup_localBody =>
      'अपना सारा डेटा इस फ़ोन पर एक फ़ाइल के रूप में सेव करें, या किसी फ़ाइल से रीस्टोर करें।';

  @override
  String get backup_saveFile => 'बैकअप फ़ाइल सेव करें';

  @override
  String get backup_restoreFile => 'फ़ाइल से रीस्टोर करें';

  @override
  String get backup_saved => 'बैकअप सेव हो गया';

  @override
  String get backup_share => 'शेयर करें';

  @override
  String get backup_working => 'बैकअप बनाया जा रहा है…';

  @override
  String get backup_optionsTitle => 'विकल्प';

  @override
  String get backup_encrypt => 'बैकअप एन्क्रिप्ट करें';

  @override
  String get backup_encryptHelp =>
      'बैकअप फ़ाइलों को पासवर्ड से सुरक्षित करता है';

  @override
  String get backup_changePassword => 'पासवर्ड बदलें';

  @override
  String get backup_includeReceipts => 'रसीद की तस्वीरें शामिल करें';

  @override
  String get backup_includeReceiptsHelp => 'इससे बैकअप फ़ाइल बड़ी हो जाती है';

  @override
  String backup_countTransactions(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString लेन-देन',
      one: '1 लेन-देन',
      zero: 'कोई लेन-देन नहीं',
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
      other: '$countString आदतें',
      one: '1 आदत',
      zero: 'कोई आदत नहीं',
    );
    return '$_temp0';
  }

  @override
  String get backup_passwordTitle => 'बैकअप पासवर्ड सेट करें';

  @override
  String get backup_passwordChangeTitle => 'बैकअप पासवर्ड बदलें';

  @override
  String get backup_passwordField => 'पासवर्ड';

  @override
  String get backup_passwordConfirm => 'पासवर्ड की पुष्टि करें';

  @override
  String get backup_passwordWarning =>
      'अगर आप यह पासवर्ड भूल गए, तो इससे बने बैकअप रीस्टोर नहीं हो सकेंगे। इसे वापस नहीं पाया जा सकता।';

  @override
  String get backup_passwordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get backup_passwordSave => 'पासवर्ड सेव करें';

  @override
  String get restore_passwordTitle => 'बैकअप पासवर्ड डालें';

  @override
  String get restore_open => 'बैकअप खोलें';

  @override
  String get restore_previewTitle => 'यह बैकअप रीस्टोर करें?';

  @override
  String restore_previewCreated(String date) {
    return '$date को बनाया गया';
  }

  @override
  String restore_previewVersion(String version) {
    return 'ऐप वर्ज़न $version';
  }

  @override
  String restore_previewReceipts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString रसीद की तस्वीरें शामिल हैं',
      one: '1 रसीद की तस्वीर शामिल है',
    );
    return '$_temp0';
  }

  @override
  String get restore_previewSkipped =>
      'इस बैकअप का कुछ डेटा ऐसे फ़ीचर का है जो इस वर्ज़न में नहीं है। उसे छोड़ दिया जाएगा।';

  @override
  String get restore_continue => 'आगे बढ़ें';

  @override
  String get restore_confirmTitle => 'मौजूदा डेटा बदलें?';

  @override
  String get restore_confirmBody =>
      'आपके मौजूदा सभी लेन-देन, खाते, श्रेणियाँ, बजट, दोहराई जाने वाली एंट्री, आदतें, चेक-इन और पसंद इस बैकअप से बदल दिए जाएँगे। इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get restore_confirmAction => 'डेटा बदलें';

  @override
  String get restore_inProgress => 'रीस्टोर हो रहा है…';

  @override
  String get restore_done => 'बैकअप रीस्टोर हो गया';

  @override
  String get restore_doneMissingReceipts =>
      'बैकअप रीस्टोर हो गया, लेकिन कुछ रसीद की तस्वीरें कॉपी नहीं हो सकीं।';

  @override
  String get restore_failedTitle => 'रीस्टोर नहीं हो सका';

  @override
  String get backup_failedTitle => 'बैकअप नहीं हो सका';

  @override
  String get backup_errNotRecognized =>
      'यह DailyTrack बैकअप नहीं है। कुछ नहीं बदला गया।';

  @override
  String get backup_errDamaged =>
      'यह बैकअप फ़ाइल खराब है और पढ़ी नहीं जा सकती। कुछ नहीं बदला गया।';

  @override
  String get backup_errInvalid =>
      'इस बैकअप में ऐसा डेटा है जिसे DailyTrack इस्तेमाल नहीं कर सकता। कुछ नहीं बदला गया।';

  @override
  String get backup_errTooNew =>
      'यह बैकअप रीस्टोर करने के लिए DailyTrack अपडेट करें।';

  @override
  String get backup_errWrongPassword => 'गलत पासवर्ड या खराब फ़ाइल।';

  @override
  String get backup_errNeedsPassword =>
      'एन्क्रिप्टेड बैकअप बनाते रहने के लिए अपना बैकअप पासवर्ड फिर से सेट करें।';

  @override
  String get backup_errTooLarge =>
      'यह बैकअप एन्क्रिप्ट करने के लिए बहुत बड़ा है। रसीद की तस्वीरें बंद करके फिर से कोशिश करें।';

  @override
  String get backup_errBusy =>
      'एक बैकअप या रीस्टोर पहले से चल रहा है। थोड़ी देर बाद फिर से कोशिश करें।';

  @override
  String get backup_errStorage =>
      'इस फ़ोन में पर्याप्त जगह नहीं है। थोड़ी जगह खाली करके फिर से कोशिश करें।';

  @override
  String get backup_errGeneric => 'कुछ गड़बड़ हो गई। कुछ नहीं बदला गया।';

  @override
  String get backup_driveTitle => 'Google Drive';

  @override
  String get backup_driveBody =>
      'अपनी Google Drive पर बैकअप लें। बैकअप एक निजी ऐप फ़ोल्डर में रखे जाते हैं, जो आपको अपनी Drive फ़ाइलों में नहीं दिखेगा।';

  @override
  String get backup_driveUnavailable =>
      'इस बिल्ड में Google Drive उपलब्ध नहीं है।';

  @override
  String backup_connected(String email) {
    return '$email के रूप में जुड़ा है';
  }

  @override
  String get backup_backUpNow => 'अभी बैकअप लें';

  @override
  String get backup_uploading => 'Google Drive पर बैकअप हो रहा है…';

  @override
  String get backup_driveSaved => 'Google Drive पर बैकअप हो गया';

  @override
  String get backup_autoTitle => 'ऑटो बैकअप';

  @override
  String get backup_autoOff => 'बंद';

  @override
  String get backup_autoDaily => 'रोज़';

  @override
  String get backup_autoWeekly => 'हर हफ़्ते';

  @override
  String get backup_wifiOnly => 'सिर्फ़ Wi-Fi पर';

  @override
  String get backup_wifiOnlyHelp => 'बैकअप से पहले Wi-Fi का इंतज़ार करता है';

  @override
  String get backup_driveListTitle => 'Google Drive से रीस्टोर करें';

  @override
  String get backup_driveListEmpty => 'Google Drive में अभी तक कोई बैकअप नहीं';

  @override
  String get backup_driveListError =>
      'आपके Google Drive बैकअप लोड नहीं हो सके।';

  @override
  String backup_driveEntry(String date, String size) {
    return '$date · $size';
  }

  @override
  String get backup_kindManual => 'मैन्युअल';

  @override
  String get backup_kindAuto => 'ऑटो';

  @override
  String get backup_delete => 'हटाएँ';

  @override
  String get backup_deleteTitle => 'यह बैकअप हटाएँ?';

  @override
  String get backup_deleteBody =>
      'इसे Google Drive से हटा दिया जाएगा। इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get backup_deleteAction => 'बैकअप हटाएँ';

  @override
  String get backup_moreActions => 'इस बैकअप के लिए और विकल्प';

  @override
  String get backup_listLoading => 'आपके बैकअप लोड हो रहे हैं…';

  @override
  String get backup_downloading => 'बैकअप डाउनलोड हो रहा है…';

  @override
  String get backup_errAuth => 'आपका Google खाता फिर से जोड़ना होगा।';

  @override
  String get backup_reconnect => 'Google खाता फिर से जोड़ें';

  @override
  String get backup_errQuota =>
      'आपकी Google Drive भर गई है। Drive में जगह खाली करके फिर से कोशिश करें।';

  @override
  String get backup_errOffline =>
      'Google Drive तक नहीं पहुँच सके। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get backup_errDrive =>
      'Google Drive अभी जवाब नहीं दे रही है। बाद में फिर से कोशिश करें।';

  @override
  String get notif_channelBackup => 'बैकअप';

  @override
  String get notif_channelBackupDescription =>
      'ऑटोमैटिक बैकअप बार-बार विफल होने पर बताता है';

  @override
  String get notif_backupFailingTitle => 'ऑटोमैटिक बैकअप काम नहीं कर रहा';

  @override
  String get notif_backupFailingBody =>
      'Google Drive पर आपके पिछले 3 बैकअप विफल रहे। जाँचने के लिए टैप करें।';

  @override
  String get lock_forgotBodyRestore =>
      'आपका PIN वापस नहीं मिल सकता। आप Google Drive बैकअप से अपना डेटा रीस्टोर कर सकते हैं, या सारा डेटा मिटाकर नए सिरे से शुरू कर सकते हैं।';

  @override
  String get lock_restoreFromDrive => 'Google Drive बैकअप से रीस्टोर करें';

  @override
  String get export_title => 'डेटा एक्सपोर्ट करें';

  @override
  String get export_settingsHelp => 'CSV या PDF';

  @override
  String get export_dataType => 'डेटा';

  @override
  String get export_transactions => 'लेन-देन';

  @override
  String get export_habits => 'आदतें';

  @override
  String get export_period => 'अवधि';

  @override
  String get export_format => 'फ़ॉर्मेट';

  @override
  String get export_csv => 'CSV';

  @override
  String get export_pdf => 'PDF';

  @override
  String get export_filtersTitle => 'फ़िल्टर';

  @override
  String get export_accounts => 'खाते';

  @override
  String get export_categories => 'श्रेणियाँ';

  @override
  String get export_all => 'सभी';

  @override
  String export_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुने गए',
      one: '1 चुना गया',
    );
    return '$_temp0';
  }

  @override
  String get export_filterDone => 'लागू करें';

  @override
  String get export_button => 'एक्सपोर्ट करें';

  @override
  String get export_working => 'आपकी फ़ाइल बन रही है…';

  @override
  String get export_locked =>
      'एक्सपोर्ट DailyTrack Pro का हिस्सा हैं। एक एक्सपोर्ट के लिए विज्ञापन देखें, या Pro लें।';

  @override
  String get export_nothing => 'इस अवधि के लिए एक्सपोर्ट करने को कुछ नहीं है';

  @override
  String get export_failedTitle => 'एक्सपोर्ट नहीं हो सका';

  @override
  String get export_failed =>
      'फ़ाइल नहीं बन सकी। कुछ भी शेयर नहीं किया गया। फिर से कोशिश करें।';

  @override
  String get export_reportAction => 'यह रिपोर्ट एक्सपोर्ट करें';

  @override
  String get export_colDate => 'तारीख';

  @override
  String get export_colTime => 'समय';

  @override
  String get export_colType => 'प्रकार';

  @override
  String get export_colCategory => 'श्रेणी';

  @override
  String get export_colAccount => 'खाता';

  @override
  String get export_colPaymentMode => 'भुगतान का तरीका';

  @override
  String get export_colAmount => 'राशि';

  @override
  String get export_colNote => 'नोट';

  @override
  String get export_colHabit => 'आदत';

  @override
  String get export_colValue => 'मान';

  @override
  String get export_colTarget => 'लक्ष्य';

  @override
  String get export_colUnit => 'इकाई';

  @override
  String get export_colStatus => 'स्थिति';

  @override
  String get export_statusDone => 'पूरा';

  @override
  String get export_statusPartial => 'आंशिक';

  @override
  String get export_statusFreeze => 'फ़्रीज़';

  @override
  String get export_totalIncome => 'कुल आय';

  @override
  String get export_totalExpense => 'कुल खर्च';

  @override
  String get export_net => 'शुद्ध';

  @override
  String get export_count => 'एंट्री';

  @override
  String export_percent(int percent) {
    return '$percent% पूरा';
  }

  @override
  String export_filterAccounts(String names) {
    return 'खाते: $names';
  }

  @override
  String export_filterCategories(String names) {
    return 'श्रेणियाँ: $names';
  }

  @override
  String export_transfer(String from, String to) {
    return '$from → $to';
  }

  @override
  String get export_chartTitle => 'श्रेणी के अनुसार खर्च';

  @override
  String get export_other => 'अन्य';

  @override
  String get export_summaryTitle => 'सारांश';

  @override
  String export_pdfHeader(String title, String period) {
    return 'DailyTrack · $title · $period';
  }

  @override
  String export_page(int page, int pages) {
    return 'पेज $page / $pages';
  }

  @override
  String get notif_channelDailySummary => 'रोज़ का सारांश';

  @override
  String get notif_channelDailySummaryDescription =>
      'दिन का आपका खर्च और आदतें';

  @override
  String get notif_dailySummaryTitle => 'आज DailyTrack में';

  @override
  String notif_dailySummaryBoth(String amount, int done, int total) {
    return 'आज $amount खर्च · $done/$total आदतें पूरी';
  }

  @override
  String notif_dailySummarySpend(String amount) {
    return 'आज $amount खर्च';
  }

  @override
  String notif_dailySummaryHabits(int done, int total) {
    return '$done/$total आदतें पूरी';
  }

  @override
  String get notif_actionMarkDone => 'पूरा करें';

  @override
  String get notif_actionSnooze => '1 घंटे बाद';

  @override
  String get settings_exactNote => 'रिमाइंडर कुछ मिनट देर से आ सकते हैं';

  @override
  String get settings_exactAllow => 'सटीक समय की अनुमति दें';

  @override
  String get security_showWidgetData => 'विजेट पर डेटा दिखाएँ';

  @override
  String get security_showWidgetDataHelp =>
      'आपकी होम स्क्रीन पर राशि और आदतों के नाम दिखाता है';

  @override
  String get widget_label => 'DailyTrack आज';

  @override
  String get widget_description => 'आज का खर्च, बजट और आदतों की जाँच';

  @override
  String get widget_open => 'DailyTrack खोलें';

  @override
  String get widget_spentToday => 'आज का खर्च';

  @override
  String widget_spentTodayA11y(String amount) {
    return 'आज का खर्च, $amount';
  }

  @override
  String widget_monthBudget(String month) {
    return '$month का बजट';
  }

  @override
  String widget_budgetText(int percent, String spent, String limit) {
    return '$percent% इस्तेमाल · $limit में से $spent';
  }

  @override
  String get widget_noBudget => 'कोई बजट सेट नहीं';

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
    return '$name, पूरा';
  }

  @override
  String widget_habitTodoA11y(String name) {
    return '$name, पूरा नहीं। पूरा करने के लिए दो बार टैप करें';
  }

  @override
  String widget_habitCountA11y(String name, String progress) {
    return '$name, $progress। एक जोड़ने के लिए दो बार टैप करें';
  }

  @override
  String get ads_badge => 'विज्ञापन';

  @override
  String get ads_bannerLabel => 'विज्ञापन';

  @override
  String get privacy_adChoices => 'विज्ञापन निजता विकल्प';

  @override
  String get ads_resetCounters => 'विज्ञापन काउंटर रीसेट करें';

  @override
  String get ads_resetCountersDone => 'विज्ञापन काउंटर रीसेट हो गए';

  @override
  String get premium_title => 'DailyTrack Pro';

  @override
  String get premium_benefitNoAds => 'कोई विज्ञापन नहीं';

  @override
  String get premium_benefitThemes => 'सभी थीम';

  @override
  String get premium_benefitReports => 'उन्नत रिपोर्ट';

  @override
  String get premium_benefitExports => 'असीमित एक्सपोर्ट';

  @override
  String get premium_benefitFreezes => 'सीमा तक असीमित स्ट्रीक फ़्रीज़';

  @override
  String get rewarded_titleReports => '24 घंटे के लिए उन्नत रिपोर्ट अनलॉक करें';

  @override
  String get rewarded_titleCsv => 'एक CSV एक्सपोर्ट अनलॉक करें';

  @override
  String get rewarded_titlePdf => 'एक PDF एक्सपोर्ट अनलॉक करें';

  @override
  String rewarded_titleTheme(String theme) {
    return '$theme थीम हमेशा के लिए अनलॉक करें';
  }

  @override
  String rewarded_titleFreeze(String habit) {
    return '$habit के लिए 1 स्ट्रीक फ़्रीज़ पाएँ';
  }

  @override
  String get rewarded_explainReports =>
      'अगले 24 घंटों तक रुझान, खाते और हर अवधि देखने के लिए एक छोटा विज्ञापन देखें।';

  @override
  String get rewarded_explainExport =>
      'इस फ़ॉर्मैट में एक एक्सपोर्ट फ़ाइल बनाने के लिए एक छोटा विज्ञापन देखें।';

  @override
  String get rewarded_explainTheme =>
      'यह रंग थीम हमेशा के लिए पाने के लिए एक छोटा विज्ञापन देखें।';

  @override
  String get rewarded_explainFreeze =>
      'इस आदत में एक स्ट्रीक फ़्रीज़ जोड़ने के लिए एक छोटा विज्ञापन देखें (अधिकतम 2)।';

  @override
  String get rewarded_watch => 'एक छोटा विज्ञापन देखें';

  @override
  String get rewarded_getPro => 'इसके बजाय Pro लें';

  @override
  String get rewarded_notNow => 'अभी नहीं';

  @override
  String get rewarded_loadingAd => 'विज्ञापन लोड हो रहा है';

  @override
  String get rewarded_unavailable =>
      'विज्ञापन उपलब्ध नहीं है, बाद में फिर कोशिश करें';

  @override
  String get rewarded_tryAgain => 'फिर कोशिश करें';

  @override
  String get rewarded_closedEarly => 'अनलॉक करने के लिए पूरा विज्ञापन देखें';

  @override
  String get rewarded_limitReached =>
      'आज के लिए इस अनलॉक की सीमा पूरी हो गई है। कल फिर कोशिश करें, या Pro लें।';

  @override
  String get locked_watchAdReports =>
      '24 घंटे के लिए अनलॉक करने को विज्ञापन देखें';

  @override
  String get locked_watchAdExport =>
      'एक एक्सपोर्ट अनलॉक करने को विज्ञापन देखें';

  @override
  String get locked_watchAdTheme => 'यह थीम अनलॉक करने को विज्ञापन देखें';

  @override
  String get locked_watchAdFreeze => 'फ़्रीज़ पाने के लिए विज्ञापन देखें';

  @override
  String premium_buyFor(String price) {
    return '$price में Pro लें';
  }

  @override
  String get premium_restore => 'खरीदारी वापस पाएँ';

  @override
  String get premium_restored => 'Pro वापस मिल गया';

  @override
  String get premium_restoreNotFound =>
      'इस Google खाते के लिए कोई Pro खरीदारी नहीं मिली';

  @override
  String get premium_storeUnavailable =>
      'स्टोर अभी उपलब्ध नहीं है, बाद में फिर कोशिश करें';

  @override
  String get premium_accountNote =>
      'आपकी खरीदारी आपके Google खाते से जुड़ी है।';

  @override
  String get premium_pending => 'भुगतान पूरा होते ही Pro अनलॉक हो जाएगा';

  @override
  String get premium_purchaseError =>
      'खरीदारी पूरी नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get premium_owned => 'आपके पास Pro है। आपके साथ के लिए धन्यवाद।';

  @override
  String get premium_cardTitle => 'विज्ञापन हटाएँ और सब कुछ अनलॉक करें';

  @override
  String get premium_cardSubtitle =>
      'DailyTrack Pro: एक बार खरीदें, हमेशा के लिए';

  @override
  String get habit_addFreezePro => 'फ़्रीज़ जोड़ें';

  @override
  String get account_title => 'खाता';

  @override
  String get account_signedOutTitle => 'अपने Google खाते से बैकअप लें';

  @override
  String get account_pointDrive =>
      'आपका डेटा आपकी अपनी Google Drive में सेव होता है';

  @override
  String get account_pointRestore => 'नए फ़ोन पर इसे रीस्टोर करें';

  @override
  String get account_pointOptional =>
      'वैकल्पिक: ऐप बिना खाते के भी पूरी तरह काम करता है';

  @override
  String get account_signIn => 'Google से साइन इन करें';

  @override
  String get account_pinFootnote =>
      'आपके ऐप लॉक PIN का कभी बैकअप नहीं लिया जाता।';

  @override
  String get account_signInFailed =>
      'साइन इन नहीं हो सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get account_restoreOffline =>
      'रीस्टोर करने के लिए इंटरनेट से कनेक्ट करें';

  @override
  String get account_signInOffline =>
      'Google से साइन इन करने के लिए इंटरनेट से कनेक्ट करें';

  @override
  String get account_signedInBackedUp =>
      'साइन इन हो गया। आपके डेटा का बैकअप हो गया है।';

  @override
  String account_lastBackupFrom(String time, String device) {
    return 'पिछला बैकअप: $time · $device';
  }

  @override
  String account_lastBackup(String time) {
    return 'पिछला बैकअप: $time';
  }

  @override
  String get account_noBackupYet => 'इस खाते में अभी तक कोई बैकअप नहीं';

  @override
  String get account_statusBackedUp => 'Google पर बैकअप हो गया';

  @override
  String get account_statusOffline =>
      'आप ऑफ़लाइन हैं। ऑनलाइन होने पर बैकअप फिर से शुरू होंगे।';

  @override
  String get account_statusWaitingForWifi => 'Wi-Fi का इंतज़ार है';

  @override
  String get account_statusFailedNoPassword =>
      'बैकअप विफल रहा: बैकअप और रीस्टोर में अपना बैकअप पासवर्ड सेट करें';

  @override
  String get account_signOutBackedUp => 'बैकअप हो गया';

  @override
  String get account_statusBackingUp => 'बैकअप हो रहा है…';

  @override
  String get account_statusPaused =>
      'बैकअप रुका है: दूसरे फ़ोन का नया बैकअप मौजूद है';

  @override
  String get account_statusFailed => 'बैकअप विफल रहा';

  @override
  String get account_statusError => 'आपके बैकअप पढ़े नहीं जा सके।';

  @override
  String account_autoSummaryWifi(String frequency) {
    return '$frequency · सिर्फ़ Wi-Fi पर';
  }

  @override
  String get account_signOut => 'साइन आउट करें';

  @override
  String get account_signedOut =>
      'साइन आउट हो गया। आपका डेटा अभी भी इसी फ़ोन पर है।';

  @override
  String get account_deleteBackups => 'मेरे बैकअप हटाएँ';

  @override
  String get account_deleteTitle => 'अपने बैकअप हटाएँ?';

  @override
  String account_deleteBody(int count, String email) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$email से DailyTrack के सभी $countString बैकअप हटाएँ? इस फ़ोन का डेटा रहेगा। इसे पहले जैसा नहीं किया जा सकता।',
      one:
          '$email से DailyTrack का 1 बैकअप हटाएँ? इस फ़ोन का डेटा रहेगा। इसे पहले जैसा नहीं किया जा सकता।',
    );
    return '$_temp0';
  }

  @override
  String get account_deleteAction => 'बैकअप हटाएँ';

  @override
  String get account_deleted => 'आपके बैकअप हटा दिए गए';

  @override
  String account_photoOf(String name) {
    return '$name की प्रोफ़ाइल फ़ोटो';
  }

  @override
  String get backup_manageAccount => 'अपना खाता मैनेज करें';

  @override
  String get backup_conflictTitle => 'फिर भी बैकअप लें?';

  @override
  String backup_conflictNewer(String device, String time) {
    return '$device का एक नया बैकअप ($time) मौजूद है। अभी बैकअप लेने पर इस फ़ोन का डेटा सबसे नया बन जाएगा।';
  }

  @override
  String get backup_conflictEmpty =>
      'इस फ़ोन पर कोई डेटा नहीं है। अभी बैकअप लेने पर खाली बैकअप सबसे नया बन जाएगा।';

  @override
  String get backup_backUpAnyway => 'फिर भी बैकअप लें';

  @override
  String get backup_unknownDevice => 'अज्ञात डिवाइस';

  @override
  String get account_androidPhone => 'Android फ़ोन';

  @override
  String get notif_backupPausedTitle => 'बैकअप रुका है';

  @override
  String get notif_backupPausedBody =>
      'दूसरे फ़ोन ने नया बैकअप लिया है। देखने के लिए टैप करें।';

  @override
  String account_choiceTitle(String email) {
    return '$email पर बैकअप मिला';
  }

  @override
  String get account_fromThisPhone => 'इसी फ़ोन से';

  @override
  String account_fromDevice(String device) {
    return '$device से';
  }

  @override
  String get account_encrypted => 'एन्क्रिप्टेड';

  @override
  String account_thisPhone(String counts) {
    return 'यह फ़ोन: $counts';
  }

  @override
  String get account_thisPhoneEmpty => 'यह फ़ोन: अभी कोई डेटा नहीं';

  @override
  String get account_replaceNote =>
      'रीस्टोर करने पर इस फ़ोन का डेटा बदल जाएगा।';

  @override
  String get account_restoreFromAccount => 'खाते से रीस्टोर करें';

  @override
  String get account_keepThisPhone => 'इस फ़ोन का डेटा रखें';

  @override
  String get account_seeAllBackups => 'सभी बैकअप देखें';

  @override
  String get account_close => 'बंद करें';

  @override
  String get account_wrongPassword => 'वह पासवर्ड काम नहीं किया';

  @override
  String get account_restoreFailed =>
      'रीस्टोर नहीं हो सका। इस फ़ोन का आपका डेटा नहीं बदला गया।';

  @override
  String get account_safetyCopyFailed =>
      'पहले इस फ़ोन के डेटा की कॉपी सेव करने के लिए जगह नहीं है, इसलिए कुछ भी रीस्टोर नहीं हुआ। जगह खाली करके फिर से कोशिश करें।';

  @override
  String account_restoredCounts(String summary) {
    return 'रीस्टोर हो गया: $summary';
  }

  @override
  String get account_restoring => 'आपका डेटा रीस्टोर हो रहा है…';

  @override
  String get account_restore => 'रीस्टोर करें';

  @override
  String get account_review => 'देखें';

  @override
  String get account_switch => 'खाता बदलें';

  @override
  String get account_switchFailedTitle => 'पहले बैकअप नहीं हो सका';

  @override
  String account_switchFailedBody(String email) {
    return 'आपके नए बदलाव अभी $email में नहीं हैं। फिर भी खाता बदलें? आपका डेटा इसी फ़ोन पर रहेगा।';
  }

  @override
  String get account_switchAnyway => 'फिर भी बदलें';

  @override
  String get account_sessionExpired =>
      'आपका Google साइन-इन खत्म हो गया। बैकअप जारी रखने के लिए फिर से साइन इन करें।';

  @override
  String account_signOutSheetTitle(String email) {
    return '$email से साइन आउट करें?';
  }

  @override
  String get account_signOutBackingUp => 'आपके नए बदलावों का बैकअप हो रहा है…';

  @override
  String get account_signOutBackupFailed =>
      'आपके नए बदलावों का बैकअप नहीं हो सका';

  @override
  String get account_signOutAnyway => 'फिर भी साइन आउट करें';

  @override
  String get account_keepData => 'इस फ़ोन पर डेटा रखें';

  @override
  String get account_keepDataHelp =>
      'आप बिना खाते के ऐप का इस्तेमाल जारी रख सकते हैं।';

  @override
  String get account_removeData => 'इस फ़ोन से डेटा हटाएँ';

  @override
  String get account_removeDataHelp => 'आपका बैकअप आपके Google खाते में रहेगा।';

  @override
  String get auth_title => 'अपना डेटा सुरक्षित रखें';

  @override
  String get auth_body =>
      'अपने खर्चों और आदतों का बैकअप लेने और नए फ़ोन पर उन्हें वापस पाने के लिए Google से साइन इन करें।';

  @override
  String get auth_continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get auth_continueAsGuest => 'मेहमान के रूप में जारी रखें';

  @override
  String get auth_guestNote =>
      'मेहमान के रूप में, आपका डेटा सिर्फ़ इसी फ़ोन पर रहता है।';

  @override
  String get auth_signInCancelled =>
      'साइन इन रद्द हो गया। फिर से कोशिश करें या मेहमान के रूप में जारी रखें।';

  @override
  String get auth_offline =>
      'आप ऑफ़लाइन हैं। Google से साइन इन करने के लिए इंटरनेट से जुड़ें, या मेहमान के रूप में जारी रखें।';

  @override
  String get auth_continueWithoutRestoring => 'रीस्टोर किए बिना जारी रखें';

  @override
  String get accountCard_guestTitle =>
      'मेहमान · डेटा सिर्फ़ इसी फ़ोन पर सेव है';

  @override
  String accountCard_backedUp(String time) {
    return 'Google पर बैकअप हो गया · $time';
  }

  @override
  String get accountCard_paused => 'बैकअप रुका है';

  @override
  String get accountCard_justNow => 'अभी-अभी';

  @override
  String accountCard_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '1 मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String accountCard_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '1 घंटा पहले',
    );
    return '$_temp0';
  }

  @override
  String accountCard_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: 'कल',
    );
    return '$_temp0';
  }

  @override
  String get settings_logOutGuest => 'मेहमान मोड से लॉग आउट करें';

  @override
  String get logOutGuest_title => 'लॉग आउट करें और अपना डेटा मिटाएँ?';

  @override
  String get logOutGuest_body =>
      'मेहमान के रूप में, आपका डेटा सिर्फ़ इसी फ़ोन पर सेव है। लॉग आउट करने से आपके सभी खर्च, आदतें, बजट, रसीदें और अनलॉक हमेशा के लिए मिट जाएँगे। इसे वापस नहीं किया जा सकता।';

  @override
  String get logOutGuest_signInInstead => 'इसके बजाय Google से साइन इन करें';

  @override
  String get logOutGuest_confirm => 'लॉग आउट करें और मिटाएँ';

  @override
  String get logOutGuest_failed =>
      'आपका डेटा नहीं मिटाया जा सका। फिर से कोशिश करें।';

  @override
  String get finishSetup_title => 'सेटअप पूरा करें';

  @override
  String get finishSetup_body =>
      'आपका डेटा वापस आ गया। आपके ऐप लॉक PIN का कभी बैकअप नहीं होता, इसलिए अपना डेटा निजी रखने के लिए नया PIN सेट करें।';

  @override
  String get finishSetup_setLock => 'ऐप लॉक सेट करें';

  @override
  String get finishSetup_allowNotifications => 'सूचनाओं की अनुमति दें';

  @override
  String get finishSetup_notNow => 'अभी नहीं';

  @override
  String get backup_previousTitle => 'फ़ोन का पिछला डेटा रीस्टोर करें';

  @override
  String backup_previousDetail(String date, String counts) {
    return '$date को सेव किया · $counts';
  }

  @override
  String get currency_INR => 'भारतीय रुपया';

  @override
  String get currency_USD => 'अमेरिकी डॉलर';

  @override
  String get currency_EUR => 'यूरो';

  @override
  String get currency_GBP => 'ब्रिटिश पाउंड';

  @override
  String get currency_AED => 'यूएई दिरहम';

  @override
  String get currency_SAR => 'सऊदी रियाल';

  @override
  String get currency_QAR => 'क़तरी रियाल';

  @override
  String get currency_KWD => 'कुवैती दीनार';

  @override
  String get currency_OMR => 'ओमानी रियाल';

  @override
  String get currency_BHD => 'बहरीनी दीनार';

  @override
  String get currency_SGD => 'सिंगापुर डॉलर';

  @override
  String get currency_MYR => 'मलेशियाई रिंगिट';

  @override
  String get currency_THB => 'थाई बाट';

  @override
  String get currency_IDR => 'इंडोनेशियाई रुपिया';

  @override
  String get currency_PHP => 'फ़िलिपीनी पेसो';

  @override
  String get currency_JPY => 'जापानी येन';

  @override
  String get currency_CNY => 'चीनी युआन';

  @override
  String get currency_HKD => 'हांगकांग डॉलर';

  @override
  String get currency_KRW => 'दक्षिण कोरियाई वॉन';

  @override
  String get currency_AUD => 'ऑस्ट्रेलियाई डॉलर';

  @override
  String get currency_NZD => 'न्यूज़ीलैंड डॉलर';

  @override
  String get currency_CAD => 'कनाडाई डॉलर';

  @override
  String get currency_CHF => 'स्विस फ़्रैंक';

  @override
  String get currency_SEK => 'स्वीडिश क्रोना';

  @override
  String get currency_NOK => 'नॉर्वेजियन क्रोन';

  @override
  String get currency_DKK => 'डेनिश क्रोन';

  @override
  String get currency_ZAR => 'दक्षिण अफ़्रीकी रैंड';

  @override
  String get currency_NPR => 'नेपाली रुपया';

  @override
  String get currency_BDT => 'बांग्लादेशी टका';

  @override
  String get currency_LKR => 'श्रीलंकाई रुपया';
}
