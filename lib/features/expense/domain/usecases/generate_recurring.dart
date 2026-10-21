import 'package:clock/clock.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/repositories/recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';

/// Creates every due recurring occurrence (FR-023–FR-025, research R9).
/// Run on app open and from the daily background job; each rule is handled
/// in its own exactly-once transaction, so concurrent or repeated runs never
/// duplicate an occurrence.
final class RecurringGenerator {
  new(this._rules, this._clock, {this.alerts});

  final RecurringRuleRepository _rules;
  final Clock _clock;

  /// Budget alerts for generated expenses in the current month (FR-029).
  /// Optional, so recurring rules work without budgets.
  final BudgetAlertChecker? alerts;

  /// Returns the number of transactions created. Never throws: a failing
  /// rule is skipped and the others still run.
  Future<int> runDue() async {
    final now = _clock.now();
    final List<String> due;
    try {
      due = await _rules.dueRuleIds(now);
    } on Object {
      return 0;
    }
    var created = 0;
    final month = monthKeyOf(now);
    for (final id in due) {
      try {
        final rows = await _rules.generateDue(id, now);
        created += rows.length;
        final checker = alerts;
        if (checker == null) continue;
        for (final t in rows) {
          if (t.type != TxnType.expense) continue;
          if (monthKeyOf(t.occurredAt.toLocal()) != month) continue;
          await checker.check(
            occurredAtUtcMs: t.occurredAt.millisecondsSinceEpoch,
            categoryId: t.categoryId,
            type: t.type,
          );
        }
      } on Object {
        // One bad rule never stops the rest (contracts/repositories.md).
      }
    }
    return created;
  }
}
