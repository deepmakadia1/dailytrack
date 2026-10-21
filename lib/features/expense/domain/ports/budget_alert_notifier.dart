import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';

/// Sends one budget alert (research R6). Implemented in data with the core
/// `NotificationService` and ARB text.
abstract interface class BudgetAlertNotifier {
  Future<void> notify(BudgetAlert alert);

  /// Removes every shown budget alert (`ExpenseModule.onDisable`, FR-043).
  Future<void> cancelAll();
}
