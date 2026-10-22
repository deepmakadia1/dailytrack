import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

/// The daily summary (feature 008 T106, FR-036, research R18).
void main() {
  HomeGlance glance(
    DateTime date, {
    int spent = 125000,
    int done = 3,
    bool expense = true,
    bool habits = true,
  }) => HomeGlance(
    date: date,
    spend: expense
        ? GlanceSpend(
            todayMinor: spent,
            currencyCode: 'INR',
            monthStart: DateTime(date.year, date.month),
          )
        : null,
    habits: habits
        ? GlanceHabits(scheduled: 5, done: done, items: const [])
        : null,
  );

  group('textFor', () {
    final day = DateTime(2026, 10, 21);
    final cases = {
      'en': (
        'Spent ₹1,250.00 today · 3/5 habits done',
        'Spent ₹1,250.00 today',
        '3/5 habits done',
      ),
      'hi': (
        'आज ₹1,250.00 खर्च · 3/5 आदतें पूरी',
        'आज ₹1,250.00 खर्च',
        '3/5 आदतें पूरी',
      ),
      'gu': (
        'આજે ₹1,250.00 ખર્ચ · 3/5 આદતો પૂર્ણ',
        'આજે ₹1,250.00 ખર્ચ',
        '3/5 આદતો પૂર્ણ',
      ),
    };
    for (final MapEntry(key: lang, value: (both, spend, habits))
        in cases.entries) {
      test('$lang: both modules, Expense only, Habit only', () {
        final l10n = lookupAppLocalizations(Locale(lang));
        expect(DailySummaryScheduler.textFor(l10n, glance(day)), both);
        expect(
          DailySummaryScheduler.textFor(l10n, glance(day, habits: false)),
          spend,
        );
        expect(
          DailySummaryScheduler.textFor(l10n, glance(day, expense: false)),
          habits,
        );
      });
    }

    test('no module → no text', () {
      expect(
        DailySummaryScheduler.textFor(
          lookupAppLocalizations(const Locale('en')),
          glance(day, expense: false, habits: false),
        ),
        isNull,
      );
    });
  });

  group('reschedule', () {
    late MutableClock clock;
    late FakeNotificationService service;
    late FakeSettingsRepository settings;
    final requested = <DateTime>[];

    DailySummaryScheduler scheduler() => DailySummaryScheduler(
      notifications: service,
      settings: settings,
      clock: clock,
      glanceFor: (day) async {
        requested.add(day);
        // Tomorrow: nothing spent or done yet.
        return day.day == 22 ? glance(day, spent: 0, done: 0) : glance(day);
      },
    );

    setUp(() {
      clock = MutableClock(DateTime(2026, 10, 21, 18));
      service = FakeNotificationService();
      settings = FakeSettingsRepository(
        initial: const AppSettings(locale: 'en'),
      );
      requested.clear();
    });

    test('one one-shot at the next summary time with the current text, '
        'opening Home', () async {
      await scheduler().reschedule(today: glance(DateTime(2026, 10, 21)));
      expect(dailySummaryNotificationId, stableNotificationId('daily-summary'));
      final s = service.scheduled.values.single;
      expect(s.notification.id, dailySummaryNotificationId);
      expect(s.notification.channel, NotificationChannelId.dailySummary);
      expect(s.notification.title, 'Today in DailyTrack');
      expect(s.notification.body, 'Spent ₹1,250.00 today · 3/5 habits done');
      expect(s.notification.payload, '/home');
      expect(s.notification.actions, isEmpty);
      expect(s.firstAt, DateTime(2026, 10, 21, 21));
      expect(s.repeat, isNull);
      expect(s.exact, isTrue);
      expect(requested, isEmpty, reason: 'the given glance is used');
    });

    test("after today's time it uses tomorrow's glance (₹0, 0/N)", () async {
      clock.value = DateTime(2026, 10, 21, 21, 30);
      await scheduler().reschedule();
      final s = service.scheduled.values.single;
      expect(s.firstAt, DateTime(2026, 10, 22, 21));
      expect(s.notification.body, 'Spent ₹0.00 today · 0/5 habits done');
      expect(requested, [DateTime(2026, 10, 22)]);
    });

    test('the user time and inexact fallback', () async {
      await settings.setDailySummaryTime('07:15');
      service.exactAllowed = false;
      await scheduler().reschedule();
      final s = service.scheduled.values.single;
      expect(s.firstAt, DateTime(2026, 10, 22, 7, 15));
      expect(s.exact, isFalse);
    });

    test('master switch off → cancelled only', () async {
      await settings.setNotificationsEnabled(enabled: false);
      await scheduler().reschedule();
      expect(service.scheduled, isEmpty);
      expect(service.cancelled, [dailySummaryNotificationId]);
    });

    test('blocked by the OS → cancelled only', () async {
      service.allowed = false;
      await scheduler().reschedule();
      expect(service.scheduled, isEmpty);
      expect(service.cancelled, [dailySummaryNotificationId]);
    });

    test('no zone → nothing touched', () async {
      service.zoneResolvable = false;
      await scheduler().reschedule();
      expect(service.scheduled, isEmpty);
      expect(service.cancelled, isEmpty);
    });

    test('nextFire', () {
      final now = DateTime(2026, 10, 21, 21);
      expect(
        DailySummaryScheduler.nextFire('21:00', now),
        DateTime(2026, 10, 22, 21),
      );
      expect(
        DailySummaryScheduler.nextFire('21:01', now),
        DateTime(2026, 10, 21, 21, 1),
      );
    });
  });
}
