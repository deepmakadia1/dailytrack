import 'package:dailytrack/core/l10n/default_name_catalog.dart';
import 'package:dailytrack/core/l10n/default_name_catalog_impl.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/domain/ports/budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/domain/ports/notification_gate.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_store.dart';
import 'package:dailytrack/features/expense/domain/repositories/account_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/category_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/transaction_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';
import 'package:dailytrack/features/expense/domain/usecases/generate_recurring.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_providers.g.dart';

// Typed to domain interfaces and free of data/, Drift and plugin imports, so
// presentation code can depend on them (Constitution II, research R11).
// `expense_bindings.dart` binds the real implementations (only
// production_overrides.dart imports it); widget tests bind fakes through
// `pumpTestApp`.

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    throw UnimplementedError(
      'transactionRepositoryProvider must be overridden',
    );

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    throw UnimplementedError('categoryRepositoryProvider must be overridden');

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) =>
    throw UnimplementedError('accountRepositoryProvider must be overridden');

/// Budgets store (feature 003, T040).
@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) =>
    throw UnimplementedError('budgetRepositoryProvider must be overridden');

/// Sends budget alerts (feature 003 T057). Bound to the local notifier.
/// Named explicitly: the generator would drop the "Notifier" suffix.
@Riverpod(keepAlive: true, name: 'budgetAlertNotifierProvider')
BudgetAlertNotifier budgetAlertNotifier(Ref ref) =>
    throw UnimplementedError('budgetAlertNotifierProvider must be overridden');

/// Settings and OS permission check for budget alerts (FR-018).
@Riverpod(keepAlive: true)
NotificationGate notificationGate(Ref ref) =>
    throw UnimplementedError('notificationGateProvider must be overridden');

/// The budget alert check run after each EXP-02 save (FR-015). Composed
/// from the bound repository, ports and clock; needs no binding itself.
@Riverpod(keepAlive: true)
BudgetAlertChecker budgetAlertChecker(Ref ref) => BudgetAlertChecker(
  ref.watch(budgetRepositoryProvider),
  ref.watch(budgetAlertNotifierProvider),
  ref.watch(notificationGateProvider),
  ref.watch(clockProvider),
);

/// Recurring rules store (feature 003, T075).
@Riverpod(keepAlive: true)
RecurringRuleRepository recurringRuleRepository(Ref ref) =>
    throw UnimplementedError(
      'recurringRuleRepositoryProvider must be overridden',
    );

/// Creates due recurring entries on app open and from the daily job
/// (FR-023–FR-025). Composed from bound providers; needs no binding.
@Riverpod(keepAlive: true)
RecurringGenerator recurringGenerator(Ref ref) => RecurringGenerator(
  ref.watch(recurringRuleRepositoryProvider),
  ref.watch(clockProvider),
  alerts: ref.watch(budgetAlertCheckerProvider),
);

@Riverpod(keepAlive: true)
ReceiptPicker receiptPicker(Ref ref) =>
    throw UnimplementedError('receiptPickerProvider must be overridden');

@Riverpod(keepAlive: true)
ReceiptStore receiptStore(Ref ref) =>
    throw UnimplementedError('receiptStoreProvider must be overridden');

/// Translations of default names for the EXP-05 duplicate check (Q5). The
/// core implementation needs no binding; tests may override it.
@Riverpod(keepAlive: true)
DefaultNameCatalog defaultNameCatalog(Ref ref) =>
    const L10nDefaultNameCatalog();
