import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/seed_names.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared display helpers for the Expense screens, so every screen names
/// and colors things the same way (§15.1 "Consistent").

extension ExpenseL10n on AppLocalizations {
  String txnType(TxnType t) => switch (t) {
    TxnType.expense => expense_typeExpense,
    TxnType.income => expense_typeIncome,
    TxnType.transfer => expense_typeTransfer,
  };

  String paymentMode(PaymentMode m) => switch (m) {
    PaymentMode.cash => expense_payCash,
    PaymentMode.upi => expense_payUpi,
    PaymentMode.card => expense_payCard,
    PaymentMode.netBanking => expense_payNetBanking,
    PaymentMode.other => expense_payOther,
  };

  String accountType(AccountType t) => switch (t) {
    AccountType.cash => expense_accountTypeCash,
    AccountType.bank => expense_accountTypeBank,
    AccountType.upi => expense_accountTypeUpi,
    AccountType.card => expense_accountTypeCard,
    AccountType.wallet => expense_accountTypeWallet,
  };

  /// Default names are ARB keys (translated); user names are shown as typed.
  String categoryName(Category c) => localizedSeedName(this, c.name);

  String accountName(Account a) => localizedSeedName(this, a.name);

  /// EXP-08 level text, so budget status is never shown by color alone.
  String budgetLevel(BudgetLevel level) => switch (level) {
    BudgetLevel.under => expense_budgetLevelUnder,
    BudgetLevel.warning => expense_budgetLevelWarning,
    BudgetLevel.over => expense_budgetLevelOver,
  };

  /// "Overall" or the category's display name.
  String budgetName(Category? category) =>
      category == null ? expense_budgetOverall : categoryName(category);
}

/// Sign and color of an amount for a transaction type (§15.2: income +,
/// expense −, transfers neutral).
AmountKind amountKindFor(TxnType t) => switch (t) {
  TxnType.income => AmountKind.income,
  TxnType.expense => AmountKind.expense,
  TxnType.transfer => AmountKind.neutral,
};

/// A stored `#RRGGBB` palette color.
Color colorFromHex(String hex) => AppColors.fromHex(hex);

/// The user's currency (formatting only; amounts are never converted).
String currencyCodeOf(WidgetRef ref) =>
    ref.watch(appSettingsProvider).value?.currencyCode ?? 'INR';
