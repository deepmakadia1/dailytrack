// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rules_dao.dart';

// ignore_for_file: type=lint
mixin _$RecurringRulesDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $RecurringRulesTable get recurringRules => attachedDatabase.recurringRules;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  RecurringRulesDaoManager get managers => RecurringRulesDaoManager(this);
}

class RecurringRulesDaoManager {
  final _$RecurringRulesDaoMixin _db;
  RecurringRulesDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringRules,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
