import 'dart:io';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_detail_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/receipt_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-03 Transaction detail (spec §8, US2-10, T063 and T065).
void main() {
  late ExpenseFakes f;

  setUp(() {
    f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addTransaction(
        id: 'lunch',
        amount: 15550,
        category: 'food',
        note: 'Lunch with team',
        mode: PaymentMode.upi,
        at: DateTime(2026, 10, 14, 13, 5),
      )
      ..addTransaction(
        id: 'move',
        amount: 5000,
        type: TxnType.transfer,
        toAccount: 'sbi',
        at: DateTime(2026, 10, 13, 9),
      );
  });

  /// Opens EXP-01 and taps the row, like a user would.
  Future<void> openDetail(
    WidgetTester tester,
    String id, {
    FakeTextSharer? sharer,
  }) async {
    await pumpExpenseApp(tester, fakes: f, sharer: sharer);
    await tester.tap(find.byKey(ValueKey('txn_$id')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  }

  testWidgets('EXP-03 "Deleting returns to EXP-01 with Undo available."', (
    tester,
  ) async {
    await openDetail(tester, 'lunch');
    await tester.tap(find.byKey(const Key('detail_delete')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionDetailScreen), findsNothing);
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Transaction deleted'), findsOneWidget);
    expect(f.active.map((t) => t.id), isNot(contains('lunch')));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(f.active.map((t) => t.id), contains('lunch'));
    expect(find.byKey(const ValueKey('txn_lunch')), findsOneWidget);
    // Our own delete never shows "no longer exists".
    expect(find.text('This transaction no longer exists'), findsNothing);
    await flushTimers(tester);
  });

  group('EXP-03 US2-10', () {
    testWidgets('shows amount, type, category, account, mode, date and note', (
      tester,
    ) async {
      await openDetail(tester, 'lunch');
      expect(find.text('−₹155.50'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Expense'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.textContaining('14 Oct 2026'), findsOneWidget);
      expect(find.text('Lunch with team'), findsOneWidget);
      // No "Created from recurring rule" link in this feature (T1.6).
      expect(find.textContaining('recurring'), findsNothing);
    });

    testWidgets('SET-01 US4-5 the date follows the date format; the list '
        'header stays relative (feature 007 T049)', (tester) async {
      await pumpExpenseApp(
        tester,
        fakes: f,
        settings: FakeSettingsRepository(
          initial: const AppSettings(
            onboardingDone: true,
            locale: 'en',
            dateFormat: 'ddMMy',
          ),
        ),
      );
      // EXP-01 keeps its relative header ("Today" on fakeNow).
      expect(find.text('Today'), findsWidgets);
      expect(find.textContaining('14/10/2026'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('txn_lunch')));
      await tester.pumpAndSettle();
      expect(find.textContaining('14/10/2026'), findsOneWidget);
      expect(find.textContaining('14 Oct 2026'), findsNothing);
    });

    testWidgets('a transfer shows both accounts and a neutral amount', (
      tester,
    ) async {
      await openDetail(tester, 'move');
      expect(find.text('Cash → SBI'), findsOneWidget);
      expect(find.text('₹50.00'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Transfer'), findsOneWidget);
    });

    testWidgets('Edit opens EXP-02 in edit mode; Duplicate opens a copy', (
      tester,
    ) async {
      await openDetail(tester, 'lunch');
      await tester.tap(find.byKey(const Key('detail_edit')));
      await tester.pumpAndSettle();
      var form = tester.widget<TransactionFormScreen>(
        find.byType(TransactionFormScreen),
      );
      expect(
        form.args,
        const TransactionFormArgs(mode: FormMode.edit, id: 'lunch'),
      );
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('detail_duplicate')));
      await tester.pumpAndSettle();
      form = tester.widget<TransactionFormScreen>(
        find.byType(TransactionFormScreen),
      );
      expect(form.args.duplicateOf, 'lunch');
      expect(form.args.mode, FormMode.add);
    });

    testWidgets('Share sends a localized text summary and no image', (
      tester,
    ) async {
      final sharer = FakeTextSharer();
      await openDetail(tester, 'lunch', sharer: sharer);
      await tester.tap(find.byKey(const Key('detail_share')));
      await tester.pumpAndSettle();
      final text = sharer.shared.single.text;
      expect(text, startsWith('Expense: ₹155.50\nFood · Cash\n'));
      expect(text, contains('14 Oct 2026'));
      // intl separates the time and AM/PM with a narrow no-break space.
      expect(text, contains('1:05'));
      expect(text, endsWith('Note: Lunch with team'));
      expect(text, isNot(contains('receipts/')));
    });

    testWidgets('tapping the receipt opens the zoomable viewer', (
      tester,
    ) async {
      final dir = Directory.systemTemp.createTempSync('receipt');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/r.jpg')..writeAsBytesSync(_png);
      f
        ..addTransaction(
          id: 'with_receipt',
          amount: 99,
          category: 'food',
          receipt: 'receipts/r.jpg',
          at: DateTime(2026, 10, 14, 9, 30),
        )
        ..receiptStore.existing['receipts/r.jpg'] = file.path;

      await openDetail(tester, 'with_receipt');
      await tester.tap(find.byKey(const Key('receipt_thumbnail')));
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptViewer), findsOneWidget);
      expect(find.byKey(const Key('receipt_zoom')), findsOneWidget);
    });

    testWidgets('a missing receipt file shows "Receipt not available"', (
      tester,
    ) async {
      f.addTransaction(
        id: 'gone',
        amount: 99,
        category: 'food',
        receipt: 'receipts/gone.jpg',
        at: DateTime(2026, 10, 14, 9, 30),
      );
      await openDetail(tester, 'gone');
      expect(find.byTooltip('Receipt not available'), findsOneWidget);
      await tester.tap(find.byKey(const Key('receipt_thumbnail')));
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptViewer), findsNothing);
    });

    testWidgets('a row deleted elsewhere shows a message and returns to '
        'EXP-01', (tester) async {
      await openDetail(tester, 'lunch');
      await f.transactions.softDelete('lunch');
      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailScreen), findsNothing);
      expect(find.text('This transaction no longer exists'), findsOneWidget);
      await flushTimers(tester);
    });
  });

  group('EXP-03 states', () {
    testWidgets('loading shows a skeleton only after 300 ms', (tester) async {
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      f.world.watchDelay = const Duration(seconds: 1);
      routerOf(tester).go(Routes.expenseDetailPath('lunch'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SkeletonList), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('Lunch with team'), findsOneWidget);
    });

    testWidgets('a load failure shows the error state; Try again recovers', (
      tester,
    ) async {
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      f.world.failWatch = const ExpenseStorageFailure('boom');
      routerOf(tester).go(Routes.expenseDetailPath('lunch'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      f.world.failWatch = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Lunch with team'), findsOneWidget);
    });
  });
}

/// A 1×1 transparent PNG.
const List<int> _png = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
