import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';

extension CategoryRowMapper on CategoryRow {
  Category toEntity() => Category(
    id: id,
    name: name,
    type: type,
    iconKey: iconKey,
    colorHex: colorHex,
    isDefault: isDefault,
    isHidden: isArchived,
    sortOrder: sortOrder,
  );
}
