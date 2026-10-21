import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_form_state.freezed.dart';

/// New entry, edit of an entry, or edit of a recurring rule (research
/// R16).
enum FormMode { add, edit, ruleEdit }

/// Which EXP-02 to open (contracts/screens.md, routes_and_module.md).
@freezed
abstract class TransactionFormArgs with _$TransactionFormArgs {
  const factory({
    required FormMode mode,

    /// The transaction being edited (edit mode).
    String? id,
    @Default(TxnType.expense) TxnType initialType,

    /// Prefill from this transaction, dated now, without its receipt.
    String? duplicateOf,

    /// The rule being edited (rule-edit mode, `/expenses/recurring/:id/edit`).
    String? ruleId,

    /// Start with Repeat on (`/expenses/recurring/add`, the EXP-10 empty
    /// state).
    @Default(false) bool repeat,
  }) = _TransactionFormArgs;
}

enum FormStatus {
  loading,
  ready,
  loadError,

  /// The entry being edited no longer exists (deleted elsewhere).
  notFound,
}

/// EXP-02 Repeat section (FR-021). Monthly is preselected.
@freezed
abstract class RepeatState with _$RepeatState {
  const factory({
    @Default(false) bool enabled,
    @Default(Frequency.monthly) Frequency frequency,

    /// Local date; null = no end.
    DateTime? endDate,
  }) = _RepeatState;

  const new _();

  RepeatSettings get settings =>
      RepeatSettings(frequency: frequency, endDate: endDate);
}

/// EXP-02 state (contracts/screens.md).
@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory({
    required FormStatus status,
    required TransactionDraft draft,

    /// Raw keypad input, e.g. `120+35.5`.
    @Default('') String expression,
    @Default(<TxnField, TxnError>{}) Map<TxnField, TxnError> errors,

    /// True after the first save attempt; errors then update live.
    @Default(false) bool showErrors,
    @Default(<Category>[]) List<Category> expenseCategories,
    @Default(<Category>[]) List<Category> incomeCategories,

    /// Pickable accounts, plus the edited entry's archived ones.
    @Default(<Account>[]) List<Account> accounts,
    @Default(<String>[]) List<String> noteSuggestions,
    @Default(true) bool keypadOpen,
    @Default(false) bool isDirty,
    @Default(false) bool saving,
    @Default(false) bool saveFailed,
    @Default(false) bool receiptFailed,

    /// The entry as loaded (edit mode), for Undo after an edit.
    Transaction? original,
    @Default(RepeatState()) RepeatState repeat,

    /// Edit of an entry that belongs to a rule: Repeat is hidden and the
    /// edit changes only this entry (US3 s13).
    @Default(false) bool linkedToRule,

    /// The rule as loaded (rule-edit mode), for Undo after a rule edit.
    RecurringRule? originalRule,
  }) = _TransactionFormState;

  const new _();

  bool get isEdit => original != null;

  bool get isRuleEdit => originalRule != null;

  /// The Repeat section is offered unless the entry belongs to a rule.
  bool get showRepeat => !linkedToRule;

  /// The Repeat settings that apply to a save, or null when Repeat is off.
  RepeatSettings? get repeatSettings =>
      showRepeat && repeat.enabled ? repeat.settings : null;

  /// Categories for the current type (empty for a transfer).
  List<Category> get categories => switch (draft.type) {
    TxnType.expense => expenseCategories,
    TxnType.income => incomeCategories,
    TxnType.transfer => const [],
  };

  Account? accountById(String? id) {
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }
}

/// Which snackbar a save shows.
enum SaveKind {
  /// "Saved · Undo".
  saved,

  /// Rule-edit with Repeat off ended the rule (Q5): "Recurring transaction
  /// deleted · Undo".
  ruleDeleted,
}

/// What `save` returns to the screen: the saved id and how to undo it.
final class SaveResult {
  const new(this.id, this.undo, {this.kind = SaveKind.saved});

  final String id;
  final Future<void> Function() undo;
  final SaveKind kind;
}
