import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:drift/native.dart' show SqliteException;

/// Maps SQLite failures to [ExpenseStorageFailure] so callers only ever see
/// the typed domain errors (contracts/repositories.md).
Future<T> guardStorage<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on SqliteException catch (e) {
    throw ExpenseStorageFailure(e);
  }
}

extension StorageGuardStream<T> on Stream<T> {
  Stream<T> guardStorage() => handleError(
    (Object e) => throw ExpenseStorageFailure(e),
    test: (e) => e is SqliteException,
  );
}
