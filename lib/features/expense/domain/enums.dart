// Stored as their int index (Drift intEnum).
// Append-only: never reorder or remove values, or stored data and backups
// will decode to the wrong value.

enum CategoryType { expense, income }

enum AccountType { cash, bank, upi, card, wallet }

enum TxnType { expense, income, transfer }

enum PaymentMode { cash, upi, card, netBanking, other }

/// How often a recurring rule repeats (feature 003, data-model.md §2).
enum Frequency { daily, weekly, monthly, yearly }

extension AccountTypeX on AccountType {
  /// EXP-02 default payment mode for an account (spec clarification Q4).
  PaymentMode get defaultPaymentMode => switch (this) {
    AccountType.cash => PaymentMode.cash,
    AccountType.bank => PaymentMode.netBanking,
    AccountType.upi => PaymentMode.upi,
    AccountType.card => PaymentMode.card,
    AccountType.wallet => PaymentMode.other,
  };
}
