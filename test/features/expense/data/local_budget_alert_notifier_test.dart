import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/features/expense/data/notifications/local_budget_alert_notifier.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_alert.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

/// LocalBudgetAlertNotifier (T049, research R6, FR-020).
void main() {
  late FakeNotificationService service;

  LocalBudgetAlertNotifier notifier(String lang) => LocalBudgetAlertNotifier(
    service: service,
    l10n: () => lookupAppLocalizations(Locale(lang)),
    categoryName: (id) async => switch (id) {
      'food' => 'expense_cat_food',
      'chai' => 'Chai & snacks',
      _ => null,
    },
  );

  setUp(() => service = FakeNotificationService());

  const food80 = BudgetAlert(
    budgetId: 'b1',
    monthKey: '2026-10',
    categoryId: 'food',
    threshold: BudgetThreshold.p80,
    percent: 85,
  );

  test('80%: title and body name the category and the percentage', () async {
    await notifier('en').notify(food80);
    final n = service.shown.single;
    expect(n.title, 'Food budget at 85%');
    expect(n.body, "You've used 85% of your Food budget this month.");
    expect(n.channel, NotificationChannelId.budgetAlerts);
    expect(n.tag, 'budget');
    expect(n.payload, '/expenses/budgets?month=2026-10');
  });

  test('100% says the budget is used up; Overall is named', () async {
    await notifier('en').notify(
      const BudgetAlert(
        budgetId: 'b2',
        monthKey: '2026-10',
        threshold: BudgetThreshold.p100,
        percent: 135,
      ),
    );
    final n = service.shown.single;
    expect(n.title, 'Overall budget used up');
    expect(n.body, "You've used 135% of your Overall budget this month.");
  });

  test('a custom category is shown as typed', () async {
    await notifier('en').notify(food80.copyWith(categoryId: 'chai'));
    expect(service.shown.single.title, 'Chai & snacks budget at 85%');
  });

  for (final lang in ['hi', 'gu']) {
    test(
      '$lang text comes from ARB with the translated default name',
      () async {
        final l10n = lookupAppLocalizations(Locale(lang));
        await notifier(lang).notify(food80);
        final n = service.shown.single;
        final food = l10n.expense_cat_food;
        expect(n.title, l10n.notif_budget80Title(food, 85));
        expect(n.body, l10n.notif_budget80Body(food, 85));
        expect(n.title, isNot(contains('Food')));
      },
    );
  }

  test('FR-020: the text carries no amount digits or notes', () async {
    for (final lang in ['en', 'hi', 'gu']) {
      service.shown.clear();
      await notifier(lang).notify(food80.copyWith(percent: 7));
      final n = service.shown.single;
      for (final text in [n.title, n.body]) {
        expect(text, isNot(contains('₹')), reason: lang);
        // The only digits are the percentage.
        expect(
          RegExp(r'\d+').allMatches(text).map((m) => m.group(0)),
          everyElement('7'),
          reason: '$lang: $text',
        );
      }
    }
  });

  test('ids are stable per budget and threshold', () async {
    final a = await notifier('en').build(food80);
    final b = await notifier('en').build(food80.copyWith(percent: 99));
    final c = await notifier('en')
        .build(food80.copyWith(threshold: BudgetThreshold.p100));
    expect(a.id, b.id);
    expect(a.id, isNot(c.id));
    expect(a.id, stableNotificationId('b1:p80'));
    expect(stableNotificationId('b1:p80'), lessThan(1 << 31));
    expect(stableNotificationId('b1:p80'), greaterThanOrEqualTo(0));
  });

  test('cancelAll cancels every notification with the budget tag', () async {
    await notifier('en').cancelAll();
    expect(service.cancelledTags, ['budget']);
  });
}
