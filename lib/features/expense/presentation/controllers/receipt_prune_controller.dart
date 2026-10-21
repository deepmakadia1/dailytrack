import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_prune_controller.g.dart';

/// Deletes orphaned receipt files once per app process (T059, research R8).
/// Read from EXP-01 and EXP-02; never awaited by the UI, and failures are
/// ignored because pruning is housekeeping.
@Riverpod(keepAlive: true)
Future<int> receiptPrune(Ref ref) async {
  try {
    final referenced = await ref
        .read(transactionRepositoryProvider)
        .allReceiptPaths();
    return await ref.read(receiptStoreProvider).pruneOrphans(referenced);
  } on Exception {
    return 0;
  }
}
