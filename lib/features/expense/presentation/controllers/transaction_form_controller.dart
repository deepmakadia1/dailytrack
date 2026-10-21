import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/utils/result.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_transaction.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';

part 'transaction_form_controller.g.dart';

/// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
/// only notifier. Defaults remember the user (research R7): last-used
/// account, payment mode from the account type, categories by usage.
@riverpod
class TransactionFormController extends _$TransactionFormController {
  final List<StreamSubscription<Object?>> _subs = [];
  Timer? _notesDebounce;

  /// The draft, expression and Repeat section as first loaded, for
  /// [TransactionFormState.isDirty].
  (TransactionDraft, String, RepeatState)? _initial;

  /// The rule being edited (rule-edit mode).
  RecurringRule? _rule;
  var _gotAccounts = false;
  var _gotExpense = false;
  var _gotIncome = false;

  @override
  TransactionFormState build(TransactionFormArgs args) {
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      _notesDebounce?.cancel();
    });
    unawaited(Future.microtask(_load));
    return TransactionFormState(
      status: FormStatus.loading,
      draft: TransactionDraft(
        type: args.initialType,
        paymentMode: PaymentMode.cash,
        occurredAt: _now(),
      ),
      repeat: RepeatState(enabled: args.repeat),
    );
  }

  DateTime _now() => ref.read(clockProvider).now().toUtc();

  Future<void> _load() async {
    final txns = ref.read(transactionRepositoryProvider);
    final cats = ref.read(categoryRepositoryProvider);
    final accts = ref.read(accountRepositoryProvider);
    try {
      final source = switch (args) {
        TransactionFormArgs(mode: FormMode.edit, :final id?) =>
          await txns.findById(id),
        TransactionFormArgs(:final duplicateOf?) => await txns.findById(
          duplicateOf,
        ),
        _ => null,
      };
      if (!ref.mounted) return;
      if (args.mode == FormMode.edit && source == null) {
        state = state.copyWith(status: FormStatus.notFound);
        return;
      }
      if (args case TransactionFormArgs(
        mode: FormMode.ruleEdit,
        :final ruleId?,
      )) {
        final rule = await ref
            .read(recurringRuleRepositoryProvider)
            .findById(ruleId);
        if (!ref.mounted) return;
        if (rule == null || rule.deletedAt != null) {
          state = state.copyWith(status: FormStatus.notFound);
          return;
        }
        _rule = rule;
      }
      final lastUsed = source == null ? await txns.lastUsedAccountId() : null;
      if (!ref.mounted) return;

      _subs
        ..add(
          accts.watchPickable().listen((list) {
            _gotAccounts = true;
            _onAccounts(list, source, lastUsed);
          }, onError: _onLoadError),
        )
        ..add(
          cats.watchPickable(CategoryType.expense).listen((list) {
            _gotExpense = true;
            _update(state.copyWith(expenseCategories: list));
          }, onError: _onLoadError),
        )
        ..add(
          cats.watchPickable(CategoryType.income).listen((list) {
            _gotIncome = true;
            _update(state.copyWith(incomeCategories: list));
          }, onError: _onLoadError),
        );

      if (args case TransactionFormArgs(mode: FormMode.edit, :final id?)) {
        _subs.add(
          txns.watchById(id).listen((view) {
            if (view == null && state.status == FormStatus.ready) {
              state = state.copyWith(status: FormStatus.notFound);
            }
          }, onError: (_) {}),
        );
      }
      unawaited(_refreshNotes(''));
    } on Exception {
      _onLoadError(null);
    }
  }

  void _onLoadError(Object? _) {
    if (ref.mounted && state.status != FormStatus.ready) {
      state = state.copyWith(status: FormStatus.loadError);
    }
  }

  /// First account emission builds the initial draft; later ones only
  /// refresh the list.
  void _onAccounts(
    List<Account> pickable,
    TransactionView? source,
    String? lastUsed,
  ) {
    // In edit mode an archived account stays selectable (data-model §3.3).
    final extra = [
      if (source != null && args.mode == FormMode.edit) ...[
        source.account,
        ?source.toAccount,
      ],
    ].where((a) => !pickable.any((p) => p.id == a.id));
    final accounts = [...pickable, ...extra];

    if (_initial != null) {
      _update(state.copyWith(accounts: accounts));
      return;
    }

    final TransactionDraft draft;
    var repeat = state.repeat;
    final rule = _rule;
    if (rule != null) {
      // Rule-edit: the template, dated at the next occurrence ("Next date").
      draft = TransactionDraft(
        type: rule.type,
        amountMinor: rule.amountMinor,
        accountId: rule.accountId,
        toAccountId: rule.toAccountId,
        categoryId: rule.categoryId,
        paymentMode: rule.paymentMode,
        note: rule.note ?? '',
        occurredAt: rule.nextRunAt,
      );
      final end = rule.endAt?.toLocal();
      repeat = RepeatState(
        enabled: true,
        frequency: rule.frequency,
        endDate: end == null ? null : DateTime(end.year, end.month, end.day),
      );
    } else if (source != null) {
      final t = source.transaction;
      final isDuplicate = args.mode == FormMode.add;
      draft = TransactionDraft(
        type: t.type,
        amountMinor: t.amountMinor,
        accountId: t.accountId,
        toAccountId: t.toAccountId,
        categoryId: t.categoryId,
        paymentMode: t.paymentMode,
        note: t.note ?? '',
        occurredAt: isDuplicate ? _now() : t.occurredAt,
        receiptPath: isDuplicate ? null : t.receiptPath,
      );
    } else {
      final account = pickable
          .where((a) => a.id == lastUsed)
          .followedBy(pickable)
          .firstOrNull;
      draft = state.draft.copyWith(
        accountId: account?.id,
        paymentMode: account?.type.defaultPaymentMode ?? PaymentMode.cash,
        occurredAt: _now(),
      );
    }
    final expression = draft.amountMinor == null
        ? ''
        : _minorToExpression(draft.amountMinor!);
    _initial = (draft, expression, repeat);
    final isEdit = args.mode == FormMode.edit;
    _update(
      state.copyWith(
        accounts: accounts,
        draft: draft,
        expression: expression,
        original: isEdit ? source?.transaction : null,
        originalRule: rule,
        repeat: repeat,
        linkedToRule: isEdit && source?.transaction.recurringRuleId != null,
        keypadOpen: args.mode == FormMode.add && source == null,
      ),
    );
  }

  /// Applies [next], marks the form ready once every list has arrived, and
  /// recomputes dirtiness and (after a save attempt) errors.
  void _update(TransactionFormState next) {
    if (!ref.mounted) return;
    var s = next;
    if (s.status == FormStatus.loading &&
        _initial != null &&
        _gotAccounts &&
        _gotExpense &&
        _gotIncome) {
      s = s.copyWith(status: FormStatus.ready);
    }
    final initial = _initial;
    s = s.copyWith(
      isDirty:
          initial != null &&
          (s.draft != initial.$1 ||
              s.expression != initial.$2 ||
              s.repeat != initial.$3),
      errors: s.showErrors ? _validate(s) : const {},
    );
    state = s;
  }

  Map<TxnField, TxnError> _validate(TransactionFormState s) =>
      validateTransaction(
        s.draft,
        amountError: _amountError(s.expression),
        repeat: s.repeatSettings,
      );

  static AmountError? _amountError(String expression) =>
      switch (AmountEntry.parse(expression)) {
        Err(:final error) => error,
        Ok() => null,
      };

  static String _minorToExpression(int minor) {
    final paise = minor % 100;
    return paise == 0
        ? '${minor ~/ 100}'
        : '${minor ~/ 100}.${paise.toString().padLeft(2, '0')}';
  }

  void _setExpression(String expression) {
    final amount = switch (AmountEntry.parse(expression)) {
      Ok(:final value) => value,
      Err() => null,
    };
    _update(
      state.copyWith(
        expression: expression,
        draft: state.draft.copyWith(amountMinor: amount),
      ),
    );
  }

  static bool _isOperator(String ch) =>
      ch == KeypadExpression.plus ||
      ch == KeypadExpression.minus ||
      ch == KeypadExpression.times ||
      ch == KeypadExpression.divide;

  // --- Keypad intents ---

  void key(String digitOrPoint) {
    final e = state.expression;
    final lastTerm = e.split(RegExp('[+−×÷]')).last;
    if (digitOrPoint == '.' && lastTerm.contains('.')) return;
    _setExpression(
      digitOrPoint == '.' && lastTerm.isEmpty ? '${e}0.' : '$e$digitOrPoint',
    );
  }

  void operator(String op) {
    if (op == '=') return equals();
    final e = state.expression;
    if (e.isEmpty) return;
    final base = _isOperator(e[e.length - 1])
        ? e.substring(0, e.length - 1)
        : e;
    _setExpression('$base$op');
  }

  void backspace() {
    final e = state.expression;
    if (e.isEmpty) return;
    _setExpression(e.substring(0, e.length - 1));
  }

  /// Replaces the calculation with its result.
  void equals() {
    if (AmountEntry.parse(state.expression) case Ok(:final value)) {
      _setExpression(_minorToExpression(value));
    }
  }

  void setKeypadOpen({required bool open}) {
    // A drag sends many scroll notifications (research R2).
    if (open == state.keypadOpen) return;
    _update(state.copyWith(keypadOpen: open));
  }

  // --- Field intents ---

  void setType(TxnType type) {
    if (type == state.draft.type) return;
    _update(
      state.copyWith(
        draft: state.draft.copyWith(
          type: type,
          categoryId: null,
          toAccountId: type == TxnType.transfer
              ? state.draft.toAccountId
              : null,
        ),
      ),
    );
  }

  void selectCategory(String id) =>
      _update(state.copyWith(draft: state.draft.copyWith(categoryId: id)));

  /// A category created from "+ New" (EXP-05) is selected right away.
  void onCategoryCreated(Category category) => selectCategory(category.id);

  /// Picking the source account also sets its default payment mode (Q4).
  void selectAccount(String id) {
    final account = state.accountById(id);
    _update(
      state.copyWith(
        draft: state.draft.copyWith(
          accountId: id,
          paymentMode:
              account?.type.defaultPaymentMode ?? state.draft.paymentMode,
        ),
      ),
    );
  }

  void selectToAccount(String id) =>
      _update(state.copyWith(draft: state.draft.copyWith(toAccountId: id)));

  void setPaymentMode(PaymentMode mode) =>
      _update(state.copyWith(draft: state.draft.copyWith(paymentMode: mode)));

  void setOccurredAt(DateTime local) => _update(
    state.copyWith(draft: state.draft.copyWith(occurredAt: local.toUtc())),
  );

  void setNote(String note) {
    _update(state.copyWith(draft: state.draft.copyWith(note: note)));
    _notesDebounce?.cancel();
    _notesDebounce = Timer(
      const Duration(milliseconds: 200),
      () => unawaited(_refreshNotes(note.trim())),
    );
  }

  Future<void> _refreshNotes(String prefix) async {
    try {
      final notes = await ref
          .read(transactionRepositoryProvider)
          .recentNotes(prefix: prefix);
      if (!ref.mounted) return;
      _update(
        state.copyWith(
          noteSuggestions: [
            for (final n in notes)
              if (n != state.draft.note.trim()) n,
          ],
        ),
      );
    } on Exception {
      // Suggestions are optional.
    }
  }

  Future<void> pickReceipt(ReceiptSource source) async {
    _update(state.copyWith(receiptFailed: false));
    try {
      final path = await ref.read(receiptPickerProvider).pick(source);
      if (path == null || !ref.mounted) return;
      _update(state.copyWith(draft: state.draft.copyWith(receiptPath: path)));
    } on ReceiptFailure {
      if (ref.mounted) _update(state.copyWith(receiptFailed: true));
    }
  }

  void removeReceipt() =>
      _update(state.copyWith(draft: state.draft.copyWith(receiptPath: null)));

  // --- Repeat intents (FR-021) ---

  void toggleRepeat() => _update(
    state.copyWith(
      repeat: state.repeat.copyWith(enabled: !state.repeat.enabled),
    ),
  );

  void setFrequency(Frequency frequency) => _update(
    state.copyWith(repeat: state.repeat.copyWith(frequency: frequency)),
  );

  void setEndDate(DateTime local) => _update(
    state.copyWith(
      repeat: state.repeat.copyWith(
        endDate: DateTime(local.year, local.month, local.day),
      ),
    ),
  );

  void clearEndDate() =>
      _update(state.copyWith(repeat: state.repeat.copyWith(endDate: null)));

  // --- Save and delete ---

  /// Validates and saves. Returns null when invalid or when saving failed
  /// (the form stays open with the input intact).
  Future<SaveResult?> save({bool addAnother = false}) async {
    final errors = _validate(state);
    if (errors.isNotEmpty) {
      _update(state.copyWith(showErrors: true));
      return null;
    }
    _update(state.copyWith(saving: true, saveFailed: false));
    final txns = ref.read(transactionRepositoryProvider);
    try {
      final original = state.original;
      final saved = state.draft;
      final repeat = state.repeatSettings;
      final rules = ref.read(recurringRuleRepositoryProvider);
      final SaveResult result;
      if (state.originalRule case final rule?) {
        result = await _saveRule(rule, saved, repeat);
      } else if (repeat != null) {
        // FR-022: the entry is the first occurrence of a new rule; anything
        // already due is generated at once.
        final created = original == null
            ? await rules.createWithFirstOccurrence(saved, repeat)
            : await rules.attachNewRule(original.id, saved, repeat);
        final generated = await rules.generateDue(
          created.rule.id,
          ref.read(clockProvider).now(),
        );
        result = SaveResult(
          created.txn.id,
          () => rules.undoRuleCreation(
            created.rule.id,
            restoreSnapshot: original,
          ),
        );
        _checkBudgets(saved);
        _checkGenerated(generated);
      } else if (original == null) {
        final created = await txns.create(saved);
        result = SaveResult(created.id, () => txns.softDelete(created.id));
        _checkBudgets(saved);
      } else {
        await txns.update(original.id, saved);
        result = SaveResult(original.id, () => txns.restore(original));
        _checkBudgets(saved);
      }
      if (!ref.mounted) return result;
      if (addAnother) {
        _resetForAnother();
      } else {
        _update(state.copyWith(saving: false));
      }
      return result;
    } on TransactionNotFound {
      if (ref.mounted) state = state.copyWith(status: FormStatus.notFound);
      return null;
    } on RuleNotFound {
      if (ref.mounted) state = state.copyWith(status: FormStatus.notFound);
      return null;
    } on TransactionAlreadyLinked {
      if (ref.mounted) _update(state.copyWith(saving: false, saveFailed: true));
      return null;
    } on ExpenseStorageFailure {
      if (ref.mounted) _update(state.copyWith(saving: false, saveFailed: true));
      return null;
    }
  }

  /// Rule-edit save (research R16): Repeat on changes the rule for future
  /// occurrences (Undo restores the old rule); Repeat off ends it (Q5).
  /// Existing transactions never change.
  Future<SaveResult> _saveRule(
    RecurringRule rule,
    TransactionDraft template,
    RepeatSettings? repeat,
  ) async {
    final rules = ref.read(recurringRuleRepositoryProvider);
    if (repeat == null) {
      await rules.softDelete(rule.id);
      return SaveResult(
        rule.id,
        () => rules.undelete(rule.id),
        kind: SaveKind.ruleDeleted,
      );
    }
    await rules.updateRule(
      rule.id,
      template,
      repeat,
      template.occurredAt.toLocal(),
    );
    return SaveResult(rule.id, () => rules.restoreRule(rule));
  }

  /// Budget alerts for rows generated by a save (FR-029); the checker skips
  /// rows outside the current month.
  void _checkGenerated(List<Transaction> rows) {
    for (final t in rows) {
      _checkBudgets(
        TransactionDraft(
          type: t.type,
          paymentMode: t.paymentMode,
          occurredAt: t.occurredAt,
          categoryId: t.categoryId,
        ),
      );
    }
  }

  /// Budget alerts for a saved expense (FR-015, FR-018). Runs behind the
  /// save, so it never blocks, delays or fails it; the checker itself skips
  /// income, transfers and other months.
  void _checkBudgets(TransactionDraft saved) {
    if (saved.type != TxnType.expense) return;
    final BudgetAlertChecker checker;
    try {
      checker = ref.read(budgetAlertCheckerProvider);
    } on Object {
      return;
    }
    unawaited(
      checker
          .check(
            occurredAtUtcMs: saved.occurredAt.toUtc().millisecondsSinceEpoch,
            categoryId: saved.categoryId,
            type: saved.type,
          )
          .then((_) {}, onError: (Object _) {}),
    );
  }

  /// "Save and add another": same type and account, everything else fresh.
  void _resetForAnother() {
    final draft = TransactionDraft(
      type: state.draft.type,
      accountId: state.draft.accountId,
      paymentMode: state.draft.paymentMode,
      occurredAt: _now(),
    );
    _initial = (draft, '', const RepeatState());
    _update(
      state.copyWith(
        draft: draft,
        expression: '',
        saving: false,
        showErrors: false,
        keypadOpen: true,
        repeat: const RepeatState(),
      ),
    );
  }

  /// Edit mode only: soft-deletes the entry and returns its undo.
  Future<Future<void> Function()?> delete() async {
    final original = state.original;
    if (original == null) return null;
    final txns = ref.read(transactionRepositoryProvider);
    try {
      await txns.softDelete(original.id);
      return () => txns.undelete(original.id);
    } on ExpenseStorageFailure {
      if (ref.mounted) _update(state.copyWith(saveFailed: true));
      return null;
    }
  }

  /// Error state "Try again".
  void retry() => ref.invalidateSelf();
}
