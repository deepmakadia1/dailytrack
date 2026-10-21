import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// Which filter an EXP-01 chip shows (FR-020). Records compare by value, so
/// chips can be keys and test expectations.
enum FilterKind { type, mode, category, account, amount }

typedef FilterChipId = ({FilterKind kind, Object? value});

/// Pure edits of the EXP-01 session query (T070). Kept out of the
/// controller so EXP-01 has exactly one notifier (Constitution II).
extension TxnQueryOps on TxnQuery {
  TxnQuery withPeriod(Period p) => copyWith(period: p);

  TxnQuery withSearch(String text, Set<String> matchingCategoryIds) =>
      copyWith(search: text, matchingCategoryIds: matchingCategoryIds);

  TxnQuery applyFilters({
    required Set<TxnType> types,
    required Set<PaymentMode> paymentModes,
    required Set<String> categoryIds,
    required Set<String> accountIds,
    required int? minAmountMinor,
    required int? maxAmountMinor,
  }) => copyWith(
    types: types,
    paymentModes: paymentModes,
    categoryIds: categoryIds,
    accountIds: accountIds,
    minAmountMinor: minAmountMinor,
    maxAmountMinor: maxAmountMinor,
  );

  /// One chip per active filter value, in a stable order.
  List<FilterChipId> get chips => [
    for (final t in TxnType.values)
      if (types.contains(t)) (kind: FilterKind.type, value: t),
    for (final m in PaymentMode.values)
      if (paymentModes.contains(m)) (kind: FilterKind.mode, value: m),
    for (final c in categoryIds) (kind: FilterKind.category, value: c),
    for (final a in accountIds) (kind: FilterKind.account, value: a),
    if (minAmountMinor != null || maxAmountMinor != null)
      (kind: FilterKind.amount, value: null),
  ];

  TxnQuery removeChip(FilterChipId chip) => switch (chip.kind) {
    FilterKind.type => copyWith(types: {...types}..remove(chip.value)),
    FilterKind.mode => copyWith(
      paymentModes: {...paymentModes}..remove(chip.value),
    ),
    FilterKind.category => copyWith(
      categoryIds: {...categoryIds}..remove(chip.value),
    ),
    FilterKind.account => copyWith(
      accountIds: {...accountIds}..remove(chip.value),
    ),
    FilterKind.amount => copyWith(minAmountMinor: null, maxAmountMinor: null),
  };

  /// Clears search and every filter, keeping the period.
  TxnQuery cleared() => TxnQuery(period: period);

  /// EXP-06 "tap → filtered EXP-01": the account filter becomes just [id].
  TxnQuery withRouteAccount(String id) => copyWith(accountIds: {id});
}
