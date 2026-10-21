import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-02 controller intents (T051, contracts/screens.md), with fakes only.
void main() {
  Future<(ProviderContainer, TransactionFormControllerProvider)> ready(
    ExpenseFakes f,
    TransactionFormArgs args,
  ) async {
    final container = ProviderContainer(overrides: f.overrides);
    addTearDown(container.dispose);
    final provider = transactionFormControllerProvider(args);
    container.listen(provider, (_, _) {});
    for (var i = 0; i < 20; i++) {
      await pumpEventQueue();
      if (container.read(provider).status != FormStatus.loading) break;
    }
    return (container, provider);
  }

  const add = TransactionFormArgs(mode: FormMode.add);

  test('a new form defaults to the last-used account, its payment mode, '
      'and now', () async {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('Card', id: 'card', type: AccountType.card)
      ..addTransaction(amount: 1, account: 'card', category: 'food');
    final (c, p) = await ready(f, add);
    final s = c.read(p);
    expect(s.status, FormStatus.ready);
    expect(s.draft.accountId, 'card');
    expect(s.draft.paymentMode, PaymentMode.card);
    expect(s.draft.occurredAt, f.clock.now().toUtc());
    expect(s.keypadOpen, isTrue);
    expect(s.isDirty, isFalse);
  });

  test('isDirty follows changes and goes back when they are undone', () async {
    final (c, p) = await ready(ExpenseFakes.withDefaults(), add);
    final ctrl = c.read(p.notifier)..key('5');
    expect(c.read(p).isDirty, isTrue);
    ctrl.backspace();
    expect(c.read(p).isDirty, isFalse);
  });

  test('keypad: one decimal point per number, operators replace each other, '
      '= keeps the result', () async {
    final (c, p) = await ready(ExpenseFakes.withDefaults(), add);
    c.read(p.notifier)
      ..key('.')
      ..key('5')
      ..key('.')
      ..operator('+')
      ..operator('×')
      ..key('2')
      ..equals();
    final s = c.read(p);
    expect(s.expression, '1');
    expect(s.draft.amountMinor, 100);
  });

  test('setType clears the category; leaving Transfer clears the '
      'destination', () async {
    final f = ExpenseFakes.withDefaults()..addAccount('SBI', id: 'sbi');
    final (c, p) = await ready(f, add);
    final ctrl = c.read(p.notifier)
      ..selectCategory('food')
      ..setType(TxnType.income);
    expect(c.read(p).draft.categoryId, isNull);

    ctrl
      ..setType(TxnType.transfer)
      ..selectToAccount('sbi');
    expect(c.read(p).categories, isEmpty);
    ctrl.setType(TxnType.expense);
    expect(c.read(p).draft.toAccountId, isNull);
  });

  test('edit mode keeps an archived account selectable', () async {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('Old card', id: 'old', archived: true);
    final t = f.addTransaction(amount: 300, account: 'old', category: 'food');
    final (c, p) = await ready(
      f,
      TransactionFormArgs(mode: FormMode.edit, id: t.id),
    );
    final s = c.read(p);
    expect(s.isEdit, isTrue);
    expect(s.accounts.map((a) => a.id), containsAll(['cash', 'old']));
    expect(s.draft.accountId, 'old');
    expect(s.expression, '3');
    expect(s.keypadOpen, isFalse);
  });

  test('duplicateOf prefills with now and no receipt', () async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(
      amount: 1250,
      category: 'food',
      note: 'Chai',
      at: DateTime(2026, 9, 1, 8),
      receipt: 'receipts/a.jpg',
      mode: PaymentMode.upi,
    );
    final (c, p) = await ready(
      f,
      TransactionFormArgs(mode: FormMode.add, duplicateOf: t.id),
    );
    final d = c.read(p).draft;
    expect(d.amountMinor, 1250);
    expect(d.categoryId, 'food');
    expect(d.note, 'Chai');
    expect(d.paymentMode, PaymentMode.upi);
    expect(d.occurredAt, f.clock.now().toUtc());
    expect(d.receiptPath, isNull);
    expect(c.read(p).isEdit, isFalse);
  });

  test('a missing entry in edit mode is "notFound"', () async {
    final (c, p) = await ready(
      ExpenseFakes.withDefaults(),
      const TransactionFormArgs(mode: FormMode.edit, id: 'missing'),
    );
    expect(c.read(p).status, FormStatus.notFound);
  });

  test('save validates first and only writes a valid draft', () async {
    final f = ExpenseFakes.withDefaults();
    final (c, p) = await ready(f, add);
    final ctrl = c.read(p.notifier);
    expect(await ctrl.save(), isNull);
    expect(c.read(p).showErrors, isTrue);
    expect(f.transactions.writes, 0);

    ctrl
      ..key('9')
      ..selectCategory('food');
    final result = await ctrl.save();
    expect(result, isNotNull);
    expect(f.active.single.amountMinor, 900);
    await result!.undo();
    expect(f.active, isEmpty);
  });
}
