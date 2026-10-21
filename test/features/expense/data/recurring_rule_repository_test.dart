import 'package:dailytrack/features/expense/data/repositories/drift_recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// DriftRecurringRuleRepository (contracts/repositories.md, research R8,
/// R9, R16; clarifications Q3, Q5) on a real in-memory database. "Now"
/// starts at Wednesday 14 Oct 2026 10:00 local.
void main() {
  late ExpenseDb x;
  late DriftRecurringRuleRepository repo;
  late String cash;
  late String sbi;
  late String rent;

  setUp(() async {
    x = await ExpenseDb.open();
    repo = DriftRecurringRuleRepository(x.db, x.clock);
    cash = await x.account('Cash');
    sbi = await x.account('SBI', type: AccountType.bank);
    rent = await x.category('Rent');
  });

  TransactionDraft draft({
    DateTime? at,
    int amount = 1500000,
    String? category,
    TxnType type = TxnType.expense,
    String? toAccount,
    String note = 'Rent',
  }) => TransactionDraft(
    type: type,
    amountMinor: amount,
    accountId: cash,
    toAccountId: toAccount,
    categoryId: type == TxnType.transfer ? null : (category ?? rent),
    paymentMode: PaymentMode.upi,
    note: note,
    occurredAt: (at ?? DateTime(2026, 10, 5, 9)).toUtc(),
  );

  Future<List<(DateTime, String?)>> linkedRows() async {
    final rows = await (x.db.select(
      x.db.transactions,
    )..where((t) => t.deletedAt.isNull())).get();
    return [
      for (final r
          in rows..sort((a, b) => a.occurredAt.compareTo(b.occurredAt)))
        (DateTime.fromMillisecondsSinceEpoch(r.occurredAt), r.recurringRuleId),
    ];
  }

  test('createWithFirstOccurrence: one transaction + one rule, linked; the '
      'next run is the following occurrence', () async {
    final r = await repo.createWithFirstOccurrence(
      draft(),
      const RepeatSettings(),
    );
    expect(r.txn.recurringRuleId, r.rule.id);
    expect(r.txn.amountMinor, 1500000);
    expect(r.rule.anchorAt, DateTime(2026, 10, 5, 9).toUtc());
    expect(r.rule.nextRunAt, DateTime(2026, 11, 5, 9).toUtc());
    expect(r.rule.isActive, isTrue);
    expect(r.rule.frequency, Frequency.monthly);
    expect(r.rule.note, 'Rent');
    expect(await linkedRows(), [(DateTime(2026, 10, 5, 9), r.rule.id)]);
  });

  test(
    'an end date before the next occurrence makes the rule ended at once',
    () async {
      final r = await repo.createWithFirstOccurrence(
        draft(),
        RepeatSettings(endDate: DateTime(2026, 10, 20)),
      );
      expect(r.rule.isActive, isFalse);
      expect(r.rule.isEnded, isTrue);
    },
  );

  group('attachNewRule (Q3)', () {
    test('links an unlinked entry and saves its edited values', () async {
      final t = await x.add(account: cash, category: rent, amount: 1000);
      final r = await repo.attachNewRule(
        t.id,
        draft(at: DateTime(2026, 10, 1, 8), amount: 2000),
        const RepeatSettings(frequency: Frequency.weekly),
      );
      expect(r.txn.id, t.id);
      expect(r.txn.recurringRuleId, r.rule.id);
      expect(r.txn.amountMinor, 2000);
      expect(r.rule.nextRunAt, DateTime(2026, 10, 8, 8).toUtc());
    });

    test('refuses a linked entry and a missing one', () async {
      final first = await repo.createWithFirstOccurrence(
        draft(),
        const RepeatSettings(),
      );
      await expectLater(
        repo.attachNewRule(first.txn.id, draft(), const RepeatSettings()),
        throwsA(isA<TransactionAlreadyLinked>()),
      );
      await expectLater(
        repo.attachNewRule('missing', draft(), const RepeatSettings()),
        throwsA(isA<TransactionNotFound>()),
      );
    });

    test('EXP-02 US3-14: an entry from 3 months ago backfills exactly 3 '
        'linked rows; undo removes them and restores the entry', () async {
      final t = await x.add(
        account: cash,
        category: rent,
        amount: 1000,
        at: DateTime(2026, 7, 5, 9),
        note: 'old',
      );
      final r = await repo.attachNewRule(
        t.id,
        draft(at: DateTime(2026, 7, 5, 9)),
        const RepeatSettings(),
      );
      final created = await repo.generateDue(r.rule.id, x.clock.now());
      expect(created.map((c) => c.occurredAt.toLocal()), [
        DateTime(2026, 8, 5, 9),
        DateTime(2026, 9, 5, 9),
        DateTime(2026, 10, 5, 9),
      ]);
      expect(created.every((c) => c.recurringRuleId == r.rule.id), isTrue);

      await repo.undoRuleCreation(r.rule.id, restoreSnapshot: t);
      final rows = await linkedRows();
      expect(rows, [(DateTime(2026, 7, 5, 9), null)]);
      final restored = (await x.transactions.findById(t.id))!.transaction;
      expect(restored.amountMinor, 1000);
      expect(restored.note, 'old');
      expect((await repo.findById(r.rule.id))!.deletedAt, isNotNull);
    });
  });

  test('undoRuleCreation for a new entry removes the rule and every linked '
      'row', () async {
    final r = await repo.createWithFirstOccurrence(
      draft(at: DateTime(2026, 8, 5, 9)),
      const RepeatSettings(),
    );
    await repo.generateDue(r.rule.id, x.clock.now());
    expect(await linkedRows(), hasLength(3));
    await repo.undoRuleCreation(r.rule.id);
    expect(await linkedRows(), isEmpty);
    expect(await repo.dueRuleIds(DateTime(2030)), isEmpty);
  });

  group('updateRule (future occurrences only)', () {
    test(
      'changes the template and schedule; existing rows are unchanged',
      () async {
        final r = await repo.createWithFirstOccurrence(
          draft(at: DateTime(2026, 9, 5, 9)),
          const RepeatSettings(),
        );
        await repo.generateDue(r.rule.id, x.clock.now());
        final before = await linkedRows();
        final u = await repo.updateRule(
          r.rule.id,
          draft(amount: 1600000, note: 'New rent'),
          const RepeatSettings(),
          DateTime(2026, 11, 10, 9),
        );
        expect(u.amountMinor, 1600000);
        expect(u.anchorAt, DateTime(2026, 11, 10, 9).toUtc());
        expect(u.nextRunAt, DateTime(2026, 11, 10, 9).toUtc());
        expect(await linkedRows(), before);
        final rows = await x.db.select(x.db.transactions).get();
        expect(rows.every((t) => t.amountMinor == 1500000), isTrue);
      },
    );

    test('a chosen date in the past starts at the first occurrence after '
        'now', () async {
      final r = await repo.createWithFirstOccurrence(
        draft(),
        const RepeatSettings(),
      );
      final u = await repo.updateRule(
        r.rule.id,
        draft(),
        const RepeatSettings(frequency: Frequency.weekly),
        DateTime(2026, 10, 1, 9), // a Thursday, 13 days ago
      );
      expect(u.nextRunAt, DateTime(2026, 10, 15, 9).toUtc());
      expect(u.frequency, Frequency.weekly);
    });

    test('restoreRule undoes an edit', () async {
      final r = await repo.createWithFirstOccurrence(
        draft(),
        const RepeatSettings(),
      );
      await repo.updateRule(
        r.rule.id,
        draft(amount: 1),
        const RepeatSettings(),
        DateTime(2026, 12),
      );
      await repo.restoreRule(r.rule);
      expect(await repo.findById(r.rule.id), r.rule);
    });

    test('a missing rule throws RuleNotFound', () async {
      await expectLater(
        repo.updateRule('x', draft(), const RepeatSettings(), DateTime(2027)),
        throwsA(isA<RuleNotFound>()),
      );
    });
  });

  test('US3 s10: pause then resume skips the occurrences missed during the '
      'pause', () async {
    final r = await repo.createWithFirstOccurrence(
      draft(),
      const RepeatSettings(),
    );
    await repo.pause(r.rule.id);
    expect(await repo.dueRuleIds(DateTime(2027, 6)), isEmpty);
    x.clock.value = DateTime(2027, 2, 20, 10);
    await repo.resume(r.rule.id);
    final resumed = (await repo.findById(r.rule.id))!;
    expect(resumed.isActive, isTrue);
    expect(resumed.nextRunAt, DateTime(2027, 3, 5, 9).toUtc());
    expect(await repo.generateDue(r.rule.id, x.clock.now()), isEmpty);
    expect(await linkedRows(), hasLength(1), reason: 'only the first entry');
  });

  test('softDelete keeps generated rows and their links; undelete restores '
      'the rule', () async {
    final r = await repo.createWithFirstOccurrence(
      draft(at: DateTime(2026, 9, 5, 9)),
      const RepeatSettings(),
    );
    await repo.generateDue(r.rule.id, x.clock.now());
    await repo.softDelete(r.rule.id);
    expect(await linkedRows(), [
      (DateTime(2026, 9, 5, 9), r.rule.id),
      (DateTime(2026, 10, 5, 9), r.rule.id),
    ]);
    expect(await repo.watchAll().first, isEmpty);
    expect((await repo.findById(r.rule.id))!.deletedAt, isNotNull);
    await repo.undelete(r.rule.id);
    expect(await repo.watchAll().first, hasLength(1));
  });

  test('watchAll: active rules first by next run, then paused or ended; '
      'stale references are flagged', () async {
    final later = await repo.createWithFirstOccurrence(
      draft(at: DateTime(2026, 10, 9, 9)),
      const RepeatSettings(),
    );
    final sooner = await repo.createWithFirstOccurrence(
      draft(at: DateTime(2026, 10, 7, 9)),
      const RepeatSettings(),
    );
    final paused = await repo.createWithFirstOccurrence(
      draft(at: DateTime(2026, 10, 1, 9)),
      const RepeatSettings(),
    );
    await repo.pause(paused.rule.id);
    var all = await repo.watchAll().first;
    expect(all.map((v) => v.rule.id), [
      sooner.rule.id,
      later.rule.id,
      paused.rule.id,
    ]);
    expect(all.any((v) => v.staleReference), isFalse);

    await x.categories.setHidden(rent, hidden: true);
    all = await repo.watchAll().first;
    expect(all.every((v) => v.staleReference), isTrue);
    await x.categories.setHidden(rent, hidden: false);
    await x.accounts.setArchived(cash, archived: true);
    all = await repo.watchAll().first;
    expect(all.first.staleReference, isTrue);
    expect(all.first.account.id, cash);
    expect(sbi, isNotEmpty);
  });
}
