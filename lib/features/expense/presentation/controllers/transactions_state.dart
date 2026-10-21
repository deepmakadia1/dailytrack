import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transactions_state.freezed.dart';

/// EXP-01 state (contracts/screens.md).
@freezed
abstract class TransactionsState with _$TransactionsState {
  const factory({
    /// The session filter (FR-020).
    required TxnQuery query,

    /// Rows of the current page window, newest first.
    required AsyncValue<List<TransactionView>> rows,

    /// Totals for ALL matching rows (summary strip, day headers).
    required AsyncValue<PeriodLedger> ledger,

    /// What the search field shows; applied to [query] after 300 ms.
    @Default('') String searchText,
    @Default(false) bool searchOpen,
    @Default(1) int pageCount,

    /// Every non-deleted category by id (row display, search, filters).
    @Default(<String, Category>{}) Map<String, Category> categories,

    /// Every non-deleted account by id, archived ones too (filters, chips).
    @Default(<String, Account>{}) Map<String, Account> accounts,

    /// Rows deleted a moment ago, hidden until the stream catches up, so a
    /// dismissed row never reappears under the finger.
    @Default(<String>{}) Set<String> hiddenIds,
  }) = _TransactionsState;

  const new _();

  static const int pageSize = 50;

  List<TransactionView>? get visibleRows =>
      rows.value?.where((v) => !hiddenIds.contains(v.transaction.id)).toList();

  bool get hasMore => (rows.value?.length ?? 0) >= pageCount * pageSize;
}
