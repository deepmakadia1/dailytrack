import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/daos/categories_dao.dart';
import 'package:dailytrack/features/expense/data/notifications/local_budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/data/notifications/settings_notification_gate.dart';
import 'package:dailytrack/features/expense/data/receipts/file_receipt_store.dart';
import 'package:dailytrack/features/expense/data/receipts/image_receipt_picker.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_account_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_category_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_transaction_repository.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:path_provider/path_provider.dart';

/// The Expense half of the composition root (research R11): binds the Drift
/// repositories and the device receipt services. Only `app/production_overrides.dart` imports
/// this file (checked by the layering scan).
// coverage:ignore-start
List<Override> expenseOverrides() => [
  transactionRepositoryProvider.overrideWith(
    (ref) => DriftTransactionRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  categoryRepositoryProvider.overrideWith(
    (ref) => DriftCategoryRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  accountRepositoryProvider.overrideWith(
    (ref) => DriftAccountRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  budgetRepositoryProvider.overrideWith(
    (ref) => DriftBudgetRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
      ref.watch(settingsRepositoryProvider),
    ),
  ),
  recurringRuleRepositoryProvider.overrideWith(
    (ref) => DriftRecurringRuleRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  budgetAlertNotifierProvider.overrideWith(
    (ref) => LocalBudgetAlertNotifier(
      service: ref.watch(notificationServiceProvider),
      l10n: () => l10nFor(ref.read(appSettingsProvider).value?.locale),
      categoryName: (id) async =>
          (await CategoriesDao(ref.read(appDatabaseProvider)).byId(id))?.name,
    ),
  ),
  notificationGateProvider.overrideWith(
    (ref) => SettingsNotificationGate(
      ref.watch(settingsRepositoryProvider),
      ref.watch(notificationServiceProvider),
    ),
  ),
  receiptStoreProvider.overrideWith(
    (ref) => FileReceiptStore(
      getApplicationDocumentsDirectory,
      ref.watch(clockProvider),
    ),
  ),
  receiptPickerProvider.overrideWith(
    (ref) => ImageReceiptPicker(
      FileReceiptStore(
        getApplicationDocumentsDirectory,
        ref.watch(clockProvider),
      ),
      beforeLeaving: ref
          .read(externalActivityGuardProvider)
          .expectExternalActivity,
    ),
  ),
];
// coverage:ignore-end
