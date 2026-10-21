import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/daos/categories_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/category_mapper.dart';
import 'package:dailytrack/features/expense/data/repositories/storage_guard.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/category_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Drift implementation of [CategoryRepository] (data-model.md §3.2).
/// Name validation (length, uniqueness across languages) happens in the
/// domain before these calls (`ValidateCategoryName`, T090).
final class DriftCategoryRepository implements CategoryRepository {
  new(AppDatabase db, this._clock) : _db = db, _dao = CategoriesDao(db);

  final AppDatabase _db;
  final CategoriesDao _dao;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  @override
  Stream<List<CategoryWithStats>> watchByType(
    CategoryType type, {
    required Period month,
  }) => _dao
      .watchWithStats(
        type,
        monthStart: month.startUtcMs,
        monthEnd: month.endUtcMsExclusive,
      )
      .map(
        (rows) => [
          for (final r in rows)
            CategoryWithStats(
              category: r.row.toEntity(),
              monthTotalMinor: r.monthTotal,
              usageCount: r.usage,
            ),
        ],
      )
      .guardStorage();

  @override
  Stream<List<Category>> watchPickable(CategoryType type) {
    // The month bounds are irrelevant here; only the usage count orders.
    final month = MonthPeriod(_clock.now());
    return _dao
        .watchWithStats(
          type,
          monthStart: month.startUtcMs,
          monthEnd: month.endUtcMsExclusive,
          pickableOnly: true,
        )
        .map((rows) => [for (final r in rows) r.row.toEntity()])
        .guardStorage();
  }

  @override
  Stream<List<Category>> watchAll() => _dao
      .watchAll()
      .map((rows) => [for (final r in rows) r.toEntity()])
      .guardStorage();

  @override
  Future<Category> create({
    required String name,
    required CategoryType type,
    required String iconKey,
    required String colorHex,
  }) => guardStorage(
    () => _db.transaction(() async {
      final id = _uuid.v4();
      final now = _nowMs();
      await _dao.insertRow(
        CategoriesCompanion.insert(
          id: id,
          name: name.trim(),
          type: type,
          iconKey: iconKey,
          colorHex: colorHex,
          sortOrder: await _dao.nextSortOrder(type),
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
    required String iconKey,
    required String colorHex,
  }) => guardStorage(
    () => _dao.updateRow(
      id,
      CategoriesCompanion(
        name: Value(name.trim()),
        iconKey: Value(iconKey),
        colorHex: Value(colorHex),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<void> setHidden(String id, {required bool hidden}) => guardStorage(
    () => _dao.updateRow(
      id,
      CategoriesCompanion(
        isArchived: Value(hidden),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );

  @override
  Future<void> reorder(CategoryType type, List<String> orderedIds) =>
      guardStorage(
        () => _db.transaction(() async {
          final now = _nowMs();
          for (final (i, id) in orderedIds.indexed) {
            await (_db.update(
              _db.categories,
            )..where((c) => c.id.equals(id) & c.type.equalsValue(type))).write(
              CategoriesCompanion(sortOrder: Value(i), updatedAt: Value(now)),
            );
          }
        }),
      );

  @override
  Future<int> transactionCount(String id) =>
      guardStorage(() => _dao.transactionCount(id));

  @override
  Future<void> delete(String id, {String? replacementId}) => guardStorage(
    () => _db.transaction(() async {
      final category = await _dao.byId(id);
      if (category == null || category.deletedAt != null) return;
      if (category.isDefault) {
        throw const CategoryDeleteNotAllowed(CategoryDeleteReason.isDefault);
      }

      final now = _nowMs();
      if (await _dao.transactionCount(id) > 0) {
        if (replacementId == null) {
          throw const CategoryDeleteNotAllowed(
            CategoryDeleteReason.replacementRequired,
          );
        }
        final replacement = await _dao.byId(replacementId);
        if (replacement == null ||
            replacement.id == id ||
            replacement.deletedAt != null ||
            replacement.type != category.type) {
          throw const CategoryDeleteNotAllowed(
            CategoryDeleteReason.invalidReplacement,
          );
        }
        await _dao.moveTransactions(id, replacementId, now);
      }

      await _dao.updateRow(
        id,
        CategoriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }),
  );

  @override
  Future<void> undelete(String id) => guardStorage(
    () => _dao.updateRow(
      id,
      CategoriesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(_nowMs()),
      ),
    ),
  );
}
