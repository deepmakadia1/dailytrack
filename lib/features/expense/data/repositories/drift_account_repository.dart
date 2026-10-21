import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/daos/accounts_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/account_mapper.dart';
import 'package:dailytrack/features/expense/data/repositories/storage_guard.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/account_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Drift implementation of [AccountRepository] (data-model.md §3.3).
/// Balances are derived on read; the last-active guards run inside a DB
/// transaction (clarification Q3).
final class DriftAccountRepository implements AccountRepository {
  new(AppDatabase db, this._clock) : _db = db, _dao = AccountsDao(db);

  final AppDatabase _db;
  final AccountsDao _dao;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  @override
  Stream<List<AccountWithBalance>> watchAllWithBalances() => _dao
      .watchWithBalances()
      .map(
        (rows) => [
          for (final r in rows)
            AccountWithBalance(
              account: r.row.toEntity(),
              balanceMinor: r.balance,
              hasTransactions: r.txCount > 0,
            ),
        ],
      )
      .guardStorage();

  @override
  Stream<int> watchTotalBalance() => watchAllWithBalances().map(
    (accounts) => accounts
        .where((a) => !a.account.isArchived)
        .fold(0, (sum, a) => sum + a.balanceMinor),
  );

  @override
  Stream<List<Account>> watchPickable() => _dao
      .watchPickable()
      .map((rows) => [for (final r in rows) r.toEntity()])
      .guardStorage();

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  }) => guardStorage(
    () => _db.transaction(() async {
      final id = _uuid.v4();
      final now = _nowMs();
      await _dao.insertRow(
        AccountsCompanion.insert(
          id: id,
          name: name.trim(),
          type: type,
          openingBalanceMinor: Value(openingBalanceMinor),
          iconKey: iconKey,
          colorHex: colorHex,
          sortOrder: await _dao.nextSortOrder(),
          createdAt: now,
          updatedAt: now,
        ),
      );
      return (await _dao.byId(id))!.toEntity();
    }),
  );

  @override
  Future<void> update(
    String id, {
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  }) => guardStorage(
    () => _dao.updateRow(
      id,
      AccountsCompanion(
        name: Value(name.trim()),
        type: Value(type),
        openingBalanceMinor: Value(openingBalanceMinor),
        iconKey: Value(iconKey),
        colorHex: Value(colorHex),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  /// Whether [account] is the only non-deleted, non-archived account.
  Future<bool> _isLastActive(AccountRow account) async =>
      !account.isArchived &&
      account.deletedAt == null &&
      await _dao.countActive(exceptId: account.id) == 0;

  @override
  Future<void> setArchived(String id, {required bool archived}) => guardStorage(
    () => _db.transaction(() async {
      final account = await _dao.byId(id);
      if (account == null || account.deletedAt != null) return;
      if (archived && await _isLastActive(account)) {
        throw const AccountArchiveNotAllowed();
      }
      await _dao.updateRow(
        id,
        AccountsCompanion(
          isArchived: Value(archived),
          updatedAt: Value(_nowMs()),
        ),
      );
    }),
  );

  @override
  Future<void> delete(String id) => guardStorage(
    () => _db.transaction(() async {
      final account = await _dao.byId(id);
      if (account == null || account.deletedAt != null) return;
      if (await _dao.transactionCount(id) > 0) {
        throw const AccountDeleteNotAllowed(
          AccountDeleteReason.hasTransactions,
        );
      }
      if (await _isLastActive(account)) {
        throw const AccountDeleteNotAllowed(AccountDeleteReason.lastActive);
      }
      final now = _nowMs();
      await _dao.updateRow(
        id,
        AccountsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }),
  );

  @override
  Future<void> undelete(String id) => guardStorage(
    () => _dao.updateRow(
      id,
      AccountsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );
}
