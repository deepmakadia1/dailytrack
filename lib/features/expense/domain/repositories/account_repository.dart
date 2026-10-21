import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// Accounts store (contracts/repositories.md, data-model.md §3.3).
abstract interface class AccountRepository {
  /// Non-deleted accounts in sortOrder with their derived balance.
  Stream<List<AccountWithBalance>> watchAllWithBalances();

  /// Sum of balances of non-deleted, non-archived accounts.
  Stream<int> watchTotalBalance();

  /// Non-deleted, non-archived accounts in sortOrder (EXP-02 pickers).
  Stream<List<Account>> watchPickable();

  Future<Account> create({
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  });

  Future<void> update(
    String id, {
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  });

  /// Throws `AccountArchiveNotAllowed` when archiving the last active
  /// account (clarification Q3).
  Future<void> setArchived(String id, {required bool archived});

  /// Throws `AccountDeleteNotAllowed`.
  Future<void> delete(String id);

  Future<void> undelete(String id);
}
