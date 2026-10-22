import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// `categories` rows in a backup (feature 008 data-model §3).
abstract final class CategoryCodec {
  static const String table = 'categories';

  static Map<String, Object?> encode(CategoryRow r) => {
    'id': r.id,
    'name': r.name,
    'type': r.type.name,
    'iconKey': r.iconKey,
    'colorHex': r.colorHex,
    'isDefault': r.isDefault,
    'isArchived': r.isArchived,
    'sortOrder': r.sortOrder,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: name 1–40 chars, `#RRGGBB` color.
  static CategoryRow decode(BackupFields f) => CategoryRow(
    id: f.string('id', min: 1),
    name: f.string('name', min: 1, max: 40),
    type: f.enumByName('type', CategoryType.values),
    iconKey: f.string('iconKey'),
    colorHex: f.matching('colorHex', colorHexPattern, '#RRGGBB'),
    isDefault: f.boolean('isDefault'),
    isArchived: f.boolean('isArchived'),
    sortOrder: f.integer('sortOrder'),
    createdAt: f.integer('createdAt'),
    updatedAt: f.integer('updatedAt'),
    deletedAt: f.nullableInt('deletedAt'),
  );
}
