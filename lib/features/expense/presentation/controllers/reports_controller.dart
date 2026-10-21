import 'dart:async';

import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/report_access.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:dailytrack/features/expense/presentation/controllers/reports_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/reports_state.dart';

part 'reports_controller.g.dart';

/// EXP-11 Reports (T089, T096, contracts/screens.md). The screen's only
/// notifier. Every figure comes from the same ledger and breakdown queries
/// as EXP-01's summary strip, so the totals match (EXP-11 criterion 2).
/// Nothing is loaded while the current tab is locked: the overlay shows
/// sample data instead.
@riverpod
class ReportsController extends _$ReportsController {
  StreamSubscription<bool>? _gateSub;
  final List<StreamSubscription<Object?>> _dataSubs = [];
  StreamSubscription<Object?>? _selectionSub;

  PeriodLedger? _ledger;
  PeriodLedger? _previous;
  ExpenseBreakdown? _breakdown;
  bool? _any;
  Map<String, Category>? _categories;
  Map<String, Account>? _accounts;

  DateTime _now() => ref.read(clockProvider).now();

  @override
  ReportsState build() {
    ref.onDispose(() {
      unawaited(_gateSub?.cancel());
      _cancelData();
      unawaited(_selectionSub?.cancel());
    });
    final initial = ReportsState(period: MonthPeriod(_now()));
    // After build, so state exists. Until the gate answers, the free rules
    // apply.
    unawaited(
      Future.microtask(() {
        if (!ref.mounted) return;
        _gateSub = ref
            .read(featureGateProvider)
            .watch(FeatureKey.advancedReports)
            .listen(
              (unlocked) => _apply(state.copyWith(advancedUnlocked: unlocked)),
              onError: (Object _) {},
            );
        _apply(state, force: true);
      }),
    );
    return initial;
  }

  /// Applies [next], recomputes `locked`, and reloads when the inputs the
  /// data depends on changed (or [force]).
  void _apply(ReportsState next, {bool force = false}) {
    if (!ref.mounted) return;
    final locked =
        requiresAdvanced(next.tab, next.period, _now()) &&
        !next.advancedUnlocked;
    final prev = state;
    final s = next.copyWith(locked: locked);
    final reload =
        force ||
        s.period != prev.period ||
        s.locked != prev.locked ||
        (s.tab == ReportTab.trends) != (prev.tab == ReportTab.trends);
    state = s;
    if (reload) _subscribe();
  }

  void _cancelData() {
    for (final sub in _dataSubs) {
      unawaited(sub.cancel());
    }
    _dataSubs.clear();
    _ledger = _previous = null;
    _breakdown = null;
    _any = null;
    _categories = null;
    _accounts = null;
  }

  void _subscribe() {
    _cancelData();
    if (state.locked) {
      state = state.copyWith(data: const AsyncLoading());
      return;
    }
    state = state.copyWith(data: const AsyncLoading());
    final txns = ref.read(transactionRepositoryProvider);
    final period = state.period;
    final q = TxnQuery(period: period);
    final trends = state.tab == ReportTab.trends;
    void onError(Object e, StackTrace st) {
      if (ref.mounted) state = state.copyWith(data: AsyncError(e, st));
    }

    _dataSubs
      ..add(
        txns
            .watchLedger(q)
            .listen((v) => _set(() => _ledger = v), onError: onError),
      )
      ..add(
        txns
            .watchBreakdown(q)
            .listen((v) => _set(() => _breakdown = v), onError: onError),
      )
      ..add(
        txns
            .watchPage(q, limit: 1)
            .listen((v) => _set(() => _any = v.isNotEmpty), onError: onError),
      )
      ..add(
        ref
            .read(categoryRepositoryProvider)
            .watchAll()
            .listen(
              (v) => _set(() => _categories = {for (final c in v) c.id: c}),
              onError: onError,
            ),
      )
      ..add(
        ref
            .read(accountRepositoryProvider)
            .watchAllWithBalances()
            .listen(
              (v) => _set(
                () => _accounts = {for (final a in v) a.account.id: a.account},
              ),
              onError: onError,
            ),
      );
    if (trends) {
      _dataSubs.add(
        txns
            .watchLedger(TxnQuery(period: previousForTrend(period)))
            .listen((v) => _set(() => _previous = v), onError: onError),
      );
    }
    _subscribeSelection();
  }

  void _set(void Function() assign) {
    if (!ref.mounted) return;
    assign();
    final ledger = _ledger;
    final breakdown = _breakdown;
    final any = _any;
    final categories = _categories;
    final accounts = _accounts;
    final trends = state.tab == ReportTab.trends;
    if (ledger == null ||
        breakdown == null ||
        any == null ||
        categories == null ||
        accounts == null ||
        (trends && _previous == null)) {
      return;
    }
    final period = state.period;
    state = state.copyWith(
      data: AsyncData(
        ReportData(
          hasTransactions: any,
          overview: buildOverview(
            ledger: ledger,
            breakdown: breakdown,
            period: period,
            now: _now(),
            categories: categories,
          ),
          donut: buildDonut(breakdown: breakdown, categories: categories),
          bars: buildBars(breakdown: breakdown, accounts: accounts),
          trend: trends
              ? buildTrend(
                  current: ledger,
                  previous: _previous!,
                  period: period,
                  previousPeriod: previousForTrend(period),
                )
              : null,
        ),
      ),
    );
  }

  void _subscribeSelection() {
    unawaited(_selectionSub?.cancel());
    _selectionSub = null;
    final key = state.selectedKey;
    if (key == null || state.locked) {
      if (state.selected.isNotEmpty) state = state.copyWith(selected: const []);
      return;
    }
    final ids = key == donutOtherKey
        ? state.data.value?.donut.slices
                  .where((s) => s.isOther)
                  .firstOrNull
                  ?.memberIds ??
              const <String>[]
        : [key];
    _selectionSub = ref
        .read(transactionRepositoryProvider)
        .watchPage(
          TxnQuery(
            period: state.period,
            categoryIds: ids.toSet(),
            types: const {TxnType.expense},
          ),
          limit: 200,
        )
        .listen((rows) {
          if (ref.mounted) state = state.copyWith(selected: rows);
        }, onError: (Object _) {});
  }

  void setPeriod(Period period) =>
      _apply(state.copyWith(period: period, selectedKey: null, selected: []));

  void setTab(ReportTab tab) => _apply(state.copyWith(tab: tab));

  /// Highlights a donut slice (or legend row) and lists its transactions
  /// (US4 s3); selecting it again clears the selection.
  void selectSlice(String? key) {
    state = state.copyWith(
      selectedKey: key == state.selectedKey ? null : key,
      selected: const [],
    );
    _subscribeSelection();
  }

  /// Pull to refresh (US4 s5): reloads every figure.
  Future<void> refresh() async => _apply(state, force: true);

  /// Error state "Try again".
  void retry() => _apply(state, force: true);
}
