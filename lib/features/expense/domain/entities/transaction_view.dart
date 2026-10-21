import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_view.freezed.dart';

/// Read model for EXP-01 rows and EXP-03. Names are raw (key or text); the
/// UI localizes them.
@freezed
abstract class TransactionView with _$TransactionView {
  const factory({
    required Transaction transaction,
    required Account account,
    Category? category,
    Account? toAccount,
  }) = _TransactionView;

  const new _();

  /// Created from (or the first occurrence of) a recurring rule.
  bool get isRecurring => transaction.recurringRuleId != null;
}
