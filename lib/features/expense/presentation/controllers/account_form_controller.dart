import 'dart:async';

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/utils/result.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_account.dart';
import 'package:dailytrack/features/expense/presentation/controllers/account_form_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/account_form_state.dart';

part 'account_form_controller.g.dart';

/// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
/// Family argument: the account id to edit, or null for a new account.
@riverpod
class AccountFormController extends _$AccountFormController {
  StreamSubscription<Object?>? _sub;

  @override
  AccountFormState build(String? id) {
    if (id == null) {
      return AccountFormState(
        status: AccountFormStatus.ready,
        colorHex: AppColors.toHex(AppColors.palette.first),
      );
    }
    _sub = ref
        .read(accountRepositoryProvider)
        .watchAllWithBalances()
        .listen(_onAccounts, onError: (Object _) => _onLoadError());
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const AccountFormState(status: AccountFormStatus.loading);
  }

  void _onLoadError() {
    if (state.status == AccountFormStatus.loading) {
      state = state.copyWith(status: AccountFormStatus.loadError);
    }
  }

  /// The first emission fills the form; later ones are ignored so typing
  /// is never overwritten.
  void _onAccounts(List<AccountWithBalance> all) {
    if (state.status != AccountFormStatus.loading) return;
    final a = all.where((x) => x.account.id == id).firstOrNull?.account;
    if (a == null) {
      state = state.copyWith(status: AccountFormStatus.loadError);
      return;
    }
    final abs = a.openingBalanceMinor.abs();
    state = state.copyWith(
      status: AccountFormStatus.ready,
      original: a,
      name: a.name,
      type: a.type,
      openingExpression: abs == 0 ? '' : _toExpression(abs),
      negative: a.openingBalanceMinor < 0,
      iconKey: a.iconKey,
      colorHex: a.colorHex,
    );
  }

  static String _toExpression(int minor) => minor % 100 == 0
      ? '${minor ~/ 100}'
      : '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';

  /// The signed opening balance, or null when the keypad input is invalid.
  int? get openingBalanceMinor =>
      switch (KeypadExpression.evaluateToMinor(state.openingExpression)) {
        Ok(:final value) => state.negative ? -value : value,
        Err() => null,
      };

  void setName(String name) => state = state.copyWith(
    name: name,
    errors: {...state.errors}..remove(AccountField.name),
  );

  void setType(AccountType type) => state = state.copyWith(type: type);

  void setNegative({required bool negative}) =>
      state = state.copyWith(negative: negative);

  void setIcon(String key) => state = state.copyWith(iconKey: key);

  void setColor(String hex) => state = state.copyWith(colorHex: hex);

  void setKeypadOpen({required bool open}) =>
      state = state.copyWith(keypadOpen: open);

  void key(String digitOrPoint) {
    final e = state.openingExpression;
    final last = e.split(RegExp('[+−×÷]')).last;
    if (digitOrPoint == '.' && last.contains('.')) return;
    _setExpression(
      digitOrPoint == '.' && last.isEmpty ? '${e}0.' : '$e$digitOrPoint',
    );
  }

  void operator(String op) {
    if (op == '=') {
      if (KeypadExpression.evaluateToMinor(state.openingExpression) case Ok(
        :final value,
      )) {
        _setExpression(value == 0 ? '' : _toExpression(value));
      }
      return;
    }
    if (state.openingExpression.isEmpty) return;
    _setExpression('${state.openingExpression}$op');
  }

  void backspace() {
    final e = state.openingExpression;
    if (e.isNotEmpty) _setExpression(e.substring(0, e.length - 1));
  }

  void _setExpression(String e) => state = state.copyWith(
    openingExpression: e,
    errors: {...state.errors}..remove(AccountField.openingBalance),
  );

  /// Validates (FR-028) and saves; null when invalid or the write failed.
  Future<Account?> save() async {
    final balance = openingBalanceMinor;
    final errors = validateAccount(
      name: state.name,
      openingBalanceMinor: balance ?? 0,
      balanceInvalid: balance == null,
    );
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return null;
    }
    state = state.copyWith(saving: true, saveFailed: false);
    final repo = ref.read(accountRepositoryProvider);
    try {
      final original = state.original;
      final Account saved;
      if (original == null) {
        saved = await repo.create(
          name: state.name,
          type: state.type,
          openingBalanceMinor: balance!,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
      } else {
        await repo.update(
          original.id,
          name: state.name,
          type: state.type,
          openingBalanceMinor: balance!,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
        saved = original.copyWith(
          name: state.name.trim(),
          type: state.type,
          openingBalanceMinor: balance,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
      }
      if (ref.mounted) state = state.copyWith(saving: false);
      return saved;
    } on ExpenseStorageFailure {
      if (ref.mounted) {
        state = state.copyWith(saving: false, saveFailed: true);
      }
      return null;
    }
  }

  void retry() => ref.invalidateSelf();
}
