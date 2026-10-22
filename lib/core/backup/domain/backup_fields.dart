import 'package:dailytrack/core/backup/domain/backup_errors.dart';

/// Typed, validated reads from one backup row (data-model §3). Every
/// failure throws [BackupInvalid] naming the table, row, and field, so a bad
/// file is rejected before anything is written (research R5).
final class BackupFields {
  new(this._row, {required this.table, required this.index});

  /// Wraps [raw] after checking that it is a JSON object.
  factory of(Object? raw, {required String table, required int index}) {
    if (raw is! Map<String, Object?>) {
      throw BackupInvalid('$table[$index] is not an object');
    }
    return BackupFields(raw, table: table, index: index);
  }

  final Map<String, Object?> _row;
  final String table;
  final int index;

  Never _fail(String field, String problem) =>
      throw BackupInvalid('$table[$index].$field $problem');

  /// A string, optionally length-limited (after [trim] when set).
  String string(String field, {int? min, int? max, bool trim = false}) {
    final v = _row[field];
    if (v is! String) _fail(field, 'must be a string');
    final length = (trim ? v.trim() : v).length;
    if (min != null && length < min) _fail(field, 'is shorter than $min');
    if (max != null && length > max) _fail(field, 'is longer than $max');
    return v;
  }

  String? nullableString(String field, {int? max}) {
    if (_row[field] == null) return null;
    return string(field, max: max);
  }

  int integer(String field, {int? min, int? max}) {
    final v = _row[field];
    if (v is! int) _fail(field, 'must be an integer');
    if (min != null && v < min) _fail(field, 'is below $min');
    if (max != null && v > max) _fail(field, 'is above $max');
    return v;
  }

  int? nullableInt(String field, {int? min, int? max}) {
    if (_row[field] == null) return null;
    return integer(field, min: min, max: max);
  }

  bool boolean(String field) {
    final v = _row[field];
    if (v is! bool) _fail(field, 'must be true or false');
    return v;
  }

  /// An enum written by name (research R2).
  T enumByName<T extends Enum>(String field, List<T> values) {
    final name = string(field);
    for (final v in values) {
      if (v.name == name) return v;
    }
    _fail(field, 'has unknown value "$name"');
  }

  /// A string matching [pattern], e.g. a date key.
  String matching(String field, RegExp pattern, String what) {
    final v = string(field);
    if (!pattern.hasMatch(v)) _fail(field, 'is not $what');
    return v;
  }

  /// Reports a cross-field rule; used by codecs for CHECK mirrors.
  Never invalid(String field, String problem) => _fail(field, problem);
}

/// `yyyy-MM-dd`, the same shape the tables' GLOB checks accept.
final RegExp dateKeyPattern = RegExp(r'^\d{4}-[01]\d-[0-3]\d$');

/// `yyyy-MM`.
final RegExp monthKeyPattern = RegExp(r'^\d{4}-[01]\d$');

/// `#RRGGBB`.
final RegExp colorHexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');

/// Reads the list of rows for [table] from a section's `tables` object; a
/// missing table is an empty list (research R7).
List<Object?> tableRows(Map<String, Object?> section, String table) {
  final tables = section['tables'];
  if (tables == null) return const [];
  if (tables is! Map<String, Object?>) {
    throw const BackupInvalid('tables is not an object');
  }
  final rows = tables[table];
  if (rows == null) return const [];
  if (rows is! List<Object?>) throw BackupInvalid('$table is not a list');
  return rows;
}

/// Throws when two rows share an id, or a unique key (data-model §3).
void checkUnique<T>(String table, String what, Iterable<T> keys) {
  final seen = <T>{};
  for (final k in keys) {
    if (!seen.add(k)) throw BackupInvalid('$table has a duplicate $what');
  }
}

/// Throws when [id] is set but missing from [known] (in-section foreign key).
void checkReference(
  String table,
  int index,
  String field,
  String? id,
  Set<String> known,
) {
  if (id != null && !known.contains(id)) {
    throw BackupInvalid('$table[$index].$field refers to a missing row');
  }
}
