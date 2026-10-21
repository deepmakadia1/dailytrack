import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_rule.freezed.dart';

/// A template that creates transactions on a schedule (spec §4
/// recurring_rules, data-model.md §3.1, §4). Pure Dart.
@freezed
abstract class RecurringRule with _$RecurringRule {
  const factory({
    required String id,
    required TxnType type,
    required int amountMinor,
    required String accountId,
    required PaymentMode paymentMode,
    required Frequency frequency,
    required int interval,

    /// UTC of the first occurrence; the schedule is computed from it.
    required DateTime anchorAt,

    /// UTC of the next occurrence not yet generated.
    required DateTime nextRunAt,

    /// False when paused or ended.
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? toAccountId,
    String? categoryId,
    String? note,

    /// UTC, inclusive. Null = no end.
    DateTime? endAt,
    DateTime? deletedAt,
  }) = _RecurringRule;

  const new _();

  /// Past its end date: shown under "Paused" as "Ended" (research R9).
  bool get isEnded => !isActive && endAt != null && nextRunAt.isAfter(endAt!);
}

/// EXP-10 row: the rule with its display references.
@freezed
abstract class RecurringRuleView with _$RecurringRuleView {
  const factory({
    required RecurringRule rule,
    required Account account,
    Account? toAccount,
    Category? category,
  }) = _RecurringRuleView;

  const new _();

  /// An archived account or a hidden category: EXP-10 shows a warning so
  /// the user can update the rule (spec edge case). Generation continues.
  bool get staleReference =>
      account.isArchived ||
      (toAccount?.isArchived ?? false) ||
      (category?.isHidden ?? false);
}
