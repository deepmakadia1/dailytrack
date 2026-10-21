import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_transactions_controller.g.dart';

/// DSH-01 Recent transactions (feature 006 research R10): the newest five
/// rows of all time, transfers included, live.
@riverpod
class RecentTransactionsController extends _$RecentTransactionsController {
  @override
  Stream<List<TransactionView>> build() =>
      ref.watch(transactionRepositoryProvider).watchRecent();

  void retry() => ref.invalidateSelf();
}
