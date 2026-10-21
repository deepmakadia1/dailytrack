import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/today_and_month_spend.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/ports/budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/domain/ports/notification_gate.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_store.dart';
import 'package:dailytrack/features/expense/domain/repositories/account_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/category_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/repositories/transaction_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/domain/usecases/fold_ledger.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../helpers/mutable_clock.dart';

/// The default "now" in widget tests: Wednesday 2026-10-14 10:00 local.
final DateTime fakeNow = DateTime(2026, 10, 14, 10);

/// One shared in-memory store behind the three fake repositories, so joins,
/// totals and Undo behave like the Drift ones (contracts/repositories.md).
/// Widget tests use these instead of a database (Constitution IV).
final class FakeExpenseWorld {
  new(this.clock);

  final MutableClock clock;
  final Map<String, Transaction> transactions = {};
  final Map<String, Category> categories = {};
  final Map<String, Account> accounts = {};
  final Set<String> deletedCategories = {};
  final Set<String> deletedAccounts = {};

  /// Budgets by id, including soft-deleted ones (feature 003).
  final Map<String, Budget> budgets = {};
  final Set<String> deletedBudgets = {};
  final Map<String, String> moduleState = {};

  /// Recurring rules by id, including soft-deleted ones (feature 003).
  final Map<String, RecurringRule> rules = {};

  final _changes = StreamController<void>.broadcast();

  /// When set, every watch stream emits this error instead of data.
  Object? failWatch;

  /// When true, the next write throws [ExpenseStorageFailure], then resets.
  bool failNextWrite = false;

  /// Delay before every watch stream's first emission (loading states).
  Duration watchDelay = Duration.zero;

  var _seq = 0;
  String nextId(String prefix) => '$prefix-${++_seq}';

  void changed() => _changes.add(null);

  void checkWrite() {
    if (failNextWrite) {
      failNextWrite = false;
      throw const ExpenseStorageFailure('fake failure');
    }
  }

  /// A stream that emits [compute] now (after [watchDelay]) and after every
  /// change, like a Drift watch query.
  Stream<T> watch<T>(T Function() compute) => Stream.multi((c) {
    StreamSubscription<void>? sub;
    var cancelled = false;
    void emit() {
      if (cancelled) return;
      if (failWatch case final e?) {
        c.addError(e);
      } else {
        c.add(compute());
      }
    }

    // Subscribe before the first emission, and never after a cancel: a
    // listener such as `.first` cancels during that first emission.
    Future<void>.delayed(watchDelay, () {
      if (cancelled) return;
      sub = _changes.stream.listen((_) => emit());
      emit();
    });
    // Not awaited: under fake time `.first` would otherwise wait on this
    // inner cancel, which a Drift stream never makes it do.
    c.onCancel = () {
      cancelled = true;
      unawaited(sub?.cancel());
    };
  });

  bool isActiveCategory(String id) =>
      categories.containsKey(id) && !deletedCategories.contains(id);
  bool isActiveAccount(String id) =>
      accounts.containsKey(id) && !deletedAccounts.contains(id);
}

/// Test fakes for the Expense module, plus provider overrides.
final class ExpenseFakes {
  new _(this.world)
    : transactions = FakeTransactionRepository(world),
      categories = FakeCategoryRepository(world),
      accounts = FakeAccountRepository(world),
      budgets = FakeBudgetRepository(world),
      rules = FakeRecurringRuleRepository(world);

  /// One Cash account and no categories.
  factory empty({DateTime? now}) {
    return ExpenseFakes._(FakeExpenseWorld(MutableClock(now ?? fakeNow)))
      ..addAccount('expense_account_cash', id: 'cash');
  }

  /// The first-launch seed: 12 expense + 5 income categories and Cash.
  factory withDefaults({DateTime? now}) {
    final f = ExpenseFakes.empty(now: now);
    const expense = {
      'food': 'restaurant',
      'groceries': 'local_grocery_store',
      'transport': 'directions_bus',
      'fuel': 'local_gas_station',
      'shopping': 'shopping_bag',
      'bills': 'receipt',
      'rent': 'home',
      'health': 'medical_services',
      'education': 'school',
      'entertainment': 'movie',
      'travel': 'flight',
      'other': 'category',
    };
    const income = {
      'salary': 'payments',
      'business': 'storefront',
      'gift': 'redeem',
      'interest': 'savings',
      'other': 'attach_money',
    };
    for (final MapEntry(:key, :value) in expense.entries) {
      f.addCategory('expense_cat_$key', id: key, icon: value, isDefault: true);
    }
    for (final MapEntry(:key, :value) in income.entries) {
      f.addCategory(
        'income_cat_$key',
        id: 'income_$key',
        type: CategoryType.income,
        icon: value,
        isDefault: true,
      );
    }
    return f;
  }

  final FakeExpenseWorld world;
  final FakeTransactionRepository transactions;
  final FakeCategoryRepository categories;
  final FakeAccountRepository accounts;
  final FakeBudgetRepository budgets;
  final FakeRecurringRuleRepository rules;
  final FakeBudgetAlertNotifier alertNotifier = FakeBudgetAlertNotifier();
  final FakeNotificationGate notificationGate = FakeNotificationGate();
  final FakeReceiptPicker receiptPicker = FakeReceiptPicker();
  final FakeReceiptStore receiptStore = FakeReceiptStore();

  MutableClock get clock => world.clock;

  List<Override> get overrides => [
    transactionRepositoryProvider.overrideWithValue(transactions),
    categoryRepositoryProvider.overrideWithValue(categories),
    accountRepositoryProvider.overrideWithValue(accounts),
    budgetRepositoryProvider.overrideWithValue(budgets),
    recurringRuleRepositoryProvider.overrideWithValue(rules),
    budgetAlertNotifierProvider.overrideWithValue(alertNotifier),
    notificationGateProvider.overrideWithValue(notificationGate),
    receiptPickerProvider.overrideWithValue(receiptPicker),
    receiptStoreProvider.overrideWithValue(receiptStore),
    clockProvider.overrideWithValue(world.clock),
  ];

  String addAccount(
    String name, {
    String? id,
    AccountType type = AccountType.cash,
    int opening = 0,
    bool archived = false,
  }) {
    final accountId = id ?? world.nextId('account');
    world.accounts[accountId] = Account(
      id: accountId,
      name: name,
      type: type,
      openingBalanceMinor: opening,
      iconKey: 'wallet',
      colorHex: '#0F766E',
      isArchived: archived,
      sortOrder: world.accounts.length,
    );
    world.changed();
    return accountId;
  }

  String addCategory(
    String name, {
    String? id,
    CategoryType type = CategoryType.expense,
    String icon = 'category',
    bool isDefault = false,
    bool hidden = false,
  }) {
    final categoryId = id ?? world.nextId('category');
    world.categories[categoryId] = Category(
      id: categoryId,
      name: name,
      type: type,
      iconKey: icon,
      colorHex: '#0F766E',
      isDefault: isDefault,
      isHidden: hidden,
      sortOrder: world.categories.values.where((c) => c.type == type).length,
    );
    world.changed();
    return categoryId;
  }

  /// Adds a transaction directly (no validation), one second after the
  /// previous one so `createdAt` never ties.
  Transaction addTransaction({
    required int amount,
    String account = 'cash',
    TxnType type = TxnType.expense,
    String? category,
    String? toAccount,
    PaymentMode mode = PaymentMode.cash,
    String? note,
    DateTime? at,
    String? receipt,
    String? id,
  }) {
    world.clock.advance(const Duration(seconds: 1));
    final now = world.clock.now().toUtc();
    final t = Transaction(
      id: id ?? world.nextId('txn'),
      type: type,
      amountMinor: amount,
      accountId: account,
      toAccountId: toAccount,
      categoryId: category,
      paymentMode: mode,
      note: note,
      occurredAt: (at ?? fakeNow.subtract(const Duration(hours: 1))).toUtc(),
      receiptPath: receipt,
      createdAt: now,
      updatedAt: now,
    );
    world.transactions[t.id] = t;
    world.changed();
    return t;
  }

  /// Adds a budget directly (no validation).
  Budget addBudget({
    required int limit,
    String? category,
    String? month,
    bool rollover = true,
    String? id,
  }) {
    final now = world.clock.now().toUtc();
    final b = Budget(
      id: id ?? world.nextId('budget'),
      categoryId: category,
      monthKey: month ?? monthKeyOf(world.clock.now()),
      limitMinor: limit,
      rollover: rollover,
      createdAt: now,
      updatedAt: now,
    );
    world.budgets[b.id] = b;
    world.changed();
    return b;
  }

  /// Adds a recurring rule directly (no validation, no first occurrence).
  RecurringRule addRule({
    required int amount,
    required DateTime anchor,
    String category = 'rent',
    String account = 'cash',
    TxnType type = TxnType.expense,
    Frequency frequency = Frequency.monthly,
    String? note,
    DateTime? nextRun,
    DateTime? endAt,
    bool active = true,
    String? id,
  }) {
    final now = world.clock.now().toUtc();
    final schedule = RecurrenceSchedule(
      anchorLocal: anchor,
      frequency: frequency,
    );
    final r = RecurringRule(
      id: id ?? world.nextId('rule'),
      type: type,
      amountMinor: amount,
      accountId: account,
      categoryId: type == TxnType.transfer ? null : category,
      paymentMode: PaymentMode.upi,
      note: note,
      frequency: frequency,
      interval: 1,
      anchorAt: anchor.toUtc(),
      nextRunAt: (nextRun ?? schedule.firstAfter(world.clock.now())).toUtc(),
      endAt: endAt?.toUtc(),
      isActive: active,
      createdAt: now,
      updatedAt: now,
    );
    world.rules[r.id] = r;
    world.changed();
    return r;
  }

  /// Non-deleted transactions, in no particular order.
  List<Transaction> get active => [
    for (final t in world.transactions.values)
      if (t.deletedAt == null) t,
  ];
}

final class FakeTransactionRepository implements TransactionRepository {
  new(this._w);

  final FakeExpenseWorld _w;

  /// Number of create/update/restore/softDelete/undelete calls.
  int writes = 0;

  /// When set, only [watchBreakdown] fails with it (one failing input).
  Object? failBreakdown;

  List<Transaction> _matching(TxnQuery q) {
    final rows = [
      for (final t in _w.transactions.values)
        if (t.deletedAt == null && _matches(t, q)) t,
    ]..sort(_newestFirst);
    return rows;
  }

  static int _newestFirst(Transaction a, Transaction b) {
    var c = b.occurredAt.compareTo(a.occurredAt);
    if (c == 0) c = b.createdAt.compareTo(a.createdAt);
    if (c == 0) c = b.id.compareTo(a.id);
    return c;
  }

  bool _matches(Transaction t, TxnQuery q) {
    final ms = t.occurredAt.millisecondsSinceEpoch;
    if (!q.period.contains(ms)) return false;
    if (q.categoryIds.isNotEmpty && !q.categoryIds.contains(t.categoryId)) {
      return false;
    }
    if (q.accountIds.isNotEmpty &&
        !q.accountIds.contains(t.accountId) &&
        !q.accountIds.contains(t.toAccountId)) {
      return false;
    }
    if (q.paymentModes.isNotEmpty && !q.paymentModes.contains(t.paymentMode)) {
      return false;
    }
    if (q.types.isNotEmpty && !q.types.contains(t.type)) return false;
    if (q.minAmountMinor case final min? when t.amountMinor < min) return false;
    if (q.maxAmountMinor case final max? when t.amountMinor > max) return false;
    if (q.hasSearch) {
      final s = q.search.trim();
      final note = (t.note ?? '').toLowerCase();
      final byNote = note.contains(s.toLowerCase());
      final byCategory = q.matchingCategoryIds.contains(t.categoryId);
      final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(s);
      var byAmount = false;
      if (m != null) {
        final exact =
            int.parse(m.group(1)!) * 100 +
            int.parse((m.group(2) ?? '').padRight(2, '0'));
        byAmount =
            t.amountMinor == exact ||
            (!s.contains('.') && '${t.amountMinor ~/ 100}'.startsWith(s));
      }
      if (!byNote && !byCategory && !byAmount) return false;
    }
    return true;
  }

  TransactionView _view(Transaction t) => TransactionView(
    transaction: t,
    account: _w.accounts[t.accountId]!,
    toAccount: t.toAccountId == null ? null : _w.accounts[t.toAccountId],
    category: t.categoryId == null ? null : _w.categories[t.categoryId],
  );

  @override
  Stream<List<TransactionView>> watchPage(
    TxnQuery query, {
    required int limit,
  }) =>
      _w.watch(() => [for (final t in _matching(query).take(limit)) _view(t)]);

  @override
  Stream<List<TransactionView>> watchRecent({int limit = 5}) => _w.watch(() {
    final rows = [
      for (final t in _w.transactions.values)
        if (t.deletedAt == null) t,
    ]..sort(_newestFirst);
    return [for (final t in rows.take(limit)) _view(t)];
  });

  @override
  Stream<PeriodLedger> watchLedger(TxnQuery query) => _w.watch(
    () => foldLedger([
      for (final t in _matching(query))
        (t.occurredAt.millisecondsSinceEpoch, t.type, t.amountMinor),
    ]),
  );

  @override
  Stream<ExpenseBreakdown> watchBreakdown(TxnQuery query) =>
      failBreakdown == null ? _breakdown(query) : Stream.error(failBreakdown!);

  Stream<ExpenseBreakdown> _breakdown(TxnQuery query) => _w.watch(
    () => foldBreakdown([
      for (final t in _matching(query))
        if (t.type == TxnType.expense)
          (t.categoryId, t.accountId, t.paymentMode, t.amountMinor),
    ]),
  );

  @override
  Stream<TransactionView?> watchById(String id) => _w.watch(() {
    final t = _w.transactions[id];
    return t == null || t.deletedAt != null ? null : _view(t);
  });

  @override
  Future<TransactionView?> findById(String id) async {
    final t = _w.transactions[id];
    return t == null || t.deletedAt != null ? null : _view(t);
  }

  @override
  Stream<TodayAndMonthSpend> watchTodayAndMonthSpend(DateTime nowLocal) =>
      _w.watch(() {
        final day = SingleDayPeriod(nowLocal);
        final month = MonthPeriod(nowLocal);
        var today = 0;
        var monthTotal = 0;
        var count = 0;
        for (final t in _w.transactions.values) {
          if (t.deletedAt != null) continue;
          count++;
          if (t.type != TxnType.expense) continue;
          final ms = t.occurredAt.millisecondsSinceEpoch;
          if (day.contains(ms)) today += t.amountMinor;
          if (month.contains(ms)) monthTotal += t.amountMinor;
        }
        return TodayAndMonthSpend(
          todayMinor: today,
          monthMinor: monthTotal,
          hasAnyTransaction: count > 0,
        );
      });

  @override
  Future<List<String>> recentNotes({String prefix = '', int limit = 5}) async {
    final rows = [
      for (final t in _w.transactions.values)
        if (t.deletedAt == null && (t.note ?? '').isNotEmpty) t,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final seen = <String>{};
    return [
      for (final t in rows)
        if (t.note!.toLowerCase().startsWith(prefix.toLowerCase()) &&
            seen.add(t.note!))
          t.note!,
    ].take(limit).toList();
  }

  @override
  Future<String?> lastUsedAccountId() async {
    final rows = [
      for (final t in _w.transactions.values)
        if (t.deletedAt == null &&
            _w.isActiveAccount(t.accountId) &&
            !_w.accounts[t.accountId]!.isArchived)
          t,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rows.isEmpty ? null : rows.first.accountId;
  }

  @override
  Future<Set<String>> allReceiptPaths() async => {
    for (final t in _w.transactions.values)
      if (t.receiptPath != null) t.receiptPath!,
  };

  String? _note(String note) => note.trim().isEmpty ? null : note.trim();

  @override
  Future<Transaction> create(TransactionDraft draft) async {
    _w.checkWrite();
    writes++;
    _w.clock.advance(const Duration(seconds: 1));
    final now = _w.clock.now().toUtc();
    final t = Transaction(
      id: _w.nextId('txn'),
      type: draft.type,
      amountMinor: draft.amountMinor!,
      accountId: draft.accountId!,
      toAccountId: draft.toAccountId,
      categoryId: draft.categoryId,
      paymentMode: draft.paymentMode,
      note: _note(draft.note),
      occurredAt: draft.occurredAt.toUtc(),
      receiptPath: draft.receiptPath,
      createdAt: now,
      updatedAt: now,
    );
    _w.transactions[t.id] = t;
    _w.changed();
    return t;
  }

  @override
  Future<Transaction> update(String id, TransactionDraft draft) async {
    _w.checkWrite();
    writes++;
    final old = _w.transactions[id];
    if (old == null || old.deletedAt != null) throw TransactionNotFound(id);
    final t = old.copyWith(
      type: draft.type,
      amountMinor: draft.amountMinor!,
      accountId: draft.accountId!,
      toAccountId: draft.toAccountId,
      categoryId: draft.categoryId,
      paymentMode: draft.paymentMode,
      note: _note(draft.note),
      occurredAt: draft.occurredAt.toUtc(),
      receiptPath: draft.receiptPath,
      updatedAt: _w.clock.now().toUtc(),
    );
    _w.transactions[id] = t;
    _w.changed();
    return t;
  }

  @override
  Future<void> restore(Transaction snapshot) async {
    _w.checkWrite();
    writes++;
    final old = _w.transactions[snapshot.id];
    if (old == null || old.deletedAt != null) {
      throw TransactionNotFound(snapshot.id);
    }
    _w.transactions[snapshot.id] = snapshot;
    _w.changed();
  }

  @override
  Future<void> softDelete(String id) async {
    _w.checkWrite();
    writes++;
    final t = _w.transactions[id];
    if (t == null) return;
    _w.transactions[id] = t.copyWith(deletedAt: _w.clock.now().toUtc());
    _w.changed();
  }

  @override
  Future<void> undelete(String id) async {
    _w.checkWrite();
    writes++;
    final t = _w.transactions[id];
    if (t == null) return;
    _w.transactions[id] = t.copyWith(deletedAt: null);
    _w.changed();
  }
}

final class FakeCategoryRepository implements CategoryRepository {
  new(this._w);

  final FakeExpenseWorld _w;

  int _usage(String id) => _w.transactions.values
      .where((t) => t.deletedAt == null && t.categoryId == id)
      .length;

  List<Category> _ofType(CategoryType type) => [
    for (final c in _w.categories.values)
      if (c.type == type && !_w.deletedCategories.contains(c.id)) c,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Stream<List<CategoryWithStats>> watchByType(
    CategoryType type, {
    required Period month,
  }) => _w.watch(
    () => [
      for (final c in _ofType(type))
        CategoryWithStats(
          category: c,
          usageCount: _usage(c.id),
          monthTotalMinor: _w.transactions.values
              .where(
                (t) =>
                    t.deletedAt == null &&
                    t.categoryId == c.id &&
                    month.contains(t.occurredAt.millisecondsSinceEpoch),
              )
              .fold(0, (s, t) => s + t.amountMinor),
        ),
    ],
  );

  @override
  Stream<List<Category>> watchPickable(CategoryType type) => _w.watch(() {
    // Usage DESC, then sortOrder (clarification Q2); List.sort is stable.
    return [
      for (final c in _ofType(type))
        if (!c.isHidden) c,
    ]..sort((a, b) => _usage(b.id).compareTo(_usage(a.id)));
  });

  @override
  Stream<List<Category>> watchAll() => _w.watch(
    () => [
      for (final c in _w.categories.values)
        if (!_w.deletedCategories.contains(c.id)) c,
    ],
  );

  @override
  Future<Category> create({
    required String name,
    required CategoryType type,
    required String iconKey,
    required String colorHex,
  }) async {
    _w.checkWrite();
    final id = _w.nextId('category');
    final c = Category(
      id: id,
      name: name.trim(),
      type: type,
      iconKey: iconKey,
      colorHex: colorHex,
      isDefault: false,
      isHidden: false,
      sortOrder: _ofType(type).length,
    );
    _w.categories[id] = c;
    _w.changed();
    return c;
  }

  @override
  Future<void> update(
    String id, {
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    _w.checkWrite();
    _w.categories[id] = _w.categories[id]!.copyWith(
      name: name.trim(),
      iconKey: iconKey,
      colorHex: colorHex,
    );
    _w.changed();
  }

  @override
  Future<void> setHidden(String id, {required bool hidden}) async {
    _w.checkWrite();
    _w.categories[id] = _w.categories[id]!.copyWith(isHidden: hidden);
    _w.changed();
  }

  @override
  Future<void> reorder(CategoryType type, List<String> orderedIds) async {
    _w.checkWrite();
    for (final (i, id) in orderedIds.indexed) {
      _w.categories[id] = _w.categories[id]!.copyWith(sortOrder: i);
    }
    _w.changed();
  }

  @override
  Future<int> transactionCount(String id) async => _usage(id);

  @override
  Future<void> delete(String id, {String? replacementId}) async {
    _w.checkWrite();
    final c = _w.categories[id];
    if (c == null || _w.deletedCategories.contains(id)) return;
    if (c.isDefault) {
      throw const CategoryDeleteNotAllowed(CategoryDeleteReason.isDefault);
    }
    if (_usage(id) > 0) {
      if (replacementId == null) {
        throw const CategoryDeleteNotAllowed(
          CategoryDeleteReason.replacementRequired,
        );
      }
      final r = _w.categories[replacementId];
      if (r == null ||
          r.id == id ||
          r.type != c.type ||
          _w.deletedCategories.contains(r.id)) {
        throw const CategoryDeleteNotAllowed(
          CategoryDeleteReason.invalidReplacement,
        );
      }
      for (final t in [..._w.transactions.values]) {
        if (t.categoryId == id) {
          _w.transactions[t.id] = t.copyWith(categoryId: replacementId);
        }
      }
    }
    _w.deletedCategories.add(id);
    _w.changed();
  }

  @override
  Future<void> undelete(String id) async {
    _w.deletedCategories.remove(id);
    _w.changed();
  }
}

final class FakeAccountRepository implements AccountRepository {
  new(this._w);

  final FakeExpenseWorld _w;

  List<Account> get _active => [
    for (final a in _w.accounts.values)
      if (!_w.deletedAccounts.contains(a.id)) a,
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  int _balance(Account a) {
    var b = a.openingBalanceMinor;
    for (final t in _w.transactions.values) {
      if (t.deletedAt != null) continue;
      if (t.accountId == a.id) {
        b += t.type == TxnType.income ? t.amountMinor : -t.amountMinor;
      } else if (t.toAccountId == a.id && t.type == TxnType.transfer) {
        b += t.amountMinor;
      }
    }
    return b;
  }

  bool _used(String id) => _w.transactions.values.any(
    (t) => t.deletedAt == null && (t.accountId == id || t.toAccountId == id),
  );

  bool _isLastActive(Account a) =>
      !a.isArchived && !_active.any((o) => o.id != a.id && !o.isArchived);

  @override
  Stream<List<AccountWithBalance>> watchAllWithBalances() => _w.watch(
    () => [
      for (final a in _active)
        AccountWithBalance(
          account: a,
          balanceMinor: _balance(a),
          hasTransactions: _used(a.id),
        ),
    ],
  );

  @override
  Stream<int> watchTotalBalance() => _w.watch(
    () =>
        _active.where((a) => !a.isArchived).fold(0, (s, a) => s + _balance(a)),
  );

  @override
  Stream<List<Account>> watchPickable() => _w.watch(
    () => [
      for (final a in _active)
        if (!a.isArchived) a,
    ],
  );

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  }) async {
    _w.checkWrite();
    final id = _w.nextId('account');
    final a = Account(
      id: id,
      name: name.trim(),
      type: type,
      openingBalanceMinor: openingBalanceMinor,
      iconKey: iconKey,
      colorHex: colorHex,
      isArchived: false,
      sortOrder: _w.accounts.length,
    );
    _w.accounts[id] = a;
    _w.changed();
    return a;
  }

  @override
  Future<void> update(
    String id, {
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required String iconKey,
    required String colorHex,
  }) async {
    _w.checkWrite();
    _w.accounts[id] = _w.accounts[id]!.copyWith(
      name: name.trim(),
      type: type,
      openingBalanceMinor: openingBalanceMinor,
      iconKey: iconKey,
      colorHex: colorHex,
    );
    _w.changed();
  }

  @override
  Future<void> setArchived(String id, {required bool archived}) async {
    _w.checkWrite();
    final a = _w.accounts[id]!;
    if (archived && _isLastActive(a)) throw const AccountArchiveNotAllowed();
    _w.accounts[id] = a.copyWith(isArchived: archived);
    _w.changed();
  }

  @override
  Future<void> delete(String id) async {
    _w.checkWrite();
    final a = _w.accounts[id]!;
    if (_used(id)) {
      throw const AccountDeleteNotAllowed(AccountDeleteReason.hasTransactions);
    }
    if (_isLastActive(a)) {
      throw const AccountDeleteNotAllowed(AccountDeleteReason.lastActive);
    }
    _w.deletedAccounts.add(id);
    _w.changed();
  }

  @override
  Future<void> undelete(String id) async {
    _w.deletedAccounts.remove(id);
    _w.changed();
  }
}

/// Returns [next] (a relative path), null for "cancelled", or throws
/// [error] when set. Records every call.
final class FakeReceiptPicker implements ReceiptPicker {
  String? next = 'receipts/fake.jpg';
  Exception? error;
  final List<ReceiptSource> calls = [];

  @override
  Future<String?> pick(ReceiptSource source) async {
    calls.add(source);
    if (error case final e?) throw e;
    return next;
  }
}

/// Resolves nothing by default ("Receipt not available"); add paths to
/// [existing] to make them resolvable. Records prune calls.
final class FakeReceiptStore implements ReceiptStore {
  final Map<String, String> existing = {};
  final List<Set<String>> pruneCalls = [];

  @override
  Future<String?> resolve(String relativePath) async => existing[relativePath];

  @override
  Future<int> pruneOrphans(Set<String> referencedRelativePaths) async {
    pruneCalls.add(referencedRelativePaths);
    return 0;
  }

  int deleteAllCalls = 0;

  @override
  Future<void> deleteAll() async {
    deleteAllCalls++;
    existing.clear();
  }
}

/// In-memory [BudgetRepository] over the shared world, with the same
/// slot, copy, rollover, marker and compare-and-set rules as the Drift one
/// (feature 003 T040). Records calls in [calls].
final class FakeBudgetRepository implements BudgetRepository {
  new(this._w);

  final FakeExpenseWorld _w;
  final Map<String, int> calls = {};

  void _count(String name) => calls[name] = (calls[name] ?? 0) + 1;

  bool _live(Budget b) => !_w.deletedBudgets.contains(b.id);

  Iterable<Budget> _month(String monthKey) =>
      _w.budgets.values.where((b) => _live(b) && b.monthKey == monthKey);

  Budget? _slot(String monthKey, String? categoryId) =>
      _month(monthKey).where((b) => b.categoryId == categoryId).firstOrNull;

  bool _activeCategory(String? id) =>
      id == null || (_w.isActiveCategory(id) && !_w.categories[id]!.isHidden);

  int _spent(String monthKey, String? categoryId) {
    final range = monthRangeUtc(monthKey);
    var total = 0;
    for (final t in _w.transactions.values) {
      final ms = t.occurredAt.millisecondsSinceEpoch;
      if (t.deletedAt != null || t.type != TxnType.expense) continue;
      if (ms < range.startUtcMs || ms >= range.endUtcMsExclusive) continue;
      if (categoryId != null && t.categoryId != categoryId) continue;
      total += t.amountMinor;
    }
    return total;
  }

  BudgetsOverview _overview(String monthKey) {
    final now = _w.clock.now();
    BudgetStatus? overall;
    final categories = <BudgetStatus>[];
    for (final b in _month(monthKey)) {
      final spent = _spent(monthKey, b.categoryId);
      if (b.isOverall) {
        overall = buildBudgetStatus(
          budget: b,
          spentMinor: spent,
          nowLocal: now,
        );
      } else {
        categories.add(
          buildBudgetStatus(
            budget: b,
            spentMinor: spent,
            nowLocal: now,
            category: _w.categories[b.categoryId],
            categoryHidden: !_activeCategory(b.categoryId),
          ),
        );
      }
    }
    categories.sort((a, b) {
      final p = b.percent.compareTo(a.percent);
      return p != 0
          ? p
          : (a.category?.sortOrder ?? 0).compareTo(b.category?.sortOrder ?? 0);
    });
    final budgeted = {for (final s in categories) s.budget.categoryId};
    final ordered = _w.categories.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return BudgetsOverview(
      monthKey: monthKey,
      monthPhase: monthPhase(monthKey, now),
      overall: overall,
      categories: categories,
      withoutBudget: [
        for (final c in ordered)
          if (c.type == CategoryType.expense &&
              _activeCategory(c.id) &&
              !budgeted.contains(c.id))
            c,
      ],
    );
  }

  @override
  Stream<BudgetsOverview> watchOverview(String monthKey) =>
      _w.watch(() => _overview(monthKey));

  @override
  Future<Budget?> findById(String id) async {
    final b = _w.budgets[id];
    return b == null || !_live(b) ? null : b;
  }

  @override
  Future<({Budget? category, Budget? overall})> forAlert(
    String monthKey,
    String? categoryId,
  ) async {
    _count('forAlert');
    return (
      category: categoryId == null ? null : _slot(monthKey, categoryId),
      overall: _slot(monthKey, null),
    );
  }

  @override
  Future<int> spentFor(String monthKey, String? categoryId) async =>
      _spent(monthKey, categoryId);

  @override
  Future<Budget> create(BudgetDraft draft) async {
    _w.checkWrite();
    _count('create');
    if (_slot(draft.monthKey, draft.categoryId) != null) {
      throw const BudgetSlotTaken();
    }
    final now = _w.clock.now().toUtc();
    final b = Budget(
      id: _w.nextId('budget'),
      categoryId: draft.categoryId,
      monthKey: draft.monthKey,
      limitMinor: draft.limitMinor,
      rollover: draft.rollover,
      createdAt: now,
      updatedAt: now,
    );
    _w.budgets[b.id] = b;
    _w.changed();
    return b;
  }

  @override
  Future<Budget> update(
    String id, {
    required int limitMinor,
    required bool rollover,
  }) async {
    _w.checkWrite();
    _count('update');
    final old = await findById(id);
    if (old == null) throw BudgetNotFound(id);
    final spent = _spent(old.monthKey, old.categoryId);
    bool still(BudgetThreshold t) =>
        reaches(t, spentMinor: spent, limitMinor: limitMinor);
    final b = old.copyWith(
      limitMinor: limitMinor,
      rollover: rollover,
      alert80SentAt: still(BudgetThreshold.p80) ? old.alert80SentAt : null,
      alert100SentAt: still(BudgetThreshold.p100) ? old.alert100SentAt : null,
      updatedAt: _w.clock.now().toUtc(),
    );
    _w.budgets[id] = b;
    _w.changed();
    return b;
  }

  @override
  Future<void> softDelete(String id) async {
    _w.checkWrite();
    _count('softDelete');
    _w.deletedBudgets.add(id);
    _w.changed();
  }

  @override
  Future<void> undelete(String id) async {
    _w.checkWrite();
    _count('undelete');
    final b = _w.budgets[id];
    if (b == null) return;
    if (_slot(b.monthKey, b.categoryId) != null) throw const BudgetSlotTaken();
    _w.deletedBudgets.remove(id);
    _w.changed();
  }

  int _copy(Iterable<Budget> from, String target) {
    var copied = 0;
    final now = _w.clock.now().toUtc();
    for (final b in from.toList()) {
      if (!_activeCategory(b.categoryId)) continue;
      if (_slot(target, b.categoryId) != null) continue;
      final id = _w.nextId('budget');
      _w.budgets[id] = b.copyWith(
        id: id,
        monthKey: target,
        alert80SentAt: null,
        alert100SentAt: null,
        createdAt: now,
        updatedAt: now,
      );
      copied++;
    }
    if (copied > 0) _w.changed();
    return copied;
  }

  @override
  Future<int> copyPreviousMonth(String monthKey) async {
    _w.checkWrite();
    _count('copyPreviousMonth');
    return _copy(_month(shiftMonthKey(monthKey, -1)), monthKey);
  }

  @override
  Future<void> rolloverIfNeeded(String currentMonthKey) async {
    _count('rolloverIfNeeded');
    const key = 'expense.budgetRolloverMonth';
    final done = _w.moduleState[key];
    if (done != null && done.compareTo(currentMonthKey) >= 0) return;
    final earlier = [
      for (final b in _w.budgets.values)
        if (_live(b) && b.monthKey.compareTo(currentMonthKey) < 0) b.monthKey,
    ]..sort();
    if (earlier.isNotEmpty) {
      _copy(_month(earlier.last).where((b) => b.rollover), currentMonthKey);
    }
    _w.moduleState[key] = currentMonthKey;
  }

  @override
  Future<bool> markAlertSent(
    String id,
    BudgetThreshold threshold,
    int atUtcMs,
  ) async {
    _count('markAlertSent');
    final b = await findById(id);
    if (b == null) return false;
    final at = DateTime.fromMillisecondsSinceEpoch(atUtcMs, isUtc: true);
    switch (threshold) {
      case BudgetThreshold.p80:
        if (b.alert80SentAt != null) return false;
        _w.budgets[id] = b.copyWith(alert80SentAt: at);
      case BudgetThreshold.p100:
        if (b.alert100SentAt != null) return false;
        _w.budgets[id] = b.copyWith(
          alert100SentAt: at,
          alert80SentAt: b.alert80SentAt ?? at,
        );
    }
    _w.changed();
    return true;
  }
}

/// Records budget alerts instead of showing them (feature 003 T057).
final class FakeBudgetAlertNotifier implements BudgetAlertNotifier {
  final List<BudgetAlert> sent = [];
  int cancelAllCalls = 0;

  /// When set, [notify] throws it (FR-018: the save must not care).
  Exception? error;

  @override
  Future<void> notify(BudgetAlert alert) async {
    if (error case final e?) throw e;
    sent.add(alert);
  }

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

/// A [NotificationGate] with a settable answer (feature 003 T057).
final class FakeNotificationGate implements NotificationGate {
  bool allowed = true;

  /// When set, every check waits on it (a check that never completes).
  Completer<bool>? hold;
  int checks = 0;

  @override
  Future<bool> budgetAlertsAllowed() async {
    checks++;
    if (hold case final h?) return await h.future;
    return allowed;
  }
}

/// In-memory [RecurringRuleRepository] over the shared world, with the same
/// schedule, link, undo and exactly-once rules as the Drift one (feature 003
/// T075). Records calls in [calls].
final class FakeRecurringRuleRepository implements RecurringRuleRepository {
  new(this._w);

  final FakeExpenseWorld _w;
  final Map<String, int> calls = {};

  void _count(String name) => calls[name] = (calls[name] ?? 0) + 1;

  DateTime _now() => _w.clock.now().toUtc();

  RecurrenceSchedule _schedule(RecurringRule r) => RecurrenceSchedule(
    anchorLocal: r.anchorAt.toLocal(),
    frequency: r.frequency,
    interval: r.interval,
  );

  static bool _withinEnd(DateTime at, DateTime? end) =>
      end == null || !at.isAfter(end);

  RecurringRule? _live(String id) {
    final r = _w.rules[id];
    return r == null || r.deletedAt != null ? null : r;
  }

  RecurringRule _newRule(
    TransactionDraft draft,
    RepeatSettings repeat,
    DateTime anchor,
  ) {
    final now = _now();
    final schedule = RecurrenceSchedule(
      anchorLocal: anchor.toLocal(),
      frequency: repeat.frequency,
    );
    final next = schedule.occurrence(1).toUtc();
    final end = repeat.endAt?.toUtc();
    final rule = RecurringRule(
      id: _w.nextId('rule'),
      type: draft.type,
      amountMinor: draft.amountMinor!,
      accountId: draft.accountId!,
      toAccountId: draft.toAccountId,
      categoryId: draft.categoryId,
      paymentMode: draft.paymentMode,
      note: draft.note.trim().isEmpty ? null : draft.note.trim(),
      frequency: repeat.frequency,
      interval: 1,
      anchorAt: anchor.toUtc(),
      nextRunAt: next,
      endAt: end,
      isActive: _withinEnd(next, end),
      createdAt: now,
      updatedAt: now,
    );
    _w.rules[rule.id] = rule;
    return rule;
  }

  @override
  Stream<List<RecurringRuleView>> watchAll() => _w.watch(() {
    final rules =
        [
          for (final r in _w.rules.values)
            if (r.deletedAt == null) r,
        ]..sort((a, b) {
          if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
          return a.nextRunAt.compareTo(b.nextRunAt);
        });
    return [
      for (final r in rules)
        RecurringRuleView(
          rule: r,
          account: _w.accounts[r.accountId]!,
          toAccount: r.toAccountId == null ? null : _w.accounts[r.toAccountId],
          category: r.categoryId == null ? null : _w.categories[r.categoryId],
        ),
    ];
  });

  @override
  Future<RecurringRule?> findById(String id) async => _w.rules[id];

  @override
  Future<({Transaction txn, RecurringRule rule})> createWithFirstOccurrence(
    TransactionDraft draft,
    RepeatSettings repeat,
  ) async {
    _w.checkWrite();
    _count('createWithFirstOccurrence');
    final rule = _newRule(draft, repeat, draft.occurredAt);
    final now = _now();
    final t = Transaction(
      id: _w.nextId('txn'),
      type: draft.type,
      amountMinor: draft.amountMinor!,
      accountId: draft.accountId!,
      toAccountId: draft.toAccountId,
      categoryId: draft.categoryId,
      paymentMode: draft.paymentMode,
      note: draft.note.trim().isEmpty ? null : draft.note.trim(),
      occurredAt: draft.occurredAt.toUtc(),
      receiptPath: draft.receiptPath,
      recurringRuleId: rule.id,
      createdAt: now,
      updatedAt: now,
    );
    _w.transactions[t.id] = t;
    _w.changed();
    return (txn: t, rule: rule);
  }

  @override
  Future<({Transaction txn, RecurringRule rule})> attachNewRule(
    String txnId,
    TransactionDraft draft,
    RepeatSettings repeat,
  ) async {
    _w.checkWrite();
    _count('attachNewRule');
    final old = _w.transactions[txnId];
    if (old == null || old.deletedAt != null) throw TransactionNotFound(txnId);
    if (old.recurringRuleId != null) throw TransactionAlreadyLinked(txnId);
    final rule = _newRule(draft, repeat, draft.occurredAt);
    final t = old.copyWith(
      type: draft.type,
      amountMinor: draft.amountMinor!,
      accountId: draft.accountId!,
      toAccountId: draft.toAccountId,
      categoryId: draft.categoryId,
      paymentMode: draft.paymentMode,
      note: draft.note.trim().isEmpty ? null : draft.note.trim(),
      occurredAt: draft.occurredAt.toUtc(),
      receiptPath: draft.receiptPath,
      recurringRuleId: rule.id,
      updatedAt: _now(),
    );
    _w.transactions[txnId] = t;
    _w.changed();
    return (txn: t, rule: rule);
  }

  @override
  Future<void> undoRuleCreation(
    String ruleId, {
    Transaction? restoreSnapshot,
  }) async {
    _count('undoRuleCreation');
    final now = _now();
    for (final t in [..._w.transactions.values]) {
      if (t.recurringRuleId != ruleId || t.deletedAt != null) continue;
      if (t.id == restoreSnapshot?.id) continue;
      _w.transactions[t.id] = t.copyWith(deletedAt: now);
    }
    if (restoreSnapshot case final s?) {
      _w.transactions[s.id] = s.copyWith(recurringRuleId: null);
    }
    final r = _w.rules[ruleId];
    if (r != null) _w.rules[ruleId] = r.copyWith(deletedAt: now);
    _w.changed();
  }

  @override
  Future<RecurringRule> updateRule(
    String id,
    TransactionDraft template,
    RepeatSettings repeat,
    DateTime nextDateLocal,
  ) async {
    _w.checkWrite();
    _count('updateRule');
    final old = _live(id);
    if (old == null) throw RuleNotFound(id);
    final schedule = RecurrenceSchedule(
      anchorLocal: nextDateLocal.toLocal(),
      frequency: repeat.frequency,
      interval: old.interval,
    );
    final now = _w.clock.now();
    final base = nextDateLocal.isAfter(now) ? nextDateLocal : now;
    final next = schedule.occurrence(schedule.indexAtOrAfter(base)).toUtc();
    final end = repeat.endAt?.toUtc();
    final r = old.copyWith(
      type: template.type,
      amountMinor: template.amountMinor!,
      accountId: template.accountId!,
      toAccountId: template.toAccountId,
      categoryId: template.categoryId,
      paymentMode: template.paymentMode,
      note: template.note.trim().isEmpty ? null : template.note.trim(),
      frequency: repeat.frequency,
      anchorAt: nextDateLocal.toUtc(),
      nextRunAt: next,
      endAt: end,
      isActive: (old.isActive || old.isEnded) && _withinEnd(next, end),
      updatedAt: _now(),
    );
    _w.rules[id] = r;
    _w.changed();
    return r;
  }

  @override
  Future<void> restoreRule(RecurringRule snapshot) async {
    _count('restoreRule');
    _w.rules[snapshot.id] = snapshot;
    _w.changed();
  }

  @override
  Future<void> pause(String id) async {
    _w.checkWrite();
    _count('pause');
    final r = _live(id);
    if (r == null) throw RuleNotFound(id);
    _w.rules[id] = r.copyWith(isActive: false);
    _w.changed();
  }

  @override
  Future<void> resume(String id) async {
    _w.checkWrite();
    _count('resume');
    final r = _live(id);
    if (r == null) throw RuleNotFound(id);
    final next = _schedule(r).firstAfter(_w.clock.now()).toUtc();
    _w.rules[id] = r.copyWith(
      nextRunAt: next.isAfter(r.nextRunAt) ? next : r.nextRunAt,
      isActive: _withinEnd(next, r.endAt),
    );
    _w.changed();
  }

  @override
  Future<void> softDelete(String id) async {
    _w.checkWrite();
    _count('softDelete');
    final r = _w.rules[id];
    if (r != null) _w.rules[id] = r.copyWith(deletedAt: _now());
    _w.changed();
  }

  @override
  Future<void> undelete(String id) async {
    _count('undelete');
    final r = _w.rules[id];
    if (r != null) _w.rules[id] = r.copyWith(deletedAt: null);
    _w.changed();
  }

  @override
  Future<List<String>> dueRuleIds(DateTime now) async => [
    for (final r in _w.rules.values)
      if (r.deletedAt == null && r.isActive && !r.nextRunAt.isAfter(now)) r.id,
  ];

  @override
  Future<List<Transaction>> generateDue(String ruleId, DateTime now) async {
    _count('generateDue');
    final r = _live(ruleId);
    if (r == null || !r.isActive || r.nextRunAt.isAfter(now)) return const [];
    final schedule = _schedule(r);
    var n = schedule.indexAtOrAfter(r.nextRunAt);
    final stamp = _now();
    final created = <Transaction>[];
    while (true) {
      final at = schedule.occurrence(n).toUtc();
      if (at.isAfter(now) || !_withinEnd(at, r.endAt)) break;
      final t = Transaction(
        id: _w.nextId('txn'),
        type: r.type,
        amountMinor: r.amountMinor,
        accountId: r.accountId,
        toAccountId: r.toAccountId,
        categoryId: r.categoryId,
        paymentMode: r.paymentMode,
        note: r.note,
        occurredAt: at,
        recurringRuleId: r.id,
        createdAt: stamp,
        updatedAt: stamp,
      );
      _w.transactions[t.id] = t;
      created.add(t);
      n++;
    }
    final next = schedule.occurrence(n).toUtc();
    _w.rules[ruleId] = r.copyWith(
      nextRunAt: next,
      isActive: _withinEnd(next, r.endAt),
    );
    _w.changed();
    return created;
  }
}
