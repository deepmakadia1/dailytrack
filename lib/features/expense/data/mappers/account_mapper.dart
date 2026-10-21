import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';

extension AccountRowMapper on AccountRow {
  Account toEntity() => Account(
    id: id,
    name: name,
    type: type,
    openingBalanceMinor: openingBalanceMinor,
    iconKey: iconKey,
    colorHex: colorHex,
    isArchived: isArchived,
    sortOrder: sortOrder,
  );
}
