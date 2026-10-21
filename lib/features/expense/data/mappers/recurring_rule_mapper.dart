import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/mappers/transaction_mapper.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:drift/drift.dart';

DateTime _utc(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

int _ms(DateTime t) => t.toUtc().millisecondsSinceEpoch;

extension RecurringRuleRowMapper on RecurringRuleRow {
  RecurringRule toEntity() => RecurringRule(
    id: id,
    type: templateType,
    amountMinor: amountMinor,
    accountId: accountId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    paymentMode: paymentMode,
    note: note,
    frequency: frequency,
    interval: interval,
    anchorAt: _utc(anchorAt),
    nextRunAt: _utc(nextRunAt),
    endAt: endAt == null ? null : _utc(endAt!),
    isActive: isActive,
    createdAt: _utc(createdAt),
    updatedAt: _utc(updatedAt),
    deletedAt: deletedAt == null ? null : _utc(deletedAt!),
  );

  /// One generated occurrence: a copy of the template at [occurredAt],
  /// linked to this rule (research R9).
  TransactionsCompanion occurrenceRow({
    required String txnId,
    required DateTime occurredAt,
    required int now,
  }) => TransactionsCompanion.insert(
    id: txnId,
    type: templateType,
    amountMinor: amountMinor,
    accountId: accountId,
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    paymentMode: paymentMode,
    note: Value(note),
    occurredAt: _ms(occurredAt),
    recurringRuleId: Value(id),
    createdAt: now,
    updatedAt: now,
  );
}

extension RecurringRuleEntityMapper on RecurringRule {
  /// Every column, for restoring a snapshot (rule-edit Undo).
  RecurringRulesCompanion toCompanion() => RecurringRulesCompanion(
    id: Value(id),
    templateType: Value(type),
    amountMinor: Value(amountMinor),
    accountId: Value(accountId),
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    paymentMode: Value(paymentMode),
    note: Value(normalizeNote(note)),
    frequency: Value(frequency),
    interval: Value(interval),
    anchorAt: Value(_ms(anchorAt)),
    nextRunAt: Value(_ms(nextRunAt)),
    endAt: Value(endAt == null ? null : _ms(endAt!)),
    isActive: Value(isActive),
    createdAt: Value(_ms(createdAt)),
    updatedAt: Value(_ms(updatedAt)),
    deletedAt: Value(deletedAt == null ? null : _ms(deletedAt!)),
  );
}

extension RuleTemplateMapper on TransactionDraft {
  /// The template columns of a rule from an EXP-02 draft (already
  /// validated, so amount and account are set).
  RecurringRulesCompanion toRuleTemplate() => RecurringRulesCompanion(
    templateType: Value(type),
    amountMinor: Value(amountMinor!),
    accountId: Value(accountId!),
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    paymentMode: Value(paymentMode),
    note: Value(normalizeNote(note)),
  );
}
