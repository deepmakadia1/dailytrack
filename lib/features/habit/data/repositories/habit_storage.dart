import 'dart:async';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;

/// Maps SQLite failures to [HabitStorageFailure] so callers only ever see
/// the typed domain errors (contracts/repositories.md).
Future<T> guardHabitStorage<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on SqliteException catch (e) {
    throw HabitStorageFailure(e);
  }
}

extension HabitStorageStream<T> on Stream<T> {
  Stream<T> guardHabitStorage() => handleError(
    (Object e) => throw HabitStorageFailure(e),
    test: (e) => e is SqliteException,
  );
}

/// Emits [load] now and again after every write to [tables], coalescing
/// writes that arrive while a load is running.
Stream<T> watchHabitTables<T>(
  AppDatabase db,
  Iterable<ResultSetImplementation<dynamic, dynamic>> tables,
  Future<T> Function() load,
) {
  late final StreamController<T> controller;
  StreamSubscription<Set<TableUpdate>>? updates;
  var loading = false;
  var dirty = false;

  Future<void> reload() async {
    if (loading) {
      dirty = true;
      return;
    }
    loading = true;
    do {
      dirty = false;
      try {
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      } on SqliteException catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(HabitStorageFailure(e), st);
        }
      }
    } while (dirty && !controller.isClosed);
    loading = false;
  }

  controller = StreamController<T>(
    onListen: () {
      updates = db
          .tableUpdates(TableUpdateQuery.onAllTables(tables))
          .listen((_) => unawaited(reload()));
      unawaited(reload());
    },
    onCancel: () => updates?.cancel(),
  );
  return controller.stream;
}
