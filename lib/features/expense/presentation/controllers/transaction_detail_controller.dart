import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_detail_controller.g.dart';

/// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
/// or not, or null when it does not exist.
@riverpod
Future<RecurringRule?> detailRule(Ref ref, String ruleId) =>
    ref.watch(recurringRuleRepositoryProvider).findById(ruleId);

/// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
/// only notifier. Emits null when the row is missing or was deleted
/// elsewhere.
@riverpod
class TransactionDetailController extends _$TransactionDetailController {
  @override
  Stream<TransactionView?> build(String id) =>
      ref.watch(transactionRepositoryProvider).watchById(id);

  /// Soft-deletes the entry; returns its undo, or null if it failed.
  Future<Future<void> Function()?> delete() async {
    final repo = ref.read(transactionRepositoryProvider);
    try {
      await repo.softDelete(id);
    } on ExpenseStorageFailure {
      return null;
    }
    return () => repo.undelete(id);
  }

  /// A plain-text summary for the share sheet. Never includes the receipt.
  String shareText(AppLocalizations l10n, String currency) {
    final view = state.value;
    if (view == null) return '';
    final t = view.transaction;
    final category = view.category;
    final to = view.toAccount;
    final main = l10n.expense_shareText(
      l10n.txnType(t.type),
      MoneyFormatter.format(t.amountMinor, currencyCode: currency),
      switch ((category, to)) {
        (_, final to?) when t.isTransfer => l10n.expense_transferLabel(
          l10n.accountName(view.account),
          l10n.accountName(to),
        ),
        (final c?, _) => l10n.categoryName(c),
        _ => l10n.txnType(t.type),
      },
      l10n.accountName(view.account),
      formatFullDateTime(
        t.occurredAt.toLocal(),
        ref.read(fullDateFormatProvider),
        l10n.localeName,
      ),
    );
    final note = t.note;
    return note == null ? main : '$main\n${l10n.expense_shareNote(note)}';
  }
}
