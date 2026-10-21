import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// First-launch defaults (FR-025, spec §4): 12 expense categories,
/// 5 income categories and one Cash account. Names are ARB keys so they
/// translate; `SeedRunner` guarantees this runs exactly once.
final class ExpenseDefaultsSeeder implements Seeder {
  const new();

  /// Slug → icon key, in display order.
  static const Map<String, String> _expense = {
    'food': 'restaurant',
    'groceries': 'local_grocery_store',
    'transport': 'directions_bus',
    'fuel': 'local_gas_station',
    'shopping': 'shopping_bag',
    'bills': 'receipt',
    'rent': 'home',
    'health': 'medical_services',
    'education': 'school',
    'entertainment': 'movie',
    'travel': 'flight',
    'other': 'category',
  };

  static const Map<String, String> _income = {
    'salary': 'payments',
    'business': 'storefront',
    'gift': 'redeem',
    'interest': 'savings',
    'other': 'attach_money',
  };

  static List<String> get expenseKeys => [
    for (final slug in _expense.keys) 'expense_cat_$slug',
  ];

  static List<String> get incomeKeys => [
    for (final slug in _income.keys) 'income_cat_$slug',
  ];

  static const String cashAccountKey = 'expense_account_cash';

  @override
  String get id => 'expense.defaults.v1';

  @override
  Future<void> seed(AppDatabase db) async {
    const uuid = Uuid();
    final now = Epoch.nowUtcMs();
    const palette = AppColors.palette;

    CategoriesCompanion category(
      CategoryType type,
      String name,
      String icon,
      int order,
      int colorIndex,
    ) => CategoriesCompanion.insert(
      id: uuid.v4(),
      name: name,
      type: type,
      iconKey: icon,
      colorHex: AppColors.toHex(palette[colorIndex % palette.length]),
      isDefault: const Value(true),
      sortOrder: order,
      createdAt: now,
      updatedAt: now,
    );

    final expense = _expense.entries.toList();
    final income = _income.entries.toList();
    await db.batch((b) {
      b
        ..insertAll(db.categories, [
          for (var i = 0; i < expense.length; i++)
            category(
              CategoryType.expense,
              'expense_cat_${expense[i].key}',
              expense[i].value,
              i,
              i,
            ),
          for (var i = 0; i < income.length; i++)
            category(
              CategoryType.income,
              'income_cat_${income[i].key}',
              income[i].value,
              i,
              expense.length + i,
            ),
        ])
        ..insert(
          db.accounts,
          AccountsCompanion.insert(
            id: uuid.v4(),
            name: cashAccountKey,
            type: AccountType.cash,
            iconKey: 'wallet',
            colorHex: AppColors.toHex(palette[6]),
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    });
  }
}
