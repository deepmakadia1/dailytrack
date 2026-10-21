import 'dart:math';

import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_recurring_rule_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';
import 'package:dailytrack/features/expense/domain/usecases/generate_recurring.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import 'expense_db_fixture.dart';

/// RecurringGenerator over the real Drift repository (FR-023–FR-025,
/// FR-029, research R9): exact occurrence sets after gaps, month ends, no
/// duplicates across repeated and concurrent runs.
void main() {
  late ExpenseDb x;
  late DriftRecurringRuleRepository rules;
  late RecurringGenerator generator;
  late String cash;
  late String sbi;
  late String rent;

  setUp(() async {
    x = await ExpenseDb.open();
    rules = DriftRecurringRuleRepository(x.db, x.clock);
    generator = RecurringGenerator(rules, x.clock);
    cash = await x.account('Cash');
    sbi = await x.account('SBI', type: AccountType.bank);
    rent = await x.category('Rent');
  });

  Future<String> rule(
    DateTime at, {
    Frequency frequency = Frequency.monthly,
    DateTime? endDate,
    TxnType type = TxnType.expense,
    String? account,
  }) async {
    final r = await rules.createWithFirstOccurrence(
      TransactionDraft(
        type: type,
        amountMinor: 50000,
        accountId: account ?? cash,
        toAccountId: type == TxnType.transfer ? sbi : null,
        categoryId: type == TxnType.transfer ? null : rent,
        paymentMode: PaymentMode.upi,
        note: 'auto',
        occurredAt: at.toUtc(),
      ),
      RepeatSettings(frequency: frequency, endDate: endDate),
    );
    return r.rule.id;
  }

  /// Live rows of [ruleId], oldest first, as local times.
  Future<List<DateTime>> rowsOf(String ruleId) async {
    final rows =
        await (x.db.select(x.db.transactions)
              ..where(
                (t) => t.recurringRuleId.equals(ruleId) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
            .get();
    return [
      for (final r in rows) DateTime.fromMillisecondsSinceEpoch(r.occurredAt),
    ];
  }

  /// Expected occurrences from [anchor] up to [until], by plain calendar
  /// arithmetic (independent of RecurrenceSchedule).
  List<DateTime> expected(DateTime anchor, Frequency f, DateTime until) {
    int daysIn(int y, int m) => DateTime(y, m + 1, 0).day;
    final out = <DateTime>[];
    for (var n = 0; ; n++) {
      final DateTime d;
      switch (f) {
        case Frequency.daily:
          d = DateTime(
            anchor.year,
            anchor.month,
            anchor.day + n,
            anchor.hour,
            anchor.minute,
          );
        case Frequency.weekly:
          d = DateTime(
            anchor.year,
            anchor.month,
            anchor.day + 7 * n,
            anchor.hour,
            anchor.minute,
          );
        case Frequency.monthly:
          final y = anchor.year + (anchor.month - 1 + n) ~/ 12;
          final m = (anchor.month - 1 + n) % 12 + 1;
          d = DateTime(
            y,
            m,
            min(anchor.day, daysIn(y, m)),
            anchor.hour,
            anchor.minute,
          );
        case Frequency.yearly:
          final y = anchor.year + n;
          d = DateTime(
            y,
            anchor.month,
            min(anchor.day, daysIn(y, anchor.month)),
            anchor.hour,
            anchor.minute,
          );
      }
      if (d.isAfter(until)) return out;
      out.add(d);
    }
  }

  group('EXP-10 criterion "If the app was not opened for 3 months, all missed '
      'entries are created once, with correct dates, and no duplicates"', () {
    for (final f in Frequency.values) {
      test(
        '${f.name}: a 3-month jump creates exactly the missed occurrences',
        () async {
          // A yearly rule anchored a year back so the gap contains one.
          final anchor = f == Frequency.yearly
              ? DateTime(2025, 12, 20, 9)
              : DateTime(2026, 10, 14, 9);
          final id = await rule(anchor, frequency: f);
          x.clock.value = DateTime(2027, 1, 14, 10);
          final created = await generator.runDue();

          final want = expected(anchor, f, x.clock.now());
          expect(await rowsOf(id), want, reason: 'exact dates, first included');
          expect(
            created,
            want.length - 1,
            reason: 'the first was saved by hand',
          );
          expect((await rowsOf(id)).toSet(), hasLength(want.length));

          expect(
            await generator.runDue(),
            0,
            reason: 'running again → nothing',
          );
          expect(await rowsOf(id), want);
          final r = (await rules.findById(id))!;
          expect(r.nextRunAt.isAfter(x.clock.now()), isTrue);
        },
      );
    }
  });

  test('a monthly rule on the 31st through generateDue lands on each month '
      'end for 2 years', () async {
    final anchor = DateTime(2027, 1, 31, 8);
    final id = await rule(anchor);
    x.clock.value = DateTime(2029, 1, 31, 9);
    await generator.runDue();
    final rows = await rowsOf(id);
    expect(rows, expected(anchor, Frequency.monthly, x.clock.now()));
    expect(rows, hasLength(25));
    expect(rows[1], DateTime(2027, 2, 28, 8));
    expect(rows[3], DateTime(2027, 4, 30, 8));
    expect(rows[4], DateTime(2027, 5, 31, 8));
    expect(rows[13], DateTime(2028, 2, 29, 8));
  });

  test('a yearly rule on 29 Feb catches up 28 Feb in non-leap years', () async {
    final id = await rule(
      DateTime(2028, 2, 29, 7),
      frequency: Frequency.yearly,
    );
    x.clock.value = DateTime(2032, 3);
    await generator.runDue();
    expect(await rowsOf(id), [
      DateTime(2028, 2, 29, 7),
      DateTime(2029, 2, 28, 7),
      DateTime(2030, 2, 28, 7),
      DateTime(2031, 2, 28, 7),
      DateTime(2032, 2, 29, 7),
    ]);
  });

  group('missed periods: many small runs equal one big run', () {
    for (final f in Frequency.values) {
      test('${f.name}: 40 runs at random times over 3 years', () async {
        final anchor = DateTime(2026, 1, 31, 9, 30);
        x.clock.value = anchor;
        final id = await rule(anchor, frequency: f);
        final rnd = Random(f.index + 7);
        var t = anchor;
        for (var i = 0; i < 40; i++) {
          t = t.add(Duration(hours: rnd.nextInt(24 * 60)));
          x.clock.value = t;
          await generator.runDue();
          // Never anything after "now", never a duplicate, never a gap.
          expect(
            await rowsOf(id),
            expected(anchor, f, t),
            reason: 'run $i at $t',
          );
        }
      });
    }

    test('an occurrence exactly at "now" is created once', () async {
      final id = await rule(
        DateTime(2026, 10, 1, 9),
        frequency: Frequency.daily,
      );
      x.clock.value = DateTime(2026, 10, 3, 9);
      await generator.runDue();
      expect((await rowsOf(id)).last, DateTime(2026, 10, 3, 9));
      await generator.runDue();
      expect(await rowsOf(id), hasLength(3));
    });
  });

  group('no duplicates', () {
    test('two runDue() calls started together on the same database', () async {
      final id = await rule(
        DateTime(2026, 7, 14, 9),
        frequency: Frequency.daily,
      );
      x.clock.value = DateTime(2026, 10, 14, 10);
      final results = await Future.wait([
        generator.runDue(),
        generator.runDue(),
      ]);
      final rows = await rowsOf(id);
      expect(rows.toSet(), hasLength(rows.length));
      expect(
        rows,
        expected(DateTime(2026, 7, 14, 9), Frequency.daily, x.clock.now()),
      );
      expect(results.reduce((a, b) => a + b), rows.length - 1);
    });

    test(
      'generateDue with a stale next run (another run won) creates nothing',
      () async {
        final id = await rule(DateTime(2026, 7, 14, 9));
        final now = DateTime(2026, 10, 14, 10);
        final first = await rules.generateDue(id, now);
        expect(first, hasLength(3));
        expect(await rules.generateDue(id, now), isEmpty);
        expect(await rowsOf(id), hasLength(4));
      },
    );

    test('the clock moved back creates nothing; moved forward creates the '
        'rest', () async {
      final id = await rule(
        DateTime(2026, 10, 1, 9),
        frequency: Frequency.daily,
      );
      x.clock.value = DateTime(2026, 10, 10, 10);
      await generator.runDue();
      expect(await rowsOf(id), hasLength(10));
      x.clock.value = DateTime(2026, 9);
      expect(await generator.runDue(), 0);
      x.clock.value = DateTime(2026, 10, 12, 10);
      expect(await generator.runDue(), 2);
      expect(await rowsOf(id), hasLength(12));
    });
  });

  test('the end date is respected and the rule becomes ended', () async {
    final id = await rule(
      DateTime(2026, 10, 1, 9),
      frequency: Frequency.weekly,
      endDate: DateTime(2026, 10, 22),
    );
    x.clock.value = DateTime(2027);
    await generator.runDue();
    expect(await rowsOf(id), [
      DateTime(2026, 10, 1, 9),
      DateTime(2026, 10, 8, 9),
      DateTime(2026, 10, 15, 9),
      DateTime(2026, 10, 22, 9),
    ]);
    final r = (await rules.findById(id))!;
    expect(r.isActive, isFalse);
    expect(r.isEnded, isTrue);
    expect(await rules.dueRuleIds(DateTime(2030)), isEmpty);
  });

  test('a rule with an archived account still generates', () async {
    final id = await rule(DateTime(2026, 9, 14, 9));
    await x.accounts.setArchived(cash, archived: true);
    x.clock.value = DateTime(2026, 11, 14, 10);
    await generator.runDue();
    expect(await rowsOf(id), hasLength(3));
  });

  test(
    'a recurring transfer generates transfers with the same accounts',
    () async {
      final id = await rule(DateTime(2026, 8, 1, 9), type: TxnType.transfer);
      x.clock.value = DateTime(2026, 10, 2);
      await generator.runDue();
      final rows = await (x.db.select(
        x.db.transactions,
      )..where((t) => t.recurringRuleId.equals(id))).get();
      expect(rows, hasLength(3));
      for (final r in rows) {
        expect(r.type, TxnType.transfer);
        expect(r.accountId, cash);
        expect(r.toAccountId, sbi);
        expect(r.categoryId, isNull);
        expect(r.note, 'auto');
      }
    },
  );

  test('FR-029: generated current-month expenses are checked against budgets; '
      'past-month ones are not (Q2)', () async {
    final settings = SettingsRepositoryImpl(
      x.db,
      knownModuleIds: const ['expense'],
    );
    final budgets = DriftBudgetRepository(x.db, x.clock, settings);
    final notifier = FakeBudgetAlertNotifier();
    generator = RecurringGenerator(
      rules,
      x.clock,
      alerts: BudgetAlertChecker(
        budgets,
        notifier,
        FakeNotificationGate(),
        x.clock,
      ),
    );
    // ₹500 daily rule; ₹1,000 budgets for September and October.
    await budgets.create(
      BudgetDraft(
        monthKey: '2026-09',
        categoryId: rent,
        limitMinor: 100000,
        rollover: true,
      ),
    );
    await budgets.create(
      BudgetDraft(
        monthKey: '2026-10',
        categoryId: rent,
        limitMinor: 100000,
        rollover: true,
      ),
    );
    await rule(DateTime(2026, 9, 25, 9), frequency: Frequency.daily);
    x.clock.value = DateTime(2026, 10, 2, 10);
    await generator.runDue();
    expect(notifier.sent.map((a) => (a.monthKey, a.threshold.name)), [
      ('2026-10', 'p100'),
    ], reason: 'Oct 1–2 reach ₹1,000; September is never alerted');
  });

  test('a failing rule does not stop the others', () async {
    final good = await rule(DateTime(2026, 9, 14, 9));
    await rule(DateTime(2026, 9, 14, 9));
    // Corrupt the second rule's frequency so reading it throws.
    await x.db.customStatement(
      'UPDATE recurring_rules SET frequency = 9 '
      "WHERE id <> '$good'",
    );
    x.clock.value = DateTime(2026, 10, 14, 10);
    expect(await generator.runDue(), 1);
    expect(await rowsOf(good), hasLength(2));
  });

  test(
    'a daily rule a year behind creates 365 rows in under 200 ms',
    tags: ['perf'],
    () async {
      final id = await rule(
        DateTime(2025, 10, 14, 9),
        frequency: Frequency.daily,
      );
      final sw = Stopwatch()..start();
      final created = await generator.runDue();
      sw.stop();
      expect(created, 365);
      expect(await rowsOf(id), hasLength(366));
      expect(sw.elapsedMilliseconds, lessThan(200));
    },
  );
}
