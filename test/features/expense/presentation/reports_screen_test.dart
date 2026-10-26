import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/screens/reports_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/breakdown_bars.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/category_donut.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/income_expense_bar.dart';
import 'package:dailytrack/features/expense/presentation/widgets/charts/trend_line.dart';
import 'package:dailytrack/features/expense/presentation/widgets/summary_strip.dart';
import 'package:dailytrack/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-11 Reports (T085, T094): US4 scenarios 1–7 and US5 scenarios 1–4, 8,
/// with fakes only. "Now" is Wednesday 14 Oct 2026.
void main() {
  /// October: salary ₹90,000, rent ₹5,000, food ₹250 + ₹120 (card), and a
  /// transfer. September: food ₹300.
  ExpenseFakes october() => ExpenseFakes.withDefaults()
    ..addAccount('SBI', id: 'sbi', type: AccountType.bank)
    ..addTransaction(
      amount: 9000000,
      category: 'income_salary',
      type: TxnType.income,
      at: DateTime(2026, 10, 1, 10),
    )
    ..addTransaction(
      amount: 500000,
      category: 'rent',
      at: DateTime(2026, 10, 5, 9),
    )
    ..addTransaction(
      amount: 25000,
      category: 'food',
      at: DateTime(2026, 10, 13, 13),
      note: 'Lunch',
    )
    ..addTransaction(
      amount: 12000,
      category: 'food',
      account: 'sbi',
      mode: PaymentMode.card,
      at: DateTime(2026, 10, 14, 8),
      note: 'Breakfast',
    )
    ..addTransaction(
      amount: 100000,
      type: TxnType.transfer,
      toAccount: 'sbi',
      at: DateTime(2026, 10, 2),
    )
    ..addTransaction(
      amount: 30000,
      category: 'food',
      at: DateTime(2026, 9, 20, 9),
    );

  Future<ExpenseFakes> open(
    WidgetTester tester, {
    ExpenseFakes? fakes,
    bool unlocked = false,
    FakeFeatureGate? gate,
    Size size = const Size(412, 915),
    FakeRewardedUnlockPresenter? presenter,
  }) {
    final g = gate ?? FakeFeatureGate();
    if (unlocked) g.set(FeatureKey.advancedReports, unlocked: true);
    return pumpExpenseApp(
      tester,
      fakes: fakes ?? october(),
      location: Routes.expenseReports,
      gate: g,
      size: size,
      rewardedPresenter: presenter,
    );
  }

  Future<void> tab(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey('tab_$key')));
    await tester.pumpAndSettle();
  }

  testWidgets('EXP-11 US4-1 a period selector on this month and the four '
      'tabs in order; the picker offers Week, Month, Year, Custom', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    final xs = [
      for (final t in ['overview', 'categories', 'trends', 'accounts'])
        tester.getTopLeft(find.byKey(ValueKey('tab_$t'))).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));

    await tester.tap(find.text('October 2026'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('period_kind_day')), findsNothing);
    for (final k in ['week', 'month', 'year', 'custom']) {
      expect(find.byKey(ValueKey('period_kind_$k')), findsOneWidget);
    }
    // Year and Custom are locked without the unlock (Q1).
    for (final k in ['year', 'custom']) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('period_kind_$k')),
          matching: find.byIcon(Icons.lock),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('period_kind_week')),
        matching: find.byIcon(Icons.lock),
      ),
      findsNothing,
    );
  });

  testWidgets('EXP-11 US4-2 Overview: net savings, savings rate, average '
      'daily spend, the income vs expense chart and the top 3', (tester) async {
    await open(tester);
    Finder inCard(String key, String text) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.text(text),
    );
    // Expense ₹5,370; net ₹84,630; rate 94%; ₹5,370 ÷ 14 days = ₹383.57.
    expect(inCard('report_net', '+₹84,630.00'), findsOneWidget);
    expect(inCard('report_savings_rate', '94%'), findsOneWidget);
    expect(inCard('report_avg_daily', '₹383.57'), findsOneWidget);
    expect(find.byType(IncomeExpenseBar), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Income ₹90,000.00, expense ₹5,370.00')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('top_rent')), findsOneWidget);
    expect(find.byKey(const ValueKey('top_food')), findsOneWidget);
    expect(find.text('93% of spending'), findsOneWidget);
  });

  testWidgets('EXP-11 criterion "Chart totals match the EXP-01 summary strip '
      'for the same period" (widget level)', (tester) async {
    await open(tester, unlocked: true);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.byKey(const Key('report_net')), findsOneWidget);
    final reportsNet = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('report_net')),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data)
        .toList();
    expect(reportsNet, contains('−₹300.00'));

    // EXP-01 for September shows the same totals.
    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(SummaryStrip),
        matching: find.textContaining('300.00'),
      ),
      findsWidgets,
    );
  });

  testWidgets('EXP-11 US4-3 Categories: a donut with a text legend; tapping a '
      'legend row lists that category, newest first; a row opens EXP-03', (
    tester,
  ) async {
    await open(tester);
    await tab(tester, 'categories');
    expect(find.byType(CategoryDonut), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Expense by category: Rent 93%, Food 7%')),
      findsOneWidget,
    );
    final food = find.byKey(const ValueKey('legend_food'));
    expect(
      find.descendant(of: food, matching: find.text('7% of spending')),
      findsOneWidget,
    );
    await tester.tap(food);
    await tester.pumpAndSettle();
    final rows = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('report_txn_'),
    );
    expect(rows, findsNWidgets(2));
    final ys = [
      tester.getTopLeft(find.text('Breakfast')).dy,
      tester.getTopLeft(find.text('Lunch')).dy,
    ];
    expect(ys.first < ys.last, isTrue, reason: 'newest first');
    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  });

  testWidgets('EXP-11 US4-4 an empty period shows "No transactions in …" with '
      '"Add expense"', (tester) async {
    await open(tester, fakes: ExpenseFakes.withDefaults());
    expect(find.text('No transactions in October 2026'), findsOneWidget);
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('save_transaction')), findsOneWidget);
  });

  testWidgets('EXP-11 US4-5 pull to refresh recomputes; new transactions '
      'update the figures', (tester) async {
    final f = await open(tester);
    await tester.fling(
      find.byKey(const Key('report_overview')),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report_net')), findsOneWidget);
    f.addTransaction(
      amount: 30000,
      category: 'food',
      at: DateTime(2026, 10, 14, 9),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('report_net')),
        matching: find.text('+₹84,330.00'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('EXP-11 US4-7 "Export this report" is the only action, and '
      'the bottom banner is the only ad (feature 009, spec §11)', (
    tester,
  ) async {
    await open(tester);
    final scaffold = tester.widget<AppScaffold>(find.byType(AppScaffold).last);
    expect(scaffold.bannerSlot, isA<AppBannerAd>());
    expect(scaffold.actions, hasLength(1));
    expect(find.byKey(const Key('reports_export')), findsOneWidget);
    expect(find.byTooltip('Export this report'), findsOneWidget);
  });

  testWidgets('EXP-11 loading shows a skeleton only after 300 ms; an error '
      'shows "Try again"', (tester) async {
    final f = october()..world.watchDelay = const Duration(seconds: 1);
    await pumpExpenseApp(tester, fakes: f);
    routerOf(tester).go(Routes.expenseReports);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonCard), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SkeletonCard), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report_net')), findsOneWidget);

    f.world
      ..watchDelay = Duration.zero
      ..failWatch = StateError('db');
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    f.world.failWatch = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report_net')), findsOneWidget);
  });

  group('locked (US5 s1, s2, FR-040)', () {
    testWidgets('EXP-11 AC locked tabs show a blurred preview and a "Watch '
        'an ad to unlock for 24 hours" button (feature 009)', (tester) async {
      await open(tester);
      for (final t in ['trends', 'accounts']) {
        expect(find.byKey(ValueKey('tab_lock_$t')), findsOneWidget);
        await tab(tester, t);
        final overlay = find.byType(LockedFeatureOverlay);
        expect(overlay, findsOneWidget);
        expect(
          find.descendant(of: overlay, matching: find.byType(ImageFiltered)),
          findsOneWidget,
        );
        expect(find.text('Advanced reports are part of Pro.'), findsOneWidget);
        expect(find.text('Watch an ad to unlock for 24 hours'), findsOneWidget);
        final getPro = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Get Pro'),
        );
        expect(getPro.onPressed, isNotNull);
        // Sample data only: none of the user's amounts are in the tree.
        for (final amount in ['5,000.00', '250.00', '120.00', '5,370.00']) {
          expect(find.textContaining(amount), findsNothing, reason: amount);
        }
      }
      expect(find.byKey(const ValueKey('tab_lock_overview')), findsNothing);
      // Tabs merge their own role text into the label.
      expect(find.bySemanticsLabel(RegExp('Trends, locked')), findsOneWidget);
    });

    testWidgets('FR-032 "Watch an ad" opens PRM-02 for 24 hours of advanced '
        'reports; the tab opens when the gate does', (tester) async {
      final gate = FakeFeatureGate();
      final presenter = FakeRewardedUnlockPresenter();
      await open(tester, gate: gate, presenter: presenter);
      await tab(tester, 'trends');
      await tester.tap(find.byKey(const Key('locked_watch_ad')));
      await tester.pumpAndSettle();
      final request = presenter.requests.single;
      expect(request.key, FeatureKey.advancedReports);
      expect(request.duration, const Duration(hours: 24));
      // The reward's unlock reaches the gate; the tab opens in place.
      gate.set(FeatureKey.advancedReports, unlocked: true);
      await tester.pumpAndSettle();
      expect(find.byType(LockedFeatureOverlay), findsNothing);
    });

    testWidgets('"Get Pro" opens PRM-01', (tester) async {
      await open(tester);
      await tab(tester, 'trends');
      await tester.tap(find.byKey(const Key('locked_get_pro')));
      await tester.pumpAndSettle();
      expect(find.byType(PremiumScreen), findsOneWidget);
    });

    testWidgets('EXP-11 US5-2 Year and older months lock every tab', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('period_locked')), findsOneWidget);
      expect(find.byType(LockedFeatureOverlay), findsOneWidget);
      expect(find.byKey(const ValueKey('tab_lock_overview')), findsOneWidget);

      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.byType(LockedFeatureOverlay), findsNothing, reason: 'Sep');
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.byType(LockedFeatureOverlay), findsOneWidget);
      expect(find.byKey(const Key('period_locked')), findsOneWidget);
    });

    testWidgets('EXP-11 US5-8 the gate flipping while open shows or hides the '
        'overlay without leaving', (tester) async {
      final gate = FakeFeatureGate();
      await open(tester, gate: gate);
      await tab(tester, 'trends');
      expect(find.byType(LockedFeatureOverlay), findsOneWidget);
      gate.set(FeatureKey.advancedReports, unlocked: true);
      await tester.pumpAndSettle();
      expect(find.byType(LockedFeatureOverlay), findsNothing);
      expect(find.byType(TrendLine), findsOneWidget);
      expect(find.byKey(const ValueKey('tab_lock_trends')), findsNothing);
      gate.set(FeatureKey.advancedReports, unlocked: false);
      await tester.pumpAndSettle();
      expect(find.byType(LockedFeatureOverlay), findsOneWidget);
      expect(find.byType(ReportsScreen), findsOneWidget);
    });
  });

  group('unlocked (US5 s3, s4)', () {
    testWidgets('EXP-11 US5-3 Trends: a solid and a dashed line with a legend '
        'naming both', (tester) async {
      await open(tester, unlocked: true);
      await tab(tester, 'trends');
      expect(find.byType(TrendLine), findsOneWidget);
      expect(find.text('This period'), findsOneWidget);
      expect(find.text('Previous period'), findsOneWidget);
      expect(find.byKey(const Key('trend_legend_current')), findsOneWidget);
      expect(find.byKey(const Key('trend_legend_previous')), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp('Spending this period ₹5,370.00, previous period ₹300.00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('EXP-11 US5-4 Accounts: bar charts by account and by payment '
        'mode, each bar labeled with its amount', (tester) async {
      await open(tester, unlocked: true);
      await tab(tester, 'accounts');
      expect(find.byType(BreakdownBars), findsNWidgets(2));
      Finder inBars(String key, String text) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.text(text),
      );
      expect(inBars('bars_by_account', 'Cash'), findsOneWidget);
      expect(inBars('bars_by_account', '₹5,250.00'), findsOneWidget);
      expect(inBars('bars_by_account', 'SBI'), findsOneWidget);
      expect(inBars('bars_by_mode', 'Card'), findsOneWidget);
      expect(inBars('bars_by_mode', '₹120.00'), findsOneWidget);
    });
  });

  testWidgets('EXP-11 fits 360 dp at 200% font scale on every tab', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, unlocked: true, size: const Size(360, 800));
    for (final t in ['categories', 'trends', 'accounts', 'overview']) {
      await tab(tester, t);
      expect(tester.takeException(), isNull, reason: t);
    }
  });

  testWidgets('EXP-11 opens from the EXP-01 overflow menu', (tester) async {
    await pumpExpenseApp(tester, fakes: october());
    await tester.tap(find.byKey(const Key('expenses_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_reports')));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsScreen), findsOneWidget);
  });
}
