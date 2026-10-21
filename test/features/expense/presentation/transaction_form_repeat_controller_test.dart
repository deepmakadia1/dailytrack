import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_transaction.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-02 Repeat section and modes (T064, contracts/screens.md, research
/// R16, clarifications Q3, Q5), with fakes only. "Now" is 14 Oct 2026.
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

  void fill(TransactionFormController c, {String amount = '15000'}) {
    amount.split('').forEach(c.key);
    c.selectCategory('rent');
  }

  test(
    'Repeat defaults to off and Monthly; /recurring/add starts it on',
    () async {
      final (c, p) = await ready(ExpenseFakes.withDefaults(), add);
      expect(c.read(p).repeat.enabled, isFalse);
      expect(c.read(p).repeat.frequency, Frequency.monthly);
      expect(c.read(p).showRepeat, isTrue);
      final (c2, p2) = await ready(
        ExpenseFakes.withDefaults(),
        const TransactionFormArgs(mode: FormMode.add, repeat: true),
      );
      expect(c2.read(p2).repeat.enabled, isTrue);
    },
  );

  test('repeat intents change the section and make the form dirty', () async {
    final (c, p) = await ready(ExpenseFakes.withDefaults(), add);
    final n = c.read(p.notifier)
      ..toggleRepeat()
      ..setFrequency(Frequency.weekly)
      ..setEndDate(DateTime(2027, 3, 4, 15));
    var s = c.read(p);
    expect(s.repeat.enabled, isTrue);
    expect(s.repeat.frequency, Frequency.weekly);
    expect(s.repeat.endDate, DateTime(2027, 3, 4));
    expect(s.isDirty, isTrue);
    n.clearEndDate();
    s = c.read(p);
    expect(s.repeat.endDate, isNull);
  });

  test('new + Repeat → createWithFirstOccurrence then generateDue; Undo '
      'removes the rule and every row', () async {
    final f = ExpenseFakes.withDefaults();
    final (c, p) = await ready(f, add);
    final n = c.read(p.notifier);
    fill(n);
    // Dated 3 months back, so 3 occurrences are already due.
    n
      ..setOccurredAt(DateTime(2026, 7, 5, 9))
      ..toggleRepeat();
    final result = await n.save();
    expect(result, isNotNull);
    expect(f.rules.calls['createWithFirstOccurrence'], 1);
    expect(f.rules.calls['generateDue'], 1);
    expect(f.active.map((t) => t.occurredAt.toLocal()).toList()..sort(), [
      DateTime(2026, 7, 5, 9),
      DateTime(2026, 8, 5, 9),
      DateTime(2026, 9, 5, 9),
      DateTime(2026, 10, 5, 9),
    ]);
    expect(f.active.every((t) => t.recurringRuleId != null), isTrue);

    await result!.undo();
    expect(f.active, isEmpty);
    expect(f.rules.calls['undoRuleCreation'], 1);
  });

  test('edit of an unlinked entry + Repeat → attachNewRule then generateDue; '
      'Undo restores the snapshot (Q3)', () async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(
      amount: 1000,
      category: 'rent',
      at: DateTime(2026, 9, 5, 9),
      note: 'Rent',
    );
    final (c, p) = await ready(
      f,
      TransactionFormArgs(mode: FormMode.edit, id: t.id),
    );
    expect(c.read(p).showRepeat, isTrue);
    final n = c.read(p.notifier)..toggleRepeat();
    final result = await n.save();
    expect(f.rules.calls['attachNewRule'], 1);
    expect(f.active, hasLength(2), reason: '5 Sep (the entry) + 5 Oct');
    await result!.undo();
    expect(f.active.single.id, t.id);
    expect(f.active.single.recurringRuleId, isNull);
    expect(f.active.single.note, 'Rent');
  });

  test('edit of a linked entry hides Repeat and saves only that entry (US3 '
      's13)', () async {
    final f = ExpenseFakes.withDefaults();
    final rule = f.addRule(amount: 1000, anchor: DateTime(2026, 9, 5, 9));
    final t = f.addTransaction(amount: 1000, category: 'rent');
    f.world.transactions[t.id] = t.copyWith(recurringRuleId: rule.id);
    final (c, p) = await ready(
      f,
      TransactionFormArgs(mode: FormMode.edit, id: t.id),
    );
    final s = c.read(p);
    expect(s.linkedToRule, isTrue);
    expect(s.showRepeat, isFalse);
    c.read(p.notifier)
      ..toggleRepeat()
      ..key('0');
    await c.read(p.notifier).save();
    expect(f.rules.calls['attachNewRule'], isNull);
    expect(f.world.transactions[t.id]!.amountMinor, 10000);
    expect(f.world.transactions[t.id]!.recurringRuleId, rule.id);
  });

  group('rule-edit mode', () {
    TransactionFormArgs ruleArgs(String id) =>
        TransactionFormArgs(mode: FormMode.ruleEdit, ruleId: id);

    test('loads the rule: template, next date, and Repeat on', () async {
      final f = ExpenseFakes.withDefaults();
      final rule = f.addRule(
        amount: 1500000,
        anchor: DateTime(2026, 9, 5, 9),
        note: 'Rent',
        endAt: DateTime(2027, 6, 30, 23, 59),
      );
      final (c, p) = await ready(f, ruleArgs(rule.id));
      final s = c.read(p);
      expect(s.status, FormStatus.ready);
      expect(s.isRuleEdit, isTrue);
      expect(s.isEdit, isFalse);
      expect(s.draft.amountMinor, 1500000);
      expect(s.draft.note, 'Rent');
      expect(s.draft.occurredAt, rule.nextRunAt);
      expect(s.repeat.enabled, isTrue);
      expect(s.repeat.endDate, DateTime(2027, 6, 30));
      expect(s.isDirty, isFalse);
    });

    test('save → updateRule; Undo restores the old rule', () async {
      final f = ExpenseFakes.withDefaults();
      final rule = f.addRule(amount: 1500000, anchor: DateTime(2026, 9, 5, 9));
      final (c, p) = await ready(f, ruleArgs(rule.id));
      final n = c.read(p.notifier)..key('0');
      final result = await n.save();
      expect(result!.kind, SaveKind.saved);
      expect(f.world.rules[rule.id]!.amountMinor, 15000000);
      expect(f.active, isEmpty, reason: 'no transaction is written');
      await result.undo();
      expect(f.world.rules[rule.id], rule);
    });

    test('Repeat off + save ends the rule; Undo restores it (Q5)', () async {
      final f = ExpenseFakes.withDefaults();
      final rule = f.addRule(amount: 1000, anchor: DateTime(2026, 9, 5, 9));
      final (c, p) = await ready(f, ruleArgs(rule.id));
      final n = c.read(p.notifier)..toggleRepeat();
      final result = await n.save();
      expect(result!.kind, SaveKind.ruleDeleted);
      expect(f.world.rules[rule.id]!.deletedAt, isNotNull);
      await result.undo();
      expect(f.world.rules[rule.id]!.deletedAt, isNull);
    });

    test('a missing or deleted rule shows the not-found state', () async {
      final f = ExpenseFakes.withDefaults();
      final (c, p) = await ready(f, ruleArgs('nope'));
      expect(c.read(p).status, FormStatus.notFound);
      final rule = f.addRule(amount: 1, anchor: DateTime(2026, 9, 5));
      f.world.rules[rule.id] = rule.copyWith(deletedAt: DateTime.utc(2026));
      final (c2, p2) = await ready(f, ruleArgs(rule.id));
      expect(c2.read(p2).status, FormStatus.notFound);
    });
  });

  test(
    'an end date before the entry date is an inline error under Repeat',
    () async {
      final f = ExpenseFakes.withDefaults();
      final (c, p) = await ready(f, add);
      final n = c.read(p.notifier);
      fill(n);
      n
        ..toggleRepeat()
        ..setEndDate(DateTime(2026, 10));
      expect(await n.save(), isNull);
      expect(c.read(p).errors[TxnField.repeat], TxnError.repeatEndBeforeStart);
      expect(f.rules.calls['createWithFirstOccurrence'], isNull);
    },
  );

  test(
    'a current-month generated expense is checked against budgets',
    () async {
      final f = ExpenseFakes.withDefaults()
        ..addBudget(limit: 100000, category: 'rent');
      final (c, p) = await ready(f, add);
      final n = c.read(p.notifier);
      fill(n, amount: '500');
      n
        ..setOccurredAt(DateTime(2026, 9, 14, 9))
        ..toggleRepeat();
      await n.save();
      await pumpEventQueue();
      // 14 Sep (past month) is not alerted; 14 Oct reaches 50% only.
      expect(f.alertNotifier.sent, isEmpty);
      expect(f.budgets.calls['forAlert'], 1, reason: 'only the October row');
    },
  );
}
