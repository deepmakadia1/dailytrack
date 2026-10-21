import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_controller.freezed.dart';
part 'accounts_controller.g.dart';

/// EXP-06 data (contracts/screens.md).
@freezed
abstract class AccountsData with _$AccountsData {
  const factory({
    /// Sum of non-archived balances.
    required int totalMinor,
    required List<AccountWithBalance> active,
    required List<AccountWithBalance> archived,
  }) = _AccountsData;

  const new _();

  /// Q3: the last active account can be neither archived nor deleted.
  bool get canRemoveActive => active.length > 1;
}

/// EXP-06 Accounts (T105). The screen's only notifier.
@riverpod
class AccountsController extends _$AccountsController {
  @override
  Stream<AccountsData> build() =>
      ref.watch(accountRepositoryProvider).watchAllWithBalances().map((all) {
        final active = [
          for (final a in all)
            if (!a.account.isArchived) a,
        ];
        return AccountsData(
          totalMinor: active.fold(0, (s, a) => s + a.balanceMinor),
          active: active,
          archived: [
            for (final a in all)
              if (a.account.isArchived) a,
          ],
        );
      });

  /// Archives or restores [id]; returns the undo, or null when refused
  /// (last active account, Q3) or the write failed.
  Future<Future<void> Function()?> setArchived(
    String id, {
    required bool archived,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    try {
      await repo.setArchived(id, archived: archived);
    } on AccountArchiveNotAllowed {
      return null;
    } on ExpenseStorageFailure {
      return null;
    }
    return () => repo.setArchived(id, archived: !archived);
  }

  /// Deletes an account without transactions; returns the undo, or null when
  /// refused (has transactions, last active) or the write failed.
  Future<Future<void> Function()?> delete(String id) async {
    final repo = ref.read(accountRepositoryProvider);
    try {
      await repo.delete(id);
    } on AccountDeleteNotAllowed {
      return null;
    } on ExpenseStorageFailure {
      return null;
    }
    return () => repo.undelete(id);
  }

  void retry() => ref.invalidateSelf();
}
