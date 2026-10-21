import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/daos/budgets_dao.dart';
import 'package:dailytrack/features/expense/data/daos/transactions_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/budget_mapper.dart';
import 'package:dailytrack/features/expense/data/mappers/category_mapper.dart';
import 'package:dailytrack/features/expense/data/repositories/storage_guard.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:uuid/uuid.dart';

/// Drift implementation of [BudgetRepository] (research R4–R7).
final class DriftBudgetRepository implements BudgetRepository {
  new(AppDatabase db, this._clock, this._settings)
    : _db = db,
      _dao = BudgetsDao(db),
      _txns = TransactionsDao(db);

  final AppDatabase _db;
  final BudgetsDao _dao;
  final TransactionsDao _txns;
  final Clock _clock;
  final SettingsRepository _settings;
  static const Uuid _uuid = Uuid();

  /// Module-state key of the rollover marker (research R7).
  static const String rolloverMarkerKey = 'expense.budgetRolloverMonth';

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  /// SQLite reports a unique index violation as SQLITE_CONSTRAINT_UNIQUE.
  static bool _isUniqueViolation(Object e) =>
      e is SqliteException && e.extendedResultCode == 2067;

  /// Expense totals per category for [monthKey], from the same predicate as
  /// the EXP-01 ledger (research R11).
  Future<Map<String?, int>> _spentByCategory(String monthKey) async {
    final groups = await _txns.expenseGroups(
      TxnQuery(period: MonthPeriod(monthStartLocal(monthKey))),
    );
    final spent = <String?, int>{};
    for (final (category, _, _, sum) in groups) {
      spent[category] = (spent[category] ?? 0) + sum;
    }
    return spent;
  }

  Future<int> _spent(String monthKey, String? categoryId) async {
    final byCategory = await _spentByCategory(monthKey);
    return categoryId == null
        ? byCategory.values.fold<int>(0, (s, v) => s + v)
        : byCategory[categoryId] ?? 0;
  }

  Future<BudgetsOverview> _load(String monthKey) => _db.transaction(() async {
    final now = _clock.now();
    final rows = await _dao.liveForMonth(monthKey);
    final spent = await _spentByCategory(monthKey);
    final total = spent.values.fold<int>(0, (s, v) => s + v);
    final expenseCategories =
        await (_db.select(_db.categories)
              ..where(
                (c) =>
                    c.deletedAt.isNull() &
                    c.isArchived.equals(false) &
                    c.type.equalsValue(CategoryType.expense),
              )
              ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
            .get();

    BudgetStatus? overall;
    final categories = <BudgetStatus>[];
    for (final (:budget, :category) in rows) {
      final b = budget.toEntity();
      if (b.isOverall) {
        overall = buildBudgetStatus(
          budget: b,
          spentMinor: total,
          nowLocal: now,
        );
      } else {
        categories.add(
          buildBudgetStatus(
            budget: b,
            spentMinor: spent[b.categoryId] ?? 0,
            nowLocal: now,
            category: category?.toEntity(),
            categoryHidden:
                category == null ||
                category.isArchived ||
                category.deletedAt != null,
          ),
        );
      }
    }
    categories.sort((a, b) {
      final byPercent = b.percent.compareTo(a.percent);
      if (byPercent != 0) return byPercent;
      return (a.category?.sortOrder ?? 0).compareTo(b.category?.sortOrder ?? 0);
    });
    final budgeted = {for (final s in categories) s.budget.categoryId};
    return BudgetsOverview(
      monthKey: monthKey,
      monthPhase: monthPhase(monthKey, now),
      overall: overall,
      categories: categories,
      withoutBudget: [
        for (final c in expenseCategories)
          if (!budgeted.contains(c.id)) c.toEntity(),
      ],
    );
  });

  @override
  Stream<BudgetsOverview> watchOverview(String monthKey) {
    late final StreamController<BudgetsOverview> controller;
    StreamSubscription<Set<TableUpdate>>? updates;
    Timer? midnight;
    var loading = false;
    var dirty = false;

    // Reloads after every change, coalescing changes that arrive mid-load.
    Future<void> reload() async {
      if (loading) {
        dirty = true;
        return;
      }
      loading = true;
      do {
        dirty = false;
        try {
          final overview = await _load(monthKey);
          if (!controller.isClosed) controller.add(overview);
        } on SqliteException catch (e, st) {
          if (!controller.isClosed) {
            controller.addError(ExpenseStorageFailure(e), st);
          }
        }
      } while (dirty && !controller.isClosed);
      loading = false;
    }

    // Days left change at local midnight even when nothing is written.
    void armMidnight() {
      final now = _clock.now();
      final next = DateTime(now.year, now.month, now.day + 1);
      midnight = Timer(next.difference(now), () {
        unawaited(reload());
        armMidnight();
      });
    }

    controller = StreamController<BudgetsOverview>(
      onListen: () {
        updates = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                _db.budgets,
                _db.transactions,
                _db.categories,
              ]),
            )
            .listen((_) => unawaited(reload()));
        armMidnight();
        unawaited(reload());
      },
      onCancel: () async {
        midnight?.cancel();
        await updates?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<Budget?> findById(String id) =>
      guardStorage(() async => (await _dao.liveById(id))?.toEntity());

  @override
  Future<({Budget? category, Budget? overall})> forAlert(
    String monthKey,
    String? categoryId,
  ) => guardStorage(() async {
    final overall = await _dao.liveSlot(monthKey, null);
    final category = categoryId == null
        ? null
        : await _dao.liveSlot(monthKey, categoryId);
    return (category: category?.toEntity(), overall: overall?.toEntity());
  });

  @override
  Future<int> spentFor(String monthKey, String? categoryId) =>
      guardStorage(() => _spent(monthKey, categoryId));

  @override
  Future<Budget> create(BudgetDraft draft) async {
    final id = _uuid.v4();
    final now = _nowMs();
    try {
      await _dao.insertRow(
        BudgetsCompanion.insert(
          id: id,
          categoryId: Value(draft.categoryId),
          monthKey: draft.monthKey,
          limitMinor: draft.limitMinor,
          rollover: draft.rollover,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on Object catch (e) {
      if (_isUniqueViolation(e)) throw const BudgetSlotTaken();
      if (e is SqliteException) throw ExpenseStorageFailure(e);
      rethrow;
    }
    return (await findById(id))!;
  }

  @override
  Future<Budget> update(
    String id, {
    required int limitMinor,
    required bool rollover,
  }) => guardStorage(
    () => _db.transaction(() async {
      final row = await _dao.liveById(id);
      if (row == null) throw BudgetNotFound(id);
      final spent = await _spent(row.monthKey, row.categoryId);
      bool still(BudgetThreshold t) =>
          reaches(t, spentMinor: spent, limitMinor: limitMinor);
      // Q4: a marker whose threshold is no longer reached is cleared, so it
      // can alert once more; reached ones stay set.
      await _dao.updateLive(
        id,
        BudgetsCompanion(
          limitMinor: Value(limitMinor),
          rollover: Value(rollover),
          alert80SentAt: still(BudgetThreshold.p80)
              ? const Value.absent()
              : const Value(null),
          alert100SentAt: still(BudgetThreshold.p100)
              ? const Value.absent()
              : const Value(null),
          updatedAt: Value(_nowMs()),
        ),
      );
      return (await _dao.liveById(id))!.toEntity();
    }),
  );

  @override
  Future<void> softDelete(String id) =>
      guardStorage(() => _dao.setDeletedAt(id, _nowMs(), _nowMs()));

  @override
  Future<void> undelete(String id) async {
    try {
      await _dao.setDeletedAt(id, null, _nowMs());
    } on Object catch (e) {
      if (_isUniqueViolation(e)) throw const BudgetSlotTaken();
      if (e is SqliteException) throw ExpenseStorageFailure(e);
      rethrow;
    }
  }

  /// Copies [rows] into [targetMonth]'s empty slots; returns the count.
  Future<int> _copyInto(String targetMonth, List<BudgetRow> rows) async {
    var copied = 0;
    final now = _nowMs();
    for (final row in rows) {
      if (await _dao.slotTaken(targetMonth, row.categoryId)) continue;
      await _dao.insertRow(row.copyTo(targetMonth, id: _uuid.v4(), now: now));
      copied++;
    }
    return copied;
  }

  @override
  Future<int> copyPreviousMonth(String monthKey) => guardStorage(
    () => _db.transaction(() async {
      final source = shiftMonthKey(monthKey, -1);
      return await _copyInto(monthKey, await _dao.copyableForMonth(source));
    }),
  );

  @override
  Future<void> rolloverIfNeeded(String currentMonthKey) => guardStorage(
    () => _db.transaction(() async {
      final done = await _settings.readModuleState(rolloverMarkerKey);
      // Also skips when the clock moved back to an earlier month.
      if (done != null && done.compareTo(currentMonthKey) >= 0) return;
      final source = await _dao.latestMonthBefore(currentMonthKey);
      if (source != null) {
        await _copyInto(
          currentMonthKey,
          await _dao.copyableForMonth(source, rolloverOnly: true),
        );
      }
      await _settings.writeModuleState(rolloverMarkerKey, currentMonthKey);
    }),
  );

  @override
  Future<bool> markAlertSent(
    String id,
    BudgetThreshold threshold,
    int atUtcMs,
  ) => guardStorage(() async {
    final changed = switch (threshold) {
      BudgetThreshold.p80 => await _dao.markAlert80(id, atUtcMs),
      BudgetThreshold.p100 => await _dao.markAlert100(id, atUtcMs),
    };
    return changed == 1;
  });
}
