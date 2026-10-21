import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/daos/transactions_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/account_mapper.dart';
import 'package:dailytrack/features/expense/data/mappers/category_mapper.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:drift/drift.dart';

DateTime _utc(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

int _ms(DateTime t) => t.toUtc().millisecondsSinceEpoch;

/// Blank notes are stored as NULL (data-model.md §3.1).
String? normalizeNote(String? note) {
  final trimmed = note?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

extension TransactionRowMapper on TransactionRow {
  Transaction toEntity() => Transaction(
    id: id,
    type: type,
    amountMinor: amountMinor,
    accountId: accountId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    paymentMode: paymentMode,
    note: note,
    occurredAt: _utc(occurredAt),
    receiptPath: receiptPath,
    recurringRuleId: recurringRuleId,
    createdAt: _utc(createdAt),
    updatedAt: _utc(updatedAt),
    deletedAt: deletedAt == null ? null : _utc(deletedAt!),
  );
}

extension TransactionJoinRowMapper on TransactionJoinRow {
  TransactionView toView() => TransactionView(
    transaction: transaction.toEntity(),
    account: account.toEntity(),
    toAccount: toAccount?.toEntity(),
    category: category?.toEntity(),
  );
}

extension TransactionEntityMapper on Transaction {
  /// Every column, for restoring a snapshot (research R12).
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    type: Value(type),
    amountMinor: Value(amountMinor),
    accountId: Value(accountId),
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    paymentMode: Value(paymentMode),
    note: Value(normalizeNote(note)),
    occurredAt: Value(_ms(occurredAt)),
    receiptPath: Value(receiptPath),
    recurringRuleId: Value(recurringRuleId),
    createdAt: Value(_ms(createdAt)),
    updatedAt: Value(_ms(updatedAt)),
    deletedAt: Value(deletedAt == null ? null : _ms(deletedAt!)),
  );
}

extension TransactionDraftMapper on TransactionDraft {
  /// The user-editable columns. The caller has validated the draft, so the
  /// amount and source account are set.
  TransactionsCompanion toCompanion({required int updatedAt}) =>
      TransactionsCompanion(
        type: Value(type),
        amountMinor: Value(amountMinor!),
        accountId: Value(accountId!),
        toAccountId: Value(toAccountId),
        categoryId: Value(categoryId),
        paymentMode: Value(paymentMode),
        note: Value(normalizeNote(note)),
        occurredAt: Value(_ms(occurredAt)),
        receiptPath: Value(receiptPath),
        updatedAt: Value(updatedAt),
      );
}
