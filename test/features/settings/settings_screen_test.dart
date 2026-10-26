import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/settings/presentation/screens/modules_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/themes_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/web_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_webview.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';
import '../expense/fakes.dart';

/// SET-01 More / Settings (feature 007 T022, T048, T061, T068; spec US4,
/// US6, US8; FR-001 – FR-014).
void main() {
  setUp(FakeWebViewPlatform.install);

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true, locale: 'en'),
    bool devTools = false,
    ModuleRegistry? registry,
    FakeNotificationService? notifications,
    FakeExternalLauncher? launcher,
    FakeAppReviewService? review,
    FakeTextSharer? sharer,
    FakeAppResetService? reset,
    ExpenseFakes? expense,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 2600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = FakeSettingsRepository(initial: initial);
    await pumpTestApp(
      tester,
      settings: settings,
      debugTools: devTools,
      registry: registry,
      notifications: notifications,
      launcher: launcher,
      review: review,
      sharer: sharer,
      reset: reset,
      expense: expense,
    );
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    return settings;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('SET-01 layout', () {
    testWidgets('US4-1 the premium card first, then the sections in order; '
        'no ad privacy row unless the consent SDK asks (feature 009)', (
      tester,
    ) async {
      await open(tester);
      expect(find.byKey(const Key('premium_card')), findsOneWidget);
      const order = [
        'General',
        'Appearance',
        'Modules',
        'Notifications',
        'Security',
        'Data',
        'Privacy',
        'About',
      ];
      final tops = [
        for (final title in order) tester.getTopLeft(find.text(title).first).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      for (final absent in ['Ad privacy choices', 'Developer']) {
        expect(find.text(absent), findsNothing, reason: absent);
      }
    });

    testWidgets('US4-6 dev flavor: the Developer section has the debug '
        'switch, and toggling it writes the setting (FR-013)', (tester) async {
      final settings = await open(tester, devTools: true);
      expect(find.text('Developer'), findsOneWidget);
      final sw = find.byKey(const Key('debug_unlock_all'));
      await tester.ensureVisible(sw);
      expect(tester.widget<SwitchListTile>(sw).value, isFalse);
      await tester.tap(sw);
      await tester.pumpAndSettle();
      expect(settings.calls['setDebugUnlockAll'], 1);
      expect(settings.current.debugUnlockAll, isTrue);
      expect(tester.widget<SwitchListTile>(sw).value, isTrue);
    });

    testWidgets('Appearance opens SET-04; Modules opens SET-06 (FR-006)', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'settings_theme');
      expect(find.byType(ThemesScreen), findsOneWidget);
      routerOf(tester).go(Routes.more);
      await tester.pumpAndSettle();
      await tapKey(tester, 'settings_modules');
      expect(find.byType(ModulesScreen), findsOneWidget);
    });
  });

  group('SET-01 General', () {
    testWidgets('US4-2 Gujarati applies at once and is stored; System '
        'default stores null', (tester) async {
      final settings = await open(tester);
      await tapKey(tester, 'settings_language');
      await tester.tap(find.byKey(const Key('language_gu')));
      await tester.pumpAndSettle();
      expect(settings.current.locale, 'gu');
      expect(find.text('સામાન્ય'), findsOneWidget); // "General"

      await tapKey(tester, 'settings_language');
      await tester.tap(find.byKey(const Key('language_system')));
      await tester.pumpAndSettle();
      expect(settings.current.locale, isNull);
    });

    testWidgets('SET-01 AC: changing currency changes formatting only; stored '
        'amounts are not converted', (tester) async {
      final expense = ExpenseFakes.withDefaults();
      final txn = expense.addTransaction(amount: 125000, category: 'food');
      final settings = await open(tester, expense: expense);

      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(find.textContaining('₹1,250.00'), findsWidgets);

      routerOf(tester).go(Routes.more);
      await tester.pumpAndSettle();
      await tapKey(tester, 'settings_currency');
      await tester.enterText(find.byKey(const Key('currency_search')), 'USD');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('currency_USD')));
      await tester.pumpAndSettle();
      expect(settings.current.currencyCode, 'USD');

      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(find.textContaining(r'$1,250.00'), findsWidgets);
      expect(find.textContaining('₹1,250.00'), findsNothing);
      expect(expense.world.transactions[txn.id]!.amountMinor, 125000);

      await settings.setCurrency('INR');
      await tester.pumpAndSettle();
      expect(find.textContaining('₹1,250.00'), findsWidgets);
      expect(expense.world.transactions[txn.id]!.amountMinor, 125000);
    });

    testWidgets('US4-4 first day of week offers Monday, Saturday, Sunday; '
        'Sunday stores 7', (tester) async {
      final settings = await open(tester);
      await tapKey(tester, 'settings_first_day');
      expect(find.byKey(const Key('first_day_1')), findsOneWidget);
      expect(find.byKey(const Key('first_day_6')), findsOneWidget);
      expect(find.byKey(const Key('first_day_7')), findsOneWidget);
      await tester.tap(find.byKey(const Key('first_day_7')));
      await tester.pumpAndSettle();
      expect(settings.current.firstDayOfWeek, 7);
      expect(
        find.descendant(
          of: find.byKey(const Key('settings_first_day')),
          matching: find.text('Sunday'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('US4-5 the date format sheet shows today in all 4 formats; '
        'dd/MM/yyyy stores ddMMy', (tester) async {
      final settings = await open(tester);
      await tapKey(tester, 'settings_date_format');
      for (final id in ['dMMMy', 'ddMMy', 'mmddy', 'iso']) {
        expect(find.byKey(Key('date_format_$id')), findsOneWidget);
      }
      // fakeNow is 14 Oct 2026 in the expense fakes.
      expect(find.text('14/10/2026'), findsOneWidget);
      expect(find.text('2026-10-14'), findsOneWidget);
      await tester.tap(find.byKey(const Key('date_format_ddMMy')));
      await tester.pumpAndSettle();
      expect(settings.current.dateFormat, 'ddMMy');
    });
  });

  group('SET-01 Notifications', () {
    ModuleRegistry registryOf(List<FakeTrackerModule> modules) =>
        ModuleRegistry(modules);

    testWidgets('US6-1 master off: stored, other rows disabled with values '
        'kept, every visible module reconciles', (tester) async {
      final expense = FakeTrackerModule(id: 'expense');
      final habit = FakeTrackerModule(id: 'habit');
      final settings = await open(
        tester,
        registry: registryOf([expense, habit]),
      );
      await tapKey(tester, 'settings_notifications_master');
      expect(settings.current.notificationsEnabled, isFalse);
      expect(expense.notificationSettingsChangedCalls, 1);
      expect(habit.notificationSettingsChangedCalls, 1);

      final budget = tester.widget<SwitchListTile>(
        find.byKey(const Key('settings_budget_alerts')),
      );
      expect(budget.onChanged, isNull);
      expect(budget.value, isTrue);
      final reminders = tester.widget<SwitchListTile>(
        find.byKey(const Key('settings_habit_reminders')),
      );
      expect(reminders.onChanged, isNull);
      expect(reminders.value, isTrue);
      expect(
        tester
            .widget<ListTile>(
              find.byKey(const Key('settings_daily_summary_time')),
            )
            .enabled,
        isFalse,
      );
    });

    testWidgets('US6-2 budget alerts off is stored and modules reconcile', (
      tester,
    ) async {
      final expense = FakeTrackerModule(id: 'expense');
      final settings = await open(
        tester,
        registry: registryOf([expense, FakeTrackerModule(id: 'habit')]),
      );
      await tapKey(tester, 'settings_budget_alerts');
      expect(settings.current.budgetAlertsEnabled, isFalse);
      expect(expense.notificationSettingsChangedCalls, 1);
    });

    testWidgets('US6-4 Habit reminders shows only with the Habit module on', (
      tester,
    ) async {
      final habit = FakeTrackerModule(id: 'habit');
      final settings = await open(
        tester,
        registry: registryOf([FakeTrackerModule(id: 'expense'), habit]),
      );
      await tapKey(tester, 'settings_habit_reminders');
      expect(settings.current.habitRemindersEnabled, isFalse);
      expect(habit.notificationSettingsChangedCalls, 1);

      await settings.setModules(
        order: const ['expense', 'habit'],
        enabled: const ['expense'],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings_habit_reminders')), findsNothing);
    });

    testWidgets('US6-3 daily summary time: 9:00 PM by default; picking 20:30 '
        'stores it and shows 8:30 PM; the daily summary moves to 8:30 PM '
        '(feature 008 T112)', (tester) async {
      final notifications = FakeNotificationService();
      final settings = await open(tester, notifications: notifications);
      final row = find.byKey(const Key('settings_daily_summary_time'));
      expect(
        find.descendant(of: row, matching: find.text('9:00 PM')),
        findsOneWidget,
      );
      await tapKey(tester, 'settings_daily_summary_time');
      // Switch the dial picker to text input and type 8:30 PM.
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '8');
      await tester.enterText(fields.at(1), '30');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(settings.current.dailySummaryTime, '20:30');
      expect(
        find.descendant(of: row, matching: find.text('8:30 PM')),
        findsOneWidget,
      );
      final summary = notifications.scheduled[dailySummaryNotificationId]!;
      expect((summary.firstAt.hour, summary.firstAt.minute), (20, 30));
      expect(summary.repeat, isNull);
    });

    testWidgets('US6-5 blocked by the OS: a note with "Open settings"', (
      tester,
    ) async {
      final launcher = FakeExternalLauncher();
      await open(
        tester,
        notifications: FakeNotificationService(allowed: false),
        launcher: launcher,
      );
      expect(
        find.text('Notifications are blocked for DailyTrack'),
        findsOneWidget,
      );
      await tapKey(tester, 'settings_open_system_settings');
      expect(launcher.notificationSettingsCalls, 1);
    });

    testWidgets('no blocked note while notifications are allowed', (
      tester,
    ) async {
      await open(tester);
      expect(
        find.byKey(const Key('settings_notifications_blocked')),
        findsNothing,
      );
    });

    testWidgets('feature 008 FR-042 without exact alarms: "Reminders may '
        'arrive a few minutes late" with "Allow exact timing"', (tester) async {
      final notifications = FakeNotificationService()
        ..exactAllowed = false
        ..grantExactOnRequest = true;
      await open(tester, notifications: notifications);
      expect(
        find.text('Reminders may arrive a few minutes late'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('settings_exact_allow')));
      await tester.pumpAndSettle();
      expect(notifications.requestExactCalls, 1);
      expect(find.byKey(const Key('settings_exact_note')), findsNothing);
    });

    testWidgets('feature 008 exact alarms allowed: no note', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('settings_exact_note')), findsNothing);
    });

    testWidgets('feature 008 the note hides while notifications are off', (
      tester,
    ) async {
      await open(
        tester,
        initial: const AppSettings(
          onboardingDone: true,
          locale: 'en',
          notificationsEnabled: false,
        ),
        notifications: FakeNotificationService()..exactAllowed = false,
      );
      expect(find.byKey(const Key('settings_exact_note')), findsNothing);
    });

    testWidgets('feature 008 R18 turning notifications off cancels the daily '
        'summary', (tester) async {
      final notifications = FakeNotificationService();
      await open(tester, notifications: notifications);
      await tester.tap(find.byKey(const Key('settings_notifications_master')));
      await tester.pumpAndSettle();
      expect(notifications.cancelled, contains(dailySummaryNotificationId));
      expect(notifications.scheduled[dailySummaryNotificationId], isNull);
    });
  });

  group('SET-01 Privacy and About', () {
    testWidgets('US8-1 Privacy policy and Terms open the web page routes', (
      tester,
    ) async {
      await open(tester);
      await tester.ensureVisible(
        find.byKey(const Key('settings_privacy_policy')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_privacy_policy')));
      // The web view's loading bar never settles; pump a few frames.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(WebPageScreen), findsOneWidget);
      expect(find.text('Privacy policy'), findsWidgets);
    });

    testWidgets('US8-2 Rate us asks the review service', (tester) async {
      final review = FakeAppReviewService();
      await open(tester, review: review);
      await tapKey(tester, 'settings_rate');
      expect(review.calls, 1);
    });

    testWidgets('US8-3 Share app shares the store link', (tester) async {
      final sharer = FakeTextSharer();
      await open(tester, sharer: sharer);
      await tapKey(tester, 'settings_share_app');
      expect(
        sharer.shared.single.text,
        contains(
          'play.google.com/store/apps/details?id='
          'com.midexcode.daily.track.dailytrack',
        ),
      );
    });

    testWidgets('US8-4 Send feedback drafts an email with device facts only', (
      tester,
    ) async {
      final launcher = FakeExternalLauncher();
      await open(
        tester,
        launcher: launcher,
        initial: const AppSettings(
          onboardingDone: true,
          locale: 'en',
          currencyCode: 'USD',
          selectedTheme: 'saffron',
        ),
      );
      await tapKey(tester, 'settings_feedback');
      final mail = launcher.emails.single;
      expect(mail.subject, contains('1.0.0'));
      expect(mail.body, contains('1.0.0 (1)'));
      expect(mail.body, contains('Google Pixel 7'));
      expect(mail.body, contains('14 (API 34)'));
      for (final setting in ['USD', 'saffron']) {
        expect(mail.body, isNot(contains(setting)));
      }
    });

    testWidgets('US8-4 without an email app: the address with Copy email', (
      tester,
    ) async {
      final launcher = FakeExternalLauncher()..emailHandled = false;
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await open(tester, launcher: launcher);
      await tapKey(tester, 'settings_feedback');
      expect(find.textContaining('No email app found'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings_copy_email')));
      await tester.pumpAndSettle();
      expect(copied, contains('@'));
      expect(find.text('Email copied'), findsOneWidget);
    });

    testWidgets('US8-5 version shows "1.0.0 (1)"; licenses open the license '
        'page', (tester) async {
      await open(tester);
      expect(
        find.descendant(
          of: find.byKey(const Key('settings_version')),
          matching: find.text('1.0.0 (1)'),
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'settings_licenses');
      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  group('SET-01 Data (T064)', () {
    testWidgets('US7 Erase all data comes after Backup and restore, in the '
        'error color; it erases only after both confirmations', (tester) async {
      final reset = FakeAppResetService();
      await open(tester, reset: reset);
      final row = find.byKey(const Key('settings_erase_all'));
      await tapKey(tester, 'settings_erase_all');
      final title = tester.widget<Text>(
        find.descendant(of: row, matching: find.text('Erase all data')),
      );
      final context = tester.element(row);
      expect(title.style?.color, Theme.of(context).colorScheme.error);
      // Backup and restore and Export data (feature 008) come first.
      expect(find.byKey(const Key('settings_backup')), findsOneWidget);
      expect(find.byKey(const Key('settings_export')), findsOneWidget);

      expect(find.text('Erase all data?'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(reset.calls, 0);
      await tester.enterText(
        find.byKey(const Key('typed_confirm_field')),
        'DELETE',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('typed_confirm_button')));
      await tester.pumpAndSettle();
      expect(reset.calls, 1);
    });
  });
}
