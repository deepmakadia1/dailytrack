import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/data/daos/recurring_rules_dao.dart';
import 'package:dailytrack/features/expense/data/daos/transactions_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/account_mapper.dart';
import 'package:dailytrack/features/expense/data/mappers/category_mapper.dart';
import 'package:dailytrack/features/expense/data/mappers/recurring_rule_mapper.dart';
import 'package:dailytrack/features/expense/data/mappers/transaction_mapper.dart';
import 'package:dailytrack/features/expense/data/repositories/storage_guard.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Another run advanced the rule first; the transaction rolls back
/// (research R9). Never leaves the data layer.
final class RuleChangedConcurrently implements Exception {
  const new();
}

/// Drift implementation of [RecurringRuleRepository] (research R8, R9, R16).
final class DriftRecurringRuleRepository implements RecurringRuleRepository {
  new(AppDatabase db, this._clock)
    : _db = db,
      _dao = RecurringRulesDao(db),
      _txns = TransactionsDao(db);

  final AppDatabase _db;
  final RecurringRulesDao _dao;
  final TransactionsDao _txns;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  static int _ms(DateTime t) => t.toUtc().millisecondsSinceEpoch;

  static RecurrenceSchedule _schedule(RecurringRuleRow r) => RecurrenceSchedule(
    anchorLocal: DateTime.fromMillisecondsSinceEpoch(r.anchorAt).toLocal(),
    frequency: r.frequency,
    interval: r.interval,
  );

  static bool _withinEnd(int atMs, int? endAt) =>
      endAt == null || atMs <= endAt;

  @override
  Stream<List<RecurringRuleView>> watchAll() => _dao
      .watchAll()
      .map(
        (rows) => [
          for (final r in rows)
            RecurringRuleView(
              rule: r.rule.toEntity(),
              account: r.account.toEntity(),
              toAccount: r.toAccount?.toEntity(),
              category: r.category?.toEntity(),
            ),
        ],
      )
      .guardStorage();

  @override
  Future<RecurringRule?> findById(String id) =>
      guardStorage(() async => (await _dao.rawById(id))?.toEntity());

  /// Inserts a new active rule whose first occurrence is [anchor].
  Future<RecurringRuleRow> _insertRule(
    TransactionDraft draft,
    RepeatSettings repeat,
    DateTime anchor,
  ) async {
    final id = _uuid.v4();
    final now = _nowMs();
    final schedule = RecurrenceSchedule(
      anchorLocal: anchor.toLocal(),
      frequency: repeat.frequency,
    );
    final next = _ms(schedule.occurrence(1));
    final endAt = repeat.endAt == null ? null : _ms(repeat.endAt!);
    await _dao.insertRule(
      draft.toRuleTemplate().copyWith(
        id: Value(id),
        frequency: Value(repeat.frequency),
        interval: const Value(1),
        anchorAt: Value(_ms(anchor)),
        nextRunAt: Value(next),
        endAt: Value(endAt),
        isActive: Value(_withinEnd(next, endAt)),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return (await _dao.rawById(id))!;
  }

  @override
  Future<({Transaction txn, RecurringRule rule})> createWithFirstOccurrence(
    TransactionDraft draft,
    RepeatSettings repeat,
  ) => guardStorage(
    () => _db.transaction(() async {
      final rule = await _insertRule(draft, repeat, draft.occurredAt);
      final id = _uuid.v4();
      final now = _nowMs();
      await _txns.insertRow(
        draft
            .toCompanion(updatedAt: now)
            .copyWith(
              id: Value(id),
              createdAt: Value(now),
              recurringRuleId: Value(rule.id),
            ),
      );
      return (
        txn: (await _txns.rawById(id))!.toEntity(),
        rule: rule.toEntity(),
      );
    }),
  );

  @override
  Future<({Transaction txn, RecurringRule rule})> attachNewRule(
    String txnId,
    TransactionDraft draft,
    RepeatSettings repeat,
  ) => guardStorage(
    () => _db.transaction(() async {
      final row = await _txns.rawById(txnId);
      if (row == null || row.deletedAt != null) {
        throw TransactionNotFound(txnId);
      }
      if (row.recurringRuleId != null) throw TransactionAlreadyLinked(txnId);
      final rule = await _insertRule(draft, repeat, draft.occurredAt);
      await _txns.updateActive(
        txnId,
        draft
            .toCompanion(updatedAt: _nowMs())
            .copyWith(recurringRuleId: Value(rule.id)),
      );
      return (
        txn: (await _txns.rawById(txnId))!.toEntity(),
        rule: rule.toEntity(),
      );
    }),
  );

  @override
  Future<void> undoRuleCreation(
    String ruleId, {
    Transaction? restoreSnapshot,
  }) => guardStorage(
    () => _db.transaction(() async {
      final now = _nowMs();
      if (restoreSnapshot case final snapshot?) {
        // The entry was unlinked before Repeat was turned on (Q3).
        await _txns.updateActive(
          snapshot.id,
          snapshot.copyWith(recurringRuleId: null).toCompanion(),
        );
      }
      await _dao.deleteLinked(ruleId, now, keepId: restoreSnapshot?.id);
      await _dao.updateAny(
        ruleId,
        RecurringRulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }),
  );

  @override
  Future<RecurringRule> updateRule(
    String id,
    TransactionDraft template,
    RepeatSettings repeat,
    DateTime nextDateLocal,
  ) => guardStorage(
    () => _db.transaction(() async {
      final old = await _dao.liveById(id);
      if (old == null) throw RuleNotFound(id);
      final schedule = RecurrenceSchedule(
        anchorLocal: nextDateLocal.toLocal(),
        frequency: repeat.frequency,
        interval: old.interval,
      );
      final now = _clock.now();
      // Future occurrences only: never before now.
      final base = nextDateLocal.isAfter(now) ? nextDateLocal : now;
      final next = _ms(schedule.occurrence(schedule.indexAtOrAfter(base)));
      final endAt = repeat.endAt == null ? null : _ms(repeat.endAt!);
      final wasRunnable = old.isActive || old.toEntity().isEnded;
      await _dao.updateLive(
        id,
        template.toRuleTemplate().copyWith(
          frequency: Value(repeat.frequency),
          anchorAt: Value(_ms(nextDateLocal)),
          nextRunAt: Value(next),
          endAt: Value(endAt),
          isActive: Value(wasRunnable && _withinEnd(next, endAt)),
          updatedAt: Value(_nowMs()),
        ),
      );
      return (await _dao.rawById(id))!.toEntity();
    }),
  );

  @override
  Future<void> restoreRule(RecurringRule snapshot) =>
      guardStorage(() => _dao.updateAny(snapshot.id, snapshot.toCompanion()));

  @override
  Future<void> pause(String id) => guardStorage(() async {
    final changed = await _dao.updateLive(
      id,
      RecurringRulesCompanion(
        isActive: const Value(false),
        updatedAt: Value(_nowMs()),
      ),
    );
    if (changed == 0) throw RuleNotFound(id);
  });

  @override
  Future<void> resume(String id) => guardStorage(
    () => _db.transaction(() async {
      final rule = await _dao.liveById(id);
      if (rule == null) throw RuleNotFound(id);
      // Occurrences that fell during the pause are skipped (US3 s10).
      final next = _ms(_schedule(rule).firstAfter(_clock.now()));
      await _dao.updateLive(
        id,
        RecurringRulesCompanion(
          nextRunAt: Value(math.max(next, rule.nextRunAt)),
          isActive: Value(_withinEnd(next, rule.endAt)),
          updatedAt: Value(_nowMs()),
        ),
      );
    }),
  );

  @override
  Future<void> softDelete(String id) => guardStorage(
    () => _dao.updateAny(
      id,
      RecurringRulesCompanion(
        deletedAt: Value(_nowMs()),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<void> undelete(String id) => guardStorage(
    () => _dao.updateAny(
      id,
      RecurringRulesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<List<String>> dueRuleIds(DateTime now) =>
      guardStorage(() => _dao.dueIds(_ms(now)));

  @override
  Future<List<Transaction>> generateDue(String ruleId, DateTime now) async {
    try {
      return await guardStorage(
        () => _db.transaction(() => _generate(ruleId, now)),
      );
    } on RuleChangedConcurrently {
      return const [];
    }
  }

  /// Research R9, inside one transaction: re-read, insert every due
  /// occurrence, then compare-and-set the next run. Any failure rolls the
  /// whole rule back, so an interrupted run never duplicates or skips.
  Future<List<Transaction>> _generate(String ruleId, DateTime now) async {
    final rule = await _dao.liveById(ruleId);
    final nowMs = _ms(now);
    if (rule == null || !rule.isActive || rule.nextRunAt > nowMs) {
      return const [];
    }
    final schedule = _schedule(rule);
    var n = schedule.indexAtOrAfter(
      DateTime.fromMillisecondsSinceEpoch(rule.nextRunAt, isUtc: true),
    );
    final stamp = _nowMs();
    final rows = <TransactionsCompanion>[];
    while (true) {
      final at = schedule.occurrence(n);
      final atMs = _ms(at);
      if (atMs > nowMs || !_withinEnd(atMs, rule.endAt)) break;
      rows.add(
        rule.occurrenceRow(txnId: _uuid.v4(), occurredAt: at, now: stamp),
      );
      n++;
    }
    final next = _ms(schedule.occurrence(n));
    await _db.batch((b) => b.insertAll(_db.transactions, rows));
    final changed = await _dao.advance(
      ruleId,
      expectedNextRunAt: rule.nextRunAt,
      nextRunAt: math.max(next, rule.nextRunAt),
      isActive: _withinEnd(next, rule.endAt),
      now: stamp,
    );
    if (changed != 1) throw const RuleChangedConcurrently();
    return [
      for (final r in rows) (await _txns.rawById(r.id.value))!.toEntity(),
    ];
  }
}
