import 'package:clock/clock.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/ports/budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/domain/ports/notification_gate.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';

/// Checks budgets after an expense is saved (FR-015–FR-018, research R6).
///
/// Only expenses dated in the current local month are checked
/// (clarification Q2). For the expense's category budget and the Overall
/// budget, the highest newly reached threshold is recorded with a
/// compare-and-set write, so each threshold alerts at most once per budget
/// per month even across isolates and restarts. The notification is shown
/// only when the gate allows it; the marker is recorded either way, so
/// turning notifications back on never sends old alerts.
final class BudgetAlertChecker {
  new(this._budgets, this._notifier, this._gate, this._clock);

  final BudgetRepository _budgets;
  final BudgetAlertNotifier _notifier;
  final NotificationGate _gate;
  final Clock _clock;

  /// Never throws: any failure gives fewer (or no) alerts and leaves the
  /// saved transaction untouched (FR-018). Returns the alerts recorded.
  Future<List<BudgetAlert>> check({
    required int occurredAtUtcMs,
    required String? categoryId,
    required TxnType type,
  }) async {
    if (type != TxnType.expense) return const [];
    final now = _clock.now();
    final month = monthKeyOf(now);
    final occurred = DateTime.fromMillisecondsSinceEpoch(
      occurredAtUtcMs,
      isUtc: true,
    ).toLocal();
    if (monthKeyOf(occurred) != month) return const [];

    final recorded = <BudgetAlert>[];
    try {
      final (:category, :overall) = await _budgets.forAlert(month, categoryId);
      for (final budget in [?category, ?overall]) {
        final alert = await _record(budget, month, now);
        if (alert == null) continue;
        recorded.add(alert);
        await _notify(alert);
      }
    } on Object {
      // Alerts are best effort (FR-018).
    }
    return recorded;
  }

  Future<BudgetAlert?> _record(Budget b, String month, DateTime now) async {
    final spent = await _budgets.spentFor(month, b.categoryId);
    bool hit(BudgetThreshold t) =>
        reaches(t, spentMinor: spent, limitMinor: b.limitMinor);
    // A save that crosses both thresholds sends only the 100% alert; its
    // marker write also records the 80% one.
    final target = hit(BudgetThreshold.p100) && b.alert100SentAt == null
        ? BudgetThreshold.p100
        : hit(BudgetThreshold.p80) && b.alert80SentAt == null
        ? BudgetThreshold.p80
        : null;
    if (target == null) return null;
    final won = await _budgets.markAlertSent(
      b.id,
      target,
      now.toUtc().millisecondsSinceEpoch,
    );
    if (!won) return null;
    return BudgetAlert(
      budgetId: b.id,
      monthKey: month,
      categoryId: b.categoryId,
      threshold: target,
      percent: percentOf(spentMinor: spent, limitMinor: b.limitMinor),
    );
  }

  Future<void> _notify(BudgetAlert alert) async {
    try {
      if (await _gate.budgetAlertsAllowed()) await _notifier.notify(alert);
    } on Object {
      // A broken notification never affects the save.
    }
  }
}
