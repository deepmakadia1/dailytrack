import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'txn_query.freezed.dart';

/// The EXP-01 session filter (FR-020). Empty sets mean "no filter".
@freezed
abstract class TxnQuery with _$TxnQuery {
  const factory({
    required Period period,

    /// Raw search text; blank means no search.
    @Default('') String search,

    /// Categories whose displayed (localized) name matches [search],
    /// resolved by the controller (research R5).
    @Default(<String>{}) Set<String> matchingCategoryIds,
    @Default(<String>{}) Set<String> categoryIds,

    /// Matches either the source or the destination account.
    @Default(<String>{}) Set<String> accountIds,
    @Default(<PaymentMode>{}) Set<PaymentMode> paymentModes,
    @Default(<TxnType>{}) Set<TxnType> types,
    int? minAmountMinor,
    int? maxAmountMinor,
  }) = _TxnQuery;

  const new _();

  bool get hasSearch => search.trim().isNotEmpty;

  /// Any narrowing beyond the period (drives the "No matches" empty state).
  bool get isFiltered =>
      hasSearch ||
      categoryIds.isNotEmpty ||
      accountIds.isNotEmpty ||
      paymentModes.isNotEmpty ||
      types.isNotEmpty ||
      minAmountMinor != null ||
      maxAmountMinor != null;
}
