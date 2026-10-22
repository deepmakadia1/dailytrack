import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// `accounts` rows in a backup (feature 008 data-model §3). Enums by name.
abstract final class AccountCodec {
  static const String table = 'accounts';

  static Map<String, Object?> encode(AccountRow r) => {
    'id': r.id,
    'name': r.name,
    'type': r.type.name,
    'openingBalanceMinor': r.openingBalanceMinor,
    'iconKey': r.iconKey,
    'colorHex': r.colorHex,
    'isArchived': r.isArchived,
    'sortOrder': r.sortOrder,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: name 1–40 chars, `#RRGGBB` color.
  static AccountRow decode(BackupFields f) => AccountRow(
    id: f.string('id', min: 1),
    name: f.string('name', min: 1, max: 40),
    type: f.enumByName('type', AccountType.values),
    openingBalanceMinor: f.integer('openingBalanceMinor'),
    iconKey: f.string('iconKey'),
    colorHex: f.matching('colorHex', colorHexPattern, '#RRGGBB'),
    isArchived: f.boolean('isArchived'),
    sortOrder: f.integer('sortOrder'),
    createdAt: f.integer('createdAt'),
    updatedAt: f.integer('updatedAt'),
    deletedAt: f.nullableInt('deletedAt'),
  );
}
