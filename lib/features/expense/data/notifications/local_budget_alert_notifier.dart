import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/seed_names.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';
import 'package:dailytrack/features/expense/domain/ports/budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';

/// Tag shared by every budget alert, so they can be cancelled together.
const String budgetAlertTag = 'budget';

/// [BudgetAlertNotifier] over the core [NotificationService] (research R6).
/// Text comes from ARB in the saved or device language, so it also works in
/// a background isolate without a `BuildContext`. The text names only the
/// budget and the percentage, never an amount or a note (FR-020).
final class LocalBudgetAlertNotifier implements BudgetAlertNotifier {
  new({required this.service, required this.l10n, required this.categoryName});

  final NotificationService service;

  /// Localizations to use now (the saved language may change).
  final AppLocalizations Function() l10n;

  /// The stored category name (an ARB key for defaults), or null.
  final Future<String?> Function(String categoryId) categoryName;

  /// The notification [notify] shows for [alert], built from ARB text.
  Future<AppNotification> build(BudgetAlert alert) async {
    final t = l10n();
    final categoryId = alert.categoryId;
    final stored = categoryId == null ? null : await categoryName(categoryId);
    final name = categoryId == null
        ? t.notif_overallBudget
        : localizedSeedName(t, stored ?? t.expense_category);
    final (title, body) = switch (alert.threshold) {
      BudgetThreshold.p80 => (
        t.notif_budget80Title(name, alert.percent),
        t.notif_budget80Body(name, alert.percent),
      ),
      BudgetThreshold.p100 => (
        t.notif_budget100Title(name),
        t.notif_budget100Body(name, alert.percent),
      ),
    };
    return AppNotification(
      id: stableNotificationId('${alert.budgetId}:${alert.threshold.name}'),
      channel: NotificationChannelId.budgetAlerts,
      title: title,
      body: body,
      payload: Routes.expenseBudgetsPath(month: alert.monthKey),
      tag: budgetAlertTag,
    );
  }

  @override
  Future<void> notify(BudgetAlert alert) async =>
      await service.show(await build(alert));

  @override
  Future<void> cancelAll() => service.cancelByTag(budgetAlertTag);
}
